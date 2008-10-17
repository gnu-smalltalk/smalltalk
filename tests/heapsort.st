"======================================================================
|
|   Benchmark for array accessing and flow-control bytecodes
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

Array extend [

    heapSort [
	| j i rra l ir |
	ir := self size.
	l := self size // 2 + 1.
	[
		l > 1
			ifTrue: [ rra := self at: (l := l - 1) ]
			ifFalse: [
				rra := self at: ir.
				self at: ir put: (self at: 1).
				ir := ir - 1.
				ir = 1 ifTrue: [ self at: 1 put: rra. ^self ].
			].
		i := l.
		j := l * 2.
		[ j <= ir ] whileTrue: [
			(j < ir and: [ (self at: j) < (self at: j+1) ])
				ifTrue: [ j := j + 1 ].

			rra < (self at: j)
				ifTrue: [
					self at: i put: (self at: j).
					i := j. j := j + i ]
				ifFalse: [ j := ir + 1 ]].

		self at: i put: rra
	] repeat
   ]
]

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 1000 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].
	
    array := Array new: n.
    1 to: n do: [ :i | array at: i put: 1d nextRandom ].

    array heapSort.
    ((array last + 0.5d-10) printString copyFrom: 1 to: 12) displayNl
]
