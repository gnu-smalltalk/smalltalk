"======================================================================
|
|   MessageDigest abstract class declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2005 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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

Object subclass: #MessageDigest
       instanceVariableNames: 'state'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!MessageDigest class methodsFor: 'instance creation'!

new: initialString
    ^self new nextPutAll: initialString; yourself
! !

!MessageDigest class methodsFor: 'checksumming'!

digestOf: aStringOrStream
    ^(self new: aStringOrStream) digest
!

hexDigestOf: aStringOrStream
    ^(self new: aStringOrStream) hexDigest
!

!MessageDigest methodsFor: 'checksumming'!

copy
    ^self deepCopy
!

partialDigest
    | s digest |
    s := state copy.
    digest := self digest.
    state := s.
    ^digest
!

digest
    self subclassResponsibility
!

partialHexDigest
    | s digest |
    s := state copy.
    digest := self hexDigest.
    state := s.
    ^digest
!

hexDigest
    | digest answer |
    digest := self digest.
    answer := String new: digest size * 2.
    digest keysAndValuesDo: [ :i :each |
	answer at: i + i - 1 put: (Character digitValue: each // 16).
	answer at: i + i put: (Character digitValue: each \\ 16)
    ].
    ^answer asLowercase
! !

!MessageDigest methodsFor: 'private'!

state
    ^state!

state: anObject
    state := anObject! !
