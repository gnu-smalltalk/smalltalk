"======================================================================
|
|   C declaration tree node definitions
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



"Issues:

Problem: directly referencing a possibly null parent type could cause 
problems.  We could plug in a dummy one which just terminates the recursions. 
Or, each could check for nil.   Or we bottle neck all through an inherited 
method which does the nil check.
"


Object subclass: #CDeclarationNode
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationNode methodsFor: 'accessing'!

name
    ^self subclassResponsibility
!

getType: baseType
    ^self subclassResponsibility
! !


!CDeclarationNode methodsFor: 'printing'!

storeOn: aStream using: aBlock
    aStream nextPut: $(; nextPutAll: self class name; nl.
    aBlock value.
    aStream nextPut: $).
! !



CDeclarationNode subclass: #CDeclarationHierarchyNode
       instanceVariableNames: 'parentType'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationHierarchyNode methodsFor: 'accessing'!

name
    ^parentType name
!

parentType: aType
    parentType _ aType
! !



CDeclarationNode subclass: #CDeclarationTypedefNameReplacement
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

"Don't know what methods go here yet"

!CDeclarationTypedefNameReplacement methodsFor: 'accessing'!

name
    ^nil			"we don't have a name, ad we want 
				|declaration things which check for a name to 
				|fail "
! !




CDeclarationNode subclass: #CDeclarationName
       instanceVariableNames: 'name'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationName class methodsFor: 'instance creation'!

name: aName
    ^self new init: aName
! !

!CDeclarationName methodsFor: 'accessing'!

name
    ^name
!

getType: baseType
    ^baseType
!

typedefIntoType
    "The usage here is that the type tree is rebuilt and returned."
    ^CDeclarationTypedefNameReplacement new
! !


!CDeclarationName methodsFor: 'printing'!

printOn: aStream
    "!!! fix me"
    super printOn: aStream
!

storeOn: aStream
    self storeOn: aStream using:
	[ aStream nextPutAll: '    name: '; store: name. ].
! !



!CDeclarationName methodsFor: 'private'!

init: aName
    name _ aName
! !


CDeclarationHierarchyNode subclass: #CDeclarationArray
       instanceVariableNames: 'length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationArray class methodsFor: 'instance creation'!

length: anInteger parentType: aType
    ^self new init: anInteger parentType: aType
! !

!CDeclarationArray methodsFor: 'accessing'!

typedefIntoType
    ^CDeclarationArray length: length 
		       parentType: parentType typedefIntoType
!

getType: baseType
    ^parentType getType: (CLangArray length: length subType: baseType)
! !


!CDeclarationArray methodsFor: 'printing'!

printOn: aStream
    "!!! fix me!!!"
    super printOn: aStream.
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    length: '; store: length ; nl;
	nextPutAll: '    parentType: '; store: parentType; 
	nextPut: $).
! !



!CDeclarationArray methodsFor: 'private'!

init: anInteger parentType: aType
    length _ anInteger.
    self parentType: aType.
! !


CDeclarationHierarchyNode subclass: #CDeclarationPtr
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationPtr class methodsFor: 'instance creation'!

declarator: aType
    ^self new init: aType
! !

!CDeclarationPtr methodsFor: 'accessing'!

typedefIntoType
    ^CDeclarationPtr declarator: parentType typedefIntoType
!

getType: baseType
    ^parentType getType: (CLangPtr subType: baseType)
! !


!CDeclarationPtr methodsFor: 'printing'!

printOn: aStream
    self notYetImplemented
!

storeOn: aStream
    aStream nextPut: $(;
	nextPutAll: self class name; nextPutAll: ' declarator: ';
	store: parentType; nextPut: $).
! !



!CDeclarationPtr methodsFor: 'private'!

init: aType
    self parentType: aType.
! !


CDeclarationHierarchyNode subclass: #CDeclarationFunction
       instanceVariableNames: 'arguments'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationFunction class methodsFor: 'instance creation'!

parentType: aType arguments: argList
    ^self new init: aType arguments: argList
! !

!CDeclarationFunction methodsFor: 'accessing'!

typedefIntoType
    ^CDeclarationFunction parentType: parentType typedefIntoType
			  arguments: arguments
!

getType: baseType
    ^parentType getType: (CLangFunction returnType: baseType
					argList: arguments )
! !


!CDeclarationFunction methodsFor: 'printing'!

printOn: aStream
    self notYetImplemented
!

storeOn: aStream
    aStream nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    parentType: '; store: parentType; nl;
	nextPutAll: '    arguments: '; store: arguments;
	nextPut: $).
! !



