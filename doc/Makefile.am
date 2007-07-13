EXTRA_DIST = $(HTML_IMAGES) categories

HTML_IMAGES = images/backon.png images/back.png images/blankon.png \
	images/blank.png images/forwardon.png images/forward.png \
	images/helpon.png images/help.png images/homeon.png \
	images/home.png images/inactive.png images/indexon.png \
	images/index.png images/nexton.png images/next.png \
	images/prevon.png images/prev.png images/tocon.png \
	images/toc.png images/upon.png images/up.png

dist_man_MANS = gst.1 gst-load.1 gst-package.1 gst-sunit.1 gst-config.1 gst-convert.1
HELP2MAN = $(top_srcdir)/build-aux/help2man -p gst

info_TEXINFOS = gst.texi gst-base.texi gst-libs.texi
gst_TEXINFOS = tutorial.texi vers-gst.texi
gst_libs_TEXINFOS = blox.texi tcp.texi i18n.texi using-xml.texi vers-libs.texi
gst_base_TEXINFOS = classes.texi vers-base.texi
TEXI2DVI=pool_size=750000 $(top_srcdir)/build-aux/texi2dvi --expand

MOSTLYCLEANFILES = gst-libs.me gst-libs.mes gst-base.me gst-base.mes \
	gst-libs.cl gst-libs.cls gst-base.cl gst-base.cls \
	gst-libs.sl gst-libs.sls gst-base.sl gst-base.sls

####################################################
##
##  Rule to build the man page
##
####################################################

$(srcdir)/gst-package.1: $(top_srcdir)/scripts/Package.st $(top_srcdir)/configure.ac
	$(HELP2MAN) \
	  --name "create and install GNU Smalltalk .star package files" \
	  "$(top_builddir)/gst-tool gst-package -I $(top_builddir)/gst.im \
	     --kernel-directory $(top_srcdir)/kernel" >$@

$(srcdir)/gst-convert.1: $(top_srcdir)/scripts/Load.st $(top_srcdir)/configure.ac
	$(HELP2MAN) \
	  --name "Smalltalk syntax converter and beautifier" \
	  "$(top_builddir)/gst-tool gst-convert -I $(top_builddir)/gst.im \
	     --kernel-directory $(top_srcdir)/kernel" >$@

$(srcdir)/gst-load.1: $(top_srcdir)/scripts/Load.st $(top_srcdir)/configure.ac
	$(HELP2MAN) \
	  --name "test and load packages into a GNU Smalltalk image" \
	  "$(top_builddir)/gst-tool gst-load -I $(top_builddir)/gst.im \
	     --kernel-directory $(top_srcdir)/kernel" >$@

$(srcdir)/gst-sunit.1: $(top_srcdir)/scripts/Test.st $(top_srcdir)/configure.ac
	$(HELP2MAN) \
	  --name "unit testing tool for GNU Smalltalk" \
	  "$(top_builddir)/gst-tool gst-load -I $(top_builddir)/gst.im \
	     --kernel-directory $(top_srcdir)/kernel" >$@

$(srcdir)/gst.1: $(top_srcdir)/main.c $(top_srcdir)/configure.ac
	$(HELP2MAN) \
	  --name "the GNU Smalltalk virtual machine" $(top_builddir)/gst >$@

$(srcdir)/gst-config.1: $(top_builddir)/gst-config
	$(HELP2MAN) \
	  --name "configuration for libgst" $(top_builddir)/gst-config >$@

uninstall-local:
	rm -f $(DESTDIR)$(man1dir)/gst-reload.1

install-data-local: install-man
	rm -f $(DESTDIR)$(man1dir)/gst-reload.1
	$(LN_S) $(DESTDIR)$(man1dir)/gst-load.1 $(DESTDIR)$(man1dir)/gst-reload.1

####################################################
##
##  Rules to build the generated documentation
##
####################################################

PUBLISHED_NAMESPACES = Smalltalk SystemExceptions NetClients VFS

$(srcdir)/blox.texi: $(top_srcdir)/packages/blox/tk/stamp-classes
	rm -f $(srcdir)/blox.texi
	cd $(srcdir) && @abs_top_builddir@/gst -I @abs_top_builddir@/gst.im \
	    -f ../scripts/GenLibDoc.st BLOX BloxTK blox.texi Blox.st
	test -f $(srcdir)/blox.texi && touch $(srcdir)/gst-libs.texi 

