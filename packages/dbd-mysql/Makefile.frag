DBD-MySQL_FILES = \
packages/dbd-mysql/Column.st packages/dbd-mysql/Connection.st packages/dbd-mysql/Extensions.st packages/dbd-mysql/MySQLTests.st packages/dbd-mysql/ResultSet.st packages/dbd-mysql/Row.st packages/dbd-mysql/Statement.st packages/dbd-mysql/Table.st packages/dbd-mysql/TableColumnInfo.st packages/dbd-mysql/ChangeLog 
$(DBD-MySQL_FILES):
$(srcdir)/packages/dbd-mysql/stamp-classes: $(DBD-MySQL_FILES)
	touch $(srcdir)/packages/dbd-mysql/stamp-classes
