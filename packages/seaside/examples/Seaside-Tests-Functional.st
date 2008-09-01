WAComponent subclass: WAAllTests [
    | navigation |
    
    <comment: 'If you want to see these examples:

/seaside/config app:
- add a new application named "tests"
- choose WAAllTests as the root component
'>
    <category: 'Seaside-Tests-Functional'>

    WAAllTests class >> canBeRoot [
	<category: 'testing'>
	^true
    ]

    WAAllTests class >> description [
	<category: 'accessing'>
	^'Functional Seaside Test Suite'
    ]

    WAAllTests class >> initialize [
	<category: 'initialization'>
	(self registerAsApplication: 'tests/alltests') preferenceAt: #sessionClass
	    put: WAExpirySession
    ]

    children [
	<category: 'accessing'>
	^Array with: navigation
    ]

    initialize [
	<category: 'initialize-release'>
	| components |
	super initialize.
	components := SortedCollection 
		    sortBlock: [:a :b | a label caseInsensitiveLessOrEqual: b label].
	WAFunctionalTest allSubclassesDo: [:each | components add: each new].
	WAFunctionalTaskTest allSubclassesDo: [:each | components add: each new].
	components add: (WAParentTest new parent: self).
	navigation := WASimpleNavigation new.
	components do: [:each | navigation add: each label: each label]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html div)
	    id: 'all-tests';
	    with: 
		    [html heading: 'Functional Seaside Test Suite'.
		    html render: navigation]
    ]
]



WAComponent subclass: WAFunctionalTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	self subclassResponsibility
    ]
]



WAFunctionalTest subclass: WABatchTest [
    | batcher |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    children [
	<category: 'accessing'>
	^Array with: batcher
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	batcher := WAAlphabeticBatchedList new items: Collection allSubclasses
    ]

    label [
	<category: 'accessing'>
	^'Batch'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html render: batcher.
	html unorderedList list: batcher batch
    ]
]



WAFunctionalTest subclass: WAButtonTest [
    | input |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self input: 'a text'
    ]

    input [
	<category: 'accessing'>
	^input
    ]

    input: aString [
	<category: 'accessing'>
	input := aString
    ]

    label [
	<category: 'accessing'>
	^'Button'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html form: 
		[html div: 
			[self renderInputOn: html.
			self renderSubmitOn: html.
			self renderResetOn: html.
			self renderPushOn: html]]
    ]

    renderInputOn: html [
	<category: 'rendering'>
	html table: 
		[html tableRow: 
			[html tableHeading: 'Value:'.
			html tableData: self input].
		html tableRow: 
			[html tableHeading: 'Input:'.
			html tableData: [html textInput on: #input of: self]]]
    ]

    renderPushOn: html [
	<category: 'rendering'>
	html heading level2 with: 'Push'.
	html paragraph: 'Clicking the button should not do anything.'.
	(html button)
	    bePush;
	    with: 'Push'
    ]

    renderResetOn: html [
	<category: 'rendering'>
	html heading level2 with: 'Reset'.
	html 
	    paragraph: 'Clicking the button should not submit the form reset the value in "Input"'.
	(html button)
	    beReset;
	    with: 'Reset'
    ]

    renderSubmitOn: html [
	<category: 'rendering'>
	html heading level2 with: 'Submit'.
	html 
	    paragraph: 'Clicking the button should submit the form and update the value in "Value:" with the value in "Input"'.
	html button with: 'Submit'
    ]
]



WAFunctionalTest subclass: WACacheTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Cache'
    ]

    renderActionsOn: html [
	<category: 'rendering'>
	html paragraph: 
		[(html anchor)
		    callback: [self inform: 'answer'];
		    with: 'call'.
		html text: ' (answer: +1, escape: +1)'.
		html break.
		(html anchor)
		    callback: [self call: self class new];
		    with: 'keep calling'.
		html text: ' (answer: +1, escape: +1)'.
		html break.
		(html anchor)
		    callback: [self session redirect];
		    with: 'redirect'.
		html text: ' (response: +1, escape: +1)']
    ]

    renderContentOn: html [
	<category: 'rendering'>
	Smalltalk garbageCollect.
	self renderStatisticsOn: html.
	self renderActionsOn: html
    ]

    renderStatisticsOn: html [
	<category: 'rendering'>
	html paragraph: 
		[html
		    strong: 'Response Continuations: ';
		    text: ResponseContinuation allInstances size;
		    break.
		html
		    strong: 'Answer Continuations: ';
		    text: AnswerContinuation allInstances size;
		    break.
		html
		    strong: 'Escape Continuations: ';
		    text: EscapeContinuation allInstances size;
		    break]
    ]
]



WAFunctionalTest subclass: WACallbackTest [
    | transcript counter |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    children [
	<category: 'accessing'>
	^Array with: counter
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	transcript := String new writeStream.
	counter := WACounter new
    ]

    label [
	<category: 'accessing'>
	^'Callback'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html anchor)
	    callback: [];
	    with: 'Idempotent'.
	html space.
	(html anchor)
	    callback: [];
	    with: 'Side Effect'.
	(html form)
	    defaultAction: 
		    [transcript
			cr;
			nextPutAll: 'default action'];
	    with: 
		    [html textInput callback: 
			    [:v | 
			    transcript
				cr;
				nextPutAll: 'text: ';
				nextPutAll: v printString].
		    html textInput callback: 
			    [:v | 
			    transcript
				cr;
				nextPutAll: 'text2: ';
				nextPutAll: v printString].
		    html break.
		    html submitButton.
		    html space.
		    (html submitButton)
			callback: 
				[transcript
				    cr;
				    nextPutAll: 'go'];
			text: 'Go'.
		    html space.
		    (html cancelButton)
			callback: 
				[transcript
				    cr;
				    nextPutAll: 'cancel'];
			text: 'Cancel'].
	html preformatted: transcript contents.
	html horizontalRule.
	html render: counter
    ]
]



