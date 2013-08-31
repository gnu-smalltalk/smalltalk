Cairo_FILES = \
packages/cairo/CairoFuncs.st packages/cairo/CairoContext.st packages/cairo/CairoTransform.st packages/cairo/CairoSurface.st packages/cairo/CairoPattern.st 
$(Cairo_FILES):
$(srcdir)/packages/cairo/stamp-classes: $(Cairo_FILES)
	touch $(srcdir)/packages/cairo/stamp-classes