!CDeclarationFunction methodsFor: 'private'!

init: aType arguments: argList
    self parentType: aType.
    arguments _ argList.
! !


CDeclarationNode subclass: #CDeclarationArgument
       instanceVariableNames: 'specifier declarator'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationArgument class methodsFor: 'instance creation'!

specifier: aSpecifier declarator: aDeclarator
    ^self new init: aSpecifier declarator: aDeclarator
! !

!CDeclarationArgument methodsFor: 'accessing'!

name
    self notYetImplemented
!

getType: baseType
    self notYetImplemented
! !


!CDeclarationArgument methodsFor: 'printing'!

printOn: aStream
    '>>>>>>>>>>CDeclarationArgument printOn: not done!!!' printNl.
    ^super printOn: aStream
!

storeOn: aStream
    aStream 
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    specifier: '; store: specifier; nl;
	nextPutAll: '    declartor: '; store: declarator;
	nextPut: $); nl.
! !


!CDeclarationArgument methodsFor: 'private'!

init: aSpecifier declarator: aDeclarator
    specifier _ aSpecifier.
    declarator _ aDeclarator.
! !


CDeclarationNode subclass: #CDeclarationArgEllipses
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationArgEllipses methodsFor: 'accessing'!

"I don't know what this does right yet..."
!



CDeclarationNode subclass: #CDeclaration
       instanceVariableNames: 'specifier declarator'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclaration class methodsFor: 'instance creation'!

specifier: aSpecifier declarator: aDeclarator
    ^self new init: aSpecifier declarator: aDeclarator
! !


!CDeclaration methodsFor: 'accessing'!

"name, type, storage class, etc."
name
    ^declarator name
!

getType				"no need for the base type here; it is our 
				 specifier instance variable"

    ^declarator getType: specifier "get the type from the specifier?"
!

typedefIntoType
    ^CDeclaration specifier: specifier typedefIntoType
		  declarator: declarator typedefIntoType
!

storageClass
    ^specifier storageClass
!

isTypedef
    ^specifier isTypedef
! !


!CDeclaration methodsFor: 'declaring'!

declareInto: symbolTable
    | name |
    specifier declareInto: symbolTable.
    (declarator notNil and: 
	 [name _ declarator name. 
	  name notNil] ) ifTrue:
	[ symbolTable inspect.
	  name printNl.
	  symbolTable at: name put: self. ].
! !


!CDeclaration methodsFor: 'printing'!

printOn: aStream
    ^super printOn: aStream
!

storeOn: aStream
    aStream 
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    specifier: '; store: specifier; nl;
	nextPutAll: '    declarator: '; store: declarator; nl;
	nextPut: $); nl.
! !


!CDeclaration methodsFor: 'private'!

init: aSpecifier declarator: aDeclarator
    specifier _ aSpecifier.
    declarator _ aDeclarator.
! !



"It's not clear what class this should descend from."
Object subclass: #CDeclarationSpecifier
       instanceVariableNames: 'storageClass isTypedef type'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationSpecifier class methodsFor: 'instance creation'!

storageClass: aStorageClass type: aType
    ^self new init: aStorageClass type: aType
! !


!CDeclarationSpecifier methodsFor: 'accessing'!

storageClass
    ^storageClass
!

storageClass: aStorageClass
    storageClass _ aStorageClass
!

type
    ^type
!

type: aType
    type _ aType
!

isTypedef
    ^isTypedef
!

isTypedef: aBoolean
    isTypedef _ aBoolean
!

typedefIntoType
    ^CDeclarationSpecifier storageClass: nil type: type
! !


!CDeclarationSpecifier methodsFor: 'declaring'!

declareInto: symbolTable
    type declareInto: symbolTable
! !



!CDeclarationSpecifier methodsFor: 'printing'!

printOn: aStream
    storageClass notNil
	ifTrue: [ storageClass printOn: aStream; space ].
    isTypedef
	ifTrue: [ aStream nextPutAll: 'typedef ' ].
    type printOn: aStream.
!

storeOn: aStream
    aStream nextPutAll: '((';
	nextPutAll: self class name; nl;
	nextPutAll: '    storageClass: '; store: storageClass; nl;
	nextPutAll: '    type: '; store: type; nextPutAll: ');' ; nl;
	nextPutAll: '    isTypedef: '; store: isTypedef; nextPut: $; ; nl;
	nextPutAll: '    yourself)'.
! !



!CDeclarationSpecifier methodsFor: 'private'!

init: aStorageClass type: aType
    storageClass _ aStorageClass.
    type _ aType.
    isTypedef _ false.
! !


