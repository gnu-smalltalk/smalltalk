"======================================================================
|
|   Time Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2008,2009
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



Magnitude subclass: Time [
    | seconds |
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent times of the day.  I provide methods for instance 
creation, methods that access components (hours, minutes, and seconds) of a 
time value, and a block execution timing facility.'>

    SecondClockAdjustment := nil.
    ClockOnStartup := nil.
    ClockOnImageSave := nil.

    Time class >> utcSecondClock [
	"Answer the number of seconds since the midnight of 1/1/1901 (unlike
	 #secondClock, the reference time is here expressed as UTC, that is
	 as Coordinated Universal Time)."

	<category: 'basic (UTC)'>
	^self secondClock - self timezoneBias
    ]

    Time class >> utcNow [
	"Answer a time representing the current time of day in Coordinated
	 Universal Time (UTC)"

	<category: 'basic (UTC)'>
	^self new setSeconds: self utcSecondClock
    ]

    Time class >> midnight [
	"Answer a time representing midnight in Coordinated
	 Universal Time (UTC)"

	<category: 'basic (UTC)'>
	^self new setSeconds: 0
    ]

    Time class >> timezoneBias [
	"Specifies the current bias, in seconds, for local time translation for
	 the current time. The bias is the difference, in seconds, between
	 Coordinated Universal Time (UTC) and local time; a positive bias
	 indicates that the local timezone is to the east of Greenwich (e.g.
	 Europe, Asia), while a negative bias indicates that it is to the
	 west (e.g. America)"

	<category: 'builtins'>
	<primitive: VMpr_Time_timezoneBias>
	^self primitiveFailed
    ]

    Time class >> timezoneBias: seconds [
	"Specifies the bias, in seconds, for local time translation for
	 the given second clock value (0 being midnight of 1/1/1901).
	 The bias is the difference, in seconds, between Coordinated
	 Universal Time (UTC) and local time; a positive bias indicates
	 that the local timezone is to the east of Greenwich (e.g.
	 Europe, Asia), while a negative bias indicates that it is to
	 the west (e.g. America)"

	<category: 'builtins'>
	<primitive: VMpr_Time_timezoneBias>
	^self primitiveFailed
    ]

    Time class >> timezone [
	"Answer a String associated with the current timezone (either standard
	 or daylight-saving) on this operating system. For example, the answer
	 could be `EST' to indicate Eastern Standard Time; the answer can be
	 empty and can't be assumed to be a three-character code such as `EST'."

	<category: 'builtins'>
	<primitive: VMpr_Time_timezone>
	^self primitiveFailed
    ]

    Time class >> secondClock [
	"Answer the number of seconds since the midnight of 1/1/1901"

	<category: 'clocks'>
	^self primSecondClock + SecondClockAdjustment
    ]

    Time class >> primSecondClock [
	"Returns the number of seconds to/from 1/1/2000."

	<category: 'builtins'>
	<primitive: VMpr_Time_secondClock>
	^self primitiveFailed
    ]

    Time class >> nanosecondClock [
	"Answer the number of nanoseconds since startup."

	<category: 'clocks'>
	^self primNanosecondClock - ClockOnStartup
    ]

    Time class >> millisecondClock [
	"Answer the number of milliseconds since startup."

	<category: 'clocks'>
	^self nanosecondClock // 1000000
    ]

    Time class >> primNanosecondClock [
	"Returns the number of milliseconds since midnight."

	<category: 'builtins'>
	<primitive: VMpr_Time_nanosecondClock>
	^self primitiveFailed
    ]

    Time class >> initialize [
	"Initialize the Time class after the image has been bootstrapped"

	"(99 * 365 + 25) * 86400 secs/day."

	<category: 'initialization'>
	SecondClockAdjustment := 86400 * 36159.
        ClockOnImageSave := 0.
	ObjectMemory addDependent: self
    ]

    Time class >> update: aspect [
	"Private - Initialize the receiver's instance variables"

	<category: 'initialization'>
        | time |
	aspect == #returnFromSnapshot ifTrue: [
            ClockOnStartup := Time primNanosecondClock - ClockOnImageSave].
	aspect == #aboutToSnapshot ifTrue: [
            ClockOnImageSave := Time nanosecondClock].
    ]

    Time class >> now [
	"Answer a time representing the current time of day"

	"\\ rounds towards -infinity, so it is good for negative numbers too"

	<category: 'instance creation'>
	^self new setSeconds: self primSecondClock
    ]

    Time class >> new [
	"Answer a Time representing midnight"

	<category: 'instance creation'>
	^self basicNew setSeconds: 0
    ]

    Time class >> fromSeconds: secondCount [
	"Answer a Time representing secondCount seconds past midnight"

	<category: 'instance creation'>
	^self new setSeconds: secondCount
    ]

    Time class >> hour: h [
	"Answer a Time that is the given number of hours past midnight"

	<category: 'instance creation'>
	^self fromSeconds: h * 3600
    ]

    Time class >> hour: h minute: m second: s [
	"Answer a Time that is the given number of hours, minutes and
	 seconds past midnight"

	<category: 'instance creation'>
	^self fromSeconds: (h * 60 + m) * 60 + s
    ]

    Time class >> minute: m [
	"Answer a Time that is the given number of minutes past midnight"

	<category: 'instance creation'>
	^self fromSeconds: m * 60
    ]

    Time class >> second: s [
	"Answer a Time that is the given number of seconds past midnight"

	<category: 'instance creation'>
	^self fromSeconds: s
    ]

    Time class >> hours: h [
	"Answer a Time that is the given number of hours past midnight"

	<category: 'instance creation'>
	^self fromSeconds: h * 3600
    ]

    Time class >> hours: h minutes: m seconds: s [
	"Answer a Time that is the given number of hours, minutes and
	 seconds past midnight"

	<category: 'instance creation'>
	^self fromSeconds: (h * 60 + m) * 60 + s
    ]

    Time class >> minutes: m [
	"Answer a Time that is the given number of minutes past midnight"

	<category: 'instance creation'>
	^self fromSeconds: m * 60
    ]

    Time class >> seconds: s [
	"Answer a Time that is the given number of seconds past midnight"

	<category: 'instance creation'>
	^self fromSeconds: s
    ]

    Time class >> readFrom: aStream [
	"Parse an instance of the receiver (hours/minutes/seconds) from
	 aStream"

	<category: 'instance creation'>
        | hms i ch ws |
        hms := {0. 0. 0}.
        i := 1.
        ch := $:.
        [i <= 3 and: [aStream atEnd not and: [ch isSeparator not]]] whileTrue: [
            ws := WriteStream on: (String new: 10).
            [aStream atEnd not and: [(ch := aStream next) isDigit]]
                whileTrue: [ws nextPut: ch].
            hms at: i put: ws contents asNumber.
            i := i + 1].
        ^self fromSeconds: (hms at: 1) * 3600 + ((hms at: 2) * 60) + (hms at: 3)
    ]

    Time class >> nanosecondClockValue [
	"Answer the number of milliseconds since startup"

	<category: 'clocks'>
	^self primNanosecondClock - ClockOnStartup
    ]

    Time class >> millisecondClockValue [
	"Answer the number of milliseconds since startup"

	<category: 'clocks'>
	^self nanosecondClockValue // 1000000
    ]

    Time class >> millisecondsPerDay [
	"Answer the number of milliseconds in a day"

	<category: 'clocks'>
	^86400000
    ]

    Time class >> millisecondsToRun: timedBlock [
	"Answer the number of milliseconds which timedBlock took to run"

	<category: 'clocks'>
	| startTime |
	startTime := self millisecondClock.
	timedBlock value.
	^self millisecondClock - startTime
    ]

    asNanoseconds [
	<category: 'accessing (non ANSI & for Durations)'>
	^seconds * 1000000000
    ]

    asMilliseconds [
	<category: 'accessing (non ANSI & for Durations)'>
	^seconds * 1000
    ]

    asSeconds [
	<category: 'accessing (non ANSI & for Durations)'>
	^seconds
    ]

    hours [
	"Answer the number of hours in the receiver"

	<category: 'accessing (non ANSI & for Durations)'>
	^(seconds quo: 3600) rem: 24
    ]

    minutes [
	"Answer the number of minutes in the receiver"

	<category: 'accessing (non ANSI & for Durations)'>
	^(seconds quo: 60) rem: 60
    ]

    seconds [
	"Answer the number of seconds in the receiver"

	<category: 'accessing (non ANSI & for Durations)'>
	^seconds rem: 60
    ]

    hour [
	"Answer the number of hours in the receiver"

	<category: 'accessing (ANSI for DateAndTimes)'>
	^seconds // 3600 \\ 24
    ]

    hour12 [
	"Answer the hour in a 12-hour clock"

	<category: 'accessing (ANSI for DateAndTimes)'>
	| h |
	h := self hour \\ 12.
	^h = 0 ifTrue: [12] ifFalse: [h]
    ]

    hour24 [
	"Answer the hour in a 24-hour clock"

	<category: 'accessing (ANSI for DateAndTimes)'>
	^self hour
    ]

    minute [
	"Answer the number of minutes in the receiver"

	<category: 'accessing (ANSI for DateAndTimes)'>
	^seconds // 60 \\ 60
    ]

    second [
	"Answer the number of seconds in the receiver"

	<category: 'accessing (ANSI for DateAndTimes)'>
	^seconds \\ 60
    ]

    = aTime [
	"Answer whether the receiver is equal to aTime"

	<category: 'comparing'>
	^self class == aTime class and: [seconds = aTime asSeconds]
    ]

    < aTime [
	"Answer whether the receiver is less than aTime"

	<category: 'comparing'>
	^seconds < aTime asSeconds
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'comparing'>
	^seconds
    ]

    addSeconds: timeAmount [
	"Answer a new Time that is timeAmount seconds after the receiver"

	<category: 'arithmetic'>
	^Time new setSeconds: seconds + timeAmount
    ]

    addTime: timeAmount [
	"Answer a new Time that is timeAmount seconds after the receiver;
	 timeAmount is a Time."

	<category: 'arithmetic'>
	^Time new setSeconds: seconds + timeAmount asSeconds
    ]

    subtractTime: timeAmount [
	"Answer a new Time that is timeAmount seconds before the receiver;
	 timeAmount is a Time."

	<category: 'arithmetic'>
	^Time new setSeconds: seconds - timeAmount asSeconds
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'arithmetic'>
	self hours printOn: aStream.
	aStream nextPut: $:.
	self minutes < 10 ifTrue: [aStream nextPut: $0].
	self minutes printOn: aStream.
	aStream nextPut: $:.
	self seconds < 10 ifTrue: [aStream nextPut: $0].
	self seconds printOn: aStream
    ]

    setSeconds: secs [
	<category: 'private'>
	seconds := secs \\ 86400
    ]
]

