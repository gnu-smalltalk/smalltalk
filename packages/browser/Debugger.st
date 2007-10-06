"======================================================================
|
|   Smalltalk GUI debugger window
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2007
| Free Software Foundation, Inc.
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



GuiData subclass: Debugger [
    | stacktrace contexts debugger activeContext receiverInspector stackInspector listView theClass theMethod textView topView |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Debugger class >> debuggerClass [
	<category: 'class attributes'>
	^nil
    ]

    Debugger class >> debuggingPriority [
	<category: 'class attributes'>
	^1
    ]

    Debugger class >> new: notifier [
	<category: 'instance creation'>
	^self new init: notifier
    ]

    init: notifier [
	<category: 'initialize/release'>
	debugger := notifier debugger.
	[debugger suspendedContext isInternalExceptionHandlingContext] 
	    whileTrue: [debugger slowFinish].
	self createWindowFrom: notifier
    ]

    createWindowFrom: notifier [
	<category: 'initialize/release'>
	| toplevel container text buttonView lowerpane pane list context urpane lrpane |
	topView := (BrowserShell new: 'Debugger') data: self.
	toplevel := topView blox.
	toplevel 
	    x: 20
	    y: 50
	    width: 500
	    height: 350.
	pane := Form new: 'panes' in: topView.
	topView addChildView: pane.
	pane blox width: 500 height: 125.
	pane addChildView: ((listView := PList new: 'MethodSet' in: pane)
		    initialize;
		    data: self;
		    listMsg: #stacktrace;
		    dataMsg: #contexts;
		    handleUserChange: #contextSelectedFrom:;
		    stateChange: #stacktrace;
		    yourself).
	listView menuInit: ((PopupMenu new: listView label: 'Debug') 
		    selectors: self debugSelectors
		    receiver: self).
	listView blox width: 300 height: 100.
	pane addChildView: ((buttonView := ButtonForm new: 'Debugging' in: pane)
		    selectors: self debugSelectors receiver: self;
		    yourself).
	buttonView blox 
	    x: 0
	    y: 100
	    width: 300
	    height: 25.
	urpane := Form new: 'panes' in: pane.
	pane addChildView: urpane.
	urpane blox width: 200 height: 125.
	urpane blox posHoriz: listView blox.
	lowerpane := Form new: 'panes' in: topView.
	lowerpane blox posVert: pane blox.
	lowerpane blox width: 500 height: 225.
	topView addChildView: lowerpane.
	lowerpane addChildView: ((textView := PCode new: lowerpane)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #compile:from:;
		    setBrowserKeyBindings;
		    textMsg: #text;
		    yourself).
	textView menuInit: ((PopupMenu new: textView label: 'Edit') 
		    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors) #() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
		    receiver: textView
		    argument: nil).
	text := textView blox.
	text width: 300 height: 225.
	lrpane := Form new: 'panes' in: lowerpane.
	lowerpane addChildView: lrpane.
	lrpane blox width: 200 height: 225.
	lrpane blox posHoriz: textView blox.
	stackInspector := (Inspector new)
		    fieldLists: (self stackFieldListsFor: notifier currentContext);
		    openIn: urpane menuName: 'Stack'.
	receiverInspector := (Inspector new)
		    fieldLists: (self receiverFieldListsFor: notifier currentContext receiver);
		    openIn: lrpane menuName: 'Receiver'.
	self updateContextList.
	self currentContext: notifier currentContext.
	topView display
    ]

    receiverFieldListsFor: anObject [
	<category: 'inspector panes'>
	^{'Primitive' -> (PrimitiveInspectorFieldList new value: anObject)} 
	    , anObject inspectorFieldLists
    ]

    stackFieldListsFor: context [
	<category: 'inspector panes'>
	^
	{'Variables' -> (StackInspectorFieldList new value: context).
	'Stack' -> (ObjectInspectorFieldList new value: context)}
    ]

    compile: aString from: aView [
	"Compile aString derived from text in text view for the selected selector"

	<category: 'text pane'>
	theMethod notNil 
	    ifTrue: 
		[theClass 
		    compile: aString
		    classified: theMethod methodCategory
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString at: lineNo.
			^nil]]
    ]

    contextSelectedFrom: assoc [
	<category: 'text pane'>
	self currentContext: assoc value
    ]

    highlight: context [
	<category: 'text pane'>
	| line |
	line := context currentLine.
	(textView blox)
	    gotoLine: line end: false;
	    selectFrom: 1 @ line to: 1 @ (line + 1)
    ]

    contexts [
	<category: 'text pane'>
	^contexts
    ]

    stacktrace [
	<category: 'text pane'>
	^stacktrace
    ]

    text [
	"Return source code for the selected method"

	<category: 'text pane'>
	| source |
	^(theMethod notNil and: [(source := theMethod methodSourceString) notNil]) 
	    ifTrue: [theClass -> source]
	    ifFalse: ['']
    ]

    debugSelectors [
	<category: 'button pane'>
	^#(#('Step' #stepButtonCallback) #('Next' #nextButtonCallback) #('Finish' #finishButtonCallback) #('Continue' #continueButtonCallback) #() #('Kill' #killButtonCallback) #() #('Terminate' #terminateButtonCallback))
    ]

    updateAfter: aBlock [
	"If there's an exception, replace this window with another
	 notifier."

	<category: 'button pane'>
	aBlock on: SystemExceptions.DebuggerReentered
	    do: 
		[:ex | 
		topView close.
		Notifier openOn: debugger process.
		^self].
	self updateContextList
    ]

    stepButtonCallback [
	<category: 'button pane'>
	self updateAfter: [debugger step]
    ]

    nextButtonCallback [
	<category: 'button pane'>
	self updateAfter: [debugger next]
    ]

    finishButtonCallback [
	<category: 'button pane'>
	self updateAfter: [debugger finish: activeContext]
    ]

    continueButtonCallback [
	<category: 'button pane'>
	topView close.
	debugger continue
    ]

    killButtonCallback [
	<category: 'button pane'>
	topView close.
	debugger process primTerminate
    ]

    terminateButtonCallback [
	<category: 'button pane'>
	topView close.
	debugger process terminate.
	debugger continue
    ]

    updateContextList [
	<category: 'list pane'>
	| context lastContext |
	context := debugger suspendedContext.
	lastContext := context environment.
	stacktrace := OrderedCollection new.
	contexts := OrderedCollection new.
	[context == lastContext] whileFalse: 
		[context isDisabled 
		    ifFalse: 
			[stacktrace add: context printString.
			contexts add: context].
		context := context parentContext].
	self changeState: #stacktrace.
	self currentContext: debugger suspendedContext
    ]

    currentContext: context [
	<category: 'list pane'>
	activeContext := context.
	theMethod := context method.
	theClass := context methodClass.
	stackInspector fieldLists: (self stackFieldListsFor: context).
	receiverInspector 
	    fieldLists: (self receiverFieldListsFor: context receiver).
	self changeState: #text.
	Primitive updateViews.
	self highlight: context
    ]
]



