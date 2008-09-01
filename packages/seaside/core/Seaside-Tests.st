WADynamicVariable subclass: WADemoVariable [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    WADemoVariable class >> defaultValue [
	<category: 'defaults'>
	^'default'
    ]
]



TestCase subclass: ContinuationTest [
    | tmp tmp2 |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    callcc: aBlock [
	<category: 'utilities'>
	^Continuation currentDo: aBlock
    ]

    testBlockEscape [
	<category: 'tests'>
	| x |
	tmp := 0.
	x := 
		[tmp := tmp + 1.
		tmp2 value].
	self callcc: 
		[:cc | 
		tmp2 := cc.
		x value].
	tmp2 := [].
	x value.
	self assert: tmp = 2
    ]

    testBlockTemps [
	<category: 'tests'>
	| y |
	#(1 2 3) do: 
		[:i | 
		| x |
		x := i.
		tmp 
		    ifNil: [tmp2 := self callcc: 
					[:cc | 
					tmp := cc.
					[:q | ]]].
		tmp2 value: x.
		x := 17].
	y := self callcc: 
			[:cc | 
			tmp value: cc.
			42].
	self assert: y = 1
    ]

    testBlockVars [
	<category: 'tests'>
	| continuation |
	tmp := 0.
	tmp := (self callcc: 
			[:cc | 
			continuation := cc.
			0]) + tmp.
	tmp2 ifNotNil: [:foo | tmp2 value]
	    ifNil: 
		[#(1 2 3) 
		    do: [:i | self callcc: 
				[:cc | 
				tmp2 := cc.
				continuation value: i]]].
	self assert: tmp = 6
    ]

    testComprehension [
	"What should this print out?
	 
	 | yin yang |
	 yin := [ :x | Transcript cr. x ] value: Continuation current.
	 yang := [ :x | Transcript nextPut: $*. x ] value: Continuation current.
	 yin value: yang"

	<category: 'tests'>
	
    ]

    testMethodTemps [
	<category: 'tests'>
	| i continuation |
	i := 0.
	i := i + (self callcc: 
				[:cc | 
				continuation := cc.
				1]).
	self assert: i ~= 3.
	i = 2 ifFalse: [continuation value: 2]
    ]

    testReentrant [
	<category: 'tests'>
	| assoc |
	assoc := self callcc: [:cc | cc -> 0].
	assoc value: assoc value + 1.
	self assert: assoc value ~= 5.
	assoc value = 4 ifFalse: [assoc key value: assoc]
    ]

    testSimpleCallCC [
	<category: 'tests'>
	| x continuation |
	x := self callcc: 
			[:cc | 
			continuation := cc.
			false].
	x ifFalse: [continuation value: true].
	self assert: x
    ]

    testSimplestCallCC [
	<category: 'tests'>
	| x |
	x := self callcc: [:cc | cc value: true].
	self assert: x
    ]
]



