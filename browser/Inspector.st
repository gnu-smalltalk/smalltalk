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

GuiData subclass:  #Inspector
	instanceVariableNames: 'listView textView topView fieldList fieldLists diveList '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

Inspector comment: 
nil!

ValueHolder subclass:  #InspectorFieldList
	instanceVariableNames: 'inspector fields currentField'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

InspectorFieldList subclass: #ObjectInspectorFieldList
	instanceVariableNames: 'base '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

Inspector comment: 
nil!

ObjectInspectorFieldList subclass:  #CollectionInspectorFieldList
	instanceVariableNames: 'array'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

CollectionInspectorFieldList comment: 
nil!


!Inspector methodsFor: 'accessing'!

text
    "Return string representation of currently selected instance or indexed 
variable"

    fieldList currentField == 0 ifTrue: [^''].
    ^fieldList currentFieldString!

object
    ^textView object!

object: anObject
    textView object: anObject.
    fieldLists do: [ :each | each value: anObject ].
    self changeState: #fieldList.
    self changeState: #text.
    Primitive updateViews!

fields
    "Return list of variable names displayed in the variable list pane"

    ^fieldList fields!

currentField: field
    fieldList currentField: field.
    self changeState: #text.
    Primitive updateViews!

currentField
    ^fieldList currentField! !

!Inspector methodsFor: 'initializing'!

fieldLists
    ^fieldLists!

fieldLists: aCollection
    fieldLists := aCollection.
    self fieldList: aCollection first value!

fieldList: aFieldList
    fieldList := aFieldList.
    fieldList inspector: self.
    textView isNil ifFalse: [
	textView object: fieldList value.
	listView menuInit: ((fieldList inspectMenu: listView)
                     selectors: #(#() #('Dive' #dive) #('Pop' #pop) #('Browse class' #browse) #())
		     receiver: self
		     argument: nil).

	self initFieldListsMenu.

	self changeState: #fieldList.
	self changeState: #text.
	Primitive updateViews
    ]!

