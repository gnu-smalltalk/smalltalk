DebugTools_FILES = \
packages/debug/ChangeLog packages/debug/debugtests.st packages/debug/DebugTools.st 
$(DebugTools_FILES):
$(srcdir)/packages/debug/stamp-classes: $(DebugTools_FILES)
	touch $(srcdir)/packages/debug/stamp-classes
