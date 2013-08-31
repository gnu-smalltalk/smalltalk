Magritte-Seaside_FILES = \
packages/seaside/magritte/magritte-seaside.st 
$(Magritte-Seaside_FILES):
$(srcdir)/packages/seaside/magritte/stamp-classes: $(Magritte-Seaside_FILES)
	touch $(srcdir)/packages/seaside/magritte/stamp-classes
