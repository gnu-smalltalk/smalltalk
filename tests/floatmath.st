"======================================================================
|
|   Test floating point operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1988, 1989, 1999, 2006  Free Software Foundation.
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

(1 to: 500000) collect: [ :each |
    RegressionTesting ifFalse: [
	each \\ 1000 = 0 ifTrue: [ each basicPrint. Character nl basicPrint ]
    ].
    -1.0 negated
].

ObjectMemory globalGarbageCollect.

^3.1!

^3.45!

^3.0e4!

^3.45e4!

^3.4 + 4.3!

^-5.5 - 3.12!

^5.6 < 5.5!
^5.5 < 5.6!

^5.6 > 5.5!
^5.5 > 5.6!

^3.4 <= 3.4!
^3.6 >= 2.5!

^3.12345 = 3.12345!

^4.5 ~= 5.67!

^4.5 * 0.0004!

^4.5 / 0.0004!

^3.14159 truncated!

^3.1415926535 fractionPart!

^4523.234 exponent!

^45.0 timesTwoPower: 4!
^45.0 timesTwoPower: -4!

^FloatD infinity!
^FloatD infinity printString!

^FloatD negativeInfinity!
^FloatD negativeInfinity printString!

^FloatD nan!
^FloatD nan printString!

^FloatD infinity reciprocal printString!
^FloatD negativeInfinity reciprocal printString!

0.0 positive!
(0.0 * -1) positive!

^FloatD nan min: FloatD nan!
^FloatD nan min: 5.0!
^5.0 min: FloatD nan!
^5.0 min: 7.0!
^7.0 min: 5.0!
^7.0 min: 7.0!
^0.0 min: 0.0!
^0.0 min: 0.0 * -1!
^0.0 * -1 min: 0.0!
^0.0 * -1 min: 0.0 * -1!

^FloatD nan max: FloatD nan!
^FloatD nan max: 5.0!
^5.0 max: FloatD nan!
^5.0 max: 7.0!
^7.0 max: 5.0!
^7.0 max: 7.0!
^0.0 max: 0.0!
^0.0 max: 0.0 * -1!
^0.0 * -1 max: 0.0!
^0.0 * -1 max: 0.0 * -1!

" ### need more tests"

^(( 0.6 \\  1) * 10) rounded == ( 6 \\  10)!
^(( 0.6 \\ -1) * 10) rounded == ( 6 \\ -10)!
^((-0.6 \\  1) * 10) rounded == (-6 \\  10)!
^((-0.6 \\ -1) * 10) rounded == (-6 \\ -10)!
^(( 0.4 \\  1) * 10) rounded == ( 4 \\  10)!
^(( 0.4 \\ -1) * 10) rounded == ( 4 \\ -10)!
^((-0.4 \\  1) * 10) rounded == (-4 \\  10)!
^((-0.4 \\ -1) * 10) rounded == (-4 \\ -10)!

" Fun with signed zeros"

 #(( -0.0d -0.0d) (-0.0d 0.0d) (0.0d -0.0d) (0.0d 0.0d)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b. a negated + b. b - a.
   ((a negated + b) = (b - a)).
   a + b negated. a - b.
   ((a + b negated) = (a - b)) } printNl ]!


 #(( -0.0e -0.0e) (-0.0e 0.0e) (0.0e -0.0e) (0.0e 0.0e)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b. a negated + b. b - a.
   ((a negated + b) = (b - a)).
   a + b negated. a - b.
   ((a + b negated) = (a - b)) } printNl ]!

"This is less strict because it behaves differently on different long double
 formats."

 #(( -0.0q -0.0q) (0.0q 0.0q)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b. a negated + b. b - a.
   ((a negated + b) = (b - a)).
   a + b negated. a - b.
   ((a + b negated) = (a - b)) } printNl ]!

 #((-0.0q 0.0q) (0.0q -0.0q)) do: [ :x ||a b|
   a := x first. b := x last.
   { a. b.
   ((b - a) negated = (a - b)).
   ((a negated + b) = (b - a)).
   ((a + b negated) = (a - b)) } printNl ]!




"Fun with printing"
  
!Float methodsFor: 'testing'!

test
    (((Behavior evaluate: self printString) = self) -> self) printNl. 
! !

1e16 test!
1.2345e16 test!
10.0 test!
(20 - 2.2325251) test!
0.12345 test!
0.12345d-8 test!
0.12345e-8 test!
0.83205029433784 test!
0.832050294337844 test!
0.55470019622523 test!
0.554700196225229 test!
