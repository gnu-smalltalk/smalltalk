"======================================================================
|
|   Smalltalk GLib/GObject bindings (loading script).
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2009, 2011 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: GType [
    
    <category: 'GLib'>
    <comment: nil>

    GType class [
	| gtkTypes |
    ]

    GType class >> registerAllTypes [
	<category: 'registering GObject types'>
	gtkTypes isNil ifTrue: [gtkTypes := OrderedCollection new].
	gtkTypes do: [:each | self register: each forType: each getType]
    ]

    GType class >> registerType: aClass [
	<category: 'registering GObject types'>
	gtkTypes isNil ifTrue: [gtkTypes := OrderedCollection new].
	gtkTypes addLast: aClass.
	self register: aClass forType: aClass getType
    ]

    GType class >> update: anObject [
	<category: 'registering GObject types'>
	anObject == #returnFromSnapshot ifTrue: [self registerAllTypes]
    ]
]



Object subclass: GQuark [
    
    <category: 'GLib'>
    <comment: nil>
]



CObject subclass: GOptionContext [
    
    <category: 'GLib'>
    <comment: nil>
]



CObject subclass: GOptionGroup [
    
    <category: 'GLib'>
    <comment: nil>
]



CObject subclass: GOptionEntry [
    
    <category: 'GLib'>
    <comment: nil>
]



CObject subclass: GDate [
    
    <category: 'GLib'>
    <comment: nil>
]


!GDate class methodsFor: 'C call-outs'!
new
    <cCall: 'g_date_new' returning: #{GDate}
        args: #( )>!

newDmy: day month: month year: year
    <cCall: 'g_date_new_dmy' returning: #{GDate}
        args: #( #int #int #int )>!

newJulian: julianDay
    <cCall: 'g_date_new_julian' returning: #{GDate}
        args: #( #int )>!

!GDate methodsFor: 'C call-outs'!
free
    (self isAbsolute and: [ self address > 0 ])
        ifTrue: [ self primFree. self address: 0 ]!

primFree
    <cCall: 'g_date_free' returning: #void
        args: #( #self )>!

valid
    <cCall: 'g_date_valid' returning: #boolean
        args: #( #self )>!

validDay: day
    <cCall: 'g_date_valid_day' returning: #boolean
        args: #( #int )>!

validMonth: month
    <cCall: 'g_date_valid_month' returning: #boolean
        args: #( #int )>!

validYear: year
    <cCall: 'g_date_valid_year' returning: #boolean
        args: #( #int )>!

validWeekday: weekday
    <cCall: 'g_date_valid_weekday' returning: #boolean
        args: #( #int )>!

validJulian: julianDate
    <cCall: 'g_date_valid_julian' returning: #boolean
        args: #( #int )>!

validDmy: day month: month year: year
    <cCall: 'g_date_valid_dmy' returning: #boolean
        args: #( #int #int #int )>!

getWeekday
    <cCall: 'g_date_get_weekday' returning: #int
        args: #( #self )>!

getMonth
    <cCall: 'g_date_get_month' returning: #int
        args: #( #self )>!

getYear
    <cCall: 'g_date_get_year' returning: #int
        args: #( #self )>!

getDay
    <cCall: 'g_date_get_day' returning: #int
        args: #( #self )>!

getJulian
    <cCall: 'g_date_get_julian' returning: #int
        args: #( #self )>!

getDayOfYear
    <cCall: 'g_date_get_day_of_year' returning: #int
        args: #( #self )>!

getMondayWeekOfYear
    <cCall: 'g_date_get_monday_week_of_year' returning: #int
        args: #( #self )>!

getSundayWeekOfYear
    <cCall: 'g_date_get_sunday_week_of_year' returning: #int
        args: #( #self )>!

getIso8601WeekOfYear
    <cCall: 'g_date_get_iso8601_week_of_year' returning: #int
        args: #( #self )>!

clear: nDates
    <cCall: 'g_date_clear' returning: #void
        args: #( #self #int )>!

setParse: str
    <cCall: 'g_date_set_parse' returning: #void
        args: #( #self #string )>!