WAFunctionalTest subclass: WACanvasTableTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    entities [
	<category: 'samples'>
	^#(#('non-breaking space' #('&nbsp;' '&#160;' '&#xA0;')) #('ampersand' #('&amp;' '&#38;' '&#x26;')) #('less than sign' #('&lt;' '&#60;' '&#x3C;')) #('greater than sign' #('&gt;' '&#62;' '&#x3E;')) #('euro sign' #('&euro;' '&#8364;' '&#x20AC;')))
    ]

    exchangeRates [
	<category: 'samples'>
	^#(#('EUR' 1.7) #('USD' 1.3) #('DKK' 23.36) #('SEK' 19.32))
    ]

    label [
	<category: 'accessing'>
	^'Table'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'wacanvastabletest';
	    with: 
		    [self renderEntityTableOn: html.
		    self renderCurrencyTableOn: html]
    ]

    renderCurrencyTableBodyOn: html [
	<category: 'rendering'>
	(html tableBody)
	    title: 'Table body';
	    with: 
		    [self exchangeRates do: 
			    [:each | 
			    html tableRow: 
				    [html tableHeading: each first.
				    (html tableData)
					align: 'char';
					character: $.;
					with: each second]]]
    ]

    renderCurrencyTableHeadOn: html [
	<category: 'rendering'>
	(html tableHead)
	    title: 'Table header';
	    with: 
		    [html tableRow: 
			    [html tableHeading: 'Currency'.
			    html tableHeading: 'Rate']]
    ]

    renderCurrencyTableOn: html [
	<category: 'rendering'>
	(html table)
	    summary: 'This table shows exchange rates against the Swiss Franc';
	    with: 
		    [html tableCaption: 'Currencies against Swiss Franc (CHF)'.
		    html tableColumnGroup.
		    (html tableColumnGroup)
			width: '100px';
			align: 'char';
			character: $..
		    self renderCurrencyTableHeadOn: html.
		    self renderCurrencyTableBodyOn: html]
    ]

    renderEntityTableBodyOn: html [
	<category: 'rendering'>
	html tableBody: 
		[self entities do: 
			[:eachEntity | 
			html tableRow: 
				[(html tableData)
				    scope: 'row';
				    with: eachEntity first.
				eachEntity second do: [:each | html tableData: each].
				eachEntity second do: 
					[:each | 
					(html tableData)
					    align: 'center';
					    with: [html html: each]]]]]
    ]

    renderEntityTableColumnGroupsOn: html [
	<category: 'rendering'>
	html tableColumnGroup.
	html tableColumnGroup span: 3.
	(html tableColumnGroup)
	    span: 3;
	    align: 'center'
    ]

    renderEntityTableFootOn: html [
	<category: 'rendering'>
	html tableFoot: 
		[html tableRow: 
			[(html tableData)
			    align: 'center';
			    colSpan: 7;
			    with: '5 entities shown']]
    ]

    renderEntityTableHeadOn: html [
	<category: 'rendering'>
	html tableHead: 
		[html tableRow: 
			[#('Character' 'Entity' 'Decimal' 'Hex') do: 
				[:each | 
				(html tableHeading)
				    scope: 'col';
				    rowSpan: 2;
				    with: each].
			(html tableHeading)
			    scope: 'colgroup';
			    colSpan: 3;
			    with: 'Rendering in Your Browser'].
		html tableRow: 
			[#('Entity' 'Decimal' 'Hex') do: 
				[:each | 
				(html tableHeading)
				    scope: 'col';
				    with: each]]]
    ]

    renderEntityTableOn: html [
	<category: 'rendering'>
	(html table)
	    summary: 'This table gives the character entity reference,
                decimal character reference, and hexadecimal character
                reference for 8-bit Latin-1 characters, as well as the
                rendering of each in your browser.';
	    with: 
		    [html tableCaption: 'HTML 4.0 entities'.
		    self renderEntityTableColumnGroupsOn: html.
		    self renderEntityTableHeadOn: html.
		    self renderEntityTableFootOn: html.
		    self renderEntityTableBodyOn: html]
    ]

    style [
	<category: 'rendering'>
	^'
.wacanvastabletest table {
	border-collapse: collapse;
	border:1px solid black;
	margin:0px auto; /* center */
}

.wacanvastabletest caption {
	margin:0px auto; /* center */
}
.wacanvastabletest caption {
	font-weight: bold;
	padding: 0.5em 0 1em 0;
}
.wacanvastabletest td, .wacanvastabletest th {
	padding: 3px;
	border:1px solid black;
}
'
    ]
]



WAFunctionalTest subclass: WAClosureTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    ensure [
	<category: 'actions'>
	[self go] ensure: [self inform: 'ensure']
    ]

    go [
	<category: 'actions'>
	#(#a #b #c) 
	    keysAndValuesDo: [:a :b | self inform: a seasideString , ' ' , b seasideString]
    ]

    label [
	<category: 'accessing'>
	^'Closure'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html anchor)
	    callback: [self go];
	    with: 'go'.
	html space.
	(html anchor)
	    callback: [self ensure];
	    with: 'go with ensure'
    ]
]



