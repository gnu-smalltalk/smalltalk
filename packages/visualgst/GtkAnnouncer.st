Announcer subclass: GtkAnnouncer [
    
    <category: 'VisualGST'>
    <comment: nil>
    
    GtkAnnouncer class [
	| current |

	current [
	    <category: 'accessing'>
	    ^current ifNil: [current := super new]
	]

	new [
	    <category: 'instance creation'>
	    self shouldNotImplement
	]
    ]
]
