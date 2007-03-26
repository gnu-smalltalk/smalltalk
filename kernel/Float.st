"======================================================================
|
|   Float Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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


Number variableByteSubclass: #Float
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: 'CSymbols'
       category: 'Language-Data types'
!

Float comment: 
'My instances represent floating point numbers that have arbitrary
precision.  Besides the standard numerical operations, they provide
transcendental operations too.  They implement IEEE-754 correctly
if the hardware supports it.'  !


!Float class methodsFor: 'byte-order dependancies'!

signByte
    "Answer the byte of the receiver that contains the sign bit"
    self subclassResponsibility
! !


!Float class methodsFor: 'characterization'!

e
    "Returns the value of e. Hope is that it is precise enough"
    ^2.7182818284590452353602874713527d0
!

log10Base2
    "Returns the value of log2 10. Hope is that it is precise enough"
    ^3.3219280948873623478703194294894d0
!

ln10
    "Returns the value of ln 10. Hope is that it is precise enough"
    ^2.3025850929940456840179914546844d0
!

pi
    "Returns the value of pi. Hope is that it is precise enough"
    ^3.14159265358979323846264338327950288d0
!

radix
    "Answer the base in which computations between instances of the receiver 
     are made.  This should be 2 on about every known computer, so GNU
     Smalltalk always answers 2."
    ^2
!

denormalized
    "Answer whether instances of the receiver can be in denormalized
     form."
    ^self fminDenormalized > 0
!

fminDenormalized
    "Return the smallest Float that is > 0 if denormalized values
     are supported, else return 0."
    ^self fminNormalized timesTwoPower: 1 - self precision
!

fmin
    "Return the smallest Float that is > 0."
    | fminDen fmin |
    fmin := self fminNormalized.
    fminDen := fmin timesTwoPower: 1 - self precision.
    ^fminDen = 0 ifTrue: [ fmin ] ifFalse: [ fminDen ].
!

epsilon
    "Return the smallest Float x for which is 1 + x ~= 1"
    ^(self coerce: 2) timesTwoPower: self precision negated
! !



!Float methodsFor: 'basic'!

hash
    "Answer an hash value for the receiver"
    "Hack so that 2 hash = 2.0 hash"
    ^self fractionPart = 0.0
        ifTrue: [ self asInteger hash ]
        ifFalse: [ self primHash ]
! !


!Float methodsFor: 'arithmetic'!

negated
    "Return the negation of the receiver.  Unlike 0-self, this converts
     correctly signed zeros."
    ^self * -1
!

integerPart
    "Return the receiver's integer part"
    ^self - self fractionPart
!

raisedToInteger: anInteger
    "Return self raised to the anInteger-th power"

    | exp adjustExp val mant |

    "Some special cases first"
    anInteger isInteger ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: Integer ].
    anInteger = 0 ifTrue: [ ^self unity ].
    anInteger = 1 ifTrue: [ ^self ].

    "Avoid overflow when the result is denormal and we would have an
     unrepresentable intermediate result for its reciprocal."
    adjustExp := self exponent.
    exp := anInteger abs.
    (anInteger > 0 or: [ (adjustExp + 1) * exp < self class emax ])
	ifTrue: [
	    mant := self.
	    adjustExp := 0 ]
	ifFalse: [
	    mant := self timesTwoPower: 0 - adjustExp.
	    adjustExp := adjustExp * anInteger ].

    "Fire the big loop."
    val := mant
        raisedToInteger: exp
        withCache: ((Array new: (255 min: exp))
                        at: 1 put: mant;
                        yourself).

    anInteger < 0 ifTrue: [ val := val reciprocal ].
    adjustExp = 0 ifFalse: [ val := val timesTwoPower: adjustExp ].
    ^val
! !



!Float methodsFor: 'testing'!

isNaN
    "Answer whether the receiver represents a NaN"
    ^self ~= self
!

isFinite
    "Answer whether the receiver does not represent infinity, nor a NaN"
    ^self - self = self zero
!

isInfinite
    "Answer whether the receiver represents positive or negative infinity"
    ^self = self class infinity
	or: [ self = self class negativeInfinity ]
!

negative
    "Answer whether the receiver is negative"
    ^self <= self zero and: [ self unity / self <= self zero ]
!

strictlyPositive
    "Answer whether the receiver is > 0"
    ^self > self zero
!

positive
    "Answer whether the receiver is positive.  Negative zero is
     not positive, so the definition is not simply >= 0."
    ^self >= self zero and: [ self unity / self >= self zero ]
!

sign
    "Answer 1 if the receiver is greater than 0, -1 if less than 0,
     else 0.  Negative zero is the same as positive zero."

    self = self zero ifTrue: [^0].
    ^self < 0 ifTrue: [-1] ifFalse: [1]
