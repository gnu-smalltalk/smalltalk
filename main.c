/***********************************************************************
 *
 *	Main Module
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2004,2006,2008,2009
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
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
#include "getopt.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

#ifdef ENABLE_DISASSEMBLER
#define TRUE_FALSE_ALREADY_DEFINED
#include "dis-asm.h"
#endif

static const char help_text[] =
  "GNU Smalltalk usage:"
  "\n"
  "\n    gst [ flag ... ] [ file ... ]"
  "\n    gst [ flag ... ] { -f | --file } file [ args ... ]"
  "\n"
  "\nShort flags can appear either as -xyz or as -x -y -z.  If an option is"
  "\nmandatory for a long option, it is also mandatory for a short one. The"
  "\ncurrently defined set of flags is:"
  "\n   -a --smalltalk-args\t\t Pass the remaining arguments to Smalltalk."
  "\n   -c --core-dump\t\t Dump core on fatal signal."
  "\n   -D --declaration-trace\t Trace compilation of all loaded files."
  "\n   -E --execution-trace\t\t Trace execution of all loaded files."
  "\n   -g --no-gc-message\t\t Do not print garbage collection messages."
  "\n   -H --help\t\t\t Print this message and exit."
  "\n   -i --rebuild-image\t\t Ignore the image file; rebuild it from scratch."
  "\n      --maybe-rebuild-image\t Rebuild the image file from scratch if\n\t\t\t\t any kernel file is newer."
  "\n   -I --image FILE\t\t Instead of `gst.im', use FILE as the image\n\t\t\t\t file, and ignore the kernel files' timestamps.\n"
  "\n   -K --kernel-file FILE\t Make FILE's path relative to the image path."
  "\n   -q --quiet --silent\t\t Do not print execution information."
  "\n   -r --regression-test\t\t Run in regression test mode, i.e. make\n\t\t\t\t printed messages constant."
  "\n   -S --snapshot\t\t Save a snapshot just before exiting."
  "\n   -v --version\t\t\t Print the Smalltalk version number and exit."
  "\n   -V --verbose\t\t\t Show names of loaded files and execution stats."
  "\n      --emacs-mode\t\t Execute as a `process' (from within Emacs)"
  "\n      --kernel-directory DIR\t Look for kernel files in directory DIR."
  "\n      --no-user-files\t\t Don't read user customization files.\n"
  "\n   -\t\t\t\t Read input from standard input explicitly."
  "\n"
  "\nFiles are loaded one after the other.  After the last one is loaded,"
  "\nSmalltalk will exit.  If no files are specified, Smalltalk reads from"
  "\nthe terminal, with prompts."
  "\n"
  "\nIn the second form, the file after -f is the last loaded file; any"
  "\nparameter after that file is passed to the Smalltalk program."
  "\n" "\nReport bugs to <help-smalltalk@gnu.org>"
  "\nGNU Smalltalk home page: <http://smalltalk.gnu.org/>."
  "\nGeneral help using GNU software: <http://www.gnu.org/gethelp/>."
  "\n\n";

static const char copyright_and_legal_stuff_text[] =
  "GNU Smalltalk version %s%s"
  "\nCopyright 2009 Free Software Foundation, Inc."
  "\nWritten by Steve Byrne (sbb@gnu.org) and Paolo Bonzini (bonzini@gnu.org)"
  "\n"
  "\nGNU Smalltalk comes with NO WARRANTY, to the extent permitted by law."
  "\nYou may redistribute copies of GNU Smalltalk under the terms of the"
  "\nGNU General Public License.  For more information, see the file named"
  "\nCOPYING."
  "\n"
  "\nUsing default kernel path: %s"
  "\nUsing default image path: %s"
  "\n\n";

#define OPT_KERNEL_DIR 2
#define OPT_NO_USER 3
#define OPT_EMACS_MODE 4
#define OPT_MAYBE_REBUILD 5

#define OPTIONS "-acDEf:ghiI:K:lL:QqrSvV"

static const struct option long_options[] = {
  {"smalltalk-args", 0, 0, 'a'},
  {"core-dump", 0, 0, 'c'},
  {"declaration-trace", 0, 0, 'D'},
  {"execution-trace", 0, 0, 'E'},
  {"file", 0, 0, 'f'},
  {"kernel-directory", 1, 0, OPT_KERNEL_DIR},
  {"no-user-files", 0, 0, OPT_NO_USER},
  {"no-gc-message", 0, 0, 'g'},
  {"help", 0, 0, 'h'},
  {"maybe-rebuild-image", 0, 0, OPT_MAYBE_REBUILD},
  {"rebuild-image", 0, 0, 'i'},
  {"image-file", 1, 0, 'I'},
  {"kernel-file", 1, 0, 'K'},
  {"emacs-mode", 0, 0, OPT_EMACS_MODE},
  {"quiet", 0, 0, 'q'},
  {"no-messages", 0, 0, 'q'},
  {"silent", 0, 0, 'q'},
  {"regression-test", 0, 0, 'r'},
  {"snapshot", 0, 0, 'S'},
  {"version", 0, 0, 'v'},
  {"verbose", 0, 0, 'V'},
  {NULL, 0, 0, 0}
};

struct loaded_file {
  mst_Boolean kernel_path;
  const char *file_name;
};

static struct loaded_file *loaded_files;
int n_loaded_files;


/* These contain the default path that was picked (after looking at the
   environment variables) for the kernel files and the image.  */