initFieldListsMenu
    fieldLists do: [ :each |
        listView menu
	    selectors: { { each key. #fieldList:. each value } }
	    receiver: self
    ]!

open
    | pane |
    topView := BrowserShell new: ('Inspecting %1%2'
	bindWith: (fieldList value isClass
			ifFalse: [ fieldList value class article, ' ' ]
			ifTrue: [ '' ])
	with: (fieldList value class nameIn: Namespace current)).
    topView data: self.
    topView blox 
	x: 0
	y: 330
	width: 300
	height: 100.
    pane := Form new: 'forms' in: topView.
    topView addChildView: pane.
    self openIn: pane menuName: 'Edit'.
    topView display!

openIn: pane 
    self openIn: pane menuName: 'Edit'!

openIn: pane menuName: label
    "Initialize Inspector and open an Inspector window on anObject"

    "Initialize instance variable, fields, which governs display of
     variable list pane"

    | listWidth container |
    "Create a Form manager which will contain the variable and text pane"
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

    textView blox
	width: pane blox width - listWidth height: pane blox height;
	inset: 2.
    textView blox posHoriz: listView blox.
    "Initialize popup for text pane"
    textView menuInit: ((PopupMenu new: textView label: label)
		selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste)
			     #() #('Clear' #gstClear)
			     #() #('Line...' #line) #('Find...' #find))
		    receiver: textView
		    argument: nil;
		selectors: #(#() #('Do it' #eval: #textView) #('Print it' #evalAndPrintResult: #textView)
			     #('Inspect' #inspectValue: #textView))
		    receiver: self
		    argument: textView;
		selectors: #(#() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
		    receiver: textView
		    argument: nil;
		yourself).

    self fieldLists: self fieldLists.
    self changeState: #fieldList.
    Primitive updateViews! !

!Inspector methodsFor: 'list view menu'!

browse
    ClassBrowser new openOn: self object class asClass!

dive
    diveList isNil ifTrue: [ diveList := OrderedCollection new ].
    diveList addLast: fieldLists.
    self fieldLists: fieldList currentFieldValue inspectorFieldLists!

pop
    diveList isNil ifTrue: [ ^self ].
    diveList isEmpty ifTrue: [ ^self ].
    self fieldLists: diveList removeLast! !

!Inspector methodsFor: 'text view menu'!

eval: aView 
    "Invoked from text pane popup.  Evaluate selected expression in text pane"

    | pos aStream text |
    text := aView blox getSelection.
    (text isNil or: [text size = 0]) ifTrue: [^aView beep].
    aStream := WriteStream on: (String new: 0).
    fieldList value class evaluate: text to: fieldList value!

evalAndPrintResult: aView 
    "Print result of evaluation of selected expression to its right"

    | pos result text |
    text := aView blox getSelection.
    (text isNil or: [text size = 0]) ifTrue: [^aView beep].
    result := fieldList value class 
		evaluate: text
		to: fieldList value
		ifError: [:fname :lineNo :errorString | errorString].
    aView blox insertTextSelection: result printString!

inspectValue: aView 
    "Open an inspector for evaluated selected expression.  If selected expression 
    contains parsing error(s), the error description is selected and printed at end
    of selection"

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
    obj inspect!

setArg: aString from: aView 
    "Store result of evaluation of selected expression in selected instance or 
    indexed variable"

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
    fieldList currentFieldValue: obj! !

!InspectorFieldList methodsFor: 'field list menu'!

evalAndInspectResult: listView 
    currentField == 0 ifTrue: [^listView beep].
    self currentFieldValue inspect! !


!InspectorFieldList methodsFor: 'private'!

inspector
    ^inspector!

inspector: anInspector
    inspector := anInspector!

inspectMenu: listView 
    "Initialize menu for variable list pane"

    ^(PopupMenu new: listView) 
	selectors: #(#('Inspect' #evalAndInspectResult: #listView))
	receiver: self
	argument: listView!

currentField
    ^currentField!

currentField: assoc 
    "Set variable list index to 'index'."

    currentField := assoc key!

currentFieldValue: obj 
    self subclassResponsibility!

currentFieldValue
    self subclassResponsibility!

currentFieldString
    ^[ self currentFieldValue printString ] on: Error do: [ :ex |
	ex return: ('[%1 exception raised while printing item]'
			bindWith: ex class) ]!

fieldsSortBlock
    "nil = use OrderedCollection, else a block to be used as fields'
     sort block."

    ^nil!

fields
    ^fields!

value: anObject
    super value: anObject.
    fields := self fieldsSortBlock
	ifNil: [OrderedCollection new]
	ifNotNil: [:block | SortedCollection sortBlock: block].

    currentField := 0.
    self computeFieldList: anObject!

computeFieldList: anObject 
    "Store a string representation of the inspected object, anObject, in fields. 
     The first string is self.  The subsequent values are the object's complete set
     of instance variables names.  If the object is a variable class, append 
     numerical indices from one to number of indexed variables"

    self subclassResponsibility! !

!ObjectInspectorFieldList methodsFor: 'accessing'!

currentFieldValue: obj 
    currentField > base 
	ifTrue: [self value basicAt: currentField - base put: obj]
	ifFalse: [self value instVarAt: currentField - 1 put: obj]!

currentFieldValue
    currentField == 0 ifTrue: [^nil].
    currentField == 1 ifTrue: [^self value].
    ^currentField > base 
	ifTrue: [self value basicAt: currentField - base]
	ifFalse: [self value instVarAt: currentField - 1]!

computeFieldList: anObject 
    "Store a string representation of the inspected object, anObject, in fields. 
     The first string is self.  The subsequent values are the object's complete
     set of instance variables names.  If the object is a variable class,
     append numerical indices from one to number of indexed variables"

    | instVarNames |
    fields add: 'self'.
    instVarNames := anObject class allInstVarNames.
    1 to: instVarNames size
	do: [:x | fields add: (instVarNames at: x) asString].
    base := fields size.
    anObject class isVariable
	ifTrue: [1 to: anObject validSize do: [:x | fields add: x printString]]
! !


!CollectionInspectorFieldList methodsFor: 'initializing'!

currentFieldValue: obj
    (self value isKindOf: SequenceableCollection) not |
	(self value class == SortedCollection)
	ifTrue: [
	    self value remove: self currentFieldValue ifAbsent: []; add: obj.
	    array := self value asArray.
	    ^self ].

    self value at: currentField - 1 put: obj.
    array == self value ifFalse: [ array at: currentField - 1 put: obj ]!

currentFieldValue
    currentField == 0 ifTrue: [^nil].
    currentField == 1 ifTrue: [^self value].
    ^array at: currentField - 1!

computeFieldList: anObject 
    "Use this so that the user doesn't see implementation-dependant details"

    array := (anObject isKindOf: ArrayedCollection)
        ifFalse: [ anObject asArray ]
	ifTrue: [ anObject ].

    super computeFieldList: array! !


!Object methodsFor: 'debugging'!

inspectorFieldLists
    ^{ 'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self) }
!

basicInspect
    "Open an Inspector window on self"
    ^BLOX.BLOXBrowser.Inspector new
	fieldLists: { 'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self) };
	open;
	yourself
!

inspect
    "Open an inspection window on self -- by default, the same Inspector used
     in #basicInspect."
    ^BLOX.BLOXBrowser.Inspector new
	fieldLists: self inspectorFieldLists;
	open;
	yourself
! !

!Collection methodsFor: 'debugging'!

inspectorFieldLists
    ^{ 'Elements' -> (BLOX.BLOXBrowser.CollectionInspectorFieldList new value: self).
       'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self) }
! !
