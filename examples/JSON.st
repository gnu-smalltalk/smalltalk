"======================================================================
|
|   JSON reader/writer example
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Robin Redeker.
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


Stream subclass: #JSONReader
    instanceVariableNames: 'stream'
    classVariableNames: ''
    poolDictionaries: ''
    category: nil !

JSONReader comment:
'I read data structures (currently build of OrderedCollection and Dictionary)
from and to JSON (Java Script Object Notation). Writing is done with the
#toJSON method (note: it will behave badly with circular data structures).' !

!JSONReader class methodsFor: 'json'!

toJSON: anObject
   "I'm returning a JSON string which represents the object."
   ^anObject toJSON
!

fromJSON: string
   "I'm responsible for decoding the JSON string to objects."
   ^(self on: string readStream) nextJSONObject
!

on: aStream
    ^self new stream: aStream
! !

!JSONReader methodsFor: 'json'!

stream: aStream
    stream := aStream
!

peek
   "I'm peeking for the next non-whitespace character and will drop all whitespace in front of it"
   | c |
   [
     c := stream peek.
     c = (Character space)
         or: [ c = (Character tab)
         or: [ c = (Character lf)
         or: [ c = (Character cr)]]]
   ] whileTrue: [
     stream next
   ].
   ^c
!

next
   "I'm returning the next non-whitespace character"
   | c |
   c := self peek.
   c isNil ifTrue: [ ^self error: 'expected character but found end of stream' ].
   stream next.
   ^c
! !

!JSONReader methodsFor: 'private'!

nextJSONObject
   "I decode a json self to a value, which will be one of: nil,
