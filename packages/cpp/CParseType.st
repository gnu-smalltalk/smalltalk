"======================================================================
|
|   C type declaration parser, part of the C header parser.
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



"Here's the probelm:

at what level is the symbol table management done?  we could do it here,
just parsing whatever we come to, and recording the declarations into the
symbol table.  

Alternatively (the way the code is set up), this code just returns the
 declarations in some form (symbol table entries would be ok), and allows
the higher level code to make the determinatino about how to deal with them.
 This allows for some degree of reentrancy to the system.

The symbol table itself is available to both levels, and is kept as up to date
 as possible.

I like the reentrancy aspect enough more than the pain of having to hang onto
 some partially formed declaration, so that's what we'll go with.

"

"
OOPS -- seems that the direct tree building trick won't work quite right -- 
looks like we need to build a parse tree and then scan it for declarations.
Sigh.
"

"Another problem: how to typedefs work?  They are currently stored exactly 
 like normal variable declarations.  We need to detect them (relatively easy),
 and then use them (somewhat hard).  

The issue is that they are correct, except that they may have a scope 
 (which we don't need), they are marked as being a typedef, which means
that if we use them direclty, we can mistakenly interpret their 
instantiations as typedefs, and, where we logically need to plug them into
the type chain is at the bottom of the typedef, where the typedef name is.

When we use them, we can create a a new node which has the specifier, and
the raw type (somehow remove the name part, and possibly replace it ...
hmm... the problem is that we are at the right place when we replace the name, 
but at the wrong time.  And, when we are at the right time (like when the 
CDeclaration node is being created with the specifier and the declarator, 
we have already removed the name. 

If there was a way to get code to recurse through the specifier (hierarchy) 
I guess last, then that would work.  If the type-building (or whatever)
operation returned the built type, and then passing that type on as the 
base type (in place of the specifier) to the declarator.  This means
that the specifier accessing protocol might need to be a little more complex 
to account for this case.

Somehow, it does not feel general enough -... so what would feel general
 enough?  There are a bunch of different types of objects: type definitions,
 struct definitions, enum definitions, variable definitions, function
 declarations, (function definitions), variable declarations.

{note that we have to be somewhat careful -- variable declarations can
occur in the .h files, but probably not variable definitions.  Although,
some struct declarations may appear before the struct declaration, if used as a
 pointer, -- may need to be careful about merging them into the symbol table.}

You'd be able to tell a typedef right off.  You'd have a way to get the
type out, and use it as the base type for the rest of what you are
declaring.  

"


Object subclass: #CTypeParser
       instanceVariableNames: 'stream'
       classVariableNames: 'SymbolTable'
       poolDictionaries: 'CKeywords CToks'
       category: nil
!


CTypeParser comment:
'I parse C declarations (and some simple definitions), and yield useful
structures.  I appear to my caller to be a stream of declaration objects,
which can have "declare" invoked on them to make them register themselves
with the symbol table.  I return nil if I cannot parse, including eof.'
!

!CTypeParser class methodsFor: 'instance creation'!

on: aStream
    ^self new init: aStream
!

test: aFilename
    | s declarations |
    s _ self on: (PreprocessorStream on: (FileStream open: aFilename mode: 'r')).
    [ declarations _ s next.
      declarations notNil ] whileTrue: 
	[ declarations do: [ :decl | decl store ].
	  Transcript next: 70 put: $- ; nl; nl ].
! 

test2: aFilename
    | s declarations |
    s _ self on: (PreprocessorStream on: (FileStream open: aFilename mode: 'r')).
    [ declarations _ s next.
      declarations notNil ] whileTrue: 
	[ declarations do: [ :decl | decl declareInto: s symbolTable ].
	  Transcript next: 70 put: $- ; nl; nl ].
! 

testJust2: aFilename
    | s declarations |
    s _ self on: (PreprocessorStream on: (FileStream open: aFilename mode: 'r')).
    
    2 timesRepeat: 
	[ s next do: [ :decl | decl declareInto: s symbolTable.
			       decl store ].
	  Transcript next: 70 put: $- ; nl; nl. ].
! !


!CTypeParser methodsFor: 'accessing'!

next
    "Yields nil at end of stream, otherwise, yields the next
     declaration"
    stream atEnd
	ifTrue: [ ^ nil ].
    
    ^self parseDeclaration
! !



!CTypeParser methodsFor: 'parsing'!

    "grammar:
     <decl> ::= <declaration specifier>* [ <declarator list> ] ';'
     <declaration specifier> ::=
     	<storage class specifier>
     	| <type specifier>
     	| 'typedef'
     <storage class specifier> ::=
	'static'
	| 'auto'
	| 'register'
	| 'extern'  
     <type specifier> ::= 
     	<simple type name>
     	| <structoid specifier>
     	| <enum specifier>
     	| <elaborated type specifier>
     <simple type name> ::=
     	<ident (symbol table type)>
	| void | unsigned | ... (a list)
     <structoid specifier> ::= 
	<structoid start> '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression>
     <enum specifier> ::=
     	'enum' [ <ident> ] '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>
     <elaborated type specifier> ::= 
     	{ 'struct' | 'union' } <ident>
     	| 'enum' <ident (enum name)>
     <declarator list> ::= 
     	{ <init declarator> # ',' }+
     <init declarator> ::=
     	<declarator> [ <initializer> ]
     <declarator> ::=
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     	| '(' <expression list> ')'  ???
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "

parseDeclaration
     "<decl> ::= <declaration specifier>* [ <declarator list> ] ';'"
    | specifier declaration |
    specifier _ self parseDeclarationSpecifierList.
    declaration _ self parseDeclaratorList: specifier.
    stream next.		"gobble ';'"
    ^declaration
!      
     	

parseDeclarationSpecifierList
    | specifier |

    specifier _ CDeclarationSpecifier storageClass: nil type: CLangInt new.	"right?"
    [ (self parseDeclarationSpecifier: specifier) notNil ] whileTrue: [ ].
    ^specifier
!

parseDeclarationSpecifier: specifier
    | token |

    "parses:
     <declaration specifier> ::=
     	<storage class specifier>
     	| <type specifier>
     	| 'typedef'
     <storage class specifier> ::=
	'static'
	| 'auto'
	| 'register'
	| 'extern'  
     <type specifier> ::= 
     	<simple type name>
     	| <structoid specifier>
     	| <enum specifier>
     	| <elaborated type specifier>
     <simple type name> ::=
     	<ident (symbol table type)>
	| void | unsigned | ... (a list)
     <structoid specifier> ::= 
	<structoid start> '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression>
     <enum specifier> ::=
     	'enum' [ <ident> ] '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>
     <elaborated type specifier> ::= 
     	{ 'struct' | 'union' } <ident>
     	| 'enum' <ident (enum name)>
     "

    token _ stream peek.
    token isNil ifTrue: [ ^nil ]. "hit end of file"

    (self isStorageClassToken: token) ifTrue: 
	[ ^specifier storageClass: stream next ].
    
    token == EnumKey ifTrue: 
	[ ^specifier type: self parseEnumSpecifier ].

    token == TypedefKey ifTrue:
	[ stream next.
	  ^specifier isTypedef: true ].

    (self isStructoidToken: token) ifTrue:
	[ ^specifier type: self parseStructoid ].

    'here goes ' print. token printNl.
    (self isTypeName: token) ifTrue:
	[ '!!! Got atypedef' printNl.
	  ^specifier type: (self tokenToType: stream next) ].
    
    (self isSimpleType: token) ifTrue:
	[ ^specifier type: self parseSimpleTypeName ].
    ^nil			"nothing that we recognize, continue on"
!

isStorageClassToken: token
    ^(token == StaticKey) | (token == AutoKey) | (token == RegisterKey)
	| (token == ExternKey) 
!


isStructoidToken: token
    ^(token == StructKey) | (token == UnionKey)
!

isTypeName: token
    | symbol |
    token class == CIdentifierToken ifTrue: 
	[ symbol _ SymbolTable at: token.
	  symbol notNil ifTrue: 
	      [ ^symbol isTypedef ].
	 ].
    ^false
!

tokenToType: token
    | symbol |

    "Get this guy from the symbol table."
    symbol _ SymbolTable at: token.
    ^symbol typedefIntoType
!


isSimpleType: token
    ^(token == UnsignedKey) |
	(token == SignedKey) |
	(token == CharKey) |
	(token == ShortKey) |
	(token == IntKey) | 
	(token == LongKey) |
	(token == FloatKey) |
	(token == DoubleKey) |
	(token == VoidKey )
!

parseSimpleTypeName
    | token signedModifier sizeModifier |
    
    token _ stream peek.
    (token == UnsignedKey) | (token == SignedKey)
	ifTrue: [ signedModifier _ token.
		  stream next.
		  token _ stream peek ].
    "now, can have short, long, float, double, char, void or int.  We try for the 
     size modifiers first "
    (token == ShortKey) | (token == LongKey)
	ifTrue: [ sizeModifier _ token.
		  stream next.
		  token _ stream peek. ].
    "now just float, double, char, void, or int (or nothing)"
    token == FloatKey
	ifTrue: [ "hack the modifier here"
		  stream next.
		  ^CLangFloat new].
    token == DoubleKey
	ifTrue: [ "hack the modifier here" 
		  stream next.
		  ^CLangDouble new ].
    token == CharKey
	ifTrue: [ stream next.
		  signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedChar new ]
		      ifFalse: [ ^CLangChar new ]].
    token == VoidKey
	ifTrue: [ stream next.
		  ^CLangVoid new ].
    token == IntKey
	ifTrue: [ stream next. ].
    
    "Whether or not int was present doesn't matter here "
    sizeModifier == ShortKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedShort new ]
		      ifFalse: [ ^CLangShort new ] ].
    sizeModifier == LongKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedLong new ]
		      ifFalse: [ ^CLangLong new ] ].

    "In the default case, we're just an int"
    
    signedModifier == UnsignedKey
	ifTrue: [ ^CLangUnsignedInt new ]
	ifFalse: [ ^CLangInt new ]
