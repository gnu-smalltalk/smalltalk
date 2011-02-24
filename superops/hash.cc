/////////////////////////////// -*- C++ -*- ///////////////////////////
//
//	Program to extract superoperators from a GNU Smalltalk image.
//	Hash table creation routines (interfacing with GPERF).
//
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
//
// Copyright 2003 Free Software Foundation, Inc.
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

#include <climits> /* defines SCHAR_MAX etc. */
#include <iomanip>
#include <iostream>
#include <fstream>

#include "hash.h"

#include "options.h"
#include "search.h"
#include "keyword.h"
#include "keyword-list.h"
#include "positions.h"

#include <cstdlib>

class Output
{
public:
  /* Constructor.  */
                        Output (std::ostream &os,
				KeywordExt_List *head,
			        const char *wordlist_eltype,
                                const int *asso_values);

  /* Generates the hash function and the key word recognizer function.  */
  void                  output () const;

private:

  /* Computes the minimum and maximum hash values, and stores them
     in _min_hash_value and _max_hash_value.  */
  void                  compute_min_max ();

  /* Outputs the maximum and minimum hash values etc.  */
  void                  output_constants (struct Output_Constants&) const;

  /* Outputs a keyword, as an array of bytes.  */
  void			output_key (const char *key, int len) const;

  /* Same as above, but including the other fields and enclosed in braces.  */
  void			output_keyword_entry (KeywordExt *temp,
					      const char *indent) const;

  /* Outputs several null entries.  */
  void			output_keyword_blank_entries (int count,
						      const char *indent) const;

  /* Outputs a type with a const specifier, followed by a space.  */
  void 			output_const_type (const char *type_string) const;

  /* Generates C code for the hash function that returns the
     proper encoding for each keyword.  */
  void                  output_asso_values () const;

  /* Prints out the array containing the keywords for the hash function.  */
  void                  output_keyword_table () const;

  /* Output destination.  */
  std::ostream &        _os;

  /* Linked list of keywords.  */
  KeywordExt_List *     _head;

  /* Element type of keyword array.  */
  const char *          _wordlist_eltype;
  /* Minimum hash value for all keywords. */
  int                   _min_hash_value;
  /* Maximum hash value for all keywords. */
  int                   _max_hash_value;
  /* Value associated with each character. */
  const int * const     _asso_values;
};

/* Returns the smallest unsigned C type capable of holding integers
   up to N.  */

static const char *
smallest_integral_type (int n)
{
  if (n <= UCHAR_MAX) return "unsigned char";
  if (n <= USHRT_MAX) return "unsigned short";
  return "unsigned int";
}

/* Returns the smallest signed C type capable of holding integers
   from MIN to MAX.  */

static const char *
smallest_integral_type (int min, int max)
{
  if (min >= SCHAR_MIN && max <= SCHAR_MAX) return "signed char";
  if (min >= SHRT_MIN && max <= SHRT_MAX) return "short";
  return "int";
}

/* ------------------------------------------------------------------------- */

/* Constructor.
   Note about the keyword list starting at head:
   - The list is ordered by increasing _hash_value.  This has been achieved
     by Search::sort().
   - Duplicates, i.e. keywords with the same _selchars set, are chained
     through the _duplicate_link pointer.  Only one representative per
     duplicate equivalence class remains on the linear keyword list.
   - Accidental duplicates, i.e. keywords for which the _asso_values[] search
     couldn't achieve different hash values, cannot occur on the linear
     keyword list.  Search::optimize would catch this mistake.
 */
Output::Output (std::ostream &os, KeywordExt_List *head, 
                const char *wordlist_eltype, const int *asso_values)
  : _os(os), _head (head), _wordlist_eltype (wordlist_eltype),
    _asso_values (asso_values)
{
  compute_min_max ();
}

/* ------------------------------------------------------------------------- */

/* Computes the minimum and maximum hash values, and stores them
   in _min_hash_value and _max_hash_value.  */

