AbstractNamespace class extend [
    Icon := nil.
    Categories := nil.

    categories [
        <category: '*VisualGST'>

        ^ Categories ifNil: [ Categories := WeakKeyIdentityDictionary new ]
    ]

    icon [
        <category: '*VisualGST'>

        ^ Icon ifNil: [ Icon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/namespace.gif') file displayString error: nil ]
    ]

    icon: aGdkPixbuf [
        <category: '*VisualGST'>

        Icon := aGdkPixbuf
    ]
]

AbstractNamespace extend [

    namespace [
	<category: 'accessing'>

	^ self
    ]

    category [
	<category: 'accessing'>

	^ VisualGST.ClassCategory basicNew
    ]

    categories [
	<category: 'accessing'>

        ^ self class categories at: self
            ifAbsentPut: [ VisualGST.ClassCategory for: self ]
    ]

    icon [
        <category: '*VisualGST'>

        ^ self class icon
    ]

    isCategory [
	<category: 'testing'>

	^ false
    ]
]

