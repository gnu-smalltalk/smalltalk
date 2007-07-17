"======================================================================
|
|   Complex numbers test suite
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
|
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
|
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"

PackageLoader fileInPackage: #Complex!
PackageLoader fileInPackage: #SUnit!

TestCase subclass: #ComplexTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

!ComplexTest methodsFor: 'asserting'!

assert: x closeTo: y
    self assert: (x closeTo: y)
! !

!ComplexTest methodsFor: 'unit tests'!

testI
    self assert: Complex i real == 0.
    self assert: Complex i imaginary == 1.
    self assert: Complex i == Complex i.
    self assert: 1 i real == 0.
    self assert: 1 i imaginary == 1.
    self assert: Complex i i == -1!

testPolar
    self assert: (Complex rho: 1 theta: 0) = 1.
    self assert: (Complex rho: 1 theta: FloatD pi / 2) closeTo: Complex i.
    self assert: (Complex rho: 1 theta: FloatD pi) closeTo: -1.
    self assert: (Complex rho: 2 theta: 0) = 2!

testCartesion
    self assert: (Complex real: 1 imaginary: 0) == 1.
    self assert: (Complex real: Complex i imaginary: 0) = Complex i.
    self assert: (Complex real: 0 imaginary: Complex i) == -1.
    self assert: (Complex real: 1 imaginary: Complex i) == 0.
    self assert: (Complex real: 1 imaginary: 1) real == 1.
    self assert: (Complex real: 1 imaginary: 1) imaginary == 1.
    self assert: (Complex real: 1 imaginary: 1.0) real isFloat.
    self assert: (Complex real: 1.0 imaginary: 1) imaginary isFloat!

testPlus
    self assert: (1 + 2 i) real == 1.
    self assert: (1 + 2 i) imaginary == 2.
    self assert: 0.5 i + (1 + 2 i) = (1 + 2.5 i).
    self assert: 0.5 + (1 + 2 i) = (1.5 + 2 i).
    self assert: (3 + 4 i) + (1 + 2 i) = (4 + 6 i)!

testMinus
    self assert: (1 - 2 i) real == 1.
    self assert: (1 - 2 i) imaginary == -2.
    self assert: 0.5 i - (1 + 2 i) = (-1 + -1.5 i).
    self assert: 0.5 - (1 + 2 i) = (-0.5 + -2 i).
    self assert: (3 + 4 i) - (1 + 3 i) = (2 + 1 i).
    self assert: (1 + 2.0 i) - (1 + 2 i) = 0.
    self assert: (1.0 + 2 i) - (1 + 2 i) = 0!

testMultiply
    self assert: Complex i * Complex i = -1.
    self assert: Complex i * 1 = Complex i.
    self assert: Complex i * 0.5 = 0.5 i.
    self assert: (3 + 4 i) * (1 + 2 i) = (-5 + 10 i)!

testDivide
    self assert: Complex i / Complex i == 1.
    self assert: Complex i / 1 = Complex i.
    self assert: Complex i / 0.5 = 2 i.
    self assert: ((3 + 4 i) / (1 + 2 i)) = ((22 - 4 i) / 10).
    self assert: ((3 + 4 i) / (1 + 2 i)) real * 10 == 22.
    self assert: ((3 + 4 i) / (1 + 2 i)) imaginary * 10 == -4!

testReciprocal
    self assert: Complex i reciprocal real == 0.
    self assert: Complex i reciprocal imaginary == -1.
    self assert: (1 + 2 i) reciprocal real * 5 == 1.
    self assert: (1 + 2 i) reciprocal imaginary * 5 == -2!

testAbs
    self assert: (3 + 4 i) abs = 5.
    self assert: (3 - 4 i) abs = 5.
    self assert: (-3 + 4 i) abs = 5.
    self assert: (-3 - 4 i) abs = 5!

testAbsSquared
    self assert: (3 + 4 i) absSquared == 25.
    self assert: (3 - 4 i) absSquared == 25.
    self assert: (-3 + 4 i) absSquared == 25.
    self assert: (-3 - 4 i) absSquared == 25!

testConjugate
    self assert: Complex i * Complex i conjugate == 1.
    self assert: (3 + 4 i) conjugate = (3 - 4 i).
    self assert: 3 conjugate == 3!

testExp
    self assert: (FloatD pi negated i) exp closeTo: -1.
    self assert: (FloatD pi i) exp closeTo: -1.
    self assert: (FloatD pi i / 2) exp closeTo: Complex i.
    self assert: (1 + FloatD pi i) exp closeTo: 1 exp negated!

