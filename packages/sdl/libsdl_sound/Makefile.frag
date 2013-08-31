LibSDL_sound_FILES = \
packages/sdl/libsdl_sound/SDL_audio.st packages/sdl/libsdl_sound/SDL_cdrom.st packages/sdl/libsdl_sound/SDL_sound.st 
$(LibSDL_sound_FILES):
$(srcdir)/packages/sdl/libsdl_sound/stamp-classes: $(LibSDL_sound_FILES)
	touch $(srcdir)/packages/sdl/libsdl_sound/stamp-classes
