"======================================================================
|
|   DebugTools package unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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



TestCase subclass: DebuggerTest [
    
    <comment: nil>
    <category: 'System-Debugging-Test'>

    debuggerOn: aBlock [
	"Attach aBlock to a debugger and step until aBlock's execution begins."

	<category: 'test'>
	| debugger |
	debugger := Debugger on: aBlock newProcess.
	[debugger suspendedContext method == aBlock block] 
	    whileFalse: [debugger stepBytecode].
	^debugger
    ]

    testOn [
	"Test that #debuggerOn: works as we intend."

	<category: 'test'>
	| debugger notReached |
	notReached := false.
	debugger := self debuggerOn: [notReached := true].
	self assert: debugger suspendedContext isBlock.
	self deny: notReached
    ]

    testStep [
	"Test that #step goes through the traced process a single line at a time."

	<category: 'test'>
	| debugger reached1 reached2 notReached |
	reached1 := reached2 := notReached := false.
	debugger := self debuggerOn: 
			[reached1 := true. reached2 := true.
			notReached := true].
	debugger step.
	self assert: reached1.
	self assert: reached2.
	self deny: notReached
    ]

    testCurrentLine [
	"Test that #currentLine does not do something completely bogus."

	<category: 'test'>
	| debugger a b c prevLine |
	debugger := self debuggerOn: 
			[a := 5.
			b := 6.
			c := 7].
	
	[debugger step.
	a = 5] whileFalse.
	prevLine := debugger currentLine.
	debugger step.
	self assert: prevLine + 1 = debugger currentLine
    ]

    testForkDebugger [
	"Test forking a debugger for the current process."

	<category: 'test'>
	| value |
	
	[:debugger | 
	
	[debugger step.
	debugger suspendedContext selector = #y] whileFalse.
	value := false.
	debugger finish.
	
	[debugger step.
	debugger suspendedContext selector = #y] whileFalse.
	value := true.
	debugger finish.
	
	[debugger step.
	debugger suspendedContext selector = #y] whileFalse.
	value := 42.
	debugger continue] 
		forkDebugger.
	self y.
	self deny: value.
	self y.
	self assert: value.
	self y.
	self assert: value = 42
    ]

    testStopInferior [
	"Test using #stopInferior to restart the debugger."

	<category: 'test'>
	| theDebugger value |
	
	[:debugger | 
	theDebugger := debugger.
	[[debugger step] repeat] on: SystemExceptions.DebuggerReentered
	    do: [:ex | ex return].
	value := 42.
	debugger continue] 
		forkDebugger.
	self assert: value isNil.
	theDebugger stopInferior.
	self assert: value = 42
    ]

    testStepIntoSend [
	"Test that #step stops at the next message send."

	<category: 'test'>
	| debugger reached notReached |
	reached := false.
	debugger := self debuggerOn: 
			[reached := true. notReached := 3 factorial].
	debugger step.
	self assert: reached.
	self assert: notReached isNil
    ]

    testFinish [
	"Test that #finish does not proceed further in the parent context."

	<category: 'test'>
	| debugger reached |
	debugger := self debuggerOn: [reached := 3 factorial].
	debugger step.
	self assert: reached isNil.
	debugger finish.
	"The assignment has not been executed yet."
	self assert: reached isNil.
	debugger finish.
	self assert: reached = 6
    ]

    testStepTooMuch [
	"Test that #stepBytecode eventually raises an error."

	<category: 'test'>
	| debugger reached toFinish |
	debugger := self debuggerOn: [3 factorial].
	self should: [[debugger stepBytecode] repeat] raise: Error.
	self deny: debugger isActive
    ]

    testFinishColon [
	"Test using #finish: to leave multiple contexts at once."

	<category: 'test'>
	| debugger reached toFinish |
	debugger := self debuggerOn: [self x: [:foo | reached := foo]].
	
	[debugger step.
	debugger suspendedContext selector = #x:] whileFalse.
	toFinish := debugger suspendedContext.
	
	[debugger step.
	debugger suspendedContext selector = #z:] whileFalse.
	debugger finish: toFinish.
	self assert: reached = 42.
	self deny: debugger suspendedContext selector = #x:
    ]

    testContinue [
	"Test that #continue terminates the controlling process."

	<category: 'test'>
	| debugger reached sema1 sema2 curtailed |
	debugger := self debuggerOn: 
			[reached := 3 factorial.
			sema1 signal].
	sema1 := Semaphore new.
	sema2 := Semaphore new.
	curtailed := true.
	
	["The controlling process is terminated, so we run the test in another
	 process."

	
	[debugger continue.
	curtailed := false] ensure: [sema2 signal]] 
		fork.
	sema1 wait.
	sema2 wait.
	self assert: reached = 6.
	self assert: curtailed.
	self deny: debugger isActive
    ]

    testStepOverPrimitive [
	"Test that #step does not go inside a primitive."

	<category: 'test'>
	| debugger reached notReached |
	debugger := self debuggerOn: [reached := Object new].
	debugger step.
	self assert: reached notNil
    ]

    testNext [
	"Test that #next runs a whole line independent of how many sends are there."

	<category: 'test'>
	| debugger reached1 reached2 |
	debugger := self debuggerOn: 
			[reached1 := 3 factorial. reached2 := 4 factorial].
	debugger next.
	self assert: reached1 = 6.
	self assert: reached2 = 24
    ]

    testCurtailFinish [
	"Test that finish is not fooled by method returns."

	<category: 'test'>
	| debugger notReached |
	notReached := false.
	debugger := self debuggerOn: 
			[self w. notReached := true].
	
	[debugger step.
	debugger suspendedContext selector = #z:] whileFalse.
	debugger finish.
	self assert: debugger suspendedContext selector = #y.
	debugger finish.
	self assert: debugger suspendedContext selector = #x:.
	debugger step.
	self assert: debugger suspendedContext isBlock.
	self assert: debugger suspendedContext selector = #w.
	debugger finish.
	self assert: debugger isActive.
	self deny: notReached
    ]

    w [
	<category: 'support'>
	self x: [:foo | ^foo]
    ]

    x: aBlock [
	<category: 'support'>
	aBlock value: self y
    ]

    y [
	<category: 'support'>
	^self z: 42
    ]

    z: anObject [
	<category: 'support'>
	^anObject
    ]
]

