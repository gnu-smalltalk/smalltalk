XSL_FILES = \
packages/xml/xsl/XSL.st 
$(XSL_FILES):
$(srcdir)/packages/xml/xsl/stamp-classes: $(XSL_FILES)
	touch $(srcdir)/packages/xml/xsl/stamp-classes
