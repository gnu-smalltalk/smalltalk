Complex_FILES = \
packages/complex/ChangeLog packages/complex/Complex.st packages/complex/complextests.st 
$(Complex_FILES):
$(srcdir)/packages/complex/stamp-classes: $(Complex_FILES)
	touch $(srcdir)/packages/complex/stamp-classes