!    


parseEnumSpecifier
    | token enumName enumList enumType |
    "Starts with stream before 'enum'
     <enum specifier> ::=
     	'enum' [ <ident> ] '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>
     <elaborated type specifier> ::= 
	[ ... ]
     	| 'enum' <ident (enum name)>
     "
    stream next.		"gobble enum"
    token _ stream peek.

    "can have either ident or open curly"
    token class == CIdentifierToken ifTrue:
	[ enumName _ stream next.
	  token _ stream peek ].
    
    token == OpenBraceTok ifTrue: 
	[ enumList _ self parseEnumList ].
    
    enumName notNil
	ifTrue: [ enumType _ self lookupEnumName: enumName.
		  enumType isNil ifTrue:
		      [ enumType _ CDeclarationEnum name: enumName
						    literals: enumList ].
		  ^enumType ]
	ifFalse: [ "just a raw enum -- build the type and return it"
		   ^CDeclarationEnum name: nil literals: enumList ].
!
	
parseEnumList
    | token enumList |

    "Starts parsing before the brace:
     '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>"

    enumList _ OrderedCollection new.
    self parseBracesWithCommas: [ enumList add: self parseEnumerator. ].
    ^enumList
!

parseEnumerator
    | name token value |

     "Starts before this production:
      <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>"

    name _ stream next.
    token _ stream peek.
    self gobbleEqualTok ifTrue: 
	[ value _ self parseConstantExpression. ].
    
    ^CDeclarationEnumerator name: name value: value
