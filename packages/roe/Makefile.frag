ROE_FILES = \
packages/roe/Array.st packages/roe/Core.st packages/roe/Postgres.st packages/roe/PostgresTests.st packages/roe/SQL.st packages/roe/Tests.st packages/roe/Extensions.st 
$(ROE_FILES):
$(srcdir)/packages/roe/stamp-classes: $(ROE_FILES)
	touch $(srcdir)/packages/roe/stamp-classes
