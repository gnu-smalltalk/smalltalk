dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
dnl Calls several commonly used macros; also provides support for
dnl selectively enabling or disabling optimizations and warnings
dnl

AC_DEFUN([GST_PROG_CC], [
AC_REQUIRE([AC_PROG_CC])
AC_REQUIRE([AC_PROG_CPP])
AC_REQUIRE([AC_USE_SYSTEM_EXTENSIONS])

AC_ARG_ENABLE(warnings, 
[  --enable-warnings       enable compiler warnings (default=no)], ,
enable_warnings=no)

if test "$GCC" = yes; then
ifelse([$1$2$3$4$5], , , [dnl
  changequote(<<, >>)
  case "`$CC --version 2>&1`" in
    # This assumes egcs 1.1.2
    *gcc-2.9[0-4]*) gcc_help="echo -fbranch-probabilities \
	 -foptimize-register-moves -fcaller-saves -fcse-follow-jumps \
	 -fcse-skip-blocks -fdelayed-branch -fexpensive-optimizations \
	 -ffast-math -ffloat-store -fforce-addr -fforce-mem \
	 -ffunction-sections -fgcse -finline-functions \
	 -fkeep-inline-functions -fdefault-inline -fdefer-pop \
	 -ffunction-cse -finline -fpeephole -fomit-frame-pointer \
	 -fregmove -frerun-cse-after-loop -frerun-loop-opt -fschedule-insns \
         -fschedule-insns2 -fstrength-reduce -fthread-jumps \
	 -funroll-all-loops -funroll-loops -fmove-all-movables \
	 -freduce-all-givs -fstrict-aliasing -fstructure-noalias " ;;

    # This assumes GCC 2.7
    *gcc-2.[0-8]*) gcc_help="echo -ffloat-store -fdefault-inline -fdefer-pop \
        -fforce-mem -fforce-addr -fomit-frame-pointer -finline \
        -finline-functions -fkeep-inline-functions -ffunction-cse -ffast-math \
	-fstrength-reduce -fthread-jumps -fcse-follow-jumps \
	-fcse-skip-blocks -frerun-cse-after-loop -fexpensive-optimizations \
	-fdelayed-branch -fschedule-insns -fschedule-insns2 \
	-fcaller-saves -funroll-loops -funroll-all-loops -fpeephole " ;;

    # For GCC 2.95 and later, we have help available
    *) gcc_help="$CC -v --help" ;;
  esac
  changequote([, ])

  # Build a sed command line that changes the help
  set dummy -e h
  ifelse([$1], , , [
    for i in $1; do
       set "[$]@" -e g -e ["s/.*-f\($i\)[ 	].*/-f\1 /p"]
    done
  ])dnl
  ifelse([$2], , , [
    for i in $2; do
      set "[$]@" -e g -e ["s/.*-f\($i\)[ 	].*/-fno-\1 /p"]
    done
  ])dnl
])dnl

  wall=:
  wextra=:
  ifelse([$3], , , [
    for i in $3; do
      case $i in
	all) wall=false; CFLAGS="$CFLAGS -Wall" ;;
	extra) wextra=false; set "[$]@" -e g -e ["s/-W[ 	]/-W /p" -e g -e "s/-Wextra[ 	]/-Wextra /p" ;;]
	*) set "[$]@" -e g -e ["s/.*-W\($i\)[ 	].*/-W\1 /p" ;;]
      esac
    done
  ])dnl
  ifelse([$4], , , [
    for i in $4; do
      case $i in
	all) wall= ;;
	extra) wextra=false ;;
	*) set "[$]@" -e g -e ["s/.*-W\($i\)[ 	].*/-Wno-\1 /p" ;;]
      esac
    done
  ])dnl
  if test "$enable_warnings" != no; then
    $wall && CFLAGS="$CFLAGS -Wall"
    $wextra && set "[$]@" -e g -e ["s/-W[ 	]/-W /p" -e g -e "s/-Wextra[ 	]/-Wextra /p" ]
    ifelse([$5], , , [
      for i in $5; do
	set "[$]@" -e g -e ["s/.*-W\($i\)[ 	].*/-W\1 /p"]
      done
    ])dnl
  fi

  set "[$]@" -e d
  shift
  CFLAGS="$CFLAGS `$gcc_help 2>&1 | sed "[$]@" | sed -e H -e '$!d' -e g -e 's/\n//g'`"
fi

])dnl
