"======================================================================
|
|   Time Method Definitions
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


Magnitude subclass: #Time
	  instanceVariableNames: 'seconds'
	  classVariableNames: 'SecondClockAdjustment ClockOnStartup'
	  poolDictionaries: ''
	  category: 'Language-Data types'
!

Time comment: 
'My instances represent times of the day.  I provide methods for instance 
creation, methods that access components (hours, minutes, and seconds) of a 
time value, and a block execution timing facility.' !


!Time class methodsFor: 'basic (UTC)'!

utcSecondClock
    "Answer the number of seconds since the midnight of 1/1/1901 (unlike
     #secondClock, the reference time is here expressed as UTC, that is
     as Coordinated Universal Time)."
    ^self secondClock - self timezoneBias
!

utcNow
    "Answer a time representing the current time of day in Coordinated
     Universal Time (UTC)"

    "\\ rounds towards -infinity, so it is good for negative numbers too"
    ^self new setSeconds: self utcSecondClock
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



!Time class methodsFor: 'initialization'!

initialize
    "Initialize the Time class after the image has been bootstrapped"

    "(99 * 365 + 25) * 86400 secs/day."
    SecondClockAdjustment := 86400 * 36159.
    ObjectMemory addDependent: self
!

update: aspect
    "Private - Initialize the receiver's instance variables"
    aspect == #returnFromSnapshot
	ifTrue: [ ClockOnStartup := Time primSecondClock ].
! !

!Time class methodsFor: 'instance creation'!

now
    "Answer a time representing the current time of day"

    "\\ rounds towards -infinity, so it is good for negative numbers too"
    ^self new setSeconds: self primSecondClock
!

new
    "Answer a Time representing midnight"
    ^self basicNew setSeconds: 0
!

fromSeconds: secondCount
    "Answer a Time representing secondCount seconds past midnight"
    ^self new setSeconds: secondCount
!

hours: h
    "Answer a Time that is the given number of hours past midnight"
    ^self fromSeconds: h * 3600
!

hours: h minutes: m seconds: s
    "Answer a Time that is the given number of hours, minutes and
     seconds past midnight"
    ^self fromSeconds: (h * 60 + m) * 60 + s
!

minutes: m
    "Answer a Time that is the given number of minutes past midnight"
    ^self fromSeconds: m * 60
!

seconds: s
    "Answer a Time that is the given number of seconds past midnight"
    ^self fromSeconds: s
!

readFrom: aStream
    "Parse an instance of the receiver (hours/minutes/seconds) from
     aStream"
    | t1 t2 t3 ch ws |
    t1 := t2 := t3 := 0.

    ch := $:.
    3 timesRepeat: [
	t1 := t2. t2 := t3. t3 := 0.

	ch isSeparator ifFalse: [
            ws := WriteStream on: (String new: 10).
	    ch := $:.
	    [ aStream atEnd not and: [
	         (ch := aStream next) isDigit not]] whileTrue.

	    ch isDigit ifTrue: [
	        [ ws nextPut: ch. aStream atEnd not and: [
		    (ch := aStream next) isDigit ]] whileTrue.
	    ].
	    t3 := ws contents asNumber.
	]
    ].

    ^self fromSeconds: (t1 * 3600) + (t2 * 60) + t3! !

!Time class methodsFor: 'clocks'!

millisecondClockValue
    "Answer the number of milliseconds since startup"

    | second milli |
    [
	second := self primSecondClock.
	milli := self primMillisecondClock \\ 1000.
	(second = self primSecondClock) and: [ milli > 10 ]
    ] whileFalse.
    ^(second - ClockOnStartup) * 1000 + milli
!

millisecondClock
    "Answer the number of milliseconds since startup."

    | second milli |
    [
	second := self primSecondClock.
	milli := self primMillisecondClock \\ 1000.
	(second = self primSecondClock) and: [ milli > 10 ]
    ] whileFalse.
    ^(second - ClockOnStartup) * 1000 + milli
!

secondClock
    "Answer the number of seconds since the midnight of 1/1/1901"
    ^self primSecondClock + SecondClockAdjustment
!

millisecondsPerDay
    "Answer the number of milliseconds in a day"
    ^86400000
!

millisecondsToRun: timedBlock
    "Answer the number of milliseconds which timedBlock took to run"
    | startTime|
    startTime := self millisecondClock.
    timedBlock value.
    ^self millisecondClock - startTime
! !


!Time methodsFor: 'accessing (non ANSI & for Durations)'!

asSeconds
    ^seconds
!

hours
    "Answer the number of hours in the receiver"
    ^(seconds quo: 3600) rem: 24
!

minutes
    "Answer the number of minutes in the receiver"
    ^(seconds quo: 60) rem: 60
!

seconds
    "Answer the number of seconds in the receiver"
    ^seconds rem: 60
! !

!Time methodsFor: 'accessing (ANSI for DateAndTimes)'!

hour
    "Answer the number of hours in the receiver"
    ^(seconds // 3600) \\ 24
!

hour12
    "Answer the hour in a 12-hour clock"
    | h |
    h := self hour \\ 12.
    ^h = 0 ifTrue: [ 12 ] ifFalse: [ h ]
!

hour24
    "Answer the hour in a 24-hour clock"
    ^self hour
!

minute
    "Answer the number of minutes in the receiver"
    ^(seconds // 60) \\ 60
!

second
    "Answer the number of seconds in the receiver"
    ^seconds \\ 60
! !



!Time methodsFor: 'comparing'!

= aTime
    "Answer whether the receiver is equal to aTime"
    ^self class == aTime class and: [ seconds = aTime asSeconds ]
!

< aTime
    "Answer whether the receiver is less than aTime"
    ^seconds < aTime asSeconds
!

hash
    "Answer an hash value for the receiver"
    ^seconds
! !





!Time methodsFor: 'arithmetic'!

addTime: timeAmount
    "Answer a new Time that is timeAmount seconds after the receiver"
    ^Time new setSeconds: seconds + timeAmount asSeconds
!

subtractTime: timeAmount
    "Answer a new Time that is timeAmount seconds before the receiver"
    ^Time new setSeconds: seconds - timeAmount asSeconds
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    self hours printOn: aStream.
    aStream nextPut: $:.
    self minutes < 10 ifTrue: [ aStream nextPut: $0 ].
    self minutes printOn: aStream.
    aStream nextPut: $:.
    self seconds < 10 ifTrue: [ aStream nextPut: $0 ].
    self seconds printOn: aStream.
! !



!Time methodsFor: 'private'!

setSeconds: secs
    seconds := secs \\ 86400
! !

