"======================================================================
|
|   Smalltalk GUI generic inspectors
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
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



GuiData subclass: Inspector [
    | listView textView topView fieldList fieldLists diveList |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    text [
	"Return string representation of currently selected instance or indexed
	 variable"

	<category: 'accessing'>
	fieldList currentField == 0 ifTrue: [^''].
	^fieldList currentFieldString
    ]

    object [
	<category: 'accessing'>
	^textView object
    ]

    object: anObject [
	<category: 'accessing'>
	textView object: anObject.
	fieldLists do: [:each | each value: anObject].
	self changeState: #fieldList.
	self changeState: #text.
	Primitive updateViews
    ]

    fields [
	"Return list of variable names displayed in the variable list pane"

	<category: 'accessing'>
	^fieldList fields
    ]

    currentField: field [
	<category: 'accessing'>
	fieldList currentField: field.
	self changeState: #text.
	Primitive updateViews
    ]

    currentField [
	<category: 'accessing'>
	^fieldList currentField
    ]

    fieldLists [
	<category: 'initializing'>
	^fieldLists
    ]

    fieldLists: aCollection [
	<category: 'initializing'>
	fieldLists := aCollection.
	self fieldList: aCollection first value
    ]

    fieldList: aFieldList [
	<category: 'initializing'>
	fieldList := aFieldList.
	fieldList inspector: self.
	textView isNil 
	    ifFalse: 
		[textView object: fieldList value.
		listView menuInit: ((fieldList inspectMenu: listView) 
			    selectors: #(#() #('Dive' #dive) #('Pop' #pop) #('Browse class' #browse) #())
			    receiver: self
			    argument: nil).
		self initFieldListsMenu.
		self changeState: #fieldList.
		self changeState: #text.
		Primitive updateViews]
    ]

    initFieldListsMenu [
	<category: 'initializing'>
	fieldLists do: 
		[:each | 
		listView menu selectors: 
			{
			{each key.
			#fieldList:.
			each value}}
		    receiver: self]
    ]

    open [
	<category: 'initializing'>
	| pane |
	topView := BrowserShell 
		    new: 'Inspecting %1%2' % 
				{fieldList value isClass 
				    ifFalse: [fieldList value class article , ' ']
				    ifTrue: [''].
				fieldList value class nameIn: Namespace current}.
	topView data: self.
	topView blox 
	    x: 20
	    y: 330
	    width: 300
	    height: 100.
	pane := Form new: 'forms' in: topView.
	topView addChildView: pane.
	self openIn: pane menuName: 'Edit'.
	topView display
    ]

    openIn: pane [
	<category: 'initializing'>
	self openIn: pane menuName: 'Edit'
    ]

    openIn: pane menuName: label [
	"Initialize Inspector and open an Inspector window on anObject"

	"Initialize instance variable, fields, which governs display of
	 variable list pane"

	<category: 'initializing'>
	"Create a Form manager which will contain the variable and text pane"

	| listWidth container |
	container := pane blox.
	listWidth := pane blox width // 3 min: 100.

	"Create a text window and position it in first third of window"
	pane addChildView: ((listView := PList new: 'InstanceVars' in: pane)
		    initialize;
		    data: self;
		    stateChange: #fieldList;
		    handleUserChange: #currentField:;
		    listMsg: #fields;
		    selectionMsg: #currentField;
		    yourself).
	(listView blox)
	    width: listWidth height: pane blox height;
	    inset: 2.

	"Create text pane and position it in right 2/3s of window"
	pane addChildView: ((textView := PText new: pane)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #setArg:from:;
		    textMsg: #text;
		    canBeDirty: false;
		    setEvaluationKeyBindings;
		    object: fieldList value;
		    yourself).
	(textView blox)
	    width: pane blox width - listWidth height: pane blox height;
	    inset: 2.
	textView blox posHoriz: listView blox.
	"Initialize popup for text pane"
	textView menuInit: ((PopupMenu new: textView label: label)
		    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find))
			receiver: textView
			argument: nil;
		    selectors: #(#() #('Do it' #eval: #textView) #('Print it' #evalAndPrintResult: #textView) #('Inspect' #inspectValue: #textView))
			receiver: self
			argument: textView;
		    selectors: #(#() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
			receiver: textView
			argument: nil;
		    yourself).
	self fieldLists: self fieldLists.
	self changeState: #fieldList.
	Primitive updateViews
    ]

    browse [
	<category: 'list view menu'>
	ClassBrowser new openOn: self object class asClass
    ]

    dive [
	<category: 'list view menu'>
	diveList isNil ifTrue: [diveList := OrderedCollection new].
	diveList addLast: fieldLists.
	self fieldLists: fieldList currentFieldValue inspectorFieldLists
    ]

    pop [
	<category: 'list view menu'>
	diveList isNil ifTrue: [^self].
	diveList isEmpty ifTrue: [^self].
	self fieldLists: diveList removeLast
    ]

    eval: aView [
	"Invoked from text pane popup.  Evaluate selected expression in text pane"

	<category: 'text view menu'>
	| pos aStream text |
	text := aView blox getSelection.
	(text isNil or: [text size = 0]) ifTrue: [^aView beep].
	aStream := WriteStream on: (String new: 0).
	fieldList value class evaluate: text to: fieldList value
    ]

    evalAndPrintResult: aView [
	"Print result of evaluation of selected expression to its right"

	<category: 'text view menu'>
	| pos result text |
	text := aView blox getSelection.
	(text isNil or: [text size = 0]) ifTrue: [^aView beep].
	result := fieldList value class 
		    evaluate: text
		    to: fieldList value
		    ifError: [:fname :lineNo :errorString | errorString].
	aView blox insertTextSelection: result printString
    ]

    inspectValue: aView [
	"Open an inspector for evaluated selected expression.  If selected expression
	 contains parsing error(s), the error description is selected and printed at end
	 of selection"

	<category: 'text view menu'>
	| obj text |
	text := aView blox getSelection.
	(text isNil or: [text size = 0]) ifTrue: [^aView beep].
	obj := fieldList value class 
		    evaluate: text
		    to: fieldList value
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString.
			^nil].
	obj inspect
    ]

    setArg: aString from: aView [
	"Store result of evaluation of selected expression in selected instance or
	 indexed variable"

	<category: 'text view menu'>
	| obj |
	(aString isNil or: [aString size = 0]) ifTrue: [^aView beep].
	fieldList currentField <= 1 ifTrue: [^aView beep].

	"Evaluate selected expression.  If expression contains a parsing error, the
	 description is output at end of expression and nil is returned"
	obj := fieldList value class 
		    evaluate: aString
		    to: fieldList value
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString at: lineNo.
			^nil].
	fieldList currentFieldValue: obj
    ]
]