WAFunctionalTest subclass: WACookieTest [
    | key value |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    add [
	<category: 'actions'>
	| response |
	self session respond: 
		[:url | 
		response := self session redirectResponseFor: url.
		response addCookie: (WACookie key: key value: value).
		response].
	key := value := nil
    ]

    cookies [
	<category: 'accessing'>
	^self session currentRequest cookies
    ]

    label [
	<category: 'accessing'>
	^'Cookies'
    ]

    remove: aKey [
	<category: 'actions'>
	| response |
	self session respond: 
		[:url | 
		response := self session redirectResponseFor: url.
		response deleteCookieAt: aKey.
		response]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html form: 
		[html table: 
			[html tableRow: 
				[html tableHeading: 'Key'.
				html tableHeading: 'Value'.
				html tableHeading].
			self cookies keysAndValuesDo: 
				[:k :v | 
				html tableRow: 
					[html tableData: k.
					html tableData: v.
					html tableData: 
						[(html submitButton)
						    callback: [self remove: k];
						    text: 'remove']]].
			html tableRow: 
				[html tableData: 
					[(html textInput)
					    value: key;
					    callback: [:v | key := v]].
				html tableData: 
					[(html textInput)
					    value: value;
					    callback: [:v | value := v]].
				html tableData: [html submitButton on: #add of: self]]]]
    ]
]



WAFunctionalTest subclass: WADateSelectorTest [
    | beginDate endDate beginTime endTime beginDAT endDAT |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    WADateSelectorTest class >> example [
	<category: 'examples'>
	^self new
    ]

    WADateSelectorTest class >> initialize [
	<category: 'class initialization'>
	self registerAsApplication: 'tests/dateselector'
    ]

    children [
	<category: 'accessing'>
	^(OrderedCollection new)
	    add: beginDate;
	    add: endDate;
	    add: beginTime;
	    add: endTime;
	    add: beginDAT;
	    add: endDAT;
	    yourself
    ]

    computeDuration [
	<category: 'actions'>
	| dateDiff |
	dateDiff := (endDAT dateAndTime asDate - beginDAT dateAndTime asDate) days.
	dateDiff isZero 
	    ifFalse: [self inform: dateDiff seasideString , ' day(s)']
	    ifTrue: 
		[self 
		    inform: (endDAT dateAndTime asTime 
			    subtractTime: beginDAT dateAndTime asTime) asSeconds 
			    seasideString , ' second(s)']
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	beginDate := WADateSelector new.
	endDate := WADateSelector new.
	endDate date: (Date today addDays: 1).
	beginTime := WATimeSelector new.
	beginTime time: Time now.
	endTime := WATimeSelector new.
	endTime time: (beginTime time addSeconds: 3600).
	beginDAT := WADateTimeSelector new.
	endDAT := WADateTimeSelector new.
	endDAT dateAndTime: beginDAT dateAndTime + 1 day + 1 hour
    ]

    label [
	<category: 'accessing'>
	^'Date Selector'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderDateSelectorsOn: html.
	html horizontalRule.
	self renderTimeSelectorsOn: html.
	html horizontalRule.
	self renderDateTimeSelectorsOn: html
    ]

    renderDateSelectorsOn: html [
	<category: 'rendering'>
	(html heading)
	    level3;
	    with: 'Dates'.
	html form: 
		[html table: 
			[html tableRow: 
				[html
				    tableData: 'From';
				    tableData: beginDate].
			html tableRow: 
				[html
				    tableData: 'To';
				    tableData: endDate]].
		(html submitButton)
		    callback: 
			    [self inform: (endDate date - beginDate date) days seasideString , ' day(s)'];
		    text: 'Compute duration']
    ]

    renderDateTimeSelectorsOn: html [
	<category: 'rendering'>
	(html heading)
	    level3;
	    with: 'Dates and Times'.
	html form: 
		[html table: 
			[html tableRow: 
				[html
				    tableData: 'From';
				    tableData: beginDAT].
			html tableRow: 
				[html
				    tableData: 'To';
				    tableData: endDAT]].
		(html submitButton)
		    callback: [self computeDuration];
		    text: 'Compute duration']
    ]

    renderTimeSelectorsOn: html [
	<category: 'rendering'>
	(html heading)
	    level3;
	    with: 'Times'.
	html form: 
		[html table: 
			[html tableRow: 
				[html
				    tableData: 'From';
				    tableData: beginTime].
			html tableRow: 
				[html
				    tableData: 'To';
				    tableData: endTime]].
		(html submitButton)
		    callback: 
			    [self 
				inform: (endTime time subtractTime: beginTime time) asSeconds seasideString 
					, ' seconds(s)'];
		    text: 'Compute duration']
    ]
]



WAFunctionalTest subclass: WADateTimeTest [
    | data numericData date time data1 data2 message |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    data1 [
	<category: 'accessing'>
	^data1
    ]

    data1: aString [
	<category: 'accessing'>
	data1 := aString
    ]

    data2 [
	<category: 'accessing'>
	^data2
    ]

    data2: aString [
	<category: 'accessing'>
	data2 := aString
    ]

    date [
	<category: 'accessing'>
	^date
    ]

    date: aDate [
	<category: 'accessing'>
	date := aDate
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	data1 := 'Harry'.
	data2 := 'Covert'.
	data := String new.
	message := String new.
	numericData := 12
    ]

    label [
	<category: 'accessing'>
	^'Date and Time Selector'
    ]

    numericData [
	<category: 'accessing'>
	^numericData
    ]

    numericData: aString [
	<category: 'accessing'>
	numericData := aString
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderSubmitFormOn: html.
	self renderDateTimeOn: html.
	self renderDeadDateTimeOn: html
    ]

    renderDateTimeOn: html [
	<category: 'rendering'>
	(html heading)
	    level3;
	    with: 'Form with #dateInput and #timeInput'.
	(html form)
	    defaultAction: 
		    [message := 'Default action: ' , date seasideString , ' ' , time seasideString];
	    with: 
		    [html div: 
			    [html dateInput on: #date of: self.
			    html space: 10.
			    (html timeInput)
				withSeconds;
				on: #time of: self.
			    html break.
			    html text: message.
			    html break.
			    html submitButton 
				callback: [message := 'Button action: ' , date seasideString , ' ' , time seasideString]]]
    ]

    renderDeadDateTimeOn: html [
	<category: 'rendering'>
	(html heading)
	    level: 3;
	    with: 'Div with #dateInput and #timeInput, no callback'.
	html form: 
		[html div: 
			[html dateInput value: Date today.
			html space: 10.
			(html timeInput)
			    withSeconds;
			    value: Time now.
			html break.
			html 
			    withLineBreaks: 'The year portion of the date should be visible.
				The seconds portion of the time should be visible']]
    ]

    renderSubmitFormOn: html [
	<category: 'rendering'>
	(html heading)
	    level3;
	    with: 'Form with #submitFormNamed:'.
	(html form)
	    id: 'submitForm';
	    defaultAction: 
		    [data := 'Default action : ' , data1 seasideString , ' ' , data2 seasideString , ' ' 
				, numericData seasideString];
	    with: 
		    [html div: 
			    [html textInput on: #data1 of: self.
			    html textInput on: #data2 of: self.
			    html textInput on: #numericData of: self.
			    html break.
			    html text: data.
			    html break.
			    (html anchor)
				callback: 
					[data := 'Anchor action : ' , data1 seasideString , ' ' , data2 seasideString , ' ' 
						    , numericData seasideString];
				submitFormNamed: 'submitForm';
				with: 'Click to submit']]
    ]

    time [
	<category: 'accessing'>
	^time
    ]

    time: aTime [
	<category: 'accessing'>
	time := aTime
    ]
]



WAFunctionalTest subclass: WADefaultFormTest [
    | value |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Default Form'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html form)
	    defaultAction: [self inform: 'Default: ' , value seasideString];
	    with: 
		    [html div: 
			    [(html submitButton)
				callback: [self inform: 'Before: ' , value seasideString];
				text: 'Before'.
			    html break.
			    (html textInput)
				value: '';
				callback: [:v | value := v].
			    (html submitButton)
				callback: [self inform: 'Go: ' , value seasideString];
				text: 'Go'.
			    html break.
			    (html submitButton)
				callback: [self inform: 'After: ' , value seasideString];
				text: 'After']]
    ]
]



WAFunctionalTest subclass: WADelayTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    go [
	<category: 'actions'>
	self call: ((WAComponent new)
		    addMessage: '3 seconds';
		    addDecoration: (WADelayedAnswerDecoration new delay: 3);
		    yourself)
    ]

    label [
	<category: 'accessing'>
	^'Delay'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html 
	    paragraph: 'Clicking the following anchor should replace it with the message "3 seconds" for 3 seconds and then restore it.'.
	html paragraph: 
		[(html anchor)
		    callback: [self go];
		    with: 'Start']
    ]
]



WAFunctionalTest subclass: WAEncodingTest [
    | urlencoded multipart |
    
    <comment: 'A WAEncodingTest test whether Seaside correctly handles non-ASCII strings. Unfortunately due to differences in server setup and source code encodings this test requires manual interaction.
'>
    <category: 'Seaside-Tests-Functional'>

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self urlencoded: 'urlencoded'.
	self multipart: 'multipart'
    ]

    label [
	<category: 'accessing'>
	^'Encoding'
    ]

    multipart [
	<category: 'accessing'>
	^multipart
    ]

    multipart: aString [
	<category: 'accessing'>
	multipart := aString
    ]

    renderClassName: aString on: html [
	<category: 'rendering'>
	aString isNil 
	    ifFalse: 
		[html strong: 'Class: '.
		html text: aString class name]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderExplanationOn: html.
	self renderUrlencodedOn: html.
	self renderMultipartOn: html
    ]

    renderExplanationOn: html [
	<category: 'rendering'>
	html paragraph: 
		[html unorderedList: 
			[html listItem: 
				[html text: 'Go to the '.
				(html anchor)
				    url: 'http://www.columbia.edu/kermit/utf8.html';
				    with: 'UTF-8 Sampler'.
				html text: ' and select some "foreign" text.'].
			html 
			    listItem: 'Copy and paste it into the urlencoded text field below and click the submit button.'.
			html 
			    listItem: 'The heading, textfield and submitt button should all display the text without any error.'.
			html 
			    listItem: 'Submit again without changing anything, again everything should display normally.'.
			html 
			    listItem: 'Repeat this process for the multipart field. Make sure to pick at least every of these languages: German, Czech, Korean.']]
    ]

    renderMultipartOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: 'Multipart'.
	(html heading)
	    level3;
	    with: self multipart.
	(html form)
	    multipart;
	    with: 
		    [html textInput on: #multipart of: self.
		    html submitButton text: self multipart].
	self renderClassName: self multipart on: html
    ]

    renderUrlencodedOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: 'Urlencoded'.
	(html heading)
	    level3;
	    with: self urlencoded.
	html form: 
		[html textInput on: #urlencoded of: self.
		html submitButton text: self urlencoded].
	self renderClassName: self urlencoded on: html
    ]

    urlencoded [
	<category: 'accessing'>
	^urlencoded
    ]

    urlencoded: aString [
	<category: 'accessing'>
	urlencoded := aString
    ]
]



WAFunctionalTest subclass: WAErrorTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Error'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'errorTest';
	    with: 
		    [self renderHaltOn: html.
		    self renderErrorOn: html.
		    self renderResumableErrorOn: html.
		    self renderWarningOn: html.
		    self renderDeprecatedOn: html]
    ]

    renderDeprecatedOn: html [
	<category: 'rendering'>
	html heading: 'Deprecated'.
	html 
	    paragraph: 'The link should display a deprecated warning in the toolbar and display an information message.'.
	(html anchor)
	    callback: 
		    [self
			deprecatedApi: 'Test Deprecation';
			inform: 'To be displayed'];
	    with: 'Raise deprecated'
    ]

    renderErrorOn: html [
	<category: 'rendering'>
	html heading: 'Error'.
	html 
	    paragraph: 'The link should display an error walkback. Opening a debugger should work. Closing the debugger window should not lock the session.'.
	(html anchor)
	    callback: 
		    [self
			error: 'Test Error';
			inform: 'Not to be displayed'];
	    with: 'Raise error'
    ]

    renderHaltOn: html [
	<category: 'rendering'>
	html heading: 'Halt'.
	html 
	    paragraph: 'The link should open a debugger in the image. Clicking on proceed should display the information message "To be displayed".'.
	(html anchor)
	    callback: 
		    [self
			halt;
			inform: 'To be displayed'];
	    with: 'Halt execution'
    ]

    renderResumableErrorOn: html [
	<category: 'rendering'>
	html heading: 'Resumable error'.
	html 
	    paragraph: 'The link should display a zero divide walkback. Clicking on proceed should display the message "To be displayed". Clicking on debug should open a debugger in the image.'.
	(html anchor)
	    callback: 
		    [1 / 0.
		    self inform: 'To be displayed'];
	    with: 'Raise zero divide'
    ]

    renderWarningOn: html [
	<category: 'rendering'>
	html heading: 'Warning'.
	html 
	    paragraph: 'In Squeak the warning test works the same as the resumable error test.'.
	html 
	    paragraph: 'In VisualWorks the warning test works the same as the halt test.'.
	(html anchor)
	    callback: 
		    [self
			notify: 'Test Warning';
			inform: 'To be displayed'];
	    with: 'Raise warning'
    ]
]



