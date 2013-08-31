VFSAddOns_FILES = \
packages/vfs/VFS.st 
$(VFSAddOns_FILES):
$(srcdir)/packages/vfs/stamp-classes: $(VFSAddOns_FILES)
	touch $(srcdir)/packages/vfs/stamp-classes
