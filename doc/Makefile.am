EXTRA_DIST = $(HTML_IMAGES) categories

HTML_IMAGES = images/backon.png images/back.png images/blankon.png \
	images/blank.png images/forwardon.png images/forward.png \
	images/helpon.png images/help.png images/homeon.png \
	images/home.png images/inactive.png images/indexon.png \
	images/index.png images/nexton.png images/next.png \
	images/prevon.png images/prev.png images/tocon.png \
	images/toc.png images/upon.png images/up.png

dist_man_MANS = gst.1
HELP2MAN = $(top_srcdir)/config/help2man

info_TEXINFOS = gst.texi gst-base.texi gst-libs.texi
gst_TEXINFOS = tutorial.texi vers-gst.texi
gst_libs_TEXINFOS = blox.texi tcp.texi i18n.texi using-xml.texi vers-libs.texi
gst_base_TEXINFOS = classes.texi vers-base.texi
TEXI2DVI=pool_size=750000 $(top_srcdir)/config/texi2dvi --expand

MOSTLYCLEANFILES = gst-libs.me gst-libs.mes gst-base.me gst-base.mes \
	gst-libs.cl gst-libs.cls gst-base.cl gst-base.cls \
	gst-libs.sl gst-libs.sls gst-base.sl gst-base.sls

# The list of namespaces that are part of the printed manual
PUBLISHED_NAMESPACES = Smalltalk SystemExceptions NetClients VFS

$(srcdir)/gst.1: $(top_srcdir)/libgst/lib.c $(top_srcdir)/configure.ac
	$(HELP2MAN) --info-page gst \
	  --name "the GNU Smalltalk virtual machine" $(top_builddir)/gst >$@

$(srcdir)/blox.texi: $(top_builddir)/blox-tk/stamp-classes
	touch $(srcdir)/gst-libs.texi
	builddir=`pwd`; top_builddir=$$builddir/$(top_builddir); \
	SMALLTALK_IMAGE=$$top_builddir; export SMALLTALK_IMAGE; \
	GST=$$top_builddir/gst; \
	cd $(top_srcdir)/blox-tk && echo " \
	  PackageLoader fileInPackage: 'Parser'. \
	  Smalltalk addSubspace: #BLOX! \
          | source list classes | \
	  list := FileStream open: 'stamp-classes' mode: FileStream read. \
	  source := list lines \
	    inject: ConcatenatedStream new \
	    into: [ :str :each | str, (FileStream open: each mode: FileStream read) ]. \
	  Namespace current: BLOX. \
	  classes := STInST STClassLoader parseSmalltalkStream: source. \
	  Namespace current: Smalltalk. \
	  ClassPublisher Texinfo \
		publishAll: classes \
		onFile: '../doc/blox.texi'!" | $$GST -g \
	  ../examples/Publish.st \
	  ../examples/StreamFilter.st -

$(srcdir)/tcp.texi: $(top_builddir)/tcp/stamp-classes
	touch $(srcdir)/gst-libs.texi
	builddir=`pwd`; top_builddir=$$builddir/$(top_builddir); \
	SMALLTALK_IMAGE=$$top_builddir; export SMALLTALK_IMAGE; \
	GST=$$top_builddir/gst; \
	cd $(top_srcdir)/tcp && echo " \
	  PackageLoader fileInPackage: 'Parser'. \
	  Smalltalk addSubspace: #TCP! \
	  | source list classes | \
	  list := FileStream open: 'stamp-classes' mode: FileStream read. \
	  source := list lines \
	    inject: ConcatenatedStream new \
	    into: [ :str :each | str, (FileStream open: each mode: FileStream read) ]. \
	  Namespace current: TCP. \
	  classes := STInST STClassLoader parseSmalltalkStream: source. \
	  Namespace current: Smalltalk. \
	  ClassPublisher Texinfo \
		publishAll: classes \
		onFile: '../doc/tcp.texi'!" | $$GST -g \
	  ../examples/Publish.st \
	  ../examples/StreamFilter.st -