setTimeT: timet
    <cCall: 'g_date_set_time_t' returning: #void
        args: #( #self #int )>!

setTimeVal: timeval
    <cCall: 'g_date_set_time_val' returning: #void
        args: #( #self #cObject )>!

setMonth: month
    <cCall: 'g_date_set_month' returning: #void
        args: #( #self #int )>!

setDay: day
    <cCall: 'g_date_set_day' returning: #void
        args: #( #self #int )>!

setYear: year
    <cCall: 'g_date_set_year' returning: #void
        args: #( #self #int )>!

setDmy: day month: month y: y
    <cCall: 'g_date_set_dmy' returning: #void
        args: #( #self #int #int #int )>!

setJulian: julianDate
    <cCall: 'g_date_set_julian' returning: #void
        args: #( #self #int )>!

isFirstOfMonth
    <cCall: 'g_date_is_first_of_month' returning: #boolean
        args: #( #self )>!

isLastOfMonth
    <cCall: 'g_date_is_last_of_month' returning: #boolean
        args: #( #self )>!

addDays: nDays
    <cCall: 'g_date_add_days' returning: #void
        args: #( #self #int )>!

subtractDays: nDays
    <cCall: 'g_date_subtract_days' returning: #void
        args: #( #self #int )>!

addMonths: nMonths
    <cCall: 'g_date_add_months' returning: #void
        args: #( #self #int )>!

subtractMonths: nMonths
    <cCall: 'g_date_subtract_months' returning: #void
        args: #( #self #int )>!

addYears: nYears
    <cCall: 'g_date_add_years' returning: #void
        args: #( #self #int )>!

subtractYears: nYears
    <cCall: 'g_date_subtract_years' returning: #void
        args: #( #self #int )>!

isLeapYear: year
    <cCall: 'g_date_is_leap_year' returning: #boolean
        args: #( #int )>!

getDaysInMonth: month year: year
    <cCall: 'g_date_get_days_in_month' returning: #int
        args: #( #int #int )>!

getMondayWeeksInYear: year
    <cCall: 'g_date_get_monday_weeks_in_year' returning: #int
        args: #( #int )>!

getSundayWeeksInYear: year
    <cCall: 'g_date_get_sunday_weeks_in_year' returning: #int
        args: #( #int )>!

daysBetween: date2
    <cCall: 'g_date_days_between' returning: #int
        args: #( #self #cObject )>!

compare: rhs
    <cCall: 'g_date_compare' returning: #int
        args: #( #self #cObject )>!

toStructTm: tm
    <cCall: 'g_date_to_struct_tm' returning: #void
        args: #( #self #cObject )>!

clamp: minDate maxDate: maxDate
    <cCall: 'g_date_clamp' returning: #void
        args: #( #self #cObject #cObject )>!

order: date2
    <cCall: 'g_date_order' returning: #void
        args: #( #self #cObject )>!

strftime: s slen: slen format: format date: date
    <cCall: 'g_date_strftime' returning: #int
        args: #( #string #int #string #cObject )>! !


CObject subclass: GTypeInstance [
    
    <category: 'GLib'>
    <comment: nil>
]



GTypeInstance subclass: GObject [
    
    <category: 'GLib'>
    <comment: nil>
]



CObject subclass: GValue [
    
    <category: 'GLib'>
    <comment: nil>
]



CObject subclass: GMainContext [
    
    <category: 'GLib'>
    <comment: nil>
]


!GMainContext class methodsFor: 'C call-outs'!
new
    <cCall: 'g_main_context_new' returning: #{GMainContext}
        args: #( )>!

!GMainContext methodsFor: 'C call-outs'!
ref
    <cCall: 'g_main_context_ref' returning: #{GMainContext}
        args: #( #self )>!

free
    (self isAbsolute and: [ self address > 0 ])
        ifTrue: [ self unref ]!

unref
    <cCall: 'g_main_context_unref' returning: #void
        args: #( #self )>!

default
    <cCall: 'g_main_context_default' returning: #{GMainContext}
        args: #( )>!

iteration: mayBlock
    <cCall: 'g_main_context_iteration' returning: #boolean
        args: #( #self #boolean )>!

