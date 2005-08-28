dnl Hey Emacs, I want this in -*- Autoconf -*- mode, please.
dnl ---
dnl Copyright 1992, 1993, 1994, 1995, 1999, 2000, 2001, 2002, 2003, 2005
dnl Free Software Foundation, Inc.
dnl Please see COPYING for a description your rights and responsibilities
dnl with this software.
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ(2.52)
AC_INIT([GNU Smalltalk], 2.1.11, help-smalltalk@gnu.org, smalltalk)
MAINTAINER="bonzini@gnu.org"

dnl CURRENT:REVISION:AGE means this is the REVISION-th version of
dnl the CURRENT-th interface; all the interface from CURRENT-AGE
dnl to CURRENT are supported.
GST_REVISION(4:14:0)
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([main.c])
AM_CONFIG_HEADER(config.h)
AM_INIT_AUTOMAKE
AC_CANONICAL_HOST

RSE_BOLD

dnl 
dnl ------------------------------- PROGRAMS ------------------

{ echo; echo "${term_bold}Build Tools:${term_norm}"; } >& AS_MESSAGE_FD

GST_PROG_CC(strict-aliasing,    				 dnl enabled optimizations
    gcse,               		                         dnl disabled optimizations
    all pointer-arith declaration-after-statement,	         dnl enabled warnings
    strict-aliasing pointer-sign long-double format switch parentheses)       dnl disabled warnings

AC_PROG_AWK
AC_PROG_LN_S
AC_PATH_PROG(INSTALL_INFO, install-info, :, $PATH:/sbin)
AM_PATH_LISPDIR

dnl We only want the GNU implementations
AM_MISSING_PROG(LEX, flex, $missing_dir)
AM_MISSING_PROG(YACC, bison, $missing_dir)

test -z "$RM" && RM='rm -f'
AC_SUBST(RM)

dnl 
dnl ------------------------------ SUBDIRS --------------------

ac_configure_args="$ac_configure_args --enable-subdir"
AC_SNPRINTFV_CONVENIENCE
AC_CONFIG_SUBDIRS(snprintfv)

AC_ARG_ENABLE(generational-gc, 
[  --disable-generational-gc disable generational garbage collection], ,
[case $host in
	*-*-cygwin* | *-*-mingw* | ia64-*-* | x86_64-*-* ) enable_generational_gc=no ;;
	*) enable_generational_gc=yes ;;
esac])
if test $enable_generational_gc != no; then
  AC_CONFIG_SUBDIRS(sigsegv)
  AC_DEFINE_UNQUOTED(HAVE_SIGSEGV_H, 1,
    [Define to 1 if libsigsegv is being used])
fi
AM_CONDITIONAL(HAVE_SIGSEGV, test "$enable_generational_gc" != no)

dnl 
dnl ------------------------------ C COMPILER / OS ------------

{ echo; echo "${term_bold}Platform environment:${term_norm}"; } >& AS_MESSAGE_FD

AC_SYS_LARGEFILE
AC_C_INLINE
AC_C_CONST
AC_C_VOLATILE
ACX_C_RESTRICT
GST_C_WARN_LONG_DOUBLE
GST_C_GOTO_VOID_P
GST_C_SYMBOLSET

GST_LIBC_SO_NAME

AC_LIBTOOL_TAGS
AC_LIBTOOL_DLOPEN
AC_LIBTOOL_WIN32_DLL
AC_PROG_LIBTOOL

AC_C_BIGENDIAN
AC_CHECK_SIZEOF(int)
AC_CHECK_SIZEOF(long)
AC_CHECK_SIZEOF(off_t)
AC_CHECK_SIZEOF(char *, $ac_cv_sizeof_long)
GST_CHECK_ALIGNMENT(double)
GST_CHECK_ALIGNMENT(long double)

case "$gst_cv_machine_defines" in
    *WIN32*)
	ICON=gsticon.o
	;;
    *)
	ICON=
	;;
