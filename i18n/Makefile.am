i18ndir = $(pkgdatadir)/i18n
localedir = $(datadir)/locale

EXTRA_DIST = ref-add.sin ref-del.sin config.charset

dist_noinst_DATA = stamp-classes

noinst_SCRIPTS = ref-add.sed ref-del.sed
CLEANFILES = ref-add.sed ref-del.sed charset.alias

EXTRA_LTLIBRARIES = i18n.la
pkglib_LTLIBRARIES = @MODULES_I18N@

AM_CPPFLAGS = -DLOCALEDIR="\"$(localedir)\"" -DLIBDIR="\"$(libdir)\""

i18n_la_LIBADD = $(LIBICONV) $(top_builddir)/lib-src/library.la
i18n_la_LDFLAGS = -module -rpath $(pkglibdir) -no-undefined \
	-release $(VERSION)
i18n_la_SOURCES = i18n.c localcharset.c

INCLUDES = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src

$(srcdir)/stamp-classes: \
GetText.st	Load.st		Locale.st	Expression.st	\
Numbers.st     Times.st		Collation.st	Sets.st
	@echo Updating $@
	@sed -n "s/.*'\([^']*\.st\)'.*/\1/p" $(srcdir)/Load.st>$@


# These rules are from GNU gettext

.sin.sed:
	sed -e '/^#/d' -e 's/@''PACKAGE''@/@PACKAGE@/g' $< > t-$@
	mv t-$@ $@

charset.alias: config.charset
	$(SHELL) $(srcdir)/config.charset '@host@' > t-$@
	mv t-$@ $@

install-data-local:
	@$(POST_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(libdir); \
	temp=$(DESTDIR)$(libdir)/t-charset.alias; \
	dest=$(DESTDIR)$(libdir)/charset.alias; \
	if test -f $(DESTDIR)$(libdir)/charset.alias; then \
	  orig=$(DESTDIR)$(libdir)/charset.alias; \
	  sed -f ref-add.sed $$orig > $$temp; \
	  $(INSTALL_DATA) $$temp $$dest; \
	  rm -f $$temp; \
	else \
	  if test @GLIBC21@ = no; then \
	    orig=charset.alias; \
	    sed -f ref-add.sed $$orig > $$temp; \
	    $(INSTALL_DATA) $$temp $$dest; \
	    rm -f $$temp; \
	  fi; \
	fi

uninstall-local:
	@$(PRE_UNINSTALL)
	if test -f $(DESTDIR)$(libdir)/charset.alias; then \
	  temp=$(DESTDIR)$(libdir)/t-charset.alias; \
	  dest=$(DESTDIR)$(libdir)/charset.alias; \
	  sed -f ref-del.sed $$dest > $$temp; \
	  if grep '^# Packages using this file: $$' $$temp > /dev/null; then \
	    rm -f $$dest; \
	  else \
	    $(INSTALL_DATA) $$temp $$dest; \
	  fi; \
	  rm -f $$temp; \
	fi