CDeclarationHierarchyNode subclass: #CDeclarationBitfield
       instanceVariableNames: 'length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationBitfield class methodsFor: 'instance creation'!

parentType: aType length: anInteger
    ^self new init: aType length: anInteger

! !

!CDeclarationBitfield methodsFor: 'accessing'!

getType: baseType
    ^parentType getType: (CLangBitfield type: baseType length: length)
! !


!CDeclarationBitfield methodsFor: 'printing'!

printOn: aStream
    aStream 
	print: parentType;
	nextPutAll: ' : ';
	print: length
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    parentType: '; store: parentType; nl;
	nextPutAll: '    length: '; store: length; nl;
	nextPut: $).
! !


!CDeclarationBitfield methodsFor: 'private'!

init: aType length: anInteger
    self parentType: aType.
    length _ anInteger.
! !


CDeclarationNode subclass: #CDeclarationEnum
       instanceVariableNames: 'name literals'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationEnum class methodsFor: 'instance creation'!

name: aName literals: literalCollection
    ^self new init: aName literals: literalCollection
! !


!CDeclarationEnum methodsFor: 'accessing'!

name
    ^name
!

literals
    ^literals
! !
    

!CDeclarationEnum methodsFor: 'declaring'!

declareInto: symbolTable
    (name notNil and: [ literals notNil ])
	ifTrue: [ symbolTable atEnum: name put: literals ].
! !


!CDeclarationEnum methodsFor: 'printing'!

printOn: aStream
    "!!!not there yet"
    super printOn: aStream
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    name: '; store: name; nl;
	nextPutAll: '    literals: '; store: literals; nl;
	nextPut: $).
! !


!CDeclarationEnum methodsFor: 'private'!

init: aName literals: literalCollection
    name _ aName.
    literals _ literalCollection.
! !




CDeclarationNode subclass: #CDeclarationEnumerator
       instanceVariableNames: 'name value'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationEnumerator class methodsFor: 'instance creation'!

name: aName value: aValue
    ^self new init: aName value: aValue
! !

!CDeclarationEnumerator methodsFor: 'accessing'!

name
    ^name
!

value
    ^value
! !

!CDeclarationEnumerator methodsFor: 'printing'!

printOn: aStream
    "!!! not done yet"
    super printOn: aStream
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    name: '; store: name; nl;
	nextPutAll: '    value: '; store: value; nl;
	nextPut: $).
! !


!CDeclarationEnumerator methodsFor: 'private'!

init: aName value: aValue
    name _ aName.
    value _ aValue.
! !


CDeclarationNode subclass: #CDeclarationStructoid
       instanceVariableNames: 'name members'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationStructoid class methodsFor: 'instance creation'!

name: aName members: memberCollection
    ^self new init: aName members: memberCollection
! !

"!!!Accessors"

!CDeclarationStructoid methodsFor: 'accessors'!

name
    ^name
!

members
    ^members
! !

!CDeclarationStructoid methodsFor: 'declaring'!

declareInto: symbolTable
    (name notNil and: [ members notNil ])
	ifTrue: [ symbolTable atStruct: name
			      put: self "maybe just the members?" ].
! !





!CDeclarationStructoid methodsFor: 'printing'!

printOn: aStream
    '{CDeclarationStructoid}' printNl.
    super printOn: aStream
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    name: '; store: name; nl;
	nextPutAll: '    members: '; store: members; nl;
	nextPut: $).
    
! !


!CDeclarationStructoid methodsFor: 'prviate'!

init: aName members: memberCollection
    name _ aName.
    members _ memberCollection.
! !


CDeclarationStructoid subclass: #CDeclarationStruct
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 



CDeclarationStructoid subclass: #CDeclarationUnion
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 



CDeclarationNode subclass: #CDeclarationInitialized
       instanceVariableNames: 'declarator initializer'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationInitialized class methodsFor: 'instance creation'!

declarator: aDeclarator initializer: anInitializer
    ^self new init: aDeclarator initializer: anInitializer
! !


!CDeclarationInitialized methodsFor: 'accessing'!

declarator
    ^declarator
!

initializer
    ^initializer
!

name
    ^declarator name
! !

!CDeclarationInitialized methodsFor: 'printing'!

printOn: aStream
    aStream 
	print: declarator;
	nextPutAll: ' = ';
	print: initializer
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    declarator: '; store: declarator; nl;
	nextPutAll: '    initializer: '; store: initializer; nl;
	nextPut: $).
! !


!CDeclarationInitialized methodsFor: 'private'!

init: aDeclarator initializer: anInitializer
    declarator _ aDeclarator.
    initializer _ anInitializer.
! !
