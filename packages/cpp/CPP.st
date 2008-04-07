"======================================================================
|
|   C Preprocessor object definition
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"Overall structure of the scanner:

  raw character stream, {maybe with pushback}

| LineStream
  
  stream of lines, with \ newline removed

| tokenizer, and comment remover

  lines of tokens, including whitespace tokens 

| preprocessor, conditional handling, macros expanded, etc.

  stream of tokens, with whitespace tokens removed

| string simplification: escape characters in string and char literals 
   removed

  stream of tokens

| String concatenator

  pure token stream, adjacent string literals concatenated, ready for parser

"

Stream subclass: #PreprocessorStream
       instanceVariableNames: 'streamStack lineStream stateStack state cppSymbols'
       classVariableNames: 'DirectiveHandlers Defines SystemDefines IncludePaths SystemIncludePaths'
       poolDictionaries: 'CToks'
       category: nil
! 

Object subclass: #PPState
       instanceVariableNames: 'ignoring handled'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

PPState comment:
'I am a helper class for the preprocessor.  I maintain information about
the current state of the preprocessor in terms of what level of ifdef
processing we are at.  The preprocessor can be in one of several states.
Ignoring is turned on for the contents of some part of processing a
conditional region.
If it''s in ignoring state, all non-preprocessor and 
non-preprocessor-conditional directives are simply skipped.  

When it runs into a conditional directive other than if (like else or elif),
it examine asks me whether some part of the current if expression has
been handled.  If not, either it examines the expression in the elif, or
just turns ignoring off (for else), and proceeds.

Nested #ifs are found even in ignoring mode, so that #endifs can be balanced
properly.'!


Object subclass: #PPMacroDefinition
       instanceVariableNames: 'params definition'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!PPMacroDefinition class methodsFor: 'instance creation'!

params: parameterList definition: macroDefinition
    ^self new init: parameterList definition: macroDefinition
! !

!PPMacroDefinition methodsFor: 'accessing'!

params
    ^params
!

definition
    ^definition
! !



!PPMacroDefinition methodsFor: 'private'!

init: parameterList definition: macroDefinition
    params _ parameterList.
    definition _ macroDefinition
! !




!PPState class methodsFor: 'instance creation'!

ignoring: ignoringFlag handled: handledFlag
    
    ^self new ignoring: ignoringFlag; handled: handledFlag; yourself
! !

!PPState methodsFor: 'accessing'!

ignoring: aBoolean
    ignoring _ aBoolean
!

isIgnoring
    ^ignoring
!

handled: aBoolean
    handled _ aBoolean
!

isHandled
    ^handled
! !


!PreprocessorStream class methodsFor: 'accessing'!

addSystemIncludePath: path
    SystemIncludePaths addLast: path.
    IncludePaths addLast: path.
!

addUserIncludePath: path
    IncludePaths addLast: path.
!

includePaths
    ^IncludePaths
!

resetUserIncludePaths
    IncludePaths := SystemIncludePaths copy
! !

!PreprocessorStream class methodsFor: 'test'!

testInit
    PreprocessorStream addUserIncludePath: '/usr/openwin/include'.
    PreprocessorStream addUserIncludePath: '/usr/lib/gcc-lib/i486-linux/2.4.5/include'.
!

test: aFilename
    | s str |
    self resetSymbols.
    s := self on: (FileStream open: aFilename mode: 'r').
    s inspect.
    s do: [ :line | line printNl. ].
!

test1
    PreprocessorStream test: 'lib/sym.c'.
    "PreprocessorStream test: '/usr/openwin/include/X11/Xlib.h'."
!

test2
    | s str |
    s := PreprocessorStream on: (FileStream open: 'lib/sym.c' mode: 'r').
    s inspect.
    s do: [ :line | line printNl. ].
!

