Debugger_FILES = \
packages/debug/debugger/ChangeLog packages/debug/debugger/Extensions.st packages/debug/debugger/MiniDebugger.st packages/debug/debugger/MiniInspector.st packages/debug/debugger/MiniTool.st 
$(Debugger_FILES):
$(srcdir)/packages/debug/debugger/stamp-classes: $(Debugger_FILES)
	touch $(srcdir)/packages/debug/debugger/stamp-classes
