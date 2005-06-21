/* Handles parsing the Options provided to the user.
   Copyright (C) 1989-1998, 2000, 2002-2003 Free Software Foundation, Inc.
   Written by Douglas C. Schmidt <schmidt@ics.uci.edu>
   and Bruno Haible <bruno@clisp.org>.

   This file is part of GNU GPERF.

   GNU GPERF is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   GNU GPERF is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; see the file COPYING.
   If not, write to the Free Software Foundation, Inc.,
   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

/* Specification. */
#include "options.h"

#include <stdio.h>
#include <stdlib.h> /* declares atoi(), abs(), exit() */
#include <string.h> /* declares strcmp() */
#include <ctype.h>  /* declares isdigit() */
#include <limits.h> /* defines CHAR_MAX */
#include "getopt.h"

/* Global option coordinator for the entire program.  */
Options option;

/* Size to jump on a collision.  */
static const int DEFAULT_JUMP_VALUE = 5;

/* ------------------------------------------------------------------------- */

/* Sets the default Options.  */

Options::Options ()
  : _option_word (RANDOM),
    _jump (DEFAULT_JUMP_VALUE),
    _initial_asso_value (0),
    _asso_iterations (0),
    _size_multiple (1),
    _key_positions ()
{
}

/* Dumps option status when debugging is enabled.  */

/* ------------------------------------------------------------------------- */

#ifndef __OPTIMIZE__

#define INLINE /* not inline */
#include "options.icc"
#undef INLINE

#endif /* not defined __OPTIMIZE__ */
