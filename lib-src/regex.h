/* Definitions for data structures and routines for the regular
   expression library, version 0.12.
   Copyright (C) 1985,89,90,91,92,93,95,96,97,98 Free Software Foundation, Inc.

   This file is part of the GNU C Library.  Its master source is NOT part of
   the C library, however.  The master source lives in /gd/gnu/lib.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* modified for Ruby by matz@netlab.co.jp */

#ifndef __REGEXP_LIBRARY
#define __REGEXP_LIBRARY


#include <stddef.h>

/* Define number of parens for which we record the beginnings and ends.
   This affects how much space the `struct pre_registers' type takes up.  */
#ifndef PRE_NREGS
#define PRE_NREGS 10
#endif

#define BYTEWIDTH 8

#define PRE_REG_MAX ((1<<BYTEWIDTH)-1)

/* Maximum number of duplicates an interval can allow.  */
#ifndef PRE_DUP_MAX
#define PRE_DUP_MAX  ((1 << 15) - 1) 
#endif


/* If this bit is set, then character classes are supported; they are:
     [:alpha:],	[:upper:], [:lower:],  [:digit:], [:alnum:], [:xdigit:],
     [:space:], [:print:], [:punct:], [:graph:], and [:cntrl:].
   If not set, then character classes are not supported.  */
#define PRE_CHAR_CLASSES (1L << 9)

/* match will be done case insensetively */
#define PRE_OPTION_IGNORECASE (1L)
/* perl-style extended pattern available */
#define PRE_OPTION_EXTENDED   (PRE_OPTION_IGNORECASE<<1)
/* newline will be included for . */
#define PRE_OPTION_SINGLELINE (PRE_OPTION_EXTENDED<<1)
/* ^ and $ look at newline */
#define PRE_OPTION_MULTILINE  (PRE_OPTION_SINGLELINE<<1)
/* search for longest match, in accord with POSIX regexp */
#define PRE_OPTION_LONGEST    (PRE_OPTION_MULTILINE<<1)

#define PRE_MAY_IGNORECASE    (PRE_OPTION_LONGEST<<1)
#define PRE_OPTIMIZE_ANCHOR   (PRE_MAY_IGNORECASE<<1)
#define PRE_OPTIMIZE_EXACTN   (PRE_OPTIMIZE_ANCHOR<<1)

/* Structure used in pre_match() */

typedef union
{
  unsigned char *word;
  struct {
    unsigned is_active : 1;
    unsigned matched_something : 1;
  } bits;
} register_info_type;

/* This data structure is used to represent a compiled pattern.  */

struct pre_pattern_buffer
  {
    char *buffer;	/* Space holding the compiled pattern commands.  */
    int allocated;	/* Size of space that `buffer' points to. */
    int used;		/* Length of portion of buffer actually occupied  */
    char *fastmap;	/* Pointer to fastmap, if any, or zero if none.  */
			/* pre_search uses the fastmap, if there is one,
			   to skip over totally implausible characters.  */
    char *must;	        /* Pointer to exact pattern which strings should have
			   to be matched.  */
    int *must_skip;     /* Pointer to exact pattern skip table for bm_search */
    char *stclass;      /* Pointer to character class list at top */
    long options;	/* Flags for options such as extended_pattern. */
    long pre_nsub;	/* Number of subexpressions found by the compiler. */
    char fastmap_accurate;
			/* Set to zero when a new pattern is stored,
			   set to one when the fastmap is updated from it.  */
    char can_be_null;   /* Set to one by compiling fastmap
			   if this pattern might match the null string.
			   It does not necessarily match the null string
			   in that case, but if this is zero, it cannot.
			   2 as value means can match null string
			   but at end of range or before a character
			   listed in the fastmap.  */

    /* stack & working area for pre_match() */
    unsigned char **regstart;
    unsigned char **regend;
    unsigned char **old_regstart;
    unsigned char **old_regend;
    register_info_type *reg_info;
    unsigned char **best_regstart;
    unsigned char **best_regend;
  };

typedef struct pre_pattern_buffer regex_t;

/* Structure to store register contents data in.

   Pass the address of such a structure as an argument to pre_match, etc.,
   if you want this information back.

   For i from 1 to PRE_NREGS - 1, start[i] records the starting index in
   the string of where the ith subexpression matched, and end[i] records
   one after the ending index.  start[0] and end[0] are analogous, for
   the entire pattern.  */

struct pre_registers
  {
    int allocated;
    int num_regs;
    int *beg;
    int *end;
  };

/* Type for byte offsets within the string.  POSIX mandates this.  */
typedef size_t regoff_t;

/* POSIX specification for registers.  Aside from the different names than
   `pre_registers', POSIX uses an array of structures, instead of a
   structure of arrays.  */
typedef struct
{
  regoff_t rm_so;  /* Byte offset from string's start to substring's start.  */
  regoff_t rm_eo;  /* Byte offset from string's start to substring's end.  */
} regmatch_t;


#ifdef __STDC__

extern const char *pre_compile_pattern (const char *, int, struct pre_pattern_buffer *);
void pre_free_pattern (struct pre_pattern_buffer *);
/* Is this really advertised?  */
extern int pre_adjust_startpos (struct pre_pattern_buffer *, const char*, int, int, int);
extern void pre_compile_fastmap (struct pre_pattern_buffer *);
extern int pre_search (struct pre_pattern_buffer *, const char*, int, int, int,
		      struct pre_registers *);
extern int pre_match (struct pre_pattern_buffer *, const char *, int, int,
		     struct pre_registers *);
extern void pre_set_casetable (const char *table);
extern void pre_copy_registers (struct pre_registers*, struct pre_registers*);
extern void pre_free_registers (struct pre_registers*);

#else /* !__STDC__ */

extern char *pre_compile_pattern ();
void pre_free_regexp ();
/* Is this really advertised? */
extern int pre_adjust_startpos ();
extern void pre_compile_fastmap ();
extern int pre_search ();
extern int pre_match ();
extern void pre_set_casetable ();
extern void pre_copy_registers ();
extern void pre_free_registers ();

#endif /* __STDC__ */

#endif /* !__REGEXP_LIBRARY */
