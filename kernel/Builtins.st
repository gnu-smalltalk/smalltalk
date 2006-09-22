"=====================================================================
|
|   Smalltalk built in methods.  These are read in by the system 
|   initially, to prepare the execution environment.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006
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


!SmallInteger methodsFor: 'built ins'!

+ arg
    "Sum the receiver and arg and answer another Number"
    <primitive: VMpr_SmallInteger_plus>
    ^self generality == arg generality
	ifFalse: [ self retrySumCoercing: arg ]
	ifTrue: [ (LargeInteger fromInteger: self) +
	    (LargeInteger fromInteger: arg) ]
!

- arg
    "Subtract arg from the receiver and answer another Number"
    <primitive: VMpr_SmallInteger_minus>
    ^self generality == arg generality
	ifFalse: [ self retryDifferenceCoercing: arg ]
	ifTrue: [ (LargeInteger fromInteger: self) -
	    (LargeInteger fromInteger: arg) ]
!

< arg
    "Answer whether the receiver is less than arg"
    <primitive: VMpr_SmallInteger_lt>
    ^self retryRelationalOp: #< coercing: arg
!

> arg
    "Answer whether the receiver is greater than arg"
    <primitive: VMpr_SmallInteger_gt>
    ^self retryRelationalOp: #> coercing: arg
!

<= arg
    "Answer whether the receiver is less than or equal to arg"
    <primitive: VMpr_SmallInteger_le>
    ^self retryRelationalOp: #<= coercing: arg
!

>= arg
    "Answer whether the receiver is greater than or equal to arg"
    <primitive: VMpr_SmallInteger_ge>
    ^self retryRelationalOp: #>= coercing: arg
!

= arg
    "Answer whether the receiver is equal to arg"
    <primitive: VMpr_SmallInteger_eq>
    ^self retryEqualityCoercing: arg
!

== arg
    "Answer whether the receiver is the same object as arg"
    <primitive: VMpr_SmallInteger_eq>
    "if they aren't = by the primitive, they're not =="
    ^false
!

~= arg
    "Answer whether the receiver is not equal to arg"
    <primitive: VMpr_SmallInteger_ne>
    ^self retryInequalityCoercing: arg
!

~~ arg
    "Answer whether the receiver is not the same object as arg"
    <primitive: VMpr_SmallInteger_ne>
    ^true			"see comment above for =="
!

* arg
    "Multiply the receiver and arg and answer another Number"
    <primitive: VMpr_SmallInteger_times>
    ^self generality == arg generality
	ifFalse: [ self retryMultiplicationCoercing: arg ]
	ifTrue: [ (LargeInteger fromInteger: self) *
	    (LargeInteger fromInteger: arg) ]
!

/ arg
    "Divide the receiver by arg and answer another Integer or Fraction"
    <primitive: VMpr_SmallInteger_divide>
    " Create a Fraction when it's appropriate "
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^arg class == self class
	ifTrue: [ (Fraction numerator: self denominator: arg) reduce ]
	ifFalse: [ self retryDivisionCoercing: arg ]
!

\\ arg
    "Calculate the remainder of dividing receiver by arg (with truncation
     towards -infinity) and answer it"
    <primitive: VMpr_SmallInteger_modulo>
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^self retry: #\\ coercing: arg
!

// arg
    "Dividing receiver by arg (with truncation towards -infinity) and answer
     the result"
    <primitive: VMpr_SmallInteger_intDiv>
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^self retry: #// coercing: arg
!

quo: arg
    "Dividing receiver by arg (with truncation towards zero) and answer
     the result"
    <primitive: VMpr_SmallInteger_quo>
    arg = 0 ifTrue: [ ^self zeroDivide ].
    ^self retry: #quo: coercing: arg
!

bitAnd: arg
    "Do a bitwise AND between the receiver and arg, answer the result"
    <primitive: VMpr_SmallInteger_bitAnd>
    ^arg isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitAnd: arg ]
!

bitOr: arg
    "Do a bitwise OR between the receiver and arg, answer the result"
    <primitive: VMpr_SmallInteger_bitOr>
    ^arg isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitOr: arg ]
!

bitXor: arg
    "Do a bitwise XOR between the receiver and arg, answer the result"
    <primitive: VMpr_SmallInteger_bitXor>
    ^arg isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitXor: arg ]
!

bitShift: arg
    "Shift the receiver by arg places to the left if arg > 0,
     by arg places to the right if arg < 0, answer another Number"

    <primitive: VMpr_SmallInteger_bitShift>
    ^arg isSmallInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: arg mustBe: Integer ]
	ifTrue: [ (LargeInteger fromInteger: self) bitShift: arg ]
!

asFloatD
    "Convert the receiver to a FloatD, answer the result"
    <primitive: VMpr_SmallInteger_asFloatD>
    self primitiveFailed
!

asFloatE
    "Convert the receiver to a FloatE, answer the result"
    <primitive: VMpr_SmallInteger_asFloatE>
    self primitiveFailed
!

asFloatQ
    "Convert the receiver to a FloatQ, answer the result"
    <primitive: VMpr_SmallInteger_asFloatQ>
    self primitiveFailed
!

asObject
    "Answer the object whose index is in the receiver, nil if there is a free
     object, fail if index is out of bounds"
    <primitive: VMpr_SmallInteger_asObject>
    self primitiveFailed
!

nextValidOop
    "Answer the index of the first non-free OOP after the receiver.  This is
    used internally; it is placed here to avoid polluting Object."
    <primitive: VMpr_SmallInteger_nextValidOop>
    ^nil
!

asObjectNoFail
    "Answer the object whose index is in the receiver, or nil if no object is
     found at that index"
    <primitive: VMpr_SmallInteger_asObject>
    ^nil
! !


!LargeInteger methodsFor: 'built-ins'!

hash
    "Answer an hash value for the receiver"
    <primitive: VMpr_String_hash>
    ^0
!

size
    "Answer the number of indexed instance variable in the receiver"
    <primitive: VMpr_Object_basicSize>
!

digitLength
    "Answer the number of base-256 digits in the receiver"
    <primitive: VMpr_Object_basicSize>
!

at: anIndex
    "Answer the anIndex-th byte in the receiver's representation"
    <primitive: VMpr_Object_basicAt>
    ^self mostSignificantByte
!

at: anIndex put: aNumber
    "Set the anIndex-th byte in the receiver's representation"
    <primitive: VMpr_Object_basicAtPut>

   self checkIndexableBounds: anIndex put: aNumber
!

primReplaceFrom: start to: stop with: replacementString 
    startingAt: replaceStart    
    "Private - Replace the characters from start to stop with new
     characters contained in replacementString (which, actually, can be
     any variable byte class), starting at the replaceStart location of
     replacementString"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^self primitiveFailed
!

digitAt: anIndex
    "Answer the anIndex-th base-256 digit in the receiver's representation"
    <primitive: VMpr_Object_basicAt>
    ^self mostSignificantByte
!

digitAt: anIndex put: aNumber
    "Set the anIndex-th base-256 digit in the receiver's representation"
    <primitive: VMpr_Object_basicAtPut>
    self checkIndexableBounds: anIndex put: aNumber
! !


!LargeInteger methodsFor: 'disabled'!

asObject
    "This method always fails. The number of OOPs is far less than
    the minimum number represented with a LargeInteger."
    self primitiveFailed
!

asObjectNoFail
    ^nil
! !


!FloatD methodsFor: 'built ins'!

+ arg
    "Sum the receiver and arg and answer another Number"
    <primitive: VMpr_FloatD_plus>
    ^self retrySumCoercing: arg
!

- arg
    "Subtract arg from the receiver and answer another Number"
    <primitive: VMpr_FloatD_minus>
    ^self retryDifferenceCoercing: arg
!

< arg
    "Answer whether the receiver is less than arg"
    <primitive: VMpr_FloatD_lt>
    ^self retryRelationalOp: #< coercing: arg
!

> arg
    "Answer whether the receiver is greater than arg"
    <primitive: VMpr_FloatD_gt>
    ^self retryRelationalOp: #> coercing: arg
!

<= arg
    "Answer whether the receiver is less than or equal to arg"
    <primitive: VMpr_FloatD_le>
    ^self retryRelationalOp: #<= coercing: arg
!

>= arg
    "Answer whether the receiver is greater than or equal to arg"
    <primitive: VMpr_FloatD_ge>
    ^self retryRelationalOp: #>= coercing: arg
!

= arg
    "Answer whether the receiver is equal to arg"
    <primitive: VMpr_FloatD_eq>
    ^self retryEqualityCoercing: arg
!

~= arg
    "Answer whether the receiver is not equal to arg"
    <primitive: VMpr_FloatD_ne>
    ^self retryInequalityCoercing: arg
!

* arg
    "Multiply the receiver and arg and answer another Number"
    <primitive: VMpr_FloatD_times>
    ^self retryMultiplicationCoercing: arg
!

/ arg
    "Divide the receiver by arg and answer another FloatD"
    <primitive: VMpr_FloatD_divide>
    ^self generality = arg generality
	ifTrue: [ self zeroDivide ]
	ifFalse: [ self retryDivisionCoercing: arg ]
!

asFloatE
    "Answer the receiver converted to a FloatE"

    <primitive: VMpr_FloatD_asFloatE>
    self primitiveFailed
!

asFloatQ
    "Answer the receiver converted to a FloatQ"

    <primitive: VMpr_FloatD_asFloatQ>
    self primitiveFailed
!

truncated
    "Truncate the receiver towards zero and answer the result"

    <primitive: VMpr_FloatD_truncated>
    ^super truncated
!