WAFunctionalTest subclass: WAExpiryTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Expiry'
    ]

    renderActionsOn: html [
	<category: 'rendering'>
	(html anchor)
	    url: self session newSessionUrl;
	    with: 'New Session'.
	html break.
	(html anchor)
	    callback: [self session expire];
	    with: 'Expire'.
	html break.
	(html anchor)
	    callback: [WAExpirySession resetCounters];
	    with: 'Reset Counters'.
	html break.
	(html anchor)
	    callback: [Smalltalk garbageCollect];
	    with: 'Garbage Collect'.
	html break.
	(html anchor)
	    callback: 
		    [self session application clearHandlers.
		    Smalltalk garbageCollect];
	    with: 'Clear Handlers'.
	html break.
	(html anchor)
	    callback: 
		    [self session application clearHandlers.
		    WAExpirySession resetCounters.
		    Smalltalk garbageCollect];
	    with: 'Reset All'.
	html form: 
		[html text: 'Expiry seconds:'.
		(html textInput)
		    value: self session application sessionExpirySeconds;
		    callback: [:value | self session timeoutSeconds: value asInteger].
		html space.
		html submitButton text: 'Change']
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderStatsOn: html.
	self renderActionsOn: html
    ]

    renderStatsOn: html [
	<category: 'rendering'>
	html table: 
		[html tableRow: 
			[html tableHeading: 'Total session instances'.
			html tableData: WAExpirySession allInstances size].
		html tableRow: 
			[html tableHeading: 'Active session instances'.
			html 
			    tableData: (WAExpirySession allInstances count: [:each | each isActive])].
		html tableRow: 
			[html tableHeading: 'Total component instances'.
			html tableData: self class allInstances size].
		html tableRow: 
			[html tableHeading: 'Sessions created'.
			html tableData: WAExpirySession created].
		html tableRow: 
			[html tableHeading: 'Sessions unregistered'.
			html tableData: WAExpirySession unregistered]]
    ]
]



WAFunctionalTest subclass: WAFileLibraryHtmlTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    basePath [
	<category: 'accessing'>
	^WADispatcher default basePath
    ]

    label [
	<category: 'accessing'>
	^'File Library'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'desc';
	    with: 
		    [(html heading)
			level3;
			with: 'This page has'.
		    html unorderedList: 
			    [html listItem: 'a static stylesheet (main.css)'.
			    html 
				listItem: 'a static background image (main.jpg) named in a dynamic stylesheet'.
			    html listItem: 'an image']].
	html image url: WAFileLibraryDemo / #mainJpg
    ]

    style [
	<category: 'accessing'>
	^'

body {
	background: url(' , self basePath 
	    , '/files/WAFileLibraryDemo/main.jpg);
}
div.desc {
	padding: 2em;
}
'
    ]

    updateRoot: anHtmlRoot [
	<category: 'path'>
	super updateRoot: anHtmlRoot.
	anHtmlRoot stylesheet url: WAFileLibraryDemo / #mainCss
    ]
]



WAFunctionalTest subclass: WAFlowTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    depth: aContext [
	<category: 'private'>
	| depth current |
	depth := 0.
	current := aContext.
	[current isNil] whileFalse: 
		[current := current parentContext.
		depth := depth + 1].
	^depth
    ]

    goAnchors [
	<category: 'actions'>
	| component |
	1 to: 5
	    do: 
		[:each | 
		component := WAComponent new.
		component addMessage: 
			[:html | 
			(html anchor)
			    callback: [component answer];
			    with: each seasideString , ': ' , (self depth: thisContext) seasideString].
		self call: component]
    ]

    goButtons [
	<category: 'actions'>
	1 to: 5
	    do: [:each | self inform: each seasideString , ': ' , (self depth: thisContext) seasideString]
    ]

    label [
	<category: 'accessing'>
	^'Flow'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html 
	    paragraph: 'The following two anchors should trigger flows with 5 steps each. The stack should neither grow nor shrink. Backtracking and spawning of windows should properly work.'.
	html paragraph: 
		[(html anchor)
		    callback: [self goAnchors];
		    with: 'go anchors'.
		html break.
		(html anchor)
		    callback: [self goButtons];
		    with: 'go buttons']
    ]
]



WAFunctionalTest subclass: WAHomeTest [
    | main |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    children [
	<category: 'accessing'>
	^Array with: main
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	main := WATaskTest new
    ]

    label [
	<category: 'accessing'>
	^'Home'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html anchor)
	    callback: [main home];
	    with: 'Home'.
	html break.
	html render: main
    ]
]



