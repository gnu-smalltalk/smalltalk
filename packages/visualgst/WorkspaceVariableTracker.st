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
