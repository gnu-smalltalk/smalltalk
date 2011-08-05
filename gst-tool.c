/***********************************************************************
 *
 *	Option handling and dispatching to installed .st scripts
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2007, 2008, 2009, 2010 Free Software Foundation, Inc.
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
#include <errno.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

char *program_name;
const char *kernel_dir;
const char *image_file;
int flags = GST_NO_TTY;
int run_as_daemon;
int usage;

struct tool {
  const char *name;
  const char *script;
  const char *options;
  const char *force_opt;
  mst_Boolean allow_other_arguments;
};

const struct tool tools[] = {
  {
    "gst-convert", "scripts/Convert.st",
    "-h|--help --version -q|--quiet -v|-V|--verbose -C|--class: -r|--rule: \
        -c|--category: -f|--format: -o|--output: -I|--image-file: \
        -F|--output-format: --kernel-directory:",
    NULL, true
  },
  {
    "gst-load", "scripts/Load.st",
    "-h|--help --version -q|--quiet -v|-V|--verbose -n|--dry-run -f|--force \
	--start:: -t|--test -I|--image-file: --kernel-directory: \
	-i|--rebuild-image",
    NULL, true
  },
  {
    "gst-reload", "scripts/Load.st",
    "-h|--help --version -q|--quiet -v|-V|--verbose -n|--dry-run -f|--force \
	--start:: -t|--test -I|--image-file: --kernel-directory: \
	-i|--rebuild-image",
    "--force\0", true
  },
  {
    "gst-package", "scripts/Package.st",
    "-h|--help --version -v|-V|--verbose --load --no-load --no-install --uninstall --dist \
        --prepare --test -t|--target-directory: --list-files: --list-packages \
        --srcdir: --distdir|--destdir: --copy --all-files --vpath -n|--dry-run \
        -I|--image-file: --kernel-directory: --update|--download ",
    NULL, true
  },
  {
    "gst-sunit", "scripts/Test.st",
    "-h|--help --version -q|--quiet -v|-V|--verbose -f|--file: -p|--package: \
	-I|--image-file: --kernel-directory:",
    NULL, true
  },
  {
    "gst-browser", "scripts/Load.st",
    "-i|--rebuild-image -I|--image-file: --kernel-directory: -v|-V|--verbose",
    "--dry-run\0--start\0Browser\0", false
  },
  {
    "gst-blox", "scripts/Load.st",
    "-i|--rebuild-image -I|--image-file: --kernel-directory: -v|-V|--verbose",
    "--dry-run\0--start\0BLOXBrowser\0", false
  },
  {
    "gst-doc", "scripts/GenDoc.st",
    "-h|--help --version -p|--package: -f|--file: -I|--image-file: \
        -n|--namespace: -o|--output: --kernel-directory: -F|--output-format: -v|-V|--verbose",
    NULL, true
  },
  {
    "gst-remote", "scripts/Remote.st",
    "-h|--help --version --daemon --server -p|--port: -f|--file: -e|--eval: \
 	-l|--login: --package: --start: --stop: --pid --kill --snapshot:: \
	-I|--image-file: --kernel-directory: -v|-V|--verbose",
    NULL, true
  },
  {
    "gst-profile", "scripts/Profile.st",
    "-f|--file: -e|--eval: -o|--output: -h|--help --version \
	--no-separate-blocks -v|-V|--verbose",
    NULL, true
  },

  { NULL, NULL, NULL, NULL, false }
};

/* An option parser compatible with the one in the Getopt class.
   Does not support canonical option names, otherwise it is pretty
   complete.  */
 
struct long_option {
  char arg;
  const char *name;
  struct long_option *next;
};

#define OPT_NONE	0
#define OPT_MANDATORY	1
#define OPT_OPTIONAL	2

char short_opts[1 << (sizeof (char) * 8)];
struct long_option *long_opts;
const struct tool *tool;

void
option_error (const char *s, ...)
{
  va_list ap;
  va_start (ap, s);
  fprintf (stderr, "%s: ", program_name);
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
	  struct long_option *opt = malloc (sizeof (struct long_option));
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
  if (!short_opt && !long_opt && !tool->allow_other_arguments)
    {
      option_error ("invalid argument '%s'", arg);
      return;
    }

  if (short_opt == 'I'
      || (long_opt && !strcmp (long_opt, "image-file")))
    {
      if (image_file)
	option_error ("duplicate --image-file option");
      image_file = arg;
    }

  if (long_opt && !strcmp (long_opt, "kernel-directory"))
    {
      if (kernel_dir)
	option_error ("duplicate --kernel-directory option");
      kernel_dir = arg;
    }

  if (short_opt == 'i'
      || (long_opt && !strcmp (long_opt, "rebuild-image")))
    flags |= GST_REBUILD_IMAGE;

  if (long_opt && !strcmp (long_opt, "daemon"))
    {
#ifdef HAVE_FORK
      run_as_daemon = 1;
#else
      fprintf (stderr, "Daemon operation not supported.");
      exit (77);
#endif
    }

  if (long_opt && !strcmp (long_opt, "version"))
    usage = 1;

  if (short_opt == 'h'
      || (long_opt && !strcmp (long_opt, "help")))
    usage = 1;
}

