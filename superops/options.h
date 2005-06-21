/* This may look like C code, but it is really -*- C++ -*- */

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

/* This module provides a uniform interface to the various options available
   to a user of the gperf hash function generator.  */

#ifndef options_h
#define options_h 1

#include <stdio.h>
#include "positions.h"

/* Enumeration of the possible boolean options.  */

enum Option_Type
{
  /* --- Input file interpretation --- */

  /* Ignore case of ASCII characters.  */
  UPPERLOWER   = 1 << 1,

  /* --- Details in the output code --- */

  /* Assume 7-bit, not 8-bit, characters.  */
  SEVENBIT     = 1 << 6,

  /* --- Algorithm employed by gperf --- */

  /* Use the given key positions.  */
  POSITIONS    = 1 << 17,

  /* Handle duplicate hash values for keywords.  */
  DUP          = 1 << 18,

  /* Don't include keyword length in hash computations.  */
  NOLENGTH     = 1 << 19,

  /* Randomly initialize the associated values table.  */
  RANDOM       = 1 << 20,

  /* --- Informative output --- */

  /* Enable debugging (prints diagnostics to stderr).  */
  DEBUG        = 1 << 21
};

/* Class manager for gperf program Options.  */

struct Options
{
public:
  /* Constructor.  */
                        Options ();

  /* Accessors.  */

  /* Tests a given boolean option.  Returns true if set, false otherwise.  */
  bool                  operator[] (Option_Type option) const;

  /* Sets a given boolean option.  */
  void                  set (Option_Type option);

  /* Returns the jump value.  */
  int                   get_jump () const;

  /* Returns the initial associated character value.  */
  int                   get_initial_asso_value () const;

  /* Returns the number of iterations for finding good asso_values.  */
  int                   get_asso_iterations () const;

  /* Returns the factor by which to multiply the generated table's size.  */
  float                 get_size_multiple () const;

  /* Returns key positions.  */
  const Positions&      get_key_positions () const;

  /* Holds the boolean options.  */
  int                   _option_word;

  /* Jump length when trying alternative values.  */
  int                   _jump;

  /* Initial value for asso_values table.  */
  int                   _initial_asso_value;

  /* Number of attempts at finding good asso_values.  */
  int                   _asso_iterations;

  /* Factor by which to multiply the generated table's size.  */
  float                 _size_multiple;

  /* Contains user-specified key choices.  */
  Positions             _key_positions;
};

/* Global option coordinator for the entire program.  */
extern Options option;

#ifdef __OPTIMIZE__

#define INLINE inline
#include "options.icc"
#undef INLINE

#endif

#endif
