/*  -*- Mode: C -*-  */

/* ltdl.c --- dynamic loading for Snprintfv
 * Copyright (C) 2002 Gary V. Vaughan
 * Originally by Paolo Bonzini, 2002
 * This file is part of Snprintfv
 *
 * Snprintfv is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Snprintfv program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * As a special exception to the GNU General Public License, if you
 * distribute this file as part of a program that also links with and
 * uses the libopts library from AutoGen, you may include it under
 * the same distribution terms used by the libopts library.
 */

/* Code: */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#ifdef WITH_DMALLOC
#include <dmalloc.h>
#endif

#include "compat.h"
#include "printf.h"
#include "ltdl.h"

static int
printf_load_module_callback (const char *filename, lt_ptr data)
{
  static const char *symbol_name = "snv_register_printf_funcs";
  void (*func) (register_callback_function);

  const char *lib;
  lt_dlhandle handle = 0;
  const lt_dlinfo *info = 0;

  /* Opening random libraries is dangerous:  it may trigger initialisation
     code in the library.  Ignore filenames that have a `lib' prefix, even
     though we should be searching only directories which contain snprintfv
     modules.  */
  lib = strrchr (filename, '/');
  if (!lib)
    lib = filename;
  else
    lib++;

  if (strncmp ("lib", lib, 3) == 0)
    return 0;

  /* Bail out if the file is not a loadable module.  */
  handle = lt_dlopenext (filename);
  if (!handle)
    return 0;

  /* If the module has already been loaded, unload the duplicate
     and bail out.  */
  info = lt_dlgetinfo (handle);
  if (info->ref_count > 1)
    {
      lt_dlclose (handle);
      return 0;
    }

  /* If the access function is missing, it is not one of our modules.  */
  func = lt_dlsym (handle, symbol_name);
  if (!func)
    {
      lt_dlclose (handle);
      return 0;
    }

  func (register_printf_function);
  return 0;
}

/**
 * snv_load_all_modules: dl.h
 *
 * Register the Snprintfv modules available in the %LTDL_LIBRARY_PATH
 *
 * Return value:
 * None, but exits with an error code of %EXIT_FAILURE if there
 * is an error.
 */
void
snv_load_all_modules (void)
{
  char *path = getenv ("LTDL_LIBRARY_PATH");

  if (!path)
    return;

  if (lt_dlinit ()
      || lt_dlforeachfile (path, printf_load_module_callback, 0))

    /* Failing ltdl initialisation makes continuing somewhat futile... */
    {
      const char *dlerror = lt_dlerror ();
      fprintf (stderr, "ERROR: failed to initialize snprintfv: %s\n", dlerror);
      exit (EXIT_FAILURE);
    }
}
