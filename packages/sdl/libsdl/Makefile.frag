LibSDL_FILES = \
packages/sdl/libsdl/SDL.st packages/sdl/libsdl/SDL_active.st packages/sdl/libsdl/SDL_byteorder.st packages/sdl/libsdl/SDL_cpuinfo.st packages/sdl/libsdl/SDL_endian.st packages/sdl/libsdl/SDL_error.st packages/sdl/libsdl/SDL_events.st packages/sdl/libsdl/SDL_joystick.st packages/sdl/libsdl/SDL_keyboard.st packages/sdl/libsdl/SDL_keysym.st packages/sdl/libsdl/SDL_loadso.st packages/sdl/libsdl/SDL_mouse.st packages/sdl/libsdl/SDL_mutex.st packages/sdl/libsdl/SDL_name.st packages/sdl/libsdl/SDL_rwops.st packages/sdl/libsdl/SDL_syswm.st packages/sdl/libsdl/SDL_thread.st packages/sdl/libsdl/SDL_timer.st packages/sdl/libsdl/SDL_video.st packages/sdl/libsdl/Display.st packages/sdl/libsdl/EventSource.st 
$(LibSDL_FILES):
$(srcdir)/packages/sdl/libsdl/stamp-classes: $(LibSDL_FILES)
	touch $(srcdir)/packages/sdl/libsdl/stamp-classes
