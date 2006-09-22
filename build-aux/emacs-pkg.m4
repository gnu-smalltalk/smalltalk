AC_DEFUN([GST_EMACS_PACKAGE], [
AC_CACHE_CHECK([for $1.el], ac_cv_emacs_$1, [
  ac_cv_emacs_$1=no
  if test $EMACS != no; then
    $EMACS -batch -q -no-site-file -l $1.el 2>&1 | \
      grep 'Cannot open load file' > /dev/null 2>&1 || ac_cv_emacs_$1=yes
    $EMACS -batch -q -no-site-file -l $1.elc 2>&1 | \
      grep 'Cannot open load file' > /dev/null 2>&1 || ac_cv_emacs_$1=yes
  fi
])
AS_IF([test $ac_cv_emacs_$1 = yes], [$2], [$3])
])
