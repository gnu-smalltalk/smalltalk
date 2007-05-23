"======================================================================
|
|   Token stream Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2007
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


Stream subclass: #TokenStream
       instanceVariableNames: 'charStream'
       classVariableNames: ''
       poolDictionaries:''
       category: 'Streams-Collections'
!

TokenStream comment:
'I operate on a stream of characters and return distinct whitespace-delimited
groups of characters; I am used to parse the parameters of class-creation
methods.

Basically, I parse off whitespace separated tokens as substrings and
return them (next).  If the entire contents of the string are requested,
I return them as an Array containing the individual strings.'!



!TokenStream class methodsFor: 'instance creation'!

on: aString
    "Answer a TokenStream working on aString"
    ^self onStream: (ReadStream on: aString)
!

onStream: aStream
    "Answer a TokenStream working on the collection on which aStream
    is in turn streaming."
    ^self new setStream: aStream
! !



!TokenStream methodsFor: 'basic'!

next
    "Answer a new whitespace-separated token from the input stream"
    | char tokStream |
    self atEnd ifTrue: [ ^nil ]. "has the nice side effect of skipping
    	    	    	    	  leading white space."
    tokStream := WriteStream on: (String new: 1).
    [ char := charStream peek.
      (char notNil) and: [ (char isSeparator) not ] ]
	whileTrue: [ tokStream nextPut: (charStream next) ].
    ^tokStream contents
!

atEnd
    "Answer whether the input stream has no more tokens."
    | char |
    [ char := charStream peek.
      char isNil ] whileFalse:
    	[ (char isSeparator) ifFalse: [ ^false ].
	 charStream next ].
    ^true
! !



!TokenStream methodsFor: 'write methods'!

nextPut: anObject
    self shouldNotImplement
! !



!TokenStream methodsFor: 'private'!

setStream: aStream
    charStream := aStream.
! !
