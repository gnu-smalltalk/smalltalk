AC_DEFUN([GST_EMACS_PACKAGE], [
AC_CACHE_CHECK([for $1.el], ac_cv_emacs_$1, [
  if test $EMACS = no; then
    ac_cv_emacs_$1=no
  else
    if $EMACS -batch -q -no-site-file -l $1.el 2>&1 | \
         grep 'Cannot open load file' > /dev/null 2>&1; then
      ac_cv_emacs_$1=no
    else
      ac_cv_emacs_$1=yes
    fi
  fi
])
AS_IF([test $ac_cv_emacs_$1 = yes], [$2], [$3])
])
