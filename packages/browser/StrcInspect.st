"======================================================================
|
|   Smalltalk GUI inspector for CStruct derivatives
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



InspectorFieldList subclass: CCompoundInspectorFieldList [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    currentField: assoc [
	"Set list selection to value of index.  Force a text view update"

	<category: 'accessing'>
	assoc key == 0 
	    ifTrue: [currentField := 0]
	    ifFalse: [currentField := (fields at: assoc key) value]
    ]

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'initializing'>
	^(PopupMenu new: listView label: 'Field') 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView))
	    receiver: self
	    argument: listView
    ]

    currentFieldValue: obj [
	"Cannot change!"

	<category: 'private'>
	
    ]

    currentFieldValue [
	<category: 'private'>
	currentField == 0 ifTrue: [^nil].
	^(self value perform: currentField asSymbol) value
    ]

    computeFieldList: anObject [
	"Initialize instance variable, fields, which governs display of
	 variable list pane."

	<category: 'private'>
	self value inspectSelectorList 
	    do: [:aKey | fields add: (Association key: aKey asString value: aKey)]
    ]
]



CCompound extend [

    inspectorFieldLists [
	"Open a CCompoundInspectorFieldList window on self"

	<category: 'debugging'>
	^{'Basic' -> BLOX.BLOXBrowser.CCompoundInspectorFieldList new value: self}
    ]

]

