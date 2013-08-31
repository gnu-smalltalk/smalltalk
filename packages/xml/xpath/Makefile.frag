XPath_FILES = \
packages/xml/xpath/XPath.st 
$(XPath_FILES):
$(srcdir)/packages/xml/xpath/stamp-classes: $(XPath_FILES)
	touch $(srcdir)/packages/xml/xpath/stamp-classes
