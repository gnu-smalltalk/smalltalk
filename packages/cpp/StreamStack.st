"======================================================================
|
|   Stack of streams object.
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



Stream subclass: #StreamStack
       instanceVariableNames: 'stack'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


StreamStack comment:
'I hold a stack of open streams.  Elements are read from the most recently
pushed stream, until that reaches end of stream, at which point it is closed
and the next most recently pushed stream is read from.  When all the
streams have been exhausted, my atEnd method returns true.'!

!StreamStack class methodsFor: 'stack creation'!

new
    ^super new init
! !


!StreamStack methodsFor: 'pushstream operations'!

next
    | char |
    self atEnd
	ifTrue: [ ^nil ]
	ifFalse: [ ^self topStream next ].
!

peek
    self atEnd
	ifTrue: [ ^nil ]
	ifFalse: [ ^self topStream peek ].
!

atEnd
    self popFinishedStreams.
    ^self hasStreams not
!

close
    " ??? Not sure whether just the top should be closed or all"
    '$$$ Attempting to close stream stack' printNl.
    Smalltalk backtrace.
    [ self hasStreams ]
	whileTrue: [ self popStream ]
! !


!StreamStack methodsFor: 'stack manipulation'!

pushStream: aStream
    stack addFirst: aStream.
!

topStream
    ^stack at: 1
!

popStream
    self topStream close.
    stack removeFirst.
!

hasStreams
    ^stack size > 0
!

popFinishedStreams
    [ self hasStreams and: [ self topStream atEnd ]]
	whileTrue: [ self popStream ]
! !

!StreamStack methodsFor: 'hacks'!

peekChar
    ^self topStream peekChar
!

nextLine
    ^self topStream nextLine
! !



!StreamStack methodsFor: 'private'!

init
    stack _ OrderedCollection new.
! !
