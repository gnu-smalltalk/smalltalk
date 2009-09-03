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

TetrisPiece subclass: TetrisPieceL [
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceL class >> piece [
	<category: 'pieces'>

	^#( #( #(1 0 0 0)
	       #(1 0 0 0)
	       #(1 1 0 0)
	       #(0 0 0 0)) 
	    #( #(1 1 1 0)
	       #(1 0 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 0 0)
	       #(0 1 0 0)
	       #(0 1 0 0)
	       #(0 0 0 0))
	    #( #(0 0 1 0)
	       #(1 1 1 0)
	       #(0 0 0 0)
	       #(0 0 0 0)))
    ]

    TetrisPieceL class >> color [
	<category: 'pieces'>

	^ Cairo.Color r: 0.74 g: 0.71 b: 0.42 "DarkKhaki"
    ]
]

