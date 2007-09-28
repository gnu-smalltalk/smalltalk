XPath_FILES = \
packages/xpath/XPath.st 
$(XPath_FILES):
$(srcdir)/packages/xpath/stamp-classes: $(XPath_FILES)
	touch $(srcdir)/packages/xpath/stamp-classes
