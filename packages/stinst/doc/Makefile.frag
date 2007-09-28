ClassPublisher_FILES = \
packages/stinst/doc/Publish.st 
$(ClassPublisher_FILES):
$(srcdir)/packages/stinst/doc/stamp-classes: $(ClassPublisher_FILES)
	touch $(srcdir)/packages/stinst/doc/stamp-classes