TestCase subclass: WAAcceptTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assert: anArray at: anInteger language: aLanguageString country: aCountryString quality: aFloat [
	<category: 'private'>
	| value mimeType |
	value := anArray at: anInteger.
	self assert: (value isKindOf: WAQualifiedValue).
	self assert: value quality = aFloat.
	mimeType := value value.
	self assert: (mimeType isKindOf: WALocale).
	self assert: mimeType language = aLanguageString.
	self assert: mimeType country = aCountryString
    ]

    assert: anArray at: anInteger main: aMainString sub: aSubString quality: aFloat [
	<category: 'private'>
	| value mimeType |
	value := anArray at: anInteger.
	self assert: (value isKindOf: WAQualifiedValue).
	self assert: value quality = aFloat.
	mimeType := value value.
	self assert: (mimeType isKindOf: WAMimeType).
	self assert: mimeType main = aMainString.
	self assert: mimeType sub = aSubString
    ]

    testIe6 [
	<category: 'testing'>
	| accept accpetLanguage acceptEncoding |
	accept := WAAccept 
		    fromString: 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/vnd.ms-excel, application/msword, application/vnd.ms-powerpoint, application/x-shockwave-flash, */*'.
	self assert: accept size = 9.
	self 
	    assert: accept
	    at: 1
	    main: 'image'
	    sub: 'gif'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 2
	    main: 'image'
	    sub: 'x-xbitmap'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 3
	    main: 'image'
	    sub: 'jpeg'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 4
	    main: 'image'
	    sub: 'pjpeg'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 5
	    main: 'application'
	    sub: 'vnd.ms-excel'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 6
	    main: 'application'
	    sub: 'msword'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 7
	    main: 'application'
	    sub: 'vnd.ms-powerpoint'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 8
	    main: 'application'
	    sub: 'x-shockwave-flash'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 9
	    main: '*'
	    sub: '*'
	    quality: FloatD infinity.
	acceptEncoding := 'gzip, deflate'.
	accpetLanguage := WAAcceptLanguage fromString: 'de-ch'.
	self assert: accpetLanguage size = 1.
	self 
	    assert: accpetLanguage
	    at: 1
	    language: 'de'
	    country: 'ch'
	    quality: FloatD infinity
    ]

    testMozilla [
	<category: 'testing'>
	| accept accpetLanguage acceptCharset acceptEncoding |
	accept := WAAccept 
		    fromString: 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'.
	self assert: accept size = 7.
	self 
	    assert: accept
	    at: 1
	    main: 'text'
	    sub: 'xml'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 2
	    main: 'application'
	    sub: 'xml'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 3
	    main: 'application'
	    sub: 'xhtml+xml'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 4
	    main: 'text'
	    sub: 'html'
	    quality: 0.9.
	self 
	    assert: accept
	    at: 5
	    main: 'text'
	    sub: 'plain'
	    quality: 0.8.
	self 
	    assert: accept
	    at: 6
	    main: 'image'
	    sub: 'png'
	    quality: FloatD infinity.
	self 
	    assert: accept
	    at: 7
	    main: '*'
	    sub: '*'
	    quality: 0.5.
	acceptCharset := 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'.
	acceptEncoding := 'gzip,deflate'.
	accpetLanguage := WAAcceptLanguage 
		    fromString: 'de-de,de;q=0.8,en-us;q=0.5,en;q=0.3'.
	self assert: accpetLanguage size = 4.
	self 
	    assert: accpetLanguage
	    at: 1
	    language: 'de'
	    country: 'de'
	    quality: FloatD infinity.
	self 
	    assert: accpetLanguage
	    at: 2
	    language: 'de'
	    country: nil
	    quality: 0.8.
	self 
	    assert: accpetLanguage
	    at: 3
	    language: 'en'
	    country: 'us'
	    quality: 0.5.
	self 
	    assert: accpetLanguage
	    at: 4
	    language: 'en'
	    country: nil
	    quality: 0.3
    ]
]



TestCase subclass: WAAttributesTest [
    | attributes |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assert: aBlock gives: aString [
	<category: 'private'>
	| stream |
	aBlock value: (attributes := WAHtmlAttributes new).
	(WAHtmlStreamDocument new)
	    stream: (stream := String new writeStream);
	    print: attributes.
	self 
	    assert: stream contents = aString
	    description: 'Expected ' , aString printString , ', but got ' 
		    , stream contents printString
	    resumable: true
    ]

    setUp [
	<category: 'running'>
	attributes := WAHtmlAttributes new
    ]

    testAddClass [
	<category: 'testing-convenience'>
	self assert: [:attr | attr addClass: 'foo'] gives: ' class="foo"'.
	self assert: 
		[:attr | 
		attr
		    addClass: 'foo';
		    addClass: 'bar']
	    gives: ' class="foo bar"'
    ]

    testAddStyle [
	<category: 'testing-convenience'>
	self assert: [:attr | attr addStyle: 'display: hidden']
	    gives: ' style="display: hidden"'.
	self assert: 
		[:attr | 
		attr
		    addStyle: 'display: hidden';
		    addStyle: 'position: absolute']
	    gives: ' style="display: hidden;position: absolute"'
    ]

    testAt [
	<category: 'testing'>
	attributes at: 'foo' put: 'bar'.
	self assert: (attributes at: 'foo') = 'bar'.
	self assert: (attributes at: 'bar') isNil
    ]

    testAtAppend [
	<category: 'testing'>
	self assert: 
		[:attr | 
		attr 
		    at: 'onclick'
		    append: 'this'
		    separator: ';']
	    gives: ' onclick="this"'.
	self assert: 
		[:attr | 
		attr
		    at: 'onclick'
			append: 'this'
			separator: ';';
		    at: 'onclick'
			append: 'that'
			separator: ';']
	    gives: ' onclick="this;that"'.
	self assert: 
		[:attr | 
		attr
		    at: 'onclick'
			append: 'this'
			separator: ';';
		    at: 'onclick'
			append: nil
			separator: ';']
	    gives: ' onclick="this"'.
	self assert: 
		[:attr | 
		attr
		    at: 'onclick'
			append: 1
			separator: ';';
		    at: 'onclick'
			append: 2
			separator: ';']
	    gives: ' onclick="1;2"'
    ]

    testAtPut [
	<category: 'testing'>
	self assert: [:attr | attr at: 'id' put: 'foo'] gives: ' id="foo"'.
	self assert: [:attr | attr at: 'tabindex' put: 6] gives: ' tabindex="6"'.
	self assert: [:attr | attr at: 'checked' put: true]
	    gives: ' checked="checked"'.
	self assert: [:attr | attr at: 'readonly' put: false] gives: ''.
	self assert: [:attr | attr at: 'disabled' put: nil] gives: ''
    ]

    testCaseSensititve [
	<category: 'testing-fixtures'>
	self 
	    assert: [:attr | attr at: 'lastBuildDate' put: 'Sat, 07 Sep 2002 09:42:31 GMT']
	    gives: ' lastBuildDate="Sat, 07 Sep 2002 09:42:31 GMT"'
    ]

    testOrder [
	<category: 'testing'>
	self assert: 
		[:attr | 
		attr
		    at: 'a' put: 1;
		    at: 'b' put: 2;
		    at: 'c' put: 3]
	    gives: ' a="1" b="2" c="3"'.
	self assert: 
		[:attr | 
		attr
		    at: 'a' put: 1;
		    at: 'b' put: 2;
		    at: 'c' put: 3;
		    at: 'b' put: 4]
	    gives: ' a="1" b="4" c="3"'
    ]

    testRemoveKey [
	<category: 'testing'>
	attributes at: 'id' put: 'foo'.
	self assert: (attributes removeKey: 'id') = 'foo'.
	self assert: (attributes removeKey: 'id') isNil
    ]
]



TestCase subclass: WABacktrackingTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    testArray [
	<category: 'testing'>
	| original snapshot1 snapshot2 snapshot3 |
	original := #(1 2 3) copy.
	snapshot1 := original snapshotCopy.
	original at: 1 put: #a.
	snapshot2 := original snapshotCopy.
	original at: 2 put: #b.
	snapshot3 := original snapshotCopy.
	original restoreFromSnapshot: snapshot1.
	self assert: original = #(1 2 3).
	original restoreFromSnapshot: snapshot2.
	self assert: original = #(#a 2 3).
	original restoreFromSnapshot: snapshot3.
	self assert: original = #(#a #b 3)
    ]

    testBag [
	<category: 'testing'>
	| original snapshot1 snapshot2 snapshot3 |
	original := Bag with: 1 with: 2.
	snapshot1 := original snapshotCopy.
	original add: 3.
	snapshot2 := original snapshotCopy.
	original remove: 1.
	snapshot3 := original snapshotCopy.
	original restoreFromSnapshot: snapshot1.
	self assert: original size = 2.
	self assert: (original includes: 1).
	self assert: (original includes: 2).
	self deny: (original includes: 3).
	original restoreFromSnapshot: snapshot2.
	self assert: original size = 3.
	self assert: (original includes: 1).
	self assert: (original includes: 2).
	self assert: (original includes: 3).
	original restoreFromSnapshot: snapshot3.
	self assert: original size = 2.
	self deny: (original includes: 1).
	self assert: (original includes: 2).
	self assert: (original includes: 3).
	original add: 4.
	original restoreFromSnapshot: snapshot3.
	self assert: original size = 2.
	self deny: (original includes: 1).
	self assert: (original includes: 2).
	self assert: (original includes: 3).
	self deny: (original includes: 4)
    ]

    testDictionary [
	<category: 'testing'>
	| original snapshot1 snapshot2 snapshot3 snapshot4 |
	original := Dictionary new.
	original
	    at: 1 put: #a;
	    at: 2 put: #b.
	snapshot1 := original snapshotCopy.
	original at: 3 put: #c.
	snapshot2 := original snapshotCopy.
	original at: 3 put: #d.
	snapshot3 := original snapshotCopy.
	original removeKey: 1.
	snapshot4 := original snapshotCopy.
	original restoreFromSnapshot: snapshot1.
	self assert: original size = 2.
	self assert: (original at: 1 ifAbsent: []) = #a.
	self assert: (original at: 2 ifAbsent: []) = #b.
	self assert: (original at: 3 ifAbsent: []) = nil.
	self assert: (original at: 4 ifAbsent: []) = nil.
	original restoreFromSnapshot: snapshot2.
	self assert: (original at: 1 ifAbsent: []) = #a.
	self assert: (original at: 2 ifAbsent: []) = #b.
	self assert: (original at: 3 ifAbsent: []) = #c.
	self assert: (original at: 4 ifAbsent: []) = nil.
	original restoreFromSnapshot: snapshot3.
	self assert: (original at: 1 ifAbsent: []) = #a.
	self assert: (original at: 2 ifAbsent: []) = #b.
	self assert: (original at: 3 ifAbsent: []) = #d.
	self assert: (original at: 4 ifAbsent: []) = nil.
	original restoreFromSnapshot: snapshot4.
	self assert: (original at: 1 ifAbsent: []) = nil.
	self assert: (original at: 2 ifAbsent: []) = #b.
	self assert: (original at: 3 ifAbsent: []) = #d.
	self assert: (original at: 4 ifAbsent: []) = nil.
	original at: 2 put: #'!'.
	original restoreFromSnapshot: snapshot4.
	self assert: (original at: 1 ifAbsent: []) = nil.
	self assert: (original at: 2 ifAbsent: []) = #b.
	self assert: (original at: 3 ifAbsent: []) = #d.
	self assert: (original at: 4 ifAbsent: []) = nil
    ]

    testHolder [
	<category: 'testing'>
	| original snapshot1 snapshot2 snapshot3 |
	original := WAValueHolder new.
	snapshot1 := original snapshotCopy.
	original contents: 1.
	snapshot2 := original snapshotCopy.
	original contents: 2.
	snapshot3 := original snapshotCopy.
	original restoreFromSnapshot: snapshot1.
	self assert: original contents = nil.
	original restoreFromSnapshot: snapshot2.
	self assert: original contents = 1.
	original restoreFromSnapshot: snapshot3.
	self assert: original contents = 2
    ]

    testObject [
	<category: 'testing'>
	| original snapshot |
	original := Object new.
	snapshot := original snapshotCopy.
	original restoreFromSnapshot: snapshot
    ]

    testOrderedCollection [
	<category: 'testing'>
	| original snapshot |
	original := OrderedCollection with: 1 with: 2.
	snapshot := original snapshotCopy.
	original restoreFromSnapshot: snapshot.
	self assert: original asArray = #(1 2).
	original removeLast.
	original restoreFromSnapshot: snapshot.
	self assert: original asArray = #(1 2)
    ]

    testSet [
	<category: 'testing'>
	| original snapshot1 snapshot2 snapshot3 |
	original := Set with: 1 with: 2.
	snapshot1 := original snapshotCopy.
	original add: 3.
	snapshot2 := original snapshotCopy.
	original remove: 1.
	snapshot3 := original snapshotCopy.
	original restoreFromSnapshot: snapshot1.
	self assert: original size = 2.
	self assert: (original includes: 1).
	self assert: (original includes: 2).
	self deny: (original includes: 3).
	original restoreFromSnapshot: snapshot2.
	self assert: original size = 3.
	self assert: (original includes: 1).
	self assert: (original includes: 2).
	self assert: (original includes: 3).
	original restoreFromSnapshot: snapshot3.
	self assert: original size = 2.
	self deny: (original includes: 1).
	self assert: (original includes: 2).
	self assert: (original includes: 3).
	original add: 4.
	original restoreFromSnapshot: snapshot3.
	self assert: original size = 2.
	self deny: (original includes: 1).
	self assert: (original includes: 2).
	self assert: (original includes: 3).
	self deny: (original includes: 4)
    ]
]



TestCase subclass: WACanvasBrushTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assert: aBlock gives: aString [
	<category: 'private'>
	| html |
	html := (WARenderCanvas builder)
		    callbackOwner: self;
		    render: aBlock.
	self 
	    assert: html = aString
	    description: 'Expected: ' , aString printString , ', Actual: ' 
		    , html printString
	    resumable: true
    ]

    testAnchorTag [
	<category: 'testing-tags-anchors'>
	self assert: [:html | html anchor]
	    gives: '<a href="javascript:void(0)"></a>'.
	self assert: [:html | html anchor name: 'foo'] gives: '<a name="foo"></a>'.
	self assert: 
		[:html | 
		(html anchor)
		    callback: [];
		    with: 'foo']
	    gives: '<a href="?1">foo</a>'.
	self assert: 
		[:html | 
		(html anchor)
		    callback: [];
		    with: 'foo'.
		(html anchor)
		    callback: [];
		    with: 'bar']
	    gives: '<a href="?1">foo</a><a href="?2">bar</a>'.
	self assert: 
		[:html | 
		(html anchor)
		    extraPath: 'zork';
		    callback: [];
		    with: 'foo']
	    gives: '<a href="/zork?1">foo</a>'.
	self assert: 
		[:html | 
		(html anchor)
		    extraParameters: 'zork';
		    callback: [];
		    with: 'foo']
	    gives: '<a href="?zork&amp;1">foo</a>'
    ]

    testAnchorTagWithUrl [
	<category: 'testing-tags-anchors'>
	| url string |
	url := WAUrl new.
	url
	    hostname: 'www.seaside.st';
	    addToPath: 'foo bar&zork<blah';
	    addParameter: '1' value: nil;
	    addParameter: '2' value: 123;
	    addParameter: '3' value: 'foo bar&zork'.
	string := 'http://www.seaside.st/foo+bar%26zork%3Cblah?1&amp;2=123&amp;3=foo+bar%26zork'.
	self assert: 
		[:html | 
		(html anchor)
		    url: url;
		    with: url]
	    gives: '<a href="' , string , '">' , string , '</a>'
    ]

    testBasicNesting [
	<category: 'testing'>
	self assert: [:html | html div] gives: '<div></div>'.
	self assert: [:html | html div: 1] gives: '<div>1</div>'.
	self assert: [:html | html div: 'foo'] gives: '<div>foo</div>'
    ]

    testBreakTag [
	<category: 'testing-tags'>
	self assert: [:html | html break] gives: '<br/>'
    ]

    testButton [
	<category: 'testing-tags-forms'>
	self assert: [:html | html button]
	    gives: '<button type="submit" class="submit"></button>'.
	self assert: [:html | html button beSubmit]
	    gives: '<button type="submit" class="submit"></button>'.
	self assert: [:html | html button bePush]
	    gives: '<button type="button" class="button"></button>'.
	self assert: [:html | html button beReset]
	    gives: '<button type="reset" class="reset"></button>'
    ]

    testCanvasHtml [
	<category: 'testing-encoding'>
	self assert: [:html | html html: '<'] gives: '<'.
	self assert: [:html | html html: '>'] gives: '>'.
	self assert: [:html | html html: '"'] gives: '"'.
	self assert: [:html | html html: '&'] gives: '&'.
	self assert: [:html | html html: '<div title="&amp;">']
	    gives: '<div title="&amp;">'
    ]

    testCanvasNil [
	<category: 'testing-encoding'>
	self assert: [:html | html text: nil] gives: ''.
	self assert: [:html | html render: nil] gives: ''
    ]

    testCanvasText [
	<category: 'testing-encoding'>
	self assert: [:html | html text: '<'] gives: '&lt;'.
	self assert: [:html | html text: '>'] gives: '&gt;'.
	self assert: [:html | html text: '"'] gives: '&quot;'.
	self assert: [:html | html text: '&'] gives: '&amp;'.
	self assert: [:html | html text: '<div title="&amp;">']
	    gives: '&lt;div title=&quot;&amp;amp;&quot;&gt;'
    ]

    testCanvasWithLineBreaks [
	<category: 'testing-encoding'>
	self assert: [:html | html withLineBreaks: 'a
b
c'] gives: 'a<br/>b<br/>c'
    ]

    testCanvasWithLineBreaksAndUrls [
	<category: 'testing-encoding'>
	self assert: 
		[:html | 
		html 
		    withLineBreaksAndUrls: '1. This is http://www.seaside.st online.
2. This is http://www.squeak.org online.']
	    gives: '1. This is <a href="http://www.seaside.st">http://www.seaside.st</a> online.<br/>2. This is <a href="http://www.squeak.org">http://www.squeak.org</a> online.'
    ]

    testCanvasWithUrls [
	<category: 'testing-encoding'>
	self 
	    assert: [:html | html withUrls: 'This is http://www.seaside.st online.']
	    gives: 'This is <a href="http://www.seaside.st">http://www.seaside.st</a> online.'
    ]

    testCheckboxTag [
	<category: 'testing-tags-forms'>
	self assert: [:html | html checkbox]
	    gives: '<input type="checkbox" class="checkbox"/><input name="1" type="hidden" class="hidden"/>'.
	self assert: [:html | html checkbox value: true]
	    gives: '<input checked="checked" type="checkbox" class="checkbox"/><input name="1" type="hidden" class="hidden"/>'.
	self assert: 
		[:html | 
		(html checkbox)
		    value: false;
		    callback: [:value | ]]
	    gives: '<input name="1" type="checkbox" class="checkbox"/><input name="2" type="hidden" class="hidden"/>'.
	self assert: 
		[:html | 
		(html checkbox)
		    value: true;
		    callback: [:value | ]]
	    gives: '<input checked="checked" name="1" type="checkbox" class="checkbox"/><input name="2" type="hidden" class="hidden"/>'
    ]

    testClosingTimes [
	<category: 'testing'>
	self assert: 
		[:html | 
		html
		    div;
		    div]
	    gives: '<div></div><div></div>'.
	self assert: 
		[:html | 
		html
		    break;
		    div]
	    gives: '<br/><div></div>'.
	self assert: 
		[:html | 
		html
		    div;
		    break]
	    gives: '<div></div><br/>'.
	self assert: 
		[:html | 
		html
		    break;
		    break]
	    gives: '<br/><br/>'.
	self assert: 
		[:html | 
		html
		    div: [html div];
		    div]
	    gives: '<div><div></div></div><div></div>'.
	self assert: 
		[:html | 
		html
		    div: [html break];
		    div]
	    gives: '<div><br/></div><div></div>'.
	self assert: 
		[:html | 
		html
		    div: [html div];
		    break]
	    gives: '<div><div></div></div><br/>'.
	self assert: 
		[:html | 
		html
		    div: [html break];
		    break]
	    gives: '<div><br/></div><br/>'
    ]

    testComplexTable [
	<category: 'testing'>
	self assert: 
		[:html | 
		html table: 
			[html tableHead: 
				[html tableRow: 
					[html tableHeading: 'h1'.
					html tableHeading: 'h2']].
			html tableBody: 
				[html tableRow: 
					[html tableData: 'd1'.
					html tableData: 'd2']].
			html tableFoot.
			html tableCaption: 'cap']]
	    gives: '<table><thead><tr><th>h1</th><th>h2</th></tr></thead><tbody><tr><td>d1</td><td>d2</td></tr></tbody><tfoot></tfoot><caption>cap</caption></table>'
    ]

    testCoreAttributesClass [
	<category: 'testing-attributes'>
	self assert: [:html | html div class: 'foo']
	    gives: '<div class="foo"></div>'.
	self assert: 
		[:html | 
		(html div)
		    class: 'foo';
		    class: 'bar']
	    gives: '<div class="foo bar"></div>'
    ]

    testCoreAttributesId [
	<category: 'testing-attributes'>
	self assert: [:html | html div id: 'foo'] gives: '<div id="foo"></div>'.
	self assert: 
		[:html | 
		(html div)
		    id: 'foo';
		    id: 'bar']
	    gives: '<div id="bar"></div>'.
	self assert: [:html | self assert: html div ensureId = 'id1']
	    gives: '<div id="id1"></div>'.
	self 
	    assert: [:html | self assert: ((html div)
			    id: 'foo';
			    ensureId) = 'foo']
	    gives: '<div id="foo"></div>'.
	self 
	    assert: [:html | self assert: ((html div)
			    id: 'foo';
			    id) = 'foo']
	    gives: '<div id="foo"></div>'.
	self assert: [:html | self assert: html div id isNil] gives: '<div></div>'
    ]

    testCoreAttributesStyle [
	<category: 'testing-attributes'>
	self assert: [:html | html div style: 'left: 0']
	    gives: '<div style="left: 0"></div>'.
	self assert: 
		[:html | 
		(html div)
		    style: 'left: 0';
		    style: 'top: 2']
	    gives: '<div style="left: 0;top: 2"></div>'
    ]

    testCoreAttributesTitle [
	<category: 'testing-attributes'>
	self assert: [:html | html div title: 'Seaside']
	    gives: '<div title="Seaside"></div>'
    ]

    testEditTag [
	<category: 'testing-tags'>
	self assert: [:html | html inserted: 'foo'] gives: '<ins>foo</ins>'.
	self assert: [:html | html deleted: 'bar'] gives: '<del>bar</del>'
    ]

    testEventAttributes [
	<category: 'testing-attributes'>
	self assert: 
		[:html | 
		(html div)
		    onBlur: 1;
		    onBlur: 2]
	    gives: '<div onblur="1;2"></div>'.
	self assert: 
		[:html | 
		(html div)
		    onChange: 1;
		    onChange: 2]
	    gives: '<div onchange="1;2"></div>'.
	self assert: 
		[:html | 
		(html div)
		    onClick: 1;
		    onClick: 2]
	    gives: '<div onclick="1;2"></div>'.
	self assert: 
		[:html | 
		(html div)
		    onDoubleClick: 1;
		    onDoubleClick: 2]
	    gives: '<div ondblclick="1;2"></div>'
    ]

    testExtendedNesting [
	<category: 'testing'>
	self assert: [:html | html div: nil] gives: '<div></div>'.
	self assert: [:html | html div: #(1 $a)] gives: '<div>1a</div>'.
	self assert: [:html | html div: [html span]]
	    gives: '<div><span></span></div>'
    ]

    testFieldSetTag [
	<category: 'testing-tags'>
	self assert: [:html | html fieldSet: 'foo']
	    gives: '<fieldset>foo</fieldset>'.
	self assert: 
		[:html | 
		(html fieldSet)
		    legend: 'bar';
		    with: 'zork']
	    gives: '<fieldset><legend>bar</legend>zork</fieldset>'
    ]

    testHeadingTag [
	<category: 'testing-tags'>
	self assert: [:html | html heading] gives: '<h1></h1>'.
	self assert: 
		[:html | 
		(html heading)
		    level: 2;
		    with: 'foo']
	    gives: '<h2>foo</h2>'.
	self assert: 
		[:html | 
		(html heading)
		    level: 0;
		    with: 'foo']
	    gives: '<h1>foo</h1>'.
	self assert: 
		[:html | 
		(html heading)
		    level: 7;
		    with: 'foo']
	    gives: '<h6>foo</h6>'
    ]

    testHorizontalRuleTag [
	<category: 'testing-tags'>
	self assert: [:html | html horizontalRule] gives: '<hr/>'
    ]

    testImageButton [
	<category: 'testing-tags-forms'>
	self assert: [:html | html imageButton]
	    gives: '<input type="image" class="image"/>'
    ]

    testImageTag [
	<category: 'testing-tags'>
	self assert: [:html | html image url: 'http://www.seaside.st/logo.jpeg']
	    gives: '<img alt="" src="http://www.seaside.st/logo.jpeg"/>'.
	self assert: 
		[:html | 
		(html image)
		    title: 'Seaside';
		    altText: 'the Seaside logo';
		    url: 'http://www.seaside.st/logo.jpeg']
	    gives: '<img alt="the Seaside logo" title="Seaside" src="http://www.seaside.st/logo.jpeg"/>'
    ]

    testKeyboardAttributes [
	<category: 'testing-attributes'>
	self assert: [:html | html anchor accessKey: $a]
	    gives: '<a accesskey="a" href="javascript:void(0)"></a>'.
	self assert: [:html | html anchor tabIndex: 3]
	    gives: '<a tabindex="3" href="javascript:void(0)"></a>'
    ]

    testLabelTag [
	<category: 'testing-tags'>
	self assert: [:html | html label: 'foo'] gives: '<label>foo</label>'.
	self assert: 
		[:html | 
		(html label)
		    for: 'bar';
		    with: 'zork']
	    gives: '<label for="bar">zork</label>'
    ]

    testMultiSelectTag [
	<category: 'testing-tags-forms'>
	self assert: [:html | html multiSelect]
	    gives: '<select multiple="multiple" name="1"></select>'.
	self assert: [:html | html multiSelect list: #(1 2)]
	    gives: '<select multiple="multiple" name="1"><option>1</option><option>2</option></select>'.
	self assert: 
		[:html | 
		(html multiSelect)
		    list: #(1 2);
		    labels: [:v | 2 * v]]
	    gives: '<select multiple="multiple" name="1"><option>2</option><option>4</option></select>'.
	self assert: 
		[:html | 
		(html multiSelect)
		    list: #(1 2);
		    enabled: [:v | v even]]
	    gives: '<select multiple="multiple" name="1"><option disabled="disabled">1</option><option>2</option></select>'.
	self assert: 
		[:html | 
		(html multiSelect)
		    list: #(1 2);
		    callback: [:v | ]]
	    gives: '<input name="1" type="hidden" class="hidden"/><select multiple="multiple" name="2"><option value="3">1</option><option value="4">2</option></select><input name="5" type="hidden" class="hidden"/>'
    ]

    testOrderedListTag [
	<category: 'testing-tags'>
	self assert: [:html | html orderedList] gives: '<ol></ol>'.
	self assert: [:html | html orderedList add: 1] gives: '<ol><li>1</li></ol>'.
	self assert: [:html | html orderedList addAll: #(1 2)]
	    gives: '<ol><li>1</li><li>2</li></ol>'.
	self assert: [:html | html orderedList list: #(1 2)]
	    gives: '<ol><li>1</li><li>2</li></ol>'.
	self assert: 
		[:html | 
		(html orderedList)
		    list: #(1 2);
		    with: [html listItem: 3]]
	    gives: '<ol><li>1</li><li>2</li><li>3</li></ol>'.
	self assert: 
		[:html | 
		(html orderedList)
		    add: 2;
		    labels: [:e | 2 * e]]
	    gives: '<ol><li>4</li></ol>'.
	self assert: 
		[:html | 
		(html orderedList)
		    add: 2;
		    labels: [:e | 2 * e];
		    with: [html listItem: 5]]
	    gives: '<ol><li>4</li><li>5</li></ol>'
    ]

    testParagraphTag [
	<category: 'testing-tags'>
	self assert: [:html | html paragraph] gives: '<p></p>'.
	self assert: [:html | html paragraph: 'foo'] gives: '<p>foo</p>'
    ]

    testPasswordInput [
	<category: 'testing-tags-forms'>
	self assert: [:html | html passwordInput]
	    gives: '<input type="password" class="password"/>'.
	self assert: [:html | html passwordInput callback: [:value | ]]
	    gives: '<input name="1" type="password" class="password"/>'.
	self assert: [:html | html passwordInput value: 'foo bar&zork']
	    gives: '<input value="foo bar&amp;zork" type="password" class="password"/>'.
	self assert: 
		[:html | 
		(html passwordInput)
		    callback: [:value | ];
		    value: 'foo bar&zork']
	    gives: '<input name="1" value="foo bar&amp;zork" type="password" class="password"/>'
    ]

    testScriptTag [
	<category: 'testing-tags'>
	self assert: [:html | html script: 'alert("<foo>")']
	    gives: '<script type="text/javascript">/*<![CDATA[*/alert("<foo>")/*]]>*/</script>'.
	self assert: [:html | html script: 'true & false']
	    gives: '<script type="text/javascript">/*<![CDATA[*/true & false/*]]>*/</script>'.
	self assert: 
		[:html | 
		(html script)
		    defer;
		    with: 'alert("<foo>")']
	    gives: '<script defer="defer" type="text/javascript">/*<![CDATA[*/alert("<foo>")/*]]>*/</script>'
    ]

    testSelectTag [
	<category: 'testing-tags-forms'>
	self assert: [:html | html select] gives: '<select name="1"></select>'.
	self assert: [:html | html select list: #(1 2)]
	    gives: '<select name="1"><option>1</option><option>2</option></select>'.
	self assert: 
		[:html | 
		(html select)
		    list: #(1 2);
		    labels: [:v | 2 * v]]
	    gives: '<select name="1"><option>2</option><option>4</option></select>'.
	self assert: 
		[:html | 
		(html select)
		    list: #(1 2);
		    enabled: [:v | v even]]
	    gives: '<select name="1"><option disabled="disabled">1</option><option>2</option></select>'.
	self assert: 
		[:html | 
		(html select)
		    list: #(1 2);
		    callback: [:v | ]]
	    gives: '<select name="1"><option value="2">1</option><option value="3">2</option></select>'
    ]

    testSymbolRendering [
	<category: 'testing-tags-forms'>
	self assert: 
		[:html | 
		(html div)
		    id: #aSymbol;
		    with: #aSecondSymbol]
	    gives: '<div id="aSymbol">aSecondSymbol</div>'.
	self assert: [:html | html div: [html text: #aSecondSymbol]]
	    gives: '<div>aSecondSymbol</div>'.
	self assert: [:html | html div: [html render: #aSecondSymbol]]
	    gives: '<div>aSecondSymbol</div>'
    ]

    testTextArea [
	<category: 'testing-tags-forms'>
	self assert: [:html | html textArea]
	    gives: '<textarea rows="auto" cols="auto"></textarea>'.
	self assert: [:html | html textArea columns: 4]
	    gives: '<textarea rows="auto" cols="4"></textarea>'.
	self assert: [:html | html textArea rows: 40]
	    gives: '<textarea rows="40" cols="auto"></textarea>'.
	self assert: [:html | html textArea callback: [:value | ]]
	    gives: '<textarea rows="auto" cols="auto" name="1"></textarea>'.
	self assert: [:html | html textArea value: 'foo bar&zork']
	    gives: '<textarea rows="auto" cols="auto">foo bar&amp;zork</textarea>'.
	self assert: [:html | html textArea with: 'foo bar&zork']
	    gives: '<textarea rows="auto" cols="auto">foo bar&amp;zork</textarea>'.
	self assert: 
		[:html | 
		(html textArea)
		    callback: [:value | ];
		    with: 'foo bar&zork']
	    gives: '<textarea rows="auto" cols="auto" name="1">foo bar&amp;zork</textarea>'
    ]

    testTextInput [
	<category: 'testing-tags-forms'>
	self assert: [:html | html textInput]
	    gives: '<input type="text" class="text"/>'.
	self assert: [:html | html textInput callback: [:value | ]]
	    gives: '<input name="1" type="text" class="text"/>'.
	self assert: [:html | html textInput value: 'foo bar&zork']
	    gives: '<input value="foo bar&amp;zork" type="text" class="text"/>'.
	self assert: 
		[:html | 
		(html textInput)
		    callback: [:value | ];
		    value: 'foo bar&zork']
	    gives: '<input name="1" value="foo bar&amp;zork" type="text" class="text"/>'
    ]

    testUnorderedListTag [
	<category: 'testing-tags'>
	self assert: [:html | html unorderedList] gives: '<ul></ul>'.
	self assert: [:html | html unorderedList add: 1]
	    gives: '<ul><li>1</li></ul>'.
	self assert: [:html | html unorderedList addAll: #(1 2)]
	    gives: '<ul><li>1</li><li>2</li></ul>'.
	self assert: [:html | html unorderedList list: #(1 2)]
	    gives: '<ul><li>1</li><li>2</li></ul>'.
	self assert: 
		[:html | 
		(html unorderedList)
		    list: #(1 2);
		    with: [html listItem: 3]]
	    gives: '<ul><li>1</li><li>2</li><li>3</li></ul>'.
	self assert: 
		[:html | 
		(html unorderedList)
		    add: 2;
		    labels: [:e | 2 * e]]
	    gives: '<ul><li>4</li></ul>'.
	self assert: 
		[:html | 
		(html unorderedList)
		    add: 2;
		    labels: [:e | 2 * e];
		    with: [html listItem: 5]]
	    gives: '<ul><li>4</li><li>5</li></ul>'
    ]
]



WACanvasBrushTest subclass: WAFormTagTest [
    | session |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assertUserAgent: aString isInternetExplorer: aBoolean [
	<category: 'private'>
	self userAgent: aString.
	(WARenderCanvas builder)
	    callbackOwner: self;
	    render: [:html | self assert: html form isInternetExplorer = aBoolean]
    ]

    performTest [
	<category: 'private'>
	WACurrentSession use: session during: [super performTest]
    ]

    setUp [
	<category: 'private'>
	super setUp.
	session := WASession new currentRequest: WARequest blankRequest yourself
    ]

    testDefaultAction [
	<category: 'testing'>
	self 
	    userAgent: 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.8.1.3) Gecko/20070309 Firefox/2.0.0.3'.
	self assert: [:html | html form defaultAction: []]
	    gives: '<form accept-charset="utf-8" method="post" action=""><div><input tabindex="-1" value="Default" name="1" style="position: absolute; top: -100em" type="submit" class="submit"/></div><div></div></form>'.
	self userAgent: 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'.
	self assert: [:html | html form defaultAction: []]
	    gives: '<form accept-charset="utf-8" method="post" action=""><div><input tabindex="-1" value="Default" name="1" style="position: absolute; top: -100em" type="submit" class="submit"/><input tabindex="-1" name="2" style="position: absolute; top: -100em" type="text" class="text"/></div><div></div></form>'
    ]

    testIsInternetExplorer [
	<category: 'testing'>
	self 
	    assertUserAgent: 'Mozilla/5.0 (compatible; Konqueror/3.2; Linux 2.6.2) (KHTML, like Gecko)'
	    isInternetExplorer: false.
	self 
	    assertUserAgent: 'Mozilla/4.0 (compatible; MSIE 6.0; MSIE 5.5; Windows NT 5.1) Opera 7.04 [de]'
	    isInternetExplorer: false.
	self assertUserAgent: 'Opera/9.10 (Windows NT 5.0; U; de)'
	    isInternetExplorer: false.
	self 
	    assertUserAgent: 'Mozilla/5.0 (Windows; U; Windows NT 5.0; de-DE; rv:1.6) Gecko/20040206 Firefox/1.0.1'
	    isInternetExplorer: false.
	self 
	    assertUserAgent: 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; WOW64; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506)'
	    isInternetExplorer: true.
	self assertUserAgent: 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'
	    isInternetExplorer: true.
	self 
	    assertUserAgent: 'Lynx/2.8.4rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.6c'
	    isInternetExplorer: false.
	self 
	    assertUserAgent: 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de-AT; rv:1.8.1.2) Gecko/20070222 SeaMonkey/1.1.1'
	    isInternetExplorer: false.
	self 
	    assertUserAgent: 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.8.1.3) Gecko/20070309 Firefox/2.0.0.3'
	    isInternetExplorer: false
    ]

    userAgent: aString [
	<category: 'private'>
	session currentRequest headers at: 'user-agent' put: aString
    ]
]



WACanvasBrushTest subclass: WAResourceBaseUrlTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assertRoot: aBlock gives: aString [
	<category: 'private'>
	| html |
	html := (WARenderCanvas builder)
		    callbackOwner: self;
		    fullDocument: true;
		    rootBlock: aBlock;
		    render: [:canvas | ].
	self assert: html 
		    = ('<html><head><title></title>' , aString , '</head><body></body></html>')
    ]

    performTest [
	<category: 'private'>
	| application session |
	application := (WAApplication new)
		    preferenceAt: #resourceBaseUrl put: self resourceBaseUrl;
		    yourself.
	session := (WASession new)
		    setParent: application;
		    yourself.
	WACurrentSession use: session during: [super performTest]
    ]

    resourceBaseUrl [
	<category: 'private'>
	^'https:/www.seaside.st/resources/'
    ]

    testAbsoluteFtpUrl [
	<category: 'testing'>
	self 
	    assert: [:html | html anchor resourceUrl: 'ftp://www.google.com/track.js']
	    gives: '<a href="ftp://www.google.com/track.js"></a>'
    ]

    testAbsoluteHttpUrl [
	<category: 'testing'>
	self 
	    assert: [:html | html anchor resourceUrl: 'http://www.google.com/track.js']
	    gives: '<a href="http://www.google.com/track.js"></a>'
    ]

    testAbsoluteHttpsUrl [
	<category: 'testing'>
	self 
	    assert: [:html | html anchor resourceUrl: 'https://www.google.com/track.js']
	    gives: '<a href="https://www.google.com/track.js"></a>'
    ]

    testFileNameWithHttp [
	<category: 'testing'>
	self assert: [:html | html image resourceUrl: 'http.gif']
	    gives: '<img alt="" src="https:/www.seaside.st/resources/http.gif"/>'
    ]

    testImageTag [
	<category: 'testing'>
	self assert: [:html | html image resourceUrl: 'logo.jpeg']
	    gives: '<img alt="" src="https:/www.seaside.st/resources/logo.jpeg"/>'
    ]

    testRootScript [
	<category: 'testing'>
	self assertRoot: [:html | html javascript resourceUrl: 'main.js']
	    gives: '<script type="text/javascript" src="https:/www.seaside.st/resources/main.js"></script>'
    ]

    testScriptTag [
	<category: 'testing'>
	self assert: [:html | html script resourceUrl: 'track.js']
	    gives: '<script src="https:/www.seaside.st/resources/track.js" type="text/javascript">/*<![CDATA[*//*]]>*/</script>'
    ]

    testSylesheet [
	<category: 'testing'>
	self assertRoot: [:html | html stylesheet resourceUrl: 'main.css']
	    gives: '<link rel="stylesheet" type="text/css" href="https:/www.seaside.st/resources/main.css"/>'
    ]
]



TestCase subclass: WAConfigurationTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    testLinearization [
	"from http://www.webcom.com/haahr/dylan/linearization-oopsla96.html"

	<category: 'tests'>
	| root boat dayBoat wheelBoat engineLess pedalWheelBoat smallMultihull smallCatamaran pedalo |
	root := WAUserConfiguration new.
	boat := (WAUserConfiguration new)
		    addAncestor: root;
		    yourself.
	dayBoat := (WAUserConfiguration new)
		    addAncestor: boat;
		    yourself.
	wheelBoat := (WAUserConfiguration new)
		    addAncestor: boat;
		    yourself.
	engineLess := (WAUserConfiguration new)
		    addAncestor: dayBoat;
		    yourself.
	pedalWheelBoat := (WAUserConfiguration new)
		    addAncestor: engineLess;
		    addAncestor: wheelBoat;
		    yourself.
	smallMultihull := (WAUserConfiguration new)
		    addAncestor: dayBoat;
		    yourself.
	smallCatamaran := (WAUserConfiguration new)
		    addAncestor: smallMultihull;
		    yourself.
	pedalo := (WAUserConfiguration new)
		    addAncestor: pedalWheelBoat;
		    addAncestor: smallCatamaran;
		    yourself.
	self 
	    assert: pedalWheelBoat allAncestors = (Array 
			    with: engineLess
			    with: dayBoat
			    with: wheelBoat
			    with: boat
			    with: root).
	self 
	    assert: smallCatamaran allAncestors = (Array 
			    with: smallMultihull
			    with: dayBoat
			    with: boat
			    with: root).
	self assert: pedalo allAncestors 
		    = ((Array 
			    with: pedalWheelBoat
			    with: engineLess
			    with: smallCatamaran
			    with: smallMultihull) , (Array 
					with: dayBoat
					with: wheelBoat
					with: boat
					with: root))
    ]
]



TestCase subclass: WACookieUnitTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    testWriteOn [
	<category: 'testing'>
	| expiry cookie actual |
	expiry := DateTime 
		    year: 2007
		    month: 11
		    day: 21
		    hour: 14
		    minute: 42
		    second: 48
		    offset: (Duration 
			    days: 0
			    hours: 2
			    minutes: 0
			    seconds: 0).
	cookie := WACookie key: 'ikuser' value: '1234'.
	actual := String streamContents: [:stream | cookie writeOn: stream].
	self assert: actual = 'ikuser=1234'.
	cookie expiry: expiry.
	actual := String streamContents: [:stream | cookie writeOn: stream].
	self 
	    assert: actual = 'ikuser=1234; expires=Wed, 21-November-2007 12:42:48 GMT'.
	cookie path: '/seaside/counter'.
	actual := String streamContents: [:stream | cookie writeOn: stream].
	self assert: actual 
		    = 'ikuser=1234; expires=Wed, 21-November-2007 12:42:48 GMT; path=/seaside/counter'.
	cookie value: nil.
	actual := String streamContents: [:stream | cookie writeOn: stream].
	self assert: actual 
		    = 'ikuser=; expires=Wed, 21-November-2007 12:42:48 GMT; path=/seaside/counter'
    ]
]



