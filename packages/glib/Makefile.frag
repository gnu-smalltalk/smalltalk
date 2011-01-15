GLib_FILES = \
packages/glib/GLib.st 
$(GLib_FILES):
$(srcdir)/packages/glib/stamp-classes: $(GLib_FILES)
	touch $(srcdir)/packages/glib/stamp-classes
