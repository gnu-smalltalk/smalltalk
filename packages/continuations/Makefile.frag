Continuations_FILES = \
packages/continuations/Amb.st packages/continuations/ShiftReset.st packages/continuations/Test.st packages/continuations/AmbTest.st packages/continuations/ShiftResetTest.st 
$(Continuations_FILES):
$(srcdir)/packages/continuations/stamp-classes: $(Continuations_FILES)
	touch $(srcdir)/packages/continuations/stamp-classes
