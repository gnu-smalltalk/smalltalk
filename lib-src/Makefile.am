noinst_LTLIBRARIES = library.la

library_la_LIBADD =  @LTLIBOBJS@ @LTALLOCA@ $(LIBADD_DL)
library_la_DEPENDENCIES =  @LTLIBOBJS@ @LTALLOCA@

# These are to be included *always*, the rest are driven by configure.in
library_la_SOURCES = \
       qsort.c getopt.c getopt1.c md5.c avltrees.c rbtrees.c \
       strspell.c signalx.c ltdl.c

noinst_HEADERS = \
       obstack.h poll_.h getopt.h md5.h ansidecl.h strspell.h \
       mathl.h trigl.h avltrees.h rbtrees.h trigl.c sincosl.c \
       signalx.h socketx.h ltdl.h

DISTCLEANFILES = stdintx.h poll.h

