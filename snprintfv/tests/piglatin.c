/*  -*- Mode: C -*-  */

/* piglatin.c --- example module for snprintfv
 * Copyright (C) 2002 Gary V. Vaughan
 * Originally by Paolo Bonzini, 2002
 * This file is part of Snprintfv.
 *
 * Snprintfv is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Snprintfv is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * As a special exception to the GNU General Public License, if you
 * distribute this file as part of a program that also links with and
 * uses the libopts library from AutoGen, you may include it under
 * the same distribution terms used by the libopts library.
 */

/* Code: */
#include <snprintfv/printf.h>

/* Usually, this is taken care of by AC_SNPRINTFV_INSTALLABLE.  */
#define LIBSNPRINTFV_DLL_IMPORT 1

static void pig_latin (STREAM *stream, struct printf_info * const pinfo, union printf_arg const *args);
void snv_register_printf_funcs (register_callback_function *regfunc);

/* Just to show how easy it is to write your own:
   here is specifier function which writes pig latin to a STREAM. */
static void
pig_latin (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  const char *string = args->pa_string;
  int len = strlen (string);

  /* printf extravaganza :-) */
  stream_printf (stream, "%c%.*say", string[len - 1], len - 1, string);
}

void snv_register_printf_funcs (register_callback_function *regfunc)
{
  spec_entry *ent = regfunc ('P', printf_generic, NULL);
  ent->type = PA_STRING;
  ent->user = pig_latin;
}
