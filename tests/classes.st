"======================================================================
|
|   Test the class hierarchy
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2007, 2008  Free Software Foundation.
| Written by Steve Byrne
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

Eval [ Array new: 5 ]

Eval [ Array ]

Eval [ Metaclass ]	"should be Metaclass"
Eval [ Metaclass class ]
Eval [ Metaclass class class ]	"should be Metaclass, since the metaclass of metaclass
				 is a metaclass"
Eval [ Object ]
Eval [ Object class ]		"should be Object class"
Eval [ Object class class ] 	"should be MetaClass"

Eval [ nil ]
Eval [ nil class ]

Eval [ true ]
Eval [ true class ]


"Test creating classes at runtime

I apologize for the apparent lack of professionalism in the choice
of variable and method names here."

Eval [
    Object subclass: #Rambo
	instanceVariableNames: 'foo bar'
	classVariableNames: 'guinea pigs'
	poolDictionaries: ''
	category: ''
]

!Rambo methodsFor: 'test'!

"Assign some instance variables and return a result"
ramboTest
    foo := 3.
    bar := 7.
    ^foo + bar
!

"Assign to class variables"
initPigs: guineaArg and: pigsArg
    guinea := guineaArg.
    pigs := pigsArg
!


"inspect instance variables"

foof
    ^foo
!

barf
    ^bar
!


"inspect class variables"

returnGuinea
    ^guinea
!

returnPigs
    ^pigs

! !



Eval [ Smalltalk at: #testVar put: (Rambo new) ]

Eval [ testVar foof ]			"should be nil (it hasn't been initialized)"
Eval [ testVar barf ]			"should be nil (it hasn't been initialized)"
Eval [ testVar returnGuinea ]		"should be nil (it hasn't been initialized)"
Eval [ testVar returnPigs ]		"should be nil (it hasn't been initialized)"
Eval [ Rambo new returnPigs ]		"should be nil"
Eval [ Rambo new returnGuinea ]	"should be nil"

Eval [ testVar ramboTest ]		"should be 10"

Eval [ testVar barf ]			"should now be set to 7"

Eval [ testVar foof ]			"should new be set to 3"

Eval [ testVar initPigs: 'squeeky' and: 'junior' ]
				"nil is returned, we just set some global
				 variables"

Eval [ testVar returnPigs ]		"should return 'junior'"
Eval [ testVar returnGuinea ]		"should return 'squeeky'"

"Test that class variables really affect all instances"
Eval [ Rambo new returnPigs ]		"all instances now return 'junior'"
Eval [ Rambo new returnGuinea ]	"all instances now return 'squeeky'"



"Create a subclass of a created class to test variable and method inheritance"

Rambo subclass: #Rocky
	instanceVariableNames: 'quem juma'
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

!Rocky methodsFor: 'test'!

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

Eval [ Rocky new returnGuinea ]	"should return 'squeeky' by inheritance"
Eval [ Rocky new returnPigs ]	"should return 'junior' by inheritance"

Eval [ Rocky new quem ]		"should return nil (not initialized)"
Eval [ Rocky new juma ]		"should return nil (not initialized)"

"Test overriding of methods"
Eval [ (testVar := Rocky new) ramboTest ]		"should return 15, and set some inst vars"

"Set the instance variables"
testVar quem: 'zoneball'.	
testVar juma: #theJumaSymbol!

Eval [ testVar foof ]			"should return 12"
Eval [ testVar barf ]			"should return 3"
Eval [ testVar quem ]			"should return 'zoneball'"
Eval [ testVar juma ]			"should return #theJumaSymbol"

"Test setting class variables from subclass"
Eval [ (Rocky new) initPigs: 'frisky' and: 'radar' ]
				"should return instance of Rocky"

"+++ work in tests involving Dudley (Milkdud) and Speedy too+++"

"Test subclass access to class variables"
Eval [ Rocky new returnGuinea ]	"should return 'frisky'"
Eval [ Rocky new returnPigs ]		"should return 'radar'"

"Test class access to class variables that were modified from subclass"
Eval [ Rambo new returnGuinea ]	"should return 'frisky'"
Eval [ Rambo new returnPigs ]		"should return 'radar'"

"Make sure that the existing instance also sees the change in class vars"
Eval [ testVar returnPigs ]		"should return 'radar'"



"test of class instance varialbes"

Eval [ Rambo class instanceVariableNames: 'fred' ]

!Rambo class methodsFor: 'testing'!

put: x
    fred := x.
!

get
    ^fred
! !

Eval [ 			Rambo get ]
Eval [ Rambo put: 5.	Rambo get ]
Eval [ 			Rocky get ]
Eval [ Rocky put: 15.	Rambo get ]
Eval [ 			Rocky get ]

"Test out parsing bad instance variable names"
Eval [ Rambo instanceVariableNames: 'd99ogABCRblammo 9whammo loser! dogbert++' ]
Eval [ Rambo instanceVariableNames: 'dog!,blammo whammo? loser! dogbert++' ]

"Test mutation"

Eval [
    (Object subclass: #AB)
        instanceVariableNames: 'a'.
    (AB subclass: #C)
        instanceVariableNames: 'c';
        createGetMethod: 'c';
        createSetMethod: 'c'.

    cObj := C new.
    cObj c: 34.
    Smalltalk at: #TestObj put: cObj.
    ^C instSize
]

Eval [
    ^TestObj c
]

Eval [
    ^TestObj instVarAt: 2
]

Eval [
    AB
        instanceVariableNames: 'a b';
        createGetMethod: 'b';
        createSetMethod: 'b'.
    ^C instSize
]

Eval [
    ^TestObj c
]

Eval [
    ^TestObj instVarAt: 3
]

Eval [
    TestObj b: 12.
    AB instanceVariableNames: 'b'.
    ^C instSize
]

Eval [
    ^TestObj b
]

Eval [
    ^TestObj instVarAt: 1
]

Eval [
    ^TestObj c
]

Eval [
    ^TestObj instVarAt: 2
]

Eval [
    AB instanceVariableNames: 'b a'.
    ^C instSize
]

Eval [
    ^TestObj b
]

Eval [
    ^TestObj instVarAt: 1
]

Eval [
    ^TestObj c
]

Eval [
    ^TestObj instVarAt: 3
]
