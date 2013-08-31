LibSDL_GL_FILES = \
packages/sdl/libsdl_gl/Display.st 
$(LibSDL_GL_FILES):
$(srcdir)/packages/sdl/libsdl_gl/stamp-classes: $(LibSDL_GL_FILES)
	touch $(srcdir)/packages/sdl/libsdl_gl/stamp-classes
