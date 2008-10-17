"======================================================================
|
|   Benchmark for hash tables (2)
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

Eval [
    n := Smalltalk arguments isEmpty
	ifTrue: [ 10 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

    hash1 := LookupTable new: 15000.
    0 to: 9999 do: [ :each |
	hash1 at: 'foo_', each printString put: each.
    ].

    hash2 := LookupTable new: 15000.
    n timesRepeat: [
        hash1 keysAndValuesDo: [ :k :v |
    	    hash2 at: k put: (hash2 at: k ifAbsent: [0]) + v ]].

    ('%1 %2 %3 %4' % {
	hash1 at: 'foo_1'.
	hash1 at: 'foo_9999'.
	hash2 at: 'foo_1'.
	hash2 at: 'foo_9999' }) displayNl
]
