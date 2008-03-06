Seaside-Examples_FILES = \
packages/seaside/examples/Seaside-Examples.st packages/seaside/examples/Seaside-Tests-Functional.st 
$(Seaside-Examples_FILES):
$(srcdir)/packages/seaside/examples/stamp-classes: $(Seaside-Examples_FILES)
	touch $(srcdir)/packages/seaside/examples/stamp-classes
