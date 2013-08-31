ClassPublisher_FILES = \
packages/stinst/doc/ChangeLog packages/stinst/doc/HTML.st packages/stinst/doc/PSFileOut.st packages/stinst/doc/Publish.st packages/stinst/doc/Texinfo.st 
$(ClassPublisher_FILES):
$(srcdir)/packages/stinst/doc/stamp-classes: $(ClassPublisher_FILES)
	touch $(srcdir)/packages/stinst/doc/stamp-classes
