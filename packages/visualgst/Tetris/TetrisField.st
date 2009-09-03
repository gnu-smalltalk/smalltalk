"======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: TetrisField [
    | rows currentPiece |
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisField class >> new [
	<category: 'instance creation'>

	^ self basicNew initialize
    ]

    at: point [
	<category: 'accessing'>

	^ (rows at: point y) at: point x
    ]

    at: point put: value [
	<category: 'accessing'>

	^ (rows at: point y) at: point x put: value
    ]

    initialize [
	<category: 'initializing'>
	
	rows := (1 to: 22) collect: [:each | ByteArray new: 10].
	rows do: [:each | self initializeLine: each].
	(rows at: 22) atAll: (1 to: 10) put: 1
    ]

    initializeLine: line [
	<category: 'initializing'>

	line
	    atAll: (1 to: 10) put: 0
    ]

    checkLine: y [
	<category: 'removing filled lines'>

	^ (rows at: y) allSatisfy: [:each | each ~~ 0]
    ]

    removeLines [
	<category: 'removing filled lines'>

	| removed lastLine firstLine |
	removed := 0.
	firstLine := self currentPiece y.
	lastLine := 21 min: firstLine + 3.
	lastLine - firstLine + 1 timesRepeat: 
		[(self checkLine: lastLine) 
		    ifTrue: 
			[removed := removed + 1.
			self removeLine: lastLine]
		    ifFalse: [lastLine := lastLine - 1]].
	^ removed
    ]

    removeLine: filledY [
	<category: 'removing filled lines'>

	| saved y shift line |
	saved := rows at: filledY.
	filledY to: 2
	    by: -1
	    do: [:each | rows at: each put: (rows at: each - 1)].
	self initializeLine: saved.
	rows at: 1 put: saved
    ]

    cementPiece [
	<category: 'piece'>

	self currentPiece cementOn: self
    ]

    dropPiece [
	<category: 'moving pieces'>

	[ self slidePiece ] whileTrue: []
    ]

    movePieceLeft [
	<category: 'moving pieces'>

	self currentPiece x: self currentPiece x - 1.
	^ self currentPiece moveInto: self
	    ifFail: [self currentPiece x: self currentPiece x + 1]
    ]

    movePieceRight [
	<category: 'moving pieces'>

	self currentPiece x: self currentPiece x + 1.
	^ self currentPiece moveInto: self
	    ifFail: [ self currentPiece x: self currentPiece x - 1 ]
    ]

    rotatePiece [
	<category: 'moving pieces'>

	self currentPiece rotate: 1.
	^ self currentPiece moveInto: self ifFail: [ self currentPiece rotate: 3 ]
    ]

    slidePiece [
	<category: 'moving pieces'>

	self currentPiece y: self currentPiece y + 1.
	^ self currentPiece moveInto: self
	    ifFail: [self currentPiece y: self currentPiece y - 1]
    ]

    currentPiece [
	<category: 'accessing piece variables'>

	^ currentPiece
    ]

    currentPiece: piece [
	<category: 'accessing piece variables'>

	currentPiece := piece.
	(self currentPiece)
	    x: 4;
	    y: 1.

	self currentPiece moveInto: self
            ifFail: [ ^ false ].
	^ true
    ]

    drawOn: aCanvas [
	<category: 'drawing'>

	1 to: 21 do: [ :y |
	    1 to: 10 do: [ :x |
		((rows at: y) at: x) ~= 0 ifTrue: [
		    BlockWidget new
			position: (50 + (x * 15))@(50 + (y * 15));
			size: 15;
			color: Cairo.Color white;
			drawOn: aCanvas ] ] ].
	self currentPiece drawOn: aCanvas
    ]
]

