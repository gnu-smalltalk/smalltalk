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

GuiData subclass:  #Notifier
	instanceVariableNames: 'callstackList debugger stacktrace
				currentSelection errMessage topView listView '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

Notifier comment: 
nil!

!Notifier class methodsFor: 'debugging attributes'!

debuggerClass
    ^nil
!

debuggingPriority
    ^1
! !

!Notifier class methodsFor: 'instance creation'!

openOn: aProcess message: message
    self new init: message debugger: (Smalltalk.Debugger on: aProcess)!

open
    self open: ('Notifier on %1' % { Processor activeProcess })!

open: message
    | handleErrorsWithGui |
    handleErrorsWithGui := BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui.
    BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui: false.
    [ :debugger |
        Processor activeProcess name: 'Notifier/Debugger'.
	self new init: message debugger: debugger.
        BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui: handleErrorsWithGui.
    ] forkDebugger
! !

!Notifier methodsFor: 'accessing'!

currentContext
    currentSelection isNil ifTrue: [currentSelection := 1].
    ^callstackList at: currentSelection! !

!Notifier methodsFor: 'callback'!

process
    ^debugger process!

debugger
    ^debugger!

contextSelectedFrom: assoc 
    currentSelection := assoc key!

debug
    Debugger new: self!

stacktrace
    ^stacktrace! !

!Notifier methodsFor: 'private'!

close: aView 
    | tv |
    tv := aView rootView blox.
    aView rootView close ifTrue: [tv destroy]!

init: aString debugger: aDebugger
    | context lastContext contexts |
    errMessage := aString.
    debugger := aDebugger.
    context := debugger suspendedContext.
    lastContext := context environment.
    stacktrace := OrderedCollection new.
    contexts := OrderedCollection new.

    "Skip top contexts that are internal to the exception-handling
     system."

    [ context ~~ lastContext and: [
        context isInternalExceptionHandlingContext ] ] whileTrue: [
            context := context parentContext.
    ].

    [ context == lastContext ] whileFalse: [
        context isDisabled ifFalse: [
 	    stacktrace add: context printString.
       	    contexts add: context ].

        context := context parentContext.
    ].

    self createWindow.
    callstackList contents: stacktrace elements: contexts.
    topView display.
    listView update.
    listView select: 1!

createWindow
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
    callstackList := listView blox! !

!Behavior methodsFor: 'overriding'!

debuggerClass
    ^BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui
	ifTrue: [ BLOX.BLOXBrowser.Notifier ]
	ifFalse: [ nil ]! !
