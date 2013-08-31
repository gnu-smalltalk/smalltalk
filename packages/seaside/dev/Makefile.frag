Seaside-Development_FILES = \
packages/seaside/dev/ChangeLog packages/seaside/dev/Seaside-Development-Core.st 
$(Seaside-Development_FILES):
$(srcdir)/packages/seaside/dev/stamp-classes: $(Seaside-Development_FILES)
	touch $(srcdir)/packages/seaside/dev/stamp-classes
