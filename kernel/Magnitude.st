"======================================================================
|
|   Magnitude Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001
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


Object subclass: #Magnitude
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Data types'
!

Magnitude comment: 
'I am an abstract class.  My objects represent things that are discrete and 
map to a number line.  My instances can be compared with < and >.' !


!Magnitude methodsFor: 'basic'!

"Relational operators.  '==', '~=', '~~' are inherited from Object"

= aMagnitude
    "Answer whether the receiver is equal to aMagnitude"
    self subclassResponsibility
!

< aMagnitude
    "Answer whether the receiver is less than aMagnitude"
    self subclassResponsibility
!

> aMagnitude
    "Answer whether the receiver is greater than aMagnitude"
    ^aMagnitude < self
!

<= aMagnitude
    "Answer whether the receiver is less than or equal to aMagnitude"
    ^(aMagnitude < self) not
!

>= aMagnitude
    "Answer whether the receiver is greater than or equal to aMagnitude"
    ^(self < aMagnitude) not
! !



!Magnitude methodsFor: 'misc methods'!

between: min and: max
    "Returns true if object is inclusively between min and max."
    ^(self >= min) and: [ self <= max ]
!

min: aMagnitude
    "Returns the least object between the receiver and aMagnitude"
    ^self < aMagnitude ifTrue: [ self ]
    	    	      ifFalse: [ aMagnitude ]
!

max: aMagnitude
    "Returns the greatest object between the receiver and aMagnitude"
    ^self > aMagnitude ifTrue: [ self ]
    	    	      ifFalse: [ aMagnitude ]
! !

