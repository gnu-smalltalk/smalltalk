dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
AC_DEFUN([GST_FUNC_LOCALTIME], [

AC_CACHE_CHECK(whether localtime caches the timezone, emacs_cv_localtime_cache,
[AC_REQUIRE([AC_HEADER_TIME])
AC_TRY_RUN(
    [#if defined(HAVE_SYS_TIME_H) || defined(TIME_WITH_SYS_TIME)
    # include <sys/time.h>
    #endif
    #if !defined(HAVE_SYS_TIME_H) || defined(TIME_WITH_SYS_TIME)
    # include <time.h>
    #endif
    #if STDC_HEADERS
    # include <stdlib.h>
    #endif

    extern char **environ;
    unset_TZ ()
    {
      char **from, **to;
      for (to = from = environ; (*to = *from); from++)
        if (! (to[0][0] == 'T' && to[0][1] == 'Z' && to[0][2] == '='))
          to++;
    }
    char TZ_GMT0[] = "TZ=GMT0";
    char TZ_PST8[] = "TZ=PST8";
    main()
    {
      time_t now = time ((time_t *) 0);
      int hour_GMT0, hour_unset;
      if (putenv (TZ_GMT0) != 0)
        exit (1);
      hour_GMT0 = localtime (&now)->tm_hour;
      unset_TZ ();
      hour_unset = localtime (&now)->tm_hour;
      if (putenv (TZ_PST8) != 0)
        exit (1);
      if (localtime (&now)->tm_hour == hour_GMT0)
        exit (1);
      unset_TZ ();
      if (localtime (&now)->tm_hour != hour_unset)
        exit (1);
      exit (0);
    }],
    emacs_cv_localtime_cache=no, emacs_cv_localtime_cache=yes,

    [# Assume the worst when cross-compiling.
    emacs_cv_localtime_cache=yes])
])
test $emacs_cv_localtime_cache = yes && \
  AC_DEFINE(LOCALTIME_CACHE, 1, [Define if your system's localtime(3) caches the timezone.])

])dnl
