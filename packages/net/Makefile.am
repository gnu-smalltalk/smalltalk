pkglibexecdir = $(libexecdir)/$(PACKAGE)
pkglibexec_PROGRAMS = gnutls-wrapper
gnutls_wrapper_SOURCES = gnutls-wrapper.c
gnutls_wrapper_LDADD = $(GNUTLS_LIBS) \
	$(top_builddir)/lib-src/library.la $(SOCKET_LIBS)

AM_CPPFLAGS = $(GNUTLS_CFLAGS) -I$(top_srcdir)/lib-src
