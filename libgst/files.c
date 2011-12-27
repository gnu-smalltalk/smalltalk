/******************************** -*- C -*- ****************************
 *
 *	Public library entry points
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006,2007,2008,2009
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
const char *_gst_user_file_base_path = NULL;

/* Whether to look for user files.  */
static mst_Boolean no_user_files = false;

/* This is the name of the binary image to load.  If it is not NULL after the
   command line is parsed, the checking of the dates of the kernel source files
   against the image file date is overridden.  If it is NULL, it is set to
   default_image_name.  */
const char *_gst_binary_image_name = NULL;

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

/* Loads the kernel Smalltalk files.  It uses a vector of file names,
   and loads each file individually.  To provide for greater
   flexibility, if a one of the files exists in the current directory,
   that is used in preference to one in the default location.  The
   default location can be overridden at runtime by setting the
   SMALLTALK_KERNEL environment variable.  */
static int load_standard_files (void);

/* Path names for the per-user customization files, respectively
   init.st (loaded at every startup) and pre.st (loaded before a local
   image is saved.  */
static const char *user_init_file = NULL;
static const char *user_pre_image_file = NULL;
static const char *site_pre_image_file = NULL;

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
  "MessageLookup.st\0"
  "DirMessage.st\0"
  "Boolean.st\0"
  "False.st\0"
  "True.st\0"
  "Magnitude.st\0"
  "LookupKey.st\0"
  "DeferBinding.st\0"
  "Association.st\0"
  "HomedAssoc.st\0"
  "VarBinding.st\0"
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
  "Link.st\0"
  "Process.st\0"
  "CallinProcess.st\0"
  "Iterable.st\0"
  "Collection.st\0"
  "SeqCollect.st\0"
  "LinkedList.st\0"
  "Semaphore.st\0"
  "ArrayColl.st\0"
  "CompildCode.st\0"
  "CompildMeth.st\0"
  "CompiledBlk.st\0"
  "Array.st\0"
  "ByteArray.st\0"
  "CharArray.st\0"
  "String.st\0"
  "Symbol.st\0"
  "UniString.st\0"
  "Interval.st\0"
  "OrderColl.st\0"
  "SortCollect.st\0"
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
  "UndefObject.st\0"
  "ProcSched.st\0"
  "ContextPart.st\0"
  "MthContext.st\0"
  "BlkContext.st\0"
  "BlkClosure.st\0"
  "Behavior.st\0"
  "ClassDesc.st\0"
  "Class.st\0"
  "Metaclass.st\0"
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
  "Bag.st\0"
  "MappedColl.st\0"
  "Delay.st\0"
  "SharedQueue.st\0"
  "Random.st\0"
  "RecursionLock.st\0"
  "Transcript.st\0"
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
  "CCallable.st\0"
  "CFuncs.st\0"
  "CCallback.st\0"
  "CStruct.st\0"

  /* Exception handling and ProcessEnvironment */
  "ProcEnv.st\0"
  "ExcHandling.st\0"
  "SysExcept.st\0"

  /* Virtual filesystem layer */
  "FilePath.st\0"
  "File.st\0"
  "Directory.st\0"
  "VFS.st\0"
  "VFSZip.st\0"
  "URL.st\0"
  "FileStream.st\0"

  /* Goodies */
  "DynVariable.st\0"
  "DLD.st\0"
  "Getopt.st\0"
  "Generator.st\0"
  "StreamOps.st\0"
  "Regex.st\0"
  "PkgLoader.st\0"
  "Autoload.st\0"
};

/* The argc and argv that are passed to libgst via gst_smalltalk_args. 
   The default is passing no parameters.  */
static int smalltalk_argc = 0;
static const char **smalltalk_argv = NULL;

/* The argc and argv that are made available to Smalltalk programs
   through the -a option.  */
int _gst_smalltalk_passed_argc = 0;
const char **_gst_smalltalk_passed_argv = NULL;



