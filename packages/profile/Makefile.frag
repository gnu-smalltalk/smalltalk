ProfileTools_FILES = \
packages/profile/ChangeLog packages/profile/Profiler.st 
$(ProfileTools_FILES):
$(srcdir)/packages/profile/stamp-classes: $(ProfileTools_FILES)
	touch $(srcdir)/packages/profile/stamp-classes
