/***********************************************************************
 *
 *	Option handling and dispatching to installed .st scripts
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2007 Free Software Foundation, Inc.
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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "gstpub.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

const char *program_name;
const char **smalltalk_argv;
int smalltalk_argc;
int error;

struct tool {
  const char *name;
  const char *script;
  const char *options;
  const char *force_opt;
};

struct tool tools[] = {
  {
    "gst-load", "scripts/Load.st",
    "-h|--help -q|--quiet -v|-V|--verbose -n|--dry-run -f|--force \
	-t|--test -I|--image-file: --kernel-directory:",
    NULL
  },
  {
    "gst-reload", "scripts/Load.st",
    "-h|--help -q|--quiet -v|-V|--verbose -n|--dry-run -f|--force \
	-t|--test -I|--image-file: --kernel-directory:",
    "--force"
  },
  {
    "gst-package", "scripts/Package.st",
    "-h|--help --version --load --no-load --no-install --uninstall --dist \
        --test -t|--target-directory: --list-files: --list-packages \
        --srcdir: --distdir|--destdir: --copy --all-files --vpath \
        -n|--dry-run -I|--image-file: --kernel-directory:",
    NULL
  },
  {
    "gst-sunit", "scripts/Test.st",
    "-h|--help -q|--quiet -v|-V|--verbose -f|--file: -p|--package: \
	-I|--image-file: --kernel-directory:",
    NULL
  },
  {
    "gst-blox", "scripts/Browser.st",
    "-I|--image-file: --kernel-directory:",
    NULL
  },
  { NULL, NULL, NULL, NULL }
};

/* An option parser compatible with the one in the Getopt class.
   Does not support canonical option names, otherwise it is pretty
   complete.  */
 
struct option {
  char arg;
  const char *name;
  struct option *next;
};

#define OPT_NONE	0
#define OPT_MANDATORY	1
#define OPT_OPTIONAL	2

char short_opts[1 << (sizeof (char) * 8)];
struct option *long_opts;

void
option_error (const char *s, ...)
{
  static int first;
  va_list ap;
  if (!first)
    return;

  error = 1;
  first = 1;
  va_start (ap, s);

  vfprintf (stderr, s, ap);
  fprintf (stderr, "\n");
  va_end (ap);
  exit (1);
}

void
setup_option (char *p, char *end)
{
  int arg = 0;
  if (*p != '-')
    abort ();

  while (*end == ':')
    {
      *end-- = '\0';
      arg++;
    }

  if (arg > 2)
    abort ();

  while (p)
    {
      unsigned char short_opt = 0;
      const char *long_opt = NULL;

      if (*p++ != '-')
	abort ();
      if (*p == '-')
	{
	  ++p;
	  long_opt = strsep (&p, "|");
	}
      else
	{
	  short_opt = *p++;
	  if (!*p)
	    p = NULL;
	  else if (*p++ != '|')
	    abort ();
	}

      if (long_opt)
	{
	  struct option *opt = malloc (sizeof (struct option));
	  opt->name = strdup (long_opt);
	  opt->arg = arg;
	  opt->next = long_opts;
	  long_opts = opt;
	}
      else
	short_opts[(unsigned char) short_opt] = arg;
    }
}

void
setup_options (const char *str)
{
  char *copy = strdup (str);
  char *p = copy;

  memset (short_opts, -1, sizeof (short_opts));
  do
    {
      while (isspace (*p))
        p++;
      if (*p)
	{
          char *begin, *end;
          begin = strsep (&p, " \t\n");
          end = begin + strlen (begin) - 1;
          setup_option (begin, end);
	}
    }
  while (p && *p);

  free (copy);
}

void
parse_option (int short_opt, const char *long_opt, const char *arg)
{
  if (short_opt == 'I'
      || (long_opt && !strcmp (long_opt, "image-file")))
    {
      static int found_option;
      if (found_option)
	option_error ("duplicate --image-file option");
      found_option = true;
      smalltalk_argv[smalltalk_argc++] = "-I";
      smalltalk_argv[smalltalk_argc++] = arg;
    }

  if (long_opt && !strcmp (long_opt, "kernel-directory"))
    {
      static int found_option;
      if (found_option)
	option_error ("duplicate --kernel-directory option");
      found_option = true;
      smalltalk_argv[smalltalk_argc++] = "--kernel-directory";
      smalltalk_argv[smalltalk_argc++] = arg;
    }
}

