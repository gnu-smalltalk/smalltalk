"======================================================================
|
|   Test floating point operations
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
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

" ### need more tests"

^(( 0.6 \\  1) * 10) rounded == ( 6 \\  10)!
^(( 0.6 \\ -1) * 10) rounded == ( 6 \\ -10)!
^((-0.6 \\  1) * 10) rounded == (-6 \\  10)!
^((-0.6 \\ -1) * 10) rounded == (-6 \\ -10)!
^(( 0.4 \\  1) * 10) rounded == ( 4 \\  10)!
^(( 0.4 \\ -1) * 10) rounded == ( 4 \\ -10)!
^((-0.4 \\  1) * 10) rounded == (-4 \\  10)!
^((-0.4 \\ -1) * 10) rounded == (-4 \\ -10)!
