"======================================================================
|
|   Number Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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


Magnitude subclass: #Number
	  instanceVariableNames: ''
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Language-Data types'
!

Number comment: 
'I am an abstract class that provides operations on numbers, both floating
point and integer.  I provide some generic predicates, and supply the 
implicit type coercing code for binary operations.' !


!Number class methodsFor: 'converting'!

coerce: aNumber
    "Answer aNumber - whatever class it belongs to, it is good"
    ^aNumber
!

readFrom: aStream
    "Answer the number read from the rest of aStream, converted to an
     instance of the receiver. If the receiver is number, the class of the
     result is undefined -- but the result is good."
    | value ch scale |
    value := 0.
    scale := (aStream peekFor: $-) ifTrue: [ -1 ] ifFalse: [ 1 ].

    [ aStream atEnd ifTrue: [^self coerce: value].
      (ch := aStream next) isDigit ] whileTrue: [
	 value := ch digitValue * scale + (value * 10).
    ].
    ch = $. ifFalse: [aStream skip: -1. ^value].

    [ aStream atEnd ifTrue: [^self coerce: value].
      (ch := aStream next) isDigit ] whileTrue: [
	 scale := scale / 10.
	 value := ch digitValue * scale + value.
    ].

    aStream skip: -1.
    ^self coerce: value
! !


!Number class methodsFor: 'testing'!

isImmediate
    "Answer whether, if x is an instance of the receiver, x copy == x"
    ^true
! !


!Number methodsFor: 'copying'!

shallowCopy
    "Return the receiver - it's an immediate (immutable) object"
    ^self
!

deepCopy
    "Return the receiver - it's an immediate (immutable) object"
    ^self
! !


!Number methodsFor: 'converting'!

asNumber
    "Answer the receiver, since it is already a number"
    ^self
!

degreesToRadians
    "Convert the receiver to radians"
    ^self asFloatD / 57.295779513082320876846364344191
!

radiansToDegrees
    "Convert the receiver from radians to degrees"
    ^self asFloatD * 57.295779513082320876846364344191
!

coerce: aNumber
    "Answer aNumber - whatever class it belongs to, it is good"
    ^aNumber
!

zero
    "Coerce 0 to the receiver's class. The default implementation works,
     but is inefficient"
    ^self coerce: 0
!

unity
    "Coerce 1 to the receiver's class. The default implementation works,
     but is inefficient"
    ^self coerce: 1
!

generality
    "Answer the receiver's generality"
    self subclassResponsibility
!

asScaledDecimal: n
    "Answer the receiver, converted to a ScaledDecimal object."
    ^ScaledDecimal
	newFromNumber: self asFraction
	scale: n
!

asScaledDecimal: denDigits scale: n
    "Answer the receiver, divided by 10^denDigits and converted to
     a ScaledDecimal object."
    ^ScaledDecimal
	newFromNumber: (self asFraction *
	  (10 raisedToInteger: denDigits))
	scale: n
!

asFloat
    "Convert the receiver to an arbitrary subclass of Float"
    ^self asFloatD
!

asFloatD
    self subclassResponsibility
!

asFloatE
    self subclassResponsibility
!

asFloatQ
    self subclassResponsibility
! !


!Number methodsFor: 'retrying'!

retryError
    "Raise an error---a retrying method was called with two arguments
     having the same generality."
    ^self error: 'retry:coercing: called with arguments of the same generality' 
!

retry: aSymbol coercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling aSymbol.  aSymbol is
     supposed not to be #= or #~= (since those don't fail if aNumber is not
     a Number)."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    selfGen > aNumGen
    	ifTrue: [ ^self perform: aSymbol with: (self coerce: aNumber) ].
    selfGen < aNumGen
    	ifTrue: [ ^(aNumber coerce: self) perform: aSymbol with: aNumber ].

    self retryError
!

retryRelationalOp: aSymbol coercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling aSymbol (<, <=, >, >=)."

    | delta |
    delta := self retryDifferenceCoercing: aNumber.

    "Avoids a #perform: which is usually more expensive -- all the comparisons
     below are inlined by both the compiler and the interpreter"

    aSymbol == #< ifTrue: [ ^delta < delta zero ].
    aSymbol == #<= ifTrue: [ ^delta <= delta zero ].
    aSymbol == #>= ifTrue: [ ^delta >= delta zero ].
    aSymbol == #> ifTrue: [ ^delta > delta zero ].
    self error: 'bad relational operator'
!

retryEqualityCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #=."

    | selfGen aNumGen |
    (aNumber isKindOf: Number) ifFalse: [ ^false ].

    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^false ].

    selfGen > aNumGen ifTrue: [ ^self = (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) = aNumber ].

    self retryError
!

retryInequalityCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #~=."

    | selfGen aNumGen |
    (aNumber isKindOf: Number) ifFalse: [ ^true ].

    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^true ].

    selfGen > aNumGen ifTrue: [ ^false == (self = (self coerce: aNumber)) ].
    selfGen < aNumGen ifTrue: [ ^false == ((aNumber coerce: self) ~= aNumber) ].

    self retryError
!

retrySumCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #+."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^aNumber sumFromNumber: self ].
    selfGen > aNumGen ifTrue: [ ^self + (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) + aNumber ].

    self retryError
!

retryDifferenceCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #-."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^aNumber differenceFromNumber: self ].
    selfGen > aNumGen ifTrue: [ ^self - (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) - aNumber ].

    self retryError
!

retryMultiplicationCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #*."


    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.
    aNumGen isNil ifTrue: [ ^aNumber productFromNumber: self ].
    selfGen > aNumGen ifTrue: [ ^self * (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) * aNumber ].

    self retryError
!

retryDivisionCoercing: aNumber
    "Coerce to the other number's class the one number between the receiver and
     aNumber which has the lowest, and retry calling #/."

    | selfGen aNumGen |
    selfGen := self generality.
    aNumGen := aNumber generality.

    selfGen > aNumGen ifTrue: [ ^self / (self coerce: aNumber) ].
    selfGen < aNumGen ifTrue: [ ^(aNumber coerce: self) / aNumber ].

    self retryError
! !



!Number methodsFor: 'arithmetic'!

+ aNumber
    "Sum the receiver and aNumber, answer the result"
    self subclassResponsibility
!

- aNumber
    "Subtract aNumber from the receiver, answer the result"
    self subclassResponsibility
!

* aNumber
    "Subtract the receiver and aNumber, answer the result"
    self subclassResponsibility
!

/ aNumber
    "Divide the receiver by aNumber, answer the result (no loss of
     precision).  Raise a ZeroDivide exception or return a valid
     (possibly infinite) continuation value if aNumber is zero."
    self subclassResponsibility
!

// aNumber
    "Return the integer quotient of dividing the receiver by aNumber with
    truncation towards negative infinity.  Raise a ZeroDivide
    exception if aNumber is zero"

    aNumber = 0 ifTrue: [ self zeroDivide ].
    ^(self / aNumber) floor
!

\\ aNumber
    "Return the remainder of dividing the receiver by aNumber with
    truncation towards negative infinity.  Raise a ZeroDivide
    exception if aNumber is zero"

    aNumber = 0 ifTrue: [ self zeroDivide ].
    ^self negative == aNumber negative
	ifTrue: [ self rem: aNumber ]
	ifFalse: [ (self rem: aNumber) + aNumber ]
!

quo: aNumber
    "Return the integer quotient of dividing the receiver by aNumber with
    truncation towards zero.  Raise a ZeroDivide exception if aNumber is
    zero"
    aNumber = 0 ifTrue: [ self zeroDivide ].
    ^(self / aNumber) truncated
!

rem: aNumber
    "Return the remainder of dividing the receiver by aNumber with
    truncation towards zero.  Raise a ZeroDivide exception if aNumber is
    zero"

    ^self - ((self quo: aNumber) * aNumber)
! !



!Number methodsFor: 'truncation and round off'!

integerPart
    "Answer the receiver, truncated towards zero"
    ^self truncated
!

fractionPart
    "Answer a number which, summed to the #integerPart of the
     receiver, gives the receiver itself."
    ^self - self integerPart
!

asInteger
    "Answer the receiver, rounded to the nearest integer"
    ^self rounded
!

truncated
    "Answer the receiver, truncated towards zero"
    ^self subclassResponsibility
!

truncateTo: aNumber
    "Answer the receiver, truncated towards zero to a multiple
     of aNumber"
    ^(self coerce: (self quo: aNumber)) * aNumber
!

rounded
    "Returns the integer nearest the receiver"
    ^self negative
	ifTrue: [ (self - (self unity / 2)) ceiling ]
	ifFalse: [ (self + (self unity / 2)) floor ]
!

roundTo: aNumber
    "Answer the receiver, truncated to the nearest multiple
     of aNumber"
    ^(self coerce: (self / aNumber) rounded) * aNumber
! !



!Number methodsFor: 'testing'!

