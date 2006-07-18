"======================================================================
|
|   Behavior Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005,2006
| Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: #Behavior
       instanceVariableNames: 'superClass subClasses methodDictionary 
    	    	    	       instanceSpec instanceVariables'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

Behavior comment: 
'I am the parent class of all "class" type methods.  My instances know
about the subclass/superclass relationships between classes, contain
the description that instances are created from, and hold the method
dictionary that''s associated with each class.  I provide methods for
compiling methods, modifying the class inheritance hierarchy, examining the
method dictionary, and iterating over the class hierarchy.' !

!Behavior methodsFor: 'instance variables'!

addInstVarName: aString
    "Add the given instance variable to instance of the receiver"
    | newInstanceVariables duplicated symbol |

    self validateIdentifier: aString.

    symbol := aString asSymbol.
    newInstanceVariables := instanceVariables isNil
	ifTrue: [ { symbol } ]
        ifFalse: [ instanceVariables copyWith: symbol ].

    duplicated := self superclass allInstVarNames includes: symbol.

    self
	updateInstanceVars: newInstanceVariables
	shape: self shape.

    duplicated ifTrue: [ self compileAll ].
    self compileAllSubclasses.
!

removeInstVarName: aString
    "Remove the given instance variable from the receiver and recompile
     all of the receiver's subclasses"

    | newInstanceVariables symbol index |

    symbol := aString asSymbol.
    index := instanceVariables findLast: [ :each | each = symbol ].
    index = 0 ifTrue: [ SystemExceptions.NotFound signalOn: symbol what: 'instance variable' ].

    newInstanceVariables := instanceVariables
	copyReplaceFrom: index to: index with: #().

    self
	updateInstanceVars: newInstanceVariables
	shape: self shape.

    self compileAll; compileAllSubclasses.
! !


!Behavior methodsFor: 'method dictionary'!

