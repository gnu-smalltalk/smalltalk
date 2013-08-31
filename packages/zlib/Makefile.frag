ZLib_FILES = \
packages/zlib/ZLibReadStream.st packages/zlib/ZLibStream.st packages/zlib/zlibtests.st packages/zlib/ZLibWriteStream.st 
$(ZLib_FILES):
$(srcdir)/packages/zlib/stamp-classes: $(ZLib_FILES)
	touch $(srcdir)/packages/zlib/stamp-classes
