GtkNamespaceModel subclass: GtkCategorizedNamespaceModel [
    | categoryIcon model namespaceIcon |

    GtkCategorizedNamespaceModel class >> displayedNamespaceColumn [
        <category: 'accessing'>

        ^ 1 
    ]

    GtkCategorizedNamespaceModel class >> namespaceColumn [
        <category: 'accessing'>

        ^ 2
    ]

    GtkCategorizedNamespaceModel class >> categoryColumn [
        <category: 'accessing'>

        ^ 3
    ]

    initialize [
	<category: 'initialize-release'>

	| package |
	package := PackageLoader packageAt: 'VisualGST'.
	categoryIcon := GTK.GdkPixbuf newFromFile: (package / 'Icons/category.png') file displayString error: nil.
	namespaceIcon := GTK.GdkPixbuf newFromFile: (package / 'Icons/namespace.png') file displayString error: nil.
	super initialize.
    ]

    registerNotifier [
	<category: 'initialize-release'>

	super registerNotifier.
	(VisualGST uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedClassEvent:'
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: 4 varargs: {GTK.GdkPixbuf getType. GTK.GValue gTypeString. GTK.GLib oopType. GTK.GValue gTypeString} ]
    ]

    appendNamespace: aNamespace to: parentGtkIter [
	<category: 'model builder'>

	| iter |
	iter := self gtkModel append: parentGtkIter item: {namespaceIcon. aNamespace displayString. aNamespace. 'N'}.

	(aNamespace subspaces collect: [ :each | each name ]) asSortedCollection
	    do: [ :each | self appendNamespace: (aNamespace at: each) to: iter ].
	self appendCategoriesOf: aNamespace into: iter.
    ]

    appendCategoriesOf: aNamespace into: aGtkIter [
	<category: 'model builder'>

	| classes |
	classes := aNamespace definedKeys.
	classes := classes select: [ :each | (aNamespace at: each) isClass ].
	(classes collect: [ :each | (aNamespace at: each) category ])
	    asSortedCollection
		do: [ :each | self appendCategory: each for: aNamespace into: aGtkIter ]
    ]

    appendCategory: aString for: aNamespace into: aGtkIter [
        <category: 'model builder'>

	| iter token |
        token := aString ifNil: [ #() ] ifNotNil: [ aString tokenize: '-' ].
	token isEmpty ifTrue: [^self].
	"(token size = 1 and: [ token first = aNamespace name asString ]) ifTrue: [ ^self ]."

        token inject: aGtkIter into: [ :iter :item |
            | result |
            (self findIterInACategory: item parent: iter)
                ifNil: [ self gtkModel append: iter item: {categoryIcon. item. nil. 'C'} ] ]
    ]

    findIterInACategory: aString parent: aGtkIter [
        <category: 'item selection'>

        | iter path |
        iter := GTK.GtkTreeIter new.
        path := self gtkModel getPath: aGtkIter.
	path down.
	(self gtkModel getIter: iter path: path) ifFalse: [ ^ nil ].
	[ aString = (self gtkModel getOop: iter column: self class displayedNamespaceColumn) 
	    and: [ 'C' = (self gtkModel getOop: iter column: self class categoryColumn) ] ] whileFalse: [
	  path next.
	  (self gtkModel getIter: iter path: path) ifFalse: [ ^ nil ] ].
        ^ iter
    ]

    findIterInANamespace: aNamespace [
        <category: 'item selection'>

	self gtkModel itersDo: [ :iter |
	    (self gtkModel at: iter column: self class namespaceColumn) = aNamespace ifTrue: [ ^ iter ] ].

	^ self error: 'Namespace ', aNamespace displayString , ' not found'
    ]

    addEvent: anEvent [
	<category: 'model event'>

	self appendNamespace: anEvent item to: (self findIterInANamespace: anEvent item superspace)
    ]

    isIterNamespace: aGtkIter [
        <category: 'iter accessing'>

	^ 'N' = (self gtkModel getOop: aGtkIter column: self class categoryColumn)
    ]

    recategorizedClassEvent: anEvent [
	<category: 'model event'>

	| iter namespace |
	namespace := anEvent item environment.
        iter := self findIterInANamespace: namespace.
	self appendCategory: anEvent item category for: namespace into: iter
    ]

]

