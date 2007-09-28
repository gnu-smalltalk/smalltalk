Continuations_FILES = \
packages/continuations/Continuations.st 
$(Continuations_FILES):
$(srcdir)/packages/continuations/stamp-classes: $(Continuations_FILES)
	touch $(srcdir)/packages/continuations/stamp-classes
