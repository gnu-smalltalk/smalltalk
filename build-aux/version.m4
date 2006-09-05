dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_REVISION], [

VERSION=$PACKAGE_VERSION
VERSION_INFO=$1

# Split the version number
[
ST_MAJOR_VERSION=`echo $VERSION| sed 's%\..*%%'`
ST_MINOR_VERSION=`echo $VERSION| sed 's%[0-9]*\.\([0-9]*\).*%\1%'`
case $VERSION in
  *.*.*) 
    ST_EDIT_VERSION=`echo $VERSION| sed 's%\([0-9]*\)\.%%g'` ;;
  *.*[a-z])
    ST_EDIT_VERSION=\'`echo $VERSION| sed 's%[0-9.]*%%'`\' ;;
  *) ST_EDIT_VERSION=0 ;;
esac
]

AC_DEFINE_UNQUOTED(ST_MAJOR_VERSION, $ST_MAJOR_VERSION,
                   [Major version of GNU Smalltalk])
AC_DEFINE_UNQUOTED(ST_MINOR_VERSION, $ST_MINOR_VERSION,
                   [Minor version of GNU Smalltalk])
AC_DEFINE_UNQUOTED(ST_EDIT_VERSION, $ST_EDIT_VERSION,
                   [Patch level version of GNU Smalltalk])
AC_DEFINE_UNQUOTED(MAINTAINER, "$MAINTAINER",
                   [E-Mail address of the person maintaining this package])


AC_SUBST(PACKAGE)
AC_SUBST(VERSION)
AC_SUBST(VERSION_INFO)
AC_SUBST(MAINTAINER)

])
