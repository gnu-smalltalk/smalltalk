"======================================================================
|
|   SortCriteria example
|
|
 ======================================================================"


"======================================================================
|
| Written by Peter William Lount.
|
| This file is part of GNU Smalltalk.
|
 ======================================================================"

Object subclass: #SortCriteria
	instanceVariableNames: 'columnSortCriteria '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sort Criteria'!

Object subclass: #SortCriteriaColumn
	instanceVariableNames: 'columnName ascendingFlag accessProtocol '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sort Criteria'!

Object subclass: #SortCriteriaTest
	instanceVariableNames: 'size length code '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Sort Criteria'!

SortCriteria comment: 
'SortCriteria and SortCriteriaColumn objects copyright 1996, 1997, 1998, and 1999 by Peter William Lount
All rights reserved. peter@smalltalk.org, http://www.smalltalk.org

Usage License
You may use these objects for any purpose what so ever as long as this notice remains intact. If these objects are used in a used in a software product for which source code is not released to the public you must visibly display the above notice.'!


!SortCriteria methodsFor: 'initialization' stamp: 'pwl 7/16/1999 12:04'!
initialize

    columnSortCriteria := OrderedCollection new.! !


!SortCriteria methodsFor: 'sorted collection protocol' stamp: 'PWVL 9/14/1998 18:03'!
fixTemps
	"We don't need to do anything here."! !

!SortCriteria methodsFor: 'sorted collection protocol' stamp: 'PWVL 9/14/1998 17:17'!
value: theFirstElement value: theSecondElement
    "Part of the protocol that Blocks used in sorting use... the default sort block used by SortedCollection
    is [:a :b | a <= b]. We implement this protocol and can therefore be
    placed into the SortedCollection..."
    | aResult aLastColCriteria |
    columnSortCriteria isNil ifTrue: [
	 "Ignore the sorting order as we don't have any columns to sort...yet"
	^ true
    ] ifFalse: [
	 	"We have columns to sort, so lets sort them..."
	columnSortCriteria do: [:aColumnCriteria |
	    aResult := aColumnCriteria value: theFirstElement value: theSecondElement.
	    aResult == nil ifFalse: [
		"The elements are either greater or less, but not equal, return which..."
		^aResult
	    ].
	    "The elements in this column were equal - use the next column (if any)  to decide sort order..."
	    aLastColCriteria := aColumnCriteria.
	].
	"The last comparison of the elements were equal...return the appropriate value..."
	^ aLastColCriteria equalBoolean
    ]! !


!SortCriteria methodsFor: 'sort order' stamp: 'pwl 7/16/1999 11:35'!
addColumnName: theColumnName
ascendingFlag: theBoolean

    columnSortCriteria add: (
	SortCriteriaColumn new
	    columnName: theColumnName ;
	    ascendingFlag: theBoolean;
	    yourself
    )! !

!SortCriteria methodsFor: 'sort order'!
columnNames
    "Generate and return a list of column names in sequence..."
    | aList |
    aList := OrderedCollection new: columnSortCriteria size.
    columnSortCriteria do: [:aColSortCriteria |
	aList add: aColSortCriteria columnName asSymbol
    ].
    ^aList! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SortCriteria class
	instanceVariableNames: ''!

!SortCriteria class methodsFor: 'instance creation' stamp: 'pwl 7/16/1999 12:02'!
new
	^super new initialize! !



!SortCriteriaColumn methodsFor: 'initialize' stamp: 'pwl 7/16/1999 12:04'!
initialize

	self ascendingSort.
	self useMethodPerformProtocol.! !


!SortCriteriaColumn methodsFor: 'equality testing'!
equalBoolean
    "Return the boolean flag used to determine sort order when the two elements are the same...
    This is dependent upon the ascendingFlag sort order...
	i.e. Ascending sort: when a <= b return true, when a > b return false.
	      Decending sort: when a <= b return false, when a > b return true...
	Therefore, if you'll notice, it works to return a logical not of the ascending flag...
    "
    ^ ascendingFlag! !


