XML_FILES = \
packages/xml/DOM.st packages/xml/NodeBuilder.st packages/xml/Parser.st packages/xml/SAX.st packages/xml/XML.st packages/xml/ChangeLog 
$(XML_FILES):
$(srcdir)/packages/xml/stamp-classes: $(XML_FILES)
	touch $(srcdir)/packages/xml/stamp-classes
