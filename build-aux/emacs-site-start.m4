AC_DEFUN([GST_PATH_LISPSTARTDIR], [
AC_ARG_WITH([lispstartdir], [AC_HELP_STRING([--with-lispstartdir], [directory for Emacs startup files])])
AC_REQUIRE([AM_PATH_LISPDIR])
  gst_save_prefix=$prefix
  if test "${prefix}" = NONE; then
    prefix=$ac_default_prefix
  fi

  if test $cross_compiling = yes; then
    AC_MSG_WARN([cross compiling, guessing ${lispdir}/site-start.d])
  elif test -d `eval echo ${sysconfdir}`/emacs/site-start.d; then
    gst_cv_lispstartdir='${sysconfdir}/emacs/site-start.d'
  elif test -f `eval eval echo ${lispdir}`/site-start.el &&
       test -d `eval eval echo ${lispdir}`/site-start.d; then
    gst_cv_lispstartdir='${lispdir}/site-start.d'
  elif test -d /etc/emacs/site-start.d; then
    AC_MSG_WARN([found /etc/emacs/site-start.d on your system])
    AC_MSG_WARN([maybe you forgot --with-lispstartdir?])
    gst_cv_lispstartdir='${sysconfdir}/emacs/site-start.d'
  else
    gst_lispstartdir_for_echo=`eval eval echo ${lispdir}/site-start.d`
    AC_MSG_WARN([Emacs start directory not detected, guessing])
    AC_MSG_WARN([     ${gst_lispstartdir_for_echo}])
    AC_MSG_WARN([you may need this in your .emacs or site-start.el file:])
    AC_MSG_WARN([     (mapc 'load (directory-files])
    AC_MSG_WARN([          "${gst_lispstartdir_for_echo}"])
    AC_MSG_WARN([          t "\\.el\\'"))])
    gst_cv_lispstartdir='${lispdir}/site-start.d'
  fi
  lispstartdir=$gst_cv_lispstartdir
  prefix=$gst_save_prefix
  AC_MSG_CHECKING([where to place Emacs startup files])
  AC_MSG_RESULT([$lispstartdir])
  AC_SUBST([lispstartdir])
])
