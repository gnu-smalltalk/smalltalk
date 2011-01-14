Announcer subclass: GtkAnnouncer [
    GtkAnnouncer class [ | current | ]

    GtkAnnouncer class >> current [
	<category: 'accessing'>

	^ current ifNil: [ current := super new ]
    ]

    GtkAnnouncer class >> new [
	<category: 'instance creation'>

	self shouldNotImplement
    ]
]
