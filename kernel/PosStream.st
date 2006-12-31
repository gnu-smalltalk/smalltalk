"======================================================================
|
|   PositionableStream Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006
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

Stream subclass: #PositionableStream
       instanceVariableNames: 'collection ptr endPtr access'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Streams-Collections'
!

PositionableStream comment: 
'My instances represent streams where explicit positioning is permitted.
Thus, my streams act in a manner to normal disk files: you can read
or write sequentially, but also position the file to a particular place
whenever you choose.  Generally, you''ll want to use ReadStream, WriteStream
or ReadWriteStream instead of me to create and use streams.' !



!PositionableStream class methodsFor: 'instance creation'!

on: aCollection
    "Answer an instance of the receiver streaming on the
    whole contents of aCollection"
    self subclassResponsibility
!

on: aCollection from: firstIndex to: lastIndex
    "Answer an instance of the receiver streaming from
     the firstIndex-th item of aCollection to the lastIndex-th"
    ^self on: (aCollection copyFrom: firstIndex to: lastIndex)
! !



!PositionableStream methodsFor: 'accessing-reading'!

close
    "Disassociate a stream from its backing store."
    self flush.
    collection := nil.
    endPtr := nil.
    ptr := nil.
    access := nil
!

next
    "Answer the next item of the receiver.  Returns nil when at end of stream."

    | element |
    (access bitAnd: 1) = 0
    	ifTrue: [ ^self shouldNotImplement ].
    ptr > endPtr ifTrue: [ ^self pastEnd ].
    element := collection at: ptr.
    ptr := ptr + 1.
    ^element
!

peek
    "Returns the next element of the stream without moving the pointer.
    Returns nil when at end of stream."
    
    (access bitAnd: 1) = 0
    	ifTrue: [ ^self shouldNotImplement ].
    ptr > endPtr ifTrue: [ ^nil ].
    ^collection at: ptr
!

peekFor: anObject
    "Returns true and gobbles the next element from the stream of it is
    equal to anObject, returns false and doesn't gobble the next element
    if the next element is not equal to anObject."
    self atEnd ifTrue: [ ^false ].
    ^self next = anObject
    	ifTrue: [ true ]
    	ifFalse: [ self skip: -1. false ]
!

copyFrom: start to: end
    "Answer the data on which the receiver is streaming, from
     the start-th item to the end-th.  Note that this method is 0-based,
     unlike the one in Collection, because a Stream's #position method
     returns 0-based values."

    ^collection copyFrom: start + 1 to: end + 1
!

contents
    "Returns a collection of the same type that the stream accesses, up to 
    and including the final element."
    ^collection copyFrom: 1 to: endPtr
!

readStream
    "Answer a ReadStream on the same contents as the receiver"
    ^ReadStream on: collection from: 1 to: endPtr
!

reverseContents
    "Returns a collection of the same type that the stream accesses, up to 
    and including the final element, but in reverse order."
    | newCollection |
    newCollection := collection copyEmpty: endPtr.
    1 to: endPtr do:
	[ :i | newCollection at: i put: (collection at: endPtr - i + 1) ].
    ^newCollection
! !



!PositionableStream methodsFor: 'testing'!

atEnd
    "Answer whether the objects in the stream have reached an end"
    ^ptr > endPtr
!

basicAtEnd
    "Answer whether the objects in the stream have reached an end.
     This method must NOT be overridden."
    ^ptr > endPtr
!

isEmpty
    "Answer whether the stream has no objects"
    ^endPtr = 0
! !


!PositionableStream methodsFor: 'truncating'!

truncate
    "Truncate the receiver to the current position - only valid
     for writing streams"

    (access bitAnd: 2) = 0
	ifTrue: [ self shouldNotImplement ]
	ifFalse: [ endPtr := ptr - 1 ]
! !

!PositionableStream methodsFor: 'positioning'!

skipSeparators
    "Advance the receiver until we find a character that is not a
     separator.  Answer false if we reach the end of the stream,
     else answer true; in this case, sending #next will return the
     first non-separator character (possibly the same to which the
     stream pointed before #skipSeparators was sent)."
    | ch |
    [   (ch := self peek) isNil ifTrue: [^false].
        ch isSeparator ] whileTrue: [ self next ].

    ^true
!

position
    "Answer the current value of the stream pointer"
    ^ptr - 1
!

position: anInteger
    "Move the stream pointer to the anInteger-th object"
    (anInteger between: 0 and: endPtr)
	ifTrue: [ ptr := anInteger + 1 ]
	ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: ptr ]
!

basicPosition: anInteger
    "Move the stream pointer to the anInteger-th object"
    (anInteger between: 0 and: endPtr)
	ifTrue: [ ptr := anInteger + 1 ]
	ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: ptr ]
!

reset
    "Move the stream back to its first element. For write-only streams,
    the stream is truncated there."
    self position: 0
!

setToEnd
    "Move the current position to the end of the stream."
    ptr := endPtr + 1
!

size
    "Answer the size of data on which we are streaming."
    ^endPtr
!

isPositionable
    "Answer true if the stream supports moving backwards with #skip:."
    ^true
!

skip: anInteger
    "Move the current position by anInteger places, either forwards or
    backwards."
    self position: ((self position + anInteger max: 0) min: endPtr).
! !


!PositionableStream methodsFor: 'private'!

beReadOnly
    access := 1
!

beWriteOnly
    access := 2
!

beReadWrite
    access := 3
!

collection
    ^collection
!

status: aString
    "When working with a stream on strings, this method can be useful!
     Format of the output:
	'ABCDEFG'   aString
	   ^		    "
    Transcript
	print: (collection copyFrom: 1 to: endPtr);
	nextPutAll: '    ';
	nextPutAll: aString;
	nl;
	next: self position put: Character space;
	nextPut: $^;
	nl
! !


!PositionableStream methodsFor: 'class type methods'!

isExternalStream
    "We stream on a collection residing in the image, so answer false"
    ^false
!

species
    "The collections returned by #upTo: etc. are the same kind as
    those returned by the collection with methods such as #select:"
    ^collection species
! !
