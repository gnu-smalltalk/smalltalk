"======================================================================
|
|   DateTime and Duration Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001, 2002 Free Software Foundation, Inc.
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Date subclass: #DateTime
	  instanceVariableNames: 'seconds offset'
	  classVariableNames: 'ClockPrecision'
	  poolDictionaries: ''
	  category: 'Language-Data types'!

Time subclass: #Duration
	  instanceVariableNames: ''
	  classVariableNames: 'Zero'
	  poolDictionaries: ''
	  category: 'Language-Data types'!

DateTime comment: 
'My instances represent timestamps.' !

Duration comment: 
'My instances represent differences between timestamps.' !


!DateTime class methodsFor: 'information'!

initialize
    "Initialize the receiver's class variables"
    ClockPrecision := Duration seconds: 1!

clockPrecision
    ^ClockPrecision! !

!DateTime class methodsFor: 'instance creation (non-ANSI)'!

fromDays: days seconds: secs offset: ofs
    "Answer a DateTime denoting the d-th day of the given (as a number)
     month and year. Set the offset field to ofs (a Duration), and
     the the time part to the given hour, minute, and second"
    ^(self fromDays: days)
	setSeconds: secs;
	setOffset: ofs
! !

!DateTime class methodsFor: 'instance creation'!

readFrom: aStream
    "Parse an instance of the receiver from aStream"
    ^(super readFrom: aStream) + (Duration readFrom: aStream)
!

now
    "Answer an instance of the receiver referring to the current
     date and time."
    ^self dateAndTimeNow
!

year: y month: m day: d hour: h minute: min second: s
    "Answer a DateTime denoting the d-th day of the given (as a number)
     month and year, setting the time part to the given hour, minute,
     and second"
    ^(super year: y month: m day: d hour: h minute: min second: s)
	setSeconds: (h * 60 + min) * 60 + s
!

year: y day: d hour: h minute: min second: s
    "Answer a DateTime denoting the d-th day of the given year, and
    setting the time part to the given hour, minute, and second"
    ^(super year: y day: d hour: h minute: min second: s)
	setSeconds: (h * 60 + min) * 60 + s
!

year: y month: m day: d hour: h minute: min second: s offset: ofs
    "Answer a DateTime denoting the d-th day of the given (as a number)
     month and year. Set the offset field to ofs (a Duration), and
     the the time part to the given hour, minute, and second"
    ^(super year: y month: m day: d hour: h minute: min second: s)
	setSeconds: (h * 60 + min) * 60 + s;
	setOffset: ofs
!

year: y day: d hour: h minute: min second: s offset: ofs
    "Answer a DateTime denoting the d-th day of the given year.
     Set the offset field to ofs (a Duration), and the time part
     to the given hour, minute, and second"
    ^(super year: y day: d hour: h minute: min second: s)
	setSeconds: (h * 60 + min) * 60 + s;
	setOffset: ofs
! !


!DateTime methodsFor: 'testing'!

< aDateTime
    "Answer whether the receiver indicates a date preceding aDate"
    self offset = aDateTime offset ifFalse: [ ^self asUTC < aDateTime asUTC ].
    ^super < aDateTime
	or: [ super = aDateTime and: [ seconds < aDateTime seconds ] ]
!

= aDateTime
    "Answer whether the receiver indicates the same date as aDate"
    self class == aDateTime class ifFalse: [ ^false ].
    self offset = aDateTime offset ifFalse: [ ^self asUTC = aDateTime asUTC ].
    ^super = aDateTime and: [ seconds = aDateTime seconds ]
!

hash
    "Answer an hash value for the receievr"
    ^super hash * 37 + (self seconds - self offset seconds)
! !


!DateTime methodsFor: 'basic'!

+ aDuration
    "Answer a new Date pointing dayCount past the receiver"
    | newSecs |
    newSecs := self seconds + (aDuration asSeconds rem: 86400).
    ^newSecs > 86400
	ifTrue: [
	    DateTime
		fromDays: self days + aDuration days + 1
		seconds: newSecs - 86400
		offset: self offset
	]
	ifFalse: [
	    DateTime
		fromDays: self days + aDuration days
		seconds: newSecs
		offset: self offset
	]
!

