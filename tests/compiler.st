"======================================================================
|
|   Regression tests for the compiler
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #BugTest
	instanceVariableNames: 'value '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Regression testing'!

!Object methodsFor: 'bugs'!

a: value
    ^[ undefVariable ]! !

!BugTest methodsFor: 'bugs'!

bugHere
    "The scope for the above method isn't popped and a
     bogus error is returned here."
    value := 42! !

"Here is another one.  In this case the temporaries inside the block
 were not counted correctly and were overwritten by push bytecodes."

!String methodsFor: 'matching'!

phoneNumber
    | s attempted |
    attempted := false.
    self keysAndValuesDo: [ :k :each |
	| skip ok ch |
	ok := false.
	each = $( ifTrue: [
	    ok := self size - k >= 13 and: [ (self at: k + 4) = $) ].
	    skip := 1.
	].
	each isDigit ifTrue: [
	    ok := self size - k >= 11.
	    skip := 0.
	].
	ok := ok and: [ attempted not ].
	attempted := skip notNil.
	ok ifTrue: [
	    skip + k to: skip + 2 + k do: [ :i |
		ok := ok and: [ (self at: i) isDigit ]
	    ].
	    (skip * 2 + k + 4) to: (skip * 2 + k + 6) do: [ :i |
		ok := ok and: [ (self at: i) isDigit ]
	    ].
	    (skip * 2 + k + 8) to: (skip * 2 + k + 11) do: [ :i |
		ok := ok and: [ (self at: i) isDigit ]
	    ].
	    ch := self at: skip * 2 + k + 7.
	    ok := ok and: [ (ch = $ ) | (ch = $-) ].
	    ok ifTrue: [ ^{
		self copyFrom: k + skip to: k + skip + 2.
		self copyFrom: skip * 2 + k + 4 to: skip * 2 + k + 6.
		self copyFrom: skip * 2 + k + 8 to: skip * 2 + k + 11.
	    } ]
	].
    ].
    ^nil
! !

'(111) 111-1111' phoneNumber!