fractionPart
    "Answer the fractional part of the receiver"
    <primitive: VMpr_FloatD_fractionPart>
    self checkCoercion.
    ^self primitiveFailed
!

exponent
    "Answer the exponent of the receiver in mantissa*2^exponent
     representation ( |mantissa|<=1 ) "
    <primitive: VMpr_FloatD_exponent>
!

timesTwoPower: arg
    "Answer the receiver multiplied by 2^arg"
    <primitive: VMpr_FloatD_timesTwoPower>
! !


!FloatE methodsFor: 'built ins'!

+ arg
    "Sum the receiver and arg and answer another Number"
    <primitive: VMpr_FloatE_plus>
    ^self retrySumCoercing: arg
!

- arg
    "Subtract arg from the receiver and answer another Number"
    <primitive: VMpr_FloatE_minus>
    ^self retryDifferenceCoercing: arg
!

< arg
    "Answer whether the receiver is less than arg"
    <primitive: VMpr_FloatE_lt>
    ^self retryRelationalOp: #< coercing: arg
!

> arg
    "Answer whether the receiver is greater than arg"
    <primitive: VMpr_FloatE_gt>
    ^self retryRelationalOp: #> coercing: arg
!

<= arg
    "Answer whether the receiver is less than or equal to arg"
    <primitive: VMpr_FloatE_le>
    ^self retryRelationalOp: #<= coercing: arg
!

>= arg
    "Answer whether the receiver is greater than or equal to arg"
    <primitive: VMpr_FloatE_ge>
    ^self retryRelationalOp: #>= coercing: arg
!

= arg
    "Answer whether the receiver is equal to arg"
    <primitive: VMpr_FloatE_eq>
    ^self retryEqualityCoercing: arg
!

~= arg
    "Answer whether the receiver is not equal to arg"
    <primitive: VMpr_FloatE_ne>
    ^self retryInequalityCoercing: arg
!

* arg
    "Multiply the receiver and arg and answer another Number"
    <primitive: VMpr_FloatE_times>
    ^self retryMultiplicationCoercing: arg
!

/ arg
    "Divide the receiver by arg and answer another FloatE"
    <primitive: VMpr_FloatE_divide>
    ^self generality = arg generality
	ifTrue: [ self zeroDivide ]
	ifFalse: [ self retryDivisionCoercing: arg ]
!

asFloatD
    "Answer the receiver converted to a FloatD"

    <primitive: VMpr_FloatE_asFloatD>
    self primitiveFailed
!

asFloatQ
    "Answer the receiver converted to a FloatQ"

    <primitive: VMpr_FloatE_asFloatQ>
    self primitiveFailed
!

truncated
    "Truncate the receiver towards zero and answer the result"

    <primitive: VMpr_FloatE_truncated>
    ^super truncated
!

fractionPart
    "Answer the fractional part of the receiver"
    <primitive: VMpr_FloatE_fractionPart>
    self checkCoercion.
    ^self primitiveFailed
!

exponent
    "Answer the exponent of the receiver in mantissa*2^exponent
     representation ( |mantissa|<=1 ) "
    <primitive: VMpr_FloatE_exponent>
!

timesTwoPower: arg
    "Answer the receiver multiplied by 2^arg"
    <primitive: VMpr_FloatE_timesTwoPower>
! !


!FloatQ methodsFor: 'built ins'!

+ arg
    "Sum the receiver and arg and answer another Number"
    <primitive: VMpr_FloatQ_plus>
    ^self retrySumCoercing: arg
!

- arg
    "Subtract arg from the receiver and answer another Number"
    <primitive: VMpr_FloatQ_minus>
    ^self retryDifferenceCoercing: arg
!

< arg
    "Answer whether the receiver is less than arg"
    <primitive: VMpr_FloatQ_lt>
    ^self retryRelationalOp: #< coercing: arg
!

> arg
    "Answer whether the receiver is greater than arg"
    <primitive: VMpr_FloatQ_gt>
    ^self retryRelationalOp: #> coercing: arg
!

<= arg
    "Answer whether the receiver is less than or equal to arg"
    <primitive: VMpr_FloatQ_le>
    ^self retryRelationalOp: #<= coercing: arg
!

>= arg
    "Answer whether the receiver is greater than or equal to arg"
    <primitive: VMpr_FloatQ_ge>
    ^self retryRelationalOp: #>= coercing: arg
!

= arg
    "Answer whether the receiver is equal to arg"
    <primitive: VMpr_FloatQ_eq>
    ^self retryEqualityCoercing: arg
!

~= arg
    "Answer whether the receiver is not equal to arg"
    <primitive: VMpr_FloatQ_ne>
    ^self retryInequalityCoercing: arg
!

* arg
    "Multiply the receiver and arg and answer another Number"
    <primitive: VMpr_FloatQ_times>
    ^self retryMultiplicationCoercing: arg
!

/ arg
    "Divide the receiver by arg and answer another FloatQ"
    <primitive: VMpr_FloatQ_divide>
    ^self generality = arg generality
	ifTrue: [ self zeroDivide ]
	ifFalse: [ self retryDivisionCoercing: arg ]
!

asFloatD
    "Answer the receiver converted to a FloatD"

    <primitive: VMpr_FloatQ_asFloatD>
    self primitiveFailed
!

asFloatE
    "Answer the receiver converted to a FloatE"

    <primitive: VMpr_FloatQ_asFloatE>
    self primitiveFailed
!

truncated
    "Truncate the receiver towards zero and answer the result"

    <primitive: VMpr_FloatQ_truncated>
    ^super truncated
!

fractionPart
    "Answer the fractional part of the receiver"
    <primitive: VMpr_FloatQ_fractionPart>
    self checkCoercion.
    ^self primitiveFailed
!

exponent
    "Answer the exponent of the receiver in mantissa*2^exponent
     representation ( |mantissa|<=1 ) "
    <primitive: VMpr_FloatQ_exponent>
!

timesTwoPower: arg
    "Answer the receiver multiplied by 2^arg"
    <primitive: VMpr_FloatQ_timesTwoPower>
! !


!Float methodsFor: 'built ins'!

exp
    "Answer 'e' (2.718281828459...) raised to the receiver"
    <primitive: VMpr_Float_exp>
    self primitiveFailed
!

ln
    "Answer the logarithm of the receiver in base 'e' (2.718281828459...)"
    <primitive: VMpr_Float_ln>
    self primitiveFailed
!

raisedTo: aNumber
    "Answer the receiver raised to its aNumber power"
    <primitive: VMpr_Float_pow>
    aNumber isFloat ifTrue: [ self arithmeticError: 'invalid operands' ].
    ^self raisedTo: (self coerce: aNumber)
!

sqrt
    "Answer the square root of the receiver"
    <primitive: VMpr_Float_sqrt>
    self primitiveFailed
!

ceiling
    "Answer the integer part of the receiver, truncated towards +infinity"
    <primitive: VMpr_Float_ceil>
    self checkCoercion.
    ^self > 0
	ifTrue: [ self truncated + self fractionPart sign ]
	ifFalse: [ self truncated ]
!

primHash
    "Private - Answer an hash value for the receiver"
    <primitive: VMpr_String_hash>
    ^0
!

floor
    "Answer the integer part of the receiver, truncated towards -infinity"
    <primitive: VMpr_Float_floor>
    self checkCoercion.
    ^self < 0
	ifTrue: [ self truncated + self fractionPart sign ]
	ifFalse: [ self truncated ]
!

sin
    "Answer the sine of the receiver"
    <primitive: VMpr_Float_sin>
    self primitiveFailed
!

cos
    "Answer the cosine of the receiver"
    <primitive: VMpr_Float_cos>
    self primitiveFailed
!

tan
    "Answer the tangent of the receiver"
    <primitive: VMpr_Float_tan>
!

arcSin
    "Answer the arc-sine of the receiver"
    <primitive: VMpr_Float_arcSin>
    ^self arithmeticError: 'argument out of range'
!

arcCos
    "Answer the arc-cosine of the receiver"
    <primitive: VMpr_Float_arcCos>
    ^self arithmeticError: 'argument out of range'
!

arcTan
    "Answer the arc-tangent of the receiver"
    <primitive: VMpr_Float_arcTan>
! !



!Object methodsFor: 'built ins'!

allOwners
    "Return an Array of Objects that point to the receiver."
    <primitive: VMpr_Object_allOwners>
!

changeClassTo: aBehavior
    "Mutate the class of the receiver to be aBehavior.
     Note: Tacitly assumes that the structure is the same
     for the original and new class!!"
     <primitive: VMpr_Object_changeClassTo>
!

checkIndexableBounds: index 
   "Private - Check the reason why an access to the given indexed
    instance variable failed"

    self class isFixed ifTrue: [ ^SystemExceptions.NotIndexable signalOn: self ].

    index isInteger ifFalse: [ ^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger ].
    (index < 1) ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].
    (index > self basicSize) ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].
!

