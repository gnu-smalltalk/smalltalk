Seaside-Core_FILES = \
packages/seaside/core/Seaside-Core.st packages/seaside/core/Seaside-GST.st packages/seaside/core/Seaside-GST-Override.st packages/seaside/core/Seaside-Tests.st packages/seaside/core/Seaside-Adapters-Core.st packages/seaside/core/Seaside-Adapters-GST.st packages/seaside/core/Seaside-Adapters-Tests.st packages/seaside/core/ChangeLog 
$(Seaside-Core_FILES):
$(srcdir)/packages/seaside/core/stamp-classes: $(Seaside-Core_FILES)
	touch $(srcdir)/packages/seaside/core/stamp-classes
