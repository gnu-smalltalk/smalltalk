dnl  -*- Mode: M4 -*- 
dnl configure.in --- GNU autoconf source for toplevel directory.
dnl Copyright (C) 1998, 1999, 2000, 2009 Gary V. Vaughan
dnl Originally by Gary V. Vaughan <gvv@techie.com>, 1998
dnl This file is part of Snprintfv.
dnl
dnl Snprintfv is free software; you can redistribute it and/or
dnl modify it under the terms of the GNU General Public License as
dnl published by the Free Software Foundation; either version 2 of the
dnl License, or (at your option) any later version.
dnl
dnl Snprintfv is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
dnl 
dnl  As a special exception to the GNU General Public License, if you
dnl  distribute this file as part of a program that also links with and
dnl  uses the libopts library from AutoGen, you may include it under
dnl  the same distribution terms used by the libopts library.

dnl Code:

AC_PREREQ(2.60)
AC_INIT(snprintfv, 1.1, bonzini@gnu.org)
AC_CONFIG_SRCDIR(snprintfv/printf.h)
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_AUX_DIR(../build-aux)
AC_CONFIG_MACRO_DIR(../build-aux)

AC_ARG_ENABLE(subdir,
[  --enable-subdir     used in a package, texinfo+testsuite stripped], ,
[enable_subdir=no])

AM_INIT_AUTOMAKE

SNV_CURRENT=3;	AC_SUBST(SNV_CURRENT)
SNV_REVISION=0; AC_SUBST(SNV_REVISION)
SNV_AGE=0;	AC_SUBST(SNV_AGE)

AC_LIBTOOL_WIN32_DLL
AC_PROG_LIBTOOL

AC_PROG_SED

# ----------------------------------------------------------------------
# If `configure' is invoked (in)directly via `make', ensure that it
# encounters no `make' conflicts.  Ignore error if shell does not have
# unset, but at least set these to empty values.
# ----------------------------------------------------------------------
MFLAGS=
MAKEFLAGS=
MAKELEVEL=
unset MFLAGS MAKEFLAGS MAKELEVEL 2>/dev/null

# ----------------------------------------------------------------------
# Set up and process configure options
# ----------------------------------------------------------------------
AM_CONDITIONAL(SUBDIR_SNPRINTFV,
test x"${enable_subdir-no}" != xno)
if test x"${enable_subdir-no}" = xno; then
  enable_snprintfv_install=yes
  enable_snprintfv_convenience=no
else
  if test x"$enable_snprintfv_convenience$enable_snprintfv_install" = x; then
    AC_MSG_WARN([*** The top-level configure should select either])
    AC_MSG_WARN([*** [A@&t@C_SNPRINTFV_INSTALL] or [A@&t@C_SNPRINTFV_CONVENIENCE],])
    enable_snprintfv_convenience=yes
    enable_snprintfv_install=no
  fi
fi

AM_CONDITIONAL(INSTALL_SNPRINTFV,
test x"${enable_snprintfv_install-no}" != xno)
if test x"${enable_snprintfv_install-no}" != xno; then
  installed_libsnprintfv=libsnprintfv.la
fi
AC_SUBST(installed_libsnprintfv)

AM_CONDITIONAL(CONVENIENCE_SNPRINTFV,
test x"${enable_snprintfv_convenience-no}" != xno)
if test x"${enable_snprintfv_convenience-no}" != xno; then
  convenience_libsnprintfv=libsnprintfvc.la
fi
AC_SUBST(convenience_libsnprintfv)

AC_ARG_ENABLE(convenience-float-printing,
[  --enable-convenience-float-printing     enable/disable printing floats
					   in convenience snprintfv [yes]], ,
enable_convenience_float_printing=yes)
if test x"$enable_convenience_float_printing" = yes; then
  enable_convenience_float_printing=$enable_snprintfv_convenience
fi
AC_MSG_CHECKING([whether the convenience libsnprintfv needs printing floats])
AC_MSG_RESULT([$enable_convenience_float_printing])
if test x$enable_convenience_float_printing = xyes; then
  LIBSNPRINTFVC_PRINT_FLOATS=
else
  LIBSNPRINTFVC_PRINT_FLOATS='-DNO_FLOAT_PRINTING'
fi
AC_SUBST(LIBSNPRINTFVC_PRINT_FLOATS)

AM_WITH_DMALLOC

# ----------------------------------------------------------------------
# check for various programs used during the build.
# ----------------------------------------------------------------------
AC_PROG_CC
AC_C_CONST
AC_C_INLINE
AC_EXEEXT
AC_PROG_INSTALL
AC_PROG_AWK

# ----------------------------------------------------------------------
# check for standard headers.
# ----------------------------------------------------------------------
AC_HEADER_STDC
AC_CHECK_HEADERS(sys/types.h)

