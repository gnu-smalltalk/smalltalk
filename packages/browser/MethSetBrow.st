"======================================================================
|
|   Smalltalk GUI method set browser
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



GuiData subclass: MethodSetBrowser [
    | methodList theClass theSelector selection |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    MethodSetBrowser class >> referencesTo: anObject parent: listView [
	<category: 'instance creation'>
	| col value selection |
	col := SortedCollection 
		    sortBlock: [:a :b | a displayString <= b displayString].
	(anObject isKindOf: Association) 
	    ifTrue: 
		[selection := anObject key.
		value := anObject value]
	    ifFalse: 
		[selection := nil.
		value := anObject].
	Class allSubclassesDo: 
		[:meta | 
		(meta whichSelectorsReferTo: anObject) do: [:sel | col add: meta >> sel].
		(meta instanceClass whichSelectorsReferTo: anObject) 
		    do: [:sel | col add: meta instanceClass >> sel]].
	col isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No references to ' , value printString
		    in: listView].
	^self new 
	    openOn: col
	    title: 'References to ' , value printString
	    selection: selection
    ]

    MethodSetBrowser class >> implementorsOf: aSymbol parent: listView [
	"Opens a message set browser on all methods that implement selected method"

	<category: 'instance creation'>
	| col |
	col := SortedCollection 
		    sortBlock: [:a :b | a displayString <= b displayString].
	"Collect all methods which implement selected method.  Collection is sorted
	 alphabetically"
	Class allSubclassesDo: 
		[:meta | 
		(meta includesSelector: aSymbol) ifTrue: [col add: meta >> aSymbol].
		(meta instanceClass includesSelector: aSymbol) 
		    ifTrue: [col add: meta instanceClass >> aSymbol]].
	col isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No implementors for ' , aSymbol
		    in: listView].
	^self new 
	    openOn: col
	    title: 'Implementors of ' , aSymbol
	    selection: nil
    ]

    MethodSetBrowser class >> sendersOf: aSymbol parent: listView [
	<category: 'instance creation'>
	| col |
	col := SortedCollection 
		    sortBlock: [:a :b | a displayString <= b displayString].
	Class allSubclassesDo: 
		[:meta | 
		(meta whichSelectorsReferTo: aSymbol) do: [:sel | col add: meta >> sel].
		(meta instanceClass whichSelectorsReferTo: aSymbol) 
		    do: [:sel | col add: meta instanceClass >> sel]].
	col isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No senders for ' , aSymbol in: listView].
	^self new 
	    openOn: col
	    title: 'Senders of ' , aSymbol
	    selection: aSymbol
    ]

    methodList [
	<category: 'accessing'>
	^methodList
    ]

    methodSelection: assoc [
	"Derive class and selector from list selection.  The selection is derived
	 from an item in the method list pane.  A list item may be of two
	 forms: 1) className class selector, or 2) className selector. Form (1)
	 contains 3 string tokens and form (2) contains 2.  To derive the class
	 from form (1), the instance class is derived from the Smallltalk
	 dictionary using the first string token as a key.  Then class is sent
	 to the instance class to derive the class of the instance class.  The
	 selector is derived from the third token.  In form (2), the instance
	 class is derived directly from the first string token.  The selector
	 is obtained from the second token"

	<category: 'accessing'>
	| parsing className |
	assoc value isNil ifTrue: [^theSelector := nil].
	theClass := assoc value methodClass.
	theSelector := assoc value selector.
	self changeState: #text.
	Primitive updateViews
    ]

    text [
	"Return source code for the selected method"

	<category: 'accessing'>
	theSelector notNil 
	    ifTrue: [^theClass -> (theClass >> theSelector) methodRecompilationSourceString].
	^''
    ]

    openOn: aSortedCollection title: name selection: aSymbol [
	"Open a method set browser.  The argument aMethodDictionary consists of
	 alpha-sorted collection of strings.  Each element is of two forms: 1) className
	 class selector, or 2) className selector.  This browser consists of two
	 vertically placed panes.  The top pane is a list which displays the sorted
	 methods in aMethodDictionary.  The bottom pane is a text view which will
	 display the source code for a selector which is selected from the top pane.
	 In general, aSymbol denotes a selector.  If this parameter is non-nil, the
	 first occurence of aSymbol will be selected in the text view when a
	 selector is first selected from the top pane"

	<category: 'initializing'>
	| topView childView aStream listView textView container |
	aSymbol notNil 
	    ifTrue: 
		["Parse selector expression, aSymbol, inclusive of first colon"

		aStream := WriteStream on: (String new: 0).
		aSymbol detect: 
			[:ch | 
			aStream nextPut: ch.
			ch == $:]
		    ifNone: [0].
		selection := aStream contents].
	topView := BrowserShell 
		    new: name , ' (' , aSortedCollection size printString , ')'.
	topView data: self.
	topView blox x: 20.
	topView blox y: 330.
	topView blox height: 308.
	topView blox width: 408.

	"Use Form class to manage the list and text view panes"
	childView := Form new: 'Form' in: topView.
	topView addChildView: childView.
	container := childView blox.

	"Create a list in top half of window"
	childView 
	    addChildView: ((listView := PList new: 'MethodSet' in: childView)
		    initialize;
		    data: self;
		    stateChange: #methodList;
		    handleUserChange: #methodSelection:;
		    dataMsg: #methodList;
		    menuInit: (self blueButtonMenuForMethods: listView);
		    yourself).
	(listView blox)
	    inset: 2;
	    width: 400 height: 150.

	"Create a text view and install in lower half of window"
	childView addChildView: ((textView := PCode new: childView)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #compile:from:;
		    textMsg: #text;
		    setBrowserKeyBindings;
		    selection: selection;
		    yourself).
	textView menuInit: ((PopupMenu new: textView label: 'Edit') 
		    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors) #() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
		    receiver: textView
		    argument: nil).
	textView blox width: 400 height: 150.
	textView blox posVert: listView blox.
	textView blox inset: 2.
	"Initialize instance variable, methodList, which governs list display"
	methodList := aSortedCollection.
	self changeState: #methodList.
	Primitive updateViews.
	"Initialize all the manufactured widgets"
	topView display
    ]

    inspectMethod: listView [
	"Bring up an inspector on a Class"

	<category: 'selector list blue button menu'>
	theSelector isNil ifTrue: [^listView beep].
	(theClass >> theSelector) inspect
    ]

    blueButtonMenuForMethods: theView [
	"Create method list pane menu"

	<category: 'selector list blue button menu'>
	^(PopupMenu new: theView label: 'Method') 
	    selectors: #(#('File out...' #fileOutSelector: #theView) #() #('Senders' #senders: #theView) #('Implementors' #implementors: #theView) #() #(#Inspect #inspectMethod: #theView))
	    receiver: self
	    argument: theView
    ]

    fileOutSelector: listView [
	"Creates a file containing description of selected method"

	<category: 'selector list blue button menu'>
	| fileName |
	theSelector isNil ifTrue: [^listView beep].
	theClass name notNil 
	    ifTrue: [fileName := theClass name]
	    ifFalse: [fileName := theClass asClass name , '-class'].

	"If the name is too long, maybe truncate it"
	fileName := self fileoutDir , fileName , '.' , theSelector , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out selector'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[theClass fileOutSelector: theSelector to: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    implementors: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	theSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser implementorsOf: theSelector parent: listView
    ]

    senders: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	theSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser sendersOf: theSelector parent: listView
    ]

    compile: aString from: aView [
	"Compile aString derived from text in text view for the selected selector"

	<category: 'text view blue button menu'>
	theSelector isNil ifTrue: [^aView beep].
	theClass 
	    compile: aString
	    classified: (theClass compiledMethodAt: theSelector) methodCategory
	    ifError: 
		[:fname :lineNo :errorString | 
		aView displayError: errorString at: lineNo.
		^nil]
    ]

    selection [
	<category: 'text view blue button menu'>
	^selection
    ]
]

