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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"

GuiData subclass:  #Notifier
	instanceVariableNames: 'callstackList process stacktrace
				currentSelection errMessage topView '
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

openOn: process message: message
    BLOX BLOXBrowser BrowserMain handleErrorsWithGui: false.
    [
        Processor activeProcess name: 'Notifier/Debugger'.
        [ process isSuspended ] whileFalse: [ Processor yield ].

        self new
            init: message
	    process: process.

        BLOX BLOXBrowser BrowserMain handleErrorsWithGui: true.
    ] fork.

    process suspend.
! !

!Notifier methodsFor: 'accessing'!

currentContext
    currentSelection isNil ifTrue: [^nil].
    ^callstackList at: currentSelection! !

!Notifier methodsFor: 'callback'!

contexts
    ^callstackList elements!

nameList
    ^callstackList labels!

process
    ^process!

contextSelectedFrom: assoc 
    currentSelection := assoc key!

inspectContext
    Debugger new: self!

stacktrace
    ^stacktrace! !

!Notifier methodsFor: 'private'!

close: aView 
    | tv |
    tv := aView rootView blox.
    aView rootView close ifTrue: [tv destroy]!

init: aString process: aProcess
    | context lastContext contexts |
    errMessage := aString.
    process := aProcess.
    context := process suspendedContext.
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
    topView display!

createWindow
    | topLevel listView |
    topView := (BrowserShell new: errMessage) data: self.
    topLevel := topView blox.
    topLevel
	width: 300;
	height: 100.
    topView addChildView: ((listView := PList new: 'MethodSet' in: topView)
		initialize;
		data: self;
		listMsg: #stacktrace;
		handleUserChange: #contextSelectedFrom:;
		menuInit: ((PopupMenu new: listView label: 'Context')
			    selectors: #(#('Inspect' #inspectContext))
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
