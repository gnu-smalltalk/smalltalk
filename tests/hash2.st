"======================================================================
|
|   Benchmark for hash tables (2)
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003  Free Software Foundation.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
|
 ======================================================================"

| hash1 hash2 i n |

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

('%1 %2 %3 %4' bindWith: (hash1 at: 'foo_1')
	with: (hash1 at: 'foo_9999')
	with: (hash2 at: 'foo_1')
	with: (hash2 at: 'foo_9999')) displayNl!
