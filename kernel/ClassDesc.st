"======================================================================
|
|   ClassDescription Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005
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



Behavior subclass: #ClassDescription
	 instanceVariableNames: ''
	 classVariableNames: ''
	 poolDictionaries: ''
	 category: 'Language-Implementation'
!

ClassDescription comment: 
'My instances provide methods that access classes by category, and
allow whole categories of classes to be filed out to external disk
files.' !




!ClassDescription methodsFor: 'organization of messages and classes'!

createGetMethod: what default: value
    "Create a method accessing the variable `what', with a default value
    of `value', using lazy initialization"

    ^(super createGetMethod: what default: value)
	methodCategory: 'accessing'
!

createGetMethod: what
    "Create a method accessing the variable `what'."

    ^(super createGetMethod: what)
	methodCategory: 'accessing'
!

createSetMethod: what
    "Create a method which sets the variable `what'."

    ^(super createSetMethod: what)
	methodCategory: 'accessing'
!

defineAsyncCFunc: cFuncNameString
    withSelectorArgs: selectorAndArgs
    args: argsArray
    "See documentation.  This function is deprecated, you should use
     the <asyncCCall: ... > special syntax instead."

    ^(super defineAsyncCFunc: cFuncNameString
	     withSelectorArgs: selectorAndArgs
	     args: argsArray) methodCategory: 'C call-outs'
!

defineCFunc: cFuncNameString
    withSelectorArgs: selectorAndArgs
    returning: returnTypeSymbol 
    args: argsArray
    "See documentation.  This function is deprecated, you should use
     the <asyncCCall: ... > special syntax instead."

    ^(super defineCFunc: cFuncNameString
	     withSelectorArgs: selectorAndArgs
	     returning: returnTypeSymbol 
	     args: argsArray) methodCategory: 'C call-outs'
!

classify: aSelector under: aString
    "Put the method identified by the selector aSelector
     under the category given by aString."
    ^(self >> aSelector) methodCategory: aString
!

removeCategory: aString
    "Remove from the receiver every method belonging to the given category"
    | selector method category |
    methodDictionary isNil
    	ifTrue: [ ^self ].

    methodDictionary copy associationsDo: [ :assoc |
	method := assoc value.
	method methodCategory = category ifTrue: [
	   methodDictionary remove: assoc
	]
    ].
!

whichCategoryIncludesSelector: selector
    "Answer the category for the given selector, or nil if the selector is
     not found"
    
    | method |
    methodDictionary isNil ifTrue: [ ^nil ].
    method := methodDictionary at: selector ifAbsent: [ ^nil ].
    ^method methodCategory
! !



!ClassDescription methodsFor: 'copying'!

copy: selector from: aClass
    "Copy the given selector from aClass, assigning it the same category"
    | method |
    method := aClass compiledMethodAt: selector.
    methodDictionary at: selector put: (method withNewMethodClass: self).
!

copy: selector from: aClass classified: categoryName
    "Copy the given selector from aClass, assigning it the given category"
    | method |
    method := (aClass compiledMethodAt: selector) withNewMethodClass: self.
    method methodCategory: categoryName.
    methodDictionary at: selector put: method
!

copyAll: arrayOfSelectors from: class
    "Copy all the selectors in arrayOfSelectors from class, assigning them the
     same category they have in class"
    arrayOfSelectors do:
	[ :selector | self copy: selector
			   from: class ]
!

copyAll: arrayOfSelectors from: class classified: categoryName
    "Copy all the selectors in arrayOfSelectors from aClass, assigning them
     the given category"
    arrayOfSelectors do:
	[ :selector | self copy: selector
			   from: class
			   classified: categoryName ]
!

copyAllCategoriesFrom: aClass
    "Copy all the selectors in aClass, assigning them the original category"
    | method |
    aClass selectors do:
	[ :selector | self copy: selector from: aClass ]
!

copyCategory: categoryName from: aClass
    "Copy all the selectors in from aClass that belong to the given category"
    | method |
    aClass selectors do:
	[ :selector | method := aClass compiledMethodAt: selector.
		      method methodCategory = categoryName
			  ifTrue: [ self copy: selector from: aClass ] ]
!

copyCategory: categoryName from: aClass classified: newCategoryName
    "Copy all the selectors in from aClass that belong to the given category,
     reclassifying them as belonging to the given category"
    | method |
    aClass selectors do:
	[ :selector | method := aClass compiledMethodAt: selector.
		      method methodCategory = categoryName
			  ifTrue: [ self copy: selector
					 from: aClass
					 classified: newCategoryName ] ]
! !



!ClassDescription methodsFor: 'compiling'!

compile: code classified: categoryName
    "Compile code in the receiver, assigning the method to the given category.
     Answer the newly created CompiledMethod, or nil if an error was found."
    | method |
    method := self compile: code.
    method notNil 
		ifTrue: [method methodCategory: categoryName].
    ^method
!

