Sport_FILES = \
packages/sport/sportsocktests.st packages/sport/sport.st packages/sport/sporttests.st 
$(Sport_FILES):
$(srcdir)/packages/sport/stamp-classes: $(Sport_FILES)
	touch $(srcdir)/packages/sport/stamp-classes
