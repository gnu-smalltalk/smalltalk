dnl Hey Emacs, I want this in -*- Autoconf -*- mode, please.
dnl ---
dnl Copyright 1992-2009 Free Software Foundation, Inc.
dnl Please see COPYING for a description your rights and responsibilities
dnl with this software.
dnl Process this file with autoconf to produce a configure script.

dnl 2.63 needed by testsuite, actually
AC_PREREQ(2.63)
AC_INIT([GNU Smalltalk], 3.2.90, help-smalltalk@gnu.org, smalltalk,
        [http://smalltalk.gnu.org/])
MAINTAINER="bonzini@gnu.org"

dnl CURRENT:REVISION:AGE means this is the REVISION-th version of
dnl the CURRENT-th interface; all the interface from CURRENT-AGE
dnl to CURRENT are supported.
GST_REVISION(8:3:1)
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AC_CONFIG_SRCDIR([main.c])
AC_CONFIG_TESTDIR(tests)
AC_CONFIG_HEADERS([config.h])
GST_PROG_GAWK
AM_INIT_AUTOMAKE
AC_CANONICAL_HOST

if test -d $srcdir/.git; then
  GIT_REVISION=-`git rev-parse --short HEAD 2>/dev/null || echo git`
else	
  GIT_REVISION=
fi
AC_DEFINE_UNQUOTED([PACKAGE_GIT_REVISION], ["$GIT_REVISION"],
		   [The git version that GNU Smalltalk was compiled from.])


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

# We don't require Automake 1.10, so invoke _AM_DEPENDENCIES manually.  And
# since we actually use Objective-C only on Mac OS (for libsdl), for now we
# get by with using gcc as an Objective-C compiler.
AC_SUBST(OBJC, [$CC])
AC_SUBST(OBJCFLAGS, [$CFLAGS])
_AM_DEPENDENCIES(OBJC)

AC_PROG_SED
AC_PROG_LN_S
GST_PROG_LN
PKG_PROG_PKG_CONFIG
AC_PATH_TOOL(WINDRES, windres, no)
AC_PATH_PROG(INSTALL_INFO, install-info, :, $PATH:/sbin:/usr/sbin)
AC_PATH_PROG(ZIP, zip, no, $PATH)
AC_CHECK_PROG(TIMEOUT, timeout, [timeout 600s], [env])
if test "$ZIP" = no; then
  AC_MSG_ERROR([Please install InfoZIP to use GNU Smalltalk.])
fi

# For Wine, compile in GST a generic path to zip.exe.  For build time,
# wrap the native zip with winewrapper to hide Windows paths from it.
GST_WINE_IF([WINEWRAPPERDEP='winewrapper$(EXEEXT)'
	     WINEWRAPPER='$(abs_top_builddir)/winewrapper$(EXEEXT)'
	     XZIP='$(WINEWRAPPER) '$ZIP
	     ZIP=zip.exe,
             AC_CONFIG_FILES([makesetup], [chmod +x makesetup])],
	    [WINEWRAPPER=
	     WINEWRAPPERDEP=
	     XZIP=$ZIP])
AC_SUBST([WINEWRAPPER])
AC_SUBST([WINEWRAPPERDEP])
AC_SUBST([XZIP])

AC_ARG_WITH(emacs, 
[  --without-emacs         disable Emacs modes for Smalltalk], ,
with_emacs=yes)
test "$with_emacs" = no && EMACS=no

AM_PATH_LISPDIR
GST_PATH_LISPSTARTDIR
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

PKG_CHECK_MODULES(GNUTLS, gnutls,
                  [ac_cv_lib_gnutls_gnutls_global_init=yes],
                  [GST_HAVE_LIB(gnutls, gnutls_global_init)])
if test "$ac_cv_lib_gnutls_gnutls_global_init" = yes; then
  AC_DEFINE(HAVE_GNUTLS, 1, [Define to 1 if gnutls is being used])
fi

AC_ARG_WITH(system-libltdl,
[  --with-system-libltdl[=PATH]  use system libltdl.la (search in PATH if given)],
[], [with_system_libltdl=detect])

GST_HAVE_LIB([ltdl], [lt_dlopen])
case $with_system_libltdl in
  yes|no|detect)
    if test $ac_cv_lib_ltdl_lt_dlopen = no; then
      AC_MSG_ERROR([libltdl is required to compile GNU Smalltalk])
    elif test $with_system_libltdl = no; then
      AC_MSG_WARN([libltdl is required to compile GNU Smalltalk])
      AC_MSG_WARN([ignoring --without-system-libltdl])
    fi
    INCLTDL= LIBLTDL=-lltdl
    ;;
  *)
    INCLTDL="-I$with_system_libltdl/../include"
    LIBLTDL="-L$with_system_libltdl -lltdl"
