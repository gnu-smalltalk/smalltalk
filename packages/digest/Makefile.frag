Digest_FILES = \
packages/digest/digest.st packages/digest/md5.st packages/digest/sha1.st packages/digest/mdtests.st 
$(Digest_FILES):
$(srcdir)/packages/digest/stamp-classes: $(Digest_FILES)
	touch $(srcdir)/packages/digest/stamp-classes
