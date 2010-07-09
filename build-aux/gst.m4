dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
dnl AM_PATH_GST(MIN-REQ-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
dnl

AC_DEFUN([AM_PATH_GST],[

dnl Various autoconf user options

AC_ARG_WITH(gst,
AS_HELP_STRING([--with-gst=PFX], [Prefix where GNU Smalltalk is installed]),
gst_prefix="$withval", gst_prefix="")

    gst_old_PKG_CONFIG_PATH_set=${PKG_CONFIG_PATH+set}
    gst_old_PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
    if test x$gst_prefix != x; then
        : ${GST="$gst_prefix/bin/gst"}
        : ${GST_CONFIG="$gst_prefix/bin/gst-config"}
        : ${GST_PACKAGE="$gst_prefix/bin/gst-package"}
	gst_config_path=$gst_prefix/lib/pkgconfig
        PKG_CONFIG_PATH=$gst_config_path${PKG_CONFIG_PATH+:$PKG_CONFIG_PATH}
        export PKG_CONFIG_PATH
    fi

    PKG_PROG_PKG_CONFIG([0.7])
    AC_PATH_PROG([GST], [gst], no)
    AC_PATH_PROG([GST_CONFIG], [gst-config], no)
    AC_PATH_PROG([GST_PACKAGE], [gst-package], no)

    export PKG_CONFIG_PATH
    PKG_CHECK_MODULES(GST, [gnu-smalltalk[]m4_if([$1],[],[],[ >= $1])],
	[gstlibdir=`$PKG_CONFIG --variable=libdir gnu-smalltalk`
	 gstdatadir=`$PKG_CONFIG --variable=pkgdatadir gnu-smalltalk`
	 gstmoduledir=`$PKG_CONFIG --variable=moduledir gnu-smalltalk`
         gstmoduleexecdir='${gstmoduledir}'
	 have_gst=yes],
	[have_gst=no])

    PKG_CONFIG_PATH=$gst_old_PKG_CONFIG_PATH
    export PKG_CONFIG_PATH
    test x$gst_old_PKG_CONFIG_PATH_set = xset || unset PKG_CONFIG_PATH
    AS_IF([test $have_gst = yes], [$2], [$3])
    AC_SUBST(gstlibdir)
    AC_SUBST(gstdatadir)
     AC_SUBST(gstmoduledir)
     AC_SUBST(gstmoduleexecdir)
])
