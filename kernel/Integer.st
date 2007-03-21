"======================================================================
|
|   Integer Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005,2006
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


Number subclass: #Integer
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: 'CSymbols'
       category: 'Language-Data types'
!

Integer comment:
'I am the abstract integer class of the GNU Smalltalk system.  My
subclasses'' instances can represent signed integers of various
sizes (a subclass is picked according to the size), with varying
efficiency.' !


!Integer class methodsFor: 'converting'!

coerce: aNumber
    "Answer aNumber converted to a kind of Integer"
    ^aNumber truncated
! 

readFrom: aStream radix: radix
    "Read a possibly negative number in the given radix from aStream,
     and answer its value."
    | value ch scale |
    value := 0.
    scale := (aStream peekFor: $-) ifTrue: [ -1 ] ifFalse: [ 1 ].
    [
	(ch := aStream peek) notNil and: 
	    [ (ch := ch asUppercase) isDigit: radix ]
    ] whileTrue: [
	value := (value * radix) + ch digitValue.
	aStream next
    ].
    ^value * scale
! !


!Integer methodsFor: 'basic'!

hash
    "Answer an hash value for the receiver"
    ^self
! !



!Integer methodsFor: 'iterators'!

timesRepeat: aBlock
    "Evaluate aBlock a number of times equal to the receiver's value.
     Compiled in-line for no argument aBlocks without temporaries, and
     therefore not overridable."
    1 to: self do: [ :each | aBlock value ]
! !



!Integer methodsFor: 'bit operators'!

bitAt: index
    "Answer the index-th bit of the receiver (the LSB has an index 
     of 1)"
    ^(self bitShift: (index - 1) negated) bitAnd: 1
!

bitAt: index put: value
    "Answer an integer which is identical to the receiver,
     possibly with the exception of the index-th bit of the
     receiver (the LSB having an index of 1), which assumes
     a value equal to the low-order bit of the second parameter."

    | bit |
    bit := (value bitAnd: 1) bitXor: (self bitAt: index).
    bit := bit bitShift: (index - 1).
    ^self bitXor: bit!

bitInvert
    "Return the 1's complement of the bits of the receiver"
    ^self bitXor: -1
!

bitClear: aMask 
    "Answer an Integer equal to the receiver, except that all the bits
     that are set in aMask are cleared."

    ^(self bitOr: aMask) bitXor: aMask
!

allMask: anInteger
    "True if all 1 bits in anInteger are 1 in the receiver"
    ^(self bitAnd: anInteger) = anInteger
!

anyMask: anInteger
    "True if any 1 bits in anInteger are 1 in the receiver"
    ^(self bitAnd: anInteger) ~= 0
!

clearBit: index
    "Clear the index-th bit of the receiver and answer a new Integer"
    | bit |
    bit := 1 bitShift: (index - 1).
    ^(self bitOr: bit) bitXor: bit
!

noMask: anInteger
    "Answer true if no 1 bits in anInteger are 1 in the receiver."
    ^(self bitAnd: anInteger) = 0
!

lowBit
    "Return the index of the lowest order 1 bit of the receiver."
    self subclassResponsibility
!

highBit
    "Return the index of the highest order 1 bit of the receiver."
    self subclassResponsibility
!

isBitSet: index
    "Answer whether the index-th bit of the receiver is set"
    ^((self bitShift: (index - 1) negated) bitAnd: 1) == 1
!

setBit: index
    "Set the index-th bit of the receiver and answer a new Integer"
    ^self bitOr: (1 bitShift: (index - 1))
! !



!Integer methodsFor: 'math methods'!

