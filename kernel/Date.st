"======================================================================
|
|   Date Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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


Magnitude subclass: #Date
	  instanceVariableNames: 'days day month year'
	  classVariableNames: 'DayNameDict MonthNameDict'
	  poolDictionaries: ''
	  category: 'Language-Data types'!

Date comment: 
'My instances represent dates.  My base date is defined to be Jan 1, 1901.
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
method.' !


!Date class methodsFor: 'basic'!

initialize
    "Initialize the receiver"

    "28 = 7 days*2 keys each day, multiplied by 2 to make hashing effective.
     48 = 12 months*2 keys each month, multiplied by 2 for the same reason."
    DayNameDict := IdentityDictionary new: 28.
    MonthNameDict := IdentityDictionary new: 48.
    self initDayNameDict.
    self initMonthNameDict
!

initDayNameDict
    "Initialize the DayNameDict to the names of the days"
    | dayNames |
    dayNames := #(
    	    	 (#monday #mon)	"1"
    	    	 (#tuesday #tue) "2"
    	    	 (#wednesday #wed) "3"
    	    	 (#thursday #thu) "4"
    	    	 (#friday #fri)	"5"
    	    	 (#saturday #sat) "6"
    	    	 (#sunday #sun)	"7"
    	    	).
    dayNames keysAndValuesDo: [ :dayIndex :names |
	names do:
	    [ :name | DayNameDict at: name put: dayIndex ]
    ].
!

initMonthNameDict
    "Initialize the MonthNameDict to the names of the months"
    | monthNames |
    monthNames := #(
    	    	 (#january   #jan)	"1"
    	    	 (#february  #feb)	"2"
    	    	 (#march     #mar)    	"3"
    	    	 (#april     #apr)    	"4"
    	    	 (#may)	    	    	"5"
    	    	 (#june	     #jun)    	"6"
    	    	 (#july	     #jul)	"7"
    	    	 (#august    #aug)	"8"
    	    	 (#september #sep)	"9"
    	    	 (#october   #oct)	"10"
    	    	 (#november  #nov)	"11"
    	    	 (#december  #dec)	"12"
    	    	).
    monthNames doWithIndex: [ :names :dayIndex |
	names do:
	    [ :name | MonthNameDict at: name put: dayIndex ]
    ].
!


dayOfWeek: dayName
    "Answer the index of the day of week corresponding to the given name"
    ^DayNameDict at: dayName asLowercase asSymbol
!

nameOfDay: dayIndex
    "Answer the name of the day of week corresponding to the given index"
    ^#(#Monday #Tuesday #Wednesday #Thursday #Friday #Saturday #Sunday)
	at: dayIndex
!

abbreviationOfDay: dayIndex
    "Answer the abbreviated name of the day of week corresponding to the given
     index"
    ^#(#Mon #Tue #Wed #Thu #Fri #Sat #Sun) at: dayIndex
!

indexOfMonth: monthName
    "Answer the index of the month corresponding to the given name"
    ^MonthNameDict
	at: monthName asLowercase asSymbol
!

shortNameOfMonth: monthIndex
    "Answer the name of the month corresponding to the given index"
    ^#(#Jan #Feb #Mar #Apr #May #Jun #Jul #Aug #Sep #Oct #Nov #Dec)
	at: monthIndex
!

nameOfMonth: monthIndex
    "Answer the name of the month corresponding to the given index"
    ^#(#January #February  #March
       #April   #May       #June
       #July    #August    #September
       #October #November  #December) at: monthIndex
!

daysInMonth: monthName forYear: yearInteger
    "Answer the number of days in the given (named) month for the given year"
    | monthIndex |
    monthIndex := self indexOfMonth: monthName.
    ^self daysInMonthIndex: monthIndex forYear: yearInteger
!

daysInYear: i
    "Answer the number of days in the given year"
    ^((i + 4800) * 1461 // 4) - ((i + 4900) // 100 * 3 // 4)
    -((i + 4799) * 1461 // 4) + ((i + 4899) // 100 * 3 // 4)
! !


!Date class methodsFor: 'instance creation (Blue Book)'!

dateAndTimeNow
    "Answer an array containing the current date and time"
    | secondClock utcSecondClock |
    secondClock := Time secondClock.
    utcSecondClock := Time utcSecondClock.
    ^DateTime
	fromDays: secondClock // 86400
	seconds: secondClock \\ 86400
	offset: (Duration fromSeconds: secondClock - utcSecondClock)
!

utcDateAndTimeNow
    "Answer an array containing the current date and time in Coordinated
     Universal Time (UTC)"
    | utcSecondClock |
    utcSecondClock := Time utcSecondClock.
    ^DateTime
	fromDays: utcSecondClock // 86400
	seconds: utcSecondClock \\ 86400
	offset: Duration zero
!

today
    "Answer a Date denoting the current date in local time"
    ^self fromSeconds: Time secondClock
!

utcToday
    "Answer a Date denoting the current date in Coordinated Universal
     Time (UTC)"
    ^self fromSeconds: Time utcSecondClock
!

fromSeconds: time
    "Answer a Date denoting the date time seconds past Jan 1st, 1901"
    | days |
    days := time // (24 * 60 * 60).
    ^self new setDays: days
!


fromJulian: jd
    "Answer a Date denoting the jd-th day in the astronomical Julian calendar."
    ^self new setDays: jd - 2415386
!

fromDays: dayCount
    "Answer a Date denoting dayCount days past 1/1/1901"
    ^self new setDays: dayCount
!

newDay: dayCount year: yearInteger
    "Answer a Date denoting the dayCount day of the yearInteger year"
    ^self new setDays:
	dayCount + (self yearAsDays: yearInteger)
!

newDay: day monthIndex: monthIndex year: yearInteger
    "Answer a Date denoting the dayCount day of the given (as a number)
     month and year"
    ^self new
	setDay: day
	monthIndex: monthIndex
	year: yearInteger
!

newDay: day month: monthName year: yearInteger
    "Answer a Date denoting the dayCount day of the given (named)
     month and year"
    ^self new
	setDay: day
	monthIndex: (self indexOfMonth: monthName)
	year: yearInteger
!

readFrom: aStream
    "Parse an instance of the receiver from aStream"
    | t1 t2 t3 ch month ws |
    1 to: 3 do: [ :i |
        ws := WriteStream on: (String new: 10).
	[ aStream atEnd not and: [
	     (ch := aStream next) isAlphaNumeric not ]] whileTrue.

	ch isAlphaNumeric ifTrue: [
	    [ ws nextPut: ch. aStream atEnd not and: [
		(ch := aStream next) isAlphaNumeric ]] whileTrue.
	].
	
	t1 := t2. t2 := t3. t3 := ws contents.

	(t3 at: 1) isDigit
	    ifTrue: [ t3 := t3 asNumber ]
	    ifFalse: [
	        month := i.
	        t3 := self indexOfMonth: t3 asSymbol.
	    ].

	(i = 2 and: [ month = 1 and: [ t3 > 31 ]])  "January 2000" 
	    ifTrue: [ ^self newDay: 1 monthIndex: t2 year: t3 ].
    ].

    month isNil ifTrue: [
	t1 > 31
	    ifTrue: [ ^self newDay: t3 monthIndex: t2 year: t1 ]. "YMD"
	^t1 <= 12
	    ifTrue: [ ^self newDay: t2 monthIndex: t1 year: t3 ]  "MDY"
	    ifFalse: [ ^self newDay: t1 monthIndex: t2 year: t3 ] "DMY"
    ].

    ^month = 1 
	ifTrue: [ self newDay: t2 monthIndex: t1 year: t3 ] "MDY"
	ifFalse: [ self newDay: t1 monthIndex: t2 year: t3 ] "DMY"
! !


!Date class methodsFor: 'instance creation (ANSI)'!

year: y month: m day: d hour: h minute: min second: s
    "Answer a Date denoting the d-th day of the given (as a number)
     month and year"
    ^self new
	setDay: d
	monthIndex: m
	year: y
!

year: y day: d hour: h minute: min second: s
    "Answer a Date denoting the d-th day of the given year"
    ^self new
	setDays: (self yearAsDays: y) + d
! !


!Date class methodsFor: 'private methods'!

yearAsDays: i
    "Private - Returns the number of days between Jan 1, 1901
     and Jan 0th of the given year yearInteger"
	
    "Calculate Julian day via Fliegal & Van Flandern method
     -- ACM Algorithm 289. I have to subtract 2415387 to correct for Smalltalk
     epoch, and I merged that constant in the one (32074) in their formula."
    ^((i + 4799) * 1461 // 4)
	 - ((i + 4899) // 100 * 3 // 4)
	 - 2447125!

daysUntilMonth: monthIndex year: yearInteger
    "Private - Answer the number of days between Jan 1, 1901, and the
     hypotetical 0th day in the given month, for the given year"
    | i j |
    j := (monthIndex - 14) quo: 12.
    i := j + yearInteger.
	
    "Calculate Julian day via Fliegal & Van Flandern method
     -- ACM Algorithm 289. I have to subtract 2415386 to correct for Smalltalk
     epoch, and I merged that constant in the one (32074) in their formula."
    ^((i + 4800) * 1461 // 4)
	 + ((monthIndex - 2 - (j * 12)) * 367 // 12)
	 - ((i + 4900) // 100 * 3 // 4)
	 - 2447461
!


daysInMonthIndex: monthIndex forYear: yearInteger
    "Private - Answer the number of days in the given (indexed) month,
     for the given year"

    monthIndex = 2
    	ifTrue: [ ^(self daysInYear: yearInteger) - 337 ].

    ^#[ 31 0 31				"Jan Feb Mar"
	30 31 30			"Apr May Jun"
	31 31 30			"Jul Aug Sep"
	31 30 31] at: monthIndex	"Oct Nov Dec"
! !


!Date methodsFor: 'testing'!

< aDate
    "Answer whether the receiver indicates a date preceding aDate"
    ^self days < aDate days
!

= aDate
    "Answer whether the receiver indicates the same date as aDate"
    ^(aDate class == self class) and: [ aDate days = self days ]
!

hash
    "Answer an hash value for the receievr"
    ^self days
! !


!Date methodsFor: 'basic'!

addDays: dayCount
    "Answer a new Date pointing dayCount past the receiver"
    ^Date fromDays: self days + dayCount
!

subtractDays: dayCount
    "Answer a new Date pointing dayCount before the receiver"
    ^Date fromDays: self days - dayCount
!

subtractDate: aDate
    "Answer the number of days between aDate and the receiver (negative
     if the receiver is before aDate)"
    ^self days - aDate days
! !


!Date methodsFor: 'compatibility (non-ANSI)'!

day
    "Answer the day represented by the receiver"
    ^day
!

dayName
    "Answer the day of week of the receiver as a Symbol"
    ^Date nameOfDay: ((self days + 1) \\ 7 + 1)
!

shortMonthName
    "Answer the abbreviated name of the month represented by the receiver"
    ^Date shortNameOfMonth: self month
! !

!Date methodsFor: 'date computations'!

asSeconds
    "Answer the date as the number of seconds from 1/1/1901."
    ^self days * 86400
!

dayOfWeek
    "Answer the day of week of the receiver. 1 = Monday, 7 = Sunday"
    ^(self days + 1) \\ 7 + 1
!

dayOfWeekName
    "Answer the day of week of the receiver as a Symbol"
    ^Date nameOfDay: ((self days + 1) \\ 7 + 1)
!

dayOfWeekAbbreviation
    "Answer the day of week of the receiver as a Symbol"
    ^Date abbreviationOfDay: ((self days + 1) \\ 7 + 1)
!

dayOfMonth
    "Answer the day represented by the receiver (same as #day)"
    ^day
!

dayOfYear
    "Answer the days passed since 31/12 of last year; e.g. New Year's Day is 1"
    ^self days - (Date yearAsDays: self year)
!

daysFromBaseDay
    "Answer the days passed since 1/1/1901"
    ^days
!

daysInMonth
    "Answer the days in the month represented by the receiver"
    ^Date daysInMonthIndex: month forYear: year
!

daysInYear
    "Answer the days in the year represented by the receiver"
    ^Date daysInYear: self year
!

daysLeftInMonth
    "Answer the days to the end of the month represented by the receiver"
    ^(Date daysInMonthIndex: month forYear: year) - day
!

daysLeftInYear
    "Answer the days to the end of the year represented by the receiver"
    ^(Date yearAsDays: self year + 1) - self days
!

firstDayOfMonth
    "Answer a Date representing the first day of the month represented by the
     receiver"
    ^self subtractDays: self dayOfMonth - 1
!

isLeapYear
    "Answer whether the receiver refers to a date in a leap year."
    ^self daysInYear == 366
!

lastDayOfMonth
    "Answer a Date representing the last day of the month represented by the
     receiver"
    ^self addDays: self daysLeftInMonth
!

month
    "Answer the index of the month represented by the receiver"
    ^month
!

monthIndex
    "Answer the index of the month represented by the receiver"
    ^month
!

monthName
    "Answer the name of the month represented by the receiver"
    ^Date nameOfMonth: self month
!

monthAbbreviation
    "Answer the abbreviated name of the month represented by the receiver"
    ^Date shortNameOfMonth: self month
!

year
    "Answer the year represented by the receiver"
    ^year
! !


!Date methodsFor: 'printing'!

printOn: aStream
    "Print a representation for the receiver on aStream"
    aStream
	print: self day;
	nextPut: $-;
	nextPutAll: (Date shortNameOfMonth: self month);
	nextPut: $-;
	print: self year
! !



!Date methodsFor: 'storing'!

storeOn: aStream
    "Store on aStream Smalltalk code compiling to the receiver"

    aStream
	nextPut: $(;
	nextPutAll: self classNameString;
	nextPutAll: ' newDay: ';
	store: self day;
	nextPutAll: ' monthIndex: ';
	store: self month;
	nextPutAll: ' year: ';
	store: self year;
	nextPut: $)
! !



!Date methodsFor: 'private methods'!

days
    "Private - Same as daysFromBaseDay"
    ^days
!

setDay: dayOfMonth monthIndex: monthIndex year: yearInteger
    "Private - Set the receiver to the given date parts"

    days := dayOfMonth + (Date daysUntilMonth: monthIndex year: yearInteger).
    dayOfMonth < 1
	ifTrue: [ ^self setDays: days ].
    dayOfMonth > (Date daysInMonthIndex: monthIndex forYear: yearInteger)
	ifTrue: [ ^self setDays: days ].

    day := dayOfMonth.
    month := monthIndex.
    year := yearInteger.
!

setDays: dayCount
    "Private - Compute the date parts from the given dayCount and initialize
     the receiver"

    "Fliegal and Van Flandern's methods for computing y/m/d from Julian.
     The original algorithm starts by summing 68569 to the Julian day --
     I sum 2483955 to adjust for smalltalk epoch."

    | julian n |
    days := dayCount.
    julian := days + 2483955.
    n := (4 * julian) // 146097.
    julian := julian - ((146097 * n + 3) // 4).
    year := (4000 * (julian + 1)) // 1461001.
    julian := julian - ((1461 * year) // 4) + 31.
    month := (80 * julian) // 2447.
    day := julian - ((2447 * month) // 80).
    julian := month // 11.
    month := month + 2 - (12 * julian).
    year := (100 * (n - 49)) + year + julian.
! !
