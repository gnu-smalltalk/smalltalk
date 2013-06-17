"======================================================================
|
| WorkspaceVariableTracker class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

STInST.STInST.RBProgramNodeVisitor subclass: WorkspaceVariableTracker [
    | keyword class |

    initialize [
        <category: 'initialization'>

        keyword := #('self' 'super' 'true' 'false' 'nil' 'thisContext') asSet.
	class := (Behavior new)
                    superclass: Object;
                    yourself
    ]

    objectClass [
        <category: 'accessing'>

        ^ class
    ]

    includesVariable: aString [
        <category: 'operation'>

        ^ aString first isUppercase or: [ (keyword includes: aString) or: [ class allInstVarNames includes: aString asSymbol ] ]
    ]

    defineVariable: aString [
        <category: 'operation'>

        class addInstVarName: aString
    ]

    removeVariable: aString [
	<category: 'operation'>

        class removeInstVarName: aString
    ]

    checkAndAdd: aString [
	<category: 'operation'>

        (self includesVariable: aString)
            ifFalse: [ self defineVariable: aString ].
    ]

    acceptAssignmentNode: anRBAssignmentNode [
        <category: 'operation'>

	self checkAndAdd: anRBAssignmentNode variable name.
        self visitNode: anRBAssignmentNode value
    ]

    acceptVariableNode: anRBVariableNode [
        <category: 'operation'>

	self checkAndAdd: anRBVariableNode name
    ]

]
