"======================================================================
|
|   LC_TIME support
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002 Free Software Foundation, Inc.
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
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU Lesser
| General Public License for more details.
|
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"



LcPrintFormats subclass: LcTime [
    | abday day abmon mon amPm dtFmt dFmt tFmt tFmtAmPm altDigits |
    
    <comment: 'Sending either #?, #printString: or #print:on: converts a Date or Time
to a String according to the rules that are used in the given locale.'>
    <category: 'i18n-Printing'>

    LcTime class >> category [
	"Answer the environment variable used to determine the default
	 locale"

	<category: 'accessing'>
	^#LC_TIME
    ]

    LcTime class >> selector [
	"Answer the selector that accesses the receiver when sent to a Locale
	 object."

	<category: 'accessing'>
	^#time
    ]

    print: aDateOrTimeOrArray on: aStream [
	"Print aDateOrTimeOrArray on aStream according to the receiver's
	 formatting conventions.  It can be a Date, Time, DateTime, or
	 an array made of a Date and a Time"

	<category: 'printing'>
	^self 
	    print: aDateOrTimeOrArray
	    on: aStream
	    ifFull: dtFmt
	    ifDate: dFmt
	    ifTime: tFmt
    ]

    print: aDate time: aTime format: aString on: aStream [
	"Print the specified date and time on aStream according to the
	 receiver's formatting conventions, using the given format.
	 The valid abbreviations are the same used by the C function
	 strftime:
	 abbreviated weekday	      (%a)
	 weekday			      (%A)
	 abbreviated month	      (%b)
	 month			      (%B)
	 date & time		      (%c)
	 century			      (%C)
	 day of the month	      (%d)
	 date (US)		      (%D)
	 day of the month	      (%e)
	 year for the ISO week	      (%g)
	 year for the ISO week	      (%G)
	 abbreviated month	      (%h)
	 hours			      (%H)
	 hours (AM/PM)		      (%I)
	 day of the year		      (%j)
	 hours			      (%k)
	 hours (AM/PM)		      (%l)
	 month			      (%m)
	 minutes			      (%M)
	 AM/PM			      (%p)
	 lowercase AM/PM		      (%P)
	 AM/PM time		      (%r)
	 time (US)		      (%R)
	 time_t			      (%s)
	 seconds			      (%S)
	 time (US)		      (%T)
	 day of the week		      (%u)
	 week number starting at Sun   (%U)
	 week number starting at Thu   (%V)
	 day of the week, Sunday=0     (%w)
	 week number starting at Mon   (%W)
	 date			      (%x)
	 time			      (%X)
	 year (2-digit)		      (%y)
	 year (4-digit)		      (%Y)."

	<category: 'printing'>
	| what |
	what := 
		{aDate.
		aTime}.
	self 
	    strftime: what
	    format: aString readStream
	    on: aStream
    ]

    print: aDateOrTimeOrArray on: aStream ifFull: fullFmt ifDate: dateFmt ifTime: timeFmt [
	"Print aDateOrTimeOrArray on aStream according to the receiver's
	 formatting conventions.  It can be a Date, Time, DateTime, or
	 an array made of a Date and a Time: Date is printed with
	 dateFmt and Time with timeFmt, while in the other cases
	 fullFmt is used.  For information on the formatting codes,
	 see #print:time:format:on:."

	<category: 'printing'>
	| what format |
	format := fullFmt.
	what := aDateOrTimeOrArray.
	aDateOrTimeOrArray class == Date 
	    ifTrue: 
		[what := Array with: aDateOrTimeOrArray with: nil.
		format := dateFmt].
	aDateOrTimeOrArray class == Time 
	    ifTrue: 
		[what := Array with: nil with: aDateOrTimeOrArray.
		format := timeFmt].
	^self 
	    strftime: what
	    format: format readStream
	    on: aStream
    ]

    allFormatsExample [
	"Answer a long string that includes all the possible formats"

	<category: 'tests'>
	^'
%%a   %tabbreviated weekday	      %a
%%A   %tweekday			      %A
%%b   %tabbreviated month	      %b
%%B   %tmonth			      %B
%%c   %tdate & time		      %c
%%C   %tcentury			      %C
%%d   %tday of the month	      %d
%%D   %tdate (US)		      %D
%%e   %tday of the month	      %e
%%g   %tyear for the ISO week	      %g
%%G   %tyear for the ISO week	      %G
%%h   %tabbreviated month	      %h
%%H   %thours			      %H
%%I   %thours (AM/PM)		      %I
%%j   %tday of the year		      %j
%%k   %thours			      %k
%%l   %thours (AM/PM)		      %l
%%m   %tmonth			      %m
%%M   %tminutes			      %M
%%p   %tAM/PM			      %p
%%P   %tlowercase AM/PM		      %P
%%r   %tAM/PM time		      %r
%%R   %ttime (US)		      %R
%%s   %ttime_t			      %s
%%S   %tseconds			      %S
%%T   %ttime (US)		      %T
%%u   %tday of the week		      %u
%%U   %tweek number starting at Sun   %U
%%V   %tweek number starting at Thu   %V
%%w   %tday of the week, Sunday=0     %w
%%W   %tweek number starting at Mon   %W
%%x   %tdate			      %x
%%X   %ttime			      %X
%%y   %tyear (2-digit)		      %y
%%Y   %tyear (4-digit)		      %Y%n'
    ]

    strftime: timestamp format: formatStream on: aStream [
	<category: 'private'>
	| d t |
	d := timestamp at: 1.
	t := timestamp at: 2.
	[formatStream atEnd] whileFalse: 
		[aStream nextPutAll: (formatStream upTo: $%).
		self 
		    strftimeField: timestamp
		    format: formatStream
		    on: aStream
		    date: d
		    time: t]
    ]

    strftimeField: timestamp format: formatStream on: aStream date: d time: t [
	"OUCH! This methods is 300+ lines long... but we need re-entrancy, and
	 I don't want to create a separate object to print a particular
	 date & time pair."

	<category: 'private'>
	| pad padTo ch output fmt case invertCase modifier dow |
	pad := nil.
	padTo := 1.
	case := #yourself.
	invertCase := false.
	
	[ch := formatStream next.
	ch == $_ 
	    ifTrue: 
		[pad := $ .
		true]
	    ifFalse: 
		[ch == $- 
		    ifTrue: 
			[pad := nil.
			true]
		    ifFalse: 
			[ch == $0 
			    ifTrue: 
				[pad := $0.
				true]
			    ifFalse: 
				[ch == $^ 
				    ifTrue: 
					[case := #asUppercase.
					true]
				    ifFalse: 
					[(ch == $#)
					    ifTrue: [invertCase := true];
					    yourself]]]]] 
		whileTrue.
	modifier := nil.
	ch == $E ifTrue: [modifier := $E].
	ch == $O ifTrue: [modifier := $O].
	modifier isNil ifFalse: [ch := formatStream next].
	ch == $% ifTrue: [output := '%'].

	"Abbreviated weekday"
	ch == $a 
	    ifTrue: 
		[dow := (d days + 2) \\ 7 + 1.
		output := abday at: dow.
		invertCase ifTrue: [case := #asUppercase]].

	"Weekday"
	ch == $A 
	    ifTrue: 
		[dow := (d days + 2) \\ 7 + 1.
		output := day at: dow.
		invertCase ifTrue: [case := #asUppercase]].

	"Abbreviated month"
	(ch == $b or: [ch == $h]) 
	    ifTrue: 
		[output := abmon at: d month.
		invertCase ifTrue: [case := #asUppercase]].

	"Month"
	ch == $B 
	    ifTrue: 
		[output := mon at: d month.
		invertCase ifTrue: [case := #asUppercase]].

	"Full date"
	ch == $c 
	    ifTrue: 
		[fmt := dtFmt.
		output := String streamContents: 
				[:stream | 
				self 
				    strftime: timestamp
				    format: fmt readStream
				    on: stream]].

	"Century"
	ch == $C ifTrue: [output := d year // 100].

	"Day of month"
	ch == $d 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := d day].

	"Date (month/day/year)"
	ch == $D 
	    ifTrue: 
		[output := String streamContents: 
				[:stream | 
				self 
				    strftime: timestamp
				    format: '%m/%d/%y' readStream
				    on: stream]].

	"Day of month"
	ch == $e 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $ ].
		padTo := 2.
		output := d day].

	"Hours"
	ch == $H 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := t hours].

	"Hours (12-hours format)"
	ch == $I 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := t hours \\ 12.
		output = 0 ifTrue: [output := 12]].

	"Day of year"
	ch == $j 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 3.
		output := d dayOfYear].

	"Hours"
	ch == $k 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $ ].
		padTo := 2.
		output := t hours].

	"Hours (12-hours format)"
	ch == $l 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $ ].
		padTo := 2.
		output := t hours \\ 12.
		output = 0 ifTrue: [output := 12]].

	"Month"
	ch == $m 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := d month].

	"Minutes"
	ch == $M 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := t minutes].

	"Newline"
	ch == $n ifTrue: [output := Character nl asString].

	"AM/PM"
	ch == $p 
	    ifTrue: 
		[output := amPm at: t hours // 12 + 1.
		invertCase ifTrue: [case := #asLowercase]].

	"Lowercase AM/PM"
	ch == $P 
	    ifTrue: 
		[output := amPm at: t hours // 12 + 1.
		case := #asLowercase].

	"AM/PM time"
	ch == $r 
	    ifTrue: 
		[output := String streamContents: 
				[:stream | 
				self 
				    strftime: timestamp
				    format: tFmtAmPm readStream
				    on: stream]].

	"Hours:Minutes time"
	ch == $R 
	    ifTrue: 
		[output := String streamContents: 
				[:stream | 
				self 
				    strftime: timestamp
				    format: '%H:%M' readStream
				    on: stream]].

	"Seconds since 1/1/1970"
	ch == $s 
	    ifTrue: 
		[output := Date 
			    newDay: 1
			    monthIndex: 1
			    year: 1970.
		output := d isNil ifTrue: [0] ifFalse: [(d subtractDate: output) * 86400].
		output := t isNil ifTrue: [output] ifFalse: [output + t asSeconds]].

	"Seconds since 1/1/1970"
	ch == $S 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := t seconds].

	"Tab"
	ch == $t ifTrue: [output := Character tab asString].

	"Hours:Minutes:Seconds time"
	ch == $T 
	    ifTrue: 
		[output := String streamContents: 
				[:stream | 
				self 
				    strftime: timestamp
				    format: '%H:%M:%S' readStream
				    on: stream]].

	"Day of week, 1=Monday, 7=Sunday"
	ch == $u ifTrue: [output := d dayOfWeek].

	"Week, first day=Sunday, 0 if before first Sunday"
	ch == $U 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := d weekStartingAt: 7].

	"Week, first day=Thursday, 52 or 53 if before first Thursday"
	ch == $V 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := d weekStartingAt: 4.
		output = 0 ifTrue: [output := (d subtractDays: d day) weekStartingAt: 4]].

	"Day of week, Sunday=0, Saturday=6"
	ch == $w ifTrue: [output := d dayOfWeek \\ 7].

	"Week, first day=Monday, 0 if before first Monday"
	ch == $W 
	    ifTrue: 
		[pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := d weekStartingAt: 1].

	"Date"
	ch == $x 
	    ifTrue: 
		[fmt := dFmt.
		output := String streamContents: 
				[:stream | 
				self 
				    strftime: timestamp
				    format: fmt readStream
				    on: stream]].

	"Time"
	ch == $X 
	    ifTrue: 
		[fmt := tFmt.
		output := String streamContents: 
				[:stream | 
				self 
				    strftime: timestamp
				    format: fmt readStream
				    on: stream]].

	"Current year or (if `g' and before first Thursday of the year) previous
	 year; 2 digits."
	(ch == $y or: [ch == $g]) 
	    ifTrue: 
		[output := d year.
		ch == $g 
		    ifTrue: [(d weekStartingAt: 4) = 0 ifTrue: [output := output - 1]].
		pad isNil ifTrue: [pad := $0].
		padTo := 2.
		output := output \\ 100].

	"Current year or (if `g' and before first Thursday of the year) previous
	 year; 4 digits."
	(ch == $Y or: [ch == $G]) 
	    ifTrue: 
		[output := d year.
		ch == $G 
		    ifTrue: [(d weekStartingAt: 4) = 0 ifTrue: [output := output - 1]].
		pad isNil ifTrue: [pad := $ ].
		padTo := 4].
	ch == $Z ifTrue: [output := ''].
	output isNil 
	    ifTrue: 
		[output := ch asString.
		case := #yourself].
	(output isInteger and: [modifier == $O]) 
	    ifTrue: 
		[modifier := nil.
		output < altDigits size ifTrue: [output := altDigits at: output + 1]].
	modifier isNil ifFalse: [self error: 'invalid modifier specified'].
	output isInteger 
	    ifTrue: 
		[output := output printString.
		pad isNil 
		    ifFalse: 
			[ch := $0.
			padTo - output size timesRepeat: 
				[(output at: 1) == $- 
				    ifTrue: 
					[output at: 1 put: $0.
					ch := $-].
				aStream nextPut: ch.
				ch := $0]].
		case := #yourself].
	output := output perform: case.
	aStream nextPutAll: output
    ]
]



Date extend [

    weekStartingAt: startDay [
	<category: 'calculations'>
	| yday wday weekDayJan1 first |
	yday := self dayOfYear - 1.	"January 1st = 0"
	wday := self dayOfWeek.
	weekDayJan1 := (wday - yday) \\ 7.	"week day for January 1st"
	first := (startDay - weekDayJan1) \\ 7.	"day of year for first startDay"
	^(yday - first) // 7 + 1
    ]

]