void
Output::compute_min_max ()
{
  /* Since the list is already sorted by hash value all we need to do is
     to look at the first and the last element of the list.  */

  _min_hash_value = _head->first()->_hash_value;

  KeywordExt_List *temp;
  for (temp = _head; temp->rest(); temp = temp->rest())
    ;
  _max_hash_value = temp->first()->_hash_value;
}

/* -------------------- Output_Constants and subclasses -------------------- */

/* This class outputs an enumeration using 'enum'.  */

struct Output_Constants
{
  virtual void          output_start ();
  virtual void          output_item (const char *name, int value);
  virtual void          output_end ();
                        Output_Constants (std::ostream &os, const char *indent)
                          : _os(os), _indentation (indent) {}
  virtual               ~Output_Constants () {}
private:
  std::ostream &_os;
  const char *_indentation;
  bool _pending_comma;
};

void Output_Constants::output_start ()
{
  _os << _indentation << "enum" << std::endl
      << _indentation << "  {" << std::endl;
          
  _pending_comma = false;
}

void Output_Constants::output_item (const char *name, int value)
{
  if (_pending_comma)
    _os << ',' << std::endl;
  _os << _indentation << "    " << name << " = " << value;
  _pending_comma = true;
}

void Output_Constants::output_end ()
{
  if (_pending_comma)
    _os << std::endl;
  _os << _indentation << "  };" << std::endl << std::endl;
}

/* Outputs the maximum and minimum hash values etc.  */

void
Output::output_constants (struct Output_Constants& style) const
{
  style.output_start ();
  style.output_item ("MIN_HASH_VALUE", _min_hash_value);
  style.output_item ("MAX_HASH_VALUE", _max_hash_value);
  style.output_end ();
}

/* ------------------------------------------------------------------------- */

/* Outputs a keyword, as an array of bytes.  */

void
Output::output_key (const char *key, int len) const
{
  _os << '{';
  if (key[len-1] == 0)
    {
      while (len > 0 && key[len-1] == 0)
        len--;
      len++;
    }

  for (; len > 0; len--)
    {
      unsigned char c = static_cast<unsigned char>(*key++);
      _os << ' ' << (int) c;
      if (len > 1)
        _os << ',';
    }
  _os << '}';
}

/* ------------------------------------------------------------------------- */

/* Outputs a type with a const specifier, followed by a space.  */

void
Output::output_const_type (const char *type_string) const
{
  if (type_string[strlen(type_string)-1] == '*')
    /* For pointer types, put the 'const' after the type.  */
    _os << type_string << " const ";
  else
    /* For scalar or struct types, put the 'const' before the type.  */
    _os << "const " << type_string << ' ';
}

/* --------------------- Output_Compare and subclasses --------------------- */

/* Generates C code for the hash function that returns the
   proper encoding for each keyword.
   The hash function has the signature
     unsigned int <hash> (const char *str, unsigned int len).  */

void
Output::output_asso_values () const
{
  _os << "  static const " << smallest_integral_type (_max_hash_value + 1)
      << " asso_values[] =" << std::endl
      << "    {";

  const int columns = 10;

  /* Calculate maximum number of digits required for MAX_HASH_VALUE.  */
  int field_width = 2;
  for (int trunc = _max_hash_value; (trunc /= 10) > 0;)
    field_width++;

  for (unsigned int count = 0; count < 256; count++)
    {
      if (count > 0)
        _os << ',';
      if ((count % columns) == 0)
        _os << std::endl << "     ";
      _os << std::setw(field_width) << _asso_values[count] << std::setw(0);
    }

  _os << std::endl << "    };" << std::endl;
}

/* ------------------------------------------------------------------------- */

void
Output::output_keyword_entry (KeywordExt *temp, const char *indent) const
{
  _os << indent << "    {";
  output_key (temp->_allchars, temp->_allchars_length);
  if (strlen (temp->_rest) > 0)
    _os << ", "  << temp->_rest;
  _os << '}';
}