closeTo: num
    "Answer whether the receiver can be considered sufficiently
     close to num (this is done by checking equality if num is
     not a number, and by checking with 0.01% tolerance if num
     is a number)."
    num isNumber ifFalse: [ ^self = num ].
    self = self zero ifTrue: [ ^num abs < 0.0001 ].
    num = num zero ifTrue: [ ^self abs < 0.0001 ].
    ^(self - num) abs / 0.0001 <= (self abs max: num abs)
!

isNaN
    "Answer whether the receiver is a Not-A-Number.  Most numeric
     classes don't handle nans, so the default is to answer false
     rather than calling #subclassResponsibility."
    ^false
!

isFinite
    "Answer whether the receiver represents a finite quantity.  Most
     numeric classes are for finite quantities, so the default is to
     answer true rather than calling #subclassResponsibility."
    ^true
!

isInfinite
    "Answer whether the receiver represents an infinite quantity.  Most
     numeric classes are for finite quantities, so the default is to
     answer false rather than calling #subclassResponsibility."
    ^false
!

isRational
    "Answer whether the receiver is rational - false by default"
    ^false
!

isNumber
    ^true
!

negative
    "Answer whether the receiver is < 0"
    ^self < self zero
!

positive
    "Answer whether the receiver is >= 0"
    ^self >= self zero
!

strictlyPositive
    "Answer whether the receiver is > 0"
    ^self > self zero
!

sign
    "Returns the sign of the receiver."
    self < self zero ifTrue: [ ^-1 ].
    self > self zero ifTrue: [ ^1 ].
    ^0
!

even
    "Returns true if self is divisible by 2"
    ^self truncated even
!

odd
    "Returns true if self is not divisible by 2"
    ^self truncated odd
! !



!Number methodsFor: 'comparing'!

min: aNumber
    "Answer the minimum between the receiver and aNumber.  Redefine
     in subclasses if necessary to ensure that if either self or
     aNumber is a NaN, it is always answered."

    "If both self and aNumber are zero, return aNumber in case it
     has a negative sign, because we assume our zero is positive.
     If the test is false, always answer aNumber in case it is a
     NaN, because we assume that self is not a NaN."
    ^aNumber > self ifTrue: [ self ] ifFalse: [ aNumber ]!

max: aNumber
    "Answer the maximum between the receiver and aNumber.  Redefine
     in subclasses if necessary to ensure that if either self or
     aNumber is a NaN, it is always answered."

    "If both self and aNumber are zero, return self in case aNumber
     has a negative sign, because we assume our zero is positive.
     If the test is false, always answer aNumber in case it is a
     NaN, because we assume that self is not a NaN."
    ^aNumber <= self ifTrue: [ self ] ifFalse: [ aNumber ]!



!Number methodsFor: 'misc math'!

positiveDifference: aNumber
    "Answer the positive difference of the receiver and
     aNumber, that is self - aNumber if it is positive,
     0 otherwise."
    | diff |
    diff := self - aNumber.
    diff isNaN ifTrue: [ ^diff ].
    ^diff negative ifTrue: [ diff zero ] ifFalse: [ diff ]
!

squared
    "Answer the square of the receiver"
    ^self * self
!

abs
    "Answer the absolute value of the receiver"
    ^self > self zero
	ifTrue: [ self ]
	ifFalse: [ self negated ]
!

negated
    "Answer the negated of the receiver"
    ^self zero - self
!

sin
    "Answer the sine of the receiver"
    ^self asFloatD sin
!

cos
    "Answer the cosine of the receiver"
    ^self asFloatD cos
!

tan
    "Answer the tangent of the receiver"
    ^self asFloatD tan
!

arcSin
    "Answer the arc sine of the receiver"
    ^self asFloatD arcSin
!

arcCos
    "Answer the arc cosine of the receiver"
    ^self asFloatD arcCos
!

arcTan
    "Answer the arc tangent of the receiver"
    ^self asFloatD arcTan
!

arcTan: x
    "Answer the angle (measured counterclockwise) between (x, self) and
     a ray starting in (0, 0) and moving towards (1, 0) - i.e. 3 o'clock"

    | result |
    x = 0 ifTrue: [
	"Always adopt the most general number representation of pi.
	 If none of the number is a floating point number, go with
	 a FloatD."
	^self generality < x generality
	    ifTrue: [
		x generality < 0.0e generality
		    ifTrue: [ FloatD pi * self sign / -2 ]
		    ifFalse: [ x class pi * self sign / -2 ]]
	    ifFalse: [
		self generality < 0.0e generality
		    ifTrue: [ FloatD pi * self sign / -2 ]
		    ifFalse: [ self class pi * self sign / -2 ]]].

    result := (self / x) arcTan.
    ^x < 0
	ifFalse: [ result ]
	ifTrue: [
	    result > result zero
		ifFalse: [ result + result class pi ]
		ifTrue: [ result - result class pi ] ]
