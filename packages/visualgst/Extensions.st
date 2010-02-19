Object extend [

    gtkInspect [
	"Open a GtkInspector on self"
	<category: '*VisualGST'>

	VisualGST.GtkInspector openOn: self
    ]

    inspectorView [
	<category: '*VisualGST'>

	^ VisualGST.GtkObjectInspectorView
    ]

    hasLiterals [
	<category: '*VisualGST'>

	^ false
    ]
]

SequenceableCollection extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkSequenceableCollectionInspectorView
    ]
]

Character extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkCharacterInspectorView
    ]
]

Integer extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkIntegerInspectorView
    ]
]

Float extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkFloatInspectorView
    ]
]

Symbol extend [
    hasLiterals [
	<category: '*VisualGST'>

	^ true
    ]

    symbolFromliterals [
	<category: '*VisualGST'>

	^ {self}
    ]
]

Array extend [
    hasLiterals [
	<category: '*VisualGST'>

	self do: [ :each |
	    each hasLiterals ifTrue: [ ^ true ] ].
	^ false
    ]

    symbolFromliterals [
        <category: '*VisualGST'>

	| result |
	result := OrderedCollection new.
	self do: [ :each |
	    each hasLiterals ifTrue: [ result add: each symbolFromliterals first ] ].
        ^ result
    ]
]

Class extend [

    subclass: classNameString environment: aNamespace [
	<category: '*VisualGST'>

        "Define a subclass of the receiver with the given name.  If the class
	 is already defined, don't modify its instance or class variables
         but still, if necessary, recompile everything needed."

	| meta |
	KernelInitialized ifFalse: [^Smalltalk at: classNameString].
	meta := self metaclassFor: classNameString.
	^ meta 
	    name: classNameString
	    environment: aNamespace
	    subclassOf: self
    ]
]

CompiledCode extend [

    hasLiterals [
	<category: '*VisualGST'>

	^ self literals isEmpty not
    ]

    isSendingWithSpecialSelector: aByteCode [
	<category: '*VisualGST'>

	^ aByteCode <= 31
    ]

    specialSelectorSended: aByteCode and: anOperand [
	<category: '*VisualGST'>

	(self isSendingWithSpecialSelector: aByteCode) ifFalse: [ ^ self error: 'bad byte code' ].
	aByteCode <= 26 ifTrue: [ ^ self class specialSelectors at: aByteCode + 1 ].
        (aByteCode = 30 or: [ aByteCode = 31 ]) ifTrue: [ ^ self class specialSelectors at: anOperand + 1 ].
    ]

    extractSpecialSelectors [
	<category: '*VisualGST'>

	| result |
	result := Set new.
        self allByteCodeIndicesDo: [ :i :bytecode :operand |
	    (self isSendingWithSpecialSelector: bytecode) ifTrue: [
		result add: (self specialSelectorSended: bytecode and: operand) ] ].
	^ result
    ]

    literalsAndSpecialSelectors [
	<category: '*VisualGST'>

	"Answer whether the receiver refers to the given object"

        | result |
	result := Set new.
	self literalsDo: [ :each |
	    each hasLiterals ifTrue: [ result addAll: each symbolFromliterals ] ].

        ^ result + self extractSpecialSelectors
    ]

    literalsAndSpecialSelectorsDo: aOneArgBlock [
	<category: '*VisualGST'>

	self literalsAndSpecialSelectors do: aOneArgBlock
    ]

]

CompiledBlock extend [
    symbolFromliterals [
	<category: '*VisualGST'>

	^ self extractSpecialSelectors
    ]
]

MethodContext extend [
    variables [
        <category: '*VisualGST'>

        | variables method |
        method := self method method parserClass parseMethod: self method method methodSourceString onError: [ :aString :position | ^ variables:= #() ].
        (variables := method argumentNames asOrderedCollection) addAll: method body temporaryNames.
        ^ variables
    ]
]

BlockContext extend [
    variables [
        <category: '*VisualGST'>

        | variables method |
        method := self method method parserClass parseMethod: self method method methodSourceString.
        variables := method argumentNames,  method body temporaryNames.
        ^ variables
    ]
]

ContextPart extend [
    parentContextAt: anInteger [
	<category: '*VisualGST'>

	| ctxt i |
	anInteger <= 0 ifTrue: [ self error: 'Error indice <= 0' ].
	self parentContext ifNil: [ self error: 'Error indice too high' ].
	anInteger = 1 ifTrue: [ ^ self ].
	i := 2.
	ctxt := self parentContext.
	[ i < anInteger and: [ ctxt parentContext isNil not ] ] whileTrue: [
	    ctxt := ctxt parentContext.
	    i := i + 1 ].
	^ i = anInteger 
	    ifTrue: [ ctxt ]
	    ifFalse: [ self error: 'Error indice too high' ]
    ]

    variables [
	<category: '*VisualGST'>

	^ 1 to: self numArgs + self numTemps collect: [ :each |
	    each displayString ]
    ]

    variablesDo: aBlock [
	<category: '*VisualGST'>

	^ self variables do: aBlock
    ]

    stackInspectorView [
        <category: '*VisualGST'>

        ^ GtkStackInspectorView
    ]
]

Debugger extend [

    receiver [
	<category: '*VisualGST'>

	^ self suspendedContext receiver
    ]

    myStepInto [
        "Run to the end of the current line in the inferior process or to the
         next message send."

	"TODO: Stop when affectation (get the current bytecode)"
        <category: '*VisualGST'>
        | context |
        context := self suspendedContext.

        [ self stepBytecode.
          self suspendedContext == context ]
                whileTrue
    ]

    myStep [
        "Run to the end of the current line in the inferior process, skipping
         over message sends."

	"TODO: Stop when affectation (get the current bytecode)"
        <category: '*VisualGST'>
        | context |
        context := self suspendedContext.

        [ self stepBytecode.
         (self suspendedContext notNil and: [ self suspendedContext parentContext == context ])
                ifTrue: [ self finish: self suspendedContext. ^ self ].
         self suspendedContext == context ]
                whileTrue
    ]
]

Behavior extend [

    debuggerClass [
	<category: '*VisualGST'>

	^ VisualGST.GtkDebugger
    ]
]

VariableBinding extend [

    hasLiterals [
	<category: '*VisualGST'>

	^ true
    ]

    symbolFromliterals [
	<category: '*VisualGST'>

	^ {self key}
    ]
]

Metaclass extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self instanceClass name
    ]
]

AbstractNamespace extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self displayString asSymbol
    ]
]

Symbol extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self
    ]
]

GTK.GtkDialog extend [
    showModal [
        <category: '*VisualGST'>

        self
            setModal: true;
            showAll 
    ]

    showModalOnAnswer: aBlock [
        <category: '*VisualGST'>

        self
            setModal: true;
            connectSignal: 'response' to: aBlock selector: #cull:cull:;
            showAll 
    ]
    
    showModalDestroy [
        <category: '*VisualGST'>

        self
            setModal: true;
            connectSignal: 'response' to: self selector: #destroy;
            showAll 
    ]

    showOnAnswer: aBlock [
        <category: '*VisualGST'>

        self
            setModal: false;
            connectSignal: 'response' to: aBlock selector: #cull:cull:;
            showAll 
    ]
]
