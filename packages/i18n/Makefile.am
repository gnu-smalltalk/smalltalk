moduleexec_LTLIBRARIES = i18n.la

gst_module_ldflags = -rpath $(moduleexecdir) -release $(VERSION) -module \
	-no-undefined -export-symbols-regex gst_initModule

i18n_la_LDFLAGS = $(gst_module_ldflags)
i18n_la_SOURCES = i18n.c localcharset.c

AM_CPPFLAGS = -I$(top_srcdir)/libgst -I$(top_srcdir)/lib-src \
	-DLOCALEDIR="\"$(localedir)\"" -DLIBDIR="\"$(libdir)\""

# These rules are from GNU gettext

EXTRA_DIST = ref-add.sin ref-del.sin config.charset
noinst_SCRIPTS = ref-add.sed ref-del.sed
CLEANFILES = ref-add.sed ref-del.sed charset.alias

.sin.sed:
	$(SED) -e '/^#/d' -e 's/@''PACKAGE''@/@PACKAGE@/g' $< > t-$@
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
	  $(SED) -f ref-add.sed $$orig > $$temp; \
	  $(INSTALL_DATA) $$temp $$dest; \
	  rm -f $$temp; \
	else \
	  if test @GLIBC21@ = no; then \
	    orig=charset.alias; \
	    $(SED) -f ref-add.sed $$orig > $$temp; \
	    $(INSTALL_DATA) $$temp $$dest; \
	    rm -f $$temp; \
	  fi; \
	fi

uninstall-local:
	@$(PRE_UNINSTALL)
	if test -f $(DESTDIR)$(libdir)/charset.alias; then \
	  temp=$(DESTDIR)$(libdir)/t-charset.alias; \
	  dest=$(DESTDIR)$(libdir)/charset.alias; \
	  $(SED) -f ref-del.sed $$dest > $$temp; \
	  if grep '^# Packages using this file: $$' $$temp > /dev/null; then \
	    rm -f $$dest; \
	  else \
	    $(INSTALL_DATA) $$temp $$dest; \
	  fi; \
	  rm -f $$temp; \
	fi

