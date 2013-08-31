I18N_FILES = \
packages/i18n/Locale.st packages/i18n/Expression.st packages/i18n/GetText.st packages/i18n/Numbers.st packages/i18n/Times.st packages/i18n/ChangeLog 
$(I18N_FILES):
$(srcdir)/packages/i18n/stamp-classes: $(I18N_FILES)
	touch $(srcdir)/packages/i18n/stamp-classes
