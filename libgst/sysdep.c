/******************************** -*- C -*- ****************************
 *
 * System specific implementation module.
 *
 * This module contains implementations of various operating system
 * specific routines.  This module should encapsulate most (or all)
 * of these calls so that the rest of the code is portable.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006,2007
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#include "gstpriv.h"

#ifdef HAVE_UTIME_H
# include <utime.h>
#endif

#ifdef HAVE_SYS_TIMES_H
# include <sys/times.h>
#endif

#ifdef HAVE_SYS_IOCTL_H
# include <sys/ioctl.h>
#endif

#ifdef HAVE_TERMIOS_H
# include <termios.h>
#endif

#ifdef HAVE_STROPTS_H
#include <stropts.h>
#endif

#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif

#ifdef HAVE_SYS_TIMEB_H
#include <sys/timeb.h>
#endif

#ifdef WIN32
# define WIN32_LEAN_AND_MEAN /* avoid including junk */
# include <windows.h>
#endif

/* Get declaration of _NSGetExecutablePath on MacOS X 10.2 or newer.  */
#if HAVE_MACH_O_DYLD_H
# define ENUM_DYLD_BOOL
# include <mach-o/dyld.h>
#endif

#if defined MAP_ANONYMOUS && !defined MAP_ANON
# define MAP_ANON MAP_ANONYMOUS
#endif

#ifndef MAP_FAILED
# define MAP_FAILED ((char *) -1)
#endif

#ifndef F_OK
#define F_OK 0
#define X_OK 1
#define W_OK 2
#define R_OK 4
#endif

#ifndef O_BINARY
#define O_BINARY     0
#endif

#ifdef HAVE_SPAWNL
#include <process.h>
#ifndef P_WAIT
#define P_WAIT       0
#define P_NOWAIT     1
#define P_OVERLAY    2
#define P_NOWAITO    3
#define P_DETACH     4
#endif /* !P_WAIT */
#endif /* HAVE_SPAWNL */

#if defined FASYNC && !defined O_ASYNC
#define O_ASYNC FASYNC
#endif

#ifndef PATH_MAX
#define PATH_MAX  1024		/* max length of a file and path */
#endif

#ifndef MAXSYMLINKS
#define MAXSYMLINKS 5
#endif

/* Yield A - B, measured in seconds.
   This function is copied from the GNU C Library.  */
static int tm_diff (struct tm *a,
		    struct tm *b);

static void do_interrupts (mst_Boolean disable);

#define DISABLED_MASK ((-1) ^ (1 << SIGSEGV) ^ (1 << SIGBUS) ^ \
			      (1 << SIGILL) ^ (1 << SIGABRT))


#if defined SIG_BLOCK
static sigset_t oldSet;

#define DECLARE

#define DISABLE do { \
  sigset_t newSet; \
  sigfillset (&newSet); \
  sigdelset (&newSet, SIGSEGV); \
  sigdelset (&newSet, SIGBUS); \
  sigdelset (&newSet, SIGILL); \
  sigdelset (&newSet, SIGQUIT); \
  sigdelset (&newSet, SIGABRT); \
  sigprocmask (SIG_BLOCK, &newSet, &oldSet); \
} while (0)
  
#define ENABLE \
  sigprocmask (SIG_SETMASK, &oldSet, NULL)

#elif defined HAVE_SIGSETMASK     /* BSD */
static int signalMask;

#define DECLARE
#define DISABLE signalMask = sigsetmask (DISABLED_MASK)
#define ENABLE sigsetmask (signalMask)

#elif defined HAVE_SIGHOLD 	/* SVID style */
#define DECLARE int i
#define DISABLE \
  do { \
    for (i = 0; i < 8 * sizeof (long); i++) \
      if (DISABLED_MASK & (1 << i)) \
        sighold (i); \
  } while(0)

#define ENABLE \
  do { \
    for (i = 0; i < 8 * sizeof (long); i++) \
      if (DISABLED_MASK & (1 << i)) \
        sigrelse (i);
  } while(0)

#else
static long pending_sigs = 0;
static SigHandler saved_handlers[8 * sizeof (long)];
static RETSIGTYPE dummy_signal_handler (int sig)
{
  pending_sigs |= 1L << sig;
  signal (sig, SIG_IGN);
}

#define DECLARE \
  int i; \
  long local_pending_sigs

#define DISABLE \
  do { \
    for (i = 0; i < 8 * sizeof (long); i++) \
      if (DISABLED_MASK & (1 << i)) \
        saved_handlers[i] = signal (i, dummy_signal_handler); \
  } while (0)

#define ENABLE \
  do \
    { \
      for (i = 0; i < 8 * sizeof (long); i++) \
        if (DISABLED_MASK & (1 << i)) \
          signal (i, saved_handlers[i]); \
      local_pending_sigs = pending_sigs; \
      pending_sigs = 0; \
      for (i = 0; local_pending_sigs; local_pending_sigs >>= 1, i++) \
        if (local_pending_sigs & 1) \
          raise (i); \
    } \
  while (0)
#endif

int _gst_signal_count;

void
_gst_disable_interrupts (mst_Boolean from_signal_handler)
{
  DECLARE;
  
  __sync_synchronize ();
  if (_gst_signal_count++ == 0)
    {
      __sync_synchronize ();
#ifdef _POSIX_VERSION
      if (from_signal_handler)
        return;
#endif
      DISABLE;
    }
}

void
_gst_enable_interrupts (mst_Boolean from_signal_handler)
{
  DECLARE;

  __sync_synchronize ();
  if (--_gst_signal_count == 0)
    {
      __sync_synchronize ();
#ifdef _POSIX_VERSION
      if (from_signal_handler)
        return;
#endif
      ENABLE;
    }
}

#undef DECLARE
#undef DISABLE
#undef ENABLE

SigHandler
_gst_set_signal_handler (int signum,
			 SigHandler handlerFunc)
{
#ifdef _POSIX_VERSION
  /* If we are running on a POSIX-compliant system, then do things the
     POSIX way.  */
  struct sigaction act, o_act;

  act.sa_handler = handlerFunc;
  act.sa_flags = 0;

  sigfillset (&act.sa_mask);
  sigdelset (&act.sa_mask, SIGSEGV);
  sigdelset (&act.sa_mask, SIGBUS);
  sigdelset (&act.sa_mask, SIGILL);
  sigdelset (&act.sa_mask, SIGQUIT);
  sigdelset (&act.sa_mask, SIGABRT);
  sigaction (signum, &act, &o_act);
  return o_act.sa_handler;

#else
  return signal (signum, handlerFunc);
#endif
}


int
_gst_mem_protect (PTR addr, size_t len, int prot)
{
#if defined HAVE_MPROTECT
  return mprotect (addr, len, prot);

#elif defined WIN32
  DWORD oldprot;
  int my_prot;

  switch (prot & (PROT_READ | PROT_WRITE | PROT_EXEC))
  {
  case PROT_NONE:
    my_prot = 0; break;

  case PROT_READ:
    my_prot = PAGE_READONLY; break;

  case PROT_WRITE:
  case PROT_READ | PROT_WRITE:
    my_prot = PAGE_READWRITE; break;

  case PROT_EXEC:
    my_prot = PAGE_EXECUTE; break;

  case PROT_EXEC | PROT_READ:
    my_prot = PAGE_EXECUTE_READ; break;

  case PROT_EXEC | PROT_WRITE:
  case PROT_EXEC | PROT_READ | PROT_WRITE:
    my_prot = PAGE_EXECUTE_READWRITE; break;
  
  default:
    return -1;
  }

  if (VirtualProtect (addr, len, my_prot, &oldprot))
    return 0;
  else
    return -1;
#else
  return -1;
#endif
}



