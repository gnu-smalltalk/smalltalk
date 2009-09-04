"======================================================================
|
|   Smalltalk GUI notifier window
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



GuiData subclass: Notifier [
    | callstackList debugger stacktrace currentSelection errMessage topView listView |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Notifier class >> debuggerClass [
	<category: 'debugging attributes'>
	^nil
    ]

    Notifier class >> debuggingPriority [
	<category: 'debugging attributes'>
	^1
    ]

    Notifier class >> openOn: aProcess message: message [
	<category: 'instance creation'>
	self new init: message debugger: (Smalltalk.Debugger on: aProcess)
    ]

    Notifier class >> open [
	<category: 'instance creation'>
	self open: 'Notifier on %1' % {Processor activeProcess}
    ]

    Notifier class >> open: message [
	<category: 'instance creation'>
	| handleErrorsWithGui |
	handleErrorsWithGui := BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui.
	BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui: false.
	
	[:debugger | 
	Processor activeProcess name: 'Notifier/Debugger'.
	self new init: message debugger: debugger.
	BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui: handleErrorsWithGui] 
		forkDebugger
    ]

    currentContext [
	<category: 'accessing'>
	currentSelection isNil ifTrue: [currentSelection := 1].
	^callstackList at: currentSelection
    ]

    process [
	<category: 'callback'>
	^debugger process
    ]

    debugger [
	<category: 'callback'>
	^debugger
    ]

    contextSelectedFrom: assoc [
	<category: 'callback'>
	currentSelection := assoc key
    ]

    debug [
	<category: 'callback'>
	Debugger new: self
    ]

    stacktrace [
	<category: 'callback'>
	^stacktrace
    ]

    close: aView [
	<category: 'private'>
	| tv |
	tv := aView rootView blox.
	aView rootView close ifTrue: [tv destroy]
    ]

    init: aString debugger: aDebugger [
	<category: 'private'>
	| context lastContext contexts |
	errMessage := aString.
	debugger := aDebugger.
	context := debugger suspendedContext.
	lastContext := context environment.
	stacktrace := OrderedCollection new.
	contexts := OrderedCollection new.

	"Skip top contexts that are internal to the exception-handling
	 system."
	[context ~~ lastContext and: [context isInternalExceptionHandlingContext]] 
	    whileTrue: [context := context parentContext].
	[context == lastContext] whileFalse: 
		[context isDisabled 
		    ifFalse: 
			[stacktrace add: context printString.
			contexts add: context].
		context := context parentContext].
	self createWindow.
	callstackList contents: stacktrace elements: contexts.
	topView display.
	listView update.
	listView select: 1
    ]

    createWindow [
	<category: 'private'>
	| topLevel |
	topView := (BrowserShell new: errMessage) data: self.
	topLevel := topView blox.
	topLevel 
	    x: 20
	    y: 50
	    width: 300
	    height: 100.
	topView addChildView: ((listView := PList new: 'MethodSet' in: topView)
		    initialize;
		    data: self;
		    listMsg: #stacktrace;
		    handleUserChange: #contextSelectedFrom:;
		    menuInit: ((PopupMenu new: listView label: 'Context')
				selectors: #(#('Debug' #debug))
				    receiver: self
				    argument: listView;
				selectors: #(#() #('Copy Trace' #copyAll) #('Copy Selection' #copySelection))
				    receiver: listView
				    argument: nil;
				selectors: #(#() #('Close' #close))
				    receiver: listView
				    argument: nil;
				yourself);
		    yourself).
	callstackList := listView blox
    ]
]



Behavior extend [

    debuggerClass [
	<category: 'overriding'>
	^BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui 
	    ifTrue: [BLOX.BLOXBrowser.Notifier]
	    ifFalse: [nil]
    ]

]

