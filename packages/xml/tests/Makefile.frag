XML-ParserTests_FILES = \
packages/xml/tests/XMLPullParserTests.st 
$(XML-ParserTests_FILES):
$(srcdir)/packages/xml/tests/stamp-classes: $(XML-ParserTests_FILES)
	touch $(srcdir)/packages/xml/tests/stamp-classes
