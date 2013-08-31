Magritte_FILES = \
packages/magritte/ChangeLog packages/magritte/magritte-gst.st packages/magritte/magritte-model.st packages/magritte/magritte-tests.st packages/magritte/PORTING 
$(Magritte_FILES):
$(srcdir)/packages/magritte/stamp-classes: $(Magritte_FILES)
	touch $(srcdir)/packages/magritte/stamp-classes
