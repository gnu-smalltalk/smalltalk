/***********************************************************************
 *
 *	Regular expression interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2006, 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini and Dragomir Milevojevic.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "gstpriv.h"
#include "regex.h"
#include "re.h"

#if STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

/* Regex caching facility */

#define REGEX_CACHE_SIZE 10

typedef enum RegexCachingEnum
{
  REGEX_NOT_CACHED,
  REGEX_CACHE_HIT,
  REGEX_CACHE_MISS
}
RegexCaching;

typedef struct RegexCacheEntry
{
  OOP patternOOP;
  struct pre_pattern_buffer *regex;
}
RegexCacheEntry;

static RegexCaching lookupRegex (OOP patternOOP,
				 struct pre_pattern_buffer **pRegex);
static const char *compileRegex (OOP patternOOP,
				 struct pre_pattern_buffer *regex);
static struct pre_pattern_buffer *allocateNewRegex (void);
static void markRegexAsMRU (int i);
static void init_re (void);

static RegexCacheEntry cache[REGEX_CACHE_SIZE];

/* Smalltalk globals */
static OOP regexClassOOP, resultsClassOOP;

/* Allocate a buffer to be passed to the regular expression matcher */
struct pre_pattern_buffer *
allocateNewRegex (void)
{
  struct pre_pattern_buffer *regex;
  regex = (struct pre_pattern_buffer *)
    calloc (1, sizeof (struct pre_pattern_buffer));

  regex->allocated = 0;
  regex->fastmap = malloc (1 << BYTEWIDTH);

  return regex;
}

/* Compile a pattern that's stored into an OOP.  Answer an error, or NULL. */
const char *
compileRegex (OOP patternOOP, struct pre_pattern_buffer *regex)
{
  int patternLength;
  const char *pattern;
  const char *ress;

  pattern = &STRING_OOP_AT (OOP_TO_OBJ (patternOOP), 1);
  patternLength = _gst_basic_size (patternOOP);

  /* compile pattern */
  ress = pre_compile_pattern (pattern, patternLength, regex);
  return ress;
}

/* Move the i-th entry of the cache to the first position */
void
markRegexAsMRU (int i)
{
  RegexCacheEntry saved;
  int j;

  saved = cache[i];
  for (j = i; j > 0; j--)
    cache[j] = cache[j - 1];

  cache[0] = saved;
}

/* If patternOOP is not a Regex, answer REGEX_NOT_CACHED.  Else look
   it up in the cache and move it to its top (so that it is marked as
   most recently used).  Answer REGEX_CACHE_HIT if it is found, or
   REGEX_CACHE_MISS if it is not.

   pRegex will point to the compiled regex if there is a cache hit, else
   lookupRegex will only initialize it, and it will be the caller's
   responsibility to compile the regex into the buffer that is returned.
   If the patternOOP is not a Regex (i.e. REGEX_NOT_CACHED returned), the
   caller will also have to free the buffer pointed to by pRegex.  */
RegexCaching
lookupRegex (OOP patternOOP, struct pre_pattern_buffer **pRegex)
{
  int i;
  RegexCaching result;

  if (!IS_OOP_READONLY (patternOOP))
    {
      *pRegex = allocateNewRegex ();
      return REGEX_NOT_CACHED;
    }

  /* Search for the Regex object in the cache */
  for (i = 0; i < REGEX_CACHE_SIZE; i++)
    if (cache[i].patternOOP == patternOOP)
      break;

  if (i < REGEX_CACHE_SIZE)
    result = REGEX_CACHE_HIT;

  else
    {
      /* Kick out the least recently used regexp */
      i--;
      result = REGEX_CACHE_MISS;

      /* Register the objects we're caching with the virtual machine */
      if (cache[i].patternOOP)
	_gst_unregister_oop (cache[i].patternOOP);

      _gst_register_oop (patternOOP);
      cache[i].patternOOP = patternOOP;
    }

  /* Mark the object as most recently used */
  if (!cache[i].regex)
    cache[i].regex = allocateNewRegex ();

  markRegexAsMRU (i);
  *pRegex = cache[0].regex;
  return result;
}

/* Create a Regex object.  We look for one that points to the same string
   in the cache (so that we can optimize a loop that repeatedly calls
   asRegex; if none is found, we create one ex-novo.
   Note that Regex and String objects have the same layout; only, Regexes
   are read-only so that we can support this kind of "interning" them.  */
OOP
_gst_re_make_cacheable (OOP patternOOP)
{
  OOP regexOOP;
  const char *pattern;
  char *regex;
  struct pre_pattern_buffer *compiled;
  int patternLength;
  int i;

  if (!regexClassOOP)
    init_re ();

  if (IS_OOP_READONLY (patternOOP))
    return patternOOP;

  /* Search in the cache */
  patternLength = _gst_basic_size (patternOOP);
  pattern = &STRING_OOP_AT (OOP_TO_OBJ (patternOOP), 1);

  for (i = 0; i < REGEX_CACHE_SIZE; i++)
    {
      if (!cache[i].regex)
	break;

      regexOOP = cache[i].patternOOP;
      regex = &STRING_OOP_AT (OOP_TO_OBJ (regexOOP), 1);
      if (_gst_basic_size (regexOOP) == patternLength &&
	  memcmp (regex, pattern, patternLength) == 0)
	{
	  markRegexAsMRU (i);
	  return regexOOP;
	}
    }

  /* No way, must allocate a new Regex object */
  regexOOP = _gst_object_alloc (regexClassOOP, patternLength);
  regex = &STRING_OOP_AT (OOP_TO_OBJ (regexOOP), 1);
  memcpy (regex, pattern, patternLength);

  /* Put it in the cache (we must compile it to check that it
   * is well-formed).
   */
  lookupRegex (regexOOP, &compiled);
  if (compileRegex (patternOOP, compiled) != NULL)
    return _gst_nil_oop;
  else
    return regexOOP;
}


