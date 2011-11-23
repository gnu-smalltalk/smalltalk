"======================================================================
|
|   Test the Date class
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1999, 2007, 2008 Free Software Foundation.
| Written by Paolo Bonzini and Jeff Rosenwald.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Date class extend [

    inspect: aDate and: anotherDate day: dd month: mm year: yyyy [
        Transcript
	    show: 'newDay: ';
	    print: aDate;
	    show: '(';
	    print: aDate days;
	    show: ') <--> ';
	    print: dd;
	    show: '-';
	    show: (self shortNameOfMonth: mm);
	    show: '-';
	    print: yyyy;
	    show: ' <--> fromDays: ';
	    print: anotherDate;
	    show: '(';
	    print: anotherDate days;
	    show: ')';
	    nl.
            
        ^self error: 'bad status'.
    ]

    test3 [
            | i d |
            -100 to: 100 do: [:j |
                    i _ (j * 24 * 3600) - 1.  "23:59:59"
                    d _ self fromSeconds: i.
                    i print. Transcript space. d day print. Transcript space.
                    d month print. Transcript space. d year print.
                    Transcript space. d days printNl.
    
                    i _ (j * 24 * 3600) .  "00:00:00"
                    d _ self fromSeconds: i.
                    i print. Transcript space. d day print. Transcript space.
                    d month print. Transcript space. d year print.
                    Transcript space. d days printNl.
            ]
    ]

    test [
        | r r1 d1 k |
        "This step tests a reasonable interval of years in a small time.
         Note that 7 is prime with 4, 100, 400."
        1700 to: 4500 by: 7 do: [:yyyy |
	    (Date daysInYear: yyyy) = 366
		    ifTrue: [ Transcript show: 'leap ' ].
	    yyyy printNl.
	    1 to: 12 do: [:mm |
                k _ Date daysInMonthIndex: mm forYear: yyyy.
                1 to: k do: [:dd |
		    r _ Date newDay: dd monthIndex: mm year: yyyy.
		    r1 _ Date fromDays: (r days).
    
		    (r month = r1 month) & (r day = r1 day) &
		    (r year = r1 year) & (r1 days = r days) &
		    (r1 dayOfWeek = r dayOfWeek) & (r month = mm) &
		    (r day = dd) & (r year = yyyy) &
		    (d1 isNil or: [ (d1 - r daysFromBaseDay) ~= 1 ]) ifFalse: [
		        self
			    inspect: r and: r1
			    day: dd month: mm year: yyyy ].
		    d1 := r daysFromBaseDay.
	        ].
	    ]
        ].
    ]

    test2 [
    
        #(1600 1699 1700 1799 1800 1899 1900 1901 1996 1997 1998 1999 2000 2001)
	    do: [ :y |
	        (Date newDay: 1 month: #jan year: y) print. Transcript space.
	        (Date newDay: 1 month: #feb year: y) print. Transcript space.
	        (Date newDay: 28 month: #feb year: y) print. Transcript space.
	        (Date newDay: 1 month: #mar year: y) print. Transcript space.
	        (Date newDay: 31 month: #dec year: y) print. Transcript space.
	        (Date newDay: 29 month: #feb year: y) printNl
	    ]
    ]
]

Eval [ Date test ]
Eval [ Date test2 ]
Eval [ Date test3 ]

String extend [
    suffix: suffix testReading: aClass [
        | stream result |
        stream := (self, suffix) readStream.
        result := aClass readFrom: (self, suffix) readStream.
        (stream upToEnd endsWith: suffix trimSeparators) ifFalse: [^nil].
        result = (aClass readFrom: self readStream) ifFalse: [^nil].
        ^result->self
    ]
]

Eval [
    ('2011-02-01' suffix: ' abcd' testReading: Date) printNl.
    ('2011-02-01' suffix: 'abcd' testReading: Date) printNl.
    ('Feb 1 2011' suffix: ' abcd' testReading: Date) printNl.
    ('Feb 1 2011' suffix: 'abcd' testReading: Date) printNl.
    ('-2011-02-01' suffix: ' abcd' testReading: Date) printNl.
    ('-2011-02-01' suffix: 'abcd' testReading: Date) printNl.
    ('Feb 1 -2011' suffix: ' abcd' testReading: Date) printNl.
    ('Feb 1 -2011' suffix: 'abcd' testReading: Date) printNl.

    ('09:00:02' suffix: ' 1234' testReading: Time) printNl.
    ('09:00:02' suffix: ':1234' testReading: Time) printNl.
    ('09:00:02' suffix: ' abcd' testReading: Time) printNl.
    ('09:00:02' suffix: 'abcd' testReading: Time) printNl.
    ('09:00' suffix: ' 1234' testReading: Time) printNl.
    ('09:00' suffix: '::1234' testReading: Time) printNl.
    ('09:00' suffix: ' abcd' testReading: Time) printNl.
    ('09:00' suffix: 'abcd' testReading: Time) printNl.
    ('9:00' suffix: ' 1234' testReading: Time) printNl.
    ('9:00' suffix: '::1234' testReading: Time) printNl.
    ('9:00' suffix: ' abcd' testReading: Time) printNl.
    ('9:00' suffix: 'abcd' testReading: Time) printNl.

    ('01:09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('01:09:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('01:09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('01:09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('1:09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('1:09:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('1:09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('1:09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('1:9:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('1:9:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('1:9:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('1:9:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('09:00:02' suffix: '::1234' testReading: Duration) printNl.
    ('09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('9:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('9:00:02' suffix: '::1234' testReading: Duration) printNl.
    ('9:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('9:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('09:00' suffix: ' 1234' testReading: Duration) printNl.
    ('09:00' suffix: '::1234' testReading: Duration) printNl.
    ('09:00' suffix: ' abcd' testReading: Duration) printNl.
    ('09:00' suffix: 'abcd' testReading: Duration) printNl.
    ('9:00' suffix: ' 1234' testReading: Duration) printNl.
    ('9:00' suffix: '::1234' testReading: Duration) printNl.
    ('9:00' suffix: ' abcd' testReading: Duration) printNl.
    ('9:00' suffix: 'abcd' testReading: Duration) printNl.
    ('-01:09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('-01:09:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('-01:09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('-01:09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('-1:09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('-1:09:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('-1:09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('-1:09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('-1:9:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('-1:9:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('-1:9:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('-1:9:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('-09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('-09:00:02' suffix: '::1234' testReading: Duration) printNl.
    ('-09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('-09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('-9:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('-9:00:02' suffix: '::1234' testReading: Duration) printNl.
    ('-9:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('-9:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('-09:00' suffix: ' 1234' testReading: Duration) printNl.
    ('-09:00' suffix: '::1234' testReading: Duration) printNl.
    ('-09:00' suffix: ' abcd' testReading: Duration) printNl.
    ('-09:00' suffix: 'abcd' testReading: Duration) printNl.
    ('-9:00' suffix: ' 1234' testReading: Duration) printNl.
    ('-9:00' suffix: '::1234' testReading: Duration) printNl.
    ('-9:00' suffix: ' abcd' testReading: Duration) printNl.
    ('-9:00' suffix: 'abcd' testReading: Duration) printNl.
    ('+01:09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('+01:09:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('+01:09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('+01:09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('+1:09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('+1:09:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('+1:09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('+1:09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('+1:9:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('+1:9:00:02' suffix: ':1234' testReading: Duration) printNl.
    ('+1:9:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('+1:9:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('+09:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('+09:00:02' suffix: '::1234' testReading: Duration) printNl.
    ('+09:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('+09:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('+9:00:02' suffix: ' 1234' testReading: Duration) printNl.
    ('+9:00:02' suffix: '::1234' testReading: Duration) printNl.
    ('+9:00:02' suffix: ' abcd' testReading: Duration) printNl.
    ('+9:00:02' suffix: 'abcd' testReading: Duration) printNl.
    ('+09:00' suffix: ' 1234' testReading: Duration) printNl.
    ('+09:00' suffix: '::1234' testReading: Duration) printNl.
    ('+09:00' suffix: ' abcd' testReading: Duration) printNl.
    ('+09:00' suffix: 'abcd' testReading: Duration) printNl.
    ('+9:00' suffix: ' 1234' testReading: Duration) printNl.
    ('+9:00' suffix: '::1234' testReading: Duration) printNl.
    ('+9:00' suffix: ' abcd' testReading: Duration) printNl.
    ('+9:00' suffix: 'abcd' testReading: Duration) printNl.

    ('2011-02-01 09:00  +01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('2011-02-01 09:00  +01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00  +01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00 +01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('2011-02-01 09:00 +01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00 +01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00+01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('2011-02-01 09:00+01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00+01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00+1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00+1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00+01' suffix: ' 1234' testReading: DateTime) printNl.
    ('2011-02-01 09:00+01' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00+01' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+01' suffix: ' 1234' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+01' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10+01' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00  -01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00  -01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00 -01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00 -01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10-01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10-01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10-1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10-1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00-01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00-01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00-1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00-1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00:10' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01 09:00' suffix: 'abcd' testReading: DateTime) printNl.

    ('2011-02-01T09:00+01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00+01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00+1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00+1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00+01' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00+01' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10+01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10+01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10+1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10+1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10+01' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10+01' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10-01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10-01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10-1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10-1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00-01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00-01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00-1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00-1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00:10' suffix: 'abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01T09:00' suffix: 'abcd' testReading: DateTime) printNl.

    ('2011-02-01' suffix: ' abcd' testReading: DateTime) printNl.
    ('2011-02-01' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011' suffix: 'abcd' testReading: DateTime) printNl.

    ('-2011-02-01T09:00+01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('-2011-02-01T09:00+01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('-2011-02-01' suffix: ' abcd' testReading: DateTime) printNl.
    ('-2011-02-01' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 -2011' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 -2011' suffix: 'abcd' testReading: DateTime) printNl.

    ('Feb 1 2011 09:00  +01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00  +01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00  +01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00 +01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00 +01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00 +01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+01' suffix: ' 1234' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+01' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+01' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+01:30' suffix: ' 1234' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+01' suffix: ' 1234' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+01' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+01' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10+1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00+1:30' suffix: 'abcd' testReading: DateTime) printNl.

    ('Feb 1 2011 09:00  -01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00  -01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00 -01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00 -01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00-01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00-01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10-01:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10-01:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10-1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10-1:30' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00-1:30' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00-1:30' suffix: 'abcd' testReading: DateTime) printNl.

    ('Feb 1 2011 09:00:10' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00:10' suffix: 'abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00' suffix: ' abcd' testReading: DateTime) printNl.
    ('Feb 1 2011 09:00' suffix: 'abcd' testReading: DateTime) printNl.
]