checkIndexableBounds: index put: object
   "Private - Check the reason why a store to the given indexed
    instance variable failed"

    | shape size |
    self class isFixed ifTrue: [ ^SystemExceptions.NotIndexable signalOn: self ].

    self isReadOnly ifTrue: [ ^SystemExceptions.ReadOnlyObject signal ].

    index isInteger ifFalse: [ ^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger ].
    (index < 1) ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].
    (index > self basicSize) ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    shape := self class shape.
    (shape == #float or: [ shape == #double ]) ifTrue: [
	SystemExceptions.WrongClass signalOn: object mustBe: { Float. SmallInteger } ].

    (object isKindOf: Character) ifFalse: [
        (shape == #character or: [ shape == #utf32 ]) ifTrue: [
	    SystemExceptions.WrongClass signalOn: object mustBe: Character ] ].

    shape == #character ifTrue: [
        ^SystemExceptions.ArgumentOutOfRange
	    signalOn: object
	    mustBeBetween: 0 asCharacter
	    and: 255 asCharacter ].

    shape == #utf32 ifTrue: [
        ^SystemExceptions.ArgumentOutOfRange
	    signalOn: object
	    mustBeBetween: 0 asCharacter
	    and: 16r10FFFF asCharacter ].

    shape == #byte ifTrue: [ size := 8 ].
    shape == #int8 ifTrue: [ size := 7 ].
    shape == #ushort ifTrue: [ size := 16 ].
    shape == #short ifTrue: [ size := 15 ].
    shape == #uint ifTrue: [ size := 32 ].
    shape == #int ifTrue: [ size := 31 ].
    shape == #uint64 ifTrue: [ size := 64 ].
    shape == #int64 ifTrue: [ size := 63 ].
    size isNil ifTrue: [ ^self primtiveFailed ].

    ^SystemExceptions.ArgumentOutOfRange
        signalOn: object
        mustBeBetween: (size odd ifTrue: [ -1 bitShift: size ] ifFalse: [ 0 ])
        and: (1 bitShift: size) - 1
!

at: anIndex
    "Answer the index-th indexed instance variable of the receiver"
    <primitive: VMpr_Object_basicAt>
    self checkIndexableBounds: anIndex
!

basicAt: anIndex
    "Answer the index-th indexed instance variable of the receiver.
     This method must not be overridden, override at: instead"
    <primitive: VMpr_Object_basicAt>
    self checkIndexableBounds: anIndex
!

at: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver"
    <primitive: VMpr_Object_basicAtPut>
   self checkIndexableBounds: anIndex put: value
!

basicAt: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver
     This method must not be overridden, override at:put: instead"

    <primitive: VMpr_Object_basicAtPut>
    self checkIndexableBounds: anIndex put: value
!

size
    "Answer the number of indexed instance variable in the receiver"
    <primitive: VMpr_Object_basicSize>
!

basicSize
    "Answer the number of indexed instance variable in the receiver"
    <primitive: VMpr_Object_basicSize>
!

become: otherObject
    "Change all references to the receiver into references to otherObject.
     Depending on the implementation, references to otherObject might or
     might not be transformed into the receiver (respectively,
     'two-way become' and 'one-way become').
     Implementations doing one-way become answer the receiver (so that it is
     not lost). Most implementations doing two-way become answer otherObject,
     but this is not assured - so do answer the receiver for consistency.
     GNU Smalltalk does two-way become and answers otherObject, but this
     might change in future versions: programs should not rely on the behavior
     and results of #become: ."
    <primitive: VMpr_Object_become>

    ^SystemExceptions.ReadOnlyObject signal
!

shallowCopy
    "Returns a shallow copy of the receiver (the instance variables are
     not copied)"
    | class aCopy |

    "This is a primitive for speed.  An alternative implementation is
     found below."
    <primitive: VMpr_Object_shallowCopy>

    class := self class.
    class isVariable
        ifTrue: [ aCopy := class basicNew: self basicSize ]
        ifFalse: [ aCopy := class basicNew ].

    " copy the instance variables (if any) "
    1 to: class instSize + self basicSize do: [ :i |
        aCopy instVarAt: i put: (self instVarAt: i).
    ].
    ^aCopy
!

makeFixed
    "Avoid that the receiver moves in memory across garbage collections."

    <primitive: VMpr_Object_makeFixed>

    "We are an integer - fail"
    SystemExceptions.InvalidValue signalOn: self reason:
	'Instances of Integer cannot be tenured!'
!

tenure
    "Move the object to oldspace."

    <primitive: VMpr_Object_tenure>

    "We are an integer - they won't notice the difference so don't
     fail."
!

instVarAt: index
    "Answer the index-th instance variable of the receiver.
     This method must not be overridden."
    <primitive: VMpr_Object_instVarAt>
    (index < 1)
	ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].
    index isInteger ifFalse: [ ^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger ].

    index > (self basicSize + self class instSize)
	ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    ^self basicAt: index - self class instSize
!

instVarAt: index put: value
    "Store value in the index-th instance variable of the receiver.
     This method must not be overridden."
    <primitive: VMpr_Object_instVarAtPut>
    self isReadOnly ifTrue: [ ^SystemExceptions.ReadOnlyObject signal ].

    (index < 1)
	ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].
    index isInteger ifFalse: [ ^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger ].

    index > (self basicSize + self class instSize)
	ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    ^self basicAt: index - self class instSize put: value
!

isReadOnly
    "Answer whether the object's indexed instance variables can be
     written"

    <primitive: VMpr_Object_isReadOnly>
!

isUntrusted
    "Answer whether the object is to be considered untrusted."

    <primitive: VMpr_Object_isUntrusted>
!

makeReadOnly: aBoolean
    "Set whether the object's indexed instance variables can be written"

    <primitive: VMpr_Object_makeReadOnly>
    SystemExceptions.WrongClass signalOn: aBoolean mustBe: Boolean
!

makeUntrusted: aBoolean
    "Set whether the object is to be considered untrusted."

    <primitive: VMpr_Object_makeUntrusted>
    SystemExceptions.WrongClass signalOn: aBoolean mustBe: Boolean
!

makeWeak
    "Make the object a 'weak' one. When an object is only referenced by weak
     objects, it is collected and the slots in the weak objects are changed to
     nils by the VM; the weak object is then sent the #mourn message."

    <primitive: VMpr_Object_makeWeak>
!

makeEphemeron
    "Make the object an 'ephemeron'.  An ephemeron is marked after all
     other objects, and if no references are found to the key except from
     the object itself, it is sent the #mourn message."

    <primitive: VMpr_Object_makeEphemeron>
    SystemExceptions.InvalidValue signalOn: self reason:
	'ephemerons should have at least one instance variables'
!

asOop
    "Answer the object index associated to the receiver. The object
     index doesn't change when garbage collection is performed."
    <primitive: VMpr_Object_hash>
    
    "We are an integer - fail"
    SystemExceptions.InvalidValue signalOn: self reason:
	'Instances of Integer have no associated OOP!'
!

identityHash
    "Answer an hash value for the receiver. This method must not be
     overridden"
    <primitive: VMpr_Object_hash>
    
    "We are an integer - answer the receiver"
    ^self
!

hash
    "Answer an hash value for the receiver. This hash value is ok
     for objects that do not redefine ==."

    <primitive: VMpr_Object_hash>

    "We are an integer - answer the receiver"
    ^self
!

nextInstance
    "Private - answer another instance of the receiver's class, or
     nil if the entire object table has been walked"
    <primitive: VMpr_Object_nextInstance>
    ^nil
!