TestCase subclass: WADictionaryTest [
    | dictionary |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    setUp [
	<category: 'running'>
	super setUp.
	dictionary := WASmallDictionary new
    ]

    testAssociations [
	<category: 'testing-enumerating'>
	dictionary
	    at: '1' put: 'foo';
	    at: '2' put: 'bar'.
	self assert: dictionary associations 
		    = (Array with: '1' -> 'foo' with: '2' -> 'bar')
    ]

    testAssociationsDo [
	<category: 'testing-enumerating'>
	dictionary associationsDo: [:key :valye | self assert: false].
	dictionary
	    at: '1' put: 'foo';
	    at: '2' put: 'bar'.
	dictionary associationsDo: 
		[:assoc | 
		self assert: ((assoc key = '1' and: [assoc value = 'foo']) 
			    or: [assoc key = '2' and: [assoc value = 'bar']])]
    ]

    testAt [
	<category: 'testing'>
	self should: [dictionary at: '1'] raise: Error.
	dictionary at: '1' put: 'foo'.
	self assert: (dictionary at: '1') = 'foo'
    ]

    testAtIfAbsent [
	<category: 'testing'>
	self assert: (dictionary at: '1' ifAbsent: ['foo']) = 'foo'.
	dictionary at: '1' put: 'bar'.
	self assert: (dictionary at: '1' ifAbsent: ['foo']) = 'bar'
    ]

    testAtIfAbsentPut [
	<category: 'testing'>
	self assert: (dictionary at: '1' ifAbsentPut: ['foo']) = 'foo'.
	self assert: (dictionary at: '1' ifAbsentPut: ['bar']) = 'foo'
    ]

    testAtIfPresent [
	<category: 'testing'>
	dictionary at: '1' put: 'foo'.
	self assert: (dictionary at: '1' ifPresent: [:v | v , 'bar']) = 'foobar'.
	self assert: (dictionary at: '2' ifPresent: [:v | v , 'bar']) isNil
    ]

    testAtPut [
	<category: 'testing'>
	dictionary at: '1' put: 'foo'.
	self assert: (dictionary at: '1') = 'foo'.
	dictionary at: '1' put: 'bar'.
	self assert: (dictionary at: '1') = 'bar'
    ]

    testIncludesKey [
	<category: 'testing-testing'>
	self deny: (dictionary includesKey: '1').
	dictionary at: '1' put: 'foo'.
	self assert: (dictionary includesKey: '1')
    ]

    testIsEmpty [
	<category: 'testing-testing'>
	self assert: dictionary isEmpty.
	dictionary at: '1' put: 'foo'.
	self deny: dictionary isEmpty
    ]

    testKeys [
	<category: 'testing-enumerating'>
	dictionary
	    at: '1' put: 'foo';
	    at: '2' put: 'bar'.
	self assert: dictionary keys = #('1' '2')
    ]

    testKeysAndValuesDo [
	<category: 'testing-enumerating'>
	dictionary keysAndValuesDo: [:key :valye | self assert: false].
	dictionary
	    at: '1' put: 'foo';
	    at: '2' put: 'bar'.
	dictionary keysAndValuesDo: 
		[:key :value | 
		self assert: ((key = '1' and: [value = 'foo']) 
			    or: [key = '2' and: [value = 'bar']])]
    ]

    testKeysDo [
	<category: 'testing-enumerating'>
	| result |
	result := OrderedCollection new.
	dictionary
	    at: '1' put: 'foo';
	    at: '2' put: 'bar'.
	dictionary keysDo: [:each | result add: each].
	self assert: result asArray = #('1' '2')
    ]

    testRemoveKey [
	<category: 'testing'>
	dictionary at: '1' put: 'foo'.
	self assert: (dictionary removeKey: '1') = 'foo'.
	self should: [dictionary removeKey: '1'] raise: Error
    ]

    testRemoveKeyIfAbsent [
	<category: 'testing'>
	dictionary at: '1' put: 'foo'.
	self assert: (dictionary removeKey: '1' ifAbsent: ['bar']) = 'foo'.
	self assert: (dictionary removeKey: '1' ifAbsent: ['bar']) = 'bar'
    ]

    testSize [
	<category: 'testing'>
	self assert: dictionary size = 0.
	dictionary at: '1' put: 'foo'.
	self assert: dictionary size = 1.
	dictionary at: '2' put: 'bar'.
	self assert: dictionary size = 2
    ]

    testValues [
	<category: 'testing-enumerating'>
	dictionary
	    at: '1' put: 'foo';
	    at: '2' put: 'bar'.
	self assert: dictionary values = #('foo' 'bar')
    ]

    testValuesDo [
	<category: 'testing-enumerating'>
	| result |
	result := OrderedCollection new.
	dictionary
	    at: '1' put: 'foo';
	    at: '2' put: 'bar'.
	dictionary valuesDo: [:each | result add: each].
	self assert: result asArray = #('foo' 'bar')
    ]
]



