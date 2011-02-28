/////////////////////////////// -*- C++ -*- ///////////////////////////
//
//	Program to extract superoperators from a GNU Smalltalk image.
//
//	Should only be of interest to the maintainer and to
//	casual hackers.
//
//	Sorry for writing this in C++, did not feel like writing hash
//	table code for the 200th time in my (so far) short life :-) --
//	and later it turned out to be good for integrating gperf...
//
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
//
// Copyright 2003, 2007 Free Software Foundation, Inc.
// Written by Paolo Bonzini.
//
// This file is part of GNU Smalltalk.
//
// GNU Smalltalk is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2, or (at your option) any later
// version.
//
// GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along with
// GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
// Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//
///////////////////////////////////////////////////////////////////////

#if defined __GNUC__ && __GNUC__ < 3
#error Sorry, you need a recent C++ compiler to compile this program.
#endif

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <string>
#include <map>
#include <unistd.h>
#include <sys/wait.h>

#include "observer-list.h"
#include "byte_def.h"
#include "vm_def.h"
#include "table.h"
#include "hash.h"

// GPERF include files
#include "options.h"
#include "search.h"
#include "keyword.h"
#include "keyword-list.h"
#include "positions.h"

bool isLineNo[256];

struct superop_collector;
struct sequence;

// This class collects the (bytecode,bytecode,arg) triplets
// that are candidates for superoperators and keeps in a
// heap data structure // the best ones
class superop_collector {

  // This class represents a sequence that is a candidate
  // for becoming a superoperator
  struct triplet {
    int bc1, bc2, arg, occurrences;

    triplet (int bc1_, int bc2_, int arg_) :
      bc1 (bc1_), bc2(bc2_), arg(arg_), occurrences (0) { }

    bool operator== (const triplet& them) const {
      return bc1 == them.bc1 && bc2 == them.bc2 && arg == them.arg;
    }

    bool operator< (const triplet& them) const {
      if (bc1 < them.bc1) return true;
      if (bc1 > them.bc1) return false;
      if (bc2 < them.bc2) return true;
      if (bc2 > them.bc2) return false;
      return (arg < them.arg);
    }
  };

  // This class does the actual work of maintaining the table
  // of superoperator candidates.  The containing class keeps
  // two of them, one when the fixed argument is the second
  // bytecode's argument, and one when it is the first bytecode's
  // argument.
  //
  // This a simple heap data structure implemented on top of a
  // std::vector, with some additional glue to find an item in
  // the heap: the map associates each superoperator candidate
  // to its current index in the vector.
  class triplet_collector {
    typedef std::vector <triplet *> triplet_heap;
    typedef std::map <triplet, int> triplet_map;

    triplet_heap heap;
    triplet_map triplets;

    int map_at (triplet& t);
    void map_at_put (triplet& t, int index);

  public:
    triplet_collector() : heap (), triplets () { }
    ~triplet_collector();
    void add (int bc1, int bc2, int arg);
    triplet& top () const { return *heap[0]; }
  };

  triplet_collector heap1;
  triplet_collector heap2;
  bool found[256];

 public:
  superop_collector ();
  void found_bytecode (int bc) { found[bc] = true; };
  void with_fixed_arg_1 (int bc1, int arg1, int bc2);
  void with_fixed_arg_2 (int bc1, int bc2, int arg2);
  bool replace_best_in_sequences (observer_list &obs,
				  sequence *s) const;
};

// This class represents a bytecode sequence from which to derive
// the superoperators.
struct sequence {
  sequence *next;
  int n;
  unsigned char *seq;

  sequence (sequence *next_, std::istream& is);
  int all_count ();
  bool all_visit (observer_list& obs);
  void all_replace_with_fixed_arg_1 (int new_bc, int bc1, int arg1, int bc2);
  void all_replace_with_fixed_arg_2 (int new_bc, int bc1, int bc2, int arg2);
  void visit (superop_collector& sc);
  void replace_with_fixed_arg_1 (int new_bc, int bc1, int arg1, int bc2);
  void replace_with_fixed_arg_2 (int new_bc, int bc1, int bc2, int arg2);
  bool includes_superoperators ();
};


superop_collector::triplet_collector::~triplet_collector ()
{
  while (heap.size ())
    {
      triplet *t = heap.back ();
      heap.pop_back ();
      delete t;
    }
}