esac
AC_SUBST(ICON)

dnl 
dnl ------------------------------- C LIBRARY -----------------

{ echo; echo "${term_bold}C library features:${term_norm}"; } >& AS_MESSAGE_FD

AC_TYPE_SIGNAL
AC_TYPE_PID_T
AC_TYPE_SIZE_T

AC_DEFINE(_GNU_SOURCE, 1, [We want the definition of every available function])

AC_HEADER_STDC
AC_HEADER_DIRENT
AC_HEADER_TIME
AC_CHECK_HEADERS(unistd.h poll.h sys/ioctl.h sys/resource.h \
	sys/utsname.h stropts.h sys/param.h stddef.h limits.h \
	sys/timeb.h termios.h sys/mman.h sys/file.h execinfo.h \
	sys/wait.h fcntl.h)

if test x$ac_cv_header_poll_h = xno; then
  AC_CONFIG_LINKS([lib-src/poll.h:lib-src/poll_.h])
fi

AC_FUNC_ALLOCA
AC_FUNC_MEMCMP
AC_FUNC_OBSTACK

AC_CHECK_LIB(m, atan)
GST_REPLACE_POLL
AC_REPLACE_FUNCS(putenv strdup strerror strsignal memmove \
	mkstemp getpagesize getdtablesize dup2 strstr \
	ftruncate floorl ceill sqrtl frexpl ldexpl asinl acosl \
	atanl logl expl tanl sinl cosl)
AC_CHECK_FUNCS(gethostname memcpy sighold uname sbrk usleep \
	grantpt popen getrusage gettimeofday getcwd fork strchr	 \
	sigsetmask alarm select mprotect madvise nl_langinfo waitpid \
	setsid spawnl nanosleep)

GST_FUNC_STRTOUL
GST_FUNC_LOCALTIME

{ echo; echo "${term_bold}Dynamic linking capabilities:${term_norm}"; } >& AS_MESSAGE_FD

AC_LIB_LTDL

dnl ------------------------- OTHER LIBRARIES -------------------

{ echo; echo "${term_bold}Auxiliary libraries:${term_norm}"; } >& AS_MESSAGE_FD

AM_LANGINFO_CODESET
AM_ICONV
GST_HAVE_GMP
GST_HAVE_TCLTK
GST_HAVE_READLINE
GST_INET_SOCKETS

MODULES_EXAMPLE="regex.la"
MODULES_TK=""
MODULES_GTK=""
MODULES_TCP=""
MODULES_I18N=""
I18N_DISABLED="disabled-"
GTK_DISABLED="disabled-"
BLOX_IMPLEMENTATION=BloxTK

AC_SUBST(MODULES_EXAMPLE)
AC_SUBST(MODULES_TCP)
AC_SUBST(MODULES_GTK)
AC_SUBST(MODULES_I18N)
AC_SUBST(MODULES_TK)
AC_SUBST(I18N_DISABLED)
AC_SUBST(GTK_DISABLED)
AC_SUBST(BLOX_IMPLEMENTATION)

AC_CHECK_HEADER(gdbm.h, MODULES_EXAMPLE="$MODULES_EXAMPLE gdbm.la")

AC_ARG_ENABLE(gtk,
[  --disable-gtk           disable GTK+ bindings], ,
enable_gtk=yes)

if test "$enable_gtk" != "no"; then
  enable_gtk=no
  AM_PATH_GLIB_2_0(2.0.0, [
    AM_PATH_GTK_2_0(2.0.0, [
      PKG_CHECK_MODULES(ATK, atk >= 1.0.0, [
        PKG_CHECK_MODULES(PANGO, pango >= 1.0.0, [enable_gtk=yes])
      ])
    ])
  ], [], gobject)
fi


