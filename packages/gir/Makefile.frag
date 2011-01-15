GObject-Introspection_FILES = \
packages/gir/GIR.st 
$(GObject-Introspection_FILES):
$(srcdir)/packages/gir/stamp-classes: $(GObject-Introspection_FILES)
	touch $(srcdir)/packages/gir/stamp-classes
