AC_DEFUN([GST_EMACS_PACKAGE], [
AC_CACHE_CHECK([for $1.el], [ac_cv_emacs_[]AS_TR_SH([$1])], [
  ac_cv_emacs_[]AS_TR_SH([$1])=no
  if test $EMACS != no; then
    echo "AS_ESCAPE([(require '$1)])" > conftest
    $EMACS -batch -q -no-site-file -l conftest 2>&1 | \
      grep 'Cannot open load file' > /dev/null 2>&1 || \
      ac_cv_emacs_[]AS_TR_SH([$1])=yes
    rm conftest
  fi
])
AS_IF([test $ac_cv_emacs_[]AS_TR_SH([$1]) = yes], [$2], [$3])
])
