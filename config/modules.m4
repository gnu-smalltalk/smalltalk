dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_ARG_ENABLE_MODULES], [

AC_ARG_ENABLE(modules,
[  --enable-modules=list   add these packages to the pre-built image])

test "$enable_modules" = "yes" && enable_modules="$1"
test "$enable_modules" = "no" && enable_modules=
MODULES=`echo $enable_modules | sed "s/,/ /g"`
AC_SUBST(MODULES)
])

