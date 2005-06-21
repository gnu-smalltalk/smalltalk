"======================================================================
|
|   Test out block operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999  Free Software Foundation.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

[45]!		"should return nil"

^[45]!			"should return a block"

[^#quem] value!		"should return #quem"

^['foo'] value!		"should return 'foo'"

^[:i | i] value: 'juma'!	"should return 'juma'"

^[:i :j| j] value: 12 value: 17! 	"should return 17"

!Object methodsFor: 'testing'!

blockTest1
    [#foo]
!

blockTest2
    [^#foo]
!

blockTest3
    ^[#bar]
!

blockTest4
    ^[^#bar]
!

blockTest5: arg
    ^[arg]
!

blockTest6: arg
    ^[:i | arg at: i]
!

blockTest7: arg
    | temp |
    temp := (arg at: 4) + 8.
    ^[temp]
!

blockTest8: which
    | first second |
    first := nil blockTest7: #('one' #two 3.0 4 $5).
    second := nil blockTest7: #("You are[,] number" 'six' #seven 8.0 9 $A).
    which ifTrue: [ ^first value ]
	  ifFalse: [ ^second value]
!

"Implements a 'closure'!!!  Smalltalk is AMAZING!!!"
blockTest9: initialValue
    | counter |
    counter := initialValue.
    ^[:incr | counter := counter + incr. 
              counter]
!

"Implements a REAL 'closure'!!!  GNU Smalltalk is AMAZING!!!"
blockTest10
    | counter |
    counter := 1.
    "If blocks were not real closures, variable would be 1 the
     second time the block was called and hence it would not
     be modified.
     Instead if blocks are closures, variable is still nil the
     second time the block is evaluated, and is initialized to
     two.  eh eh eh!!"
    ^[   | variable |
         variable isNil ifTrue: [ variable := counter ].
         counter := counter + 1.
         variable
    ]
!

blockTest11: initialValue
    ^[^initialValue]

! !

^nil blockTest1!		"should return nil"

^nil blockTest2!		"should return nil"

^nil blockTest3!		"should return a BlockClosure"
^nil blockTest3 value!		"should return #bar"

^nil blockTest4 value!		"should issue an error, we're returning to
				 a non-existent context"

^(nil blockTest5: 'Smalltalk!') value!
				"should return 'Smalltalk!'"

^(nil blockTest6: #('one' #two 3.0 4 $5)) value: 2!
				"should return #two"

^(nil blockTest7: #('you' #are #number 6)) value!
				"should return 14"

^nil blockTest8: true!		"should return 12"
^nil blockTest8: false!		"should return 17"

"Create a block with the initial value of 2"
Smalltalk at: #testBlock put: (nil blockTest9: 2)!

^testBlock value: 3!		"should return 5"
^testBlock value: 6!		"should return 11"
^testBlock value: 2!		"should return 13"

Smalltalk at: #testBlock put: (nil blockTest10)!

^testBlock value!		"should return 1"
^testBlock value!		"should return 2 (1 if blocks aren't closures)"

"And this is even more amazing!!!"
| array |
array := (1 to: 10) collect: [ :each | [each] ].
^array inject: 0 into: [ :sum :each | sum + each value ]!	"should get 55"

^(nil blockTest11: 3) value!	"should be invalid; we're returning to non-
				 existent parent"