esac
AC_SUBST(INCLTDL)
AC_SUBST(LIBLTDL)

AC_ARG_WITH(system-libffi,
[  --with-system-libffi[=PATH]   use system libffi.la (search in PATH if given)],
[], [with_system_libffi=detect])

PKG_CHECK_MODULES(LIBFFI, libffi,
                  [ac_cv_lib_libffi_ffi_prep_cif=yes],
                  [GST_HAVE_LIB(libffi, ffi_prep_cif)])
case $with_system_libffi in
  yes|no|detect)
    if test $ac_cv_lib_libffi_ffi_prep_cif = no; then
      AC_MSG_ERROR([libffi is required to compile GNU Smalltalk])
    elif test $with_system_libffi = no; then
      AC_MSG_WARN([libffi is required to compile GNU Smalltalk])
      AC_MSG_WARN([ignoring --without-system-libffi])
    fi
    INCFFI=$LIBFFI_CFLAGS
    LIBFFI=${LIBFFI_LIBS:-'-lffi'}
    ;;
  *)
    INCFFI="-I$with_system_libffi/../include"
    LIBFFI="-L$with_system_libffi -lffi"
esac
case $host in
  *-*-darwin[[912]]* ) LIBFFI_EXECUTABLE_LDFLAGS=-Wl,-allow_stack_execute ;;
  *) LIBFFI_EXECUTABLE_LDFLAGS= ;;
esac
AC_SUBST(INCFFI)
AC_SUBST(LIBFFI)
AC_SUBST(LIBFFI_EXECUTABLE_LDFLAGS)

case $ac_configure_args in
  *--enable-subdir) ;;
  *) ac_configure_args="$ac_configure_args --enable-subdir" ;;
esac
AC_SNPRINTFV_CONVENIENCE
AC_CONFIG_SUBDIRS(snprintfv)

AC_ARG_ENABLE(generational-gc,
[  --disable-generational-gc disable generational garbage collection], ,
[case $host in
	*-k*bsd-gnu | \
        *-*-cygwin* | *-*-mingw* | \
	ia64-*-* | alpha*-*-* | sparc*-*-* )
	  enable_generational_gc=no ;;
        *)
	  enable_generational_gc=yes ;;
esac])

AC_ARG_WITH(system-libsigsegv,
[  --with-system-libsigsegv[=PATH]   use system libsigsegv.la likewise],
[], [with_system_libsigsegv=detect])

GST_HAVE_LIB([sigsegv], [sigsegv_install_handler])
if test $enable_generational_gc = no; then
  INCSIGSEGV= LIBSIGSEGV=
else
  case $with_system_libsigsegv in
    yes|no|detect)
      if test $ac_cv_lib_sigsegv_sigsegv_install_handler = no; then
        AC_MSG_ERROR([libsigsegv is required by default to compile GNU Smalltalk.
To proceed, configure with --disable-generational-gc.])
      elif test $with_system_libsigsegv = no; then
        AC_MSG_WARN([libsigsegv is required by default to compile GNU Smalltalk.])
        AC_MSG_WARN([You specified --without-system-libsigsegv, but it will be])
        AC_MSG_WARN([ignored; if you wanted to avoid using libsigsegv altogether])
        AC_MSG_WARN([you should use --disable-generational-gc instead.])
      fi
      INCSIGSEGV= LIBSIGSEGV=-lsigsegv
      ;;
    *)
      INCSIGSEGV="-I$with_system_libsigsegv/../include"
      LIBSIGSEGV="-L$with_system_libsigsegv -lsigsegv"
  esac
  AC_DEFINE(HAVE_SIGSEGV_H, 1, [Define to 1 if libsigsegv is being used])