TestCase subclass: WADispatcherTest [
    | defaultDispatcher alternateDispatcher shortDispatcher baseName alternateName lastUpdate |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    dispatcher: aDispatcher hasSameEntryPointsAs: anotherDispatcher [
	"VW does not have Set >> #=
	 OMFG!! SRSLY? wtf...?"

	<category: 'private'>
	| aSet anotherSet |
	aSet := aDispatcher entryPoints keys.
	anotherSet := anotherDispatcher entryPoints keys.
	aSet == anotherSet ifTrue: [^true].
	aSet class == anotherSet class ifFalse: [^false].	"not sure this is really clever but ..."
	aSet size = anotherSet size ifFalse: [^false].
	^aSet allSatisfy: [:each | anotherSet includes: each]
    ]

    setUp [
	"The statement below makes sure that the 'files' entry is registered
	 into the default dispatcher before starting this test.
	 This may be needed after loading Seaside in a stock VW image
	 depending on the order the unit tests are executed.
	 Without it, the WADispatcher tests that need the 'files' entry may fail in VW
	 namely #testAlternateFiles and #testDefaultFiles"

	<category: 'running'>
	WAFileHandler default.
	baseName := SeasidePlatformSupport defaultDispatcherName.
	alternateName := 'seaside/stream'.
	defaultDispatcher := WADispatcher default.
	alternateDispatcher := defaultDispatcher copy setName: alternateName.
	shortDispatcher := defaultDispatcher copy setName: ''.
	defaultDispatcher addDependent: self
    ]

    tearDown [
	<category: 'running'>
	defaultDispatcher removeDependent: self
    ]

    testAlternateCloning [
	<category: 'testing'>
	| originalHandler |
	self deny: alternateDispatcher == defaultDispatcher.
	self assert: (self dispatcher: alternateDispatcher
		    hasSameEntryPointsAs: defaultDispatcher).
	alternateDispatcher entryPoints do: 
		[:handler | 
		originalHandler := defaultDispatcher entryPointAt: handler name.
		self assert: handler class == originalHandler class.
		self deny: handler == originalHandler.
		handler isDispatcher 
		    ifTrue: 
			[self 
			    assert: (self dispatcher: handler hasSameEntryPointsAs: originalHandler)]]
    ]

    testAlternateConfig [
	<category: 'testing'>
	| app originalApp |
	app := alternateDispatcher entryPointAt: 'config'.
	originalApp := defaultDispatcher entryPointAt: 'config'.
	self assert: app class == WAApplication.
	self assert: app isApplication.
	self deny: app isDispatcher.
	self deny: app parent isNil.
	self assert: app name = 'config'.
	self assert: app basePath = ('/' , alternateDispatcher name , '/config').
	self deny: app == originalApp.
	self assert: app name = originalApp name.
	self assert: app parent == alternateDispatcher.
	self assert: originalApp parent == defaultDispatcher
    ]

    testAlternateCounterDirect [
	<category: 'testing'>
	| app originalApp |
	app := alternateDispatcher entryPointAt: 'examples/counter'.
	originalApp := defaultDispatcher entryPointAt: 'examples/counter'.
	self assert: app name = 'counter'.
	self assert: app parent name = 'examples'.
	self assert: app basePath 
		    = ('/' , alternateDispatcher name , '/examples/counter').
	self deny: app == originalApp.
	self assert: app name = originalApp name.
	self deny: app parent == originalApp parent.
	self assert: app parent name = originalApp parent name.
	self deny: app parent parent == originalApp parent parent.
	self deny: app parent parent name = originalApp parent parent name.
	self assert: app parent parent == alternateDispatcher.
	self assert: originalApp parent parent == defaultDispatcher
    ]

    testAlternateFiles [
	<category: 'testing'>
	| app originalApp |
	app := alternateDispatcher entryPointAt: 'files'.
	originalApp := defaultDispatcher entryPointAt: 'files'.
	self assert: app class == WAFileHandler.
	self deny: app isApplication.
	self deny: app isDispatcher.
	self deny: app parent isNil.
	self assert: app name = 'files'.
	self assert: app basePath = ('/' , alternateDispatcher name , '/files').
	self deny: app == originalApp.
	self deny: app libraries == originalApp libraries.
	self assert: app name = originalApp name.
	self assert: app parent == alternateDispatcher.
	self assert: originalApp parent == defaultDispatcher
    ]

    testAlternateRoot [
	<category: 'testing'>
	| app |
	app := alternateDispatcher.
	self assert: app class == WADispatcher.
	self deny: app isApplication.
	self assert: app isDispatcher.
	self assert: app isRoot.
	self assert: app parent isNil.
	self assert: app name = alternateName
    ]

    testAlternateTests [
	<category: 'testing'>
	| app originalApp |
	app := alternateDispatcher entryPointAt: 'tests'.
	originalApp := defaultDispatcher entryPointAt: 'tests'.
	self assert: app class == WADispatcher.
	self deny: app isApplication.
	self assert: app isDispatcher.
	self deny: app isRoot.
	self deny: app parent isNil.
	self assert: app name = 'tests'.
	self assert: app basePath = ('/' , alternateDispatcher name , '/tests').
	self deny: app == originalApp.
	self assert: app name = originalApp name.
	self assert: app parent == alternateDispatcher.
	self assert: originalApp parent == defaultDispatcher
    ]

    testDefaultConfig [
	<category: 'testing'>
	| app |
	app := defaultDispatcher entryPointAt: 'config'.
	self assert: app class == WAApplication.
	self assert: app isApplication.
	self deny: app isDispatcher.
	self deny: app parent isNil.
	self assert: app name = 'config'.
	self assert: app basePath = ('/' , baseName , '/config')
    ]

    testDefaultCounterDirect [
	<category: 'testing'>
	| app |
	app := defaultDispatcher entryPointAt: 'examples/counter'.
	self assert: app class == WAApplication.
	self assert: app isApplication.
	self deny: app isDispatcher.
	self deny: app parent isNil.
	self assert: app name = 'counter'.
	self assert: app parent name = 'examples'.
	self assert: app basePath = ('/' , baseName , '/examples/counter')
    ]

    testDefaultCounterNavigate [
	<category: 'testing'>
	| app |
	app := defaultDispatcher entryPointAt: 'examples'.
	self assert: app class == WADispatcher.
	self assert: app isDispatcher.
	self deny: app isRoot.
	self deny: app isApplication.
	self deny: app parent isNil.
	self assert: app name = 'examples'.
	self assert: app basePath = ('/' , baseName , '/examples').
	app := app entryPointAt: 'counter'.
	self assert: app class == WAApplication.
	self assert: app isApplication.
	self deny: app isDispatcher.
	self deny: app parent isNil.
	self assert: app name = 'counter'.
	self assert: app parent name = 'examples'.
	self assert: app basePath = ('/' , baseName , '/examples/counter')
    ]

    testDefaultFiles [
	<category: 'testing'>
	| app |
	app := defaultDispatcher entryPointAt: 'files'.
	self assert: app class == WAFileHandler.
	self deny: app isDispatcher.
	self deny: app isApplication.
	self deny: app parent isNil.
	self assert: app name = 'files'.
	self assert: app basePath = ('/' , baseName , '/files')
    ]

    testDefaultRoot [
	<category: 'testing'>
	| app |
	app := defaultDispatcher.
	self assert: app == WADispatcher default.
	self assert: app class == WADispatcher.
	self assert: app isDispatcher.
	self assert: app isRoot.
	self deny: app isApplication.
	self assert: app parent isNil.
	self assert: app name = baseName.
	self assert: app basePath = ('/' , baseName)
    ]

    testDefaultTests [
	<category: 'testing'>
	| app |
	app := defaultDispatcher entryPointAt: 'tests'.
	self assert: app class == WADispatcher.
	self assert: app isDispatcher.
	self deny: app isRoot.
	self deny: app isApplication.
	self deny: app parent isNil.
	self assert: app name = 'tests'.
	self assert: app basePath = ('/' , baseName , '/tests')
    ]

    testShortTests [
	<category: 'testing'>
	| app |
	app := shortDispatcher entryPointAt: 'tests'.
	self assert: shortDispatcher basePath = ''.
	self assert: app basePath = '/tests'
    ]
]



