TestCase subclass: GtkCategorizedNamespaceWidgetTest [

    | changed |

    namespaceChanged [

        changed := true
    ]

    testModelBuilding [
        <category: 'testing'>

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace mainWidget: namespace buildTreeView
    ]

    testState [
        <category: 'testing'>

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace mainWidget: namespace buildTreeView.
        self assert: namespace state namespace isNil.
        self assert: namespace state classOrMeta isNil.
        self assert: namespace state category isNil.
        self assert: namespace state method isNil.
	namespace selectANamespace: Kernel.
        self assert: namespace state namespace == Kernel.
        self assert: namespace state classOrMeta isNil.
        self assert: namespace state category isNil.
        self assert: namespace state method isNil
    ]

    testSelectionEvents [

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace mainWidget: namespace buildTreeView.
        self assert: namespace hasSelectedNamespace not.
        self should: [ namespace selectedNamespace ] raise: Error.
        namespace selectANamespace: Kernel.
        self assert: namespace hasSelectedNamespace.
        self assert: namespace selectedNamespace == Kernel
    ]

    testConnectionEvents [

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace 
	    mainWidget: namespace buildTreeView;
            whenSelectionChangedSend: #namespaceChanged to: self;
	    selectANamespace: Kernel.
        self assert: changed
    ]
]