WAFunctionalTest subclass: WAHtmlTest [
    | booleanList message number |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    allSelectors [
	<category: 'accessing'>
	^(self class selectors asSortedCollection 
	    select: [:s | s startsWith: 'render'])
	    remove: #renderContentOn:;
	    yourself
    ]

    initialMessage [
	<category: 'accessing'>
	^'Hello world!'
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	message := self initialMessage.
	booleanList := #(#a #b #c #d) 
		    collect: [:key | key -> (Array with: true with: false) atRandom].
	number := 10 atRandom
    ]

    label [
	<category: 'accessing'>
	^'Form Elements'
    ]

    message [
	<category: 'accessing'>
	^message
    ]

    message: aString [
	<category: 'accessing'>
	message := aString
    ]

    number [
	<category: 'accessing'>
	^number
    ]

    number: anInteger [
	<category: 'accessing'>
	number := anInteger
    ]

    renderCheckboxesOn: html [
	<category: 'rendering'>
	html text: booleanList.
	html paragraph.
	html form: 
		[booleanList do: 
			[:association | 
			html
			    text: association key;
			    space.
			(html checkbox)
			    addShortcut: 'Ctrl-' , association key asUppercase;
			    on: #value of: association.
			(html span)
			    class: 'indented';
			    class: 'hint';
			    with: 'Shortcuts: ' , 'Ctrl-' , association key asUppercase.
			html break].
		html submitButton]
    ]

    renderContentOn: html [
	"don't use pairsDo:, doesn't work for JPMorgan"

	<category: 'rendering'>
	| selectors indices |
	selectors := self allSelectors.
	indices := (1 to: selectors size) select: [:each | each odd].
	indices do: 
		[:index | 
		(html div)
		    class: 'row';
		    with: 
			    [(html div)
				class: 'left';
				with: [self perform: (selectors at: index) with: html].
			    index < selectors size 
				ifTrue: 
				    [(html div)
					class: 'left';
					with: [self perform: (selectors at: index + 1) with: html]]]]
    ]

    renderRadioButtonsOn: html [
	<category: 'rendering'>
	html text: booleanList.
	html paragraph.
	html form: 
		[booleanList do: 
			[:association | 
			| group |
			group := html radioGroup.
			html
			    text: association key;
			    space.
			(group radioButton)
			    addShortcut: 'Ctrl-' , association key;
			    selected: association value;
			    callback: [association value: true].
			(group radioButton)
			    addShortcut: 'Alt-' , association key;
			    selected: association value not;
			    callback: [association value: false].
			(html span)
			    class: 'indented';
			    class: 'hint';
			    with: 'Shortcuts: ' , 'Ctrl-' , association key , ' Alt-' , association key.
			html break].
		html submitButton]
    ]

    renderSelectsOn: html [
	<category: 'rendering'>
	html text: number.
	html paragraph.
	html form: 
		[(html select)
		    list: (1 to: 10);
		    on: #number of: self.
		html submitButton]
    ]

    renderSubmitButtonsOn: html [
	<category: 'rendering'>
	html text: number.
	html paragraph.
	html form: 
		[1 to: 10
		    do: 
			[:index | 
			(html submitButton)
			    addShortcut: 'F' , index seasideString;
			    callback: [number := index];
			    text: index.
			html space]].
	(html span)
	    class: 'hint';
	    with: 'Above, you may be able to use F1 .. F10 as shortcuts, if the browser allows you.'
    ]

    renderTextAreaOn: html [
	<category: 'rendering'>
	| position |
	position := message = self initialMessage ifTrue: [6] ifFalse: ['End'].
	html form: 
		[html text: message.
		(html paragraph)
		    class: 'hint';
		    with: 'The text area below should have the focus and be wholly selected, unless it has its initial value, ' 
				, self initialMessage printString 
				    , ', in which case you should see the cursor right after the "o" of "Hello".'.
		(html textArea)
		    setCursorPosition: position;
		    on: #message of: self.
		html break.
		html submitButton]
    ]

    renderTextInputOn: html [
	<category: 'rendering'>
	html form: 
		[html text: message.
		html paragraph.
		html textInput on: #message of: self.
		html submitButton]
    ]

    renderVFieldSetOn: html [
	<category: 'rendering'>
	(html fieldSet)
	    legend: 'Various text rendering in a fieldset';
	    with: 
		    [html
			strong: 'Strong';
			break;
			emphasis: 'Emphasis';
			break.
		    (html acronym)
			title: 'United States of America';
			with: 'USA'.
		    html
			break;
			emphasis: 'Emphasis';
			break.
		    (html div)
			style: 'color: red';
			style: 'background-color: lightgreen';
			style: 'padding: 1em';
			style: 'border: solid 2px black';
			style: 'font-weight: bold';
			style: 'font-size: 150%';
			style: 'height: 3em';
			style: 'text-align: center';
			with: 'Large bold red in a green div'.
		    html break]
    ]

    renderZFieldSetOn: html [
	<category: 'rendering'>
	| url |
	url := html context 
		    urlForDocument: WAStandardFiles default inspectorPng
		    mimeType: 'image/png'
		    fileName: 'Debug.jpg'.
	(html fieldSet)
	    legend: 'Various images in a fieldset';
	    with: 
		    [(html image)
			url: url;
			altText: 'Halo-Debug'.
		    html space.
		    html break.
		    (html image)
			url: WAHandlerEditorFiles / #logoPng;
			width: '80%';
			altText: 'Seaside'.
		    html break.
		    (html image)
			url: WAHandlerEditorFiles / #logoPng;
			height: '50px';
			altText: 'Seaside'.
		    html break.
		    (html image)
			url: WAHandlerEditorFiles / #logoPng;
			width: '250px';
			height: '60px';
			altText: 'Seaside']
    ]

    style [
	<category: 'rendering'>
	^'
div.row {
	clear: both
}

div.left {
	float: left;
	width: 45%;
	margin: 1%
}

.indented {
	margin-left: 2em;
}

.hint {
	font-family: Tahoma, Arial;
	font-size: small;
}
'
    ]
]



WAFunctionalTest subclass: WAIframeTest [
    | counter |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    children [
	<category: 'accessing'>
	^Array with: counter
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	counter := WACounter new
    ]

    label [
	<category: 'accessing'>
	^'Iframe'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html iframe contents: counter.
	html
	    break;
	    break.
	html iframe 
	    url: (WADispatcher default entryPointAt: WACounter entryPointName) basePath.
	html
	    break;
	    break.
	html iframe document: WAHandlerEditorFiles default logoPng
	    mimeType: 'image/jpeg'
    ]

    style [
	<category: 'rendering'>
	^'iframe {
	border: 1px solid gray;
	width: 100%;
}'
    ]
]



WAFunctionalTest subclass: WAImageMapTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    clickedAt: aPoint id: aString [
	<category: 'actions'>
	self inform: 'Clicked at ' , aPoint seasideString , ' on ' , aString seasideString
    ]

    label [
	<category: 'accessing'>
	^'Image map (ismap)'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html heading)
	    level: 3;
	    with: 'A byte array with server side map (ismap)'.
	(html map)
	    title: 'Click anywhere on the Seaside logo';
	    id: #map1;
	    callback: [:aPoint | self clickedAt: aPoint id: 'the Seaside logo'];
	    with: 
		    [(html image)
			altText: 'Seaside logo';
			width: '40%';
			document: WAHandlerEditorFiles new logoPng
			    mimeType: 'image/jpg'
			    fileName: 'seasideLogo.jpg']
    ]
]