fi
AC_SUBST(INCSIGSEGV)
AC_SUBST(LIBSIGSEGV)

AC_ARG_WITH(imagedir,
[  --with-imagedir=PATH   path where to place the system image
			  (default: /usr/local/var/lib/$PACKAGE)],
[imagedir="$withval"],
[imagedir=`echo "$libdir" | sed \
		-e 's,${exec_prefix},${localstatedir},' \
		-e "s,${exec_prefix},\${localstatedir}," `/$PACKAGE ])
AC_SUBST(imagedir)

AC_ARG_WITH(moduledir,
[  --with-moduledir=PATH  path where to look for modules
			  (default: /usr/local/lib/$PACKAGE)],
[moduledir="$withval"],
[moduledir='${pkglibdir}'])
moduleexecdir='${moduledir}'
AC_SUBST(moduledir)
AC_SUBST(moduleexecdir)

dnl 
dnl ------------------------------ C COMPILER / OS ------------

{ echo; echo "${term_bold}Platform environment:${term_norm}"; } >& AS_MESSAGE_FD

GST_C_SYNC_BUILTINS
if test $gst_cv_have_sync_fetch_and_add = no; then
  AC_MSG_ERROR([Synchronization primitives not found, please use a newer compiler.])
fi

GST_LOCK
AC_SYS_LARGEFILE
AC_C_INLINE
AC_C_RESTRICT

dnl Test for broken solaris include file.  Should be moved to gnulib maybe?
AC_MSG_CHECKING([for broken sys/avl.h])
AC_PREPROC_IFELSE([AC_LANG_SOURCE([#include <sys/avl.h>
  #ifndef _AVL_H
  would be useless anyway
  #endif
])], [
  AC_MSG_RESULT(yes)
  AC_DEFINE(_AVL_H, 1,
    [Define to 1 if, like Solaris, your system has a sys/avl.h header that
pollutes the name space.])], [
  AC_MSG_RESULT(no)])

GST_C_HIDDEN_VISIBILITY
GST_C_LONG_DOUBLE
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
AC_CHECK_ALIGNOF(long long)
AC_CHECK_SIZEOF(off_t)
AC_CHECK_SIZEOF(int)
AC_CHECK_SIZEOF(long)
AC_CHECK_SIZEOF(wchar_t, , [[
#include <wchar.h>]])
AC_CHECK_SIZEOF(OOP, , [[
typedef void *OOP;]])

AC_LIBTOOL_DLOPEN
AC_LIBTOOL_WIN32_DLL
AC_PROG_LIBTOOL

LIBGST_CFLAGS="$SYNC_CFLAGS"
case '$host_cpu: $CFLAGS ' in
   i*86:*' -pg '*) ;;
   i*86:*) LIBGST_CFLAGS="$LIBGST_CFLAGS -fomit-frame-pointer" ;;
   *) ;;
esac
AC_SUBST(LIBGST_CFLAGS)

case "$host_os:$WINDRES" in
  *:no) ICON= ;;
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

AC_HEADER_ASSERT
AC_CHECK_HEADERS_ONCE(stdint.h inttypes.h unistd.h poll.h sys/ioctl.h \
	sys/resource.h sys/utsname.h stropts.h sys/param.h stddef.h limits.h \
	sys/timeb.h termios.h sys/mman.h sys/file.h execinfo.h utime.h \
	sys/select.h sys/wait.h fcntl.h crt_externs.h, [], [], [AC_INCLUDES_DEFAULT])

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
GST_SOCKETS
AC_REPLACE_FUNCS(putenv strdup strerror strsignal mkstemp getpagesize \
	getdtablesize strstr ftruncate floorl ceill sqrtl frexpl ldexpl asinl \
	acosl atanl logl expl tanl sinl cosl powl truncl lrintl truncf lrintf \
        lrint trunc strsep strpbrk symlink mkdtemp)
AC_CHECK_FUNCS_ONCE(gethostname memcpy memmove sighold uname usleep lstat \
	grantpt popen getrusage gettimeofday fork strchr utimes utime readlink \
	sigsetmask alarm select mprotect madvise waitpid accept4 \
	setsid spawnl pread pwrite _NSGetExecutablePath _NSGetEnviron \
	chown getgrnam getpwnam endgrent endpwent setgroupent setpassent)

