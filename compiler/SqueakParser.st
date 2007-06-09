"======================================================================
|
|   Squeak input parser
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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


STFileInParser subclass: #SqueakFileInParser
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

!SqueakFileInParser methodsFor: 'accessing'!

evaluate: node
    "Convert some Squeak messages to GNU Smalltalk file-out syntax.
     This avoids that the STParsingDriver need to know about other
     dialects."
    | stmt |
    node statements size == 1 ifFalse: [ ^driver evaluate: node ].

    stmt := node statements first.
    stmt isMessage ifFalse: [ ^driver evaluate: node ].
    stmt selector == #addCategory: ifTrue: [ ^false ].
    stmt selector == #commentStamp:prior: ifTrue: [
	stmt arguments: { scanner nextRawChunk }.
	stmt selector: #comment: ].

    stmt selector == #methodsFor:stamp: ifTrue: [
	stmt arguments first value = 'as yet unclassified'
	    ifTrue: [ stmt arguments first token value: nil ].

	stmt arguments: { stmt arguments first }.
	stmt selector: #methodsFor: ].

    ^driver evaluate: node
! !

!SqueakFileInParser methodsFor: 'private-parsing'!

scannerClass
    "We need a special scanner to convert the double-bangs in strings
     to single bangs.  Unlike in GNU Smalltalk, all bangs must be
     `escaped' in Squeak."
    ^SqueakFileInScanner! !


STFileScanner subclass: #SqueakFileInScanner
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!SqueakFileInScanner methodsFor: 'accessing'!

scanLiteralString
    "In theory, this should also be applied to method comments, but the
     representation of comments in RBParseNode makes it more complicated;
     not a big deal."
    | val |
    val := super scanLiteralString.
    val value: (val value copyReplaceAll: '!!' with: '!').
    val value: (val value copyReplacing: 13 asCharacter withObject: 10 asCharacter).
    ^val!

scanSpecialCharacter
    "Treat ! specially, it is a binary operator in Squeak (if properly escaped).
     This actually fails on tokens like +!! which is the binary operator +!,
     but this are never used in practice."

    | val |
    currentCharacter == $!
	ifFalse: [^super scanSpecialCharacter].
    self step == $!
	ifFalse: [^RBSpecialCharacterToken value: $! start: tokenStart].

    buffer nextPut: $!.
    (characterType == #binary and: [currentCharacter ~~ $-]) ifTrue:
            [buffer nextPut: currentCharacter.
            self step].
    val := buffer contents.
    val := val asSymbol.
    ^RBBinarySelectorToken value: val start: tokenStart!

nextRawChunk
    "Return a raw chunk, converting all double exclamation marks to single.
     This is used for parsing Squeak class comments."

    buffer reset.
    [ currentCharacter == $! and: [self step ~~ $!] ]
	whileFalse:
            [buffer nextPut: currentCharacter.
            self step].

    self stripSeparators.
    ^RBLiteralToken
        value: buffer contents
        start: tokenStart! !
