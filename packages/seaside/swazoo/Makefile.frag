Seaside-Swazoo_FILES = \
packages/seaside/swazoo/Seaside-Adapters-Swazoo.st 
$(Seaside-Swazoo_FILES):
$(srcdir)/packages/seaside/swazoo/stamp-classes: $(Seaside-Swazoo_FILES)
	touch $(srcdir)/packages/seaside/swazoo/stamp-classes