ObjectInspectorFieldList subclass: PrimitiveInspectorFieldList [
    
    <comment: nil>
    <category: 'System-Compilers'>

    validSize: anObject [
	<category: 'primitives'>
	^((self primClass: anObject) inheritsFrom: ContextPart) 
	    ifTrue: [self prim: anObject instVarAt: ContextPart spIndex]
	    ifFalse: [self primBasicSize: anObject]
    ]

    prim: anObject instVarAt: anIndex [
	"Answer the index-th indexed variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_instVarAt>
	self primitiveFailed
    ]

    prim: anObject instVarAt: anIndex put: value [
	"Store value in the index-th instance variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_instVarAtPut>
	self primitiveFailed
    ]

    prim: anObject basicAt: anIndex [
	"Answer the index-th indexed instance variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_basicAt>
	self primitiveFailed
    ]

    prim: anObject basicAt: anIndex put: value [
	"Store value in the index-th indexed instance variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_basicAtPut>
	self primitiveFailed
    ]

    primBasicAt: anIndex [
	<category: 'primitives'>
	^((self primClass: self value) inheritsFrom: Object) 
	    ifTrue: [self value basicAt: anIndex]
	    ifFalse: [self prim: self value basicAt: anIndex]
    ]

    primBasicAt: anIndex put: anObject [
	<category: 'primitives'>
	^((self primClass: self value) inheritsFrom: Object) 
	    ifTrue: [self value basicAt: anIndex put: anObject]
	    ifFalse: 
		[self 
		    prim: self value
		    basicAt: anIndex
		    put: anObject]
    ]

    primBasicSize: anObject [
	"Answer the number of indexed instance variable in anObject"

	<category: 'primitives'>
	<primitive: VMpr_Object_basicSize>
	
    ]

    primClass: anObject [
	"Answer the class of anObject"

	<category: 'primitives'>
	<primitive: VMpr_Object_class>
	
    ]

    currentFieldValue: obj [
	<category: 'accessing'>
	currentField > base 
	    ifTrue: [self primBasicAt: currentField - base put: obj]
	    ifFalse: 
		[self 
		    prim: self value
		    instVarAt: currentField - 1
		    put: obj]
    ]

    currentFieldValue [
	<category: 'accessing'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^currentField > base 
	    ifTrue: [self primBasicAt: currentField - base]
	    ifFalse: [self prim: self value instVarAt: currentField - 1]
    ]

    computeFieldList: anObject [
	"Store a string representation of the inspected object, anObject, in fields.
	 The first string is self.  The subsequent values are the object's complete
	 set of instance variables names.  If the object is a variable class,
	 append numerical indices from one to number of indexed variables"

	<category: 'accessing'>
	| instVarNames class |
	fields add: 'self'.
	class := self primClass: anObject.
	instVarNames := class allInstVarNames.
	1 to: instVarNames size
	    do: [:x | fields add: (instVarNames at: x) asString].
	base := fields size.
	class isVariable 
	    ifTrue: 
		[1 to: (self validSize: anObject) do: [:x | fields add: x printString]]
    ]
]



InspectorFieldList subclass: StackInspectorFieldList [
    | vars |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    currentFieldValue: obj [
	<category: 'private'>
	| variable |
	currentField < 2 ifTrue: [^self].
	variable := vars at: currentField - 1.
	^variable key at: variable value put: obj
    ]

    currentFieldValue [
	"Return value at currently selected key"

	<category: 'private'>
	| variable |
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	variable := vars at: currentField - 1.
	^variable key at: variable value
    ]

    computeFieldList: anObject [
	<category: 'private'>
	vars := OrderedCollection new.
	fields add: 'thisContext'.
	self setFieldsIn: anObject
    ]

    setFieldsIn: context [
	<category: 'private'>
	| prefix numVars prefixSize |
	numVars := context numArgs + context numTemps.
	(context home == context or: [context outerContext == nil]) 
	    ifTrue: [prefixSize := -2]
	    ifFalse: [prefixSize := self setFieldsIn: context outerContext].
	numVars > 0 ifTrue: [prefixSize := prefixSize + 2].
	prefix := String new: (prefixSize max: 0) withAll: $-.
	(1 to: numVars) with: context variableNames
	    do: 
		[:i :varName | 
		fields add: prefix , varName.
		vars add: context -> i].
	^prefixSize
    ]
]

