"======================================================================
|
|   Smalltalk GUI inspector for CompiledMethods
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



InspectorFieldList subclass: MethodInspectorFieldList [
    | lastVar |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'initializing'>
	^(PopupMenu new: listView label: nil) 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView) #('References' #references: #listView))
	    receiver: self
	    argument: listView
    ]

    currentFieldValue: obj [
	<category: 'private'>
	Blox beep
    ]

    currentFieldValue [
	<category: 'private'>
	| s |
	self currentField == 0 ifTrue: [^nil].
	self currentField = 2 
	    ifTrue: 
		[s := WriteStream on: (String new: 100).
		self value printHeaderOn: s.
		^s contents].
	self currentField = 1 
	    ifTrue: 
		[s := WriteStream on: (String new: 100).
		self value printByteCodesOn: s.
		^s contents].
	^self currentField <= lastVar 
	    ifTrue: [self value instVarAt: self currentField]
	    ifFalse: [self value literalAt: self currentField - lastVar]
    ]

    computeFieldList: anObject [
	"Initialize instance variable, fields, which governs display of
	 variable list pane."

	<category: 'private'>
	| string instVarNames |
	instVarNames := self value class allInstVarNames.
	fields add: '- bytecodes'.
	fields add: '- header'.
	3 to: instVarNames size
	    do: 
		[:x | 
		string := (instVarNames at: x) asString.
		fields add: string].
	lastVar := fields size.
	1 to: self value numLiterals do: [:x | fields add: x printString]
    ]

    currentFieldString [
	<category: 'private'>
	self currentField < 3 ifTrue: [^self currentFieldValue].
	^self currentFieldValue printString
    ]

    references: listView [
	"Open a method set browser on all methods which reference selected key"

	<category: 'variable list menu'>
	currentField isNil ifTrue: [^listView beep].
	currentField <= lastVar ifTrue: [^listView beep].
	MethodSetBrowser 
	    referencesTo: (self value literalAt: currentField - lastVar)
	    parent: listView
    ]
]



CompiledCode extend [

    inspectorFieldLists [
	"Open a MethodInspectorFieldList window on self"

	<category: 'debugging'>
	^{'Basic' -> (BLOX.BLOXBrowser.MethodInspectorFieldList new value: self)}
    ]

]

