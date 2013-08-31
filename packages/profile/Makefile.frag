ProfileTools_FILES = \
packages/profile/Profiler.st packages/profile/ChangeLog 
$(ProfileTools_FILES):
$(srcdir)/packages/profile/stamp-classes: $(ProfileTools_FILES)
	touch $(srcdir)/packages/profile/stamp-classes