WAFunctionalTest subclass: WAInputTest [
    | inputElements |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    WAInputTest class >> description [
	<category: 'accessing'>
	^'Various XHTML form input elements'
    ]

    WAInputTest class >> example [
	<category: 'accessing'>
	^self new
    ]

    children [
	<category: 'accessing'>
	^Array with: inputElements
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	inputElements := WAInputElementContainer new
    ]

    label [
	<category: 'accessing'>
	^'Input'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html form: 
		[html table: inputElements.
		html submitButton]
    ]
]



WAFunctionalTest subclass: WALinkSubmitTest [
    | count |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    count [
	<category: 'accessing'>
	^count
    ]

    count: anIntegerOrString [
	<category: 'accessing'>
	count := anIntegerOrString asInteger
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	count := 0
    ]

    label [
	<category: 'accessing'>
	^'Submit'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	| formId |
	formId := #myform.
	(html form)
	    id: formId;
	    with: 
		    [html textInput on: #count of: self.
		    html break.
		    (html anchor)
			id: #decreaseLink;
			addShortcut: 'Ctrl-Down';
			callback: [count := count - 1];
			submitFormNamed: formId;
			with: '--'.
		    html space.
		    (html anchor)
			id: #increaseLink;
			addShortcut: 'Ctrl-Up';
			callback: [count := count + 1];
			submitFormNamed: formId;
			with: '++'.
		    html
			break;
			break.
		    count = 0 
			ifFalse: 
			    [(html checkbox)
				addShortcut: 'Ctrl-Z';
				addShortcut: 'Ctrl-z';
				value: count = 0;
				callback: [:value | value ifTrue: [count := 0]];
				submitFormNamed: formId.
			    html space.
			    html text: 'Reset']].
	html emphasis: 'Handy shortcuts : Ctrl-Up, Ctrl-Down and Ctrl-Z'
    ]
]



WAFunctionalTest subclass: WALotsaLinksTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Links'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html unorderedList: 
		[1 to: 5000
		    do: 
			[:each | 
			html listItem: 
				[(html anchor)
				    callback: [self inform: each];
				    with: each]]]
    ]
]



WAFunctionalTest subclass: WAMiniCalendarTest [
    | calendar |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    children [
	<category: 'accessing'>
	^Array with: calendar
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	calendar := WAMiniCalendar new
    ]

    label [
	<category: 'accessing'>
	^'Mini Calendar'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html render: calendar.
	html strong: 'selected:'.
	html space.
	html render: calendar date
    ]
]



WAFunctionalTest subclass: WAModelTest [
    | state user pass test |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Model'
    ]

    logoff [
	<category: 'actions'>
	state := #OFF.
	test ifTrue: [self inform: 'Logged off']
    ]

    logon [
	<category: 'actions'>
	user isEmptyOrNil 
	    ifTrue: [self inform: 'Nope !']
	    ifFalse: 
		[state := #ON.
		test ifTrue: [self inform: 'Logged on']]
    ]

    pass [
	"Answer the value of pass"

	<category: 'accessing'>
	^pass
    ]

    pass: anObject [
	"Set the value of pass"

	<category: 'accessing'>
	pass := anObject
    ]

    renderButtonOn: html [
	<category: 'rendering'>
	| action |
	action := state == #ON ifTrue: [#logoff] ifFalse: [#logon].
	html submitButton on: action of: self
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html form)
	    id: 'myform';
	    with: 
		    [html table: 
			    [self renderUsernameOn: html.
			    self renderPasswordOn: html.
			    self renderFeedbackOn: html].
		    self renderButtonOn: html]
    ]

    renderFeedbackOn: html [
	<category: 'rendering'>
	html tableRow: 
		[html tableData: 
			[(html label)
			    for: #withFeedback;
			    with: 'With Feedback:'].
		html tableData: 
			[(html checkbox)
			    id: #withFeedback;
			    on: #test of: self]]
    ]

    renderPasswordOn: html [
	<category: 'rendering'>
	html tableRow: 
		[html tableData: 
			[(html label)
			    for: #pass;
			    with: 'Password:'].
		html tableData: 
			[(html passwordInput)
			    id: #pass;
			    on: #pass of: self]]
    ]

    renderUsernameOn: html [
	<category: 'rendering'>
	html tableRow: 
		[html tableData: 
			[(html label)
			    for: #userid;
			    with: 'Username:'].
		html tableData: 
			[(html textInput)
			    id: #userid;
			    on: #user of: self]]
    ]

    test [
	"Answer the value of test"

	<category: 'accessing'>
	^test
    ]

    test: anObject [
	"Set the value of test"

	<category: 'accessing'>
	test := anObject
    ]

    user [
	"Answer the value of user"

	<category: 'accessing'>
	^user
    ]

    user: anObject [
	"Set the value of user"

	<category: 'accessing'>
	user := anObject
    ]
]



WAFunctionalTest subclass: WAMultipartInputTest [
    | inputElements |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    WAMultipartInputTest class >> description [
	<category: 'accessing'>
	^'Various XHTML form input elements'
    ]

    WAMultipartInputTest class >> example [
	<category: 'accessing'>
	^self new
    ]

    children [
	<category: 'accessing'>
	^Array with: inputElements
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	inputElements := WAInputElementContainer new
    ]

    label [
	<category: 'accessing'>
	^'Multipart Input'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html form)
	    multipart;
	    with: 
		    [html table: inputElements.
		    html submitButton]
    ]
]



WAFunctionalTest subclass: WAPathTest [
    | counter |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    children [
	<category: 'accessing'>
	^Array with: counter
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	counter := WACounter new
    ]

    label [
	<category: 'accessing'>
	^'Path'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html anchor name: counter count.
	html render: counter
    ]

    updateUrl: aUrl [
	<category: 'path'>
	super updateUrl: aUrl.
	aUrl addToPath: counter count seasideString.
	aUrl fragment: counter count seasideString
    ]
]



WAFunctionalTest subclass: WAPhraseElementsTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Phrase'
    ]

    renderAbbreviatedOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<abbr>'.
	(html abbreviated)
	    title: 'World Wide Web';
	    with: 'WWW'
    ]

    renderAcronymOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<acronym>'.
	(html acronym)
	    title: 'Federal Bureau of Investigation';
	    with: 'F.B.I.'
    ]

    renderAddressOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<address>'.
	html address: 
		[#('Newsletter editor' 'J.R. Brown' 'JimquickPost News, Jimquick, CT 01234' 'Tel (123) 456 7890') 
		    do: [:each | html text: each]
		    separatedBy: [html break]]
    ]

    renderCodeOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<code>'.
	html text: 'Expressions like '.
	html code: 'a[i++] + b[i++]'.
	html text: ' should not be used, since they cause undefined behavior'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderHarryOn: html.
	self renderAbbreviatedOn: html.
	self renderAcronymOn: html.
	self renderKeyboardInputOn: html.
	self renderVariableOn: html.
	self renderCodeOn: html.
	self renderDefinitionOn: html.
	self renderSampleOn: html.
	self renderAddressOn: html.
	self renderModificationOn: html
    ]

    renderDefinitionOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<dfn>'.
	html definition: 'Ichthyology'.
	html text: ' is the branch of natural science which
