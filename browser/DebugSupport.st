"======================================================================
|
|   Smalltalk GUI debugger support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================
"

STInST.RBProgramNodeVisitor subclass: #VariableNames
       instanceVariableNames: 'varNames current optimizedBlocks'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
! 

!VariableNames class methodsFor: 'visiting RBSequenceNodes'!

on: aString
    "Parse aString and return a collection of collections of variable
     names.  Each collection corresponds to a site where arguments
     and/or temporaries can be defined (that is, the method and each
     of the non-optimized blocks).  The first, in particular, lists
     arguments and temporaries for the method, the second lists them
     for the first non-optimized block, and so on."

    ^self new
	initialize;
	visitNode: (STInST.RBParser parseMethod: aString);
	varNames! !

!VariableNames methodsFor: 'initializing'!

addScope
    "Add a new collection of variable names."
    varNames add: (current := OrderedCollection new)!

initialize
    optimizedBlocks := 0.
    varNames := OrderedCollection new.
    self addScope! !

!VariableNames methodsFor: 'accessing'!

varNames
    ^varNames!

!VariableNames methodsFor: 'visiting nodes'!

visitArgument: node
    "Found a variable definition.  Record it."
    current addLast: node name!

acceptBlockNode: aBlockNode
    "Check if the block is open-coded.  If not, add an item to
     varNames which will record arguments and temporaries for
     aBlockNode.  If it is open coded, instead, variables are
     added to the current list of variable names."
    | optBlocks |
    optBlocks := optimizedBlocks.
    optimizedBlocks := 0.
    optBlocks > 0
	ifTrue: [ optBlocks := optBlocks - 1 ]
	ifFalse: [ self addScope ].

    super acceptBlockNode: aBlockNode.
    optimizedBlocks := optBlocks!

acceptMessageNode: node
    "Check which of the receiver and arguments are open-coded blocks.
     Before visiting the children of the node, we set optimizedBlocks
     to a number > 0 if we find an open-coded block."

    node receiver isBlock
	ifTrue: [ self checkIfOptimizedBlockClosureMessage: node ].

    self visitNode: node receiver.

    self checkIfOptimizedTest: node.

    node arguments do: [:each | 
	each isBlock ifTrue: [
	    self checkIfOptimizedToDo: node.
	].
	self visitNode: each]!

checkIfOptimizedToDo: node
    "Increase optimizedBlocks if node is an open-coded #to:do:,
     #timesRepeat: or #to:by:do: message send."

    (node selector == #to:do: or: [ node selector == #timesRepeat: 
	or: [ node selector == #to:by:do:
		and: [ (node arguments at: 2) isLiteral ]]])
		    ifFalse: [ ^self ].

    (self isOptimizedBlockClosure: node arguments last args: 1)
	ifFalse: [ ^self ].

    optimizedBlocks := optimizedBlocks + 1!

isOptimizedBlockClosure: block args: numArgs
    "Answer whether block is an RBBlockNode with no temporaries and
     numArgs arguments."

    ^block isBlock and: [ block body temporaries isEmpty and: [
	block arguments size = numArgs ]]!

checkIfOptimizedTest: node
    "Increase optimizedBlocks if node is an open-coded Boolean test."

    (#(#ifTrue: #ifTrue:ifFalse: #ifFalse:ifTrue: #ifFalse: #and: #or:)
	includes: node selector) ifFalse: [ ^self ].

    (node arguments allSatisfy: [ :each |
        self isOptimizedBlockClosure: each args: 0 ])
            ifFalse: [ ^self ].

    optimizedBlocks := optimizedBlocks + node arguments size!

checkIfOptimizedBlockClosureMessage: node
    "Increase optimizedBlocks if node is an open-coded while loop."

    (#(#whileTrue #whileTrue: #whileFalse #whileFalse: #repeat)
	includes: node selector) ifFalse: [ ^self ].

    (self isOptimizedBlockClosure: node receiver args: 0)
	ifFalse: [ ^self ].

    (node arguments allSatisfy: [ :each |
	self isOptimizedBlockClosure: each args: 0 ])
	    ifFalse: [ ^self ].

    optimizedBlocks := optimizedBlocks + node arguments size + 1! !

!ContextPart methodsFor: 'debugging'!

variableNames
    ^self method variableNames! !

!CompiledCode methodsFor: 'debugging'!

variableNames
    "Answer the names of the arguments and temporaries in the receiver.
     By default, only numbers are produced."
    ^(1 to: self numArgs + self numTemps)
	collect: [ :each | each printString ]! !

!CompiledMethod methodsFor: 'debugging'!

variableNames
    "Answer the names of the arguments and temporaries in the receiver."
    | source |
    source := self methodSourceString.
    source isNil ifTrue: [ ^super variableNames ].
    ^(BLOX.BLOXBrowser.VariableNames on: source) at: 1!

!CompiledBlock methodsFor: 'debugging'!

variableNames
    "Answer the names of the arguments and temporaries in the receiver."
    | source index |
    self numArgs + self numTemps = 0 ifTrue: [ ^#() ].

    source := self methodSourceString.
    source isNil ifTrue: [ ^super variableNames ].

    "Find how many blocks are there in the method before the receiver."
    index := 2.
    self literals keysAndValuesDo: [ :i :each |
	each class == BlockClosure ifTrue: [
	    each block == self ifTrue: [
	        "Ok, now parse the source code."
		^(BLOX.BLOXBrowser.VariableNames on: source) at: index
	    ].

	    index := index + 1
	]
    ].
    ^super variableNames! !