typedef struct _gst_interval
{
  OBJ_HEADER;
  OOP fromOOP;
  OOP toOOP;
  OOP stepOOP;
} *gst_interval;

typedef struct _gst_registers
{
  OBJ_HEADER;
  OOP subjectOOP;
  OOP fromOOP;
  OOP toOOP;
  OOP registersOOP;
  OOP matchOOP;
  OOP cacheOOP;
} *gst_registers;

static OOP
make_re_results (OOP srcOOP, struct pre_registers *regs)
{
  OOP resultsOOP;
  gst_registers results;

  int i;
  if (!regs->beg || regs->beg[0] == -1)
    return _gst_nil_oop;

  resultsOOP = _gst_object_alloc (resultsClassOOP, 0);
  results = (gst_registers) OOP_TO_OBJ (resultsOOP);
  results->subjectOOP = srcOOP;
  results->fromOOP = FROM_INT (regs->beg[0] + 1);
  results->toOOP = FROM_INT (regs->end[0]);
  if (regs->num_regs > 1)
    {
      OOP registersOOP = _gst_object_alloc (_gst_array_class, regs->num_regs - 1);
      results = (gst_registers) OOP_TO_OBJ (resultsOOP);
      results->registersOOP = registersOOP;
    }

  for (i = 1; i < regs->num_regs; i++)
    {
      OOP intervalOOP;
      if (regs->beg[i] == -1)
	intervalOOP = _gst_nil_oop;
      else
	{
          gst_interval interval;
	  intervalOOP = _gst_object_alloc (_gst_interval_class, 0);
          interval = (gst_interval) OOP_TO_OBJ (intervalOOP);
          interval->fromOOP = FROM_INT (regs->beg[i] + 1);
          interval->toOOP = FROM_INT (regs->end[i]);
          interval->stepOOP = FROM_INT (1);
	}

      /* We need to reload results as it may be invalidated by GC.  */
      results = (gst_registers) OOP_TO_OBJ (resultsOOP);
      _gst_oop_at_put (results->registersOOP, i - 1, intervalOOP);
    }

  return resultsOOP;
}

/* Search helper function */

OOP
_gst_re_search (OOP srcOOP, OOP patternOOP, int from, int to)
{
  const char *src;
  struct pre_pattern_buffer *regex;
  struct pre_registers *regs;
  RegexCaching caching;
  OOP resultOOP;

  if (!regexClassOOP)
    init_re ();

  caching = lookupRegex (patternOOP, &regex);
  if (caching != REGEX_CACHE_HIT && compileRegex (patternOOP, regex) != NULL)
    return NULL;

  /* now search */
  src = &STRING_OOP_AT (OOP_TO_OBJ (srcOOP), 1);
  regs = (struct pre_registers *) calloc (1, sizeof (struct pre_registers));
  pre_search (regex, src, to, from - 1, to - from + 1, regs);

  if (caching == REGEX_NOT_CACHED)
    pre_free_pattern (regex);

  resultOOP = make_re_results (srcOOP, regs);
  pre_free_registers(regs);
  free(regs);
  return resultOOP;
}


/* Match helper function */

int
_gst_re_match (OOP srcOOP, OOP patternOOP, int from, int to)
{
  int res = 0;
  const char *src;
  struct pre_pattern_buffer *regex;
  RegexCaching caching;

  if (!regexClassOOP)
    init_re ();

  caching = lookupRegex (patternOOP, &regex);
  if (caching != REGEX_CACHE_HIT && compileRegex (patternOOP, regex) != NULL)
    return -100;

  /* now search */
  src = &STRING_OOP_AT (OOP_TO_OBJ (srcOOP), 1);
  res = pre_match (regex, src, to, from - 1, NULL);

  if (caching == REGEX_NOT_CACHED)
    pre_free_pattern (regex);

  return res;
}



/* Initialize regex.c */
static void
init_re (void)
{
  /* This is a ASCII downcase-table.  We don't make any assumptions
     about what bytes >=128 are, so can't downcase them. */
  static const char casetable[256] =
    {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
     16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
     ' ', '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/', 
     '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?', 
     '@', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 
     'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '[', '\\', ']', '^', '_', 
     '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 
     'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~', 127, 
     128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 
     144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
     160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 
     176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 
     192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 
     208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 
     224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 
     240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255};
  pre_set_casetable (casetable);

  regexClassOOP = _gst_class_name_to_oop ("Regex");
  resultsClassOOP = _gst_class_name_to_oop ("Kernel.MatchingRegexResults");
}