unsigned
_gst_get_milli_time (void)
{
#if defined WIN32
  /* time() seems not to work... so we hack. This method to obtain the
     time is complex, but it is the most precise.  */
  static long frequency = 0, frequencyH, adjust = 0;
  long milli;
  LARGE_INTEGER counter;
  SYSTEMTIME st;

  if (!frequency)
    {
      if (QueryPerformanceFrequency (&counter))
	{
	  /* frequencyH = 1000 * 2^32 / frequency */
	  frequency = counter.HighPart ? -1 : counter.LowPart;
	  frequencyH = MulDiv (1000 * (1 << 16), (1 << 16), frequency);
	}
      else
	frequency = -1;
    }

  if (frequency == -1)
    {
      /* QueryPerformanceCounter not supported, always use GetLocalTime 
       */
      adjust = milli = 0;
    }
  else
    {
      QueryPerformanceCounter (&counter);
      /* milli = (high * 2^32 + low) * 1000 / freq = high * (1000 *
         2^32 / freq) + (low * 1000 / freq) = (high * frequencyH) +
         (low / 4) * 4000 / freq) Dividing and multiplying
         counter.LowPart by 4 is needed because MulDiv accepts signed
         integers but counter.LowPart is unsigned.  */
      milli = counter.HighPart * frequencyH;
      milli += MulDiv (counter.LowPart >> 2, 4000, frequency);
    }

  if (!adjust)
    {
      GetLocalTime (&st);
      adjust = st.wMilliseconds;
      adjust += st.wSecond * 1000;
      adjust += st.wMinute * 60000;
      adjust += st.wHour * 3600000;
      adjust -= milli;
      milli += adjust;
    }
  else
    {
      milli += adjust;
      while (milli > 86400000)
	{
	  milli -= 86400000;
	  adjust -= 86400000;
	}
    }
  return (unsigned) milli;

#elif defined HAVE_GETTIMEOFDAY 	/* BSD style */
  struct timeval t;

  gettimeofday (&t, NULL);
  t.tv_sec %= 86400;
  return (t.tv_sec * 1000 + t.tv_usec / 1000);

#else
  /* Assume that ftime (System V) is available */
  struct timeb t;
  ftime (&t);
  return t.time * 1000 + t.millitm;
#endif
}

#define TM_YEAR_BASE 1900

static int
tm_diff (struct tm *a,
	 struct tm *b)
{
  /* Compute intervening leap days correctly even if year is negative.
     Take care to avoid int overflow in leap day calculations, but it's 
     OK to assume that A and B are close to each other.  */
  int a4 = (a->tm_year >> 2) + (TM_YEAR_BASE >> 2) - !(a->tm_year & 3);
  int b4 = (b->tm_year >> 2) + (TM_YEAR_BASE >> 2) - !(b->tm_year & 3);
  int a100 = a4 / 25 - (a4 % 25 < 0);
  int b100 = b4 / 25 - (b4 % 25 < 0);
  int a400 = a100 >> 2;
  int b400 = b100 >> 2;
  int intervening_leap_days = (a4 - b4) - (a100 - b100) + (a400 - b400);
  int years = a->tm_year - b->tm_year;
  int days = (365 * years + intervening_leap_days
	      + (a->tm_yday - b->tm_yday));
  return (60 * (60 * (24 * days + (a->tm_hour - b->tm_hour))
		+ (a->tm_min - b->tm_min)) + (a->tm_sec - b->tm_sec));
}

time_t
_gst_adjust_time_zone (time_t t)
{
  struct tm save_tm, *decoded_time;
  time_t bias;

#ifdef LOCALTIME_CACHE
  tzset ();
#endif
  decoded_time = localtime (&t);
  save_tm = *decoded_time;
  decoded_time = gmtime (&t);
  bias = tm_diff (&save_tm, decoded_time);

  return (t + bias);
}

long
_gst_current_time_zone_bias (void)
{
  time_t now;
  long bias;
  struct tm save_tm, *decoded_time;

  time (&now);

#ifdef LOCALTIME_CACHE
  tzset ();
#endif

  decoded_time = localtime (&now);
  save_tm = *decoded_time;
  decoded_time = gmtime (&now);
  bias = tm_diff (&save_tm, decoded_time);
  return (bias);
}

char *
_gst_current_time_zone_name (void)
{
  const char *zone;
  zone = getenv ("TZ");
  if (!zone)
    {
#ifdef WIN32
      long bias = _gst_current_time_zone_bias () / 60;
      TIME_ZONE_INFORMATION tzi;
      LPCWSTR name;
      static char buffer[32];
      GetTimeZoneInformation (&tzi);
      zone = buffer;
      name = (bias == (tzi.Bias + tzi.StandardBias))
	? tzi.StandardName : tzi.DaylightName;

      WideCharToMultiByte (CP_ACP, 0,
			   name, lstrlenW (name), zone, 32, NULL, NULL);

#else
      /* Maybe we could guess it */
      zone = "XXX";
#endif
    }

  return xstrdup (zone);
}

time_t
_gst_get_time (void)
{
  time_t now;
  time (&now);

  return (_gst_adjust_time_zone (now));
}



#ifdef WIN32
struct
{
  HANDLE hNewWaitEvent;
  long sleepTime;
}
alarms;

/* thread for precise alarm callbacks */
void CALLBACK
alarm_thread (unused)
     LPVOID unused;
{
  WaitForSingleObject (alarms.hNewWaitEvent, INFINITE);
  for (;;)
    {
      int sleepTime;

      sleepTime = alarms.sleepTime;
      if (sleepTime > 0)
	{
	  if (WaitForSingleObject (alarms.hNewWaitEvent, sleepTime) !=
	      WAIT_TIMEOUT)
	    {
	      /* The old wait was canceled by a new one */
	      continue;
	    }
	}
      raise (SIGALRM);
      WaitForSingleObject (alarms.hNewWaitEvent, INFINITE);
    }
}

static void
initialize_alarms ()
{
  HANDLE hthread;
  DWORD tid;

  /* Starts as non-signaled, so alarm_thread will wait */
  alarms.hNewWaitEvent = CreateEvent (NULL, FALSE, FALSE, NULL);

  /* Start alarm_thread with a 1024 bytes stack */
  hthread = CreateThread (NULL,
			  1024,
			  (LPTHREAD_START_ROUTINE) alarm_thread,
			  NULL, 0, &tid);
  
  /* This does not terminate the thread - it only releases our handle */
  CloseHandle (hthread);
}
#endif

/* Please feel free to make this more accurate for your operating system
 * and send me the changes.
 */
void
_gst_signal_after (int deltaMilli,
		   SigHandler func,
		   int kind)
{
  _gst_set_signal_handler (kind, func);

  if (deltaMilli <= 0)
    {
      raise (kind);
      return;
    }

  if (kind == TIMER_PROCESS)
    {
#if defined ITIMER_VIRTUAL
      struct itimerval value;
      value.it_interval.tv_sec = value.it_interval.tv_usec = 0;
      value.it_value.tv_sec = deltaMilli / 1000;
      value.it_value.tv_usec = (deltaMilli % 1000) * 1000;
      setitimer (ITIMER_VIRTUAL, &value, (struct itimerval *) 0);
#endif

    }
  else if (kind == TIMER_REAL)
    {
#if defined WIN32
      alarms.sleepTime = deltaMilli;
      SetEvent (alarms.hNewWaitEvent);

#elif defined ITIMER_REAL
      struct itimerval value;
      value.it_interval.tv_sec = value.it_interval.tv_usec = 0;
      value.it_value.tv_sec = deltaMilli / 1000;
      value.it_value.tv_usec = (deltaMilli % 1000) * 1000;
      setitimer (ITIMER_REAL, &value, (struct itimerval *) 0);

#elif defined HAVE_FORK
      static pid_t pid = -1;
      long end, ticks;
      if (pid != -1)
	kill (pid, SIGTERM);

      switch (pid = fork ())
	{
	case -1:
	  /* Error, try to recover */
	  raise (SIGALRM);
	  break;

	case 0:
	  /* Child process */
	  end = _gst_get_milli_time () + deltaMilli;
	  do
	    {
	      ticks = end - _gst_get_milli_time ();
	      if (ticks > 1100)	/* +100 is arbitrary */
		sleep ((int) (ticks / 1000));
	    }
	  while (ticks > 0);
	  kill (getppid (), SIGALRM);
	  _exit (0);
	}

#elif defined HAVE_ALARM
      alarm (deltaMilli / 1000);

#else
      /* Cannot do anything better than this */
      raise (SIGALRM);
#endif
    }
}

