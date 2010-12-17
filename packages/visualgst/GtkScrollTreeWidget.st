GtkConcreteWidget subclass: GtkScrollTreeWidget [

    GtkScrollTreeWidget class >> createListWithModel: anObject [
	<category: 'instance creation'>

	^ self basicNew
		treeView: (GTK.GtkTreeView createListWithModel: anObject);
		initialize;
		yourself
    ]

    GtkScrollTreeWidget class >> createTreeWithModel: anObject [
        <category: 'instance creation'>

        ^ self basicNew
                treeView: (GTK.GtkTreeView createTreeWithModel: anObject);
                initialize;
                yourself
    ]

    | treeView |

    initialize [
	<category:'initialize'>

	popupMenu := [ :value | ].
	self buildTreeView.
	self mainWidget: (GTK.GtkScrolledWindow withChild: self treeView)
    ]

    buildTreeView [
	<category: 'user interface'>

    ]

    treeView: aGtkTreeView [
	<category: 'accessing'>

	treeView := aGtkTreeView.
    ]

    treeView [
	<category: 'accessing'>

	^ treeView
    ]
]

