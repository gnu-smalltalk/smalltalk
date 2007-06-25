"======================================================================
|
|   Command-line parsing utility for Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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

Smalltalk arguments size < 1 ifTrue: [ ObjectMemory quit: 1 ].
Smalltalk arguments size = 1 ifTrue: [ ObjectMemory quit: 0 ].

"Usage: Getopt.st PATTERN [ OPTIONS ... ]"

Getopt
    parse: (Smalltalk arguments copyFrom: 2)
    with: (Smalltalk arguments first)
    do: [ :opt :arg || pat o a |
	o := opt ifNil: [ '' ].
	pat := o isString ifTrue: [ '--%1 %2' ] ifFalse: [ '-%1 %2' ].
	a := arg ifNil: [ '' ].
	(pat % { o. a }) displayNl ]
    ifError: [ 'ERROR' displayNl ]
