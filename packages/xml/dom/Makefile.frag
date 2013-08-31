XML-DOM_FILES = \
packages/xml/dom/DOM.st 
$(XML-DOM_FILES):
$(srcdir)/packages/xml/dom/stamp-classes: $(XML-DOM_FILES)
	touch $(srcdir)/packages/xml/dom/stamp-classes
