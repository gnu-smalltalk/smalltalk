Object subclass: Project [
    | authors licence name namespace workspace |

    addAuthor: anAuthor [
	<category: 'accessing'>

	self authors add: anAuthor
    ]

    authors [
	<category: 'accessing'>

	^ authors ifNil: [ authors := OrderedCollection new ]
    ]

    licence: aLicence [
	<category: 'accessing'>

	licence := aLicence
    ]

    licence [
	<category: 'accessing'>

	^ licence
    ]

    name: aString [
	<category: 'accessing'>

	name := aString
    ]

    name [
	<category: 'accessing'>

	^ name
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace
    ]

    namespace [
	<category: 'accessing'>

	^ namespace
    ]

    workspace: aPath [
	<category: 'accessing'>

	workspace := aPath
    ]

    workspace [
	<category: 'accessing'>

	^ workspace
    ]
]