createGetMethod: what default: value
    "Create a method accessing the variable `what', with a default value
    of `value', using lazy initialization"

    ^self compile: ('%1
    "Answer the receiver''s %1. Its default value is %2"
    %1 isNil ifTrue: [ %1 := %2 ].
    ^%1' bindWith: what with: value)
!

createGetMethod: what
    "Create a method accessing the variable `what'."

    ^self compile: ('%1
    "Answer the receiver''s %1"
    ^%1' bindWith: what)
!

createSetMethod: what
    "Create a method which sets the variable `what'."

    | parameter |
    parameter := (what = 'value') ifTrue: [ 'theValue' ] ifFalse: [ 'value' ].
    
    ^self compile: ('%1: %2
    "Set the receiver''s %1 to %2"
    %1 := %2' bindWith: what with: parameter)
!

defineAsyncCFunc: cFuncNameString
    withSelectorArgs: selectorAndArgs
    args: argsArray

    "Please lookup the part on the C interface in the manual.  This method
     is deprecated, you should use the asyncCCall:args: attribute."

    | code |
    code := (
'%1
    <asyncCCall: ''%2'' args: #%3>')
	bindWith: selectorAndArgs
	with: cFuncNameString
	with: argsArray printString.

    ^self compile: code ifError: [ :file :line :error | code error: error ].
!

defineCFunc: cFuncNameString
    withSelectorArgs: selectorAndArgs
    returning: returnTypeSymbol 
    args: argsArray

    "Please lookup the part on the C interface in the manual.  This method
     is deprecated, you should use the cCall:returning:args: attribute."

    | code |
    code := (
'%1
    <cCall: ''%2'' returning: %3 args: #%4>')
	bindWith: selectorAndArgs
	with: cFuncNameString
	with: returnTypeSymbol storeString
	with: argsArray printString.

    ^self compile: code ifError: [ :file :line :error | code error: error ].
!

methodDictionary
    "Answer the receiver's method dictionary. Don't modify the method
     dictionary unless you exactly know what you're doing"
    ^methodDictionary
!

selectorsAndMethodsDo: aBlock
    "Evaluate aBlock, passing for each evaluation a selector that's
     defined in the receiver and the corresponding method."
    self methodDictionary isNil ifFalse: [
	self methodDictionary keysAndValuesDo: aBlock
    ]
!

methodDictionary: aDictionary
    "Set the receiver's method dictionary to aDictionary"
    | newDictionary |
    newDictionary := aDictionary collect: [ :each |
	each withNewMethodClass: self
    ].
    aDictionary become: newDictionary.
    Behavior flushCache.
    methodDictionary := aDictionary.
!

addSelector: selector withMethod: compiledMethod
    "Add the given compiledMethod to the method dictionary, giving it
     the passed selector. Answer compiledMethod"

    self methodDictionary isNil
	ifTrue: [ methodDictionary := MethodDictionary new ].
    ^self methodDictionary
	at: selector
	put: (compiledMethod withNewMethodClass: self selector: selector).
!

removeSelector: selector
    "Remove the given selector from the method dictionary, answer
     the CompiledMethod attached to that selector"
    ^self
	removeSelector: selector
	ifAbsent: [ SystemExceptions.NotFound signalOn: selector what: 'method' ]
!

removeSelector: selector ifAbsent: aBlock
    "Remove the given selector from the method dictionary, answer
     the CompiledMethod attached to that selector. If the selector cannot
     be found, answer the result of evaluating aBlock."

    self methodDictionary isNil ifTrue: [ ^aBlock value ].
    (self methodDictionary includesKey: selector) ifFalse: [ ^aBlock value ].
    ^self methodDictionary removeKey: selector ifAbsent: [ self error: 'huh?!?' ]
!

compile: code
    "Compile method source.  If there are parsing errors, answer nil.
     Else, return a CompiledMethod result of compilation"
    (code isKindOf: PositionableStream)
    	ifTrue: [ ^self compileString: code contents ].
    (code isMemberOf: String)
    	ifFalse: [ ^self compileString: code asString ].
    ^self compileString: code
!

compile: code ifError: block
    "Compile method source.  If there are parsing errors, invoke
     exception block, 'block' passing file name, line number and error.
     description. Return a CompiledMethod result of compilation"
    (code isKindOf: PositionableStream)
	ifTrue: [ ^self compileString: code contents ifError: block ].
    (code isMemberOf: String)
	ifFalse: [ ^self compileString: code asString ifError: block ].
    ^self compileString: code ifError: block.
!

compile: code notifying: requestor
    "Compile method source.  If there are parsing errors, send #error:
     to the requestor object, else return a CompiledMethod result of
     compilation"
    | method |
    method := self compile: code.
    method isNil ifTrue: [ requestor error: 'Compilation failed' ].
    ^method
!

compileAllSubclasses: aNotifier
    "Recompile all selector of all subclasses. Notify aNotifier by sen-
     ding #error: messages if something goes wrong."
    self allSubclassesDo: [ :subclass | subclass compileAll: aNotifier ]
!

compileAllSubclasses
    "Recompile all selector of all subclasses. Notify aNotifier by sen-
     ding #error: messages if something goes wrong."
    self allSubclassesDo: [ :subclass | subclass compileAll ]
!

recompile: selector
    "Recompile the given selector, answer nil if something goes wrong or
     the new CompiledMethod if everything's ok."

    | source category ok |
    ok := [
	source := self sourceCodeAt: selector.
    	category := (self compiledMethodAt: selector) methodCategory.
	true
    ] on: Error do: [ :ex | ex return: false ].

    ok ifFalse: [ ^nil ].
    RegressionTesting ifFalse: [
        Transcript
	    nextPutAll: 'Recompiling selector: ';
	    print: selector asSymbol; nl.
    ].

    ^self compile: source classified: category
!

recompile: selector notifying: aNotifier
    "Recompile the given selector.  If there are parsing errors, send #error:
     to the aNotifier object, else return a CompiledMethod result of
     compilation"

    | source category ok |
    ok := [
	source := self sourceCodeAt: selector.
    	category := (self compiledMethodAt: selector) methodCategory.
	true
    ] on: Error do: [ :ex | ex return: false ].

    ok ifFalse: [ ^nil ].
    RegressionTesting ifFalse: [
        Transcript
	    nextPutAll: 'Recompiling selector: ';
	    print: selector asSymbol; nl.
    ].

    ^self compile: source classified: category notifying: aNotifier
!

decompile: selector
    "Decompile the bytecodes for the given selector."

    | method source |
    method := self compiledMethodAt: selector.
    source := method methodSourceString.
    ^source isNil & self decompilerClass notNil
	ifTrue: [ self decompilerClass decompile: selector in: self ]
    	ifFalse: [ source ]
!

edit: selector
    "Open Emacs to edit the method with the passed selector, then compile it"
    | method sourceFile sourcePos |
    method := self compiledMethodAt: selector.
    sourceFile := method methodSourceFile.
    sourceFile isNil
    	ifTrue: [ ^self error: 'decompiler can''t edit methods without source' ].
    sourcePos := method methodSourcePos.
    Smalltalk system: 'emacs -l st -smalltalk ', sourceFile, ' ', sourcePos printString

"   Possible Windows code follows: ""
    method := self >> selector.
    sourceFile := method methodSourceCode asString.
    sourcePos := sourceFile size.

    (sourceFile at: sourcePos) = $!
	ifTrue: [ sourcePos := sourcePos - 1 ].

    (FileStream open: 'st.tmp' mode: FileStream write)
	nextPutAll: (sourceFile copyFrom: 1 to: sourcePos);
	close.

    Smalltalk system: 'notepad st.tmp'.

    sourceFile := FileStream open: 'st.tmp' mode: FileStream read.
    self compile: sourceFile contents.
    sourceFile close.

    (self >> selector) methodCategory: method methodCategory.

    Smalltalk system: 'del st.tmp' "
!

compileAll
    "Recompile all selectors in the receiver. Ignore errors."
    self methodDictionary notNil
	ifTrue: [
	    RegressionTesting ifFalse: [
	        Transcript nextPutAll: 'Recompiling class: '; print: self; nl.
	    ].
	    self methodDictionary keysDo: 
		      [ :selector | self recompile: selector ] ]
!

compileAll: aNotifier
    "Recompile all selectors in the receiver. Notify aNotifier by sen-
     ding #error: messages if something goes wrong."
    self methodDictionary notNil
	ifTrue: [
	    RegressionTesting ifFalse: [
	        Transcript nextPutAll: 'Recompiling class: '; print: self; nl.
	    ].
	    self methodDictionary keysDo: 
		      [ :selector | self recompile: selector notifying: aNotifier] ]
! !



!Behavior methodsFor: 'evaluating'!

evalString: aString to: anObject
    "Answer the stack top at the end of the evaluation of the code in
     aString. The code is executed as part of anObject"
    | s result next method |
    s := ReadStream on: aString.
    [
	next := self extractEvalChunk: s.
	method := anObject class
	    compileString: 'Doit ^ [
', next, ' ] value ' ifError: [ :fname :line :error | nil ]. 

	method isNil | (next allSatisfy: [ :each | each = Character space ])
	    ifFalse: [ [ result := anObject perform: method ] valueWithUnwind ].

	s atEnd ] whileFalse.

    anObject class removeSelector: #Doit ifAbsent: [].
    ^result
!

evalString: aString to: anObject ifError: aBlock
    "Answer the stack top at the end of the evaluation of the code in
     aString. If aString cannot be parsed, evaluate aBlock (see
     compileString:ifError:). The code is executed as part of anObject"
    | s result next method |

    s := ReadStream on: aString.
    [
	next := self extractEvalChunk: s.
	method := anObject class
	    compileString: 'Doit ^ [
', next, ' ] value '
	    ifError: [:fname :lineNo :errorString | 
		aBlock value: fname value: lineNo - 1 value: errorString.
		nil
	    ].

	method isNil | (next allSatisfy: [ :each | each = Character space ])
	    ifFalse: [ [ result := anObject perform: method ] valueWithUnwind ].

	s atEnd ] whileFalse.

    anObject class removeSelector: #Doit ifAbsent: [].
    ^result
!

evaluate: code
    "Evaluate Smalltalk expression in 'code' and return result."

    (code isKindOf: PositionableStream)
	ifTrue: [ ^self evalString: code contents to: nil ].
    (code isMemberOf: String)
	ifFalse: [ ^self evalString: code asString to: nil ].
    ^self evalString: code to: nil
!


evaluate: code ifError: block
    "Evaluate 'code'.  If a parsing error is detected, invoke 'block'"

    (code isKindOf: PositionableStream)
	ifTrue: [ ^self evalString: code contentsto: nil ifError: block ].
    (code isMemberOf: String)
	ifFalse: [ ^self evalString: code asString to: nil ifError: block ].
    ^self evalString: code to: nil ifError: block.
!

evaluate: code to: anObject ifError: block
   "Evaluate Smalltalk expression as part of anObject's method definition.  This 
    method is used to support Inspector expression evaluation.  If a parsing error 
    is encountered, invoke error block, 'block'" 

   (code isKindOf: PositionableStream)
	ifTrue: [ ^self evalString: code contents to: anObject ifError: block ].
    (code isMemberOf: String)
	ifFalse: [ ^self evalString: code asString to: anObject ifError: block ].
    ^self evalString: code to: anObject ifError: block.
!

evaluate: code to: anObject 
    "Evaluate Smalltalk expression as part of anObject's method definition"

    (code isKindOf: PositionableStream)
	ifTrue: [ ^self evalString: code contents to: anObject ].
    (code isMemberOf: String)
	ifFalse: [ ^self evalString: code asString to: anObject ].
    ^self evalString: code to: anObject.
!

evaluate: code notifying: requestor
    "Evaluate Smalltalk expression in 'code'. If a parsing error is encountered, 
    send #error: to requestor"
    | method aStream |
    ^self evaluate: code ifError: [:fname :lineNo :errorString | 
		requestor error: ('line ', lineNo printString, ': ' , errorString) ].
! !


!Behavior methodsFor: 'creating a class hierarchy'!

superclass: aClass
    "Set the receiver's superclass."
    superClass := aClass.
    instanceSpec isNil ifTrue: [
	instanceSpec := aClass isNil
	    ifTrue: [ 0 ]
	    ifFalse: [ aClass instanceSpec ]
    ].
!

addSubclass: aClass
    "Add aClass asone of the receiver's subclasses."
    subClasses isNil 
	ifTrue: [ subClasses := Array new ]
	ifFalse: [ "remove old class if any"
		  subClasses := subClasses copyWithout: aClass ].
    subClasses := subClasses copyWith: aClass
!

removeSubclass: aClass
    "Remove aClass from the list of the receiver's subclasses"
    subClasses := subClasses copyWithout: aClass
! !



!Behavior methodsFor: 'accessing the methodDictionary'!

selectors
    "Answer a Set of the receiver's selectors"
    self methodDictionary isNil
    	ifTrue: [ ^Set new ]
	ifFalse: [ ^self methodDictionary keys ]
!

allSelectors
    "Answer a Set of all the selectors understood by the receiver"
    | aSet |
    aSet := self selectors.
    self allSuperclassesDo:
    	[ :superclass | aSet addAll: superclass selectors ].
    ^aSet
!

compiledMethodAt: selector ifAbsent: aBlock
    "Return the compiled method associated with selector, from the local
    method dictionary.  Evaluate aBlock if not found."
    self methodDictionary isNil ifTrue: [ ^aBlock value ].
    ^self methodDictionary at: selector ifAbsent: aBlock
!

compiledMethodAt: selector
    "Return the compiled method associated with selector, from the local
    method dictionary.  Error if not found."
    self methodDictionary isNil ifTrue: [
	SystemExceptions.NotFound signalOn: selector what: 'key' ].
    ^self methodDictionary at: selector ifAbsent: [
	SystemExceptions.NotFound signalOn: selector what: 'key' ].
!

>> selector
    "Return the compiled method associated with selector, from the local
    method dictionary.  Error if not found."
    self methodDictionary isNil ifTrue: [
	SystemExceptions.NotFound signalOn: selector what: 'key' ].
    ^self methodDictionary at: selector ifAbsent: [
	SystemExceptions.NotFound signalOn: selector what: 'key' ].
!

selectorAt: method
    "Return selector for the given compiledMethod"
    self methodDictionary isNil ifTrue: [
	SystemExceptions.NotFound signalOn: method what: 'method' ].
    ^self methodDictionary keyAtValue: method ifAbsent: [
        SystemExceptions.NotFound signalOn: method what: 'method' ].
!

sourceCodeAt: selector
    "Answer source code (if available) for the given compiledMethod"
    | source |
    source := (self compiledMethodAt: selector) methodSourceCode.
    source isNil ifTrue: [ ^'" *** SOURCE CODE NOT AVAILABLE *** "' copy ].
    ^source asString
!

sourceMethodAt: selector
    "This is too dependent on the original implementation"
    self shouldNotImplement
! !



!Behavior methodsFor: 'accessing instances and variables'!

allInstances
    "Returns a set of all instances of the receiver"
    | result weakResult anInstance |
    result := WriteStream on: (Array new: 100).
    anInstance := self someInstance.
    [ anInstance notNil ] whileTrue: [
	result nextPut: anInstance.
    	anInstance := anInstance nextInstance ].

    result := result contents.
    weakResult := WeakArray new: result size.
    1 to: result size do: [ :i |
	weakResult at: i put: (result at: i)
    ].
    ^weakResult
!

instanceCount
    "Return a count of all the instances of the receiver"
    | count anInstance |
    count := 0.
    anInstance := self someInstance.
    [ anInstance notNil ]
    	whileTrue: [ count := count + 1.
	    	     anInstance := anInstance nextInstance ].    
    ^count
!
    
instVarNames
    "Answer an Array containing the instance variables defined by the receiver"
    | superVars |
    instanceVariables isNil ifTrue: [ ^#() ].
    superClass isNil
	ifTrue: [ ^instanceVariables copy ]
	ifFalse: [ superVars := superClass allInstVarNames.
		   ^instanceVariables copyFrom: superVars size+1 
				      to: instanceVariables size ]
!

subclassInstVarNames
    "Answer the names of the instance variables the receiver inherited from its
     superclass"
    | superVars |
    instanceVariables isNil ifTrue: [ ^#() ].
    superClass isNil ifTrue: [ ^#() ].

    ^superClass allInstVarNames
!

allInstVarNames
    "Answer the names of every instance variables the receiver contained in the
     receiver's instances"
    ^instanceVariables isNil ifTrue: [#()] ifFalse: [instanceVariables].
!

classVarNames
    "Answer all the class variables for instances of the receiver"
    ^self superclass isNil
	ifTrue: [ #() ]
	ifFalse: [ self superclass classVarNames ]
!

allClassVarNames
    "Return all the class variables understood by the receiver"
    | result |
    result := WriteStream with: self classVarNames asArray.
    self allSuperclassesDo: [ :each |
	result nextPutAll: each classVarNames
    ].
    ^result contents
!

classPool
    "Answer the class pool dictionary. Since Behavior does not support
     classes with class variables, we answer an empty one; adding
     variables to it results in an error."
    ^Dictionary new makeReadOnly: true; yourself
!

sharedPools
    "Return the names of the shared pools defined by the class"
    ^self superclass isNil
	ifTrue: [ #() ]
	ifFalse: [ self superclass sharedPools ]
!

allSharedPools
    "Return the names of the shared pools defined by the class and any of
     its superclasses"
    | result |
    result := self sharedPools asSet.
    self environment withAllSuperspacesDo: [ :each |
	result add: each name asSymbol
    ].
    self allSuperclassesDo: [ :each |
	result addAll: each sharedPools
    ].
    ^result asArray
! !



!Behavior methodsFor: 'accessing class hierarchy'!

subclasses
    "Answer the direct subclasses of the receiver in a Set"
    subClasses isNil
	ifTrue: [ ^Set new ]
	ifFalse: [ ^subClasses asSet ]
!

allSubclasses
    "Answer the direct and indirect subclasses of the receiver in a Set"
    | aSet |
    aSet := Set new.
    self allSubclassesDo: [ :subclass | aSet add: subclass ].
    ^aSet
!

withAllSubclasses
    "Answer a Set containing the receiver together with its direct and
     indirect subclasses"
    | aSet |
    aSet := Set with: self.
    aSet addAll: (self allSubclasses).
    ^aSet
!

superclass
    "Answer the receiver's superclass (if any, otherwise answer nil)"
    ^superClass
!

withAllSuperclasses
    "Answer the receiver and all of its superclasses in a collection"
    | supers |
    supers := OrderedCollection with: self.
    self allSuperclassesDo:
    	[ :superclass | supers addLast: superclass ].
    ^supers
!


allSuperclasses
    "Answer all the receiver's superclasses in a collection"
    | supers |
    supers := OrderedCollection new.
    self allSuperclassesDo:
    	[ :superclass | supers addLast: superclass ].
    ^supers
! !



!Behavior methodsFor: 'testing the method dictionary'!

whichSelectorsReferToByteCode: aByteCode
    "Return the collection of selectors in the class which
     reference the byte code, aByteCode"
    | s method specialSelector |
    s := Set new.
    self methodDictionary isNil ifTrue: [ ^s ].
    self methodDictionary keysAndValuesDo:
	[ :sel :method |
	    ((1 to: method numBytecodes) detect:
		[ :i | aByteCode = (method bytecodeAt: i)]
			ifNone: [0]) > 0 
				ifTrue: [ s add: sel ].
	].
    ^s
!

hasMethods
    "Return whether the receiver has any methods defined"

    ^self methodDictionary notNil and: [ self methodDictionary notEmpty ]
!

includesSelector: selector
    "Returns true if the local method dictionary contains the given selector"
    self methodDictionary isNil ifTrue: [ ^false ].
    ^self methodDictionary includesKey: selector
!

canUnderstand: selector
    "Returns true if the instances of the receiver understand
     the given selector"
    (self includesSelector: selector)
    	ifTrue: [ ^true ].
    self allSuperclassesDo:
    	[ :superclass | (superclass includesSelector: selector)
	    	    	    ifTrue: [ ^true ] ].
    ^false
!

whichClassIncludesSelector: selector
    "Answer which class in the receiver's hierarchy contains the implementation
     of selector used by instances of the class (nil if none does)"
    self withAllSuperclassesDo:
    	[ :superclass | (superclass includesSelector: selector)
	    	    	    ifTrue: [ ^superclass ] ].
    ^nil
!

whichSelectorsRead: instVarName
    "Answer a Set of selectors which read the given instance variable"
    | md index |
    index := self allInstVarNames
	indexOf: instVarName asSymbol
	ifAbsent: [ ^Set new ].   " ### should it raise an error?"
    
    md := self methodDictionary.
    md isNil ifTrue: [ ^Set new ].
    ^(md select: [ :each | each reads: index - 1 ])
	keys
!

whichSelectorsAssign: instVarName
    "Answer a Set of selectors which read the given instance variable"
    | md index |
    index := self allInstVarNames
	indexOf: instVarName asSymbol
	ifAbsent: [ ^Set new ].   " ### should it raise an error?"
    
    md := self methodDictionary.
    md isNil ifTrue: [ ^Set new ].
    ^(md select: [ :each | each assigns: index - 1 ])
	keys
!

whichSelectorsAccess: instVarName
    "Answer a Set of selectors which access the given instance variable"
    | md index |
    index := self allInstVarNames
	indexOf: instVarName asSymbol
	ifAbsent: [ ^Set new ].   " ### should it raise an error?"
    
    md := self methodDictionary.
    md isNil ifTrue: [ ^Set new ].
    ^(md select: [ :each | each accesses: index - 1 ])
	keys
!

whichSelectorsReferTo: anObject
    "Returns a Set of selectors that refer to anObject"
    | md |
    md := self methodDictionary.
    md isNil ifTrue: [ ^Set new ].
    ^(md select: [ :each | each refersTo: anObject ])
	keys
!

scopeHas: name ifTrue: aBlock
    "If methods understood by the receiver's instances have access to a
     symbol named 'name', evaluate aBlock"

    | nameSym |
    nameSym := name asSymbol.
    (self allInstVarNames includes: nameSym) ifTrue: [ ^aBlock value ].
    (self allClassVarNames includes: nameSym) ifTrue: [ ^aBlock value ].
    (self environment includesKey: nameSym) ifTrue: [ ^aBlock value ].

    self allSharedPools do: [ :dictName |
	((self environment at: dictName asGlobalKey) includesKey: nameSym)
			  ifTrue: [ ^aBlock value ] ]
! !



!Behavior methodsFor: 'testing the form of the instances'!

isPointers
    "Answer whether the instance variables of the receiver's instances
     are objects"
    ^(self instanceSpec bitAnd: 31) = 31
!

isIdentity
    "Answer whether x = y implies x == y for instances of the receiver"
    ^false
!

isImmediate
    "Answer whether, if x is an instance of the receiver, x copy == x"
    ^false
!

isFixed
    "Answer whether the receiver's instances have no indexed
     instance variables"
    ^self isVariable not
!

isVariable
    "Answer whether the receiver's instances have indexed instance variables"
    ^(self instanceSpec bitAt: 5) ~= 0
!

instSize
    "Answer how many fixed instance variables are reserved to each of the
     receiver's instances"
    ^self instanceSpec bitShift: -12
! !



!Behavior methodsFor: 'testing the class hierarchy'!

includesBehavior: aClass
    "Returns true if aClass is the receiver or a superclass of the receiver."

    ^self == aClass or: [ self inheritsFrom: aClass ]
!

inheritsFrom: aClass
    "Returns true if aClass is a superclass of the receiver"
    | sc |
    sc := self.
    [ sc := sc superclass.
      sc isNil ]
    	whileFalse:
	    [ sc == aClass ifTrue: [ ^true ] ].
    ^false
!

kindOfSubclass
    "Return a string indicating the type of class the receiver is"
    self isVariable ifFalse: [ ^'subclass:' ].
    self isPointers ifFalse: [ ^'variableSubclass:' ].
    ^'variable: ', self shape storeString, 'subclass:'
!

shapes
    ^#(#int8 #byte #character #short #ushort #int #uint #float #int64 #uint64
       #double #utf32 nil nil nil #pointer)
!

shape
    self isVariable ifFalse: [ ^nil ].
    ^self shapes at: (instanceSpec bitAnd: 15) + 1
! !



!Behavior methodsFor: 'enumerating'!

allSubclassesDo: aBlock
    "Invokes aBlock for all subclasses, both direct and indirect."
    subClasses isNil ifTrue: [ ^self ].

    subClasses do: [ :class |
	aBlock value: class.
	class allSubclassesDo: aBlock
    ].
!

allSuperclassesDo: aBlock
    "Invokes aBlock for all superclasses, both direct and indirect."
    | class superclass |
    class := self.
    [ superclass := class superclass.
      class := superclass.
      superclass notNil ] whileTrue:
      	[ aBlock value: superclass ]
!

withAllSubclassesDo: aBlock
    "Invokes aBlock for the receiver and all subclasses, both direct
     and indirect."
    aBlock value: self.
    self allSubclassesDo: aBlock.
!

withAllSuperclassesDo: aBlock
    "Invokes aBlock for the receiver and all superclasses, both direct
     and indirect."
    | class |
    class := self.
    [ aBlock value: class.
      class := class superclass.
      class notNil ] whileTrue
!

allInstancesDo: aBlock
    "Invokes aBlock for all instances of the receiver"
    | anInstance |
    anInstance := self someInstance.
    [ anInstance notNil ] whileTrue: [
        aBlock value: anInstance.
        anInstance := anInstance nextInstance ].
!

allSubinstancesDo: aBlock
    "Invokes aBlock for all instances of each of the receiver's subclasses."
    | oopIndex object classes last ok |
    classes := IdentitySet withAll: self allSubclasses.

    "Break-even point found by trial and error"
    classes size < 17 ifTrue: [
	classes do: [ :each | each allInstancesDo: aBlock ].
	^self
    ].

    "Use a more complicated walk when there are many subclasses."
    classes := (IdentitySet new: classes size * 3)
    	addAll: classes;
	yourself.

    "Get the first OOP.  Implementation dependent!"
    oopIndex := 0 asCharacter asOop.
    [
        object := oopIndex asObject.

        "Simple-minded caching"
        object class == last ifFalse: [
	   ok := classes includes: (last := object class).
        ].

        ok ifTrue: [ aBlock value: object ].
        (oopIndex := oopIndex nextValidOop) isNil
    ] whileFalse.
!

selectSubclasses: aBlock
    "Return a Set of subclasses of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSubclassesDo: [ :subclass | (aBlock value: subclass)
    	    	    	    	    	    ifTrue: [ aSet add: subclass ] ].
    ^aSet
!

selectSuperclasses: aBlock
    "Return a Set of superclasses of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSuperclassesDo: [ :superclass | (aBlock value: superclass)
    	    	    	    	    	    ifTrue: [ aSet add: superclass ] ].
    ^aSet
!

subclassesDo: aBlock
    "Invokes aBlock for all direct subclasses."
    subClasses isNil ifTrue: [ ^self ].
    subClasses do: aBlock
! !



!Behavior methodsFor: 'compilation (alternative)'!

methods
    "Don't use this, it's only present to file in from Smalltalk/V"
    ^self methodsFor: 'no category'
!

methodsFor
    "Don't use this, it's only present to file in from Dolphin Smalltalk"
    ^self methodsFor: 'no category'
!

methodsFor: category ifFeatures: features
    "Start compiling methods in the receiver if this implementation of
     Smalltalk has the given features, else skip the section"
    ^self methodsFor: category ifTrue: (Smalltalk hasFeatures: features)
!

methodsFor: category stamp: notUsed
    "Don't use this, it's only present to file in from Squeak"
    ^self methodsFor: category
!

privateMethods
    "Don't use this, it's only present to file in from IBM Smalltalk"
    ^self methodsFor: 'private'
!

publicMethods
    "Don't use this, it's only present to file in from IBM Smalltalk"
    ^self methodsFor: 'public'
! !


!Class methodsFor: 'security'!

check: aPermission
    self securityPolicy isNil ifTrue: [ ^self isUntrusted not ].
    ^self securityPolicy check: aPermission
! !


!Behavior methodsFor: 'support for lightweight classes'!

article
    "Answer an article (`a' or `an') which is ok for the receiver's name"
    ^self superclass article
!

asClass
    "Answer the first superclass that is a full-fledged Class object"
    ^self superclass asClass
!

environment
    "Answer the namespace that this class belongs to - the same as the
     superclass, since Behavior does not support namespaces yet."
    ^self superclass environment
!

nameIn: aNamespace
    "Answer the class name when the class is referenced from aNamespace
     - a dummy one, since Behavior does not support names."
    ^'<no name>'
!

securityPolicy
    ^self asClass securityPolicy
!

securityPolicy: aSecurityPolicy
    self shouldNotImplement
!

printOn: aStream in: aNamespace
    "Answer the class name when the class is referenced from aNamespace
     - a dummy one, since Behavior does not support names."
    aStream nextPutAll: (self nameIn: aNamespace)
!

name
    "Answer the class name; this prints to the name of the superclass
     enclosed in braces.  This class name is used, for example, to print
     the receiver."
    ^'{%1}' bindWith: self asClass printString
! !


!Behavior methodsFor: 'instance creation'!

newInFixedSpace: numInstanceVariables
    "Create a new instance of a class with indexed instance variables. The
     instance has numInstanceVariables indexed instance variables.  The
     instance is guaranteed not to move across garbage collections.  If
     a subclass overrides #new:, the changes will apply to this method too."
    ^(self new: numInstanceVariables) makeFixed
!

newInFixedSpace
    "Create a new instance of a class without indexed instance variables. 
     The instance is guaranteed not to move across garbage collections.
     If a subclass overrides #new, the changes will apply to this method too."
    ^self new makeFixed
! !


!Behavior methodsFor: 'private'!

extractEvalChunk: aStream
    "Private - Extract the code in the next evaluation chunk (i.e. the code
     until the next bang which is outside string literals or comments)"

    | code ch |
    code := WriteStream on: (String new: 100).
    [   aStream atEnd ] whileFalse: [
	ch := aStream next.
	ch = $! ifTrue: [ ^code contents ].

	code nextPut: ch.
	ch = $" ifTrue: [ code nextPutAll: (aStream upTo: ch); nextPut: ch ].
	ch = $' ifTrue: [
	    [
		code
		    nextPutAll: (aStream upTo: ch);
		    nextPut: $'.
		aStream atEnd not and: [ aStream peekFor: ch ]
	    ]   whileTrue: [
		code nextPut: ch.
	    ]
	].
    ].
    ^code contents
!

instanceSpec
    ^instanceSpec
!

setInstanceSpec: shape instVars: anIntegerSize
    instanceSpec := anIntegerSize bitShift: 12.
    shape isNil ifFalse: [
	instanceSpec := instanceSpec
	    bitOr: 15 + (self shapes
			    indexOf: shape
			    ifAbsent: [ self error: 'invalid shape value' ]) ].

!

sharedPoolDictionaries
    "Return the shared pools (not the names!) defined by the class"
    ^self superclass sharedPoolDictionaries
!

setInstanceVariables: instVariableArray
    instanceVariables := instVariableArray
!

validateIdentifier: token
    "Token is a string or string-oid"
    | firstTime |
    firstTime := true.
    token do: [ :ch |
        (ch isLetter | (firstTime not and: [ ch = $_ | ch isDigit ]))
            ifFalse: [ SystemExceptions.InvalidValue signalOn: token reason: 'invalid Smalltalk identifier' ].

        firstTime := false
    ].
    ^true
!

updateInstanceVars: variableArray
    shape: shape

    "Update instance variables and instance spec of the class and all
     its subclasses"

    | instVarMap startOfInstanceVars endOfInstanceVars newInstanceVars 
       oldInstVars oldClass instances |

    startOfInstanceVars := self superclass instSize + 1.
    endOfInstanceVars := self instSize.
    newInstanceVars := variableArray
	copyFrom: startOfInstanceVars 
	to: variableArray size. 

    oldInstVars :=  self allInstVarNames. 
    instVarMap := Array new: newInstanceVars size.
    startOfInstanceVars to: endOfInstanceVars do: [ :i || map |
	map := newInstanceVars findLast: [ :each | each = (oldInstVars at: i) ]. 
	map > 0 ifTrue: [instVarMap at: map put: i]
    ].

    "Fix up all subclasses."
    self allSubclassesDo: [ :sc || iv |
	oldClass := Behavior new.
	oldClass superclass: sc.
	instances := sc allInstances.
	instances do: [ :each | each changeClassTo: oldClass ].

	iv := sc allInstVarNames
	    copyReplaceFrom: startOfInstanceVars
	    to: endOfInstanceVars
	    with: newInstanceVars.

	sc setInstanceVariables: iv.

	sc setInstanceSpec: sc shape
	    instVars: sc allInstVarNames size.

	"Mutate all instances of the class to conform to new memory model
	 of the class."

	instances do: [ :each |
	    each mutate: instVarMap
		 startAt: startOfInstanceVars
		 newClass: sc
	]
    ].

    "Now update this class' instance vars "       
    oldClass := Behavior new.
    oldClass superclass: self.
    instances := self allInstances.
    instances do: [ :each | each changeClassTo: oldClass ].

    self setInstanceVariables: variableArray.

    self setInstanceSpec: shape
	instVars: variableArray size.

    instances do: [ :each |
	each
	    mutate: instVarMap
	    startAt: startOfInstanceVars
	    newClass: self
    ].
! !


!Behavior methodsFor: 'testing functionality'!

isBehavior
    ^true
! !

!Behavior methodsFor: 'pluggable behavior (not yet implemented)'!

debuggerClass
    "Answer which class is to be used to debug a chain of contexts which
     includes the receiver.  nil means 'do not debug'; other classes are
     sent #debuggingPriority and the one with the highest priority is
     picked."
    ^nil
!

decompilerClass
    "Answer the class that can be used to decompile methods,
     or nil if there is none (as is the case now)."
    ^nil
!

evaluatorClass
    "Answer the class that can be used to evaluate doits,
     or nil if there is none (as is the case now)."
    ^nil
!

parserClass
    "Answer the class that can be used to parse methods,
     or nil if there is none (as is the case now)."
    ^nil
!

compilerClass
    "Answer the class that can be used to compile parse trees,
     or nil if there is none (as is the case now).  Not
     used for methods if parserClass answers nil, and for
     doits if evaluatorClass answers nil."
    ^nil
! !

!Behavior methodsFor: 'printing hierarchy'!

printHierarchy
    "Print my entire subclass hierarchy on the terminal."
    self printSubclasses: 0 using: [ :name :level |
	stdout
	    next: level * self hierarchyIndent put: Character space;
	    nextPutAll: name;
	    nl
    ]
!

printSubclasses: level using: aBlock
    "I print my name, and then all my subclasses, each indented according
     to its position in the hierarchy. I pass aBlock a class name and a level"
    | mySubclasses |
    aBlock value: self name value: level.

    mySubclasses := self subclasses asSortedCollection: [ :a :b |
	(a isMetaclass | b isMetaclass) or: [ a name <= b name ]
    ].
    mySubclasses do: [ :subclass |
	subclass isMetaclass
	    ifFalse: [ subclass printSubclasses: level + 1
	    	    		using: aBlock ]
    ]
!

hierarchyIndent
    "Answer the indent to be used by #printHierarchy - 4 by default"
    ^4
! !
