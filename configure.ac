dnl Hey Emacs, I want this in -*- Autoconf -*- mode, please.
dnl ---
dnl Copyright 1992,1993,1994,1995,1999,2000,2001,2002,2003,2004,2005,2006
dnl Free Software Foundation, Inc.
dnl Please see COPYING for a description your rights and responsibilities
dnl with this software.
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ(2.60)
AC_INIT([GNU Smalltalk], 2.3.1, help-smalltalk@gnu.org, smalltalk)
MAINTAINER="bonzini@gnu.org"

dnl CURRENT:REVISION:AGE means this is the REVISION-th version of
dnl the CURRENT-th interface; all the interface from CURRENT-AGE
dnl to CURRENT are supported.
GST_REVISION(6:1:2)
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AC_CONFIG_SRCDIR([main.c])
AM_CONFIG_HEADER(config.h)
AM_INIT_AUTOMAKE
AC_CANONICAL_HOST

RSE_BOLD

dnl 
dnl ------------------------------- PROGRAMS ------------------

{ echo; echo "${term_bold}Build Tools:${term_norm}"; } >& AS_MESSAGE_FD

GST_PROG_CC(strict-aliasing,	   	 		           dnl enabled optimizations
    gcse,                               	                   dnl disabled optimizations
    all write-strings pointer-arith declaration-after-statement,   dnl enabled warnings
    strict-aliasing pointer-sign long-double format switch)	   dnl disabled warnings

if test "$GCC" != yes; then
  AC_MSG_ERROR([Please use GCC to compile GNU Smalltalk.])
fi

AC_PROG_SED
AC_PROG_AWK
AC_PROG_LN_S
GST_PROG_LN
AC_PATH_PROG(INSTALL_INFO, install-info, :, $PATH:/sbin)

AC_ARG_WITH(emacs, 
[  --without-emacs         disable Emacs modes for Smalltalk], ,
with_emacs=yes)
test "$with_emacs" = no && EMACS=no

AM_PATH_LISPDIR
GST_EMACS_PACKAGE(comint)

AM_CONDITIONAL(WITH_EMACS, test "$EMACS" != no)
AM_CONDITIONAL(WITH_EMACS_COMINT, test "$ac_cv_emacs_comint" != no)

dnl We only want the GNU implementations
AM_MISSING_PROG(LEX, flex, $missing_dir)
AM_MISSING_PROG(YACC, bison, $missing_dir)
AM_MISSING_PROG(GPERF, gperf, $missing_dir)

dnl 
dnl ------------------------------ SUBDIRS --------------------

AC_CONFIG_SUBDIRS(libffi)

case $ac_configure_args in
  *--enable-subdir) ;;
  *) ac_configure_args="$ac_configure_args --enable-subdir" ;;
esac
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
  AC_DEFINE(HAVE_SIGSEGV_H, 1,
    [Define to 1 if libsigsegv is being used])
fi
AM_CONDITIONAL(HAVE_SIGSEGV, test "$enable_generational_gc" != no)

dnl 
dnl ------------------------------ C COMPILER / OS ------------

{ echo; echo "${term_bold}Platform environment:${term_norm}"; } >& AS_MESSAGE_FD

AC_SYS_LARGEFILE
AC_C_INLINE
AC_C_RESTRICT

dnl Test for broken solaris include file.  Should be moved to gnulib maybe?
AC_MSG_CHECKING([for broken sys/avl.h])
AC_PREPROC_IFELSE([#include <sys/avl.h>
  #ifndef _AVL_H
  would be useless anyway :-(
  #endif], [
  AC_MSG_RESULT(yes)
  AC_DEFINE(_AVL_H, 1,
    [Define to 1 if, like Solaris, your system has a sys/avl.h header that
pollutes the name space.])], [
  AC_MSG_RESULT(no)])

GST_C_HIDDEN_VISIBILITY
GST_C_WARN_LONG_DOUBLE
GST_C_GOTO_VOID_P

AC_DEFINE_UNQUOTED(HOST_SYSTEM, "$host",
  [Define to the host triplet.])

AC_C_BIGENDIAN
AC_CHECK_ALIGNOF(double)
AC_CHECK_ALIGNOF(long double)
AC_CHECK_SIZEOF(off_t)
AC_CHECK_SIZEOF(OOP, , [[
typedef void *OOP;]])

GST_LIBC_SO_NAME

AC_LIBTOOL_TAGS
AC_LIBTOOL_DLOPEN
AC_LIBTOOL_WIN32_DLL
AC_PROG_LIBTOOL

# We define two tags for LIBTOOL, one of which is special
# for libgst.

save_enable_shared=$enable_shared
GST_LIBTOOL_TAG(LIBGST, CC, [
  case "$host_cpu:$GCC:`$CC -v 2>&1 | sed -n '[s/^gcc version \([0-9.]*\).*/\1/p]'`" in
   *:no:*)
     enable_shared=no ;;

   # Old versions of GCC do not support the visibility attribute,
   # and we need it otherwise the library is dead slow.
   [*:*:[12].*])
     enable_shared=no ;;

   [*:*:3.[012]*])
     enable_shared=no ;;

   i*86:yes:*)
     # For the x86, building a shared library with the frame pointer
     # is too slow.  On the other hand, most people will find a static
     # library without it undebuggable, which is a problem with respeect
     # to bug reports.  For this reason, we hack libtool to allow
     # additional flags to be specified for the PIC case.
     _LT_AC_TAGVAR(lt_prog_compiler_pic, LIBGST)="dnl
