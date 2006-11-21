/***********************************************************************
 *
 *	Regular expression interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2006 Free Software Foundation, Inc.
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

static RegexCacheEntry cache[REGEX_CACHE_SIZE];

/* Smalltalk globals */
static OOP regexClass;

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
  patternLength = gst_interpreter_proxy.basicSize (patternOOP);

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
 * it up in the cache and move it to its top (so that it is marked as
 * most recently used).  Answer REGEX_CACHE_HIT if it is found, or
 * REGEX_CACHE_MISS if it is not.
 * pRegex will point to the compiled regex if there is a cache hit, else
 * lookupRegex will only initialize it, and it will be the caller's
 * responsibility to compile the regex into the buffer that is returned.
 * If the patternOOP is not a Regex (i.e. REGEX_NOT_CACHED returned), the
 * caller will also have to free the buffer pointed to by pRegex.
 */
RegexCaching
lookupRegex (OOP patternOOP, struct pre_pattern_buffer **pRegex)
{
  int i;
  RegexCaching result;

  if (!regexClass)
    regexClass = _gst_class_name_to_oop ("Regex");

  if (OOP_CLASS (patternOOP) != regexClass)
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
	gst_interpreter_proxy.unregisterOOP (cache[i].patternOOP);

      gst_interpreter_proxy.registerOOP (patternOOP);
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
 * in the cache (so that we can optimize a loop that repeatedly calls
 * asRegex; if none is found, we create one ex-novo.
 * Note that Regex and String objects have the same layout; only, Regexes
 * are read-only so that we can support this kind of "interning" them.
 */
OOP
_gst_re_make_cacheable (OOP patternOOP)
{
  OOP regexOOP;
  const char *pattern;
  char *regex;
  struct pre_pattern_buffer *compiled;
  int patternLength;
  int i;

  if (!regexClass)
    regexClass = _gst_class_name_to_oop ("Regex");

  if (OOP_CLASS (patternOOP) == regexClass)
    return patternOOP;

  /* Search in the cache */
  patternLength = gst_interpreter_proxy.basicSize (patternOOP);
  pattern = &STRING_OOP_AT (OOP_TO_OBJ (patternOOP), 1);

  for (i = 0; i < REGEX_CACHE_SIZE; i++)
    {
      if (!cache[i].regex)
	break;

      regexOOP = cache[i].patternOOP;
      regex = &STRING_OOP_AT (OOP_TO_OBJ (regexOOP), 1);
      if (gst_interpreter_proxy.basicSize (regexOOP) == patternLength &&
	  memcmp (regex, pattern, patternLength) == 0)
	{
	  markRegexAsMRU (i);
	  return regexOOP;
	}
    }

  /* No way, must allocate a new Regex object */
  regexOOP = gst_interpreter_proxy.objectAlloc (regexClass, patternLength);
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

/* Search helper function */
struct pre_registers *
_gst_re_search (OOP srcOOP, OOP patternOOP, int from, int to)
{
  int res = 0;
  const char *src;
  struct pre_pattern_buffer *regex;
  struct pre_registers *regs;
  RegexCaching caching;

  caching = lookupRegex (patternOOP, &regex);
  if (caching != REGEX_CACHE_HIT && compileRegex (patternOOP, regex) != NULL)
    return NULL;

  /* now search */
  src = &STRING_OOP_AT (OOP_TO_OBJ (srcOOP), 1);
  regs = (struct pre_registers *) calloc (1, sizeof (struct pre_registers));
  res = pre_search (regex, src, to, from - 1, to - from + 1, regs);

  if (caching == REGEX_NOT_CACHED)
    pre_free_pattern (regex);

  return regs;
}

void 
_gst_re_free_registers(struct pre_registers *regs)
{
	pre_free_registers(regs);
	free(regs);
}

/* Match helper function */
int
_gst_re_match (OOP srcOOP, OOP patternOOP, int from, int to)
{
  int res = 0;
  const char *src;
  struct pre_pattern_buffer *regex;
  RegexCaching caching;

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

