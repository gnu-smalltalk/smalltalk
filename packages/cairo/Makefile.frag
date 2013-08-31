Cairo_FILES = \
packages/cairo/CairoContext.st packages/cairo/CairoFuncs.st packages/cairo/CairoPattern.st packages/cairo/CairoSurface.st packages/cairo/CairoTransform.st 
$(Cairo_FILES):
$(srcdir)/packages/cairo/stamp-classes: $(Cairo_FILES)
	touch $(srcdir)/packages/cairo/stamp-classes
