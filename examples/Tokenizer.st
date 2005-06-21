"======================================================================
|
|   Generic tokenizer superclass.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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

FileStream fileIn: Directory kernel, '/../examples/PushBack.st'!

Stream subclass: #Tokenizer
       instanceVariableNames: 'stream line'
       classVariableNames: 'CR LF'
       poolDictionaries: ''
       category: 'Examples-Useful'!

!Tokenizer class methodsFor: 'initialization'!

initialize
    CR := Character cr.
    LF := Character nl
!

!Tokenizer class methodsFor: 'instance creation'!

on: aFileName
    ^self new init: (FileStream open: aFileName mode: 'r')
!

onStream: aStream
    ^self new init: aStream
! !

!Tokenizer methodsFor: 'accessing'!

isFileStream
    ^self stream isKindOf: FileStream
!

stream
    ^stream stream
! !

!Tokenizer methodsFor: 'stream compatibility'!

position
    ^stream position
!

close
    stream close
!

nextPut: notUsed
    self shouldNotImplement
!

next
    | ch tok |
    [ stream atEnd ifTrue: [ ^self atEndToken ].
      ch := self nextChar.
      tok := self tokenize: ch.
      tok isNil ] whileTrue: [ ].
    ^tok
!

atEnd
    ^stream atEnd
!

close
    stream close
! !

!Tokenizer methodsFor: 'parsing tokens'!

atEndToken
    ^nil
!

tokenize: ch
    "This must answer a token. The tokens' starting char is
     passed in ch"
    self subclassResponsibility
! !

!Tokenizer methodsFor: 'utility methods'!

line
    ^line
!

peekChar
    ^stream peek
!

peekChar: aChar
    | next |
    (next := stream next) == aChar ifTrue: [ ^true ].
    stream putBack: next.
    ^false
!

putBack: aChar
    stream putBack: aChar.
! !

!Tokenizer methodsFor: 'recording'!

nextChar
    | c |
    c := stream next.
    c == CR ifTrue: [ line := line + 1. stream peekFor: LF ].
    c == LF ifTrue: [ line := line + 1 ].
    ^c
! !


!Tokenizer methodsFor: 'private'!

init: aStream
    stream := PushBackStream on: aStream.
    line := 1.
! !

Tokenizer initialize!
