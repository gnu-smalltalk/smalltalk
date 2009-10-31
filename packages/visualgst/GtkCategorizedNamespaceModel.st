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
	(SystemChangeNotifier uniqueInstance)
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedClassEvent:'
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: 4 varargs: {GTK.GdkPixbuf getType. GTK.GValue gTypeString. GTK.GLib oopType. GTK.GValue gTypeString}.
	    self appendNamespace: Smalltalk to: nil.
	    model ]
    ]

    appendNamespace: aNamespace to: parentGtkIter [
	<category: 'model builder'>

	| iter |
	iter := self gtkModel append: parentGtkIter item: {namespaceIcon. aNamespace displayString. aNamespace. 'N'}.

	self appendCategoriesOf: aNamespace into: iter.

	aNamespace subspacesDo: [ :each |
	    self appendNamespace: each to: iter ]
    ]

    appendCategoriesOf: aNamespace into: aGtkIter [
	<category: 'model builder'>

	aNamespace do: [ :each |
	    (each isNil not and: [ each isClass and: [ each environment = aNamespace ] ])
		ifTrue: [ self appendCategoriesOfClass: each into: aGtkIter ] ]
    ]

    appendCategoriesOfClass: aClass into: aGtkIter [
        <category: 'model builder'>

	| i iter token |
        token := aClass category ifNil: [ #() ] ifNotNil: [ aClass category tokenize: '-' ].
        iter := aGtkIter.
        i := 1.
        token do: [ :item |
            | result |
            (item ~= '' and: [ i > 1 or: [ i = 1 and: [ item ~= aClass environment displayString ] ] ]) ifTrue: [
            (result := self findIterInACategory: item parent: iter) 
                        ifNil: [ iter := self gtkModel append: iter item: {categoryIcon. item. nil. 'C'} ] 
                        ifNotNil: [ iter := result ] ].
            i := i + 1 ]
    ]

    findIterInACategory: aString parent: aGtkIter [
        <category: 'item selection'>

        | iter path |
        iter := GTK.GtkTreeIter new.
        path := self gtkModel getPath: aGtkIter.
	path down.
	self gtkModel getIter: iter path: path.
	[ aString = (self gtkModel getOop: iter column: self class displayedNamespaceColumn) 
	    and: [ 'C' = (self gtkModel getOop: iter column: self class categoryColumn) ] ] whileFalse: [
	  path next.
	  (self gtkModel getIter: iter path: path) ifFalse: [ ^ nil ] ].
        ^ iter
    ]

    findIterInANamespace: aNamespace [
        <category: 'item selection'>

	self gtkModel itersDo: [ :iter |
	    (self gtkModel getOop: iter column: self class namespaceColumn) = aNamespace ifTrue: [ ^ iter ] ].

	^ self error: 'Namespace ', aNamespace displayString , ' not found'
    ]

    addEvent: anEvent [
	<category: 'model event'>

	| iter |
	iter := self findIterInANamespace: anEvent item superspace.
	self gtkModel append: iter item: {namespaceIcon. anEvent item displayString. anEvent item. 'N'}
    ]

    recategorizedClassEvent: anEvent [
	<category: 'model event'>

       | iter |
        iter := self findIterInANamespace: anEvent item environment.
	self appendCategoriesOfClass: anEvent item into: iter
    ]

]

