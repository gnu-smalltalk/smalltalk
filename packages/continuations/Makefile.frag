Continuations_FILES = \
packages/continuations/Amb.st packages/continuations/Test.st packages/continuations/AmbTest.st 
$(Continuations_FILES):
$(srcdir)/packages/continuations/stamp-classes: $(Continuations_FILES)
	touch $(srcdir)/packages/continuations/stamp-classes
