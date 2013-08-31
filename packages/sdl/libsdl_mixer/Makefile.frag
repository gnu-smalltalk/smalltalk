LibSDL_mixer_FILES = \
packages/sdl/libsdl_mixer/SDL_mixer.st 
$(LibSDL_mixer_FILES):
$(srcdir)/packages/sdl/libsdl_mixer/stamp-classes: $(LibSDL_mixer_FILES)
	touch $(srcdir)/packages/sdl/libsdl_mixer/stamp-classes
