"======================================================================
|
|   ClassDescription Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005,2008
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



Behavior subclass: ClassDescription [
    
    <category: 'Language-Implementation'>
    <comment: 'My instances provide methods that access classes by category, and
allow whole categories of classes to be filed out to external disk
files.'>

    createGetMethod: what default: value [
	"Create a method accessing the variable `what', with a default value
	 of `value', using lazy initialization"

	<category: 'organization of messages and classes'>
	^(super createGetMethod: what default: value) methodCategory: 'accessing'
    ]

    createGetMethod: what [
	"Create a method accessing the variable `what'."

	<category: 'organization of messages and classes'>
	^(super createGetMethod: what) methodCategory: 'accessing'
    ]

    createSetMethod: what [
	"Create a method which sets the variable `what'."

	<category: 'organization of messages and classes'>
	^(super createSetMethod: what) methodCategory: 'accessing'
    ]

    defineAsyncCFunc: cFuncNameString withSelectorArgs: selectorAndArgs args: argsArray [
	"See documentation.  This function is deprecated, you should use
	 the <asyncCCall: ... > special syntax instead."

	<category: 'organization of messages and classes'>
	^(super 
	    defineAsyncCFunc: cFuncNameString
	    withSelectorArgs: selectorAndArgs
	    args: argsArray) methodCategory: 'C call-outs'
    ]

    defineCFunc: cFuncNameString withSelectorArgs: selectorAndArgs returning: returnTypeSymbol args: argsArray [
	"See documentation.  This function is deprecated, you should use
	 the <asyncCCall: ... > special syntax instead."

	<category: 'organization of messages and classes'>
	^(super 
	    defineCFunc: cFuncNameString
	    withSelectorArgs: selectorAndArgs
	    returning: returnTypeSymbol
	    args: argsArray) methodCategory: 'C call-outs'
    ]

    classify: aSelector under: aString [
	"Put the method identified by the selector aSelector
	 under the category given by aString."

	<category: 'organization of messages and classes'>
	^self >> aSelector methodCategory: aString
    ]

    removeCategory: aString [
	"Remove from the receiver every method belonging to the given category"

	<category: 'organization of messages and classes'>
	| selector method category |
	methodDictionary isNil ifTrue: [^self].
	methodDictionary copy associationsDo: 
		[:assoc | 
		method := assoc value.
		method methodCategory = category ifTrue: [methodDictionary remove: assoc]]
    ]

    whichCategoryIncludesSelector: selector [
	"Answer the category for the given selector, or nil if the selector is
	 not found"

	<category: 'organization of messages and classes'>
	| method |
	methodDictionary isNil ifTrue: [^nil].
	method := methodDictionary at: selector ifAbsent: [^nil].
	^method methodCategory
    ]

    copy: selector from: aClass [
	"Copy the given selector from aClass, assigning it the same category"

	<category: 'copying'>
	| method |
	method := aClass compiledMethodAt: selector.
	self addSelector: selector withMethod: (method withNewMethodClass: self)
    ]

    copy: selector from: aClass classified: categoryName [
	"Copy the given selector from aClass, assigning it the given category"

	<category: 'copying'>
	| method |
	method := (aClass compiledMethodAt: selector) withNewMethodClass: self.
	method methodCategory: categoryName.
	self addSelector: selector withMethod: method
    ]

    copyAll: arrayOfSelectors from: class [
	"Copy all the selectors in arrayOfSelectors from class, assigning them the
	 same category they have in class"

	<category: 'copying'>
	arrayOfSelectors do: [:selector | self copy: selector from: class]
    ]

    copyAll: arrayOfSelectors from: class classified: categoryName [
	"Copy all the selectors in arrayOfSelectors from aClass, assigning them
	 the given category"

	<category: 'copying'>
	arrayOfSelectors do: 
		[:selector | 
		self 
		    copy: selector
		    from: class
		    classified: categoryName]
    ]

    copyAllCategoriesFrom: aClass [
	"Copy all the selectors in aClass, assigning them the original category"

	<category: 'copying'>
	| method |
	aClass selectors do: [:selector | self copy: selector from: aClass]
    ]

    copyCategory: categoryName from: aClass [
	"Copy all the selectors in from aClass that belong to the given category"

	<category: 'copying'>
	| method |
	aClass selectors do: 
		[:selector | 
		method := aClass compiledMethodAt: selector.
		method methodCategory = categoryName 
		    ifTrue: [self copy: selector from: aClass]]
    ]

    copyCategory: categoryName from: aClass classified: newCategoryName [
	"Copy all the selectors in from aClass that belong to the given category,
	 reclassifying them as belonging to the given category"

	<category: 'copying'>
	| method |
	aClass selectors do: 
		[:selector | 
		method := aClass compiledMethodAt: selector.
		method methodCategory = categoryName 
		    ifTrue: 
			[self 
			    copy: selector
			    from: aClass
			    classified: newCategoryName]]
    ]

    compile: code classified: categoryName [
	"Compile code in the receiver, assigning the method to the given category.
	 Answer the newly created CompiledMethod, or nil if an error was found."

	<category: 'compiling'>
	| method |
	method := self compile: code.
	method notNil ifTrue: [method methodCategory: categoryName].
	^method
    ]

    compile: code classified: categoryName ifError: block [
	"Compile method source and install in method category, categoryName.  If
	 there are parsing errors, invoke exception block, 'block' (see
	 compile:ifError:).  Return the method"

	<category: 'compiling'>
	| method |
	method := self compile: code
		    ifError: 
			[:f :l :e | 
			^block 
			    value: f
			    value: l
			    value: e].
	method methodCategory: categoryName.
	^method
    ]

    compile: code classified: categoryName notifying: requestor [
	"Compile method source and install in method category, categoryName.  If
	 there are parsing errors, send an error message to requestor"

	<category: 'compiling'>
	| method |
	method := self compile: code notifying: requestor.
	method notNil ifTrue: [method methodCategory: categoryName].
	^method
    ]

    nameIn: aNamespace [
	"Answer the class name when the class is referenced from aNamespace"

	<category: 'printing'>
	^self environment == aNamespace 
	    ifTrue: [self name asString]
	    ifFalse: [(self environment nameIn: aNamespace) , '.' , self name]
    ]

    printOn: aStream in: aNamespace [
	"Print on aStream the class name when the class is referenced from
	 aNamespace"

	<category: 'printing'>
	self environment == aNamespace 
	    ifFalse: 
		[self environment printOn: aStream in: aNamespace.
		aStream nextPut: $.].
	aStream nextPutAll: self name
    ]

    classVariableString [
	<category: 'printing'>
	self subclassResponsibility
    ]

    instanceVariableString [
	"Answer a string containing the name of the receiver's instance variables."

	<category: 'printing'>
	| stream |
	instanceVariables isNil ifTrue: [^''].
	stream := WriteStream on: String new.
	instanceVariables do: 
		[:instVarName | 
		stream
		    nextPutAll: instVarName;
		    nextPut: $ ].
	^stream contents
    ]

    sharedVariableString [
	<category: 'printing'>
	self subclassResponsibility
    ]

    fileOutOn: aFileStream [
	"File out complete class description:  class definition, class and
	 instance methods.  Requires package Parser."

	<category: 'filing'>
	self subclassResponsibility
    ]

    fileOut: fileName [
	"Open the given file and to file out a complete class description to it.
	 Requires package Parser."

	<category: 'filing'>
	| aFileStream |
	aFileStream := FileStream open: fileName mode: FileStream write.
	Transcript
	    nextPutAll: 'Filing out class to: ';
	    nextPutAll: fileName.
	self fileOutOn: aFileStream.
	aFileStream close
    ]

    fileOutCategory: categoryName to: fileName [
	"File out all the methods belonging to the method category, categoryName,
	 to the fileName file.  Requires package Parser."

	<category: 'filing'>
	| aFileStream |
	aFileStream := FileStream open: fileName mode: FileStream write.
	Transcript
	    nextPutAll: 'Filing out a category to: ';
	    nextPutAll: fileName.
	self fileOutCategory: categoryName toStream: aFileStream.
	aFileStream close
    ]

    fileOutCategory: categoryName toStream: aFileStream [
	"File out the given selector to a FileStream.  Requires package Parser."

	<category: 'filing'>
	self notYetImplemented
    ]

    fileOutSelector: selector to: fileName [
	"File out the given selector to fileName.  Requires package Parser."

	<category: 'filing'>
	| aFileStream |
	aFileStream := FileStream open: fileName mode: FileStream write.
	Transcript
	    nextPutAll: 'Filing out a selector to: ';
	    nextPutAll: fileName.
	self fileOutSelector: selector toStream: aFileStream.
	aFileStream close
    ]

    fileOutSelector: selector toStream: aFileStream [
	"File out the given selector to a FileStream.  Requires package Parser."

	<category: 'filing'>
	self notYetImplemented
    ]

    collectCategories [
	"Answer all the method categories, sorted by name"

	<category: 'private'>
	| categories |
	methodDictionary isNil ifTrue: [^#()].
	categories := Set new.
	methodDictionary do: [:method | categories add: method methodCategory].
	^categories asSortedCollection
    ]

    binding [
	"Answer a VariableBinding object whose value is the receiver"

	<category: 'conversion'>
	^self environment associationAt: self asClass name
    ]

    asClass [
	<category: 'conversion'>
	self subclassResponsibility
    ]

    asMetaclass [
	"Answer the metaclass associated to the receiver"

	<category: 'conversion'>
	^self asClass class
    ]

    addSharedPool: aDictionary [
	"Add the given shared pool to the list of the class' pool dictionaries"

	<category: 'parsing class declarations'>
	self subclassResponsibility
    ]

    import: aDictionary [
	"Add the given shared pool to the list of the class' pool dictionaries"
	"If you promote this method, you must also promote the version
	 in Builtins.st."

	<category: 'parsing class declarations'>
	self addSharedPool: aDictionary
    ]
]

