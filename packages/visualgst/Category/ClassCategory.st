Object subclass: ClassCategory [
    | categories classes name namespace parent |

    <category: 'Language-Implementation'>

    ClassCategory class [ | uniqueInstance icon | ]

    ClassCategory class >> icon [
	<category: '*VisualGST'>
	
	^ icon ifNil: [ icon := GTK.GdkPixbuf newFromFile: ((PackageLoader packageAt: 'VisualGST') / 'Icons/category.gif') file displayString error: nil ]
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

    ClassCategory class >> uniqueInstance [
	<category: 'accessing'>

	^ uniqueInstance ifNil: [ uniqueInstance := self basicNew ]
    ]

    ClassCategory class >> initialize [
	<category: 'initialize'>

	self extractCategory: Class
    ]

    ClassCategory class >> extractCategory: aClass [
	<category: 'extraction'>

	self extractCategory: aClass for: self uniqueInstance.
	aClass subclassesDo: [ :each |
	    self extractCategory: each ]
    ]

    ClassCategory class >> extractCategory: aClass for: aParentCategory [
        <category: 'extraction'>

	self extractCategory: aClass for: aParentCategory into: nil
    ]

    ClassCategory class >> extractCategory: aClass for: aParentCategory into: aNamespace [
        <category: 'extraction'>

        | category subcat token |
        token := aClass category ifNil: [ #() ] ifNotNil: [ aClass category tokenize: '-' ].
        category := aParentCategory.
        token do: [ :each |
            category at: each ifAbsentPut: [ self named: each parent: category namespace: aNamespace ].
            category := category at: each ].
        category classes add: aClass asClass
    ]

    at: aString ifAbsentPut: aBlock [
    
	^ self at: aString ifAbsent: [ self at: aString put: aBlock value ]
    ]

    at: aString put: aCategory [
        <category: 'accessing'>

	self categories at: aString put: aCategory.
	VisualGST.SystemChangeNotifier root classCategoryAdded: aCategory.
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

    childrenNamespace: aNamespace [
        <category: 'accessing'>

	self namespace: aNamespace.
	self values do: [ :each | each childrenNamespace: aNamespace ]
    ]

    category [
        <category: 'accessing'>

        ^ self
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
	VisualGST.SystemChangeNotifier root classCategoryRemoved: aCategory.
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

    isRoot [
	<category: 'testing'>

	^ self parent isNil and: [ self name isEmpty]
    ]

    icon [
	<category: '*VisualGST'>

	^ self class icon
    ]
]
