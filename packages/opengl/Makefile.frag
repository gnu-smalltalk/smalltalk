OpenGL_FILES = \
packages/opengl/ChangeLog packages/opengl/OpenGL.st packages/opengl/OpenGLEnum.st packages/opengl/OpenGLU.st packages/opengl/OpenGLUEnum.st packages/opengl/OpenGLObjects.st packages/opengl/test/bezsurf.st packages/opengl/test/cubemap.st packages/opengl/test/list.st packages/opengl/test/robot.st packages/opengl/test/test.st packages/opengl/test/test2.st packages/opengl/test/texturesurf.st packages/opengl/test/unproject.st packages/opengl/OpenGLUNurbs.st
$(OpenGL_FILES):
$(srcdir)/packages/opengl/stamp-classes: $(OpenGL_FILES)
	touch $(srcdir)/packages/opengl/stamp-classes