AC_CACHE_CHECK([for static inline], [snv_cv_static_inline], [
AC_TRY_COMPILE([static inline foo(bar) int bar; { return bar; }],
  [return foo(0);],
  [snv_cv_static_inline=yes],
  [snv_cv_static_inline=no])
])

# If string.h is present define HAVE_STRING_H, otherwise if strings.h
# is present define HAVE_STRINGS_H.
AC_CHECK_HEADERS(string.h strings.h, break)
AC_CHECK_FUNCS(flockfile fputc_unlocked)

# ----------------------------------------------------------------------
# Checks for typedefs
# ----------------------------------------------------------------------
AC_CHECK_HEADER(wchar.h)
AC_CHECK_TYPE(wchar_t)
AC_CHECK_TYPE(wint_t)
AC_CHECK_TYPE(intmax_t)
AC_TYPE_SIZE_T
AC_CHECK_SIZEOF(int)
AC_CHECK_SIZEOF(wint_t)

# ----------------------------------------------------------------------
# Checks for floating-point features
# ----------------------------------------------------------------------
AC_C_LONG_DOUBLE
AC_CHECK_LIB(m, log)
AC_CHECK_FUNCS(copysign copysignl isinf isinfl isnan isnanl modfl)

# ----------------------------------------------------------------------
# Add code to config.status to create an installable host dependent
# configuration file.
# ----------------------------------------------------------------------

