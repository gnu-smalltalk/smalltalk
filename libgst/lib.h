/******************************** -*- C -*- ****************************
 *
 *	Public interface for main module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
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
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/


#ifndef GST_LIB_H
#define GST_LIB_H

/* These contain the default path that was picked (after looking at the
   environment variables) for the kernel files and the image. */
extern char *_gst_kernel_file_default_path;
extern char *_gst_image_file_default_path;

/* This is the name of the binary image to load.  If it is not NULL after the
   command line is parsed, the checking of the dates of the kernel source files
   against the image file date is overridden.  If it is NULL, it is set to
   default_image_name. */
extern char *_gst_binary_image_name;

/* This is used by the callin functions to auto-initialize Smalltalk.
   When it's not true, initialization needs to be performed.  It's set
   to true by gst_init_smalltalk(). */
extern mst_Boolean _gst_smalltalk_initialized;

/* This is TRUE if we are doing regression testing, and causes
   whatever sources of variance to be suppressed (such as printing out
   execution statistics).  */
extern mst_Boolean _gst_regression_testing;

/* When true, this flag suppresses the printing of execution-related
   messages, such as the number of byte codes executed by the
   last expression, etc. */
extern mst_Boolean _gst_quiet_execution;

/* The argc and argv that are made available to Smalltalk programs
   through the -a option. */
extern int _gst_smalltalk_passed_argc;
extern char **_gst_smalltalk_passed_argv;

/* This is used to avoid doing complicated things (currently, this
   includes call-ins before and after _gst_execute_statements) before
   the system is ready to do them. */
extern mst_Boolean _gst_kernel_initialized;

/* If true, even both kernel and user method definitions are shown as
   they are compiled.  */
extern mst_Boolean _gst_trace_kernel_declarations;

/* If true, execution tracing is performed when loading kernel method
   definitions. */
extern mst_Boolean _gst_trace_kernel_execution;

/* Set by cmd line flag.  If true, Smalltalk is more verbose about
   what it's doing. */
extern mst_Boolean _gst_verbose;

#endif /* GST_LIB_H */
