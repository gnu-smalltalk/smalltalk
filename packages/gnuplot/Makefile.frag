GNUPlot_FILES = \
packages/gnuplot/Base.st packages/gnuplot/Objects.st packages/gnuplot/Series.st packages/gnuplot/Terminals.st packages/gnuplot/Expressions.st packages/gnuplot/2D.st packages/gnuplot/Examples.st packages/gnuplot/ChangeLog 
$(GNUPlot_FILES):
$(srcdir)/packages/gnuplot/stamp-classes: $(GNUPlot_FILES)
	touch $(srcdir)/packages/gnuplot/stamp-classes
