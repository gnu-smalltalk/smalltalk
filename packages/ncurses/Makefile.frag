NCurses_FILES = \
packages/ncurses/ncurses.st 
$(NCurses_FILES):
$(srcdir)/packages/ncurses/stamp-classes: $(NCurses_FILES)
	touch $(srcdir)/packages/ncurses/stamp-classes