test3
    | s |
    "s := FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'."
    s := FileStream open: 'lib/sym.c' mode: 'r'.
    s := PreprocessorStream onStream: s.
    s printNl.
    s do: [ :line | line printNl. ].
!

test4
    | s |
    "s := FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'."
    "s := FileStream open: 'xl.h' mode: 'r'."
    s := FileStream open: 'lib/sym.c' mode: 'r'.
    s := LineTokenStream onStream: s.
    s inspect.
    s printNl.
    s do: [ :line | line printNl. ].
!

test5
    | s expStream |
    "s := FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'."
    "s := FileStream open: 'xl.h' mode: 'r'."
    s := FileStream open: 'lib/sym.c' mode: 'r'.
    s := LineTokenStream onStream: s.
    s do: [ :line |
	expStream := ExpansionStreamStack new.
	expStream pushStream: line readStream.
	s printNl.
        line printNl ].
! !

!PreprocessorStream class methodsFor: 'instance creation'!

test: aFilename
    | s str |
    self resetSymbols.
    s _ self on: (FileStream open: aFilename mode: 'r').
    s inspect.
    s do: [ :line | line printNl. ].
!

define: symbol
    Defines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (CIntegerToken value: 1))
!

systemDefine: symbol
    SystemDefines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (CIntegerToken value: 1)).

    Defines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (CIntegerToken value: 1))
!

resetSymbols
    "Put the symbol table back to its original state"
    Defines := SystemDefines copy.
!

symbols
    ^Defines copy
!

initialize
    SystemIncludePaths := OrderedCollection new.
    self resetUserIncludePaths.
    self addSystemIncludePath: '/usr/include'.

    SystemDefines := Dictionary new.
    Defines := Dictionary new.
    Features do: [ :each |
	(each at: 1) = $_ ifTrue: [ self systemDefine: each ]
    ].

    DirectiveHandlers _ Dictionary new.
    DirectiveHandlers 
	at: 'if'  put: #handleIf;
	at: 'ifdef' put: #handleIfdef;
	at: 'ifndef' put: #handleIfndef;
	at: 'include' put: #handleInclude;
	at: 'else' put: #handleElse;
	at: 'elif' put: #handleElif;
	at: 'endif' put: #handleEndif;
	at: 'define' put: #handleDefine;
	at: 'undef' put: #handleUndef.
!

on: aCollection
    ^self onStream: aCollection readStream
!

onStream: aStream
    "This works by stacking different kinds of preprocessing streams
     one on top of another, each doing a specific task.  Additional
     layers are in LineTokenStream and StreamStack.  As in Unix, 
     this sacrifices performance for some elegance/simplicity."
    | str |
    str _ StringUnquoteStream on: aStream.
    str _ self new setStream: str.
    ^StringConcatStream on: str.
! !



!PreprocessorStream methodsFor: 'scanning'!

atEnd
    [ (lineStream isNil or: [ lineStream atEnd ]) ]
	  whileTrue: [
	       lineStream _ self nextLine.
	       lineStream isNil ifTrue: [ ^true ].
	  ].

    ^false
!

next
    self atEnd ifTrue: [ ^nil ].

    "lineStream is already macro-expanded for us.  thanks nextLine."
    ^lineStream next
!

expandDefinedFrom: expStream
    "Either 'defined/\ <anIdent>' or 'defined/\(<anIdent>)'"
    | ident tok result|
    tok _ expStream next.
    tok == OpenParenTok
	ifTrue: [ ident _ expStream next.
		  expStream next "gobble ')' " ]
	ifFalse: [ ident _ tok ].
    
   "'expanding defined' print. ident printNl.  "

    ^{ CIntegerToken value: ((cppSymbols includesKey: ident)
			    ifTrue: [ 1 ] 
			    ifFalse: [ 0 ]) }
!

