STTools_FILES = \
packages/sttools/Parser/Loader.st packages/sttools/Parser/SourceClass.st packages/sttools/Parser/SourceComments.st packages/sttools/Parser/SourceEntity.st packages/sttools/Parser/SourceEval.st 
$(STTools_FILES):
$(srcdir)/packages/sttools/stamp-classes: $(STTools_FILES)
	touch $(srcdir)/packages/sttools/stamp-classes
