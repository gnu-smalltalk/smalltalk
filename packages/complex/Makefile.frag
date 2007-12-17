Complex_FILES = \
packages/complex/Complex.st packages/complex/complextests.st packages/complex/ChangeLog 
$(Complex_FILES):
$(srcdir)/packages/complex/stamp-classes: $(Complex_FILES)
	touch $(srcdir)/packages/complex/stamp-classes
