"======================================================================
|
|   Smalltalk proxy class loader
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002 Free Software Foundation, Inc.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

RBParser subclass: #STInterpreter
       instanceVariableNames: 'currentClass
			       '
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
       instanceVariableNames: 'loadedClasses proxies currentCategory currentNamespace'
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

evaluateStatement: node
    | receiver selector argumentNodes |
    node arguments size = 0 ifTrue: [ ^self ].

    receiver := node receiver.
    selector := node selector.
    argumentNodes := node arguments.

    self class evaluationMethods at: selector ifPresent: [ :method |
	self
	    perform: method
	    with: receiver
	    with: selector
	    with: argumentNodes ].
!

evaluate: node
    node statements do: [ :each |
        each isMessage ifTrue: [ self evaluateStatement: each ]
    ].
    ^currentClass notNil
! !

!STClassLoader class methodsFor: 'accessing'!

initialize
    self
	toEvaluate: #subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableWordSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableByteSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #methodsFor:
	perform: #doMethodsFor:selector:arguments:;

	toEvaluate: #addSubspace:
	perform: #doAddNamespace:selector:arguments:;

	toEvaluate: #current:
	perform: #doSetNamespace:selector:arguments:;

	toEvaluate: #comment:
	perform: #doComment:selector:arguments:;

	toEvaluate: #instanceVariableNames:
	perform: #doClassInstVars:selector:arguments:
! !

!STClassLoader class methodsFor: 'instance creation'!

new
    ^self basicNew initialize
! !

!STClassLoader methodsFor: 'accessing'!

currentNamespace
    ^currentNamespace!

currentNamespace: ns
    currentNamespace := ns!

proxyForNamespace: anObject
    ^proxies at: anObject ifAbsentPut: [
	ProxyNamespace on: anObject for: self ]!

proxyForClass: anObject
    ^proxies at: anObject ifAbsentPut: [
	ProxyClass on: anObject for: self ]! !

!STClassLoader methodsFor: 'initializing'!

initialize
    loadedClasses := OrderedCollection new.
    proxies := IdentityDictionary new.
    currentNamespace := self proxyForNamespace: Namespace current.
! !

!STClassLoader methodsFor: 'overrides'!

result
    "This is what #parseSmalltalk answers"
    ^loadedClasses
!

endMethodList
    currentClass := nil
!

compile: node
    currentClass methodDictionary
	at: node selector asSymbol
	put: (LoadedMethod
	    category: currentCategory
	    source: node source)
! !

!STClassLoader methodsFor: 'evaluating statements'!

doSubclass: receiver selector: selector arguments: argumentNodes
    | class arguments newClass |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^self ].

    class := self resolveClass: receiver.
    arguments := argumentNodes collect: [ :each | each value ].
    newClass := class perform: selector withArguments: arguments asArray.
    loadedClasses add: newClass.
    proxies at: newClass put: newClass
!

doComment: receiver selector: selector arguments: argumentNodes
    | class |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^self ].

    class := self resolveClass: receiver.
    class comment: argumentNodes first value.
!

doClassInstVars: receiver selector: selector arguments: argumentNodes
    | class |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^self ].

    receiver isMessage ifFalse: [ ^self ].
    receiver selector = #class ifFalse: [ ^self ].

    class := self resolveClass: receiver.
    class instanceVariableNames: argumentNodes first value.
!

doSetNamespace: receiver selector: selector arguments: argumentNodes
    | ns |
    receiver isVariable ifFalse: [ ^self ].
    receiver name = 'Namespace' ifFalse: [ ^self ].

    ns := self resolveNamespace: argumentNodes first.
    self currentNamespace: ns
!

doAddNamespace: receiver selector: selector arguments: argumentNodes
    | root |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^self ].
    root := self resolveNamespace: receiver.
    root addSubspace: argumentNodes first value.
!

doMethodsFor: receiver selector: selector arguments: argumentNodes
    | class |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^self ].

    currentClass := self resolveClass: receiver.
    currentCategory := argumentNodes first value
!

resolveClass: node
    | object |
    (node isMessage and: [ node selector = #class ])
	ifTrue: [ ^(self resolveClass: node receiver) asMetaclass ].

    object := self resolveName: node.
    object isClass ifFalse: [ ^object ].

    ^self proxyForClass: object
!

resolveNamespace: node
    | object |
    object := self resolveName: node.
    object isNamespace ifFalse: [ ^object ].

    ^self proxyForNamespace: object
!

resolveName: node
    | current selectors |
    node isVariable
	ifTrue: [
	    ^(node name substrings: $.)
		inject: self currentNamespace
		into: [ :current :each | current at: each asSymbol ]
	].

    current := node.
    selectors := OrderedCollection new.
    [ current isMessage ] whileTrue: [
	selectors addFirst: current selector printNl.
	current := current receiver
    ].
    selectors addAllFirst: (current name printNl substrings: $.).

    ^selectors
	inject: self currentNamespace
	into: [ :current :each | current at: each asSymbol ]
! !

STClassLoader initialize!