$(srcdir)/tcp.texi: $(top_srcdir)/packages/tcp/stamp-classes
	rm -f $(srcdir)/tcp.texi
	cd $(srcdir) && @abs_top_builddir@/gst -I @abs_top_builddir@/gst.im \
	    -f ../scripts/GenLibDoc.st TCP TCP tcp.texi TCP.st
	test -f $(srcdir)/tcp.texi && touch $(srcdir)/gst-libs.texi 

$(srcdir)/i18n.texi: $(top_srcdir)/packages/i18n/stamp-classes
	rm -f $(srcdir)/i18n.texi
	cd $(srcdir) && @abs_top_builddir@/gst -I @abs_top_builddir@/gst.im \
	    -f ../scripts/GenLibDoc.st I18N I18N i18n.texi Load.st Collation.st
	test -f $(srcdir)/i18n.texi && touch $(srcdir)/gst-libs.texi 

$(srcdir)/classes.texi: $(top_srcdir)/kernel/stamp-classes
	rm -f $(srcdir)/classes.texi
	cd $(srcdir) && @abs_top_builddir@/gst -I @abs_top_builddir@/gst.im \
	    -f ../scripts/GenBaseDoc.st $(PUBLISHED_NAMESPACES)
	test -f $(srcdir)/classes.texi && touch $(srcdir)/gst-base.texi

# In TeX output, having colons in index entries looks pretty, but
# this is impossible in info output!!!  So we hack by replacing
# colons with underscores in the info file.
.texi.info:
	@cd $(srcdir) && rm -f $@ $@-[0-9] $@-[0-9][0-9]
	fixed=`pwd`/`echo $< | $(SED) 's/\.texi/-fixed&/' `; \
	  cd $(srcdir) && \
	  $(MAKEINFO) `echo $< | $(SED) 's,.*/,,'` -E - -o /dev/null | \
	  $(SED) '/^@..index/ s/:/_/g' > $$fixed && \
	  $(MAKEINFO) $$fixed > /dev/null 2>&1 && \
	  rm -f $$fixed

####################################################
##
##  Rules to build the HTML documentation
##
####################################################

# We want the HTML doc to look professional, so we use makeinfo first.
# This rule is pretty complex.  What it does is:
#  - check whether /usr/bin/env perl works
#  - check whether we have makeinfo (it could be faked by the missing script)
#  - check whether we have makeinfo 4.0
#  - resolve macros in gst.texi using makeinfo
#  - finally invoke texi2html
#  - remove the temporary file with resolved macros
html: $(srcdir)/gst.texi $(srcdir)/gst-base.texi $(srcdir)/gst-libs.texi
	@(echo 'print "ohyeah"' | perl | grep ohyeah) > /dev/null 2>&1 || \
	    (echo "You need Perl to make HTML documentation"; exit 1)
	@($(MAKEINFO) --version 2>&1 | grep missing:) > /dev/null 2>&1 || exit 0; \
	    (echo "You need Makeinfo to make HTML documentation"; exit 1)
	rm -rf html
	mkdir html
	@echo "Building HTML documentation may be a long task... please wait"
	($(MAKEINFO) --help | grep ifhtml) > /dev/null 2>&1 && makeinfo4=yes; \
	  htmldir=`pwd`/html && \
	  cd $(srcdir) && \
	  srcdir=`pwd` && \
	  $(MAKEINFO) gst.texi -E $$htmldir/gst.texi \
	    $${makeinfo4+--no-iftex --no-ifinfo --ifhtml} -o /dev/null && \
	  $(MAKEINFO) gst-libs.texi -E $$htmldir/gst-libs.texi \
	    $${makeinfo4+--no-iftex --no-ifinfo --ifhtml} -o /dev/null && \
	  $(MAKEINFO) gst-base.texi -E $$htmldir/gst-base.texi \
	    $${makeinfo4+--no-iftex --no-ifinfo --ifhtml} -o /dev/null && \
	  cd $$htmldir && \
	  $$srcdir/../build-aux/texi2html -Verbose -split section gst.texi && \
	  $$srcdir/../build-aux/texi2html -Verbose -split section gst-libs.texi && \
	  $$srcdir/../build-aux/texi2html -Verbose -split section gst-base.texi && \
	  ln -sf $$srcdir/images $$htmldir/images && \
	  $(RM) $$htmldir/gst.texi $$htmldir/gst-libs.texi $$htmldir/gst-base.texi

clean-local:
	$(RM) -r html

.PHONY: clean-html