binomial: anInteger
    "Compute the number of combinations of anInteger objects among
     a number of objects given by the receiver."

    | n k mask gcd maxNum step num den stepNum stepDen |

    (self < 0 or: [ anInteger < 0 or: [ anInteger > self ]]) ifTrue: [
        ^self arithmeticError: 'binomial coefficient with invalid arguments' ].

    "The easy one."
    anInteger = 0 ifTrue: [ ^1 ].

    "The number of SmallInteger factors we computed so far"
    step := 1.

    "Two stacks holding intermediate factors."
    num := OrderedCollection new.
    den := OrderedCollection new.

    "The next factors to be multiplied."
    n := self. 
    k := anInteger+anInteger > n ifTrue: [n - anInteger] ifFalse: [ anInteger ].
    [
	stepNum := stepDen := 1.
	[
            maxNum := SmallInteger largest // n.
	    [ stepNum <= maxNum ] whileTrue: [
		stepNum := stepNum * n. stepDen := stepDen * k.
		k = 1 ifTrue: [ 
		    "We're finishing, empty the stack and then simplify the
		     remaining common factors."
		    gcd := stepNum gcd: stepDen.
		    stepNum := stepNum // gcd.
		    stepDen := stepDen // gcd.

		    num size timesRepeat: [
			stepNum := stepNum * num removeLast.
			stepDen := stepDen * den removeLast
		    ].

		    ^stepNum // stepDen
		].
		n := n - 1. k := k - 1 ].

	    (gcd := stepNum gcd: stepDen) > 1 and: [
	        stepNum := stepNum // gcd.
		stepDen := stepDen // gcd.
 	    
		"The numerators and denominators have been simplified, try
	         to add some more factors."
		stepNum <= maxNum ]
	] whileTrue.

        "Pop factors from the stack and combine them.  The number of factors
         we pop is equal to the order of the lowest bit set.

         That is, on the first iteration we push a size 1 LargeInteger;
         on the second iteration we pop it and make a size 2 LargeInteger;
         on the third iteration we push another size 1 LargeInteger;
         on the fourth iteration we pop it and make a size 2 LargeInteger;
         we then combine it with the other similarly sized integer and
         make a size 4 LargeInteger; and so on.

	 For the denominator the balancing is probably worse, since we
	 decide when to stop multiplying based on the numerator's magnitude,
	 but it is not a serious problem."

        mask := step bitXor: step - 1.
        [ mask = 1 ] whileFalse: [
            stepNum := stepNum * num removeLast.
            stepDen := stepDen * den removeLast.
            mask := mask bitShift: -1.
        ].
        num addLast: stepNum.
        den addLast: stepDen.
        step := step + 1.
    ] repeat
!

factorial
    "Return the receiver's factorial."
    | mask k n a b max stack |

    self < 0 ifTrue: [
        ^self arithmeticError: 'factorial of a negative number' ].

    self < 2 ifTrue: [ ^1 ].

    "The number of SmallInteger factors we computed so far"
    k := 1.

    "The next factor to be multiplied."
    n := self.

    "The stack holding intermediate factors."
    stack := OrderedCollection new.

    [
	a := n - 1.
	b := n.
	max := SmallInteger largest // n.
        [
	    n := n - 2.
            n < 2 ifTrue: [
		"Done, empty the stack and combine all the factors."
		a := a * b.
		stack size timesRepeat: [ a := a * stack removeLast ].
		^a
	    ].
	    b < max
        ] whileTrue: [
            a := a * (n - 1).
            b := b * n
	].

	"Compose the two SmallInteger factors"
	a := a * b.

	"Pop factors from the stack and combine them.  The number of factors
	 we pop is equal to the order of the lowest bit set.

	 That is, on the first iteration we push a size 1 LargeInteger;
	 on the second iteration we pop it and make a size 2 LargeInteger;
	 on the third iteration we push another size 1 LargeInteger;
	 on the fourth iteration we pop it and make a size 2 LargeInteger;
	 we then combine it with the other similarly sized integer and
	 make a size 4 LargeInteger; and so on."

	mask := k bitXor: k - 1.
	[ mask = 1 ] whileFalse: [
	    a := a * stack removeLast.
	    mask := mask bitShift: -1.
	].
	stack addLast: a.
	k := k + 1.
    ] repeat
!

estimatedLog
    "Answer an estimate of (self abs floorLog: 10)"
    ^(self highBit asFloatD / FloatD log10Base2) ceiling
!

floorLog: radix
    "Answer (self log: radix) floor. Optimized to answer an integer."

    | me answer |

    self < self zero ifTrue: [
       ^self arithmeticError: 'cannot extract logarithm of a negative number'
    ].

    radix <= radix unity ifTrue: [
	(radix <= radix zero)
	    ifTrue: [ ^self arithmeticError: 'base of a logarithm cannot be negative' ].
	(radix = radix unity)
	    ifTrue: [ ^self arithmeticError: 'base of a logarithm cannot be 1' ].
	^(self ceilingLog: radix reciprocal) negated
    ].
    radix isInteger ifFalse: [
	^(radix coerce: self) floorLog: radix
    ].

    me := self.
    answer := 0.
    [   me >= radix ] whileTrue: [
	me := me // radix.
	answer := answer + 1
    ].
    ^answer
!

ceilingLog: radix
    "Answer (self log: radix) ceiling. Optimized to answer an integer."

    | me answer |

    self < self zero ifTrue: [
       ^self arithmeticError: 'cannot extract logarithm of a negative number'
    ].

    radix <= radix unity ifTrue: [
	(radix <= radix zero)
	    ifTrue: [ ^self arithmeticError: 'base of a logarithm cannot be negative' ].
	(radix = radix unity)
	    ifTrue: [ ^self arithmeticError: 'base of a logarithm cannot be 1' ].
	^(self floorLog: radix reciprocal) negated
    ].
    radix isInteger ifFalse: [
	^(radix coerce: self) ceilingLog: radix
    ].

    me := self.
    answer := 1.
    [   me > radix ] whileTrue: [
	me := me // radix.
	answer := answer + 1
    ].
    ^answer
