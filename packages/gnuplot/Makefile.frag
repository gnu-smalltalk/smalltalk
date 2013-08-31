GNUPlot_FILES = \
packages/gnuplot/2D.st packages/gnuplot/Base.st packages/gnuplot/ChangeLog packages/gnuplot/Examples.st packages/gnuplot/Expressions.st packages/gnuplot/Objects.st packages/gnuplot/Series.st packages/gnuplot/Terminals.st 
$(GNUPlot_FILES):
$(srcdir)/packages/gnuplot/stamp-classes: $(GNUPlot_FILES)
	touch $(srcdir)/packages/gnuplot/stamp-classes
