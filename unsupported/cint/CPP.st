"======================================================================
|
|   C Preprocessor object definition
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
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

"
|     Change Log
| ============================================================================
| Author       Date       Change 
| pb	       8 Jan 99	  Yes! Started reintegrating everything into 1.1.6!
|			  Added support for '#   define Foo Bar'
|
"


| dir |
dir := Directory working.
Directory working: Directory kernel, '/../cint'.
FileStream fileIn: 'LineStream.st'.
FileStream fileIn: 'LineTokenStream.st'.
FileStream fileIn: 'CPStrUnq.st'.
FileStream fileIn: 'CPStrConc.st'.
FileStream fileIn: 'ExpansionStream.st'.
FileStream fileIn: 'CTreeBuilder.st'.
FileStream fileIn: 'CollapsedStream.st'.
Directory working: dir!

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

PushBackStream subclass: #PPStream
       instanceVariableNames: 'lineStream stateStack state cppSymbols'
       classVariableNames: 'DirectiveHandlers'
       poolDictionaries: ''
       category: nil
! 

Stream subclass: #PreprocessorStream
       instanceVariableNames: 'stream'
       classVariableNames: 'Defines SystemDefines IncludePaths SystemIncludePaths'
       poolDictionaries: ''
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
    "s := LineStream onStream: (FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r')."
    "s := LineStream onStream: (FileStream open: 'xl.h' mode: 'r')."
    s := LineStream onStream: (FileStream open: 'lib/sym.c' mode: 'r').
    s := LineTokenStream onStream: s.
    s := PPStream onStream: s.
    s printNl.
    s do: [ :line | line printNl. ].
!

test4
    | s |
    "s := LineStream onStream: (FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r')."
    "s := LineStream onStream: (FileStream open: 'xl.h' mode: 'r')."
    s := LineStream onStream: (FileStream open: 'lib/sym.c' mode: 'r').
    s := LineTokenStream onStream: s.
    s inspect.
    s := CollapsedStream on: s.
    s printNl.
    s do: [ :line | line printNl. ].
!

test5
    | s expStream |
    "s := LineStream onStream: (FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r')."
    "s := LineStream onStream: (FileStream open: 'xl.h' mode: 'r')."
    s := LineStream onStream: (FileStream open: 'lib/sym.c' mode: 'r').
    s := LineTokenStream onStream: s.
    expStream := ExpansionStream new.
    expStream addStream: (CollapsedStream on: s).
    s := expStream.
    s printNl.
    s do: [ :line | line printNl. ].
! !

!PreprocessorStream class methodsFor: 'instance creation'!

on: aStream
    ^self new init: aStream
!

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
	put: (PPMacroDefinition params: nil definition: (IntegerTok value: 1))
!

systemDefine: symbol
    SystemDefines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (IntegerTok value: 1)).

    Defines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (IntegerTok value: 1))
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
! !


!PreprocessorStream methodsFor: 'accessing'!

next
    ^stream next
!

peek
    ^stream peek
!

atEnd
    ^stream atEnd
! !


!PreprocessorStream methodsFor: 'private'!

init: aStream
    | str | 
    "This works by stacking different kinds of preprocessing streams
     one on top of another, each doing a specific task.  As in Unix, 
     this sacrifices performance for some elegance/simplicity."
    str _ LineStream onStream: aStream.
    str _ LineTokenStream onStream: str.
    str _ PPStream onStream: str.

    str _ StringUnquoteStream on: str.
    str _ StringConcatStream on: str.
    stream _ str.
! !


"!!! change all code below not to use this precious name"





!PPStream class methodsFor: 'instance creation'!

onStream: aStream
    ^self new setStream: aStream
! !



!PPStream class methodsFor: 'initialization'!

initialize
    "??? perhaps add in the default ones that we have"

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
! !



!PPStream methodsFor: 'scanning'!

next
    | tok |
    queue size > 0
	ifTrue: [ ^queue removeFirst ].
    
    " ??? do we need to ensure that lineStream is non-nil, or will init:
     take care of that for us?"
    [ (lineStream isNil or: [ lineStream atEnd ]) ]
	  whileTrue: [
	      "!!! need to check for real end of stream "
	       lineStream _ self nextLine.
	       lineStream isNil ifTrue: [ ^nil ].
	  ].

    "lineStream is already macro-expanded for us.  thanks nextLine."
    ^lineStream next