!


parseStructoid
    | token structType structName memberList |

    "We are at the start of this production, although we know it has to be 
     on one of the paths indicated:
     <type specifier> ::= 
     	<simple type name>
     	| *** <structoid specifier>
     	| <enum specifier>
     	| *** <elaborated type specifier>
     <structoid specifier> ::= 
	<structoid start> '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression>
     <elaborated type specifier> ::= 
     	{ 'struct' | 'union' } <ident>
     	| 'enum' <ident (enum name)> "

     structType _ stream next.	"either 'struct' or 'union'"
     
     token _ stream peek.
     token class == CIdentifierToken ifTrue: 
	 [ structName _ stream next.
	   token _ stream peek ].
     
     memberList _ OrderedCollection new.

     token == OpenBraceTok ifTrue: 
	 [ memberList _ self parseStructoidMemberList ].
     
     structType == StructKey
	 ifTrue: [ ^CDeclarationStruct name: structName members: memberList ]
	 ifFalse: [ ^CDeclarationUnion name: structName members: memberList ]
!

parseStructoidMemberList
    | memberList |

    "Here is what we parse:
     '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression> "
    
    stream next.		"gobble '{'"
     
    memberList _ OrderedCollection new.
    [ self gobbleCloseBraceTok ] whileFalse: 
	[ memberList add: self parseMember.  ].

    ^memberList
