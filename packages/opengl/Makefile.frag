OpenGL_FILES = \
packages/opengl/OpenGL.st packages/opengl/OpenGLEnum.st packages/opengl/OpenGLU.st packages/opengl/OpenGLUEnum.st packages/opengl/OpenGLUNurbs.st packages/opengl/OpenGLUTess.st packages/opengl/OpenGLObjects.st packages/opengl/ChangeLog packages/opengl/test/bezsurf.st packages/opengl/test/cubemap.st packages/opengl/test/list.st packages/opengl/test/robot.st packages/opengl/test/surface.st packages/opengl/test/surfpoints.st packages/opengl/test/tess.st packages/opengl/test/test.st packages/opengl/test/test2.st packages/opengl/test/texturesurf.st packages/opengl/test/unproject.st packages/opengl/test/font.st 
$(OpenGL_FILES):
$(srcdir)/packages/opengl/stamp-classes: $(OpenGL_FILES)
	touch $(srcdir)/packages/opengl/stamp-classes
