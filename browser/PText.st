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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"

Primitive subclass:  #PText
	instanceVariableNames: 'textMsg selection canBeDirty object '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

PText comment: 
nil!

STInST RBProgramNodeVisitor subclass:  #WorksheetVariableTracker
	instanceVariableNames: 'vars class '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

PText subclass:  #PWorksheetText
	instanceVariableNames: 'variableTracker '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Windows'!

!PText class methodsFor: 'instance creation'!

bloxClass
    ^BText!

new: parent 
    | view |
    view := self new.
    view canBeDirty: true.
    view parentView: parent.
    view blox: (self bloxClass new: parent blox).
    view blox callback: view message: 'setDirtyFlag'.
    ^view!

newReadOnly: parent 
    | view |
    view := self new.
    view parentView: parent.
    view blox: (self bloxClass newReadOnly: parent blox).
    "view blox backgroundColor: 'LemonChiffon'."
    ^view! !

!PText methodsFor: 'private'!

getSelectionOrLine
    "Answer the text currently selected or the text on the current line if
     there's no text selected.  This enables Do It, Print It, and Inspect It
     to be used without manually selecting text."

    | text |
    text := blox getSelection.
    (text isNil or: [ text isEmpty ]) ifTrue: [^blox lineAt: blox currentLine].
    ^text! !

!PText methodsFor: 'blue button menu items'!

compileIt
    "Activated when the user selects 'accept' from the popup menu.  Send a 
     stateChangeMsg to the data object"

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

	    dirty := rejected & canBeDirty]!

eval
    | text pos |
    pos := blox currentLine.
    text := self getSelectionOrLine.
    (text isNil or: [text size = 0]) ifTrue: [^self beep].
    self doEval: text
	ifError: [:fname :lineNo :errorString |
	    self displayError: errorString at: lineNo + pos]!

doLine
    "Perform a single line of code in a Worksheet or the Transcript window. 
     This actually executes the _previous_ line because Tcl/Tk passes through
     the Return of the Control-Return keybinding to its text editor widget
     before we get here."

    | endPt |
    endPt := 1 @ blox currentLine.
    blox selectFrom: 1 @ (blox currentLine - 1) to: endPt.
    self eval.
    blox selectFrom: endPt to: endPt!

evalAndInspectResult
    "Open an inspector on the result of the evaluation of the selected Smalltalk expression"

    | obj text pos |
    pos := blox currentLine.
    text := self getSelectionOrLine.
    (text isNil or: [text size = 0]) ifTrue: [^self beep].
    obj := self doEval: text
		ifError: 
		    [:fname :lineNo :errorString | 
		    self displayError: errorString at: lineNo + pos.
		    ^nil].
    obj inspect!

evalAndPrintResult
    "Display and select result of evaluation of selected expression to right of
     selection"

    | text obj pos |
    pos := blox currentLine.
    text := self getSelectionOrLine.
    (text isNil or: [text size = 0]) ifTrue: [^self beep].
    obj := self doEval: text
		ifError: 
		    [:fname :lineNo :errorString | 
		    self displayError: errorString at: lineNo + pos.
		    ^nil].
    blox insertTextSelection: obj printString!

find
    | prompter |
    prompter := Prompter message: 'Search...' in: self.
    prompter response ~= '' ifTrue: [blox searchString: prompter response]!

gstClear
    blox replaceSelection: ''!

gstCopy
    Blox clipboard: blox getSelection!

gstCut
    self gstCopy.
    self gstClear!

gstPaste
    | clip |
    clip := Blox clipboard.
    clip isEmpty ifFalse: [blox replaceSelection: clip]!

implementors
    "Maybe getSelectionOrWord?"
    self getSelectionOrLine
	ifNotNil: [:sel | MethodSetBrowser implementorsOf: sel asSymbol parent: self]!

line
    "Prompt user to enter a line number.  If a valid number, attempt
     to scroll to entered line number"

    | prompter |
    prompter := Prompter message: 'Goto line...' in: self.
    prompter response isEmpty ifTrue: [^self].
    (prompter response allSatisfy: [:ch | ch isDigit]) 
	ifTrue: [blox gotoLine: prompter response asInteger end: false]!

revert
    "Revert text changes and replace current text with original text"

    self display!

senders
    "Maybe getSelectionOrWord?"
    self getSelectionOrLine
	ifNotNil: [:sel | MethodSetBrowser sendersOf: sel asSymbol parent: self]! !

!PText methodsFor: 'displaying'!

