Iconv_FILES = \
packages/iconv/Sets.st packages/iconv/UTF7.st packages/iconv/iconvtests.st 
$(Iconv_FILES):
$(srcdir)/packages/iconv/stamp-classes: $(Iconv_FILES)
	touch $(srcdir)/packages/iconv/stamp-classes
