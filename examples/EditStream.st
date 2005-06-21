"======================================================================
|
|   `Splitting' stream, useful for editors and the like.
|
|
 ======================================================================"


"======================================================================
|
| Written by Ulf Dambacher.
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


Stream subclass: #EditorStream
       instanceVariableNames: 'head headEnd tail tailStart overwrite'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

" headEnd points behind the last valid member of head.
  tailStart points to the first valid member of tail!
"

!EditorStream class methodsFor: 'all'!
on: aString
   ^self new initOn: aString
! !

!EditorStream methodsFor: 'initializing'!

initOn: aColl
    tail _ aColl.
    head _ aColl species new: 10.
    headEnd _ tailStart _ 1.
    overwrite _ false.
!
insert
    overwrite _ false.
!
overwrite
    overwrite _ true.
! !

!EditorStream methodsFor: 'positioning'!

position
    ^headEnd
!

position: anInt
    anInt < headEnd
	ifTrue: [ self copyHeadToTail: (headEnd - anInt) ]
	ifFalse:[ self copyTailToHead: (anInt - headEnd)]
!

skip: anInt
    anInt < 0
	ifTrue: [ self copyHeadToTail: anInt negated ]
	ifFalse:[ self copyTailToHead: anInt ]
!

toEnd
    self copyTailToHead: tail size - tailStart + 1.
!

toPos1
    self copyHeadToTail: headEnd.
! !

!EditorStream methodsFor: 'access'!
previous
    self skip: -1.
    ^ self peek
!
next
    ^ (self next:1) at: 1.
!

next: anInt
    | old |
    self atEnd ifTrue:  [ self error: 'no object to next!'].
    old _ headEnd.
    self skip: anInt.
    ^ head copyFrom: old to: headEnd - 1
!

nextPut: anObject
    headEnd > head size ifTrue: [head grow].
    head at: headEnd put: anObject.
    headEnd _ headEnd + 1.
    overwrite ifTrue: [ tailStart  _ (tailStart min: tail size) + 1].
!

remove: anInt
    anInt < 0
	ifTrue: [ headEnd _ headEnd + anInt max: 1 ]
	ifFalse: [ tailStart _ tailStart + anInt min: tail size +1 ].
!

peek
    self atEnd ifTrue: [self error: 'no object to peek!'].
    ^tail at: tailStart
! !

!EditorStream methodsFor: 'testing'!

atEnd
    ^ tailStart > tail size
! !

!EditorStream methodsFor: 'contents access'!

head
    ^ head copyFrom: 1 to: headEnd - 1
!

tail
    ^ tail copyFrom: tailStart to: tail size
!

contents
    ^ self head , self tail
!

size
"    ^self contents size"
    ^ headEnd "- 1 " + tail size - tailStart " + 1 ".
! !

!EditorStream methodsFor: 'collection like access'!

at: anInt
    ^self at: anInt ifAbsent: [ ^self error: 'index out of range'].
!

at: anInt ifAbsent: aBlock
    (anInt between: 1 and: self size) ifFalse: [^aBlock value].
    anInt < headEnd
	ifTrue: [ ^head at: anInt ]
	ifFalse: [ ^ tail at: (anInt - headEnd + tailStart)]
!

inject: aValue into: aBlock
    1 to: self size do: [ :i | aValue _ aBlock value: aValue
				    value: (self at: i)].
    ^aValue
! !

!EditorStream methodsFor: 'private'!
" 
oldcopyHeadToTail: anInt
    [ (tailStart > 1 and: [headEnd > 1]) and: [anInt > 0]]
	whileTrue: [ tailStart _ tailStart - 1.
		     headEnd _ headEnd - 1.
		     tail at: tailStart put: (head at: headEnd).
		     anInt _ anInt - 1].
    anInt > 0 ifTrue:
	[ tail _ (head copyFrom: (headEnd - anInt max: 1) 
		       to: headEnd - 1),tail.
	  headEnd _ headEnd - anInt max: 1]
!

oldcopyTailToHead: anInt
    [ tailStart <= tail size and: [anInt > 0]] 
	whileTrue:
	    [ headEnd > head size ifTrue: [head grow].
	      head at: headEnd put: (tail at: tailStart).
	      tailStart _ tailStart +1.
	      headEnd _ headEnd + 1.
	      anInt _ anInt - 1 ].
!
"

copyHeadToTail: anInt
    | coll i j |
    anInt _ anInt min: headEnd - 1.
    tailStart <= anInt
	ifTrue: [ i _ anInt + 10. " 10 more spaces... "
		  j _ tail size - tailStart + 1.
		  coll _ tail species new: i + j.
		  coll replaceFrom: i + 1 to: i + j
		       with: tail startingAt: tailStart.
		  tail _ coll.
		  tailStart _ i + 1].
    tail replaceFrom: tailStart - anInt  to: tailStart - 1
	 with: head startingAt: headEnd - anInt.
    headEnd _ headEnd - anInt.
    tailStart _ tailStart - anInt.
!    

copyTailToHead: anInt    
    | coll i |
    anInt _ anInt min: tail size - tailStart + 1.
    headEnd + anInt > head size
	ifTrue: [ i _ anInt + 10.
		  coll _ head species new: i + headEnd - 1.
		  coll replaceFrom: 1 to: headEnd - 1
		       with: head startingAt: 1.
		  head _ coll ].
    head replaceFrom: headEnd to: headEnd - 1 + anInt
	 with: tail startingAt: tailStart.
    tailStart _ tailStart + anInt.
    headEnd _ headEnd + anInt.
! !