canBeDirty
    ^canBeDirty!

canBeDirty: aBoolean 
    canBeDirty := aBoolean.
    dirty := dirty & canBeDirty!

canUpdate
    "If text has been modified, display a prompter.  If the No button is
     selected, return true"

    | cancel |
    data isNil ifTrue: [^true].
    canBeDirty ifFalse: [^true].
    dirty ifFalse: [^true].
    cancel := self 
		confirm: 'The text has been altered.' , (String with: Character nl) 
			, 'Do you wish to discard those changes?'.
    ^cancel!

confirm: aString 
    "Used by canUpdate when the text has been modified.  If the user wishes to 
     discard the editing changes by pressing 1, the dirty flag is reset"

    (ModalDialog new)
	message: aString in: self;
	addButton: 'Yes' message: [dirty := false];
	addButton: 'No' message: [];
	display: self.
    ^dirty not!

display
    "Update text view.  Dirty flag is reset"

    textMsg isNil ifFalse: [self contents: (data perform: textMsg)].
    dirty := false!

displayError: errorString 
    "Insert error string at cursor and select it"

    self blox insertTextSelection: errorString!

displayError: errorString at: lineNo 
    "Display error string at end of line indicated by lineNo"

    (self blox gotoLine: lineNo end: true) = 0 
	ifFalse: [self blox insertSelectedText: errorString]
	ifTrue: [self beep]!

findString: aString 
    "Select aString in the text view.  If not found, beep"

    (blox searchString: aString) = 0 ifTrue: [self beep]! !

!PText methodsFor: 'initializing'!

selection: aString 
    selection := aString!

setBrowserKeyBindings
    "Add key bindings for Accept, etc."
    #('Control-S')
        with: #(#compileIt)
        do: [:key :sel | self blox onKeyEvent: key send: sel to: self]!

setEvaluationKeyBindings
    "Add key bindings for Doit, Print it, etc."
    #('Meta-D' 'Meta-P' 'Meta-I' 'Control-Return')
        with: #(#eval #evalAndPrintResult #evalAndInspectResult #doLine)
        do: [:key :sel | self blox onKeyEvent: key send: sel to: self]!

setDirtyFlag
    "Set modification state of text view"
    dirty := canBeDirty!

stateChange: stateChangeKey 
    "Install message handler to redraw text pane in response to an stateChangeKey 
     message.  If there is text which is initially selected, select the text.  This
     feature is utilized by some types of message set browsers"

    self stateChange: stateChangeKey
	updateWith: 
	    [self display.
	    selection notNil ifTrue: [self findString: selection]]!

textMsg: textSelector 
    "The textSelector is supplied by the view's data object.  When invoked
     from computeText, the text to be displayed is returned"

    textMsg := textSelector! !

!PText methodsFor: 'polymorphism'!

contents: text 
    blox contents: text! !


!PText methodsFor: 'evaluation'!

object
    ^object!

object: anObject
    object := anObject!

doEval: text ifError: aBlock
    ^Behavior evaluate: text to: object ifError: aBlock! !

!WorksheetVariableTracker methodsFor: 'initialization'!

initialize
    vars := #('self' 'super' 'true' 'false' 'nil' 'thisContext') asSet.
    class := Behavior new superclass: Object; yourself! !

!WorksheetVariableTracker methodsFor: 'accessing'!

objectClass
    ^class! !

!WorksheetVariableTracker methodsFor: 'operation'!

includesVariable: aString
    ^aString first isUppercase or: [ vars includes: aString ]!

defineVariable: aString
    vars add: aString.
    class addInstVarName: aString! 

acceptAssignmentNode: anRBAssignmentNode
    (self includesVariable: anRBAssignmentNode variable name)
	ifFalse: [ self defineVariable: anRBAssignmentNode variable name ].

    self visitNode: anRBAssignmentNode value! !

!PWorksheetText class methodsFor: 'instance creation'!

new
    ^super new initialize
! !

!PWorksheetText methodsFor: 'initialization'!

initialize
    "Use a lightweight class to evaluate the workspace expressions,
     so that variables are kept across evaluations."

    variableTracker := WorksheetVariableTracker new.
    self object: variableTracker objectClass new!

doEval: text ifError: aBlock
    | nodes |
    nodes := STInST.RBParser parseExpression: text onError: [ :s :p |
	^super doEval: text ifError: aBlock ].

    variableTracker visitNode: nodes.
    ^super doEval: text ifError: aBlock! !