#ifdef HAVE_FORK
static void
fork_daemon (void)
{
  int child_pid;

#ifdef SIGHUP
  signal (SIGHUP, SIG_IGN);
#endif

  child_pid = fork();
  if (child_pid < 0)
    {
      perror("Failed to fork daemon");
      exit(1);
    }

  /* Stop parent.  */
  if (child_pid != 0)
    exit (0);

  /* Detach and spawn server.
     Create a new SID for the child process */
#ifdef HAVE_SETSID
  if (setsid() < 0)
    {
      perror("setsid failed");
      exit(1);
    }
#endif

#ifdef SIGHUP
  signal (SIGHUP, SIG_DFL);
#endif
}
#endif

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
        option_error ("expected argument for option -%c", short_opt);
    }

  return 1;
}

int
parse_long_option (const char *name, const char *arg)
{
  struct long_option *all_opts, *opt = NULL;
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
      if (at_end || argv[0][0] != '-' || argv[0][1] == '\0')
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
  int smalltalk_argc;
  const char **smalltalk_argv;
  const char *executable_name;
  int i;
  int result;

#ifdef _WIN32
  executable_name = strrchr (argv[0], '\\');
  if (!executable_name || strchr (executable_name, '/'))
    executable_name = strrchr (argv[0], '/');
#else
  executable_name = strrchr (argv[0], '/');
#endif /* _WIN32 */

  if (executable_name)
    executable_name++;
  else
    executable_name = argv[0];

  /* Check if used in the build tree.  */
  if (!strcasecmp (executable_name, "gst-tool" EXEEXT)
      || !strcasecmp (executable_name, "gst-tool" ARGV_EXEEXT)
      || !strcasecmp (executable_name, "lt-gst-tool" EXEEXT)
      || !strcasecmp (executable_name, "lt-gst-tool" ARGV_EXEEXT))
    {
      program_name = strdup (argv[1]);
      flags |= GST_IGNORE_USER_FILES;
      argv++, argc--;
    }
  else
    {
      int n = strlen (executable_name);
      program_name = strdup (executable_name);

      /* Strip the executable extension if needed.  */
      if (EXEEXT[0]
	  && n > strlen (EXEEXT)
	  && !strcasecmp (program_name + n - strlen (EXEEXT), EXEEXT))
	program_name[n - strlen (EXEEXT)] = 0;
    }

  for (i = 0; ; i++)
    if (!tools[i].name)
      exit (127);
    else if (!strcmp (tools[i].name, program_name))
      break;

  tool = &tools[i];
  setup_options (tool->options);
  parse_options (&argv[1]);

#ifdef HAVE_FORK
  if (run_as_daemon && !usage)
    fork_daemon ();
#endif

  if (tool->force_opt)
    {
      const char *p;
      int n;
      for (p = tool->force_opt, n = 0; *p; p += strlen (p) + 1)
	n++;

      smalltalk_argc = argc + n - 1;
      smalltalk_argv = alloca (sizeof (char *) * smalltalk_argc);
      for (p = tool->force_opt, n = 0; *p; p += strlen (p) + 1)
	smalltalk_argv[n++] = p;
      memcpy (&smalltalk_argv[n], &argv[1], argc * sizeof (char *));
    }
  else
    {
      smalltalk_argc = argc - 1;
      smalltalk_argv = argv + 1;
    }

#ifdef CMD_LN_S
  if (!getenv ("LN_S"))
    setenv ("LN_S", CMD_LN_S, 0);
#endif
#ifdef CMD_INSTALL
  if (!getenv ("INSTALL"))
    setenv ("INSTALL", CMD_INSTALL, 0);
#endif
#ifdef CMD_ZIP
  if (!getenv ("XZIP"))
    setenv ("XZIP", CMD_XZIP, 0);
#endif

  gst_set_var (GST_VERBOSITY, 0);
  gst_smalltalk_args (smalltalk_argc, smalltalk_argv);
  gst_set_executable_path (argv[0]);
  result = gst_initialize (kernel_dir, image_file, flags);
  if (result != 0)
    exit (result < 0 ? 1 : result);
    
  if (!gst_process_file (tool->script, GST_DIR_KERNEL_SYSTEM))
    fprintf (stderr, "%s: Couldn't open kernel file `%s': %s\n",
	     executable_name, tool->script, strerror (errno));

  gst_invoke_hook (GST_ABOUT_TO_QUIT);
  exit (0);
}