static SigHandler sigio_handler = SIG_IGN;

void
_gst_set_file_interrupt (int fd,
			 SigHandler func)
{
  if (func != sigio_handler) 
    {
      sigio_handler = func;

#ifdef SIGPOLL
      _gst_set_signal_handler (SIGPOLL, func);
#else
      _gst_set_signal_handler (SIGIO, func);
#endif
#ifdef SIGURG
      _gst_set_signal_handler (SIGURG, func);
#endif
    }

#if defined F_SETOWN && defined O_ASYNC

  {
    int oldflags;

    oldflags = fcntl (fd, F_GETFL, 0);
    if (((oldflags & O_ASYNC)
	 || (fcntl (fd, F_SETFL, oldflags | O_ASYNC) != -1))
	&& fcntl (fd, F_SETOWN, getpid ()) != -1)
      return;
  }
#endif

#ifdef I_SETSIG
  if (ioctl (fd, I_SETSIG, S_INPUT | S_OUTPUT | S_HIPRI) > -1)
    return;
#endif

#ifdef FIOSSAIOSTAT
#ifdef FIOSSAIOOWN
  {
    int stat_flags = 1;
    int own_flags = getpid();

    if (ioctl (fd, FIOSSAIOSTAT, &stat_flags) != -1
	&& ioctl (fd, FIOSSAIOOWN, &own_flags) != -1)
      return;
  }
#endif
#endif

#ifndef __MSVCRT__
#ifdef FIOASYNC
  {
    int argFIOASYNC = 1;
#if defined SIOCSPGRP
    int argSIOCSPGRP = getpid ();

    if (ioctl (fd, SIOCSPGRP, &argSIOCSPGRP) > -1 ||
        ioctl (fd, FIOASYNC, &argFIOASYNC) > -1)
      return;
#elif defined O_ASYNC
    int oldflags;

    oldflags = fcntl (fd, F_GETFL, 0);
    if (((oldflags & O_ASYNC)
         || (fcntl (fd, F_SETFL, oldflags | O_ASYNC) != -1))
        && ioctl (fd, FIOASYNC, &argFIOASYNC) > -1)
      return;
#else
    if (ioctl (fd, FIOASYNC, &argFIOASYNC) > -1)
      return;
#endif
  }
#endif
#endif /* FIOASYNC */
}



char *
_gst_get_cur_dir_name (void)
{
  char *cwd;
  char *ret;
  unsigned path_max;
  int save_errno;

  path_max = (unsigned) PATH_MAX;
  path_max += 2;		/* The getcwd docs say to do this.  */

  cwd = xmalloc (path_max);

  errno = 0;
  do
    {
      ret = getcwd (cwd, path_max);
      if (ret)
	return (cwd);

      if (errno != ERANGE)
	break;

      errno = 0;
      path_max += 128;
      cwd = xrealloc (cwd, path_max);
    }
  while (!errno);

  save_errno = errno;
  xfree (cwd);
  errno = save_errno;
  return (NULL);
}


int
_gst_set_file_access_times (const char *name, long new_atime, long new_mtime)
{
  int result;
#if defined HAVE_UTIMES
  struct timeval times[2];
  times[0].tv_sec = new_atime + 86400 * 10957;
  times[1].tv_sec = new_mtime + 86400 * 10957;
  times[0].tv_usec = times[1].tv_usec = 0;
  result = utimes (name, times);
#elif defined HAVE_UTIME
  struct utimbuf utb;
  utb.actime = new_atime + 86400 * 10957;
  utb.modtime = new_mtime + 86400 * 10957;
  result = utime (name, &utb);
#else
#warning neither utime nor utimes are available.
  errno = ENOSYS;
  result = -1;
#endif
  if (!result)
    errno = 0;
  return (result);
}


char *
_gst_get_full_file_name (const char *name)
{
  char *rpath, *dest;
  const char *start, *end, *rpath_limit;
  long int path_max;
#ifdef HAVE_READLINK
  int num_links = 0;
  char *extra_buf = NULL;
#endif

#ifdef PATH_MAX
  path_max = PATH_MAX;
#else
  path_max = pathconf (name, _PC_PATH_MAX);
  if (path_max <= 0)
    path_max = 1024;
#endif

  rpath = malloc (path_max);
  if (rpath == NULL)
    return NULL;
  rpath_limit = rpath + path_max;

#if defined WIN32 && !defined __CYGWIN__
  {
    struct stat st;
    DWORD retval = GetFullPathNameA (name, path_max, rpath, NULL);
    if (retval > path_max)
      {
	rpath = realloc (rpath, retval);
        retval = GetFullPathNameA (name, retval, rpath, NULL);
      }
    if (retval == 0
	|| stat (rpath, &st) == -1)
      goto error;
  }
#else
  if (name[0] != '/')
    {
      if (!getcwd (rpath, path_max))
	goto error;

      dest = strchr (rpath, '\0');
    }
  else
    {
      rpath[0] = '/';
      dest = rpath + 1;
    }

  for (start = end = name; *start; start = end)
    {
      struct stat st;

      /* Skip sequence of multiple path-separators.  */
      while (*start == '/')
	++start;

      /* Find end of path component.  */
      for (end = start; *end && *end != '/'; ++end)
	/* Nothing.  */;

      if (end - start == 0)
	break;
      else if (end - start == 1 && start[0] == '.')
	/* nothing */;
      else if (end - start == 2 && start[0] == '.' && start[1] == '.')
	{
	  /* Back up to previous component, ignore if at root already.  */
	  if (dest > rpath + 1)
	    while ((--dest)[-1] != '/');
	}
      else
	{
	  size_t new_size;

	  if (dest[-1] != '/')
	    *dest++ = '/';

	  if (dest + (end - start) >= rpath_limit)
	    {
	      ptrdiff_t dest_offset = dest - rpath;
	      char *new_rpath;

	      new_size = rpath_limit - rpath;
	      if (end - start + 1 > path_max)
		new_size += end - start + 1;
	      else
		new_size += path_max;
	      new_rpath = (char *) realloc (rpath, new_size);
	      if (new_rpath == NULL)
		goto error;
	      rpath = new_rpath;
	      rpath_limit = rpath + new_size;

	      dest = rpath + dest_offset;
	    }

	  memcpy (dest, start, end - start);
	  dest += end - start;
	  *dest = '\0';

	  if (lstat (rpath, &st) < 0)
	    goto error;

#if HAVE_READLINK
	  if (S_ISLNK (st.st_mode))
	    {
	      char *buf;
	      size_t len;
	      int n;

	      if (++num_links > MAXSYMLINKS)
		{
		  errno = ELOOP;
		  goto error;
		}

	      buf = alloca (path_max);
	      n = readlink (rpath, buf, path_max - 1);
	      if (n < 0)
		{
		  int saved_errno = errno;
		  errno = saved_errno;
		  goto error;
		}
	      buf[n] = '\0';
	      if (!extra_buf)
		extra_buf = alloca (path_max);

	      len = strlen (end);
	      if ((long int) (n + len) >= path_max)
		{
		  errno = ENAMETOOLONG;
		  goto error;
		}

	      /* Careful here, end may be a pointer into extra_buf... */
	      memmove (&extra_buf[n], end, len + 1);
	      name = end = memcpy (extra_buf, buf, n);

	      if (buf[0] == '/')
		dest = rpath + 1;	/* It's an absolute symlink */
	      else
		/* Back up to previous component, ignore if at root already: */
		if (dest > rpath + 1)
		  while ((--dest)[-1] != '/');
	    }
#endif
	}
    }
  if (dest > rpath + 1 && dest[-1] == '/')
    --dest;
  *dest = '\0';
#endif
  return rpath;

error:
  {
    int saved_errno = errno;
    free (rpath);
    errno = saved_errno;
  }
  return NULL;
}



