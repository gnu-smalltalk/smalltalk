Kernel-Tests_FILES = \
packages/kernel-tests/ChangeLog packages/kernel-tests/kernel/CompiledMethodTests.st packages/kernel-tests/kernel/ContextPartTests.st packages/kernel-tests/kernel/ObjectTests.st 
$(Kernel-Tests_FILES):
$(srcdir)/packages/kernel-tests/stamp-classes: $(Kernel-Tests_FILES)
	touch $(srcdir)/packages/kernel-tests/stamp-classes
