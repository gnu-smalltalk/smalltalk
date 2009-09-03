STInST.STInST.RBProgramNodeVisitor subclass: WorkspaceVariableTracker [
    | vars class |

    initialize [
        <category: 'initialization'>

        vars := #('self' 'super' 'true' 'false' 'nil' 'thisContext') asSet.
	class := (Behavior new)
                    superclass: Object;
                    yourself
    ]

    objectClass [
        <category: 'accessing'>

        ^ class
    ]

    variable [
        <category: 'accessing'>

        ^ vars
    ]

    includesVariable: aString [
        <category: 'operation'>

        ^ aString first isUppercase or: [ self variable includes: aString ]
    ]

    defineVariable: aString [
        <category: 'operation'>

        self variable add: aString.
        class addInstVarName: aString
    ]

    acceptAssignmentNode: anRBAssignmentNode [
        <category: 'operation'>

        (self includesVariable: anRBAssignmentNode variable name)
            ifFalse: [ self defineVariable: anRBAssignmentNode variable name ].
        self visitNode: anRBAssignmentNode value
    ]
]