compile: code classified: categoryName ifError: block
    "Compile method source and install in method category, categoryName.  If
     there are parsing errors, invoke exception block, 'block' (see
     compile:ifError:).  Return the method"
    | method |
    method := self compile: code ifError: [ :f :l :e |
	^block value: f value: l value: e
    ].
    method methodCategory: categoryName.
    ^method
!

compile: code classified: categoryName notifying: requestor
    "Compile method source and install in method category, categoryName.  If
     there are parsing errors, send an error message to requestor"
    | method |
    method := self compile: code notifying: requestor.
    method notNil 
		ifTrue: [method methodCategory: categoryName].
    ^method
! !



!ClassDescription methodsFor: 'printing'!

nameIn: aNamespace
    "Answer the class name when the class is referenced from aNamespace"
    ^self environment == aNamespace
	ifTrue: [ self name asString ]
	ifFalse: [ (self environment nameIn: aNamespace), '.', self name ]
!

printOn: aStream in: aNamespace
    "Print on aStream the class name when the class is referenced from
     aNamespace"
    self environment == aNamespace
	ifFalse: [ 
	    self environment printOn: aStream in: aNamespace.
	    aStream nextPut: $. ].

    aStream nextPutAll: self name!

classVariableString
    self subclassResponsibility
!

instanceVariableString
    "Answer a string containing the name of the receiver's instance variables."
    | stream |
    instanceVariables isNil ifTrue: [ ^'' ].
    stream := WriteStream on: String new.
    instanceVariables do: [ :instVarName |
	stream nextPutAll: instVarName; nextPut: ($ ) ].
    ^stream contents
!

sharedVariableString
    self subclassResponsibility
! !



!ClassDescription methodsFor: 'filing'!

fileOutOn: aFileStream
    "File out complete class description:  class definition, class and
     instance methods"

    self subclassResponsibility
!

fileOut: fileName
    "Open the given file and to file out a complete class description to it"

    | aFileStream  |
    aFileStream := FileStream open: fileName mode: FileStream write.

    Transcript nextPutAll: 'Filing out class to: '; nextPutAll: fileName.
    
    self fileOutOn: aFileStream. 
    aFileStream close.
!

fileOutCategory: categoryName to: fileName
    "File out all the methods belonging to the method category, categoryName,
     to the fileName file"

    | aFileStream |
    aFileStream := FileStream open: fileName mode: FileStream write.

    Transcript nextPutAll: 'Filing out a category to: '; nextPutAll: fileName.

    self fileOutCategory: categoryName toStream: aFileStream.
    aFileStream close
!
	
fileOutCategory: category toStream: aFileStream
    "File out all the methods belonging to the method category, categoryName,
     to aFileStream"

    | methods |
    self selectors isNil ifTrue: [ ^self ].

    methods := self selectors select: [ :selector |
	(self compiledMethodAt: selector) methodCategory = category
    ].

    methods isEmpty ifTrue: [ ^self ].

    aFileStream
	nextPut: $!;
	print: self;
	nextPutAll: ' methodsFor: ';
	store: category;
	nextPut: $!.

    methods asSortedCollection do: [ :selector |
	aFileStream
	    nextPutAll: '

';
	    "nextPutAll: (STInST.RBFormatter new
		format: (STInST.RBParser parseMethod: (self sourceCodeAt: selector)));"
	    nextPutAll: (self sourceCodeAt: selector);
	    nextPut: $!
    ].
    aFileStream nextPutAll: ' !

'
!

fileOutHeaderOn: aFileStream
    "Write date and time stamp to aFileStream"
    | now |
    aFileStream nextPutAll: '"Filed out from ';
	nextPutAll: Smalltalk version;
	nextPutAll: ' on '.
    now := Date dateAndTimeNow.
    aFileStream print: now asDate;
	nextPutAll:  '  ';
	print: now asTime;
	nextPutAll: '"!

'!

fileOutSelector: selector to: fileName
    "File out the given selector to fileName"

    | aFileStream |
    aFileStream := FileStream open: fileName mode: FileStream write.

    Transcript nextPutAll: 'Filing out a selector to: '; nextPutAll: fileName.
    self fileOutHeaderOn: aFileStream.
    aFileStream nextPutAll: '!';
	print: self;
	nextPutAll: ' methodsFor: ';
	store: (self compiledMethodAt: selector) methodCategory;
	nextPut: $!;
	nl;
	nextPutAll: (self sourceCodeAt: selector) ;
	nextPutAll: '! !';
	close
! !


!ClassDescription methodsFor: 'private'!

collectCategories
    "Answer all the method categories, sorted by name"

    | categories |
    methodDictionary isNil ifTrue: [ ^#() ].

    categories := Set new.
    methodDictionary do:
	[ :method | categories add: (method methodCategory) ].

    ^categories asSortedCollection
! !


!ClassDescription methodsFor: 'conversion'!

binding
    "Answer a VariableBinding object whose value is the receiver"
    ^self environment associationAt: self asClass name
!

asClass
    self subclassResponsibility
!

asMetaclass
    "Answer the metaclass associated to the receiver"
    ^self asClass class
! !
