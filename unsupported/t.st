"======================================================================
|
|   Generic test bed and source of interesting bits of code for GNU 
|   Smalltalk.
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

stdout nextPutAll: ('Welcome to GNU Smalltalk [', Version, ']

This file contains a wealth of goodies, not all packaged neatly.
It sort of grows by accretion, so you''re likely to find most
anything in here.
' ).

ObjectMemory quit!

"| q |
    q := SharedQueue new.
    q nextPut: 'foo'.
    q nextPut: 'bar'.
    q next printNl.
    q next printNl.
    q next printNl   ""Should print no-runnable-proceses""
!
"

Object withAllSubclasses do: 
    [ :subclass | (subclass name notNil and: [ subclass comment isNil ])
		      ifTrue: [ subclass name print.
				' has no comment.' printNl ] 
		      ]

!

ObjectMemory quit!



!Object methodsFor: 'testing'!

test
    | x |
      x := [ :dummy | "thisContext inspect.
		  Smalltalk backtrace."
		    thisContext backit ].
"    x inspect."
    x value: 3
!

backit
    | n context | 
    n := 0.
    context := thisContext.
    [ context notNil ] whileTrue: [ n := n + 1. context := context parentContext ].
    context := thisContext.
    n to: 1 by: -1 do: 
	[ :i | context receiver print.
	       '>>' print.
	       context selector printNl.
	       context := context parentContext ].
! !

!BlockContext methodsFor: 'debugging'!

callers
    self inspect.
    caller notNil
	ifTrue: [ caller callers ]
!

parentContext
    ^caller
!

selector
    ^selector
!

receiver
    ^'[] in ', home class name
! !

!MethodContext methodsFor: 'debugging'!

callers
    self inspect.
    sender notNil 
	ifTrue: [ sender callers ]
!

parentContext
    ^sender
!

receiver
    ^receiver class name
!

selector
    ^selector
! !

3 test!

ObjectMemory quit!


"| count |

SymbolTable do: 
    [ :elt | elt printString.
	     "Character nl print
	     count := 0.
	     elt notNil ifTrue: [ elt do: [ :x | count := count + 1 ]].
	     count timesRepeat: [ 'x' print ].
	     Character nl print" ] !


ObjectMemory quit!
"

"| d days |
d := Date new.
1 to: 70 do:
    [ :year | days := year * 365.
    	      days - 5 to: days + 5 do:
		 [ :i | d setDays: i.
			d printString ] ]
!

ObjectMemory quit!"

Date edit: #computeDateParts:!

"| pipe |
    pipe := FileStream popen: 'lpr -Pelab' dir: 'w'.
    FileStream fileOutOn: pipe.
    FileStream class fileOutOn: pipe.
    pipe close!"



| d days |
d := Date new.
1 to: 70 do:
    [ :year | days := year * 365.
    	      '----------' printNl.
    	      days - 5 to: days + 5 do:
		 [ :i | d setDays: i.
			d printNl ] ]
!

Date today printNl!

| f |
    f := ReadWriteStream on: (String new: 0).
    'foo on you' printOn: f.
    f position: 3.
    '123456789' printOn: f.
    f skip: -1.
    f next printNl.
    f contents printNl.
    f reset.
    'test[]' printOn: f.
    f contents printNl!

16r3F0000000 printNl!

ObjectMemory quit!

!Date methodsFor: 'rambo'!

computeDateParts: aBlock
    | yearInteger tempDays monthIndex daysInMonth |
    tempDays := days - (days // 1460) "4*365"
    	    	    + (days // 36500) "100*365"
		    - (days // 146000). "400*365"
    yearInteger := tempDays // 365.
    tempDays := days - (yearInteger * 365)
		    - (yearInteger // 4)
		    + (yearInteger // 100)
		    - (yearInteger // 400)
		    + 1.
    yearInteger := yearInteger + 1901.
    monthIndex := 1.
    [ monthIndex < 12
    	and: [ daysInMonth := Date daysInMonthIndex: monthIndex
	    	    	    	  forYear: yearInteger.
    	       tempDays > daysInMonth ] ] whileTrue:
    	[ monthIndex := monthIndex + 1.
	  tempDays := tempDays - daysInMonth ].
    ^aBlock value: yearInteger value: monthIndex value: tempDays
! !

| d days |
d := Date new.
1 to: 70 do:
    [ :year | days := year * 365.
    	      '----------' printNl.
    	      days - 5 to: days + 5 do:
		 [ :i | d setDays: i.
			d printNl ] ]
!

Date today printNl!

| f |
    f := ReadWriteStream on: (String new: 0).
    'foo on you' printOn: f.
    f position: 3.
    '123456789' printOn: f.
    f skip: -1.
    f next printNl.
    f contents printNl.
    f reset.
    'test[]' printOn: f.
    f contents printNl!

16r3F0000000 printNl!


| d days |
d := Date new.
1 to: 70 do:
    [ :year | days := year * 365.
    	      '----------' printNl.
    	      days - 3 to: days + 10 do:
		 [ :i | d setDays: i.
			d printNl ] ]
!

Date today printNl!

| f |
    f := ReadWriteStream on: (String new: 0).
    'foo on you' printOn: f.
    f position: 3.
    '123456789' printOn: f.
    f skip: -1.
    f next printNl.
    f contents printNl.
    f reset.
    'test[]' printOn: f.
    f contents printNl!

Object withAllSubclasses do:
    [ :aClass | aClass fileOutOn: stdout ]!

!Bag methodsFor: 'enumerating the elements of a collection'!

occurrencesOf: anObject
    ^contents at: anObject ifAbsent: [ ^0 ]
!

size
    | count |
    count := 0.
    contents printNl.
    contents do: [ :element | count := count + element ].
    ^count
!

do: aBlock
    contents associationsDo:
      [ :assoc | assoc value printNl
"  assoc value timesRepeat: [ aBlock value: assoc key ]" ]
! !

| b |
    b := Bag new.
    (b occurrencesOf: 'foo' ) printNl.
    b size printNl.
    b basicSize printNl.
    b add: 'foo'.
    b add: 'bar'.
    b add: 'quem.'.
    b do: [ :value | 'value is ' print. value printNl ]
!

!ClassDescription methodsFor: 'filing'!

fileOutOn: aFileStream
    | categories |
    categories := Bag new.
    methodDictionary do:
	[ :method | categories add: (method methodCategory) ].
'categories....' printNl.
    categories inspect.
    categories do:
	[ :category | category printNl "self emitCategory: category toStream: aFileStream" ]
! !

!ClassDescription methodsFor: 'private'!

emitCategory: category toStream: aFileStream
    ' methodsFor: ''' printOn: aFileStream.
    category printOn: aFileStream.
    '''

'   printOn: aFileStream.
    methodDictionary do:
	[ :method | (method methodCategory) = category
			ifTrue: [ method methodSourceString
				      printOn: aFileStream.
				  '!

'				 printOn: aFileStream ] ].
    '!

'   printOn: aFileStream

! !

Object fileOutOn: stdout!


"Boolean selectors do: [ :selectors | selectors printNl ].
'
after ' printNl.
Boolean copyCategory: 'basic' from: True.
Boolean selectors do: [ :selectors | selectors printNl ]!"

"| method newMethod |
    method := CompiledMethod compiledMethodAt: #bytecodeAt:.
    'Original' printNl.
    method inspect.
    '

Cheap imitation' printNl.
    newMethod := Object copy: #bytecodeAt:
		     from: CompiledMethod
		     classified: 'rambo'.
    (Object compiledMethodAt: #bytecodeAt:) methodCategory printNl.

    method methodCategory printNl
!

ObjectMemory quit!"


"| j |
    j := 0.
    1 to: 20000 do: [ :i | j := j + i ]!

ObjectMemory quit!"

"Smalltalk gcMessage: false!"

!ClassDescription methodsFor: 'test'!

printSubclassMethods
    | mySubclasses |
    self name printNl.
    instanceVariables notNil
	ifTrue: [ 'Instance variables: ' print.
		  instanceVariables do: [ :var | var print.
						 ' ' print ].
		  Character nl print].
    '-----------------------------------------------' printNl.
    self selectors asSortedCollection do:
	[ :selector |
	  (self compiledMethodAt: selector) methodSourceString printNl.
	 '' printNl ].
    mySubclasses := self subclasses asSortedCollection:
    	    		[ :a :b | (a name isNil or: [ b name isNil ])
    	    	    	    	      ifTrue: [ true ]
		    	    	      ifFalse: [ a name <= b name ] ].
    mySubclasses do:
    	[ :subclass | subclass class ~~ Metaclass
	    	    	ifTrue: [ subclass printSubclassMethods ] ]
! !


Object printSubclassMethods!

ObjectMemory quit!
""
!Collection methodsFor: 'test'!

printSorted
    self asSortedCollection do:
    	[ :element | '    ' print. element printNl ]
! !
"
Smalltalk at: #BasicClassSelectors put: Class allSelectors!

"
!Behavior methodsFor: 'test'!

printInheritedSelectors
    | sels |
    sels := self allSelectors.
    sels removeAll: self selectors.
    sels printSorted
!
"
printNewSelectors
    | sels |
    sels := self allSelectors.
    sels removeAll: BasicClassSelectors.
    sels printSorted

!"!
Smalltalk monitor: true.
Class printInheritedSelectors.
Smalltalk monitor: false.
ObjectMemory quit!"
"

"Metaclass allInstancesDo: [ :inst | '------------' print.
    	    	    	    	    inst print.
    	    	    	    	    inst printNewSelectors.
				    '' print ] !"

"| selectorSet newSelectors |
selectorSet := Set new.
Object withAllSubclasses do:
    [ :subclass | newSelectors := subclass selectors.
    	    	  '-----------------' print.
    	    	  subclass print.
		  newSelectors printSorted.
		  '' print.
		  selectorSet addAll: newSelectors ].
'****************' print.
'The set of selectors is...' print.
selectorSet size print.
selectorSet do: [ :elt | elt print ]
!"

'LIVE' printNl!

(Object withAllSubclasses asSortedCollection:
    [ :a :b | (a name isNil or: [ b name isNil ])
    	    	ifTrue: [ true ]
		ifFalse: [ a name <= b name ] ])
    do:
	[ :subclass | 
    	    subclass class ~~ Metaclass
    	    	ifTrue: [ '------------------------------------------' printNl.
		    	  subclass printNl.
    		    	  'inherited selectors' printNl.
    			  subclass printInheritedSelectors.
			  '' printNl ]
    ]!


ObjectMemory quit!


"


"**********************************************************************"

('foo' match: 'foo') printNl.
('foo' match: 'FoO') printNl.
('#oo' match: 'Foo') printNl.
('###' match: 'que') printNl.
'should be false ' print.       ('###' match: 'quem') printNl.
'should be false ' print.       ('###' match: 'bo') printNl.
'should be true  ' print.	('* string' match: 'any string') printNl.
'should be true  ' print.	('*.st' match: 'filename.st') printNl.
'should be true  ' print.	('foo.*' match: 'foo.bar') printNl.
'should be true  ' print.	('foo.*' match: 'foo.') printNl.
'should be true  ' print.	('*' match: 'foo.') printNl.
'should be true  ' print.	('*' match: '') printNl.
'should be true  ' print.	('***' match: '') printNl.
'should be true  ' print.	('*.st' match: '.st') printNl.
'should be true  ' print.	('*#*' match: '.st') printNl.
'should be true  ' print.	('*#*' match: '.s') printNl.
'should be true  ' print.	('*#*' match: 's') printNl.
'should be false ' print.	('*.st' match: '.s') printNl.
'should be false ' print.	('*#*' match: '') printNl!

ObjectMemory quit!

| j |
    j := 0.
    1 to: 1000 do:
    	[ :i | j := j + i ]!

ObjectMemory quit!

300 timesRepeat:
    [ String new: 20000 ].
'Foo ' printNl!
    

"ObjectMemory quit!"

!Object methodsFor: 'testing'!

quem
    ^1 + 2
! !

!Symbol methodsFor: 'testing'!
quem
    ^1 + 2
! !

((Object compiledMethodAt: #quem) = (Object compiledMethodAt: #quem)) printNl."


(LinkedList compiledMethodAt: #addLast:) inspect.
(CompiledMethod compiledMethodAt: #inspect) inspect.
(SmallInteger compiledMethodAt: #+) inspect.

(Stream compiledMethodAt: #next) methodSourceString printNl!
(LinkedList compiledMethodAt: #addLast:) methodSourceString printNl!

Smalltalk at: #quem put: (['foo' printNl. Processor yield ] newProcess)!
Smalltalk at: #proc2 put: (['process2' printNl. Processor yield. 
 'Hi again from proc 2' printNl. Processor yield ] newProcess)!
['process3' printNl. Processor yield ] fork!

quem resume.
proc2 resume!

'Yielding...' printNl.
Processor yield!

"proc2 terminate."
'Back to main' printNl.
Processor yield.

'Back to main from second yield' printNl.

Smalltalk at: #rambo
	  put: ([ :arg1 :arg2 | arg2 printNl". Processor yield" ]
	    	    newProcessWith: #('foo on you' 'and your mother'))!

rambo resume!
Processor yield!


ObjectMemory quit!

!ClassDescription methodsFor: 'debug'!

printClass
    | instVarNames instVars instVal |
    instanceVariables printNl.
    instVarNames := self instanceVariableString.
    instVars := (TokenStream on: instVarNames) contents.
    self printNl.
    1 to: instVars size do:
    	[ :i | '  ' print.
	       (instVars at: i) print.
	       ': ' print.
	       instVal := self instVarAt: i.
	       (instVal isKindOf: Dictionary)
    	    	   ifTrue: [ instVal printNl "'a ' print.
		    	     instVal class print.
		    	     ' with ' print.
		    	     instVal size print.
			     ' elements' printNl" ]
		   ifFalse: [ instVal printNl ] ]
! !

!Metaclass class methodsFor: 'basic'!

!

!Metaclass  methodsFor: 'basic'!

!

| newMeta |
newMeta := Metaclass subclassOf: Object class.
(newMeta class whichClassIncludesSelector: #new) printNl.
newMeta name: 'Rambo'
	environment: Smalltalk
    	subclassOf: Object
	instanceVariableNames: 'john paul  george  
ringo '
	variable: false
    	words: true
	pointers: true
    	classVariableNames: 'charlie davey'
	poolDictionaries: ''
    	category: ''
    	comment: 'no comment'

". newMeta print"!

Collection inspect!
Rambo inspect!
Rambo new inspect!

"Smalltalk system: 'mail jb'!
Smalltalk system: 'ls -lt  *.st'!"

"12500000000000000000000000000000000.0 print.

0.0625 print.
0.125 print.
0.25 print.
0.5 print.
0.12345678901234 print.

0.0 print.
1.0 print.
2.0 print.
3345678912345678.0 print!"

"Object
	defineCFunc: 'marli'
	withSelectorArgs: 'doMarli: anInteger'
	returning: #void
	args: #(#int).
nil doMarli: 3!"



"
| l |
    l := LinkedList new.
    l add: (Link new).
    l add: (Link new).
    l add: (Link new).
    l store
!"

"3.5 print. ' ' print!
3.5e5 print. ' ' print!"

"!Object methodsFor: 'test'!"

"testComp
    Object compile: (FileStream open: 'test.st' mode: 'r')"
"    Object compile: 'rambo [ ''Hi there'' print' ]"
"! !"

"nil testComp.
nil rambo!
"

| d |
Smalltalk monitor: true.
d := Date new.
10000 to: 10050 do:
    [ :i | d setDays: i.
    	   d storeString.
    	   "Character nl print" ]
. Smalltalk monitor: false
!

| s |
"Smalltalk monitor: true."
    s := Bag new.
    s add: #quem.
    s add: #zoneball.
    s add: #quem.
    s add: #juma withOccurrences: 20.
    s print.
    s store.
"    s add: #quem.
    s add: #juma."
"    s add: 12345.
    'after adding ' print."
"    s add: 'wont you please break that record' ."
"    s add: $c."
    s printOn: stdout.
    stdout nextPut: Character nl.
    s storeOn: stdout
". Smalltalk monitor: false"
!
"| f |
    f := FileStream open: 'foo.test' mode: 'w'.
    f nextPutAll: 'this is a test of your mother'.
    f nextPut: Character nl.
    f close
!

| f |
    f := FileStream open: 'foo.test' mode: 'r'.
    [ f atEnd ] whileFalse:
    	[ f next print ].
    f position: 0.
    [ f atEnd ] whileFalse:
    	[ f next print ].
    f close
!
"

!Set methodsFor: 'testing'!

printSet
    1 to: self basicSize do: [ :i | 'at ' print.
    	    	    	    	    i print.
				    (self basicAt: i) print. ]
!

findNilBefore: index
    "Finds the first nil element before index and returns the index of that
     nil.  If there is no nil element, index is returned."
    | size count i |
    count := size := self basicSize.
    i := index.
    [ count > 0 ]
    	whileTrue:
	    [ i := i - 2 \\ size + 1. "step backward w/wrap through elements"
    	      (self basicAt: i) isNil ifTrue: [ ^i ].
	      count := count - 1 ].
    ^index + 1
! !

ObjectMemory quit!

!Collection methodsFor: 'test'!

printSorted
    self asSortedCollection do:
    	[ :element | element print ]
! !

Smalltalk at: #BasicClassSelectors put: Class allSelectors!


!Behavior methodsFor: 'test'!

printInheritedSelectors
    | sels |
    sels := self allSelectors.
    sels removeAll: self selectors.
    sels printSorted
!

printNewSelectors
    | sels |
    sels := self allSelectors.
    sels removeAll: BasicClassSelectors.
    sels printSorted

! !

"Smalltalk monitor: true.
Class printInheritedSelectors.
Smalltalk monitor: false.
ObjectMemory quit!"

"Metaclass allInstancesDo: [ :inst | '------------' print.
    	    	    	    	    inst print.
    	    	    	    	    inst printNewSelectors.
				    '' print ] !"

| selectorSet newSelectors |
selectorSet := Set new.
Object withAllSubclasses do:
    [ :subclass | newSelectors := subclass selectors.
    	    	  '-----------------' print.
    	    	  subclass print.
		  newSelectors printSorted.
		  '' print.
		  selectorSet addAll: newSelectors ].
'****************' print.
'The set of selectors is...' print.
selectorSet size print.
selectorSet do: [ :elt | elt print ]
!

ObjectMemory quit!


(Object withAllSubclasses "asSortedCollection:
    [ :a :b | (a name isNil or: [ b name isNil ])
    	    	ifTrue: [ true ]
		ifFalse: [ a name <= b name ] ]")
    do:
	[ :subclass | 
    	    subclass class ~~ Metaclass
    	    	ifTrue: [ '------------------------------------------' print.
		    	  subclass print.
    		    	  'inherited selectors' print.
    			  subclass printInheritedSelectors.
			  '' print ]
    ]!
"
!Object methodsFor: 'test'!

printElements
    self do: [ :element | element print ]
!

"counter | i total |
    total := i := 0.
    [i <= self] whileTrue:
	[ total := total + i.
	  i := i + 1 ].
    ^total
!

timer | i |
    i := 0.
    [i < self] whileTrue: [ i := i + 1 ]
"

count2
    | sum |
    sum := 0.
    1 to: self do: [ :i | sum := sum + i ].
    ^sum
!

myTest
    ^12 factorial

! !

!Integer methodsFor: 'test'!

factorial
    self > 0 ifTrue: [ self * (self - 1) factorial ]
    	     ifFalse: [ ^self error: 'factorial of a small number' ]
! !

^Symbol allInstances size!

ObjectMemory quit!

"^Date yearAsDays: 1904!



1850 to: 2050 do:
    [ :year | year print.
    	      (Date leapYear: year) print ]!"

| s |
    s := WriteStream on: (String new: 0).
    s nextPutAll: 'name'.
    s tab.
    s nextPutAll: 'city'.
    s reset.
    s nextPutAll: 'foo'.
    s setToEnd.
    s nl.
    s nextPutAll: 'quem?'.
    s workingSize print.
    ^s contents
!




| s str|
    str := WriteStream on: (String new: 5).
    s := #(#foo #bar #baz #quem #juma #zoneball).
    s do: [ :sym | str nextPutAll: sym , ' ' ].
    ^str contents
"    s := s inject: '' into: [ :str :atom | str , atom , ' ' ].
    s size print.
    s grow.
    s size print.
    s print"
!

| t |
    t := #(#foo #bar #baz).
    t := t , #(#quem #juma).
    t do: [ :element | element print ]!


"
Smalltalk at: #children put: SortedCollection new!


^children add: #Joe!
^children add: #Bill!
^children add: #Alice!
^children printElements!
^children add: #Sam!
^(children sortBlock: [ :a :b | a > b ]) printElements!
^children add: #Henrietta!
^children printElements!
"
| t |
    t := SortedCollection new.
    t add: 'foo'.
    t add: 'bar'.
    t add: 'dinner'.
    t add: 'in'.
    t add: 'the'.
    t add: 'diner'.
    t add: 'nothing'.
    t add: 'could'.
    t add: 'be'.
    t add: 'finer'.
    "1 to: t size do: [ :i | i print. (t at: i ) print ]."
    t sortBlock: [ :a :b | a > b ].
    1 to: t size do: [ :i | i print. (t at: i ) print ].
!



600 to: 1000 do:
    [ :i | i print.
    	   i asObject print ]!


^(Bag with: #foo with: #foo ) occurrencesOf: #foo!


"
Smalltalk at: #Test put: Dictionary new.
Smalltalk at: #X put: 0!
X := Bag new!
^X occurrencesOf: 3!
^X add: 3!

Test at: #jeff put: 1.
Test at: #steve put: 5.
Test at: #jiz put: 99!
^Test at: #jeff!
^Test at: #steve!
^Test at: #jiz!


X := Test collect: [ :elt | elt * 2 ]!
^X occurrencesOf: 1!
^X occurrencesOf: 2!
^X occurrencesOf: 5!
^X occurrencesOf: 10!
^X occurrencesOf: 99!
^X occurrencesOf: 99*2!
^X size!
"
"
^Test at: #blockA put: [ 'this is a test' ]!
^Test at: #blockB put: [ 'hello from block b' ]!
^Test at: #juma put: 'hello jeff! !!'!
^Test size!
^Test at: #juma!

^(Test at: #blockB) value!
^(Test at: #blockA) value!

^Test removeKey: #juma!
^Test size!
^Test removeKey: #juma!
"

"^Test := Bag new!

^Test add: #quem!
^Test size!
^Test basicSize!
"

"
^Test := Set new!

^'test'!
^Test basicSize!

^Test findObjectIndex: #foo!
^Test species!

^Test add: #quem!
^Test add: #juma!

^Test size!
^Test grow!
^Test add: #juma2!
^Test add: #juma3!

^Test size!
^Test basicSize!

^Test findObjectIndex: #juma2!
^Test remove: #juma2!
^Test findObjectIndex: #juma2!
^Test basicAt: (Test findObjectIndex: #juma2)!
^Test size!
^Test occurrencesOf: #juma2!
^Test occurrencesOf: #juma3!
^Test remove: #juma2!"

"^3 * 4.0!

^Float pi!

^'QuemonYour:Mother:' asSymbol!

^3 zoneball!

^#FoobarOnYouBar asUppercase!

[]!

^[] value!

^3 count2!
^4 count2!"

"
!Object methodsFor: 'test'!

dictTest
    | d |
    d := Dictionary new.
    d at: #foo put: #bar.
    d at: #quem put: #juma.
    d at: #barf put: 'your mama'.
    ^d at self     
! !"



"Smalltalk at: #poolDict1 put: Dictionary new!
Smalltalk at: #poolDict2 put: Dictionary new!

poolDict1 at: #pd1foo put: 'foo'!
poolDict1 at: #pd1bar put: #bar!

poolDict2 at: #pd2baz put: 'bazola'!
poolDict2 at: #pd2barn put: #fred! 


Object subclass: #Rambo
	instanceVariableNames: 'foo bar'
	classVariableNames: 'guinea pigs'
	poolDictionaries: 'poolDict1'
	category: ''!

!Rambo methodsFor: 'test'!

xxx
   pd1foo := 3.
   ^pd1bar testMessage: pd2barn + pd2baz
!

ramboTest
    foo := 3.
    bar := 7.
    ^foo + bar
!

initPigs: guineaArg and: pigsArg
    guinea := guineaArg.
    pigs := pigsArg
!

foof
    ^foo
!

barf
    ^bar
!

returnGuinea
    ^guinea
!

returnPigs
    ^pigs

! !

Rambo subclass: #Rocky
	instanceVariableNames: 'quem juma'
	classVariableNames: ''
	poolDictionaries: 'poolDict2'
	category: ''!

!Rocky methodsFor: 'test'!

xxx
   pd1foo := 3.
   ^pd1bar testMessage: pd2barn + pd2baz
!

ramboTest
    foo := 12.
    bar := 3.
    ^foo + bar
!


quem: arg
    quem := arg
!

quem
    ^quem
!

juma: arg
   juma := arg
!

juma
    ^juma

! !
"

"Smalltalk at: #testVar put: Rambo new!"

"^#barf dictTest!
^#foo dictTest!
^#quem dictTest!"



"^2 arrayTest!"



"^nil atest2!"

"   ^$C = ('FUBAR' at: 3) !"

"^1000 counter !"

"^16rA + 16rA !

^$C !

^#foo:bar:baz: !
^'this is a test string
I wonder how this will print' !"

"100000 timer!"
	


"^3 < 4 ifTrue: [^#foobar] !"

"
!Boolean methodsFor: 'test'!
quem: bar juma: baz
    bar := #foon:barn:.
    baz := 3.
!

marli
    true when: [3 < (Smalltalk at: #foo)] do: #quem:bar:.
    Smalltalk at: #foo put: 3

! !

!String methodsFor: 'your mother'!
xxx: arg
    self < arg ifTrue: [^false].
    (self = arg and: [arg + 1 > 3]) ifTrue: [^#foo]
! !

"

"playing with dates!Date methodsFor: 'rambo'!

computeDateParts: aBlock
    | trialYearInteger yearInteger tempDays monthIndex daysInMonth offset |
    trialYearInteger := (days // 365).
    offset := (trialYearInteger // 4) - (trialYearInteger // 100) + (trialYearInteger // 400).
""yearInteger print. 
' Days: ' print. days print. 
' year ' print. (yearInteger * 365) print.
' offset ' print. offset printNl.""
    yearInteger := trialYearInteger.
    tempDays := days - (yearInteger * 365).
'>>> Days: ' print. tempDays print. 
' offset ' print. offset printNl.

    tempDays < offset
""    (days - offset) < (yearInteger * 365)""
    	ifTrue: [ yearInteger := yearInteger - 1 ]
	ifFalse: [ tempDays := tempDays - offset ].
""     
    yearInteger := (days - offset) // 365.
    yearInteger = trialYearInteger
    	ifTrue: [ tempDays := tempDays - offset ].""
    yearInteger := yearInteger + 1901.
    monthIndex := 1.
    [ monthIndex < 12
    	and: [ daysInMonth := Date daysInMonthIndex: monthIndex
	    	    	    	  forYear: yearInteger.
    	       tempDays >= daysInMonth ] ] whileTrue:
    	[ monthIndex := monthIndex + 1.
	  tempDays := tempDays - daysInMonth ].
    ^aBlock value: yearInteger value: monthIndex value: tempDays + 1
! !
"