TestCase subclass: WADocumentHandlerTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assertHttpResponseFrom: aResponse matches: aHandler [
	<category: 'private'>
	self assert: aResponse status = 200.
	self assert: aResponse contents contents = aHandler document.
	self assert: aResponse contentType = aHandler mimeType.
	self assert: aResponse contents contents size = aHandler document size.
	self assert: aResponse cookies isEmpty
    ]

    createAndVerifyBinaryDocumentNamed: aFilename hasAttachement: aHttpHeaderValue [
	<category: 'private'>
	self 
	    createAndVerifyDocumentNamed: aFilename
	    content: WAStandardFiles default profilerPng
	    mimeType: 'image/png'
	    hasAttachement: aHttpHeaderValue
    ]

    createAndVerifyDocumentNamed: aFilename content: anObject mimeType: aMimeTypeString hasAttachement: aHttpHeaderValue [
	<category: 'private'>
	| handler response |
	handler := WADocumentHandler 
		    document: anObject
		    mimeType: aMimeTypeString
		    fileName: aFilename.
	self assert: handler document = anObject.
	response := handler response.
	self assert: (self headerAt: 'Expires' forResponse: response) notNil.
	self assert: (self headerAt: 'Content-Disposition' forResponse: response) 
		    = aHttpHeaderValue.
	self assertHttpResponseFrom: response matches: handler
    ]

    createAndVerifyTextDocumentNamed: aFilename hasAttachement: aHttpHeaderValue [
	<category: 'private'>
	self 
	    createAndVerifyDocumentNamed: aFilename
	    content: WAStandardFiles default toolbarCss
	    mimeType: 'text/css'
	    hasAttachement: aHttpHeaderValue
    ]

    headerAt: aString forResponse: aResponse [
	<category: 'private'>
	| header |
	header := aResponse headers detect: [:each | each key = aString]
		    ifNone: [^nil].
	^header value
    ]

    testByteArray [
	<category: 'testing'>
	self createAndVerifyBinaryDocumentNamed: nil hasAttachement: nil.
	self createAndVerifyBinaryDocumentNamed: 'profiler.png'
	    hasAttachement: 'attachment; filename="profiler.png"'
    ]

    testString [
	<category: 'testing'>
	self createAndVerifyTextDocumentNamed: nil hasAttachement: nil.
	self createAndVerifyTextDocumentNamed: 'toolbar.css'
	    hasAttachement: 'attachment; filename="toolbar.css"'
    ]
]



TestCase subclass: WADynamicVariableTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assertValue: anObject [
	<category: 'private'>
	| value |
	value := WADemoVariable value.
	self assert: value = anObject
    ]

    testWithValue [
	<category: 'testing'>
	| value |
	value := 'value'.
	WADemoVariable use: value during: [self assertValue: value]
    ]

    testWithoutValue [
	<category: 'testing'>
	self assertValue: WADemoVariable defaultValue
    ]
]



TestCase subclass: WAEncoderTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assert: aString encoder: aClass gives: anEncodedString [
	<category: 'private'>
	| stream |
	stream := WriteStream on: String new.
	(aClass on: stream) nextPutAll: aString.
	self assert: stream contents = anEncodedString
    ]

    testEncodedHtml [
	<category: 'testing'>
	self 
	    assert: 'Seaside'
	    encoder: WAHtmlEncoder
	    gives: 'Seaside'.
	self 
	    assert: '<div id="&amp;">'
	    encoder: WAHtmlEncoder
	    gives: '&lt;div id=&quot;&amp;amp;&quot;&gt;'
    ]

    testEncodedLatin1Url [
	<category: 'testing'>
	self 
	    assert: (String with: (Character value: 233) with: (Character value: 228))
	    encoder: WAUrlEncoder
	    gives: '%E9%E4'
    ]

    testEncodedUnicode [
	"this makes sure the encoder doesn't fall on the nose with unicode"

	<category: 'testing'>
	| hiraA hiraO hiraAO zero ea |
	ea := String with: (Character value: 233) with: (Character value: 228).
	self 
	    assert: ea
	    encoder: WAHtmlEncoder
	    gives: ea.
	hiraA := (Character codePoint: 12354) asString.	"HIRAGANA LETTER A"
	hiraO := (Character codePoint: 12362) asString.	"HIRAGANA LETTER O"
	hiraAO := hiraA , hiraO.
	self 
	    assert: hiraA
	    encoder: WAHtmlEncoder
	    gives: hiraA.
	self 
	    assert: hiraO
	    encoder: WAHtmlEncoder
	    gives: hiraO.
	self 
	    assert: hiraAO
	    encoder: WAHtmlEncoder
	    gives: hiraAO.

	"The Supplementary Multilingual Plane (SMP: Plane 1, U+010000 - U+01FFFF)
	 http://www.unicode.org/charts/PDF/U10140.pdf
	 Ancient Greek Zero Sign"
	zero := (Character codePoint: 65930) asString.
	self 
	    assert: zero
	    encoder: WAHtmlEncoder
	    gives: zero
    ]

    testEncodedUrl [
	<category: 'testing'>
	self 
	    assert: 'Seaside Aubergines'
	    encoder: WAUrlEncoder
	    gives: 'Seaside+Aubergines'.
	self 
	    assert: 'www.seaside.st'
	    encoder: WAUrlEncoder
	    gives: 'www.seaside.st'.
	self 
	    assert: '~seaside-info_'
	    encoder: WAUrlEncoder
	    gives: '~seaside-info_'.
	self 
	    assert: 'http://www.seaside.st?foo=1&bar=2'
	    encoder: WAUrlEncoder
	    gives: 'http%3A%2F%2Fwww.seaside.st%3Ffoo%3D1%26bar%3D2'.
	self 
	    assert: 'a%'
	    encoder: WAUrlEncoder
	    gives: 'a%25'.
	self 
	    assert: (String with: Character cr)
	    encoder: WAUrlEncoder
	    gives: '%0D'
    ]

    testEncodedUtf8Url [
	"this tests url encoding of strings that are already utf8"

	"'übertriñgé' isoToUtf8"

	<category: 'testing'>
	self 
	    assert: #(195 188 98 101 114 116 114 105 195 177 103 195 169) asByteArray 
		    seasideString
	    encoder: WAUrlEncoder
	    gives: '%C3%BCbertri%C3%B1g%C3%A9'
    ]
]



TestCase subclass: WAExternalIDTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    count [
	<category: 'accessing'>
	^512
    ]

    testFromString [
	<category: 'testing'>
	| string |
	string := 'abCD12_-'.
	self assert: (WAExternalID fromString: string) printString = string
    ]

    testStartUp [
	<category: 'testing'>
	| collection |
	WAExternalID startUp.
	collection := Set new: self count.
	self count timesRepeat: [collection add: WAExternalID new].
	WAExternalID startUp.
	self count timesRepeat: 
		[self deny: (collection includes: WAExternalID new)
		    description: 'This is extremely unlikely to fail, if it does repeatedly then there is something wrong with the initialization of the random-generator.']
    ]

    testUnique [
	<category: 'testing'>
	| collection id |
	collection := Set new: self count.
	self count timesRepeat: 
		[id := WAExternalID new.
		self deny: (collection includes: id)
		    description: 'This is extremely unlikely to fail, if it does repeatedly then there is something wrong with the random generator.'.
		collection add: id]
    ]
]



