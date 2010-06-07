Object subclass: GtkColumnType [
    | visible title |

    GtkColumnType class >> kind [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    GtkColumnType class >> kindName [
        <category: 'accessing'>

        ^ self subclassResponsibility
    ]

    GtkColumnType class >> cellRenderer [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    GtkColumnType class >> new [
	<category: 'instance creation'>

	^ self error: 'should not call new'
    ]

    GtkColumnType class >> hidden [
        <category: 'instance creation'>

        ^ self basicNew
            initialize;
            yourself
    ]

    GtkColumnType class >> visible [
        <category: 'instance creation'>

        ^ self basicNew
            initialize;
	    visible: true;
            yourself
    ]

    GtkColumnType class >> title: aString [
	<category: 'instance creation'>

	^ self basicNew
	    title: aString;
	    visible: true;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	visible := false
    ]

    kind [
	<category: 'accessing'>

	^ self class kind
    ]

    kindName [
        <category: 'accessing'>

        ^ self class kindName
    ]

    cellRenderer [
        <category: 'accessing'>

        ^ self class cellRenderer
    ]

    visible: aBoolean [
	<category: 'accessing'>

	visible := aBoolean
    ]

    isVisible [
	<category: 'testing'>

	^ visible
    ]

    hasTitle [
	<category: 'testing'>

	^ title isNil not
    ]

    title: aString [
	<category: 'accessing'>

	title := aString
    ]

    title [
	<category: 'accessing'>

	^ title
    ]
]
