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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"



STInST.STInST.RBProgramNodeVisitor subclass: VariableNames [
    | varNames current optimizedBlocks |
    
    <category: 'System-Compiler'>
    <comment: nil>

    VariableNames class >> on: method [
	"Parse aString and return a collection of collections of variable
	 names.  Each collection corresponds to a site where arguments
	 and/or temporaries can be defined (that is, the method and each
	 of the non-optimized blocks).  The first, in particular, lists
	 arguments and temporaries for the method, the second lists them
	 for the first non-optimized block, and so on."

	<category: 'visiting RBSequenceNodes'>
	^(self new)
	    initialize;
	    visitNode: (method parserClass parseMethod: method methodSourceString);
	    varNames
    ]

    addScope [
	"Add a new collection of variable names."

	<category: 'initializing'>
	varNames add: (current := OrderedCollection new)
    ]

    initialize [
	<category: 'initializing'>
	optimizedBlocks := 0.
	varNames := OrderedCollection new.
	self addScope
    ]

    varNames [
	<category: 'accessing'>
	^varNames
    ]

    visitArgument: node [
	"Found a variable definition.  Record it."

	<category: 'visiting nodes'>
	current addLast: node name
    ]

    acceptBlockNode: aBlockNode [
	"Check if the block is open-coded.  If not, add an item to
	 varNames which will record arguments and temporaries for
	 aBlockNode.  If it is open coded, instead, variables are
	 added to the current list of variable names."

	<category: 'visiting nodes'>
	| optBlocks |
	optBlocks := optimizedBlocks.
	optimizedBlocks := 0.
	optBlocks > 0 ifTrue: [optBlocks := optBlocks - 1] ifFalse: [self addScope].
	super acceptBlockNode: aBlockNode.
	optimizedBlocks := optBlocks
    ]

    acceptMessageNode: node [
	"Check which of the receiver and arguments are open-coded blocks.
	 Before visiting the children of the node, we set optimizedBlocks
	 to a number > 0 if we find an open-coded block."

	<category: 'visiting nodes'>
	node receiver isBlock 
	    ifTrue: [self checkIfOptimizedBlockClosureMessage: node].
	self visitNode: node receiver.
	self checkIfOptimizedTest: node.
	node arguments do: 
		[:each | 
		each isBlock ifTrue: [self checkIfOptimizedToDo: node].
		self visitNode: each]
    ]

    checkIfOptimizedToDo: node [
	"Increase optimizedBlocks if node is an open-coded #to:do:,
	 #timesRepeat: or #to:by:do: message send."

	<category: 'visiting nodes'>
	(node selector == #to:do: or: 
		[node selector == #timesRepeat: 
		    or: [node selector == #to:by:do: and: [(node arguments at: 2) isLiteral]]]) 
	    ifFalse: [^self].
	(self isOptimizedBlockClosure: node arguments last args: 1) 
	    ifFalse: [^self].
	optimizedBlocks := optimizedBlocks + 1
    ]

    isOptimizedBlockClosure: block args: numArgs [
	"Answer whether block is an RBBlockNode with no temporaries and
	 numArgs arguments."

	<category: 'visiting nodes'>
	^block isBlock 
	    and: [block body temporaries isEmpty and: [block arguments size = numArgs]]
    ]

    checkIfOptimizedTest: node [
	"Increase optimizedBlocks if node is an open-coded Boolean test."

	<category: 'visiting nodes'>
	(#(#ifTrue: #ifTrue:ifFalse: #ifFalse:ifTrue: #ifFalse: #and: #or:) 
	    includes: node selector) ifFalse: [^self].
	(node arguments 
	    allSatisfy: [:each | self isOptimizedBlockClosure: each args: 0]) 
		ifFalse: [^self].
	optimizedBlocks := optimizedBlocks + node arguments size
    ]

    checkIfOptimizedBlockClosureMessage: node [
	"Increase optimizedBlocks if node is an open-coded while loop."

	<category: 'visiting nodes'>
	(#(#whileTrue #whileTrue: #whileFalse #whileFalse: #repeat) 
	    includes: node selector) ifFalse: [^self].
	(self isOptimizedBlockClosure: node receiver args: 0) ifFalse: [^self].
	(node arguments 
	    allSatisfy: [:each | self isOptimizedBlockClosure: each args: 0]) 
		ifFalse: [^self].
	optimizedBlocks := optimizedBlocks + node arguments size + 1
    ]
]



ContextPart extend [

    variableNames [
	<category: 'debugging'>
	^self method variableNames
    ]

]



CompiledCode extend [

    variableNames [
	"Answer the names of the arguments and temporaries in the receiver.
	 By default, only numbers are produced."

	<category: 'debugging'>
	^(1 to: self numArgs + self numTemps) collect: [:each | each printString]
    ]

]



CompiledMethod extend [

    variableNames [
	"Answer the names of the arguments and temporaries in the receiver."

	<category: 'debugging'>
	| source |
	source := self methodSourceString.
	source isNil ifTrue: [^super variableNames].
	^(BLOX.BLOXBrowser.VariableNames on: self) at: 1
    ]

]



CompiledBlock extend [

    variableNames [
	"Answer the names of the arguments and temporaries in the receiver."

	<category: 'debugging'>
	| source index |
	self numArgs + self numTemps = 0 ifTrue: [^#()].
	source := self methodSourceString.
	source isNil ifTrue: [^super variableNames].

	"Find how many blocks are there in the method before the receiver."
	index := 2.
	self literals keysAndValuesDo: 
		[:i :each | 
		each class == BlockClosure 
		    ifTrue: 
			[each block == self 
			    ifTrue: 
				["Ok, now parse the source code."

				^(BLOX.BLOXBrowser.VariableNames on: self method) at: index].
			index := index + 1]].
	^super variableNames
    ]

]