- aDateTimeOrDuration
    "Answer a new Date pointing dayCount before the receiver"
    | newSecs resultClass |
    aDateTimeOrDuration class == self class
	ifTrue: [
	    self offset = aDateTimeOrDuration offset
		ifFalse: [ ^self asUTC - aDateTimeOrDuration asUTC ].

	    resultClass := Duration.
	    newSecs := self seconds - aDateTimeOrDuration seconds
	]	
	ifFalse: [
	    resultClass := DateTime.
	    newSecs := self seconds - (aDateTimeOrDuration asSeconds rem: 86400)
	].

    ^newSecs < 0
	ifTrue: [
	    resultClass
		fromDays: self days - aDateTimeOrDuration days - 1
		seconds: newSecs + 86400
		offset: self offset
	]
	ifFalse: [
	    resultClass
		fromDays: self days - aDateTimeOrDuration days
		seconds: newSecs
		offset: self offset
	]
! !


!DateTime methodsFor: 'computations'!

asSeconds
    "Answer the date as the number of seconds from 1/1/1901."
    ^super asSeconds + seconds
!

dayOfWeek
    "Answer the day of week of the receiver. Unlike Dates, DateAndTimes
     have 1 = Sunday, 7 = Saturday"
    ^#(2 3 4 5 6 7 1) at: super dayOfWeek
!

hour
    "Answer the hour in a 24-hour clock"
    ^seconds // 3600
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

