Object subclass: Licence [
    | name shortDescription description url |

    Licence class >> name: aString shortDescription: aString2 description: aString3 url: aString4 [
	<category: 'instance creation'>

	^ self new
	    name: aString;
	    shortDescription: aString2;
	    description: aString3;
	    url: aString4
    ]

    name [
	<category: 'accessing'>

	^ name
    ]

    name: aString [
	<category: 'accessing'>

	name := aString
    ]

    shortDescription [
	<category: 'accessing'>

	^ shortDescription
    ]

    shortDescription: aString [
	<category: 'accessing'>

	shortDescription := aString
    ]

    description [
	<category: 'accessing'>

	^ description
    ]

    description: aString [
	<category: 'accessing'>

	description := aString
    ]

    url [
	<category: 'accessing'>

	^ url
    ]

    url: aString [
	<category: 'accessing'>

	url := aString
    ]
]

