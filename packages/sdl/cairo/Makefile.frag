CairoSDL_FILES = \
packages/sdl/cairo/CairoSDL.st 
$(CairoSDL_FILES):
$(srcdir)/packages/sdl/cairo/stamp-classes: $(CairoSDL_FILES)
	touch $(srcdir)/packages/sdl/cairo/stamp-classes
