ZLib_FILES = \
packages/zlib/ZLibStream.st packages/zlib/ZLibReadStream.st packages/zlib/ZLibWriteStream.st packages/zlib/zlibtests.st 
$(ZLib_FILES):
$(srcdir)/packages/zlib/stamp-classes: $(ZLib_FILES)
	touch $(srcdir)/packages/zlib/stamp-classes
