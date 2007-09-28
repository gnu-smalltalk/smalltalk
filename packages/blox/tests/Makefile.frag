Blox_FILES = \
packages/blox/tests/test.st 
$(Blox_FILES):
$(srcdir)/packages/blox/tests/stamp-classes: $(Blox_FILES)
	touch $(srcdir)/packages/blox/tests/stamp-classes
