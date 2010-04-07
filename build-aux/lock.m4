# lock.m4 serial 8 (gettext-0.18)
dnl Copyright (C) 2005-2009 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl From Bruno Haible.

dnl GST_LOCK
dnl -------
dnl Tests for a multithreading library to be used.
dnl Defines at most one of the macros USE_POSIX_THREADS or USE_WIN32_THREADS.
dnl Sets the variables LIBTHREAD to the linker options for use in a Makefile.
dnl Adds to CPPFLAGS the flag -D_REENTRANT or -D_THREAD_SAFE if needed for
dnl multithread-safe programs.

AC_DEFUN([GST_LOCK],
[
  AC_REQUIRE([AC_CANONICAL_HOST])
  AC_REQUIRE([AC_USE_SYSTEM_EXTENSIONS])

  # Prerequisites of lib-src/lock.c.
  AC_REQUIRE([AC_C_INLINE])

  dnl Check for multithreading.
  AC_ARG_ENABLE(threads,
AC_HELP_STRING([--enable-threads={posix|solaris|win32}], [specify multithreading API])
AC_HELP_STRING([--disable-threads], [build without multithread safety]),
    [gst_use_threads=$enableval],
    [case "$host_os" in
       dnl Disable multithreading by default on OSF/1, because it interferes
       dnl with fork()/exec(): When msgexec is linked with -lpthread, its
       dnl child process gets an endless segmentation fault inside execvp().
       osf*) gst_use_threads=no ;;
       *)    gst_use_threads=yes ;;
     esac])
  if test "$gst_use_threads" = yes || test "$gst_use_threads" = posix; then
    # For using <pthread.h>:
    case "$host_os" in
      osf*)
        # On OSF/1, the compiler needs the flag -D_REENTRANT so that it
        # groks <pthread.h>. cc also understands the flag -pthread, but
        # we don't use it because 1. gcc-2.95 doesn't understand -pthread,
        # 2. putting a flag into CPPFLAGS that has an effect on the linker
        # causes the AC_TRY_LINK test below to succeed unexpectedly,
        # leading to wrong values of LIBTHREAD.
        CPPFLAGS="$CPPFLAGS -D_REENTRANT"
        ;;
    esac
    # Some systems optimize for single-threaded programs by default, and
    # need special flags to disable these optimizations. For example, the
    # definition of 'errno' in <errno.h>.
    case "$host_os" in
      aix* | freebsd*) CPPFLAGS="$CPPFLAGS -D_THREAD_SAFE" ;;
      solaris*) CPPFLAGS="$CPPFLAGS -D_REENTRANT" ;;
    esac
  fi

  gst_threads_api=none
  LIBTHREAD=
  if test "$gst_use_threads" != no; then
    dnl Check whether the compiler and linker support weak declarations.
    AC_CACHE_CHECK([whether imported symbols can be declared weak],
      [gst_cv_have_weak],
      [gst_cv_have_weak=no
       dnl First, test whether the compiler accepts it syntactically.
       AC_TRY_LINK([extern void xyzzy ();
#pragma weak xyzzy], [xyzzy();], [gst_cv_have_weak=maybe])
       if test $gst_cv_have_weak = maybe; then
         dnl Second, test whether it actually works. On Cygwin 1.7.2, with
         dnl gcc 4.3, symbols declared weak always evaluate to the address 0.
         AC_TRY_RUN([
#include <stdio.h>
#pragma weak fputs
int main ()
{
  return (fputs == NULL);
}], [gst_cv_have_weak=yes], [gst_cv_have_weak=no],
           [dnl When cross-compiling, assume that only ELF platforms support
            dnl weak symbols.
            AC_EGREP_CPP([Extensible Linking Format],
              [#ifdef __ELF__
               Extensible Linking Format
               #endif
              ],
              [gst_cv_have_weak="guessing yes"],
              [gst_cv_have_weak="guessing no"])
           ])
       fi
      ])
    if test "$gst_use_threads" = yes || test "$gst_use_threads" = posix; then
      # On OSF/1, the compiler needs the flag -pthread or -D_REENTRANT so that
      # it groks <pthread.h>. It's added above.
      AC_CHECK_HEADER(pthread.h, gst_have_pthread_h=yes, gst_have_pthread_h=no)
      if test "$gst_have_pthread_h" = yes; then
        # Other possible tests:
        #   -lpthreads (FSU threads, PCthreads)
        #   -lgthreads
        gst_have_pthread=
        # Test whether both pthread_mutex_lock and pthread_mutexattr_init exist
        # in libc. IRIX 6.5 has the first one in both libc and libpthread, but
        # the second one only in libpthread, and lock.c needs it.
        AC_TRY_LINK([#include <pthread.h>],
          [pthread_mutex_lock((pthread_mutex_t*)0);
           pthread_mutexattr_init((pthread_mutexattr_t*)0);],
          [gst_have_pthread=yes])
        # Test for libpthread by looking for pthread_kill. (Not pthread_self,
        # since it is defined as a macro on OSF/1.)
        if test -n "$gst_have_pthread"; then
          # The program links fine without libpthread. But it may actually
          # need to link with libpthread in order to create multiple threads.
          AC_CHECK_LIB(pthread, pthread_kill,
            [LIBTHREAD=
             # On Solaris and HP-UX, most pthread functions exist also in libc.
             # Therefore pthread_in_use() needs to actually try to create a
             # thread: pthread_create from libc will fail, whereas
             # pthread_create will actually create a thread.
             case "$host_os" in
               solaris* | hpux*)
                 AC_DEFINE([PTHREAD_IN_USE_DETECTION_HARD], 1,
                   [Define if the pthread_in_use() detection is hard.])
             esac
            ])
        else
          # Some library is needed. Try libpthread and libc_r.
          AC_CHECK_LIB(pthread, pthread_kill,
            [gst_have_pthread=yes
             LIBTHREAD=-lpthread])
          if test -z "$gst_have_pthread"; then
            # For FreeBSD 4.
            AC_CHECK_LIB(c_r, pthread_kill,
              [gst_have_pthread=yes
               LIBTHREAD=-lc_r])
          fi
        fi
        if test -n "$gst_have_pthread"; then
          gst_threads_api=posix
          AC_DEFINE([USE_POSIX_THREADS], 1,
            [Define if the POSIX multithreading library can be used.])
          if test -n "$LIBTHREAD"; then
            if test $gst_have_weak = yes; then
              AC_DEFINE([USE_POSIX_THREADS_WEAK], 1,
                [Define if references to the POSIX multithreading library should be made weak.])
	      LIBTHREAD=
            fi
          fi
          # OSF/1 4.0 and MacOS X 10.1 lack the pthread_rwlock_t type and the
          # pthread_rwlock_* functions.
          AC_CHECK_TYPE([pthread_rwlock_t],
            [AC_DEFINE([HAVE_PTHREAD_RWLOCK], 1,
               [Define if the POSIX multithreading library has read/write locks.])],
            [],
            [#include <pthread.h>])
          # glibc defines PTHREAD_MUTEX_RECURSIVE as enum, not as a macro.
          AC_TRY_COMPILE([#include <pthread.h>],
            [#if __FreeBSD__ == 4
error "No, in FreeBSD 4.0 recursive mutexes actually don't work."
#else
int x = (int)PTHREAD_MUTEX_RECURSIVE;
return !x;
#endif],
            [AC_DEFINE([HAVE_PTHREAD_MUTEX_RECURSIVE], 1,
               [Define if the <pthread.h> defines PTHREAD_MUTEX_RECURSIVE.])])
        fi
      fi
    fi
    if test -z "$gst_have_pthread"; then
      if test "$gst_use_threads" = yes || test "$gst_use_threads" = win32; then
        if { case "$host_os" in
               mingw*) true;;
               *) false;;
             esac
           }; then
          gst_threads_api=win32
          AC_DEFINE([USE_WIN32_THREADS], 1,
            [Define if the Win32 multithreading API can be used.])
        fi
      fi
    fi
  fi
  AC_MSG_CHECKING([for multithread API to use])
  AC_MSG_RESULT([$gst_threads_api])
  AC_SUBST(LIBTHREAD)
])


dnl Survey of platforms:
dnl
dnl Platform          Available   Compiler    Supports   test-lock
dnl                   flavours    option      weak       result
dnl ---------------   ---------   ---------   --------   ---------
dnl Linux 2.4/glibc   posix       -lpthread       Y      OK
dnl
dnl GNU Hurd/glibc    posix
dnl
dnl FreeBSD 5.3       posix       -lc_r           Y
dnl                   posix       -lkse ?         Y
dnl                   posix       -lpthread ?     Y
dnl                   posix       -lthr           Y
dnl
dnl FreeBSD 5.2       posix       -lc_r           Y
dnl                   posix       -lkse           Y
dnl                   posix       -lthr           Y
dnl
dnl FreeBSD 4.0,4.10  posix       -lc_r           Y      OK
dnl
dnl NetBSD 1.6        --
dnl
dnl OpenBSD 3.4       posix       -lpthread       Y      OK
dnl
dnl MacOS X 10.[123]  posix       -lpthread       Y      OK
dnl
dnl Solaris 7,8,9     posix       -lpthread       Y      Sol 7,8: 0.0; Sol 9: OK
dnl                   solaris     -lthread        Y      Sol 7,8: 0.0; Sol 9: OK
dnl
dnl HP-UX 11          posix       -lpthread       N (cc) OK
dnl                                               Y (gcc)
dnl
dnl IRIX 6.5          posix       -lpthread       Y      0.5
dnl
dnl AIX 4.3,5.1       posix       -lpthread       N      AIX 4: 0.5; AIX 5: OK
dnl
dnl OSF/1 4.0,5.1     posix       -pthread (cc)   N      OK
dnl                               -lpthread (gcc) Y
dnl
dnl Cygwin            posix       -lpthread       Y      OK
dnl
dnl Mingw             win32                       N      OK
dnl
dnl BeOS 5            --
dnl
dnl The test-lock result shows what happens if in test-lock.c EXPLICIT_YIELD is
dnl turned off:
dnl   OK if all three tests terminate OK,
dnl   0.5 if the first test terminates OK but the second one loops endlessly,
dnl   0.0 if the first test already loops endlessly.
