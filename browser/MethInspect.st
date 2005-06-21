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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"

InspectorFieldList subclass:  #MethodInspectorFieldList
	instanceVariableNames: 'lastVar '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

MethodInspectorFieldList comment: 
nil!

!MethodInspectorFieldList methodsFor: 'initializing'!

inspectMenu: listView 
    "Initialize menu for variable list pane"

    ^(PopupMenu new: listView label: nil) 
	selectors: #(#('Inspect' #evalAndInspectResult: #listView) #('References' #references: #listView))
	receiver: self
	argument: listView! !

!MethodInspectorFieldList methodsFor: 'private'!

currentFieldValue: obj 
    Blox beep!

currentFieldValue
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
	ifFalse: [self value literalAt: self currentField - lastVar]!

computeFieldList: anObject 
    "Initialize instance variable, fields, which governs display of
     variable list pane."

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
    1 to: self value numLiterals do: [:x | fields add: x printString]!

currentFieldString

    self currentField < 3 ifTrue: [^self currentFieldValue].
    ^self currentFieldValue printString
! !

!MethodInspectorFieldList methodsFor: 'variable list menu'!

references: listView 
    "Open a method set browser on all methods which reference selected key"

    currentField isNil ifTrue: [^listView beep].
    currentField <= lastVar ifTrue: [^listView beep].
    MethodSetBrowser
	referencesTo: (self value literalAt: currentField - lastVar)
	parent: listView
! !


!CompiledCode methodsFor: 'debugging'!

inspectorFieldLists
    "Open a MethodInspectorFieldList window on self"
    ^{ 'Basic' -> (BLOX.BLOXBrowser.MethodInspectorFieldList new value: self) }
! !
