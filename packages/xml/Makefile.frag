XML_FILES = \
packages/xml/XML.st packages/xml/ChangeLog 
$(XML_FILES):
$(srcdir)/packages/xml/stamp-classes: $(XML_FILES)
	touch $(srcdir)/packages/xml/stamp-classes