!

parseMember
    | declarationSpecifier  memberDeclaration |

    " parses 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression> 
	| : <constant expression> "
    
    declarationSpecifier _ self parseDeclarationSpecifierList.
    memberDeclaration _ self parseMemberDeclaratorList: declarationSpecifier.
    stream next.		"gobble ';'"
    ^memberDeclaration
!

parseMemberDeclaratorList: declarationSpecifier
    | declarator token declarationList |
    "
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression> 
	| : <constant expression> "

    declarationList _ OrderedCollection new.
    [ declarator _ self parseMemberDeclarator.
      declarationList add: (CDeclaration specifier: declarationSpecifier
					 declarator: declarator).
      token _ stream peek.
      self gobbleCommaTok ] whileTrue: [ ].
   ^declarationList
!    


parseMemberDeclarator
    | token declarator bitSize |
    " parses
     <member declarator> ::=
     	<declarator> 
     	| <declarator> ':' <constant expression> 
	| : <constant expression> "
    
    "Hmm -- guessing about parseDeclarator: "
    declarator _ self parseDeclarator.
    token _ stream peek.
    token == ColonTok
	ifTrue: [ stream next.	"gobble it"
		  bitSize _ self parseConstantExpression.
		  "!!! this may not be the right way to use declaration 
		   specifier/ parentType -- I think the declaration specifier 
		   is applied last after building the rest of the thing."
		  declarator _ CDeclarationBitfield parentType: declarator
						    length: bitSize ].
    ^declarator
!

