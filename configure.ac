dnl Hey Emacs, I want this in -*- Autoconf -*- mode, please.
dnl ---
dnl Copyright 1992,93,94,95,99,2000,2001,2002,2003,2004,2005,2006,2007,2008
dnl Free Software Foundation, Inc.
dnl Please see COPYING for a description your rights and responsibilities
dnl with this software.
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ(2.60)
AC_INIT([GNU Smalltalk], 3.0, help-smalltalk@gnu.org, smalltalk)
MAINTAINER="bonzini@gnu.org"

dnl CURRENT:REVISION:AGE means this is the REVISION-th version of
dnl the CURRENT-th interface; all the interface from CURRENT-AGE
dnl to CURRENT are supported.
GST_REVISION(7:0:0)
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AC_CONFIG_SRCDIR([main.c])
AC_CONFIG_TESTDIR(tests)
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

case "$host" in
  alpha*-*-*) CFLAGS="$CFLAGS -mieee" ;;
esac

AC_PROG_SED
AC_PROG_AWK
AC_PROG_LN_S
GST_PROG_LN
AC_PATH_PROG(INSTALL_INFO, install-info, :, $PATH:/sbin:/usr/sbin)
AC_PATH_PROG(ZIP, zip, no, $PATH)
if test "$ZIP" = no; then
  AC_MSG_ERROR([Please install InfoZIP to use GNU Smalltalk.])
fi

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
AM_MISSING_PROG(AUTOM4TE, autom4te, $missing_dir)

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
        *-*-cygwin* | *-*-mingw* | ia64-*-* ) enable_generational_gc=no ;;
        *) enable_generational_gc=yes ;;
esac])
if test $enable_generational_gc != no; then
  AC_CONFIG_SUBDIRS(sigsegv)
  AC_DEFINE(HAVE_SIGSEGV_H, 1,
    [Define to 1 if libsigsegv is being used])
fi
AM_CONDITIONAL(HAVE_SIGSEGV, test "$enable_generational_gc" != no)

AC_ARG_WITH(imagedir,
[  --with-imagedir=PATH   path where to place the system image
			  (default: /usr/local/var/lib/smalltalk)],
[imagedir="$withval"],
[imagedir=`echo "$libdir" | sed \
		-e 's,${exec_prefix},${localstatedir},' \
		-e "s,${exec_prefix},\${localstatedir}," `/$PACKAGE ])
AC_SUBST(imagedir)

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

AC_DEFINE_UNQUOTED(EXEEXT, "$ac_exeext",
  [Define to the extension for executable files.])

case "$ac_exeext:$host_os" in
  :*) ac_argv_exeext= ;;
  .exe:cygwin*) ac_argv_exeext= ;;
  .exe:*) ac_argv_exeext=$ac_exeext ;;
esac
AC_DEFINE_UNQUOTED(ARGV_EXEEXT, "$ac_argv_exeext",
  [Define to the extension for executable files, as it appears in argv[0].])

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
	sys/timeb.h termios.h sys/mman.h sys/file.h execinfo.h utime.h \
	sys/select.h sys/wait.h fcntl.h, [], [], [AC_INCLUDES_DEFAULT])

AC_CHECK_MEMBERS([struct stat.st_mtim.tv_nsec, struct stat.st_mtimensec,
		  struct stat.st_mtimespec.tv_nsec])

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
gt_FUNC_SETENV
AC_REPLACE_FUNCS(putenv strdup strerror strsignal mkstemp getpagesize \
	getdtablesize strstr ftruncate floorl ceill sqrtl frexpl ldexpl asinl \
	acosl atanl logl expl tanl sinl cosl powl truncl lrintl strsep strpbrk \
	symlink mkdtemp)
AC_CHECK_FUNCS_ONCE(gethostname memcpy memmove sighold uname usleep lstat \
	grantpt popen getrusage gettimeofday fork strchr utimes utime readlink \
	sigsetmask alarm select mprotect madvise waitpid \
	setsid spawnl nanosleep pread pwrite _NSGetExecutablePath)

GST_FUNC_LRINT
GST_FUNC_STRTOUL
GST_FUNC_LOCALTIME

{ echo; echo "${term_bold}Dynamic linking capabilities:${term_norm}"; } >& AS_MESSAGE_FD

AC_LIB_LTDL

dnl ------------------------- OTHER LIBRARIES -------------------

{ echo; echo "${term_bold}Auxiliary libraries:${term_norm}"; } >& AS_MESSAGE_FD

GST_HAVE_GMP
GST_HAVE_READLINE

GST_PACKAGE_PREFIX([packages])
GST_PACKAGE_DEPENDENCIES([gst-tool gst.im])

GST_PACKAGE_ENABLE([BloxTK], [blox/tk],
   [GST_HAVE_TCLTK],
   [gst_cv_tcltk_libs],
   [Makefile], [blox-tk.la])
GST_PACKAGE_ENABLE([Browser], [browser])
GST_PACKAGE_ENABLE([Complex], [complex])
GST_PACKAGE_ENABLE([Continuations], [continuations])
GST_PACKAGE_ENABLE([CParser], [cpp])
GST_PACKAGE_ENABLE([DebugTools], [debug])

