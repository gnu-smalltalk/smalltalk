/******************************** -*- C -*- ****************************
 *
 *	Find similarity between two strings
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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


#include "config.h"

/* AIX is so broken that requires this to be the first thing in the file.  */
#if defined(_AIX)
#pragma alloca
#else
# if !defined(alloca)		/* predefined by HP cc +Olibcalls */
#  ifdef __GNUC__
#   define alloca __builtin_alloca
#  else
#   if HAVE_ALLOCA_H
#    include <alloca.h>
#   else
#    if defined(__hpux)
void *alloca ();
#    else
#     if !defined(__OS2__) && !defined(WIN32)
char *alloca ();
#     else
#      include <malloc.h>	/* OS/2 defines alloca in here */
#     endif
#    endif
#   endif
#  endif
# endif
#endif

#include <ctype.h>
#if STDC_HEADERS
#include <string.h>
#include <stdlib.h>
#endif

#include "strspell.h"

#define min(a, b)  ((a) < (b) ? (a) : (b))
#define max(a, b)  ((a) > (b) ? (a) : (b))

int
strspell (s1, s2, subst, wrong_case, ins, del)
     char *s1, *s2;
     int subst, wrong_case, ins, del;
{
  return strnspell (s1, s2, strlen(s1), strlen(s2),
		    subst, wrong_case, ins, del);
}

int
strnspell (s1, s2, l1, l2, subst, wrong_case, ins, del)
     char *s1, *s2;
     int l1, l2, subst, wrong_case, ins, del;
{
  int i, j;
  int up_left, left, up;
  int *last, *curr, *tmp;

  /* This is a dynamic programming algorithm which finds the
     best set of changes to obtain the first J characters of S2
     starting from the first I characters of S1.  At the end we
     have the best set of changes to obtain all of the L2
     characters of S2 starting from all of the L1 characters of
     S1.  Note that at each step we need only two rows -- the
     current one and the last one -- of the matrix.  */

  last = alloca ((l2 + 1) * sizeof (int));
  curr = alloca ((l2 + 1) * sizeof (int));

  last[0] = 0;

  /* To obtain J characters of S2 starting from 0 characters of S1,
     we need to insert J characters.  */
  for (j = 1; j <= l2; j++)
    last[j] = ins * j;

  /* To obtain 0 characters of S2 starting from 1 character of S1,
     we need to delete one character.  */
  curr[0] = del;
  s1--; s2--;

  for (i = 1; i <= l1; i++)
    {
      for (j = 1; j <= l2; j++)
	{
	  left = curr[j-1] + ins;
	  up = last[j] + del;
	  up_left = last[j-1];
	  if (s1[i] != s2[j])
	    up_left += tolower (s1[i]) == tolower (s2[j]) ? wrong_case : subst;

	  if (up_left < left)
	    curr[j] = min (up, up_left);
	  else
	    curr[j] = min (up, left);
	}

      tmp = last, last = curr, curr = tmp;
    }

  return last[l2];
}