int
superop_collector::triplet_collector::map_at (triplet& t)
{
  triplet_map::iterator it = triplets.find (t);
  if (it == triplets.end ())
    {
      // Add a triplet to the end of the heap.
      triplet_map::value_type key_val (t, heap.size ());
      triplets.insert (key_val);
      heap.push_back (new triplet (t));
      return key_val.second;
    }
  else
    return it->second;
}

void
superop_collector::triplet_collector::map_at_put (triplet& t, int index)
{
  // Find the triplet in the map and set its index.
  triplet_map::iterator it = triplets.find (t);

  // Should already be in the map!
  if (it == triplets.end ())
    abort ();
  else
    it->second = index;
}

void
superop_collector::triplet_collector::add (int bc1, int bc2, int arg)
{
  triplet t = triplet (bc1, bc2, arg);
  int index = map_at (t);
  triplet& this_triplet = *heap[index];

  // Give a penalty to superoperators that include the line number
  // bytecode, because it is a nop and saves only the decoding,
  // without giving advantages in instruction scheduling and
  // stack movement (simply speaking, a pop/push superoperator
  // is more useful than a line/pop superoperator).
  if (isLineNo[bc1] || isLineNo[bc2])
    this_triplet.occurrences++;
  else
    this_triplet.occurrences += 2;

#if DEBUG
  std::cout << " with weight " << this_triplet.occurrences << " was at index " << index;
#endif

  // Percolate the element towards the top of the heap.
  //
  // Yes my Standard C++ Library knowledge is limited.  I did
  // not find a standard algorithm to percolate an item already
  // in the heap, so I wrote the heap code myself.
  while (index > 0)
    {
      int parent = index / 2;
      triplet& parent_triplet = *heap[parent];
      if (parent_triplet.occurrences < this_triplet.occurrences)
	{
	  // Swap parent and child
	  heap[parent] = &this_triplet;
	  heap[index] = &parent_triplet;
	  map_at_put (this_triplet, parent);
	  map_at_put (parent_triplet, index);
	}
      else
	break;

      index = parent;
    }

#if DEBUG
  std::cout << " now at index " << index << std::endl;
#endif
}

superop_collector::superop_collector () : heap1(), heap2 ()
{
  for (int i = 0; i < 256; i++)
    found[i] = false;
}

void
superop_collector::with_fixed_arg_1 (int bc1, int arg1, int bc2)
{
#if DEBUG
  std::cout << "Candidate " << bc1 << '(' << arg1 << "), " << bc2;
#endif

  heap1.add (bc1, bc2, arg1);
}

void
superop_collector::with_fixed_arg_2 (int bc1, int bc2, int arg2)
{
#if DEBUG
  std::cout << "Candidate " << bc1 << ", " << bc2 << '(' << arg2 << ')';
#endif

  heap2.add (bc1, bc2, arg2);
}

bool
superop_collector::replace_best_in_sequences (observer_list &obs,
					       sequence * s) const
{
  triplet heap1_best = heap1.top ();
  triplet heap2_best = heap2.top ();

  // Look for the bytecode
  int new_bc;
  for (new_bc = 64; found[new_bc]; new_bc++)
    if (new_bc == 255)
      return false;

  if (heap2_best.occurrences > heap1_best.occurrences)
    {
      isLineNo[new_bc] = isLineNo[heap2_best.bc1] || isLineNo[heap2_best.bc2];
	
      int bc1 = heap2_best.bc1;
      int bc2 = heap2_best.bc2;
      int arg = heap2_best.arg;

      obs.with_fixed_arg_2 (new_bc, bc1, bc2, arg);
      s->all_replace_with_fixed_arg_2 (new_bc, bc1, bc2, arg);
    }
  else
    {
      isLineNo[new_bc] = isLineNo[heap1_best.bc1] || isLineNo[heap1_best.bc2];

      int bc1 = heap1_best.bc1;
      int arg = heap1_best.arg;
      int bc2 = heap1_best.bc2;

      obs.with_fixed_arg_1 (new_bc, bc1, arg, bc2);
      s->all_replace_with_fixed_arg_1 (new_bc, bc1, arg, bc2);
    }

  return true;
}

// Load the sequence from the input stream, IS.
sequence::sequence (sequence * next_, std::istream& is) : next (next_)
{
  is >> n;
  seq = new unsigned char[n];
  for (int i = 0; i < n; i++)
    {
      int bc;
      is >> bc;
      seq[i] = bc;
    }
}

bool 
sequence::includes_superoperators ()
{
  for (int i = 0; i < n; i += 2)
    if (seq[i] >= 64)
      return true;
  return false;
}

