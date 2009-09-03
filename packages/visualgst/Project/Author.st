Object subclass: Author [
    | firstname lastname |

    Author class >> firstname: aString lastname: aString2 [
	<category: 'instance creation'>

	^ self new
	    firstname: aString;
	    lastname: aString2
    ]

    firstname [
	<category: 'accessing'>

	^ firstname
    ]

    firstname: aString [
	<category: 'accessing'>

	firstname := aString
    ]

    lastname [
	<category: 'accessing'>

	^ lastname
    ]

    lastname: aString [
	<category: 'accessing'>

	lastname := aString
    ]
]