int
parse_short_options (const char *name, const char *arg)
{
  while (*name)
    {
      unsigned char short_opt = (unsigned char) *name++;
      int have_arg = short_opts[short_opt];
      if (have_arg == -1)
        option_error ("invalid option -%c", short_opt);

      if (have_arg == OPT_NONE || (have_arg == OPT_OPTIONAL && !*name))
        parse_option (short_opt, NULL, NULL);

      else if (*name || arg)
        {
          parse_option (short_opt, NULL, *name ? name : arg);
          return *name ? 1 : 2;
        }

      else /* if (have_arg == OPT_MANDATORY) */
        option_error ("expected argument for option -%s", name[-1]);
    }

  return 1;
}

int
parse_long_option (const char *name, const char *arg)
{
  struct option *all_opts, *opt = NULL;
  int num_matches = 0;
  int len;
  const char *p = strchr (name, '=');

  if (!p)
    len = strlen (name);
  else
    len = p++ - name;

  for (all_opts = long_opts; all_opts; all_opts = all_opts->next)
    if (!memcmp (name, all_opts->name, len))
      {
	opt = all_opts;
	if (opt->name[len] == '\0')
	  {
	    /* Exact match!  */
	    num_matches = 1;
	    break;
	  }
	else
	  num_matches++;
      }

  if (!opt)
    option_error ("invalid option --%.*s", len, name);

  if (num_matches > 1)
    option_error ("ambiguous option --%.*s", len, name);

  if (opt->arg == OPT_NONE && p)
    option_error ("unexpected argument for option --%s", opt->name);

  else if (p || opt->arg != OPT_MANDATORY)
    {
      parse_option (0, opt->name, p);
      return 1;
    }

  else if (!arg)
    option_error ("expected argument for option --%s", opt->name);

  else
    {
      parse_option (0, opt->name, arg);
      return 2;
    }

  return 1;
}

void
parse_options (const char **argv)
{
  int at_end = 0;
  while (*argv)
    {
      if (at_end || argv[0][0] != '-')
	{
	  parse_option (0, NULL, argv[0]);
	  argv++;
	}

      else if (argv[0][1] != '-')
	argv += parse_short_options (&argv[0][1], argv[1]);

      else if (argv[0][2] == '\0')
	{
	  at_end = true;
	  argv++;
	}

      else
	argv += parse_long_option (&argv[0][2], argv[1]);
    }
}

int
main(int argc, const char **argv)
{
  int i;
  int result;

  program_name = strrchr (argv[0], '/');
  if (program_name)
    program_name++;
  else
    program_name = argv[0];

  if (!strcmp (program_name, "gst-tool"))
    {
      argv++, argc--;
      program_name = argv[0];
    }

  smalltalk_argv = alloca (sizeof (const char *) * (argc + 9));
  smalltalk_argc = 1;
  smalltalk_argv[0] = argv[0];

  for (i = 0; ; i++)
    if (!tools[i].name)
      exit (127);
    else if (!strcmp (tools[i].name, program_name))
      break;

  setup_options (tools[i].options);
  parse_options (&argv[1]);

  smalltalk_argv[smalltalk_argc++] = "--no-user-files";
  smalltalk_argv[smalltalk_argc++] = "-qK";
  smalltalk_argv[smalltalk_argc++] = tools[i].script;
  smalltalk_argv[smalltalk_argc++] = "-a";
  if (tools[i].force_opt)
    smalltalk_argv[smalltalk_argc++] = tools[i].force_opt;

  memcpy (&smalltalk_argv[smalltalk_argc], &argv[1], argc * sizeof (char *));
  smalltalk_argc += argc - 1;

#ifdef CMD_LN_S
  setenv ("LN_S", CMD_LN_S, 0);
#endif
#ifdef CMD_INSTALL
  setenv ("INSTALL", CMD_INSTALL, 0);
#endif
#ifdef CMD_ZIP
  setenv ("XZIP", CMD_ZIP, 0);
#endif

  gst_smalltalk_args(smalltalk_argc, smalltalk_argv);
  result = gst_init_smalltalk();
  if (result != 0)
    exit (result < 0 ? 1 : result);
    
  gst_top_level_loop();
  exit (error ? 1 : 0);
}
