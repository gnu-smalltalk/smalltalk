BloxTK_FILES = \
packages/blox/tk/Blox.st packages/blox/tk/BloxBasic.st packages/blox/tk/BloxWidgets.st packages/blox/tk/BloxText.st packages/blox/tk/BloxCanvas.st packages/blox/tk/BloxExtend.st packages/blox/tk/colors.txt packages/blox/tk/ChangeLog 
$(BloxTK_FILES):
$(srcdir)/packages/blox/tk/stamp-classes: $(BloxTK_FILES)
	touch $(srcdir)/packages/blox/tk/stamp-classes
