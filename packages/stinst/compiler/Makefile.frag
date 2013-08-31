Compiler_FILES = \
packages/stinst/compiler/StartCompiler.st packages/stinst/compiler/test.st packages/stinst/compiler/ChangeLog 
$(Compiler_FILES):
$(srcdir)/packages/stinst/compiler/stamp-classes: $(Compiler_FILES)
	touch $(srcdir)/packages/stinst/compiler/stamp-classes
