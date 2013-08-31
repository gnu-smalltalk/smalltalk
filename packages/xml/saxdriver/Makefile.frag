XML-SAXDriver_FILES = \
packages/xml/saxdriver/SAX.st packages/xml/saxdriver/Events.st 
$(XML-SAXDriver_FILES):
$(srcdir)/packages/xml/saxdriver/stamp-classes: $(XML-SAXDriver_FILES)
	touch $(srcdir)/packages/xml/saxdriver/stamp-classes
