"======================================================================
|
|   Smalltalk GUI wrapper for text widgets
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
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



Primitive subclass: PText [
    | textMsg selection canBeDirty object |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PText class >> bloxClass [
	<category: 'instance creation'>
	^BText
    ]

    PText class >> new: parent [
	<category: 'instance creation'>
	| view |
	view := self new.
	view canBeDirty: true.
	view parentView: parent.
	view blox: (self bloxClass new: parent blox).
	view blox callback: view message: 'setDirtyFlag'.
	^view
    ]

    PText class >> newReadOnly: parent [
	<category: 'instance creation'>
	| view |
	view := self new.
	view parentView: parent.
	view blox: (self bloxClass newReadOnly: parent blox).
	"view blox backgroundColor: 'LemonChiffon'."
	^view
    ]

    getSelectionOrLine [
	"Answer the text currently selected or the text on the current line if
	 there's no text selected.  This enables Do It, Print It, and Inspect It
	 to be used without manually selecting text."

	<category: 'private'>
	| text |
	text := blox getSelection.
	(text isNil or: [text isEmpty]) ifTrue: [^blox lineAt: blox currentLine].
	^text
    ]

    compileIt [
	"Activated when the user selects 'accept' from the popup menu.  Send a
	 stateChangeMsg to the data object"

	<category: 'blue button menu items'>
	| text rejected |
	text := blox contents.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	self canChangeState 
	    ifTrue: 
		[rejected := stateChangeMsg numArgs = 1 
			    ifTrue: 
				["One parameter selector"

				(data perform: stateChangeMsg with: blox contents) isNil]
			    ifFalse: 
				["Two parameter selector"

				(data 
				    perform: stateChangeMsg
				    with: blox contents
				    with: self) isNil].
		dirty := rejected & canBeDirty]
    ]

    eval [
	<category: 'blue button menu items'>
	| text pos |
	pos := blox currentLine.
	text := self getSelectionOrLine.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	self doEval: text
	    ifError: [:fname :lineNo :errorString | self displayError: errorString at: lineNo + pos]
    ]

    doLine [
	"Perform a single line of code in a Worksheet or the Transcript window.
	 This actually executes the _previous_ line because Tcl/Tk passes through
	 the Return of the Control-Return keybinding to its text editor widget
	 before we get here."

	<category: 'blue button menu items'>
	| endPt |
	endPt := 1 @ blox currentLine.
	blox selectFrom: 1 @ (blox currentLine - 1) to: endPt.
	self eval.
	blox selectFrom: endPt to: endPt
    ]

    evalAndInspectResult [
	"Open an inspector on the result of the evaluation of the selected Smalltalk expression"

	<category: 'blue button menu items'>
	| obj text pos |
	pos := blox currentLine.
	text := self getSelectionOrLine.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	obj := self doEval: text
		    ifError: 
			[:fname :lineNo :errorString | 
			self displayError: errorString at: lineNo + pos.
			^nil].
	obj inspect
    ]

    evalAndPrintResult [
	"Display and select result of evaluation of selected expression to right of
	 selection"

	<category: 'blue button menu items'>
	| text obj pos |
	pos := blox currentLine.
	text := self getSelectionOrLine.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	obj := self doEval: text
		    ifError: 
			[:fname :lineNo :errorString | 
			self displayError: errorString at: lineNo + pos.
			^nil].
	blox insertTextSelection: obj printString
    ]

    find [
	<category: 'blue button menu items'>
	| prompter |
	prompter := Prompter message: 'Search...' in: self.
	prompter response ~= '' ifTrue: [blox searchString: prompter response]
    ]

    gstClear [
	<category: 'blue button menu items'>
	blox replaceSelection: ''
    ]

    gstCopy [
	<category: 'blue button menu items'>
	Blox clipboard: blox getSelection
    ]

    gstCut [
	<category: 'blue button menu items'>
	self gstCopy.
	self gstClear
    ]

    gstPaste [
	<category: 'blue button menu items'>
	| clip |
	clip := Blox clipboard.
	clip isEmpty ifFalse: [blox replaceSelection: clip]
    ]

    implementors [
	"Maybe getSelectionOrWord?"

	<category: 'blue button menu items'>
	self getSelectionOrLine 
	    ifNotNil: [:sel | MethodSetBrowser implementorsOf: sel asSymbol parent: self]
    ]

    line [
	"Prompt user to enter a line number.  If a valid number, attempt
	 to scroll to entered line number"

	<category: 'blue button menu items'>
	| prompter |
	prompter := Prompter message: 'Goto line...' in: self.
	prompter response isEmpty ifTrue: [^self].
	(prompter response allSatisfy: [:ch | ch isDigit]) 
	    ifTrue: [blox gotoLine: prompter response asInteger end: false]
    ]

    revert [
	"Revert text changes and replace current text with original text"

	<category: 'blue button menu items'>
	self display
    ]

    senders [
	"Maybe getSelectionOrWord?"

	<category: 'blue button menu items'>
	self getSelectionOrLine 
	    ifNotNil: [:sel | MethodSetBrowser sendersOf: sel asSymbol parent: self]
    ]

    canBeDirty [
	<category: 'displaying'>
	^canBeDirty
    ]

    canBeDirty: aBoolean [
	<category: 'displaying'>
	canBeDirty := aBoolean.
	dirty := dirty & canBeDirty
    ]

    canUpdate [
	"If text has been modified, display a prompter.  If the No button is
	 selected, return true"

	<category: 'displaying'>
	| cancel |
	data isNil ifTrue: [^true].
	canBeDirty ifFalse: [^true].
	dirty ifFalse: [^true].
	cancel := self 
		    confirm: 'The text has been altered.' , (String with: Character nl) 
			    , 'Do you wish to discard those changes?'.
	^cancel
    ]

    confirm: aString [
	"Used by canUpdate when the text has been modified.  If the user wishes to
	 discard the editing changes by pressing 1, the dirty flag is reset"

	<category: 'displaying'>
	(ModalDialog new)
	    message: aString in: self;
	    addButton: 'Yes' message: [dirty := false];
	    addButton: 'No' message: [];
	    display: self.
	^dirty not
    ]

    display [
	"Update text view.  Dirty flag is reset"

	<category: 'displaying'>
	textMsg isNil ifFalse: [self contents: (data perform: textMsg)].
	dirty := false
    ]

    displayError: errorString [
	"Insert error string at cursor and select it"

	<category: 'displaying'>
	self blox insertTextSelection: errorString
    ]

    displayError: errorString at: lineNo [
	"Display error string at end of line indicated by lineNo"

	<category: 'displaying'>
	(self blox gotoLine: lineNo end: true) = 0 
	    ifFalse: [self blox insertSelectedText: errorString]
	    ifTrue: [self beep]
    ]

    findString: aString [
	"Select aString in the text view.  If not found, beep"

	<category: 'displaying'>
	(blox searchString: aString) = 0 ifTrue: [self beep]
    ]

    selection: aString [
	<category: 'initializing'>
	selection := aString
    ]

    setBrowserKeyBindings [
	"Add key bindings for Accept, etc."

	<category: 'initializing'>
	#('Control-S') with: #(#compileIt)
	    do: 
		[:key :sel | 
		self blox 
		    onKeyEvent: key
		    send: sel
		    to: self]
    ]

    setEvaluationKeyBindings [
	"Add key bindings for Doit, Print it, etc."

	<category: 'initializing'>
	#('Meta-D' 'Meta-P' 'Meta-I' 'Control-Return') 
	    with: #(#eval #evalAndPrintResult #evalAndInspectResult #doLine)
	    do: 
		[:key :sel | 
		self blox 
		    onKeyEvent: key
		    send: sel
		    to: self]
    ]

    setDirtyFlag [
	"Set modification state of text view"

	<category: 'initializing'>
	dirty := canBeDirty
    ]

    stateChange: stateChangeKey [
	"Install message handler to redraw text pane in response to an stateChangeKey
	 message.  If there is text which is initially selected, select the text.  This
	 feature is utilized by some types of message set browsers"

	<category: 'initializing'>
	self stateChange: stateChangeKey
	    updateWith: 
		[self display.
		selection notNil ifTrue: [self findString: selection]]
    ]

    textMsg: textSelector [
	"The textSelector is supplied by the view's data object.  When invoked
	 from computeText, the text to be displayed is returned"

	<category: 'initializing'>
	textMsg := textSelector
    ]

    contents: text [
	<category: 'polymorphism'>
	blox contents: text
    ]

    object [
	<category: 'evaluation'>
	^object
    ]

    object: anObject [
	<category: 'evaluation'>
	object := anObject
    ]

    doEval: text ifError: aBlock [
	<category: 'evaluation'>
	^Behavior 
	    evaluate: text
	    to: object
	    ifError: aBlock
    ]
]



