"======================================================================
|
|   Smalltalk proxy class loader
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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

STParsingDriver subclass: #STInterpreter
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
!

STInterpreter class
       instanceVariableNames: 'evaluationMethods'
!

STInterpreter comment:
'This class does simple interpretation of the chunks that make up a
file-in.'!

STInterpreter subclass: #STClassLoader
       instanceVariableNames: 'loadedClasses proxies proxyNilClass currentClass
			       currentCategory currentNamespace defaultNamespace'
       classVariableNames: ''
       poolDictionaries: 'STClassLoaderObjects'
       category: 'System-Compiler'
!

STClassLoader comment:
'This class creates non-executable proxies for the classes it loads in.
It does not work if classes are created dynamically, but otherwise it
does it job well.'!

!STInterpreter class methodsFor: 'accessing'!

evaluationMethods
    ^evaluationMethods!

toEvaluate: interpretedSelector perform: selector
    evaluationMethods isNil
	ifTrue: [ evaluationMethods := IdentityDictionary new ].

    evaluationMethods at: interpretedSelector put: selector! !

!STInterpreter methodsFor: 'overrides'!

evaluationMethodFor: selector
    | method class |
    class := self class.
    [
        class evaluationMethods isNil ifFalse: [
            method := class evaluationMethods at: selector ifAbsent: [ nil ].
	    method isNil ifFalse: [ ^method ].
	].
	class == STInterpreter ifTrue: [ ^nil ].
	class := class superclass
    ] repeat
!

evaluateStatement: node
    | method |
    method := self evaluationMethodFor: node selector.
    (method isNil)
        ifTrue: [ ^self unknown: node ]
        ifFalse: [ ^self
	                perform: method
	                with: node receiver
	                with: node selector
	                with: node arguments ]
!

evaluate: node
    ^node statements 
	inject: false
	into: [ :old :each |
	    "We *do not* want short-circuit evaluation here!!"
	    | node |
	    node := each.
	    each isReturn
		ifTrue: [ node := each value ].

	    node isMessage
		ifTrue: [ old | (self evaluateStatement: node) ]
		ifFalse: [ self unknown: node ].
        ]
!

unknown: node
    ^false
! !

!STClassLoader class methodsFor: 'accessing'!

initialize
    self
	toEvaluate: #subclass:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:environment:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variable:subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableWordSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableByteSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:declaration:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variable:subclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableSubclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableWordSubclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableByteSubclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #methodsFor:
	perform: #doMethodsFor:selector:arguments:;

	toEvaluate: #addSubspace:
	perform: #doAddNamespace:selector:arguments:;

	toEvaluate: #current:
	perform: #doSetNamespace:selector:arguments:;

	toEvaluate: #import:
	perform: #doImport:selector:arguments:;

	toEvaluate: #category:
	perform: #doSend:selector:arguments:;

	toEvaluate: #comment:
	perform: #doSend:selector:arguments:;

	toEvaluate: #shape:
	perform: #doSend:selector:arguments:;

	toEvaluate: #addClassVarName:
	perform: #doSend:selector:arguments:;
	
	toEvaluate: #addClassVarName:value:
	perform: #doAddClassVarName:selector:arguments:;

	toEvaluate: #instanceVariableNames:
	perform: #doSend:selector:arguments:
! !

!STClassLoader class methodsFor: 'instance creation'!

new
    ^self basicNew initialize
! !

!STClassLoader methodsFor: 'accessing'!

currentNamespace
    ^currentNamespace!

currentNamespace: ns
    currentNamespace := self proxyForNamespace: ns!

proxyNilClass
    proxyNilClass isNil ifTrue: [ proxyNilClass := ProxyNilClass on: nil for: self ].
    ^proxyNilClass!
    
proxyForNamespace: anObject
    anObject isNamespace ifFalse: [ ^anObject ].
    ^proxies at: anObject ifAbsentPut: [
	ProxyNamespace on: anObject for: self ]!

proxyForClass: anObject
    anObject isClass ifFalse: [ ^anObject ].
    ^proxies at: anObject ifAbsentPut: [
	ProxyClass on: anObject for: self ]! !

!STClassLoader methodsFor: 'initializing'!

defaultNamespace
    ^defaultNamespace
!

initialNamespace
    ^Namespace current
