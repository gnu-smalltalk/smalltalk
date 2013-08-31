Seaside-Development_FILES = \
packages/seaside/dev/Seaside-Development-Core.st packages/seaside/dev/ChangeLog 
$(Seaside-Development_FILES):
$(srcdir)/packages/seaside/dev/stamp-classes: $(Seaside-Development_FILES)
	touch $(srcdir)/packages/seaside/dev/stamp-classes
