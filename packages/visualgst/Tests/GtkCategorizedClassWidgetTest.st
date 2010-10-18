TestCase subclass: GtkCategorizedClassWidgetTest [

    | changed |

    classChanged [

        changed := true
    ]

    testModelBuilding [
        <category: 'testing'>

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''
    ]

    testState [
        <category: 'testing'>

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: nil category: ''.
	self assert: class state namespace isNil.
	self assert: class state classOrMeta isNil.
	self assert: class state category isNil.
	self assert: class state method isNil.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''.
        self assert: class state namespace == Kernel.
        self assert: class state classCategory fullname = ''.
	self assert: class state classOrMeta isNil.
        self assert: class state category isNil.
        self assert: class state method isNil.
	class selectAClass: Kernel.CollectingStream class.
        self assert: class state namespace == Kernel.
        self assert: class state classCategory fullname = 'Examples-Useful tools'.
        self assert: class state classOrMeta == Kernel.CollectingStream.
        self assert: class state category isNil.
        self assert: class state method isNil
    ]

    testSelectionEvents [

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''.
        self assert: class hasSelectedClass not.
        self should: [ class selectedClass ] raise: Error.
	class selectAClass: Kernel.CollectingStream class.
        self assert: class hasSelectedClass.
        self assert: class selectedClass == Kernel.CollectingStream
    ]

    testConnectionEvents [

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: '';
            whenSelectionChangedSend: #classChanged to: self;
            selectAClass: Kernel.CollectingStream class.
        self assert: changed
    ]
]

