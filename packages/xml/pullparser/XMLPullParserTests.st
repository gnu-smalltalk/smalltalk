XMLPullParser extend [
    XMLPullParser class >> parse: source [
	<category: 'instance creation'>
	| pull |
	pull := self onString: source.
	pull validate: false.
	^pull
    ]
]



TestCase subclass: XMLPullParserTest [
    
    <comment: nil>
    <category: 'XMLPullParser'>

    testCDATA [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser 
		    parse: '<document><![CDATA[This is a test & stuff in here doesn''t have to be escaped]]></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: parser next isText.
	self assert: parser text 
		    = 'This is a test & stuff in here doesn''t have to be escaped'.
	self assert: (parser isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testCharacterReferences [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser 
		    parse: '<document><name>&#35;&#40;&amp;&#41;</name></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isStartTag: 'name').
	self assert: parser next isText.
	self assert: parser text = '#(&)'.
	self assert: (parser isEndTag: 'name').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testDoubleTag [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser parse: '<document><body></body></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isStartTag: 'body').
	self assert: (parser next isEndTag: 'body').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testEmpty [
	<category: 'testing'>
	| parser |
	[
	    parser := XMLPullParser parse: ''.
	    self assert: parser isStartDocument.
	    self assert: parser next isEndDocument
	] on: EmptySignal do: [ :ex | ex resume ]
    ]

    testEscapes [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser 
		    parse: '<tag>Escaped &amp; Unescaped: &lt;&gt;</tag>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'tag').
	self assert: parser next isText.
	self assert: parser text = 'Escaped & Unescaped: <>'.
	self assert: parser next isEndDocument
    ]

    testPerson [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser 
		    parse: '
<person id="27">
	<!-- Comment -->
	<name>Kent Beck</name>
	<notedFor>XP</notedFor>
</person>
'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'person').
	self assert: (parser current attributes at: 'id') = '27'.
	self assert: (parser next isStartTag: 'name').
	self assert: parser next isText.
	self assert: parser text = 'Kent Beck'.
	self assert: (parser next isStartTag: 'notedFor').
	self assert: parser next isText.
	self assert: parser text = 'XP'.
	self assert: (parser next isEndTag: 'person').
	self assert: parser next isEndDocument
    ]

    testPI [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser parse: '<?xml version="1.0"?><?xsl stylesheet="a"?><test />'.
	self assert: parser isStartDocument.
	self assert: (parser next isPI).
	self deny: (parser isPI: 'xml').
	self assert: (parser isPI: 'xsl').
	self assert: (parser current target = 'xsl').
	self assert: (parser current data = 'stylesheet="a"').
	self assert: (parser next isStartTag: 'test').
	self assert: parser next isEndTag.
	self assert: parser next isEndDocument
    ]

    testSingleSelfClosingTag [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser parse: '<selfClose />'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'selfClose').
	self assert: parser next isEndTag.
	self assert: parser next isEndDocument
    ]

    testSingleTag [
	<category: 'testing'>
	| parser |
	parser := XMLPullParser parse: '<document><body></body></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isStartTag: 'body').
	self assert: (parser next isEndTag: 'body').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
    ]
]
