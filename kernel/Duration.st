"======================================================================
|
|   Duration Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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

Time subclass: Duration [
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent differences between timestamps.'>

    Zero := nil.

    Duration class >> fromDays: days seconds: secs offset: unused [
	"Answer a duration of `d' days and `secs' seconds.  The last
	 parameter is unused; this message is available for interoperability
	 with the DateTime class."

	<category: 'instance creation (non ANSI)'>
	^self fromSeconds: days * 86400 + secs
    ]

    Duration class >> milliseconds: msec [
	"Answer a duration of `msec' milliseconds"

	<category: 'instance creation'>
	^self fromSeconds: msec / 1000
    ]

    Duration class >> weeks: w [
	"Answer a duration of `w' weeks"

	<category: 'instance creation'>
	^self fromSeconds: w * ##(86400 * 7)
    ]

    Duration class >> days: d [
	"Answer a duration of `d' days"

	<category: 'instance creation'>
	^self fromSeconds: d * 86400
    ]

    Duration class >> days: d hours: h minutes: m seconds: s [
	"Answer a duration of `d' days and the given number of hours,
	 minutes, and seconds."

	<category: 'instance creation'>
	^self fromSeconds: ((d * 24 + h) * 60 + m) * 60 + s
    ]

    Duration class >> readFrom: aStream [
        "Parse an instance of the receiver (hours/minutes/seconds) from
         aStream"

        <category: 'instance creation'>
        | sign sec hms i ch ws |
        hms := {0. 0. 0}.
        sign := (aStream peekFor: $-)
            ifTrue: [-1]
            ifFalse: [aStream peekFor: $+. 1].
        i := 1.
        ch := $:.
        [aStream atEnd not and: [ch isSeparator not and: [
             ch ~= $+ and: [ch ~= $- and: [
                 i > 1 ifTrue: [aStream next].
                 i <= 4 and: [(ch := aStream peek) isDigit]]]]]] whileTrue: [
            ws := WriteStream on: (String new: 10).
            [ws nextPut: aStream next.
             aStream atEnd not and: [(ch := aStream peek) isDigit]] whileTrue.
            i = 4
                ifTrue: [
                    hms := {
                        (hms at: 1) * 24 + (hms at: 2).
                        hms at: 3.
                        ws contents asNumber}]
                ifFalse: [
                    hms at: i put: ws contents asNumber].
	    i := i + 1].
        sec := ((hms at: 1) * 3600 + ((hms at: 2) * 60) + (hms at: 3)) * sign.
        ^self fromSeconds: sec
    ]

    Duration class >> initialize [
	"Initialize the receiver's instance variables"

	<category: 'instance creation'>
	Zero := self new
    ]

    Duration class >> zero [
	"Answer a duration of zero seconds."

	<category: 'instance creation'>
	^Zero
    ]

    * factor [
	"Answer a Duration that is `factor' times longer than the receiver"

	<category: 'arithmetics'>
	^Duration fromSeconds: self asSeconds * factor
    ]

    / factorOrDuration [
	"If the parameter is a Duration, answer the ratio between the receiver
	 and factorOrDuration.  Else divide the receiver by factorOrDuration (a
	 Number) and answer a new Duration that is correspondingly shorter."

	<category: 'arithmetics'>
	^factorOrDuration isNumber 
	    ifFalse: [self asSeconds / factorOrDuration asSeconds]
	    ifTrue: [Duration fromSeconds: self asSeconds / factorOrDuration]
    ]

    + aDuration [
	"Answer a Duration that is the sum of the receiver and aDuration's
	 lengths."

	<category: 'arithmetics'>
	^Duration fromSeconds: self asSeconds + aDuration asSeconds
    ]

    - aDuration [
	"Answer a Duration that is the difference of the receiver and aDuration's
	 lengths."

	<category: 'arithmetics'>
	^Duration fromSeconds: self asSeconds - aDuration asSeconds
    ]

    isZero [
	"Answer whether the receiver correspond to a duration of zero seconds."

	<category: 'arithmetics'>
	^self asSeconds = 0
    ]

    abs [
	"Answer a Duration that is as long as the receiver, but always in
	 the future."

	<category: 'arithmetics'>
	^Duration fromSeconds: self asSeconds abs
    ]

    days [
	"Answer the number of days in the receiver"

	<category: 'arithmetics'>
	^self asSeconds quo: 86400
    ]

    negated [
	"Answer a Duration that is as long as the receiver, but with past and
	 future exchanged."

	<category: 'arithmetics'>
	^Duration fromSeconds: self asSeconds negated
    ]

    storeOn: aStream [
	"Store on aStream Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream
	    nextPut: $(;
	    nextPutAll: self class storeString;
	    nextPutAll: ' days: ';
	    store: self days;
	    nextPutAll: ' hours: ';
	    store: self hours;
	    nextPutAll: ' minutes: ';
	    store: self minutes;
	    nextPutAll: ' seconds: ';
	    store: self seconds;
	    nextPut: $)
    ]

    negative [
	"Answer whether the receiver is in the past."

	<category: 'arithmetics'>
	^self asSeconds < 0
    ]

    positive [
	"Answer whether the receiver is a zero-second duration or is
	 in the future."

	<category: 'arithmetics'>
	^self asSeconds >= 0
    ]

    printOn: aStream [
	"Print a represention of the receiver on aStream."

	<category: 'arithmetics'>
	self negative 
	    ifTrue: 
		[aStream
		    nextPut: $-;
		    print: self negated.
		^self].
	aStream
	    print: self days;
	    nextPut: $:;
	    next: (self hours < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self hours;
	    nextPut: $:;
	    next: (self minutes < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self minutes;
	    nextPut: $:;
	    next: (self seconds < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self seconds
    ]

    setSeconds: secs [
	<category: 'private'>
	seconds := secs
    ]

    wait [
	"Answer a Delay waiting for the amount of time represented
	 by the receiver and start waiting on it."
	<category: 'processes'>
	^(Delay forMilliseconds: self asSeconds * 1000) wait
    ]
]



Eval [
    Duration initialize
]