!SortCriteriaColumn methodsFor: 'sort attribute'!
columnName
    ^columnName! !

!SortCriteriaColumn methodsFor: 'sort attribute'!
columnName: theColumnName
    columnName := theColumnName asSymbol! !


!SortCriteriaColumn methodsFor: 'sort order'!
ascendingFlag
    ^ascendingFlag! !

!SortCriteriaColumn methodsFor: 'sort order'!
ascendingFlag: theBoolean
    ascendingFlag := theBoolean.! !

!SortCriteriaColumn methodsFor: 'sort order' stamp: 'PWVL 9/14/1998 17:27'!
ascendingSort
    self ascendingFlag: true.! !

!SortCriteriaColumn methodsFor: 'sort order' stamp: 'PWVL 9/14/1998 17:27'!
decendingSort
    self ascendingFlag: false.! !


!SortCriteriaColumn methodsFor: 'attribute access protocols' stamp: 'PWVL 9/14/1998 17:27'!
useDictionaryAtProtocol
	accessProtocol := #dictionaryAt.
! !

!SortCriteriaColumn methodsFor: 'attribute access protocols' stamp: 'PWVL 9/14/1998 17:28'!
useMethodPerformProtocol
	accessProtocol := #methodPerform.
! !

!SortCriteriaColumn methodsFor: 'attribute access protocols' stamp: 'pwl 7/16/1999 11:46'!
valueOfColumnNamed: theColumnName 
for: theTargetObject
ifAbsent: theAbsentBlock

	"Retreive the value of the column name for the target object using the appropiate access method protocol.
	If the object does not have the column name as an attribute then execute the absent block and return it's result."

	accessProtocol = #dictionaryAt ifTrue: [
		^theTargetObject 
			at: columnName 
			ifAbsent: [
				nil
			].
	].
	accessProtocol = #methodPerform ifTrue: [
		^theTargetObject 
			perform: columnName
	].
	^nil! !


!SortCriteriaColumn methodsFor: 'sorted collection protocol' stamp: 'pwl 7/16/1999 08:56'!
value: theFirstElement value: theSecondElement
    | aFirstValue aSecondValue |
    "Compare the two elements and determine which comes first...
    If a column name is missing then use a blank value order..."
    columnName isNil ifTrue: [^ascendingFlag].

	"Get the value of the first element."
	aFirstValue := self valueOfColumnNamed: columnName for: theFirstElement ifAbsent: [^ascendingFlag].
	aFirstValue ifNil: [^ascendingFlag].

	"Get the value of the second element."
	aSecondValue := self valueOfColumnNamed: columnName for: theSecondElement ifAbsent: [^ascendingFlag not].
	aSecondValue ifNil: [^ascendingFlag not].

    "Actually compare the values now taking the ascending and decending order into account..."
    ascendingFlag ifTrue: [
	aFirstValue < aSecondValue ifTrue: [
	    "The first element comes before the second element..."
	    ^true
	] ifFalse: [
	    "Are the two elements equal?"
	    aFirstValue = aSecondValue ifTrue: [
		"The elements are equal... the next column (if any) must be checked..."
		^nil
	    ] ifFalse: [
		"The second element comes before the first..."
		^false
	    ]
	 ]
    ] ifFalse: [
	"The sort order is decending...reverse the comparisons..."
	aSecondValue < aFirstValue ifTrue: [
	    "The second element comes before the first element..."
	    ^true
	] ifFalse: [
	    "Are the two elements equal?"
	    aSecondValue = aFirstValue ifTrue: [
		"The elements are equal..."
		^nil
	    ] ifFalse: [
		"The first element comes before the second..."
		^false
	    ]
	 ]
    ]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SortCriteriaColumn class
	instanceVariableNames: ''!

