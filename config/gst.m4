dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
dnl AM_PATH_GST(MIN-REQ-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
dnl

AC_DEFUN([AM_PATH_GST],[

dnl Various autoconf user options

AC_ARG_WITH(gst,
[  --with-gst=PFX   ]dnl
[Prefix where GNU Smalltalk is installed],
gst_prefix="$withval", gst_prefix="")

    if test x$gst_prefix != x; then
        GST_CONFIG="$gst_prefix/bin/gst-config"
    fi

    have_gst="no";
     
    AC_PATH_PROG(GST_CONFIG, gst-config, no)
    min_gst_version=ifelse([$1],,0.0.0,$1)
    AC_MSG_CHECKING(for GNU Smalltalk version >= $min_gst_version)
    if test "x$GST_CONFIG" != xno; then
        GST_CFLAGS=`$GST_CONFIG --cflags`
        GST_LIBS=`$GST_CONFIG --libs $extra_libs`
        GST_PREFIX=`$GST_CONFIG --prefix`

        gst_config_major_version=`$GST_CONFIG --version | \
            sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
        gst_config_minor_version=`$GST_CONFIG --version | \
            sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
        gst_config_micro_version=`$GST_CONFIG --version | \
            sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`

        # Later we should do actual tests on the library
        gst_req_major_version=`echo $min_gst_version | \
            sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
        gst_req_minor_version=`echo $min_gst_version | \
            sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
        gst_req_micro_version=`echo $min_gst_version | \
            sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`

        if test $gst_req_major_version -lt $gst_config_major_version; then
            have_gst="yes"
        elif test $gst_req_major_version -eq $gst_config_major_version && \
                test $gst_req_minor_version -lt $gst_config_minor_version; then
            have_gst="yes"
        elif test $gst_req_major_version -eq $gst_config_major_version && \
                test $gst_req_minor_version -eq $gst_config_minor_version && \
                test $gst_req_micro_version -le $gst_config_micro_version; then
            have_gst="yes"
        fi
    fi

    if test "x$have_gst" = xyes; then
        AC_MSG_RESULT(yes)
        ifelse([$2], , :, [$2])
    else
        AC_MSG_RESULT(no)
        if test "x$GST_CONFIG" = xno; then
            echo "*** The gst-config script could not be found. This script"
            echo "*** needs to be in the PATH, or should be specified using"
            echo "*** the --with-gst option to configure."
        fi

	GST_CFLAGS=""
	GST_LIBS=""
	ifelse([$3], , :, [$3])
    fi

    AC_SUBST(GST_CFLAGS)
    AC_SUBST(GST_LIBS)
    AC_SUBST(GST_PREFIX)
])    
