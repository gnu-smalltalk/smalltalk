"======================================================================
|
|   Test the array routines
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2007, 2008  Free Software Foundation.
| Written by Steve Byrne
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

Object extend [

    arrayConstTest1 [
        | a |
        a := #(#foo #bar 'quem').
        ^a
    ]

    arrayConstTest2 [
        | a |
        a := #(#foo #bar 'quem').
        ^a class
    ]

    arrayConstTest3 [
        | a |
        a := #(#foo #bar 'quem').
        ^a size
    ]

    arrayConstTest4 [
        | a |
        a := #(#foo (#a #sub #array) #bar 'quem' 3.4 1 $C #barn:yard:owl: #baz).
        ^a class
    ]

    arrayConstSubscriptTest [
        | a |
        a := #(#foo (#a #sub #array) #bar 'quem' 3.4 1 $C #barn:yard:owl: #baz).
        ^a at: self
    ]

    arrayTrueFalseNilTest [
        | a |
        a := #(true #true false #false nil #nil).
        a do: [ :each | each class printNl ]
    ]

    newArray1 [
        | a |
        a := Array new: 10.
        ^a class
    ]

    newArray2 [
        | a |
        a := Array new: 10.
        a at: self put: self.
        ^a at: self
    ]
]

Eval [ nil arrayConstTest1 ]

Eval [ nil arrayConstTest2 ]
 
Eval [ nil arrayConstTest3 ]

Eval [ nil arrayConstTest4 ]

Eval [ 1 arrayConstSubscriptTest ]
Eval [ 2 arrayConstSubscriptTest ]
Eval [ 3 arrayConstSubscriptTest ]
Eval [ 4 arrayConstSubscriptTest ]
Eval [ 5 arrayConstSubscriptTest ]
Eval [ 6 arrayConstSubscriptTest ]
Eval [ 7 arrayConstSubscriptTest ]
Eval [ 8 arrayConstSubscriptTest ]
Eval [ 9 arrayConstSubscriptTest ]

Eval [ nil newArray1 ]

Eval [ 1 newArray2 ]
Eval [ 5 newArray2 ]
Eval [ 10 newArray2 ]

Eval [ nil arrayTrueFalseNilTest ]

Eval [ ByteArray with: -1 ]
Eval [ ByteArray with: 0 ]
Eval [ ByteArray with: 255 ]
Eval [ ByteArray with: 256 ]
Eval [ WordArray with: (-1 bitShift: 64) ]
Eval [ WordArray with: -1 ]
Eval [ WordArray with: 0 ]
Eval [ WordArray with: 255 ]
Eval [ WordArray with: 256 ]
Eval [ WordArray with: (1 bitShift: 64) ]

"-----------------"

"used to trigger a failure in the verifier"
Eval [ {{}} printString ]

"-----------------"

"This test used to fail because #removeAtIndex: was not implemented
 in SortedCollection."

Eval [
   n4 := 4->2. n5 := 5->3. n6 := 6->3.
   n7 := 7->2. n8 := 8->1. n9 := 9->8.
   n10 := 10->8. n12 := 12->1.

   sc := SortedCollection new: 10.
   sc sortBlock: [ :a :b |
       a value < b value
	   or: [ a value = b value and: [ a key <= b key ] ] ].

   sc addAll: { n8. n12. n4. n7. n5. n6. n9. n10 }.
   sc remove: n10.
   sc remove: n8.
   sc add: n8.
   sc printNl
]

"--------------"

"Test for memmove semantics of #replaceFrom:to:with:startingAt:"

Eval [
    | a |
    (a := #(1 2 3 4 5) copy) replaceFrom: 2 to: 4 with: a startingAt: 1.
    a printNl.
    (a := #(1 2 3 4 5) copy) replaceFrom: 1 to: 3 with: a startingAt: 2.
    a printNl.

    (a := 'abcde' copy) replaceFrom: 2 to: 4 with: a startingAt: 1.
    a printNl.
    (a := 'abcde' copy) replaceFrom: 1 to: 3 with: a startingAt: 2.
    a printNl.
]

"--------------"

"This was wrong due to an off-by-one error in SortedCollection>>#percolateUp"

Eval [
    it := SortedCollection new.
    it addAll: #(1 2 3 7 9 10 11).
    it removeLast.
    it add: 6.
    it add: 8.
    it removeLast. "<<< the bug happened here, the heap was inconsistent!"
    it add: 5.
    it add: 0.
    it removeLast.
    it add: 4.
    it printString.
]
