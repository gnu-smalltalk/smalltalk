CParser_FILES = \
packages/cpp/StreamWrapper.st packages/cpp/PushBackStream.st packages/cpp/CToken.st packages/cpp/LineTokenStream.st packages/cpp/CPStrUnq.st packages/cpp/CPStrConc.st packages/cpp/StreamStack.st packages/cpp/ExpansionStreamStack.st packages/cpp/CExpressionNode.st packages/cpp/CParseExpr.st packages/cpp/CPP.st packages/cpp/CSymbol.st packages/cpp/CDeclNode.st packages/cpp/CSymbolTable.st packages/cpp/CParseType.st packages/cpp/README packages/cpp/ChangeLog 
$(CParser_FILES):
$(srcdir)/packages/cpp/stamp-classes: $(CParser_FILES)
	touch $(srcdir)/packages/cpp/stamp-classes