STInST.STInST.RBProgramNodeVisitor subclass: WorksheetVariableTracker [
    | vars class |
    
    <category: 'Graphics-Windows'>
    <comment: nil>

    initialize [
	<category: 'initialization'>
	vars := #('self' 'super' 'true' 'false' 'nil' 'thisContext') asSet.
	class := (Behavior new)
		    superclass: Object;
		    yourself
    ]

    objectClass [
	<category: 'accessing'>
	^class
    ]

    includesVariable: aString [
	<category: 'operation'>
	^aString first isUppercase or: [vars includes: aString]
    ]

    defineVariable: aString [
	<category: 'operation'>
	vars add: aString.
	class addInstVarName: aString
    ]

    acceptAssignmentNode: anRBAssignmentNode [
	<category: 'operation'>
	(self includesVariable: anRBAssignmentNode variable name) 
	    ifFalse: [self defineVariable: anRBAssignmentNode variable name].
	self visitNode: anRBAssignmentNode value
    ]
]



PText subclass: PWorksheetText [
    | variableTracker |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PWorksheetText class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	"Use a lightweight class to evaluate the workspace expressions,
	 so that variables are kept across evaluations."

	<category: 'initialization'>
	variableTracker := WorksheetVariableTracker new.
	self object: variableTracker objectClass new
    ]

    doEval: text ifError: aBlock [
	<category: 'initialization'>
	| nodes |
	nodes := STInST.RBParser parseExpression: text
		    onError: [:s :p | ^super doEval: text ifError: aBlock].
	variableTracker visitNode: nodes.
	^super doEval: text ifError: aBlock
    ]
]

