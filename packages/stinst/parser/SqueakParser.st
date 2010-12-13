"======================================================================
|
|   Squeak input parser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



STFileInParser subclass: SqueakFileInParser [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    evaluate: node [
	"Convert some Squeak messages to GNU Smalltalk file-out syntax.
	 This avoids that the STParsingDriver need to know about other
	 dialects."

	<category: 'accessing'>
	| stmt |
	node statements size == 1 ifFalse: [^super evaluate: node].
	stmt := node statements first.
        stmt isReturn ifTrue: [ stmt := stmt value ].
	stmt isMessage ifFalse: [^super evaluate: node].
	stmt selector == #addCategory: ifTrue: [^false].
	stmt selector == #commentStamp:prior: 
	    ifTrue: 
		[stmt arguments: {RBLiteralNode new literalToken: scanner nextRawChunk}.
		stmt selector: #comment:].
	stmt selector == #methodsFor:stamp: 
	    ifTrue: 
		[stmt arguments first value = 'as yet unclassified' 
		    ifTrue: [stmt arguments first token value: nil].
		stmt arguments: {stmt arguments first}.
		stmt selector: #methodsFor:].
	^super evaluate: node
    ]

    scannerClass [
	"We need a special scanner to convert the double-bangs in strings
	 to single bangs.  Unlike in GNU Smalltalk, all bangs must be
	 `escaped' in Squeak."

	<category: 'private-parsing'>
	^SqueakFileInScanner
    ]
]



STFileScanner subclass: SqueakFileInScanner [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    on: aStream [
	<category: 'accessing'>
	super on: aStream.
	classificationTable := classificationTable copy.
	classificationTable at: $! value put: #binary
    ]

    scanLiteralString [
	"In theory, this should also be applied to method comments, but the
	 representation of comments in RBParseNode makes it more complicated;
	 not a big deal."

	<category: 'accessing'>
	| val |
	val := super scanLiteralString.
	val value: (val value copyReplaceAll: '!!' with: '!').
	val 
	    value: (val value copyReplacing: 13 asCharacter withObject: 10 asCharacter).
	^val
    ]

    scanLiteralCharacter [
	"Also treat ! specially here."

	<category: 'accessing'>
	| val |
	val := super scanLiteralCharacter.
	val value = $! ifTrue: [self step].
	^val
    ]

    scanBinary: aClass [
	"Treat ! specially, it is a binary operator in Squeak (if properly
	 escaped)."

        <category: 'private-scanning'>
        | val |
	currentCharacter == $! ifTrue: [
	    self step == $! 
	        ifFalse: [^RBSpecialCharacterToken value: $! start: tokenStart]].

        buffer nextPut: currentCharacter.
        self step.
        (characterType == #binary and: [currentCharacter ~~ $-])
            ifTrue:
		[currentCharacter == $!
		    ifTrue:
			[self step == $!
			    ifTrue: [
				buffer nextPut: $!.
				self step]
			    ifFalse: [
				stream skip: -1.
				currentCharacter := $!.
				characterType := #binary]]
		    ifFalse:
	                [buffer nextPut: currentCharacter.
	                self step]].
	[characterType == #binary]
		whileTrue: [
		buffer nextPut: currentCharacter.
		self step].

        val := buffer contents.
        val := val asSymbol.
        ^aClass value: val start: tokenStart
    ]

    nextRawChunk [
	"Return a raw chunk, converting all double exclamation marks to single.
	 This is used for parsing Squeak class comments."

	<category: 'accessing'>
	buffer reset.
	[currentCharacter == $! and: [self step ~~ $!]] whileFalse: 
		[buffer nextPut: currentCharacter.
		self step].
	self stripSeparators.
	^RBLiteralToken value: buffer contents start: tokenStart
    ]
]