TestCase subclass: WAFileLibraryTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assertFile: aString contentType: aMimeType handler: aHandler symbol: aSymbol library: aLibrary [
	<category: 'utilities'>
	| request response |
	request := WARequest 
		    method: 'GET'
		    url: '/seaside/files/' , aLibrary name , '/' , aString
		    headers: Dictionary new
		    fields: Dictionary new
		    cookies: Dictionary new.
	response := aHandler handleRequest: request.
	self assert: response status = 200.
	self assert: response contentType = aMimeType.
	self assert: response stream contents = (aLibrary perform: aSymbol)
    ]

    testAsFileName [
	<category: 'testing'>
	| library |
	library := WAFileLibraryDemo new.
	self assert: (library asFilename: #mainJs) = 'main.js'.
	self assert: (library asFilename: #style2Css) = 'style2.css'.
	self assert: (library asFilename: #index) = 'index'
    ]

    testAsSelector [
	<category: 'testing'>
	self assert: (WAFileLibrary asSelector: 'main.css') = #mainCss.
	self assert: (WAFileLibrary asSelector: 'main.js') = #mainJs.
	self assert: (WAFileLibrary asSelector: 'style-2.css') = #style2Css.
	self assert: (WAFileLibrary asSelector: 'style_2.css') = #style2Css
    ]

    testAsSelectorCapitalized [
	<category: 'testing'>
	| library |
	library := WAFileLibraryDemo new.
	self assert: (library asSelector: 'COMMENTS.TXT') = #COMMENTSTxt.
	self assert: (library asFilename: #COMMENTSTxt) = 'COMMENTS.txt'
    ]

    testAsSelectorFunky [
	<category: 'testing'>
	self 
	    assert: (WAFileLibrary 
		    asSelector: '1_2$3-4/5()6!7   8.9.test 1 2 3 me 4 5 6 .txt') 
			= #test123me456Txt
    ]

    testAsSelectorLeadingDigits [
	<category: 'testing'>
	| library |
	library := WAFileLibraryDemo new.
	self assert: (library asSelector: '1readme.txt') = #readmeTxt.
	self assert: (library asSelector: '123456789readme.txt') = #readmeTxt.
	self assert: (library asSelector: '123456789readme89.txt') = #readme89Txt
    ]

    testCompileByteArray [
	<category: 'testing'>
	| library data file first second |
	library := WAFileLibraryDemo new.
	self deny: (library class selectors includes: #demoJpeg).
	data := (1 to: 255) asByteArray.
	file := (WAFile new)
		    contentType: 'image/jpeg' toMimeType;
		    contents: data;
		    fileName: 'demo.jpeg';
		    yourself.
	library addFile: file.
	self assert: (library class selectors includes: #demoJpeg).
	first := library perform: #demoJpeg.
	self assert: first = data.
	second := library perform: #demoJpeg.
	self assert: first == second.
	library removeFile: file fileName.
	self deny: (library class selectors includes: #demoJpeg)
    ]

    testCompileString [
	<category: 'testing'>
	| library data file first second source |
	library := WAFileLibraryDemo new.
	self deny: (library class selectors includes: #demoTxt).
	data := 'this is a string'.
	file := (WAFile new)
		    contentType: 'text/plain' toMimeType;
		    contents: data;
		    fileName: 'demo.txt';
		    yourself.
	library addFile: file.
	self assert: (library class selectors includes: #demoTxt).
	first := library perform: #demoTxt.
	self assert: first = data.
	second := library perform: #demoTxt.
	self assert: first == second.
	library removeFile: file fileName.
	self deny: (library class selectors includes: #demoTxt)
    ]

    testFileLibraryDemo [
	<category: 'testing'>
	| actual expected |
	actual := WAFileLibraryDemo new filenames.
	expected := #('main.css' 'main.jpg').
	self assert: actual size = expected size.
	expected do: [:each | self assert: (actual includes: each)]
    ]

    testFilenames [
	<category: 'testing'>
	| expected actual |
	expected := #(#editorCss #topJpg #mainCss #savePng).
	actual := WAHandlerEditorFiles new fileSelectors.
	"VW does not implement #= in Sets"
	self assert: actual size = expected size.
	expected do: [:each | self assert: (expected includes: each)]
    ]

    testIsBinary [
	<category: 'testing'>
	self deny: (WAFileLibraryDemo isBinary: 'scipt.js').
	self deny: (WAFileLibraryDemo isBinary: 'markup.xml').
	self deny: (WAFileLibraryDemo isBinary: 'markup.xhtml').
	self deny: (WAFileLibraryDemo isBinary: 'markup.html').
	self deny: (WAFileLibraryDemo isBinary: 'file.txt').
	self deny: (WAFileLibraryDemo isBinary: 'calendar.ics').
	self assert: (WAFileLibraryDemo isBinary: 'image.jpeg').
	self assert: (WAFileLibraryDemo isBinary: 'squeak.exe')
    ]

    testKalseyTabs [
	<category: 'testing'>
	| handler |
	handler := WAFileHandler new.
	self 
	    assertFile: 'kalseyTabs.css'
	    contentType: 'text/css' toMimeType
	    handler: handler
	    symbol: #kalseyTabsCss
	    library: WAStandardFiles new
    ]

    testKalseyTabsCascade [
	<category: 'testing'>
	| handler |
	handler := WAFileHandler new.
	self 
	    assertFile: 'kalseyTabs.css'
	    contentType: 'text/css' toMimeType
	    handler: handler
	    symbol: #kalseyTabsCss
	    library: WAStandardFiles new
    ]

    testLiveUpdate [
	<category: 'testing'>
	| handler |
	handler := WAFileHandler new.
	self 
	    assertFile: 'misc.js'
	    contentType: 'application/x-javascript' toMimeType
	    handler: handler
	    symbol: #miscJs
	    library: WAStandardFiles new
    ]

    testMainCss [
	<category: 'testing'>
	| handler |
	handler := WAFileHandler new.
	self 
	    assertFile: 'main.css'
	    contentType: 'text/css' toMimeType
	    handler: handler
	    symbol: #mainCss
	    library: WAFileLibraryDemo new
    ]

    testMainCssCascade [
	<category: 'testing'>
	| handler |
	handler := WAFileHandler new.
	self 
	    assertFile: 'main.css'
	    contentType: 'text/css' toMimeType
	    handler: handler
	    symbol: #mainCss
	    library: WAFileLibraryDemo new
    ]

    testMainJpg [
	<category: 'testing'>
	| handler library request response contents |
	handler := WAFileHandler new.
	library := WAFileLibraryDemo new.
	request := WARequest 
		    method: 'GET'
		    url: '/i/dont/care/WAFileLibraryDemo/main.jpg'
		    headers: Dictionary new
		    fields: Dictionary new
		    cookies: Dictionary new.
	response := handler handleRequest: request.
	self assert: response status = 200.
	self assert: response contentType = 'image/jpeg' toMimeType.
	contents := (response stream)
		    binary;
		    contents.
	self assert: contents asByteArray = (library perform: #mainJpg)
    ]

    testMainJs [
	<category: 'testing'>
	| handler request response |
	handler := WAFileHandler new.
	request := WARequest 
		    method: 'GET'
		    url: '/i/dont/care/main.js'
		    headers: Dictionary new
		    fields: Dictionary new
		    cookies: Dictionary new.
	response := handler handleRequest: request.
	self assert: response status = 404
    ]

    testMimeType [
	<category: 'testing'>
	| library |
	library := WAFileLibraryDemo new.
	self assert: (library mimetypeForFile: 'main.js') 
		    = 'application/x-javascript' toMimeType.
	self 
	    assert: (library mimetypeForFile: 'style2.css') = 'text/css' toMimeType.
	self 
	    assert: (library mimetypeForFile: 'image.jpg') = 'image/jpeg' toMimeType.
	self assert: (library mimetypeForFile: 'index') 
		    = 'application/octet-stream' toMimeType
    ]

    testNoneStatisfy [
	<category: 'testing'>
	self deny: (#(1 2 3) noneSatisfy: [:each | each even]).
	self assert: (#(1 3 5) noneSatisfy: [:each | each even])
    ]

    testStandardFiles [
	<category: 'testing'>
	| actual expected |
	actual := WAStandardFiles new filenames.
	expected := #('halo.css' 'kalseyTabs.css' 'toolbar.css' 'window.css' 'externalAnchors.js' 'misc.js' 'shortcuts.js' 'codebrowser.png' 'inspector.png' 'styleeditor.png' 'config.png' 'profiler.png' 'memory.png').
	"VW does not implement #= in Collection because you don't want that"
	self assert: actual size = expected size.
	expected do: [:each | self assert: (actual includes: each)]
    ]

    testUrlOf [
	<category: 'testing'>
	self assert: (WAStandardFiles / #seasideJpg) seasideString 
		    = ('/' , SeasidePlatformSupport defaultDispatcherName 
			    , '/files/WAStandardFiles/seaside.jpg')
    ]
]



TestCase subclass: WAFileSystemTest [
    | fileSystem |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    requestWithUrl: aString [
	<category: 'private'>
	^WARequest 
	    method: 'POST'
	    url: aString
	    headers: Dictionary new
	    fields: Dictionary new
	    cookies: Dictionary new
    ]

    setUp [
	<category: 'running'>
	super setUp.
	fileSystem := WAFileSystem new.
	fileSystem setName: 'culture'
    ]

    testAsAbsoluteUrlRelativeTo [
	<category: 'testing'>
	| request |
	fileSystem configuration valueAt: #directory put: '/home/philppe/pr0n'.
	request := self requestWithUrl: '/culture/pictures'.
	self 
	    assert: (fileSystem asAbsoluteUrl: 'cleopatra.jpeg' relativeTo: request) 
		    = '/culture/pictures/cleopatra.jpeg'.
	request := self requestWithUrl: '/culture/pictures/'.
	self 
	    assert: (fileSystem asAbsoluteUrl: 'cleopatra.jpeg' relativeTo: request) 
		    = '/culture/pictures/cleopatra.jpeg'
    ]

    testPathForRequest [
	<category: 'testing'>
	| request |
	fileSystem configuration valueAt: #directory put: '/home/philppe/pr0n'.
	request := self requestWithUrl: '/culture/cleopatra.jpeg'.
	self assert: (fileSystem pathForRequest: request) 
		    = '/home/philppe/pr0n/cleopatra.jpeg'.
	fileSystem configuration valueAt: #directory put: '/home/philppe/pr0n/'.
	self assert: (fileSystem pathForRequest: request) 
		    = '/home/philppe/pr0n/cleopatra.jpeg'
    ]
]



TestCase subclass: WAFileTest [
    | file |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    setUp [
	<category: 'running'>
	file := WAFile new
    ]

    testBorderline [
	<category: 'running'>
	file fileName: 'C'.
	self assert: file fileName = 'C'.
	file fileName: 'C:'.
	self assert: file fileName = 'C:'.
	file fileName: 'C:\'.
	self assert: file fileName = ''
    ]

    testNonLatinWindowsPath [
	<category: 'running'>
	"If the following assertion fails, your Smalltalk dialect most probably does not support non-latin characters. This is true for Squeak 3.7. If your Smalltalk dialect does support non-latin characters adjust the test."

	| koreanName |
	self shouldnt: 
		[koreanName := (UnicodeString 
			    with: (Character codePoint: 50976)
			    with: (Character codePoint: 47532)
			    with: (Character codePoint: 47484)) asString, '.txt']
	    raise: Error.
	file fileName: koreanName.
	self assert: file fileName = koreanName.
	file fileName: 'C:\important\' , koreanName.
	self assert: file fileName = koreanName
    ]

    testWindowsPath [
	<category: 'running'>
	file fileName: 'C:\important\passwords.txt'.
	self assert: file fileName = 'passwords.txt'.
	file fileName: '/important/passwords.txt'.
	self assert: file fileName = '/important/passwords.txt'.
	file fileName: 'passwords.txt'.
	self assert: file fileName = 'passwords.txt'
    ]
]



TestCase subclass: WAHtmlBuilderTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    testBody [
	<category: 'testing'>
	| actual |
	actual := WARenderCanvas builder 
		    render: [:html | html unorderedList: [html listItem: 'an item']].
	self assert: actual = '<ul><li>an item</li></ul>'
    ]

    testFullDocument [
	<category: 'testing'>
	| actual |
	actual := (WARenderCanvas builder)
		    fullDocument: true;
		    render: [:html | html unorderedList: [html listItem: 'an item']].
	self assert: actual 
		    = '<html><head><title></title></head><body><ul><li>an item</li></ul></body></html>'
    ]

    testFullDocumentWithBlock [
	<category: 'testing'>
	| actual |
	actual := (WARenderCanvas builder)
		    fullDocument: true;
		    rootBlock: [:root | root title: 'title'];
		    render: [:html | html unorderedList: [html listItem: 'an item']].
	self assert: actual 
		    = '<html><head><title>title</title></head><body><ul><li>an item</li></ul></body></html>'
    ]
]



TestCase subclass: WAHtmlRootTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    assert: aBlock gives: aString [
	<category: 'private'>
	| html |
	html := (WARenderCanvas builder)
		    callbackOwner: self;
		    fullDocument: true;
		    rootBlock: aBlock;
		    render: [:canvas | ].
	self 
	    assert: html = ('<html><head>' , aString , '</head><body></body></html>')
    ]

    testConditionalComment [
	<category: 'testing'>
	self assert: 
		[:html | 
		(html if)
		    greaterThan;
		    orEqual;
		    ie55;
		    do: 
			    [(html script)
				defer;
				url: 'http://www.example.com/bugs.js']]
	    gives: '<title></title><!--[if gte IE 5.5]><script defer="defer" src="http://www.example.com/bugs.js"></script><![endif]-->'.
	self assert: 
		[:html | 
		(html if)
		    not;
		    ie;
		    do: [html script url: 'http://www.example.com/bugs.js']]
	    gives: '<title></title><!--[if ! IE]><script src="http://www.example.com/bugs.js"></script><![endif]-->'
    ]

    testContentType [
	<category: 'testing'>
	self 
	    assert: [:html | html meta contentType: 'application/xhml+xml' toMimeType]
	    gives: '<title></title><meta http-equiv="Content-Type" content="application/xhml+xml"/>'.
	self assert: [:html | html meta contentType: 'application/xhml+xml']
	    gives: '<title></title><meta http-equiv="Content-Type" content="application/xhml+xml"/>'
    ]

    testJavascript [
	<category: 'testing'>
	self assert: [:html | html javascript add: 'true & false']
	    gives: '<title></title><script type="text/javascript">/*<![CDATA[*/true & false/*]]>*/</script>'
    ]

    testLinkElement [
	<category: 'testing'>
	self assert: 
		[:html | 
		(html stylesheet)
		    addAural;
		    addTeletype;
		    title: 'aTilte';
		    url: 'http://example.com/style.css']
	    gives: '<title></title><link rel="stylesheet" type="text/css" media="aural, tty" title="aTilte" href="http://example.com/style.css"/>'
    ]

    testLinkElementWithContent [
	<category: 'testing'>
	self assert: [:html | html stylesheet add: 'div > em { color: blue; }']
	    gives: '<title></title><style type="text/css">/*<![CDATA[*/div > em { color: blue; }/*]]>*/</style>'.
	self assert: [:html | html stylesheet add: 'E[foo$="bar"]']
	    gives: '<title></title><style type="text/css">/*<![CDATA[*/E[foo$="bar"]/*]]>*/</style>'
    ]

    testRevealedConditionalComment [
	<category: 'testing'>
	self assert: 
		[:html | 
		(html revealedIf)
		    ie7;
		    do: 
			    [(html script)
				defer;
				url: 'http://www.example.com/bugs.js']]
	    gives: '<title></title><!--[if IE 7]><!--><script defer="defer" src="http://www.example.com/bugs.js"></script><!--<![endif]-->'
    ]
]



TestCase subclass: WALocaleTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    testCountryName [
	<category: 'testing'>
	| locale |
	locale := WALocale fromString: 'de-CH'.
	self assert: locale countryName = 'SWITZERLAND'
    ]

    testIso3 [
	<category: 'testing'>
	| locale |
	locale := WALocale fromString: 'gsw-CHE'.
	self assert: locale language = 'gsw'.
	self assert: locale country = 'CHE'.
	self assert: locale seasideString = 'gsw-CHE'.
	locale := WALocale fromString: 'gsw_CHE'.
	self assert: locale language = 'gsw'.
	self assert: locale country = 'CHE'.
	self assert: locale seasideString = 'gsw-CHE'
    ]

    testLanguageName [
	<category: 'testing'>
	| locale |
	locale := WALocale fromString: 'de'.
	self assert: locale languageName = 'German'.
	locale := WALocale fromString: 'gsw'.
	self assert: locale languageName = 'Swiss German; Alemannic'
    ]

    testLangugeAndCountry [
	<category: 'testing'>
	| locale |
	locale := WALocale fromString: 'de-CH'.
	self assert: locale language = 'de'.
	self assert: locale country = 'CH'.
	self assert: locale seasideString = 'de-CH'.
	locale := WALocale fromString: 'de_CH'.
	self assert: locale language = 'de'.
	self assert: locale country = 'CH'.
	self assert: locale seasideString = 'de-CH'
    ]

    testLangugeOnly [
	<category: 'testing'>
	| locale |
	locale := WALocale fromString: 'de'.
	self assert: locale language = 'de'.
	self assert: locale country isNil.
	self assert: locale seasideString = 'de'
    ]
]



TestCase subclass: WAMimeTypeTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    testBasic [
	<category: 'testing'>
	| mimeType |
	mimeType := WAMimeType fromString: 'image/jpeg'.
	self assert: mimeType main = 'image'.
	self assert: mimeType sub = 'jpeg'.
	self assert: mimeType parameters isEmpty.
	self assert: mimeType seasideString = 'image/jpeg'
    ]

    testCharSet [
	<category: 'testing'>
	| mimeType |
	mimeType := WAMimeType fromString: 'text/html'.
	mimeType charset: 'utf-8'.
	self assert: mimeType seasideString = 'text/html;charset=utf-8'
    ]

    testEquals [
	<category: 'testing'>
	| first second |
	first := WAMimeType fromString: 'text/html'.
	second := WAMimeType fromString: 'text/html'.
	self assert: first = second.
	self assert: first hash = second hash.
	second charset: 'utf-8'.
	self assert: first = second.
	self assert: first hash = second hash.
	first charset: 'iso-8859-1'.
	self assert: first = second.
	self assert: first hash = second hash.
	second := WAMimeType fromString: 'text/xml'.
	self deny: first = second
    ]

    testIsBinary [
	<category: 'testing'>
	| notBinary binary |
	notBinary := #('text/plain' 'text/bar' 'application/x-javascript' 'application/xhml+xml' 'application/xml').
	notBinary do: 
		[:each | 
		| mimeType |
		mimeType := WAMimeType fromString: each.
		self deny: mimeType isBinary].
	binary := #('application/octet-stream' 'image/jpeg').
	binary do: 
		[:each | 
		| mimeType |
		mimeType := WAMimeType fromString: each.
		self assert: mimeType isBinary]
    ]

    testIsNonStandard [
	<category: 'testing'>
	| mimeType |
	mimeType := WAMimeType fromString: 'image/png'.
	self deny: mimeType isNonStandard.
	mimeType := WAMimeType fromString: 'image/x-icon'.
	self assert: mimeType isNonStandard.
	mimeType := WAMimeType fromString: 'image/X-icon'.
	self assert: mimeType isNonStandard.
	mimeType := WAMimeType fromString: 'x-icon/image'.
	self assert: mimeType isNonStandard.
	mimeType := WAMimeType fromString: 'X-icon/image'.
	self assert: mimeType isNonStandard
    ]

    testIsVendorSpecifc [
	<category: 'testing'>
	| mimeType |
	mimeType := WAMimeType fromString: 'image/png'.
	self deny: mimeType isVendorSpecific.
	mimeType := WAMimeType fromString: 'image/vnd.microsoft.icon'.
	self assert: mimeType isVendorSpecific.
	mimeType := WAMimeType fromString: 'vnd.microsoft.icon/image'.
	self deny: mimeType isVendorSpecific
    ]

    testMatches [
	<category: 'testing'>
	| pattern mimeType |
	pattern := WAMimeType fromString: 'image/png'.
	mimeType := WAMimeType fromString: 'image/png'.
	self assert: (mimeType matches: pattern).
	mimeType := WAMimeType fromString: 'image/gif'.
	self deny: (mimeType matches: pattern).
	pattern := WAMimeType fromString: 'image/*'.
	mimeType := WAMimeType fromString: 'image/png'.
	self assert: (mimeType matches: pattern).
	mimeType := WAMimeType fromString: 'text/html'.
	self deny: (mimeType matches: pattern).
	pattern := WAMimeType fromString: '*/*'.
	mimeType := WAMimeType fromString: 'image/png'.
	self assert: (mimeType matches: pattern)
    ]

    testParamters [
	<category: 'testing'>
	^#('text/html;charset=utf-8' 'text/html; charset=utf-8') do: 
		[:each | 
		| mimeType |
		mimeType := WAMimeType fromString: each.
		self assert: mimeType main = 'text'.
		self assert: mimeType sub = 'html'.
		self assert: mimeType parameters size = 1.
		self assert: (mimeType parameters at: 'charset') = 'utf-8'.
		self assert: mimeType seasideString = 'text/html;charset=utf-8']
    ]

    testTo [
	<category: 'testing'>
	| mimeType |
	mimeType := 'image/jpeg' toMimeType.
	self assert: (mimeType isKindOf: WAMimeType).
	self assert: mimeType main = 'image'.
	self assert: mimeType sub = 'jpeg'.
	self assert: mimeType parameters isEmpty.
	self assert: mimeType seasideString = 'image/jpeg'.
	mimeType := mimeType toMimeType.
	self assert: (mimeType isKindOf: WAMimeType)
    ]
]



TestCase subclass: WAPlatformTest [
    
    <comment: 'A WAPlatformTest is a test to make sure the platform (= the Smalltalk dialect we are running on) implements the protocol we need for system classes like Collection. An example would be to make sure Collection implements #count: with the sementics we need.'>
    <category: 'Seaside-Tests-Unit'>

    testAddFirst [
	<category: 'testing'>
	| strings |
	strings := #('b' 'c' 'd') asOrderedCollection.
	strings addFirst: 'a'.
	self 
	    assert: strings = ((OrderedCollection new)
			    add: 'a';
			    add: 'b';
			    add: 'c';
			    add: 'd';
			    yourself)
    ]

    testAsInteger [
	<category: 'testing'>
	self assert: 2007 asInteger = 2007.
	self assert: '2007' asInteger = 2007.
	self assert: (['foo' asInteger] on: Error do: [:e | 0]) = 0
    ]

    testAsMIMEDocument [
	<category: 'testing'>
	| document |
	document := 'hello Seaside' asMIMEDocumentType: 'text/plain' toMimeType.
	self assert: document contentType = 'text/plain'.
	self assert: document content = 'hello Seaside'.
	self 
	    assert: (document asMIMEDocumentType: 'text/plain' toMimeType) == document
    ]

    testAsNumber [
	<category: 'testing'>
	self assert: 2007 asNumber = 2007.
	self assert: '2007' asNumber = 2007
    ]

    testAsTwoCharacterString [
	<category: 'testing'>
	self assert: 2 asTwoCharacterString = '02'.
	self assert: 11 asTwoCharacterString = '11'.
	self assert: 1943 asTwoCharacterString = '19'.
	self assert: 0 asTwoCharacterString = '00'.
	self assert: -2 asTwoCharacterString = '-2'.
	self assert: -234 asTwoCharacterString = '-2'
    ]

    testAsUppercase [
	<category: 'testing'>
	self assert: 'abc' asUppercase = 'ABC'.
	self assert: 'ABC' asUppercase = 'ABC'
    ]

    testAtRandom [
	"don't change this to an Interval, we want to test SequenceableCollection"

	<category: 'testing'>
	self assert: (#(0 1 2 3 4 5 6 7 8 9) atRandom between: 0 and: 9).

	"don't change this to an Interval, we want to test SequenceableCollection"
	self 
	    assert: ((#(0 1 2 3 4 5 6 7 8 9) 
		    atRandom: SeasidePlatformSupport randomClass new) between: 0 and: 9).
	self assert: (9 between: 1 and: 9)
    ]

    testBeMutable [
	<category: 'testing'>
	self shouldnt: [Object new beMutable] raise: MessageNotUnderstood
    ]

    testBetweenAnd [
	<category: 'testing'>
	self assert: (6 between: 1 and: 12)
    ]

    testBlockContextWithPossibleArgument [
	<category: 'testing'>
	| block |
	block := [:x | 1 + x].
	self assert: (block valueWithPossibleArgument: 2) = 3.
	block := [false not].
	self assert: (block valueWithPossibleArgument: 3)
    ]

    testCapitalized [
	<category: 'testing'>
	self assert: 'capitalized' capitalized = 'Capitalized'.
	self assert: 'Capitalized' capitalized = 'Capitalized'.
	self assert: 'CAPITALIZED' capitalized = 'CAPITALIZED'.
	self assert: #capitalized capitalized = #Capitalized.
	self assert: #Capitalized capitalized = #Capitalized.
	self assert: #CAPITALIZED capitalized = #CAPITALIZED
    ]

    testCharacterAsUnicode [
	"test for:
	 Character >> #asUnicode
	 ^self asInteger"

	<category: 'testing'>
	self assert: $S codePoint = 83
    ]

    testCharacterTo [
	<category: 'testing'>
	| actual expected |
	actual := ($a to: $z) , ($A to: $Z) , ($0 to: $9) 
		    , (Array with: $_ with: $-) collect: [:each | each asInteger].
	expected := #(97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 48 49 50 51 52 53 54 55 56 57 95 45).
	self assert: actual size = expected size.
	actual with: expected do: [:first :second | self assert: first = second]
    ]

    testCopyAfter [
	<category: 'testing'>
	self assert: ('de_CH' copyAfter: $_) = 'CH'
    ]

    testCopyAfterLast [
	<category: 'testing'>
	self assert: ('britney.sex.tape.mkv' copyAfterLast: $.) = 'mkv'
    ]

    testCopyUpToLast [
	<category: 'testing'>
	self 
	    assert: ('britney.sex.tape.mkv' copyUpToLast: $.) = 'britney.sex.tape'
    ]

    testCount [
	<category: 'testing'>
	self assert: (#(1 2 3) count: [:each | each odd]) = 2
    ]

    testDaysInMonthForYear [
	<category: 'testing'>
	(1 to: 12) with: #(31 28 31 30 31 30 31 31 30 31 30 31)
	    do: [:month :days | self assert: days = (Date daysInMonthNumber: month forYear: 2007)]
    ]

    testDefaultPathName [
	<category: 'testing-files'>
	self deny: SeasidePlatformSupport defaultDirectoryName isNil.
	self deny: SeasidePlatformSupport defaultDirectoryName isEmpty
    ]

    testEmptyOrNil [
	<category: 'testing'>
	self assert: '' isEmptyOrNil.
	self assert: nil isEmptyOrNil.
	self assert: Array new isEmptyOrNil.
	self deny: 'Timberwolf' isEmptyOrNil
    ]

    testFindTokens [
	<category: 'testing'>
	| mimeType tokens |
	mimeType := 'application/xhtml+xml'.
	tokens := mimeType findTokens: '/'.
	self assert: tokens size = 2.
	self assert: tokens first = 'application'.
	self assert: tokens second = 'xhtml+xml'
    ]

    testFixCallbackTemps [
	"Make sure that #fixCallbackTemps is properly understood by block-contexts. Make sure that this is either a nop for Smalltalks with true block closures, or it properly fixes the context otherwise."

	<category: 'testing'>
	| array blocks values |
	array := #(1 2 3).
	blocks := array collect: [:each | [each] fixCallbackTemps].
	values := blocks collect: [:each | each value].
	self assert: values = array
    ]

    testGarbageCollect [
	"if you miss this do a class extension"

	<category: 'testing'>
	self shouldnt: [Smalltalk garbageCollect] raise: MessageNotUnderstood
    ]

    testIfNil [
	<category: 'testing'>
	self assert: (nil ifNil: [1]) = 1.
	self assert: (1 ifNil: [2]) = 1
    ]

    testIncludesSubString [
	<category: 'testing'>
	self assert: ('britney.sex.tape.mkv' startsWith: 'britney').
	self deny: ('britney.sex.tape.mkv' startsWith: 'sex')
    ]

    testIsKeyword [
	<category: 'testing'>
	self deny: #isKeyword isKeyword.
	self deny: #+ isKeyword.
	self assert: #isKeyword: isKeyword.
	self assert: #isKeyword:isKeyword: isKeyword
    ]

    testIsUnary [
	<category: 'testing'>
	self assert: #isUnary isUnary.
	self deny: #+ isUnary.
	self deny: #isUnary: isUnary.
	self deny: #isUnary:isUnary: isUnary
    ]

    testMessageSendValueWithPossibleArgument [
	"test for:
	 MessageSend >> #valueWithPossibleArgument: anArg
	 
	 self numArgs = 0 ifTrue: [^self value].
	 self numArgs = 1 ifTrue: [^self value: anArg].
	 self numArgs  > 1 ifTrue: [^self valueWithArguments: {anArg}, (Array new: self numArgs  - 1)]"

	<category: 'testing'>
	| send |
	send := DirectedMessage receiver: 1 selector: #+.
	self assert: (send valueWithPossibleArgument: 2) = 3.
	send := DirectedMessage receiver: false selector: #not.
	self assert: (send valueWithPossibleArgument: 3)
    ]

    testNewDayMonthNumberYear [
	<category: 'testing'>
	| date |
	date := Date 
		    newDay: 6
		    monthNumber: 11
		    year: 2007.
	self assert: date year = 2007.
	self assert: date dayOfYear = 310
    ]

    testPaddedToWith [
	<category: 'testing'>
	self assert: ('X' 
		    padded: #left
		    to: 2
		    with: $0) = '0X'.
	self assert: ('XX' 
		    padded: #left
		    to: 2
		    with: $0) = 'XX'
    ]

    testPlatformString [
	<category: 'testing-accessing'>
	self deny: SeasidePlatformSupport versionString isNil.
	self deny: SeasidePlatformSupport versionString isEmpty
    ]

    testPrintStringAsCents [
	<category: 'testing'>
	self assert: 523 printStringAsCents = '$5.23'
    ]

    testPrintStringBase [
	<category: 'testing'>
	self assert: (15 printStringBase: 16) = 'F'.
	self assert: (16 printStringBase: 16) = '10'
    ]

    testRemoveAllFoundIn [
	<category: 'testing'>
	| actual |
	actual := #(1 2 3) asOrderedCollection.
	actual removeAllFoundIn: #(1 2).
	self assert: actual size = 1.
	self assert: actual first = 3
    ]

    testSeconds [
	<category: 'testing'>
	self assert: Time now seconds isInteger.
	self deny: Time now seconds isFraction
    ]

    testShutDownList [
	"A smoke test: checks if the test-class can be added and removed to the shutdown list."

	<category: 'testing-image'>
	[SeasidePlatformSupport addToShutDownList: self class] 
	    ensure: [SeasidePlatformSupport removeFromShutDownList: self class]
    ]

    testStartUpList [
	"A smoke test: checks if the test-class can be added and removed to the startup list."

	<category: 'testing-image'>
	[SeasidePlatformSupport addToStartUpList: self class] 
	    ensure: [SeasidePlatformSupport removeFromStartUpList: self class]
    ]

    testStreamClosed [
	"test for:
	 Stream >> #closed
	 ^false"

	<category: 'testing'>
	self deny: 'Seaside' readStream closed
    ]

    testSymbolAsMutator [
	"test for:
	 Symbol >> #asMutator
	 ^ (self copyWith: $:) asSymbol"

	<category: 'testing'>
	self assert: #name asMutator = #name:
    ]

    testToString [
	<category: 'testing'>
	self assert: 'Timberwolf' seasideString = 'Timberwolf'.
	self assert: #DireWolf seasideString = 'DireWolf'.
	self assert: true seasideString = 'true'.
	self assert: 666 seasideString = '666'.
	self assert: $A seasideString = 'A'.
	self assert: nil seasideString = 'nil'.
	[1 / 0] on: ZeroDivide
	    do: [:error | self assert: error seasideString = 'ZeroDivide'].
	self assert: 15.25 seasideString isString.
	self assert: 15.25 seasideString asNumber = 15.25.
	self assert: nil seasideString isString.
	self assert: (4 @ 2) seasideString = '4@2'.
	self assert: #(101 97) asByteArray seasideString = 'ea'.
	self assert: Object new seasideString isString
    ]

    testTotalSeconds [
	"Answer the total seconds since the Squeak epoch: 1 January 1901."

	<category: 'testing'>
	| seconds |
	seconds := Time secondClock.
	self assert: seconds isInteger
    ]

    testTrimBlanks [
	<category: 'testing'>
	self assert: '	abc ' trimSeparators = 'abc'
    ]

    testVersionString [
	<category: 'testing-accessing'>
	self deny: SeasidePlatformSupport platformString isNil.
	self deny: SeasidePlatformSupport platformString isEmpty
    ]
]



TestCase subclass: WAResponseTest [
    | response |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    setUp [
	<category: 'running'>
	response := WAResponse new
    ]

    testCaching [
	<category: 'testing'>
	self assert: response headers isEmpty.
	response cacheForever.
	self assert: (response headerAt: 'Expires') value 
		    = 'Thu, 01 Jan 2095 12:00:00 GMT'.
	self assert: response headers size = 1
    ]

    testDoNotCache [
	<category: 'testing'>
	self assert: response headers isEmpty.
	response doNotCache.
	self assert: (response headerAt: 'Cache-Control') value 
		    = 'no-cache, must-revalidate'.
	self assert: (response headerAt: 'Expires') value 
		    = 'Thu, 11 Jun 1980 12:00:00 GMT'.
	self assert: (response headerAt: 'Pragma') value = 'no-cache'.
	self assert: response headers size = 3
    ]
]



TestCase subclass: WAUrlTest [
    | url |
    
    <comment: nil>
    <category: 'Seaside-Tests-Unit'>

    setUp [
	<category: 'running'>
	url := WAUrl new
    ]

    testAddParamter [
	<category: 'testing-adding'>
	url addToPath: 'files'.
	self assert: url seasideString = '/files'.
	url addParameter: 'x'.
	self assert: url seasideString = '/files?x'.
	url addParameter: 'y' value: 1.
	self assert: url seasideString = '/files?x&y=1'
    ]

    testAddToPath [
	<category: 'testing-adding'>
	url addToPath: '/files/WAStandardFiles/seaside.jpg'.
	self assert: url seasideString = '/files/WAStandardFiles/seaside.jpg'
    ]

    testEqual [
	<category: 'testing-comparing'>
	url
	    hostname: 'seaside.st';
	    addParameter: 'foo' value: 'bar'.
	self assert: url = url.
	self deny: url = WAUrl new.
	self deny: url = url printString.
	self deny: url = url withoutParameters.
	self deny: url = (url withParameter: 'zork').
	self deny: url = (url withParameter: 'zork' value: 'zonk')
    ]

    testFragment [
	<category: 'testing'>
	url fragment: 'id'.
	self assert: url fragment = 'id'.
	self assert: url seasideString = '#id'
    ]

    testHash [
	<category: 'testing-comparing'>
	url hostname: 'seaside.st'.
	self assert: url hash = url hash.
	self assert: url hash = url copy hash
    ]

    testHostname [
	<category: 'testing'>
	url hostname: 'seaside.st'.
	self assert: url hostname = 'seaside.st'.
	self assert: url seasideString = 'http://seaside.st'
    ]

    testParameters [
	<category: 'testing'>
	url parameters at: '1' put: nil.
	self assert: url seasideString = '?1'.
	url parameters at: '2' put: 'foo'.
	self assert: url seasideString = '?1&2=foo'.
	url parameters at: '3' put: 123.
	self assert: url seasideString = '?1&2=foo&3=123'.
	url parameters at: '4' put: 'foo bar&zork'.
	self assert: url seasideString = '?1&2=foo&3=123&4=foo+bar%26zork'
    ]

    testPassword [
	<category: 'testing'>
	url
	    hostname: 'seaside.st';
	    username: 'foo';
	    password: 'bar'.
	self assert: url password = 'bar'.
	self assert: url seasideString = 'http://foo:bar@seaside.st'
    ]

    testPath [
	<category: 'testing'>
	self assert: url seasideString = ''.
	url path add: 'aa'.
	self assert: url seasideString = '/aa'.
	url path add: 'bb'.
	self assert: url seasideString = '/aa/bb'.
	self assert: url path asArray = #('aa' 'bb')
    ]

    testPathEncoding [
	<category: 'testing-encoding'>
	url path: #('foo/bar').
	self assert: url printString = '/foo%2Fbar'.
	url path: #('foo bar').
	self assert: url printString = '/foo+bar'.
	url path: #('foo+bar').
	self assert: url printString = '/foo%2Bbar'.
	url path: #('foo%bar').
	self assert: url printString = '/foo%25bar'
    ]

    testPort [
	<category: 'testing'>
	url
	    hostname: 'seaside.st';
	    port: 8080.
	self assert: url port = 8080.
	self assert: url seasideString = 'http://seaside.st:8080'
    ]

    testQueryEncoding [
	<category: 'testing-encoding'>
	self assert: (url withParameter: '/' value: ' ') printString = '?%2F=+'.
	self assert: (url withParameter: '+' value: '%') printString = '?%2B=%25'.
	self assert: (url withParameter: '?' value: '&') printString = '?%3F=%26'.
	self assert: (url withParameter: '[' value: ']') printString = '?%5B=%5D'.
	self assert: (url withParameter: '=' value: '<') printString = '?%3D=%3C'
    ]

    testScheme [
	<category: 'testing'>
	url
	    scheme: 'https';
	    hostname: 'seaside.st'.
	self assert: url scheme = 'https'.
	self assert: url seasideString = 'https://seaside.st'.
	"Tests from Boris"
	url hostname: 'seaside.st'.
	url
	    port: 80;
	    scheme: 'http'.
	self assert: url seasideString = 'http://seaside.st'.
	url
	    port: 443;
	    scheme: 'https'.
	self assert: url seasideString = 'https://seaside.st'.
	url
	    port: 80;
	    scheme: #http.
	self assert: url seasideString = 'http://seaside.st'.
	url
	    port: 443;
	    scheme: #https.
	self assert: url seasideString = 'https://seaside.st'
    ]

    testUsername [
	<category: 'testing'>
	url
	    hostname: 'seaside.st';
	    username: 'foo'.
	self assert: url username = 'foo'.
	self assert: url seasideString = 'http://foo@seaside.st'
    ]
]



Eval [
    WAAllTests initialize.
    WADateSelectorTest initialize.
    WAExpirySession initialize
]