pending
    <cCall: 'g_main_context_pending' returning: #boolean
        args: #( #self )>!

wakeup
    <cCall: 'g_main_context_wakeup' returning: #void
        args: #( #self )>!

prepare: priority
    <cCall: 'g_main_context_prepare' returning: #boolean
        args: #( #self #cObject )>!

query: maxPriority timeout: timeout fds: fds nFds: nFds
    <cCall: 'g_main_context_query' returning: #int
        args: #( #self #int #cObject #cObject #int )>!

check: maxPriority fds: fds nFds: nFds
    <cCall: 'g_main_context_check' returning: #int
        args: #( #self #int #cObject #int )>!

dispatch
    <cCall: 'g_main_context_dispatch' returning: #void
        args: #( #self )>! !


CObject subclass: GMainLoop [
    
    <category: 'GLib'>
    <comment: nil>
]

!GMainLoop class methodsFor: 'C call-outs'!
new: context isRunning: isRunning
    <cCall: 'g_main_loop_new' returning: #{GMainLoop}
        args: #( #cObject #boolean )>! !

!GMainLoop methodsFor: 'C call-outs'!
run
    <cCall: 'g_main_loop_run' returning: #void
        args: #( #self )>!

primQuit
    <cCall: 'g_main_loop_quit' returning: #void
        args: #( #self )>!

ref
    <cCall: 'g_main_loop_ref' returning: #{GMainLoop}
        args: #( #self )>!

free
    (self isAbsolute and: [ self address > 0 ])
        ifTrue: [ self unref ]!
unref
    <cCall: 'g_main_loop_unref' returning: #void
        args: #( #self )>!

isRunning
    <cCall: 'g_main_loop_is_running' returning: #boolean
        args: #( #self )>!

getContext
    <cCall: 'g_main_loop_get_context' returning: #{GMainContext}
        args: #( #self )>! !



CStruct subclass: GTypeClass [
    
    <category: 'GLib'>
    <comment: nil>
    <declaration: #(#(#'g_type' #uLong ) )>
]



CStruct subclass: GList [
    
    <category: 'GLib'>
    <comment: nil>
    <declaration: #(#(#data #(#ptr #CObject ) ) #(#next #(#ptr #{GList} ) )
		    #(#prev #(#ptr #{GList} ) ) )>

    free [
        <category: 'C call-outs'>
        <cCall: 'g_list_free' returning: #void args: #(#self )>
    ]
]



CStruct subclass: GSList [
    
    <category: 'GLib'>
    <comment: nil>
    <declaration: #(#(#data #(#ptr #CObject ) ) #(#next #(#ptr #{GSList} ) ) )>

    free [
        <category: 'C call-outs'>
        <cCall: 'g_slist_free' returning: #void args: #(#self )>
    ]
]

GMainLoop class extend [

    popMainLoop [
	<category: 'C call-outs'>
	<cCall: 'gstGtkPopMainLoop' returning: #{GMainLoop} args: #() >
    ]

    pushMainLoop [
	<category: 'C call-outs'>
	<cCall: 'gstGtkPushMainLoop' returning: #{GMainLoop} args: #() >
    ]
]


GType class extend [

    register: anObject forType: gType [
	<category: 'C call-outs'>
	<cCall: 'gstGtkRegisterForType' returning: #void
	args: #(#smalltalk #unknown )>
    ]

    oopType [
	<category: 'C call-outs'>
	<cCall: 'gstTypeOOP' returning: #long
	args: #()>
    ]
]



