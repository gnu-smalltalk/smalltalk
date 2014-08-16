Kernel-Tests_FILES = \
packages/kernel-tests/ChangeLog packages/kernel-tests/kernel/BehaviorTests.st packages/kernel-tests/kernel/CCallableTest.st packages/kernel-tests/kernel/CompiledMethodTests.st packages/kernel-tests/kernel/ContextPartTests.st packages/kernel-tests/kernel/MappedCollectionTests.st packages/kernel-tests/kernel/ObjectTests.st packages/kernel-tests/kernel/RecursionLockTests.st packages/kernel-tests/kernel/RegexpTests.st packages/kernel-tests/kernel/URLTests.st 
$(Kernel-Tests_FILES):
$(srcdir)/packages/kernel-tests/stamp-classes: $(Kernel-Tests_FILES)
	touch $(srcdir)/packages/kernel-tests/stamp-classes