! !



!Float methodsFor: 'coercing'!

truncated
    "Convert the receiver to an Integer.  Only used for LargeIntegers,
     there are primitives for the other cases."

    | exponent bytes positive float |

    self isFinite ifFalse: [^self].
    (positive := self > 0)
        ifTrue: [ float := self ]
        ifFalse: [ float := self negated ].

    exponent := float exponent.
    bytes := LargePositiveInteger new: (self class precision + 7) // 8 + 1.
    float := float timesTwoPower: float class precision - exponent - 8.

    1 to: bytes size do: [ :i |
         bytes digitAt: i put: (float fractionPart timesTwoPower: 8) truncated.
         float := float integerPart timesTwoPower: -8.
    ].

    bytes := bytes bitShift: (exponent - float class precision).
    positive ifFalse: [ bytes := bytes negated ].
    ^bytes
!

asExactFraction
    "Convert the receiver into a fraction with optimal approximation,
     but with usually huge terms."

    | shift mantissa |
    self checkCoercion.
    shift := self exponent negated + self class precision.
    mantissa := (self timesTwoPower: shift) truncated.
    ^shift negative
        ifTrue: [mantissa * (1 bitShift: shift negated)]
        ifFalse: [mantissa / (1 bitShift: shift)]
!

asFraction
    "Convert the receiver into a fraction with a good (but undefined)
     approximation"

    | a x n2 d2 n1 d1 n0 d0 eps abs gcd |

    self checkCoercion.

    "This uses an algorithm based on continued fractions.
      n2/d2 = numerator and denominator of the fraction two steps ago
      n1/d1 = numerator and denominator of the fraction a steps ago
      n0/d0 = numerator and denominator of the fraction at the current step"

    n1  := d0 := 0.
    n0  := d1 := 1.
    abs := self abs timesTwoPower: self exponent negated.
    eps := self class epsilon.
    x   := abs.

    [   a := x truncated.
	n2 := n1. d2 := d1.
	n1 := n0. d1 := d0.
	n0 := n1 * a + n2.
	d0 := d1 * a + d2.
	(x := self unity / x fractionPart) isInfinite or: [
	    ((self coerce: n0) / (self coerce: d0) - abs) abs < eps ]
    ]   whileFalse.

    self exponent < 0
	ifTrue: [ d0 := d0 * (2 raisedToInteger: self exponent negated) ]
	ifFalse: [ n0 := n0 * (2 raisedToInteger: self exponent) ].

    gcd := n0 gcd: d0.
    n0 := n0 quo: gcd.
    d0 := d0 quo: gcd.

    ^Fraction
	numerator: (self < 0 ifTrue: [ n0 negated ] ifFalse: [ n0 ])
	denominator: d0
! !


!Float methodsFor: 'transcendental operations'!

log
    ^self ln / self class ln10
!

estimatedLog
    "Answer an estimate of (self abs floorLog: 10)"
    ^(self exponent + 1) asFloatD / FloatD log10Base2
!

asFloat
    "Just defined for completeness.  Return the receiver."
    ^self
! !


!Float methodsFor: 'comparing'!

min: aNumber
    "Answer the minimum between the receiver and aNumber.  Redefine
     in subclasses if necessary to ensure that if either self or
     aNumber is a NaN, it is always answered."

    "If both self and aNumber are zero, return aNumber in case it
     has a negative sign, because we assume our zero is positive.
     If the test is false, always answer aNumber in case it is a
     NaN, because we assume that self is not a NaN."

    ^aNumber < self
	ifTrue: [ aNumber ]
	ifFalse: [
	    self = aNumber
		ifFalse: [
		    aNumber = aNumber
			ifFalse: [ aNumber ]
			ifTrue: [ self ] ]
		ifTrue: [
		    "Remember than -0.0 - +0.0 = -0.0, but the other pairs are +0.0."
		    self = self zero
			ifTrue: [ (self * -1 - aNumber) * -1 ]
			ifFalse: [ self ] ] ]!

max: aNumber
    "Answer the maximum between the receiver and aNumber.  Redefine
     in subclasses if necessary to ensure that if either self or
     aNumber is a NaN, it is always answered."

    ^aNumber > self
	ifTrue: [ aNumber ]
	ifFalse: [
	    self = aNumber
		ifFalse: [
		    aNumber = aNumber
			ifFalse: [ aNumber ]
			ifTrue: [ self ] ]
		ifTrue: [
		    "Remember than -0.0 + -0.0 = -0.0, but the other pairs are +0.0."
		    self = self zero
			ifTrue: [ self + aNumber ]
			ifFalse: [ self ] ] ]!

