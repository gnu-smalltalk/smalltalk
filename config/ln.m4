AC_DEFUN([GST_PROG_LN],
[AC_MSG_CHECKING([whether ln works])
rm -f conf$$ conf$$.exe conf$$.file
echo >conf$$.file
if ln conf$$.file conf$$ 2>/dev/null; then
  # We could just check for DJGPP; but this test works, is more generic
  # and will remain valid once DJGPP supports symlinks (DJGPP 2.04).
  if test -f conf$$.exe; then
    # Don't use ln at all; we don't have any links
    LN='cp -p'
  else
    LN='ln'
  fi
else
  LN=m4_if([$1], [], [$as_ln_s], [$1])
fi
rm -f conf$$ conf$$.exe conf$$.file
AC_SUBST([LN])dnl
if test "$LN" = ln; then
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no, using $LN])
fi
])# GST_PROG_LN