mst_Boolean
_gst_file_is_newer (const char *file1, const char *file2)
{
  static char *prev_file1;
  static struct stat st1;
  struct stat st2;

  if (!prev_file1 || strcmp (file1, prev_file1))
    {
      if (prev_file1)
	xfree (prev_file1);
      prev_file1 = xstrdup (file1);

      if (!_gst_file_is_readable (file1))
        return false;
      if (stat (file1, &st1) < 0)
	return false;
    }

  if (!_gst_file_is_readable (file2))
    return true;
  if (stat (file2, &st2) < 0)
    return true;

  if (st1.st_mtime != st2.st_mtime)
    return st1.st_mtime > st2.st_mtime;

  /* 15 years have passed and nothing seems to have changed.  */
#if defined HAVE_STRUCT_STAT_ST_MTIMENSEC
  return st1.st_mtimensec >= st2.st_mtimensec;
#elif defined HAVE_STRUCT_STAT_ST_MTIM_TV_NSEC
  return st1.st_mtim.tv_nsec >= st2.st_mtim.tv_nsec;
#elif defined HAVE_STRUCT_STAT_ST_MTIMESPEC_TV_NSEC
  return st1.st_mtimespec.tv_nsec >= st2.st_mtimespec.tv_nsec;
#else
  /* Say that the image file is newer.  */
  return true;
#endif
}


mst_Boolean
_gst_file_is_readable (const char *fileName)
{
  return (access (fileName, R_OK) == 0);
}

mst_Boolean
_gst_file_is_writeable (const char *fileName)
{
  return (access (fileName, W_OK) == 0);
}

mst_Boolean
_gst_file_is_executable (const char *fileName)
{
  return (access (fileName, X_OK) == 0);
}

#ifdef __linux__
/* File descriptor of the executable, used for double checking.  */
static int executable_fd = -1;
#endif

/* The path to the executable, derived from argv[0].  */
const char *_gst_executable_path = NULL;

/* Tests whether a given pathname may belong to the executable.  */
static mst_Boolean
maybe_executable (const char *filename)
{
  if (!_gst_file_is_executable (filename))
    return false;

#ifdef __linux__
  if (executable_fd >= 0)
    {
      /* If we already have an executable_fd, check that filename points to
	 the same inode.  */
      struct stat statexe, statfile;

      if (fstat (executable_fd, &statexe) < 0
	  || stat (filename, &statfile) < 0
	  || !(statfile.st_dev
	       && statfile.st_dev == statexe.st_dev
	       && statfile.st_ino == statexe.st_ino))
	return false;

      close (executable_fd);
      executable_fd = -1;
    }
#endif

  return true;
}

/* Determine the full pathname of the current executable, freshly allocated.
   Return NULL if unknown.  Guaranteed to work on Linux and Win32, Mac OS X.
   Likely to work on the other Unixes (maybe except BeOS), under most
   conditions.  */
static char *
find_executable (const char *argv0)
{
#if defined WIN32
  char location[MAX_PATH];
  int length = GetModuleFileName (NULL, location, sizeof (location));
  if (length <= 0)
    return NULL;

#if defined __CYGWIN__
  {
    /* On Cygwin, we need to convert paths coming from Win32 system calls
       to the Unix-like slashified notation.  */
    static char location_as_posix_path[2 * MAX_PATH];

    /* There's no error return defined for cygwin_conv_to_posix_path.
       See cygwin-api/func-cygwin-conv-to-posix-path.html.
       Does it overflow the buffer of expected size MAX_PATH or does it
       truncate the path?  I don't know.  Let's catch both.  */
    cygwin_conv_to_posix_path (location, location_as_posix_path);
    location_as_posix_path[MAX_PATH - 1] = '\0';
    if (strlen (location_as_posix_path) >= MAX_PATH - 1)
      /* A sign of buffer overflow or path truncation.  */
      return NULL;

    return _gst_get_full_file_name (location_as_posix_path);
  }
#else
  return xstrdup (location);
#endif

#else /* Unix && !Cygwin */
#ifdef PATH_MAX
  int path_max = PATH_MAX;
#else
  int path_max = pathconf (name, _PC_PATH_MAX);
  if (path_max <= 0)
    path_max = 1024;
#endif

#if HAVE_MACH_O_DYLD_H && HAVE__NSGETEXECUTABLEPATH
  char *location = alloca (path_max);
  uint32_t length = path_max;
  if (_NSGetExecutablePath (location, &length) == 0 && location[0] == '/')
    return _gst_get_full_file_name (location);

#elif defined __linux__
  /* The executable is accessible as /proc/<pid>/exe.  In newer Linux
     versions, also as /proc/self/exe.  Linux >= 2.1 provides a symlink
     to the true pathname; older Linux versions give only device and ino,
     enclosed in brackets, which we cannot use here.  */
  {
    char buf[6 + 10 + 5];
    char *location = xmalloc (path_max + 1);
    ssize_t n;

    sprintf (buf, "/proc/%d/exe", getpid ());
    n = readlink (buf, location, path_max);
    if (n > 0 && location[0] != '[')
      {
        location[n] == '\0';
        return location;
      }
    if (executable_fd < 0)
      executable_fd = open (buf, O_RDONLY, 0);
  }
#endif

  if (*argv0 == '-')
    argv0++;

  /* Guess the executable's full path.  We assume the executable has been
     called via execlp() or execvp() with properly set up argv[0].
     exec searches paths without slashes in the directory list given
     by $PATH.  */
  if (!strchr (argv0, '/'))
    {
      const char *p_next = getenv ("PATH");
      const char *p;

      while ((p = p_next) != NULL)
	{
	  char *concat_name;

	  p_next = strchr (p, ':');
	  /* An empty PATH element designates the current directory.  */
	  if (p_next == p + 1)
	    concat_name = xstrdup (argv0);
	  else if (!p_next)
	    asprintf (&concat_name, "%s/%s", p, argv0);
	  else
	    asprintf (&concat_name, "%.*s/%s", p_next++ - p, p, argv0);

	  if (maybe_executable (concat_name))
	    {
	      char *full_path = _gst_get_full_file_name (concat_name);
	      free (concat_name);
	      return full_path;
	    }

	  free (concat_name);
	}
      /* Not found in the PATH, assume the current directory.  */
    }

  if (maybe_executable (argv0))
    return _gst_get_full_file_name (argv0);

  /* No way to find the executable.  */
#ifdef __linux__
  close (executable_fd);
  executable_fd = -1;
#endif
  return NULL;
#endif
}

void
_gst_set_executable_path (const char *argv0)
{
  _gst_executable_path = find_executable (argv0);
}

