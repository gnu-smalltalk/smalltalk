Glorp_FILES = \
packages/glorp/GlorpPort.st packages/glorp/Glorp.st packages/glorp/GlorpMySQL.st packages/glorp/GlorpTest.st 
$(Glorp_FILES):
$(srcdir)/packages/glorp/stamp-classes: $(Glorp_FILES)
	touch $(srcdir)/packages/glorp/stamp-classes