void
Output::output_keyword_blank_entries (int count, const char *indent) const
{
  int column = 0;
  for (int i = 0; i < count; i++)
    {
      if ((column % 6) == 0)
        {
          if (i > 0)
            _os << ',' << std::endl;
          _os << indent << "    ";
        }
      else
        {
          if (i > 0)
            _os << ", ";
        }

      _os << "{{}, -1 }";
      column++;
    }
}

/* Prints out the array containing the keywords for the hash function.  */

void
Output::output_keyword_table () const
{
  const char *indent  = "  ";
  int index;
  KeywordExt_List *temp;

  _os << indent << "static ";
  output_const_type (_wordlist_eltype);
  _os << "keylist[] =" << std::endl
      << indent << "  {" << std::endl;

  /* Generate an array of reserved words at appropriate locations.  */
  for (temp = _head, index = 0; temp; temp = temp->rest())
    {
      KeywordExt *keyword = temp->first();

      if (index > 0)
	{
          _os << ',' << std::endl;

          if (index < keyword->_hash_value)
            {
              /* Some blank entries.  */
              output_keyword_blank_entries (keyword->_hash_value - index, indent);
              _os << ',' << std::endl;
              index = keyword->_hash_value;
            }
	}

      keyword->_final_index = index;
      output_keyword_entry (keyword, indent);
      index++;
    }

  if (index > 0)
    _os << std::endl;

  _os << indent << "  };" << std::endl << std::endl;
}

/* ------------------------------------------------------------------------- */

/* Generates the hash function and the key word recognizer function
   based upon the user's Options.  */

void
Output::output () const
{
  Output_Constants style (_os, "  ");
  output_constants (style);
  output_asso_values ();
  output_keyword_table ();
}

hash_builder::hash_builder () : list1(NULL), list2(NULL)
{
  option.set (RANDOM);
  option.set (NOLENGTH);
};


void hash_builder::with_fixed_arg_1 (int new_bc, int bc1, int arg, int bc2)
{
  char *c = new char[3];
  c[0] = bc1;
  c[1] = bc2;
  c[2] = arg;
  char *rest = new char[10];
  sprintf (rest, "%d", new_bc);
  KeywordExt *k = new KeywordExt(c, 3, rest);
  KeywordExt_List *new_head = new KeywordExt_List(k);
  new_head->rest() = list1;
  list1 = new_head;
}

void hash_builder::with_fixed_arg_2 (int new_bc, int bc1, int bc2, int arg)
  {
    char *c = new char[3];
    c[0] = bc1;
    c[1] = bc2;
    c[2] = arg;
    char *rest = new char[10];
    sprintf (rest, "%d", new_bc);
    KeywordExt *k = new KeywordExt(c, 3, rest);
    KeywordExt_List *new_head = new KeywordExt_List(k);
    new_head->rest() = list2;
    list2 = new_head;
  }

void hash_builder::search (Positions &p, KeywordExt_List *list,
			   const char *type, const char *file)
{
  std::cout << "Hash function written to " << file << ", hash positions ";
  std::cout.flush ();
  p.print();
  fflush (stdout);
  std::cout << std::endl;
  
  option._key_positions = p;
  option.set (POSITIONS);
  Search searcher (list);
  searcher.optimize ();
  std::ofstream fs (file);
  fs << "/* Automagically generated by superops, do not edit!  */" << std::endl;
  if (!fs)
    {
      std::cerr << "Cannot open output file '" << file << '\'' << std::endl;
      std::exit (1);
    }
  
  Output outputter (fs, searcher._head, type, searcher._asso_values);
  outputter.output ();
}

void hash_builder::output1 ()
{
  Positions p;
  p.add(0);
  p.add(1);
  p.add(2);
  
  search (p, list1, "struct superop_with_fixed_arg_1_type", "superop1.inl");
}

void hash_builder::output2 ()
{
  Positions p;
  p.add(0);
  p.add(1);
  p.add(2);
  
  search (p, list2, "struct superop_with_fixed_arg_2_type", "superop2.inl");
}

void hash_builder::output ()
{
  output1 ();
  output2 ();
}