nextLine
    | ch |
    [ streamStack atEnd ] whileFalse: 
	  [ ch _ streamStack peek.
	    (self isSharp: ch)
		ifTrue: 
		    [ "It's for us!!!"
		      streamStack next. "gobble '#'"
		      self dispatchDirective.
		      ]
		ifFalse: [
			  state isIgnoring
				ifTrue: [ streamStack nextLine ]
				ifFalse: [ ^self macroExpandRemainder ]
		 ]
	].
    ^nil
!




macroExpandRemainder
    | result lineTokens expStream expansion token |
    lineTokens _ streamStack nextLine.
    result _ WriteStream on: (Array new: lineTokens size).
    expStream _ ExpansionStreamStack new.
    expStream pushStream: lineTokens readStream.
    [ expStream atEnd ] whileFalse:
	[ token _ expStream next.
	   "'reading from exp: ' print. token printNl."
   
	  ((token isMemberOf: CIdentifierToken) and: 
	       [ (cppSymbols includesKey: token) and: 
		     [ (expStream isAlreadyExpanded: token ) not ] ])
	      ifTrue: [ expansion _ self expandMacro: token from: expStream.
			expStream pushStream: expansion readStream
				  forMacro: token ]
	      ifFalse: [ result nextPut: token ]
	 ].
    lineStream _ nil.		"force a reload"
    "'expanded into: ' print. result printNl."
    ^result readStream
!
	      


expandMacro: macroName from: expStream
    | defn body params result str paramName |
    macroName value = 'defined'
	ifTrue: [ ^self expandDefinedFrom: expStream ].
    defn _ cppSymbols at: macroName.
    defn params isNil ifTrue: "No parameters -- easy substitution!"
	[ ^defn definition ].
    
    "Assume we're looking at: 'foo/\ (...'"
    params _ self parseMacroActuals: defn params fromStream: expStream.
     
    "  '%%%%% macro actuals: ' print. params printNl."

    body _ defn definition.
    
    result _ OrderedCollection new: body size.
    str _ ReadStream on: body.
    str do: 
	[ :token | self processMacroToken: token
			into: result 
			fromStream: str
			withParams: params
		   ].
    ^result
!

processMacroToken: token into: result fromStream: expStream withParams: params
    | paramName lastToken nextToken nextParams |
    
    (token class == CBinaryOperatorToken 
	and: [ token value = '##' ]) 
	ifTrue: 
	    [ lastToken _ result removeLast.
	      nextToken _ expStream next.
	      "'[[[[[[[[[ next is ' print. nextToken printNl."
	      (nextToken class == CIdentifierToken
		   and: [ params includesKey: nextToken ])
		  ifTrue: [ nextParams _ params at: nextToken.
			    "!!! Here we assume we always have identifiertokens"
			    lastToken class == CIdentifierToken
				ifFalse: [^self error: '## called with non identifier' ].
			    lastToken _ CIdentifierToken value: 
				lastToken value , nextParams removeFirst valueString.
			    nextParams addFirst: lastToken.
			    ^result addAllLast: nextParams ]
		  ifFalse: [ lastToken _ CIdentifierToken value: 
				 lastToken value, nextToken valueString.
			     ^result addLast: lastToken ]
	      ].
    (self isSharp: token)
	ifTrue: [ paramName _ expStream next.
		  ^result addLast: 
		      (self stringifyActual: 
			   (params at: paramName)) ].
    (token class == CIdentifierToken
	 and: [ params includesKey: token ])
	ifTrue: [ ^result addAllLast: 
		      (params at: token) ].
    result addLast: token
!
		      


stringifyActual: macroActualParam
    | result tokenString |
    result _ WriteStream on: (String new: 1).
    macroActualParam do:
	[ :token | 
		   "Whitespace are already present and their value is a 
		    single space, so it works out ok."
		   tokenString _ self toString: token.
		   result nextPutAll: tokenString.
		       ].
    ^CStringToken value: result contents
!

toString: token
    (token isKindOf: CStringoidToken)
	  ifTrue: [ ^token quotedStringValue ].
    ^token valueString
