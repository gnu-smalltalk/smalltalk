dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([ACX_C_RESTRICT],
[AC_REQUIRE([AC_PROG_CC_STDC])dnl
AC_CACHE_CHECK([for restrict], acx_cv_c_restrict,
[acx_cv_c_restrict=no
for ac_kw in restrict __restrict__ __restrict; do
  AC_COMPILE_IFELSE([AC_LANG_SOURCE(
[#ifndef __cplusplus
int func (foo) char *$ac_kw foo; { return 0; }
#endif
])],
                    [acx_cv_c_restrict=$ac_kw; break])
done
])
case $acx_cv_c_restrict in
  restrict | yes) ;;
  no) AC_DEFINE(restrict,,
                [Define as `__restrict' if that's what the C compiler calls it,
                 or to nothing if it is not supported.]) ;;
  *)  AC_DEFINE_UNQUOTED(restrict, $acx_cv_c_restrict) ;;
esac
])# ACX_C_RESTRICT