meridianAbbreviation
    "Answer either #AM (for anti-meridian) or #PM (for post-meridian)"
    ^self hour < 12 ifTrue: [ #AM ] ifFalse: [ #PM ]
!

minute
    "Answer the minute"
    ^(seconds // 60) \\ 60
!

second
    "Answer the month represented by the receiver"
    ^seconds \\ 60
! !


!DateTime methodsFor: 'splitting in dates & times'!

at: anIndex
    "Since in the past timestamps were referred to as Arrays containing
     a Date and a Time (in this order), this method provides access to
     DateTime objects like if they were two-element Arrays."
    anIndex = 1 ifTrue: [ ^self asDate ].
    anIndex = 2 ifTrue: [ ^self asTime ].
    SystemExceptions.IndexOutOfRange signalOn: self withIndex: anIndex.
!

asDate
    "Answer a Date referring to the same day as the receiver"
    ^Date fromDays: self days
!

asTime
    "Answer a Time referring to the same time (from midnight) as the receiver"
    ^Time fromSeconds: seconds
! !

!DateTime methodsFor: 'time zones'!

asLocal
    "Answer the receiver, since DateTime objects store themselves
     in Local time"
    ^self
!

asUTC
    "Convert the receiver to UTC time, and answer a new DateTime object."
    | newSecs |
    newSecs := self seconds - self offset asSeconds.
    ^newSecs < 0
	ifTrue: [
	    DateTime
		fromDays: self days + offset days - 1
		seconds: newSecs + 86400
		offset: Duration zero
	]
	ifFalse: [
	    DateTime
		fromDays: self days + offset days
		seconds: newSecs
		offset: Duration zero
	]
!

offset
    "Answer the receiver's offset from UTC to local time (e.g. +3600 seconds
     for Central Europe Time, -3600*6 seconds for Eastern Standard Time).
     The offset is expressed as a Duration"
    ^offset
!

offset: anOffset
    "Answer a copy of the receiver with the offset from UTC to local time
     changed to anOffset (a Duration)."
    anOffset = offset ifTrue: [ ^self ].
    ^self copy setOffset: anOffset; yourself
!

timeZoneAbbreviation
    "Answer an abbreviated indication of the receiver's offset, expressed
     as `shhmm', where `hh' is the number of hours and `mm' is the number
     of minutes between UTC and local time, and `s' can be `+' for the
     Eastern hemisphere and `-' for the Western hemisphere."
    ^String
	with: (self offset positive ifTrue: [ $+ ] ifFalse: [ $- ])
	with: (self offset hour   // 10) digitValue
	with: (self offset hour   \\ 10) digitValue
	with: (self offset minute // 10) digitValue
	with: (self offset minute \\ 10) digitValue
!

timeZoneName
    "Answer the time zone name for the receiver (currently, it is
     simply `GMT +xxxx', where `xxxx' is the receiver's
     #timeZoneAbbreviation)."
    ^'GMT ', self timeZoneAbbreviation
! !


!DateTime methodsFor: 'printing'!

printOn: aStream
    "Print a representation for the receiver on aStream"
    aStream
	nextPut: (self year < 0 ifTrue: [ $- ] ifFalse: [ Character space ]);
	next: 3 - (self year abs log: 10) floor put: $0;
	print: self year abs;
	nextPut: $- ;
	next: (self month < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self month;
	nextPut: $- ;
	next: (self day < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self day;
	nextPut: $T ;
	next: (self hour < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self hour;
	nextPut: $: ;
	next: (self minute < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self minute;
	nextPut: $: ;
	next: (self second < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self second;
	nextPut: (self offset negative ifTrue: [ $- ] ifFalse: [ $+ ]);
	next: (self offset hours < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self offset hours;
	nextPut: $: ;
	next: (self offset minutes < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self offset minutes.

    self offset seconds = 0 ifTrue: [ ^self ].

    aStream
	nextPut: $: ;
	print: self offset seconds.

! !



!DateTime methodsFor: 'storing'!

storeOn: aStream
    "Store on aStream Smalltalk code compiling to the receiver"

    self notYetImplemented
! !



!DateTime methodsFor: 'private'!

setDay: dayOfMonth monthIndex: monthIndex year: yearInteger
    "Private - Set the receiver to the given date parts"

    seconds := 0.
    offset := Duration zero.
    ^super setDay: dayOfMonth monthIndex: monthIndex year: yearInteger
!

setDays: dayCount
    "Private - Compute the date parts from the given dayCount and initialize
     the receiver"

    seconds := 0.
    offset := Duration zero.
    ^super setDays: dayCount
!

seconds
    ^seconds
!

setSeconds: secondsCount
    seconds := secondsCount
!

setOffset: offsetDuration
    offset := offsetDuration
! !


!Duration class methodsFor: 'instance creation (non ANSI)'!

fromDays: days seconds: secs offset: unused
    "Answer a duration of `d' days and `secs' seconds.  The last
     parameter is unused; this message is available for interoperability
     with the DateTime class."
    ^self fromSeconds: days * 86400 + secs
! !

!Duration class methodsFor: 'instance creation'!

days: d
    "Answer a duration of `d' days"
    ^self fromSeconds: d * 86400
!

days: d hours: h minutes: m seconds: s
    "Answer a duration of `d' days and the given number of hours,
     minutes, and seconds."
    ^self fromSeconds: ((d * 24 + h) * 60 + m) * 60 + s
!

initialize
    "Initialize the receiver's instance variables"
    Zero := self new!

zero
    "Answer a duration of zero seconds."
    ^Zero! !

!Duration methodsFor: 'arithmetics'!

* factor
    "Answer a Duration that is `factor' times longer than the receiver"
    ^Duration fromSeconds: self asSeconds * factor!

/ factorOrDuration
    "If the parameter is a Duration, answer the ratio between the receiver
     and factorOrDuration.  Else divide the receiver by factorOrDuration (a
     Number) and answer a new Duration that is correspondingly shorter."
    ^factorOrDuration isNumber
	ifFalse: [ self asSeconds / factorOrDuration asSeconds ]
	ifTrue: [ Duration fromSeconds: self asSeconds / factorOrDuration ]!

+ aDuration
    "Answer a Duration that is the sum of the receiver and aDuration's
     lengths."
    ^Duration fromSeconds: self asSeconds + aDuration asSeconds!

- aDuration
    "Answer a Duration that is the difference of the receiver and aDuration's
     lengths."
    ^Duration fromSeconds: self asSeconds - aDuration asSeconds!

abs
    "Answer a Duration that is as long as the receiver, but always in
     the future."
    ^Duration fromSeconds: self asSeconds abs!

days
    "Answer the number of days in the receiver"
    ^self asSeconds quo: 86400!

negated
    "Answer a Duration that is as long as the receiver, but with past and
     future exchanged."
    ^Duration fromSeconds: self asSeconds negated!

negative
    "Answer whether the receiver is in the past."
    ^self asSeconds < 0!

positive
    "Answer whether the receiver is a zero-second duration or is
     in the future."
    ^self asSeconds >= 0!

printOn: aStream
    "Print a represention of the receiver on aStream."
    self negative ifTrue: [ aStream nextPut: $-; print: self negated. ^self ].
    aStream
	print: self days;
	nextPut: $:;
	next: (self hours < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self hours;
	nextPut: $:;
	next: (self minutes < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self minutes;
	nextPut: $:;
	next: (self seconds < 10 ifTrue: [ 1 ] ifFalse: [ 0 ]) put: $0;
	print: self seconds
! !


!Duration methodsFor: 'private'!

setSeconds: secs
    seconds := secs
! !

Duration initialize!