ValueHolder subclass: InspectorFieldList [
    | inspector fields currentField |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    evalAndInspectResult: listView [
	<category: 'field list menu'>
	currentField == 0 ifTrue: [^listView beep].
	self currentFieldValue inspect
    ]

    inspector [
	<category: 'private'>
	^inspector
    ]

    inspector: anInspector [
	<category: 'private'>
	inspector := anInspector
    ]

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'private'>
	^(PopupMenu new: listView) 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView))
	    receiver: self
	    argument: listView
    ]

    currentField [
	<category: 'private'>
	^currentField
    ]

    currentField: assoc [
	"Set variable list index to 'index'."

	<category: 'private'>
	currentField := assoc key
    ]

    currentFieldValue: obj [
	<category: 'private'>
	self subclassResponsibility
    ]

    currentFieldValue [
	<category: 'private'>
	self subclassResponsibility
    ]

    currentFieldString [
	<category: 'private'>
	^[self currentFieldValue printString] on: Error
	    do: [:ex | ex return: '[%1 exception raised while printing item]' % {ex class}]
    ]

    fieldsSortBlock [
	"nil = use OrderedCollection, else a block to be used as fields'
	 sort block."

	<category: 'private'>
	^nil
    ]

    fields [
	<category: 'private'>
	^fields
    ]

    value: anObject [
	<category: 'private'>
	super value: anObject.
	fields := self fieldsSortBlock ifNil: [OrderedCollection new]
		    ifNotNil: [:block | SortedCollection sortBlock: block].
	currentField := 0.
	self computeFieldList: anObject
    ]

    computeFieldList: anObject [
	"Store a string representation of the inspected object, anObject, in fields.
	 The first string is self.  The subsequent values are the object's complete set
	 of instance variables names.  If the object is a variable class, append
	 numerical indices from one to number of indexed variables"

	<category: 'private'>
	self subclassResponsibility
    ]
]



