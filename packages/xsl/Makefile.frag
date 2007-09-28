XSL_FILES = \
packages/xsl/XSL.st 
$(XSL_FILES):
$(srcdir)/packages/xsl/stamp-classes: $(XSL_FILES)
	touch $(srcdir)/packages/xsl/stamp-classes
