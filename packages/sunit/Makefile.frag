SUnit_FILES = \
packages/sunit/SUnitPreload.st packages/sunit/SUnit.st packages/sunit/SUnitScript.st packages/sunit/SUnitTests.st packages/sunit/SUnitScriptTests.st 
$(SUnit_FILES):
$(srcdir)/packages/sunit/stamp-classes: $(SUnit_FILES)
	touch $(srcdir)/packages/sunit/stamp-classes