!

expandDefinedFrom: expStream
    "Either 'defined/\ <anIdent>' or 'defined/\(<anIdent>)'"
    | ident tok result|
    self skipWhitespaceOn: expStream.
    tok _ expStream next.
    tok class == OpenParenTok
	ifTrue: [ self skipWhitespaceOn: expStream.
		  ident _ expStream next.
		  self skipWhitespaceOn: expStream. 
		  expStream next "gobble ')' " ]
	ifFalse: [ ident _ tok ].
    
   'expanding defined' print. ident printNl.  

    result _ OrderedCollection new.
    result addLast: 
	(IntegerTok value: ((cppSymbols includesKey: ident)
			    ifTrue: [ 1 ] 
			    ifFalse: [ 0 ])).
    ^result
!

nextLine
    | line ch |
    [ stream atEnd ] whileFalse: 
	[ line _ stream next.
    "'consumed' print.
    line printNl."
	  lineStream _ ReadStream on: line.
    
	  self skipWhitespace.
	  lineStream atEnd
	      ifFalse: 
		  [ ch _ lineStream peek.
		    (self isSharp: ch)
			ifTrue: 
			    [ "It's for us!!!"
			      lineStream next. "gobble '#'"
			      self dispatchDirective.
			      ]
			ifFalse: [
				  ^PushBackStream on: (state isIgnoring
					  ifTrue: [ lineStream ]
					  ifFalse: [ ReadStream on: self macroExpandRemainder ])
			 ]
		  ]

	].
    ^nil
!




macroExpandRemainder
    | result expStream expansion token |
    result _ OrderedCollection new.
    self pushBackRemainder.
    expStream _ ExpansionStream new.
    expStream addStream: (CollapsedStream on: stream).
    [ expStream atEnd ] whileFalse:
	[ token _ expStream next.
   "'reading from exp: ' print. token printNl."
   
	  "
   ((token isMemberOf: IdentifierTok) and: 
	      [ (cppSymbols includesKey: token) ])
       ifTrue: [ '#######' print. token printNl.
		 (expStream isAlreadyExpanded: token) printNl.
		     
		     ].
	   "
	  ((token isMemberOf: IdentifierTok) and: 
	       [ (cppSymbols includesKey: token) and: 
		     [ (expStream isAlreadyExpanded: token ) not ] ])
	      ifTrue: [ expansion _ self expandMacro: token from: expStream.
			expStream recordExpansionOf: token
				  into: expansion ]
	      ifFalse: [ result addLast: token ]
	 ].
    lineStream _ nil.		"force a reload"
    "'expanded into: ' print. result printNl."
    ^result
!
	      


pushBackRemainder
    "push back whatever is left in lineStream"
    | remainder |
    remainder _ OrderedCollection new.
""    'pushingback' printNl.  ""
    lineStream do: [ :token | remainder addLast: token ""printNl"" ].
    stream putBack: remainder.
!

