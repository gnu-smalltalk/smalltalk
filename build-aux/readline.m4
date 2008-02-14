dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_HAVE_READLINE], [

AC_ARG_WITH(readline, 
	[  --with-readline=path    set path to readline and termcap libraries
  --without-readline      don't try to detect readline])


if test "$with_readline" != no; then
  AC_CACHE_CHECK(how to link with readline, gst_cv_readline_libs, [
    test "$with_readline" && test -d "$with_readline" && \
      LDFLAGS="$LDFLAGS -L$with_readline" \
      CPPFLAGS="$CPPFLAGS -I$with_readline/../include"

    gst_cv_readline_libs="not found"
    ac_save_LIBS="$LIBS"
    for lib in "" -ltermcap -ltermlib -lncurses; do
      LIBS="$ac_save_LIBS -lreadline $lib"

      cat > conftest.$ac_ext <<\EOF
#include <stdio.h>
#include <readline/readline.h>
char *readline_quote_filename (const char *s, int rtype, const char *qcp)
{
  return (NULL);
}

int
main()
{
  rl_bind_key ('\t', rl_insert);
  /* This is missing in BSD libedit!  */
  rl_filename_quoting_function = (CPFunction *) readline_quote_filename;
  exit(0);
}
EOF
      # Link the program.  If not cross-compiling, run it too,
      # to detect shared library dependancies.

      ok=yes
      (AC_TRY_EVAL(ac_link) && test -s conftest${ac_exeext})	         || ok=no
      test $cross_compiling = no && test $ok = yes && (./conftest; exit) || ok=no
      rm -rf conftest*

      if test $ok = yes; then
        gst_cv_readline_libs="-lreadline $lib"
        test "x$with_readline" != x && test "$with_readline" != yes \
	  && test -d "$with_readline" \
	  && gst_cv_readline_libs="-L$with_readline $gst_cv_readline_libs"
        break
      fi
    done
    LIBS="$ac_save_LIBS"
  ])

  if test "$gst_cv_readline_libs" != "not found"; then
    LIBREADLINE="$gst_cv_readline_libs"
    AC_SUBST(LIBREADLINE)
    AC_DEFINE(HAVE_READLINE, 1,
          [Define if your system has the GNU readline library.])

    # Readline's ABI changed around version 4.2; test which
    # version is ours and work around the change if they have
    # an older readline.

    ac_save_LIBS="$LIBS"
    LIBS="$LIBS $LIBREADLINE"
    AC_CHECK_FUNC(rl_completion_matches, , [
      AC_DEFINE(rl_filename_completion_function, filename_completion_function,
                [Define to filename_completion_function if you have an older readline])
      AC_DEFINE(rl_username_completion_function, username_completion_function,
                [Define to username_completion_function if you have an older readline])
      AC_DEFINE(rl_completion_matches, completion_matches,
                [Define to completion_matches if you have an older readline])
    ])
    LIBS="$ac_save_LIBS"
  fi
fi

])dnl
