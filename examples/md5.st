"======================================================================
|
|   MD5 module declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2005 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #MD5
       instanceVariableNames: 'state'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!MD5 methodsFor: 'C call-outs'!

newState
    <cCall: 'MD5AllocOOP' returning: #smalltalk args: #()>
!

combine: input size: len into: context
    <cCall: 'MD5Update' returning: #void args: #(#byteArray #int #byteArrayOut)>
!

finalize: state in: digest
    <cCall: 'MD5Final' returning: #void args: #(#byteArray #byteArrayOut)>
! !

!MD5 class methodsFor: 'instance creation'!

new
    ^self basicNew initialize
!

new: initialString
    ^self basicNew initialize; nextPutAll: initialString; yourself
! !

!MD5 class methodsFor: 'checksumming'!

digestOf: aStringOrStream
    ^(self new: aStringOrStream) digest
!

hexDigestOf: aStringOrStream
    ^(self new: aStringOrStream) hexDigest
!

!MD5 methodsFor: 'initialization'!

initialize
    state := self newState
! !

!MD5 methodsFor: 'checksumming'!

copy
    ^self deepCopy
!

nextPut: char
    self combine: (String with: char) size: 1 into: state
!

nextPutAll: aStringOrStream
    | buffer n |
    (aStringOrStream isKindOf: String)
	ifTrue: [
	    self
		combine: aStringOrStream
		size: aStringOrStream size
		into: state
	]
	ifFalse: [
	    buffer := aStringOrStream species new: 1024.
	    n := 0.
	    aStringOrStream do: [ :each |
		n := n + 1.
		buffer at: n put: each.
		n = 1024 ifTrue: [
		    self combine: buffer size: n into: state.
		    n := 0
		]
	    ].
	    self combine: buffer size: n into: state.
	]
!

partialDigest
    ^self digestFor: state copy
!

digest
    ^self digestFor: state
!

partialHexDigest
    ^self hexDigestFor: state copy
!

hexDigest
    ^self hexDigestFor: state
! !

!MD5 methodsFor: 'private'!

digestFor: aState
    | answer |
    answer := ByteArray new: 16.
    self finalize: aState in: answer.
    ^answer
!

hexDigestFor: aState
    | digest answer |
    digest := self digestFor: aState.
    answer := String new: 32.
    digest keysAndValuesDo: [ :i :each |
	answer at: i + i - 1 put: (Character digitValue: each // 16).
	answer at: i + i put: (Character digitValue: each \\ 16)
    ].
    ^answer asLowercase
! !
