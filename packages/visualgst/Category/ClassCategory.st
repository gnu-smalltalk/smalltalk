Object subclass: ClassCategory [
    | categories classes name namespace parent |

    <category: 'Language-Implementation'>

    ClassCategory class [ | icon | ]

    ClassCategory class >> icon [
	<category: '*VisualGST'>
	
	^ icon ifNil: [ icon := GTK.GdkPixbuf newFromFile: (GtkLauncher / 'Icons/category.gif') file displayString error: nil ]
    ]

    ClassCategory class >> icon: aGdkPixbuf [
        <category: '*VisualGST'>

        icon := aGdkPixbuf
    ]

    ClassCategory class >> namespace: aNamespace [
        <category: 'instance creation'>

        ^ self basicNew
		    namespace: aNamespace;
		    yourself
    ]

    ClassCategory class >> named: aString [
	<category: 'instance creation'>

	^ self named: aString parent: nil 
    ]

    ClassCategory class >> named: aString parent: aClassCategory [
        <category: 'instance creation'>

	^ self named: aString parent: aClassCategory namespace: nil 
    ]

    ClassCategory class >> named: aString parent: aClassCategory namespace: aNamespace [
        <category: 'instance creation'>

        ^ self basicNew
                    name: aString;
                    parent: aClassCategory;
		    namespace: aNamespace;
                    yourself
    ]

    ClassCategory class >> for: aNamespace [
	<category: 'instance creation'>

	| category classes |
	category := self namespace: aNamespace.
        classes := aNamespace definedKeys.
        classes do: [ :each | (aNamespace at: each) isClass ifTrue: [ self extractCategory: (aNamespace at: each) for: category into: aNamespace ] ].
	^ category 
    ]

    ClassCategory class >> named: name for: aParentCategory into: aNamespace [
	<category: 'instance creation'>

        | token category |
        token := name ifNil: [ #() ] ifNotNil: [ (name tokenize: '-') asOrderedCollection ].
        category := aParentCategory.
	token isEmpty ifFalse: [ token first = aNamespace name asString ifTrue: [ token removeFirst ] ].
        token do: [ :each |
            category at: each ifAbsentPut: [ self named: each parent: category namespace: aNamespace ].
            category := category at: each ].
        ^category
    ]

    ClassCategory class >> named: name into: aNamespace [
	<category: 'instance creation'>

        ^ self named: name for: aNamespace categories into: aNamespace
    ]

    ClassCategory class >> extractCategory: aClass for: aParentCategory into: aNamespace [
        <category: 'extraction'>

	| cat |
        (cat := (self named: aClass category for: aParentCategory into: aNamespace)) classes add: aClass asClass.
	^ cat
    ]

    ClassCategory class >> extractClassCategory: aClass [
        <category: 'extraction'>

	^ self extractCategory: aClass for: aClass environment categories into: aClass environment
    ]

    = anObject [
        <category: 'testing'>
    
        ^ self class == anObject class and: [
	   self parent == anObject parent and: [
           self namespace == anObject namespace and: [
           self name = anObject name ]]]
    ]

    hash [
        <category: 'testing'>
    
	^ (self parent identityHash
           + self namespace identityHash)
               bitXor: self name hash
    ]

    at: aString ifAbsentPut: aBlock [
        <category: 'accessing'>
    
	^ self at: aString ifAbsent: [ self at: aString put: aBlock value ]
    ]

    at: aString put: aCategory [
        <category: 'accessing'>

	self categories at: aString put: aCategory.
	"SystemChangeNotifier root classCategoryAdded: aCategory."
        ^ aCategory
    ]

    at: aString [
	<category: 'accessing'>

	^ self at: aString ifAbsent: [ SystemExceptions.NotFound signalOn: aString what: 'Category ', aString, ' not found' ]
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>

	^ self categories at: aString ifAbsent: aBlock
    ]

    registerNotifier [
        <category: 'initialize-release'>

        "TODO: do not go through GtkLauncher's notifier
        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'classRecategorizedEvent:'"
    ]

    "classRecategorizedEvent: anEvent [
        <category: 'model event'>

        | namespace oldCat newCat |
        namespace := anEvent item environment.
        oldCat := ClassCategory named: anEvent oldCategory into: namespace.
        oldCat removeClass: anEvent item
    ]"

    initialize [
        <category: 'initialize-release'>

        self registerNotifier
    ]

    values [
	<category: 'accessing'>

	^ self categories values
    ]

    namespace [
        <category: 'accessing'>

        ^ namespace
    ]

    namespace: aNamespace [
        <category: 'accessing'>

        namespace := aNamespace
    ]

    name: aString [
	<category: 'accessing'>

	name := aString
    ]

    name [
	<category: 'accessing'>

	^ name ifNil: [ name := String new ]
    ]

    fullname [
	<category: 'accessing'>

	| r p |
	p := self parent.
	r := self name.
	[ p isNil or: [ p name isEmpty ] ] whileFalse: [ r := p name, '-', r.
	    p := p parent ].
	^ r 
    ]

    parent: aCategory [
	<category: 'category accessing'>

	parent := aCategory
    ]

    parent [
	<category: 'category accessing'>

	^ parent
    ]

    category [
	<category: 'category accessing'>

	^ self
    ]

    removeCategory: aCategory [
	<category: 'category accessing'>

	self at: aCategory name ifAbsent: [ ^ self ].
	aCategory parent: nil.
	self categories removeKey: aCategory name.
	"SystemChangeNotifier root classCategoryRemoved: aCategory."
	(self classes isEmpty and: [ self parent isNil not ]) ifTrue: [ self parent removeCategory: self ]
    ]

    categories [
	<category: 'category accessing'>

	^ categories ifNil: [ categories := Dictionary new ]
    ]
    
    subspaces [
	<category: 'accessing'>

	^ #()
    ]

    classes [
	<category: 'class accessing'>

	^ classes ifNil: [ classes := IdentitySet new ]
    ]

    removeClass: aClass [
	<category: 'class accessing'>

	(self classes includes: aClass) ifFalse: [ ^ self ].
	self classes remove: aClass.
	(self classes isEmpty and: [ self parent isNil not ]) ifTrue: [ self parent removeCategory: self ]
    ]

    isCategory [
	<category: 'testing'>

	^ true
    ]

    isNamespace [
	<category: 'testing'>

	^ false
    ]

    icon [
	<category: '*VisualGST'>

	^ self class icon
    ]
]