!

gcd: anInteger
    "Return the greatest common divisor (Euclid's algorithm) between the
     receiver and anInteger"
    | a b remainder |
    self negative | anInteger negative ifTrue: [ ^self abs gcd: anInteger abs ].

    self < anInteger
	ifTrue: [ a := anInteger. b := self ]
	ifFalse: [ a := self. b := anInteger ].
    [ b = 0 ] whileFalse: [
	remainder := a \\ b.
	a := b.
	b := remainder. ].
    ^a
!

lcm: anInteger
    "Return the least common multiple between the receiver and anInteger"
    ^((self // (self gcd: anInteger)) * anInteger) abs
!

even
    "Return whether the receiver is even"
    ^(self bitAnd: 1) = 0
!

odd
    "Return whether the receiver is odd"
    ^(self bitAnd: 1) ~= 0
! !



!Integer methodsFor: 'converting'!

asCharacter
    "Return self as a Character or UnicodeCharacter object."
    ^Character codePoint: self
!

coerce: aNumber
    "Coerce aNumber to the receiver's class."
    ^aNumber truncated
!

ceiling
    "Return the receiver - it's already truncated"
    ^self
!

floor
    "Return the receiver - it's already truncated"
    ^self
!

truncated
    "Return the receiver - it's already truncated"
    ^self
!

rounded
    "Return the receiver - it's already truncated"
    ^self
!

asScaledDecimal: n
    "Answer the receiver, converted to a ScaledDecimal object.
     The scale is forced to be 0."
    ^ScaledDecimal
        newFromNumber: self asFraction
        scale: 0
!

asFraction
    "Return the receiver converted to a fraction"
    ^Fraction numerator: self denominator: 1
! !



!Integer methodsFor: 'printing'!

printOn: aStream base: b
    "Print on aStream the base b representation of the receiver"
    aStream nextPutAll: (self printString: b)
!

storeOn: aStream base: b
    "Print on aStream Smalltalk code compiling to the receiver, 
     represented in base b"
    aStream nextPutAll: (self printStringRadix: b)
!

radix: baseInteger
    "Return the base b representation of the receiver, with BBr in
     front of it.  This method is deprecated, use #printStringRadix:
     instead."
    ^self printStringRadix: baseInteger
!

printStringRadix: baseInteger
    "Return the base b representation of the receiver, with BBr in
     front of it"
    | sign num string size radixSize |
    sign := self < self zero.
    num := sign ifFalse: [ self ] ifTrue: [ self negated ].

    radixSize := (baseInteger floorLog: 10) + 1.
    size := (num floorLog: baseInteger) + radixSize + 2.
    sign ifTrue: [ size := size + 1 ].

    string := String new: size.
    num replace: string withStringBase: baseInteger.

    string replaceFrom: 1 to: radixSize
        with: (baseInteger printString: 10)
        startingAt: 1.

    string at: radixSize + 1 put: $r.
    sign ifTrue: [ string at: radixSize + 2 put: $- ].
    ^string
!

printString: baseInteger
    "Return the base b representation of the receiver"
    | num string |
    ^self < self zero
	ifFalse: [
	    string := String new: (self floorLog: baseInteger) + 1.
	    self replace: string withStringBase: baseInteger
	]
	ifTrue: [
	    num := self negated.
	    string := String new: (num floorLog: baseInteger) + 2.
	    string at: 1 put: $-.
	    num replace: string withStringBase: baseInteger
	].
!

displayString
    "Return the base 10 representation of the receiver"
    ^self printString: 10
!

printString
    "Return the base 10 representation of the receiver"
    ^self printString: 10
!

displayOn: aStream
    "Print on aStream the base 10 representation of the receiver"
    aStream nextPutAll: (self printString: 10)
!

printOn: aStream
    "Print on aStream the base 10 representation of the receiver"
    aStream nextPutAll: (self printString: 10)
! !



!Integer methodsFor: 'storing'!

storeString
    "Return the base 10 representation of the receiver"
    ^self printString: 10
!

storeOn: aStream
    "Print on aStream the base 10 representation of the receiver"
    aStream nextPutAll: (self printString: 10)
! !



!Integer methodsFor: 'private'!

replace: string withStringBase: b
    "Put in str the reversed base b representation of the receiver
     (which is > 0)"

    | num where |
    num := self.
    where := string size.
    [
	string at: where put: (Character digitValue: (num \\ b)).
	where := where - 1.
	(num := num // b) > 0
    ] whileTrue.
    ^string
! !


!Integer methodsFor: 'testing functionality'!

isRational
    "Answer whether the receiver is rational - true"
    ^true
!

isInteger
    ^true
! !



!Integer methodsFor: 'accessing'!

numerator
    ^self
!

denominator
    ^1
! !

