dnl AC_SNPRINTFV_CONVENIENCE[(dir)] - sets LIBSNPRINTFV to the link flags for
dnl the snprintfv convenience library and INCSNPRINTFV to the include flags for
dnl the snprintfv header and adds --enable-snprintfv-convenience to the
dnl configure arguments.  Note that AC_CONFIG_SUBDIRS is not called.  If DIR
dnl is not provided, it is assumed to be `snprintfv'.  LIBSNPRINTFV will be 
dnl prefixed with '${top_builddir}/' and INCSNPRINTFV will be prefixed with
dnl '${top_srcdir}/' (note the single quotes!).  If your package is not
dnl flat and you're not using automake, define top_builddir and
dnl top_srcdir appropriately in the Makefiles.
AC_DEFUN([AC_SNPRINTFV_CONVENIENCE],
[case $enable_snprintfv_convenience in
  no) AC_MSG_ERROR([this package needs a convenience snprintfv]) ;;
  "") enable_snprintfv_convenience=yes
      ac_configure_args="$ac_configure_args --enable-snprintfv-convenience" ;;
  esac
  LIBSNPRINTFV='${top_builddir}/'ifelse($#,1,[$1],['snprintfv'])/snprintfv/libsnprintfvc.la
  INCSNPRINTFV='-I${top_builddir}/'ifelse($#,1,[$1],['snprintfv'])' -I${top_srcdir}/'ifelse($#,1,[$1],['snprintfv'])
  AC_SUBST(LIBSNPRINTFV)
  AC_SUBST(INCSNPRINTFV)
])

dnl AC_SNPRINTFV_INSTALLABLE[(dir)] - sets LIBSNPRINTFV to the link flags for
dnl the snprintfv installable library and INCSNPRINTFV to the include flags for
dnl the snprintfv header and adds --enable-snprintfv-install to the
dnl configure arguments.  Note that AC_CONFIG_SUBDIRS is not called.  If DIR
dnl is not provided and an installed libsnprintfv is not found, it is assumed
dnl to be `snprintfv'.  LIBSNPRINTFV will be prefixed with '${top_builddir}/'
dnl and INCSNPRINTFV will be prefixed with # '${top_srcdir}/' (note the single
dnl quotes!).  If your package is not flat and you're not using automake,
dnl define top_builddir and top_srcdir appropriately in the Makefiles.
dnl In the future, this macro may have to be called after AC_PROG_LIBTOOL.
AC_DEFUN([AC_SNPRINTFV_INSTALLABLE],
[AC_BEFORE([$0],[AC_LIBTOOL_SETUP])dnl
AC_REQUIRE([AC_CANONICAL_HOST])dnl
  AC_CHECK_LIB(snprintfv, snv_printf,
  [test x"$enable_snprintfv_install" != xyes && enable_snprintfv_install=no],
  [if test x"$enable_snprintfv_install" = xno; then
     AC_MSG_WARN([snprintfv not installed, but installation disabled])
   else
     enable_snprintfv_install=yes

     # ----------------------------------------------------------------------
     # Win32 objects need to tell the header whether they will be linking
     # with a dll or static archive in order that everything is imported
     # to the object in the same way that it was exported from the
     # archive (``extern'' for static, ``__declspec(dllimport)'' for dlls).
     # ----------------------------------------------------------------------
     case "$host" in
     *-*-cygwin* | *-*-mingw* | *-*-os2)
       AC_DEFINE([LIBSNPRINTFV_DLL_IMPORT], ,
	 [Defined to 1 to work around Windows' broken implementation of
	  exported data symbols])
         echo '#define LIBSNPRINTFV_DLL_IMPORT 1' >> $tmpfile
       fi
       ;;
     esac
   fi
  ])


  if test x"$enable_snprintfv_install" = x"yes"; then
    ac_configure_args="$ac_configure_args --enable-snprintfv-install"
    LIBSNPRINTFV='${top_builddir}/'ifelse($#,1,[$1],['snprintfv'])/snprintfv/libsnprintfv.la
    INCSNPRINTFV='-I${top_srcdir}/'ifelse($#,1,[$1],['snprintfv'])
    INCSNPRINTFV='-I${top_builddir}/'ifelse($#,1,[$1],['snprintfv'])' -I${top_srcdir}/'ifelse($#,1,[$1],['snprintfv'])
  else
    ac_configure_args="$ac_configure_args --enable-snprintfv-install=no"
    LIBSNPRINTFV="-lsnprintfv"
    INCSNPRINTFV=
  fi
])