GObject extend [

    connectSignalAfter: name to: handler selector: sel userData: userData [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignalAfter' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk #smalltalk )>
       
    ]

    connectSignalAfter: name to: handler selector: sel [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignalAfterNoUserData' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk )>
       
    ]

    connectSignal: name to: handler selector: sel userData: userData [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignal' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk #smalltalk )>
       
    ]

    connectSignal: name to: handler selector: sel [
       <category: 'C call-outs'>
       <cCall: 'gstGtkConnectSignalNoUserData' returning: #int
       args: #(#selfSmalltalk #string #smalltalk #smalltalk )>
       
    ]

    disconnectSignal: anInteger [
       <category: 'C call-outs'>
       <cCall: 'g_signal_handler_disconnect' returning: #void
       args: #(#self #int )>
    ]

    narrow [
       <category: 'C call-outs'>
       <cCall: 'gstGtkNarrowGObjectOOP' returning: #smalltalk
	args: #(#self #selfSmalltalk )>
    ]

    free [
	<category: 'C call-outs'>
	<cCall: 'gstGtkFreeGObjectOOP' returning: #void args: #(#self )>
    ]

    propertiesAt: name [
	<category: 'C call-outs'>
	<cCall: 'gstGtkGetProperty' returning: #smalltalk args: #(#self #string )>
    ]

    propertiesAt: name put: anObject [
	<category: 'C call-outs'>
	<cCall: 'gstGtkSetProperty' returning: #void
	args: #(#self #string #smalltalk )>
    ]

]



GValue class extend [

    typeFromName: aName [
	<category: 'C call-outs'>
	<cCall: 'g_type_from_name' returning: #int args: #(#string )>
    ]

]

GObject class extend [
    new [
	<category: 'instance creation'>
        ^self new: self getType varargs: #(nil)
    ]
]


GList extend [
    do: aOneArgBlock [
	<category: 'iterating'>
	| iter |
	iter := self.
	[ iter isNull not ] whileTrue: [
	    aOneArgBlock value: iter data value.
	    iter := iter next value ]
    ]
]


GMainLoop extend [
    | process sem |

    quit [
        | saveSem |
        saveSem := sem.
        process terminate.
        process := nil.
        sem := nil.
        self primQuit.
        saveSem signal.
    ]

    run [
        sem := Semaphore new.
        process := Processor forkEventLoop.
        sem wait
    ]

    pop [
        self address: 0.
        self class popMainLoop unref
    ]
]

GMainLoop class extend [
    | loop |

    mainQuit [
        loop quit
    ]

    main [
	"Main loop implementation.  The main loop is already running, this
         only waits for it to be ended by GMainLoop>>#mainQuit."

	<category: 'event loop'>
        loop := self pushMainLoop.
	[loop run] ensure: [loop := nil. self popMainLoop unref]
    ]

]


"Finish initialization.  This will call #registerAllTypes upon
 #returnFromSnapshot on subsequent image loads."

Eval [
    ObjectMemory addDependent: GType
]

!GLib class methodsFor: 'GDateDMY'!

gDateMonth ^1!
gDateDay ^0!
gDateYear ^2! !

!GLib class methodsFor: 'GDateWeekday'!

gDateSaturday ^6!
gDateThursday ^4!
gDateTuesday ^2!
gDateWednesday ^3!
gDateMonday ^1!
gDateBadWeekday ^0!
gDateFriday ^5!
gDateSunday ^7! !

!GLib class methodsFor: 'GDateMonth'!

gDateOctober ^10!
gDateMarch ^3!
gDateJune ^6!
gDateAugust ^8!
gDateJanuary ^1!
gDateNovember ^11!
gDateDecember ^12!
gDateJuly ^7!
gDateApril ^4!
gDateSeptember ^9!
gDateMay ^5!
gDateFebruary ^2!
gDateBadMonth ^0! !

!GLib class methodsFor: 'GOptionFlags'!

gOptionFlagFilename ^16!
gOptionFlagInMain ^2!
gOptionFlagOptionalArg ^32!
gOptionFlagHidden ^1!
gOptionFlagReverse ^4!
gOptionFlagNoalias ^64!
gOptionFlagNoArg ^8! !

!GLib class methodsFor: 'GOptionArg'!

gOptionArgFilenameArray ^6!
gOptionArgFilename ^4!
gOptionArgInt ^2!
gOptionArgDouble ^7!
gOptionArgCallback ^3!
gOptionArgNone ^0!
gOptionArgInt64 ^8!
gOptionArgString ^1!
gOptionArgStringArray ^5! !

!GLib class methodsFor: 'GOptionError'!

gOptionErrorBadValue ^1!
gOptionErrorFailed ^2!
gOptionErrorUnknownOption ^0! !

