"======================================================================
|
|   Smalltalk GUI inspector for Dictionaries
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



InspectorFieldList subclass: DictionaryInspectorFieldList [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    currentField: assoc [
	"Set list selection to value of index.  Force a text view update"

	<category: 'accessing'>
	assoc key <= 1 
	    ifTrue: [currentField := assoc key]
	    ifFalse: [currentField := fields at: assoc key]
    ]

    fieldsSortBlock [
	<category: 'accessing'>
	^[:a :b | a = 'self' or: [b ~= 'self' and: [a displayString <= b displayString]]]
    ]

    computeFieldList: anObject [
	"Return sorted list of keys from set of Associations stored in fields"

	<category: 'accessing'>
	fields add: 'self'.
	fields addAll: anObject keys
    ]

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'initializing'>
	^(PopupMenu new: listView) 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView) #('References' #references: #listView) #() #('Add key...' #addField: #listView) #('Remove...' #removeField: #listView))
	    receiver: self
	    argument: listView
    ]

    currentFieldValue: obj [
	<category: 'private'>
	self value at: currentField put: obj
    ]

    currentFieldValue [
	<category: 'private'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^self value at: currentField
    ]

    addField: listView [
	"Prompt user for the name of new dictionary key.  If name is valid, add it
	 to dictionary"

	<category: 'variable list menu'>
	| key |
	listView canChangeState ifFalse: [^self].
	key := (Prompter message: 'Enter a new field' in: listView) response.
	key isEmpty ifTrue: [^self].
	(key at: 1) == $# 
	    ifTrue: [key := (key copyFrom: 2 to: key size) asSymbol]
	    ifFalse: [key isNumeric ifTrue: [key := key asNumber]].

	"If new key already exists, reject"
	(self value includesKey: key) 
	    ifTrue: 
		[^ModalDialog new 
		    alertMessage: 'Invalid name: the key, ' , key , ', already exists.'
		    in: listView].

	"Update variable selection"
	currentField := key.
	"Update dictionary"
	self value at: key put: nil.
	"Update instance variable governing variable list pane display"
	fields add: key.
	"Update text view"
	inspector
	    changeState: #fieldList;
	    changeState: #text.
	Primitive updateViews
    ]

    references: listView [
	"Open a method set browser on all methods which reference selected key"

	<category: 'variable list menu'>
	| alert keyRefs theKey |
	currentField <= 1 ifTrue: [^listView beep].
	keyRefs := SortedCollection new.
	Namespace current allClassObjectsDo: 
		[:subclass | 
		(subclass whichSelectorsReferTo: (self value associationAt: currentField)) 
		    do: [:sel | keyRefs add: subclass printString , ' ' , sel]].
	keyRefs isEmpty 
	    ifTrue: 
		[^alert := ModalDialog new 
			    alertMessage: 'No references to ' , currentField printString
			    in: listView].
	MethodSetBrowser new 
	    openOn: keyRefs
	    title: 'References to ' , currentField printString
	    selection: currentField displayString
    ]

    removeField: listView [
	"Remove selected key from dictionary"

	<category: 'variable list menu'>
	| cancel |
	currentField isNil ifTrue: [^listView beep].
	(ModalDialog new)
	    message: 'Are you sure you want to remove, ' , currentField displayString 
			, '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].
	"Remove key from dictionary"
	self value removeKey: currentField.
	"Remove the association composed of the key and the value from the data object"
	fields remove: currentField.
	currentField := 0.
	"Force a text view update to reflect deleted key"
	inspector
	    changeState: #fieldList;
	    changeState: #text.
	Primitive updateViews
    ]
]



Dictionary extend [

    inspectorFieldLists [
	"Open a DictionaryInspectorFieldList window on self"

	<category: 'debugging'>
	^
	{'Keys' -> (BLOX.BLOXBrowser.DictionaryInspectorFieldList new value: self).
	'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)}
    ]

]

