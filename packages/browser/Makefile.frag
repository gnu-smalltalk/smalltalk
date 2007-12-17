Browser_FILES = \
packages/browser/BrowShell.st packages/browser/Inspector.st packages/browser/Notifier.st packages/browser/View.st packages/browser/BrowserMain.st packages/browser/Load.st packages/browser/PCode.st packages/browser/bear.gif packages/browser/ClassBrow.st packages/browser/Manager.st packages/browser/PList.st packages/browser/ButtonForm.st packages/browser/ClassHierBrow.st packages/browser/Menu.st packages/browser/PText.st packages/browser/DebugSupport.st packages/browser/Debugger.st packages/browser/MethInspect.st packages/browser/RadioForm.st packages/browser/NamespBrow.st packages/browser/DictInspect.st packages/browser/MethSetBrow.st packages/browser/GuiData.st packages/browser/ModalDialog.st packages/browser/StrcInspect.st packages/browser/ChangeLog 
$(Browser_FILES):
$(srcdir)/packages/browser/stamp-classes: $(Browser_FILES)
	touch $(srcdir)/packages/browser/stamp-classes