void
_gst_smalltalk_args (int argc,
		     const char **argv)
{
  smalltalk_argc = argc;
  smalltalk_argv = argv;
}

   
int
_gst_initialize (const char *kernel_dir,
		 const char *image_file,
		 int flags)
{
  char *currentDirectory = _gst_get_cur_dir_name ();
  const char *home = getenv ("HOME");
  char *str;
  mst_Boolean loadBinary, abortOnFailure;
  int rebuild_image_flags =
    flags & (GST_REBUILD_IMAGE | GST_MAYBE_REBUILD_IMAGE);

  /* Even though we're nowhere near through initialization, we set this
     to make sure we don't invoke a callin function which would recursively
     invoke us.  */
  _gst_smalltalk_initialized = true;
  _gst_init_snprintfv ();

  if (!_gst_executable_path)
    _gst_executable_path = DEFAULT_EXECUTABLE;

  /* By default, apply this kludge fpr OSes such as Windows and MS-DOS
     which have no concept of home directories.  */
  if (home == NULL)
    home = xstrdup (currentDirectory);

  asprintf ((char **) &_gst_user_file_base_path, "%s/%s",
	    home, LOCAL_BASE_DIR_NAME);

  /* Check that supplied paths are readable.  If they're not, fail unless
     they told us in advance.  */
  if (kernel_dir
      && !_gst_file_is_readable (kernel_dir))
    {
      if (flags & GST_IGNORE_BAD_KERNEL_PATH)
	kernel_dir = NULL;
      else
	{
          _gst_errorf ("kernel path %s not readable", kernel_dir);
          exit (1);
	}
    }

  /* For the image file, it is okay to find none if we can/should rebuild
     the image file.  */
  if (image_file
      && (flags & (GST_REBUILD_IMAGE | GST_MAYBE_REBUILD_IMAGE)) == 0
      && !_gst_file_is_readable (image_file))
    {
      if (flags & GST_IGNORE_BAD_IMAGE_PATH)
	image_file = NULL;
      else
	{
	  _gst_errorf ("Couldn't open image file %s", image_file);
	  exit (1);
	}
    }

  /* The image path can be used as the default kernel path, so we split
     it anyway into directory+filename.  */
  if (image_file)
    {
      const char *p;
      /* Compute the actual path of the image file */
      p = image_file + strlen (image_file);
      for (;;)
	if (*--p == '/'
#if defined(MSDOS) || defined(WIN32) || defined(__OS2__)
	    || *p == '\\'
#endif
	   )
	  {
	    char *dirname;
	    int n = p > image_file ? p - image_file : 1;
	    asprintf (&dirname, "%.*s", n, image_file);
	    _gst_image_file_path = dirname;

	    /* Remove path from image_file.  */
	    image_file = p + 1;
	    break;
	  }

	else if (p == image_file)
	  {
	    _gst_image_file_path = ".";
	    break;
	  }
    }
  else
    {
      /* No image file given, we use the system default or revert to the
	 current directory.  */
      str = _gst_relocate_path (IMAGE_PATH);
      if (_gst_file_is_readable (str))
        _gst_image_file_path = str;
      else
	{
          free (str);
          _gst_image_file_path = xstrdup (currentDirectory);
	}

      flags |= GST_IGNORE_BAD_IMAGE_PATH;
      image_file = "gst.im";
    }

  if (!kernel_dir)
    {
      str = _gst_relocate_path (KERNEL_PATH);
      if (!_gst_file_is_readable (str))
	{
          free (str);
	  asprintf (&str, "%s/kernel", _gst_image_file_path);
	}

      kernel_dir = str;
    }

  xfree (currentDirectory);

  /* Uff, we're done with the complicated part.  Set variables to mirror
     what we've decided in the above marathon.  */
  _gst_image_file_path = _gst_get_full_file_name (_gst_image_file_path);
  _gst_kernel_file_path = _gst_get_full_file_name (kernel_dir);
  asprintf (&str, "%s/%s", _gst_image_file_path, image_file);
  _gst_binary_image_name = str;

  _gst_smalltalk_passed_argc = smalltalk_argc;
  _gst_smalltalk_passed_argv = smalltalk_argv;
  no_user_files = (flags & GST_IGNORE_USER_FILES) != 0;
  _gst_no_tty = (flags & GST_NO_TTY) != 0 || !isatty (0);

  site_pre_image_file = _gst_find_file (SITE_PRE_IMAGE_FILE_NAME,
					GST_DIR_KERNEL_SYSTEM);

  user_pre_image_file = find_user_file (USER_PRE_IMAGE_FILE_NAME);

  if (!_gst_regression_testing)
    user_init_file = find_user_file (USER_INIT_FILE_NAME);
  else
    user_init_file = NULL;

  _gst_init_sysdep ();
  _gst_init_signals ();
  _gst_init_event_loop();
  _gst_init_cfuncs ();
  _gst_init_sockets ();
  _gst_init_primitives ();

  if (_gst_regression_testing)
    {
      _gst_declare_tracing = 0;
      _gst_execution_tracing = 0;
      _gst_verbosity = 2;
      setvbuf (stdout, NULL, _IOLBF, 1024);
    }

  if (rebuild_image_flags == 0)
    loadBinary = abortOnFailure = true;
  else
    {
      loadBinary = (rebuild_image_flags == GST_MAYBE_REBUILD_IMAGE
		    && ok_to_load_binary ());
      abortOnFailure = false;

      /* If we must create a new non-local image, but the directory is
         not writeable, we must resort to the current directory.  In
         practice this is what happens when a "normal user" puts stuff in
	 his ".st" directory or does "gst -i".  */

      if (!loadBinary
          && !_gst_file_is_writeable (_gst_image_file_path)
	  && (flags & GST_IGNORE_BAD_IMAGE_PATH))
        {
          _gst_image_file_path = _gst_get_cur_dir_name ();
          asprintf (&str, "%s/gst.im", _gst_image_file_path);
	  _gst_binary_image_name = str;
          loadBinary = (rebuild_image_flags == GST_MAYBE_REBUILD_IMAGE
		        && ok_to_load_binary ());
        }
    }

  if (loadBinary && _gst_load_from_file (_gst_binary_image_name))
    {
      _gst_init_interpreter ();
      _gst_init_vmproxy ();
    }
  else if (abortOnFailure)
    {
      _gst_errorf ("Couldn't load image file %s", _gst_binary_image_name);
      return 1;
    }
  else
    {
      mst_Boolean willRegressTest = _gst_regression_testing;
      int result;

      _gst_regression_testing = false;
      _gst_init_oop_table (NULL, INITIAL_OOP_TABLE_SIZE);
      _gst_init_mem_default ();
      _gst_init_dictionary ();
      _gst_init_interpreter ();
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
  _gst_invoke_hook (GST_RETURN_FROM_SNAPSHOT);
  if (user_init_file)
    _gst_process_file (user_init_file, GST_DIR_ABS);

#ifdef HAVE_READLINE
  _gst_initialize_readline ();
#endif /* HAVE_READLINE */

  return 0;
}


mst_Boolean
ok_to_load_binary (void)
{
  const char *fileName;

  if (!_gst_file_is_readable (_gst_binary_image_name))
    return (false);

  for (fileName = standard_files; *fileName; fileName += strlen (fileName) + 1)
    {
      char *fullFileName = _gst_find_file (fileName, GST_DIR_KERNEL);
      mst_Boolean ok = _gst_file_is_newer (_gst_binary_image_name,
					   fullFileName);
      xfree (fullFileName);
      if (!ok)
        return (false);
    }

  if (site_pre_image_file
      && !_gst_file_is_newer (_gst_binary_image_name, site_pre_image_file))
    return (false);

  if (user_pre_image_file
      && !_gst_file_is_newer (_gst_binary_image_name, user_pre_image_file))
    return (false);

  return (true);
}

int
load_standard_files (void)
{
  const char *fileName;

  for (fileName = standard_files; *fileName; fileName += strlen (fileName) + 1)
    {
      if (!_gst_process_file (fileName, GST_DIR_KERNEL))
	{
	  _gst_errorf ("couldn't load system file '%s': %s", fileName,
		       strerror (errno));
	  _gst_errorf ("image bootstrap failed, use option --kernel-directory");
	  return 1;
	}
    }

  _gst_msg_sendf (NULL, "%v %o relocate", _gst_file_segment_class);

  if (site_pre_image_file)
    _gst_process_file (site_pre_image_file, GST_DIR_ABS);

  if (user_pre_image_file)
    _gst_process_file (user_pre_image_file, GST_DIR_ABS);

  return 0;
}


char *
_gst_find_file (const char *fileName,
		enum gst_file_dir dir)
{
  char *fullFileName, *localFileName;

  if (dir == GST_DIR_ABS)
    return xstrdup (fileName);

  asprintf (&fullFileName, "%s/%s%s", _gst_kernel_file_path,
	    dir == GST_DIR_KERNEL ? "" : "../",
	    fileName);

  if (!no_user_files && dir != GST_DIR_KERNEL_SYSTEM)
    {
      asprintf (&localFileName, "%s/%s%s",
		_gst_user_file_base_path,
		dir == GST_DIR_BASE ? "" : LOCAL_KERNEL_DIR_NAME "/",
		fileName);

      if (_gst_file_is_newer (localFileName, fullFileName))
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