char *
_gst_relocate_path (const char *path)
{
  const char *p;
  char *s;

  /* Detect absolute paths.  */
#if defined(MSDOS) || defined(WIN32) || defined(__OS2__)
  if ((path[0] && path[1] == ':')
      || path[0] == '/' || path[0] == '\\')
    return xstrdup (path);
#else
  if (path[0] == '/')
    return xstrdup (path);
#endif

  /* Remove filename from executable path.  */
  p = _gst_executable_path + strlen (_gst_executable_path);
  do
    --p;
  while (p >= _gst_executable_path
         && *p != '/'
#if defined(MSDOS) || defined(WIN32) || defined(__OS2__)
	 && *p != '\\'
#endif
	);
  p++;

  /* Now p points just past the last separator (if any).  */
  s = alloca (p - _gst_executable_path + strlen (path) + 1);
  sprintf (s, "%.*s%s", p - _gst_executable_path, _gst_executable_path, path);
  return _gst_get_full_file_name (s);
}


/* Code to use PTY's did not work on Mac OS.  I'm keeping the Unix code,
   but it should not be used.  */
#ifdef __MSVCRT__
typedef struct pty_info {
  int access;
  int master;
  int slave;
  char *slavenam;

  int save_stdin;
  int save_stdout;
  int save_stderr;
} pty_info;

static int
open_pty (pty_info *pty)
{
#ifdef HAVE_TERMIOS_H
  static mst_Boolean initialized;
#ifdef HAVE_GRANTPT
  static mst_Boolean have_devptmx;
#endif
  static int firstpty;

  pty->slave = -1;
  if (!initialized)
    {
      char s[] = "/dev/pty?0";
      int n;
#ifdef HAVE_GRANTPT
      have_devptmx = _gst_file_is_readable ("/dev/ptmx");
#endif

      /* Search for the first letter to be tried when using pty devices */
      firstpty = -1;
      for (n = 26, s[8] = 'p'; n--;
	   s[8] = (s[8] == 'z') ? 'a' : s[8] + 1)
	{
	  struct stat statb;
	  if (stat (s, &statb) >= 0)
	    {
	      firstpty = s[strlen ("/dev/pty")];
	      break;
	    }
	}
    }

#ifdef HAVE_GRANTPT
  /* If we have Unix98-style pty's, things are much simpler! */
  if (have_devptmx)
    {
      pty->master = open ("/dev/ptmx", O_RDWR);
      if (pty->master >= 0)
	{
	  char *slavenam;
	  grantpt (pty->master);
	  unlockpt (pty->master);
	  slavenam = (char *) ptsname (pty->master);
	  if (!slavenam)
	    close (pty->master);

	  else
	    {
	      pty->slavenam = xstrdup (slavenam);
	      return pty->master;
	    }
	}
    }
#endif

  if (firstpty != -1)
    {
      /* Assume /dev/ptyXN and /dev/ttyXN naming system. The
         FIRST_PTY_LETTER gives the first X to try. We try in the
         sequence FIRST_PTY_LETTER, .., 'z', 'a', .., FIRST_PTY_LETTER. 
         Is this worthwhile, or just over-zealous? */

      char slavenam[16];
      char *ptyId = slavenam + strlen ("/dev/pty");
      int n;
      strcpy (slavenam, "/dev/pty?0");

      /* Sieve all letter-hex.digit combinations to find a usable pty device */
      for (n = 26, ptyId[0] = firstpty;
	   n--; ptyId[0] = (ptyId[0] == 'z') ? 'a' : ptyId[0] + 1)
	{

	  for (ptyId[1] = '0'; ptyId[1] <= 'f';
	       ptyId[1] = (ptyId[1] == '9') ? 'a' : ptyId[1] + 1)
	    {

	      struct stat statb;
	      if (stat (slavenam, &statb) < 0)
		return -1;
	      if ((pty->master = open (slavenam, O_RDWR)) >= 0)
		{
		  slavenam[strlen ("/dev/")] = 't';
		  if (_gst_file_is_readable (slavenam)
		      && _gst_file_is_writeable (slavenam))
		    {
		      pty->slavenam = xstrdup (slavenam);
		      return pty->master;
		    }

		  slavenam[strlen ("/dev/")] = 'p';
		  close (pty->master);
		}		/* open master */
	    }			/* hex digit */
	}			/* alphabetic char */
    }
#endif /* HAVE_TERMIOS_H */

#ifdef __MSVCRT__
  {
    const char *prefix = "\\\\..\\pipe\\_gnu_smalltalk_named_pipe";
    HANDLE hMaster, hSlave;
    static long int id = 0;

    /* Windows 95 only has anonymous pipes, so we prefer them for unidirectional
       pipes; we have no choice but named pipes for bidirectional operation.
       Note that CreatePipe gives two handles, so we open both sides at once
       and store the file descriptor into pty->slave, while CreateNamedPipe has
       more or less the same semantics as Unix pty's (the difference is that both
       sides of the pipe use the same filename, but that's transparent).  */
    switch (pty->access)
      {
      case O_RDONLY:
	if (!CreatePipe (&hMaster, &hSlave, NULL, 0))
	  return -1;

	pty->slave = _open_osfhandle (hSlave, O_WRONLY | O_BINARY);
	break;
				
      case O_WRONLY:
	if (!CreatePipe (&hSlave, &hMaster, NULL, 0))
	  return -1;

	pty->slave = _open_osfhandle (hSlave, O_RDONLY | O_BINARY);
	break;
				
      case O_RDWR:
	asprintf (&pty->slavenam, "%s_%d_%ld__",
	          prefix, getpid (), id++);

	hMaster = CreateNamedPipe (pty->slavenam,
			           PIPE_ACCESS_DUPLEX, 0, 1, 0, 0, 0, NULL);

	if (!hMaster)
	  return -1;

	pty->slave = -1;
	break;
      }

    pty->master = _open_osfhandle (hMaster, pty->access | O_BINARY);
    return pty->master;
  }
#else
  return -1;
#endif
}

