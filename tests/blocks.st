"======================================================================
|
|   Test out block operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2007, 2008  Free Software Foundation.
| Written by Steve Byrne and Paolo Bonzini
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

Eval [ [45] ]			"should return a block"

Eval [ [^#quem] value ]		"should return #quem"

Eval [ ['foo'] value ]		"should return 'foo'"

Eval [ [:i | i] value: 'juma' ]	"should return 'juma'"

Eval [ [:i :j| j] value: 12 value: 17 ] 	"should return 17"

Object extend [

    blockTest1 [
        [#foo]
    ]

    blockTest2 [
        [^#foo]
    ]

    blockTest3 [
        ^[#bar]
    ]

    blockTest4 [
        ^[^#bar]
    ]

    blockTest5: arg [
        ^[arg]
    ]

    blockTest6: arg [
        ^[:i | arg at: i]
    ]

    blockTest7: arg [
        | temp |
        temp := (arg at: 4) + 8.
        ^[temp]
    ]

    blockTest8: which [
        | first second |
        first := nil blockTest7: #('one' #two 3.0 4 $5).
        second := nil blockTest7: #("You are[,] number" 'six' #seven 8.0 9 $A).
        which ifTrue: [ ^first value ]
	      ifFalse: [ ^second value]
    ]

"Implements a 'closure'!!!  Smalltalk is AMAZING!!!"
    blockTest9: initialValue [
        | counter |
        counter := initialValue.
        ^[:incr | counter := counter + incr. 
                  counter]
    ]

    "Implements a REAL 'closure'!!!  GNU Smalltalk is AMAZING!!!"
    blockTest10 [
        | counter |
        counter := 1.
        "If blocks were not real closures, variable would be 1 the
         second time the block was called and hence it would not
         be modified.
         Instead if blocks are closures, variable is still nil the
         second time the block is evaluated, and is initialized to
         two."
        ^[   | variable |
             variable isNil ifTrue: [ variable := counter ].
             counter := counter + 1.
             variable
        ]
    ]

    blockTest11: initialValue [
        ^[^initialValue]
    ]
]

Eval [ nil blockTest1 ]		"should return nil"

Eval [ nil blockTest2 ]		"should return nil"

Eval [ nil blockTest3 ]		"should return a BlockClosure"
Eval [ nil blockTest3 value ]		"should return #bar"

Eval [ nil blockTest4 value ]		"should issue an error, we're returning to
				 a non-existent context"

Eval [ (nil blockTest5: 'Smalltalk!') value ]
				"should return 'Smalltalk!'"

Eval [ (nil blockTest6: #('one' #two 3.0 4 $5)) value: 2 ]
				"should return #two"

Eval [ (nil blockTest7: #('you' #are #number 6)) value ]
				"should return 14"

Eval [ nil blockTest8: true ]		"should return 12"
Eval [ nil blockTest8: false ]		"should return 17"

"Create a block with the initial value of 2"
Eval [ Smalltalk at: #testBlock put: (nil blockTest9: 2) ]

Eval [ testBlock value: 3 ]		"should return 5"
Eval [ testBlock value: 6 ]		"should return 11"
Eval [ testBlock value: 2 ]		"should return 13"

Eval [ Smalltalk at: #testBlock put: (nil blockTest10) ]

Eval [ testBlock value ]		"should return 1"
Eval [ testBlock value ]		"should return 2 (1 if blocks aren't closures)"

"And this is even more amazing!!!"
Eval [
    | array |
    array := (1 to: 10) collect: [ :each | [each] ].
    ^array inject: 0 into: [ :sum :each | sum + each value ]	"should get 55"
]


Eval [ (nil blockTest11: 3) value ]	"should be invalid; we're returning to non-
					 existent parent"

"Various tests on #cull:cull:cull: and friends."
Eval [   [] cull: 1     ]
Eval [   [] cull: 1 cull: 2     ]
Eval [   [] cull: 1 cull: 2 cull: 3    ]

Eval [   [:a |a] cull: 1     ]
Eval [   [:a |a] cull: 1 cull: 2     ]
Eval [   [:a |a] cull: 1 cull: 2 cull: 3    ]

Eval [   [:a :b |a] cull: 1     ]
Eval [   [:a :b |a] cull: 1 cull: 2   ]
Eval [   [:a :b |a] cull: 1 cull: 2 cull: 3   ]
Eval [   [:a :b |b] cull: 1 cull: 2    ]
Eval [   [:a :b |b] cull: 1 cull: 2 cull: 3    ]

Eval [   [:a :b :c |a] cull: 1 cull: 2    ]
Eval [   [:a :b :c |a] cull: 1 cull: 2 cull: 3    ]
Eval [   [:a :b :c |b] cull: 1 cull: 2 cull: 3    ]
Eval [   [:a :b :c |c] cull: 1 cull: 2 cull: 3    ]