char *kernel_dir = NULL;

/* Mapped to the corresponding GST variable, with additional care to
   handle more than 1 occurrence of the option.  */
int declare_tracing;
int execution_tracing;

/* Flags to be passed to gst_initialize.  Set mostly from command-line
   variables.  */
int flags;

/* We implement -S ourselves.  This flag is set to 1 if -S is passed.  */
mst_Boolean snapshot_after_load;

/* This is the name of the binary image to load.  If it is not NULL after the
   command line is parsed, the checking of the dates of the kernel source files
   against the image file date is overridden.  If it is NULL, it is set to
   default_image_name.  */
const char *image_file = NULL;

/* Prompt; modified if --emacs-process is given to add a ^A in front of it.  */
const char *stdin_prompt = "st> ";


#define EMACS_PROCESS_MARKER    "\001"

void
parse_args (int argc,
	    const char **argv)
{
  int ch, prev_optind = 1, minus_a_optind = -1;

  /* get rid of getopt's own error reporting for invalid options */
  opterr = 1;

  while ((ch = getopt_long (argc, (char **) argv, OPTIONS,
			    long_options, NULL)) != -1)
    {

#if DEBUG_GETOPT
      printf ("%c \"%s\"  %d  %d  %d\n", ch, optarg ? optarg : "",
	      optind, prev_optind, minus_a_optind);
#endif

      switch (ch)
	{
	case 'c':
	  gst_set_var (GST_MAKE_CORE_FILE, true);
	  break;
	case 'D':
	  declare_tracing++;
	  break;
	case 'E':
	  execution_tracing++;
	  break;
	case 'g':
	  gst_set_var (GST_GC_MESSAGE, false);
	  break;
	case OPT_MAYBE_REBUILD:
	  flags |= GST_MAYBE_REBUILD_IMAGE;
	  break;
	case 'i':
	  flags |= GST_REBUILD_IMAGE;
	  break;
	case OPT_EMACS_MODE:
	  stdin_prompt = EMACS_PROCESS_MARKER "st> ";
	  gst_set_var (GST_VERBOSITY, 1);
	  flags |= GST_NO_TTY;
	  break;
	case 'q':
	case 'Q':
	  gst_set_var (GST_VERBOSITY, 1);
	  break;
	case 'r':
	  gst_set_var (GST_REGRESSION_TESTING, true);
	  break;
	case 'S':
	  snapshot_after_load = true;
	  break;
	case 'V':
	  gst_set_var (GST_VERBOSITY, 3);
	  break;

	case 'f':
	  /* Same as -q, passing a file, and -a.  */
	  gst_set_var (GST_VERBOSITY, 0);
	  loaded_files[n_loaded_files].kernel_path = false;
	  loaded_files[n_loaded_files++].file_name = optarg;

	case 'a':
	  /* "Officially", the C command line ends here.  The Smalltalk 
	     command line, instead, starts right after the parameter
	     containing -a. -a is handled specially by the code that
	     tests the minus_a_optind variable, so that ./gst -aI 
	     xxx yyy for example interprets xxx as the image to be
	     loaded.  */
	  minus_a_optind = optind;
	  break;

	case 'I':
	  if (image_file)
	    {
	      fprintf (stderr, "gst: Only one -I option should be given\n");
	      exit (1);
	    }
	  image_file = optarg;
	  break;

	case 'K':
	  loaded_files[n_loaded_files].kernel_path = true;
	  loaded_files[n_loaded_files++].file_name = optarg;
	  break;

	case OPT_KERNEL_DIR:
	  if (kernel_dir)
	    {
	      fprintf (stderr, "gst: Only one --kernel-directory option should"
			       " be given\n");
	      exit (1);
	    }
	  kernel_dir = optarg;
	  break;

	case OPT_NO_USER:
	  flags |= GST_IGNORE_USER_FILES;
	  break;

	case 'v':
	  printf (copyright_and_legal_stuff_text, VERSION,
		  PACKAGE_GIT_REVISION,
		  gst_relocate_path (KERNEL_PATH),
		  gst_relocate_path (IMAGE_PATH));
	  exit (0);

	case '\1':
	  loaded_files[n_loaded_files].kernel_path = false;
	  loaded_files[n_loaded_files++].file_name = optarg;
	  break;

	default:
	  /* Fall through and show help message */

	case 'h':
	  printf (help_text);
	  exit (ch == 'h' ? 1 : 0);
	}

      if (minus_a_optind > -1
	  && (ch == '\1'
	      || ch == 'f'
	      || optind > prev_optind
	      || optind > minus_a_optind))
	{
	  /* If the first argument was not an option, undo and leave.  */
	  if (ch == '\1')
	    optind--;

	  /* If the first argument after -a was not an option, or if there
	     is nothing after -a, or if we finished processing the argument
	     which included -a, leave.  */
	  gst_smalltalk_args (argc - optind, argv + optind);
	  break;
	}

      prev_optind = optind;
    }
}