perform: selectorOrMessageOrMethod
    "Send the unary message named selectorOrMessageOrMethod (if a Symbol)
     to the receiver, or the message and arguments it identifies (if a Message
     or DirectedMessage), or finally execute the method within the receiver
     (if a CompiledMethod).  In the last case, the method need not reside on
     the hierarchy from the receiver's class to Object -- it need not reside
     at all in a MethodDictionary, in fact -- but doing bad things will
     compromise stability of the Smalltalk virtual machine (and don't blame
     anybody but yourself).

     This method should not be overridden"
    <primitive: VMpr_Object_perform>
    selectorOrMessageOrMethod isSymbol ifTrue: [
	(self respondsTo: selectorOrMessageOrMethod)
	    ifTrue: [ ^SystemExceptions.WrongArgumentCount signal ]
	    ifFalse: [ self doesNotUnderstand: (Message
		selector: selectorOrMessageOrMethod
		arguments: #()) ]
    ].
    (selectorOrMessageOrMethod isKindOf: CompiledMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ].

    ^selectorOrMessageOrMethod sendTo: self
!

perform: selectorOrMethod with: arg1
    "Send the message named selectorOrMethod (if a Symbol) to the receiver,
     passing arg1 to it, or execute the method within the receiver
     (if a CompiledMethod).  In the latter case, the method need not reside on
     the hierarchy from the receiver's class to Object -- it need not reside
     at all in a MethodDictionary, in fact -- but doing bad things will
     compromise stability of the Smalltalk virtual machine (and don't blame
     anybody but yourself).

     This method should not be overridden"
    <primitive: VMpr_Object_perform>
    (selectorOrMethod isKindOf: CompiledMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ].
    selectorOrMethod isSymbol
	ifFalse: [ SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol ].

    (self respondsTo: selectorOrMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ]
	ifFalse: [ self doesNotUnderstand: (Message
	    selector: selectorOrMethod
	    arguments: {arg1}) ]
!

perform: selectorOrMethod with: arg1 with: arg2
    "Send the message named selectorOrMethod (if a Symbol) to the receiver,
     passing arg1 and arg2 to it, or execute the method within the receiver
     (if a CompiledMethod).  In the latter case, the method need not reside on
     the hierarchy from the receiver's class to Object -- it need not reside
     at all in a MethodDictionary, in fact -- but doing bad things will
     compromise stability of the Smalltalk virtual machine (and don't blame
     anybody but yourself).

     This method should not be overridden"
    <primitive: VMpr_Object_perform>
    (selectorOrMethod isKindOf: CompiledMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ].
    selectorOrMethod isSymbol
	ifFalse: [ SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol ].

    (self respondsTo: selectorOrMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ]
	ifFalse: [ self doesNotUnderstand: (Message
	    selector: selectorOrMethod
	    arguments: { arg1. arg2 }) ]
!

perform: selectorOrMethod with: arg1 with: arg2 with: arg3
    "Send the message named selectorOrMethod (if a Symbol) to the receiver,
     passing the other arguments to it, or execute the method within the
     receiver (if a CompiledMethod).  In the latter case, the method need not
     reside on the hierarchy from the receiver's class to Object -- it need
     not reside at all in a MethodDictionary, in fact -- but doing bad things
     will compromise stability of the Smalltalk virtual machine (and don't
     blame anybody but yourself).

     This method should not be overridden"
    <primitive: VMpr_Object_perform>
    (selectorOrMethod isKindOf: CompiledMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ].
    selectorOrMethod isSymbol
	ifFalse: [ SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol ].

    (self respondsTo: selectorOrMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ]
	ifFalse: [ self doesNotUnderstand: (Message
	    selector: selectorOrMethod
	    arguments: { arg1. arg2. arg3 }) ]
!

perform: selectorOrMethod with: arg1 with: arg2 with: arg3 with: arg4
    "Send the message named selectorOrMethod (if a Symbol) to the receiver,
     passing the other arguments to it, or execute the method within the
     receiver (if a CompiledMethod).  In the latter case, the method need not
     reside on the hierarchy from the receiver's class to Object -- it need
     not reside at all in a MethodDictionary, in fact -- but doing bad things
     will compromise stability of the Smalltalk virtual machine (and don't
     blame anybody but yourself).

     This method should not be overridden"
    <primitive: VMpr_Object_perform>
    (selectorOrMethod isKindOf: CompiledMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ].
    selectorOrMethod isSymbol
	ifFalse: [ SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol ].

    (self respondsTo: selectorOrMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ]
	ifFalse: [ self doesNotUnderstand: (Message
	    selector: selectorOrMethod
	    arguments: { arg1. arg2. arg3. arg4 }) ]
!

perform: selectorOrMethod withArguments: argumentsArray
    "Send the message named selectorOrMethod (if a Symbol) to the receiver,
     passing the elements of argumentsArray as parameters, or execute the
     method within the receiver (if a CompiledMethod).  In the latter case,
     the method need not reside on the hierarchy from the receiver's class
     to Object -- it need not reside at all in a MethodDictionary, in
     fact -- but doing bad things will compromise stability of the Smalltalk
     virtual machine (and don't blame anybody but yourself).

     This method should not be overridden"
    <primitive: VMpr_Object_performWithArguments>
    argumentsArray isArray 
	ifFalse: [ SystemExceptions.WrongClass signalOn: argumentsArray mustBe: Array ].
    (selectorOrMethod isKindOf: CompiledMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ].
    selectorOrMethod isSymbol
	ifFalse: [ SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol ].

    (self respondsTo: selectorOrMethod)
	ifTrue: [ SystemExceptions.WrongArgumentCount signal ]
	ifFalse: [ self doesNotUnderstand: (Message
	    selector: selectorOrMethod
	    arguments: argumentsArray) ]
!

== arg
    "Answer whether the receiver is the same object as arg. This is a
     very fast test and is called 'object identity'. "
    <primitive: VMpr_Object_identity>
!

= arg
    "Answer whether the receiver is equal to arg. The equality test is
     by default the same as that for identical objects. = must not fail;
     answer false if the receiver cannot be compared to arg"
    <primitive: VMpr_Object_identity>
!

class
    "Answer the class to which the receiver belongs"
    <primitive: VMpr_Object_class>
    self primitiveFailed
!

error: message
    "Stop the execution and/or bring up a debugger. message is an error
     message to be shown"
    <primitive: VMpr_Object_bootstrapError>
!

basicPrint
    "Print a basic representation of the receiver"
    <primitive: VMpr_Object_basicPrint>
!

"### look these messages up to be sure"

halt
    "Called to enter the debugger"
    ^self halt: 'halt encountered'
!

halt: aString
    "Called to enter the debugger"
    ^self error: aString
!

mark: aSymbol
    "Private - use this method to mark code which needs to be reworked,
     removed, etc. You can then find all senders of #mark: to find all marked
     methods or you can look for all senders of the symbol that you sent to
     #mark: to find a category of marked methods."
!

primitiveFailed
    "Called when a VM primitive fails"
    SystemExceptions.PrimitiveFailed signal
!

shouldNotImplement
    "Called when objects belonging to a class should not answer a
     selector defined by a superclass"

    SystemExceptions.ShouldNotImplement signal
!

subclassResponsibility
    "Called when a method defined by a class should be overridden
     in a subclass"

    SystemExceptions.SubclassResponsibility signal
!

notYetImplemented
    "Called when a method defined by a class is not yet implemented,
     but is going to be"

    SystemExceptions.NotYetImplemented signal
! !


!Object methodsFor: 'VM callbacks'!

doesNotUnderstand: message
    "Called by the system when a selector was not found. message is a
     Message containing information on the receiver"
    <primitive: VMpr_Object_bootstrapDNU>
!

badReturnError
    "Called back when a block performs a bad return."

    SystemExceptions.BadReturn signal
!

mustBeBoolean
    "Called by the system when ifTrue:*, ifFalse:*, and: or or: are sent to
     anything but a boolean"

    | result |
    result := SystemExceptions.MustBeBoolean signalOn: self.
    result == false ifFalse: [ result := true ].
    ^result
!

noRunnableProcess
    "Called back when all processes are suspended"
    SystemExceptions.NoRunnableProcess signal
!

userInterrupt
    "Called back when the user presses Ctrl-Break"
    SystemExceptions.UserInterrupt signal
! !


!SmallInteger methodsFor: 'builtins'!

scramble
    "Answer the receiver with its bits mixed and matched."
    <primitive: VMpr_SmallInteger_scramble>
    self primitiveFailed
!

at: anIndex
    "Answer the index-th indexed instance variable of the receiver.
     This method always fails."
    SystemExceptions.NotIndexable signalOn: self
!

basicAt: anIndex
    "Answer the index-th indexed instance variable of the receiver.
     This method always fails."
    SystemExceptions.NotIndexable signalOn: self
!

at: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver
     This method always fails."

    SystemExceptions.NotIndexable signalOn: self
!

basicAt: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver
     This method always fails."

    SystemExceptions.NotIndexable signalOn: self
! !



!ObjectMemory class methodsFor: 'builtins'!

addressOfOOP: anObject
    "Returns the address of the OOP (object table slot) for anObject.
     The address is an Integer and will not change over time (i.e. is
     immune from garbage collector action) except if the virtual machine
     is stopped and restarted."

    <primitive: VMpr_Memory_addressOfOOP>
    SystemExceptions InvalidArgument
	signalOn: anObject
	reason: 'Cannot extract address of an immediate OOP'
!

addressOf: anObject
    "Returns the address of the actual object that anObject
     references.  Note that, with the exception of fixed objects
     this address is only valid until the next garbage collection;
     thus it's pretty risky to count on the address returned by
     this method for very long."
    <primitive: VMpr_Memory_addressOf>
    SystemExceptions InvalidArgument
	signalOn: anObject
	reason: 'Cannot extract address of an immediate OOP'
!

scavenge
    "Force a minor garbage collection"
    <primitive: VMpr_ObjectMemory_scavenge>
    ^self primitiveFailed
!

globalGarbageCollect
    "Force a full garbage collection"
    <primitive: VMpr_ObjectMemory_globalGarbageCollect>
    ^self primitiveFailed
!

compact
    "Force a full garbage collection, including compaction of oldspace"
    <primitive: VMpr_ObjectMemory_compact>
    ^self primitiveFailed
!

incrementalGCStep
    "Do a step in the incremental garbage collection."
    <primitive: VMpr_ObjectMemory_incrementalGCStep>
    ^self primitiveFailed
!

finishIncrementalGC
    "Do a step in the incremental garbage collection."
    <primitive: VMpr_ObjectMemory_finishIncrementalGC>
    ^self primitiveFailed
!

abort
    "Quit the Smalltalk environment, dumping core."
    <primitive: VMpr_ObjectMemory_abort>
!

quit
    "Quit the Smalltalk environment. Whether files are closed and
     other similar cleanup occurs depends on the platform"
    self quit: 0
!

quit: exitStatus
    "Quit the Smalltalk environment, passing the exitStatus integer
     to the OS. Files are closed and other similar cleanups occur."
    <primitive: VMpr_ObjectMemory_quit>
    SystemExceptions.WrongClass signalOn: exitStatus mustBe: SmallInteger
!

smoothingFactor
    "Answer the factor (between 0 and 1) used to smooth the statistics
     provided by the virtual machine about memory handling.  0 disables
     updating the averages, 1 disables the smoothing (the statistics
     return the last value)."
    <primitive: VMpr_ObjectMemory_getSmoothingFactor>
    ^self primitiveFailed
!

smoothingFactor: rate
    "Set the factor (between 0 and 1) used to smooth the statistics
     provided by the virtual machine about memory handling.  0 disables
     updating the averages, 1 disables the smoothing (the statistics
     return the last value)."
    <primitive: VMpr_ObjectMemory_setSmoothingFactor>
    rate class == FloatD
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: rate mustBeBetween: 0 and: 1 ]
	ifFalse: [ ^self spaceGrowRate: rate asFloatD ]
!

spaceGrowRate
    "Answer the rate with which the amount of memory used by the system grows"
    <primitive: VMpr_ObjectMemory_getSpaceGrowRate>
    ^self primitiveFailed
!

spaceGrowRate: rate
    "Set the rate with which the amount of memory used by the system grows"
    <primitive: VMpr_ObjectMemory_setSpaceGrowRate>
    rate class == FloatD
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: rate mustBeBetween: 0.01 and: 500.0 ]
	ifFalse: [ ^self spaceGrowRate: rate asFloatD ]
!

bigObjectThreshold
   "Answer the smallest size for objects that are allocated outside
    the main heap in the hope of providing more locality of reference
    between small objects."
    <primitive: VMpr_ObjectMemory_getBigObjectThreshold>
    ^self primitiveFailed
!

bigObjectThreshold: bytes
   "Set the smallest size for objects that are allocated outside
    the main heap in the hope of providing more locality of reference
    between small objects.  bytes must be a positive SmallInteger."

    <primitive: VMpr_ObjectMemory_setBigObjectThreshold>
    bytes isSmallInteger
	ifTrue: [ SystemExceptions.ArgumentOutOfRange
	    signalOn: bytes mustBeBetween: 0 and: SmallInteger largest ]
	ifFalse: [ SystemExceptions.WrongClass
	    signalOn: bytes mustBe: SmallInteger ]
!

growThresholdPercent
    "Answer the percentage of the amount of memory used by the system grows
     which has to be full for the system to allocate more memory"
    <primitive: VMpr_ObjectMemory_getGrowThresholdPercent>
    ^self primitiveFailed
!

growThresholdPercent: growPercent
    "Set the percentage of the amount of memory used by the system grows
     which has to be full for the system to allocate more memory"
    <primitive: VMpr_ObjectMemory_setGrowThresholdPercent>

    growPercent class == FloatD
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: growPercent mustBeBetween: 0.01 and: 100.0 ]
	ifFalse: [ ^self growThresholdPercent: growPercent asFloatD ]
