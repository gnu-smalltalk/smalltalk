DBD-SQLite_FILES = \
packages/dbd-sqlite/SQLite.st packages/dbd-sqlite/Connection.st packages/dbd-sqlite/ResultSet.st packages/dbd-sqlite/Statement.st packages/dbd-sqlite/Row.st packages/dbd-sqlite/ColumnInfo.st packages/dbd-sqlite/Table.st packages/dbd-sqlite/TableColumnInfo.st packages/dbd-sqlite/SQLiteTests.st 
$(DBD-SQLite_FILES):
$(srcdir)/packages/dbd-sqlite/stamp-classes: $(DBD-SQLite_FILES)
	touch $(srcdir)/packages/dbd-sqlite/stamp-classes