$lt_prog_compiler_pic -fomit-frame-pointer" ;;

   *) ;;
  esac
])
enable_shared=$save_enable_shared

case "$host_os" in
  cygwin*|mingw*) ICON=gsticon.o ;;
  *) ICON= ;;
esac
AC_SUBST(ICON)

dnl 
dnl ------------------------------- C LIBRARY -----------------

{ echo; echo "${term_bold}C library features:${term_norm}"; } >& AS_MESSAGE_FD

AC_TYPE_SIGNAL
AC_TYPE_PID_T
AC_TYPE_SIZE_T

AC_DEFINE(_GNU_SOURCE, 1, [We want the definition of every available function])

AC_HEADER_ASSERT
AC_CHECK_HEADERS_ONCE(stdint.h inttypes.h unistd.h poll.h sys/ioctl.h \
	sys/resource.h sys/utsname.h stropts.h sys/param.h stddef.h limits.h \
	sys/timeb.h termios.h sys/mman.h sys/file.h execinfo.h \
	sys/wait.h fcntl.h, [], [], [AC_INCLUDES_DEFAULT])

AC_TYPE_INT8_T
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT64_T
AC_TYPE_INTMAX_T
AC_TYPE_INTPTR_T
AC_TYPE_UINT8_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T
AC_TYPE_UINTMAX_T
AC_TYPE_UINTPTR_T

if test x$ac_cv_header_poll_h = xno; then
  AC_CONFIG_LINKS([lib-src/poll.h:lib-src/poll_.h])
fi

AC_FUNC_ALLOCA
AC_FUNC_OBSTACK

AC_CHECK_LIB(m, atan)
GST_REPLACE_POLL
AC_REPLACE_FUNCS(putenv strdup strerror strsignal mkstemp getpagesize \
	getdtablesize strstr ftruncate floorl ceill sqrtl frexpl ldexpl asinl \
	acosl atanl logl expl tanl sinl cosl truncl strsep strpbrk)
AC_CHECK_FUNCS_ONCE(gethostname memcpy memmove sighold uname sbrk usleep lstat \
	grantpt popen getrusage gettimeofday getcwd fork strchr	\
	sigsetmask alarm select mprotect madvise nl_langinfo waitpid \
	setsid spawnl nanosleep pread pwrite)

GST_FUNC_STRTOUL
GST_FUNC_LOCALTIME

{ echo; echo "${term_bold}Dynamic linking capabilities:${term_norm}"; } >& AS_MESSAGE_FD

AC_LIB_LTDL

dnl ------------------------- OTHER LIBRARIES -------------------

{ echo; echo "${term_bold}Auxiliary libraries:${term_norm}"; } >& AS_MESSAGE_FD

AM_LANGINFO_CODESET
AM_ICONV
GST_HAVE_LIB(ncurses, initscr)
GST_HAVE_GMP
GST_HAVE_TCLTK
GST_HAVE_READLINE
GST_INET_SOCKETS

MODULES_EXAMPLE=""
MODULES_TK=""
MODULES_GTK=""
MODULES_TCP=""
MODULES_I18N=""
BLOX_IMPLEMENTATION=BloxTK
NCURSES_DISABLED="disabled-"
I18N_DISABLED="disabled-"
GTK_DISABLED="disabled-"

AC_SUBST(MODULES_EXAMPLE)
AC_SUBST(MODULES_TCP)
AC_SUBST(MODULES_GTK)
AC_SUBST(MODULES_I18N)
AC_SUBST(MODULES_TK)
AC_SUBST(BLOX_IMPLEMENTATION)
AC_SUBST(GTK_DISABLED)
AC_SUBST(I18N_DISABLED)
AC_SUBST(NCURSES_DISABLED)

