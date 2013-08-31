ObjectDumper_FILES = \
packages/object-dumper/Init.st packages/object-dumper/ObjDumper.st packages/object-dumper/ObjectDumperTest.st packages/object-dumper/Proxy.st 
$(ObjectDumper_FILES):
$(srcdir)/packages/object-dumper/stamp-classes: $(ObjectDumper_FILES)
	touch $(srcdir)/packages/object-dumper/stamp-classes
