"======================================================================
|
|   How can Sieve be missing?
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
	ifTrue: [ 1 ]
	ifFalse: [ 1 max: Smalltalk arguments first asInteger ].

    flags0 := Array new: 8192 withAll: true.

    n timesRepeat: [
        count := 0.
        flags := flags0 copy.
        2 to: 8192 do: [ :i |
            (flags at: i) ifTrue: [
	        i+i to: 8192 by: i do: [ :j | flags at: j put: false ].
	        count := count + 1 ]].
    ].

    ('Count: %1' % { count }) displayNl
]
