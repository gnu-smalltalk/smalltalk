DBI_FILES = \
packages/dbi/ConnectionInfo.st packages/dbi/Connection.st packages/dbi/Statement.st packages/dbi/ResultSet.st packages/dbi/Row.st packages/dbi/ColumnInfo.st packages/dbi/Table.st packages/dbi/FieldConverter.st packages/dbi/ChangeLog 
$(DBI_FILES):
$(srcdir)/packages/dbi/stamp-classes: $(DBI_FILES)
	touch $(srcdir)/packages/dbi/stamp-classes
