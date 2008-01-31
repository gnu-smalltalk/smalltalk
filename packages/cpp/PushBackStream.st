"======================================================================
|
|   A stream wrapper with unlimited push back capabilites
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


StreamWrapper subclass: #PushBackStream
	   instanceVariableNames: 'queue '
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Examples-Useful'
!

PushBackStream comment:
'LIFO pushback capability on top of ReadStreams'
!


!PushBackStream methodsFor: 'accessing' !

next
    | char |
    queue size > 0 
	ifTrue: [ ^queue removeFirst ].
    ^self atEnd
	ifTrue: [ nil ]
	ifFalse: [ super next ]
!

peek
    self atEnd ifTrue: [ ^nil ].
    ^queue size == 0 
	ifTrue: [ self putBack: self next ]
	ifFalse: [ queue at: 1 ]
!

position
    ^super position - queue size
!

position: pos
    super position: pos.
    queue := OrderedCollection new
!

stream
    ^stream
!

atEnd
    ^(queue size == 0) and: [ super atEnd ]
!

putBack: anElement
    ^queue addFirst: anElement
! !






!PushBackStream methodsFor: 'private'!

init: aStream
    super init: aStream.
    queue _ OrderedCollection new.
! !