studies fish.'
    ]

    renderHarryOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<cite>, <q>, <strong>'.
	html text: 'As '.
	html citation: 'Harry S. Truman'.
	html text: ' said, '.
	html quote: 'The buck stops here.'.
	html break.
	html text: 'More information can be found in '.
	html citation: '[ISO-0000]'.
	html text: '.'.
	html break.
	html 
	    text: 'Please refer to the following reference number in future correspondence: '.
	html strong: '1-234-55'
    ]

    renderKeyboardInputOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<kbd>'.
	html text: 'Finally, type '.
	html keyboard: 'logout'.
	html text: ' and press the return key.'
    ]

    renderModificationOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<ins>, <del>'.
	html paragraph: 
		[html text: 'A Sheriff can employ '.
		(html deleted)
		    title: 'Changed as a result of the SECURE bill.';
		    cite: 'http://www.w3.org/TR/html401/struct/text.html#edef-del';
		    datetime: '1994-11-05T08:15:30-05:00';
		    with: 3.
		(html inserted)
		    title: 'Changed as a result of the SECURE bill.';
		    cite: 'http://www.w3.org/TR/html401/struct/text.html#edef-del';
		    datetime: '1994-11-05T08:15:30-05:00';
		    with: 5.
		html text: ' deputies.']
    ]

    renderSampleOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<samp>'.
	html 
	    text: 'If you select the ''champion'' option, you will receive the message '.
	html sample: 'The monkey is not a caterpillar'.
	html text: '.'
    ]

    renderVariableOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: '<var>'.
	html 
	    text: 'In the simplest case, the command for deleting a file in Unix is'.
	html break.
	html keyboard: 'rm'.
	html space.
	html variable: 'filename'
    ]
]



WAFunctionalTest subclass: WAPopupTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    counterLoop [
	<category: 'actions'>
	WARenderLoop new call: WACounter new
    ]

    label [
	<category: 'accessing'>
	^'Popup'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html popupAnchor)
	    callback: [self counterLoop];
	    with: 'popup'.
	html break.
	(html popupAnchor)
	    extent: 100 @ 100;
	    callback: [self counterLoop];
	    with: 'popup with extent'.
	html break.
	(html popupAnchor)
	    position: 100 @ 100;
	    callback: [self counterLoop];
	    with: 'popup with position'.
	html break.
	(html popupAnchor)
	    location: true;
	    callback: [self counterLoop];
	    with: 'popup with location'.
	html break.
	(html popupAnchor)
	    resizable: false;
	    callback: [self counterLoop];
	    with: 'popup not resizable'
    ]
]



WAFunctionalTest subclass: WARubyTest [
    
    <comment: 'Examples taken directly from spec:
http://www.w3.org/TR/2001/REC-ruby-20010531/
'>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Ruby'
    ]

    renderComplexOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: 'Complex ruby markup'.
	html ruby: 
		[html rubyBaseContainer: 
			[html rubyBase: 10.
			html rubyBase: 31.
			html rubyBase: 2002].
		html rubyTextContainer: 
			[html rubyText: 'Month'.
			html rubyText: 'Day'.
			html rubyText: 'Year'].
		html rubyTextContainer: 
			[(html rubyText)
			    span: 3;
			    with: 'Expiration Date']]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderSimpleOn: html.
	self renderSimpleParenthesesOn: html.
	self renderComplexOn: html
    ]

    renderSimpleOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: 'Simple ruby markup'.
	html ruby: 
		[html rubyBase: 'WWW'.
		html rubyText: 'World Wide Web']
    ]

    renderSimpleParenthesesOn: html [
	<category: 'rendering'>
	(html heading)
	    level2;
	    with: 'Simple ruby markup with parentheses'.
	html ruby: 
		[html rubyBase: 'WWW'.
		html rubyParentheses: '('.
		html rubyText: 'World Wide Web'.
		html rubyParentheses: ')']
    ]
]



WAFunctionalTest subclass: WASvgTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'<object>'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html object)
	    type: 'image/svg+xml' toMimeType;
	    width: 600;
	    height: 800;
	    standby: 'loading tiger';
	    classId: 'http://www.adobe.com/svg/viewer/install/main.html';
	    url: 'http://croczilla.com/svg/samples/tiger/tiger.svg';
	    with: 'Your browser doesn''t support SVG'
    ]
]



WAFunctionalTest subclass: WATableReportTest [
    | report |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    WATableReportTest class >> example [
	<category: 'accessing'>
	^self new
    ]

    children [
	<category: 'accessing'>
	^Array with: report
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	report := (WATableReport new)
		    rows: WAComponent allSubclasses asArray;
		    columns: ((OrderedCollection new)
				add: (WAReportColumn 
					    selector: #fullName
					    title: 'Name'
					    onClick: [:each | self inform: each description]);
				add: ((WAReportColumn selector: #canBeRoot title: 'Can Be Root') 
					    sortBlock: [:a :b | a]);
				add: (WAReportColumn 
					    renderBlock: [:each :html | html emphasis: each description]
					    title: 'Description');
				yourself);
		    rowColors: #(#lightblue #lightyellow);
		    rowPeriod: 1;
		    yourself
    ]

    label [
	<category: 'accessing'>
	^'Table Report'
    ]
]



WAFunctionalTest subclass: WATransactionTest [
    | nestedTransation |
    
    <comment: 'A WATransactionTest runs a WANestedTransaction with a description'>
    <category: 'Seaside-Tests-Functional'>

    children [
	<category: 'accessing'>
	^Array with: nestedTransation
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	nestedTransation := WANestedTransaction new
    ]

    label [
	<category: 'accessing'>
	^'Transaction'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderExplanationOn: html.
	html render: nestedTransation
    ]

    renderExplanationOn: html [
	<category: 'rendering'>
	html paragraph: 
		[html 
		    text: 'This checks if nested #isolate: block work. It has the following nested transactions:'.
		html orderedList: 
			[html listItem: 'Inside parent txn'.
			html listItem: 
				[html orderedList: [html listItem: 'Inside child txn'].
				html listItem: 'Outside child txn']].
		html 
		    text: 'if you leave the child transaction and enter it with the back button you should end up in the parent transaction. If you leave the parent transaction with the back button and enter either it or the child transaction with the back button you should end up outside the parent transaction.']
    ]
]



WAFunctionalTest subclass: WAUploadTest [
    | file |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	^'Upload'
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html heading: 'Upload File'.
	(html form)
	    multipart;
	    with: 
		    [html fileUpload callback: [:f | file := f].
		    html submitButton text: 'Load'].
	file ifNotNil: 
		[:foo | 
		(html anchor)
		    document: file contents
			mimeType: file contentType
			fileName: file fileName;
		    with: file fileName , ' (' , file contentType seasideString , ')'.
		html break.
		(html anchor)
		    document: file contents;
		    with: file fileName.
		html preformatted: file contents]
    ]
]



