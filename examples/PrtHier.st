"======================================================================
|
|   Print out the class hierarchy.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,1999,2000 Free Software Foundation, Inc.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!Behavior methodsFor: 'demo'!

printHierarchy
    "I print my entire subclass hierarchy to standard out."
    self printSubclasses: 0    
! !

!Behavior methodsFor: 'private'!

printSubclasses: level
    "I print my name, and then all my subclasses, each indented according
     to its position in the hierarchy."
    | mySubclasses |
    self indentToLevel: level.
    Transcript nextPutAll: self name; nl.
    mySubclasses := self subclasses asSortedCollection:
    	    		[ :a :b | (a name isNil or: [ b name isNil ])
    	    	    	    	      ifTrue: [ true ]
		    	    	      ifFalse: [ a name <= b name ] ].
    mySubclasses do:
    	[ :subclass | subclass class ~~ Metaclass
	    	    	ifTrue: [ subclass printSubclasses: level + 1 ] ]
!

indentToLevel: level
    level timesRepeat:
    	[ Transcript next: (self hierarchyIndent) put: Character space ]
!

hierarchyIndent
    ^4
! !

Object printHierarchy!