true, false, OrderedCollection, Dictionary, String or Number
(i will return Integer or Float depending on the input)."
   | c |
   c := self peek.
   (c = $n) ifTrue: [ self next: 4. ^nil   ].
   (c = $t) ifTrue: [ self next: 4. ^true  ].
   (c = $f) ifTrue: [ self next: 5. ^false ].
   (c = ${) ifTrue: [ ^self nextJSONDict ].
   (c = $[) ifTrue: [ ^self nextJSONArray  ].
   (c = $") ifTrue: [ ^self nextJSONString ].
   ^self nextJSONNumber
!

nextJSONArray
   "I decode JSON arrays from self and will return a OrderedCollection for them."
   | c obj value |
   obj := OrderedCollection new.
   self next.
   [ c := self peek.
     (c = $]) ] whileFalse: [
      (c = $,) ifTrue: [ self next. ].
      value := self nextJSONObject.
      obj add: value.
   ].
   self next.
   ^obj
!

nextJSONDict
   "I decode JSON objects from self and will return a Dictionary containing all the key/value pairs."
   | c obj key value |
   obj := Dictionary new.
   self next.
   [ c := self peek.
     c = $} ] whileFalse: [
      (c = $,) ifTrue: [ self next ].

      key := self nextJSONString.

      c := self next.
      c = $: ifFalse: [
         self error: ('unexpected character found where name-seperator '':'' expected, found: %1' bindWith: c)
      ].

      value := self nextJSONObject.

      obj at: key put: value.
   ].
   self next.
   ^obj
!

nextJSONString
   "I'm extracting a JSON string from self and return them as String."
   | c obj str |
   str := WriteStream on: (String new).
   self next.
   [
	c := self next.
        c = $"
   ] whileFalse: [
      c = $\
         ifTrue: [
            c := self next.
            c isNil ifTrue:
               [ ^self error: 'expected character, found end of self' ].
            c = $b ifTrue: [ c := 8 asCharacter ].
            c = $f ifTrue: [ c := 12 asCharacter ].
            c = $n ifTrue: [ c := Character nl ].
            c = $r ifTrue: [ c := Character cr ].
            c = $t ifTrue: [ c := Character tab ].
            c = $u
               ifTrue: [
		  c := (Integer readFrom: (self next: 4) readStream radix: 16) asCharacter.
		  (c class == UnicodeCharacter and: [ str species == String ])
		    ifTrue: [ str := (UnicodeString new writeStream
					nextPutAll: str contents; yourself) ] ].
         ].
      str nextPut: c.
   ].
   "Undo the conversion to UnicodeString done above."
   ^str contents asString
!

nextJSONNumber
   "I'm extracting a number in JSON format from self and return Integer or Float depending on the input."
   | c num sgn int intexp frac exp isfloat |
   num := WriteStream on: (String new).

   isfloat := false.
   sgn     := 1.
   int     := 0.
   intexp  := 1.

   c := self peek.
   (c isNil) ifTrue: [ ^self error: 'expected number or -sign, but found end of self' ].
   c = $- ifTrue: [ sgn := -1. self next. ].

   c := self peek.
   (c isNil) ifTrue: [ ^self error: 'expected number, but found end of self' ].
   (c isDigit or: [ c = $. ]) ifFalse: [ ^self error: 'invalid JSON input' ].

   [ c notNil and: [ c isDigit ] ] whileTrue: [
      self next.
      int := sgn * (c digitValue) + (int * 10).
      c := self peek
   ].
   (c isNil) ifTrue: [ ^int ].

   c = $. ifTrue: [
      self next.
      isfloat := true.
      [ c := self peek. c notNil and: [ c isDigit ] ] whileTrue: [
         sgn := sgn / 10.
         int := sgn * (c digitValue) + int.
         self next
      ]
   ].

   exp := 0.
   ((c = $e) or: [ c = $E ]) ifFalse: [
	^isfloat ifTrue: [ int asFloat ] ifFalse: [ int ] ].

   self next.
   c := self peek.
   (c isNil) ifTrue: [ ^int ].
   sgn := 1.
   c = $+ ifTrue: [ sgn :=  1. self next ].
   c = $- ifTrue: [ sgn := -1. self next ].

   [ c := self peek. c notNil and: [ c isDigit ] ] whileTrue: [
      exp := (c digitValue) + (exp * 10).
      self next
   ].

   int := int * (10 raisedToInteger: exp * sgn).
   ^int asFloat
! !

!Number methodsFor: 'json'!

jsonPrintOn: aStream
   "I return the Number in a JSON compatible format as String."
   self asFloat printOn: aStream
! !

!Float methodsFor: 'json'!

jsonPrintOn: aStream
   "I return the Number in a JSON compatible format as String."
   aStream nextPutAll:
	(self printString copyReplacing: self exponentLetter withObject: $e)
! !

!Integer methodsFor: 'json'!

jsonPrintOn: aStream
   "I return the Integer in a JSON compatible format as String."
   self printOn: aStream
! !

!Dictionary methodsFor: 'json'!

jsonPrintOn: ws
   "I encode my contents (key/value pairs) to a JSON object and return it as String."
   | f |
   ws nextPut: ${.
   f := true.
   self keysAndValuesDo: [ :key :val |
      f ifFalse: [ ws nextPut: $, ].
      key jsonPrintOn: ws.
      ws nextPut: $:.
      val jsonPrintOn: ws.
      f := false
   ].
   ws nextPut: $}.
! !

!CharacterArray methodsFor: 'json'!

jsonPrintOn: ws
   "I will encode me as JSON String and return a String containing my encoded version."
   ws nextPut: $".
   self do: [ :c || i |
      i := c asInteger.
      (((i = 16r20
         or: [ i = 16r21 ])
         or: [ i >= 16r23 and: [ i <= 16r5B ] ])
         or: [ i >= 16r5D ])
            ifTrue: [ ws nextPut: c ];
            ifFalse: [ | f |
               f := false.
               ws nextPut: $\.
               i = 16r22 ifTrue: [ f := true. ws nextPut: c ].
               i = 16r5C ifTrue: [ f := true. ws nextPut: c ].
               i = 16r2F ifTrue: [ f := true. ws nextPut: c ].
               i = 16r08 ifTrue: [ f := true. ws nextPut: $b ].
               i = 16r0C ifTrue: [ f := true. ws nextPut: $f ].
               i = 16r0A ifTrue: [ f := true. ws nextPut: $n ].
               i = 16r0D ifTrue: [ f := true. ws nextPut: $r ].
               i = 16r09 ifTrue: [ f := true. ws nextPut: $t ].
               f ifFalse: [
		  ws nextPut: $u.
		  ws nextPutAll: ('0000', i printString: 16) last: 4 ].
            ]
   ].
   ws nextPut: $".
!

!String methodsFor: 'json'!

jsonPrintOn: aStream
   "I will encode me as JSON String and return a String containing my encoded version."
   (self anySatisfy: [ :ch | ch value between: 128 and: 255 ])
	ifTrue: [ self asUnicodeString jsonPrintOn: aStream ]
	ifFalse: [ super jsonPrintOn: aStream ]! !

!SequenceableCollection methodsFor: 'json'!

jsonPrintOn: ws
   "I'm returning a JSON encoding of my contents as String."
   | f |
   ws nextPut: $[.
   f := true.
   self do: [ :val |
      f ifFalse: [ ws nextPut: $, ].
      val jsonPrintOn: ws.
      f := false
   ].
   ws nextPut: $].
! !

!UndefinedObject methodsFor: 'json'!

jsonPrintOn: aStream
   "I'm returning my corresponding value as JSON String."
   aStream nextPutAll: 'null'
! !

!Boolean methodsFor: 'json'!

jsonPrintOn: aStream
   "I'm returning the JSON String for truth or lie."
   self printOn: aStream
! !

!Object methodsFor: 'json'!

jsonPrintOn: aStream
    self subclassResponsibility
!

toJSON
    ^String streamContents: [ :aStream | self jsonPrintOn: aStream ]
! !

