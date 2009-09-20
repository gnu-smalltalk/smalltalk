"======================================================================
|
|   SAX event-based pull parser testcases
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2009, Antony Blakey
| All rights reserved.
| 
| Redistribution and use in source and binary forms, with or without
| modification, are permitted provided that the following conditions
| are met:
|     * Redistributions of source code must retain the above copyright
|       notice, this list of conditions and the following disclaimer.
|     * Redistributions in binary form must reproduce the above copyright
|       notice, this list of conditions and the following disclaimer in the
|       documentation and/or other materials provided with the distribution.
|     * Neither the name of Antony Blakey nor the names of its contributors
|       may be used to endorse or promote products derived derived from
|       this software without specific prior written permission.
| 
| THIS SOFTWARE IS PROVIDED 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES,
| INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
| AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
| ANTONY BLAKEY BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
| SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
| TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
| PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
| LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
| NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
| SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|
 ======================================================================"


TestCase subclass: XMLPullParserTest [
    
    <comment: nil>
    <category: 'XMLPullParser'>

    parserOn: source [
	<category: 'instance creation'>
	| pull |
	pull := XMLPullParser onString: source.
	pull validate: false.
	^pull
    ]

    testCDATA [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<document><![CDATA[This is a test & stuff in here doesn''t have to be escaped]]></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: parser next isText.
	self assert: parser text 
		    = 'This is a test & stuff in here doesn''t have to be escaped'.
	self assert: (parser isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testCDATAEvents [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<document>This is a test <![CDATA[& stuff in here doesn''t have to be escaped]]></document>'.
	parser needCdataDelimiters: true.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: parser next isText.
	self assert: parser text = 'This is a test '.
	self assert: parser isStartCdataSection.
	self assert: parser next isText.
	self assert: parser text = '& stuff in here doesn''t have to be escaped'.
	self assert: parser isEndCdataSection.
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testCharacterReferences [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<document><name>&#35;&#40;&amp;&#41;</name></document>'.
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
	parser := self parserOn: '<document><body></body></document>'.
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
	    parser := self parserOn: ''.
	    self assert: parser isStartDocument.
	    self assert: parser next isEndDocument
	] on: EmptySignal do: [ :ex | ex resume ]
    ]

    testEscapes [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<tag>Escaped &amp; Unescaped: &lt;&gt;</tag>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'tag').
	self assert: parser next isText.
	self assert: parser text = 'Escaped & Unescaped: <>'.
	self assert: parser next isEndDocument
    ]

    testPerson [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '
<person id="27"><!-- Comment
--><name>Kent Beck</name><notedFor>XP</notedFor></person>'.
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

    testComments [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '
<a><!-- Comment 1 --><!-- Comment 2 --><b/><!-- Another comment --><c/></a>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'a').
	parser needComments: true.
	self assert: parser next isComment.
	self assert: parser next isComment.
	self assert: (parser next isStartTag: 'b').
	parser skip: 'b'.

	"Test that #needComments: works even if #skip: did lookahead."
	parser needComments: false.
	self assert: (parser next isStartTag: 'c').

    ]

    testPI [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<?xml version="1.0"?><?xsl stylesheet="a"?><test />'.
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
	parser := self parserOn: '<selfClose />'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'selfClose').
	self assert: parser next isEndTag.
	self assert: parser next isEndDocument
    ]

    testSingleTag [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<document><body></body></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isStartTag: 'body').
	self assert: (parser next isEndTag: 'body').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testDTDSkip [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<!DOCTYPE name [
<!NOTATION nblah PUBLIC "foo">
<!ENTITY blah SYSTEM "" NDATA nblah>
]><document/>'.
	self assert: parser isStartDocument.
	self assert: parser next isStartDoctypeDecl.
	self assert: parser doctypeName = 'name'.
	self assert: (parser isStartTag: 'document').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testDTDEvents [
	<category: 'testing'>
	| parser |
	parser := self parserOn: '<!DOCTYPE test [
<!NOTATION nblah PUBLIC "foo">
<!ENTITY blah SYSTEM "" NDATA nblah>
]><document/>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartDoctypeDecl: 'test').
	self assert: parser next isNotationDecl.
	self assert: parser current name = 'nblah'.
	self assert: parser current publicID = 'foo'.
	self assert: parser current systemID isNil.
	self assert: parser next isUnparsedEntityDecl.
	self assert: parser current publicID isNil.
	self assert: parser current systemID isEmpty.
	self assert: parser current notationName = 'nblah'.
	self assert: parser next isEndDoctypeDecl.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
    ]

    testResolveEntity [
	<category: 'testing'>
	| parser |
	[
	    parser := self parserOn: '<!DOCTYPE test [
<!ENTITY blah PUBLIC "bar" "foo://">
]><document>&blah;</document>'.
	    parser needDTDEvents: false.
	    self assert: parser isStartDocument.
	    self assert: (parser next isStartTag: 'document').
	    self assert: (parser next isText).
	    self assert: (parser current text = 'bar').
	    self assert: (parser next isEndTag: 'document').
	    self assert: parser next isEndDocument
	]
	    on: XMLResolveEntityNotification
	    do: [ :e |
		e resume: (InputSource
				uri: e systemID
				encoding: ''
				stream: e publicID readStream) ]
    ]
]