if test "$ac_cv_func__NSGetEnviron" = yes; then
  AC_DEFINE([environ], [_NSGetEnviron()],
    [Define to an appropriate function call if the system does not provide the
     environ variable.])
fi

AC_SEARCH_LIBS([nanosleep], [rt])
if test "$ac_cv_search_nanosleep" != no; then
  AC_DEFINE(HAVE_NANOSLEEP, 1, 
    [Define if the system provides nanosleep.])
fi

AC_SEARCH_LIBS([clock_gettime], [rt])
if test "$ac_cv_search_clock_gettime" != no; then
  AC_DEFINE(HAVE_CLOCK_GETTIME, 1, 
    [Define if the system provides clock_gettime.])
fi

AC_SEARCH_LIBS([timer_create], [rt])
if test "$ac_cv_search_timer_create" != no; then
  AC_DEFINE(HAVE_TIMER_CREATE, 1, 
    [Define if the system provides timer_create.])
fi

GST_FUNC_LRINT
GST_FUNC_STRTOUL
GST_FUNC_LOCALTIME

{ echo; echo "${term_bold}Dynamic linking capabilities:${term_norm}"; } >& AS_MESSAGE_FD

GST_LIB_LTDL

dnl ------------------------- OTHER LIBRARIES -------------------

{ echo; echo "${term_bold}Auxiliary libraries:${term_norm}"; } >& AS_MESSAGE_FD

GST_LIBC_SO_NAME
GST_HAVE_GMP
GST_HAVE_READLINE

GST_PACKAGE_ALLOW_DISABLING
GST_PACKAGE_PREFIX([packages])
GST_PACKAGE_DEPENDENCIES([gst-tool$(EXEEXT) gst.im $(WINEWRAPPERDEP)])

GST_PACKAGE_ENABLE([Announcements], [announcements])
GST_PACKAGE_ENABLE([BloxTK], [blox/tk],
   [GST_HAVE_TCLTK],
   [gst_cv_tcltk_libs],
   [Makefile], [blox-tk.la])
GST_PACKAGE_ENABLE([BLOXBrowser], [blox/browser])
GST_PACKAGE_ENABLE([Complex], [complex])
GST_PACKAGE_ENABLE([Continuations], [continuations])
GST_PACKAGE_ENABLE([CParser], [cpp])
GST_PACKAGE_ENABLE([DebugTools], [debug])
GST_PACKAGE_ENABLE([ObjectDumper], [object-dumper])

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
   [AC_CHECK_HEADER([sqlite3.h])
    GST_HAVE_LIB(sqlite3, sqlite3_clear_bindings)],
   [ac_cv_header_sqlite3_h],
   [Makefile], [dbd-sqlite3.la])

GST_PACKAGE_ENABLE([DBI], [dbi])

GST_PACKAGE_ENABLE([GDBM], [gdbm],
   [AC_CHECK_HEADER([gdbm.h])],
   [ac_cv_header_gdbm_h],
   [Makefile], [gdbm.la])
GST_PACKAGE_ENABLE([Glorp], [glorp])
GST_PACKAGE_ENABLE([Cairo], [cairo],
  [PKG_CHECK_MODULES([CAIRO], cairo, [gst_cv_cairo=yes], [gst_cv_cairo=no])],
  [gst_cv_cairo])

GST_PACKAGE_ENABLE([GLib], [glib], [
  AM_PATH_GLIB_2_0(2.0.0, [
    PKG_CHECK_MODULES(GTHREAD, gthread-2.0 >= 2.0.0,
                      [gst_cv_glib=yes], [gst_cv_glib=no])
  ], [], gobject)
  if test $gst_cv_glib = yes; then
    ac_save_LIBS=$LIBS
    ac_save_CFLAGS=$CFLAGS
    LIBS="$LIBS $GLIB_LIBS"
    CFLAGS="$CFLAGS $GLIB_CFLAGS"
    AC_CHECK_FUNCS([g_poll])
    if test $ac_cv_func_g_poll = no; then
      AC_DEFINE([g_poll], [poll], [Define to poll if your glib does not provide g_poll.])
    fi
    LIBS=$ac_save_LIBS
    CFLAGS=$ac_save_CFLAGS
  fi],
  [gst_cv_glib],
  [Makefile], [gst-glib.la libgst-gobject.la])