!

sqrt
    "Answer the square root of the receiver"
    ^self asFloatD sqrt
!

exp
    "Answer e raised to the receiver"
    ^self asFloatD exp
!

ln
    "Answer log base e of the receiver"
    ^self asFloatD ln
!

estimatedLog
    "Answer an estimate of (self abs floorLog: 10). This method
     should be overridden by subclasses, but Number's implementation
     does not raise errors - simply, it gives a correct result, so
     it is slow."
    ^self abs floorLog: 10
!

log
    "Answer log base aNumber of the receiver"
    ^self asFloatD ln / FloatD ln10
!

log: aNumber
    "Answer log base aNumber of the receiver"
    ^self asFloatD ln / aNumber asFloatD ln
!

floorLog: radix
    "Answer (self log: radix) floor. Optimized to answer an integer."

    | me that answer |

    self < self zero ifTrue: [
       ^self arithmeticError: 'cannot extract logarithm of a negative number'
    ].
    radix <= radix unity ifTrue: [
	(radix <= radix zero) ifTrue: [ ^self arithmeticError: 'bad radix' ].
	(radix = radix unity) ifTrue: [ ^self arithmeticError: 'bad radix' ].
	^(self ceilingLog: radix reciprocal) negated
    ].

    answer := -1.
    self < self unity
	ifTrue: [
	    me := self.
	    [   me := me * radix. me < me unity ] whileTrue: [
		answer := answer - 1
	    ]
	]
	ifFalse: [
	    that := 1.
	    [   that <= self ] whileTrue: [
		that := that * radix.
		answer := answer + 1
	    ]
	].

   ^answer
!

ceilingLog: radix
    "Answer (self log: radix) ceiling. Optimized to answer an integer."

    | me that answer |
    self < self zero ifTrue: [
       ^self arithmeticError: 'cannot extract logarithm of a negative number'
    ].
    radix <= radix unity ifTrue: [
	(radix <= radix zero) ifTrue: [ ^self arithmeticError: 'bad radix' ].
	(radix = radix unity) ifTrue: [ ^self arithmeticError: 'bad radix' ].
	^(self floorLog: radix reciprocal) negated
    ].

    answer := 0.
    self < self unity
	ifTrue: [
	    me := self.
	    [ me := me * radix. me <= me unity ] whileTrue: [
		answer := answer - 1
	    ].
	]
	ifFalse: [
	    that := 1.
	    [ that < self ] whileTrue: [
		that := that * radix.
		answer := answer + 1.
	    ].
	].

   ^answer
!

raisedTo: aNumber
    "Return self raised to aNumber power"

    ^aNumber isInteger
        ifTrue: [ self raisedToInteger: aNumber ]
        ifFalse: [ self asFloatD raisedTo: aNumber asFloatD ]
!

raisedToInteger: anInteger
    "Return self raised to the anInteger-th power"

    "Some special cases first"
    anInteger isInteger ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: Integer ].
    anInteger < 0 ifTrue: [ ^self reciprocal raisedToInteger: 0 - anInteger ].
    anInteger = 0 ifTrue: [ ^self unity ].
    anInteger = 1 ifTrue: [ ^self ].

    "Fire the big loop."
    ^self
	raisedToInteger: anInteger
	withCache: ((Array new: (255 min: anInteger))
			at: 1 put: self;
			yourself)
!

withSignOf: aNumber
    "Answer the receiver, with its sign possibly changed to match
     that of aNumber."
    ^aNumber positive == self positive
	ifTrue: [ self ]
	ifFalse: [ self negated ]
! !



!Number methodsFor: 'truncation and round off'!

floor
    "Return the integer nearest the receiver toward negative infinity."

    | selfTruncated |
    selfTruncated := self truncated.
    "If positive, truncation to zero is what we want."
    self >= self zero ifTrue: [^selfTruncated].

    "Must be negative."
    self = (self coerce: selfTruncated)
	ifTrue: [^selfTruncated]
	ifFalse: [^selfTruncated - 1]
! !


!Number methodsFor: 'arithmetic'!

reciprocal
    "Return the reciprocal of the receiver"
    self = self zero
	ifTrue: [self zeroDivide]
	ifFalse: [^self unity / self]
! !



!Number methodsFor: 'shortcuts and iterators'!

