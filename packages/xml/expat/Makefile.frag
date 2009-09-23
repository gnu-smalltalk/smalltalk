XML-Expat_FILES = \
packages/xml/expat/ExpatPullParser.st packages/xml/expat/ExpatParser.st packages/xml/expat/ExpatTests.st 
$(XML-Expat_FILES):
$(srcdir)/packages/xml/expat/stamp-classes: $(XML-Expat_FILES)
	touch $(srcdir)/packages/xml/expat/stamp-classes
