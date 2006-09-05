dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
# serial 1 LIGHTNING_CONFIGURE_IF_NOT_FOUND
AC_DEFUN([LIGHTNING_CONFIGURE_IF_NOT_FOUND], [
AC_REQUIRE([AC_PROG_LN_S])dnl
AC_REQUIRE([AC_CANONICAL_HOST])dnl
AC_CHECK_HEADER(lightning.h)
AM_CONDITIONAL(LIGHTNING_MAIN, (exit 1))
AM_CONDITIONAL(HAVE_INSTALLED_LIGHTNING, test "$ac_cv_header_lightning_h" = yes)

lightning=
if test "$ac_cv_header_lightning_h" = yes; then
  lightning=yes
else
  case "$host_cpu" in
	i?86)	 cpu_subdir=i386					;;
	sparc*)	 cpu_subdir=sparc					;;
	powerpc) cpu_subdir=ppc						;;
	*)	 ;;
  esac
  test -n "$cpu_subdir" && lightning=yes
fi

ifdef([AC_HELP_STRING], [
  dnl autoconf 2.50 style
  if test -n "$cpu_subdir"; then
    AC_CONFIG_LINKS(lightning/asm.h:lightning/$cpu_subdir/asm.h
		    lightning/core.h:lightning/$cpu_subdir/core.h
		    lightning/fp.h:lightning/$cpu_subdir/fp.h
		    lightning/funcs.h:lightning/$cpu_subdir/funcs.h, , [
      cpu_subdir=$cpu_subdir
    ])
  fi
], [
  dnl autoconf 2.13 style
  AC_OUTPUT_COMMANDS([
    if test -n "$cpu_subdir"; then
      for i in asm fp core funcs; do
        echo linking $srcdir/lightning/$cpu_subdir/$i.h to lightning/$i.h 
        (cd lightning && $LN_S -f $srcdir/$cpu_subdir/$i.h $i.h)
      done
    fi
  ], [
    LN_S='$LN_S'
    cpu_subdir=$cpu_subdir
  ])
])

if test -n "$lightning"; then
  AC_DEFINE(HAVE_LIGHTNING, 1, [Define if GNU lightning can be used])
  lightning=
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi

])dnl
