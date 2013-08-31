GLUT_FILES = \
packages/glut/ChangeLog packages/glut/OpenGlutCallbacks.st packages/glut/OpenGlutEnum.st packages/glut/OpenGlutExampleObjects.st packages/glut/OpenGlut.st 
$(GLUT_FILES):
$(srcdir)/packages/glut/stamp-classes: $(GLUT_FILES)
	touch $(srcdir)/packages/glut/stamp-classes
