/***********************************************************************
 *
 *	Conversion of Windows path to Unix for .star file creation
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2009 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
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

/* When cross-compiling under Wine, GNU Smalltalk will see Windows paths
   and so it will try to pass them to the native zip program.  This program
   will find and convert such paths, so long as they are distinct
   arguments in argv.  */

#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef char *wine_get_unix_file_name_t (const WCHAR *);
static wine_get_unix_file_name_t *wine_get_unix_file_name_ptr;

/* Based on the source code for winepath.  */

static char *
maybe_convert_arg (char *arg)
{
  if (wine_get_unix_file_name_ptr
      && (strchr (arg, '\\') || (arg[0] && arg[1] == ':')))
    {
      int len;
      WCHAR *win_name_wide;
      char *unix_name, *ret;
      len = strlen (arg);
      win_name_wide = malloc (sizeof (WCHAR) * (len + 1));
      MultiByteToWideChar(CP_ACP, 0, arg, -1, win_name_wide, len + 1);
      unix_name = wine_get_unix_file_name_ptr (win_name_wide);
      ret = strdup (unix_name);
      free (win_name_wide);
      HeapFree (GetProcessHeap(), 0, unix_name);
      return ret;
    }
  else
    return arg;
}

int
main (int argc, char **argv)
{
  int i;

  wine_get_unix_file_name_ptr = (wine_get_unix_file_name_t *)
    GetProcAddress (GetModuleHandle ("KERNEL32"), "wine_get_unix_file_name");

  argv[0] = argv[1];
  for (i = 2; --argc > 1; i++)
    argv[i - 1] = maybe_convert_arg (argv[i]);

  argv[i - 1] = NULL;
  execvp (argv[0], argv);

  /* Error.  */
  perror ("winewrapper");
  exit (1);
}