// Count the total length of the sequences.
int
sequence::all_count ()
{
  int total = 0;
  for (sequence *s = this; s; s = s->next)
    total += s->n;

  return total;
}

// Pass all the sequences in the list to SC.
bool
sequence::all_visit (observer_list& obs)
{
  superop_collector sc;
  for (sequence *s = this; s; s = s->next)
    s->visit (sc);

  return sc.replace_best_in_sequences (obs, this);
}

// Replace the given superoperator into all the sequences with
// the bytecode NEW_BC.
void
sequence::all_replace_with_fixed_arg_1 (int new_bc, int bc1, int arg1,
					int bc2)
{
  for (sequence *s = this; s; s = s->next)
    s->replace_with_fixed_arg_1 (new_bc, bc1, arg1, bc2);
}

// Replace the given superoperator into all the sequences with
// the bytecode NEW_BC.
void
sequence::all_replace_with_fixed_arg_2 (int new_bc, int bc1, int bc2,
					int arg2)
{
  for (sequence *s = this; s; s = s->next)
    s->replace_with_fixed_arg_2 (new_bc, bc1, bc2, arg2);
}

// Print the sequence represented by S on the output stream, OS.
std::ostream&
operator<< (std::ostream& os, const sequence& s)
{
  os << s.n;
  for (int i = 0; i < s.n; i++)
    os << ' ' << (int) s.seq[i];

  return os;
}

// Pass the candidate superoperators in this sequence to SC.
void
sequence::visit (superop_collector& sc)
{
#ifdef DEBUG
  std::cout << "Visiting " << *this << std::endl;
#endif

  // Also mark the first bytecode as used!
  sc.found_bytecode (seq[0]);

  for (int i = 2; i < n; i += 2)
    {
      sc.found_bytecode (seq[i]);

      int bc1 = seq[i-2];
      int arg1 = seq[i-1];
      int bc2 = seq[i];
      int arg2 = seq[i+1];

      if (bc2 == EXT_BYTE)
	continue;

      if ((i == 2 || seq[i-4] != EXT_BYTE)
	  && bc1 != EXT_BYTE && !isLineNo[bc1])
        sc.with_fixed_arg_1 (bc1, arg1, bc2);

      if (!isLineNo[bc2])
        sc.with_fixed_arg_2 (bc1, bc2, arg2);
    }
}

// Replace the given superoperator into this sequences with
// the bytecode NEW_BC.
void
sequence::replace_with_fixed_arg_1 (int new_bc, int bc1, int arg1, int bc2)
{
#ifdef DEBUG
  std::cout << "Replacing in " << *this << std::endl;
#endif

  for (int i = 2; i < n; i += 2)
    if (seq[i-2] == bc1 && seq[i-1] == arg1 && seq[i] == bc2
        && (i == 2 || seq[i-4] != EXT_BYTE))
      {
	seq[i-2] = new_bc;
	seq[i-1] = seq[i+1];
	std::memmove (&seq[i], &seq[i+2], n - (i+2));
	n -= 2;
      }

#ifdef DEBUG
  std::cout << "Rewritten as " << *this << std::endl;
#endif
}

// Replace the given superoperator into this sequences with
// the bytecode NEW_BC.
void
sequence::replace_with_fixed_arg_2 (int new_bc, int bc1, int bc2, int arg2)
{
#ifdef DEBUG
  std::cout << "Replacing in " << *this << std::endl;
#endif

  for (int i = 2; i < n; i += 2)
    if (seq[i-2] == bc1 && seq[i] == bc2 && seq[i+1] == arg2)
      {
	seq[i-2] = new_bc;
	std::memmove (&seq[i], &seq[i+2], n - (i+2));
	n -= 2;
      }

#ifdef DEBUG
  std::cout << "Rewritten as " << *this << std::endl;
#endif
}