!

parseMacroActuals: names fromStream: expStream
    "this has to work with whatever stream is sitting below it, essentially
     the stream stack.  This means that the line stream has to be wrapped into
     something that behaves like a normal stream"
    | paramDict actual |
    " expecting scanner to be at foo/\ (arg1, arg2, ...), leaves after eating
     the close paren"
    paramDict _ Dictionary new.
    expStream next.		"gobble ("

    names do: 
	[ :name | actual _ self parseMacroActual: expStream.
		  paramDict at: name put: actual.
		  expStream next. "gobble the trailing delimiter" 
		  ].
    "!!! should put back the remainder of the queue (if any)"
    ^paramDict
!

"!!! still have to build lineStream -> simple token translator
 !!! build stream stack extension with macro prohibition
     (can use this as what our next operation does too...just push the
     right stream in the way, and the right thing will happen).
"

parseMacroActual: expStream
    "parses a paren balanced series of tokens, up to (and either a close paren
	 or a comma, returning the list, minus white spaces at either end"
    | result token parenLevel |
    result _ OrderedCollection new.
    parenLevel _ 0.
    
    [ token _ expStream peek.
      parenLevel == 0
	  and: [ (token == CloseParenTok)
		     or: [ token class == CBinaryOperatorToken and: 
			       [ token value = ',' ] ] ] ]
	whileFalse: [ result addLast: token.
		      expStream next. "gobble it"
		      token == OpenParenTok
			  ifTrue: [ parenLevel _ parenLevel + 1 ].
		      token == CloseParenTok
			  ifTrue: [ parenLevel _ parenLevel - 1 ]. 
		      ].

    ^result
!

"
input stream: ls (line stream)


parse actuals (may involve fetching several input lines), produces a
dictionary mapping actual names to token sequences.  this actual
parsing may also be useful elsewhere

expand macro body
put expansion into input stream, prohibiting recursive expansion






tokens out the top, ws removed

"



isSharp: token
    ^token class == COperatorToken and: [ token value = '#' ]
!

