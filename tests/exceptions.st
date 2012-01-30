"======================================================================
|
|   Test the exception handling hackery
|
|
 ======================================================================"


"======================================================================
|
| Written by Paolo Bonzini (original code by Jonathan Carlson)
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

Exception subclass: #TestException!

Eval [
    [
        Transcript cr; show: 'testResume...'.
        TestException signal.
        Transcript show: 'passed'
    ]
        on: TestException
        do: [:excp | excp resume ].
        
    Transcript cr
]

Eval [
    [
        Transcript cr; show: 'testReturn...'.
        TestException signal.
        Transcript show: ' - failed'
    ]
        on: TestException
        do: [:excp |
            Transcript show: 'passed if nothing follows on this line'.
            excp return ].
            
    Transcript cr
]

Eval [
    [
        Transcript cr; show: 'testPass...'.
        [
            TestException signal.
	    Transcript show: ' - failed'
        ]
            on: TestException
            do: [:ex | Transcript show: 'passing...'. ex pass ]
    ]
	on: TestException
	do: [:excp |
	    Transcript show: 'passed if nothing follows on this line'.
	    excp return].
	    
    Transcript cr
]

Eval [
    "Test that passing disables all exception handlers in the #on:do: snippet."

    Transcript cr; show: 'testPass (2)...'.
    [[self error: 'abc']
		on: Exception do: [ :ex | Transcript show: 'failed' ]
		on: Error do: [ :ex | Transcript show: 'passing...'. ex pass ]]
	on: Error do: [ :ex | Transcript show: 'ok' ].

    Transcript cr
]

Eval [
    [   Transcript cr; show: 'testEnsure...'.
            self error: ' Ignore this error']
        ensure: [Transcript show: 'passed'; cr]
]

Eval [
    Smalltalk at: #Ok put: 0
]

Eval [
    [   self error: ' Ignore this error']
        ifCurtailed: [ Ok := Ok + 1 ].
    
    Ok := Ok + 2
]

Eval [
    Transcript cr; show: 'testIfCurtailed...'.
    Ok = 1 ifFalse: [
	Ok >= 2 ifTrue: [ Transcript show: 'control returned'; cr ].
	Ok even ifTrue: [ Transcript show: 'ifCurtailed not executed'; cr ].
	^self
    ].
    Transcript show: 'passed'; cr
]

Eval [
	| r |
	Ok := 0.
	r := [#( 1 2 ) size] ensure: [Ok := Ok + 1].
	^(r = 2) & (Ok = 1)
]

Eval [
	Ok := 0. 
	[ [#( 1 2 ) siz] ensure: [ Ok := Ok + 1 ].
	] on: MessageNotUnderstood do: [ :mnu | mnu return ].
	^Ok = 1
]

Eval [
	Ok := 0.
	[#( 1 2 ) siz] ensure: [ Ok := Ok + 1 ]
]
Eval [ ^Ok = 1 ]

Eval [
	Ok := 0.
	[ [Error signal] ensure: [ Ok := Ok + 1 ].
	] on: Error do: [ :error | error return ].
	^Ok = 1
]

Eval [
	Ok := 0.
	[Error signal] ensure: [ Ok := Ok + 1 ]
]
Eval [ ^Ok = 1 ]

Eval [
	| tmp |
	Ok := 0.
	[tmp := [Notification signal. Ok = 0] ensure: [ Ok := Ok + 1 ].
	] on: Notification do: [ :notification | notification resume ].
	^tmp
]

Eval [ Smalltalk removeKey: #Ok ]


"Do some torture testing on #ensure: and #ifCurtailed:"

Eval [ [ #block printNl ] ensure: [ #outer printNl ] ]
Eval [ [ #block printNl ] ensure: [ ^#outer printNl ] ]
Eval [ [ [ #block printNl ] ensure: [ #inner printNl ] ] ensure: [ #outer printNl ] ]
Eval [ [ [ #block printNl ] ensure: [ #inner printNl ] ] ensure: [ ^#outer printNl ] ]
Eval [ [ [ #block printNl ] ensure: [ ^#inner printNl ] ] ensure: [ #outer printNl ] ]
Eval [ [ [ #block printNl ] ensure: [ ^#inner printNl ] ] ensure: [ ^#outer printNl ] ]

Eval [ [ #block printNl ] ifCurtailed: [ #outer printNl ] ]
Eval [ [ #block printNl ] ifCurtailed: [ ^#outer printNl ] ]
Eval [ [ [ #block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ #outer printNl ] ]
Eval [ [ [ #block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ ^#outer printNl ] ]
Eval [ [ [ #block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ #outer printNl ] ]
Eval [ [ [ #block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ ^#outer printNl ] ]


Eval [ [ ^#block printNl ] ifCurtailed: [ #outer printNl ] ]
Eval [ [ ^#block printNl ] ifCurtailed: [ ^#outer printNl ] ]
Eval [ [ [ ^#block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ #outer printNl ] ]
Eval [ [ [ ^#block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ ^#outer printNl ] ]
Eval [ [ [ ^#block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ #outer printNl ] ]
Eval [ [ [ ^#block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ ^#outer printNl ] ]


"used to go in an infinite loop"
Eval [ [ self halt ] on: 1 do: [ :ex | 'blah' printNl ] ]

"Test error handling within a process."
Eval [ p := [^'test'] fork. [p isReady] whileTrue: [Processor yield]]

"Test error handling within a process."
Eval [ p := [self error: 'test'] fork. [p isReady] whileTrue: [Processor yield]]

"This is invalid, but it should not give a walkback."
Eval [
    [1 doSomething] on: Error do: [:err | error := err].
    error signalingContext
]

"Test MessageLookup"
Object subclass: TestDNU [
    doesNotUnderstand: aMessage [
        ^(aMessage selector = #'foo:bar:'
            and: [ aMessage arguments first = 1 ])
            and: [ aMessage startingClass = aMessage arguments last ]
    ]
]

TestDNU subclass: TestSuperDNU [
    foo: a baz: b [ ^super foo: a bar: b ]
]

Eval [ TestDNU new foo: 1 bar: TestDNU ]
Eval [ TestSuperDNU new foo: 1 bar: TestSuperDNU ]
Eval [ TestSuperDNU new foo: 1 baz: TestDNU ]
