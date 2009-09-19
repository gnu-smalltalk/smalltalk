XML-PullParser_FILES = \
packages/xml/pullparser/XMLPullParser.st packages/xml/pullparser/XMLPullParserTests.st 
$(XML-PullParser_FILES):
$(srcdir)/packages/xml/pullparser/stamp-classes: $(XML-PullParser_FILES)
	touch $(srcdir)/packages/xml/pullparser/stamp-classes
