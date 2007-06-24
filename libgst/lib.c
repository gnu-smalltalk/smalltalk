/******************************** -*- C -*- ****************************
 *
 *	Public library entry points
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006
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



#include "gstpriv.h"
#include "getopt.h"

#ifndef MAXPATHLEN
#define MAXPATHLEN		1024	/* max length of a file and path */
#endif


/* Define to debug the getopt code.  */
/* #define DEBUG_GETOPT */

#ifdef MSDOS
#define LOCAL_BASE_DIR_NAME		"_st"
#else
#define LOCAL_BASE_DIR_NAME		".st"
#endif

#define USER_INIT_FILE_NAME		"init.st"
#define USER_PRE_IMAGE_FILE_NAME	"pre.st"
#define LOCAL_KERNEL_DIR_NAME		"kernel"
#define SITE_PRE_IMAGE_FILE_NAME	"site-pre.st"



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
#ifndef ENABLE_JIT_TRANSLATION
  "\n   -E --execution-trace\t\t Trace execution of all loaded files."
#endif
  "\n   -g --no-gc-message\t\t Do not print garbage collection messages."
  "\n   -H --help\t\t\t Print this message and exit."
  "\n   -i --rebuild-image\t\t Ignore the image file; rebuild it from scratch."
  "\n   -I --image-file FILE\t\t Instead of `gst.im', use FILE as the image\n\t\t\t\t file, and ignore the kernel files' timestamps.\n"
  "\n   -K --kernel-file FILE\t Make FILE's path relative to the image path."
  "\n   -q --quiet --silent\t\t Do not print execution information."
  "\n   -r --regression-test\t\t Run in regression test mode, i.e. make\n\t\t\t\t printed messages constant.\n"
  "\n   -S --snapshot\t\t Save a snapshot just before exiting."
  "\n   -v --version\t\t\t Print the Smalltalk version number and exit."
  "\n   -V --verbose\t\t\t Print names of loaded files and execution stats."
  "\n      --emacs-mode\t\t Execute as a `process' (from within Emacs)"
  "\n      --image-dir DIR\t\t Look for the image in directory DIR."
  "\n      --kernel-dir DIR\t\t Look for kernel files in directory DIR."
  "\n      --no-user-files\t\t Don't read user customization files.\n"
  "\n   -\t\t\t\t Read input from standard input explicitly."
  "\n"
  "\nFiles are loaded one after the other.  After the last one is loaded,"
  "\nSmalltalk will exit.  If no files are specified, Smalltalk reads from"
  "\nthe terminal, with prompts."
  "\n"
  "\nIn the second form, the file after -f is the last loaded file; any"
  "\nparameter after that file is passed to the Smalltalk program."
  "\n" "\nReport bugs to help-smalltalk@gnu.org\n";

static const char copyright_and_legal_stuff_text[] =
  "GNU Smalltalk version %s"
  "\nCopyright 2006 Free Software Foundation, Inc."
  "\nWritten by Steve Byrne (sbb@gnu.org) and Paolo Bonzini (bonzini@gnu.org)"
  "\n"
  "\nGNU Smalltalk comes with NO WARRANTY, to the extent permitted by law."
  "\nYou may redistribute copies of GNU Smalltalk under the terms of the"
  "\nGNU General Public License.  For more information, see the file named"
  "\nCOPYING."
  "\n"
  "\nUsing default kernel path: %s" "\nUsing default image path: %s"
  "\n";

#define OPT_KERNEL_DIR 2
#define OPT_IMAGE_DIR 3
#define OPT_NO_USER 4
#define OPT_EMACS_MODE 5

