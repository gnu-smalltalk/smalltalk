Continuations_FILES = \
packages/continuations/Amb.st packages/continuations/AmbTest.st packages/continuations/ShiftReset.st packages/continuations/ShiftResetTest.st packages/continuations/Test.st 
$(Continuations_FILES):
$(srcdir)/packages/continuations/stamp-classes: $(Continuations_FILES)
	touch $(srcdir)/packages/continuations/stamp-classes
