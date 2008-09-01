Seaside_FILES = \
packages/seaside/swazoo/Seaside-Adapters-Swazoo.st packages/seaside/swazoo/ChangeLog 
$(Seaside_FILES):
$(srcdir)/packages/seaside/swazoo/stamp-classes: $(Seaside_FILES)
	touch $(srcdir)/packages/seaside/swazoo/stamp-classes
