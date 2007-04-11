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

Smalltalk at: #TestException put: ExAll newChild!

    [
        Transcript cr; show: 'testResume...'.
        TestException signal.
        Transcript show: 'passed'
    ]
        on: TestException
        do: [:excp | excp resume ].
        
    Transcript cr!


    [
        Transcript cr; show: 'testReturn...'.
        TestException signal.
        Transcript show: ' - failed'
    ]
        on: TestException
        do: [:excp |
            Transcript show: 'passed if nothing follows on this line'.
            excp return ].
            
    Transcript cr!

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
	    
    Transcript cr!

    [   Transcript cr; show: 'testEnsure...'.
            self error: ' Ignore this error']
        ensure: [Transcript show: 'passed'; cr]!

Smalltalk at: #Ok put: 0!

"TODO: turn this into an eval!!"
[
    [   self error: ' Ignore this error']
        ifCurtailed: [ Ok := Ok + 1 ].
    
    Ok := Ok + 2
] value!

    Transcript cr; show: 'testIfCurtailed...'.
    Ok = 1 ifFalse: [
	Ok >= 2 ifTrue: [ Transcript show: 'control returned'; cr ].
	Ok even ifTrue: [ Transcript show: 'ifCurtailed not executed'; cr ].
	^self
    ].
    Transcript show: 'passed'; cr!

	| r |
	Ok := 0.
	r := [#( 1 2 ) size] ensure: [Ok := Ok + 1].
	^(r = 2) & (Ok = 1)!

	Ok := 0. 
	[ [#( 1 2 ) siz] ensure: [ Ok := Ok + 1 ].
	] on: MessageNotUnderstood do: [ :mnu | mnu return ].
	^Ok = 1!

	Ok := 0.
	[#( 1 2 ) siz] ensure: [ Ok := Ok + 1 ]!
	^Ok = 1!

	Ok := 0.
	[ [Error signal] ensure: [ Ok := Ok + 1 ].
	] on: Error do: [ :error | error return ].
	^Ok = 1!

	Ok := 0.
	[Error signal] ensure: [ Ok := Ok + 1 ]!
	^Ok = 1!

	| tmp |
	Ok := 0.
	[tmp := [Notification signal. Ok = 0] ensure: [ Ok := Ok + 1 ].
	] on: Notification do: [ :notification | notification resume ].
	^tmp!

Smalltalk removeKey: #Ok!


"Do some torture testing on #ensure: and #ifCurtailed:"

^[ #block printNl ] ensure: [ #outer printNl ]!
^[ #block printNl ] ensure: [ ^#outer printNl ]!
^[ [ #block printNl ] ensure: [ #inner printNl ] ] ensure: [ #outer printNl ]!
^[ [ #block printNl ] ensure: [ #inner printNl ] ] ensure: [ ^#outer printNl ]!
^[ [ #block printNl ] ensure: [ ^#inner printNl ] ] ensure: [ #outer printNl ]!
^[ [ #block printNl ] ensure: [ ^#inner printNl ] ] ensure: [ ^#outer printNl ]!

^[ #block printNl ] ifCurtailed: [ #outer printNl ]!
^[ #block printNl ] ifCurtailed: [ ^#outer printNl ]!
^[ [ #block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ #outer printNl ]!
^[ [ #block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ ^#outer printNl ]!
^[ [ #block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ #outer printNl ]!
^[ [ #block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ ^#outer printNl ]!


^[ ^#block printNl ] ifCurtailed: [ #outer printNl ]!
^[ ^#block printNl ] ifCurtailed: [ ^#outer printNl ]!
^[ [ ^#block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ #outer printNl ]!
^[ [ ^#block printNl ] ifCurtailed: [ #inner printNl ] ] ifCurtailed: [ ^#outer printNl ]!
^[ [ ^#block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ #outer printNl ]!
^[ [ ^#block printNl ] ifCurtailed: [ ^#inner printNl ] ] ifCurtailed: [ ^#outer printNl ]!


"used to go in an infinite loop"
[ self halt ] on: 1 do: [ :ex | 'blah' printNl ]!

"Test error handling within a process."
[^'test'] fork!

"Test error handling within a process."
[self error: 'test'] fork!