!

initialize
    loadedClasses := OrderedSet new.
    proxies := IdentityDictionary new.
    defaultNamespace := self proxyForNamespace: self initialNamespace.
    currentNamespace := defaultNamespace.
! !

!STClassLoader methodsFor: 'overrides'!

loadedClasses
    ^loadedClasses
!

fullyDefinedLoadedClasses
    ^loadedClasses select: [ :each | each isFullyDefined ]
!

result
    "This is what #parseSmalltalk answers"
    ^self loadedClasses
!

endMethodList
    currentClass := nil
!

defineMethod: node 
    node category: currentCategory.
    ^currentClass methodDictionary
        at: (node selector asSymbol)
        put: (LoadedMethod node: node)
!

compile: node
    ^self defineMethod: node
! !

!STClassLoader methodsFor: 'evaluating statements'!

defineSubclass: receiver selector: selector arguments: argumentNodes
    | class arguments newClass |
    
    class := self resolveClass: receiver.
    arguments := argumentNodes collect: [ :each | each value ].
    newClass := class perform: selector withArguments: arguments asArray.
    loadedClasses add: newClass.
    proxies at: newClass put: newClass.
    ^newClass
!

doSubclass: receiver selector: selector arguments: argumentNodes
   
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].
    
    self defineSubclass: receiver selector: selector arguments: argumentNodes.
    ^false
!

doSend: receiver selector: selector arguments: argumentNodes
    | isClass class |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].

    isClass := receiver isMessage and: [ receiver selector = #class ].
    class := isClass
	ifTrue: [ (self resolveClass: receiver receiver) asMetaclass ]
	ifFalse: [ self resolveClass: receiver ].

    class perform: selector with: argumentNodes first value.
    ^false
!

doAddClassVarName: receiver selector: selector arguments: argumentNodes
    | class classVarName value |
    class := self resolveClass: receiver.
    classVarName := argumentNodes first value asString.
    value := argumentNodes last.
    class addClassVarName: classVarName value: value.
    ^false
!

doImport: receiver selector: selector arguments: argumentNodes
    | class namespace |
    receiver isMessage ifTrue: [ ^false ].
    class := self resolveClass: receiver.
    namespace := self resolveNamespace: argumentNodes first.
    class import: namespace.
    ^false
!

doSetNamespace: receiver selector: selector arguments: argumentNodes
    | ns |
    receiver isVariable ifFalse: [ ^false ].
    receiver name = 'Namespace' ifFalse: [ ^false ].

    ns := self resolveNamespace: argumentNodes first.
    self currentNamespace: ns.
    ^false
!

doAddNamespace: receiver selector: selector arguments: argumentNodes
    | root |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].

    root := self resolveNamespace: receiver.
    root addSubspace: argumentNodes first value.
    ^false
!

doMethodsFor: receiver selector: selector arguments: argumentNodes
    | class |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].

    currentClass := self resolveClass: receiver.
    currentCategory := argumentNodes first value.
    ^true
!

resolveClass: node
    | object |
    (node isMessage and: [ node selector = #class or: [ node selector = #classSide ]])
	ifTrue: [ ^(self resolveClass: node receiver) asMetaclass ].
    node isLiteral ifTrue: [
        "Dictionary cannot have nil as a key, use the entire RBLiteralNode."
        ^self proxyNilClass ].
        
    object := self
	resolveName: node
	isNamespace: [ :index :size | index < size ].
    ^self proxyForClass: object
!

resolveNamespace: node
    | object |
    object := self
	resolveName: node
	isNamespace: [ :index :size | true ].

    ^self proxyForNamespace: object
!

resolveName: node isNamespace: aBlock
    | current selectors |
    current := node.
    selectors := OrderedCollection new.
    [ current isMessage ] whileTrue: [
	selectors addFirst: current selector.
	current := current receiver
    ].
    selectors addAllFirst: (current name substrings: $.).

    current := self currentNamespace.
    selectors keysAndValuesDo: [ :index :each || name |
	name := each asSymbol.
	current := current
	       at: name
	       ifAbsentPut: [
	           (aBlock value: index value: selectors size)
		       ifTrue: [ current addSubspace: name ]
		       ifFalse: [ UndefinedClass name: name in: current for: self ]]].
    ^current! !

STClassLoader initialize!