static void
init_pty (pty_info *pty)
{
  int slave;

#ifndef HAVE_SPAWNL
  close (pty->master);
#endif

  /* Order can be either open/setsid/TIOCSCTTY or setsid/open.
     Anyway we need to make this process a session group leader,
     because it is on a new PTY, and things like job control
     simply will not work correctly unless there is a session
     group leader and a process group leader (which a session
     group leader automatically is).  This also disassociates
     us from our old controlling tty.  */
#ifdef TIOCSCTTY
  if (pty->slave != -1)
    slave = pty->slave;
  else if ((slave = open (pty->slavenam, O_RDWR | O_BINARY)) < 0)
    {
      perror ("open(slave)");
      exit (255);
    }

#if !defined HAVE_SPAWNL && defined HAVE_SETSID
  if (setsid () < 0)
    {
      perror ("setsid");
      exit (255);
    }
#endif

  ioctl (slave, TIOCSCTTY, 0);
#else
#if !defined HAVE_SPAWNL && defined HAVE_SETSID
  if (setsid () < 0)
    {
      perror ("setsid");
      exit (255);
    }
#endif

  if (pty->slave != -1)
    slave = pty->slave;
  else if ((slave = open (pty->slavenam, O_RDWR | O_BINARY)) < 0)
    {
      perror ("open(slave)");
      exit (255);
    }
#endif

#ifdef I_PUSH
  /* Push the necessary modules onto the slave to get terminal
     semantics.  */
  ioctl (slave, I_PUSH, "ptem");
  ioctl (slave, I_PUSH, "ldterm");
#endif

#ifdef HAVE_TERMIOS_H
  {
    struct termios st;
    tcgetattr (slave, &st);
    st.c_iflag &= ~(ISTRIP | IGNCR | INLCR | IXOFF);
    st.c_iflag |= (ICRNL | IGNPAR | BRKINT | IXON);
    st.c_cflag &= ~CSIZE;
    st.c_cflag |= CREAD | CS8 | CLOCAL;
    st.c_oflag &= ~OPOST;
    st.c_lflag &= ~(ECHO | ECHOE | ECHOK | NOFLSH | TOSTOP);
    st.c_lflag |= ISIG;
#if 0
    st.c_cc[VMIN] = 1;
    st.c_cc[VTIME] = 0;
#endif

  /* Set some control codes to default values */
#ifdef VINTR
    st.c_cc[VINTR] = '\003';	/* ^c */
#endif
#ifdef VQUIT
    st.c_cc[VQUIT] = '\034';	/* ^| */
#endif
#ifdef VERASE
    st.c_cc[VERASE] = '\177';	/* ^? */
#endif
#ifdef VKILL
    st.c_cc[VKILL] = '\025';	/* ^u */
#endif
#ifdef VEOF
    st.c_cc[VEOF] = '\004';	/* ^d */
#endif

    tcsetattr (slave, TCSANOW, &st);
  }
#endif /* HAVE_TERMIOS_H */

#ifdef HAVE_SPAWNL
#define SAVE_FD(where, fd) ((where) = dup ((fd)))
#else
#define SAVE_FD(where, fd) ((void)0)
#endif

  pty->save_stdin = pty->save_stdout = pty->save_stderr = -1;

  /* Duplicate the handles.  Which handles are to be hooked is
     anti-intuitive: remember that pty->access gives the parent's point 
     of view, not the child's, so `read only' means the child
     should write to the pipe and `write only' means the child
     should read from the pipe.  */
  if (pty->access != O_RDONLY)
    {
      SAVE_FD (pty->save_stdin, 0);
      dup2 (slave, 0);
    }

  if (pty->access != O_WRONLY)
    {
      SAVE_FD (pty->save_stdout, 1);
      SAVE_FD (pty->save_stderr, 2);
      dup2 (slave, 1);
      dup2 (slave, 2);
    }

  if (slave > 2)
    close (slave);
}

int
_gst_open_pipe (const char *command,
		const char *mode)
{
  pty_info pty;
  int master;
  int access;
  int result;

  access = strchr (mode, '+') ? O_RDWR :
    (mode[0] == 'r' ? O_RDONLY : O_WRONLY);

  pty.access = access;
  pty.slave = -1;

  master = open_pty (&pty);
  if (master == -1)
    return -1;

  _gst_set_signal_handler (SIGPIPE, SIG_DFL);
  _gst_set_signal_handler (SIGFPE, SIG_DFL);

#ifdef HAVE_SPAWNL
  init_pty (&pty);

#ifdef __CYGWIN__
  result = spawnl (P_NOWAIT, "/bin/sh", "/bin/sh", "-c", command, NULL);
#else
  result = spawnl (P_NOWAIT, getenv("COMSPEC"), "/C", command, NULL);
#endif

  if (pty.save_stdin != -1)
    {
      dup2 (pty.save_stdin, 0);
      close (pty.save_stdin);
    }

  if (pty.save_stdout != -1)
    {
      dup2 (pty.save_stdout, 1);
      close (pty.save_stdout);
    }

  if (pty.save_stderr != -1)
    {
      dup2 (pty.save_stderr, 2);
      close (pty.save_stderr);
    }

#else /* !HAVE_SPAWNL */
  /* We suppose it is a system that has fork.  */
  result = fork ();
  if (result == 0)
    {
      /* Child process */
      init_pty (&pty);
      free (pty.slavenam);
      _exit (system (command) >= 0);
      /*NOTREACHED*/
    }

#endif /* !HAVE_SPAWNL */

  _gst_set_signal_handler (SIGPIPE, SIG_IGN);
  _gst_set_signal_handler (SIGFPE, SIG_IGN);

  /* Free it in the parent too! */
  free (pty.slavenam);

  if (result == -1)
    {
      int save_errno;
      save_errno = errno;
      close (master);
      errno = save_errno;
      return (-1);
    }
  else
    return (master);
}
#else

/* Use sockets or pipes.  */
int
_gst_open_pipe (const char *command,
		const char *mode)
{
  int fd[2];
  int our_fd, child_fd;
  int master;
  int access;
  int result;

  access = strchr (mode, '+') ? O_RDWR :
    (mode[0] == 'r' ? O_RDONLY : O_WRONLY);

  if (access == O_RDWR)
    {
      result = socketpair (AF_UNIX, SOCK_STREAM, 0, fd);
      our_fd = fd[1];
      child_fd = fd[0];
    }
  else
    {
      result = pipe (fd);
      our_fd = access == O_RDONLY ? fd[0] : fd[1];
      child_fd = access == O_RDONLY ? fd[1] : fd[0];
    }

  if (result == -1)
    return -1;

  _gst_set_signal_handler (SIGPIPE, SIG_DFL);
  _gst_set_signal_handler (SIGFPE, SIG_DFL);

#ifdef HAVE_SPAWNL
  {
    /* Prepare file descriptors, saving the old ones so that we can keep
       them.  */
    int save_stdin = -1, save_stdout = -1, save_stderr = -1;
    if (access != O_WRONLY)
      {
        save_stdout = dup (1);
        save_stderr = dup (2);
        dup2 (child_fd, 1);
        dup2 (child_fd, 2);
      }
    if (access != O_RDONLY)
      {
        save_stdin = dup (0);
        dup2 (child_fd, 0);
      }

#ifdef __CYGWIN__
    result = spawnl (P_NOWAIT, "/bin/sh", "/bin/sh", "-c", command, NULL);
#else
    result = spawnl (P_NOWAIT, getenv("COMSPEC"), "/C", command, NULL);
#endif

    if (save_stdin != -1)
      {
        dup2 (save_stdin, 0);
        close (save_stdin);
      }

    if (save_stdout != -1)
      {
        dup2 (save_stdout, 1);
        close (save_stdout);
      }

    if (save_stderr != -1)
      {
        dup2 (save_stderr, 2);
        close (save_stderr);
      }
  }
#else /* !HAVE_SPAWNL */
  /* We suppose it is a system that has fork.  */
  result = fork ();
  if (result == 0)
    {
      /* Child process */
      close (our_fd);
      if (access != O_WRONLY)
        {
          dup2 (child_fd, 1);
          dup2 (child_fd, 2);
        }
      if (access != O_RDONLY)
        dup2 (child_fd, 0);

      _exit (system (command) >= 0);
      /*NOTREACHED*/
    }

#endif /* !HAVE_SPAWNL */

  close (child_fd);
  _gst_set_signal_handler (SIGPIPE, SIG_IGN);
  _gst_set_signal_handler (SIGFPE, SIG_IGN);

  if (result == -1)
    {
      int save_errno;
      save_errno = errno;
      close (our_fd);
      errno = save_errno;
      return (-1);
    }
  else
    return (our_fd);
}
#endif

int
_gst_open_file (const char *filename,
		const char *mode)
{
  mst_Boolean create = false;
  int oflags = O_BINARY, access = 0;
  int fd, i;

  switch (*mode)
    {
    case 'a':
      access = O_WRONLY;
      oflags |= O_APPEND;
      create = 1;
      break;
    case 'w':
      access = O_WRONLY;
      oflags |= O_TRUNC;
      create = 1;
      break;
    case 'r':
      access = O_RDONLY;
      break;
    default:
      return -1;
    }

  for (i = 1; i < 3; ++i)
    {
      ++mode;
      if (*mode == '\0')
	break;
      else if (*mode == '+')
        create = 1, access = O_RDWR;
      else if (*mode == 'x')
	oflags |= O_EXCL;
    }

#ifdef O_CLOEXEC
  oflags |= O_CLOEXEC;
#endif

  if (create)
    fd = open (filename, oflags | access | O_CREAT, 0666);
  else
    fd = open (filename, oflags | access);

  if (fd < 0)
    return -1;

#if defined FD_CLOEXEC && !defined O_CLOEXEC
  fcntl (fd, F_SETFD, fcntl (fd, F_GETFD, 0) | FD_CLOEXEC);
#endif

  return fd;
}