$(srcdir)/i18n.texi: $(top_builddir)/i18n/stamp-classes
	touch $(srcdir)/gst-libs.texi
	builddir=`pwd`; top_builddir=$$builddir/$(top_builddir); \
	SMALLTALK_IMAGE=$$top_builddir; export SMALLTALK_IMAGE; \
	GST=$$top_builddir/gst; \
	cd $(top_srcdir)/i18n && echo " \
	  PackageLoader fileInPackage: 'Parser'. \
	  Smalltalk addSubspace: #I18N! \
	  | source list classes | \
	  list := FileStream open: 'stamp-classes' mode: FileStream read. \
	  source := list lines \
	    inject: ConcatenatedStream new \
	    into: [ :str :each | str, (FileStream open: each mode: FileStream read) ]. \
	  Namespace current: I18N. \
	  classes := STInST STClassLoader parseSmalltalkStream: source. \
	  Namespace current: Smalltalk. \
	  ClassPublisher Texinfo \
		publishAll: classes \
		onFile: '../doc/i18n.texi'!" | $$GST -g \
	  ../examples/Publish.st \
	  ../examples/StreamFilter.st -

$(srcdir)/classes.texi: $(top_builddir)/kernel/stamp-classes
	touch $(srcdir)/gst-base.texi
	@builddir=`pwd`; top_builddir=$$builddir/$(top_builddir); \
	SMALLTALK_IMAGE=$$top_builddir; export SMALLTALK_IMAGE; \
	GST=$$top_builddir/gst; \
	echo 'cd $(top_srcdir) &&'; \
	  echo '  echo "ClassPublisher Texinfo publishNamespaces: #('; \
	  echo "$(PUBLISHED_NAMESPACES)" | sed \
	    -e 's/[A-Za-z][A-Za-z]*/#{&}/g' \
	    -e 's/^/	/' \
	    -e '$$s/$$/)!\" |/'; \
	  echo "  `pwd`/$(top_builddir)/gst examples/Publish.st - -g"; \
	cd $(top_srcdir) && \
	  echo "$(PUBLISHED_NAMESPACES)" | sed \
	    -e 's/[A-Za-z][A-Za-z]*/#{&}/g' \
	    -e '1s/^/ClassPublisher Texinfo publishNamespaces: #(/' \
	    -e '$$s/$$/)!/' | \
	      $$GST examples/Publish.st - -g


# In TeX output, having colons in index entries looks pretty, but
# this is impossible in info output!!!  So we hack by replacing
# colons with underscores in the info file.
.texi.info:
	@cd $(srcdir) && rm -f $@ $@-[0-9] $@-[0-9][0-9]
	fixed=`pwd`/`echo $< | sed 's/\.texi/-fixed&/' `; \
	  cd $(srcdir) && \
	  $(MAKEINFO) `echo $< | sed 's,.*/,,'` -E - -o /dev/null | \
	  sed '/^@..index/ s/:/_/g' > $$fixed && \
	  $(MAKEINFO) $$fixed > /dev/null 2>&1 && \
	  rm -f $$fixed

# We want the HTML doc to look professional, so we use makeinfo first.
# This rule is very complex.  What it does is:
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
	-$(RM) -r html
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
	  $$srcdir/../config/texi2html -Verbose -split section gst.texi && \
	  $$srcdir/../config/texi2html -Verbose -split section gst-libs.texi && \
	  $$srcdir/../config/texi2html -Verbose -split section gst-base.texi && \
	  ln -sf $$srcdir/images $$htmldir/images && \
	  $(RM) $$htmldir/gst.texi $$htmldir/gst-libs.texi $$htmldir/gst-base.texi

clean: clean-html

clean-html:
	$(RM) -r html

.PHONY: clean-html
