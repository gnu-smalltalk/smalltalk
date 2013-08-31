ROE_FILES = \
packages/roe/Array.st packages/roe/Core.st packages/roe/Extensions.st packages/roe/SQLiteTests.st packages/roe/SQL.st packages/roe/Tests.st 
$(ROE_FILES):
$(srcdir)/packages/roe/stamp-classes: $(ROE_FILES)
	touch $(srcdir)/packages/roe/stamp-classes