GST_PACKAGE_ENABLE([GObject-Introspection], [gir], [
  PKG_CHECK_MODULES(GIR, gobject-introspection-1.0 >= 0.9.3,
                    [gst_cv_gir=yes], [gst_cv_gir=no])],
  [gst_cv_gir])

GST_PACKAGE_ENABLE([GTK], [gtk], [
  AC_ARG_ENABLE(gtk,
  [  --enable-gtk={yes,no,blox}
                          enable GTK+ bindings.  Blox/GTK is experimental.], ,
  enable_gtk=yes)

  if test "$enable_gtk" != no && test "$gst_cv_glib" != no; then
    maybe_enable_gtk=$enable_gtk
    enable_gtk=no
    AM_PATH_GTK_2_0(2.0.0,
      [PKG_CHECK_MODULES(ATK, atk >= 1.0.0,
        [PKG_CHECK_MODULES(PANGO, pango >= 1.0.0,
                           [enable_gtk=$maybe_enable_gtk], :)], [:])])
  fi],
  [enable_gtk gst_cv_cairo],
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
GST_PACKAGE_ENABLE([Magritte], [magritte])
GST_PACKAGE_ENABLE([Magritte-Seaside], [seaside/magritte])

GST_PACKAGE_ENABLE([NCurses],
  [ncurses],
  [GST_HAVE_LIB(ncurses, initscr)],
  [ac_cv_lib_ncurses_initscr])
GST_PACKAGE_ENABLE([NetClients], [net], [], [], [Makefile])
GST_PACKAGE_ENABLE([DhbNumericalMethods], [numerics])
GST_PACKAGE_ENABLE([OpenGL], [opengl],
   [GST_HAVE_OPENGL],
   [gst_cv_opengl_libs],
   [Makefile], [gstopengl.la])
GST_PACKAGE_ENABLE([GLUT], [glut],
   [GST_HAVE_GLUT],
   [gst_cv_glut_libs],
   [Makefile], [gstglut.la])

GST_PACKAGE_ENABLE([LibSDL], [sdl/libsdl],
  [PKG_CHECK_MODULES(SDL, sdl >= 1.2.0, [gst_cv_sdl=yes], [gst_cv_sdl=no])
  case "$SDL_LIBS" in
    *-framework,Cocoa* | *"-framework Cocoa"*) gst_cv_sdl_uses_cocoa=yes ;;
    *) gst_cv_sdl_uses_cocoa=no ;;
  esac

  save_CFLAGS=$CFLAGS
  save_LIBS=$LIBS
  CFLAGS="$CFLAGS $SDL_CFLAGS"
  LIBS="$LIBS $SDL_LIBS"
  AC_LINK_IFELSE([AC_LANG_SOURCE([
      #include <SDL.h>
      #include <SDL_main.h>
      int main(int argc, char **argv) { SDL_Init(0); return 0; }])],
    [], [gst_cv_sdl=no])

  LIBS=$save_LIBS
  CFLAGS=$save_CFLAGS

  # We do SDLmain's job on our own, and mingw32 is linked automatically
  # into the DLL.  If we do not do this, libtool refuses to create a DLL
  # for the SDL module.
  SDL_LIBS=`echo " $SDL_LIBS " | sed 's/ -lSDLmain / /; s/ -lmingw32 / /' `
  
  AM_CONDITIONAL([HAVE_COCOA], [test $gst_cv_sdl_uses_cocoa = yes])],
  [gst_cv_sdl],
  [Makefile], [sdl.la])
GST_PACKAGE_ENABLE([LibSDL_GL], [sdl/libsdl_gl], [],
		   [gst_cv_sdl gst_cv_opengl_libs])
GST_PACKAGE_ENABLE([CairoSDL], [sdl/cairo],
  [],
  [gst_cv_cairo gst_cv_sdl])
