"======================================================================
|
|   Smalltalk eight queens
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

"That's how a *real* Smalltalker solves the eight queens' problem: with
 four classes (one is for amazons)!!"

Object subclass: #NullChessPiece
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Classic'!

NullChessPiece subclass: #ChessPiece
    instanceVariableNames: 'row column neighbor rows'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Classic'!
! !

ChessPiece subclass: #Rook
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Classic'!
! !

"From the code's point of view, Amazon and Queen could subclass directly from
 ChessPiece, but it is more cool this way... ;-)"

Rook subclass: #Queen
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Classic'!
! !

Queen subclass: #Amazon
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Classic'!
! !


!NullChessPiece methodsFor: 'queens'!

move
    "Move the queen so that it is not menaced, backtracking if necessary.
     Answer whether a position can be found.
     If the null queen is asked to advance, the search tree has been walked
     entirely - so return false."
    ^false
!

menaces: test
    "Answer whether a queen is menaced in the given position by the queens
     up to and including the receiver. The null queen does not menace
     anything."
    ^false
!

do: aBlock
    "Evaluate aBlock passing all the remaining solutions"
    | result |
    [ result := self next. result notNil ] whileTrue: [
	aBlock value: result
    ]
!

result
    "Answer all the queens' rows, up to and including the receiver"
    ^OrderedCollection new
!

next
    "Answer a solution, or nil if there aren't anymore"
    ^self move
	ifTrue: [ self result ]
	ifFalse: [ nil ]
! !

!ChessPiece class methodsFor: 'testing'!

test: side
    | line n |
    (line := String new: side * 2 + 1)
	atAll: (1 to: side * 2 + 1 by: 2) put: $|;
	atAll: (2 to: side * 2 + 1 by: 2) put: $_.

    n := 0.
    (self board: side) do: [ :result |
	n := n + 1.
	Transcript
	    space;
	    next: side * 2 - 1 put: $_;
	    nl.

	result do: [:x |
    	    line at: x + x put: $*.
    	    Transcript nextPutAll: line; nl.
    	    line at: x + x put: $_.
	].
	Transcript nl.
    ].
    Transcript nl.
    ^n! !

!ChessPiece class methodsFor: 'instance creation'!

board: n
    "Answer a ChessPiece which will return results for a chessboard of side n"
    ^(1 to: n) inject: NullChessPiece new into: [ :neighbor :column |
	self new
	    setColumn: column
	    rows: n
	    neighbor: neighbor
    ]
! !

!ChessPiece methodsFor: 'private'!

setColumn: aNumber rows: n neighbor: aChessPiece
    "Initialize the receiver to work on column aNumber of a chessboard of
     side n, having aChessPiece as a neighbor"
    column := aNumber.
    rows := n.
    neighbor := aChessPiece.
    row := 0.
    
    "Put all the queens but the last in some place where they are safe. The
     last will be requested by sending #next"
    self neighbor move.
    ^self
!

advance
    "Move the receiver one row further if possible, else backtrack and move
     to the first row. Answer whether there was a safe position for the
     neighbor (in the first case, the neighbor was already in a safe position,
     so answer true!)"
    ^row = rows
	ifTrue: [ row := 1. self neighbor move ]
	ifFalse: [ row := row + 1. true ].
!

row
    ^row
!

column
    ^column
!

neighbor
    ^neighbor
! !

!ChessPiece methodsFor: 'inherited'!

menaces: test
    "Answer whether the receiver or any of the pieces above it menace the
     `test' piece if it stays where its #row and #column methods say.
     This method will test if the receiver itself menaces the tested
     piece and if not will delegate the choice to the neighbor."
    self subclassResponsibility
!

move
    "Here and in #advance is where the search really takes place.
     We advance the queen to the next cell; if the edge has been reached,
     #advance takes care of backtracking by sending #move to the neighbor
     (which in turn could backtrack).  If the queen is safe there, return
     true; else we advance the queen once more and check again.
     Sooner or later every queen will be aligned on the right edge and each
     one will be ask its neighbor to advance.  So the first queen will send
     #move to the NullChessPiece, the NullChessPiece will answer false, and
     all the invocations of #move will in turn answer false, terminating the
     search."
    [   self advance ifFalse: [ ^false ].
	self neighbor menaces: self
    ] whileTrue: [ ].
    ^true
!

result
    ^self neighbor result
	addLast: row;
	yourself
! !



!Rook methodsFor: 'inherited'!

menaces: test
    "Answer whether the receiver or any of the pieces above it menace the
     `test' piece if it stays where its #row and #column methods say."

    (test row - self row) abs = 0	ifTrue: [ ^true ].
    ^self neighbor menaces: test
! !



!Queen methodsFor: 'inherited'!

menaces: test
    "Answer whether the receiver or any of the pieces above it menace the
     `test' piece if it stays where its #row and #column methods say."

    | columnDifference rowDifference |
    columnDifference := (test column - self column) abs.
    rowDifference := (test row - self row) abs.

    rowDifference = 0			ifTrue: [ ^true ].
    rowDifference = columnDifference	ifTrue: [ ^true ].

    ^self neighbor menaces: test
! !



!Amazon methodsFor: 'inherited'!

menaces: test
    "Answer whether the receiver or any of the pieces above it menace the
     `test' piece if it stays where its #row and #column methods say."

    | columnDifference rowDifference |
    columnDifference := (test column - self column) abs.
    rowDifference := (test row - self row) abs.

    rowDifference	 = 0		    ifTrue: [ ^true ].
    rowDifference	 = columnDifference ifTrue: [ ^true ].
    rowDifference * 2    = columnDifference ifTrue: [ ^true ].
    columnDifference * 2 = rowDifference    ifTrue: [ ^true ].

    ^self neighbor menaces: test
! !

"	EVALUATE THIS:		"	"RESULT	"

"	^Rook test: 3!		"	"6	"
"	^Rook test: 4!		"	"24	"
"	^Rook test: 5!		"	"120	"
"	^Rook test: 6!		"	"720	"

"	^Queen test: 3!		"	"0	"
"	^Queen test: 4!		"	"2	"
"	^Queen test: 8!		"	"92	"

"	^Amazon test: 8!	"	"0	"
"	^Amazon test: 10!	"	"4	"

"does the sequence for rooks remind you of something?..."
