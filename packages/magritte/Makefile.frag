Magritte_FILES = \
packages/magritte/magritte-gst.st packages/magritte/magritte-model.st packages/magritte/PORTING packages/magritte/magritte-tests.st 
$(Magritte_FILES):
$(srcdir)/packages/magritte/stamp-classes: $(Magritte_FILES)
	touch $(srcdir)/packages/magritte/stamp-classes
