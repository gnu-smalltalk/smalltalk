/******************************** -*- C -*- ****************************
 *
 *	System specific module declarations
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2007,2008,2009
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


#ifndef GST_SYSDEP_H
#define GST_SYSDEP_H

#ifdef sgi
# define _BSD_SIGNALS
#endif

#ifndef SEEK_SET
#define SEEK_SET                0
#define SEEK_CUR                1
#define SEEK_END                2
#endif

#ifndef HAVE_SYS_MMAN_H
#define PROT_READ       0x1             /* Page can be read.  */
#define PROT_WRITE      0x2             /* Page can be written.  */
#define PROT_EXEC       0x4             /* Page can be executed.  */
#define PROT_NONE       0x0             /* Page can not be accessed.  */
#endif

/* These nice tests are simple, guaranteed and independent of byte order.  */
#define IS_FINITE(dbl)		(!IS_NAN((dbl) * 0.0))
#define IS_NAN(dbl)		 ((dbl) != (dbl))

typedef RETSIGTYPE (*SigHandler) ();

/* The path to the executable.  */
extern const char *_gst_executable_path;

/* The count of nested _gst_disable_interrupts calls.  */
extern int _gst_signal_count;

/* Saves and returns the current state of the software interrupt
   system.  Disables all interrupts.  */
extern void _gst_disable_interrupts (mst_Boolean fromSignalHandler)
  ATTRIBUTE_HIDDEN;

/* Restores the state of the interrupt system to that which it had when
   _gst_disable_interrupts was last invoked.  */
extern void _gst_enable_interrupts (mst_Boolean fromSignalHandler)
  ATTRIBUTE_HIDDEN;

/* Set the signal handler for signal SIGNUM to be HANDLERFUNC.  Further
   interrupts are blocked within the signal if supported.  (The signal
   handler should still call _gst_disable_interrupts and
   _gst_enable_interrupts passing true to fromSignalHandler).  */
extern SigHandler _gst_set_signal_handler (int signum,
					   SigHandler handlerFunc)
  ATTRIBUTE_HIDDEN;

/* Establish FUNC to be called when DELTAMILLI milliseconds of
   process time have passed.  */
extern void _gst_sigvtalrm_every (int deltaMilli,
			       SigHandler func)
  ATTRIBUTE_HIDDEN;

/* Establish SIGALRM to be called when the nanosecond clock reaches NSTIME
   nanoseconds.  */
extern void _gst_sigalrm_at (int64_t nsTime)
  ATTRIBUTE_HIDDEN;

/* Initialize system dependent stuff.  */
extern void _gst_init_sysdep (void)
  ATTRIBUTE_HIDDEN;
extern void _gst_init_sysdep_timer (void)
  ATTRIBUTE_HIDDEN;

/* Arrange so that FUNC is called when I/O becomes possible on
   registered file descriptors, and set up FD to trigger the
   signal.  */
extern void _gst_set_file_interrupt (int fd,
				     SigHandler func)
  ATTRIBUTE_HIDDEN;

/* Used for debugging.  You set a breakpoint in the _gst_debug routine
   in the debugger, and have code call it when you want it to stop.
   Performs no action normally.  */
extern void _gst_debug (void)
  ATTRIBUTE_HIDDEN;

/* Sleeps for US milliseconds.  */
extern void _gst_usleep (int us)
  ATTRIBUTE_HIDDEN;

/* Returns a (hopefully) monotonic time value in milliseconds */
extern uint64_t _gst_get_milli_time (void)
  ATTRIBUTE_HIDDEN;

/* Returns a (hopefully) monotonic time value in nanoseconds */
extern uint64_t _gst_get_ns_time (void)
  ATTRIBUTE_HIDDEN;

/* Returns the time in seconds since midnight Jan 1, 1970 (standard UNIX
   type time).  */
extern time_t _gst_get_time (void)
  ATTRIBUTE_HIDDEN;

/* Returns whether FILE1 is newer (or last modified at the same time as)
   FILE2.  Returns true if FILE2 is not readable, false if FILE1 is not
   readable.  */
extern mst_Boolean _gst_file_is_newer (const char *file1, const char *file2)
  ATTRIBUTE_HIDDEN;

/* Sets the time when FILENAME was last modified.  The times are in
   seconds, relative to 1 Jan 2000.  */
extern int _gst_set_file_access_times (const char *name, long new_atime,
				       long new_mtime)
  ATTRIBUTE_HIDDEN;

/* Converts the given time (expressed in seconds since midnight Jan 1,
   1970, and in Universal Coordinated Time) into a local time.  */
extern time_t _gst_adjust_time_zone (time_t t)
  ATTRIBUTE_HIDDEN;

/* Answer the current bias in seconds between UTC and local time */
extern long _gst_current_time_zone_bias (void)
  ATTRIBUTE_HIDDEN;