GST_PACKAGE_ENABLE([DBD-MySQL], [dbd-mysql])
AC_MSG_CHECKING([whether to run MySQL tests])
AC_ARG_ENABLE(mysql-tests,
[  --enable-mysql-tests=USER:PWD:DATABASE
                          test MySQL bindings [default=root:root:test]], ,
[enable_mysql_tests=no])
AC_SUBST(enable_mysql_tests)
AC_MSG_RESULT($enable_mysql_tests)

GST_PACKAGE_ENABLE([DBD-PostgreSQL], [dbd-postgresql],
   [GST_HAVE_LIB(pq, PQconnectdb)],
   [ac_cv_lib_pq_PQconnectdb])

GST_PACKAGE_ENABLE([DBD-SQLite], [dbd-sqlite],
   [AC_CHECK_HEADER([sqlite3.h])],
   [ac_cv_header_sqlite3_h],
   [Makefile], [dbd-sqlite3.la])

GST_PACKAGE_ENABLE([DBI], [dbi])

GST_PACKAGE_ENABLE([GDBM], [gdbm],
   [AC_CHECK_HEADER([gdbm.h])],
   [ac_cv_header_gdbm_h],
   [Makefile], [gdbm.la])
GST_PACKAGE_ENABLE([Glorp], [glorp])
GST_PACKAGE_ENABLE([GTK], [gtk], [
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
  fi],
  [enable_gtk],
  [Makefile], [gst-gtk.la])
GST_PACKAGE_ENABLE([BloxGTK], [blox/gtk],, [enable_gtk])
GST_PACKAGE_ENABLE([Blox], [blox/tests],
	    [enable_blox=no
	     case x"$enable_gtk" in
		 xno|xnot\ found) ;; *) enable_blox=yes ;; esac
	     case x"$gst_cv_tcltk_libs" in
		 xno|xnot\ found) ;; *) enable_blox=yes ;; esac], 
	    [enable_blox], [package.xml])
GST_PACKAGE_ENABLE([WebServer], [httpd])
GST_PACKAGE_ENABLE([I18N], [i18n],
  [AC_CHECK_FUNCS_ONCE([nl_langinfo])
  AM_LANGINFO_CODESET
  AM_ICONV],
  [ac_cv_func_nl_langinfo am_cv_func_iconv],
  [Makefile], [i18n.la])
GST_PACKAGE_ENABLE([Iconv], [iconv],
  [AM_ICONV],
  [am_cv_func_iconv],
  [Makefile], [iconv.la])
GST_PACKAGE_ENABLE([Java], [java])
GST_PACKAGE_ENABLE([Digest], [digest], [], [], [Makefile], [digest.la])
GST_PACKAGE_ENABLE([GNUPlot], [gnuplot])

GST_PACKAGE_ENABLE([NCurses],
  [ncurses],
  [GST_HAVE_LIB(ncurses, initscr)],
  [ac_cv_lib_ncurses_initscr])
GST_PACKAGE_ENABLE([NetClients], [net])
GST_PACKAGE_ENABLE([DhbNumericalMethods], [numerics])
GST_PACKAGE_ENABLE([Compiler], [stinst/compiler])
GST_PACKAGE_ENABLE([Parser], [stinst/parser])
GST_PACKAGE_ENABLE([ClassPublisher], [stinst/doc])
GST_PACKAGE_ENABLE([ROE], [roe])
GST_PACKAGE_ENABLE([Sport], [sport])
GST_PACKAGE_ENABLE([SUnit], [sunit])
GST_PACKAGE_ENABLE([Swazoo], [swazoo-httpd])
GST_PACKAGE_ENABLE([TCP], [tcp],
  [GST_INET_SOCKETS],
  [gst_cv_inet_sockets],
  [Makefile], [tcp.la])
GST_PACKAGE_ENABLE([VFSAddOns], [vfs], [], [], [Makefile])
GST_PACKAGE_ENABLE([XML-XMLNodeBuilder], [xml/builder])
GST_PACKAGE_ENABLE([XML-DOM], [xml/dom])
GST_PACKAGE_ENABLE([XML-XMLParser], [xml/parser])
GST_PACKAGE_ENABLE([XML-SAXDriver], [xml/saxdriver])
GST_PACKAGE_ENABLE([XML-SAXParser], [xml/saxparser])
GST_PACKAGE_ENABLE([XPath], [xml/xpath])
GST_PACKAGE_ENABLE([XSL], [xml/xsl])
GST_PACKAGE_ENABLE([ZLib],
  [zlib],
  [AC_CHECK_HEADER([zlib.h])],
  [ac_cv_header_zlib_h],
  [Makefile], [zlib.la])

if test "$enable_gtk" = blox; then
  BLOX_IMPLEMENTATION=BloxGTK
else
  BLOX_IMPLEMENTATION=BloxTK
fi
AC_SUBST(BLOX_IMPLEMENTATION)

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
AC_CONFIG_FILES(tests/gst, chmod +x tests/gst)
AC_CONFIG_FILES(tests/atlocal)
AC_CONFIG_FILES(libc.la)

dnl Master Makefile
AC_CONFIG_FILES(Makefile)

dnl VM makefiles
AC_CONFIG_FILES(doc/Makefile lib-src/Makefile libgst/Makefile)
AC_CONFIG_FILES(opcode/Makefile lightning/Makefile tests/Makefile)

AC_OUTPUT
