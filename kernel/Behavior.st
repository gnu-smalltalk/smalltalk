"======================================================================
|
|   Behavior Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,
| 2005,2006,2007,2008,2009 Free Software Foundation, Inc.
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



Object subclass: Behavior [
    | superClass methodDictionary instanceSpec subClasses instanceVariables |
    
    <category: 'Language-Implementation'>
    <comment: 'I am the parent class of all "class" type methods.  My instances know
about the subclass/superclass relationships between classes, contain
the description that instances are created from, and hold the method
dictionary that''s associated with each class.  I provide methods for
compiling methods, modifying the class inheritance hierarchy, examining the
method dictionary, and iterating over the class hierarchy.'>

    addInstVarName: aString [
	"Add the given instance variable to instance of the receiver"

	<category: 'instance variables'>
	| newInstanceVariables duplicated symbol |
	self validateIdentifier: aString.
	symbol := aString asSymbol.
	newInstanceVariables := instanceVariables isNil 
		    ifTrue: [{symbol}]
		    ifFalse: [instanceVariables copyWith: symbol].
	duplicated := self superclass allInstVarNames includes: symbol.
	self updateInstanceVars: newInstanceVariables shape: self shape.
	duplicated ifTrue: [self compileAll].
	self compileAllSubclasses
    ]

    removeInstVarName: aString [
	"Remove the given instance variable from the receiver and recompile
	 all of the receiver's subclasses"

	<category: 'instance variables'>
	| newInstanceVariables symbol index |
	symbol := aString asSymbol.
	index := instanceVariables findLast: [:each | each = symbol].
	index = 0 
	    ifTrue: [SystemExceptions.NotFound signalOn: symbol what: 'instance variable'].
	newInstanceVariables := instanceVariables 
		    copyReplaceFrom: index
		    to: index
		    with: #().
	self
	    updateInstanceVars: newInstanceVariables shape: self shape;
	    compileAll;
	    compileAllSubclasses
    ]

    instanceVariableNames: instVarNames [
        "Set the instance variables for the receiver to be those
         in instVarNames"

        <category: 'instance variables'>
        | variableArray oldInstVarNames oldSize removed changed added |
        variableArray := self parseInstanceVariableString: instVarNames.
        variableArray := self subclassInstVarNames, variableArray.
        oldInstVarNames := self allInstVarNames.

        "If instance variables change, update  instance variables and
         instance spec of the class and all its subclasses"
        variableArray = oldInstVarNames ifTrue: [^self].
        self updateInstanceVars: variableArray shape: self shape.

        "If this class or the subclasses' variables changed, need to recompile."
        oldSize := oldInstVarNames size.
        changed := variableArray size < oldSize or: [
            (variableArray first: oldSize) ~= (oldInstVarNames first: oldSize)].
        removed := oldInstVarNames anySatisfy: [:each |
            (variableArray includes: each) not].
        added := variableArray anySatisfy: [:each |
            (oldInstVarNames includes: each) not].

        changed | removed | added ifFalse: [^self].
        changed | removed ifTrue: [self compileAll].
        self compileAllSubclasses
    ]

    parseInstanceVariableString: variableString [
	"As with #parseVariableString:, but answer symbols that name
	 the variables instead of strings."
        <category: 'parsing class declarations'>
        | variableArray |
        variableArray := self parseVariableString: variableString.
        ^variableArray collect: [:each | each asSymbol]
    ]

    parseVariableString: aString [
	"Answer an array of instance variable names.  aString should
	 specify these in traditional file-in `instanceVariableNames'
	 format.  Signal an error if aString contains something other
	 than valid Smalltalk variables."
        <category: 'parsing class declarations'>
        | tokens |
        tokens := aString subStrings asArray.
        tokens do: [:token | self validateIdentifier: token].
        ^tokens
    ]

    createGetMethod: what default: value [
	"Create a method accessing the variable `what', with a default value
	 of `value', using lazy initialization"

	<category: 'method dictionary'>
	^self 
	    compile: '%1 [
	"Answer the receiver''s %1. Its default value is %2"
	%1 isNil ifTrue: [ %1 := %2 ].
	^%1
    ]' 
		    % {what. value}
    ]

    createGetMethod: what [
	"Create a method accessing the variable `what'."

	<category: 'method dictionary'>
	^self compile: '%1 [
	"Answer the receiver''s %1"
	^%1
    ]'
		% {what}
    ]

    createSetMethod: what [
	"Create a method which sets the variable `what'."

	<category: 'method dictionary'>
	| parameter |
	parameter := what = 'value' ifTrue: ['theValue'] ifFalse: ['value'].
	^self 
	    compile: '%1: %2 [
	"Set the receiver''s %1 to %2"
	%1 := %2
    ]'
		% {what. parameter}
    ]

    defineAsyncCFunc: cFuncNameString withSelectorArgs: selectorAndArgs args: argsArray [
	"Please lookup the part on the C interface in the manual.  This method
	 is deprecated, you should use the asyncCCall:args: attribute."

	<category: 'method dictionary'>
	| code |
	code := '%1 [
	<asyncCCall: ''%2'' args: #%3>
    ]' % 
			{selectorAndArgs.
			cFuncNameString.
			argsArray printString}.
	^self compile: code ifError: [:file :line :error | code error: error]
    ]

    defineCFunc: cFuncNameString withSelectorArgs: selectorAndArgs returning: returnTypeSymbol args: argsArray [
	"Please lookup the part on the C interface in the manual.  This method
	 is deprecated, you should use the cCall:returning:args: attribute."

	<category: 'method dictionary'>
	| code |
	code := '%1 [
	<cCall: ''%2'' returning: %3 args: #%4>
    ]' % 
			{selectorAndArgs.
			cFuncNameString.
			returnTypeSymbol storeString.
			argsArray printString}.
	^self compile: code ifError: [:file :line :error | code error: error]
    ]

    methodDictionary [
	"Answer the receiver's method dictionary. Don't modify the method
	 dictionary unless you exactly know what you're doing"

	<category: 'method dictionary'>
	^methodDictionary
    ]

    selectorsAndMethodsDo: aBlock [
	"Evaluate aBlock, passing for each evaluation a selector that's
	 defined in the receiver and the corresponding method."

	<category: 'method dictionary'>
	self methodDictionary isNil 
	    ifFalse: [self methodDictionary keysAndValuesDo: aBlock]
    ]

    methodDictionary: aDictionary [
	"Set the receiver's method dictionary to aDictionary"

	<category: 'method dictionary'>
	| newDictionary |
	aDictionary isNil ifFalse: [
	    newDictionary := aDictionary 
		    collect: [:each | each withNewMethodClass: self].
	    aDictionary become: newDictionary
	].
	Behavior flushCache.
	methodDictionary := aDictionary
    ]

    addSelector: selector withMethod: compiledMethod [
	"Add the given compiledMethod to the method dictionary, giving it
	 the passed selector. Answer compiledMethod"

	<category: 'method dictionary'>
	self methodDictionary isNil 
	    ifTrue: [methodDictionary := MethodDictionary new].
	^self methodDictionary at: selector
	    put: (compiledMethod withNewMethodClass: self selector: selector)
    ]

    removeSelector: selector [
	"Remove the given selector from the method dictionary, answer
	 the CompiledMethod attached to that selector"

	<category: 'method dictionary'>
	^self removeSelector: selector
	    ifAbsent: [SystemExceptions.NotFound signalOn: selector what: 'method']
    ]

    removeSelector: selector ifAbsent: aBlock [
	"Remove the given selector from the method dictionary, answer
	 the CompiledMethod attached to that selector. If the selector cannot
	 be found, answer the result of evaluating aBlock."

	<category: 'method dictionary'>
	self methodDictionary isNil ifTrue: [^aBlock value].
	(self methodDictionary includesKey: selector) ifFalse: [^aBlock value].
	^self methodDictionary removeKey: selector ifAbsent: [self error: 'huh?!?']
    ]

    formattedSourceStringAt: aSelector ifAbsent: aBlock [
	"Answer the method source code as a formatted string. Requires
	 package Parser."

	<category: 'accessing the method dictionary'>
	self notYetImplemented
    ]

    formattedSourceStringAt: selector [
	"Answer the method source code as a formatted string (if available)
	 for the given selector.  Requires package Parser."

	<category: 'accessing the method dictionary'>
	^self formattedSourceStringAt: selector ifAbsent: [
	    '" *** SOURCE CODE NOT AVAILABLE *** "']
    ]

    compile: code [
	"Compile method source.  If there are parsing errors, answer nil.
	 Else, return a CompiledMethod result of compilation"

	<category: 'method dictionary'>
	(code isKindOf: WriteStream) ifTrue: [^self primCompile: code readStream].
	(code isKindOf: Stream) ifTrue: [^self primCompile: code].
	^self primCompile: code asString
    ]

    compile: code ifError: block [
	"Compile method source.  If there are parsing errors, invoke
	 exception block, 'block' passing file name, line number and
	 error.  Return a CompiledMethod result of compilation"

	<category: 'method dictionary'>
	(code isKindOf: WriteStream) 
	    ifTrue: [^self primCompile: code readStream ifError: block].
	(code isKindOf: Stream) ifTrue: [^self primCompile: code ifError: block].
	^self primCompile: code asString ifError: block
    ]

    compile: code notifying: requestor [
	"Compile method source.  If there are parsing errors, send #error:
	 to the requestor object, else return a CompiledMethod result of
	 compilation"

	<category: 'method dictionary'>
	| method |
	method := self compile: code.
	method isNil ifTrue: [requestor error: 'Compilation failed'].
	^method
    ]

    compileAllSubclasses: aNotifier [
	"Recompile all selector of all subclasses. Notify aNotifier by sending
	#error: messages if something goes wrong."

	<category: 'method dictionary'>
	self allSubclassesDo: [:subclass | subclass compileAll: aNotifier]
    ]

    compileAllSubclasses [
	"Recompile all selector of all subclasses. Notify aNotifier by sending
	#error: messages if something goes wrong."

	<category: 'method dictionary'>
	self allSubclassesDo: [:subclass | subclass compileAll]
    ]

    recompile: selector [
	"Recompile the given selector, answer nil if something goes wrong or
	 the new CompiledMethod if everything's ok."

	<category: 'method dictionary'>
	(self >> selector) recompile.
    ]

    recompile: selector notifying: aNotifier [
	"Recompile the given selector.  If there are parsing errors, send #error:
	 to the aNotifier object, else return a CompiledMethod result of
	 compilation"

	<category: 'method dictionary'>
	(self >> selector) recompileNotifying: aNotifier.
    ]

    decompile: selector [
	"Decompile the bytecodes for the given selector."

	<category: 'method dictionary'>
	| method source |
	method := self >> selector.
	source := method methodSourceString.
	^source isNil & self decompilerClass notNil 
	    ifTrue: [self decompilerClass decompile: selector in: self]
	    ifFalse: [source]
    ]

    edit: selector [
	"Open Emacs to edit the method with the passed selector, then compile it"

	<category: 'method dictionary'>
	| method sourceFile sourcePos |
	method := self >> selector.
	sourceFile := method methodSourceFile.
	sourceFile isNil 
	    ifTrue: [^self error: 'decompiler can''t edit methods without source'].
	sourcePos := method methodSourcePos.
	Smalltalk system: 'emacs -l st -smalltalk ' , sourceFile , ' ' 
		    , sourcePos printString

	"Possible Windows code follows:"	"
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
	 
	 Smalltalk system: 'del st.tmp'"
    ]

    compileAll [
	"Recompile all selectors in the receiver. Ignore errors."

	<category: 'method dictionary'>
	self methodDictionary notNil 
	    ifTrue: 
		[self methodDictionary do: [:method | method recompile]]
    ]

    compileAll: aNotifier [
	"Recompile all selectors in the receiver. Notify aNotifier by sending
	#error: messages if something goes wrong."

	<category: 'method dictionary'>
	self methodDictionary notNil 
	    ifTrue: 
		[self methodDictionary do: [:method | method recompileNotifying: aNotifier]]
    ]

    evalString: aString to: anObject [
	"Answer the stack top at the end of the evaluation of the code in
	 aString. The code is executed as part of anObject"

	<category: 'evaluating'>
	| s result next method |
	s := ReadStream on: aString.
	
	[next := self extractEvalChunk: s.
	method := anObject class compile: 'Doit [ ^ [
' , next , ' ] value ]'
		    ifError: [:fname :line :error | nil].
	method isNil | (next allSatisfy: [:each | each = Character space]) 
	    ifFalse: [[result := anObject perform: method] valueWithUnwind].
	s atEnd] 
		whileFalse.
	anObject class removeSelector: #Doit ifAbsent: [].
	^result
    ]

    evalString: aString to: anObject ifError: aBlock [
	"Answer the stack top at the end of the evaluation of the code in
	 aString. If aString cannot be parsed, evaluate aBlock (see
	 compile:ifError:). The code is executed as part of anObject"

	<category: 'evaluating'>
	| s result next method |
	s := ReadStream on: aString.
	
	[next := self extractEvalChunk: s.
	method := anObject class compile: 'Doit [ ^ [
' , next , ' ] value ] '
		    ifError: 
			[:fname :lineNo :errorString | 
			aBlock 
			    value: fname
			    value: lineNo - 1
			    value: errorString.
			nil].
	method isNil | (next allSatisfy: [:each | each = Character space]) 
	    ifFalse: [[result := anObject perform: method] valueWithUnwind].
	s atEnd] 
		whileFalse.
	anObject class removeSelector: #Doit ifAbsent: [].
	^result
    ]

    evaluate: code [
	"Evaluate Smalltalk expression in 'code' and return result."

	<category: 'evaluating'>
	^self evaluate: code to: nil
    ]

    evaluate: code ifError: block [
	"Evaluate 'code'.  If a parsing error is detected, invoke 'block'"

	<category: 'evaluating'>
	^self 
	    evaluate: code
	    to: nil
	    ifError: block
    ]

    evaluate: code to: anObject ifError: block [
	"Evaluate Smalltalk expression as part of anObject's method definition.  This
	 method is used to support Inspector expression evaluation.  If a parsing error
	 is encountered, invoke error block, 'block'"

	<category: 'evaluating'>
	(code isKindOf: Stream) 
	    ifTrue: 
		[^self 
		    evalString: code contents
		    to: anObject
		    ifError: block].
	^self 
	    evalString: code
	    to: anObject
	    ifError: block
    ]

    evaluate: code to: anObject [
	"Evaluate Smalltalk expression as part of anObject's method definition"

	<category: 'evaluating'>
	(code isKindOf: Stream) 
	    ifTrue: [^self evalString: code contents to: anObject].
	^self evalString: code to: anObject
    ]

    evaluate: code notifying: requestor [
	"Evaluate Smalltalk expression in 'code'. If a parsing error is encountered,
	 send #error: to requestor"

	<category: 'evaluating'>
	| method aStream |
	^self evaluate: code
	    ifError: [:fname :lineNo :errorString | requestor error: 'line ' , lineNo printString , ': ' , errorString]
    ]

    superclass: aClass [
	"Set the receiver's superclass."

	<category: 'creating a class hierarchy'>
	superClass := aClass.
	instanceSpec isNil 
	    ifTrue: 
		[instanceSpec := aClass isNil ifTrue: [0] ifFalse: [aClass instanceSpec]]
    ]

    addSubclass: aClass [
	"Add aClass asone of the receiver's subclasses."

	<category: 'creating a class hierarchy'>
	subClasses isNil 
	    ifTrue: [subClasses := Array new]
	    ifFalse: 
		["remove old class if any"

		subClasses := subClasses copyWithout: aClass].
	subClasses := subClasses copyWith: aClass
    ]

    removeSubclass: aClass [
	"Remove aClass from the list of the receiver's subclasses"

	<category: 'creating a class hierarchy'>
	subClasses := subClasses copyWithout: aClass
    ]

    selectors [
	"Answer a Set of the receiver's selectors"

	<category: 'accessing the method dictionary'>
	self methodDictionary isNil 
	    ifTrue: [^Set new]
	    ifFalse: [^self methodDictionary keys]
    ]

    allSelectors [
	"Answer a Set of all the selectors understood by the receiver"

	<category: 'accessing the method dictionary'>
	| aSet |
	aSet := self selectors.
	self allSuperclassesDo: [:superclass | aSet addAll: superclass selectors].
	^aSet
    ]

    lookupSelector: aSelector [
	"Return the compiled method associated with selector, from the local
	 method dictionary or one of a superclass; return nil if not found."

	<category: 'accessing the method dictionary'>
	| class method |
	class := self.
	
	[method := class compiledMethodAt: aSelector ifAbsent: [nil].
	method isNil ifFalse: [^method].
	class := class superclass.
	class isNil ifTrue: [^nil]] 
		repeat
    ]

    lookupAllSelectors: aSelector [
	"Answer a Set of all the compiled method associated with selector.
	 from the local method dictionary and all of the superclasses."

	<category: 'accessing the method dictionary'>
	| implementors |

	implementors := Set new.
	self withAllSuperclassesDo: [:c | | m |
	    m := c compiledMethodAt: aSelector ifAbsent: [nil].
	    m ifNotNil: [implementors add: m]].
	^implementors
    ]

    compiledMethodAt: selector ifAbsent: aBlock [
	"Return the compiled method associated with selector, from the local
	 method dictionary.  Evaluate aBlock if not found."

	<category: 'accessing the method dictionary'>
	self methodDictionary isNil ifTrue: [^aBlock value].
	^self methodDictionary at: selector ifAbsent: aBlock
    ]

    compiledMethodAt: selector [
	"Return the compiled method associated with selector, from the local
	 method dictionary.  Error if not found."

	<category: 'accessing the method dictionary'>
	self methodDictionary isNil 
	    ifTrue: [SystemExceptions.NotFound signalOn: selector what: 'key'].
	^self methodDictionary at: selector
	    ifAbsent: [SystemExceptions.NotFound signalOn: selector what: 'key']
    ]

    >> selector [
	"Return the compiled method associated with selector, from the local
	 method dictionary.  Error if not found."

	<category: 'accessing the method dictionary'>
	self methodDictionary isNil 
	    ifTrue: [SystemExceptions.NotFound signalOn: selector what: 'key'].
	^self methodDictionary at: selector
	    ifAbsent: [SystemExceptions.NotFound signalOn: selector what: 'key']
    ]

    selectorAt: method [
	"Return selector for the given CompiledMethod"

	<category: 'accessing the method dictionary'>
	self methodDictionary isNil 
	    ifTrue: [SystemExceptions.NotFound signalOn: method what: 'method'].
	^self methodDictionary keyAtValue: method
	    ifAbsent: [SystemExceptions.NotFound signalOn: method what: 'method']
    ]

    parseTreeFor: selector [
	"Answer the parse tree for the given selector, or nil if there was an
	 error.  Requires the Parser package to be loaded."

	<category: 'accessing the method dictionary'>
	^(self >> selector) methodParseNode
    ]

    sourceCodeAt: selector ifAbsent: aBlock [
	"Answer source code (if available) for the given selector."

	<category: 'accessing the method dictionary'>
	| source |
	source := (self >> selector) methodSourceCode.
	source isNil ifTrue: [^aBlock value copy].
	^source asString
    ]

    sourceCodeAt: selector [
	"Answer source code (if available) for the given selector."

	<category: 'accessing the method dictionary'>
	^self sourceCodeAt: selector ifAbsent: [
	    '" *** SOURCE CODE NOT AVAILABLE *** "']
    ]

    sourceMethodAt: selector [
	"This is too dependent on the original implementation"

	<category: 'accessing the method dictionary'>
	self shouldNotImplement
    ]

    allInstances [
	"Returns a set of all instances of the receiver"

	<category: 'accessing instances and variables'>
	| result weakResult anInstance |
	result := WriteStream on: (Array new: 100).
	anInstance := self someInstance.
	[anInstance notNil] whileTrue: 
		[result nextPut: anInstance.
		anInstance := anInstance nextInstance].
	result := result contents.
	weakResult := WeakArray new: result size.
	1 to: result size do: [:i | weakResult at: i put: (result at: i)].
	^weakResult
    ]

    instanceCount [
	"Return a count of all the instances of the receiver"

	<category: 'accessing instances and variables'>
	| count anInstance |
	count := 0.
	anInstance := self someInstance.
	[anInstance notNil] whileTrue: 
		[count := count + 1.
		anInstance := anInstance nextInstance].
	^count
    ]

    indexOfInstVar: aString [
	"Answer the index of aString in the fixed instance variables of the
	 instances of the receiver, or 0 if the variable is missing."

	<category: 'accessing instances and variables'>
	^self allInstVarNames indexOfLast: aString asSymbol ifAbsent: [0]
    ]

    indexOfInstVar: aString ifAbsent: aBlock [
	"Answer the index of aString in the fixed instance variables of the
	 instances of the receiver, or 0 if the variable is missing."

	<category: 'accessing instances and variables'>
	^self allInstVarNames indexOfLast: aString asSymbol ifAbsent: aBlock
    ]

    instVarNames [
	"Answer an Array containing the instance variables defined by the receiver"

	<category: 'accessing instances and variables'>
	| superVars |
	instanceVariables isNil ifTrue: [^#()].
	superClass isNil 
	    ifTrue: [^instanceVariables copy]
	    ifFalse: 
		[superVars := superClass allInstVarNames.
		^instanceVariables copyFrom: superVars size + 1 to: instanceVariables size]
    ]

    subclassInstVarNames [
	"Answer the names of the instance variables the receiver inherited from its
	 superclass"

	<category: 'accessing instances and variables'>
	| superVars |
	instanceVariables isNil ifTrue: [^#()].
	superClass isNil ifTrue: [^#()].
	^superClass allInstVarNames
    ]

    allInstVarNames [
	"Answer the names of every instance variables the receiver contained in the
	 receiver's instances"

	<category: 'accessing instances and variables'>
	^instanceVariables isNil ifTrue: [#()] ifFalse: [instanceVariables]
    ]

    classVarNames [
	"Answer all the class variables for instances of the receiver"

	<category: 'accessing instances and variables'>
	^self superclass isNil 
	    ifTrue: [#()]
	    ifFalse: [self superclass classVarNames]
    ]

    allClassVarNames [
	"Return all the class variables understood by the receiver"

	<category: 'accessing instances and variables'>
	| result |
	result := WriteStream with: self classVarNames asArray.
	self allSuperclassesDo: [:each | result nextPutAll: each classVarNames].
	^result contents
    ]

    classPool [
	"Answer the class pool dictionary. Since Behavior does not support
	 classes with class variables, we answer an empty one; adding
	 variables to it results in an error."

	<category: 'accessing instances and variables'>
	^(Dictionary new)
	    makeReadOnly: true;
	    yourself
    ]

    sharedPools [
	"Return the names of the shared pools defined by the class"

	<category: 'accessing instances and variables'>
	^self superclass isNil ifTrue: [#()] ifFalse: [self superclass sharedPools]
    ]

    allSharedPoolDictionariesDo: aBlock [
        "Answer the shared pools visible from methods in the metaclass,
         in the correct search order."

        self superclass allSharedPoolDictionariesDo: aBlock
    ]

    allSharedPoolDictionaries [
	"Return the shared pools defined by the class and any of
	 its superclasses, in the correct search order."

	<category: 'accessing instances and variables'>
	| result |
	result := OrderedCollection new.
	self allSharedPoolDictionariesDo: [:each | result add: each].
	^result
    ]

    allSharedPools [
	"Return the names of the shared pools defined by the class and any of
	 its superclasses, in the correct search order."

	<category: 'accessing instances and variables'>
	| result |
	result := OrderedCollection new.
	self allSharedPoolDictionariesDo: [:each |
		result add: (each nameIn: self environment)].
	^result
    ]

    subclasses [
	"Answer the direct subclasses of the receiver in a Set"

	<category: 'accessing class hierarchy'>
	subClasses isNil ifTrue: [^Set new] ifFalse: [^subClasses asSet]
    ]

    allSubclasses [
	"Answer the direct and indirect subclasses of the receiver in a Set"

	<category: 'accessing class hierarchy'>
	| aSet |
	aSet := Set new.
	self allSubclassesDo: [:subclass | aSet add: subclass].
	^aSet
    ]

    withAllSubclasses [
	"Answer a Set containing the receiver together with its direct and
	 indirect subclasses"

	<category: 'accessing class hierarchy'>
	| aSet |
	aSet := Set with: self.
	aSet addAll: self allSubclasses.
	^aSet
    ]

    superclass [
	"Answer the receiver's superclass (if any, otherwise answer nil)"

	<category: 'accessing class hierarchy'>
	^superClass
    ]

    withAllSuperclasses [
	"Answer the receiver and all of its superclasses in a collection"

	<category: 'accessing class hierarchy'>
	| supers |
	supers := OrderedCollection with: self.
	self allSuperclassesDo: [:superclass | supers addLast: superclass].
	^supers
    ]

    allSuperclasses [
	"Answer all the receiver's superclasses in a collection"

	<category: 'accessing class hierarchy'>
	| supers |
	supers := OrderedCollection new.
	self allSuperclassesDo: [:superclass | supers addLast: superclass].
	^supers
    ]

    whichSelectorsReferToByteCode: aByteCode [
	"Return the collection of selectors in the class which
	 reference the byte code, aByteCode"

	<category: 'testing the method dictionary'>
	| s method specialSelector |
	s := Set new.
	self methodDictionary isNil ifTrue: [^s].
	self methodDictionary keysAndValuesDo: 
		[:sel :method | 
		((1 to: method numBytecodes) 
		    detect: [:i | aByteCode = (method bytecodeAt: i)]
		    ifNone: [0]) > 0 
		    ifTrue: [s add: sel]].
	^s
    ]

    hasMethods [
	"Return whether the receiver has any methods defined"

	<category: 'testing the method dictionary'>
	^self methodDictionary notNil and: [self methodDictionary notEmpty]
    ]

    includesSelector: selector [
	"Returns true if the local method dictionary contains the given selector"

	<category: 'testing the method dictionary'>
	self methodDictionary isNil ifTrue: [^false].
	^self methodDictionary includesKey: selector
    ]

    canUnderstand: selector [
	"Returns true if the instances of the receiver understand
	 the given selector"

	<category: 'testing the method dictionary'>
	^(self lookupSelector: selector) notNil
    ]

    whichClassIncludesSelector: selector [
	"Answer which class in the receiver's hierarchy contains the implementation
	 of selector used by instances of the class (nil if none does)"

	<category: 'testing the method dictionary'>
	self withAllSuperclassesDo: 
		[:superclass | 
		(superclass includesSelector: selector) ifTrue: [^superclass]].
	^nil
    ]

    whichSelectorsRead: instVarName [
	"Answer a Set of selectors which read the given instance variable"

	<category: 'testing the method dictionary'>
	| md index |
	index := self allInstVarNames indexOf: instVarName asSymbol
		    ifAbsent: [^Set new].	"### should it raise an error?"
	md := self methodDictionary.
	md isNil ifTrue: [^Set new].
	^(md select: [:each | each reads: index - 1]) keys
    ]

    whichSelectorsAssign: instVarName [
	"Answer a Set of selectors which read the given instance variable"

	<category: 'testing the method dictionary'>
	| md index |
	index := self allInstVarNames indexOf: instVarName asSymbol
		    ifAbsent: [^Set new].	"### should it raise an error?"
	md := self methodDictionary.
	md isNil ifTrue: [^Set new].
	^(md select: [:each | each assigns: index - 1]) keys
    ]

    whichSelectorsAccess: instVarName [
	"Answer a Set of selectors which access the given instance variable"

	<category: 'testing the method dictionary'>
	| md index |
	index := self allInstVarNames indexOf: instVarName asSymbol
		    ifAbsent: [^Set new].	"### should it raise an error?"
	md := self methodDictionary.
	md isNil ifTrue: [^Set new].
	^(md select: [:each | each accesses: index - 1]) keys
    ]

    whichSelectorsReferTo: anObject [
	"Returns a Set of selectors that refer to anObject"

	<category: 'testing the method dictionary'>
	| md |
	md := self methodDictionary.
	md isNil ifTrue: [^Set new].
	^(md select: [:each | each refersTo: anObject]) keys
    ]

    scopeHas: name ifTrue: aBlock [
	"If methods understood by the receiver's instances have access to a
	 symbol named 'name', evaluate aBlock"

	<category: 'testing the method dictionary'>
	| nameSym |
	nameSym := name asSymbol.
	(self allInstVarNames includes: nameSym) ifTrue: [^aBlock value].
	(self allClassVarNames includes: nameSym) ifTrue: [^aBlock value].
	(self environment includesKey: nameSym) ifTrue: [^aBlock value].
	self allSharedPools do: 
		[:dictName | 
		((self environment at: dictName asGlobalKey) includesKey: nameSym) 
		    ifTrue: [^aBlock value]]
    ]

    isBits [
	"Answer whether my instances' variables are immediate, non-OOP
	 values."
	<category: 'testing the form of the instances'>
	^self shape notNil and: [self isPointers not]
    ]

    isPointers [
	"Answer whether the instance variables of the receiver's instances
	 are objects"

	<category: 'testing the form of the instances'>
	^(self instanceSpec bitAnd: 31) = 31
    ]

    isIdentity [
	"Answer whether x = y implies x == y for instances of the receiver"

	<category: 'testing the form of the instances'>
	^false
    ]

    isImmediate [
	"Answer whether, if x is an instance of the receiver, x copy == x"

	<category: 'testing the form of the instances'>
	^false
    ]

    isFixed [
	"Answer whether the receiver's instances have no indexed
	 instance variables"

	<category: 'testing the form of the instances'>
	^self isVariable not
    ]

    isVariable [
	"Answer whether the receiver's instances have indexed instance variables"

	<category: 'testing the form of the instances'>
	^(self instanceSpec bitAt: 5) ~= 0
    ]

    instSize [
	"Answer how many fixed instance variables are reserved to each of the
	 receiver's instances"

	<category: 'testing the form of the instances'>
	^self instanceSpec bitShift: -12
    ]

    includesBehavior: aClass [
	"Returns true if aClass is the receiver or a superclass of the receiver."

	<category: 'testing the class hierarchy'>
	^self == aClass or: [self inheritsFrom: aClass]
    ]

    inheritsFrom: aClass [
	"Returns true if aClass is a superclass of the receiver"

	<category: 'testing the class hierarchy'>
	| sc |
	aClass isNil ifTrue: [^true].

	sc := self.
	[sc := sc superclass.
	sc isNil] whileFalse: [sc == aClass ifTrue: [^true]].
	^false
    ]

    kindOfSubclass [
	"Return a string indicating the type of class the receiver is"

	<category: 'testing the class hierarchy'>
	self isVariable ifFalse: [^'subclass:'].
	self isPointers ifTrue: [^'variableSubclass:'].
	^'variable: ' , self shape storeString , 'subclass:'
    ]

    shapes [
	"Used by #shape to map a bitfield to symbolic shapes."
	<category: 'private-testing the class hierarchy'>
	^#(#int8 #byte #character #short #ushort #int #uint #float #int64 #uint64 #double #utf32 nil nil nil #pointer)
    ]

    shape: shape [
	"Give the provided shape to the receiver's instances.
	 The shape can be nil, or one of #byte #int8 #character #short #word
	 #ushort #int #uint #int64 #uint64 #utf32 #float #double or #pointer.
	 In addition, the special value #inherit means to use the shape of the
	 superclass; note however that this is a static setting, and subclasses
	 that used #inherit are not mutated when the superclass adopts a different
	 shape."

	<category: 'testing the class hierarchy'>
	| realShape |
	realShape := shape.
	shape = #word 
	    ifTrue: 
		[realShape := CSymbols.CLongSize = 4 ifTrue: [#uint] ifFalse: [#uint64]].
	shape = #inherit
	    ifTrue:
		[realShape := self superclass isNil ifTrue: [nil] ifFalse: [self superclass shape]].
	self shape == realShape ifTrue: [^false].
	realShape isNil ifTrue: [
            self updateInstanceVars: self allInstVarNames shape: nil ].
	self isVariable 
	    ifTrue: 
		[SystemExceptions.MutationError 
		    signal: 'Cannot change shape of variable class'].

	"Changing from fixed to variable.  No need to mutate the instances."
	self setInstanceSpec: realShape instVars: self allInstVarNames size
    ]

    shape [
	"Answer the symbolic shape of my instances."
	<category: 'testing the class hierarchy'>
	self isVariable ifFalse: [^nil].
	^self shapes at: (instanceSpec bitAnd: 15) + 1
    ]

    allSubclassesDo: aBlock [
	"Invokes aBlock for all subclasses, both direct and indirect."

	<category: 'enumerating'>
	subClasses isNil ifTrue: [^self].
	subClasses do: 
		[:class | 
		aBlock value: class.
		class allSubclassesDo: aBlock]
    ]

    allSuperclassesDo: aBlock [
	"Invokes aBlock for all superclasses, both direct and indirect."

	<category: 'enumerating'>
	| class superclass |
	class := self.
	
	[superclass := class superclass.
	class := superclass.
	superclass notNil] 
		whileTrue: [aBlock value: superclass]
    ]

    withAllSubclassesDo: aBlock [
	"Invokes aBlock for the receiver and all subclasses, both direct
	 and indirect."

	<category: 'enumerating'>
	aBlock value: self.
	self allSubclassesDo: aBlock
    ]

    withAllSuperclassesDo: aBlock [
	"Invokes aBlock for the receiver and all superclasses, both direct
	 and indirect."

	<category: 'enumerating'>
	| class |
	class := self.
	
	[aBlock value: class.
	class := class superclass.
	class notNil] whileTrue
    ]

    allInstancesDo: aBlock [
	"Invokes aBlock for all instances of the receiver"

	<category: 'enumerating'>
	| anInstance |
	anInstance := self someInstance.
	[anInstance notNil] whileTrue: 
		[aBlock value: anInstance.
		anInstance := anInstance nextInstance]
    ]

    allSubinstancesDo: aBlock [
	"Invokes aBlock for all instances of each of the receiver's subclasses."

	<category: 'enumerating'>
	| oopIndex object classes last ok |
	classes := IdentitySet withAll: self allSubclasses.

	"Break-even point found by trial and error"
	classes size < 17 
	    ifTrue: 
		[classes do: [:each | each allInstancesDo: aBlock].
		^self].

	"Use a more complicated walk when there are many subclasses."
	classes := (IdentitySet new: classes size * 3)
		    addAll: classes;
		    yourself.

	"Get the first OOP.  Implementation dependent!"
	oopIndex := 0 asCharacter asOop.
	
	[object := oopIndex asObject.

	"Simple-minded caching"
	object class == last 
	    ifFalse: [ok := classes includes: (last := object class)].
	ok ifTrue: [aBlock value: object].
	(oopIndex := oopIndex nextValidOop) isNil] 
		whileFalse
    ]

    selectSubclasses: aBlock [
	"Return a Set of subclasses of the receiver satisfying aBlock."

	<category: 'enumerating'>
	| aSet |
	aSet := Set new.
	self 
	    allSubclassesDo: [:subclass | (aBlock value: subclass) ifTrue: [aSet add: subclass]].
	^aSet
    ]

    selectSuperclasses: aBlock [
	"Return a Set of superclasses of the receiver satisfying aBlock."

	<category: 'enumerating'>
	| aSet |
	aSet := Set new.
	self 
	    allSuperclassesDo: [:superclass | (aBlock value: superclass) ifTrue: [aSet add: superclass]].
	^aSet
    ]

    subclassesDo: aBlock [
	"Invokes aBlock for all direct subclasses."

	<category: 'enumerating'>
	subClasses isNil ifTrue: [^self].
	subClasses do: aBlock
    ]

    methods [
	"Don't use this, it's only present to file in from Smalltalk/V"

	<category: 'compilation (alternative)'>
	^self methodsFor: 'no category'
    ]

    methodsFor [
	"Don't use this, it's only present to file in from Dolphin Smalltalk"

	<category: 'compilation (alternative)'>
	^self methodsFor: 'no category'
    ]

    methodsFor: category ifFeatures: features [
	"Start compiling methods in the receiver if this implementation of
	 Smalltalk has the given features, else skip the section"

	<category: 'compilation (alternative)'>
	^self methodsFor: category ifTrue: (Smalltalk hasFeatures: features)
    ]

    methodsFor: category stamp: notUsed [
	"Don't use this, it's only present to file in from Squeak"

	<category: 'compilation (alternative)'>
	^self methodsFor: category
    ]

    privateMethods [
	"Don't use this, it's only present to file in from IBM Smalltalk"

	<category: 'compilation (alternative)'>
	^self methodsFor: 'private'
    ]

    publicMethods [
	"Don't use this, it's only present to file in from IBM Smalltalk"

	<category: 'compilation (alternative)'>
	^self methodsFor: 'public'
    ]

    article [
	"Answer an article (`a' or `an') which is ok for the receiver's name"

	<category: 'support for lightweight classes'>
	^self superclass article
    ]

    asClass [
	"Answer the first superclass that is a full-fledged Class object"

	<category: 'support for lightweight classes'>
	^self superclass asClass
    ]

    environment [
	"Answer the namespace that this class belongs to - the same as the
	 superclass, since Behavior does not support namespaces yet."

	<category: 'support for lightweight classes'>
	^self superclass environment
    ]

    nameIn: aNamespace [
	"Answer the class name when the class is referenced from aNamespace
	 - a dummy one, since Behavior does not support names."

	<category: 'support for lightweight classes'>
	^'<no name>'
    ]

    securityPolicy [
	<category: 'support for lightweight classes'>
	^self asClass securityPolicy
    ]

    securityPolicy: aSecurityPolicy [
	<category: 'support for lightweight classes'>
	self shouldNotImplement
    ]

    printOn: aStream in: aNamespace [
	"Answer the class name when the class is referenced from aNamespace
	 - a dummy one, since Behavior does not support names."

	<category: 'support for lightweight classes'>
	aStream nextPutAll: (self nameIn: aNamespace)
    ]

    name [
	"Answer the class name; this prints to the name of the superclass
	 enclosed in braces.  This class name is used, for example, to print
	 the receiver."

	<category: 'support for lightweight classes'>
	^'{%1}' % {self asClass}
    ]

    newInFixedSpace: numInstanceVariables [
	"Create a new instance of a class with indexed instance variables. The
	 instance has numInstanceVariables indexed instance variables.  The
	 instance is guaranteed not to move across garbage collections.  If
	 a subclass overrides #new:, the changes will apply to this method too."

	<category: 'instance creation'>
	^(self new: numInstanceVariables) makeFixed
    ]

    newInFixedSpace [
	"Create a new instance of a class without indexed instance variables.
	 The instance is guaranteed not to move across garbage collections.
	 If a subclass overrides #new, the changes will apply to this method too."

	<category: 'instance creation'>
	^self new makeFixed
    ]

    extractEvalChunk: aStream [
	"Private - Extract the code in the next evaluation chunk (i.e. the code
	 until the next bang which is outside string literals or comments)"

	<category: 'private'>
	| code ch |
	code := WriteStream on: (String new: 100).
	[aStream atEnd] whileFalse: 
		[ch := aStream next.
		ch = $! ifTrue: [^code contents].
		code nextPut: ch.
		ch = $" 
		    ifTrue: 
			[code
			    nextPutAll: (aStream upTo: ch);
			    nextPut: ch].
		ch = $' 
		    ifTrue: 
			[
			[code
			    nextPutAll: (aStream upTo: ch);
			    nextPut: $'.
			aStream atEnd not and: [aStream peekFor: ch]] 
				whileTrue: [code nextPut: ch]]].
	^code contents
    ]

    instanceSpec [
	<category: 'private'>
	^instanceSpec
    ]

    setInstanceSpec: shape instVars: anIntegerSize [
	<category: 'private'>
	| realShape |
	instanceSpec := anIntegerSize bitShift: 12.
	shape isNil 
	    ifFalse: 
		[realShape := shape = #inherit
		    ifTrue: [self superclass isNil ifTrue: [nil] ifFalse: [self superclass shape]]
		    ifFalse: [shape].
		instanceSpec := instanceSpec bitOr: 15 
				    + (self shapes indexOf: realShape ifAbsent: [self error: 'invalid shape value'])]
    ]

    sharedPoolDictionaries [
	"Return the shared pools (not the names!) defined by the class"

	<category: 'private'>
	^self superclass sharedPoolDictionaries
    ]

    setInstanceVariables: instVariableArray [
	<category: 'private'>
	instanceVariables := instVariableArray
    ]

    validateIdentifier: token [
	"Token is a string or string-oid"

	<category: 'private'>
	| firstTime |
	firstTime := true.
	token do: 
		[:ch | 
		ch isLetter | (firstTime not and: [ch = $_ | ch isDigit]) 
		    ifFalse: 
			[SystemExceptions.InvalidValue signalOn: token
			    reason: 'invalid Smalltalk identifier'].
		firstTime := false].
	^true
    ]

    updateInstanceVars: variableArray shape: shape [
	"Update instance variables and instance spec of the class and all
	 its subclasses.  variableArray lists the new variables, including
	 inherited ones."
	^self
	    updateInstanceVars: variableArray
	    superclass: self superclass
	    shape: shape
    ]

    updateInstanceVars: variableArray superclass: newSuper shape: shape [
	"Update instance variables and instance spec of the class and all
	 its subclasses.  variableArray lists the new variables, including
	 those inherited from newSuper."

	<category: 'private'>
	| instVarMap newInstVars oldInstVars oldClass instances oldSuper |

	"Find a common superclass."
	oldSuper := self superclass.
	newSuper == oldSuper ifFalse: [
	    [ newSuper includesBehavior: oldSuper ] whileFalse: [
	        oldSuper := oldSuper superclass ] ].

	"Make map for inherited instance variables."
	oldInstVars := self allInstVarNames.
	instVarMap := Array new: oldInstVars size.
	1 to: oldSuper instSize do: [ :i |
	    instVarMap at: i put: i ].

	"Make map for this class's instance variables."
	newInstVars := variableArray copyFrom: newSuper instSize + 1.
	oldInstVars
	    from: oldSuper instSize + 1 to: oldInstVars size
	    keysAndValuesDo: [ :index :var |
	        | map |
	        map := newInstVars findLast: [:each | each = var].
	        map > 0 ifTrue: [instVarMap at: index put: map + newSuper instSize]].

	"Fix up all subclasses."
	self allSubclassesDo: 
		[:sc | 
		| iv |
		oldClass := Behavior new.
		oldClass superclass: sc.
		instances := sc allInstances.
		instances do: [:each | each changeClassTo: oldClass].
		iv := variableArray, (sc allInstVarNames 
			    copyFrom: oldInstVars size + 1
			    to: sc allInstVarNames size).
		sc setInstanceVariables: iv.
		sc setInstanceSpec: sc shape instVars: sc allInstVarNames size.

		"Mutate all instances of the class to conform to new memory model
		 of the class."
		instances do: [:each | 
		    sc mutate: each via: instVarMap]].

	"Now update this class' instance vars"
	oldClass := Behavior new.
	oldClass superclass: self.
	instances := self allInstances.
	instances do: [:each | each changeClassTo: oldClass].
	self setInstanceVariables: variableArray.
	self setInstanceSpec: shape instVars: variableArray size.
	instances do: [:each | 
	    self mutate: each via: instVarMap]
    ]

    mutate: object via: instVarMap [
        "Private - Mutate object to a new class representation. instVarMap
         maps from old instVarAt: indices to new instVarAt:put: indices.
         start is the first instance variable to change."

        <category: 'private'>
        | aCopy mappedValue end adjustment |
        aCopy := object class isVariable
                    ifTrue: [self basicNew: object basicSize]
                    ifFalse: [self basicNew].

        "Copy old instance variables to their new positions using instVarMap."
        1 to: instVarMap size do: [:i |
            mappedValue := instVarMap at: i.
            mappedValue notNil
                ifTrue: [aCopy instVarAt: mappedValue put: (object instVarAt: i)]].

        "If mutating a subclass, instVarMap is smaller than `object class instSize';
         in this case, everything after it must be copied."
        adjustment := self instSize - object class instSize.
        instVarMap size + 1 to: object class instSize
            do: [:i | aCopy instVarAt: i + adjustment put: (object instVarAt: i)].

        "Copy the indexed variables, if any."
        1 to: object basicSize do: [:i | aCopy basicAt: i put: (object basicAt: i)].
        ^object become: aCopy
    ]

    isBehavior [
	<category: 'testing functionality'>
	^true
    ]

    debuggerClass [
	"Answer which class is to be used to debug a chain of contexts which
	 includes the receiver.  nil means 'do not debug'; other classes are
	 sent #debuggingPriority and the one with the highest priority is
	 picked."

	<category: 'pluggable behavior (not yet implemented)'>
	^nil
    ]

    decompilerClass [
	"Answer the class that can be used to decompile methods,
	 or nil if there is none (as is the case now)."

	<category: 'pluggable behavior (not yet implemented)'>
	^nil
    ]

    evaluatorClass [
	"Answer the class that can be used to evaluate doits,
	 or nil if there is none (as is the case now)."

	<category: 'pluggable behavior (not yet implemented)'>
	^nil
    ]

    parserClass [
	"Answer the class that can be used to parse methods,
	 or nil if there is none (as is the case now)."

	<category: 'pluggable behavior (not yet implemented)'>
	^nil
    ]

    compilerClass [
	"Answer the class that can be used to compile parse trees,
	 or nil if there is none (as is the case now).  Not
	 used for methods if parserClass answers nil, and for
	 doits if evaluatorClass answers nil."

	<category: 'pluggable behavior (not yet implemented)'>
	^nil
    ]

    printHierarchy [
	"Print my entire subclass hierarchy on the terminal."

	<category: 'printing hierarchy'>
	self printSubclasses: 0
    ]

    printFullHierarchy [
	"Print my full hierarchy (i.e. all my superclasses and subclasses)
	 on the terminal."

	<category: 'printing hierarchy'>
	self printSuperclasses: 0; printSubclasses: self allSuperclasses size
    ]

    printSuperclasses: level [
	"I print all my superclasses, each indented according to its position in
	the hierarchy. I pass aBlock a class name and a level."

	<category: 'private'>
	| mySuperclass currentLevel |
	currentLevel := level.
	self allSuperclasses reverseDo:
	    [:superclass |
	    Transcript
		space: currentLevel * self hierarchyIndent;
		nextPutAll: (superclass nameIn: Namespace current);
		nl.
	    currentLevel := currentLevel + 1]
    ]

    printSubclasses: level [
	"I print my name, and then all my subclasses, each indented according
	 to its position in the hierarchy. I pass aBlock a class name and a level"

	<category: 'private'>
	| mySubclasses |
	Transcript
	    space: level * self hierarchyIndent;
	    nextPutAll: (self nameIn: Namespace current);
	    nl.
	mySubclasses := self subclasses reject: [ :a | a isMetaclass ].
	(mySubclasses asSortedCollection: [:a :b | a name <= b name]) do: 
		[:subclass | subclass printSubclasses: level + 1]
    ]

    hierarchyIndent [
	"Answer the indent to be used by #printHierarchy - 4 by default"

	<category: 'printing hierarchy'>
	^4
    ]

    flushCache [
	"Invalidate the method cache kept by the virtual machine. This
	 message should not need to be called by user programs."

	<category: 'built ins'>
	<primitive: VMpr_Behavior_flushCache>
	^self primitiveFailed
    ]

    basicNewInFixedSpace: numInstanceVariables [
	"Create a new instance of a class with indexed instance variables. The
	 instance has numInstanceVariables indexed instance variables.  The
	 instance is guaranteed not to move across garbage collections.  Like
	 #basicNew:, this method should not be overridden."

	<category: 'built ins'>
	<primitive: VMpr_Behavior_basicNewFixedColon>
	self isFixed 
	    ifTrue: 
		[SystemExceptions.WrongMessageSent signalOn: #basicNewInFixedSpace:
		    useInstead: #basicNewInFixedSpace].
	numInstanceVariables isSmallInteger ifTrue: [^self primitiveFailed].
	^SystemExceptions.WrongClass signalOn: numInstanceVariables
	    mustBe: SmallInteger
    ]

    basicNewInFixedSpace [
	"Create a new instance of a class with no indexed instance variables.
	 The instance is guaranteed not to move across garbage collections.
	 Like #basicNew, this method should not be overridden."

	<category: 'built ins'>
	<primitive: VMpr_Behavior_basicNewFixed>
	self isFixed ifTrue: [^self primitiveFailed].
	SystemExceptions.WrongMessageSent signalOn: #basicNewInFixedSpace
	    useInstead: #basicNewInFixedSpace:
    ]

    someInstance [
	"Private - Answer the first instance of the receiver in the object
	 table"

	<category: 'built ins'>
	<primitive: VMpr_Behavior_someInstance>
	^nil	"return nil on failure"
    ]

    methodsFor: category ifTrue: condition [
	"Compile the following code inside the receiver, with the given
	 category, if condition is true; else ignore it"

	<category: 'built ins'>
	<primitive: VMpr_Behavior_methodsForIfTrue>
	^self primitiveFailed
    ]

    primCompile: code [
	"Compile the code, a string or readable stream, with no
	 category. Fail if the code does not obey Smalltalk syntax. Answer
	 the generated CompiledMethod if it does.
	 
	 Do not send this in user code; use #compile: or related methods
	 instead."

	<category: 'built ins'>
	<primitive: VMpr_Behavior_primCompile>
	^self primitiveFailed
    ]

    primCompile: code ifError: aBlock [
	"As with #primCompile:, but evaluate aBlock (passing the file
	 name, line number and description of the error) if the code does
	 not obey Smalltalk syntax.
	 
	 Do not send this in user code; use #compile:ifError: or related
	 methods instead."

	<category: 'built ins'>
	<primitive: VMpr_Behavior_primCompileIfError>
	^self primitiveFailed
    ]

    scopeDictionary [
        "Answer the dictionary that is used when the receiver is before
         a period in Smalltalk source code."
        <category: 'compilation'>
        ^self classPool
    ]
]