expandMacro: macroName from: expStream
    | defn body params result str paramName |
    macroName value printNl.
    macroName value = 'defined'
	ifTrue: [ ^self expandDefinedFrom: expStream ].
    defn _ cppSymbols at: macroName.
    defn params isNil ifTrue: "No parameters -- easy substitution!"
	[ ^defn definition ].
    
    "Assume we're looking at: 'foo/\ (...'"
    params _ self parseMacroActuals: defn params fromStream: expStream.
     
 ""  '%%%%% macro actuals: ' print. params printNl.""

    body _ defn definition.
    
    result _ OrderedCollection new.
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
    
    (token isMemberOf: WhitespaceTok) ifTrue: [ ^self "reject these asap" ].
 ""   '******** debbie does macros ' print. token printNl. ""
    (token class == CBinaryOperatorToken 
	and: [ token value = '##' ]) 
	ifTrue: 
	    [ lastToken _ result removeLast.
	      self skipWhitespaceOn: expStream.
	      nextToken _ expStream next.
	      "'[[[[[[[[[ next is ' print. nextToken printNl."
	      (nextToken class == IdentifierTok
		   and: [ params includesKey: nextToken ])
		  ifTrue: [ nextParams _ params at: nextToken.
			    "!!! Here we assume we always have identifiertokens"
			    lastToken class == IdentifierTok
				ifFalse: [^self error: '## called with non identifier' ].
			    lastToken _ IdentifierTok value: 
				lastToken value , nextParams removeFirst valueString.
			    nextParams addFirst: lastToken.
			    ^result addAllLast: nextParams ]
		  ifFalse: [ lastToken _ IdentifierTok value: 
				 lastToken value, nextToken valueString.
			     ^result addLast: lastToken ]
	      ].
    (self isSharp: token)
	ifTrue: [ self skipWhitespaceOn: expStream.
		  paramName _ expStream next.
		  ^result addLast: 
		      (self stringifyActual: 
			   (params at: paramName)) ].
    (token class == IdentifierTok
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
    ^StringTok value: result contents
!

toString: token
    (token isKindOf: StringoidTok)
	  ifTrue: [ ^token quotedStringValue ].
    ^token valueString
!

parseMacroActuals: names fromStream: expStream
    "this has to work with whatever stream is sitting below it, essentially
     the stream stack.  This means that the line stream has to be wrapped into
     something that behaves like a normal stream"
    | paramDict actual bypass |
    " expecting scanner to be at foo/\ (arg1, arg2, ...), leaves after eating
     the close paren"
    paramDict _ Dictionary new.
    self skipWhitespaceOn: expStream.
    expStream next.		"gobble ("

    names do: 
	[ :name | actual _ self parseMacroActual: expStream.
		  paramDict at: name put: actual.
		  bypass next. "gobble the trailing delimiter" 
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
    self skipWhitespaceOn: expStream.
    parenLevel _ 0.
    
    [ token _ expStream peek.
      parenLevel == 0
	  and: [ (token class == CloseParenTok)
		     or: [ token class == CBinaryOperatorToken and: 
			       [ token value = ',' ] ] ] ]
	whileFalse: [ result addLast: token.
		      expStream next. "gobble it"
		      token class == OpenParenTok
			  ifTrue: [ parenLevel _ parenLevel + 1 ].
		      token class == CloseParenTok
			  ifTrue: [ parenLevel _ parenLevel - 1 ]. 
		      ].

    " trim trailing whitespace "
    [ result size > 0 
	  and: [ (result at: result size) class == WhitespaceTok ]]
	whileTrue: [ result removeLast ].
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
    self skipWhitespace.
    directive := lineStream next.

    self perform: (DirectiveHandlers
	at: directive value
	ifAbsent: [ #skipDirective ]).
! !


!PPStream methodsFor: 'handling directives'!

handleUndef
    | symbol |
    state isIgnoring
	ifTrue: [ ^true ].

    self skipWhitespace.
    symbol _ lineStream next.
    'undefining' print. symbol value printNl.
    cppSymbols removeKey: symbol ifAbsent: [].
!
    
handleDefine
    | symbol tok definition params macroDef |
    state isIgnoring
	ifTrue: [ ^true ].

    self skipWhitespace.
    symbol _ lineStream next.

    'defining' print. symbol value printNl.
    tok _ lineStream peek.
    tok class == OpenParenTok
	ifTrue: [ 'doing parameters' printNl. params _ self parseMacroParams ].

    self skipWhitespace.
    definition _ OrderedCollection new.
    [ lineStream atEnd ] whileFalse:
	[ definition addLast: lineStream next ].
    "we'll let the #<name> directive deal with trailing white space
     removal, other things don't care"

    macroDef _ PPMacroDefinition params: params
				 definition: definition.
    cppSymbols at: symbol put: macroDef.
!

parseMacroParams
    "scanner at #define foo/\(...) "
    | params ident tok |
    lineStream next.		"gobble paren"
    params _ OrderedCollection new.
    tok _ lineStream peek.
    tok class ~~ CloseParenTok 
	ifTrue: 
	    [ [ self skipWhitespace.
		ident _ lineStream next.
		params addLast: ident.
		self skipWhitespace.
		tok _ lineStream next.
		tok value = ',' ] whileTrue: [ ] ]
	ifFalse: [ lineStream next ].
    "must have gobbled the close paren already (we're not a full C
     language, and we presume syntactically correct C programs), so we
     are done."
    ^params
!


skipWhitespace
    ^self skipWhitespaceOn: lineStream
!

"!!! this should probably be a method on the individual stream"
skipWhitespaceOn: aStream
    | tok |
    [ aStream atEnd not
	  and: [ tok _ aStream peek.
		 tok class == WhitespaceTok ]
	  ]
	whileTrue: [ aStream next ]
!



handleIfdef
    | symbol isDefined |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    self skipWhitespace.
    symbol _ lineStream next.
    
    isDefined _ (cppSymbols includesKey: symbol).
    'ifdef' print. symbol value printNl.  isDefined printNl.
    state _ PPState ignoring: isDefined not handled: isDefined
! 

handleIfndef
    | symbol isDefined |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    self skipWhitespace.
    symbol _ lineStream next.
    
    isDefined _ (cppSymbols includesKey: symbol).
    'ifndef' print. symbol value printNl.  isDefined printNl.
    state _ PPState ignoring: isDefined handled: isDefined not
!

handleInclude
    | token fileName searchLocal fileStream |
    state isIgnoring
	ifTrue: [ ^true ].

    self skipWhitespace.
    token _ lineStream next.
    token class == StringTok
	ifTrue: [ fileName _ token value.
		  searchLocal _ true ]
	ifFalse:
	    [ "should be < dir/dir/dir.../filename > "
	      searchLocal _ false.
	      fileName _ ''.
	      [ token _ lineStream next.
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
    stream pushStream: aStream
! 

findIncludeFile: fileName locally: locally
    | paths file stream |
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
	[ :path | file _ File name: path , '/', fileName.
		  file exists ifTrue: [ ^file readStream ] ].
    ^nil
!

includePaths
    ^PreprocessorStream includePaths
!

addIncludePath: aPath
    ^PreprocessorStream addUserIncludePath: aPath
!

"???how to handle defined?  One alternative is to have all macros
 expanded by now (I think a requirement), and have part of the macro
 expansion specially check for defined and do the right thing"


handleIf
    | expr exprBool |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    expr _ self parseExpression.
    
    exprBool _ (expr evaluate) ~= 0.
    'if' print. exprBool printNl.
    state _ PPState ignoring: exprBool not
		    handled: exprBool
! 

parseExpression
    " parse some set of stuff from lineStream and return it as an expression
     tree"
    | exprParser expr cleanedLine |
    
    cleanedLine _ self macroExpandRemainder reject:
	[ :token | token isMemberOf: WhitespaceTok ].

    'parsing. ' print. cleanedLine printNl.

    exprParser _ CExpressionParser onStream: (PushBackStream on: 
						  (ReadStream on: cleanedLine)).
    expr _ exprParser parseExpression.
    ^expr
!

handleElse
    state isHandled
	ifTrue: [ state ignoring: true ]
	ifFalse: [ state ignoring: false.
		   state handled: true ].
    'else ' print. state isIgnoring printNl.
!

handleElif
    | expr | 
    state isHandled
	ifTrue: [ state ignoring: true ]
	ifFalse:
	    [ expr _ self parseExpression.
	      (expr evaluate) ~= 0
		  ifTrue: [ state handled: true; ignoring: false ]
		  ifFalse: [ state ignoring: false ] ].
    'elif ' print. state isIgnoring printNl.
!

handleEndif
    'endif ' printNl.
    state _ stateStack removeFirst.
! 

skipDirective
    "does doing nothing work for pragmas etc.?"
    ^self
! !


!PPStream methodsFor: 'private'!

setStream: aStream
    super init: aStream.
    state _ PPState ignoring: false handled: false.
    stateStack _ OrderedCollection new.
    cppSymbols _ PreprocessorStream symbols.
    cppSymbols at: (IdentifierTok value: 'defined') put: 1. "value does not matter"
! !


PPStream initialize!
PreprocessorStream initialize!
