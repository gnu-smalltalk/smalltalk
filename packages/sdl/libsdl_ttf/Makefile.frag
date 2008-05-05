LibSDL_ttf_FILES = \
packages/sdl/libsdl_ttf/SDL_ttf.st 
$(LibSDL_ttf_FILES):
$(srcdir)/packages/sdl/libsdl_ttf/stamp-classes: $(LibSDL_ttf_FILES)
	touch $(srcdir)/packages/sdl/libsdl_ttf/stamp-classes