!


growTo: numBytes
    "Grow the amount of memory used by the system grows to numBytes."
    <primitive: VMpr_ObjectMemory_growTo>
    ^self primitiveFailed
!

snapshot: aString
    "Save an image on the aString file"
    <primitive: VMpr_ObjectMemory_snapshot>
    ^aString isString
	ifFalse: [ SystemExceptions.WrongClass signalOn: aString mustBe: String ]
	ifTrue: [ File checkError ]
!

gcMessage
    "Answer whether messages indicating that garbage collection is taking
     place are printed on stdout"
    ^Smalltalk getTraceFlag: 3
!

gcMessage: aBoolean 
    "Set whether messages indicating that garbage collection is taking
     place are printed on stdout"
    ^Smalltalk setTraceFlag: 3 to: aBoolean
! !


!ObjectMemory methodsFor: 'builtins'!

update
    "Update the values in the object to the current state of the VM."
    <primitive: VMpr_ObjectMemory_update>
    self primitiveFailed
! !


!SystemDictionary methodsFor: 'builtins'!

basicBacktrace
    "Prints the method invocation stack backtrace, as an aid to debugging"
    <primitive: VMpr_SystemDictionary_backtrace>
    self primitiveFailed
!

backtrace
    "Prints the method invocation stack backtrace, as an aid to debugging"
    <primitive: VMpr_SystemDictionary_backtrace>
    self primitiveFailed
!

getTraceFlag: anIndex
    "Private - Returns a boolean value which is one of the interpreter's
     tracing flags"
    <primitive: VMpr_SystemDictionary_getTraceFlag>
    self primitiveFailed
!

setTraceFlag: anIndex to: aBoolean
    "Private - Sets the value of one of the interpreter's tracing flags
    (indicated by 'anIndex') to the value aBoolean."
    <primitive: VMpr_SystemDictionary_setTraceFlag>
    self primitiveFailed
!

byteCodeCounter
    "Answer the number of bytecodes executed by the VM"
    <primitive: VMpr_SystemDictionary_byteCodeCounter>
!

debug
    "This methods provides a way to break in the VM code.  Set a breakpoint
     in _gst_debug and call this method near the point where you think
     the bug happens."
    <primitive: VMpr_SystemDictionary_debug>
!


"==========================================================================
 These are so useful throughout the loading of the kernel methods that I
 make an exception here and put in real methods instead of just primitives.
 "

executionTrace
    "Answer whether executed bytecodes are printed on stdout"
    ^self getTraceFlag: 1
!

executionTrace: aBoolean
    "Set whether executed bytecodes are printed on stdout"
    ^self setTraceFlag: 1 to: aBoolean
!

declarationTrace
    "Answer whether compiled bytecodes are printed on stdout"
    ^self getTraceFlag: 0
!

declarationTrace: aBoolean
    "Set whether compiled bytecodes are printed on stdout"
    ^self setTraceFlag: 0 to: aBoolean
!

verboseTrace
    "Answer whether execution tracing prints the object on the stack top"
    ^self getTraceFlag: 2
!

verboseTrace: aBoolean
    "Set whether execution tracing prints the object on the stack top"
    ^self setTraceFlag: 2 to: aBoolean
! !


!Behavior methodsFor: 'built ins'!

flushCache
    "Invalidate the method cache kept by the virtual machine. This
     message should not need to be called by user programs."
    <primitive: VMpr_Behavior_flushCache>
    ^self primitiveFailed
!

new
    "Create a new instance of a class with no indexed instance variables"
    <primitive: VMpr_Behavior_basicNew>
    self isFixed ifFalse: [ ^self new: 0 ].
    ^self primitiveFailed
!

basicNew
    "Create a new instance of a class with no indexed instance variables;
     this method must not be overridden."
    <primitive: VMpr_Behavior_basicNew>
    self isFixed ifFalse: [ ^self basicNew: 0 ].
    ^self primitiveFailed
!

new: numInstanceVariables
    "Create a new instance of a class with indexed instance variables. The
     instance has numInstanceVariables indexed instance variables."
    <primitive: VMpr_Behavior_basicNewColon>
    self isFixed ifTrue: [
	SystemExceptions.WrongMessageSent signalOn: #new: useInstead: #new
    ].
    numInstanceVariables isSmallInteger ifTrue: [ ^self primitiveFailed ].

    ^SystemExceptions.WrongClass signalOn: numInstanceVariables mustBe: SmallInteger
!

basicNew: numInstanceVariables
    "Create a new instance of a class with indexed instance variables. The
     instance has numInstanceVariables indexed instance variables;
     this method must not be overridden."
    <primitive: VMpr_Behavior_basicNewColon>
    self isFixed ifTrue: [
	SystemExceptions.WrongMessageSent signalOn: #basicNew: useInstead: #basicNew
    ].
    numInstanceVariables isSmallInteger ifTrue: [ ^self primitiveFailed ].

    ^SystemExceptions.WrongClass signalOn: numInstanceVariables mustBe: SmallInteger
!

basicNewInFixedSpace: numInstanceVariables
    "Create a new instance of a class with indexed instance variables. The
     instance has numInstanceVariables indexed instance variables.  The
     instance is guaranteed not to move across garbage collections.  Like
     #basicNew:, this method should not be overridden."
    <primitive: VMpr_Behavior_basicNewFixedColon>
    self isFixed ifTrue: [
	SystemExceptions.WrongMessageSent signalOn: #basicNewInFixedSpace:
	    useInstead: #basicNewInFixedSpace
    ].
    numInstanceVariables isSmallInteger ifTrue: [ ^self primitiveFailed ].

    ^SystemExceptions.WrongClass signalOn: numInstanceVariables mustBe: SmallInteger
!

basicNewInFixedSpace
    "Create a new instance of a class with no indexed instance variables.
     The instance is guaranteed not to move across garbage collections.
     Like #basicNew, this method should not be overridden."
    <primitive: VMpr_Behavior_basicNewFixed>
    self isFixed ifTrue: [ ^self primitiveFailed ].
    SystemExceptions.WrongMessageSent signalOn: #basicNewInFixedSpace
	useInstead: #basicNewInFixedSpace:
!

someInstance
    "Private - Answer the first instance of the receiver in the object
     table"
    <primitive: VMpr_Behavior_someInstance>
    ^nil			"return nil on failure"
!

methodsFor: category ifTrue: condition
    "Compile the following code inside the receiver, with the given
     category, if condition is true; else ignore it"
    <primitive: VMpr_Behavior_methodsForIfTrue>
    ^self primitiveFailed
!

compileString: aString
    "Compile the code in aString, with no category. Fail if the code
     does not obey Smalltalk syntax. Answer the generated CompiledMethod
     if it does"
    <primitive: VMpr_Behavior_compileString>
    ^self primitiveFailed
!

compileString: aString ifError: aBlock
    "Compile the code in aString, with no category. Evaluate aBlock
     (passing the file name, line number and description of the error) if
     the code does not obey Smalltalk syntax. Answer the generated
     CompiledMethod if it does"
    <primitive: VMpr_Behavior_compileStringIfError>
    ^self primitiveFailed
! !


!ContextPart class methodsFor: 'built ins'!

thisContext
    "Return the value of the thisContext variable.  Called internally
     when the variable is accessed."

    <primitive: VMpr_ContextPart_thisContext>
! !

!ContextPart methodsFor: 'built ins'!

continue: anObject
    "Resume execution from the receiver, faking that the context on
     top of it in the execution chain has returned anObject.  The
     receiver must belong to the same process as the executing context,
     otherwise the results are not predictable.  All #ensure: (and
     possibly #ifCurtailed:) blocks between the currently executing
     context and the receiver are evaluated (which is not what
     would happen if you directly bashed at the parent context of
     thisContext)."

    <primitive: VMpr_ContextPart_continue>
    self badReturnError
! !


!BlockClosure methodsFor: 'built ins'!

value
    "Evaluate the receiver passing no parameters"
    <primitive: VMpr_BlockClosure_value>
    SystemExceptions.WrongArgumentCount signal
!