to: stop
    "Return an interval going from the receiver to stop by 1"
    ^Interval from: self to: stop
!

to: stop by: step
    "Return an interval going from the receiver to stop with the given step"
    ^Interval from: self to: stop by: step
!

to: stop by: step do: aBlock
    "Evaluate aBlock for each value in the interval going from the receiver
     to stop with the given step. Compiled in-line for integer literal steps,
     and for one-argument aBlocks without temporaries, and therefore
     not overridable."
    | i |
    i := self.
    step > step zero
	ifTrue: [
    	    [ i <= stop ]
	    	whileTrue: [ aBlock value: i.
		    	     i := i + step ]
    	]
	ifFalse: [
    	    [ i >= stop ]
	    	whileTrue: [ aBlock value: i.
		    	     i := i + step ]
	].
    ^stop
!

to: stop do: aBlock
    "Evaluate aBlock for each value in the interval going from the receiver
     to stop by 1. Compiled in-line for one-argument aBlocks without
     temporaries, and therefore not overridable."
    | i |
    i := self.
    [ i <= stop ]
    	whileTrue: [ aBlock value: i.
	    	     i := i + self unity ]
! !


!Number methodsFor: 'errors'!

arithmeticError: message
    self error: message
!

zeroDivide
    self error: 'cannot divide by zero'
! !


!Number methodsFor: 'private'!

raisedToInteger: n withCache: cache
    "Internal implementation of #raisedToInteger:."

    | result index |

    "For very big numbers, remove the rightmost bit."
    n > 255
	ifTrue: [
	    result := self raisedToInteger: n // 2 withCache: cache.
	    ^(n bitAnd: 1) = 0
		ifTrue: [ result squared ]
		ifFalse: [ result * (result * self) ]
	].

    "Else, use a table with the optimal choice of k so that
     self^k * self^(n - k) does as few multiplications as possible."
    result := cache at: n.
    result isNil ifTrue: [
        index := self powerTable at: n.
        result := 
	    (self raisedToInteger: n - index withCache: cache) *
	    (self raisedToInteger: index withCache: cache).

        cache at: n put: result
    ].
    ^result
!

powerTable
    "Internal table for #raisedToInteger:withCache:.  Example:
     (powerTable at: 9) == 6 means that n^9 is best computed
     as n^3 * n^6.  From Knuth's Seminumerical Algorithms."

    ^#[    0   1   2   2   3   3   4  "   1 -   7 "
       4   6   5   6   6  10   7   9  "   8 -  15 "
       8  16   9  16  10  12  11  13  "  16 -  23 "
      12  17  13  18  14  24  15  26  "  24 -  31 "
      16  17  17  19  18  33  19  26  "  32 -  39 "
      20  25  21  40  22  27  23  44  "  40 -  47 "
      24  32  25  34  26  29  27  44  "  48 -  55 "
      28  31  29  34  30  60  31  36  "  56 -  63 "
      32  64  33  34  34  46  35  37  "  64 -  71 "
      36  65  37  50  38  48  39  69  "  72 -  79 "
      40  49  41  43  42  51  43  58  "  80 -  87 "
      44  64  45  47  46  59  47  76  "  88 -  95 "
      48  65  49  66  50  67  51  66  "  96 - 103 "
      52  70  53  74  54 104  55  74  " 104 - 111 "
      56  64  57  69  58  78  59  68  " 112 - 119 "
      60  61  61  80  62  75  63  68  " 120 - 127 "
      64  65  65 128  66 129  67  90  " 128 - 135 "
      68  73  69 131  70  94  71  88  " 136 - 143 "
      72 128  73  98  74 132  75 121  " 144 - 151 "
      76 102  77 124  78 132  79 106  " 152 - 159 "
      80  97  81 160  82  99  83 134  " 160 - 167 "
      84  86  85  95  86 160  87 100  " 168 - 175 "
      88 113  89  98  90 107  91 122  " 176 - 183 "
      92 111  93 102  94 126  95 150  " 184 - 191 "
      96 128  97 130  98 133  99 195  " 192 - 199 "
     100 128 101 123 102 164 103 138  " 200 - 207 "
     104 145 105 146 106 109 107 149  " 208 - 215 "
     108 200 109 146 110 170 111 157  " 216 - 223 "
     112 128 113 130 114 182 115 132  " 224 - 231 "
     116 200 117 132 118 158 119 206  " 232 - 239 "
     120 240 121 162 122 147 123 152  " 240 - 247 "
     124 166 125 214 126 138 127 153] " 248 - 255 "
! !

