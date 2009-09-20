XMLPullParserTest subclass: XMLParserTest [
    
    <comment: nil>
    <category: 'ExpatPullParser'>

    parserOn: source [
	<category: 'instance creation'>
	| pull |
	pull := XMLParser pullParserOn: source readStream.
	pull validate: false.
	^pull
    ]
]