GST_PACKAGE_ENABLE([LibSDL_image], [sdl/libsdl_image],
  [GST_HAVE_LIB(SDL_image, IMG_Linked_Version)],
  [ac_cv_lib_SDL_image_IMG_Linked_Version])
GST_PACKAGE_ENABLE([LibSDL_mixer], [sdl/libsdl_mixer],
  [GST_HAVE_LIB(SDL_mixer, Mix_Linked_Version)],
  [ac_cv_lib_SDL_mixer_Mix_Linked_Version])
GST_PACKAGE_ENABLE([LibSDL_sound], [sdl/libsdl_sound],
  [GST_HAVE_LIB(SDL_sound, Sound_GetLinkedVersion)],
  [ac_cv_lib_SDL_sound_Sound_GetLinkedVersion])
GST_PACKAGE_ENABLE([LibSDL_ttf], [sdl/libsdl_ttf],
  [GST_HAVE_LIB(SDL_ttf, TTF_Init)],
  [ac_cv_lib_SDL_ttf_TTF_Init])

GST_PACKAGE_ENABLE([Compiler], [stinst/compiler])
GST_PACKAGE_ENABLE([Parser], [stinst/parser])
GST_PACKAGE_ENABLE([ClassPublisher], [stinst/doc])
GST_PACKAGE_ENABLE([ProfileTools], [profile])
GST_PACKAGE_ENABLE([ROE], [roe])
GST_PACKAGE_ENABLE([SandstoneDb], [sandstonedb])
GST_PACKAGE_ENABLE([Seaside-Core], [seaside/core])
GST_PACKAGE_ENABLE([Seaside-Development], [seaside/dev])
GST_PACKAGE_ENABLE([Seaside-Examples], [seaside/examples])
GST_PACKAGE_ENABLE([Seaside], [seaside/swazoo])
GST_PACKAGE_ENABLE([Sport], [sport])
GST_PACKAGE_ENABLE([SUnit], [sunit])
GST_PACKAGE_ENABLE([Swazoo], [swazoo-httpd])
GST_PACKAGE_ENABLE([Sockets], [sockets], [], [gst_cv_sockets])
GST_PACKAGE_ENABLE([VFSAddOns], [vfs], [], [], [Makefile])
GST_PACKAGE_ENABLE([VisualGST], [visualgst])
GST_PACKAGE_ENABLE([XML-XMLNodeBuilder], [xml/builder])
GST_PACKAGE_ENABLE([XML-DOM], [xml/dom])
GST_PACKAGE_ENABLE([XML-ParserTests], [xml/tests])
GST_PACKAGE_ENABLE([XML-PullParser], [xml/pullparser])
GST_PACKAGE_ENABLE([XML-Expat], [xml/expat],
  [AC_CHECK_HEADER([expat.h])
   GST_HAVE_LIB(expat, XML_ParserCreateNS)],
  [ac_cv_header_expat_h ac_cv_lib_expat_XML_ParserCreateNS],
  [Makefile], [expat.la])
