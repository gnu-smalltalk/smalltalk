BloxGTK_FILES = \
packages/blox/gtk/Blox.st packages/blox/gtk/BloxBasic.st packages/blox/gtk/BloxWidgets.st packages/blox/gtk/BloxText.st packages/blox/gtk/BloxExtend.st 
$(BloxGTK_FILES):
$(srcdir)/packages/blox/gtk/stamp-classes: $(BloxGTK_FILES)
	touch $(srcdir)/packages/blox/gtk/stamp-classes