testSin
    self assert: 1 i sin imaginary = 1 sinh.
    self assert: (FloatD pi + 1 i) sin imaginary = -1 sinh.
    self assert: (FloatD pi / 2 + 1 i) sin real = 1 cosh!

testCos
    self assert: 1 i cos = 1 cosh!

testSinh
    self assert: FloatD pi i sinh closeTo: 0!

testCosh
    self assert: FloatD pi i cosh closeTo: -1!

testArcCos
    self assert: 1 cosh arcCos real closeTo: 0.
    self assert: 1 cosh arcCos imaginary closeTo: 1!

testArcSin
    self assert: 1 cosh arcSin imaginary closeTo: -1.
    self assert: 1 cosh arcSin real closeTo: FloatD pi / 2!

testArcTan
    self assert: 1 tanh i arcTan real closeTo: 0.
    self assert: 1 tanh i arcTan imaginary closeTo: 1.
    self assert: (Complex i arcTan: 1 tanh reciprocal) real closeTo: 0.
    self assert: (Complex i arcTan: 1 tanh reciprocal) imaginary closeTo: 1!

testArg
    self assert: -1 arg closeTo: FloatD pi.
    self assert: Complex i arg closeTo: (FloatD pi / 2).
    self assert: (1 + 1 i) arg closeTo: (FloatD pi / 4)!

testSqrt
    self assert: -1 sqrt isComplex.
    self deny: 1 sqrt isComplex.
    self assert: -1 sqrt = Complex i.
    self assert: Complex i sqrt real = Complex i sqrt imaginary.
    self assert: (3 + 4 i) sqrt = (2+1i)!

testLn
    self assert: -1 ln isComplex.
    self deny: 1 ln isComplex.
    self assert: -1 ln imaginary closeTo: FloatD pi.
    self assert: (1 + 1 i) ln real * 2 closeTo: 2 ln.
    self assert: (1 + 1 i) ln imaginary closeTo: (FloatD pi / 4)!

testLog
    "Return the base-10 logarithm of the receiver."
    self assert: (1 + 1 i) log real * 2 = 2 log!

testTanh
    "Return the hyperbolic tangent of the receiver."
    self assert: Complex i tanh closeTo: 1 tan i!

testTan
    "Return the tangent of the receiver."
    self assert: Complex i tan closeTo: 1 tanh i!

testLess
    self deny: (1 + 1 i) < 1.
    self deny: (1 + 1 i) < -1.
    self deny: (3 + 4 i) < 5.
    self deny: (3 + 4 i) < -5.
    self deny: (3 + 4 i) < (4 + 3 i).
    self deny: (3 + 4 i) < (4 - 3 i).
    self deny: (3 - 4 i) < (4 + 3 i).
    self deny: (3 - 4 i) < (4 - 3 i).
    self assert: (1 + 1 i) < 10.
    self assert: (1 + 1 i) < -10!

testLessEqual
    self deny: (1 + 1 i) <= 1.
    self deny: (1 + 1 i) <= -1.
    self assert: (3 + 4 i) <= 5.
    self assert: (3 + 4 i) <= -5.
    self assert: (3 + 4 i) <= (4 + 3 i).
    self assert: (3 + 4 i) <= (4 - 3 i).
    self assert: (3 - 4 i) <= (4 + 3 i).
    self assert: (3 - 4 i) <= (4 - 3 i).
    self assert: (1 + 1 i) <= 10.
    self assert: (1 + 1 i) <= -10!

testGreaterEqual
    self assert: (1 + 1 i) >= 1.
    self assert: (1 + 1 i) >= -1.
    self assert: (3 + 4 i) >= 5.
    self assert: (3 + 4 i) >= -5.
    self assert: (3 + 4 i) >= (4 + 3 i).
    self assert: (3 + 4 i) >= (4 - 3 i).
    self assert: (3 - 4 i) >= (4 + 3 i).
    self assert: (3 - 4 i) >= (4 - 3 i).
    self deny: (1 + 1 i) >= 10.
    self deny: (1 + 1 i) >= -10!

testGreater
    self assert: (1 + 1 i) > 1.
    self assert: (1 + 1 i) > -1.
    self deny: (3 + 4 i) > 5.
    self deny: (3 + 4 i) > -5.
    self deny: (3 + 4 i) > (4 + 3 i).
    self deny: (3 + 4 i) > (4 - 3 i).
    self deny: (3 - 4 i) > (4 + 3 i).
    self deny: (3 - 4 i) > (4 - 3 i).
    self deny: (1 + 1 i) > 10.
    self deny: (1 + 1 i) > -10!