!SortCriteriaColumn class methodsFor: 'instance creation' stamp: 'pwl 7/16/1999 12:02'!
new
	^super new initialize! !



!SortCriteriaTest comment:
'SortCriteriaTest is a test and an example of using the sort criteria objects.'!


!SortCriteriaTest methodsFor: 'accessing'!
code
    ^code! !

!SortCriteriaTest methodsFor: 'accessing'!
code: theObject
    code := theObject! !

!SortCriteriaTest methodsFor: 'accessing'!
length
    ^length! !

!SortCriteriaTest methodsFor: 'accessing'!
length: theObject
    length := theObject! !

!SortCriteriaTest methodsFor: 'accessing'!
size
    ^size! !

!SortCriteriaTest methodsFor: 'accessing'!
size: theObject
    size := theObject! !


!SortCriteriaTest methodsFor: 'printing' stamp: 'pwl 7/16/1999 12:46'!
printOn: theStream
  
    theStream
		nextPutAll: '(', self class name;
		nextPutAll: ' code: ', self code printString;
		nextPutAll: ' size: ', self size printString;
		nextPutAll: ' length: ', self length printString;
		nextPutAll: ')'; 
		cr
		! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SortCriteriaTest class
	instanceVariableNames: ''!

!SortCriteriaTest class methodsFor: 'testing' stamp: 'pwl 7/16/1999 12:50'!
addToList: theSortedList

    theSortedList add: (
	SortCriteriaTest new
	    code: 'R301';
	    size: '5M';
	    length: 50;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R202';
	    size: '29M';
	    length: 70;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R002';
	    size: '18M';
	    length: 65;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R202';
	    size: '15M';
	    length: 89;
	    yourself
    ).
   theSortedList add: (
	SortCriteriaTest new
	    code: 'R101';
	    size: '26M';
	    length: 90;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R202';
	    size: '15M';
	    length: 16;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R202';
	    size: '15M';
	    length: 18;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R202';
	    size: '15M';
	    length: 45;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R202';
	    size: '15M';
	    length: 89;
	    yourself
    ).
    theSortedList add: (
	SortCriteriaTest new
	    code: 'R202';
	    size: '15M';
	    length: 114;
	    yourself
    ).


    ^theSortedList! !

!SortCriteriaTest class methodsFor: 'testing' stamp: 'pwl 7/16/1999 12:48'!
test1
	"SortCriteriaTest test1"

	| aSortedList aSortCriteria |
	aSortCriteria := SortCriteria new.
	aSortCriteria addColumnName: #code ascendingFlag: true.
	aSortCriteria addColumnName: #size ascendingFlag: false.
	aSortCriteria addColumnName: #length ascendingFlag: false.

	aSortedList := SortedCollection sortBlock: aSortCriteria.
	self addToList: aSortedList.

    ^aSortedList! !

!SortCriteriaTest class methodsFor: 'testing' stamp: 'pwl 7/16/1999 12:49'!
test2
	"SortCriteriaTest test2"

	| aSortedList aSortCriteria |
	aSortCriteria := SortCriteria new.
	aSortCriteria addColumnName: #code ascendingFlag: true.
	aSortCriteria addColumnName: #size ascendingFlag: true.
	aSortCriteria addColumnName: #length ascendingFlag: true.

	aSortedList := SortedCollection sortBlock: aSortCriteria.

	self addToList: aSortedList.

    ^aSortedList! !

!SortCriteriaTest class methodsFor: 'testing' stamp: 'pwl 7/16/1999 13:05'!
test3
	"SortCriteriaTest test3"

	| aSortedList aSortCriteria |
	aSortCriteria := SortCriteria new.
	aSortCriteria addColumnName: #length ascendingFlag: false.
	aSortCriteria addColumnName: #code ascendingFlag: true.
	aSortCriteria addColumnName: #size ascendingFlag: true.

	aSortedList := SortedCollection sortBlock: aSortCriteria.

	self addToList: aSortedList.

    ^aSortedList! !
