Sport_FILES = \
packages/sport/sport.st packages/sport/sporttests.st packages/sport/sportsocktests.st 
$(Sport_FILES):
$(srcdir)/packages/sport/stamp-classes: $(Sport_FILES)
	touch $(srcdir)/packages/sport/stamp-classes
