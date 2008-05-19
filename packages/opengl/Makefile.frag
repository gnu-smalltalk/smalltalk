OpenGL_FILES = \
packages/opengl/OpenGL.st packages/opengl/OpenGLEnum.st packages/opengl/OpenGLU.st packages/opengl/OpenGLUEnum.st packages/opengl/OpenGLObjects.st 
$(OpenGL_FILES):
$(srcdir)/packages/opengl/stamp-classes: $(OpenGL_FILES)
	touch $(srcdir)/packages/opengl/stamp-classes
