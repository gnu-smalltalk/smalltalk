TestCase subclass: GtkMethodWidgetTest [

    | changed |

    methodChanged [

	changed := true
    ]

    testModelBuilding [
	<category: 'testing'>

	| method |
	method := GtkMethodWidget new.
	method mainWidget: method buildTreeView.
	method class: Object withCategory: 'built ins'.
	self assert: method selectedCategory = 'built ins'
    ]

    testState [
        <category: 'testing'>

        | method |
        method := GtkMethodWidget new.
        method mainWidget: method buildTreeView.
        method class: Object withCategory: 'built ins'.
        self assert: method state namespace isNil.
        self assert: method state classOrMeta isNil.
        self assert: method state method isNil.
	method selectAMethod: #'at:'.
        self assert: method state namespace == Smalltalk.
        self assert: method state classOrMeta == Object.
        self assert: method state method == (Object>>#'at:').
    ]

    testSelectionEvents [

        | method |
        method := GtkMethodWidget new.
        method mainWidget: method buildTreeView.
        method class: Object withCategory: 'built ins'.
        self assert: method hasSelectedMethod not.
        self should: [ method selectedMethod ] raise: Error.
        self should: [ method sourceCode ] raise: Error.
	method selectAMethod: #'at:'.
        self assert: method hasSelectedMethod.
        self assert: method selectedMethod == (Object>>#'at:').
        self assert: method sourceCode = (Object>>#'at:') methodRecompilationSourceString.
    ]

    testConnectionEvents [

        | method |
        method := GtkMethodWidget new.
        method 
	    mainWidget: method buildTreeView;
	    whenSelectionChangedSend: #methodChanged to: self;
	    class: Object withCategory: 'built ins';
	    selectAMethod: #'at:'.
        self assert: changed
    ]
]