AC_CHECK_HEADER(gdbm.h, MODULES_EXAMPLE="$MODULES_EXAMPLE gdbm.la")

AC_ARG_ENABLE(gtk,
[  --enable-gtk={yes,no,blox}
                          enable GTK+ bindings.  Blox/GTK is experimental.], ,
enable_gtk=yes)

if test "$enable_gtk" != no; then
  maybe_enable_gtk=$enable_gtk
  enable_gtk=no
  AM_PATH_GLIB_2_0(2.0.0, [
    AM_PATH_GTK_2_0(2.0.0, [
      PKG_CHECK_MODULES(ATK, atk >= 1.0.0, [
        PKG_CHECK_MODULES(PANGO, pango >= 1.0.0, [enable_gtk=$maybe_enable_gtk])
      ])
    ])
  ], [], gobject)
fi
 
AM_CONDITIONAL(HAVE_GTK, test "$enable_gtk" != no)
test "$enable_gtk" != no && MODULES_GTK="gst-gtk.la" GTK_DISABLED=""
test "$enable_gtk" = blox && BLOX_IMPLEMENTATION=BloxGTK
test "$gst_cv_tcltk_libs" != "not found" && MODULES_TK="blox-tk.la"
test "$gst_cv_inet_sockets" != "no" && MODULES_TCP="tcp.la"
test "$ac_cv_lib_ncurses_initscr" = yes && NCURSES_DISABLED=""
test "$ac_cv_func_nl_langinfo" = yes && \
  test "$am_cv_func_iconv" = yes && MODULES_I18N="i18n.la" I18N_DISABLED=""

AC_ARG_ENABLE(jit, 
[  --enable-jit            enable dynamic translation to machine code], ,
enable_jit=no)

LIGHTNING_CONFIGURE_IF_NOT_FOUND([], enable_jit=no)
if test "$enable_jit" != no; then
  AC_DEFINE(ENABLE_JIT_TRANSLATION, 1, 
    [Define to enable dynamic translation to machine code])
fi

AC_ARG_ENABLE(disassembler, 
[  --enable-disassembler   include a disassembler in the gst executable], ,
enable_disassembler=no)
AM_CONDITIONAL(ENABLE_DISASSEMBLER, test "$enable_disassembler" != no)
if test "$enable_disassembler" != no; then
  AC_DEFINE(ENABLE_DISASSEMBLER, 1, 
    [Define to include a disassembler in the gst executable])
fi

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

GST_RUN='$(top_builddir)/gst -I $(top_builddir)/gst.im -f'

AC_SUBST(GST_RUN)
AC_SUBST(CFLAGS)
AC_SUBST(INCLTDL)
AC_SUBST(LIBLTDL)
AC_SUBST(LTALLOCA)
AC_SUBST(LTLIBOBJS)

dnl Scripts & data files
AC_CONFIG_FILES(gnu-smalltalk.pc)
AC_CONFIG_FILES(gst-config, chmod +x gst-config)
AC_CONFIG_FILES(gst-package, chmod +x gst-package)
AC_CONFIG_FILES(packages.xml)
AC_CONFIG_FILES(libc.la)

dnl Master Makefile
AC_CONFIG_FILES(Makefile, [
  echo 'Makefile: packages.xml' >> Makefile
  for i in blox-tk:BloxTK tcp:TCP i18n:I18N kernel:Kernel; do
    package=`echo $i | sed s/.*://`
    dir=`echo $i | sed s/:.*//`

    echo
    echo "all-local: \$(top_srcdir)/$dir/stamp-classes"
    echo "\$(top_srcdir)/$dir/stamp-classes: \\"

    ./gst-package --list-files $package packages.xml | \
      sed -n 's,.*\.st$,& \\,p'

    echo
    echo "	echo timestamp > \$(top_srcdir)/$dir/stamp-classes"
  done >> Makefile
])

dnl VM makefiles
AC_CONFIG_FILES(doc/Makefile lib-src/Makefile libgst/Makefile)
AC_CONFIG_FILES(opcode/Makefile lightning/Makefile tests/Makefile)

dnl Modules makefiles
AC_CONFIG_FILES(blox-tk/Makefile examples/Makefile)
AC_CONFIG_FILES(i18n/Makefile tcp/Makefile)
AC_CONFIG_FILES(gtk/Makefile)

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
