"======================================================================
|
|   Benchmark for matrices
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

Array extend [
    Array class >> newMatrix: rows columns: cols [
        | count mx row |
        count := 1.
        mx := self new: rows.
        1 to: rows do: [ :i |
            row := mx at: i put: (Array new: cols).
            1 to: cols do: [ :j |
	        row at: j put: count.
	        count := count + 1
	    ].
        ].
        ^mx
    ]

    atXY: coord [
        ^(self at: coord x) at: coord y
    ]
    
    mmult: m2 [
        | rows cols terms val mx row myRow |
        rows := self size.
        terms := m2 size.
        cols := m2 first size.
        mx := Array new: rows.
        1 to: rows do: [ :i |
            row := mx at: i put: (Array new: cols).
	    myRow := self at: i.
            1 to: cols do: [ :j |
	        val := 0.
	        1 to: terms do: [ :k |
	            val := val + ((myRow at: k) * ((m2 at: k) at: j) bitAnd: 16r3FFF_FFFF) ].
	        row at: j put: val.
	    ].
        ].
        ^mx
    ]
]

Eval [
    | m1 m2 mm size n |
    n := Smalltalk arguments isEmpty
	ifTrue: [ 1 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

    size := 30.
    m1 := Array newMatrix: size columns: size.
    m2 := Array newMatrix: size columns: size.
    n timesRepeat: [ mm := m1 mmult: m2 ].
    ('%1 %2 %3 %4' % {
	mm atXY: 1@1.
        mm atXY: 3@4.
	mm atXY: 4@3.
        mm atXY: 5@5 }) displayNl
]