dispatchDirective
    | directive |
    directive := streamStack next.

    self perform: (DirectiveHandlers
	at: directive value
	ifAbsent: [ #skipDirective ]).
! !


!PreprocessorStream methodsFor: 'handling directives'!

handleUndef
    | symbol |
    state isIgnoring
	ifTrue: [ ^true ].

    symbol _ streamStack next.
    "'undefining' print. symbol value printNl."
    cppSymbols removeKey: symbol ifAbsent: [].
!
    
handleDefine
    | symbol tok definition params macroDef |
    state isIgnoring
	ifTrue: [ ^true ].

    symbol _ streamStack next.

    "'defining' print. symbol value printNl."
    streamStack peekChar = $(
	ifTrue: [
	    "'doing parameters' printNl." params _ self parseMacroParams ].

    macroDef _ PPMacroDefinition params: params
				 definition: streamStack nextLine.
    cppSymbols at: symbol put: macroDef.
!

parseMacroParams
    "scanner at #define foo/\(...) "
    | params ident tok |
    streamStack next.		"gobble paren"
    params _ OrderedCollection new.
    tok _ streamStack peek.
    tok class ~~ CloseParenTok 
	ifTrue: 
	    [ [ ident _ streamStack next.
		params addLast: ident.
		tok _ streamStack next.
		tok value = ',' ] whileTrue: [ ] ]
	ifFalse: [ streamStack next ].
    "must have gobbled the close paren already (we're not a full C
     language, and we presume syntactically correct C programs), so we
     are done."
    ^params
!


handleIfdef
    | symbol isDefined |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    symbol _ streamStack next.
    
    isDefined _ (cppSymbols includesKey: symbol).
    "'ifdef' print. symbol value printNl.  isDefined printNl."
    state _ PPState ignoring: isDefined not handled: isDefined
! 

handleIfndef
    | symbol isDefined |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    symbol _ streamStack next.
    
    isDefined _ (cppSymbols includesKey: symbol).
    "'ifndef' print. symbol value printNl.  isDefined printNl."
    state _ PPState ignoring: isDefined handled: isDefined not
!

handleInclude
    | token fileName searchLocal fileStream |
    state isIgnoring
	ifTrue: [ ^true ].

    token _ streamStack next.
    token class == CStringToken
	ifTrue: [ fileName _ token value.
		  searchLocal _ true ]
	ifFalse:
	    [ "should be < dir/dir/dir.../filename > "
	      searchLocal _ false.
	      fileName _ ''.
	      [ token _ streamStack next.
		token value ~= '>' ] whileTrue:
		    [ fileName _ fileName, token value ].
	      ].
  Transcript nextPutAll: 'including: '; nextPutAll: fileName; nl.
    fileStream _ self findIncludeFile: fileName locally: searchLocal.
    fileStream notNil
	ifTrue: [ self pushStream: fileStream ]
	ifFalse: [ ^self error: 'Could not locate include file "', fileName, 
		       '"' ].
!

pushStream: aStream
    streamStack pushStream: (LineTokenStream onStream: aStream).
!

findIncludeFile: fileName locally: locally
    | paths file |
    " !!! should this be smarter and search the current directory by default,
     that is, the directory of the includer, or not?.  GNU CPP uses for quote
     delimited include file names the directory of the current input file (as 
     opposed to the current working directory, so we'll probably have to do
     this as well at some point.  The angle bracket variant just pays 
     attention to the -I files and the standard directories."
    "'@@@@@@@@@@@@ file name ' print. fileName printNl."
    paths _ self includePaths.
    locally ifTrue: [ paths addFirst: '.' ].
    paths do: 
	[ :path | file _ path / fileName.
		  file exists ifTrue: [ ^file readStream ] ].
    ^nil
!

includePaths
    ^PreprocessorStream includePaths
!

addIncludePath: aPath
    ^PreprocessorStream addUserIncludePath: aPath
!

handleIf
    | expr exprBool |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    expr _ self parseExpression.
    
    exprBool _ (expr evaluate) ~= 0.
    "'if' print. exprBool printNl."
    state _ PPState ignoring: exprBool not
		    handled: exprBool
! 

parseExpression
    " parse a line of stuff from streamStack and return it as an expression
     tree"
    | exprParser expr cleanedLine |
    
    cleanedLine _ self macroExpandRemainder.

    "'parsing. ' print. cleanedLine copy upToEnd printNl."

    exprParser _ CExpressionParser onStream: cleanedLine.
    expr _ exprParser parseExpression.
    ^expr
!

handleElse
    state isHandled
	ifTrue: [ state ignoring: true ]
	ifFalse: [ state ignoring: false.
		   state handled: true ].
    "'else ' print. state isIgnoring printNl."
!

handleElif
    | expr | 
    state isHandled
	ifTrue: [ state ignoring: true ]
	ifFalse:
	    [ expr _ self parseExpression.
	      (expr evaluate) ~= 0
		  ifTrue: [ state handled: true; ignoring: false ]
		  ifFalse: [ state ignoring: true ] ].
    "'elif ' print. state isIgnoring printNl."
!

handleEndif
    "'endif ' printNl."
    state _ stateStack removeFirst.
! 

skipDirective
    "does doing nothing work for pragmas etc.?"
    streamStack nextLine
! !


!PreprocessorStream methodsFor: 'private'!

setStream: aStream
    streamStack := StreamStack new.
    self pushStream: aStream.
    state _ PPState ignoring: false handled: false.
    stateStack _ OrderedCollection new.
    cppSymbols _ PreprocessorStream symbols.
    cppSymbols at: (CIdentifierToken value: 'defined') put: 1. "value does not matter"
! !


PreprocessorStream initialize!
