NCurses_FILES = \
packages/ncurses/ncurses.st packages/ncurses/ChangeLog 
$(NCurses_FILES):
$(srcdir)/packages/ncurses/stamp-classes: $(NCurses_FILES)
	touch $(srcdir)/packages/ncurses/stamp-classes
