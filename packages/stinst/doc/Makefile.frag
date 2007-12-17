ClassPublisher_FILES = \
packages/stinst/doc/Publish.st packages/stinst/doc/ChangeLog 
$(ClassPublisher_FILES):
$(srcdir)/packages/stinst/doc/stamp-classes: $(ClassPublisher_FILES)
	touch $(srcdir)/packages/stinst/doc/stamp-classes
