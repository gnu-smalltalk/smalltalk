"======================================================================
|
|   Driver for the ANSI-compliancy tests
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2000  Free Software Foundation.
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

FloatANSITest isClass ifFalse: [ ObjectMemory quit: 1 ]!

Smalltalk arguments do: [ :each || results |
    results := (Smalltalk at: each asSymbol) suite run.
    Transcript showCr: ('%1: %2' % { each. results }).
    results failureCount > 0 ifTrue: [ results failures printNl ].
    results errorCount > 0 ifTrue: [ results errors printNl ].
    results correctCount < results runCount ifTrue: [ ObjectMemory quit: 1 ]
].

ObjectMemory quit!

