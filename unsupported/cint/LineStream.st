"======================================================================
|
|   Line at a time input handling
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

"
|     Change Log
| ============================================================================
| Author       Date       Change 
| sbb	      8 Aug 93	  Cloned from TokenStream
"


FileStream fileIn: 'StreamStack.st' ifMissing: #StreamStack!

"??? Should this be ReadStream as the parent?"
PushBackStream subclass: #LineStream
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries:''
       category: nil
!


LineStream comment:
'I am not a typical part of the Smalltalk kernel class hierarchy.
I operate on a stream of characters and return distinct strings which 
represent individual lines in the input stream.  I collapse adjacent lines
which are terminated by a line termination string (currently hard coded
to be "\").' !


!LineStream class methodsFor: 'instance creation'!

on: aString
    ^self onStream: (ReadStream on: aString)
!

onStream: aStream
    ^self new setStream: aStream
! !



!LineStream methodsFor: 'basic'!

next
    | char tokStream result |
    self atEnd ifTrue: [ ^nil ]. "has the nice side effect of skipping
    	    	    	    	  leading white space."
    tokStream _ WriteStream on: (String new: 1).
    [
	[ char _ stream peek.
	  (char notNil) and: [ char ~= Character nl ] ]
	    whileTrue: [ tokStream nextPut: (stream next) ].
	char == Character nl
	    ifTrue: [ stream next "gobble it" ].
	result _ tokStream contents.
	(result size > 0) and: [ (result at: result size) == $\ ]
	    ] whileTrue: 
		[ tokStream skip: -1 ].
    
 "'yielding' print. tokStream contents printNl."
    ^tokStream contents
!

atEnd
    | char |
    [ char _ stream peek.
      char isNil ifTrue: [ ^true ].
      char isSeparator ] whileTrue: [ stream next ].

    ^false
!

do: aBlock
    [ self atEnd ] whileFalse:
    	[ aBlock value: self next ]
!

contents
    | arrayStream |
    arrayStream _ WriteStream on: (Array new: 0).
    self do: [ :aToken | arrayStream nextPut: aToken ].
    ^arrayStream contents
! !



!LineStream methodsFor: 'stream stack manipulation'!

pushStream: aStream
    stream pushStream: aStream
! !




!LineStream methodsFor: 'private'!

setStream: aStream
    | streamStack |
    streamStack _ StreamStack new.
    streamStack pushStream: aStream.
    super init: streamStack
! !

"
| s |
     s _ LineStream onStream: (FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r').
    s _ LineStream onStream: (FileStream open: '/usr/openwin/include/X11/Xutil.h' mode: 'r').
    s printNl.
    s do: [ :line | line printNl. ].
!
"