mst_Boolean
_gst_is_pipe (int fd)
{
  struct stat st;

  fstat (fd, &st);
#ifdef S_IFREG
  return !(st.st_mode & S_IFREG);
#else
  return !S_ISREG (st.st_mode);
#endif
}

int
_gst_recv (int fd,
	   PTR buffer,
	   int size,
	   int flags)
{
#ifdef HAVE_SOCKETS
  int result;
  int save_errno = errno;

  for (;;)
    {
      result = recvfrom (fd, buffer, size, flags, NULL, NULL);
      if (errno == EFAULT)
        abort ();

      if (is_socket_error (EINTR))
	clear_socket_error ();
      else
	break;
    }

  if (errno == EINTR)
    errno = save_errno;

  return result;
#else
  errno = ENOSYS;
  return -1;
#endif
}

int
_gst_send (int fd,
	   PTR buffer,
	   int size,
	   int flags)
{
#ifdef HAVE_SOCKETS
  int result;
  int save_errno = errno;

  for (;;)
    {
      result = send (fd, buffer, size, flags);
      if (errno == EFAULT)
        abort ();

      if (is_socket_error (EINTR))
	clear_socket_error ();
      else
	break;
    }

  if (errno == EINTR)
    errno = save_errno;

  return result;
#else
  errno = ENOSYS;
  return -1;
#endif
}

int
_gst_read (int fd,
	   PTR buffer,
	   int size)
{
  int result;
  int save_errno = errno;

  do
    {
      result = read (fd, buffer, size);
      if (errno == EFAULT)
        abort ();
    }
  while ((result == -1) && (errno == EINTR));
  if (errno == EINTR)
    errno = save_errno;

  return result;
}

int
_gst_write (int fd,
	    PTR buffer,
	    int size)
{
  int result;
  int save_errno = errno;

  do
    {
      result = write (fd, buffer, size);
      if (errno == EFAULT)
        abort ();
    }
  while ((result == -1) && (errno == EINTR));
  if (errno == EINTR)
    errno = save_errno;

  return result;
}

int
_gst_full_write (int fd,
	         PTR buffer,
	         int size)
{
  char *buf = (char *) buffer;
  int num = 0, sofar = 0;

  for (; size; buf += num, size -= num, sofar += num)
    num = _gst_write (fd, buf, size);

  return (num < 0 ? num : sofar);
}


static void
sigchld_handler (int signum)
{
#ifdef HAVE_WAITPID
  int pid, status, serrno;
  serrno = errno;
  do
    pid = waitpid (-1, &status, WNOHANG);
  while (pid > 0);
  errno = serrno;
#endif

  /* Pass it to the SIGIO handler, it might reveal a POLLHUP event.  */
  if (sigio_handler != SIG_DFL && sigio_handler != SIG_IGN)
    sigio_handler (signum);

  _gst_set_signal_handler (SIGCHLD, sigchld_handler);
}

void
_gst_init_sysdep (void)
{
#ifdef WIN32
  initialize_alarms ();
#endif /* WIN32 */

  tzset ();

  _gst_set_signal_handler (SIGPIPE, SIG_IGN);
  _gst_set_signal_handler (SIGFPE, SIG_IGN);
  _gst_set_signal_handler (SIGCHLD, sigchld_handler);
}

void
_gst_debugf (const char *fmt,
	     ...)
{
  char buf[1024];
  va_list args;
  va_start (args, fmt);

  vsprintf (buf, fmt, args);

#if defined WIN32 && !defined __GNUC__
  OutputDebugString (buf);
#else /* !WIN32 */
  {
    static FILE *debFile = NULL;
    if (debFile == NULL)
      debFile = fopen ("gst.deb", "w");

    fputs (buf, debFile);
    fflush (debFile);
  }
#endif /* !WIN32 */

  va_end (args);
}

void
_gst_debug (void)
{
  fflush (stdout);
  /* abort(); */
  /* raise(SIGTRAP); */
  /* getchar(); */
}

/* We have three possible implementations: Win32, mmap-ing /dev/zero
   or using anonymous mmaps, and anonymous mmaps with MAP_NORESERVE. 
   There is support for providing fallback implementations, but it
   is not used currently.  */

typedef struct heap_implementation {
  mst_Boolean (*check) ();
  PTR (*reserve) (PTR, size_t);
  void (*release) (PTR, size_t);
  PTR (*commit) (PTR, size_t);
  void (*decommit) (PTR, size_t);
} heap_implementation;

#ifdef WIN32
static PTR win32_reserve (PTR, size_t);
static void win32_release (PTR, size_t);
static PTR win32_commit (PTR, size_t);
static void win32_decommit (PTR, size_t);
struct heap_implementation heap_impl_tab[] = {
  { NULL, win32_reserve, win32_release, win32_commit, win32_decommit },
  { NULL, NULL, NULL, NULL, NULL }
};
#else /* !WIN32 */

# if defined MAP_AUTORESRV && !defined MAP_NORESERVE
#  define MAP_NORESERVE MAP_AUTORESRV
# endif
# ifdef MAP_NORESERVE
static PTR noreserve_reserve (PTR, size_t);
static void noreserve_decommit (PTR, size_t);
#endif
static mst_Boolean anon_mmap_check (void);
static PTR anon_mmap_reserve (PTR, size_t);
static void anon_mmap_release (PTR, size_t);
static PTR anon_mmap_commit (PTR, size_t);

struct heap_implementation heap_impl_tab[] = {
# ifdef MAP_NORESERVE
  { NULL, noreserve_reserve, _gst_osmem_free, anon_mmap_commit, noreserve_decommit },
# endif
  { anon_mmap_check, anon_mmap_reserve, anon_mmap_release, anon_mmap_commit, _gst_osmem_free },
  { NULL, NULL, NULL, NULL, NULL }
};

# ifndef MAP_ANON
static int dev_zero = -1;
#  define anon_mmap(addr, size, prot, flags) \
     mmap ((addr), (size), (prot), (flags), \
	   (UNCOMMON(dev_zero == -1) \
	    ? dev_zero = open ("/dev/zero", O_RDWR) \
	    : dev_zero), 0)
# else
#  define anon_mmap(addr, size, prot, flags) \
     mmap ((addr), (size), (prot), MAP_ANON | (flags), -1, 0)
# endif
#endif /* !WIN32 */



static heap_implementation *impl;

PTR
_gst_osmem_reserve (PTR address, size_t size)
{
  if (!impl)
    {
      /* Find an implementation of heaps that is ok for this machine.
         The check is done at run-time because it is cheap.  */
      for (impl = heap_impl_tab; impl->reserve; impl++)
        if (!impl->check || impl->check ())
	  return impl->reserve (address, size);

      /* Not found, check again the next time just in case and return
         ENOMEM.  */
      impl = NULL;
      errno = ENOMEM;
      return (NULL);
    }
  else
    return impl->reserve (address, size);
}

void
_gst_osmem_release (PTR base, size_t size)
{
  impl->release (base, size);
}

PTR
_gst_osmem_commit (PTR base, size_t size)
{
  return impl->commit (base, size);
}

