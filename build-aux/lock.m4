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

  gst_threads_api=none
  LIBTHREAD=

  dnl Check for multithreading.
  # Some systems optimize for single-threaded programs by default, and
  # need special flags to disable these optimizations. For example, the
  # definition of 'errno' in <errno.h>.
  # On OSF/1, the compiler needs the flag -D_REENTRANT so that it
  # groks <pthread.h>. cc also understands the flag -pthread, but
  # we don't use it because 1. gcc-2.95 doesn't understand -pthread,
  # 2. putting a flag into CPPFLAGS that has an effect on the linker
  # causes the AC_TRY_LINK test below to succeed unexpectedly,
  # leading to wrong values of LIBTHREAD.
  # On Solaris and HP-UX, most pthread functions exist also in libc.
  # However, pthread_create from libc will fail.
  case "$host_os" in
    osf*) CPPFLAGS="$CPPFLAGS -D_REENTRANT" ;;
    aix*) CPPFLAGS="$CPPFLAGS -D_THREAD_SAFE" ;;
    freebsd*) CPPFLAGS="$CPPFLAGS -D_THREAD_SAFE" LIBTHREAD=-pthread ;;
    solaris*) CPPFLAGS="$CPPFLAGS -D_REENTRANT" LIBTHREAD=-lpthread ;;
    hpux*) LIBTHREAD=-lpthread ;;
  esac

  AC_CHECK_HEADER(pthread.h, gst_have_pthread_h=yes, gst_have_pthread_h=no)

  if { case "$host_os" in
         mingw*) true;;
         *) false;;
       esac
     }; then
    gst_threads_api=win32
    AC_DEFINE([USE_WIN32_THREADS], 1,
      [Define if the Win32 multithreading API can be used.])
  elif test "$gst_have_pthread_h" = yes; then
    # Test whether both pthread_mutex_lock and pthread_mutexattr_init exist
    # in libc. IRIX 6.5 has the first one in both libc and libpthread, but
    # the second one only in libpthread.  FreeBSD has libc_r.
    gst_save_CFLAGS=$CFLAGS
    gst_save_LIBS=$LIBS
    CFLAGS="$CFLAGS $LIBTHREAD"
    gst_have_pthread=yes
    AC_SEARCH_LIBS([pthread_mutexattr_init], [pthread pthreads c_r], ,
      [gst_have_pthread=no])
    AC_SEARCH_LIBS([pthread_mutex_lock], [pthread pthreads c_r], ,
      [gst_have_pthread=no])
    CFLAGS=$gst_save_CFLAGS
    LIBS=$gst_save_LIBS
    if test "$gst_have_pthread" = yes; then
      if test "$ac_cv_search_pthread_mutex_lock" != "none required"; then
        LIBTHREAD="$LIBTHREAD $ac_cv_search_pthread_mutex_lock"
      fi
      gst_threads_api=posix
      AC_DEFINE([USE_POSIX_THREADS], 1,
        [Define if the POSIX multithreading library can be used.])
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
