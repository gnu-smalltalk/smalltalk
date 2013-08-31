DebugTools_FILES = \
packages/debug/DebugTools.st packages/debug/ChangeLog packages/debug/debugtests.st 
$(DebugTools_FILES):
$(srcdir)/packages/debug/stamp-classes: $(DebugTools_FILES)
	touch $(srcdir)/packages/debug/stamp-classes
