GLUT_FILES = \
packages/glut/ChangeLog packages/glut/OpenGlut.st packages/glut/OpenGlutEnum.st packages/glut/OpenGlutCallbacks.st packages/glut/OpenGlutExampleObjects.st 
$(GLUT_FILES):
$(srcdir)/packages/glut/stamp-classes: $(GLUT_FILES)
	touch $(srcdir)/packages/glut/stamp-classes
