Iconv_FILES = \
packages/iconv/iconvtests.st packages/iconv/Sets.st packages/iconv/UTF7.st 
$(Iconv_FILES):
$(srcdir)/packages/iconv/stamp-classes: $(Iconv_FILES)
	touch $(srcdir)/packages/iconv/stamp-classes
