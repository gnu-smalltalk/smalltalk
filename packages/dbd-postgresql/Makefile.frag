DBD-PostgreSQL_FILES = \
packages/dbd-postgresql/Connection.st packages/dbd-postgresql/ResultSet.st packages/dbd-postgresql/Row.st packages/dbd-postgresql/ColumnInfo.st packages/dbd-postgresql/Statement.st packages/dbd-postgresql/Table.st packages/dbd-postgresql/TableColumnInfo.st packages/dbd-postgresql/FieldConverter.st
$(DBD-PostgreSQL_FILES):
$(srcdir)/packages/dbd-postgresql/stamp-classes: $(DBD-PostgreSQL_FILES)
	touch $(srcdir)/packages/dbd-postgresql/stamp-classes