int
main (int argc, char **argv)
{
  int rfd[2], wfd[2];

  /* ?fd[0] is for the parent, ?fd[1] is for the child.  */
  pipe (rfd);
  wfd[0] = rfd[1];
  wfd[1] = rfd[0];
  pipe (rfd);

  if (fork () == 0)
    {
      close (0);
      dup (wfd[1]);
      close (1);
      dup (rfd[1]);
      execl ("../gst", "../gst", "-Q", "-I", "../gst.im", NULL);
    }

  // A simple script to collect the superoperator candidates
  // from the current image.
  const char gst_script[] =
    " CompiledCode extend ["

    " allSuperoperatorBreaks ["
    "     | breaks |"
    "     breaks := SortedCollection new."
    "     self allByteCodeIndicesDo: [ :i :b :op |"
    ///////// "Split where jumps land"
    "         (b >= 40 and: [ b <= 43 ])"
    "            ifTrue: [ breaks add: (self jumpDestinationAt: i forward: b > 40) ]."

    ///////// "Split after returns"
    "         (b >= 50 and: [ b <= 51 ])"
    "            ifTrue: [ breaks add: (self nextBytecodeIndex: i) ]."

    ///////// "Split after jumps"
    "         (b >= 40 and: [ b <= 43 ])"
    "            ifTrue: [ breaks add: (self nextBytecodeIndex: i) ]."

    ///////// "Split after push/store literal variable"
    "         (b = 34 or: [ b = 38 ])"
    "            ifTrue: [ breaks add: (self nextBytecodeIndex: i) ]."

    ///////// "Split after sends"
    "         (b < 32 and: [ (b + 12 bitAnd: 250) ~= 32 ])"
    "            ifTrue: [ breaks add: (self nextBytecodeIndex: i) ]"
    "     ]."
    "     ^breaks ]"

    " allOptimizableSequencesDo: aBlock ["
    "     | breaks ws |"
    "     breaks := self allSuperoperatorBreaks."
    "     ({1}, breaks)"
    "         with: (breaks asArray copyWith: self numBytecodes + 1)"
    "         do: [ :begin :end |"
    "             end - begin > 2 ifTrue: ["
    "                 aBlock value: (self copyFrom: begin to: end - 1) ]"
    "         ] ]"

    " printAllOptimizableSequences ["
    "     self allOptimizableSequencesDo: [ :seq |"
    "         seq size printOn: stdout."
    "         seq do: [ :each | stdout space. each printOn: stdout ]."
    "         stdout nl"
    "     ] ] ]."

    " Eval [ "
    " stdout nextPutAll: 'BEGIN'; nl."
    " CompiledMethod allInstancesDo: [ :each |"
    "     each descriptor notNil"
    "         ifTrue: [ each printAllOptimizableSequences ] ]."

    " CompiledBlock allInstancesDo: [ :each |"
    "     each method notNil"
    "         ifTrue: [ each printAllOptimizableSequences ] ]."

    " stdout nl."
    " ObjectMemory quit ]";

  write (wfd[0], gst_script, sizeof (gst_script) - 1);

  // Load the Smalltalk script's output into a buffer
  int nread = 0, nthis;
  char *total = NULL;
  char buf[8192];
  do
    {
      nthis = read (rfd[0], buf, 8192);
      total = (char *) realloc (total, nread + nthis);
      std::memcpy (total + nread, buf, nthis);
      nread += nthis;
    }
  while (nthis > 0
	 && !(total[nread - 1] == '\n' && total[nread - 2] == '\n'));

  total = strstr (total, "BEGIN\n") + 6;

  // Parse sequences from the buffer until we reach its end
  // (which is marked by an empty sequence).  Don't save sequences
  // whose length is 2 because they produce no superoperators.
  std::string istr (total, nread);
  std::istringstream is (istr);

  sequence *seqs = NULL;
  int bad_seqs = 0;
  do
    {
      seqs = new sequence (seqs, is);
      sequence *first = seqs;
      if (first->includes_superoperators ())
        {
	  bad_seqs++;
          seqs = seqs->next;
	  delete first;
	}
    }
  while (is.tellg () > 0);

  if (bad_seqs)
    {
      std::cout << "Discarded " << bad_seqs << " sequences.  "
	<< (bad_seqs > 200 ? "Was gst compiled with NO_SUPEROPERATORS?" : "")
        << std::endl;
    }

  // Statistics are fun...
  int before = seqs->all_count();
  std::cout << before << " bytecodes read." << std::endl;

  // Now do the job until no bytecodes are free.
  isLineNo[LINE_NUMBER_BYTECODE] = true;
  superop_table_builder stb;
  hash_builder hb;
  byte_def_builder bdb;
  vm_def_builder vdb;

  observer_list obs;
  obs.push_back (&hb);
  obs.push_back (&bdb);
  obs.push_back (&vdb);
  obs.push_back (&stb);
  while (seqs->all_visit (obs));

  // Statistics can be even more fun...
  int after = seqs->all_count();
  int ratio_1000 = int (1000 * (double (after) / before));
  std::cout << after << " bytecodes remain, "
            << double (1000 - ratio_1000) / 10.0 << "% savings."
	    << std::endl;

  // And now invoke gperf.
  hb.output ();

  int pid;
  wait (&pid);
}
