DBI_FILES = \
packages/dbi/ChangeLog packages/dbi/ColumnInfo.st packages/dbi/ConnectionInfo.st packages/dbi/Connection.st packages/dbi/FieldConverter.st packages/dbi/ResultSet.st packages/dbi/Row.st packages/dbi/Statement.st packages/dbi/Table.st 
$(DBI_FILES):
$(srcdir)/packages/dbi/stamp-classes: $(DBI_FILES)
	touch $(srcdir)/packages/dbi/stamp-classes