GST_PACKAGE_ENABLE([XML-XMLParser], [xml/parser])
GST_PACKAGE_ENABLE([XML-SAXDriver], [xml/saxdriver])
GST_PACKAGE_ENABLE([XML-SAXParser], [xml/saxparser])
GST_PACKAGE_ENABLE([XPath], [xml/xpath])
GST_PACKAGE_ENABLE([XSL], [xml/xsl])
GST_PACKAGE_ENABLE([ZLib],
  [zlib],
  [AC_CHECK_HEADER([zlib.h])
   GST_HAVE_LIB(z, inflate)],
  [ac_cv_header_zlib_h ac_cv_lib_z_inflate],
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
dnl ------------------------------- RELOCATABILITY ------------

# See if we can make the installed binaries relocatable

AC_MSG_CHECKING([whether to enable relocatable install])
AC_RELOCATABLE_NOP
relocatable_reason=$RELOCATABLE

# First of all, compute the final paths for the various components.

AC_LIB_PREPARE_PREFIX

acl_final_datadir=`echo "${datadir}" | sed \
	-e "s,\\\${datarootdir},$datarootdir," \
	-e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
	-e "s,\\\${prefix},$acl_final_prefix," `
acl_final_bindir=`echo "${bindir}" | sed \
	-e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
	-e "s,\\\${prefix},$acl_final_prefix," `
acl_final_libdir=`echo "${libdir}" | sed \
	-e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
	-e "s,\\\${prefix},$acl_final_prefix," `
acl_final_libexecdir=`echo "${libexecdir}" | sed \
	-e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
	-e "s,\\\${prefix},$acl_final_prefix," `

acl_final_pkgdatadir="$acl_final_datadir/$PACKAGE"
acl_final_pkglibdir="$acl_final_libdir/$PACKAGE"

acl_final_imagedir=`echo "${imagedir}" | sed \
	-e "s,\\\${localstatedir},$localstatedir," \
	-e "s,\\\${pkgdatadir},$pkgdatadir," \
	-e "s,\\\${datadir},$datadir," \
	-e "s,\\\${docdir},$docdir," \
	-e "s,\\\${datarootdir},$datarootdir," \
	-e "s,\\\${pkglibdir},$acl_final_pkglibdir," \
	-e "s,\\\${libdir},$acl_final_libdir," \
	-e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
	-e "s,\\\${prefix},$acl_final_prefix," `
acl_final_moduledir=`echo "${moduledir}" | sed \
	-e "s,\\\${localstatedir},$localstatedir," \
	-e "s,\\\${pkgdatadir},$pkgdatadir," \
	-e "s,\\\${datadir},$datadir," \
	-e "s,\\\${docdir},$docdir," \
	-e "s,\\\${datarootdir},$datarootdir," \
	-e "s,\\\${pkglibdir},$acl_final_pkglibdir," \
	-e "s,\\\${libdir},$acl_final_libdir," \
	-e "s,\\\${exec_prefix},$acl_final_exec_prefix," \
	-e "s,\\\${prefix},$acl_final_prefix," `


# If shared libraries are enabled, there are a few extra constraints.

if test "$enable_shared" != no; then
  case $host in
    *-*-cygwin* | *-*-mingw*)
      # For Windows, the shared library will be installed in bindir anyway
      ;;

    *-linux*)
      # For Linux, we can use a relative rpath via -Wl,-rpath,...
      case "$acl_final_libdir" in
        "${acl_final_exec_prefix}"/*) ;;
        /*) relocatable_reason='no, libdir outside exec-prefix' ;;
        *) relocatable_reason='no, relative libdir' ;;
      esac
      ;;

    *)
      relocatable_reason="no,
	relocatable shared libraries not supported on $host"
      ;;
  esac
fi

# Further OS-independent tests ensure that we can make relative
# paths from the executable's location.

if test "$relocatable_reason" = yes; then
  case "${acl_final_bindir}" in
    "${acl_final_exec_prefix}") ;;
    "${acl_final_exec_prefix}"/*) ;;
    /*) relocatable_reason='no, bindir outside exec-prefix' ;;
    *) relocatable_reason='no, relative bindir' ;;
  esac
  case "${acl_final_libexecdir}" in
    "${acl_final_exec_prefix}") ;;
    ${acl_final_exec_prefix}/*) ;;
    /*) relocatable_reason='no, libexecdir outside exec_prefix' ;;
    *) relocatable_reason='no, relative libexecdir' ;;
  esac
  case "${acl_final_datadir}" in
    ${acl_final_prefix}) ;;
    ${acl_final_prefix}/*) ;;
    /*) relocatable_reason='no, datadir outside prefix' ;;
    *) relocatable_reason='no, relative datadir' ;;
  esac
  case "${acl_final_imagedir}" in
    ${acl_final_prefix}) ;;
    ${acl_final_prefix}/*) ;;
    /*) relocatable_reason='no, imagedir outside prefix' ;;
    *) relocatable_reason='no, relative imagedir' ;;
  esac
  case "${acl_final_moduledir}" in
    ${acl_final_prefix}) ;;
    ${acl_final_prefix}/*) ;;
    /*) relocatable_reason='no, moduledir outside prefix' ;;
    *) relocatable_reason='no, relative moduledir' ;;
  esac

  test "$acl_final_prefix" != "$acl_final_exec_prefix" && \
    relocatable_reason='no, prefix does not match exec prefix'
fi

# echo the relative path from ${acl_final_bindir} to $1
# (Works only if both are absolute.)
[func_make_relpath ()
{
  dir=$1
  idir=${acl_final_bindir}

  while true; do
    dfirst=`echo "$dir" | sed -n -e 's,^//*\([^/]*\).*$,/\1,p'`
    ifirst=`echo "$idir" | sed -n -e 's,^//*\([^/]*\).*$,/\1,p'`
    test x"$dfirst" = x && break
    test x"$ifirst" = x && break
    test "$dfirst" != "$ifirst" && break

    dir=`echo "$dir" | sed -e 's,^//*[^/]*,,'`
    idir=`echo "$idir" | sed -e 's,^//*[^/]*,,'`
  done
  idir=`echo "$idir" | sed -e 's,//*[^/]*,/..,g' -e 's,^/,,' `
  echo "${idir:-.}$dir"
}]

case "$relocatable_reason" in
  yes)
    # Command-line option to include a relative search path for
    # shared libraries
    if test "$enable_shared" != no; then
      case "$host" in
        *-linux*)
          RELOC_LDFLAGS='-Wl,-rpath,"\$$ORIGIN/'`func_make_relpath ${acl_final_libdir}`'"'
	  ;;
      esac
    fi

    KERNEL_PATH=`func_make_relpath ${acl_final_pkgdatadir}/kernel`
    IMAGE_PATH=`func_make_relpath ${acl_final_imagedir}`
    MODULE_PATH=`func_make_relpath ${acl_final_moduledir}`
    LIBEXEC_PATH=`func_make_relpath "${acl_final_libexecdir}/${PACKAGE}"`
    PREFIX=`func_make_relpath "${acl_final_prefix}"`
    EXEC_PREFIX=`func_make_relpath "${acl_final_exec_prefix}"`
    AC_DEFINE_UNQUOTED(KERNEL_PATH, "$KERNEL_PATH",
		       [The relative path from the program to the kernel path.
		        Defined only for relocatable installs.])
    AC_DEFINE_UNQUOTED(IMAGE_PATH, "$IMAGE_PATH",
		       [The relative path from the program to the image path.
		        Defined only for relocatable installs.])
    AC_DEFINE_UNQUOTED(MODULE_PATH, "$MODULE_PATH",
		       [The relative path from the program to the module path.
		        Defined only for relocatable installs.])
    AC_DEFINE_UNQUOTED(LIBEXEC_PATH, "$LIBEXEC_PATH",
		       [The relative path from the program to the per-package
			libexec path.  Defined only for relocatable installs.])
    AC_DEFINE_UNQUOTED(PREFIX, "$PREFIX",
		       [The relative path from the program to the prefix.
		        Defined only for relocatable installs.])
    AC_DEFINE_UNQUOTED(EXEC_PREFIX, "$EXEC_PREFIX",
		       [The relative path from the program to the exec-prefix.
			Defined only for relocatable installs.])
    ;;

  *)
    # Pass paths on the command-line to allow specifying a prefix at "make"
    # time.
    RELOC_CPPFLAGS='-DKERNEL_PATH=\""${pkgdatadir}/kernel"\" \
	-DIMAGE_PATH=\""${imagedir}"\" \
	-DMODULE_PATH=\""${moduledir}"\" \
	-DLIBEXEC_PATH=\""${libexecdir}/${PACKAGE}"\" \
	-DPREFIX=\""${prefix}"\" \
	-DEXEC_PREFIX=\""${exec_prefix}"\" '
    ;;
esac

RELOC_CPPFLAGS=$RELOC_CPPFLAGS' \
	-DDEFAULT_EXECUTABLE=\""${bindir}/gst${EXEEXT}"\"'
AC_MSG_RESULT([$relocatable_reason])
AC_SUBST(RELOC_CPPFLAGS)
AC_SUBST(RELOC_LDFLAGS)

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

dnl Master Makefile
AC_CONFIG_FILES(Makefile)

dnl VM makefiles
AC_CONFIG_FILES(doc/Makefile lib-src/Makefile libgst/Makefile)
AC_CONFIG_FILES(opcode/Makefile lightning/Makefile tests/Makefile)

AC_OUTPUT