static const struct option long_options[] = {
  {"smalltalk-args", 0, 0, 'a'},
  {"core-dump", 0, 0, 'c'},
  {"declaration-trace", 0, 0, 'D'},
#ifndef ENABLE_JIT_TRANSLATION
  {"execution-trace", 0, 0, 'E'},
#endif
  {"file", 0, 0, 'f'},
  {"kernel-directory", 1, 0, OPT_KERNEL_DIR},
  {"image-directory", 1, 0, OPT_IMAGE_DIR},
  {"no-user-files", 0, 0, OPT_NO_USER},
  {"no-gc-message", 0, 0, 'g'},
  {"help", 0, 0, 'H'},
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

enum user_dir {
  NO_USER_DIR,
  KERNEL_USER_DIR,
  BASE_USER_DIR
};

static struct loaded_file *loaded_files;
int n_loaded_files;


/* When true, this flag suppresses the printing of execution-related
 * messages, such as the number of byte codes executed by the
 * last expression, etc.
 */
int _gst_verbosity = 2;

/* These contain the default path that was picked (after looking at the
   environment variables) for the kernel files and the image.  */
const char *_gst_kernel_file_path = NULL;
const char *_gst_image_file_path = NULL;

/* The ".st" directory, in the current directory or in the user's
   home directory.  */
const char *_gst_user_file_base_path;

/* Whether to look for user files.  */
static mst_Boolean no_user_files;

/* This is the name of the binary image to load.  If it is not NULL after the
   command line is parsed, the checking of the dates of the kernel source files
   against the image file date is overridden.  If it is NULL, it is set to
   default_image_name.  */
char *_gst_binary_image_name = NULL;

/* This is used by the callin functions to auto-initialize Smalltalk.
   When it's not true, initialization needs to be performed.  It's set
   to true by gst_init_smalltalk().  */
mst_Boolean _gst_smalltalk_initialized = false;

/* This is used to avoid doing complicated things (currently, this
   includes call-ins before and after _gst_execute_statements) before
   the system is ready to do them.  */
mst_Boolean _gst_kernel_initialized = false;

/* This is TRUE if we are doing regression testing, and causes
   whatever sources of variance to be suppressed (such as printing out
   execution statistics).  */
mst_Boolean _gst_regression_testing = false;



/***********************************************************************
 *
 *	Private declarations
 *
 ***********************************************************************/

/* Parse the Smalltalk source code contained in FILENAME.  If QUIET
   is true, for no reason show messages about the execution state (this
   is turned on while loading kernel files).  */
static mst_Boolean process_file (const char *fileName);

/* Parse the Smalltalk source code read from stdin.  */
static void process_stdin ();

/* Answer whether it is ok to load the binary image pointed to by
   _gst_binary_image_name.  This is good is the image file is local
   and newer than all of the kernel files, or if the image file is
   global, newer than all of the global kernel files, and no local
   kernel file is found.  */
static mst_Boolean ok_to_load_binary (void);

/* Attempts to find a viable Smalltalk file for user-level customization.
   FILENAME is a simple file name, sans directory; the file name to use 
   for the particular file is returned, or NULL if it is not found.  */
static char *find_user_file (const char *fileName);

/* Attempts to find a viable kernel Smalltalk file (.st file).
   FILENAME is a simple file name, sans directory; the file name to use 
   for the particular kernel file is returned.
   If there is a file in the .stkernel directory with name FILENAME, that is
   returned; otherwise the kernel path is prepended to FILENAME (separated
   by a slash, of course) and that is stored in the string that is returned.  */
static char *find_kernel_file (const char *fileName, const char *systemPrefix,
			       enum user_dir userDir);

/* Loads the kernel Smalltalk files.  It uses a vector of file names,
   and loads each file individually.  To provide for greater
   flexibility, if a one of the files exists in the current directory,
   that is used in preference to one in the default location.  The
   default location can be overridden at runtime by setting the
   SMALLTALK_KERNEL environment variable.  */
static int load_standard_files (void);

/* Sets up the paths for the kernel source directory and for where the
   saved Smalltalk binary image lives.  Uses environment variables
   SMALLTALK_KERNEL and SMALLTALK_IMAGE if they are set, otherwise
   uses the paths passed by the makefiles.  */
static void init_paths (void);

/* This routine scans the command line arguments, accumulating
   information and setting flags.  */
static int parse_args (int argc,
		       const char **argv);

/* Path names for the per-user customization files, respectively
   init.st (loaded at every startup) and pre.st (loaded before a local
   image is saved.  */
static const char *user_init_file;
static const char *user_pre_image_file;
static const char *site_pre_image_file;

/* Set by command line flag.  When true, Smalltalk saves a snapshot after
   loading the files on the command line, before exiting.  */
static mst_Boolean snapshot_after_load = false;

/* If true, skip date checking of kernel files vs. binary image; pretend
   that binary image does not exist.  */
static mst_Boolean ignore_image = false;

/* The complete list of "kernel" class and method definitions.  Each
   of these files is loaded, in the order given below.  Their last
   modification dates are compared against that of the image file; if
   any are newer, the image file is ignored, these files are loaded,
   and a new image file is created.
   
   As a provision for when we'll switch to a shared library, this
   is not an array but a list of consecutive file names.  */
static const char standard_files[] = {
  "Builtins.st\0"
  "SysDict.st\0"
  "Object.st\0"
  "Message.st\0"
  "DirMessage.st\0"
  "Boolean.st\0"
  "False.st\0"
  "True.st\0"
  "Magnitude.st\0"
  "Integer.st\0"
  "Date.st\0"
  "Time.st\0"
  "Number.st\0"
  "Float.st\0"
  "FloatD.st\0"
  "FloatE.st\0"
  "FloatQ.st\0"
  "Fraction.st\0"
  "LargeInt.st\0"
  "SmallInt.st\0"
  "Character.st\0"
  "UniChar.st\0"
  "LookupKey.st\0"
  "Association.st\0"
  "HomedAssoc.st\0"
  "VarBinding.st\0"
  "Link.st\0"
  "Process.st\0"
  "CallinProcess.st\0"
  "CompildCode.st\0"
  "CompildMeth.st\0"
  "CompiledBlk.st\0"
  "Collection.st\0"
  "SeqCollect.st\0"
  "LinkedList.st\0"
  "Semaphore.st\0"
  "ArrayColl.st\0"
  "Array.st\0"
  "ByteArray.st\0"
  "CharArray.st\0"
  "String.st\0"
  "Symbol.st\0"
  "UniString.st\0"
  "Interval.st\0"
  "OrderColl.st\0"
  "SortCollect.st\0"
  "Bag.st\0"
  "MappedColl.st\0"
  "HashedColl.st\0"
  "Set.st\0"
  "IdentitySet.st\0"
  "Dictionary.st\0"
  "LookupTable.st\0"
  "IdentDict.st\0"
  "MethodDict.st\0"
  "BindingDict.st\0"
  "AbstNamespc.st\0"
  "RootNamespc.st\0"
  "Namespace.st\0"
  "Stream.st\0"
  "PosStream.st\0"
  "ReadStream.st\0"
  "WriteStream.st\0"
  "RWStream.st\0"
  "ByteStream.st\0"
  "UndefObject.st\0"
  "ProcSched.st\0"
  "Delay.st\0"
  "SharedQueue.st\0"
  "Behavior.st\0"
  "ClassDesc.st\0"
  "Class.st\0"
  "Metaclass.st\0"
  "ContextPart.st\0"
  "MthContext.st\0"
  "BlkContext.st\0"
  "BlkClosure.st\0"
  "Continuation.st\0"
  "Memory.st\0"
  "MethodInfo.st\0"
  "FileSegment.st\0"
  "FileDescr.st\0"
  "SymLink.st\0"
  "Security.st\0"
  "WeakObjects.st\0"
  "ObjMemory.st\0"

  /* More core classes */
  "Random.st\0"
  "Transcript.st\0"
  "RecursionLock.st\0"
  "Point.st\0"
  "Rectangle.st\0"
  "RunArray.st\0"
  "AnsiDates.st\0"
  "ScaledDec.st\0"
  "ValueAdapt.st\0"
  "OtherArrays.st\0"

  /* C call-out facilities */
  "CObject.st\0"
  "CType.st\0"
  "CFuncs.st\0"
  "CStruct.st\0"

  /* Exception handling */
  "ExcHandling.st\0"
  "AnsiExcept.st\0"

  /* Virtual filesystem layer */
  "File.st\0"
  "Directory.st\0"
  "VFS.st\0"
  "URL.st\0"
  "FileStream.st\0"

  /* Goodies */
  "Autoload.st\0"
  "DLD.st\0"
  "Getopt.st\0"
  "Generator.st\0"
  "StreamOps.st\0"
  "ObjDumper.st\0"
  "PkgLoader.st\0"
  "Regex.st\0"
};

/* The argc and argv that are passed to libgst via gst_smalltalk_args. 
   The default is passing no parameters.  */
static const char *smalltalk_arg_vec[] = { "gst", NULL };
static int smalltalk_argc = 0;
static const char **smalltalk_argv = smalltalk_arg_vec;

/* The argc and argv that are made available to Smalltalk programs
   through the -a option.  */
int _gst_smalltalk_passed_argc = 0;
const char **_gst_smalltalk_passed_argv = NULL;



void
gst_smalltalk_args (int argc,
		    const char **argv)
{
  smalltalk_argc = argc;
  smalltalk_argv = argv;
}


int
gst_init_smalltalk (void)
{
  mst_Boolean loadBinary, abortOnFailure;
  mst_Boolean traceUserDeclarations, traceUserExecution;
  int result;

  /* Even though we're nowhere near through initialization, we set this
     to make sure we don't invoke a callin function which would recursively
     invoke us.  */
  _gst_smalltalk_initialized = true;

  _gst_init_snprintfv ();

  result = parse_args (smalltalk_argc, smalltalk_argv);
  if (result)
    return result;

  init_paths ();
  _gst_init_sysdep ();
  _gst_init_signals ();
  _gst_init_cfuncs ();
  _gst_init_primitives ();

  if (_gst_regression_testing)
    {
      _gst_declare_tracing = 0;
      _gst_execution_tracing = 0;
      _gst_verbosity = 2;
      setvbuf (stdout, NULL, _IOLBF, 1024);
    }

  traceUserDeclarations = _gst_declare_tracing;
  traceUserExecution = _gst_execution_tracing;
  if (_gst_declare_tracing == 1)
    _gst_declare_tracing--;
  if (_gst_execution_tracing == 1)
    _gst_execution_tracing--;

  if (_gst_binary_image_name)
    loadBinary = abortOnFailure = true;
  else
    {
      char *default_image_file_name;
      asprintf (&default_image_file_name, "%s/gst.im", _gst_image_file_path);

      _gst_binary_image_name = default_image_file_name;
      loadBinary = !ignore_image && ok_to_load_binary();
      abortOnFailure = false;

      /* If we must create a new non-local image, but the directory is
         not writeable, we must resort to the current directory.  In
         practice this is what happens when a "normal user" puts stuff in
	 his ".st" directory or does "gst -i".  */

      if (!loadBinary
          && !_gst_file_is_writeable (_gst_image_file_path))
        {
          _gst_image_file_path = _gst_get_cur_dir_name ();
          asprintf (&_gst_binary_image_name, "%s/gst.im", _gst_image_file_path);
          loadBinary = !ignore_image && ok_to_load_binary();
	  xfree (default_image_file_name);
        }
    }

  if (loadBinary && _gst_load_from_file (_gst_binary_image_name))
    {
      _gst_init_interpreter ();
      _gst_init_compiler ();
      _gst_init_vmproxy ();
    }
  else
    {
      mst_Boolean willRegressTest = _gst_regression_testing;
      _gst_regression_testing = false;

      if (abortOnFailure)
	{
	  _gst_errorf ("Couldn't load image file %s", _gst_binary_image_name);
	  return 1;
	}

      _gst_init_oop_table (NULL, INITIAL_OOP_TABLE_SIZE);
      _gst_init_mem_default ();
      _gst_init_dictionary ();
      _gst_init_interpreter ();
      _gst_init_compiler ();
      _gst_init_vmproxy ();

      _gst_install_initial_methods ();

      result = load_standard_files ();
      _gst_regression_testing = willRegressTest;
      if (result)
	return result;

      if (!_gst_save_to_file (_gst_binary_image_name))
	_gst_errorf ("Couldn't open file %s", _gst_binary_image_name);
    }

  _gst_kernel_initialized = true;
  _gst_invoke_hook ("returnFromSnapshot");
  if (user_init_file)
    process_file (user_init_file);

  _gst_declare_tracing = traceUserDeclarations;
  _gst_execution_tracing = traceUserExecution;

#ifdef HAVE_READLINE
  _gst_initialize_readline ();
#endif /* HAVE_READLINE */

  return 0;
}

void
gst_top_level_loop (void)
{
  struct loaded_file *file;
  for (file = loaded_files; file < &loaded_files[n_loaded_files]; file++)
    {
      char *f;
      if (file->kernel_path)
	{
	  f = find_kernel_file (file->file_name, "../", BASE_USER_DIR);
	  if (!f)
	    {
	      _gst_errorf ("Couldn't open kernel file %s", file->file_name);
	      continue;
	    }
	}
      else
	f = xstrdup (file->file_name);

      /* - by itself indicates standard input */
      if (!strcmp (f, "-"))
        process_stdin ();
      else
	{
	  if (!process_file (f))
	    _gst_errorf ("Couldn't open file %s", f);
	}

      xfree (f);
    }

  if (n_loaded_files == 0)
    process_stdin ();

  xfree (loaded_files);
  n_loaded_files = 0;
  if (snapshot_after_load)
    _gst_save_to_file (_gst_binary_image_name);

  _gst_invoke_hook ("aboutToQuit");
}



void
init_paths (void)
{
  char *currentDirectory = _gst_get_cur_dir_name ();

  const char *home = getenv ("HOME");

  /* By default, apply this kludge fpr OSes such as Windows and MS-DOS
     which have no concept of home directories.  */
  if (home == NULL)
    home = xstrdup (currentDirectory);

  asprintf ((char **) &_gst_user_file_base_path, "%s/%s", home, LOCAL_BASE_DIR_NAME);

  if (_gst_binary_image_name)
    {
      /* Compute the actual path of the image file */
      const char *p = _gst_binary_image_name + strlen (_gst_binary_image_name);
      for (;;)
	if (*--p == '/'
#if defined(MSDOS) || defined(WIN32) || defined(__OS2__)
	    || *p == '\\'
#endif
	   )
	  {
	    char *dirname;
	    int n = p > _gst_binary_image_name ? p - _gst_binary_image_name : 1;
	    dirname = xmalloc (n + 1);
	    strncpy (dirname, _gst_binary_image_name, n);
	    _gst_image_file_path = dirname;
	    break;
	  }

	else if (p == _gst_binary_image_name)
	  {
	    _gst_image_file_path = ".";
	    break;
	  }
    }

  /* These might go away in the next release.  */
  if (!_gst_kernel_file_path)
    {
      _gst_kernel_file_path = getenv ("SMALLTALK_KERNEL");
      if (_gst_kernel_file_path)
	_gst_warningf ("SMALLTALK_KERNEL variable deprecated, "
		       "use --kernel-directory instead");
      if (!_gst_file_is_readable (_gst_kernel_file_path))
	_gst_kernel_file_path = NULL;
    }

  if (!_gst_image_file_path)
    {
      _gst_image_file_path = getenv ("SMALLTALK_IMAGE");
      if (_gst_image_file_path)
	_gst_warningf ("SMALLTALK_IMAGE variable deprecated, "
		       "use --image-directory instead");
      if (!_gst_file_is_readable (_gst_image_file_path))
	_gst_image_file_path = NULL;
    }

  if (!_gst_image_file_path)
    {
      if (_gst_file_is_readable (IMAGE_PATH))
        _gst_image_file_path = IMAGE_PATH;
      else
        _gst_image_file_path = xstrdup (currentDirectory);
    }

  if (!_gst_kernel_file_path)
    {
      if (_gst_file_is_readable (KERNEL_PATH))
        _gst_kernel_file_path = KERNEL_PATH;
      else
	{
          char *kernel_file_path;
	  asprintf (&kernel_file_path, "%s/kernel", _gst_image_file_path);
	  _gst_kernel_file_path = kernel_file_path;
	}
    }

  _gst_image_file_path = _gst_get_full_file_name (_gst_image_file_path);
  _gst_kernel_file_path = _gst_get_full_file_name (_gst_kernel_file_path);

  xfree (currentDirectory);

  site_pre_image_file = find_kernel_file (SITE_PRE_IMAGE_FILE_NAME, "../",
					  NO_USER_DIR);

  user_pre_image_file = find_user_file (USER_PRE_IMAGE_FILE_NAME);

  if (!_gst_regression_testing)
    user_init_file = find_user_file (USER_INIT_FILE_NAME);
  else
    user_init_file = NULL;
}

mst_Boolean
ok_to_load_binary (void)
{
  time_t imageFileTime;
  const char *fileName;

  imageFileTime = _gst_get_file_modify_time (_gst_binary_image_name);

  if (imageFileTime == 0)	/* not found */
    return (false);

  for (fileName = standard_files; *fileName; fileName += strlen (fileName) + 1)
    {
      char *fullFileName = find_kernel_file (fileName, "", KERNEL_USER_DIR);
      mst_Boolean ok = (imageFileTime > _gst_get_file_modify_time (fullFileName));
      xfree (fullFileName);
      if (!ok)
        return (false);
    }

  if (site_pre_image_file
      && imageFileTime <= _gst_get_file_modify_time (site_pre_image_file))
    return (false);

  if (user_pre_image_file
      && imageFileTime <= _gst_get_file_modify_time (user_pre_image_file))
    return (false);

  return (true);
}

int
load_standard_files (void)
{
  const char *fileName;

  for (fileName = standard_files; *fileName; fileName += strlen (fileName) + 1)
    {
      char *fullFileName = find_kernel_file (fileName, "", KERNEL_USER_DIR);
      if (!fullFileName)
	{
	  _gst_errorf ("can't find system file '%s'", fileName);
	  _gst_errorf ("image bootstrap failed, use option --kernel-directory");
	  return 1;
	}
      else
	{
	  mst_Boolean ok = process_file (fullFileName);
	  xfree (fullFileName);
	  if (!ok)
	    return 1;
	}
    }

  if (site_pre_image_file)
    process_file (site_pre_image_file);

  if (user_pre_image_file)
    process_file (user_pre_image_file);

  return 0;
}


char *
find_kernel_file (const char *fileName, const char *systemPrefix,
		  enum user_dir userDir)
{
  char *fullFileName, *localFileName;

  asprintf (&fullFileName, "%s/%s%s", _gst_kernel_file_path, systemPrefix,
	    fileName);

  if (!no_user_files && userDir != NO_USER_DIR)
    {
      asprintf (&localFileName, "%s/%s%s",
		_gst_user_file_base_path,
		userDir == BASE_USER_DIR ? "" : LOCAL_KERNEL_DIR_NAME "/",
		fileName);

      if (_gst_file_is_readable (localFileName)
          /* If the system file is newer, use the system file instead.  */
          && (!_gst_file_is_readable (fullFileName) ||
	      _gst_get_file_modify_time (localFileName) >=
	      _gst_get_file_modify_time (fullFileName)))
	{
	  xfree (fullFileName);
	  return localFileName;
	}
      else
	xfree (localFileName);
    }

  if (_gst_file_is_readable (fullFileName))
    return fullFileName;

  xfree (fullFileName);
  return NULL;
}


char *
find_user_file (const char *fileName)
{
  char *fullFileName;
  if (no_user_files)
    return NULL;

  asprintf (&fullFileName, "%s/%s", _gst_user_file_base_path, fileName);
  if (!_gst_file_is_readable (fullFileName))
    {
      xfree (fullFileName);
      return NULL;
    }
  else
    return fullFileName;
}


void
process_stdin ()
{
  if (_gst_verbosity == 3 || isatty (0))
    {
      printf ("GNU Smalltalk ready\n\n");
      fflush (stdout);
    }

  _gst_non_interactive = false;
  _gst_push_stdin_string ();
  _gst_parse_stream (false);
  _gst_pop_stream (true);
  _gst_non_interactive = true;
}

mst_Boolean
process_file (const char *fileName)
{
  enum undeclared_strategy old;
  int fd;

  fd = _gst_open_file (fileName, "r");
  if (fd == -1)
    return (false);

  if (_gst_verbosity == 3)
    printf ("Processing %s\n", fileName);

  old = _gst_set_undeclared (UNDECLARED_GLOBALS);
  _gst_push_unix_file (fd, fileName);
  _gst_parse_stream (false);
  _gst_pop_stream (true);
  _gst_set_undeclared (old);
  return (true);
}


int
parse_args (int argc,
	    const char **argv)
{
  int ch, prev_optind = 1, minus_a_optind = -1;

#ifndef ENABLE_DYNAMIC_TRANSLATION
# define OPTIONS "-acDEf:ghiI:K:lL:QqrSvV"
#else
# define OPTIONS "-acDf:ghiI:K:lL:QqrSvV"
#endif

  loaded_files =
    (struct loaded_file *) xmalloc (sizeof (struct loaded_file) * argc);

  /* get rid of getopt's own error reporting for invalid options */
  opterr = 1;

  while ((ch =
	  getopt_long (argc, (char **) argv, OPTIONS, long_options, NULL)) != -1)
    {
#undef OPTIONS

#if DEBUG_GETOPT
      printf ("%c \"%s\"  %d  %d  %d\n", ch, optarg ? optarg : "",
	      optind, prev_optind, minus_a_optind);
#endif

      switch (ch)
	{
	case 'c':
	  _gst_make_core_file = true;
	  break;
	case 'D':
	  _gst_declare_tracing++;
	  break;
#ifndef ENABLE_JIT_TRANSLATION
	case 'E':
	  _gst_execution_tracing++;
	  break;
#endif
	case 'g':
	  _gst_gc_message = false;
	  break;
	case 'i':
	  ignore_image = true;
	  break;
	case OPT_EMACS_MODE:
	  _gst_emacs_process = true;
	  break;
	case 'q':
	case 'Q':
	  _gst_verbosity = 1;
	  break;
	case 'r':
	  _gst_regression_testing = true;
	  break;
	case 'S':
	  snapshot_after_load = true;
	  break;
	case 'V':
	  _gst_verbosity = 3;
	  break;

	case 'f':
	  /* Same as -q, passing a file, and -a.  */
	  _gst_verbosity = 1;
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
	  _gst_binary_image_name = optarg;
          if (!_gst_file_is_readable (_gst_binary_image_name))
	    {
	      _gst_errorf ("Couldn't open image file %s", _gst_binary_image_name);
	      return 1;
	    }
	  break;

	case 'K':
	  loaded_files[n_loaded_files].kernel_path = true;
	  loaded_files[n_loaded_files++].file_name = optarg;
	  break;

	case OPT_KERNEL_DIR:
	  _gst_kernel_file_path = optarg;
          if (!_gst_file_is_readable (_gst_kernel_file_path))
	    {
	      _gst_errorf ("kernel path %s not readable", _gst_kernel_file_path);
	      return 1;
	    }
	  break;

	case OPT_IMAGE_DIR:
	  _gst_image_file_path = optarg;
          if (!_gst_file_is_readable (_gst_image_file_path))
	    {
	      _gst_errorf ("image path %s not readable", _gst_image_file_path);
	      return 1;
	    }
	  break;

	case OPT_NO_USER:
	  no_user_files = true;
	  break;

	case 'v':
	  printf (copyright_and_legal_stuff_text, VERSION, KERNEL_PATH,
		  IMAGE_PATH);
	  return -1;

	case '\1':
	  loaded_files[n_loaded_files].kernel_path = false;
	  loaded_files[n_loaded_files++].file_name = optarg;
	  break;

	default:
	  /* Fall through and show help message */

	case 'h':
	  printf (help_text);
	  return ch == 'h' ? -1 : 1;
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
	  _gst_smalltalk_passed_argc = argc - optind;
	  _gst_smalltalk_passed_argv =
	    xmalloc (sizeof (char *) * _gst_smalltalk_passed_argc);
	  memcpy (_gst_smalltalk_passed_argv, argv + optind,
		  sizeof (char *) * _gst_smalltalk_passed_argc);
	  break;
	}

      prev_optind = optind;
    }

  return 0;
}
