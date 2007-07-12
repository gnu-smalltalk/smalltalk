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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
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

!Object methodsFor: 'aaa'!

a1 ##(Undeclared keys size). ^A1!
a2 ##(Undeclared keys size). ^A2!
a3 ##(Undeclared keys size). ^A3!
a4 ##(Undeclared keys size). ^A4!
a5 ##(Undeclared keys size). ^A5!
a6 ##(Undeclared keys size). ^A6!
a7 ##(Undeclared keys size). ^A7!
a8 ##(Undeclared keys size). ^A8!
a9 ##(Undeclared keys size). ^A9!
a10 ##(Undeclared keys size). ^A10!
a11 ##(Undeclared keys size). ^A11!
a12 ##(Undeclared keys size). ^A12!
a13 ##(Undeclared keys size). ^A13!
a14 ##(Undeclared keys size). ^A14!
a15 ##(Undeclared keys size). ^A15!
a16 ##(Undeclared keys size). ^A16!
a17 ##(Undeclared keys size). ^A17!
a18 ##(Undeclared keys size). ^A18!
a19 ##(Undeclared keys size). ^A19!
a20 ##(Undeclared keys size). ^A20!
a21 ##(Undeclared keys size). ^A21!
a22 ##(Undeclared keys size). ^A22!
a23 ##(Undeclared keys size). ^A23!
a24 ##(Undeclared keys size). ^A24!
a25 ##(Undeclared keys size). ^A25!
a26 ##(Undeclared keys size). ^A26!
a27 ##(Undeclared keys size). ^A27!
a28 ##(Undeclared keys size). ^A28!
a29 ##(Undeclared keys size). ^A29!
a30 ##(Undeclared keys size). ^A30!
a31 ##(Undeclared keys size). ^A31!
a32 ##(Undeclared keys size). ^A32!
a33 ##(Undeclared keys size). ^A33!
a34 ##(Undeclared keys size). ^A34!
a35 ##(Undeclared keys size). ^A35!
a36 ##(Undeclared keys size). ^A36!
a37 ##(Undeclared keys size). ^A37!
a38 ##(Undeclared keys size). ^A38!
a39 ##(Undeclared keys size). ^A39!
a40 ##(Undeclared keys size). ^A40!
a41 ##(Undeclared keys size). ^A41!
a42 ##(Undeclared keys size). ^A42!
a43 ##(Undeclared keys size). ^A43!
a44 ##(Undeclared keys size). ^A44!
a45 ##(Undeclared keys size). ^A45!
a46 ##(Undeclared keys size). ^A46!
a47 ##(Undeclared keys size). ^A47!
a48 ##(Undeclared keys size). ^A48!
a49 ##(Undeclared keys size). ^A49!
a50 ##(Undeclared keys size). ^A50!
a51 ##(Undeclared keys size). ^A51!
a52 ##(Undeclared keys size). ^A52!
a53 ##(Undeclared keys size). ^A53!
a54 ##(Undeclared keys size). ^A54!
a55 ##(Undeclared keys size). ^A55!
a56 ##(Undeclared keys size). ^A56!
a57 ##(Undeclared keys size). ^A57!
a58 ##(Undeclared keys size). ^A58!
a59 ##(Undeclared keys size). ^A59!
a60 ##(Undeclared keys size). ^A60!
a61 ##(Undeclared keys size). ^A61!
a62 ##(Undeclared keys size). ^A62!
a63 ##(Undeclared keys size). ^A63!
a64 ##(Undeclared keys size). ^A64!
a65 ##(Undeclared keys size). ^A65!
a66 ##(Undeclared keys size). ^A66!
a67 ##(Undeclared keys size). ^A67!
a68 ##(Undeclared keys size). ^A68!
a69 ##(Undeclared keys size). ^A69!
a70 ##(Undeclared keys size). ^A70!
a71 ##(Undeclared keys size). ^A71!
a72 ##(Undeclared keys size). ^A72!
a73 ##(Undeclared keys size). ^A73!
a74 ##(Undeclared keys size). ^A74!
a75 ##(Undeclared keys size). ^A75!
a76 ##(Undeclared keys size). ^A76!
a77 ##(Undeclared keys size). ^A77!
a78 ##(Undeclared keys size). ^A78!
a79 ##(Undeclared keys size). ^A79!
a80 ##(Undeclared keys size). ^A80!
a81 ##(Undeclared keys size). ^A81!
a82 ##(Undeclared keys size). ^A82!
a83 ##(Undeclared keys size). ^A83!
a84 ##(Undeclared keys size). ^A84!
a85 ##(Undeclared keys size). ^A85!
a86 ##(Undeclared keys size). ^A86!
a87 ##(Undeclared keys size). ^A87!
a88 ##(Undeclared keys size). ^A88!
a89 ##(Undeclared keys size). ^A89!
a90 ##(Undeclared keys size). ^A90!
a91 ##(Undeclared keys size). ^A91!
a92 ##(Undeclared keys size). ^A92!
a93 ##(Undeclared keys size). ^A93!
a94 ##(Undeclared keys size). ^A94!
a95 ##(Undeclared keys size). ^A95!
a96 ##(Undeclared keys size). ^A96!
a97 ##(Undeclared keys size). ^A97!
a98 ##(Undeclared keys size). ^A98!
a99 ##(Undeclared keys size). ^A99!
a100 ##(Undeclared keys size). ^A100! !

Undeclared keys size!

"Various errors in the recursive-descent parser"
!BugTest class methodsFor: 'bugs'!

c
    ^'No crashes'!

a
    ^#[]!

b
    ^{}!

c
    <3 4>
    ^'foo'! !

^BugTest c!

"The lexer crashed on this because it returned a SYMBOL_LITERAL with
 -123 in the ival.  This gives a parse error..."
^#-123!

"... this does not."
^#(#-123) size!
