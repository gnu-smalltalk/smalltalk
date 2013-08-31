LibSDL_image_FILES = \
packages/sdl/libsdl_image/SDL_image.st 
$(LibSDL_image_FILES):
$(srcdir)/packages/sdl/libsdl_image/stamp-classes: $(LibSDL_image_FILES)
	touch $(srcdir)/packages/sdl/libsdl_image/stamp-classes
