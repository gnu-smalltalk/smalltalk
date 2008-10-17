"======================================================================
|
|   Benchmark for floats
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003, 2007, 2008  Free Software Foundation.
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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"

Number extend [
    Last := 42.

    nextRandom [
	Last := Last * 3877 + 29573 rem: 139968.
	^self * Last asFloatD / 139968d
   ]
]

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 1000 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].
	
    n timesRepeat: [ 100d nextRandom ].
    ((100d nextRandom + 0.5d-9) printString copyFrom: 1 to: 11) displayNl
]
