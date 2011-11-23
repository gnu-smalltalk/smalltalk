"======================================================================
|
|   Date Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2008
| Free Software Foundation, Inc.
| Written by Steve Byrne, Paolo Bonzini and Jeff Rosenwald.
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



Magnitude subclass: Date [
    | days day month year |
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent dates.  My base date is defined to be Jan 1, 1901.
I provide methods for instance creation (including via "symbolic" dates, 
such as "Date newDay: 14 month: #Feb year: 1990".

PLEASE BE WARNED -- use this class only for dates after 1582 AD; that''s the
beginning of the epoch. Dates before 1582 will not be correctly printed. In
addition, since ten days were lost from October 5 through October 15,
operations between a Gregorian date (after 15-Oct-1582) and a Julian date
(before 5-Oct-1582) will give incorrect results; or, 4-Oct-1582 + 2 days will
yield 6-Oct-1582 (a non-existent day!), not 16-Oct-1582.

In fact, if you pass a year < 1582 to a method like #newDay:month:year:
it will assume that it is a two-digit year (e.g. 90=1990, 1000=2900). The only
way to create Julian calendar dates is with the #fromDays: instance creation
method.'>

    DayNameDict := nil.
    MonthNameDict := nil.

    Date class >> initialize [
	"Initialize the receiver"

	"28 = 7 days*2 keys each day, multiplied by 2 to make hashing effective.
	 48 = 12 months*2 keys each month, multiplied by 2 for the same reason."

	<category: 'basic'>
	DayNameDict := IdentityDictionary new: 28.
	MonthNameDict := IdentityDictionary new: 48.
	self initDayNameDict.
	self initMonthNameDict
    ]

    Date class >> initDayNameDict [
	"Initialize the DayNameDict to the names of the days"

	<category: 'basic'>
	| dayNames |
	dayNames := #(#(#monday #mon) #(#tuesday #tue) #(#wednesday #wed) #(#thursday #thu) #(#friday #fri) #(#saturday #sat) #(#sunday #sun)).	"1"	"2"	"3"	"4"	"5"	"6"	"7"
	dayNames 
	    keysAndValuesDo: [:dayIndex :names | names do: [:name | DayNameDict at: name put: dayIndex]]
    ]

    Date class >> initMonthNameDict [
	"Initialize the MonthNameDict to the names of the months"

	<category: 'basic'>
	| monthNames |
	monthNames := #(#(#january #jan) #(#february #feb) #(#march #mar) #(#april #apr) #(#may) #(#june #jun) #(#july #jul) #(#august #aug) #(#september #sep) #(#october #oct) #(#november #nov) #(#december #dec)).	"1"	"2"	"3"	"4"	"5"	"6"	"7"	"8"	"9"	"10"	"11"	"12"
	monthNames 
	    doWithIndex: [:names :dayIndex | names do: [:name | MonthNameDict at: name put: dayIndex]]
    ]

    Date class >> dayOfWeek: dayName [
	"Answer the index of the day of week corresponding to the given name"

	<category: 'basic'>
	^DayNameDict at: dayName asLowercase asSymbol
    ]

    Date class >> nameOfDay: dayIndex [
	"Answer the name of the day of week corresponding to the given index"

	<category: 'basic'>
	^#(#Monday #Tuesday #Wednesday #Thursday #Friday #Saturday #Sunday) 
	    at: dayIndex
    ]

    Date class >> abbreviationOfDay: dayIndex [
	"Answer the abbreviated name of the day of week corresponding to the given
	 index"

	<category: 'basic'>
	^#(#Mon #Tue #Wed #Thu #Fri #Sat #Sun) at: dayIndex
    ]

    Date class >> indexOfMonth: monthName [
	"Answer the index of the month corresponding to the given name"

	<category: 'basic'>
	^MonthNameDict at: monthName asLowercase asSymbol
    ]

    Date class >> shortNameOfMonth: monthIndex [
	"Answer the name of the month corresponding to the given index"

	<category: 'basic'>
	^#(#Jan #Feb #Mar #Apr #May #Jun #Jul #Aug #Sep #Oct #Nov #Dec) 
	    at: monthIndex
    ]

    Date class >> nameOfMonth: monthIndex [
	"Answer the name of the month corresponding to the given index"

	<category: 'basic'>
	^#(#January #February #March #April #May #June #July #August #September #October #November #December) 
	    at: monthIndex
    ]

    Date class >> daysInMonth: monthName forYear: yearInteger [
	"Answer the number of days in the given (named) month for the given year"

	<category: 'basic'>
	| monthIndex |
	monthIndex := self indexOfMonth: monthName.
	^self daysInMonthIndex: monthIndex forYear: yearInteger
    ]

    Date class >> daysInYear: i [
	"Answer the number of days in the given year"

	<category: 'basic'>
	^(i + 4800) * 1461 // 4 - ((i + 4900) // 100 * 3 // 4) 
	    - ((i + 4799) * 1461 // 4) + ((i + 4899) // 100 * 3 // 4)
    ]

    Date class >> dateAndTimeNow [
	"Answer an array containing the current date and time"

	<category: 'instance creation (Blue Book)'>
	| secondClock utcSecondClock |
	secondClock := Time secondClock.
	utcSecondClock := Time utcSecondClock.
	^DateTime 
	    fromDays: secondClock // 86400
	    seconds: secondClock \\ 86400
	    offset: (Duration fromSeconds: secondClock - utcSecondClock)
    ]

    Date class >> utcDateAndTimeNow [
	"Answer an array containing the current date and time in Coordinated
	 Universal Time (UTC)"

	<category: 'instance creation (Blue Book)'>
	| utcSecondClock |
	utcSecondClock := Time utcSecondClock.
	^DateTime 
	    fromDays: utcSecondClock // 86400
	    seconds: utcSecondClock \\ 86400
	    offset: Duration zero
    ]

    Date class >> today [
	"Answer a Date denoting the current date in local time"

	<category: 'instance creation (Blue Book)'>
	^self fromSeconds: Time secondClock
    ]

    Date class >> utcToday [
	"Answer a Date denoting the current date in Coordinated Universal
	 Time (UTC)"

	<category: 'instance creation (Blue Book)'>
	^self fromSeconds: Time utcSecondClock
    ]

    Date class >> fromSeconds: time [
	"Answer a Date denoting the date time seconds past Jan 1st, 1901"

	<category: 'instance creation (Blue Book)'>
	| days |
	days := time // (24 * 60 * 60).
	^self new setDays: days
    ]

    Date class >> fromJulian: jd [
	"Answer a Date denoting the jd-th day in the astronomical Julian calendar."

	<category: 'instance creation (Blue Book)'>
	^self new setDays: jd - 2415386
    ]

    Date class >> fromDays: dayCount [
	"Answer a Date denoting dayCount days past 1/1/1901"

	<category: 'instance creation (Blue Book)'>
	^self new setDays: dayCount
    ]

    Date class >> newDay: dayCount year: yearInteger [
	"Answer a Date denoting the dayCount day of the yearInteger year"

	<category: 'instance creation (Blue Book)'>
	^self new setDays: dayCount + (self yearAsDays: yearInteger)
    ]

    Date class >> newDay: day monthIndex: monthIndex year: yearInteger [
	"Answer a Date denoting the dayCount day of the given (as a number)
	 month and year"

	<category: 'instance creation (Blue Book)'>
	^self new 
	    setDay: day
	    monthIndex: monthIndex
	    year: yearInteger
    ]

    Date class >> newDay: day month: monthName year: yearInteger [
	"Answer a Date denoting the dayCount day of the given (named)
	 month and year"

	<category: 'instance creation (Blue Book)'>
	^self new 
	    setDay: day
	    monthIndex: (self indexOfMonth: monthName)
	    year: yearInteger
    ]

    Date class >> readFrom: aStream [
	"Parse an instance of the receiver from aStream"

	<category: 'instance creation (Blue Book)'>
	| t1 t2 t3 ch month ws |
	1 to: 3
	    do: 
		[:i | 
		ws := WriteStream on: (String new: 10).
		[aStream atEnd not and: [(ch := aStream peek) isAlphaNumeric not
                       and: [ch ~= $-]]] 
		    whileTrue: [aStream next].
                aStream atEnd ifFalse: [
		    aStream next.
                    ch isLetter
		        ifTrue: 
			    [[ws nextPut: ch.
			    aStream atEnd not and: [(ch := aStream next) isLetter]] 
				    whileTrue]
                        ifFalse:
			    [[ws nextPut: ch.
			        aStream atEnd not and: [(ch := aStream next) isDigit]] 
				    whileTrue]].
		t1 := t2.
		t2 := t3.
		t3 := ws contents.
		(t3 at: 1) isLetter 
		    ifFalse: [t3 := t3 asNumber]
		    ifTrue: 
			[month := i.
			t3 := self indexOfMonth: t3 asSymbol].
		(i = 2 and: [month = 1 and: [t3 > 31]]) 
		    ifTrue: 
			["January 2000"

			^self 
			    newDay: 1
			    monthIndex: t2
			    year: t3]].
	month isNil 
	    ifTrue: 
		[(t1 between: 1 and: 31)
		    ifFalse: 
			[^self 
			    newDay: t3
			    monthIndex: t2
			    year: t1].	"YMD"
		^t1 <= 12 
		    ifTrue: 
			[^self 
			    newDay: t2
			    monthIndex: t1
			    year: t3	"MDY"]
		    ifFalse: 
			[^self 
			    newDay: t1
			    monthIndex: t2
			    year: t3	"DMY"]].
	^month = 1 
	    ifTrue: 
		[self 
		    newDay: t2
		    monthIndex: t1
		    year: t3	"MDY"]
	    ifFalse: 
		[self 
		    newDay: t1
		    monthIndex: t2
		    year: t3	"DMY"]
    ]

    Date class >> year: y month: m day: d hour: h minute: min second: s [
	"Answer a Date denoting the d-th day of the given (as a number)
	 month and year"

	<category: 'instance creation (ANSI)'>
	^self new 
	    setDay: d
	    monthIndex: m
	    year: y
    ]

    Date class >> year: y day: d hour: h minute: min second: s [
	"Answer a Date denoting the d-th day of the given year"

	<category: 'instance creation (ANSI)'>
	^self new setDays: (self yearAsDays: y) + d
    ]

    Date class >> yearAsDays: i [
	"Private - Returns the number of days between Jan 1, 1901
	 and Jan 0th of the given year yearInteger"

	"Calculate Julian day via Fliegal & Van Flandern method
	 -- ACM Algorithm 289. I have to subtract 2415387 to correct for Smalltalk
	 epoch, and I merged that constant in the one (32074) in their formula."

	<category: 'private methods'>
	^(i + 4799) * 1461 // 4 - ((i + 4899) // 100 * 3 // 4) - 2447125
    ]

    Date class >> daysUntilMonth: monthIndex year: yearInteger [
	"Private - Answer the number of days between Jan 1, 1901, and the
	 hypotetical 0th day in the given month, for the given year"

	<category: 'private methods'>
	| i j |
	j := monthIndex - 14 quo: 12.
	i := j + yearInteger.

	"Calculate Julian day via Fliegal & Van Flandern method
	 -- ACM Algorithm 289. I have to subtract 2415386 to correct for Smalltalk
	 epoch, and I merged that constant in the one (32074) in their formula."
	^(i + 4800) * 1461 // 4 + ((monthIndex - 2 - (j * 12)) * 367 // 12) 
	    - ((i + 4900) // 100 * 3 // 4) - 2447461
    ]

    Date class >> daysInMonthIndex: monthIndex forYear: yearInteger [
	"Private - Answer the number of days in the given (indexed) month,
	 for the given year"

	<category: 'private methods'>
	monthIndex = 2 ifTrue: [^(self daysInYear: yearInteger) - 337].
	^#[31 0 31 30 31 30 31 31 30 31 30 31] at: monthIndex	"Jan Feb Mar"	"Apr May Jun"	"Jul Aug Sep"	"Oct Nov Dec"
    ]

    < aDate [
	"Answer whether the receiver indicates a date preceding aDate"

	<category: 'testing'>
	^self days < aDate days
    ]

    = aDate [
	"Answer whether the receiver indicates the same date as aDate"

	<category: 'testing'>
	^aDate class == self class and: [aDate days = self days]
    ]

    hash [
	"Answer an hash value for the receievr"

	<category: 'testing'>
	^self days
    ]

    - aDate [
	"Answer a new Duration counting the number of days between the
         receiver and aDate."

	<category: 'basic'>
	^Duration days: self days - aDate days
    ]

    + aDuration [
        "Answer a new Date or DateTime pointing aDuration time past the
         receiver."
        aDuration seconds = 0
            ifTrue: [ ^Date fromDays: self days + aDuration days ].
	^DateTime 
	    fromDays: self days + aDuration days
	    seconds: aDuration seconds
	    offset: Duration zero
    ]

    addDays: dayCount [
	"Answer a new Date pointing dayCount past the receiver"

	<category: 'basic'>
	^Date fromDays: self days + dayCount
    ]

    subtractDays: dayCount [
	"Answer a new Date pointing dayCount before the receiver"

	<category: 'basic'>
	^Date fromDays: self days - dayCount
    ]

    subtractDate: aDate [
	"Answer the number of days between aDate and the receiver (negative
	 if the receiver is before aDate)"

	<category: 'basic'>
	^self days - aDate days
    ]

    day [
	"Answer the day represented by the receiver"

	<category: 'compatibility (non-ANSI)'>
	^day
    ]

    dayName [
	"Answer the day of week of the receiver as a Symbol"

	<category: 'compatibility (non-ANSI)'>
	^Date nameOfDay: (self days + 1) \\ 7 + 1
    ]

    shortMonthName [
	"Answer the abbreviated name of the month represented by the receiver"

	<category: 'compatibility (non-ANSI)'>
	^Date shortNameOfMonth: self month
    ]

    asSeconds [
	"Answer the date as the number of seconds from 1/1/1901."

	<category: 'date computations'>
	^self days * 86400
    ]

    dayOfWeek [
	"Answer the day of week of the receiver. 1 = Monday, 7 = Sunday"

	<category: 'date computations'>
	^(self days + 1) \\ 7 + 1
    ]

    dayOfWeekName [
	"Answer the day of week of the receiver as a Symbol"

	<category: 'date computations'>
	^Date nameOfDay: (self days + 1) \\ 7 + 1
    ]

    dayOfWeekAbbreviation [
	"Answer the day of week of the receiver as a Symbol"

	<category: 'date computations'>
	^Date abbreviationOfDay: (self days + 1) \\ 7 + 1
    ]

    dayOfMonth [
	"Answer the day represented by the receiver (same as #day)"

	<category: 'date computations'>
	^day
    ]

    dayOfYear [
	"Answer the days passed since 31/12 of last year; e.g. New Year's Day is 1"

	<category: 'date computations'>
	^self days - (Date yearAsDays: self year)
    ]

    daysFromBaseDay [
	"Answer the days passed since 1/1/1901"

	<category: 'date computations'>
	^days
    ]

    daysInMonth [
	"Answer the days in the month represented by the receiver"

	<category: 'date computations'>
	^Date daysInMonthIndex: month forYear: year
    ]

    daysInYear [
	"Answer the days in the year represented by the receiver"

	<category: 'date computations'>
	^Date daysInYear: self year
    ]

    daysLeftInMonth [
	"Answer the days to the end of the month represented by the receiver"

	<category: 'date computations'>
	^(Date daysInMonthIndex: month forYear: year) - day
    ]

    daysLeftInYear [
	"Answer the days to the end of the year represented by the receiver"

	<category: 'date computations'>
	^(Date yearAsDays: self year + 1) - self days
    ]

    firstDayOfMonth [
	"Answer a Date representing the first day of the month represented by the
	 receiver"

	<category: 'date computations'>
	^self subtractDays: self dayOfMonth - 1
    ]

    isLeapYear [
	"Answer whether the receiver refers to a date in a leap year."

	<category: 'date computations'>
	^self daysInYear == 366
    ]

    lastDayOfMonth [
	"Answer a Date representing the last day of the month represented by the
	 receiver"

	<category: 'date computations'>
	^self addDays: self daysLeftInMonth
    ]

    month [
	"Answer the index of the month represented by the receiver"

	<category: 'date computations'>
	^month
    ]

    monthIndex [
	"Answer the index of the month represented by the receiver"

	<category: 'date computations'>
	^month
    ]

    monthName [
	"Answer the name of the month represented by the receiver"

	<category: 'date computations'>
	^Date nameOfMonth: self month
    ]

    monthAbbreviation [
	"Answer the abbreviated name of the month represented by the receiver"

	<category: 'date computations'>
	^Date shortNameOfMonth: self month
    ]

    year [
	"Answer the year represented by the receiver"

	<category: 'date computations'>
	^year
    ]

    printOn: aStream [
	"Print a representation for the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self day;
	    nextPut: $-;
	    nextPutAll: (Date shortNameOfMonth: self month);
	    nextPut: $-;
	    print: self year
    ]

    storeOn: aStream [
	"Store on aStream Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream
	    nextPut: $(;
	    nextPutAll: self class storeString;
	    nextPutAll: ' newDay: ';
	    store: self day;
	    nextPutAll: ' monthIndex: ';
	    store: self month;
	    nextPutAll: ' year: ';
	    store: self year;
	    nextPut: $)
    ]

    days [
	"Private - Same as daysFromBaseDay"

	<category: 'private methods'>
	^days
    ]

    setDay: dayOfMonth monthIndex: monthIndex year: yearInteger [
	"Private - Set the receiver to the given date parts"

	<category: 'private methods'>
	days := dayOfMonth + (Date daysUntilMonth: monthIndex year: yearInteger).
	dayOfMonth < 1 ifTrue: [^self setDays: days].
	dayOfMonth > (Date daysInMonthIndex: monthIndex forYear: yearInteger) 
	    ifTrue: [^self setDays: days].
	day := dayOfMonth.
	month := monthIndex.
	year := yearInteger
    ]

    setDays: dayCount [
	"Private - Compute the date parts from the given dayCount and initialize
	 the receiver"

	"Fliegal and Van Flandern's methods for computing y/m/d from Julian.
	 The original algorithm starts by summing 68569 to the Julian day --
	 I sum 2483955 to adjust for smalltalk epoch."

	<category: 'private methods'>
	| julian n |
	days := dayCount.
	julian := days + 2483955.
	n := 4 * julian // 146097.
	julian := julian - ((146097 * n + 3) // 4).
	year := 4000 * (julian + 1) // 1461001.
	julian := julian - (1461 * year // 4) + 31.
	month := 80 * julian // 2447.
	day := julian - (2447 * month // 80).
	julian := month // 11.
	month := month + 2 - (12 * julian).
	year := 100 * (n - 49) + year + julian
    ]
]

