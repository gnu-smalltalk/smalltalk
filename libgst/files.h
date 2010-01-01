/******************************** -*- C -*- ****************************
 *
 *	Public interface for main module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2008,2009
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


#ifndef GST_LIB_H
#define GST_LIB_H

/* These contain the default path that was picked (after looking at the
   environment variables) for the kernel files and the image.  */
extern const char *_gst_kernel_file_path 
  ATTRIBUTE_HIDDEN;
extern const char *_gst_image_file_path 
  ATTRIBUTE_HIDDEN;

/* The ".st" directory, in the current directory or in the user's
   home directory.  */
extern const char *_gst_user_file_base_path;

/* This is the name of the binary image to load.  If it is not NULL after the
   command line is parsed, the checking of the dates of the kernel source files
   against the image file date is overridden.  If it is NULL, it is set to
   default_image_name.  */
extern const char *_gst_binary_image_name 
  ATTRIBUTE_HIDDEN;

/* This is TRUE if we are doing regression testing, and causes
   whatever sources of variance to be suppressed (such as printing out
   execution statistics).  */
extern mst_Boolean _gst_regression_testing 
  ATTRIBUTE_HIDDEN;

/* The standard value of this flag is 2.  The four possible values (0 to 3)
   correspond respectively to -Q, -q, nothing, and -V.  
   When set to 3, this flag enables the printing of execution statistics.
   When set to 1 or lower, this flag suppresses the printing of
   execution-related messages, such as the result of do-its.
   When set to 0, Smalltalk does not print any sort of version banner
   at the startup of the interpreter.  This makes Smalltalk usable as
   a filter, or as a pure producer of content (such as the main program
   in a cgi-bin script).  */
extern int _gst_verbosity 
  ATTRIBUTE_HIDDEN;

/* The argc and argv that are made available to Smalltalk programs
   through the -a option.  */
extern int _gst_smalltalk_passed_argc 
  ATTRIBUTE_HIDDEN;
extern const char **_gst_smalltalk_passed_argv 
  ATTRIBUTE_HIDDEN;

/* This is used to avoid doing complicated things (currently, this
   includes call-ins before and after _gst_execute_statements) before
   the system is ready to do them.  */
extern mst_Boolean _gst_kernel_initialized 
  ATTRIBUTE_HIDDEN;

/* Set by cmd line flag.  If true, Smalltalk is more verbose about
   what it's doing.  */
extern mst_Boolean _gst_verbose 
  ATTRIBUTE_HIDDEN;

/* This is true if the image initialization has already been
   started.  */
extern mst_Boolean _gst_smalltalk_initialized
  ATTRIBUTE_HIDDEN;

/* This sets the arguments to be passed to the Smalltalk library,
   which are the same that are available by the `gst' executable.  */
extern void _gst_smalltalk_args (int argc,
				 const char **argv)
  ATTRIBUTE_HIDDEN;

/* Set the fundamental paths for the Smalltalk VM and initialize
   it.  */
extern int _gst_initialize (const char *kernel_dir,
			    const char *image_file,
			    int flags)
  ATTRIBUTE_HIDDEN;

/* This processes files passed to gst_smalltalk_args and, if none
   was passed, stdin is looked for input.  */
extern void _gst_top_level_loop (void)
  ATTRIBUTE_HIDDEN;

/* Attempts to find a viable kernel Smalltalk file (.st file).
   FILENAME is a simple file name, sans directory; the file name to use 
   for the particular kernel file is returned.
   If there is a file in the .stkernel directory with name FILENAME, that is
   returned; otherwise the kernel path is prepended to FILENAME (separated
   by a slash, of course) and that is stored in the string that is returned.  */
extern char *_gst_find_file (const char *fileName,
			     enum gst_file_dir dir)
  ATTRIBUTE_HIDDEN;

#endif /* GST_LIB_H */