value: arg1
    "Evaluate the receiver passing arg1 as the only parameter"
    <primitive: VMpr_BlockClosure_value>
    SystemExceptions.WrongArgumentCount signal
!

value: arg1 value: arg2
    "Evaluate the receiver passing arg1 and arg2 as the parameters"
    <primitive: VMpr_BlockClosure_value>
    SystemExceptions.WrongArgumentCount signal
!

value: arg1 value: arg2 value: arg3
    "Evaluate the receiver passing arg1, arg2 and arg3 as the parameters"
    <primitive: VMpr_BlockClosure_value>
    SystemExceptions.WrongArgumentCount signal
!

valueWithArguments: argumentsArray
    "Evaluate the receiver passing argArray's elements as the parameters"
    <primitive: VMpr_BlockClosure_valueWithArguments>
    argumentsArray isArray 
	ifFalse: [ SystemExceptions.WrongClass signalOn: argumentsArray mustBe: Array ].

    SystemExceptions.WrongArgumentCount signal
! !

!BlockClosure methodsFor: 'private'!

valueAndResumeOnUnwind
    "Private - For use by #ensure:"
    <primitive: VMpr_BlockClosure_valueAndResumeOnUnwind>
    SystemExceptions.WrongArgumentCount signal
! !
    


!ArrayedCollection methodsFor: 'built ins'!

size
    "Answer the size of the receiver"
    <primitive: VMpr_Object_basicSize>

! !



!ByteArray class methodsFor: 'instance creation'!

fromCData: aCObject size: anInteger
    "Answer a ByteArray containing anInteger bytes starting at the location pointed
     to by aCObject"
    <primitive: VMpr_String_fromCData>
    ^SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger
! !



!String class methodsFor: 'instance creation'!

fromCData: aCObject
    "Answer a String containing the bytes starting at the location pointed
     to by aCObject, up to the first NUL character."
    <primitive: VMpr_String_fromCData>
    ^self primitiveFailed!

fromCData: aCObject size: anInteger
    "Answer a String containing anInteger bytes starting at the location pointed
     to by aCObject"
    <primitive: VMpr_String_fromCData_size>
    ^SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger
! !



!String methodsFor: 'built ins'!

hash
    "Answer an hash value for the receiver"
    <primitive: VMpr_String_hash>
    ^0
!

similarityTo: aString
    "Answer a number that denotes the similarity between aString and
     the receiver.  0 indicates equality, negative numbers indicate
     some difference.  Implemented as a primitive for speed."
    <primitive: VMpr_String_similarityTo>
    ^SystemExceptions.WrongClass signalOn: aString mustBe: String
!
    
size
    "Answer the size of the receiver"
    <primitive: VMpr_Object_basicSize>
    ^self primitiveFailed
!

replaceFrom: start to: stop withByteArray: byteArray startingAt: replaceStart
    "Replace the characters from start to stop with new characters whose
     ASCII codes are contained in byteArray, starting at the replaceStart
     location of byteArray"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^super replaceFrom: start to: stop with: byteArray asString startingAt: replaceStart
!

replaceFrom: start to: stop with: aString startingAt: replaceStart
    "Replace the characters from start to stop with new characters whose
     ASCII codes are contained in aString, starting at the replaceStart
     location of aString"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^super replaceFrom: start to: stop with: aString startingAt: replaceStart
!

primReplaceFrom: start to: stop with: replacementString 
    startingAt: replaceStart    
    "Private - Replace the characters from start to stop with new
     characters contained in replacementString (which, actually, can be
     any variable byte class, starting at the replaceStart location of
     replacementString"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^self primitiveFailed
!

at: anIndex
    "Answer the index-th indexed instance variable of the receiver"
    <primitive: VMpr_Object_basicAt>
    self checkIndexableBounds: anIndex
!

basicAt: anIndex
    "Answer the index-th indexed instance variable of the receiver.
     This method must not be overridden, override at: instead"
    <primitive: VMpr_Object_basicAt>
    self checkIndexableBounds: anIndex
!

at: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver"
    <primitive: VMpr_Object_basicAtPut>
   self checkIndexableBounds: anIndex put: value
!

basicAt: anIndex put: value
    "Store value in the index-th indexed instance variable of the receiver
     This method must not be overridden, override at:put: instead"

    <primitive: VMpr_Object_basicAtPut>
    self checkIndexableBounds: anIndex put: value
!

asCData: aCType
    "Convert the receiver to a CObject with the given type"
    <primitive: VMpr_String_asCData>
    ^self primitiveFailed
! !

!UnicodeString methodsFor: 'built-ins'!

hash
    "Answer an hash value for the receiver"
    <primitive: VMpr_String_hash>
    ^0
!



!CharacterArray methodsFor: 'built ins'!

valueAt: index
    "Answer the ascii value of index-th character variable of the receiver"
    | shape size |

    <primitive: VMpr_CharacterArray_valueAt>

    shape := self class shape.
    (shape == #character or: [ shape == #utf32 ]) ifFalse: [ ^self subclassResponsibility ].
    self class isFixed ifTrue: [ ^self subclassResponsibility ].

    index isInteger ifFalse: [ ^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger ].
    ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index
!
 
valueAt: index put: value
    "Store (Character value: value) in the index-th indexed instance variable
     of the receiver"
    | shape size |

    <primitive: VMpr_CharacterArray_valueAtPut>

    shape := self class shape.
    (shape == #character or: [ shape == #utf32 ]) ifFalse: [ ^self subclassResponsibility ].
    self class isFixed ifTrue: [ ^self subclassResponsibility ].

    self isReadOnly ifTrue: [ ^SystemExceptions.ReadOnlyObject signal ].

    index isInteger ifFalse: [ ^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger ].
    (index < 1) ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].
    (index > self basicSize) ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    value isInteger ifFalse: [
            SystemExceptions.WrongClass signalOn: value mustBe: SmallInteger ].

    shape == #character ifTrue: [
        ^SystemExceptions.ArgumentOutOfRange signalOn: value mustBeBetween: 0 and: 255 ].

    ^SystemExceptions.ArgumentOutOfRange signalOn: value mustBeBetween: 0 and: 16r10FFFF
! !


!Symbol class methodsFor: 'built ins'!

intern: aString
    "Private - Same as 'aString asSymbol'"
    <primitive: VMpr_Symbol_intern>
    SystemExceptions.WrongClass signalOn: aString mustBe: String
! !



!Symbol methodsFor: 'built ins'!

= aSymbol
    "Answer whether the receiver and aSymbol are the same object"
    <primitive: VMpr_Object_identity>
    ^false
!

hash
    "Answer an hash value for the receiver. Symbols are optimized
     for speed"
    <primitive: VMpr_Object_hash>

! !



!UnicodeCharacter class methodsFor: 'built ins'!

value: anInteger
    "Returns the character object, possibly a Character, corresponding
     to anInteger.  Error if anInteger is not an integer, or not in
     0..16r10FFFF.

     This is only a primitive for speed.  UnicodeCharacter's #value:
     method is equivalent to #codePoint: (which is the same for
     Character and UnicodeCharacter)."
     <primitive: VMpr_UnicodeCharacter_create>

    anInteger isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ]
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger mustBeBetween: 0 and: 16r10FFFF ]
! !


!Character class methodsFor: 'built ins'!

codePoint: anInteger
    "Returns the character object, possibly an UnicodeCharacter, corresponding
     to anInteger.  Error if anInteger is not an integer, or not in 0..16r10FFFF."
     <primitive: VMpr_UnicodeCharacter_create>

    anInteger isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ]
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger mustBeBetween: 0 and: 16r10FFFF ]
!

asciiValue: anInteger
    "Returns the character object corresponding to anInteger.  Error if
     anInteger is not an integer, or not in 0..127."

    anInteger isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ].

    ^(self between: 0 and: 127)
	ifTrue: [ self value: anInteger ]
	ifFalse: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger mustBeBetween: 0 and: 127 ]
!

value: anInteger
    "Returns the character object corresponding to anInteger.  Error if
     anInteger is not an integer, or not in 0..255."
     <primitive: VMpr_Character_create>

    anInteger isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ]
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger mustBeBetween: 0 and: 255 ]
! !



!Character methodsFor: 'built ins'!

= char
    "Boolean return value; true if the characters are equal"
    <primitive: VMpr_Character_equal>
!

asciiValue
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
!

asInteger
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
!

codePoint
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
!

value
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
! !



!Dictionary class methodsFor: 'built ins'!

new
    "Answer a new Dictionary. This method, actually, won't last long -
     until LookupTbl.st is loaded"
    <primitive: VMpr_Dictionary_new>
    ^self primitiveFailed
! !



!Dictionary methodsFor: 'built ins'!

at: key
    "Answer the value associated with the given key in the receiver.
     This method, actually, won't last long - until LookupTbl.st is loaded"
    <primitive: VMpr_Dictionary_at>
    ^self primitiveFailed
!

at: key put: value
    "Change the value associated with the given key in the receiver to value.
     This method, actually, won't last long - until LookupTbl.st is loaded"
    <primitive: VMpr_Dictionary_atPut>
    ^self primitiveFailed

! !



!CompiledCode class methodsFor: 'cache flushing'!

flushTranslatorCache
    "Answer any kind of cache mantained by a just-in-time code translator
     in the virtual machine (if any).  Do nothing for now."
! !

!CompiledCode methodsFor: 'translation'!

discardTranslation
    "Flush the just-in-time translated code for the receiver (if any)."
    <primitive: VMpr_CompiledCode_discardTranslation>
! !

!CompiledCode methodsFor: 'private'!

verificationResult
    "Answer the result of verifying the bytecodes for the receiver."
    <primitive: VMpr_CompiledCode_verificationResult>