InspectorFieldList subclass: ObjectInspectorFieldList [
    | base |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    currentFieldValue: obj [
	<category: 'accessing'>
	currentField > base 
	    ifTrue: [self value basicAt: currentField - base put: obj]
	    ifFalse: [self value instVarAt: currentField - 1 put: obj]
    ]

    currentFieldValue [
	<category: 'accessing'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^currentField > base 
	    ifTrue: [self value basicAt: currentField - base]
	    ifFalse: [self value instVarAt: currentField - 1]
    ]

    computeFieldList: anObject [
	"Store a string representation of the inspected object, anObject, in fields.
	 The first string is self.  The subsequent values are the object's complete
	 set of instance variables names.  If the object is a variable class,
	 append numerical indices from one to number of indexed variables"

	<category: 'accessing'>
	| instVarNames |
	fields add: 'self'.
	instVarNames := anObject class allInstVarNames.
	1 to: instVarNames size
	    do: [:x | fields add: (instVarNames at: x) asString].
	base := fields size.
	anObject class isVariable 
	    ifTrue: [1 to: anObject validSize do: [:x | fields add: x printString]]
    ]
]



ObjectInspectorFieldList subclass: CollectionInspectorFieldList [
    | array |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    currentFieldValue: obj [
	<category: 'initializing'>
	(self value isKindOf: SequenceableCollection) not 
	    | (self value class == SortedCollection) 
		ifTrue: 
		    [(self value)
			remove: self currentFieldValue ifAbsent: [];
			add: obj.
		    array := self value asArray.
		    ^self].
	self value at: currentField - 1 put: obj.
	array == self value ifFalse: [array at: currentField - 1 put: obj]
    ]

    currentFieldValue [
	<category: 'initializing'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^array at: currentField - 1
    ]

    computeFieldList: anObject [
	"Use this so that the user doesn't see implementation-dependant details"

	<category: 'initializing'>
	array := (anObject isKindOf: ArrayedCollection) 
		    ifFalse: [anObject asArray]
		    ifTrue: [anObject].
	super computeFieldList: array
    ]
]



Object extend [

    inspectorFieldLists [
	<category: 'debugging'>
	^{'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)}
    ]

    basicInspect [
	"Open an Inspector window on self"

	<category: 'debugging'>
	^(BLOX.BLOXBrowser.Inspector new)
	    fieldLists: 
		    {'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)};
	    open;
	    yourself
    ]

    inspect [
	"Open an inspection window on self -- by default, the same Inspector used
	 in #basicInspect."

	<category: 'debugging'>
	^(BLOX.BLOXBrowser.Inspector new)
	    fieldLists: self inspectorFieldLists;
	    open;
	    yourself
    ]

]



Collection extend [

    inspectorFieldLists [
	<category: 'debugging'>
	^
	{'Elements' 
	    -> (BLOX.BLOXBrowser.CollectionInspectorFieldList new value: self).
	'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)}
    ]

]