/* Returns the full path name for a given file.  */
extern char *_gst_get_full_file_name (const char *fileName)
  ATTRIBUTE_HIDDEN;

/* Returns the path name for the current directory, without trailing
   delimiter.  The return value is a pointer to allocated string for
   current path name.  Caller has responsibility for freeing the
   returned value when through.  */
extern char *_gst_get_cur_dir_name (void)
  ATTRIBUTE_HIDDEN;

/* Returns the name of the current time zone.  */
extern char *_gst_current_time_zone_name (void)
  ATTRIBUTE_HIDDEN;

/* Portable implementation of mprotect.  The implementation does not
   necessarily support PROT_EXEC or PROT_WRITE without PROT_READ.  The
   only guarantees are that no writing will be allowed without
   PROT_WRITE and no access will be allowed for PROT_NONE.  */
extern int _gst_mem_protect (PTR addr,
			     size_t len,
			     int prot)
  ATTRIBUTE_HIDDEN;

/* Returns true if the file named FILENAME exists has the given
   permission for the current user.  Returns false otherwise.  */
extern mst_Boolean _gst_file_is_readable (const char *fileName)
  ATTRIBUTE_HIDDEN;
extern mst_Boolean _gst_file_is_writeable (const char *fileName)
  ATTRIBUTE_HIDDEN;
extern mst_Boolean _gst_file_is_executable (const char *fileName)
  ATTRIBUTE_HIDDEN;

/* Return a path to the executable given argv[0].  */
extern void _gst_set_executable_path (const char *argv0)
  ATTRIBUTE_HIDDEN;

/* Return the absolute path for PATH, interpreted relative to the
   executable.  */
char *_gst_relocate_path (const char *path)
  ATTRIBUTE_HIDDEN;

/* Answer true if the file descriptor FD is associated to a pipe
   (it cannot be seeked through).  */
extern mst_Boolean _gst_is_pipe (int fd)
  ATTRIBUTE_HIDDEN;

/* Similar to popen, but supports two-way pipes (achieved through
   tty's) and returns a file descriptor.  */
extern int _gst_open_pipe (const char *command,
			   const char *mode)
  ATTRIBUTE_HIDDEN;

/* Similar to fopen, but returns a file descriptor.  */
extern int _gst_open_file (const char *filename,
			   const char *mode)
  ATTRIBUTE_HIDDEN;

/* Read SIZE bytes into BUFFER from the file descriptor, FD.  */
extern ssize_t _gst_read (int fd,
		          PTR buffer,
		          size_t size)
  ATTRIBUTE_HIDDEN;

/* Write SIZE bytes of BUFFER into the file descriptor, FD.  */
extern ssize_t _gst_write (int fd,
		           PTR buffer,
		           size_t size)
  ATTRIBUTE_HIDDEN;

/* Read SIZE bytes into BUFFER from the file descriptor for a socket, FD.  */
extern ssize_t _gst_recv (int fd,
		          PTR buffer,
		          size_t size,
		          int flags)
  ATTRIBUTE_HIDDEN;

/* Write SIZE bytes of BUFFER into the file descriptor for a socket, FD.  */
extern ssize_t _gst_send (int fd,
		          PTR buffer,
		          size_t size,
		          int flags)
  ATTRIBUTE_HIDDEN;

/* Writes a debug message with the given formatting.  */
extern void _gst_debugf (const char *, ...)
  ATTRIBUTE_PRINTF_1
  ATTRIBUTE_HIDDEN;

/* Do an anonymous memory map of SIZE bytes.  */
extern PTR _gst_osmem_alloc (size_t size)
  ATTRIBUTE_HIDDEN;

/* Unmap the SIZE bytes at PTR.  */
extern void _gst_osmem_free (PTR ptr, size_t size)
  ATTRIBUTE_HIDDEN;

/* Reserve SIZE bytes of the address space without allocating them.  */
extern PTR _gst_osmem_reserve (PTR base,
			       size_t size)
  ATTRIBUTE_HIDDEN;

/* Release SIZE bytes of the address space starting from BASE.  */
extern void _gst_osmem_release (PTR base,
				size_t size)
  ATTRIBUTE_HIDDEN;

/* Actually allocate SIZE bytes of address space, starting from BASE,
   that have already been reserved.  */
extern PTR _gst_osmem_commit (PTR base,
			      size_t size)
  ATTRIBUTE_HIDDEN;

/* Free the memory used by SIZE bytes of address space, starting from BASE,
   but keep the addresses reserved.  */
extern void _gst_osmem_decommit (PTR base,
				 size_t size)
  ATTRIBUTE_HIDDEN;

/* Synchronously wait for FD to have input on it.  */
extern void _gst_wait_for_input (int fd)
  ATTRIBUTE_HIDDEN;

#endif /* GST_SYSDEP_H */