! !

!CompiledCode methodsFor: 'security'!

verify
    "Verify the bytecodes for the receiver, and raise an exception if
     the verification process failed."
    | result |
    result := self verificationResult.
    result isNil ifFalse: [
	SystemExceptions.VerificationError signal: result
    ]
! !


!CompiledMethod class methodsFor: 'instance creation'!

literals: lits numArgs: numArg numTemps: numTemp
    attributes: attrArray bytecodes: bytecodes depth: depth

    "Answer a full fledged CompiledMethod. Construct the method
     header from the parameters, and set the literals and bytecodes
     to the provided ones.  Also, the bytecodes are optimized and
     any embedded CompiledBlocks modified to refer to these literals
     and to the newly created CompiledMethod."

    <primitive: VMpr_CompiledMethod_create>
    attrArray inject: false into: [ :found :each |
	each arguments size ~= each selector numArgs
	    ifTrue: [ SystemExceptions.VerificationError signal: 'invalid number of arguments' ].

	each selector == #primitive:
	    ifFalse: [ found ]
	    ifTrue: [
		found
		    ifTrue: [ SystemExceptions.VerificationError signal: 'duplicate primitive declaration' ].
		(each arguments first class == SmallInteger
		    and: [ each arguments first strictlyPositive ])
		    ifFalse: [ SystemExceptions.VerificationError signal: 'invalid primitive declaration' ].

		true
	    ].
    ]
! !


!CompiledBlock class methodsFor: 'instance creation'!

numArgs: args numTemps: temps bytecodes: bytecodes depth: depth literals: literalArray
    "Answer an (almost) full fledged CompiledBlock.  To make it complete,
     you must either set the new object's `method' variable, or put it
     into a BlockClosure and put the BlockClosure into a CompiledMethod's
     literals.  The clean-ness of the block is automatically computed."

    <primitive: VMpr_CompiledBlock_create>
    self primitiveFailed
!


!ByteArray methodsFor: 'built ins'!

byteAt: index
    "Answer the index-th indexed instance variable of the receiver"
    <primitive: VMpr_Object_basicAt>
    self checkIndexableBounds: index
!

byteAt: index put: value
    "Store the `value' byte in the index-th indexed instance variable
     of the receiver"
    <primitive: VMpr_Object_basicAtPut>

    self checkIndexableBounds: index put: value
!


hash
    "Answer an hash value for the receiver"
    <primitive: VMpr_String_hash>
    ^0
!

replaceFrom: start to: stop withString: aString startingAt: replaceStart
    "Replace the characters from start to stop with the
     ASCII codes contained in aString (which, actually, can be
     any variable byte class), starting at the replaceStart
     location of aString"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^super replaceFrom: start to: stop with: aString startingAt: replaceStart
!

replaceFrom: start to: stop with: aByteArray startingAt: replaceStart
    "Replace the characters from start to stop with the
     bytes contained in aByteArray (which, actually, can be
     any variable byte class), starting at the replaceStart
     location of aByteArray"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^super replaceFrom: start to: stop with: aByteArray startingAt: replaceStart
!

primReplaceFrom: start to: stop with: aByteArray startingAt: srcIndex
    "Private - Replace the characters from start to stop with the
     ASCII codes contained in aString (which, actually, can be
     any variable byte class), starting at the srcIndex location of
     aString"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^self primitiveFailed
!

asCData: aCType
    "Convert the receiver to a CObject with the given type"
    <primitive: VMpr_ByteArray_asCData>
    ^self primitiveFailed
! !




!Stream methodsFor: 'built ins'!

fileIn
    "File in the contents of the receiver.
     During a file in operation, global variables (starting with an
     uppercase letter) that are not declared don't yield an `unknown
     variable' error. Instead, they are defined as nil in the `Undeclared'
     dictionary (a global variable residing in Smalltalk).
     As soon as you add the variable to a namespace (for example by creating
     a class) the Association will be removed from Undeclared and reused
     in the namespace, so that the old references will automagically point
     to the new value."

    <primitive: VMpr_Stream_fileIn>
    self primitiveFailed!

fileInLine: lineNum fileName: aString at: charPosInt
    "Private - Much like a preprocessor #line directive; it is used
     by the Emacs Smalltalk mode."

    <primitive: VMpr_Stream_fileInLine>
    self primitiveFailed
! !

!FileDescriptor methodsFor: 'built ins'!

fileOp: ioFuncIndex
    "Private - Used to limit the number of primitives used by FileStreams"
    <primitive: VMpr_FileDescriptor_fileOp>
    file isNil ifTrue: [ SystemExceptions.FileError signal: 'file closed' ].
    self checkError.
    ^nil
!

fileOp: ioFuncIndex ifFail: aBlock
    "Private - Used to limit the number of primitives used by FileStreams."
    <primitive: VMpr_FileDescriptor_fileOp>
    ^aBlock value
!

fileOp: ioFuncIndex with: arg1
    "Private - Used to limit the number of primitives used by FileStreams"
    <primitive: VMpr_FileDescriptor_fileOp>
    file isNil ifTrue: [ SystemExceptions.FileError signal: 'file closed' ].
    self checkError.
    ^nil
!

fileOp: ioFuncIndex with: arg1 ifFail: aBlock
    "Private - Used to limit the number of primitives used by FileStreams."
    <primitive: VMpr_FileDescriptor_fileOp>
    ^aBlock value
!

fileOp: ioFuncIndex with: arg1 with: arg2
    "Private - Used to limit the number of primitives used by FileStreams"
    <primitive: VMpr_FileDescriptor_fileOp>
    file isNil ifTrue: [ SystemExceptions.FileError signal: 'file closed' ].
    self checkError.
    ^nil
!

fileOp: ioFuncIndex with: arg1 with: arg2 ifFail: aBlock
    "Private - Used to limit the number of primitives used by FileStreams."
    <primitive: VMpr_FileDescriptor_fileOp>
    ^aBlock value
!

fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3
    "Private - Used to limit the number of primitives used by FileStreams"
    <primitive: VMpr_FileDescriptor_fileOp>
    file isNil ifTrue: [ SystemExceptions.FileError signal: 'file closed' ].
    self checkError.
    ^nil
!

fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 ifFail: aBlock
    "Private - Used to limit the number of primitives used by FileStreams."
    <primitive: VMpr_FileDescriptor_fileOp>
    ^aBlock value
!

fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 with: arg4
    "Private - Used to limit the number of primitives used by FileStreams"
    <primitive: VMpr_FileDescriptor_fileOp>
    file isNil ifTrue: [ SystemExceptions.FileError signal: 'file closed' ].
    self checkError.
    ^nil
!

fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 with: arg4 ifFail: aBlock
    "Private - Used to limit the number of primitives used by FileStreams."
    <primitive: VMpr_FileDescriptor_fileOp>
    ^aBlock value
! !


!Memory class methodsFor: 'private'!

type: aType at: anAddress
    "Returns a particular type object from memory at anAddress"
    <primitive: VMpr_Memory_at>
    ^self primitiveFailed
!

type: aType at: anAddress put: aValue
    "Sets the memory location anAddress to aValue"
    <primitive: VMpr_Memory_atPut>
    ^self primitiveFailed
! !



!Time class methodsFor: 'builtins'!

timezoneBias
    "Specifies the current bias, in minutes, for local time translation for
     the current time. The bias is the difference, in seconds, between
     Coordinated Universal Time (UTC) and local time; a positive bias
     indicates that the local timezone is to the east of Greenwich (e.g.
     Europe, Asia), while a negative bias indicates that it is to the
     west (e.g. America)"
    <primitive: VMpr_Time_timezoneBias>
    ^self primitiveFailed
!

timezone
    "Answer a String associated with the current timezone (either standard
     or daylight-saving) on this operating system. For example, the answer
     could be `EST' to indicate Eastern Standard Time; the answer can be
     empty and can't be assumed to be a three-character code such as `EST'."
    <primitive: VMpr_Time_timezone>
    ^self primitiveFailed
!

secondClock
    "Returns the number of seconds to/since 1/1/2000. This method won't
     last long - until Time.st restores correct Blue Book semantics"
    <primitive: VMpr_Time_secondClock>
    ^self primitiveFailed
!

primSecondClock
    "Returns the number of seconds to/from 1/1/2000."
    <primitive: VMpr_Time_secondClock>
    ^self primitiveFailed
!

millisecondClock
    "Returns the number of milliseconds since midnight. This method won't
     last long - until Time.st restores correct Blue Book semantics"
    <primitive: VMpr_Time_millisecondClock>
   ^self primitiveFailed
!

primMillisecondClock
    "Returns the number of milliseconds since midnight."
    <primitive: VMpr_Time_millisecondClock>
   ^self primitiveFailed
! !



!Process methodsFor: 'builtins'!

singleStepWaitingOn: aSemaphore
    "Execute a limited amount of code (usually a bytecode, or up to the
     next backward jump, or up to the next message send) of the receiver,
     which must in a ready-to-run state (neither executing nor terminating
     nor suspended), then restart running the current process.  aSemaphore
     is used as a means to synchronize the execution of the current process
     and the receiver and should have no signals on it.  The current process
     should have higher priority than the receiver."
    <primitive: VMpr_Process_singleStepWaitingOn>
    SystemExceptions.InvalidProcessState signalOn: self
!

resume
    "Resume the receiver's execution"
    <primitive: VMpr_Process_resume>
    SystemExceptions.ProcessTerminated signalOn: self
!

yield
    "Yield control from the receiver to other processes"
    <primitive: VMpr_Process_yield>
! !


