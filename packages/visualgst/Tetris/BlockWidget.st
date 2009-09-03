"======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Gwenael Casaccio.
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

TetrisPieceWidget subclass: BlockWidget [

    drawOn: aCanvas [
	<category: 'drawing'>

	| linear |
        linear := Cairo.LinearGradient from: position to: (position x + size@ position y + size).
        linear addStopAt: 0 color: color.
        linear addStopAt: 1 color: Cairo.Color black.

        aCanvas
            fill: [ aCanvas rectangle: (position extent: size@size) ]
            with: linear
    ]
]