AM_CONDITIONAL(HAVE_GTK, test "$enable_gtk" != no)
test "$enable_gtk" != no && MODULES_GTK="gst-gtk.la" GTK_DISABLED=""
test "$gst_cv_tcltk_libs" != "not found" && MODULES_TK="blox-tk.la"
test "$gst_cv_inet_sockets" != "no" && MODULES_TCP="tcp.la"
test "$ac_cv_func_nl_langinfo" = yes && \
  test "$am_cv_func_iconv" = yes && MODULES_I18N="i18n.la" I18N_DISABLED=""


LIGHTNING_CONFIGURE_IF_NOT_FOUND(jit=yes, jit=no)
AC_ARG_ENABLE(jit, 
[  --enable-jit            enable dynamic translation to machine code], ,
jit=no)

AM_CONDITIONAL(USE_JIT_TRANSLATION, test x$jit = xyes)
if test x$jit = xyes; then
     AC_DEFINE(USE_JIT_TRANSLATION, 1, 
           [Define to enable dynamic translation to machine code])
fi
jit=

AC_ARG_WITH(emacs,
[  --without-emacs         disable Emacs modes for Smalltalk], ,
with_emacs=yes)
AM_CONDITIONAL(WITH_EMACS, test "$with_emacs" != no)

AC_ARG_ENABLE(dld,
[  --disable-dld           disable loading of external modules at runtime], ,
enable_dld=yes)

if test "$enable_dld" != no; then
  AC_DEFINE(ENABLE_DLD, 1,
    [Define to enable usage of libltdl to load external modules at runtime])
fi

AC_ARG_ENABLE(checking,
[  --enable-checking       enable assertions at runtime], ,
enable_checking=no)

if test "$enable_checking" = no; then
  AC_DEFINE(OPTIMIZE, 1,
    [Define to disable assertion checking at runtime])
fi

AC_ARG_ENABLE(preemption,
[  --enable-preemption     enable preemptive multitasking], ,
enable_preemption=no)

if test "$enable_preemption" != no; then
  AC_DEFINE(ENABLE_PREEMPTION, 1,
    [Define to enable preemptive multitasking of Smalltalk processes])
fi

GST_ARG_ENABLE_MODULES([Blox,TCP])

dnl 
dnl ------------------------------- FILE GENERATION -----------

{ echo; echo "${term_bold}Output substitutions:${term_norm}"; } >& AS_MESSAGE_FD

AC_CONFIG_COMMANDS_PRE([
  LTLIBOBJS=`echo "$LIB@&t@OBJS" |
                sed 's,\.[[^.]]* ,.lo ,g;s,\.[[^.]]*$,.lo,'`

  LTALLOCA=`echo "$ALLOCA" | sed 's/\.o/.lo/g'`
])

AC_SUBST(CFLAGS)
AC_SUBST(INCLTDL)
AC_SUBST(LIBLTDL)
AC_SUBST(LDFLAGS)
AC_SUBST(LDPATH)
AC_SUBST(LTALLOCA)
AC_SUBST(LTLIBOBJS)

dnl Scripts & data files
AC_CONFIG_FILES(gnu-smalltalk.spec)
AC_CONFIG_FILES(gst-config, chmod +x gst-config)
AC_CONFIG_FILES(gst-package, chmod +x gst-package)
AC_CONFIG_FILES(libc.la)

dnl Makefiles
AC_CONFIG_FILES(Makefile doc/Makefile lib-src/Makefile libgst/Makefile lightning/Makefile config/Makefile tests/Makefile)

dnl Smalltalk makefiles
AC_CONFIG_FILES(blox-tk/Makefile examples/Makefile i18n/Makefile kernel/Makefile tcp/Makefile gtk/Makefile)

dnl Support VPATH builds off a CVS repository.  When building from
dnl the tarball, a suitable packages.xml file is put in the root source
dnl directory by `make dist'.
AC_CONFIG_COMMANDS($srcdir/packages.xml, [
  if test -f $srcdir/packages.xml; then
    :
  else
    $as_ln_s `pwd`/packages.xml $srcdir/packages.xml
  fi
])

AC_OUTPUT
