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
#include <stdio.h>
#include <unistd.h>

typedef char *wine_get_unix_file_name_t (const WCHAR *);
static wine_get_unix_file_name_t *wine_get_unix_file_name_ptr;
typedef WCHAR *wine_get_dos_file_name_t (const char *);
static wine_get_dos_file_name_t *wine_get_dos_file_name_ptr;

/* Based on the source code for winepath.  */

static char *
maybe_convert_arg_to_unix (char *arg)
{
  if (wine_get_unix_file_name_ptr
      && arg[0] != '-'
      && (strchr (arg, '\\') || (arg[0] && arg[1] == ':')))
    {
      int len;
      WCHAR *dos_name_wide;
      char *unix_name, *ret;
      len = strlen (arg);
      dos_name_wide = malloc (sizeof (WCHAR) * (len + 1));
      MultiByteToWideChar(CP_ACP, 0, arg, -1, dos_name_wide, len + 1);
      unix_name = wine_get_unix_file_name_ptr (dos_name_wide);
      ret = strdup (unix_name);
      free (dos_name_wide);
      HeapFree (GetProcessHeap(), 0, unix_name);
      return ret;
    }
  else
    return arg;
}

static char *
maybe_convert_arg_to_dos (char *arg)
{
  if (wine_get_dos_file_name_ptr
      && arg[0] != '-'
      && strchr (arg, '/'))
    {
      int len;
      WCHAR *dos_name_wide;
      char dos_name[MAX_PATH+1];
      dos_name_wide = wine_get_dos_file_name_ptr (arg);
      len = wcslen (dos_name_wide);
      WideCharToMultiByte (CP_ACP, 0, dos_name_wide, -1, dos_name,
			   MAX_PATH, NULL, NULL);
      HeapFree (GetProcessHeap(), 0, dos_name_wide);
      return strdup (dos_name);
    }
  else
    return arg;
}

int
main (int argc, char **argv)
{
  int i;
  int ret, cmdlen;
  char *cmd = argv[1];

  wine_get_unix_file_name_ptr = (wine_get_unix_file_name_t *)
    GetProcAddress (GetModuleHandle ("KERNEL32"), "wine_get_unix_file_name");
  wine_get_dos_file_name_ptr = (wine_get_dos_file_name_t *)
    GetProcAddress (GetModuleHandle ("KERNEL32"), "wine_get_dos_file_name");

  cmdlen = strlen (cmd);
  argv[0] = maybe_convert_arg_to_dos (cmd);
  if (cmdlen > 4 && stricmp (cmd + cmdlen - 4, ".exe") == 0)
    for (i = 2; --argc > 1; i++)
      argv[i - 1] = maybe_convert_arg_to_dos (argv[i]);
  else
    for (i = 2; --argc > 1; i++)
      argv[i - 1] = maybe_convert_arg_to_unix (argv[i]);

  argv[i - 1] = NULL;
  ret = _spawnvp (_P_WAIT, argv[0], (const char* const *)argv);
  if (ret == -1)
    {
      perror ("winewrapper");
      ret = 124;
    }

  exit (ret);
}