parseDeclaratorList: specifier
    | list token declarator |

    "Parsing starts here:
     <declarator list> ::= 
     	{ <init declarator> # ',' }+
     <init declarator> ::=
     	<declarator> [ <initializer> ]
     <declarator> ::=
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     	| '(' <expression list> ')'  ???
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "

    "We pretend that we have seen these declarations all on separate lines, 
     and return an ordered collection of declarations"

    list _ OrderedCollection new.
    [ declarator _ self parseInitDeclarator.
      list add: (CDeclaration specifier: specifier
			      declarator: declarator).
      token _ stream peek.
      self gobbleCommaTok ] whileTrue: [ ].
    ^list

!

parseInitDeclarator
    | declarator token initializer |
    "parses:
     <init declarator> ::=
     	<declarator> [ <initializer> ]
     <declarator> ::=
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "
    
    declarator _ self parseDeclarator.
    self gobbleEqualTok ifTrue:
	[ initializer _ self parseInitializer.
	  ^CDeclarationInitialized declarator: declarator
				   initializer: initializer. ].
    ^declarator
!

parseInitializer
    | token initializerList |
    "We're just past the '=':
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     <initializer list> ::= 
	<assignment expression>
	| <initializer list> ',' <assignment expression>
     	| '{' <initializer list> [ ',' ] '}'
     "

    token _ stream peek.
    token == OpenBraceTok
	ifTrue: [ ^self parseInitializerList. ]
	ifFalse: [ ^self parseAssignmentExpression ]
!

parseInitializerList
    | token initializerList initializer | 
    "We are just at the '*' (just a marker, not in the stream)
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' * '{' <initializer list> [ ',' ] '}'
     <initializer list> ::= 
	<assignment expression>
	| <initializer list> ',' <assignment expression>
     	| '{' <initializer list> [ ',' ] '}'
     "
    
    stream next.		"gobble '{'"
    initializerList _ OrderedCollection new.
    [ token _ stream peek.
      token == OpenBraceTok
	  ifTrue: [ initializer _ self parseInitializerList ]
	  ifFalse: [ initializer _ self parseAssignmentExpression ].
      initializerList add: initializer.
      self gobbleCommaTok.	"eat a ',' if there is one"
      self gobbleCloseBraceTok.	"terminate if '}' seen"
      ] whileFalse: [ ].
    ^initializerList
!

OBSOLETEparseListOfInitializers
    | initializerList initializer |
    "We are just at the '*':
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| * '{' <initializer list> [ ',' ] '}'
     "
    
    stream next.		"gobble '{'"
    
    initializerList _ OrderedCollection new.
    [ initializer _ self parseInitializerList.
      initializerList add: initializer.
      self gobbleCommaTok ] whileTrue: [ ]. "not exactly right, but close "

    stream next.		"gobble '}'"
    ^initializerList
!

OBSOLETEparseListOfAssignmentExpressions
    | assignmentExprList assignmentExpr |
    
    "We are at the '*'
     <initializer list> ::= 
     	* { <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "

    assignmentExprList _ OrderedCollection new.
    [ assignmentExpr _ self parseAssignmentExpression.
      assignmentExprList add: assignmentExpr.
      self gobbleCommaTok ] whileTrue: [ ].

    ^assignmentExprList
!

parseDeclarator
    | token declarator |

    "Here we are at the core of the type parser.
     <declarator>
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     "

    token _ stream peek.

    (self isStarTok: token) 
	ifTrue: [ stream next.	"gobble the token "
		  declarator _ self parseDeclarator.
		  ^CDeclarationPtr declarator: declarator ].
    token == OpenParenTok
	ifTrue: [ stream next.	"gobble '('"
		  declarator _ self parseDeclarator.
		  stream next.	"gobble ')'" ].
    "We can do this because token hasn't changed and the choices are mutex"
    token class == CIdentifierToken
	ifTrue: [ declarator _ CDeclarationName name: stream next.
		  "should be an ident" ].
    
    ^self parseDeclaratorSuffixList: declarator
!

parseDeclaratorSuffixList: baseDeclarator
    | token declarator |
					     
    "We are at the '*'
     	| <declarator> * '(' <argument declaration list> ')'
     	| <declarator> * '[' [ <constant expression> ] ']'
     "

    token _ stream peek.

    token == OpenParenTok
	ifTrue: 
	    [ declarator _ self parseFunctionDeclaration: baseDeclarator. 
	      ^self parseDeclaratorSuffixList: declarator ].
    token == OpenBracketTok
	ifTrue: 
	    [ declarator _ self parseArrayDimension: baseDeclarator. 
	      ^self parseDeclaratorSuffixList: declarator ].
    ^baseDeclarator
!

parseFunctionDeclaration: baseDeclarator
    | argList |

    "We are at '*'
     <declarator> * '(' <argument declaration list> ')'"

    stream next.		"skip '('"
    argList _ self parseArgumentDeclarationList.
    stream next.		"skip ')'"
    
    ^CDeclarationFunction parentType: baseDeclarator arguments: argList
!

parseArgumentDeclarationList
    | token argList |
    "This parses 
     <argument declaration list> ::=
	| <empty> 
     	| '...' 
     	| <arg decl list> 
     	| <arg decl list> ',' '...'
     <arg decl list> ::=
	{ <argument declaration> # ',' }+
     "

    token _ stream peek.
    token == DotDotDotTok
	ifTrue: [ argList _ OrderedCollection new.
		  argList add: (CDeclarationArgEllipses new).
		  ^argList ].
    ^self parseArgDeclList
!

parseArgDeclList
    | token argDecl argList | 
    
    "Parses the productions marked with '*'
     <argument declaration list> ::=
	| * <empty> 
     	| '...' 
     	| * <arg decl list> 
     	| * <arg decl list> ',' '...'
     <arg decl list> ::=
	{ <argument declaration> # ',' }+
     "
    
    
    argList _ OrderedCollection new.
    
    argDecl _ self parseArgumentDeclaration.
    argDecl isNil
	ifTrue: 
	    [ " <empty> "
	      ^argList ].
    
    argList add: argDecl.
    [ self gobbleCommaTok ] whileTrue:
	[ token _ stream peek.
	  token == DotDotDotTok
	      ifTrue: [ argList add: CDeclarationArgEllipses new.
			^argList ].
	  argDecl _ self parseArgumentDeclaration.
	  argList add: argDecl ].
    ^argList
!


parseArgumentDeclaration
    | specifier declarator |

    "Parses:
     <argument declaration> ::=
	<declaration specifier>* <declarator>
    "
    specifier _ self parseDeclarationSpecifierList.
    declarator _ self parseDeclarator.
    ^CDeclarationArgument specifier: specifier declarator: declarator
!

parseArrayDimension: baseDeclarator
    | length t |
    "parses '[' [ <constant expression> ']' "
    t _ stream next.		"skip '['"
    stream peek class ~~ CloseBracketTok ifTrue: 
	[ length _ self parseConstantExpression. ].
    stream next.		"skip ']'"
					 
    ^CDeclarationArray length: length parentType: baseDeclarator
!

parseConstantExpression
    | parser |
    "May not be best to be on the stream..."
    parser _ CExpressionParser onStream: stream.
    "I decided to do the evaluation because almost always we only care
     about the evaluated expression and not the expression itself. Also,
     if the expression is not evaludated immediately and involves things 
     which can change due to further declarations, we could get a bad value."
    ^parser conditionalExpression evaluate
!


parseAssignmentExpression
    | parser |
    parser _ CExpressionParser onStream: stream.
    "I decided to do the evaluation because almost always we only care
     about the evaluated expression and not the expression itself. Also,
     if the expression is not evaludated immediately and involves things 
     which can change due to further declarations, we could get a bad value."
    ^parser assignExpression evaluate	 "!!!not the best -- a temp hack"
!




"------------ Utility methods below here -------------"

"
parseBraceAndCommaList: aBlock
    
    | assignmentExprList assignmentExpr |
    
    ""Parses 
     <brace and comma list> ::= 
     	'{' <some nonterminal > [ ',' ] '}'
     ""

    stream next.		""gobble '{'""
    
    assignmentExprList _ OrderedCollection new.
    [ assignmentExpr _ self parseAssignmentExpression.
      assignmentExprList add: assignmentExpr.
      self gobbleCommaTok ] whileTrue: [ ].

    stream next.		""gobble '}'""
    ^assignmentExprList
"


" self ifNextIs: ColonTok
       then: [ ablock ] ' should be expressed in terms of the method below'


  self ifNextIs: [ :token | ... ]
       do: [ stream next. ]	'gobble it'
       andThen: [ a block ]     'the main body'

"


gobbleCommaTok
    | token |

    "Answers true if it was able to grab the comma, and false if not"

    token _ stream peek.
    (token class == CBinaryOperatorToken
	and: [ token value = ',' ]) ifTrue:
	[ stream next.		"gobble it!"
	  ^true ].
    ^false
!				    
    

gobbleCloseBraceTok
    | token |

    "Answers true if it was able to grab the comma, and false if not"

    token _ stream peek.

    token == CloseBraceTok ifTrue:
	[ stream next.		"gobble it!"
	  ^true ].
    ^false
!				    
    

gobbleEqualTok
    | token |
    "Answers true if it was able to grab the '=', and false if not"

    token _ stream peek.
    (token class == CBinaryOperatorToken
	and: [ token value = '=' ]) ifTrue:
	[ stream next.		"gobble it!"
	  ^true ].
    ^false
!

parseBracesWithCommas: aBlock
    | token |
    "parses
     '{' { <some production> # ',' }* '}' "

    stream next.		"gobble '{'"
     
    [ self gobbleCloseBraceTok ] whileFalse:
	  [ aBlock value.
	    self gobbleCommaTok. ].
!




isEqualTok: token
    ^token class == CBinaryOperatorToken
	and: [ token value = '=' ]
!

isStarTok: token
    ^token class == COperatorToken
	and: [ token value = '*' ]
!

lookupEnumName: enumName
    ^SymbolTable atEnum: enumName
!


parseBalancedBraces
    | count token |
     "Parses a balanced, possibly nested, set of braces"

    count _ 1.
    [ count > 0 ] whileTrue: 
	[ token _ stream next.
	  token == OpenBraceTok
	      ifTrue: [ count _ count + 1 ].
	  token == CloseBraceTok
	      ifTrue: [ count _ count - 1 ].
	  ].
! !

"
parseTypeList
    ""Parses a C type list, either a single type name, or a compound type 
     like 'unsigned short'.""
    | token type signedModifier sizeModifier |
    token _ stream peek.
    (type _ SymbolTable at: token)
	notNil ifTrue: [ ^type ].
    signedModifier _ SignedKey.
    token == UnsignedKey 
	ifTrue: [ signedModifier _ UnsignedKey.
		  stream next.
		  token _ stream peek ].
    ""now, can have short, long, float, double, char, void or int.  We try for the 
     size modifiers first ""
    (token == ShortKey) | (token == LongKey)
	ifTrue: [ sizeModifier _ token.
		  stream next.
		  token _ stream peek. ].
    ""now just float, double, char, void, or int (or nothing)""
    token == float 
	ifTrue: [ ""hack the modifier here""
		  stream next.
		  ^CLangFloat new].
    token == double
	ifTrue: [ ""hack the modifier here"" 
		  stream next.
		  ^CLangDouble new ].
    token == char
	ifTrue: [ stream next.
		  signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedChar new ]
		      ifFalse: [ ^CLangChar new ]].
    token == void
	ifTrue: [ stream next.
		  ^CLangVoid new ].
    token == int
	ifTrue: [ stream next. ].
    
    ""Whether or not int was present doesn't matter here ""
    sizeModifier == ShortKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedShort new ]
		      ifFalse: [ ^CLangShort new ] ].
    sizeModifier == LongKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedLong new ]
		      ifFalse: [ ^CLangLong new ] ].

    ""In the default case, we're just an int""
    
    signedModifier == UnsignedKey
	ifTrue: [ ^CLangUnsignedInt new ]
	ifFalse: [ ^CLangInt new ]
!
"

!CTypeParser methodsFor: 'accessing'!

symbolTable
    ^SymbolTable
! !


!CTypeParser methodsFor: 'private'!

init: aStream
    stream _ aStream.
    SymbolTable _ CSymbolTable new.
! !

		      
    
    

"
| x |
     CTypeParser test: 'test.c'
!

"