!ProcessorScheduler methodsFor: 'built ins'!

disableInterrupts
   "Disable interrupts caused by external events while the
    current process is executing.  Note that interrupts are
    disabled on a per-process basis, and that calling
    #disableInterrupts twice requires calling #enableInterrupts
    twice as well to re-enable interrupts."
   <primitive: VMpr_Processor_disableInterrupts>
!

enableInterrupts
   "Re-enable interrupts caused by external events while the
    current process is executing.  By default, interrupts are
    enabled."
   <primitive: VMpr_Processor_enableInterrupts>
!


!ProcessorScheduler methodsFor: 'timed invocation'!

isTimeoutProgrammed
    "Private - Answer whether there is a pending call to
    #signal:atMilliseconds:"
    <primitive: VMpr_Processor_isTimeoutProgrammed>
!

signal: aSemaphore atMilliseconds: millis
    "Private - signal 'aSemaphore' after 'millis' milliseconds have elapsed"
    <primitive: VMpr_Processor_signalAtMilliseconds>
    ^self primitiveFailed
!

signal: aSemaphore onInterrupt: anIntegerSignalNumber
    "Private - signal 'aSemaphore' when the given C signal occurs"
    <primitive: VMpr_Processor_signalOnInterrupt>
    ^self primitiveFailed
! !



!Semaphore methodsFor: 'builtins'!

"synchronization"

notify
    "Resume one of the processes that were waiting on the semaphore if
    there were any.  Do not leave a signal on the semaphore if no
    process is waiting."
    <primitive: VMpr_Semaphore_notify>
    ^self primitiveFailed
!

notifyAll
    "Resume all the processes that were waiting on the semaphore if there
     were any.  Do not leave a signal on the semaphore if no process is
     waiting."
    <primitive: VMpr_Semaphore_notifyAll>
    ^self primitiveFailed
!

signal
    "Signal the receiver, resuming a waiting process' if there is one"
    <primitive: VMpr_Semaphore_signal>
    ^self primitiveFailed
!

wait
    "Wait for the receiver to be signalled, suspending the executing process
     if it is not yet"
    <primitive: VMpr_Semaphore_wait>
    ^self primitiveFailed
!

waitAfterSignalling: aSemaphore
    "Signal aSemaphore then, atomically, wait for the receiver to be
     signalled, suspending the executing process if it is not yet.  This
     is needed to avoid race conditions when the #notify and #notifyAll
     are used before waiting on receiver: otherwise, if a process sends
     any of the two between the time aSemaphore is signaled and the time
     the process starts waiting on the receiver, the notification is lost."
    <primitive: VMpr_Semaphore_waitAfterSignalling>
    ^self primitiveFailed
!

lock
    "Without putting the receiver to sleep, force processes that try to wait
     on the semaphore to block.  Answer whether this was the case even before."
    <primitive: VMpr_Semaphore_lock>
    ^self primitiveFailed
! !



!CObject class methodsFor: 'instance creation'!

alloc: nBytes
    "Allocate nBytes bytes and return an instance of the receiver"
    <primitive: VMpr_CObject_alloc>
    ^SystemExceptions.WrongClass signalOn: nBytes mustBe: SmallInteger
!

new: nBytes
    "Allocate nBytes bytes and return an instance of the receiver"
    <primitive: VMpr_CObject_alloc>
    ^SystemExceptions.WrongClass signalOn: nBytes mustBe: SmallInteger
!

alloc: nBytes type: cTypeObject
    "Allocate nBytes bytes and return a CObject of the given type"
    <primitive: VMpr_CObject_allocType>
    nBytes isInteger ifFalse: [
	^SystemExceptions.WrongClass signalOn: nBytes mustBe: SmallInteger
    ].
    ^SystemExceptions.WrongClass signalOn: cTypeObject mustBe: CType
! !



!CObject methodsFor: 'C data access'!

at: byteOffset type: aType
    "Answer some data of the given type from byteOffset bytes after
     the pointer stored in the receiver"
    <primitive: VMpr_CObject_at>
    byteOffset isInteger ifFalse: [
	^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger
    ].
    ^SystemExceptions.WrongClass signalOn: aType
!
    
at: byteOffset put: aValue type: aType
    "Store aValue as data of the given type from byteOffset bytes after
     the pointer stored in the receiver"
    | type |
    <primitive: VMpr_CObject_atPut>

    "Attempt to store something meaningful from another CObject"
    type := aValue cObjStoredType.
    type isNil ifTrue: [ type := aType ].
    ^self at: byteOffset noCObjectsPut: aValue cObjStoredValue type: type
!

free
    "Free the receiver's pointer and set it to null. Big trouble hits
     you if the receiver doesn't point to the base of a malloc-ed area."
    <primitive: VMpr_CObject_free>
    ^self primitiveFailed
! !



!CObject methodsFor: 'private'!

at: byteOffset noCObjectsPut: aValue type: aType
    "Private - Store aValue as data of the given type from byteOffset bytes
     after the pointer stored in the receiver. This version refuses CObjects
     for `aValue'. "
    <primitive: VMpr_CObject_atPut>

    byteOffset isInteger ifFalse: [
	^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger
    ].
    (aType isInteger or: [ aType isKindOf: CType ]) ifFalse: [
	^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger
    ].
    ^SystemExceptions.WrongClass signalOn: aValue
!

derefAt: byteOffset type: aType
    <primitive: VMpr_CObject_derefAt>

    byteOffset isInteger ifFalse: [
	^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger
    ].
    ^SystemExceptions.WrongClass signalOn: aType
!

derefAt: byteOffset put: aValue type: aType
    | type |
    <primitive: VMpr_CObject_derefAtPut>

    "Attempt to store something meaningful from another CObject"
    type := aValue cObjStoredType.
    type isNil ifTrue: [ type := aType ].
    ^self derefAt: byteOffset noCObjectsPut: aValue cObjStoredValue type: type
!

derefAt: byteOffset noCObjectsPut: aValue type: aType
    <primitive: VMpr_CObject_derefAtPut>

    byteOffset isInteger ifFalse: [
	^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger
    ].
    (aType isInteger or: [ aType isKindOf: CType ]) ifFalse: [
	^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger
    ].
    ^SystemExceptions.WrongClass signalOn: aValue
! !


!CFunctionDescriptor class methodsFor: 'instance creation'!

for: funcNameString returning: returnTypeSymbol withArgs: argsArray
    "Private - Answer a CFunctionDescriptor"

    <primitive: VMpr_CFuncDescriptor_create>
    ^self primitiveFailed
! !


!HashedCollection methodsFor: 'builtins'!

primAt: anIndex
    "Private - Answer the anIndex-th item of the hash table for the receiver.
     Using this instead of basicAt: allows for easier changes in the
     representation"
    <primitive: VMpr_Object_basicAt>
    self checkIndexableBounds: anIndex
!

primAt: anIndex put: value
    "Private - Store value in the anIndex-th item of the hash table for the
     receiver. Using this instead of basicAt:put: allows for easier
     changes in the representation"
    <primitive: VMpr_Object_basicAtPut>

    self checkIndexableBounds: anIndex put: value
!

primSize
    "Private - Answer the size of the hash table for the receiver.
     Using this instead of basicSize allows for easier changes
     in the representation"
    <primitive: VMpr_Object_basicSize>
! !

!AbstractNamespace methodsFor: 'basic & copying'!

= arg
    "Answer whether the receiver is equal to arg. The equality test is
     by default the same as that for equal objects. = must not fail;
     answer false if the receiver cannot be compared to arg"
    <primitive: VMpr_Object_identity>
!

hash
    "Answer an hash value for the receiver.  This is the same as the
     object's #identityHash."
    <primitive: VMpr_Object_hash>
! !

!Namespace class methodsFor: 'accessing'!

current
    "Answer the current namespace"
    Current isNil ifTrue: [ Current := Smalltalk ].
    ^Current
!

current: aNamespaceOrClass
    "Set the current namespace to be aNamespace or, if it is a class,
     its class pool (the Dictionary that holds class variables)."
    "The primitive call is needed to inform the compiler"
    | namespace |
    <primitive: VMpr_Namespace_setCurrent>
    namespace := aNamespaceOrClass isClass
	ifTrue: [ aNamespaceOrClass classPool ]
	ifFalse: [ aNamespaceOrClass ].

    (namespace isKindOf: Dictionary)
	ifTrue: [ Current := namespace ]
	ifFalse: [
	    SystemExceptions.WrongClass
		signalOn: aNamespaceOrClass
		mustBe: { Dictionary. Class } ].
! !


"These are stubs...they will be replaced with the appropriate class
from Class.st and UndefObject.st.  These allow for Smalltalk type class
declarations of the built-in classes, so that they may be edited and
modified.  This mostly present to allow for future enhancement in which
the Smalltalk source files take a more active role in the definition of
the system, and the C definition of the classes diminishes in importance."

!Class methodsFor: 'builtins'!

subclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variable: shape subclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variableSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variableWordSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variableByteSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
! !



!UndefinedObject methodsFor: 'builtins'!

subclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variable: shape subclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variableSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variableWordSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
!

variableByteSubclass: classNameString
  instanceVariableNames: stringInstVarNames
  classVariableNames: stringOfClassVarNames
  poolDictionaries: stringOfPoolNames
  category: categoryNameString
    (Smalltalk at: classNameString) category: categoryNameString
! !


!Class methodsFor: 'builtins'!

category: aString
    "Define a category for the receiver"

    category := aString
!

comment: aString
    "Define a comment for the receiver"

    comment := aString
    "This method is present so that comment declarations can always work, even
     before the real method is defined."
! !
