GDBM_FILES = \
packages/gdbm/gdbm-c.st packages/gdbm/gdbm.st packages/gdbm/gdbmtests.st 
$(GDBM_FILES):
$(srcdir)/packages/gdbm/stamp-classes: $(GDBM_FILES)
	touch $(srcdir)/packages/gdbm/stamp-classes
