AUTOMAKE_OPTIONS	= gnu no-dependencies

CLEANFILES              = snprintfv.fns snprintfv.pgs snprintfv.tps
MAINTAINERCLEANFILES    = filament.stamp printf.stamp stream.stamp mem.stamp
BUILT_SOURCES		= filament.texi printf.texi stream.texi mem.texi

info_TEXINFOS		= snprintfv.texi
snprintfv_TEXINFOS      = $(BUILT_SOURCES) version.texi \
			  stdio.texi rprintf.c.texi fdl.texi

EXTRA_DIST		= api-comment-style.txt gnome-doc.el \
			  $(MAINTAINERCLEANFILES)

SUFFIXES		= .info .texi .h


# Bah!  various flavours of awk treat gendoc slightly differently =(O|
# AWK			= @AWK@
AWK			= gawk

GENDOC			= $(AWK) -v format=SNV_GNUC_PRINTF \
			-f $(top_srcdir)/gendoc.awk

# Create these in the source directory because that is where
# they are when the distribution tarball is unpacked.

$(srcdir)/%.texi: %.stamp
	@:

%.stamp: $(top_builddir)/snprintfv/%.h
	@file=`echo $@ | $(SED) 's,\.stamp$$,.texi,'`; \
	$(GENDOC) $< > $${file}T; \
	if cmp -s $(srcdir)/$$file $${file}T; then \
	  rm -f $${file}T; \
	else \
	  echo creating $(srcdir)/$$file; mv -f $${file}T $(srcdir)/$$file; \
	fi
	@echo timestamp > $@

$(srcdir)/filament.texi: filament.stamp
$(srcdir)/printf.texi: printf.stamp
$(srcdir)/stream.texi: stream.stamp
$(srcdir)/mem.texi: mem.stamp
filament.stamp: $(top_builddir)/snprintfv/filament.h
printf.stamp: $(top_builddir)/snprintfv/printf.h
stream.stamp: $(top_builddir)/snprintfv/stream.h
mem.stamp: $(top_builddir)/snprintfv/mem.h

