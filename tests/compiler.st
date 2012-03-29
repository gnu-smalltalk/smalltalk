"======================================================================
|
|   Regression tests for the compiler
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2003, 2007, 2008, 2009 Free Software Foundation.
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
   thisContext currentLineInFile
       + 0
]

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

Eval [ '(111) 111-1111' phoneNumber ]

Eval [ (Object compile: 'foo [ <category: ''bar''> ^5 ]') methodCategory ]

Eval [
    a := Undeclared keys size.
    1 to: 100 do: [ :i | Object compile: 'a%1 [ ^A%1 ]' % {i} ].
    Undeclared keys size - a
]

!BugTest class methodsFor: 'bugs'!

pragma1
    <test>
!

pragma2
    <test: #abc>
!

pragma3
    <primitive: 100>
!

pragma4
    <primitive: 100>
    <test: #abc>
! !

Eval [
    (BugTest class >> #pragma1) attributes size
]
Eval [
    (BugTest class >> #pragma1) attributes first class
]
Eval [
    (BugTest class >> #pragma1) attributes first selector
]
Eval [
    (BugTest class >> #pragma1) attributes first arguments
]
Eval [
    (BugTest class >> #pragma2) attributes size
]
Eval [
    (BugTest class >> #pragma2) attributes first class
]
Eval [
    (BugTest class >> #pragma2) attributes first selector
]
Eval [
    (BugTest class >> #pragma2) attributes first arguments
]
Eval [
    (BugTest class >> #pragma3) attributes size
]
Eval [
    (BugTest class >> #pragma3) attributes first class
]
Eval [
    (BugTest class >> #pragma3) attributes first selector
]
Eval [
    (BugTest class >> #pragma3) attributes first arguments
]
Eval [
    (BugTest class >> #pragma4) attributes size
]

"Various errors in the recursive-descent parser"
!BugTest class methodsFor: 'bugs'!

c
    ^'No crashes'!

a
    ^#[]!

b
    ^{}!

"The lexer crashed on this because it returned a SYMBOL_LITERAL with
 -123 in the ival.  This gives a parse error..."

c
    #-123!

c
    <3 4>
    ^'foo'! !

"... this does not."
Eval [ #(#-123) size ]

Eval [ BugTest c ]

"Also used to crash."
Object subclass: A [
    B := C.
]

"Compiling a method should not capture the current temporaries dictionary."
Eval [
    a:=42.
    Object compile: 'gotcha [ "shouldn''t compile!" ^a ]'
]
Eval [ nil gotcha ]

"Regression test for a compiler bug.  Check that jump threading is
 performed correctly (or not performed at all) if the threaded jump
 requires extension bytes and the original one had none."

Number extend [
    inWords [
        | tens part1 part2 |
        
        ((self \\ 100) < 20 and: [(self \\ 100) > 10]) ifTrue: [
            part1 := ''.
            ((self \\ 100) = 19) ifTrue: [ part2 := 'nineteen'.  ].
        ] ifFalse: [
            ((self \\ 10) = 0) ifTrue: [
                part1 := ''.  ].
            ((self \\ 10) = 1) ifTrue: [
                part1 := 'one'.  ].
            ((self \\ 10) = 2) ifTrue: [
                part1 := 'two'.  ].
            ((self \\ 10) = 3) ifTrue: [
                part1 := 'three'.  ].
            ((self \\ 10) = 4) ifTrue: [
                part1 := 'four'.  ].
            ((self \\ 10) = 5) ifTrue: [
                part1 := 'five'.  ].
            ((self \\ 10) = 6) ifTrue: [
                part1 := 'six'.  ].
            ((self \\ 10) = 7) ifTrue: [
                part1 := 'seven'.  ].
            ((self \\ 10) = 8) ifTrue: [
                part1 := 'eight'.  ].
            ((self \\ 10) = 9) ifTrue: [
                part1 := 'nine'.  ].
            
            tens := tens - (tens \\ 10).
            ((tens \\ 100) = 10) ifTrue: [ part2 := 'ten'.  ].
            ((tens \\ 100) = 20) ifTrue: [ part2 := 'twenty'.  ].
            ((tens \\ 100) = 30) ifTrue: [ part2 := 'thirty'.  ].
            ((tens \\ 100) = 40) ifTrue: [ part2 := 'forty'.  ].
            ((tens \\ 100) = 50) ifTrue: [ part2 := 'fifty'.  ].
            ((tens \\ 100) = 60) ifTrue: [ part2 := 'sixty'.  ].
            ((tens \\ 100) = 70) ifTrue: [ part2 := 'seventy'.  ].
            ((tens \\ 100) = 80) ifTrue: [ part2 := 'eighty'.  ].
            ((tens \\ 100) = 90) ifTrue: [ part2 := 'ninety'.  ].
        ].
        
        ^part2, part1
    ]
]

"this has a jump of exactly 256 bytes, and was buggy at some point.
 reduced with delta, so the code does not totally make sense. :-) "
Object extend [
    buggy: packagesList test: aBoolean ifMissing: aBlock [
	| toBeLoaded featuresFound pending allPrereq allFeatures package name |
	featuresFound := Set withAll: Smalltalk.Features.
	[pending notEmpty] whileTrue: [
	    name := pending removeFirst.
	    (featuresFound includes: name) 
	        ifFalse: 
		    [package := self at: name ifAbsent: [^aBlock value: name].
		    allPrereq := package prerequisites asSet.
		    allFeatures := package features asSet.
		    (aBoolean and: [package test notNil]) ifTrue: [
		        allPrereq addAll: package test prerequisites.
		        allFeatures addAll: package test features].
		    (allPrereq noneSatisfy: [ :each | pending includes: each ])
		        ifFalse: [
			    pending addLast: name]
			ifTrue: [
			    pending removeAll: allPrereq ifAbsent: [:doesNotMatter | ].
			    pending removeAll: allFeatures ifAbsent: [:doesNotMatter | ].
			    allPrereq removeAll: allFeatures ifAbsent: [:doesNotMatter | ].
			    featuresFound addAll: allFeatures.
			    featuresFound add: name.
			    toBeLoaded addFirst: name.
			    pending addAllLast: allPrereq]]].
    ]
]

Eval [ 19 inWords ]

"test that blocks defined with ##() work properly"
Object extend [
    block [ ^##([ 'abc' asUppercase ]) ]
]

Eval [ nil block value ]

"test the limited support for unary minus in literals"
Eval [ 2-2 ]
Eval [ -2 + 2 ]
Eval [ -16r33 + 16r33 ]		"Blue Book actually says 16r-33"
Eval [ 16r33 + 16r-33 ]		"Blue Book actually says 16r-33"
Eval [ -12345678901234567890123 + 12345678901234567890123 ]
Eval [ -123.0 + 123.0 ]
Eval [ -123s3 printString ]

"test for errors -- we still fail on -16r-0, but that's insane..."
Eval [ Object compile: 'a [ -16r-33 ]' ]
Eval [ Object compile: 'a [ -16r-33.0 ]' ]
Eval [ Object compile: 'a [ -16r-33s3 ]' ]
Eval [ Object compile: 'a [ -16r-12345678901234567890123 ]' ]

"test that streams are correctly associated to FileSegments"
Eval [
    (Object >> #addDependent:) descriptor sourceCode class
]
Eval [
    'Object extend [ a [ ^5 ] ]' readStream fileIn.
    (Object >> #a) descriptor sourceCode class
]

"Test scoped method within class block."
Object subclass: A [
    A class [
        A class >> a [] "valid"
        A >> a []       "invalid"
    ]
]

Eval [A class >> #a]
Eval [A >> #a]

"Test referring to an undeclared global in a method attribute.
 This is unpleasant when outside a binding constant, but
 more or less necessary."
A extend [
    test1 [ <cCall: 'getArgv' returning: #{UndeclaredGlobal} arguments: #(#int)> ]
]

Eval [ Undeclared includesKey: #UndeclaredGlobal ]

"Fix referring to self, as well as previous class variables,
 in class variable declarations"
Object subclass: A [
    B := name.
    C := self.
    D := C name
]
Eval [ A.B ]
Eval [ A.C ]
Eval [ A.D ]

"Test referring to the current class from a pragma."
Behavior extend [
    debug: anObject [ anObject printNl ]
]

Namespace current: Subspace [
    Object subclass: B [
        <debug: #(#{B})>
    ]
]

"Test referring to an invalid binding"
Eval [ ##(#{ABC}) ]
Eval [ #((#{ABC})) ]

"Check that lookahead tokens are not discarded after compiling a doit."
Eval ['''abc'' printNl ''def'' printNl' readStream fileIn]
