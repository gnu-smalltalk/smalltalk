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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"

InspectorFieldList subclass:  #CCompoundInspectorFieldList
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

CCompoundInspectorFieldList comment:
nil!

!CCompoundInspectorFieldList methodsFor: 'accessing'!

currentField: assoc 
    "Set list selection to value of index.  Force a text view update"

    assoc key == 0 
	ifTrue: [currentField := 0]
	ifFalse: [currentField := (fields at: assoc key) value]! !

!CCompoundInspectorFieldList methodsFor: 'initializing'!

inspectMenu: listView 
    "Initialize menu for variable list pane"

    ^(PopupMenu new: listView label: 'Field') 
	selectors: #(#('Inspect' #evalAndInspectResult: #listView))
	receiver: self
	argument: listView! !

!CCompoundInspectorFieldList methodsFor: 'private'!

currentFieldValue: obj 
    "Cannot change!"

    !

currentFieldValue
    currentField == 0 ifTrue: [^nil].
    ^(self value perform: currentField asSymbol) value!

computeFieldList: anObject 
    "Initialize instance variable, fields, which governs display of
     variable list pane."

    self value inspectSelectorList 
	do: [:aKey | fields add: (Association key: aKey asString value: aKey)]! !


!CCompound methodsFor: 'debugging'!

inspectorFieldLists
    "Open a CCompoundInspectorFieldList window on self"
    ^{ 'Basic' -> BLOX.BLOXBrowser.CCompoundInspectorFieldList new value: self }
! !