int
main(int argc, const char **argv)
{
  int result;
  struct loaded_file *file;

  loaded_files =
    (struct loaded_file *) alloca (sizeof (struct loaded_file) * argc);

  gst_set_executable_path (argv[0]);
#ifdef __APPLE__
  if (argc >= 2 && strncmp (argv[1], "-psn", 4) == 0)
    gst_smalltalk_args (argc - 1, argv + 1);
  else
#endif
    parse_args (argc, argv);

  /* These might go away in the next release.  */
  if (!kernel_dir)
    {
      kernel_dir = getenv ("SMALLTALK_KERNEL");
      if (kernel_dir)
	{
          flags |= GST_IGNORE_BAD_KERNEL_PATH;
          fprintf (stderr, "gst: SMALLTALK_KERNEL variable deprecated, "
		           "use --kernel-directory instead\n");
	}
    }

  if (!image_file)
    {
      const char *image_dir = getenv ("SMALLTALK_IMAGE");
      flags |= GST_MAYBE_REBUILD_IMAGE;
      if (image_dir)
        {
	  int len = strlen (image_dir);
	  char *p = malloc (len + 8);
	  memcpy (p, image_dir, len);
	  strcpy (p + len, "/gst.im");
	  image_file = p;
          flags |= GST_IGNORE_BAD_IMAGE_PATH;
          fprintf (stderr, "gst: SMALLTALK_IMAGE variable deprecated, "
		           "use -I instead\n");
        }
    }

  gst_set_var (GST_DECLARE_TRACING, declare_tracing > 1);
  gst_set_var (GST_EXECUTION_TRACING, execution_tracing > 1);
  result = gst_initialize (kernel_dir, image_file, flags);
  if (result)
    exit (result);

  gst_set_var (GST_DECLARE_TRACING, declare_tracing > 0);
  gst_set_var (GST_EXECUTION_TRACING, execution_tracing > 0);

  for (file = loaded_files; file < &loaded_files[n_loaded_files]; file++)
    {
      /* - by itself indicates standard input */
      if (!file->kernel_path && !strcmp (file->file_name, "-"))
        gst_process_stdin (stdin_prompt);

      else
	{
	  errno = 0;
	  if (!gst_process_file (file->file_name,
				 file->kernel_path ? GST_DIR_BASE : GST_DIR_ABS))
	    {
	      if (file->kernel_path)
		fprintf (stderr, "gst: Couldn't open kernel file `%s': %s\n",
			 file->file_name, strerror (errno));
	      else
		fprintf (stderr, "gst: Couldn't open file `%s': %s\n",
			 file->file_name, strerror (errno));
	    }
	}
    }

  if (n_loaded_files == 0)
    gst_process_stdin (stdin_prompt);

  if (snapshot_after_load)
    gst_msg_sendf (NULL, "%v %o snapshot: %o", 
		   gst_class_name_to_oop ("ObjectMemory"),
                   gst_str_msg_send (gst_class_name_to_oop ("File"),
				     "image", NULL));

  gst_invoke_hook (GST_ABOUT_TO_QUIT);
  exit (0);
}

#ifdef ENABLE_DISASSEMBLER
void disassemble(stream, from, to)
     FILE *stream;
     char *from, *to;
{
  disassemble_info info;
  bfd_vma pc = (bfd_vma) from;
  bfd_vma end = (bfd_vma) to;

  INIT_DISASSEMBLE_INFO(info, stream, fprintf);
  info.buffer = NULL;
  info.buffer_vma = 0;
  info.buffer_length = end;

  while (pc < end) {
    fprintf_vma(stream, pc);
    putc('\t', stream);
#ifdef __i386__
    pc += print_insn_i386(pc, &info);
#endif
#ifdef __ppc__
    pc += print_insn_big_powerpc(pc, &info);
#endif
#ifdef __sparc__
    pc += print_insn_sparc(pc, &info);
#endif
    putc('\n', stream);
  }
}
#endif
