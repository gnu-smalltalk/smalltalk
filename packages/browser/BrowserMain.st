"======================================================================
|
|   Smalltalk GUI `outside the classes' method
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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



GuiData subclass: BrowserMain [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Shell := nil.
    SavedState := nil.
    Windows := nil.
    HandleErrorsWithGui := nil.

    BrowserMain class >> addWindow: toplevel [
	<category: 'accessing'>
	Windows add: toplevel
    ]

    BrowserMain class >> checkExit [
	<category: 'accessing'>
	^Windows isNil or: [Windows allSatisfy: [:w | w canClose]]
    ]

    BrowserMain class >> close [
	"This method is invoked before quitting the browser and before saving the
	 Smalltalk image.  When the system is launched subsequently, it is important
	 that the shell be nil until the browser is initialized.  Other methods use the
	 state of this variable (Shell) to probe the browser's initialization status"

	<category: 'accessing'>
	Shell := nil
    ]

    BrowserMain class >> handleErrorsWithGui [
	<category: 'accessing'>
	^HandleErrorsWithGui
    ]

    BrowserMain class >> handleErrorsWithGui: aBoolean [
	<category: 'accessing'>
	HandleErrorsWithGui := aBoolean
    ]

    BrowserMain class >> removeWindow: toplevel [
	<category: 'accessing'>
	Windows remove: toplevel
    ]

    BrowserMain class >> shell [
	"Return application widget pointer.  This method is used to determine whether
	 the Tk and browser environment is initialized.  If 'shell' is non-nil, the
	 environment is completely initialized"

	<category: 'accessing'>
	^Shell
    ]

    BrowserMain class >> update: aspect [
	"There is no guarantee that the image will be loaded running the
	 browser. So some variables must be nil'ed out.
	 
	 The class variable, 'Shell', is used, secondarily as a flag to
	 indicate initialization status.  If it is nil, the browser does
	 not attempt to display a Notifier or some other type of window
	 before the Tk and Smalltalk system has been initialized"

	<category: 'accessing'>
	aspect == #aboutToSnapshot 
	    ifTrue: 
		[SavedState := Transcript message -> Shell.
		Transcript message: stdout -> #nextPutAllFlush:.
		self handleErrorsWithGui: false.
		Shell := nil].
	aspect == #finishedSnapshot 
	    ifTrue: 
		[SavedState isNil ifTrue: [^self].
		Shell := SavedState value.
		self handleErrorsWithGui: true.
		Transcript message: SavedState key.
		SavedState := nil]
    ]

    BrowserMain class >> windowsDo: aBlock [
	<category: 'accessing'>
	Windows do: aBlock
    ]

    BrowserMain class >> directQuit [
	<category: 'blue button messages'>
	self checkExit ifFalse: [^self beep].
	self shell release.
	Blox terminateMainLoop.
	ObjectMemory quit
    ]

    BrowserMain class >> garbageCollect [
	"Force a full garbage collection in order to dispose of all unreferenced
	 instances"

	<category: 'blue button messages'>
	ObjectMemory compact
    ]

    BrowserMain class >> fileIn [
	<category: 'blue button messages'>
	| fileName |
	fileName := Prompter 
		    openFileName: 'Which file do you want me to read?'
		    default: '*.st'
		    in: Shell.
	fileName isNil ifFalse: [FileStream fileIn: fileName]
    ]

    BrowserMain class >> openBrowser [
	<category: 'blue button messages'>
	ClassHierarchyBrowser new open
    ]

    BrowserMain class >> openNamespaceBrowser [
	<category: 'blue button messages'>
	NamespaceBrowser new open
    ]

    BrowserMain class >> openWorksheet [
	<category: 'blue button messages'>
	^BrowserShell openWorksheet: 'Worksheet'
    ]

    BrowserMain class >> openWorksheet: label [
	<category: 'blue button messages'>
	^BrowserShell openWorksheet: label
    ]

    BrowserMain class >> quit [
	"Quit Smalltalk browser"

	<category: 'blue button messages'>
	| exit |
	self checkExit ifFalse: [^self beep].
	exit := false.
	(ModalDialog new)
	    message: 'Save image before quitting?' in: self shell;
	    addButton: 'Yes'
		message: 
		    [self saveImage.
		    exit := true];
	    addButton: 'No' message: [exit := true];
	    addButton: 'Cancel' message: [];
	    display: self shell.
	exit ifFalse: [^false].
	self shell release.
	Blox terminateMainLoop.
	ObjectMemory quit.
	^true
    ]

    BrowserMain class >> saveImageAs [
	"Save a snapshot on a file the user chooses."

	<category: 'blue button messages'>
	| fileName |
	fileName := Prompter 
		    saveFileName: 'Save image as'
		    default: ImageFileName
		    in: Shell.
	fileName isNil 
	    ifFalse: 
		[ObjectMemory snapshot: fileName.
		ImageFileName := fileName	"Are we sure?"]
    ]

    BrowserMain class >> saveImage [
	"Save a snapshot"

	<category: 'blue button messages'>
	ObjectMemory snapshot
    ]

    initialize [
	"Initialize Tk environment.  Create a transcript which will be used to
	 operate the browser.  It has a menu from which the user can select the
	 desired menu option"

	<category: 'initializing'>
	| win transcriptAndShell |
	self class handleErrorsWithGui: false.
	Smalltalk addFeature: #EventLoop.
	Shell := nil.
	Windows := Set new.
	transcriptAndShell := BrowserShell openWorksheet: 'Smalltalk Transcript'
		    withText: (Version copyWith: Character nl).
	(Smalltalk includesKey: #GTK) 
	    ifTrue: ['FIXME GTK bindings not ready for GUI transcript' printNl]
	    ifFalse: [Transcript message: transcriptAndShell value -> #insertAtEnd:].
	Shell := transcriptAndShell key.
	Shell data: self.
	win := Shell blox.
	win callback: self class message: #quit.
	self class handleErrorsWithGui: true.
	Shell display.
	Blox dispatchEvents.
	Shell blox exists ifTrue: [Shell blox destroy].
	self class handleErrorsWithGui: false.
	Shell := nil
    ]

    addWindow: toplevel [
	<category: 'window maintenance'>
	^Windows add: toplevel
    ]

    removeWindow: toplevel [
	<category: 'window maintenance'>
	^Windows remove: toplevel
    ]
]



Eval [
    BrowserMain handleErrorsWithGui: false.
    ObjectMemory addDependent: BrowserMain
]