void
_gst_osmem_decommit (PTR base, size_t size)
{
  impl->decommit (base, size);
}

PTR
_gst_osmem_alloc (size_t size)
{
  PTR addr;
#ifdef WIN32
  addr = VirtualAlloc(NULL, size, MEM_RESERVE, PAGE_NOACCESS);
  if (addr)
    {
      PTR result = VirtualAlloc (addr, size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
      if (result)
        return result;

      VirtualFree (addr, size, MEM_RELEASE);
    }

  errno = ENOMEM;
  return NULL;
#else

  addr = anon_mmap (NULL, size,
		    PROT_READ | PROT_WRITE | PROT_EXEC,
		    MAP_PRIVATE);

  return addr == MAP_FAILED ? NULL : addr;
#endif
}

void
_gst_osmem_free (PTR ptr, size_t size)
{
#ifdef WIN32
  VirtualFree(ptr, size, MEM_DECOMMIT);
  VirtualFree(ptr, size, MEM_RELEASE);
#else
  munmap (ptr, size);
#endif
}


/* Implementation of the four basic primitives for Win32.  */

#ifdef WIN32

PTR
win32_reserve (PTR address, size_t size)
{
  PTR base;
  base = VirtualAlloc(address, size, MEM_RESERVE, PAGE_NOACCESS);
  if (!base && address)
    base = VirtualAlloc(NULL, size, MEM_RESERVE, PAGE_NOACCESS);
  if (!base)
    errno = ENOMEM;

  return base;
}

void
win32_release (PTR base, size_t size)
{
  VirtualFree(base, size, MEM_RELEASE);
}

PTR
win32_commit (PTR base, size_t size)
{
  PTR addr;
  addr = VirtualAlloc (base, size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if (!addr)
    errno = ENOMEM;

  return addr;
}

void
win32_decommit (PTR base, size_t size)
{
  VirtualFree(base, size, MEM_DECOMMIT);
}

#else /* !WIN32 */

#ifdef MAP_NORESERVE
/* Implementation of the four basic primitives when MAP_NORESERVE
   is available.  */

PTR
noreserve_reserve (PTR address, size_t size)
{
  PTR result = anon_mmap (address, size, PROT_NONE,
			  MAP_PRIVATE | MAP_NORESERVE);

  return result == MAP_FAILED ? NULL : result;
}

void
noreserve_decommit (PTR base, size_t size)
{
  anon_mmap (base, size, PROT_NONE,
	     MAP_PRIVATE | MAP_NORESERVE | MAP_FIXED);
}
#endif

/* Implementation of the four basic primitives when MAP_NORESERVE
   is not available.  Not foolproof, but we try to keep the balance
   between simplicity and usefulness.  */

static char *baseaddr;

PTR
anon_mmap_reserve (PTR address, size_t size)
{
  PTR base;

  /* We must check for overflows in baseaddr!  Note that we ignore address.  */
  if (((uintptr_t) baseaddr) + size < (uintptr_t) baseaddr)
    {
      errno = ENOMEM;
      return NULL;
    }
  else
    {
      base = baseaddr;
      baseaddr += size;
      return base;
    }
}

void
anon_mmap_release (PTR base, size_t size)
{
  if ((char *) baseaddr == (char *) base + size)
    baseaddr = base;
}

PTR
anon_mmap_commit (PTR base, size_t size)
{
  PTR result = anon_mmap (base, size,
		          PROT_READ | PROT_WRITE | PROT_EXEC,
		          MAP_PRIVATE | MAP_FIXED);

  return UNCOMMON (result == MAP_FAILED) ? NULL : result;
}

/* This is hairy and a hack.  We have to find a place for our heaps...  */

/* This signal handler is used if it is the only means to decide if
   a page is mapped into memory.  We intercept SIGSEGV and decide
   that the heap can be allocated at a given location only if we
   receive a signal.

   We also try access(2) and EFAULT, but it is not ensured that it
   works because the whole EFAULT business is quite unclear; however
   it is worth doing because debugging is way more painful if we
   have SIGSEGV's as part of the normal initialization sequence.  */

static RETSIGTYPE not_mapped (int sig);
static jmp_buf already_mapped;

RETSIGTYPE
not_mapped (sig)
     int sig;
{
  _gst_set_signal_handler (sig, not_mapped);
  longjmp (already_mapped, 1);
}

mst_Boolean
anon_mmap_check (void)
{
  volatile char *mmapGuess, *higher, *lower;	/* reference addresses */
  volatile char *first = NULL, *second;	/* probed addresses */
  volatile const int *step;

  static const int steps[] = {
    true, 256, 256, 0,		/* try 256 Mb after the higher address */
    true, 128, 256, 0,		/* try 128 Mb after the higher address */
    true, 64, 256, 0,		/* try 64 Mb after the higher address */
    false, 256, 256, 512,	/* try 256 Mb after the lower address */
    false, 128, 256, 384,	/* try 128 Mb after the lower address */
    false, 64, 256, 320,	/* try 64 Mb after the lower address */
    true, 32, 256, 0,		/* try 32 Mb after the higher address */
    true, 32, 128, 0,		/* again, for a smaller heap */
    false, 64, 128, 192,	/* this has a smaller heap too */
    -1
  };

  volatile int test, *testPtr = &test;
  volatile SigHandler oldSegvHandler;
  int pagesize = getpagesize();

  if (baseaddr)
    return (true);

  /* Placate GNU C's warnings about clobbered variables */
  testPtr = (volatile int *) &higher;
  testPtr = (volatile int *) &lower;
  testPtr = (volatile int *) &first;
  testPtr = (volatile int *) &step;
  testPtr = (volatile int *) &test;

  /* Install custom signal handlers to detect failed memory accesses */
  oldSegvHandler = _gst_set_signal_handler (SIGSEGV, not_mapped);

  /* Get two reference addresses which we will base ourselves on */
  mmapGuess = higher = _gst_osmem_alloc (pagesize);
  lower = sbrk (0);

  if (higher < lower)
    {
      higher = lower;
      lower = mmapGuess;
    }

  /* Now try each of the possibilities...  */
  for (step = steps; *step > -1; step += 4)
    {
      if (higher > lower + (step[3] << 20))
	{
	  first = ((step[0] ? higher : lower) + (step[1] << 20));
	  second = (first + (step[2] << 20));
	  assert ( ((intptr_t)first & (pagesize-1)) == 0);
	  assert ( ((intptr_t)second & (pagesize-1)) == 0);

	  /* Try reading the two locations */
	  if (setjmp (already_mapped) == 0)
	    {
	      errno = 0;
	      access ((char *) first, F_OK);
	      if (errno != EFAULT)
		{
		  *testPtr = *first;
	          continue;
		}
	    }
	  if (setjmp (already_mapped) == 0)
	    {
	      errno = 0;
	      access ((char *) second, F_OK);
	      if (errno != EFAULT)
		{
		  *testPtr = *second;
	          continue;
		}
	    }

	  /* Try mmap-ing them */
	  if (!anon_mmap_commit ((char *) first, pagesize))
	    continue;

	  _gst_osmem_free ((char *) first, pagesize);
	  if (!anon_mmap_commit ((char *) second, pagesize))
	    continue;

	  /* Were not readable and could be mmap-ed.  We're done.  */
	  _gst_osmem_free ((char *) second, pagesize);
	  break;
	}
    }

  /* Restore things...  */
  _gst_set_signal_handler (SIGSEGV, oldSegvHandler);

  munmap ((char *) mmapGuess, pagesize);

  if (first == NULL || *step == -1)
    return (false);
  else
    {
      baseaddr = (PTR) first;
      return (true);
    }
}
#endif /* !WIN32 */
