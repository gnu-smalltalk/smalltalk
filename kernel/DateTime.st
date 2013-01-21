"======================================================================
|
|   DateTime Method Definitions
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

Date subclass: DateTime [
    | seconds offset |
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent timestamps.'>

    ClockPrecision := nil.

    DateTime class >> initialize [
	"Initialize the receiver's class variables"

	<category: 'information'>
	ClockPrecision := Duration seconds: 1
    ]

    DateTime class >> clockPrecision [
	<category: 'information'>
	^ClockPrecision
    ]

    DateTime class >> fromSeconds: secs offset: ofs [
	"Answer a DateTime denoting the given date and time (as seconds
	 since January 1, 1901 midnight). Set the offset field to ofs (a
	 Duration)."

	<category: 'instance creation (non-ANSI)'>
	^self fromDays: 0 seconds: secs offset: ofs
    ]

    DateTime class >> fromSeconds: secs [
	"Answer a DateTime denoting the given date and time (as seconds
	 since January 1, 1901 midnight UTC)."

	<category: 'instance creation (non-ANSI)'>
	^self fromDays: 0 seconds: secs offset: Duration zero
    ]

    DateTime class >> fromDays: days seconds: secs [
	"Answer a DateTime denoting the given date (as days since
	 January 1, 1901) and time (as seconds since UTC midnight)."

	<category: 'instance creation (non-ANSI)'>
	^self fromDays: days seconds: secs offset: Duration zero
    ]

    DateTime class >> fromDays: days seconds: secs offset: ofs [
	"Answer a DateTime denoting the given date (as days since
	 January 1, 1901) and time (as seconds since midnight). Set the
	 offset field to ofs (a Duration)."

	<category: 'instance creation (non-ANSI)'>
	^(self fromDays: days + (secs // 86400))
	    setSeconds: secs \\ 86400;
	    setOffset: ofs
    ]

    DateTime class >> date: aDate time: aTime offset: ofs [
	"Answer a DateTime denoting the given date and time. Set the
	 offset field to ofs (a Duration)."

	<category: 'instance creation (non-ANSI)'>
	^(self fromDays: aDate days)
	    setSeconds: aTime asSeconds;
	    setOffset: ofs
    ]

    DateTime class >> date: aDate time: aTime [
	"Answer a DateTime denoting the given date and time. Set the
	 offset field to ofs (a Duration)."

	<category: 'instance creation (non-ANSI)'>
	^(self fromDays: aDate days)
	    setSeconds: aTime asSeconds;
	    setOffset: Duration zero
    ]

    DateTime class >> readFrom: aStream [
	"Parse an instance of the receiver from aStream"

	<category: 'instance creation'>
        | date time ofs ch |
        date := super readFrom: aStream.
        (aStream peekFor: $T) ifFalse: [aStream skipSeparators].
        time := (aStream atEnd or: [aStream peek isDigit])
            ifTrue: [Duration readFrom: aStream]
            ifFalse: [Duration zero].
        aStream skipSeparators.
        ch := aStream peek.
        (ch = $+ or: [ch = $-]) ifFalse: [^date + time].
        ofs := Duration readFrom: aStream.
        ^(date + time) setOffset: ofs
    ]

    DateTime class >> today [
	"Answer an instance of the receiver referring to midnight of today
	 in local time."

	<category: 'instance creation'>
	| t seconds secondsAtMidnight biasNow biasAtMidnight |
        t := self now.
        seconds := t asSeconds.
        secondsAtMidnight := seconds - t seconds.
        biasAtMidnight := Time timezoneBias: secondsAtMidnight.
        ^DateTime
            fromSeconds: secondsAtMidnight
            offset: (Duration fromSeconds: biasAtMidnight)
    ]

    DateTime class >> now [
	"Answer an instance of the receiver referring to the current
	 date and time."

	<category: 'instance creation'>
	^self dateAndTimeNow
    ]

    DateTime class >> year: y month: m day: d hour: h minute: min second: s [
	"Answer a DateTime denoting the d-th day of the given (as a number)
	 month and year, setting the time part to the given hour, minute,
	 and second"

	<category: 'instance creation'>
	^(super 
	    year: y
	    month: m
	    day: d
	    hour: h
	    minute: min
	    second: s) setSeconds: (h * 60 + min) * 60 + s
    ]

    DateTime class >> year: y day: d hour: h minute: min second: s [
	"Answer a DateTime denoting the d-th day of the given year, and
	 setting the time part to the given hour, minute, and second"

	<category: 'instance creation'>
	^(super 
	    year: y
	    day: d
	    hour: h
	    minute: min
	    second: s) setSeconds: (h * 60 + min) * 60 + s
    ]

    DateTime class >> year: y month: m day: d hour: h minute: min second: s offset: ofs [
	"Answer a DateTime denoting the d-th day of the given (as a number)
	 month and year. Set the offset field to ofs (a Duration), and
	 the the time part to the given hour, minute, and second"

	<category: 'instance creation'>
	^(super 
	    year: y
	    month: m
	    day: d
	    hour: h
	    minute: min
	    second: s)
	    setSeconds: (h * 60 + min) * 60 + s;
	    setOffset: ofs
    ]

    DateTime class >> year: y day: d hour: h minute: min second: s offset: ofs [
	"Answer a DateTime denoting the d-th day of the given year.
	 Set the offset field to ofs (a Duration), and the time part
	 to the given hour, minute, and second"

	<category: 'instance creation'>
	^(super 
	    year: y
	    day: d
	    hour: h
	    minute: min
	    second: s)
	    setSeconds: (h * 60 + min) * 60 + s;
	    setOffset: ofs
    ]

    < aDateTime [
	"Answer whether the receiver indicates a date preceding aDate"

	<category: 'testing'>
	self offset = aDateTime offset ifFalse: [^self asUTC < aDateTime asUTC].
	^super < aDateTime 
	    or: [super = aDateTime and: [seconds < aDateTime seconds]]
    ]

    = aDateTime [
	"Answer whether the receiver indicates the same date as aDate"

	<category: 'testing'>
	self class == aDateTime class ifFalse: [^false].
	self offset = aDateTime offset ifFalse: [^self asUTC = aDateTime asUTC].
	^super = aDateTime and: [seconds = aDateTime seconds]
    ]

    hash [
	"Answer an hash value for the receievr"

	<category: 'testing'>
	^super hash * 37 + (self seconds - self offset seconds)
    ]

    + aDuration [
	"Answer a new Date pointing aDuration time past the receiver"

	<category: 'basic'>
	| newSecs |
	newSecs := self seconds + (aDuration asSeconds rem: 86400).
	^newSecs > 86400 
	    ifTrue: 
		[DateTime 
		    fromDays: self days + aDuration days + 1
		    seconds: newSecs - 86400
		    offset: self offset]
	    ifFalse: 
		[DateTime 
		    fromDays: self days + aDuration days
		    seconds: newSecs
		    offset: self offset]
    ]

    - aDateTimeOrDuration [
	"Answer a new Date pointing dayCount before the receiver"

	<category: 'basic'>
	| newSecs resultClass |
	aDateTimeOrDuration class == self class 
	    ifTrue: 
		[self offset = aDateTimeOrDuration offset 
		    ifFalse: [^self asUTC - aDateTimeOrDuration asUTC].
		resultClass := Duration.
		newSecs := self seconds - aDateTimeOrDuration seconds]
	    ifFalse: 
		[resultClass := DateTime.
		newSecs := self seconds - (aDateTimeOrDuration asSeconds rem: 86400)].
	^newSecs < 0 
	    ifTrue: 
		[resultClass 
		    fromDays: self days - aDateTimeOrDuration days - 1
		    seconds: newSecs + 86400
		    offset: self offset]
	    ifFalse: 
		[resultClass 
		    fromDays: self days - aDateTimeOrDuration days
		    seconds: newSecs
		    offset: self offset]
    ]

    asSeconds [
	"Answer the date as the number of seconds from 1/1/1901."

	<category: 'computations'>
	^super asSeconds + seconds
    ]

    dayOfWeek [
	"Answer the day of week of the receiver. Unlike Dates, DateAndTimes
	 have 1 = Sunday, 7 = Saturday"

	<category: 'computations'>
	^#(2 3 4 5 6 7 1) at: super dayOfWeek
    ]

    hour [
	"Answer the hour in a 24-hour clock"

	<category: 'computations'>
	^seconds // 3600
    ]

    hour12 [
	"Answer the hour in a 12-hour clock"

	<category: 'computations'>
	| h |
	h := self hour \\ 12.
	^h = 0 ifTrue: [12] ifFalse: [h]
    ]

    hour24 [
	"Answer the hour in a 24-hour clock"

	<category: 'computations'>
	^self hour
    ]

    meridianAbbreviation [
	"Answer either #AM (for anti-meridian) or #PM (for post-meridian)"

	<category: 'computations'>
	^self hour < 12 ifTrue: [#AM] ifFalse: [#PM]
    ]

    minute [
	"Answer the minute"

	<category: 'computations'>
	^seconds // 60 \\ 60
    ]

    second [
	"Answer the month represented by the receiver"

	<category: 'computations'>
	^seconds \\ 60
    ]

    at: anIndex [
	"Since in the past timestamps were referred to as Arrays containing
	 a Date and a Time (in this order), this method provides access to
	 DateTime objects like if they were two-element Arrays."

	<category: 'splitting in dates & times'>
	anIndex = 1 ifTrue: [^self asDate].
	anIndex = 2 ifTrue: [^self asTime].
	SystemExceptions.IndexOutOfRange signalOn: self withIndex: anIndex
    ]

    asDate [
	"Answer a Date referring to the same day as the receiver"

	<category: 'splitting in dates & times'>
	^Date fromDays: self days
    ]

    asTime [
	"Answer a Time referring to the same time (from midnight) as the receiver"

	<category: 'splitting in dates & times'>
	^Time fromSeconds: seconds
    ]

    asLocal [
	"Answer the receiver, since DateTime objects store themselves
	 in Local time"

	<category: 'time zones'>
        | utcSecs offset |
	utcSecs := self asSeconds - self offset asSeconds.
        offset := Time timezoneBias: utcSecs.
	^DateTime
            fromSeconds: utcSecs + offset
            offset: (Duration fromSeconds: offset)
    ]

    asUTC [
	"Convert the receiver to UTC time, and answer a new DateTime object."

	<category: 'time zones'>
	| newSecs |
	self offset asSeconds = 0 ifTrue: [ ^self ].
	newSecs := self seconds - self offset asSeconds.
	^newSecs < 0 
	    ifTrue: 
		[DateTime 
		    fromDays: self days + offset days - 1
		    seconds: newSecs + 86400
		    offset: Duration zero]
	    ifFalse: 
		[DateTime 
		    fromDays: self days + offset days
		    seconds: newSecs
		    offset: Duration zero]
    ]

    offset [
	"Answer the receiver's offset from UTC to local time (e.g. +3600 seconds
	 for Central Europe Time, -3600*6 seconds for Eastern Standard Time).
	 The offset is expressed as a Duration"

	<category: 'time zones'>
	^offset
    ]

    offset: anOffset [
	"Answer a copy of the receiver with the offset from UTC to local time
	 changed to anOffset (a Duration)."

	<category: 'time zones'>
	anOffset = offset ifTrue: [^self].
	^(self copy)
	    setOffset: anOffset;
	    yourself
    ]

    timeZoneAbbreviation [
	"Answer an abbreviated indication of the receiver's offset, expressed
	 as `shhmm', where `hh' is the number of hours and `mm' is the number
	 of minutes between UTC and local time, and `s' can be `+' for the
	 Eastern hemisphere and `-' for the Western hemisphere."

	<category: 'time zones'>
	^String 
	    with: (self offset positive ifTrue: [$+] ifFalse: [$-])
	    with: (self offset hour // 10) digitValue
	    with: (self offset hour \\ 10) digitValue
	    with: (self offset minute // 10) digitValue
	    with: (self offset minute \\ 10) digitValue
    ]

    timeZoneName [
	"Answer the time zone name for the receiver (currently, it is
	 simply `GMT +xxxx', where `xxxx' is the receiver's
	 #timeZoneAbbreviation)."

	<category: 'time zones'>
	^'GMT ' , self timeZoneAbbreviation
    ]

    printOn: aStream [
	"Print a representation for the receiver on aStream"

	<category: 'printing'>
	aStream
	    nextPut: (self year < 0 ifTrue: [$-] ifFalse: [Character space]);
	    next: 3 - (self year abs log: 10) floor put: $0;
	    print: self year abs;
	    nextPut: $-;
	    next: (self month < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self month;
	    nextPut: $-;
	    next: (self day < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self day;
	    nextPut: $T;
	    next: (self hour < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self hour;
	    nextPut: $:;
	    next: (self minute < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self minute;
	    nextPut: $:;
	    next: (self second < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self second;
	    nextPut: (self offset negative ifTrue: [$-] ifFalse: [$+]);
	    next: (self offset hours abs < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self offset hours abs;
	    nextPut: $:;
	    next: (self offset minutes abs < 10 ifTrue: [1] ifFalse: [0]) put: $0;
	    print: self offset minutes abs.
	self offset seconds = 0 ifTrue: [^self].
	aStream
	    nextPut: $:;
	    print: self offset seconds
    ]

    storeOn: aStream [
	"Store on aStream Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream
	    nextPut: $(;
	    nextPutAll: self class storeString;
	    nextPutAll: ' year: ';
	    store: self year;
	    nextPutAll: ' month: ';
	    store: self month;
	    nextPutAll: ' day: ';
	    store: self day;
	    nextPutAll: ' hour: ';
	    store: self hour;
	    nextPutAll: ' minute: ';
	    store: self minute;
	    nextPutAll: ' second: ';
	    store: self second.

	self offset = Duration zero ifFalse: [
	    aStream
		nextPutAll: ' offset: ';
		store: self offset ].

	aStream
	    nextPut: $)
    ]

    setDay: dayOfMonth monthIndex: monthIndex year: yearInteger [
	"Private - Set the receiver to the given date parts"

	<category: 'private'>
	seconds := 0.
	offset := Duration zero.
	^super 
	    setDay: dayOfMonth
	    monthIndex: monthIndex
	    year: yearInteger
    ]

    setDays: dayCount [
	"Private - Compute the date parts from the given dayCount and initialize
	 the receiver"

	<category: 'private'>
	seconds := 0.
	offset := Duration zero.
	^super setDays: dayCount
    ]

    seconds [
	<category: 'private'>
	^seconds
    ]

    setSeconds: secondsCount [
	<category: 'private'>
	seconds := secondsCount
    ]

    setOffset: offsetDuration [
	<category: 'private'>
	offset := offsetDuration
    ]
]