WAComponent subclass: WAInputElementContainer [
    | textInput textInputExample textArea textAreaExample singleSelection singleSelectionOptional multiSelection nestedSelection |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    elements [
	<category: 'accessing'>
	^#(#Quito #Dakar #Sydney #Bamako)
    ]

    exampleText [
	<category: 'accessing'>
	^'Example Text'
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	textInput := textArea := 'Some Text'
    ]

    nestedElements [
	<category: 'accessing'>
	^#(#('Functional' #('Haskell ' 'Lisp' 'ML')) #('Dataflow' #('Hartmann pipelines' 'G' 'Max' 'Prograph')) #('Fourth-generation' #('Today' 'Ubercode' 'Uniface')))
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderHeadingOn: html.
	self renderTextInputOn: html.
	self renderTextInputExampleOn: html.
	self renderTextAreaOn: html.
	self renderTextAreaExampleOn: html.
	self renderSingleSelectionOn: html.
	self renderSingleSelectionOptionalOn: html.
	self renderSingleSelectionWithoutCallbackOn: html.
	self renderMultiSelectionOn: html.
	self renderNestedSelectionOn: html
    ]

    renderHeadingOn: html [
	<category: 'rendering-elements'>
	html tableRow: 
		[html tableData.
		html tableHeading: 'Control'.
		html tableHeading: 'Print String']
    ]

    renderLabel: aString input: anInputBlock output: anOutputBlock on: html [
	<category: 'rendering'>
	html tableRow: 
		[html tableHeading: aString.
		html tableData: anInputBlock.
		html tableData: anOutputBlock]
    ]

    renderMultiSelectionOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Multi Selection'
	    input: 
		[(html multiSelect)
		    list: self elements;
		    selected: multiSelection;
		    callback: [:value | multiSelection := value]]
	    output: [html unorderedList list: multiSelection]
	    on: html
    ]

    renderNestedSelectionOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Nested Selection'
	    input: 
		[html select: 
			[self nestedElements do: 
				[:list | 
				(html optionGroup)
				    label: list first;
				    with: 
					    [list second do: 
						    [:each | 
						    (html option)
							selected: nestedSelection = each;
							callback: [nestedSelection := each];
							with: each]]]]]
	    output: nestedSelection printString
	    on: html
    ]

    renderSingleSelectionOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Single Selection'
	    input: 
		[(html select)
		    list: self elements;
		    selected: singleSelection;
		    callback: [:value | singleSelection := value]]
	    output: singleSelection printString
	    on: html
    ]

    renderSingleSelectionOptionalOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Single Selection (Optional)'
	    input: 
		[(html select)
		    beOptional;
		    list: self elements;
		    optionalLabel: '(none)';
		    selected: singleSelectionOptional;
		    callback: [:value | singleSelectionOptional := value]]
	    output: singleSelectionOptional printString
	    on: html
    ]

    renderSingleSelectionWithoutCallbackOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Single Selection (Without Callback)'
	    input: [html select list: self elements]
	    output: nil
	    on: html
    ]

    renderTextAreaExampleOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Text Area (Example)'
	    input: 
		[(html textArea)
		    value: textAreaExample;
		    exampleText: self exampleText;
		    callback: [:value | textAreaExample := value]]
	    output: textAreaExample printString
	    on: html
    ]

    renderTextAreaOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Text Area'
	    input: 
		[(html textArea)
		    value: textArea;
		    callback: [:value | textArea := value]]
	    output: textArea printString
	    on: html
    ]

    renderTextInputExampleOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Text Input (Example)'
	    input: 
		[(html textInput)
		    value: textInputExample;
		    exampleText: self exampleText;
		    callback: [:value | textInputExample := value]]
	    output: textInputExample printString
	    on: html
    ]

    renderTextInputOn: html [
	<category: 'rendering-elements'>
	self 
	    renderLabel: 'Text Input'
	    input: 
		[(html textInput)
		    setFocus;
		    value: textInput;
		    callback: [:value | textInput := value]]
	    output: textInput printString
	    on: html
    ]
]



WAComponent subclass: WAParentTest [
    | parent |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    go [
	<category: 'actions'>
	parent inform: 'Test green!'
    ]

    label [
	<category: 'accessing'>
	^'Parent'
    ]

    parent: aComponent [
	<category: 'accessing'>
	parent := aComponent
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderExplanationOn: html.
	self renderSwapParentOn: html
    ]

    renderExplanationOn: html [
	<category: 'rendering'>
	html 
	    paragraph: 'This regression tests checks if #call: on the parent component works. If you click "swap parent" "Test green!" should appear without a tab panel.'
    ]

    renderSwapParentOn: html [
	<category: 'rendering'>
	(html anchor)
	    callback: [self go];
	    with: 'swap parent'
    ]
]



WAComponent subclass: WATaskTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    renderContentOn: html [
	<category: 'rendering'>
	(html anchor)
	    callback: [self call: WAExceptionTest new];
	    with: 'go'
    ]
]



WASession subclass: WAExpirySession [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    Created := nil.
    Unregistered := nil.

    WAExpirySession class >> created [
	<category: 'accessing'>
	^Created
    ]

    WAExpirySession class >> initialize [
	<category: 'class initialization'>
	self resetCounters
    ]

    WAExpirySession class >> resetCounters [
	<category: 'actions'>
	Unregistered := 0.
	Created := 0
    ]

    WAExpirySession class >> unregistered [
	<category: 'accessing'>
	^Unregistered
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	Created := Created + 1
    ]

    unregistered [
	<category: 'subclass responsibilities'>
	super unregistered.
	Unregistered := Unregistered + 1
    ]
]



WATask subclass: WAFunctionalTaskTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    label [
	<category: 'accessing'>
	self subclassResponsibility
    ]
]



WAFunctionalTaskTest subclass: WAConvenienceTest [
    | cheese |
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    chooseCheese [
	<category: 'controlling'>
	cheese := self chooseFrom: #('Greyerzer' 'Tilsiter' 'Sbrinz')
		    caption: 'What''s your favorite Cheese?'.
	cheese isNil ifTrue: [self chooseCheese]
    ]

    confirmCheese [
	<category: 'controlling'>
	^self confirm: 'Is ' , cheese , ' your favorite cheese?'
    ]

    go [
	<category: 'controlling'>
	
	[self chooseCheese.
	self confirmCheese] whileFalse.
	self informCheese
    ]

    informCheese [
	<category: 'controlling'>
	self inform: 'Your favorite cheese is ' , cheese , '.'
    ]

    label [
	<category: 'accessing'>
	^'Convenience'
    ]
]



WAFunctionalTaskTest subclass: WAExceptionTest [
    
    <comment: nil>
    <category: 'Seaside-Tests-Functional'>

    go [
	<category: 'processing'>
	[(self confirm: 'Raise an exception?') ifTrue: [self error: 'foo']] 
	    on: Error
	    do: [:error | self inform: 'Caught: ' , error description]
    ]

    label [
	<category: 'accessing'>
	^'Exception'
    ]
]



WATask subclass: WANestedTransaction [
    
    <comment: 'A WANestedTransaction is a test that uses two nested #isolate: blocks'>
    <category: 'Seaside-Tests-Functional'>

    go [
	<category: 'processing'>
	self inform: 'Before parent txn'.
	self isolate: 
		[self inform: 'Inside parent txn'.
		self isolate: [self inform: 'Inside child txn'].
		self inform: 'Outside child txn'].
	self inform: 'Outside parent txn'
    ]
]


Eval [
    WAAllTests initialize.
    WADateSelectorTest initialize.
    WAExpirySession initialize
]

