XML-SAXParser_FILES = \
packages/xml/saxparser/Parser.st 
$(XML-SAXParser_FILES):
$(srcdir)/packages/xml/saxparser/stamp-classes: $(XML-SAXParser_FILES)
	touch $(srcdir)/packages/xml/saxparser/stamp-classes