AC_CONFIG_COMMANDS([snprintfv/compat.h], [
    outfile=snprintfv/compat.h
    tmpfile=${outfile}T
    dirname="sed s,^.*/,,g"
    echo creating $outfile
    cat > $tmpfile << _EOF_
/*  -*- Mode: C -*-
 * --------------------------------------------------------------------
 * DO NOT EDIT THIS FILE!  It has been automatically generated
 * from:    configure.in and `echo $outfile|$dirname`.in
 * on host: `(hostname || uname -n) 2>/dev/null | sed 1q`
 * --------------------------------------------------------------------
 * `echo $outfile|$dirname` --- portability code generated for snprintfv by configure.in
 */

#ifndef SNPRINTFV_COMPAT_H
#define SNPRINTFV_COMPAT_H 1

#ifdef __cplusplus
extern "C" {
#if 0
/* This brace is so that emacs can still indent properly: */ }
#endif
#endif /* __cplusplus */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
_EOF_

    # Add the code to include these headers only if autoconf has
    # shown them to be present.
    if test x$ac_cv_header_sys_types_h = xyes; then
      echo '#include <sys/types.h>' >> $tmpfile
    fi
    if test x$ac_cv_header_string_h = xyes; then
      echo '#include <string.h>' >> $tmpfile
    elif test x$ac_cv_header_strings_h = xyes; then
      echo '#include <strings.h>' >> $tmpfile
    fi

    if test x$ac_cv_header_inttypes_h = xyes; then
      echo '#include <inttypes.h>' >> $tmpfile
    elif test x$ac_cv_header_stdint_h = xyes; then
      echo '#include <stdint.h>' >> $tmpfile
    fi

    if test x$ac_cv_header_wchar_h = xyes; then
      echo '#include <wchar.h>' >> $tmpfile
    fi

    if test x$snv_cv_static_inline = xyes; then
      echo '#define SNV_INLINE static inline' >> $tmpfile
    else
      echo '#define SNV_INLINE static' >> $tmpfile
    fi

    if test x$ac_cv_type_wchar_t = xno; then
      echo 'typedef unsigned int snv_wchar_t;' >> $tmpfile
    else
      echo 'typedef wchar_t snv_wchar_t;' >> $tmpfile
    fi
    if test x$ac_cv_type_wint_t = xno || test $ac_cv_sizeof_wint_t -lt $ac_cv_sizeof_int; then
      echo 'typedef unsigned int snv_wint_t;' >> $tmpfile
    else
      echo 'typedef wint_t snv_wint_t;' >> $tmpfile
    fi

    if test x$ac_cv_c_long_double = xno; then
      echo 'typedef double snv_long_double;' >> $tmpfile
    else
      echo 'typedef long double snv_long_double;' >> $tmpfile
    fi
    if test x$ac_cv_type_intmax_t = xno; then
      cat >> $tmpfile << '_EOF_'
#if __GNUC__ >= 2
typedef long long intmax_t;
typedef unsigned long long uintmax_t;
#else
typedef long intmax_t;
typedef unsigned long uintmax_t;
#endif

_EOF_
    fi

    if test x$ac_cv_type_size_t != xyes; then
      cat >> $tmpfile << \_EOF_

typedef unsigned long size_t;
_EOF_
    fi

    if test $ac_cv_func_fputc_unlocked = no || test $ac_cv_func_flockfile = no; then
      cat >> $tmpfile << \_EOF_
#define SNV_FPUTC_UNLOCKED fputc
#define SNV_PUTC_UNLOCKED putc
#define SNV_WITH_LOCKED_FP(fp, tmp_var) \
  for (tmp_var = 1; tmp_var--; )
_EOF_

    else
      cat >> $tmpfile << \_EOF_
#define SNV_FPUTC_UNLOCKED fputc_unlocked
#define SNV_PUTC_UNLOCKED putc_unlocked
#define SNV_WITH_LOCKED_FP(fp, tmp_var) \
  for (flockfile (fp), tmp_var = 1; \
       tmp_var--; funlockfile (fp))
_EOF_
    fi

    cat >> $tmpfile << \_EOF_

/* Define macros for storing integers inside pointers.
 * Be aware that it is only safe to use these macros to store `int'
 * values in `char*' (or `void*') words, and then extract them later.
 * Although it will work the other way round on many common
 * architectures, it is not portable to assume a `char*' can be
 * stored in an `int' and extracted later without loss of the msb's
 */

#define SNV_POINTER_TO_INT(p)	((long)(p))
#define SNV_POINTER_TO_UINT(p)	((unsigned long)(p))
#define SNV_INT_TO_POINTER(i)	((snv_pointer)(long)(i))
#define SNV_UINT_TO_POINTER(u)	((snv_pointer)(unsigned long)(u))
_EOF_

    # The ugly but portable cpp stuff comes from here
    infile=$srcdir/snprintfv/`echo $outfile | sed 's,.*/,,g;s,\..*$,,g'`.in
    sed '/^##.*$/d' $infile >> $tmpfile 

    cat >> $tmpfile << \_EOF_

#ifdef __cplusplus
#if 0
/* This brace is so that emacs can still indent properly: */ {
#endif
}
#endif /* __cplusplus */

#endif /* COMPAT_H */
_EOF_

    if cmp -s $tmpfile $outfile; then
      echo $outfile is unchanged
      rm -f $tmpfile
    else
      mv $tmpfile $outfile
    fi

],[
  ac_cv_header_inttypes_h=$ac_cv_header_inttypes_h
  ac_cv_header_stdint_h=$ac_cv_header_stdint_h
  ac_cv_header_stdlib_h=$ac_cv_header_stdlib_h
  ac_cv_header_sys_types_h=$ac_cv_header_sys_types_h
  ac_cv_header_wchar_h=$ac_cv_header_wchar_h
  ac_cv_header_memory_h=$ac_cv_header_memory_h
  ac_cv_header_stdarg_h=$ac_cv_header_stdarg_h
  ac_cv_header_varargs_h=$ac_cv_header_varargs_h
  ac_cv_header_string_h=$ac_cv_header_string_h
  ac_cv_header_strings_h=$ac_cv_header_strings_h
  ac_cv_header_limits_h=$ac_cv_header_limits_h
  ac_cv_header_values_h=$ac_cv_header_values_h
  ac_cv_header_errno_h=$ac_cv_header_errno_h
  ac_cv_func_fputc_unlocked=$ac_cv_func_fputc_unlocked
  ac_cv_func_flockfile=$ac_cv_func_flockfile
  ac_cv_type_intmax_t=$ac_cv_type_intmax_t
  ac_cv_c_long_double=$ac_cv_c_long_double
  ac_cv_type_size_t=$ac_cv_type_size_t
  ac_cv_type_wchar_t=$ac_cv_type_wchar_t
  ac_cv_type_wint_t=$ac_cv_type_wint_t
  ac_cv_sizeof_wint_t=$ac_cv_sizeof_wint_t
  ac_cv_sizeof_int=$ac_cv_sizeof_int
  snv_cv_static_inline=$snv_cv_static_inline
  srcdir=$srcdir
])
    
# ----------------------------------------------------------------------
# Generate the make files.
# ----------------------------------------------------------------------
LTLIBOBJS=`echo "$LIB@&t@OBJS"|sed 's,\.o ,.lo,g;s,\.o$,.lo,'`
AC_SUBST(LTLIBOBJS)

AC_SUBST(LIBS)
AC_SUBST(INCLUDES)
AC_SUBST(ac_aux_dir)

AC_CONFIG_FILES(Makefile snprintfv/Makefile)
dnl BEGIN GNU SMALLTALK LOCAL
dnl if test "x${enable_subdir-no}" = xno; then
dnl   AC_CONFIG_FILES(doc/Makefile tests/Makefile)
dnl fi
dnl END GNU SMALLTALK LOCAL

AC_OUTPUT

dnl configure.ac ends here
