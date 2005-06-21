"======================================================================
|
|   Test the array routines
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999  Free Software Foundation.
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

!Object methodsFor: 'testing'!

arrayConstTest1
    | a |
    a := #(#foo #bar 'quem').
    ^a
!

arrayConstTest2
    | a |
    a := #(#foo #bar 'quem').
    ^a class
!

arrayConstTest3
    | a |
    a := #(#foo #bar 'quem').
    ^a size
!

arrayConstTest4
    | a |
    a := #(#foo (#a #sub #array) #bar 'quem' 3.4 1 $C #barn:yard:owl: #baz).
    ^a class
!

arrayConstSubscriptTest
    | a |
    a := #(#foo (#a #sub #array) #bar 'quem' 3.4 1 $C #barn:yard:owl: #baz).
    ^a at: self
!

arrayTrueFalseNilTest
    | a |
    a := #(true #true false #false nil #nil).
    a do: [ :each | each class printNl ]
!

newArray1
    | a |
    a := Array new: 10.
    ^a class
!

newArray2
    | a |
    a := Array new: 10.
    a at: self put: self.
    ^a at: self
! !

^nil arrayConstTest1!

^nil arrayConstTest2!

^nil arrayConstTest3!

^nil arrayConstTest4!

^1 arrayConstSubscriptTest!
^2 arrayConstSubscriptTest!
^3 arrayConstSubscriptTest!
^4 arrayConstSubscriptTest!
^5 arrayConstSubscriptTest!
^6 arrayConstSubscriptTest!
^7 arrayConstSubscriptTest!
^8 arrayConstSubscriptTest!
^9 arrayConstSubscriptTest!

^nil newArray1!

^1 newArray2!
^5 newArray2!
^10 newArray2!

^nil arrayTrueFalseNilTest!

^ByteArray with: -1!
^ByteArray with: 0!
^ByteArray with: 255!
^ByteArray with: 256!
^WordArray with: (-1 bitShift: 64)!
^WordArray with: -1!
^WordArray with: 0!
^WordArray with: 255!
^WordArray with: 256!
^WordArray with: (1 bitShift: 64)!