testEqual
    self assert: (3 + 4 i) = (3 + 4 i).
    self assert: (3 + 4 i) = (3.0 + 4.0 i).
    self deny: (3 + 4 i) = 5.
    self deny: (3 + 4 i) = -5.
    self deny: (3 + 4 i) = (4 + 3 i).
    self deny: (3 + 4 i) = (4 - 3 i).
    self deny: (3 - 4 i) = (4 + 3 i).
    self deny: (3 - 4 i) = (4 - 3 i)!

testNotEqual
    self deny: (3 + 4 i) ~= (3 + 4 i).
    self deny: (3 + 4 i) ~= (3.0 + 4.0 i).
    self assert: (3 + 4 i) ~= 5.
    self assert: (3 + 4 i) ~= -5.
    self assert: (3 + 4 i) ~= (4 + 3 i).
    self assert: (3 + 4 i) ~= (4 - 3 i).
    self assert: (3 - 4 i) ~= (4 + 3 i).
    self assert: (3 - 4 i) ~= (4 - 3 i)!

testHash
    self assert: (3 + 4 i) hash = (3 + 4 i) hash.
    self assert: (3 + 4 i) hash = (3.0 + 4.0 i) hash!

testAsFloat
    self assert: (3 + 4 i) asFloat real isFloat.
    self assert: (3 + 4 i) asFloat imaginary isFloat!

testAsFloatD
    self assert: (3 + 4 i) asFloatD real isFloat.
    self assert: (3 + 4 i) asFloatD imaginary isFloat!

testAsFloatE
    self assert: (3 + 4 i) asFloatE real isFloat.
    self assert: (3 + 4 i) asFloatE imaginary isFloat!

testAsFloatQ
    self assert: (3 + 4 i) asFloatQ real isFloat.
    self assert: (3 + 4 i) asFloatQ imaginary isFloat!

testAsFraction
    self deny: (3.0 + 4 i) asFraction real isFloat.
    self deny: (3.0 + 4 i) asFraction imaginary isFloat!

testAsExactFraction
    self deny: (3.0 + 4 i) asFraction real isFloat.
    self deny: (3.0 + 4 i) asFraction imaginary isFloat!

testFloor
    self assert: (3.5 + 4.5 i) floor real == 3.
    self assert: (3.5 + 4.5 i) floor imaginary == 4.
    self assert: (-2.5 - 3.5 i) floor real == -3.
    self assert: (-2.5 - 3.5 i) floor imaginary == -4!

testCeiling
    self assert: (2.5 + 3.5 i) ceiling real == 3.
    self assert: (2.5 + 3.5 i) ceiling imaginary == 4.
    self assert: (-3.5 - 4.5 i) ceiling real == -3.
    self assert: (-3.5 - 4.5 i) ceiling imaginary == -4!

testTruncated
    self assert: (3.5 + 4.5 i) truncated real == 3.
    self assert: (3.5 + 4.5 i) truncated imaginary == 4.
    self assert: (-3.5 - 4.5 i) truncated real == -3.
    self assert: (-3.5 - 4.5 i) truncated imaginary == -4!

testRounded
    self assert: (3.25 + 3.75 i) rounded real == 3.
    self assert: (3.25 + 3.75 i) rounded imaginary == 4.
    self assert: (-3.25 - 3.75 i) rounded real == -3.
    self assert: (-3.25 - 3.75 i) rounded imaginary == -4!

testIsComplex 
    self assert: Complex i isComplex.
    self deny: (Complex real: 5 imaginary: 0) isComplex.
    self deny: 5 isComplex!

testZero
    self assert: Complex i zero = 0.
    self assert: 0 = Complex i zero!

testOne
    self assert: Complex i one = 1.
    self assert: 1 = Complex i one!

testReal
    self assert: 5 real == 5.
    self assert: 5.0 real = 5.0.
    self assert: Complex i real = 0.
    self assert: Complex i one real = 1!

testImaginary
    self assert: 5 imaginary == 0.
    self assert: 5.0 imaginary = 0.
    self assert: Complex i imaginary = 1.
    self assert: Complex i one imaginary = 0!

testRaisedTo
    self assert: (Complex i raisedTo: Complex i) closeTo: (Float pi / -2) exp.
    self assert: (1 raisedTo: Complex i) = 1! !
