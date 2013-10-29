DebugTools_FILES = \
packages/debug/ChangeLog packages/debug/DebuggerReentered.st packages/debug/debugtests.st packages/debug/DebugTools.st packages/debug/Extensions.st packages/debug/maybe/Just.st packages/debug/maybe/Maybe.st packages/debug/maybe/Nothing.st 
$(DebugTools_FILES):
$(srcdir)/packages/debug/stamp-classes: $(DebugTools_FILES)
	touch $(srcdir)/packages/debug/stamp-classes
