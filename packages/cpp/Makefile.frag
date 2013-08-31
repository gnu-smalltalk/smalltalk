CParser_FILES = \
packages/cpp/CDeclNode.st packages/cpp/CExpressionNode.st packages/cpp/ChangeLog packages/cpp/CParseExpr.st packages/cpp/CParseType.st packages/cpp/CPP.st packages/cpp/CPStrConc.st packages/cpp/CPStrUnq.st packages/cpp/CSymbol.st packages/cpp/CSymbolTable.st packages/cpp/CToken.st packages/cpp/ExpansionStreamStack.st packages/cpp/LineTokenStream.st packages/cpp/PushBackStream.st packages/cpp/README packages/cpp/StreamStack.st packages/cpp/StreamWrapper.st 
$(CParser_FILES):
$(srcdir)/packages/cpp/stamp-classes: $(CParser_FILES)
	touch $(srcdir)/packages/cpp/stamp-classes