withSignOf: aNumber
    "Answer the receiver, with its sign possibly changed to match
     that of aNumber."
    ^aNumber positive == self positive
	ifTrue: [ self ]
	ifFalse: [ self negated ]
! !



!Float methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream"
    self
	printOn: aStream
	special: #('Inf' '-Inf' 'NaN')
! !



!Float methodsFor: 'storing'!

storeOn: aStream
    "Print a representation of the receiver on aStream"
    self
	printOn: aStream
	special: #('%1 infinity' '%1 negativeInfinity' '%1 nan')
! !



!Float methodsFor: 'private'!

checkCoercion
    "Private - Fail if the receiver is only representable as a Float"

    self isInfinite
	ifTrue: [self arithmeticError: 'Infinity can only be a Float'].
    self isNaN
	ifTrue: [self arithmeticError: 'Not-a-Number can only be a Float'].
!

printOn: aStream special: whatToPrintArray
    "Private - Print a decimal representation of the receiver on aStream,
     printing one of the three elements of whatToPrintArray if it is
     infinity, negative infinity, or a NaN"
    | me exponential small num numLog den denLog gcd
      intFactor precision int rounding digits digitStream exponent
      dotPrinted |

    "First, take care of the easy cases."
    self isNaN ifTrue: [
	^aStream nextPutAll:
	    ((whatToPrintArray at: 3) bindWith: self class) ].
    self = self class infinity ifTrue: [
	^aStream nextPutAll:
	    ((whatToPrintArray at: 1) bindWith: self class) ].
    self = self class negativeInfinity ifTrue: [
	^aStream nextPutAll:
	    ((whatToPrintArray at: 2) bindWith: self class) ].

    "We deal only with positive values."
    me := self abs.
    self negative ifTrue: [ aStream nextPut: $- ].
    self = self zero ifTrue: [ aStream nextPutAll: '0.0'. ^self ].

    "Figure out some quantities and the way we'll print the number."
    exponential := me exponent abs > me class precision.
    small := me < me unity.
    exponent := (me floorLog: 10) + 1.

    "Compute a rational form of the number we will print..."
    (exponential and: [ small not ])
        ifTrue: [ num := me asInteger. den := 1 ]
	ifFalse: [
	    num := (me timesTwoPower: me class precision - me exponent) asInteger.
	    den := 2 raisedToInteger: me class precision - me exponent.

            "(The mantissa if printing a small number in exponential notation)."
            exponential ifTrue: [ num := num * (10 raisedTo: -1 - exponent) ].

	    gcd := num gcd: den.
	    num := num // gcd.
	    den := den // gcd ].

    "To round correctly, make sure den is even."
    (den bitAnd: 1) = 1 ifTrue: [ num := num * 2. den := den * 2 ].

    "Get the first `me class decimalDigits' base-10 digits of num // den,
     appropriately rounded"
    numLog := num ceilingLog: 10.
    denLog := den ceilingLog: 10. 
    denLog < me class decimalDigits ifTrue: [
        denLog := denLog max: den highBit ].

    intFactor := 10 raisedToInteger: denLog.
    rounding := 10 raisedToInteger: numLog - me class decimalDigits.
    int := ((num * intFactor) + ((den // 2) * (rounding + 1))) // den.

    digits := int printString.
    digits size > me class decimalDigits
        ifTrue: [ digits := digits copyFrom: 1 to: me class decimalDigits ].

    "Print the non-significant zeros."
    dotPrinted := false.
    (small and: [ exponential not ]) ifTrue: [
        (me floorLog: 10) negated timesRepeat: [
            aStream nextPut: $0.
	    dotPrinted ifFalse: [ dotPrinted := true. aStream nextPut: $. ].
            int := int // 10.
	    exponent := exponent + 1 ] ].

    "Make a stream with the significant digits."
    precision := digits findLast: [ :ch | ch ~= $0 ].
    digitStream := ReadStream on: digits from: 1 to: precision.

    "Print the integer part (only one digit if using exponential notation)."
    [
        digitStream atEnd
            ifTrue: [ aStream nextPut: $0 ]
            ifFalse: [ aStream nextPut: digitStream next ].

	exponent := exponent - 1.
        exponent > 0 and: [ exponential not ] ] whileTrue.

    "Print the fractional part."
    digitStream atEnd
    	ifTrue: [
            dotPrinted ifFalse: [ aStream nextPutAll: '.0' ] ]
    	ifFalse: [
            dotPrinted ifFalse: [ aStream nextPut: $. ].
	    digitStream do: [ :each | aStream nextPut: each ] ].

    "Finally, print the exponent if necessary."
    exponential ifTrue: [
        aStream nextPut: me exponentLetter; print: exponent ].
! !


!Float methodsFor: 'testing functionality'!

isFloat
    ^true
! !

