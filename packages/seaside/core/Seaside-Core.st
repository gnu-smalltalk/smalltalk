String extend [

    asCapitalizedPhrase [
	<category: '*Seaside-Core'>
	| read words currentWord capitalizedWord |
	(self noneSatisfy: [:ea | ea isLowercase]) ifTrue: [^self].
	words := WriteStream on: String new.
	read := ReadStream on: self.
	[read atEnd] whileFalse: 
		[currentWord := WriteStream on: String new.
		currentWord nextPut: read next.
		
		[| x |
		x := read peek.
		x isNil or: [x isUppercase]] 
			whileFalse: [currentWord nextPut: read next].
		capitalizedWord := currentWord contents capitalized.
		(#(#Of #In #At #A #Or #To #By) includes: capitalizedWord) 
		    ifTrue: [capitalizedWord := capitalizedWord asLowercase].
		words nextPutAll: capitalizedWord.
		words nextPutAll: ' '].
	words skip: -1.
	^words contents
    ]

    asMIMEDocument [
	<category: '*Seaside-Core'>
	^self asMIMEDocumentType: 'text/plain' toMimeType
    ]

    asMIMEDocumentType: mimeType [
	<category: '*Seaside-Core'>
	^SeasidePlatformSupport mimeDocumentClass contentType: mimeType seasideString
	    content: self
    ]

    encodeOn: aDocument [
	<category: '*Seaside-Core'>
	aDocument htmlEncoder nextPutAll: self
    ]

    renderOn: aRenderer [
	<category: '*Seaside-Core'>
	aRenderer text: self
    ]

    toMimeType [
	<category: '*Seaside-Core'>
	^WAMimeType fromString: self
    ]

]



DirectedMessage extend [

    fixCallbackTemps [
	"for polymorphism with BlockContext >> #fixCallbackTemps"

	<category: '*Seaside-Core'>
	
    ]

    numArgs [
	<category: '*Seaside-Core'>
	^selector numArgs
    ]

    renderOn: html [
	<category: '*Seaside-Core'>
	self value: html
    ]

    value: anObject [
	<category: '*Seaside-Core'>
	^self evaluateWithArguments: (Array with: anObject)
    ]

    valueWithPossibleArgument: anArg [
	"Evaluate the block represented by the receiver.
	 If the block requires one argument, use anArg, if it requires more than one,
	 fill up the rest with nils."

	<category: '*Seaside-Core'>
	self numArgs = 0 ifTrue: [^self value].
	self numArgs = 1 ifTrue: [^self value: anArg].
	self numArgs > 1 
	    ifTrue: 
		[^self 
		    valueWithArguments: (Array with: anArg) , (Array new: self numArgs - 1)]
    ]

]



Notification subclass: WADeprecatedApi [
    
    <category: 'Seaside-Core-Exceptions'>
    <comment: 'WADeprecatedApi is a notification that gets signaled if someone used a deprecated Seaside method.

see #deprecatedApi'>
]



Notification subclass: WADynamicVariable [
    
    <category: 'Seaside-Core-Utilities'>
    <comment: 'A WADynamicVariable is a variable that is visible only in the stackframes outgoing from this one.

Example:

WADynamicVariable
	use: ''Seaside''
	during: [ self compilcatedCalculation ]
	
Whenever
WADynamicVariable value
gets evaluated somewhere inside [ self compilcatedCalculation ] or a method invoked directly or indirectly by it, its value will be ''Seaside''. If no #use:during: handler is around the current stack frame, then the value will be the return value of #defaultValue.

Do not use WADynamicVariable directly, instead create a subclass for each variable you want to use.'>

    WADynamicVariable class >> defaultValue [
	<category: 'defaults'>
	^nil
    ]

    WADynamicVariable class >> use: anObject during: aBlock [
	<category: 'evaluating'>
	^aBlock on: self do: [:notification | notification resume: anObject]
    ]

    WADynamicVariable class >> value [
	<category: 'evaluating'>
	^self signal
    ]

    defaultAction [
	<category: 'defaults'>
	^self class defaultValue
    ]
]



WADynamicVariable subclass: WACurrentSession [
    
    <category: 'Seaside-Core-Session'>
    <comment: 'A WACurrentSession is the dynamic variable for the current Seaside session. See superclass comment for what a dynamic variable is.'>
]



Notification subclass: WAPageExpired [
    
    <category: 'Seaside-Core-Session'>
    <comment: nil>
]



Notification subclass: WARenderNotification [
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>
]



Notification subclass: WAValidationNotification [
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'I am signaled to indicate that a validation has occurred.  See: Object>>validationError:, WAComponent>>validateWith: and WAValidationDecoration.'>
]



Error subclass: WAComponentsNotFoundError [
    
    <category: 'Seaside-Core-Exceptions'>
    <comment: nil>

    possibleCauses [
	<category: 'accessing'>
	^#('you do not implement #children correctly' 'you do not backtrack #children correctly' 'you do not implement #states correctly')
    ]
]



IdentityDictionary subclass: WASnapshot [
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    register: anObject [
	<category: 'registry'>
	anObject ifNotNil: [:foo | self at: anObject put: anObject snapshotCopy]
    ]

    restore [
	"Restore all the backtracked states."

	<category: 'actions'>
	self keysAndValuesDo: [:key :value | key restoreFromSnapshot: value]
    ]

    snapshot [
	"Snapshot all the states that have been registered for backtracking overriding existing snapshots."

	<category: 'actions'>
	self associationsDo: [:assoc | assoc value: assoc key snapshotCopy]
    ]
]



Collection extend [

    inspectorFields [
	<category: '*Seaside-Core'>
	| i |
	i := 0.
	^self asArray collect: 
		[:each | 
		i := i + 1.
		i -> each]
    ]

    renderOn: html [
	<category: '*Seaside-Core'>
	self do: [:each | each renderOn: html]
    ]

]



BlockClosure extend [

    handleRequest: aRequest [
	<category: '*Seaside-Core'>
	^self value: aRequest
    ]

    renderOn: aRenderer [
	<category: '*Seaside-Core'>
	self numArgs = 0 ifTrue: [self value] ifFalse: [self value: aRenderer]
    ]

]



ByteArray extend [

    asMIMEDocument [
	<category: '*Seaside-Core'>
	^self asMIMEDocumentType: 'application/octet-stream' toMimeType
    ]

    asMIMEDocumentType: mimeType [
	<category: '*Seaside-Core'>
	^SeasidePlatformSupport mimeDocumentClass contentType: mimeType seasideString
	    content: self
    ]

    renderOn: aRenderer [
	<category: '*Seaside-Core'>
	aRenderer text: self
    ]

]



ByteArray subclass: WAExternalID [
    
    <shape: #byte>
    <category: 'Seaside-Core-Utilities'>
    <comment: 'I am a session or conticuation key.'>

    Generator := nil.
    GeneratorMutex := nil.
    GeneratorSpace := nil.

    WAExternalID class >> defaultSize [
	<category: 'private'>
	^8
    ]

    WAExternalID class >> fromString: aString [
	<category: 'instance-creation'>
	| id |
	id := self new: aString size.
	aString keysAndValuesDo: [:index :each | id at: index put: each asInteger].
	^id
    ]

    WAExternalID class >> initialize [
	<category: 'initialization'>
	self startUp.
	SeasidePlatformSupport addToStartUpList: self.
	GeneratorSpace := ($a to: $z) , ($A to: $Z) , ($0 to: $9) 
		    , (Array with: $_ with: $-) collect: [:each | each asInteger].
	GeneratorMutex := SeasidePlatformSupport semaphoreClass forMutualExclusion
    ]

    WAExternalID class >> new [
	<category: 'instance-creation'>
	^self new: self defaultSize
    ]

    WAExternalID class >> new: aNumber [
	<category: 'instance-creation'>
	^(self basicNew: aNumber) initialize
    ]

    WAExternalID class >> startUp [
	<category: 'initialization'>
	Generator := SeasidePlatformSupport randomClass new
    ]

    initialize [
	<category: 'private'>
	GeneratorMutex critical: 
		[1 to: self size
		    do: [:index | self at: index put: (GeneratorSpace atRandom: Generator)]]
    ]

    printOn: aStream [
	<category: 'private'>
	self do: [:each | aStream nextPut: (Character value: each)]
    ]
]





Continuation subclass: AnswerContinuation [
    
    <category: 'Seaside-Core-Continuations'>
    <comment: nil>
]



Continuation subclass: EscapeContinuation [
    
    <category: 'Seaside-Core-Continuations'>
    <comment: nil>
]



Continuation subclass: ResponseContinuation [
    
    <category: 'Seaside-Core-Continuations'>
    <comment: nil>
]



Object extend [

    deprecatedApi [
	<category: '*Seaside-Core'>
	self deprecatedApi: thisContext sender seasideString
    ]

    deprecatedApi: aString [
	<category: '*Seaside-Core'>
	WADeprecatedApi signal: aString
    ]

    encodeOn: aDocument [
	<category: '*Seaside-Core'>
	aDocument print: self seasideString
    ]

    inspectorFields [
	<category: '*Seaside-Core'>
	| members |
	members := Array new writeStream.
	self class allInstVarNames 
	    doWithIndex: [:each :index | members nextPut: each -> (self instVarAt: index)].
	self class isVariable 
	    ifTrue: 
		[1 to: self size do: [:index | members nextPut: index -> (self at: index)]].
	^members contents
    ]

    labelForSelector: aSymbol [
	<category: '*Seaside-Core'>
	^aSymbol asCapitalizedPhrase
    ]

    renderOn: aRenderer [
	"Override this method to customize how objects (not components) are rendered when passed as an argument to #render:. The default is the return value of #displayString.
	 Just remember that you can not use #callback:, #on:of:, or #call:"

	<category: '*Seaside-Core'>
	aRenderer text: self
    ]

    snapshotCopy [
	<category: '*Seaside-Core'>
	^self shallowCopy
    ]

    validationError: message [
	<category: '*Seaside-Core'>
	^WAValidationNotification signal: message
    ]

]



Object subclass: WABrush [
    | canvas parent closed |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: 'I represent a brush to be used on a *WACanvas*.

Instance Variables
	canvas:		The canvas instance I am used with.
	parent:		The parent brush I am used within.
	closed:		Wether I have been closed/flushed yet.'>

    WABrush class >> new [
	<category: 'instance-creation'>
	^self basicNew initialize
    ]

    close [
	"Close and flush the receiver onto the canvas and its associated document."

	<category: 'public'>
	closed ifFalse: [self with: nil]
    ]

    initialize [
	<category: 'initialization'>
	closed := false
    ]

    labelForSelector: aSymbol of: anObject [
	<category: 'private'>
	^anObject labelForSelector: aSymbol
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    setParent: aBrush canvas: aCanvas [
	<category: 'initialization'>
	parent := aBrush.
	canvas := aCanvas
    ]

    with: aBlock [
	<category: 'public'>
	canvas nest: aBlock.
	closed := true
    ]
]



WABrush subclass: WACompound [
    | callbackBlock value id properties |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I am the superclass for stuff that is not html element but you still want to access via the canvas API.'>

    callback: aBlock [
	<category: 'callbacks'>
	callbackBlock := aBlock
    ]

    close [
	<category: 'public'>
	closed ifTrue: [^self].
	closed := true.
	self with: nil
    ]

    hasCallback [
	<category: 'testing'>
	^callbackBlock notNil
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: aString [
	<category: 'accessing'>
	id := aString
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	"do not remove properties, it is used by SeasideAsync"
	properties := Dictionary new
    ]

    on: selector of: anObject [
	<category: 'callbacks'>
	self value: (anObject perform: selector).
	self callback: [:date | anObject perform: selector asMutator with: date]
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValue [
	<category: 'accessing'>
	value := aValue
    ]
]



WACompound subclass: WADateInput [
    | options month day year |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I am a composition of three input fields that allow the user to select year, month and day. #options: can be used to toggle them individually.
The argument for my callback blocks is an instance of Date.

See WADateTimeTest >> #renderDateTimeOn:'>

    addCallback [
	<category: 'private rendering'>
	self hasCallback 
	    ifFalse: 
		[canvas flush.
		^self].
	(canvas hiddenInput)
	    callback: [callbackBlock value: self setValueWithNewDate];
	    with: nil
    ]

    addDayCallbackToBrush: aBrush [
	<category: 'private callbacks'>
	self hasCallback ifFalse: [^self].
	aBrush on: #day of: self
    ]

    addMonthCallbackToBrush: aBrush [
	<category: 'private callbacks'>
	self hasCallback ifFalse: [^self].
	aBrush on: #month of: self
    ]

    addYearCallbackToBrush: aBrush [
	<category: 'private callbacks'>
	self hasCallback ifFalse: [^self].
	aBrush on: #year of: self
    ]

    day [
	<category: 'private callbacks'>
	^day
    ]

    day: anIntegerOrString [
	<category: 'private callbacks'>
	day := [anIntegerOrString asInteger] on: Error do: [:e | 1]
    ]

    defaultOptions [
	<category: 'private'>
	^#(#month #day #year)
    ]

    month [
	<category: 'private callbacks'>
	^month
    ]

    month: anIntegerOrString [
	<category: 'private callbacks'>
	month := [anIntegerOrString asInteger] on: Error do: [:error | 1]
    ]

    options [
	<category: 'accessing'>
	^options ifNil: [self defaultOptions]
    ]

    options: anArray [
	"Valid values in the array : #year #month #day
	 Can be used to control what is shown and in what order
	 Default #(month day year)"

	<category: 'accessing'>
	options := anArray
    ]

    renderDay [
	<category: 'private rendering'>
	| brush |
	brush := (canvas textInput)
		    id: (self id isNil ifFalse: [self id , '-day']);
		    value: day;
		    yourself.
	self addDayCallbackToBrush: brush.
	brush
	    attributeAt: 'size' put: 2;
	    attributeAt: 'maxlength' put: 2
    ]

    renderMonth [
	<category: 'private rendering'>
	| brush |
	brush := (canvas select)
		    id: self id;
		    list: (1 to: 12);
		    selected: month;
		    yourself.
	self addMonthCallbackToBrush: brush.
	brush labels: [:ea | Date nameOfMonth: ea]
    ]

    renderYear [
	<category: 'private rendering'>
	| brush |
	brush := (canvas textInput)
		    id: (self id isNil ifTrue: [nil] ifFalse: [self id , '-year']);
		    value: year;
		    yourself.
	self addYearCallbackToBrush: brush.
	brush
	    attributeAt: 'size' put: 4;
	    attributeAt: 'maxlength' put: 4
    ]

    setValueWithNewDate [
	<category: 'private callbacks'>
	^value := Date 
		    newDay: ((day min: (Date daysInMonthNumber: month forYear: year)) max: 1)
		    monthNumber: month
		    year: year
    ]

    with: aBlock [
	<category: 'public'>
	value isNil ifTrue: [value := Date today].
	day := value dayOfMonth.
	month := value monthIndex.
	year := value year.
	self options 
	    do: [:each | self perform: ('render' , each asLowercase capitalized) asSymbol]
	    separatedBy: [canvas space].
	self addCallback
    ]

    year [
	<category: 'private callbacks'>
	^year
    ]

    year: anIntegerOrString [
	<category: 'private callbacks'>
	year := [anIntegerOrString asInteger] on: Error do: [:e | 1900]
    ]
]



WACompound subclass: WATimeInput [
    | withSeconds hours minutes seconds |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I am a composition of three input fields that allows the user to select hour, minute and optionally second.
#withSeconds and #withoutSeconds can be used to toggle seconds.

The argument for my callback blocks is an instance of Time.

See WADateTimeTest >> #renderDateTimeOn:'>

    addCallback [
	<category: 'private rendering'>
	self hasCallback 
	    ifFalse: 
		[canvas flush.
		^self].
	(canvas hiddenInput)
	    callback: [callbackBlock value: self setValueWithNewTime];
	    with: nil
    ]

    addHoursCallbackToBrush: aBrush [
	<category: 'private callbacks'>
	self hasCallback ifFalse: [^self].
	aBrush on: #hours of: self
    ]

    addMinutesCallbackToBrush: aBrush [
	<category: 'private callbacks'>
	self hasCallback ifFalse: [^self].
	aBrush on: #minutes of: self
    ]

    addSecondsCallbackToBrush: aBrush [
	<category: 'private callbacks'>
	self hasCallback ifFalse: [^self].
	aBrush on: #seconds of: self
    ]

    hours [
	<category: 'private callbacks'>
	^hours
    ]

    hours: anIntegerOrString [
	<category: 'private callbacks'>
	hours := [anIntegerOrString asInteger] on: Error do: [:e | 0]
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self withoutSeconds
    ]

    minutes [
	<category: 'private callbacks'>
	^minutes
    ]

    minutes: anIntegerOrString [
	<category: 'private callbacks'>
	minutes := [anIntegerOrString asInteger] on: Error do: [:error | 0]
    ]

    renderHours [
	<category: 'private rendering'>
	| brush |
	brush := (canvas textInput)
		    id: self id;
		    value: hours asTwoCharacterString;
		    yourself.
	self addHoursCallbackToBrush: brush.
	brush
	    attributeAt: 'size' put: 2;
	    attributeAt: 'maxlength' put: 2
    ]

    renderMinutes [
	<category: 'private rendering'>
	| brush |
	brush := (canvas textInput)
		    id: (self id isNil ifFalse: [self id , '-mins']);
		    value: minutes asTwoCharacterString;
		    yourself.
	self addMinutesCallbackToBrush: brush.
	brush
	    attributeAt: 'size' put: 2;
	    attributeAt: 'maxlength' put: 2
    ]

    renderSeconds [
	<category: 'private rendering'>
	| brush |
	brush := (canvas textInput)
		    id: (self id isNil ifFalse: [self id , '-secs']);
		    value: seconds asTwoCharacterString;
		    yourself.
	self addSecondsCallbackToBrush: brush.
	brush
	    attributeAt: 'size' put: 2;
	    attributeAt: 'maxlength' put: 2
    ]

    seconds [
	<category: 'private callbacks'>
	^seconds
    ]

    seconds: anIntegerOrString [
	<category: 'private callbacks'>
	seconds := [anIntegerOrString asNumber] on: Error do: [:e | 0]
    ]

    setValueWithNewTime [
	<category: 'private callbacks'>
	^value := Time 
		    hours: hours
		    minutes: (minutes min: 59)
		    seconds: (seconds min: 59)
    ]

    with: aBlock [
	<category: 'public api'>
	value isNil ifTrue: [value := Time now].
	hours := value hour.
	minutes := value minutes.
	seconds := value seconds.
	self renderHours.
	canvas
	    space;
	    text: ':';
	    space.
	self renderMinutes.
	withSeconds 
	    ifTrue: 
		[canvas
		    space;
		    text: ':';
		    space.
		self renderSeconds]
	    ifFalse: [seconds := 0].
	self addCallback
    ]

    withSeconds [
	<category: 'accessing'>
	withSeconds := true
    ]

    withoutSeconds [
	<category: 'accessing'>
	withSeconds := false
    ]
]



WABrush subclass: WATagBrush [
    | attributes |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: 'This is the superclass for all XML element classes. Its main addtions are
- element name (#tag)
- attributes (instance of WAHtmlAttributes)
- common events (onXXX), this is a hack and would better be solved with traits'>

    WATagBrush class >> tag [
	"WASelectTag tag"

	"WAGenericTag tag"

	<category: 'code generation'>
	^(self selectors includes: #tag) ifTrue: [self new tag] ifFalse: [nil]
    ]

    accessKey: aString [
	"Set a keyboard shortcut to access an element. An access key is a single character from the document character set.
	 
	 Pressing an access key assigned to an element gives focus to the element. The action that occurs when an element receives focus depends on the element. For example, when a user activates a link defined by the A element, the user agent generally follows the link. When a user activates a radio button, the user agent changes the value of the radio button. When the user activates a text field, it allows input, etc.
	 
	 The following elements support the accesskey attribute: A, AREA, BUTTON, INPUT, LABEL, and LEGEND, and TEXTAREA.
	 
	 The invocation of access keys depends on the underlying system. For instance, on machines running MS Windows, one generally has to press the 'alt' key in addition to the access key. On Apple systems, one generally has to press the 'cmd' key in addition to the access key."

	<category: 'attributes-keyboard'>
	self attributes at: 'accesskey' put: aString
    ]

    addShortcut: aString [
	<category: 'convenience'>
	self canHaveShortcut 
	    ifFalse: 
		[self error: 'May not assign shortcut on items that are not clickable'].
	self ensureId.
	self session 
	    addLoadScript: (String streamContents: 
			[:stream | 
			stream
			    nextPutAll: 'addShortcut(''';
			    nextPutAll: aString;
			    nextPutAll: ''', ''';
			    nextPutAll: self id;
			    nextPutAll: ''')'])
    ]

    after [
	"This template method is called directly after rendering the content of the receiver."

	<category: 'private'>
	
    ]

    attributeAt: aKey [
	<category: 'accessing-attributes'>
	^self attributes at: aKey
    ]

    attributeAt: aKey ifAbsent: aBlock [
	<category: 'accessing-attributes'>
	^self attributes at: aKey ifAbsent: aBlock
    ]

    attributeAt: aKey ifAbsentPut: aBlock [
	<category: 'accessing-attributes'>
	^self attributes at: aKey ifAbsentPut: aBlock
    ]

    attributeAt: aKey ifPresent: aBlock [
	<category: 'accessing-attributes'>
	^self attributes at: aKey ifPresent: aBlock
    ]

    attributeAt: aKey put: aValue [
	<category: 'accessing-attributes'>
	^self attributes at: aKey put: aValue
    ]

    attributes [
	<category: 'accessing'>
	^attributes ifNil: [attributes := WAHtmlAttributes new]
    ]

    attributes: anHtmlAttributes [
	<category: 'accessing'>
	attributes := anHtmlAttributes
    ]

    before [
	"This template method is called directly before rendering the content of the receiver."

	<category: 'private'>
	
    ]

    canHaveShortcut [
	<category: 'convenience'>
	^false
    ]

    class: aString [
	"This attribute assigns one or more class names to an element; the element may be said to belong to these classes. A class name may be shared by several element instances. Multiple classes might be added to one brush."

	<category: 'attributes-core'>
	self attributes addClass: aString
    ]

    class: aString if: aBoolean [
	"Adds the class aString aString to this element if aBoolean is true,
	 
	 Example
	 
	 html div
	 class: 'important' if: self isImportant;
	 with: self message"

	<category: 'convenience'>
	aBoolean ifTrue: [self class: aString]
    ]

    closeTag [
	"Close the receiving tag onto the document."

	<category: 'private'>
	self isClosed ifFalse: [self document closeTag: self tag]
    ]

    confirm: aString [
	<category: 'convenience'>
	self onClick: 'return confirm("' , aString , '")'
    ]

    direction: aString [
	"Set the text direction ltr (left-to-right) or right-to-left (rtl).
	 
	 Not supported on:
	 APPLET, BASE, BASEFONT, BR, FRAME, FRAMESET, IFRAME, PARAM, SCRIPT"

	<category: 'attributes-language'>
	self attributes at: 'dir' put: aString
    ]

    disableEnter [
	"pressing the 'enter' key in the form input element does not submit the form"

	<category: 'convenience'>
	self onEnter: ''
    ]

    disabled [
	<category: 'attributes'>
	self disabled: true
    ]

    disabled: aBoolean [
	<category: 'attributes'>
	self attributes at: 'disabled' put: aBoolean
    ]

    document [
	<category: 'private'>
	^canvas document
    ]

    ensureId [
	"Answer the id of the receiving attribute. In case the receiver doesn't have an id yet, generate a new one."

	<category: 'public'>
	^self attributes at: 'id' ifAbsentPut: [canvas nextId]
    ]

    id [
	<category: 'accessing'>
	^self attributes at: 'id'
    ]

    id: aString [
	"The id attribute assigns a identifier to an element. The id of an element must be unique within a document."

	<category: 'attributes-core'>
	self attributes at: 'id' put: aString
    ]

    isClosed [
	"Answer true if this tag should be closed immediately, such as <br />."

	<category: 'testing'>
	^false
    ]

    language: aString [
	"Set the language code."

	<category: 'attributes-language'>
	(self attributes)
	    at: 'lang' put: aString;
	    at: 'xml:lang' put: aString
    ]

    onBlur: aString [
	"The onblurs event occurs when the element that is in focus, loses that focus."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onblur'
	    append: aString
	    separator: ';'
    ]

    onChange: aString [
	"The onchange event occurs when a select input element has a selection made or when a text input element has a change in the text."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onchange'
	    append: aString
	    separator: ';'
    ]

    onClick: aString [
	"The onclick event occurs when the pointing device button is clicked over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onclick'
	    append: aString
	    separator: ';'
    ]

    onDoubleClick: aString [
	"The ondblclick event occurs when the pointing device button is double clicked over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'ondblclick'
	    append: aString
	    separator: ';'
    ]

    onEnter: aString [
	"If 'enter' is pressed"

	<category: 'convenience'>
	self 
	    onKeyPress: 'if((window.event ? window.event.keyCode : event.which) == 13){' 
		    , aString seasideString , '; return false}; return true'
    ]

    onError: aString [
	<category: 'convenience'>
	self attributes 
	    at: 'onerror'
	    append: aString
	    separator: ';'
    ]

    onFocus: aString [
	"The onfocus event occurs when an element receives focus either by the pointing device or by tabbing navigation."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onfocus'
	    append: aString
	    separator: ';'
    ]

    onKeyDown: aString [
	"The onkeydown event occurs when a key is pressed down over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onkeydown'
	    append: aString
	    separator: ';'
    ]

    onKeyPress: aString [
	"The onkeypress event occurs when a key is pressed and released over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onkeypress'
	    append: aString
	    separator: ';'
    ]

    onKeyUp: aString [
	"The onkeyup event occurs when a key is released over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onkeyup'
	    append: aString
	    separator: ';'
    ]

    onLoad: aString [
	"The onload event occurs when the user agent finishes loading a window."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onload'
	    append: aString
	    separator: ';'
    ]

    onMouseDown: aString [
	"The onmousedown event occurs when the pointing device button is pressed over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onmousedown'
	    append: aString
	    separator: ';'
    ]

    onMouseMove: aString [
	"The onmousemove event occurs when the pointing device is moved while it is over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onmousemove'
	    append: aString
	    separator: ';'
    ]

    onMouseOut: aString [
	"The onmouseout event occurs when the pointing device is moved away from an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onmouseout'
	    append: aString
	    separator: ';'
    ]

    onMouseOver: aString [
	"The onmouseover event occurs when the pointing device is moved onto an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onmouseover'
	    append: aString
	    separator: ';'
    ]

    onMouseUp: aString [
	"The onmouseup event occurs when the pointing device button is released over an element."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onmouseup'
	    append: aString
	    separator: ';'
    ]

    onReset: aString [
	"The onreset event occurs when a form is reset."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onreset'
	    append: aString
	    separator: ';'
    ]

    onResize: aString [
	<category: 'convenience'>
	self attributes 
	    at: 'onresize'
	    append: aString
	    separator: ';'
    ]

    onScroll: aString [
	<category: 'convenience'>
	self attributes 
	    at: 'onscroll'
	    append: aString
	    separator: ';'
    ]

    onSelect: aString [
	"The onselect event occurs when a user selects some text in a text field."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onselect'
	    append: aString
	    separator: ';'
    ]

    onSubmit: aString [
	"The onsubmit event occurs when a form is submitted."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onsubmit'
	    append: aString
	    separator: ';'
    ]

    onUnload: aString [
	"The onunload event occurs when the user agent removes a document from a window."

	<category: 'attributes-events'>
	self attributes 
	    at: 'onunload'
	    append: aString
	    separator: ';'
    ]

    openTag [
	"Open the receiving and all associated attributes onto the document."

	<category: 'private'>
	self document 
	    openTag: self tag
	    attributes: attributes
	    closed: self isClosed
    ]

    session [
	<category: 'accessing'>
	^WACurrentSession value
    ]

    style: aString [
	"This attribute offers optional CSS style information. The attribute is deprecated and should be avoided in favor of an external stylesheet. Multiple styles might be added to one brush."

	<category: 'attributes-core'>
	self attributes addStyle: aString
    ]

    tabIndex: aString [
	"This attribute specifies the position of the current element in the tabbing order for the current document. This value must be a number between 0 and 32767.
	 
	 The tabbing order defines the order in which elements will receive focus when navigated by the user via the keyboard. The tabbing order may include elements nested within other elements.
	 
	 The following elements support the tabindex attribute: A, AREA, BUTTON, INPUT, OBJECT, SELECT, and TEXTAREA."

	<category: 'attributes-keyboard'>
	self attributes at: 'tabindex' put: aString
    ]

    tag [
	<category: 'private'>
	self subclassResponsibility
    ]

    title: aString [
	"This attribute offers advisory information about the element for which it is set. Visual browsers frequently display the title as a 'tool tip'."

	<category: 'attributes-core'>
	self attributes at: 'title' put: aString
    ]

    with: anObject [
	"Render anObject into the receiver. Make sure that you call #with: last in the cascade, as this method will serialize the tag onto the output document."

	<category: 'public'>
	self openTag.
	super with: 
		[self before.
		anObject renderOn: canvas.
		self after].
	self closeTag
    ]

    withLineBreaks: aString [
	"Renders text preserving line breaks."

	<category: 'convenience'>
	self with: [canvas withLineBreaks: aString]
    ]
]



WATagBrush subclass: WAAnchorTag [
    | url |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I''m the class responsible for adding anchors (links) to your webpage. There are multiple ways of using me.

1. In the following case, the method #doSomethingOnClick will be sent to self when the user click on the anchor ''Click here to do something'':

	html anchor
		callback: [ self doSomethingOnClick ];
		with: ''Click here to do something''.
		
The following code is a shortcut to create an anchor. The executed action is #doSomethingOnClick and the text is ''Do Something On Click'':

	html anchor
		on: #doSomethingOnClick of: self

2. In the following case, a link to an external resource will be generated:

	html anchor
		url: ''http://www.seaside.st'';
		with: ''Visit the Seaside'''>

    callback: aBlock [
	<category: 'callbacks'>
	self url addParameter: (canvas callbacks registerActionCallback: aBlock)
    ]

    canHaveShortcut [
	<category: 'deprecated'>
	^true
    ]

    document: aDocument [
	<category: 'documents'>
	self document: aDocument mimeType: nil
    ]

    document: aDocument mimeType: mimeType [
	<category: 'documents'>
	self 
	    document: aDocument
	    mimeType: mimeType
	    fileName: nil
    ]

    document: aDocument mimeType: mimeType fileName: fileName [
	<category: 'documents'>
	self url: (canvas context 
		    urlForDocument: aDocument
		    mimeType: mimeType
		    fileName: fileName)
    ]

    extraParameters: aCollection [
	<category: 'url'>
	self url addParameter: aCollection
    ]

    extraPath: aString [
	<category: 'url'>
	self url addToPath: aString
    ]

    fragment: aString [
	<category: 'url'>
	self url fragment: aString
    ]

    ignoreURL [
	"does nothing when clicked"

	<category: 'deprecated'>
	^self onClick: 'return false'
    ]

    mailto: aString [
	<category: 'deprecated'>
	self deprecatedApi.
	self
	    url: 'mailto:' , aString;
	    with: aString
    ]

    name: aString [
	<category: 'attributes'>
	self attributes at: 'name' put: aString
    ]

    navigation [
	"Makes the receiving anchor a purely navigational link, this is it won't redirect after processing the callbacks but directly process with the render phase. Don't use this feature if you change your model in the callback'."

	<category: 'public'>
	self url addParameter: '_n'
    ]

    newTarget [
	<category: 'deprecated'>
	self deprecatedApi.
	self target: '_new'
    ]

    on: aSymbol of: anObject [
	<category: 'callbacks'>
	self callback: [anObject perform: aSymbol].
	self with: (self labelForSelector: aSymbol of: anObject)
    ]

    rel: aString [
	<category: 'deprecated'>
	self deprecatedApi.
	self relationship: aString
    ]

    relationship: aString [
	<category: 'attributes'>
	self attributes at: 'rel' put: aString
    ]

    resourceUrl: aString [
	<category: 'url'>
	self url: (canvas context absoluteUrlForResource: aString)
    ]

    submitFormNamed: aString [
	"Submits a form with the id aString."

	<category: 'conveniance'>
	self onClick: 'document.forms[' , aString printString , '].submit()'
    ]

    tag [
	<category: 'private'>
	^'a'
    ]

    target: aString [
	<category: 'deprecated'>
	self deprecatedApi.
	self attributeAt: 'target' put: aString
    ]

    text: aString [
	<category: 'deprecated'>
	self deprecatedApi.
	self with: aString
    ]

    url [
	<category: 'accessing'>
	^url ifNil: [url := canvas context actionUrl copy]
    ]

    url: aString [
	<category: 'accessing'>
	url := aString
    ]

    with: aBlock [
	<category: 'public'>
	url isNil 
	    ifFalse: [self attributes at: 'href' put: url]
	    ifTrue: 
		[((self attributes includesKey: 'href') 
		    or: [self attributes includesKey: 'name']) 
			ifFalse: [self attributes at: 'href' put: 'javascript:void(0)']].
	super with: aBlock
    ]
]



WAAnchorTag subclass: WAImageMapTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'A WAImageMapTag is supposed to be used like this:

	html map
		callback: [ :point | self click: point ];
		with: [ html image url: ''foo.gif'' ]
			
An example can be found in WAScreenshot.

Technincal:
http://www.w3.org/TR/html4/struct/objects.html#include-maps

The location clicked is passed to the server as follows. The user agent derives a new URI from the URI specified by the href attribute of the A element, by appending `?'' followed by the x and y coordinates, separated by a comma. The link is then followed using the new URI. For instance, in the given example, if the user clicks at the location x=10, y=27 then the derived URI is "http://www.acme.com/cgi-bin/competition?10,27".
'>

    callback: aBlock [
	"The parameter for the image-map callback must be the last one, as the web-browser will use the same name and replace it with the coordinates."

	<category: 'callbacks'>
	aBlock fixCallbackTemps.
	self url addParameter: (canvas callbacks 
		    registerCallback: [:value | aBlock value: (self parseImageMap: value)])
	    value: ''
    ]

    parseImageMap: aString [
	<category: 'private'>
	| stream x y |
	('?*,*' match: aString) ifFalse: [^nil].
	stream := aString readStream.
	stream upTo: $?.
	x := stream upTo: $,.
	y := stream upToEnd.
	^x asInteger @ y asInteger
    ]
]



WAAnchorTag subclass: WAPopupAnchorTag [
    | name features |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I am used to create a link that opens in a new window. A name can be specified using #name: and many features can be configured. Note, that not all features are supported on all web browser platforms. If Javascript is disabled the link will behave like any other anchor.

Most of the time a popup-anchor is created like this:

	html popupAnchor
		callback: [ WARenderLoop new call: WACounter new ];
		with: ''Open the counter within a new window''

This code creates a new render-loop and displays a new instance of WACounter within the new browser window.		
'>

    beDependent [
	<category: 'deprecated'>
	self deprecatedApi.
	self dependent: true
    ]

    beResizable [
	<category: 'deprecated'>
	self deprecatedApi.
	self resizable: true
    ]

    dependent: aBoolean [
	"Specifies whether the new window is closed as well when the parent window gets closed."

	<category: 'features'>
	features at: #dependent put: aBoolean
    ]

    extent: aPoint [
	"Specifies the width and height of the new window."

	<category: 'features'>
	self
	    width: aPoint x;
	    height: aPoint y
    ]

    featureString [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		features associations do: 
			[:assoc | 
			stream
			    nextPutAll: assoc key;
			    nextPut: $=.
			stream nextPutAll: (assoc value == true 
				    ifTrue: ['yes']
				    ifFalse: [assoc value == false ifTrue: ['no'] ifFalse: [assoc value seasideString]])]
		    separatedBy: [stream nextPut: $,]]
    ]

    height: anInteger [
	"Specifies the height of the new window."

	<category: 'features'>
	features at: #height put: anInteger
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	name := '_blank'.
	features := Dictionary new
    ]

    left: anInteger [
	"Specifies the x coordinate of the top left corner of the new window."

	<category: 'features'>
	features at: #left put: anInteger
    ]

    location: aBoolean [
	"Specifies whether to display the address line in the new window."

	<category: 'features'>
	features at: #location put: aBoolean
    ]

    menubar: aBoolean [
	"Specifies whether to display the browser menu bar."

	<category: 'features'>
	features at: #menubar put: aBoolean
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	"String specifying the name of the new window. If a window with this name already exists, then the new content will be displayed in that existing window, rather than creating a new one."

	<category: 'accessing'>
	name := aString
    ]

    position: aPoint [
	"Specifies the x and y coordinates of the top left corner of the new window."

	<category: 'features'>
	self
	    left: aPoint x;
	    top: aPoint y
    ]

    resizable: aBoolean [
	"Specifies whether the new window is resizable."

	<category: 'features'>
	features at: #resizable put: aBoolean
    ]

    scrollbars: aBoolean [
	"Specifies whether the new window should have scrollbars."

	<category: 'features'>
	features at: #scrollbars put: aBoolean
    ]

    showScrollbars [
	<category: 'deprecated'>
	self deprecatedApi.
	self scrollbars: true
    ]

    showToolbar [
	<category: 'deprecated'>
	self deprecatedApi.
	self toolbar: true
    ]

    status: aBoolean [
	"Specifies whether to display the browser status bar."

	<category: 'features'>
	features at: #status put: aBoolean
    ]

    toolbar: aBoolean [
	"Specifies whether to display the toolbar in the new window."

	<category: 'features'>
	features at: #toolbar put: aBoolean
    ]

    top: anInteger [
	"Specifies the y coordinate of the top left corner of the new window."

	<category: 'features'>
	features at: #top put: anInteger
    ]

    width: anInteger [
	"Specifies the width of the new window."

	<category: 'features'>
	features at: #width put: anInteger
    ]

    with: aBlock [
	<category: 'public'>
	self 
	    onClick: 'window.open(this.href,' , self name printString , ',' 
		    , self featureString printString , ');return false'.
	super with: aBlock
    ]
]



WATagBrush subclass: WABreakTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'The BR element forcibly breaks (ends) the current line of text. Authors are advised to use style sheets to control text flow around floating images and other objects.

Prohibiting a line break 

Sometimes authors may want to prevent a line break from occurring between two words. The &nbsp; entity (&#160; or &#xA0;) acts as a space where user agents should not cause a line break.'>

    isClosed [
	<category: 'testing'>
	^true
    ]

    tag [
	<category: 'accessing'>
	^'br'
    ]
]



WATagBrush subclass: WACollectionTag [
    | list selected callbackBlock labelBlock |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'This element allows the use to select one (in single selection mode) or multiple (in single selection mode) elements. Multiple selection can be triggered with #beMultiple, single selection can be triggered with #beSingle .Default is single selection.

The general idea is that you pass the colletion of options to #list: and use #labels: to customize their rendering. The selected option(s) can be set with: #selected:.


This whole class is kind of an akward hack, but noone needs MI anyway. You can always get a way with composition and delegation'>

    add: anObject [
	<category: 'adding'>
	self list add: anObject
    ]

    addAll: aCollection [
	<category: 'adding'>
	self list addAll: aCollection
    ]

    before [
	<category: 'private'>
	super before.
	self hasList 
	    ifTrue: 
		[self list 
		    do: [:each | self renderListItem: each labelled: (self labelForOption: each)]]
    ]

    callback: aBlock [
	<category: 'callbacks'>
	callbackBlock := aBlock fixCallbackTemps
    ]

    hasCallback [
	<category: 'testing'>
	^callbackBlock notNil
    ]

    hasList [
	<category: 'testing'>
	^list notNil and: [list notEmpty]
    ]

    isSelected: anObject [
	"Test if anObject is currently selected."

	<category: 'testing'>
	^selected = anObject
    ]

    labelForOption: anObject [
	<category: 'private'>
	^labelBlock isNil ifTrue: [anObject] ifFalse: [labelBlock value: anObject]
    ]

    labels: aBlock [
	"Allows to customize the rendering of list items by passing a one argument block that converts each option to a string. If you need to do custom html rendering for the options use #with: or override #renderOn: in your objects."

	<category: 'callbacks'>
	labelBlock := aBlock fixCallbackTemps
    ]

    list [
	<category: 'accessing'>
	^list ifNil: [list := OrderedCollection new]
    ]

    list: aCollection [
	"Append aCollection of items to display. The rendering can be customized using #labels:."

	<category: 'accessing'>
	aCollection ifNotNil: [:foo | self addAll: aCollection]
    ]

    on: aSelector of: anObject [
	<category: 'callbacks'>
	self selected: (anObject perform: aSelector).
	self 
	    callback: [:value | anObject perform: aSelector asMutator with: value]
    ]

    performCallback: anObject [
	<category: 'private'>
	self hasCallback ifTrue: [callbackBlock value: anObject]
    ]

    renderListItem: anObject labelled: aString [
	<category: 'private'>
	self subclassResponsibility
    ]

    selected: anObject [
	"Set anObject to be selected."

	<category: 'accessing'>
	selected := anObject
    ]
]



WACollectionTag subclass: WAListTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'Abstract base class for ordered and unordered list tags.

Ordered and unordered lists are rendered in an identical manner except that visual user agents number ordered list items. User agents may present those numbers in a variety of ways. Unordered list items are not numbered.

Both types of lists are made up of sequences of list items defined by the LI element (whose end tag may be omitted).

Lists may also be nested.'>

    renderListItem: anObject labelled: aString [
	<category: 'private'>
	(canvas listItem)
	    class: 'option-selected' if: (self isSelected: anObject);
	    with: 
		    [self hasCallback 
			ifFalse: [canvas render: aString]
			ifTrue: 
			    [(canvas anchor)
				callback: [self performCallback: anObject];
				with: aString]]
    ]
]



WAListTag subclass: WAOrderedListTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'See superclass comment.'>

    tag [
	<category: 'accessing'>
	^'ol'
    ]
]



WAListTag subclass: WAUnorderedListTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'See superclass comment.'>

    tag [
	<category: 'accessing'>
	^'ul'
    ]
]



WACollectionTag subclass: WASelectTag [
    | enabledBlock isOptional optionalLabel |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'This element allows the use to select one (in single selection mode) or multiple (in single selection mode) elements. Default is single selection. Multiple selection can be triggered with #beMultiple.

Single selection is in general a drop-down list, so make sure the list of options is not too big.
Multiple selection has in general crappy browser support and a list of checkboxes is in general the better option.

If in single selection mode and you want enable "no selection" see #beOptional.

If you absolutely need to you can render the options yourself with ''html option'' inside #with:

Make sure to check the superclass for more methods.

See WAInputTest >> #renderSingleSelectionOn: and WAInputTest >> #renderMultiSelectionOn: for examples.'>

    beMultiple [
	<category: 'deprecated'>
	self 
	    deprecatedApi: 'Use #multiSelect (constructure-method) instead of #beMultiple'.
	self primitiveChangeClassTo: WAMultiSelectTag new
    ]

    beOptional [
	"This adds a nil item to #list: which has the semantic of no selection. #optionalLabel: is the label for nil. This only really makes sense in single selection mode."

	<category: 'attributes'>
	isOptional := true
    ]

    beSingle [
	<category: 'deprecated'>
	self 
	    deprecatedApi: 'Use #select (constructure-method) instead of #beSingle'.
	self primitiveChangeClassTo: WASelectTag new
    ]

    beSubmitOnChange [
	"Submit the form in the user selects a value."

	<category: 'attributes'>
	self onChange: 'submit()'
    ]

    before [
	<category: 'private'>
	self isOptional ifTrue: [self renderOptional].
	super before
    ]

    dispatchCallback [
	<category: 'private'>
	^canvas callbacks registerDispatchCallback
    ]

    enabled: aBlock [
	"Enable only those elements for selection for whom aBlock return true."

	<category: 'callbacks'>
	enabledBlock := aBlock fixCallbackTemps
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	isOptional := false
    ]

    isEnabled: anObject [
	"Test if anObject is enabled."

	<category: 'testing'>
	^enabledBlock isNil or: [enabledBlock value: anObject]
    ]

    isOptional [
	<category: 'testing'>
	^isOptional
    ]

    name: aString [
	"This attribute assigns the control name."

	<category: 'attributes'>
	self attributes at: 'name' put: aString
    ]

    openTag [
	<category: 'private'>
	self attributes at: 'name' ifAbsentPut: [self dispatchCallback].
	super openTag
    ]

    optionalLabel: aString [
	"The label for the nil element. See #beOptional."

	<category: 'attributes'>
	optionalLabel := aString
    ]

    renderListItem: anObject labelled: aString [
	<category: 'private'>
	| option |
	option := canvas option.
	self hasCallback 
	    ifTrue: [option callback: [self performCallback: anObject]].
	option
	    selected: (self isSelected: anObject);
	    disabled: (self isEnabled: anObject) not;
	    with: aString
    ]

    renderOptional [
	<category: 'private'>
	self renderListItem: nil labelled: optionalLabel
    ]

    size: aNumber [
	"If a SELECT element is presented as a scrolled list box, this attribute specifies the number of rows in the list that should be visible at the same time. Visual user agents are not required to present a SELECT element as a list box; they may use any other mechanism, such as a drop-down menu."

	<category: 'attributes'>
	self attributes at: 'size' put: aNumber
    ]

    tag [
	<category: 'accessing'>
	^'select'
    ]
]



WASelectTag subclass: WAMultiSelectTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    closeTag [
	<category: 'private'>
	super closeTag.
	self hasCallback ifFalse: [^self].
	canvas insert: 
		[canvas hiddenInput 
		    callback: [self hasCallback ifTrue: [callbackBlock value: selected]]]
    ]

    dispatchCallback [
	<category: 'private'>
	^canvas callbacks registerMultiDispatchCallback
    ]

    isSelected: anObject [
	<category: 'testing'>
	^selected notNil and: [selected includes: anObject]
    ]

    openTag [
	<category: 'private'>
	self hasCallback 
	    ifTrue: 
		[canvas 
		    insert: [canvas hiddenInput callback: [selected := OrderedCollection new]]].
	self attributes at: 'multiple' put: true.
	super openTag
    ]

    performCallback: anObject [
	<category: 'private'>
	selected add: anObject
    ]
]



WATagBrush subclass: WADivTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    clear [
	<category: 'public api'>
	self class: 'clear'.
	self with: [canvas space]
    ]

    tag [
	<category: 'accessing'>
	^'div'
    ]
]



WATagBrush subclass: WAFieldSetTag [
    | legend |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'The FIELDSET element allows authors to group thematically related controls and labels. Grouping controls makes it easier for users to understand their purpose while simultaneously facilitating tabbing navigation for visual user agents and speech navigation for speech-oriented user agents. The proper use of this element makes documents more accessible.

The LEGEND element allows authors to assign a caption to a FIELDSET. The legend improves accessibility when the FIELDSET is rendered non-visually.'>

    before [
	<category: 'private'>
	legend ifNotNil: [:foo | canvas legend: legend]
    ]

    legend: aString [
	<category: 'accessing'>
	legend := aString
    ]

    tag [
	<category: 'accessing'>
	^'fieldset'
    ]
]



WATagBrush subclass: WAFormInputTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    callback: aBlock [
	<category: 'callbacks'>
	self name: (canvas callbacks registerCallback: aBlock)
    ]

    isClosed [
	<category: 'testing'>
	^true
    ]

    name: aString [
	<category: 'attributes'>
	self attributes at: 'name' put: aString
    ]

    on: selector of: anObject [
	<category: 'callbacks'>
	self value: (anObject perform: selector).
	self callback: [:value | anObject perform: selector asMutator with: value]
    ]

    readonly: aBoolean [
	"When set to true, this boolean attribute prohibits changes to the widget."

	<category: 'attributes'>
	self attributes at: 'readonly' put: aBoolean
    ]

    setFocus [
	"Makes this element have the initial focus once the page is loaded aka autofocus."

	<category: 'javascript'>
	self ensureId.
	self session addLoadScript: 'setFocus(' , self id printString , ')'
    ]

    submitOnClick [
	<category: 'attributes'>
	self onClick: 'submit()'
    ]

    tag [
	<category: 'accessing'>
	^'input'
    ]

    text: aString [
	<category: 'attributes'>
	self value: aString
    ]

    type [
	<category: 'accessing'>
	^nil
    ]

    type: aString [
	<category: 'attributes'>
	self attributes at: 'type' put: aString
    ]

    value [
	<category: 'attributes'>
	^self attributes at: 'value'
    ]

    value: anObject [
	<category: 'attributes'>
	anObject ifNotNil: [:foo | self attributes at: 'value' put: anObject]
    ]

    with: aBlock [
	<category: 'public'>
	self type isNil 
	    ifFalse: 
		[self attributes at: 'type' ifAbsentPut: [self type].
		self class: self type].
	super with: aBlock
    ]
]



WAFormInputTag subclass: WAAbstractTextAreaTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'An abstract class to describe the HTML elements that allow the user to enter text.'>

    callback: aBlock [
	<category: 'callbacks'>
	self name: (canvas callbacks registerCallback: aBlock).
	self value: self value
    ]

    exampleText: aString [
	<category: 'javascript'>
	(self value isEmptyOrNil or: [self value = aString]) ifFalse: [^self].
	self onFocus: 'if(value==' , aString printString 
		    , '){value='''';style.color=null}'.
	self
	    style: 'color: #aaa';
	    value: aString
    ]

    setCursorPosition: anInteger [
	<category: 'javascript'>
	self setSelectionFrom: anInteger to: anInteger
    ]

    setSelectionFrom: aStartInteger to: aStopInteger [
	"Insert the javascript for setting the selection"

	<category: 'javascript'>
	| aStream |
	self ensureId.
	aStream := (String new: 30) writeStream.
	aStream
	    nextPutAll: 'setSelection(''';
	    nextPutAll: self id;
	    nextPutAll: ''''.
	aStartInteger isNumber 
	    ifTrue: 
		[aStream
		    nextPut: $,;
		    print: aStartInteger]
	    ifFalse: [aStream nextPutAll: ',1'].
	aStopInteger isNumber 
	    ifTrue: 
		[aStream
		    nextPut: $,;
		    print: aStopInteger].
	aStream nextPut: $).
	self session addLoadScript: aStream contents
    ]
]



WAAbstractTextAreaTag subclass: WATextAreaTag [
    | value |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I am a multi line text input widget. See WAInputTest >> #renderTextAreaWithExampleOn: for examples.'>

    columns: anInteger [
	"This attribute specifies the visible width in average character widths. User agents may wrap visible text lines to keep long lines visible without the need for scrolling."

	<category: 'attributes'>
	self attributeAt: 'cols' put: anInteger
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self
	    rows: 'auto';
	    columns: 'auto'
    ]

    isClosed [
	<category: 'testing'>
	^false
    ]

    rows: anInteger [
	"This attribute specifies the number of visible text lines. If more are entered, the widget scrolls."

	<category: 'attributes'>
	self attributeAt: 'rows' put: anInteger
    ]

    tag [
	<category: 'accessing'>
	^'textarea'
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aString [
	<category: 'accessing'>
	value := aString
    ]

    with: aBlock [
	<category: 'public'>
	super with: (value ifNil: [aBlock])
    ]
]



WAAbstractTextAreaTag subclass: WATextInputTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I am a single line text input widget. See WAInputTest >> #renderTextInputWithExampleOn: for examples.'>

    maxLength: aNumber [
	"This attribute specifies the maximum number of characters the user may enter. This number may exceed the specified #size:, in which case the user agent should offer a scrolling mechanism. The default value for this attribute is an unlimited number."

	<category: 'attributes'>
	self attributeAt: 'maxlength' put: aNumber
    ]

    size: aNumber [
	"This attribute tells the user agent the initial width of the widget. The width is given in number of characters."

	<category: 'attributes'>
	self attributeAt: 'size' put: aNumber
    ]

    type [
	<category: 'accessing'>
	^'text'
    ]
]



WATextInputTag subclass: WAPasswordInputTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I am a password input widget that does not display the entered text.'>

    type [
	<category: 'accessing'>
	^'password'
    ]
]



WAFormInputTag subclass: WACheckboxTag [
    | value callback |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    after [
	<category: 'private'>
	canvas hiddenInput callback: 
		[callback value: value.
		value := false]
    ]

    callback: aBlock [
	<category: 'callbacks'>
	value := false.
	callback := aBlock fixCallbackTemps.
	super callback: [value := true]
    ]

    canHaveShortcut [
	<category: 'javascript'>
	^true
    ]

    onTrue: trueBlock onFalse: falseBlock [
	<category: 'attributes'>
	trueBlock fixCallbackTemps.
	falseBlock fixCallbackTemps.
	self 
	    callback: [:v | v ifTrue: [trueBlock value] ifFalse: [falseBlock value]]
    ]

    submitFormNamed: formName [
	<category: 'attributes'>
	self onClick: 'submitForm(''' , formName seasideString , '''); return false;'
    ]

    type [
	<category: 'accessing'>
	^'checkbox'
    ]

    value: aBoolean [
	<category: 'attributes'>
	self attributeAt: 'checked' put: aBoolean
    ]
]



WAFormInputTag subclass: WAFileUploadTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'I represent a file input element (<input type="file"). My callbacks will be evaluated with an instance of WAFile as an argument.'>

    accept: aString [
	"This attribute specifies a comma-separated list of content types that a server processing this form will handle correctly. User agents may use this information to filter out non-conforming files when prompting a user to select files to be sent to the server"

	<category: 'attributes'>
	self attributes at: 'accept' put: aString
    ]

    callback: aBlock [
	<category: 'callbacks'>
	aBlock fixCallbackTemps.
	super callback: [:file | aBlock value: (file = '' ifFalse: [file])]
    ]

    on: selector of: anObject [
	<category: 'callbacks'>
	self callback: [:value | anObject perform: selector asMutator with: value]
    ]

    type [
	<category: 'accessing'>
	^'file'
    ]
]



WAFormInputTag subclass: WAHiddenInputTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'Authors may create controls that are not rendered but whose values are submitted with a form. Authors generally use this control type to store information between client/server exchanges that would otherwise be lost due to the stateless nature of HTTP (see [RFC2616]). The INPUT element is used to create a hidden control.'>

    type [
	<category: 'accessing'>
	^'hidden'
    ]
]



WAFormInputTag subclass: WARadioButtonTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    beChecked [
	<category: 'attributes'>
	self attributeAt: 'checked' put: true
    ]

    beUnchecked [
	<category: 'attributes'>
	self attributeAt: 'checked' put: false
    ]

    callback: aBlock [
	<category: 'callbacks'>
	self value: (canvas callbacks registerCallback: aBlock)
    ]

    canHaveShortcut [
	<category: 'javascript'>
	^true
    ]

    group: aRadioGroup [
	<category: 'attributes'>
	self name: aRadioGroup key
    ]

    selected: aBoolean [
	<category: 'attributes'>
	self attributeAt: 'checked' put: aBoolean
    ]

    type [
	<category: 'accessing'>
	^'radio'
    ]
]



WAFormInputTag subclass: WASubmitButtonTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    callback: aBlock [
	<category: 'callbacks'>
	self name: (canvas callbacks registerActionCallback: aBlock)
    ]

    canHaveShortcut [
	<category: 'javascript'>
	^true
    ]

    on: aSymbol of: anObject [
	<category: 'callbacks'>
	self value: (self labelForSelector: aSymbol of: anObject).
	self callback: [anObject perform: aSymbol]
    ]

    type [
	<category: 'accessing'>
	^'submit'
    ]
]



WASubmitButtonTag subclass: WAButtonTag [
    | type value |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'Buttons created with the BUTTON element function just like buttons created with the INPUT element, but they offer richer rendering possibilities: the BUTTON element may have content. For example, a BUTTON element that contains an image functions like and may resemble an INPUT element whose type is set to "image", but the BUTTON element type allows content.'>

    bePush [
	"Creates a push button. Push buttons have no default behavior. Each push button may have client-side scripts associated with the element's event attributes. When an event occurs (e.g., the user presses the button, releases it, etc.), the associated script is triggered."

	<category: 'accessing'>
	type := 'button'
    ]

    beReset [
	"Creates a reset button. When activated it resets all controls to their initial values."

	<category: 'accessing'>
	type := 'reset'
    ]

    beSubmit [
	"Creates a submit button. When activated, a submit button submits a form. A form may contain more than one submit button. This is the default."

	<category: 'accessing'>
	type := 'submit'
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self beSubmit
    ]

    isClosed [
	<category: 'testing'>
	^false
    ]

    tag [
	<category: 'accessing'>
	^'button'
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aString [
	<category: 'accessing'>
	value := aString
    ]

    with: aBlock [
	<category: 'public'>
	super with: (value ifNil: [aBlock])
    ]
]



WASubmitButtonTag subclass: WACancelButtonTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    callback: aBlock [
	<category: 'callbacks'>
	self name: (canvas callbacks registerCancelActionCallback: aBlock)
    ]
]



WASubmitButtonTag subclass: WAImageButtonTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'Creates a graphical submit button. The value of the src attribute specifies the URI of the image that will decorate the button. For accessibility reasons, authors should provide alternate text for the image via the alt attribute. 

When a pointing device is used to click on the image, the form is submitted and the click coordinates passed to the server. The x value is measured in pixels from the left of the image, and the y value in pixels from the top of the image. The submitted data includes name.x=x-value and name.y=y-value where "name" is the value of the name attribute, and x-value and y-value are the x and y coordinate values, respectively.'>

    callback: aBlock [
	<category: 'attributes'>
	self name: (canvas callbacks registerImageCallback: aBlock)
    ]

    extent: aPoint [
	<category: 'attributes'>
	self
	    width: aPoint x;
	    height: aPoint y
    ]

    form: aForm [
	<category: 'attributes'>
	self extent: aForm extent.
	self url: (canvas context urlForDocument: aForm)
    ]

    height: aNumber [
	<category: 'attributes'>
	self attributes at: 'height' put: aNumber
    ]

    resourceUrl: aString [
	<category: 'attributes'>
	self url: (canvas context absoluteUrlForResource: aString)
    ]

    type [
	<category: 'accessing'>
	^'image'
    ]

    url: aString [
	<category: 'attributes'>
	self attributes at: 'src' put: aString
    ]

    width: aNumber [
	<category: 'attributes'>
	self attributes at: 'width' put: aNumber
    ]
]



WATagBrush subclass: WAFormTag [
    | defaultAction |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'The FORM element acts as a container for input elements and buttons.

Evaluation order:
The input fields callbacks will be evaluated in the order they
appear in the XHTML. Buttons will always be evaluated last, no matter
where they are positioned.'>

    acceptCharset: aString [
	"This attribute specifies the list of character encodings for input data that is accepted by the server processing this form. The value is a space- and/or comma-delimited list of charset values. The client must interpret this list as an exclusive-or list, i.e., the server is able to accept any single character encoding per entity received.
	 
	 The default value for this attribute is the reserved string 'UNKNOWN'. User agents may interpret this value as the character encoding that was used to transmit the document containing this FORM element."

	<category: 'attributes'>
	self attributeAt: 'accept-charset' put: aString
    ]

    action: aString [
	"This attribute specifies a form processing agent. User agent behavior for a value other than an HTTP URI is undefined."

	<category: 'attributes'>
	self attributeAt: 'action' put: aString
    ]

    after [
	<category: 'private'>
	canvas div: 
		[canvas context actionUrl parameters keysAndValuesDo: 
			[:k :v | 
			(canvas hiddenInput)
			    name: k;
			    value: v]]
    ]

    before [
	"Define the default action form buttons. Some implementation notes on this feature: (1) a tab-index of -1 is not valid XHTML, but most todays browser accept it and ignore the element in the tab-order. (2) Internet Explorer requires an additional text field (without other functionality) to make the default action work. Other browser should not include this text-field, as it prevents remembering form input."

	<category: 'private'>
	defaultAction ifNil: [^nil].
	canvas div: 
		[(canvas submitButton)
		    tabIndex: -1;
		    value: 'Default';
		    callback: defaultAction;
		    style: 'position: absolute; top: -100em'.
		self isInternetExplorer 
		    ifTrue: 
			[(canvas textInput)
			    tabIndex: -1;
			    callback: [:v | ];
			    style: 'position: absolute; top: -100em']]
    ]

    defaultAction: aBlock [
	"The default action gets evaluated whenever the user presses submits
	 the form by pressing enter without having the focus on a specific
	 submit-button."

	<category: 'callbacks'>
	defaultAction := aBlock
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self acceptCharset: WACurrentSession value charSet
    ]

    isInternetExplorer [
	"Tries to find out whether the current request is made by IE. This is extremely unrelyable."

	<category: 'private'>
	| userAgent |
	userAgent := self session currentRequest userAgent.
	^userAgent notNil and: 
		[(userAgent includesSubString: 'MSIE') 
		    and: [(userAgent includesSubString: 'Opera') not]]
    ]

    method: aString [
	"This attribute specifies which HTTP method will be used to submit the form data set. Possible (case-insensitive) values are 'get' (the default) and 'post'."

	<category: 'attributes'>
	self attributeAt: 'method' put: aString
    ]

    multipart [
	"Sets the content type used to submit the form to the server (when the value of method is 'post') to multipart/form-data instead the default application/x-www-form-urlencoded. This should be used in combination with a WAFileUploadTag."

	<category: 'attributes'>
	self attributeAt: 'enctype' put: 'multipart/form-data'
    ]

    multipart: aBoolean [
	"Sets the content type used to submit the form to the server.
	 true: sets the content type to multipart/form-data
	 false: leavess the content type to default application/x-www-form-urlencoded"

	<category: 'attributes'>
	aBoolean ifTrue: [self multipart]
    ]

    name: aString [
	<category: 'attributes'>
	self attributeAt: 'name' put: aString
    ]

    noAutocomplete [
	<category: 'attributes'>
	self attributeAt: 'autocomplete' put: 'off'
    ]

    post [
	<category: 'attributes'>
	self method: 'post'
    ]

    setParent: aBrush canvas: aCanvas [
	<category: 'initialize-release'>
	super setParent: aBrush canvas: aCanvas.
	self
	    post;
	    action: aCanvas context actionUrl withoutParameters
    ]

    tag [
	<category: 'private'>
	^'form'
    ]
]



WATagBrush subclass: WAGenericTag [
    | tag |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: nil>

    WAGenericTag class >> tag: aString [
	<category: 'instance-creation'>
	^self new initializeWithTag: aString
    ]

    initializeWithTag: aString [
	<category: 'initialize-release'>
	tag := aString
    ]

    tag [
	<category: 'accessing'>
	^tag
    ]
]



WAGenericTag subclass: WAEditTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'INS and DEL are used to markup sections of the document that have been inserted or deleted with respect to a different version of a document (e.g., in draft legislation where lawmakers need to view the changes).

These two elements are unusual for HTML in that they may serve as either block-level or inline elements (but not both). They may contain one or more words within a paragraph or contain one or more block-level elements such as paragraphs, lists and tables.

This example could be from a bill to change the legislation for how many deputies a County Sheriff can employ from 3 to 5.

<P>
  A Sheriff can employ <DEL>3</DEL><INS>5</INS> deputies.
</P>

The INS and DEL elements must not contain block-level content when these elements behave as inline elements.'>

    cite: aUrl [
	"The value of this attribute is a URI that designates a source document or message. This attribute is intended to point to information explaining why a document was changed."

	<category: 'attributes'>
	self attributeAt: 'cite' put: aUrl
    ]

    datetime: anObject [
	"The value of this attribute specifies the date and time when the change was made.
	 ISO date format"

	<category: 'attributes'>
	self attributeAt: 'datetime' put: anObject
    ]
]



WATagBrush subclass: WAHeadingTag [
    | level |
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'A heading element briefly describes the topic of the section it introduces. Heading information may be used by user agents, for example, to construct a table of contents for a document automatically.

There are six levels of headings in HTML with H1 as the most important and H6 as the least. Visual browsers usually render more important headings in larger fonts than less important ones.'>

    initialize [
	<category: 'initialization'>
	super initialize.
	self level1
    ]

    level [
	<category: 'accessing'>
	^level
    ]

    level1 [
	<category: 'conveniance'>
	level := 1
    ]

    level2 [
	<category: 'conveniance'>
	level := 2
    ]

    level3 [
	<category: 'conveniance'>
	level := 3
    ]

    level4 [
	<category: 'conveniance'>
	level := 4
    ]

    level5 [
	<category: 'conveniance'>
	level := 5
    ]

    level6 [
	<category: 'conveniance'>
	level := 6
    ]

    level: anInteger [
	<category: 'accessing'>
	level := (anInteger max: 1) min: 6
    ]

    tag [
	<category: 'private'>
	^'h' , self level seasideString
    ]
]



WATagBrush subclass: WAHorizontalRuleTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'The HR element causes a horizontal rule to be rendered by visual user agents.

The amount of vertical space inserted between a rule and the content that surrounds it depends on the user agent.'>

    isClosed [
	<category: 'testing'>
	^true
    ]

    tag [
	<category: 'accessing'>
	^'hr'
    ]
]



WATagBrush subclass: WAIframeTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'The IFRAME element allows authors to insert a frame within a block of text. Inserting an inline frame within a section of text is much like inserting an object via the OBJECT element: they both allow you to insert an HTML document in the middle of another, they may both be aligned with surrounding text, etc. 

The information to be inserted inline is designated by the src attribute of this element. The contents of the IFRAME element, on the other hand, should only be displayed by user agents that do not support frames or are configured not to display frames.

Inline frames may not be resized.'>

    contents: anObject [
	<category: 'conveniance'>
	self url: (canvas urlForAction: [self performRendering: anObject])
    ]

    document: anObject [
	<category: 'conveniance'>
	self document: anObject mimeType: nil
    ]

    document: anObject mimeType: aMimeString [
	<category: 'conveniance'>
	self 
	    document: anObject
	    mimeType: aMimeString
	    fileName: nil
    ]

    document: anObject mimeType: aMimeString fileName: aFileNameString [
	<category: 'conveniance'>
	self url: (canvas context 
		    urlForDocument: anObject
		    mimeType: aMimeString
		    fileName: aFileNameString)
    ]

    height: anInteger [
	"The height of the inline frame."

	<category: 'attributes'>
	self attributes at: 'height' put: anInteger
    ]

    name: aString [
	"This attribute assigns a name to the current frame. This name may be used as the target of subsequent links."

	<category: 'attributes'>
	self attributes at: 'name' put: aString
    ]

    performRendering: anObject [
	<category: 'private'>
	| innerContext docRoot session document response renderer |
	innerContext := canvas context copy.
	docRoot := WAHtmlRoot context: innerContext.
	docRoot base target: '_top'.
	session := WACurrentSession value.
	document := session outputDocumentClass new.
	response := WAResponse new.
	response headerAt: 'Cache-Control' put: 'No-cache'.
	document stream: response stream.
	canvas context document: document.
	docRoot open: document.
	renderer := canvas species context: canvas context
		    callbacks: canvas callbacks.
	renderer
	    render: anObject;
	    flush.
	docRoot close: document.
	session returnResponse: response
    ]

    src: anUrl [
	<category: 'deprecated'>
	self deprecatedApi.
	self url: anUrl
    ]

    tag [
	<category: 'accessing'>
	^'iframe'
    ]

    url: aString [
	<category: 'attributes'>
	self attributeAt: 'src' put: aString
    ]

    width: anInteger [
	"The width of the inline frame."

	<category: 'attributes'>
	self attributes at: 'width' put: anInteger
    ]
]



WATagBrush subclass: WAImageTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'The IMG element embeds an image in the current document at the location of the element''s definition. The IMG element has no content; it is usually replaced inline by the image designated by the src attribute, the exception being for left or right-aligned images that are "floated" out of line.

The alt attribute specifies alternate text that is rendered when the image cannot be displayed (see below for information on how to specify alternate text ). User agents must render alternate text when they cannot support images, they cannot support a certain image type or when they are configured not to display images.

Seaside per default sets the alternate text to an empty string. This helps validation of the page.'>

    altText: aString [
	"The alt attribute provides a short description of the image."

	<category: 'attributes'>
	self attributes at: 'alt' put: aString
    ]

    document: aDocument [
	<category: 'accessing'>
	self document: aDocument mimeType: nil
    ]

    document: aDocument mimeType: mimeType [
	<category: 'accessing'>
	self 
	    document: aDocument
	    mimeType: mimeType
	    fileName: nil
    ]

    document: aDocument mimeType: mimeType fileName: fileName [
	<category: 'accessing'>
	self url: (canvas context 
		    urlForDocument: aDocument
		    mimeType: mimeType
		    fileName: fileName)
    ]

    form: aForm [
	<category: 'accessing'>
	self document: aForm
    ]

    height: anInteger [
	<category: 'attributes'>
	self attributes at: 'height' put: anInteger
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self altText: ''
    ]

    isClosed [
	<category: 'testing'>
	^true
    ]

    resourceUrl: aString [
	<category: 'accessing'>
	self url: (canvas context absoluteUrlForResource: aString)
    ]

    setParent: aBrush canvas: aCanvas [
	<category: 'initialize-release'>
	super setParent: aBrush canvas: aCanvas.
	(aBrush isKindOf: WAImageMapTag) 
	    ifTrue: 
		["in case the parent is an image map we need to set this attribute"

		self attributeAt: 'ismap' put: true]
    ]

    src: aString [
	<category: 'deprecated'>
	self deprecatedApi.
	self url: aString
    ]

    tag [
	<category: 'private'>
	^'img'
    ]

    url: aString [
	<category: 'attributes'>
	self attributes at: 'src' put: aString
    ]

    width: anInteger [
	<category: 'attributes'>
	self attributes at: 'width' put: anInteger
    ]
]



WATagBrush subclass: WALabelTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    for: aString [
	<category: 'attributes'>
	self attributeAt: 'for' put: aString
    ]

    tag [
	<category: 'accessing'>
	^'label'
    ]
]



WATagBrush subclass: WAObjectTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    archive: aUrl [
	<category: 'attributes'>
	self attributeAt: 'archive' put: aUrl
    ]

    classId: aUrl [
	<category: 'attributes'>
	self attributeAt: 'classid' put: aUrl
    ]

    codebase: aUrl [
	<category: 'attributes'>
	self attributeAt: 'codebase' put: aUrl
    ]

    codetype: aString [
	<category: 'attributes'>
	self attributeAt: 'codetype' put: aString
    ]

    declare: aBoolean [
	<category: 'attributes'>
	self attributeAt: 'declare' put: aBoolean
    ]

    height: anInteger [
	<category: 'attributes'>
	self attributeAt: 'height' put: anInteger
    ]

    standby: aString [
	<category: 'attributes'>
	self attributeAt: 'standby' put: aString
    ]

    tag [
	<category: 'accessing'>
	^'object'
    ]

    type: aString [
	<category: 'attributes'>
	self attributeAt: 'type' put: aString
    ]

    url: aUrl [
	<category: 'attributes'>
	self attributeAt: 'data' put: aUrl
    ]

    width: anInteger [
	<category: 'attributes'>
	self attributeAt: 'width' put: anInteger
    ]
]



WATagBrush subclass: WAOptionGroupTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: 'The OPTGROUP element allows authors to group choices logically. This is particularly helpful when the user must choose from a long list of options; groups of related choices are easier to grasp and remember than a single long list of options.

It has crappy browser support and noone as ever used it. See WAInputTest >> #renderOptionGroupOn: for examples.'>

    initialize [
	<category: 'initialization'>
	super initialize.
	self label: ''
    ]

    label: aString [
	"This attribute specifies the label for the option group."

	<category: 'attributes'>
	self attributes at: 'label' put: aString
    ]

    tag [
	<category: 'accessing'>
	^'optgroup'
    ]
]



WATagBrush subclass: WAOptionTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    callback: aBlock [
	<category: 'callbacks'>
	self value: (canvas callbacks registerCallback: aBlock)
    ]

    label: aString [
	"This attribute allows authors to specify a shorter label for an option than the content of the OPTION element. When specified, user agents should use the value of this attribute rather than the content of the OPTION element as the option label."

	<category: 'attributes'>
	self attributes at: 'label' put: aString
    ]

    selected: aBoolean [
	<category: 'attributes'>
	self attributes at: 'selected' put: aBoolean
    ]

    tag [
	<category: 'accessing'>
	^'option'
    ]

    value: aString [
	<category: 'attributes'>
	self attributes at: 'value' put: aString
    ]
]



WATagBrush subclass: WAParameterTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    name: aString [
	<category: 'attributes'>
	self attributeAt: 'name' put: aString
    ]

    tag [
	<category: 'accessing'>
	^'param'
    ]

    type: aString [
	<category: 'attributes'>
	self attributeAt: 'type' put: aString
    ]

    value: aString [
	<category: 'attributes'>
	self attributeAt: 'value' put: aString
    ]
]



WATagBrush subclass: WARubyTextTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    span: anInteger [
	<category: 'attributes'>
	self attributeAt: 'rbspan' put: anInteger
    ]

    tag [
	<category: 'accessing'>
	^'rt'
    ]
]



WATagBrush subclass: WAScriptTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    after [
	<category: 'private'>
	self document nextPutAll: '/*]]>*/'
    ]

    before [
	<category: 'private'>
	self document nextPutAll: '/*<![CDATA[*/'
    ]

    defer [
	"When set, this boolean attribute provides a hint to the user agent that the script is not going to generate any document content (e.g., no 'document.write' in javascript) and thus, the user agent can continue parsing and rendering."

	<category: 'attributes'>
	self attributeAt: 'defer' put: true
    ]

    resourceUrl: aString [
	<category: 'attributes'>
	self url: (canvas context absoluteUrlForResource: aString)
    ]

    tag [
	<category: 'accessing'>
	^'script'
    ]

    url: aString [
	<category: 'attributes'>
	self attributes at: 'src' put: aString
    ]

    with: aString [
	<category: 'public'>
	self attributes at: 'type' ifAbsentPut: ['text/javascript'].
	super 
	    with: [aString isNil ifFalse: [self document nextPutAll: aString seasideString]]
    ]
]



WATagBrush subclass: WATableCellTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    align: aString [
	<category: 'attributes'>
	self attributes at: 'align' put: aString
    ]

    character: aStringOrCharacter [
	<category: 'attributes'>
	self attributes at: 'char' put: aStringOrCharacter seasideString
    ]

    characterOffset: anInteger [
	<category: 'attributes'>
	self attributes at: 'charoff' put: anInteger
    ]

    colSpan: anInteger [
	<category: 'attributes'>
	self attributes at: 'colspan' put: anInteger
    ]

    rowSpan: anInteger [
	<category: 'attributes'>
	self attributes at: 'rowspan' put: anInteger
    ]

    scope: aString [
	<category: 'attributes'>
	self attributes at: 'scope' put: aString
    ]

    verticalAlign: aString [
	<category: 'attributes'>
	self attributes at: 'valign' put: aString
    ]
]



WATableCellTag subclass: WATableDataTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    tag [
	<category: 'accessing'>
	^'td'
    ]
]



WATableCellTag subclass: WATableHeadingTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    tag [
	<category: 'accessing'>
	^'th'
    ]
]



WATagBrush subclass: WATableColumnGroupTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    align: aString [
	<category: 'attributes'>
	self attributes at: 'align' put: aString
    ]

    character: aStringOrCharacter [
	<category: 'attributes'>
	self attributes at: 'char' put: aStringOrCharacter seasideString
    ]

    characterOffset: anInteger [
	<category: 'attributes'>
	self attributes at: 'charoff' put: anInteger
    ]

    span: anInteger [
	<category: 'attributes'>
	self attributes at: 'span' put: anInteger
    ]

    tag [
	<category: 'accessing'>
	^'colgroup'
    ]

    verticalAlign: aString [
	<category: 'attributes'>
	self attributes at: 'valign' put: aString
    ]

    width: aNumber [
	<category: 'attributes'>
	self attributeAt: 'width' put: aNumber seasideString
    ]
]



WATableColumnGroupTag subclass: WATableColumnTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    isClosed [
	<category: 'testing'>
	^true
    ]

    tag [
	<category: 'accessing'>
	^'col'
    ]
]



WATagBrush subclass: WATableTag [
    
    <category: 'Seaside-Core-Canvas-Tags'>
    <comment: nil>

    align: aString [
	<category: 'deprecated'>
	self deprecatedApi.
	self attributes at: 'align' put: aString
    ]

    border: anInteger [
	<category: 'deprecated'>
	self deprecatedApi.
	self attributes at: 'border' put: anInteger
    ]

    cellpadding: anInteger [
	<category: 'attributes'>
	self attributes at: 'cellpadding' put: anInteger
    ]

    cellspacing: anInteger [
	<category: 'attributes'>
	self attributes at: 'cellspacing' put: anInteger
    ]

    frame: aString [
	"frame = void|above|below|hsides|lhs|rhs|vsides|box|border [CI]
	 This attribute specifies which sides of the frame surrounding a table will be visible. Possible values:
	 
	 * void: No sides. This is the default value.
	 * above: The top side only.
	 * below: The bottom side only.
	 * hsides: The top and bottom sides only.
	 * vsides: The right and left sides only.
	 * lhs: The left-hand side only.
	 * rhs: The right-hand side only.
	 * box: All four sides.
	 * border: All four sides."

	<category: 'attributes'>
	self attributes at: 'frame' put: aString
    ]

    layout [
	<category: 'deprecated'>
	self deprecatedApi.
	self border: 0.
	self cellspacing: 0.
	self cellpadding: 0
    ]

    rules: aString [
	"rules = none|groups|rows|cols|all [CI]
	 This attribute specifies which rules will appear between cells within a table. The rendering of rules is user agent dependent. Possible values:
	 
	 * none: No rules. This is the default value.
	 * groups: Rules will appear between row groups (see THEAD, TFOOT, and TBODY) and column groups (see COLGROUP and COL) only.
	 * rows: Rules will appear between rows only.
	 * cols: Rules will appear between columns only.
	 * all: Rules will appear between all rows and columns."

	<category: 'attributes'>
	self attributes at: 'rules' put: aString
    ]

    summary: aString [
	<category: 'attributes'>
	self attributes at: 'summary' put: aString
    ]

    tag [
	<category: 'accessing'>
	^'table'
    ]
]



Object subclass: WACachedDocument [
    | fullFileName mimeDocument mimeType |
    
    <category: 'Seaside-Core-Document'>
    <comment: 'This class is for serving smallish files like PNG images etc using WADocumentHandler. Using the Canvas API for HTML generation you simply do this:

	html image fileName: ''myimage.png''

or:

	html image fileName: ''myimage.blurp'' mimeType: ''blurp''

This will create a request handler in your WAApplication registry that is accessible on a unique URL and does not expire.
The actual contents of the file will only be read upon first access, we could augment this class with smarter caching, like checking the modification time on disk.

The class has a Cache class var holding a Dictionary of created instances so you can clear and preload files into the image using:

	WACachedDocument
		clearCache;
		fileName: ''myimage.png'';
		fileName: ''another.gif''; "etc"
		preloadCache'>

    DocumentCache := nil.

    WACachedDocument class >> clearCache [
	"Clear the cache of instances. This will cause
	 the files to be lazily reread from disk."

	<category: 'cache'>
	DocumentCache := Dictionary new
    ]

    WACachedDocument class >> fileName: aFileName [
	"Check the cache to see if we already have this file loaded.
	 We only rely on the local filename!!"

	<category: 'instance-creation'>
	^DocumentCache at: aFileName ifAbsentPut: [self fullFileName: aFileName]
    ]

    WACachedDocument class >> fullFileName: fullFileName [
	<category: 'instance-creation'>
	^self new fullFileName: fullFileName
    ]

    WACachedDocument class >> initialize [
	<category: 'initialize-release'>
	self clearCache
    ]

    WACachedDocument class >> preloadCache [
	"Load the files into the image for the currently
	 created instances in the Cache."

	<category: 'cache'>
	DocumentCache valuesDo: [:each | each asMIMEDocument]
    ]

    = other [
	"Currently we do not take file modification time on disk into account."

	<category: 'comparing'>
	^other species = self species and: [other fullFileName = fullFileName]
    ]

    asMIMEDocument [
	<category: 'public'>
	^self asMIMEDocumentType: mimeType
    ]

    asMIMEDocumentType: type [
	"Lazy caching."

	<category: 'public'>
	^mimeDocument ifNil: 
		[mimeType := type.
		mimeDocument := SeasidePlatformSupport mimeDocumentOfType: mimeType
			    from: fullFileName]
    ]

    fullFileName [
	<category: 'accessing'>
	^fullFileName
    ]

    fullFileName: aFileName [
	<category: 'initialize-release'>
	fullFileName := aFileName
    ]

    hash [
	"Currently we do not take file modification time on disk into account.
	 Note that mimeType and mimeDocument are set lazily later, so we can't use
	 the mimeType in the hash."

	<category: 'comparing'>
	^fullFileName hash
    ]

    mimeType [
	<category: 'accessing'>
	^mimeType
    ]

    mimeType: anObject [
	<category: 'accessing'>
	mimeType := anObject
    ]
]



Object subclass: WACallback [
    | context owner key |
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    <= other [
	<category: 'comparing'>
	^self priority < other priority or: 
		[self priority = other priority 
		    and: [self key asNumber <= other key asNumber]]
    ]

    context [
	<category: 'accessing'>
	^context
    ]

    convertKey: aString [
	<category: 'converting'>
	^aString
    ]

    evaluateWithArgument: anObject [
	<category: 'evaluation'>
	self subclassResponsibility
    ]

    evaluateWithField: anObject [
	<category: 'evaluation'>
	self isEnabled ifFalse: [^self].
	self evaluateWithArgument: (self valueForField: anObject)
    ]

    isEnabled [
	<category: 'testing'>
	^true
    ]

    key [
	<category: 'accessing'>
	^self convertKey: key
    ]

    owner [
	<category: 'accessing'>
	^owner
    ]

    priority [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    session [
	<category: 'accessing'>
	^context session
    ]

    setContext: aRenderingContext owner: anObject key: aString [
	<category: 'initialization'>
	context := aRenderingContext.
	owner := anObject.
	key := aString
    ]

    valueForField: anObject [
	<category: 'converting'>
	^anObject ifNil: ['']
	    ifNotNil: 
		[:foo | 
		(anObject isCollection and: [anObject isString not]) 
		    ifTrue: [anObject isEmpty ifTrue: [''] ifFalse: [anObject first]]
		    ifFalse: [anObject]]
    ]
]



WACallback subclass: WAActionCallback [
    | block |
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    block: aZeroArgBlock [
	<category: 'accessing'>
	block := aZeroArgBlock fixCallbackTemps
    ]

    evaluateWithArgument: anObject [
	<category: 'evaluation'>
	block value.
	self signalRenderNotification
    ]

    isEnabled [
	<category: 'testing'>
	^self session currentRequest isXmlHttpRequest not
    ]

    priority [
	<category: 'accessing'>
	^8
    ]

    signalRenderNotification [
	<category: 'evaluation'>
	WARenderNotification signal
    ]
]



WAActionCallback subclass: WACancelActionCallback [
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    priority [
	<category: 'accessing'>
	^3
    ]
]



WAActionCallback subclass: WADefaultActionCallback [
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    priority [
	<category: 'accessing'>
	^10
    ]
]



WAActionCallback subclass: WAImageCallback [
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    convertKey: aString [
	<category: 'converting'>
	^aString , '.x'
    ]
]



WACallback subclass: WADispatchCallback [
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    evaluateWithArgument: anObject [
	<category: 'evaluation'>
	| callback |
	callback := context callbackAt: anObject.
	callback isNil ifFalse: [callback evaluateWithArgument: nil]
    ]

    priority [
	<category: 'accessing'>
	^5
    ]
]



WADispatchCallback subclass: WAMultiDispatchCallback [
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    evaluateWithField: anObject [
	<category: 'evaluation'>
	(anObject isCollection and: [anObject isString not]) 
	    ifFalse: [^super evaluateWithField: anObject].
	anObject 
	    do: [:each | self evaluateWithArgument: (self valueForField: each)]
    ]
]



WACallback subclass: WAValueCallback [
    | block |
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    block: aOneArgBlock [
	<category: 'accessing'>
	block := aOneArgBlock fixCallbackTemps
    ]

    evaluateWithArgument: anObject [
	<category: 'evaluation'>
	block valueWithPossibleArgument: anObject
    ]

    priority [
	<category: 'accessing'>
	^5
    ]
]



Object subclass: WACallbackRegistry [
    | context owner |
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    WACallbackRegistry class >> context: aContext [
	<category: 'instance-creation'>
	^self context: aContext owner: nil
    ]

    WACallbackRegistry class >> context: aContext owner: anObject [
	<category: 'instance-creation'>
	^self basicNew initializeWithContext: aContext owner: anObject
    ]

    initializeWithContext: aContext owner: anObject [
	<category: 'initialization'>
	context := aContext.
	owner := anObject
    ]

    owner [
	<category: 'accessing'>
	^owner
    ]

    registerActionCallback: aBlock [
	<category: 'registration'>
	^self storeCallback: (WAActionCallback new block: aBlock)
    ]

    registerCallback: aBlock [
	<category: 'registration'>
	^self storeCallback: (WAValueCallback new block: aBlock)
    ]

    registerCancelActionCallback: aBlock [
	<category: 'registration'>
	^self storeCallback: (WACancelActionCallback new block: aBlock)
    ]

    registerDefaultActionCallback: aBlock [
	<category: 'registration'>
	^self storeCallback: (WADefaultActionCallback new block: aBlock)
    ]

    registerDispatchCallback [
	<category: 'registration'>
	^self storeCallback: WADispatchCallback new
    ]

    registerImageCallback: aBlock [
	<category: 'registration'>
	^self storeCallback: (WAImageCallback new block: aBlock)
    ]

    registerMultiDispatchCallback [
	<category: 'registration'>
	^self storeCallback: WAMultiDispatchCallback new
    ]

    storeCallback: aCallback [
	<category: 'callbacks'>
	| key |
	key := context storeCallback: aCallback.
	aCallback 
	    setContext: context
	    owner: owner
	    key: key.
	^key
    ]
]



Object subclass: WACallbackStream [
    | callbacks request |
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    WACallbackStream class >> callbacks: aDictionary request: aRequest [
	<category: 'instance-creation'>
	^self basicNew initializeWithCallbacks: aDictionary request: aRequest
    ]

    atEnd [
	<category: 'testing'>
	^callbacks atEnd
    ]

    hasCallbacksForOwner: anObject [
	"Answer true if the receiving stream has more callbacks for the owner anObject. This method considers callbacks without owner to be valid as well."

	<category: 'testing'>
	| owner |
	callbacks atEnd ifTrue: [^false].
	owner := callbacks peek owner.
	^owner == anObject or: [owner isNil]
    ]

    initializeWithCallbacks: aDictionary request: aRequest [
	<category: 'initialization'>
	| collection |
	collection := SortedCollection new.
	aRequest fields keys 
	    do: [:each | aDictionary at: each ifPresent: [:callback | collection add: callback]].
	callbacks := ReadStream on: collection asArray.
	request := aRequest
    ]

    position [
	<category: 'accessing'>
	^callbacks position
    ]

    processCallbacksWithOwner: anObject [
	<category: 'processing'>
	| callback |
	[self hasCallbacksForOwner: anObject] whileTrue: 
		[callback := callbacks next.
		callback evaluateWithField: (request fields at: callback key)]
    ]

    upToEnd [
	<category: 'accessing'>
	^callbacks upToEnd
    ]
]



Object subclass: WACanvas [
    | currentBrush parentBrush |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: 'This is the superclass of all canvas. It''s a rendering interfact that generates brushes (see WABrush).

Subclass this class, if you want to generate an XML dialect.'>

    WACanvas class >> builder [
	<category: 'instance creation'>
	^WAHtmlBuilder on: self
    ]

    brush: aBrush [
	<category: 'public'>
	self flush.
	currentBrush := aBrush.
	aBrush setParent: parentBrush canvas: self.
	^aBrush
    ]

    flush [
	<category: 'private'>
	currentBrush ifNotNil: 
		[:foo | 
		currentBrush close.
		currentBrush := nil]
    ]

    insert: aBlock [
	<category: 'private'>
	| oldBrush |
	oldBrush := currentBrush.
	currentBrush := nil.
	aBlock value.
	self flush.
	currentBrush := oldBrush
    ]

    nest: aBlock [
	<category: 'private'>
	parentBrush := currentBrush.
	currentBrush := nil.
	aBlock renderOn: self.
	self flush.
	parentBrush := parentBrush parent
    ]

    render: anObject [
	<category: 'public'>
	self flush.
	anObject renderOn: self
    ]
]



WACanvas subclass: WAHtmlCanvas [
    
    <category: 'Seaside-Core-Canvas'>
    <comment: 'This canvas knows about HTML but nothing about callbacks.'>

    abbreviated [
	"Defines an abbreviation, such as 'M.', 'Inc.', 'et al.', 'etc.'"

	<category: 'tags-block'>
	^self tag: 'abbr'
    ]

    abbreviated: aBlock [
	<category: 'tags-block'>
	self abbreviated with: aBlock
    ]

    acronym [
	"Defines an acronym, such as 'GmbH', 'NATO', and 'F.B.I.'"

	<category: 'tags-block'>
	^self tag: 'acronym'
    ]

    acronym: aBlock [
	<category: 'tags-block'>
	self acronym with: aBlock
    ]

    address [
	"Defines an address element."

	<category: 'tags-block'>
	^self tag: 'address'
    ]

    address: aBlock [
	<category: 'tags-block'>
	self address with: aBlock
    ]

    anchor [
	"Defines an anchor."

	<category: 'tags-input'>
	^self brush: WAAnchorTag new
    ]

    anchor: aBlock [
	<category: 'tags-input'>
	self anchor with: aBlock
    ]

    big [
	"Defines big text."

	<category: 'tags-format'>
	^self tag: 'big'
    ]

    big: aBlock [
	<category: 'tags-format'>
	self big with: aBlock
    ]

    blockquote [
	"Defines a long quotation."

	<category: 'tags-block'>
	^self tag: 'blockquote'
    ]

    blockquote: aBlock [
	<category: 'tags-block'>
	self blockquote with: aBlock
    ]

    break [
	"Inserts a single line break."

	<category: 'tags'>
	^self brush: WABreakTag new
    ]

    citation [
	"Defines a citation."

	<category: 'tags-block'>
	^self tag: 'cite'
    ]

    citation: aBlock [
	<category: 'tags-block'>
	self citation with: aBlock
    ]

    code [
	"Defines computer code text."

	<category: 'tags-output'>
	^self tag: 'code'
    ]

    code: aBlock [
	<category: 'tags-output'>
	self code with: aBlock
    ]

    definition [
	"Defines a definition term."

	<category: 'tags-output'>
	^self tag: 'dfn'
    ]

    definition: aBlock [
	<category: 'tags-output'>
	self definition with: aBlock
    ]

    definitionData [
	"Defines a definition description."

	<category: 'tags-lists'>
	^self tag: 'dd'
    ]

    definitionData: aBlock [
	<category: 'tags-lists'>
	self definitionData with: aBlock
    ]

    definitionList [
	"Defines a definition list."

	<category: 'tags-lists'>
	^self tag: 'dl'
    ]

    definitionList: aBlock [
	<category: 'tags-lists'>
	self definitionList with: aBlock
    ]

    definitionTerm [
	"Defines a definition term."

	<category: 'tags-lists'>
	^self tag: 'dt'
    ]

    definitionTerm: aBlock [
	<category: 'tags-lists'>
	self definitionTerm with: aBlock
    ]

    deleted [
	"Defines deleted text."

	<category: 'tags-block'>
	^self brush: (WAEditTag tag: 'del')
    ]

    deleted: aBlock [
	<category: 'tags-block'>
	self deleted with: aBlock
    ]

    div [
	"Defines a section in a document."

	<category: 'tags-styles'>
	^self brush: WADivTag new
    ]

    div: aBlock [
	<category: 'tags-styles'>
	self div with: aBlock
    ]

    document [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    emphasis [
	"Defines emphasized text."

	<category: 'tags-format'>
	^self tag: 'em'
    ]

    emphasis: aBlock [
	<category: 'tags-format'>
	self emphasis with: aBlock
    ]

    encodeCharacter: aCharacter [
	<category: 'convenience'>
	self html: '&#' , aCharacter asInteger seasideString , ';'
    ]

    fieldSet [
	"Defines a fieldset."

	<category: 'tags-input'>
	^self brush: WAFieldSetTag new
    ]

    fieldSet: aBlock [
	<category: 'tags-input'>
	self fieldSet with: aBlock
    ]

    form [
	"Defines a form."

	<category: 'tags-input'>
	^self tag: 'form'
    ]

    form: aBlock [
	<category: 'tags-input'>
	self form with: aBlock
    ]

    heading [
	"Defines header 1 to header 6."

	<category: 'tags'>
	^self brush: WAHeadingTag new
    ]

    heading: aBlock [
	<category: 'tags'>
	self heading with: aBlock
    ]

    heading: anObject level: anInteger [
	<category: 'deprecated'>
	self deprecatedApi.
	(self heading)
	    level: anInteger;
	    with: anObject
    ]

    horizontalRule [
	"Defines a horizontal rule."

	<category: 'tags'>
	^self brush: WAHorizontalRuleTag new
    ]

    html: aString [
	"Emit aString unescaped onto the target document."

	<category: 'public'>
	self flush.
	self document nextPutAll: aString seasideString
    ]

    iframe [
	<category: 'deprecated'>
	^self brush: WAIframeTag new
    ]

    image [
	"Defines an image."

	<category: 'tags-images'>
	^self brush: WAImageTag new
    ]

    image: aBlock [
	<category: 'tags-images'>
	self image with: aBlock
    ]

    imageForm: aForm [
	<category: 'deprecated'>
	self deprecatedApi.
	self image form: aForm
    ]

    inserted [
	"Defines inserted text."

	<category: 'tags-block'>
	^self brush: (WAEditTag tag: 'ins')
    ]

    inserted: aBlock [
	<category: 'tags-block'>
	self inserted with: aBlock
    ]

    keyboard [
	"Defines keyboard text."

	<category: 'tags-output'>
	^self tag: 'kbd'
    ]

    keyboard: aBlock [
	<category: 'tags-output'>
	self keyboard with: aBlock
    ]

    keyboardInput [
	"Keyboard, text to be entered by the user.
	 This selector has been renamed"

	<category: 'deprecated'>
	self deprecatedApi.
	^self keyboard
    ]

    keyboardInput: aBlock [
	<category: 'deprecated'>
	self deprecatedApi.
	self keyboard: aBlock
    ]

    label [
	"Defines a label for a form control."

	<category: 'tags-input'>
	^self brush: WALabelTag new
    ]

    label: aBlock [
	<category: 'tags-input'>
	self label with: aBlock
    ]

    legend [
	"Defines a title in a fieldset."

	<category: 'tags-input'>
	^self tag: 'legend'
    ]

    legend: aBlock [
	<category: 'tags-input'>
	self legend with: aBlock
    ]

    listItem [
	"Defines a list item."

	<category: 'tags-lists'>
	^self tag: 'li'
    ]

    listItem: aBlock [
	<category: 'tags-lists'>
	self listItem with: aBlock
    ]

    map [
	"Defines an anchor to be used around an image."

	<category: 'tags-images'>
	^self brush: WAImageMapTag new
    ]

    map: aBlock [
	<category: 'tags-images'>
	self map with: aBlock
    ]

    object [
	"Defines an embedded object."

	<category: 'tags-program'>
	^self brush: WAObjectTag new
    ]

    object: aBlock [
	<category: 'tags-program'>
	self object with: aBlock
    ]

    orderedList [
	"Defines an ordered list."

	<category: 'tags-lists'>
	^self brush: WAOrderedListTag new
    ]

    orderedList: aBlock [
	<category: 'tags-lists'>
	self orderedList with: aBlock
    ]

    paragraph [
	"Defines a paragraph."

	<category: 'tags'>
	^self tag: 'p'
    ]

    paragraph: aBlock [
	<category: 'tags'>
	self paragraph with: aBlock
    ]

    parameter [
	"Defines a parameter for an object."

	<category: 'tags-program'>
	^self brush: WAParameterTag new
    ]

    parameter: aBlock [
	<category: 'tags-program'>
	self parameter
    ]

    popupAnchor [
	<category: 'tags-input'>
	^self brush: WAPopupAnchorTag new
    ]

    popupAnchor: aBlock [
	<category: 'tags-input'>
	self popupAnchor with: aBlock
    ]

    preformatted [
	"Defines preformatted text."

	<category: 'tags-output'>
	^self tag: 'pre'
    ]

    preformatted: aBlock [
	<category: 'tags-output'>
	self preformatted with: aBlock
    ]

    quote [
	"Defines a short quotation."

	<category: 'tags-block'>
	^self tag: 'q'
    ]

    quote: aBlock [
	<category: 'tags-block'>
	self quote with: aBlock
    ]

    ruby [
	<category: 'tags-ruby'>
	^self tag: 'ruby'
    ]

    ruby: aBlock [
	<category: 'tags-ruby'>
	self ruby with: aBlock
    ]

    rubyBase [
	<category: 'tags-ruby'>
	^self tag: 'rb'
    ]

    rubyBase: aBlock [
	<category: 'tags-ruby'>
	self rubyBase with: aBlock
    ]

    rubyBaseContainer [
	<category: 'tags-ruby'>
	^self tag: 'rbc'
    ]

    rubyBaseContainer: aBlock [
	<category: 'tags-ruby'>
	self rubyBaseContainer with: aBlock
    ]

    rubyParentheses [
	<category: 'tags-ruby'>
	^self tag: 'rp'
    ]

    rubyParentheses: aBlock [
	<category: 'tags-ruby'>
	self rubyParentheses with: aBlock
    ]

    rubyText [
	<category: 'tags-ruby'>
	^self brush: WARubyTextTag new
    ]

    rubyText: aBlock [
	<category: 'tags-ruby'>
	self rubyText with: aBlock
    ]

    rubyTextContainer [
	<category: 'tags-ruby'>
	^self tag: 'rtc'
    ]

    rubyTextContainer: aBlock [
	<category: 'tags-ruby'>
	self rubyTextContainer with: aBlock
    ]

    sample [
	"Defines sample computer code."

	<category: 'tags-output'>
	^self tag: 'samp'
    ]

    sample: aBlock [
	<category: 'tags-output'>
	self sample with: aBlock
    ]

    sampleOutput [
	"Sample output, from a program or script.
	 This selector has been renamed."

	<category: 'deprecated'>
	self deprecatedApi.
	^self sample
    ]

    sampleOutput: aBlock [
	<category: 'deprecated'>
	self deprecatedApi.
	self sampleOutput with: aBlock
    ]

    script [
	"Defines a script."

	<category: 'tags-program'>
	^self brush: WAScriptTag new
    ]

    script: aBlock [
	<category: 'tags-program'>
	self script with: aBlock
    ]

    small [
	"Defines small text."

	<category: 'tags-format'>
	^self tag: 'small'
    ]

    small: aBlock [
	<category: 'tags-format'>
	self small with: aBlock
    ]

    space [
	<category: 'convenience'>
	self html: self spaceEntity
    ]

    space: anInteger [
	<category: 'convenience'>
	anInteger timesRepeat: [self space]
    ]

    spaceEntity [
	"The HTML entity representing a space. To be subclassed as needed."

	<category: 'private'>
	^'&nbsp;'
    ]

    span [
	"Defines a section in a document."

	<category: 'tags-styles'>
	^self tag: 'span'
    ]

    span: aBlock [
	<category: 'tags-styles'>
	self span with: aBlock
    ]

    strong [
	"Defines strong text."

	<category: 'tags-format'>
	^self tag: 'strong'
    ]

    strong: aBlock [
	<category: 'tags-format'>
	self strong with: aBlock
    ]

    subscript [
	"Defines subscripted text."

	<category: 'tags-format'>
	^self tag: 'sub'
    ]

    subscript: aBlock [
	<category: 'tags-format'>
	self subscript with: aBlock
    ]

    superscript [
	"Defines superscripted text."

	<category: 'tags-format'>
	^self tag: 'sup'
    ]

    superscript: aBlock [
	<category: 'tags-format'>
	self superscript with: aBlock
    ]

    table [
	"Defines a table."

	<category: 'tags-tables'>
	^self brush: WATableTag new
    ]

    table: aBlock [
	<category: 'tags-tables'>
	self table with: aBlock
    ]

    tableBody [
	"Defines a table body."

	<category: 'tags-tables'>
	^self tag: 'tbody'
    ]

    tableBody: aBlock [
	<category: 'tags-tables'>
	self tableBody with: aBlock
    ]

    tableCaption [
	"Defines a table caption."

	<category: 'tags-tables'>
	^self tag: 'caption'
    ]

    tableCaption: aBlock [
	<category: 'tags-tables'>
	self tableCaption with: aBlock
    ]

    tableColumn [
	"Defines attributes for table columns."

	<category: 'tags-tables'>
	^self brush: WATableColumnTag new
    ]

    tableColumn: aBlock [
	<category: 'tags-tables'>
	self tableColumn with: aBlock
    ]

    tableColumnGroup [
	"Defines groups of table columns."

	<category: 'tags-tables'>
	^self brush: WATableColumnGroupTag new
    ]

    tableColumnGroup: aBlock [
	<category: 'tags-tables'>
	self tableColumnGroup with: aBlock
    ]

    tableData [
	"Defines a table cell."

	<category: 'tags-tables'>
	^self brush: WATableDataTag new
    ]

    tableData: aBlock [
	<category: 'tags-tables'>
	self tableData with: aBlock
    ]

    tableFoot [
	"Defines a table footer."

	<category: 'tags-tables'>
	^self tag: 'tfoot'
    ]

    tableFoot: aBlock [
	<category: 'tags-tables'>
	^self tableFoot with: aBlock
    ]

    tableHead [
	"Defines a table header."

	<category: 'tags-tables'>
	^self tag: 'thead'
    ]

    tableHead: aBlock [
	<category: 'tags-tables'>
	self tableHead with: aBlock
    ]

    tableHeading [
	"Defines a table header."

	<category: 'tags-tables'>
	^self brush: WATableHeadingTag new
    ]

    tableHeading: aBlock [
	<category: 'tags-tables'>
	self tableHeading with: aBlock
    ]

    tableRow [
	"Defines a table row."

	<category: 'tags-tables'>
	^self tag: 'tr'
    ]

    tableRow: aBlock [
	<category: 'tags-tables'>
	self tableRow with: aBlock
    ]

    tag: aString [
	"Defines a generic tag with the name aString."

	<category: 'public'>
	^self brush: (WAGenericTag tag: aString)
    ]

    teletype [
	"Defines teletype text."

	<category: 'tags-output'>
	^self tag: 'tt'
    ]

    teletype: aBlock [
	<category: 'tags-output'>
	self teletype with: aBlock
    ]

    text: anObject [
	"Emit anObject onto the target document."

	<category: 'public'>
	self flush.
	self document print: anObject
    ]

    unorderedList [
	"Defines an unordered list."

	<category: 'tags-lists'>
	^self brush: WAUnorderedListTag new
    ]

    unorderedList: aBlock [
	<category: 'tags-lists'>
	self unorderedList with: aBlock
    ]

    variable [
	"Defines a variable."

	<category: 'tags-output'>
	^self tag: 'var'
    ]

    variable: aBlock [
	<category: 'tags-output'>
	self variable with: aBlock
    ]

    withLineBreaks: aString [
	"Renders text preserving line breaks."

	<category: 'convenience'>
	| stream |
	stream := aString readStream.
	[stream atEnd] whileFalse: 
		[self text: stream nextLine.
		stream atEnd ifFalse: [self break]]
    ]

    withLineBreaksAndUrls: aString [
	<category: 'convenience'>
	| stream |
	aString ifNil: [^self].
	stream := aString readStream.
	[stream atEnd] whileFalse: 
		[self withUrls: stream nextLine.
		stream atEnd ifFalse: [self break]]
    ]

    withUrls: aString [
	<category: 'convenience'>
	| stream url |
	stream := aString readStream.
	[stream atEnd] whileFalse: 
		[self text: (stream upToAndSkipThroughAll: 'http://').
		stream atEnd 
		    ifFalse: 
			[url := 'http://' , (stream upTo: Character space).
			(self anchor)
			    url: url;
			    with: url.
			self text: ' ']]
    ]
]



WAHtmlCanvas subclass: WARenderCanvas [
    | context callbacks |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: 'This canvas knows about callbacks and is intertwined with the rest of the framework.'>

    WARenderCanvas class >> context: aRenderingContext callbacks: aCallbackStore [
	<category: 'instance creation'>
	^self basicNew initializeWithContext: aRenderingContext
	    callbacks: aCallbackStore
    ]

    button [
	<category: 'form-buttons'>
	^self brush: WAButtonTag new
    ]

    callbacks [
	"Answer the callback registry."

	<category: 'accessing'>
	^callbacks
    ]

    cancelButton [
	<category: 'form-buttons'>
	^self brush: WACancelButtonTag new
    ]

    checkbox [
	<category: 'form-elements'>
	^self brush: WACheckboxTag new
    ]

    context [
	"Answer the rendering context."

	<category: 'accessing'>
	^context
    ]

    dateInput [
	<category: 'form-elements'>
	^self brush: WADateInput new
    ]

    document [
	"Answer the XHTML document."

	<category: 'accessing'>
	^self context document
    ]

    fileUpload [
	<category: 'form-elements'>
	^self brush: WAFileUploadTag new
    ]

    form [
	<category: 'form-buttons'>
	^self brush: WAFormTag new
    ]

    hiddenInput [
	<category: 'form-elements'>
	^self brush: WAHiddenInputTag new
    ]

    imageButton [
	<category: 'form-buttons'>
	^self brush: WAImageButtonTag new
    ]

    initializeWithContext: aRenderingContext callbacks: aCallbackStore [
	<category: 'initialize-release'>
	context := aRenderingContext.
	callbacks := aCallbackStore
    ]

    multiSelect [
	<category: 'form-elements'>
	^self brush: WAMultiSelectTag new
    ]

    multiSelect: aBlock [
	<category: 'form-elements'>
	^self multiSelect with: aBlock
    ]

    nextId [
	<category: 'public'>
	^'id' , context advanceKey
    ]

    option [
	<category: 'form-elements'>
	^self brush: WAOptionTag new
    ]

    option: aBlock [
	<category: 'form-elements'>
	^self option with: aBlock
    ]

    optionGroup [
	<category: 'form-elements'>
	^self brush: WAOptionGroupTag new
    ]

    optionGroup: aBlock [
	<category: 'form-elements'>
	^self optionGroup with: aBlock
    ]

    painter [
	"Answer the component that is supposed to paint this canvas."

	<category: 'accessing'>
	^callbacks owner
    ]

    passwordInput [
	<category: 'form-elements'>
	^self brush: WAPasswordInputTag new
    ]

    peekNextId [
	<category: 'public'>
	^'id' , context nextKey
    ]

    radioButton [
	<category: 'form-elements'>
	^self brush: WARadioButtonTag new
    ]

    radioButton: aBlock [
	<category: 'form-elements'>
	^self radioButton with: aBlock
    ]

    radioGroup [
	<category: 'form-elements'>
	^WARadioGroup canvas: self
    ]

    radioGroup: aBlock [
	<category: 'form-elements'>
	^aBlock value: self radioGroup
    ]

    select [
	<category: 'form-elements'>
	^self brush: WASelectTag new
    ]

    select: aBlock [
	<category: 'form-elements'>
	^self select with: aBlock
    ]

    submitButton [
	<category: 'tags-input'>
	^self brush: WASubmitButtonTag new
    ]

    textArea [
	<category: 'form-elements'>
	^self brush: WATextAreaTag new
    ]

    textInput [
	<category: 'tags-input'>
	^self brush: WATextInputTag new
    ]

    timeInput [
	<category: 'form-elements'>
	^self brush: WATimeInput new
    ]

    urlForAction: aBlock [
	"Answer an action URL that will evaluate aBlock when beeing requested."

	<category: 'public'>
	^self context actionUrl 
	    withParameter: (self callbacks registerActionCallback: aBlock)
    ]
]



WAHtmlCanvas subclass: WAStaticHtmlCanvas [
    | document |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: 'This canvas can be used to generate static/RESTful HTML pages.'>

    document [
	<category: 'accessing'>
	^document
    ]

    document: aDocument [
	<category: 'accessing'>
	document := aDocument
    ]

    initializeWithDocument: aDocument [
	<category: 'initialize-release'>
	document := aDocument
    ]

    textArea [
	<category: 'form-elements'>
	^self brush: WATextAreaTag new
    ]
]



Object subclass: WAClosingConditionalComment [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'Closes a WAConditionalComment.'>

    encodeOn: aDocument [
	<category: 'printing'>
	aDocument nextPutAll: '<![endif]-->'
    ]
]



Object subclass: WAClosingRevealedConditionalComment [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'Closes a WARevealedConditionalComment.'>

    encodeOn: aDocument [
	<category: 'printing'>
	aDocument nextPutAll: '<!--<![endif]-->'
    ]
]



Object subclass: WAConditionalComment [
    | condition root |
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'A WAConditionalComment is an implementation of Downlevel-hidden Conditional Comments:
http://msdn2.microsoft.com/en-us/library/ms537512.aspx
These are only visible for the IE family of browsers.

See also WAOpeningConditionalComment and WAClosingConditionalComment.'>

    WAConditionalComment class >> root: anHtmlRoot [
	<category: 'instance creation'>
	^self new initializeWithRoot: anHtmlRoot
    ]

    addToCondition: aString [
	<category: 'private'>
	condition := condition , aString
    ]

    closingConditionClass [
	<category: 'private'>
	^WAClosingConditionalComment
    ]

    do: aBlock [
	<category: 'public'>
	root add: (self openingConditionClass condition: condition).
	aBlock value.
	root add: self closingConditionClass new
    ]

    equal [
	"implicit of nothing else"

	<category: 'operators'>
	
    ]

    greaterThan [
	<category: 'operators'>
	self addToCondition: ' gt'
    ]

    ie [
	<category: 'features'>
	self addToCondition: ' IE'
    ]

    ie5 [
	<category: 'features'>
	self addToCondition: ' IE 5'
    ]

    ie50 [
	<category: 'features'>
	self addToCondition: ' IE 5.0'
    ]

    ie55 [
	<category: 'features'>
	self addToCondition: ' IE 5.5'
    ]

    ie6 [
	<category: 'features'>
	self addToCondition: ' IE 6'
    ]

    ie7 [
	<category: 'features'>
	self addToCondition: ' IE 7'
    ]

    initializeWithRoot: anHtmlRoot [
	<category: 'initialization'>
	root := anHtmlRoot.
	condition := 'if'
    ]

    lessThan [
	<category: 'operators'>
	self addToCondition: ' lt'
    ]

    not [
	<category: 'operators'>
	self addToCondition: ' !'
    ]

    openingConditionClass [
	<category: 'private'>
	^WAOpeningConditionalComment
    ]

    orEqual [
	<category: 'operators'>
	self addToCondition: 'e'
    ]
]



WAConditionalComment subclass: WARevealedConditionalComment [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'A WAConditionalComment is an implementation of Downlevel-revealed Conditional Comments:
http://msdn2.microsoft.com/en-us/library/ms537512.aspx
Non-IE family browsers see them always.

See also WAOpeningRevealedConditionalComment and WARevealedConditionalComment.'>

    closingConditionClass [
	<category: 'private'>
	^WAClosingRevealedConditionalComment
    ]

    openingConditionClass [
	<category: 'private'>
	^WAOpeningRevealedConditionalComment
    ]
]



Object subclass: WAConfiguration [
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'A configuration for a Seaside application contains attributes which can be used by Seaside and the application. WAConfiguration hierarchy uses the composite pattern. Subclasses of WASystemConfiguration define related groups of attributes. A WASystemConfiguration subclass defines the name and optionally default values for attributes. See WASystemConfiguration class comment for information on defining your own group of attributes. WAUserConfiguration is a composite of configurations. The set of configurations contained in WAUserConfiguration is called the ancestors. Attribute values in a configuration override the attribute values in the ancestors. WAUserConfiguration also holds the non-default values of attributes.

Seaside applications start with a WAUserConfiguration (see WAApplication>>configuration) that start with three configurations (WARenderLoopConfiguration, WAGlobalConfiguration and WASessionConfiguration). Other configurations can be added to an application on the Seaside configuration page for the application or in your application. Values for the attributes can be given in either location. 

See Seaside documentation (http://www.seaside.st/documentation) on configuration and preferences (http://www.seaside.st/documentation/Configuration%20and%20Preferences) for more information.

Example of setting attributes and adding configurations in code
ASubclassOfWAComponent class>>initialize
	"self initialize"
	| application |
	application := self registerAsApplication: ''GlorpExample''.
	"set a standard attribute"
	application preferenceAt: #sessionClass put: Glorp.WAGlorpSession. 

	"add a configuration"
	application configuration addAncestor: GlorpConfiguration new.
	application preferenceAt: #databaseLogin put: ''foo''. "set attribute defined in GlorpConfiguration"

Subclasses must implement the following messages:
	name
		return the name of the configuration

	localValueAt:ifAbsent:
		return the value of the attribute given as first argument'>

    WAConfiguration class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    addAncestorsTo: tempCollection linearization: linearCollection [
	<category: 'ancestry'>
	(linearCollection includes: self) 
	    ifTrue: 
		[tempCollection do: [:ea | linearCollection add: ea before: self].
		tempCollection removeAllSuchThat: [:ea | true]]
	    ifFalse: 
		[tempCollection add: self.
		self ancestors isEmpty 
		    ifTrue: 
			[linearCollection addAll: tempCollection.
			tempCollection removeAllSuchThat: [:ea | true]]
		    ifFalse: 
			[self ancestors 
			    do: [:ea | ea addAncestorsTo: tempCollection linearization: linearCollection]]]
    ]

    allAncestors [
	<category: 'ancestry'>
	| temp linear |
	temp := OrderedCollection new.
	linear := OrderedCollection new.
	self addAncestorsTo: temp linearization: linear.
	^linear
	    removeFirst;
	    asArray
    ]

    allAncestorsDo: aBlock [
	<category: 'ancestry'>
	self allAncestors do: aBlock
    ]

    allAttributes [
	<category: 'attributes'>
	^Array 
	    streamContents: [:s | self withAllAncestorsDo: [:ea | s nextPutAll: ea attributes]]
    ]

    allPotentialAncestors [
	<category: 'ancestry'>
	^#()
    ]

    ancestors [
	<category: 'ancestry'>
	^#()
    ]

    attributeNamed: aSymbol [
	<category: 'attributes'>
	^self allAttributes detect: [:each | each key = aSymbol]
	    ifNone: [self error: 'No attribute named ' , aSymbol printString]
    ]

    attributes [
	<category: 'attributes'>
	^#()
    ]

    attributesAndValuesDo: keyValueBlock [
	<category: 'values'>
	^self allAttributes 
	    do: [:ea | keyValueBlock value: ea value: (self valueForAttribute: ea)]
    ]

    groupedAttributes [
	<category: 'attributes'>
	| grops attributes |
	grops := Dictionary new.
	attributes := SortedCollection sortBlock: [:a :b | a key <= b key].
	self allAttributes do: 
		[:each | 
		(grops at: each group
		    ifAbsentPut: [SortedCollection sortBlock: [:a :b | a key <= b key]]) 
			add: each].
	grops associationsDo: [:associaction | attributes add: associaction].
	^attributes
    ]

    hasAttributeNamed: aSymbol [
	<category: 'testing'>
	^self allAttributes anySatisfy: [:ea | ea key = aSymbol]
    ]

    hasLocalValueForAttribute: anAttribute [
	<category: 'testing'>
	self localValueAt: anAttribute key ifAbsent: [^false].
	^true
    ]

    hasMutableAncestry [
	<category: 'testing'>
	^false
    ]

    inheritedValueAndSourceAt: aSymbol do: aBlock [
	<category: 'values'>
	| value |
	self allAncestorsDo: 
		[:each | 
		value := each localValueAt: aSymbol ifAbsent: [nil].
		value isNil ifFalse: [^aBlock value: value value: each]].
	^nil
    ]

    inheritsFrom: aConfiguration [
	<category: 'testing'>
	^self allAncestors anySatisfy: [:ea | ea = aConfiguration]
    ]

    initialize [
	<category: 'initializing'>
	
    ]

    localValueAt: aSymbol ifAbsent: absentBlock [
	<category: 'values'>
	self subclassResponsibility
    ]

    lookupValueAt: aSymbol [
	<category: 'values'>
	^self inheritedValueAndSourceAt: aSymbol do: [:value :source | value]
    ]

    name [
	<category: 'accessing'>
	^self class name
    ]

    potentialAncestors [
	<category: 'ancestry'>
	^self allPotentialAncestors 
	    reject: [:ea | ea = self or: [(self inheritsFrom: ea) or: [ea inheritsFrom: self]]]
    ]

    valueAt: aSymbol [
	<category: 'values'>
	^self localValueAt: aSymbol ifAbsent: [self lookupValueAt: aSymbol]
    ]

    valueForAttribute: anAttribute [
	<category: 'values'>
	^self valueAt: anAttribute key
    ]

    withAllAncestorsDo: aBlock [
	<category: 'ancestry'>
	aBlock value: self.
	^self allAncestorsDo: aBlock
    ]
]



WAConfiguration subclass: WASystemConfiguration [
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'Subclass WASystemConfiguration to define a group of attributes for a Seaside application. The method "attributes" returns a collection of attributes in this configuration. If a configuration requires other configurations then implement the method "ancestors", which returns a collection of configuration classes. Subclasses can define default values for attributes. If you define an attribute named "useSessionCookie" you can provide a default value by implementing a method "useSessionCookie" that returns the default value. See existing subclasses for examples. Non-default values for attributes are not stored in WASystemConfiguration subclasses, but are stored in WAUserConfiguration.

WAUserConfiguration is a singleton class to avoid implementing = and hash. Only need one instance of WAUserConfiguration and its subclasses.

Subclasses must implement the following messages:
	attributes
		return a collection of attribute objects'>

    WASystemConfiguration class [
	| instance |
	
    ]

    WASystemConfiguration class >> instance [
	<category: 'accessing'>
	^instance ifNil: [instance := self basicNew initialize]
    ]

    WASystemConfiguration class >> new [
	<category: 'instance creation'>
	^self instance
    ]

    attributes [
	<category: 'attributes'>
	self subclassResponsibility
    ]

    localValueAt: aSymbol ifAbsent: absentBlock [
	<category: 'values'>
	^(self respondsTo: aSymbol) 
	    ifTrue: [self perform: aSymbol]
	    ifFalse: [absentBlock value]
    ]
]



WASystemConfiguration subclass: WAAuthConfiguration [
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    ancestors [
	<category: 'ancestry'>
	^Array with: WARenderLoopConfiguration new
    ]

    attributes [
	<category: 'attributes'>
	^Array with: (WAStringAttribute 
		    key: #login
		    group: #authentication
		    comment: 'The username for this application.')
	    with: (WAStringAttribute 
		    key: #password
		    group: #authentication
		    comment: 'The password for this application.')
    ]

    mainClass [
	<category: 'accessing'>
	^WAAuthMain
    ]
]



WASystemConfiguration subclass: WAFileSystemConfiguration [
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: nil>

    attributes [
	<category: 'attributes'>
	^Array with: (WAStringAttribute key: #directory
		    comment: 'The base directory to serve files from.')
	    with: (WABooleanAttribute key: #listing
		    comment: 'Enable listing of directory entries.')
    ]

    directory [
	<category: 'defaults'>
	^SeasidePlatformSupport defaultDirectoryName
    ]

    listing [
	<category: 'defaults'>
	^true
    ]
]



WASystemConfiguration subclass: WAGlobalConfiguration [
    
    <category: 'Seaside-Core-Session'>
    <comment: 'WAGlobalConfiguration defines attributes (properties) about the Seaside server. It defines
 	server protocol (http, https) 
	host name
	port number 
	server path (first part of URL path, default "seaside" in Squeak "seaside/go" in WV, maps to 
		top level WADispatcher, if you change value make sure WADispatcher is configured correctly)
	deployment mode (false = development mode)

Note setting these attributes does not change the values the server using. Changing the first four changes how Seaside generates the URLs in pages returned to the client. 

By default all applications contain this configuration.'>

    DeploymentMode := nil.

    WAGlobalConfiguration class >> initialize [
	<category: 'initialization'>
	DeploymentMode ifNil: [self setDevelopmentMode]
    ]

    WAGlobalConfiguration class >> setDeploymentMode [
	<category: 'configuration'>
	DeploymentMode := true
    ]

    WAGlobalConfiguration class >> setDevelopmentMode [
	<category: 'configuration'>
	DeploymentMode := false
    ]

    attributes [
	<category: 'attributes'>
	^Array 
	    with: ((WAListAttribute 
		    key: #serverProtocol
		    group: #server
		    comment: 'The protocol in URLs generated by Seaside.') 
			options: #(#http #https))
	    with: (WAStringAttribute 
		    key: #serverHostname
		    group: #server
		    comment: 'The hostname in URLs generated by Seaside.')
	    with: (WANumberAttribute 
		    key: #serverPort
		    group: #server
		    comment: 'The port in URLs generated by Seaside. The default of HTTP is 80, the default of HTTPS is 443.')
	    with: (WAStringAttribute 
		    key: #serverPath
		    group: #server
		    comment: 'The path in URLs generated by Seaside.')
    ]

    deploymentMode [
	<category: 'defaults'>
	^DeploymentMode
    ]

    serverPort [
	<category: 'defaults'>
	^80
    ]

    serverProtocol [
	<category: 'defaults'>
	^#http
    ]
]



WASystemConfiguration subclass: WARenderLoopConfiguration [
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    ancestors [
	<category: 'accessing'>
	^Array with: WASessionConfiguration new
    ]

    attributes [
	<category: 'accessing'>
	^Array 
	    with: ((WAListAttribute key: #rootComponent
		    comment: 'The root component of this seaside application.') 
			options: self rootComponents)
	    with: (WAStringAttribute 
		    key: #resourceBaseUrl
		    group: #server
		    comment: 'Sets the base URL for URLS generated with #resourceUrl:')
    ]

    errorHandler [
	<category: 'defaults'>
	^WASimpleErrorHandler
    ]

    mainClass [
	<category: 'defaults'>
	^WARenderLoopMain
    ]

    rootComponents [
	<category: 'defaults'>
	^(WAComponent allSubclasses select: [:each | each canBeRoot]) 
	    asSortedCollection: [:a :b | a name <= b name]
    ]
]



WASystemConfiguration subclass: WASessionConfiguration [
    
    <category: 'Seaside-Core-Session'>
    <comment: 'WASessionConfiguration defines attributes with default values about the Seaside session used by an application. 
It defines 
	sessionClass (WASession or subclass)	
	mainClass   (a subclass of WAMain)
	errorHandler	(a subclass of WAErrorHander)	
	renderContinuationClass (WARenderContinuation or subclass)
	redirectContinuationClass (WARedirectContinuation or subclass)
	useSessionCookie (
		true:
			put session id in cookie if client supports cookies
		false:
			put session id in all urls returned in the _s parameter
		default:
			false)

This configuration is added to all applications by default.'>

    allDecorationClasses [
	<category: 'defaults'>
	^WADecoration allSubclasses asSortedCollection: [:a :b | a name < b name]
    ]

    ancestors [
	<category: 'ancestry'>
	^Array with: WAGlobalConfiguration new
    ]

    attributes [
	<category: 'attributes'>
	^(OrderedCollection new)
	    add: (WANumberAttribute key: #sessionExpirySeconds);
	    add: ((WAListAttribute key: #sessionClass) options: self sessionClasses);
	    add: ((WAListAttribute key: #mainClass) options: self mainClasses);
	    add: ((WAListAttribute key: #errorHandler) 
			options: self errorHandlerClasses);
	    add: ((WAListAttribute key: #redirectHandler) 
			options: self redirectHandlerClasses);
	    add: ((WAListAttribute key: #renderContinuationClass) 
			options: self renderContinuationClasses);
	    add: ((WAListAttribute key: #redirectContinuationClass) 
			options: self redirectContinuationClasses);
	    add: (WABooleanAttribute key: #useSessionCookie);
	    add: ((WACollectionAttribute key: #libraries) options: self libraryClasses);
	    add: ((WACollectionAttribute key: #decorationClasses) 
			options: self allDecorationClasses);
	    yourself
    ]

    decorationClasses [
	<category: 'defaults'>
	^#()
    ]

    errorHandler [
	<category: 'defaults'>
	^WASimpleErrorHandler
    ]

    errorHandlerClasses [
	<category: 'defaults'>
	^WAErrorHandler withAllSubclasses 
	    asSortedCollection: [:a :b | a name <= b name]
    ]

    libraries [
	<category: 'defaults'>
	^Array with: WAStandardFiles
    ]

    libraryClasses [
	<category: 'defaults'>
	^WALibrary allSubclasses asSortedCollection: [:a :b | a name <= b name]
    ]

    mainClasses [
	<category: 'defaults'>
	^WAMain allSubclasses asSortedCollection: [:a :b | a name <= b name]
    ]

    redirectContinuationClass [
	<category: 'defaults'>
	^WARedirectContinuation
    ]

    redirectContinuationClasses [
	<category: 'defaults'>
	^WARedirectContinuation withAllSubclasses
    ]

    redirectHandler [
	<category: 'defaults'>
	^WARedirectHandler
    ]

    redirectHandlerClasses [
	<category: 'defaults'>
	^WARedirectHandler withAllSubclasses
    ]

    renderContinuationClass [
	<category: 'defaults'>
	^WARenderContinuation
    ]

    renderContinuationClasses [
	<category: 'defaults'>
	^WARenderContinuation withAllSubclasses
    ]

    sessionClass [
	<category: 'defaults'>
	^WASession
    ]

    sessionClasses [
	<category: 'defaults'>
	^WASession withAllSubclasses 
	    asSortedCollection: [:a :b | a name <= b name]
    ]

    sessionExpirySeconds [
	<category: 'defaults'>
	^600
    ]

    useSessionCookie [
	<category: 'defaults'>
	^false
    ]
]



WAConfiguration subclass: WAUserConfiguration [
    | values ancestors |
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'WAUserConfiguration is a composite of configurations.  This composite of configurations is stored in the field "ancestors". WAUserConfiguration also contains all the non-default values of attributes for an application. WAUserConfiguration inherits attribute values defined in its ancestors. If WAUserConfiguration does not have a value for an attribute it will search its ancestors for a value, stopping when it finds a value.

WAUserConfiguration is the first configuration added to a Seaside application (WAApplication). All other configurations added to the application are added as ancestors to WAUserConfiguration. When a value for an attribute is set either by the standard Seaside component configuration page or in code the value is added to the "values" dictionary in WAUserConfiguration.

Instance Variables:
	ancestors	<Collection of: WAConfiguration>	 hierarchy of configurations defining all attributes for this instance of WAUserConfiguration
	values	<Dictionary>	the dictionary key is an attribute key, dictionary value is value of that attribute 
'>

    addAncestor: aConfiguration [
	<category: 'ancestry'>
	(self inheritsFrom: aConfiguration) 
	    ifFalse: [ancestors add: aConfiguration]
    ]

    allPotentialAncestors [
	<category: 'ancestry'>
	^WASystemConfiguration allSubclasses collect: [:ea | ea new]
    ]

    ancestors [
	<category: 'accessing'>
	^ancestors
    ]

    clear [
	<category: 'menu'>
	values := Dictionary new
    ]

    clearValueForAttribute: anAttribute [
	<category: 'accessing'>
	values removeKey: anAttribute key ifAbsent: []
    ]

    hasMutableAncestry [
	<category: 'testing'>
	^true
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	values := Dictionary new.
	ancestors := OrderedCollection new
    ]

    localValueAt: aSymbol ifAbsent: errorBlock [
	<category: 'values'>
	^values at: aSymbol ifAbsent: errorBlock
    ]

    localValues [
	<category: 'accessing'>
	| dictionary value |
	dictionary := Dictionary new.
	self allAttributes do: 
		[:each | 
		value := self localValueAt: each key ifAbsent: [nil].
		value isNil 
		    ifFalse: [dictionary at: each key put: (each stringForValue: value)]].
	^dictionary
    ]

    localValues: aDictionary [
	<category: 'accessing'>
	| value |
	self allAttributes do: 
		[:each | 
		value := aDictionary at: each key ifAbsent: [nil].
		value isNil 
		    ifFalse: [self valueAt: each key put: (each valueFromString: value)]]
    ]

    overrideAttribute: anAttribute [
	<category: 'accessing'>
	self takeValue: (self valueForAttribute: anAttribute)
	    forAttribute: anAttribute
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	values := values copy.
	ancestors := ancestors collect: [:each | each copy]
    ]

    removeAncestor: aConfiguration [
	<category: 'ancestry'>
	ancestors remove: aConfiguration ifAbsent: []
    ]

    takeValue: anObject forAttribute: anAttribute [
	<category: 'accessing'>
	^anObject ifNotNil: [:foo | values at: anAttribute key put: anObject]
    ]

    valueAt: aSymbol put: anObject [
	<category: 'accessing'>
	^self takeValue: anObject forAttribute: (self attributeNamed: aSymbol)
    ]
]



Object subclass: WAConfigurationAttribute [
    | key group comment |
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'WAConfigurationAttribute represents a value of a specified type in a Seaside application configuration. Some attributes are used are needed by Seaside for your application like deployment Mode and session timeout. Attributes like a database login may be used internally by the application.  

Each subclass of WAConfigurationAttribute handles one type (Number, Boolean, etc) of attribute. The "group" of the attribute is used to place all attributes in the same group together on the Seaside configuration page. The "key" of the attribute identifies the attribute. See WAConfiguration for example of accessing a configuration attribute. 

Subclasses must implement the following messages:
	valueFromString: aString
		convert "aString" into type represented by the class, return result of the conversion
	
	accept: aVisitor with: anObject
		Typical implementation is:
			aVisitor visitXXXAttribute: self with: anObject

		where XXX is the type of this attribute. The method visitXXXAttribute:with: must be implemented in all visitors, in particular WAConfigurationEditor which creates the configuration page for Seaside applications.

Instance Variables:
	group	<Symbol>	name of the group the attribute belongs to
	key	<Symbol>	key or name of the attribute, used to look up the attribute'>

    WAConfigurationAttribute class >> key: aSymbol [
	<category: 'instance-creation'>
	^self key: aSymbol group: nil
    ]

    WAConfigurationAttribute class >> key: keySymbol comment: commentString [
	<category: 'instance-creation'>
	^self basicNew 
	    initializeWithKey: keySymbol
	    group: nil
	    comment: commentString
    ]

    WAConfigurationAttribute class >> key: keySymbol group: groupSymbol [
	<category: 'instance-creation'>
	^self 
	    key: keySymbol
	    group: groupSymbol
	    comment: ''
    ]

    WAConfigurationAttribute class >> key: keySymbol group: groupSymbol comment: commentString [
	<category: 'instance-creation'>
	^self basicNew 
	    initializeWithKey: keySymbol
	    group: groupSymbol
	    comment: commentString
    ]

    accept: aVisitor with: anObject [
	<category: 'visiting'>
	self subclassResponsibility
    ]

    comment [
	<category: 'accessing'>
	^comment
    ]

    group [
	<category: 'accessing'>
	^group ifNil: [#general]
    ]

    initializeWithKey: keySymbol group: groupSymbol comment: commentString [
	<category: 'initialization'>
	key := keySymbol.
	group := groupSymbol.
	comment := commentString
    ]

    key [
	<category: 'accessing'>
	^key
    ]

    stringForValue: anObject [
	<category: 'converting'>
	^anObject seasideString
    ]

    valueFromString: aString [
	<category: 'converting'>
	self subclassResponsibility
    ]
]



WAConfigurationAttribute subclass: WABooleanAttribute [
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'WABooleanAttribute  represents a boolean attribute. It converts between text entered on the configuration page and boolean values.'>

    accept: aVisitor with: anObject [
	<category: 'visiting'>
	aVisitor visitBooleanAttribute: self with: anObject
    ]

    valueFromString: aString [
	<category: 'converting'>
	^aString = 'true' 
	    ifTrue: [true]
	    ifFalse: 
		[aString = 'false' 
		    ifTrue: [false]
		    ifFalse: [self error: 'Invalid value for boolean attribute']]
    ]
]



WAConfigurationAttribute subclass: WAListAttribute [
    | options |
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'WAListAttribute is an attribute that is restricted to a list of values. 

Instance Variables:
	options	<Collection of: (Object | String | Symbol)>	list of possible values for the attribute'>

    accept: aVisitor with: anObject [
	<category: 'visiting'>
	aVisitor visitListAttribute: self with: anObject
    ]

    options [
	<category: 'accessing'>
	^options
    ]

    options: aCollection [
	<category: 'accessing'>
	options := aCollection
    ]

    valueFromString: aString [
	<category: 'converting'>
	^self options detect: [:each | each seasideString = aString]
	    ifNone: [self error: 'No matching list option']
    ]
]



WAListAttribute subclass: WACollectionAttribute [
    
    <category: 'Seaside-Core-Configuration'>
    <comment: nil>

    accept: aVisitor with: anObject [
	<category: 'visiting'>
	aVisitor visitCollectionAttribute: self with: anObject
    ]
]



WAConfigurationAttribute subclass: WANumberAttribute [
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'WANumberAttribute represents a number attribute. It converts between text entered on the configuration page and numbers.
'>

    accept: aVisitor with: anObject [
	<category: 'visiting'>
	aVisitor visitNumberAttribute: self with: anObject
    ]

    valueFromString: aString [
	<category: 'converting'>
	^Number readFrom: aString
    ]
]



WAConfigurationAttribute subclass: WAStringAttribute [
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'WAStringAttribute represents a string attribute. It does the trivial conversion between text entered on the Seaside configuration page and a string.'>

    accept: aVisitor with: anObject [
	<category: 'visiting'>
	aVisitor visitStringAttribute: self with: anObject
    ]

    valueFromString: aString [
	<category: 'converting'>
	^aString isEmptyOrNil ifFalse: [aString]
    ]
]



WAStringAttribute subclass: WAPasswordAttribute [
    
    <category: 'Seaside-Core-Configuration'>
    <comment: 'WAPasswordAttribute represents a password attribute. On the Seaside configuration page it displays the attribute differently than WAStringAttribute.
'>

    accept: aVisitor with: anObject [
	<category: 'visiting'>
	aVisitor visitPasswordAttribute: self with: anObject
    ]
]



Object subclass: WACookie [
    | key value path expiry |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: 'I represent a cookie, a piece of information that is stored on the client and read and writable by the server. I am basically a key/value pair of strings.
You can never trust information in a cookie, the client is free to edit it.
I model only a part of the full cookie specification.

For more information see  RFC2965 (http://tools.ietf.org/html/rfc2965)'>

    WACookie class >> key: keyString value: valueString [
	<category: 'accessing'>
	^(self new)
	    key: keyString;
	    value: valueString;
	    yourself
    ]

    = other [
	<category: 'comparing'>
	^self species = other species 
	    and: [self key = other key and: [self path = other path]]
    ]

    expireIn: aDuration [
	<category: 'api'>
	self expiry: DateTime now + aDuration
    ]

    expiry [
	<category: 'accessing'>
	^expiry
    ]

    expiry: aDateTime [
	<category: 'accessing'>
	expiry := aDateTime asUTC
    ]

    expiryString [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: (expiry dayOfWeekName first: 3);
		    nextPutAll: ', ';
		    nextPutAll: expiry dayOfMonth seasideString;
		    nextPut: $-;
		    nextPutAll: expiry monthName;
		    nextPut: $-;
		    nextPutAll: expiry year seasideString;
		    space;
		    nextPutAll: expiry hour24 seasideString;
		    nextPut: $:;
		    nextPutAll: expiry minute seasideString;
		    nextPut: $:;
		    nextPutAll: expiry second seasideString;
		    nextPutAll: ' GMT']
    ]

    hash [
	<category: 'comparing'>
	^self key hash bitXor: self path hash
    ]

    key [
	<category: 'accessing'>
	^key
    ]

    key: aString [
	<category: 'accessing'>
	key := aString
    ]

    path [
	<category: 'accessing'>
	^path ifNil: ['/']
    ]

    path: aString [
	<category: 'accessing'>
	path := aString
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aString [
	<category: 'accessing'>
	value := aString
    ]

    valueWithExpiry [
	<category: 'api'>
	^expiry ifNil: [self value]
	    ifNotNil: [:foo | (self value ifNil: ['']) , '; expires=' , self expiryString]
    ]

    writeOn: aStream [
	<category: 'writing'>
	aStream
	    nextPutAll: self key;
	    nextPut: $=;
	    nextPutAll: (self value ifNil: ['']).
	expiry isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '; expires=';
		    nextPutAll: self expiryString].
	path isNil 
	    ifFalse: 
		[aStream
		    nextPutAll: '; path=';
		    nextPutAll: self path]
    ]
]



Object subclass: WAEncoder [
    | stream table |
    
    <category: 'Seaside-Core-Document'>
    <comment: 'I encode everything that is written to myself using #nextPut: and #nextPutAll: onto the wrapped stream. To be efficient I use an encoding table to be able to transform the most used characters from the UTF Basic Multilingual Plane as efficiently as possible. The convertion of a single character is defined in #encode:on: on the class-side of my subclasses.'>

    WAEncoder class [
	| table |
	
    ]

    WAEncoder class >> encode: aCharacter on: aStream [
	<category: 'private'>
	self subclassResponsibility
    ]

    WAEncoder class >> initializeBMP [
	"Initializes the BMP, the Basic Multilingual Plane of UTF characters, using the encoding strategy of the receiver. This chaching strategy ensures that most commonly used characters can be encoded as efficient as possible."

	<category: 'initialization'>
	| stream characterLimit |
	characterLimit := self maximumCharacterValue.
	table := Array new: characterLimit.
	stream := WriteStream on: (String new: 6).
	1 to: characterLimit
	    do: 
		[:index | 
		self encode: (Character value: index - 1) on: stream reset.
		table at: index
		    put: (stream position = 1 
			    ifTrue: [stream contents first]
			    ifFalse: [stream contents])]
    ]

    WAEncoder class >> maximumCharacterValue [
	"find the maximum value of a character that we can instantiate, for Squeak 3.7 this is 255"

	<category: 'private'>
	^
	[Character value: 65535.
	65535] on: Error do: [:error | 255]
    ]

    WAEncoder class >> on: aStream [
	<category: 'instance-creation'>
	^self on: aStream table: table
    ]

    WAEncoder class >> on: aStream table: anArray [
	<category: 'instance-creation'>
	^self basicNew initializeOn: aStream table: anArray
    ]

    initializeOn: aStream table: anArray [
	<category: 'initialization'>
	stream := aStream.
	table := anArray
    ]

    nextPut: aCharacter [
	<category: 'accessing'>
	| value encoded |
	value := aCharacter asInteger.
	value < table size 
	    ifFalse: [self class encode: aCharacter on: stream]
	    ifTrue: 
		[encoded := table at: value + 1.
		encoded isString 
		    ifTrue: [stream nextPutAll: encoded]
		    ifFalse: [stream nextPut: encoded]]
    ]

    nextPutAll: aString [
	<category: 'accessing'>
	"uses #to:do: for speed reasons (on Squeak)
	 this is not premature optimization, this is a hotspot method method
	 and #to:do: shows measurable speed improvements for rendering seaside pages"

	| character value encoded |
	1 to: aString size
	    do: 
		[:index | 
		character := aString at: index.
		value := character asInteger.
		value < table size 
		    ifFalse: [self class encode: character on: stream]
		    ifTrue: 
			[encoded := table at: value + 1.
			encoded isString 
			    ifTrue: [stream nextPutAll: encoded]
			    ifFalse: [stream nextPut: encoded]]]
    ]
]



WAEncoder subclass: WAHtmlEncoder [
    
    <category: 'Seaside-Core-Document'>
    <comment: 'I encode XHTML text.'>

    WAHtmlEncoder class >> encode: aCharacter on: aStream [
	<category: 'private'>
	aCharacter = $" ifTrue: [^aStream nextPutAll: '&quot;'].
	aCharacter = $< ifTrue: [^aStream nextPutAll: '&lt;'].
	aCharacter = $& ifTrue: [^aStream nextPutAll: '&amp;'].
	aCharacter = $> ifTrue: [^aStream nextPutAll: '&gt;'].
	aStream nextPut: aCharacter
    ]

    WAHtmlEncoder class >> initialize [
	<category: 'initialization'>
	self initializeBMP
    ]
]



WAEncoder subclass: WAUrlEncoder [
    
    <category: 'Seaside-Core-Document'>
    <comment: 'I encode path segments and arguments of an URL.'>

    WAUrlEncoder class >> encode: aCharacter on: aStream [
	<category: 'private'>
	| value |
	('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~' 
	    includes: aCharacter) ifTrue: [^aStream nextPut: aCharacter].
	aCharacter = Character space ifTrue: [^aStream nextPut: $+].
	value := aCharacter asInteger.
	
	[aStream
	    nextPut: $%;
	    nextPutAll: ((value \\ 256 printStringBase: 16) 
			padded: #left
			to: 2
			with: $0).
	value := value // 256.
	value = 0] 
		whileFalse
    ]

    WAUrlEncoder class >> initialize [
	<category: 'initialization'>
	self initializeBMP
    ]
]



Object subclass: WAErrorHandler [
    
    <category: 'Seaside-Core-Session'>
    <comment: 'Error handlers are invoked when an error in a Seaside application occurs. They handle
- errors
- warnings
- internal errors in the Seaside core

I am the base class for all error handlers and handle only internal errors which which I display a code 500 error with a short stackframe.

See WAWalkbackErrorHandler for examples of how to do rendering with the canvas API.'>

    WAErrorHandler class >> handleError: anError [
	<category: 'actions'>
	^self new handleError: anError
    ]

    WAErrorHandler class >> handleWarning: aWarning [
	<category: 'actions'>
	^self new handleWarning: aWarning
    ]

    WAErrorHandler class >> internalError: anError [
	<category: 'actions'>
	^self new internalError: anError
    ]

    handleError: anError [
	<category: 'actions'>
	anError pass
    ]

    handleWarning: aWarning [
	<category: 'actions'>
	self handleError: aWarning
    ]

    internalError: anError [
	<category: 'actions'>
	^WAResponse internalError: anError
    ]
]



WAErrorHandler subclass: WASimpleErrorHandler [
    
    <category: 'Seaside-Core-Session'>
    <comment: 'I am like WAErrorHandler except that I display the code 500 error with a short stackframe for errors and warnings too.'>

    handleError: anError [
	<category: 'actions'>
	WACurrentSession value returnResponse: (WAResponse internalError: anError)
    ]
]



Object subclass: WAFile [
    | contents contentType fileName |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: 'I represent a file that was uploaded by the user via #fileInput.'>

    contentType [
	<category: 'accessing'>
	^contentType
    ]

    contentType: aMimeTypeOrString [
	<category: 'accessing'>
	contentType := aMimeTypeOrString toMimeType
    ]

    contents [
	"Answer a ByteArray"

	<category: 'accessing'>
	^contents
    ]

    contents: aByteArray [
	<category: 'accessing'>
	contents := aByteArray
    ]

    fileName [
	"compensate for windows explorer behavior"

	<category: 'accessing'>
	^self isWindowsPath 
	    ifTrue: [fileName copyAfterLast: $\]
	    ifFalse: [fileName]
    ]

    fileName: aString [
	<category: 'accessing'>
	fileName := aString
    ]

    isWindowsPath [
	"'#:\*' match: fileName is broken on Squeak for WideString arguments"

	<category: 'private'>
	^fileName notEmpty and: 
		[fileName first isLetter 
		    and: [fileName size >= 3 and: [(fileName copyFrom: 2 to: 3) = ':\']]]
    ]
]



Object subclass: WAHtmlBuilder [
    | canvasClass fullDocument documentRoot rootBlock callbackOwner rootClass |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: 'A WAHtmlBuilder is a convenience class to render html. I am supposed to be used like this.

WARenderCanvas builder render: [ :html |
	html anchor
		url: ''htttp://www.seaside.st'';
		with: ''Seaside Homepage'' ]

See WAHtmlBuilderTest for more examples.

Instance Variables
	callbackOwner:		<Object>
	canvasClass:		<WACanvas class>
	documentRoot:		<WARoot>
	fullDocument:		<Boolean>
	rootBlock:			<BlockContext>

callbackOwner
	- optional, the owner of the callbacks

canvasClass
	- the canvas class to use, on the class side it must implement #context:callbacks: as an object construction method

documentRoot
	- for private use only, the instantiated root of the document

fullDocument
	- whether a full html document including the head section should be rendered

rootBlock
	- a one argement block to customize the document root. The argument of the block is the root
'>

    WAHtmlBuilder class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    WAHtmlBuilder class >> on: aCanvasClass [
	<category: 'instance creation'>
	^(self new)
	    canvasClass: aCanvasClass;
	    yourself
    ]

    actionUrl [
	<category: 'accessing'>
	^WAUrl new
    ]

    callbackOwner [
	<category: 'accessing'>
	^callbackOwner
    ]

    callbackOwner: anObject [
	<category: 'accessing'>
	callbackOwner := anObject
    ]

    canvasClass [
	<category: 'accessing'>
	^canvasClass
    ]

    canvasClass: aClass [
	<category: 'accessing'>
	canvasClass := aClass
    ]

    closeDocument: aDocument [
	<category: 'private'>
	self fullDocument ifTrue: [documentRoot close: aDocument]
    ]

    createCallbacksFor: aContext [
	<category: 'private'>
	^self callbackOwner isNil 
	    ifTrue: [nil]
	    ifFalse: [aContext callbacksFor: self callbackOwner]
    ]

    fullDocument [
	<category: 'accessing'>
	^fullDocument
    ]

    fullDocument: aBoolean [
	<category: 'accessing'>
	fullDocument := aBoolean
    ]

    initialize [
	<category: 'initialize-release'>
	self fullDocument: false
    ]

    openDocumentDocument: aDocument context: aContext [
	<category: 'private'>
	self fullDocument 
	    ifTrue: 
		[documentRoot := self rootClass context: aContext.
		self rootBlock value: documentRoot.
		documentRoot open: aDocument]
    ]

    render: anObject [
	<category: 'rendering'>
	^String streamContents: 
		[:stream | 
		| context docRoot document html callbacks |
		document := WAHtmlStreamDocument new stream: stream.
		context := WARenderingContext new.
		context document: document.
		context actionUrl: self actionUrl.
		context session: WACurrentSession value.
		callbacks := self createCallbacksFor: context.
		html := self canvasClass context: context callbacks: callbacks.
		self openDocumentDocument: document context: context.
		html context document stream: stream.
		html render: anObject.
		html flush.
		self closeDocument: document]
    ]

    rootBlock [
	<category: 'accessing'>
	rootBlock isNil ifTrue: [rootBlock := [:html | ]].
	^rootBlock
    ]

    rootBlock: anObject [
	<category: 'accessing'>
	rootBlock := anObject
    ]

    rootClass [
	<category: 'accessing'>
	rootClass isNil ifTrue: [rootClass := WAHtmlRoot].
	^rootClass
    ]

    rootClass: anHtmlRootClass [
	<category: 'accessing'>
	rootClass := anHtmlRootClass
    ]
]



Object subclass: WAHtmlDocument [
    
    <category: 'Seaside-Core-Document'>
    <comment: nil>

    WAHtmlDocument class >> new [
	<category: 'instance-creation'>
	^self basicNew initialize
    ]

    closeTag: aString [
	<category: 'writing-xhtml'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initialization'>
	
    ]

    nextPut: aCharacter [
	<category: 'writing'>
	self subclassResponsibility
    ]

    nextPutAll: aString [
	<category: 'writing'>
	self subclassResponsibility
    ]

    openTag: aString [
	<category: 'writing-xhtml'>
	self 
	    openTag: aString
	    attributes: nil
	    closed: false
    ]

    openTag: aString attributes: anAttributes [
	<category: 'writing-xhtml'>
	self 
	    openTag: aString
	    attributes: anAttributes
	    closed: false
    ]

    openTag: aString attributes: anAttributes closed: aBoolean [
	<category: 'writing-xhtml'>
	self subclassResponsibility
    ]

    print: anObject [
	<category: 'writing'>
	self subclassResponsibility
    ]
]



WAHtmlDocument subclass: WAHtmlStreamDocument [
    | stream htmlEncoder urlEncoder |
    
    <category: 'Seaside-Core-Document'>
    <comment: nil>

    close: aHtmlRoot [
	<category: 'actions'>
	aHtmlRoot close: self
    ]

    closeTag: aString [
	<category: 'writing-xhtml'>
	stream nextPutAll: '</'.
	stream nextPutAll: aString.
	stream nextPut: $>
    ]

    htmlEncoder [
	<category: 'accessing-encoders'>
	^htmlEncoder
    ]

    nextPut: aCharacter [
	<category: 'writing'>
	stream nextPut: aCharacter
    ]

    nextPutAll: aString [
	<category: 'writing'>
	stream nextPutAll: aString
    ]

    open: aHtmlRoot [
	<category: 'actions'>
	aHtmlRoot open: self
    ]

    openTag: aString attributes: anAttributes closed: aBoolean [
	<category: 'writing-xhtml'>
	stream nextPut: $<.
	stream nextPutAll: aString.
	anAttributes encodeOn: self.
	aBoolean ifTrue: [stream nextPut: $/].
	stream nextPut: $>
    ]

    print: anObject [
	<category: 'writing'>
	anObject encodeOn: self
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream.
	htmlEncoder := WAHtmlEncoder on: stream.
	urlEncoder := WAUrlEncoder on: stream
    ]

    urlEncoder [
	<category: 'accessing-encoders'>
	^urlEncoder
    ]
]



Object subclass: WAHtmlElement [
    | root attributes children |
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'Root class of all elements inside a <head> section.'>

    WAHtmlElement class >> root: aRoot [
	<category: 'instance-creation'>
	^self basicNew initializeWithRoot: aRoot
    ]

    add: anElement [
	<category: 'accessing-children'>
	children ifNil: [children := OrderedCollection new].
	children add: anElement
    ]

    attributeAt: aString [
	<category: 'accessing-attributes'>
	^self attributes at: aString
    ]

    attributeAt: aString ifAbsent: aBlock [
	<category: 'accessing-attributes'>
	^self attributes at: aString ifAbsent: aBlock
    ]

    attributeAt: aString put: anObject [
	<category: 'accessing-attributes'>
	^self attributes at: aString put: anObject
    ]

    attributes [
	<category: 'accessing'>
	^attributes ifNil: [attributes := WAHtmlAttributes new]
    ]

    childrenDo: aBlock [
	<category: 'accessing-children'>
	children ifNotNil: [:foo | children do: aBlock]
    ]

    encodeAfterOn: aDocument [
	<category: 'printing'>
	aDocument closeTag: self tag
    ]

    encodeBeforeOn: aDocument [
	<category: 'printing'>
	aDocument 
	    openTag: self tag
	    attributes: attributes
	    closed: self isClosed
    ]

    encodeChildrenOn: aDocument [
	<category: 'printing'>
	self childrenDo: [:each | each encodeOn: aDocument]
    ]

    encodeOn: aDocument [
	<category: 'printing'>
	self encodeBeforeOn: aDocument.
	self isClosed ifTrue: [^self].
	self encodeChildrenOn: aDocument.
	self encodeAfterOn: aDocument
    ]

    initializeWithRoot: aRoot [
	<category: 'initialization'>
	root := aRoot
    ]

    isClosed [
	<category: 'testing'>
	^true
    ]

    tag [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    with: anObject [
	<category: 'public'>
	self add: anObject
    ]
]



WAHtmlElement subclass: WABaseElement [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'In HTML, links and references to external images, applets, form-processing programs, style sheets, etc. are always specified by a URI. Relative URIs are resolved according to a base URI, which may come from a variety of sources. The BASE element allows authors to specify a document''s base URI explicitly.

When present, the BASE element must appear in the HEAD section of an HTML document, before any element that refers to an external source. The path information specified by the BASE element only affects URIs in the document where the element appears.

For example, given the following BASE declaration and A declaration:
updateRoot: html
	super updateRoot: html.
	html base url: ''http://www.aviary.com/products/intro.html''

renderContentOn: html
	html anchor
		url: ''../cages/birds.gif'';
		with: ''Bird Cages''

the relative URI "../cages/birds.gif" would resolve to:
http://www.aviary.com/cages/birds.gif'>

    tag [
	<category: 'accessing'>
	^'base'
    ]

    target: aString [
	<category: 'attributes'>
	self attributeAt: 'target' put: aString
    ]

    url: aString [
	<category: 'attributes'>
	self attributeAt: 'href' put: aString
    ]
]



WAHtmlElement subclass: WAContentElement [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'Common superclass of all elements inside a <head> that can have content. Either between the start and end tag or a (mime) document pointed to by an URL.'>

    contents: aString [
	<category: 'attributes'>
	self document: aString
    ]

    document: aString [
	<category: 'document'>
	self document: aString mimeType: self typeOrNil
    ]

    document: aString fileName: fileName [
	<category: 'document'>
	self 
	    document: aString
	    mimeType: self typeOrNil
	    fileName: fileName
    ]

    document: aString mimeType: mimeType [
	<category: 'document'>
	self 
	    document: aString
	    mimeType: mimeType
	    fileName: nil
    ]

    document: aString mimeType: mimeType fileName: fileName [
	<category: 'document'>
	self url: (root context 
		    urlForDocument: aString
		    mimeType: mimeType
		    fileName: fileName)
    ]

    encodeChildrenOn: aDocument [
	<category: 'printing'>
	children isEmptyOrNil ifTrue: [^self].
	aDocument nextPutAll: '/*<![CDATA[*/'.
	children do: [:each | aDocument nextPutAll: each seasideString].
	aDocument nextPutAll: '/*]]>*/'
    ]

    isClosed [
	<category: 'testing'>
	^false
    ]

    resourceUrl: aString [
	<category: 'attributes'>
	self url: (root context absoluteUrlForResource: aString)
    ]

    type: aMimeTypeOrString [
	<category: 'attributes'>
	self attributeAt: 'type' put: aMimeTypeOrString
    ]

    typeOrNil [
	<category: 'private'>
	^self attributeAt: 'type' ifAbsent: [nil]
    ]

    url: aString [
	<category: 'attributes'>
	self subclassResponsibility
    ]
]



WAContentElement subclass: WALinkElement [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'Defines either a link or style sheet rules. If it has children then it defines style sheet rules, else it defines a link.

= if link =
This element defines a link. Unlike A, it may only appear in the HEAD section of a document, although it may appear any number of times. Although LINK has no content, it conveys relationship information that may be rendered by user agents in a variety of ways (e.g., a tool-bar with a drop-down menu of links).

= style sheet rules =
The STYLE element allows authors to put style sheet rules in the head of the document. HTML permits any number of STYLE elements in the HEAD section of a document.

User agents that don''t support style sheets, or don''t support the specific style sheet language used by a STYLE element, must hide the contents of the STYLE element. It is an error to render the content as part of the document''s text. Some style sheet languages support syntax for hiding the content from non-conforming user agents.'>

    add: anElement [
	<category: 'accessing-children'>
	super add: anElement.
	attributes isNil ifFalse: [attributes removeKey: 'rel' ifAbsent: []]
    ]

    addAll [
	<category: 'media'>
	self addMedia: 'all'
    ]

    addAural [
	<category: 'media'>
	self addMedia: 'aural'
    ]

    addBraille [
	<category: 'media'>
	self addMedia: 'braille'
    ]

    addHandheld [
	<category: 'media'>
	self addMedia: 'handheld'
    ]

    addMedia: aString [
	<category: 'media'>
	| media |
	media := (((attributes at: 'media' ifAbsent: ['']) findTokens: $,) 
		    collect: [:each | each trimSeparators]) asSet.
	media add: aString.
	self 
	    media: (String streamContents: 
			[:stream | 
			media asSortedCollection do: [:each | stream nextPutAll: each]
			    separatedBy: [stream nextPutAll: ', ']])
    ]

    addPrint [
	<category: 'media'>
	self addMedia: 'print'
    ]

    addProjection [
	<category: 'media'>
	self addMedia: 'projection'
    ]

    addScreen [
	<category: 'media'>
	self addMedia: 'screen'
    ]

    addTeletype [
	<category: 'media'>
	self addMedia: 'tty'
    ]

    addTelevision [
	<category: 'media'>
	self addMedia: 'tv'
    ]

    beAlternate [
	"Gives alternate representations of the current document."

	<category: 'relationship'>
	self relationship: 'alternate'
    ]

    beAlternateStylesheet [
	<category: 'relationship'>
	self relationship: 'alternate stylesheet'
    ]

    beAppendix [
	<category: 'relationship'>
	self relationship: 'appendix'
    ]

    beArchives [
	"Provides a link to a collection of records, documents, or other materials of historical interest."

	<category: 'relationship'>
	self relationship: 'archives'
    ]

    beAtom [
	<category: 'type'>
	self type: 'application/atom+xml' toMimeType
    ]

    beBookmark [
	<category: 'relationship'>
	self relationship: 'bookmark'
    ]

    beChapter [
	<category: 'relationship'>
	self relationship: 'chapter'
    ]

    beClossary [
	<category: 'relationship'>
	self relationship: 'lossary'
    ]

    beCopyright [
	<category: 'relationship'>
	self relationship: 'copyright'
    ]

    beCss [
	<category: 'type'>
	self type: 'text/css' toMimeType
    ]

    beFirst [
	"Indicates that the current document is a part of a series, and that the first document in the series is the referenced document."

	<category: 'relationship'>
	self relationship: 'first'
    ]

    beFontDefinition [
	<category: 'relationship'>
	self relationship: 'fontdef'
    ]

    beGlossary [
	<category: 'relationship'>
	self relationship: 'glossary'
    ]

    beHelp [
	<category: 'relationship'>
	self relationship: 'help'
    ]

    beIndex [
	<category: 'relationship'>
	self relationship: 'index'
    ]

    beLast [
	<category: 'relationship'>
	self relationship: 'last'
    ]

    beMicrosummary [
	"http://wiki.mozilla.org/Microsummaries"

	<category: 'relationship'>
	self relationship: 'microsummary'
    ]

    beNext [
	"Indicates that the current document is a part of a series, and that the next document in the series is the referenced document."

	<category: 'relationship'>
	self relationship: 'next'
    ]

    bePrevious [
	"Indicates that the current document is a part of a series, and that the previous document in the series is the referenced document."

	<category: 'relationship'>
	self relationship: 'previous'
    ]

    beRss [
	<category: 'type'>
	self type: 'application/rss+xml' toMimeType
    ]

    beSearch [
	"Gives a link to a resource that can be used to search through the current document and its related pages."

	<category: 'relationship'>
	self relationship: 'search'
    ]

    beSection [
	<category: 'relationship'>
	self relationship: 'section'
    ]

    beShortcutIcon [
	<category: 'relationship'>
	self relationship: 'shortcut icon'
    ]

    beStart [
	"Refers to the first document in a collection of documents. This link type tells search engines which document is considered by the author to be the starting point of the collection."

	<category: 'relationship'>
	self relationship: 'start'
    ]

    beStylesheet [
	"Imports a stylesheet."

	<category: 'relationship'>
	self relationship: 'stylesheet'
    ]

    beSubsection [
	<category: 'relationship'>
	self relationship: 'subsection'
    ]

    beTableOfContents [
	<category: 'relationship'>
	self relationship: 'contents'
    ]

    beTop [
	<category: 'relationship'>
	self relationship: 'top'
    ]

    beUp [
	"Provides a link to a document giving the context for the current document."

	<category: 'relationship'>
	self relationship: 'up'
    ]

    isClosed [
	<category: 'testing'>
	^children isEmptyOrNil
    ]

    media: aString [
	"This attribute specifies the intended destination medium for style information. It may be a single media descriptor or a comma-separated list. The default value for this attribute is 'screen'."

	<category: 'attributes'>
	self attributeAt: 'media' put: aString
    ]

    relationship: aString [
	"This attribute describes the relationship from the current document to the anchor specified by the href(url) attribute. The value of this attribute is a space-separated list of link types."

	<category: 'attributes'>
	self attributeAt: 'rel' put: aString
    ]

    reverse: aString [
	"This attribute is used to describe a reverse link from the anchor specified by the href attribute to the current document. The value of this attribute is a space-separated list of link types."

	<category: 'attributes'>
	self attributeAt: 'rev' put: aString
    ]

    tag [
	<category: 'accessing'>
	^children isEmptyOrNil ifTrue: ['link'] ifFalse: ['style']
    ]

    title: aString [
	<category: 'attributes'>
	self attributeAt: 'title' put: aString
    ]

    url: aString [
	<category: 'attributes'>
	self attributeAt: 'href' put: aString
    ]
]



WAContentElement subclass: WAScriptElement [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'The SCRIPT element places a script within a document. This element may appear any number of times in the HEAD of an HTML document.

The script may be defined within the contents of the SCRIPT element or in an external file. If the src attribute is not set, user agents must interpret the contents of the element as the script. If the src has a URI value, user agents must ignore the element''s contents and retrieve the script via the URI. Note that the charset attribute refers to the character encoding of the script designated by the src attribute; it does not concern the content of the SCRIPT element.'>

    beJavascript [
	<category: 'types'>
	self type: 'text/javascript' toMimeType
    ]

    defer [
	"When set, this boolean attribute provides a hint to the user agent that the script is not going to generate any document content (e.g., no 'document.write' in javascript) and thus, the user agent can continue parsing and rendering."

	<category: 'attributes'>
	self attributeAt: 'defer' put: true
    ]

    tag [
	<category: 'accessing'>
	^'script'
    ]

    url: aString [
	<category: 'attributes'>
	self attributeAt: 'src' put: aString
    ]
]



WAHtmlElement subclass: WAMetaElement [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'The META element can be used to identify properties of a document (e.g., author, expiration date, a list of key words, etc.) and assign values to those properties. This specification does not define a normative set of properties.

Each META element specifies a property/value pair. The name attribute identifies the property and the content attribute specifies the property''s value.

For example, the following declaration sets a value for the Author property:
<META name="Author" content="Dave Raggett">

The lang attribute can be used with META to specify the language for the value of the content attribute. This enables speech synthesizers to apply language dependent pronunciation rules.

In this example, the author''s name is declared to be French:

htm meta
	name: ''Author''; language: ''fr''; content: ''Arnaud Le Hors''
	
Note. The META element is a generic mechanism for specifying meta data. However, some HTML elements and attributes already handle certain pieces of meta data and may be used by authors instead of META to specify those pieces: the TITLE element, the ADDRESS element, the INS and DEL elements, the title attribute, and the cite attribute.

Note. When a property specified by a META element takes a value that is a URI, some authors prefer to specify the meta data via the LINK element. Thus, the following meta data declaration:
html meta
      name: ''DC.identifier'';
      content: ''http://www.ietf.org/rfc/rfc1866.txt''

might also be written:
html link
         relationship: ''DC.identifier'';
         type: ''text/plain'';
         url: ''http://www.ietf.org/rfc/rfc1866.txt''

The http-equiv attribute can be used in place of the name attribute and has a special significance when documents are retrieved via the Hypertext Transfer Protocol (HTTP). HTTP servers may use the property name specified by the http-equiv attribute to create an [RFC822]-style header in the HTTP response. Please see the HTTP specification ([RFC2616]) for details on valid HTTP headers.

The following sample META declaration:
htttp meta
         responseHeaderName: ''Expires'';
         content: ''Tue, 20 Aug 1996 14:25:27 GMT''

will result in the HTTP header:
Expires: Tue, 20 Aug 1996 14:25:27 GMT

This can be used by caches to determine when to fetch a fresh copy of the associated document.

Note. Some user agents support the use of META to refresh the current page after a specified number of seconds, with the option of replacing it by a different URI. Authors should not use this technique to forward users to different pages, as this makes the page inaccessible to some users. Instead, automatic page forwarding should be done using server-side redirects.

html meta
         redirectAfter: 5 to: ''http://www.google.com/'''>

    beLeftToRight [
	<category: 'conveniance'>
	self textDirection: 'LTR'
    ]

    beRightToLeft [
	<category: 'conveniance'>
	self textDirection: 'RTL'
    ]

    content: aString [
	<category: 'attributes'>
	self attributeAt: 'content' put: aString
    ]

    contentScriptType: aMimeTypeOrString [
	<category: 'conveniance'>
	self responseHeaderName: 'Content-Script-Type'.
	self content: aMimeTypeOrString
    ]

    contentType: aMimeTypeOrString [
	<category: 'conveniance'>
	self responseHeaderName: 'Content-Type'.
	self content: aMimeTypeOrString
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self content: ''
    ]

    language: aString [
	<category: 'attributes'>
	self attributeAt: 'lang' put: aString
    ]

    name: aString [
	<category: 'attributes'>
	self attributeAt: 'name' put: aString
    ]

    redirectAfter: seconds to: aString [
	<category: 'conveniance'>
	self responseHeaderName: 'refresh'.
	self content: seconds seasideString , ';URL=' , aString
    ]

    responseHeaderName: aString [
	<category: 'attributes'>
	self attributeAt: 'http-equiv' put: aString
    ]

    scheme: aString [
	<category: 'attributes'>
	self attributeAt: 'scheme' put: aString
    ]

    tag [
	<category: 'accessing'>
	^'meta'
    ]

    textDirection: aString [
	<category: 'attributes'>
	self attributeAt: 'dir' put: aString
    ]
]



Object subclass: WALRUCache [
    | table ageTable max |
    
    <category: 'Seaside-Core-Utilities'>
    <comment: 'WALRUCache implements at Least Recently Used cache. Items are removed from the cache when they reach "max" age. The age of an item is the number of additions to the cache done since the item itself was added. WALRUCache does not worry about the size of the cache. The "capacity:" method is misleading, it sets how long items will remain in the cache.

Instance Variables:
	ageTable	<Dictionary>	The age each time in the cache
	max	<SmallInteger>	The age at which items are removed from the cache
	table	<Dictionary>	Items in the cache, each item has key
			
WALRUCache is used to store the last n continutations of a session.

'>

    WALRUCache class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    WALRUCache class >> new: max [
	<category: 'instance creation'>
	^self new capacity: max
    ]

    at: aKey [
	<category: 'accessing'>
	^self at: aKey ifAbsent: [self error: 'No entry for ' , aKey]
    ]

    at: aKey ifAbsent: anErrorBlock [
	<category: 'accessing'>
	| result |
	result := table at: aKey ifAbsent: [^anErrorBlock value].
	ageTable at: result put: 0.
	^result
    ]

    at: aKey put: aValue [
	<category: 'accessing'>
	| removals |
	table at: aKey put: aValue.
	ageTable at: aValue put: 0.
	removals := OrderedCollection new.
	ageTable associationsDo: 
		[:assoc | 
		assoc value > max 
		    ifTrue: [removals add: assoc key]
		    ifFalse: [assoc value: assoc value + 1]].
	removals do: [:each | self remove: each]
    ]

    capacity: aNumber [
	<category: 'initialize-release'>
	max := aNumber
    ]

    initialize [
	<category: 'initialize-release'>
	max := 20.
	table := Dictionary new.
	ageTable := Dictionary new
    ]

    isEmpty [
	<category: 'testing'>
	^table isEmpty
    ]

    nextKey [
	<category: 'callbacks'>
	| key |
	[table includesKey: (key := WAExternalID new seasideString)] whileTrue.
	^key
    ]

    remove: anObject [
	<category: 'removing'>
	ageTable removeKey: anObject.
	table removeKey: (table keyAtValue: anObject)
    ]

    store: anObject [
	<category: 'callbacks'>
	| key |
	key := self nextKey.
	self at: key put: anObject.
	^key
    ]
]



Object subclass: WALibrary [
    
    <category: 'Seaside-Core-Libraries'>
    <comment: 'I''m the common superclass of file and string libraries.'>

    WALibrary class [
	| default |
	
    ]

    WALibrary class >> default [
	<category: 'instance-creation'>
	^default ifNil: [default := self new]
    ]

    WALibrary class >> deployFiles [
	<category: 'actions'>
	^self default deployFiles
    ]

    WALibrary class >> documentAt: aFilename ifAbsent: aBlock [
	<category: 'accessing'>
	^self default documentAt: aFilename ifAbsent: aBlock
    ]

    WALibrary class >> handlesFolder: aSymbol [
	<category: 'testing'>
	^self name = aSymbol
    ]

    asFilename: aFilename [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    asSelector: aFilename [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    deployFiles [
	"Write to disk the files that the receiver use to serve as methods.
	 The files are stored in a subfolder named like the classname of the receiver in a subfolder of Smalltalk image folder."

	<category: 'actions'>
	SeasidePlatformSupport ensureExistenceOfFolder: self name.
	self fileSelectors do: 
		[:each | 
		SeasidePlatformSupport 
		    write: (self perform: each)
		    toFile: (self asFilename: each)
		    inFolder: self name]
    ]

    documentAt: aFilename ifAbsent: aBlock [
	<category: 'accessing'>
	| selector |
	selector := self asSelector: aFilename.
	^(self fileSelectors includes: selector) 
	    ifTrue: 
		[WAResponse document: (self documentForFile: aFilename)
		    mimeType: (self mimetypeForFile: aFilename)]
	    ifFalse: [aBlock value]
    ]

    documentForFile: aFilename [
	<category: 'accessing'>
	^self perform: (self asSelector: aFilename)
    ]

    fileSelectors [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    filenames [
	<category: 'accessing'>
	^self fileSelectors asArray collect: [:each | self asFilename: each]
    ]

    mimetypeForFile: aFilename [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    name [
	<category: 'accessing'>
	^self class name
    ]

    updateRoot: anHtmlRoot [
	<category: 'processing'>
	
    ]

    urlForFile: aFilename [
	<category: 'accessing'>
	^self urlOf: (self asSelector: aFilename)
    ]

    urlOf: aSymbol [
	<category: 'accessing'>
	^self urlOf: aSymbol using: WAFileHandler default
    ]

    urlOf: aSymbol using: aHandler [
	<category: 'accessing'>
	^(aHandler baseUrl)
	    addToPath: self className;
	    addToPath: (self asFilename: aSymbol);
	    yourself
    ]
]



WALibrary subclass: WAFileLibrary [
    
    <category: 'Seaside-Core-Libraries'>
    <comment: 'What does FileLibrary do
=============================
It allows to serve static files directly from seaside without the need for a standalone server like Apache or to configure Kom. These files can reference each other (say a CSS references an image) and can be distrubuted the same way as normal Smalltalk code (Monticello, SqueakMap, ...).

Each file in a file library is represented by a method. The method name is created from the file name, the dot is removed and the first letter of the suffix in capitalized. This puts certain limitations to the allowed filenames. Eg. ''main.css'' becomes #mainCss.

Like Script- and StyleLibraries FileLibraries can be added to an application so that they automatically include themselves in the document root. Implement #selectorsToInclude and return the selectors you whish to be added to the document root.

How to create a FileLibrary
================================
- First create the static files and put them in some directory. From there they can reference the other files in the same directory normally with their filenames.
- Make sure you have a "Files" entry that serves your files. This is a normal entry point type that you can find in your /seaside/config application. If you don''t already have one, you can create it if you select "Files" in the type field of the "add entry point" dialog. For the rest of this text we assume you chose "files" as the path.
- Create a subclass of WAFileLibrary, for the rest of this text I assume its name is MyFileLibrary.
- To add the files to your file library there are two ways.
1. Programmatically with MyFileLibrary class >> #addAllFilesIn: / #addFileNamed:. For example MyFileLibrary addAllFilesIn: ''/path/to/directory/with/files'' or MyFileLibrary addFileNamed: ''/path/to/background.png''.
2. Via the web interface. Go to your /seaside/config application and there click configure for your "Files". Click "configure" behind MyFileLibrary. There you can add a file by uploading it (select the file, then click "Add")

Note that a "Files" can consist of several file libraries and can even have tradional script or style libraries.

How to integrate a FileLibrary into your application
=============================================================
Files from a FileLibrary are ingetrated the same way other static files are integrated. They have a constant path that is ''/seaside/<Static File Library>/<FileLibrary class name>/<filename>'' so for example ''/seaside/files/MyFileLibrary/background.png''. These can be conveniently generated by ''MyFileLibrary / #aSelector'' where #aSelector is the name of the method representing that file. For example ''MyFileLibrary / #backgroundPng''.

How to get back the files in a FileLibrary
=================================================
The contents of a file library can be written out to disk. Writing out a file library first makes a folder with the name of the file library in the folder of your Smallatlk image. Then a file for each file in the file library is created in this folder. Writing out to disk can happen in three ways
1. MyFileLibrary default deployFiles
2. Via the configuration interface of the file library. On the same page where you can add files to your file library there is also a button ''write to disk'' which will write out all the files in this library.
3. Via the configuration interface of your application. In the section where you can add libraries to your application there is a a button ''write to disk'' which will write out all the libraries of this application.

Examples:
==========

The following code uses WAFileLibrary to add a CSS file to a page.

updateRoot: anHtmlRoot
	super updateRoot: anHtmlRoot.
	anHtmlRoot stylesheet 
		url: WAFileLibraryDemo / #mainCss
		
The folllowing code uses WAFileLibrary to display an image.

renderContentOn: html
	html image
		url: WAFileLibraryDemo / #mainJpg'>

    MimeTypes := nil.

    WAFileLibrary class >> / aSymbol [
	<category: 'convenience'>
	^self urlOf: aSymbol
    ]

    WAFileLibrary class >> addAllFilesIn: aPathString [
	"adds all files in the directory specified by aPathString to the current file library"

	<category: 'adding-files'>
	(SeasidePlatformSupport filesIn: aPathString) 
	    do: [:each | self addFileAt: each]
    ]

    WAFileLibrary class >> addFileAt: aPath [
	"adds the file specified by aFilename to the current file library"

	<category: 'adding-files'>
	self addFileAt: aPath
	    contents: (SeasidePlatformSupport contentsOfFile: aPath
		    binary: (self isBinaryAt: aPath))
    ]

    WAFileLibrary class >> addFileAt: aPath contents: aByteArrayOrString [
	<category: 'private'>
	self addFileNamed: (SeasidePlatformSupport localNameOf: aPath)
	    contents: aByteArrayOrString
    ]

    WAFileLibrary class >> addFileNamed: aFilename contents: aByteArrayOrString [
	<category: 'private'>
	| selector |
	selector := self asSelector: aFilename.
	(self isBinary: aFilename) 
	    ifTrue: [self compileBinary: aByteArrayOrString selector: selector]
	    ifFalse: [self compileText: aByteArrayOrString selector: selector]
    ]

    WAFileLibrary class >> adjustForVisualWorks [
	<category: 'vw port-squeak'>
	| newSource oldSource badCode goodCode |
	badCode := 'xxxCache := #(nil).'.
	goodCode := 'xxxCache := #(nil) beMutable.'.
	self selectors do: 
		[:selector | 
		oldSource := self sourceCodeAt: selector.
		(oldSource indexOfSubCollection: badCode startingAt: 1) > 0 
		    ifTrue: 
			[newSource := oldSource copyReplaceAll: badCode with: goodCode.
			self compile: newSource classified: self methodCategory]]
    ]

    WAFileLibrary class >> asSelector: aFilename [
	<category: 'private'>
	| mainPart extension |
	mainPart := (aFilename copyUpToLast: $.) 
		    select: [:each | each isAlphaNumeric].
	[mainPart first isDigit] whileTrue: [mainPart := mainPart allButFirst].
	extension := (aFilename copyAfterLast: $.) asLowercase capitalized.
	^(mainPart , extension) asSymbol
    ]

    WAFileLibrary class >> compileBinary: aByteArrayOrString selector: aSymbol [
	"compiles aByteArrayOrString into a method named aSymbol that returns aByteArrayOrString as a byte array"

	<category: 'private'>
	| code |
	code := SeasidePlatformSupport 
		    asMethodReturningByteArray: aByteArrayOrString
		    named: aSymbol.
	SeasidePlatformSupport 
	    compile: code
	    into: self
	    classified: self methodCategory
    ]

    WAFileLibrary class >> compileText: aByteArrayOrString selector: aSymbol [
	"Compiles aByteArrayOrString into a method named aSymbol that returns aByteArrayOrString as a string literal.
	 aSymbol
	 ^ aByteArrayOrString"

	<category: 'private'>
	| code |
	code := String streamContents: 
			[:stream | 
			stream
			    nextPutAll: aSymbol;
			    cr.
			stream
			    tab;
			    nextPutAll: '^ '''.
			aByteArrayOrString seasideString do: 
				[:each | 
				each = $' ifTrue: [stream nextPut: $'].
				stream nextPut: each].
			stream nextPutAll: ''''].
	SeasidePlatformSupport 
	    compile: code
	    into: self
	    classified: self methodCategory
    ]

    WAFileLibrary class >> defaultMimeType [
	<category: 'accessing-defaults'>
	^'application/octet-stream'
    ]

    WAFileLibrary class >> defaultMimeTypes [
	<category: 'accessing-defaults'>
	^#('%' 'application/x-trash' '323' 'text/h323' 'abw' 'application/x-abiword' 'ai' 'application/postscript' 'aif' 'audio/x-aiff' 'aifc' 'audio/x-aiff' 'aiff' 'audio/x-aiff' 'alc' 'chemical/x-alchemy' 'art' 'image/x-jg' 'asc' 'text/plain' 'asf' 'video/x-ms-asf' 'asn' 'chemical/x-ncbi-asn1-spec' 'aso' 'chemical/x-ncbi-asn1-binary' 'asx' 'video/x-ms-asf' 'au' 'audio/basic' 'avi' 'video/x-msvideo' 'b' 'chemical/x-molconn-Z' 'bak' 'application/x-trash' 'bat' 'application/x-msdos-program' 'bcpio' 'application/x-bcpio' 'bib' 'text/x-bibtex' 'bin' 'application/octet-stream' 'bmp' 'image/x-ms-bmp' 'book' 'application/x-maker' 'bsd' 'chemical/x-crossfire' 'c' 'text/x-csrc' 'c++' 'text/x-c++src' 'c3d' 'chemical/x-chem3d' 'cac' 'chemical/x-cache' 'cache' 'chemical/x-cache' 'cascii' 'chemical/x-cactvs-binary' 'cat' 'application/vnd.ms-pki.seccat' 'cbin' 'chemical/x-cactvs-binary' 'cc' 'text/x-c++src' 'cdf' 'application/x-cdf' 'cdr' 'image/x-coreldraw' 'cdt' 'image/x-coreldrawtemplate' 'cdx' 'chemical/x-cdx' 'cdy' 'application/vnd.cinderella' 'cef' 'chemical/x-cxf' 'cer' 'chemical/x-cerius' 'chm' 'chemical/x-chemdraw' 'chrt' 'application/x-kchart' 'cif' 'chemical/x-cif' 'class' 'application/java-vm' 'cls' 'text/x-tex' 'cmdf' 'chemical/x-cmdf' 'cml' 'chemical/x-cml' 'cod' 'application/vnd.rim.cod' 'com' 'application/x-msdos-program' 'cpa' 'chemical/x-compass' 'cpio' 'application/x-cpio' 'cpp' 'text/x-c++src' 'cpt' 'image/x-corelphotopaint' 'crl' 'application/x-pkcs7-crl' 'crt' 'application/x-x509-ca-cert' 'csf' 'chemical/x-cache-csf' 'csh' 'text/x-csh' 'csm' 'chemical/x-csml' 'csml' 'chemical/x-csml' 'css' 'text/css' 'csv' 'text/comma-separated-values' 'ctab' 'chemical/x-cactvs-binary' 'ctx' 'chemical/x-ctx' 'cu' 'application/cu-seeme' 'cub' 'chemical/x-gaussian-cube' 'cxf' 'chemical/x-cxf' 'cxx' 'text/x-c++src' 'dat' 'chemical/x-mopac-input' 'dcr' 'application/x-director' 'deb' 'application/x-debian-package' 'dif' 'video/dv' 'diff' 'text/plain' 'dir' 'application/x-director' 'djv' 'image/vnd.djvu' 'djvu' 'image/vnd.djvu' 'dl' 'video/dl' 'dll' 'application/x-msdos-program' 'dmg' 'application/x-apple-diskimage' 'dms' 'application/x-dms' 'doc' 'application/msword' 'dot' 'application/msword' 'dv' 'video/dv' 'dvi' 'application/x-dvi' 'dx' 'chemical/x-jcamp-dx' 'dxr' 'application/x-director' 'emb' 'chemical/x-embl-dl-nucleotide' 'embl' 'chemical/x-embl-dl-nucleotide' 'ent' 'chemical/x-pdb' 'eps' 'application/postscript' 'etx' 'text/x-setext' 'exe' 'application/x-msdos-program' 'ez' 'application/andrew-inset' 'fb' 'application/x-maker' 'fbdoc' 'application/x-maker' 'fch' 'chemical/x-gaussian-checkpoint' 'fchk' 'chemical/x-gaussian-checkpoint' 'fig' 'application/x-xfig' 'flac' 'application/x-flac' 'fli' 'video/fli' 'fm' 'application/x-maker' 'frame' 'application/x-maker' 'frm' 'application/x-maker' 'gal' 'chemical/x-gaussian-log' 'gam' 'chemical/x-gamess-input' 'gamin' 'chemical/x-gamess-input' 'gau' 'chemical/x-gaussian-input' 'gcd' 'text/x-pcs-gcd' 'gcf' 'application/x-graphing-calculator' 'gcg' 'chemical/x-gcg8-sequence' 'gen' 'chemical/x-genbank' 'gf' 'application/x-tex-gf' 'gif' 'image/gif' 'gjc' 'chemical/x-gaussian-input' 'gjf' 'chemical/x-gaussian-input' 'gl' 'video/gl' 'gnumeric' 'application/x-gnumeric' 'gpt' 'chemical/x-mopac-graph' 'gsf' 'application/x-font' 'gsm' 'audio/x-gsm' 'gtar' 'application/x-gtar' 'h' 'text/x-chdr' 'h++' 'text/x-c++hdr' 'hdf' 'application/x-hdf' 'hh' 'text/x-c++hdr' 'hin' 'chemical/x-hin' 'hpp' 'text/x-c++hdr' 'hqx' 'application/mac-binhex40' 'hs' 'text/x-haskell' 'hta' 'application/hta' 'htc' 'text/x-component' 'htm' 'text/html' 'html' 'text/html' 'hxx' 'text/x-c++hdr' 'ica' 'application/x-ica' 'ice' 'x-conference/x-cooltalk' 'ico' 'image/x-icon' 'ics' 'text/calendar' 'icz' 'text/calendar' 'ief' 'image/ief' 'iges' 'model/iges' 'igs' 'model/iges' 'iii' 'application/x-iphone' 'inp' 'chemical/x-gamess-input' 'ins' 'application/x-internet-signup' 'iso' 'application/x-iso9660-image' 'isp' 'application/x-internet-signup' 'ist' 'chemical/x-isostar' 'istr' 'chemical/x-isostar' 'jad' 'text/vnd.sun.j2me.app-descriptor' 'jar' 'application/java-archive' 'java' 'text/x-java' 'jdx' 'chemical/x-jcamp-dx' 'jmz' 'application/x-jmol' 'jng' 'image/x-jng' 'jnlp' 'application/x-java-jnlp-file' 'jpe' 'image/jpeg' 'jpeg' 'image/jpeg' 'jpg' 'image/jpeg' 'js' 'application/x-javascript' 'kar' 'audio/midi' 'key' 'application/pgp-keys' 'kil' 'application/x-killustrator' 'kin' 'chemical/x-kinemage' 'kpr' 'application/x-kpresenter' 'kpt' 'application/x-kpresenter' 'ksp' 'application/x-kspread' 'kwd' 'application/x-kword' 'kwt' 'application/x-kword' 'latex' 'application/x-latex' 'lha' 'application/x-lha' 'lhs' 'text/x-literate-haskell' 'lsf' 'video/x-la-asf' 'lsx' 'video/x-la-asf' 'ltx' 'text/x-tex' 'lzh' 'application/x-lzh' 'lzx' 'application/x-lzx' 'm3u' 'audio/x-mpegurl' 'm4a' 'audio/mpeg' 'maker' 'application/x-maker' 'man' 'application/x-troff-man' 'mcif' 'chemical/x-mmcif' 'mcm' 'chemical/x-macmolecule' 'mdb' 'application/msaccess' 'me' 'application/x-troff-me' 'mesh' 'model/mesh' 'mid' 'audio/midi' 'midi' 'audio/midi' 'mif' 'application/x-mif' 'mm' 'application/x-freemind' 'mmd' 'chemical/x-macromodel-input' 'mmf' 'application/vnd.smaf' 'mml' 'text/mathml' 'mmod' 'chemical/x-macromodel-input' 'mng' 'video/x-mng' 'moc' 'text/x-moc' 'mol' 'chemical/x-mdl-molfile' 'mol2' 'chemical/x-mol2' 'moo' 'chemical/x-mopac-out' 'mop' 'chemical/x-mopac-input' 'mopcrt' 'chemical/x-mopac-input' 'mov' 'video/quicktime' 'movie' 'video/x-sgi-movie' 'mp2' 'audio/mpeg' 'mp3' 'audio/mpeg' 'mp4' 'video/mp4' 'mpc' 'chemical/x-mopac-input' 'mpe' 'video/mpeg' 'mpeg' 'video/mpeg' 'mpega' 'audio/mpeg' 'mpg' 'video/mpeg' 'mpga' 'audio/mpeg' 'ms' 'application/x-troff-ms' 'msh' 'model/mesh' 'msi' 'application/x-msi' 'mvb' 'chemical/x-mopac-vib' 'mxu' 'video/vnd.mpegurl' 'nb' 'application/mathematica' 'nc' 'application/x-netcdf' 'nwc' 'application/x-nwc' 'o' 'application/x-object' 'oda' 'application/oda' 'odb' 'application/vnd.oasis.opendocument.database' 'odc' 'application/vnd.oasis.opendocument.chart' 'odf' 'application/vnd.oasis.opendocument.formula' 'odg' 'application/vnd.oasis.opendocument.graphics' 'odi' 'application/vnd.oasis.opendocument.image' 'odm' 'application/vnd.oasis.opendocument.text-master' 'odp' 'application/vnd.oasis.opendocument.presentation' 'ods' 'application/vnd.oasis.opendocument.spreadsheet' 'odt' 'application/vnd.oasis.opendocument.text' 'ogg' 'application/ogg' 'old' 'application/x-trash' 'oth' 'application/vnd.oasis.opendocument.text-web' 'oza' 'application/x-oz-application' 'p' 'text/x-pascal' 'p7r' 'application/x-pkcs7-certreqresp' 'pac' 'application/x-ns-proxy-autoconfig' 'pas' 'text/x-pascal' 'pat' 'image/x-coreldrawpattern' 'pbm' 'image/x-portable-bitmap' 'pcf' 'application/x-font' 'pcf.Z' 'application/x-font' 'pcx' 'image/pcx' 'pdb' 'chemical/x-pdb' 'pdf' 'application/pdf' 'pfa' 'application/x-font' 'pfb' 'application/x-font' 'pgm' 'image/x-portable-graymap' 'pgn' 'application/x-chess-pgn' 'pgp' 'application/pgp-signature' 'pk' 'application/x-tex-pk' 'pl' 'text/x-perl' 'pls' 'audio/x-scpls' 'pm' 'text/x-perl' 'png' 'image/png' 'pnm' 'image/x-portable-anymap' 'pot' 'text/plain' 'ppm' 'image/x-portable-pixmap' 'pps' 'application/vnd.ms-powerpoint' 'ppt' 'application/vnd.ms-powerpoint' 'prf' 'application/pics-rules' 'prt' 'chemical/x-ncbi-asn1-ascii' 'ps' 'application/postscript' 'psd' 'image/x-photoshop' 'psp' 'text/x-psp' 'py' 'text/x-python' 'pyc' 'application/x-python-code' 'pyo' 'application/x-python-code' 'qt' 'video/quicktime' 'qtl' 'application/x-quicktimeplayer' 'ra' 'audio/x-realaudio' 'ram' 'audio/x-pn-realaudio' 'rar' 'application/rar' 'ras' 'image/x-cmu-raster' 'rd' 'chemical/x-mdl-rdfile' 'rdf' 'application/rdf+xml' 'rgb' 'image/x-rgb' 'rm' 'audio/x-pn-realaudio' 'roff' 'application/x-troff' 'ros' 'chemical/x-rosdal' 'rpm' 'application/x-redhat-package-manager' 'rss' 'application/rss+xml' 'rtf' 'text/rtf' 'rtx' 'text/richtext' 'rxn' 'chemical/x-mdl-rxnfile' 'sct' 'text/scriptlet' 'sd' 'chemical/x-mdl-sdfile' 'sd2' 'audio/x-sd2' 'sda' 'application/vnd.stardivision.draw' 'sdc' 'application/vnd.stardivision.calc' 'sdd' 'application/vnd.stardivision.impress' 'sdf' 'chemical/x-mdl-sdfile' 'sdp' 'application/vnd.stardivision.impress' 'sdw' 'application/vnd.stardivision.writer' 'ser' 'application/java-serialized-object' 'sgf' 'application/x-go-sgf' 'sgl' 'application/vnd.stardivision.writer-global' 'sh' 'text/x-sh' 'shar' 'application/x-shar' 'shtml' 'text/html' 'sid' 'audio/prs.sid' 'sik' 'application/x-trash' 'silo' 'model/mesh' 'sis' 'application/vnd.symbian.install' 'sit' 'application/x-stuffit' 'skd' 'application/x-koan' 'skm' 'application/x-koan' 'skp' 'application/x-koan' 'skt' 'application/x-koan' 'smf' 'application/vnd.stardivision.math' 'smi' 'application/smil' 'smil' 'application/smil' 'snd' 'audio/basic' 'spc' 'chemical/x-galactic-spc' 'spl' 'application/x-futuresplash' 'src' 'application/x-wais-source' 'stc' 'application/vnd.sun.xml.calc.template' 'std' 'application/vnd.sun.xml.draw.template' 'sti' 'application/vnd.sun.xml.impress.template' 'stl' 'application/vnd.ms-pki.stl' 'stw' 'application/vnd.sun.xml.writer.template' 'sty' 'text/x-tex' 'sv4cpio' 'application/x-sv4cpio' 'sv4crc' 'application/x-sv4crc' 'svg' 'image/svg+xml' 'svgz' 'image/svg+xml' 'sw' 'chemical/x-swissprot' 'swf' 'application/x-shockwave-flash' 'swfl' 'application/x-shockwave-flash' 'sxc' 'application/vnd.sun.xml.calc' 'sxd' 'application/vnd.sun.xml.draw' 'sxg' 'application/vnd.sun.xml.writer.global' 'sxi' 'application/vnd.sun.xml.impress' 'sxm' 'application/vnd.sun.xml.math' 'sxw' 'application/vnd.sun.xml.writer' 't' 'application/x-troff' 'tar' 'application/x-tar' 'taz' 'application/x-gtar' 'tcl' 'text/x-tcl' 'tex' 'text/x-tex' 'texi' 'application/x-texinfo' 'texinfo' 'application/x-texinfo' 'text' 'text/plain' 'tgf' 'chemical/x-mdl-tgf' 'tgz' 'application/x-gtar' 'tif' 'image/tiff' 'tiff' 'image/tiff' 'tk' 'text/x-tcl' 'tm' 'text/texmacs' 'torrent' 'application/x-bittorrent' 'tr' 'application/x-troff' 'ts' 'text/texmacs' 'tsp' 'application/dsptype' 'tsv' 'text/tab-separated-values' 'txt' 'text/plain' 'udeb' 'application/x-debian-package' 'uls' 'text/iuls' 'ustar' 'application/x-ustar' 'val' 'chemical/x-ncbi-asn1-binary' 'vcd' 'application/x-cdlink' 'vcf' 'text/x-vcard' 'vcs' 'text/x-vcalendar' 'vmd' 'chemical/x-vmd' 'vms' 'chemical/x-vamas-iso14976' 'vor' 'application/vnd.stardivision.writer' 'vrm' 'x-world/x-vrml' 'vrml' 'x-world/x-vrml' 'vsd' 'application/vnd.visio' 'wad' 'application/x-doom' 'wav' 'audio/x-wav' 'wax' 'audio/x-ms-wax' 'wbmp' 'image/vnd.wap.wbmp' 'wbxml' 'application/vnd.wap.wbxml' 'wk' 'application/x-123' 'wm' 'video/x-ms-wm' 'wma' 'audio/x-ms-wma' 'wmd' 'application/x-ms-wmd' 'wml' 'text/vnd.wap.wml' 'wmlc' 'application/vnd.wap.wmlc' 'wmls' 'text/vnd.wap.wmlscript' 'wmlsc' 'application/vnd.wap.wmlscriptc' 'wmv' 'video/x-ms-wmv' 'wmx' 'video/x-ms-wmx' 'wmz' 'application/x-ms-wmz' 'wp5' 'application/wordperfect5.1' 'wpd' 'application/wordperfect' 'wrl' 'x-world/x-vrml' 'wsc' 'text/scriptlet' 'wvx' 'video/x-ms-wvx' 'wz' 'application/x-wingz' 'xbm' 'image/x-xbitmap' 'xcf' 'application/x-xcf' 'xht' 'application/xhtml+xml' 'xhtml' 'application/xhtml+xml' 'xlb' 'application/vnd.ms-excel' 'xls' 'application/vnd.ms-excel' 'xlt' 'application/vnd.ms-excel' 'xml' 'application/xml' 'xpi' 'application/x-xpinstall' 'xpm' 'image/x-xpixmap' 'xsl' 'application/xml' 'xtel' 'chemical/x-xtel' 'xul' 'application/vnd.mozilla.xul+xml' 'xwd' 'image/x-xwindowdump' 'xyz' 'chemical/x-xyz' 'zip' 'application/zip' 'zmt' 'chemical/x-mopac-input' '~' 'application/x-trash')
    ]

    WAFileLibrary class >> initialize [
	<category: 'class initialization'>
	MimeTypes := Dictionary new.
	1 to: self defaultMimeTypes size
	    by: 2
	    do: 
		[:index | 
		MimeTypes at: (self defaultMimeTypes at: index)
		    put: (self defaultMimeTypes at: index + 1)]
    ]

    WAFileLibrary class >> isBinary: aFilename [
	<category: 'private'>
	^(self mimetypeFor: (aFilename copyAfterLast: $.)) isBinary
    ]

    WAFileLibrary class >> isBinaryAt: aPath [
	<category: 'private'>
	^self isBinary: (SeasidePlatformSupport localNameOf: aPath)
    ]

    WAFileLibrary class >> methodCategory [
	"the method category for uploaded files"

	<category: 'private'>
	^#uploaded
    ]

    WAFileLibrary class >> mimetypeFor: aString [
	<category: 'accessing'>
	^(self mimetypes at: aString ifAbsent: [self defaultMimeType]) toMimeType
    ]

    WAFileLibrary class >> mimetypes [
	<category: 'accessing'>
	^MimeTypes
    ]

    WAFileLibrary class >> register [
	"no longer needed left in so that code can still be loaded since it is sent in class side initialize methods"

	<category: 'convenience'>
	
    ]

    WAFileLibrary class >> unregister [
	"no longer used"

	<category: 'convenience'>
	
    ]

    WAFileLibrary class >> urlOf: aSymbol [
	<category: 'convenience'>
	^self new urlOf: aSymbol
    ]

    addFile: aFile [
	"adds a file to the receiver
	 
	 aFile an instance of of WAFile"

	<category: 'actions'>
	| contents |
	aFile isNil ifTrue: [^self	"in case no file was selected for uploading"].
	contents := (self class isBinary: aFile fileName) 
		    ifTrue: [aFile contents]
		    ifFalse: [SeasidePlatformSupport convertToSmalltalkNewlines: aFile contents].
	self class addFileNamed: aFile fileName contents: contents
    ]

    asFilename: aSelector [
	<category: 'private'>
	| dotIndex extension |
	dotIndex := self lastUpperCaseIndexIn: aSelector.
	dotIndex = 0 
	    ifTrue: 
		["convert Symbol to String"

		^aSelector seasideString].
	extension := (aSelector last: aSelector size - dotIndex + 1) asLowercase.
	^(aSelector first: dotIndex - 1) , '.' , extension
    ]

    asSelector: aFilename [
	<category: 'private'>
	^self class asSelector: aFilename
    ]

    compileBinary: aString selector: aSymbol [
	<category: 'private'>
	^self class compileBinary: aString selector: aSymbol
    ]

    compileText: aString selector: aSymbol [
	<category: 'private'>
	self class compileText: aString selector: aSymbol
    ]

    fileSelectors [
	<category: 'private'>
	^(self class selectors select: [:each | self isFileSelector: each])
	    removeAllFoundIn: self nonFileSelectors;
	    yourself
    ]

    isFileSelector: aSymbol [
	<category: 'private'>
	^aSymbol isUnary and: [(self lastUpperCaseIndexIn: aSymbol) > 1]
    ]

    lastUpperCaseIndexIn: aString [
	<category: 'private'>
	^aString findLast: [:each | each isUppercase]
    ]

    mimetypeForFile: aFilename [
	<category: 'accessing'>
	^self class mimetypeFor: (aFilename copyAfterLast: $.)
    ]

    nonFileSelectors [
	<category: 'private'>
	^#(#nonFileSelectors #selectorsToInclude)
    ]

    removeFile: aFilename [
	<category: 'actions'>
	SeasidePlatformSupport removeSelector: (self asSelector: aFilename)
	    from: self class
    ]

    renameFile: oldName to: newName [
	<category: 'actions'>
	| contents file |
	(self asSelector: oldName) = (self asSelector: newName) ifTrue: [^nil].
	contents := self perform: (self asSelector: oldName).
	file := WAFile new contents: contents.
	file fileName: newName.
	self addFile: file.
	self removeFile: oldName
    ]

    selectorsToInclude [
	"The files represented by the selectors this method returns will be automatically added to the html <head> if the receiver is added to the respective Seaside application.
	 
	 This makes only sense for CSS and JS files"

	<category: 'accessing'>
	^#()
    ]

    updateRoot: aHtmlRoot [
	"Only override if you want to automatically include new types of resources. The default implementation knows how to reference CSS, JS and FavIcons into aHtmlRoot."

	<category: 'processing'>
	self selectorsToInclude do: 
		[:each | 
		(each endsWith: #Js) 
		    ifTrue: [aHtmlRoot javascript url: (self urlOf: each)].
		(each endsWith: #Ico) 
		    ifTrue: 
			[(aHtmlRoot link)
			    beShortcutIcon;
			    url: (self urlOf: each)].
		(each endsWith: #Css) 
		    ifTrue: [aHtmlRoot stylesheet url: (self urlOf: each)]]
    ]
]



WAFileLibrary subclass: WAStandardFiles [
    
    <category: 'Seaside-Core-Libraries'>
    <comment: 'A collection of standard scripts, styles, and images. They are needed for the configuration application and some basic look-and-feel in Seaside. The icons are from the Tango Desktop Project (tango.freedesktop.org), they are licensed under the Creative Commons Attribution Share-Alike license.'>

    codebrowserPng [
	<category: 'accessing-images'>
	| cache |
	cache := #(nil) beMutable.
	(cache at: 1) isNil 
	    ifTrue: 
		[cache at: 1
		    put: #(137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 6 98 75 71 68 0 255 0 255 0 255 160 189 167 147 0 0 0 9 112 72 89 115 0 0 11 19 0 0 11 19 1 0 154 156 24 0 0 0 7 116 73 77 69 7 213 9 22 18 55 41 59 82 2 72 0 0 1 203 73 68 65 84 56 203 165 147 77 104 19 65 20 199 127 51 221 163 72 22 34 45 226 177 224 41 160 88 43 1 15 130 21 132 120 236 69 208 182 39 175 165 23 21 60 138 32 197 32 245 34 126 128 154 22 138 49 189 91 26 17 77 92 16 237 193 98 211 141 27 76 253 192 213 108 235 16 21 90 145 205 120 48 67 179 109 106 43 190 203 255 13 204 251 207 111 102 222 131 255 12 97 146 226 93 250 128 25 224 216 86 122 120 136 188 169 147 0 151 71 47 157 1 102 14 30 119 216 142 182 18 88 77 189 1 240 237 249 57 182 163 87 79 74 221 172 59 45 141 211 222 84 64 89 21 88 221 147 167 172 10 252 232 122 216 86 95 76 75 6 199 138 28 233 31 6 24 55 4 196 227 113 196 137 165 63 139 125 77 101 77 125 223 39 127 79 50 116 237 25 31 158 140 51 183 16 132 64 135 213 122 31 165 20 245 122 125 195 75 7 65 128 155 73 173 21 123 203 124 45 77 117 0 61 17 3 219 182 177 109 59 82 236 251 62 110 38 197 224 88 145 197 199 25 94 149 151 81 165 28 64 207 200 100 99 246 175 4 230 228 129 116 129 197 124 134 185 183 10 85 202 241 115 255 69 206 159 189 48 11 136 77 9 180 214 20 210 189 12 92 121 138 55 125 135 202 231 239 168 249 7 188 239 26 166 179 205 55 70 8 180 214 100 179 89 126 201 67 204 59 14 239 62 213 89 122 61 5 189 105 118 173 172 0 218 52 161 110 75 16 134 33 187 63 166 121 244 165 155 251 185 28 221 242 37 59 251 110 145 76 38 113 93 151 55 149 5 140 139 92 79 80 173 86 241 60 143 145 201 6 71 59 43 172 238 72 16 30 24 37 145 72 96 89 22 150 101 69 186 120 3 65 44 22 67 107 77 173 86 67 107 141 148 18 173 53 66 8 132 16 173 219 27 17 3 165 20 142 227 108 58 117 198 100 125 24 131 137 155 183 175 159 250 135 41 158 48 201 111 90 157 232 152 121 9 252 18 0 0 0 0 73 69 78 68 174 66 96 130) 
			    asByteArray].
	^cache at: 1
    ]

    configPng [
	<category: 'accessing-images'>
	| cache |
	cache := #(nil) beMutable.
	(cache at: 1) isNil 
	    ifTrue: 
		[cache at: 1
		    put: #(137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 6 98 75 71 68 0 255 0 255 0 255 160 189 167 147 0 0 0 9 112 72 89 115 0 0 11 19 0 0 11 19 1 0 154 156 24 0 0 0 7 116 73 77 69 7 213 11 4 11 55 32 209 169 238 103 0 0 0 29 116 69 88 116 67 111 109 109 101 110 116 0 67 114 101 97 116 101 100 32 119 105 116 104 32 84 104 101 32 71 73 77 80 239 100 37 110 0 0 1 217 73 68 65 84 56 203 197 147 77 107 19 97 20 133 159 105 107 131 52 157 52 35 161 38 67 55 129 198 221 132 100 66 72 138 88 117 37 53 89 137 8 21 4 33 100 254 65 17 92 117 33 136 43 17 55 45 253 3 165 45 8 67 178 81 12 88 65 145 188 249 152 162 130 219 36 148 137 52 37 89 180 136 31 113 97 103 72 219 116 213 133 119 117 121 207 229 112 239 57 231 133 115 150 116 22 240 244 217 147 190 211 63 90 122 124 230 220 152 211 220 189 119 39 163 235 113 19 64 136 74 22 32 159 51 88 93 91 57 134 157 36 115 9 116 61 110 230 115 6 150 101 1 152 161 160 74 203 110 16 10 170 160 99 166 146 105 52 77 3 232 15 146 140 13 178 89 150 197 165 105 63 183 179 11 238 91 44 17 37 70 212 197 79 214 168 211 248 21 191 248 211 255 189 24 185 50 75 171 209 98 251 221 118 175 109 183 61 59 214 78 111 202 55 229 153 240 78 80 42 149 16 162 146 253 242 249 235 183 99 27 56 130 133 130 42 0 181 90 173 103 219 223 95 9 81 221 84 20 229 170 36 141 62 92 200 220 10 56 231 232 122 220 213 98 196 97 202 231 12 98 137 127 171 250 124 62 185 217 108 110 110 172 111 153 157 78 231 189 44 123 3 206 57 249 156 49 220 133 213 181 21 66 65 149 88 34 202 193 193 225 225 220 92 122 9 32 28 14 27 221 110 183 7 200 213 114 157 194 110 241 180 6 111 94 191 93 246 43 126 49 57 233 93 188 113 237 38 63 127 253 184 208 110 183 3 145 200 236 3 73 226 242 252 245 121 121 220 51 78 69 84 16 162 146 125 241 252 229 253 161 54 166 146 105 90 118 3 117 70 69 157 81 47 30 65 178 51 147 74 166 1 204 141 245 45 215 198 145 193 117 52 77 99 207 222 167 96 22 169 150 235 0 84 203 117 10 102 145 61 123 223 201 193 112 13 142 84 237 187 73 212 49 51 211 25 10 187 69 39 153 230 199 79 31 78 37 241 220 127 225 255 215 95 179 89 175 43 2 12 187 45 0 0 0 0 73 69 78 68 174 66 96 130) 
			    asByteArray].
	^cache at: 1
    ]

    externalAnchorsJs [
	<category: 'accessing-scripts'>
	^'// See http://www.sitepoint.com/article/standards-compliant-world
function externalLinks() {
	if (!document.getElementsByTagName) return;
	var anchors = document.getElementsByTagName("a");
	for (var i=0; i<anchors.length; i++) {
	var anchor = anchors[i];
	if (anchor.getAttribute("href") && anchor.getAttribute("rel") == "external")
		anchor.target = "_blank";
	}
}'
    ]

    haloCss [
	<category: 'accessing-styles'>
	^'.halo {
	margin: 2px;
	border: 1px solid #aaa;
}

/* header */
.halo-header {
	overflow: hidden;
	padding: 2px;
	color: #444;
	background-color: #eee;
	border-bottom: 1px solid #aaa;
	font: 10pt Verdana, Arial, Helvetica, sans-serif;
}
.halo-header a {
	text-decoration: none;
}
.halo-header div {
	float: left;
}
.halo-header div.classnamehaloplugin,
.halo-header div.browserhaloplugin,
.halo-header div.inspectorplugin,
.halo-header div.styleshaloplugin {
	float: left;
	display: block;
	padding-right: 5px;
}
.halo-header div.browserhaloplugin {
	background: url(codebrowser.png) no-repeat;
}
.halo-header div.inspectorplugin {
	background: url(inspector.png) no-repeat;
}
.halo-header div.styleshaloplugin {
	background: url(styleeditor.png) no-repeat;
}
.halo-header div.browserhaloplugin a,
.halo-header div.inspectorplugin a,
.halo-header div.styleshaloplugin a {
	width: 16px;
	display: block;
	text-indent: -32000px;
	background-position: 0 50%;
	outline: none;
}
.halo-header div.modehaloplugin {
	float: right;
	display: block;
}
.halo-header div.modehaloplugin a {
	color: #444;
}
.halo-header div.modehaloplugin a:hover {
	color: #111;
}
.halo-header div.modehaloplugin a.active {
	font-weight: bold;
}

/* body */
.halo-body {
	clear: both;
	padding: 2px;
}

/* source */
.halo-source .tag-known {
	font-weight: bold;
	color: navy;
}
.halo-source .attribute-known {
	color: navy;
}
.halo-source .attribute-value {
	color: purple;
}
.halo-source .comment {
	font-style: italic;
	color: green;
}'
    ]

    inspectorPng [
	<category: 'accessing-images'>
	| cache |
	cache := #(nil) beMutable.
	(cache at: 1) isNil 
	    ifTrue: 
		[cache at: 1
		    put: #(137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 6 98 75 71 68 0 240 0 240 0 239 52 6 103 27 0 0 0 9 112 72 89 115 0 0 11 19 0 0 11 19 1 0 154 156 24 0 0 0 7 116 73 77 69 7 213 11 5 16 15 5 37 253 173 47 0 0 1 246 73 68 65 84 56 203 157 146 77 107 19 81 24 133 159 59 201 36 77 154 102 134 74 82 10 10 181 93 104 26 69 20 193 133 184 20 10 85 119 226 38 191 192 111 169 244 31 136 182 36 65 68 20 116 89 119 85 16 197 77 168 59 65 236 162 84 40 164 137 86 171 150 80 53 141 205 71 39 77 50 51 215 69 72 73 66 82 170 103 119 15 239 61 239 225 188 71 60 121 250 120 49 247 39 119 140 61 64 85 213 231 19 183 38 47 182 144 211 209 187 150 220 35 238 77 223 145 237 162 78 41 235 92 62 191 185 235 118 77 211 59 242 78 33 196 206 35 153 76 118 28 10 133 66 93 133 119 28 180 15 102 50 25 102 95 204 2 144 152 75 0 208 180 107 119 7 223 190 175 146 74 167 57 122 106 140 109 197 139 105 43 184 100 133 212 252 107 38 110 223 140 196 162 247 159 53 254 40 237 14 52 93 35 149 78 115 232 228 24 159 11 94 6 7 2 140 28 8 82 18 62 180 209 113 252 154 62 115 237 198 149 227 93 29 36 230 18 12 135 79 179 82 112 115 233 204 16 190 30 21 211 182 81 29 10 239 150 37 193 35 227 54 75 111 22 0 1 160 116 10 75 122 3 12 13 232 88 182 100 219 52 169 212 44 202 85 139 126 159 155 95 101 181 37 9 69 74 137 148 118 75 48 110 183 11 132 160 92 181 168 214 36 155 91 53 220 170 131 253 253 30 164 16 45 93 112 2 182 105 154 45 78 108 99 131 53 163 138 223 163 162 247 185 176 45 137 223 227 228 211 70 129 125 61 150 157 107 114 174 212 43 234 66 211 116 52 77 231 194 185 243 164 23 222 18 236 19 124 249 153 39 155 43 145 55 42 124 92 89 167 84 174 144 91 122 229 44 21 139 63 26 2 34 26 159 154 177 44 43 210 124 13 195 48 112 56 84 78 156 141 176 188 86 100 203 84 24 236 149 172 47 190 100 248 224 8 0 31 230 223 167 30 62 120 116 88 116 107 216 213 235 151 167 2 129 224 100 51 231 235 245 17 30 13 243 59 155 173 247 101 245 43 130 127 68 44 30 149 13 145 255 18 0 148 88 60 106 1 148 13 131 191 6 140 246 211 127 51 231 46 0 0 0 0 73 69 78 68 174 66 96 130) 
			    asByteArray].
	^cache at: 1
    ]

    kalseyTabsCss [
	"this is from http://kalsey.com/tools/csstabs/ - would also be nice to do http://www.alistapart.com/articles/slidingdoors/"

	<category: 'accessing-styles'>
	^'
.kalsey .navigation-options {
	border-bottom : 1px solid #ccc;
	margin : 0;
	padding-bottom : 19px;
	padding-left : 10px;
}

.kalsey .navigation-options ul, .kalsey .navigation-options li	{
	display : inline;
	list-style-type : none;
	margin : 0;
	padding : 0;
}


.kalsey .navigation-options a:link, .kalsey .navigation-options a:visited	{
	background : #E8EBF0;
	border : 1px solid #ccc;
	color : #666;
	float : left;
	font-size : small;
	font-weight : normal;
	line-height : 14px;
	margin-right : 8px;
	padding : 2px 10px 2px 10px;
	text-decoration : none;
}

.kalsey .navigation-options a:link.active, .kalsey .navigation-options a:visited.active	{
	background : #fff;
	border-bottom : 1px solid #fff;
	color : #000;
}

.kalsey .navigation-options ul a:hover	{
	color : #f00;
}

.kalsey .navigation-options .option-selected a {
	background : #fff;
	border-bottom : 1px solid #fff;
	color : #000;
}

.kalsey .navigation-content {
	background : #fff;
	border : 1px solid #ccc;
	border-top : none;
	clear : both;
	margin : 0px;
	padding : 15px;
	line-height: 1.1;  /* IE6 CSS workaround - http://www.dracos.co.uk/web/css/ie6floatbug/ */
}
'
    ]

    memoryPng [
	<category: 'accessing-images'>
	| cache |
	cache := #(nil) beMutable.
	(cache at: 1) isNil 
	    ifTrue: 
		[cache at: 1
		    put: #(137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 6 98 75 71 68 0 255 0 255 0 255 160 189 167 147 0 0 0 9 112 72 89 115 0 0 11 19 0 0 11 19 1 0 154 156 24 0 0 0 7 116 73 77 69 7 213 10 19 17 58 52 159 194 36 103 0 0 1 240 73 68 65 84 56 203 165 147 61 104 20 65 24 134 159 221 153 157 221 189 194 20 34 18 209 75 97 12 66 208 72 2 1 33 96 97 115 96 17 36 106 180 17 82 88 137 193 70 17 15 46 133 164 176 178 49 130 149 86 134 147 72 136 88 156 66 42 27 65 68 61 73 180 9 130 7 241 206 52 10 130 119 59 127 22 49 49 33 39 74 124 225 101 186 103 158 225 251 38 40 149 138 15 128 115 108 35 222 251 105 74 165 162 111 181 154 190 217 106 250 191 197 57 231 51 157 173 183 84 42 122 185 70 155 184 59 79 185 82 253 167 155 71 11 135 185 112 162 7 0 9 16 69 138 114 165 138 234 0 37 99 136 20 103 142 46 67 16 50 251 166 11 156 7 60 24 139 54 134 114 165 202 248 233 62 0 194 141 100 21 167 68 105 202 217 161 58 23 135 7 17 74 146 38 9 105 46 69 37 41 34 151 144 36 9 0 214 152 223 6 107 17 42 70 36 49 253 61 123 8 115 5 250 187 27 168 232 19 143 23 14 32 188 3 35 201 66 13 128 177 118 171 65 148 40 70 6 107 236 219 213 193 203 165 6 93 249 83 136 72 146 36 49 81 162 16 113 132 138 213 159 13 78 14 212 8 3 137 200 21 224 219 44 65 48 130 144 130 171 199 159 179 80 223 141 179 14 235 44 83 111 3 140 109 3 184 60 122 157 128 128 143 181 25 222 47 127 37 191 23 14 229 119 114 164 211 48 216 55 142 247 0 158 169 251 183 218 3 110 207 220 68 40 129 148 17 66 10 62 55 230 232 221 63 202 195 215 53 204 247 59 88 99 177 198 254 122 130 221 10 120 242 174 155 40 85 168 88 17 197 10 33 63 112 176 243 25 190 89 35 12 2 158 46 245 210 252 145 1 139 237 13 96 117 222 22 71 232 29 206 57 46 61 234 192 249 29 104 109 208 86 99 113 171 6 27 1 90 103 140 13 15 112 111 238 213 38 220 226 60 192 139 182 155 184 242 101 101 179 193 149 243 67 92 27 59 134 214 25 89 43 67 27 141 214 107 231 134 26 77 163 81 95 135 73 96 122 114 242 198 246 127 227 255 230 39 112 67 0 83 217 168 244 129 0 0 0 0 73 69 78 68 174 66 96 130) 
			    asByteArray].
	^cache at: 1
    ]

    miscJs [
	<category: 'accessing-scripts'>
	^'
	function swapDisplay(a, b) {
		var tmp = document.getElementById(a).style.display;
		document.getElementById(a).style.display = document.getElementById(b).style.display;
		document.getElementById(b).style.display = tmp;
	}

	function submitFormTriggeringCallback(formName, callbackKey, value) {
		if (value)
			{
				var ele = document.createElement("input");
				ele.type = "hidden";
				ele.name = callbackKey;
				ele.value = value;
				document.forms[formName].appendChild(ele)
			}
		submitForm(formName)
	}

	function submitForm(formName) {
		document.forms[formName].submit();
	}

	function chooseOther(select, hiddenId, p) {
		value = prompt(p);
		document.getElementById(hiddenId).value = value;
		select.options[select.options.length-1].text = value;
	}

	function enableChoice(enableID, disableID) {
		document.getElementById(enableID).disabled = false;
		document.getElementById(disableID).disabled = true;
	}

	function setFocus(elementId) {
		document.getElementById(elementId).focus();
	}

	function setSelection(elementId, start, stop) {
		var input = document.getElementById(elementId);
		input.focus();
		/* When stop parameter not supplied, all field is selected */
		if (!start) start = 1;
		if (!stop) stop = input.value.length + 1;
		if (typeof document.selection != "undefined") {
	    		/* Place selection in MS-IE */
	    		var range = document.selection.createRange();
	     	range.moveStart("character", start - 1);
	     	range.moveEnd("character", stop - start);
	 		range.select();
	  	} else if (typeof input.selectionStart != "undefined") {
		  	/* Place selection in Gecko browsers */
	    		input.selectionStart = start - 1;
	    		input.selectionEnd = stop - 1;
	  	} else {
	  		/* Other browsers, please feel free to implement */
			alert("unknown browser");
		}
	}

'
    ]

    profilerPng [
	<category: 'accessing-images'>
	| cache |
	cache := #(nil) beMutable.
	(cache at: 1) isNil 
	    ifTrue: 
		[cache at: 1
		    put: #(137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 4 115 66 73 84 8 8 8 8 124 8 100 136 0 0 0 9 112 72 89 115 0 0 4 157 0 0 4 157 1 124 52 107 161 0 0 0 25 116 69 88 116 83 111 102 116 119 97 114 101 0 119 119 119 46 105 110 107 115 99 97 112 101 46 111 114 103 155 238 60 26 0 0 3 25 73 68 65 84 56 141 101 147 79 104 219 117 24 198 63 223 111 218 181 105 27 243 167 165 127 213 181 22 35 181 171 237 198 152 204 22 230 193 169 200 14 67 24 84 152 135 194 16 188 8 66 17 113 243 44 115 189 120 16 65 135 5 157 90 240 160 224 230 182 67 41 108 172 44 235 97 3 219 117 90 211 218 37 105 154 52 77 211 52 77 242 203 239 251 199 131 53 108 250 192 115 123 223 207 203 3 239 35 172 181 60 170 177 209 113 25 104 14 156 10 132 90 94 110 244 53 29 208 74 233 236 230 230 189 108 58 115 253 171 111 63 185 202 127 36 30 5 188 59 246 241 96 248 64 223 55 62 191 127 64 169 138 168 171 3 173 20 219 185 50 78 197 213 249 173 252 157 244 218 218 91 95 127 255 233 234 255 0 227 239 157 127 59 220 223 247 89 93 67 77 176 183 219 71 103 48 129 150 65 124 161 126 42 21 205 159 75 113 230 34 247 217 217 113 210 235 177 216 169 139 151 206 223 168 2 206 156 254 176 249 224 139 135 127 243 135 188 29 195 71 2 120 202 119 168 245 182 83 44 149 8 118 190 134 244 120 81 74 145 201 100 185 118 121 150 100 114 251 143 116 34 49 48 57 53 81 145 0 79 247 118 127 39 106 100 199 161 161 30 230 102 127 165 232 212 163 157 36 30 247 47 246 213 122 144 82 34 165 36 24 244 51 114 236 32 96 194 77 1 255 231 0 114 108 116 92 120 27 26 15 181 181 122 233 122 178 131 55 222 252 128 153 217 24 209 165 251 56 187 15 1 133 16 226 159 188 66 208 209 217 194 11 131 61 212 213 213 31 5 144 66 136 103 129 64 40 244 4 198 24 16 130 177 119 206 177 190 219 207 236 92 148 197 197 69 172 181 143 185 185 37 136 54 170 125 108 116 188 94 122 106 106 142 26 107 106 125 190 122 86 86 163 104 173 81 74 113 226 228 25 86 182 70 184 114 245 38 174 235 98 173 197 24 67 98 45 134 223 223 132 209 38 4 246 57 169 149 138 56 101 199 221 201 151 120 170 107 127 21 176 177 177 129 197 195 240 240 8 214 90 180 214 24 99 104 111 235 36 159 47 0 228 64 44 73 107 237 239 21 167 146 201 110 230 80 74 85 125 225 194 4 199 143 191 194 208 208 32 90 235 170 141 49 100 82 89 132 144 201 201 169 137 162 156 156 154 176 197 194 238 194 194 252 67 50 153 44 74 41 92 215 229 236 217 143 8 135 195 184 174 91 133 106 173 201 109 21 184 125 123 30 167 84 140 0 72 128 92 38 115 122 183 224 108 220 186 113 143 157 157 66 117 120 59 159 163 92 46 85 33 197 221 50 215 126 185 9 200 196 149 235 63 156 171 2 38 167 38 74 15 22 238 126 17 141 166 203 63 253 56 67 34 190 177 119 85 163 181 65 107 67 124 53 205 165 201 203 36 83 185 98 36 50 125 49 182 22 13 10 33 164 176 214 34 132 104 4 122 7 250 142 188 62 252 210 171 239 123 27 26 219 189 245 251 232 238 105 163 226 104 150 151 227 184 174 182 249 252 86 106 122 230 231 47 227 201 149 8 240 0 88 174 118 65 8 225 7 158 169 173 217 183 255 240 208 177 147 173 173 157 207 55 183 180 117 25 173 77 42 21 95 79 165 18 75 119 231 111 77 91 107 215 128 5 32 102 173 181 143 181 113 239 227 26 129 16 224 7 124 123 49 139 64 1 200 0 219 214 90 243 239 206 223 67 200 195 25 126 17 209 190 0 0 0 0 73 69 78 68 174 66 96 130) 
			    asByteArray].
	^cache at: 1
    ]

    selectorsToInclude [
	<category: 'accessing'>
	^#(#toolbarCss #haloCss #windowCss #kalseyTabsCss #externalAnchorsJs #miscJs #shortcutsJs)
    ]

    shortcutsJs [
	<category: 'accessing-scripts'>
	^'

	var shortcutKeys = [];
	var shortcutElements = [];

	function resetShortcuts() {
		shortcutKeys = [];
		shortcutElements = [];
	}

	function addShortcut(shortcut, elementID) {
		var elem = document.getElementById(elementID);
		if ((elem.tagName == "INPUT" & (elem.type == "submit" || elem.type == "checkbox" || elem.type == "radio")) || elem.tagName == "A")
			{
			shortcutKeys[shortcutKeys.length] = shortcut;
			shortcutElements[shortcutElements.length] = elem;
			}
		else alert("Attempt to assign a shortcut (" + shortcut + ") to something that is not clickable");
	}

	function onKeyDown(event) {
		var keyname = "";
		var element;
		var nav;
		if (navigator.userAgent.indexOf("Safari") > 0)
			nav = "Safari";
		else if (navigator.product == "Gecko")
			nav = "Gecko";
		else
			nav = "IE";
		// cope with MS-IE
		if (event == null) event = window.event;
		if (event) {
			if (event.ctrlKey) keyname = keyname + "Ctrl-";
			if (event.altKey) keyname = keyname + "Alt-";
			if (event.metaKey) keyname = keyname + "Meta-";
			// cope with Netscape
			var keyCode = event.which;
			if (keyCode == null) keyCode = event.keyCode;
			if (keyCode == null) keyCode = event.charCode;
			if (keyCode != 0) {
				var character = String.fromCharCode(keyCode);
				character = character.toLowerCase();
				if (event.shiftKey) character = character.toUpperCase();
				// cope with special keys, designated with some logical names
				if (keyCode == 27) character = "Esc";
				if (keyCode == 8) character = "Backspace";
				if (keyCode == 9) character = "Tab";
				if (keyCode == 13) character = "Return";
				if (keyCode == 37) character = "Left";
				if (keyCode == 38) character = "Up";
				if (keyCode == 39) character = "Right";
				if (keyCode == 40) character = "Down";
				// cope with func-keys (some keys not intercepted for MS-IE)
				if ((keyCode >= 112) & (keyCode <= 123)) character = "F" + (keyCode - 112 + 1);
				for ( var x = 1 ; x <= shortcutKeys.length ; x++ ) {
					if (shortcutKeys[x-1] == keyname+character) {
						// alert("key=" + keyCode + " " + keyname + character);
						element = shortcutElements[x-1];
						if (element.tagName == "A" & nav != "IE") {
							if (element.onclick)
								element.onclick.call();
							else
								/* This does not work for anchor in IE */
								location.href = element.href;
						} else  {
							element.click();
						}
					}
				}
				return false;
			}
		}
	}

'
    ]

    styleeditorPng [
	<category: 'accessing-images'>
	| cache |
	cache := #(nil) beMutable.
	(cache at: 1) isNil 
	    ifTrue: 
		[cache at: 1
		    put: #(137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 6 98 75 71 68 0 255 0 255 0 255 160 189 167 147 0 0 0 9 112 72 89 115 0 0 11 19 0 0 11 19 1 0 154 156 24 0 0 0 7 116 73 77 69 7 214 4 9 20 4 42 36 195 187 166 0 0 2 112 73 68 65 84 56 203 173 147 221 75 83 113 24 199 63 155 155 110 57 245 164 169 232 24 180 240 173 50 207 48 74 144 68 27 82 209 141 43 147 145 136 226 159 97 36 236 70 130 174 162 232 38 34 42 86 104 26 42 5 74 47 243 5 65 212 110 52 148 48 95 74 156 107 206 236 156 249 50 117 110 167 139 58 232 130 186 144 30 248 193 247 226 249 124 248 61 207 143 31 28 172 146 107 156 213 74 119 119 183 114 16 216 180 15 222 19 184 65 116 67 167 27 228 223 167 211 13 226 31 112 226 126 184 198 89 173 104 84 24 232 183 55 54 10 73 201 41 16 217 37 184 178 66 95 107 171 4 84 44 222 110 89 150 229 96 219 204 204 76 89 93 109 61 85 85 85 212 56 171 105 111 123 169 87 5 157 246 250 122 135 226 245 18 24 25 1 69 225 136 77 132 212 52 94 127 15 140 249 46 86 230 100 103 153 15 23 228 159 160 188 188 92 133 117 64 36 14 224 42 60 40 42 41 73 88 236 233 97 119 99 131 104 56 204 178 94 199 156 205 198 194 217 211 230 230 155 46 163 86 27 135 40 138 108 132 130 60 122 248 88 7 68 0 180 234 112 74 40 4 202 222 78 190 230 230 225 63 83 76 83 83 51 62 159 143 188 188 60 218 59 94 176 24 76 222 108 56 89 89 168 246 169 2 79 48 16 32 45 63 31 157 193 192 252 229 75 248 47 216 185 238 172 197 231 243 97 52 26 233 31 232 227 211 236 23 4 177 250 208 146 144 237 138 17 76 31 79 126 254 166 191 87 193 100 226 104 105 41 19 69 133 92 113 92 99 109 109 13 69 81 88 95 15 50 60 58 202 80 192 138 201 168 195 159 146 105 143 17 124 168 73 170 141 27 44 211 188 21 38 232 26 241 144 62 61 133 167 239 61 130 32 32 203 50 119 238 221 229 227 143 12 66 187 113 108 135 35 49 239 170 3 208 155 37 123 162 152 195 192 173 49 182 36 3 130 55 132 102 106 146 150 251 207 8 71 34 172 104 173 44 109 9 164 101 89 9 200 219 100 202 126 79 140 0 32 204 38 74 244 87 150 204 195 196 235 102 241 246 26 176 228 22 99 200 182 112 42 43 129 213 245 29 62 15 116 72 54 105 201 21 35 8 123 5 207 106 116 206 97 201 201 96 97 122 25 128 236 226 45 178 114 94 49 120 99 202 247 77 41 72 4 200 148 253 30 155 180 228 122 50 249 110 92 21 104 0 28 117 86 49 122 46 208 127 190 193 34 24 73 37 202 46 235 138 159 161 167 43 146 118 40 189 162 203 61 63 254 183 143 161 81 131 163 206 42 238 28 219 113 233 205 146 93 189 85 252 92 188 235 95 240 127 169 159 24 23 11 103 188 240 115 88 0 0 0 0 73 69 78 68 174 66 96 130) 
			    asByteArray].
	^cache at: 1
    ]

    toolbarCss [
	<category: 'accessing-styles'>
	^'body {
	margin-bottom: 25px;
}
#toolbar {
	z-index: 20;
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	padding: 2px;
	color: #444;
	background-color: #eee;
	border-top: 1px solid #aaa;
	font: 10pt Verdana, Arial, Helvetica, sans-serif;
}
#toolbar a {
	color: #444;
	padding-left: 3px;
	padding-right: 3px;
	text-decoration: none;
}
#toolbar a:hover {
	color: #111;
}
#toolbar a.deprecated {
	color: #ff7000;
}'
    ]

    updateRoot: aHtmlRoot [
	<category: 'processing'>
	super updateRoot: aHtmlRoot.
	aHtmlRoot bodyAttributes at: 'onkeydown' put: 'onKeyDown(event)'
    ]

    windowCss [
	<category: 'accessing-styles'>
	^'.window {
	border: 1px solid #aaa;
}
.window .window-titlebar {
	color: #444;
	padding: 5px;
	overflow: hidden;
	background-color: #eee;
	border-bottom: 1px solid #aaa;
	font: 10pt Verdana, Arial, Helvetica, sans-serif;
}
.window .window-titlebar .window-title {
	float: left;
	font-weight: bold;
	padding-left: 20px;
}
.window .window-titlebar .browserhaloplugin {
	background: url(codebrowser.png) no-repeat;
}
.window .window-titlebar .inspectorplugin {
	background: url(inspector.png) no-repeat;
}
.window .window-titlebar .styleshaloplugin {
	background: url(styleeditor.png) no-repeat;
}
.window .window-titlebar .configuretoolplugin {
	background: url(config.png) no-repeat;
}
.window .window-titlebar .profilertoolplugin {
	background: url(profiler.png) no-repeat;
}
.window .window-titlebar .memorytoolplugin {
	background: url(memory.png) no-repeat;
}
.window .window-titlebar .window-close {
	float: right;
}
.window .window-titlebar .window-close a {
	color: #444;
	text-decoration: none;
}
.window .window-titlebar .window-close a:hover {
	color: #111;
}
.window .window-content {
	clear: both;
	padding: 2px;
}'
    ]
]



Object subclass: WALocale [
    | language country |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: nil>

    WALocale class [
	| iso2Languages iso3Languages iso2Countries |
	
    ]

    WALocale class >> countryList [
	<category: 'accessing'>
	^'This list states the country names (official short names in English) in alphabetical order as given in ISO 3166-1 and the corresponding ISO 3166-1-alpha-2 code elements. The list is updated whenever a change to the official code list in ISO 3166-1 is effected by the ISO 3166/MA. It lists 240 official short names and code elements. One line of text contains one entry. A country name and its code element are separated by a semicolon (;).

AFGHANISTAN;AF
ÅLAND ISLANDS;AX
ALBANIA;AL
ALGERIA;DZ
AMERICAN SAMOA;AS
ANDORRA;AD
ANGOLA;AO
ANGUILLA;AI
ANTARCTICA;AQ
ANTIGUA AND BARBUDA;AG
ARGENTINA;AR
ARMENIA;AM
ARUBA;AW
AUSTRALIA;AU
AUSTRIA;AT
AZERBAIJAN;AZ
BAHAMAS;BS
BAHRAIN;BH
BANGLADESH;BD
BARBADOS;BB
BELARUS;BY
BELGIUM;BE
BELIZE;BZ
BENIN;BJ
BERMUDA;BM
BHUTAN;BT
BOLIVIA;BO
BOSNIA AND HERZEGOVINA;BA
BOTSWANA;BW
BOUVET ISLAND;BV
BRAZIL;BR
BRITISH INDIAN OCEAN TERRITORY;IO
BRUNEI DARUSSALAM;BN
BULGARIA;BG
BURKINA FASO;BF
BURUNDI;BI
CAMBODIA;KH
CAMEROON;CM
CANADA;CA
CAPE VERDE;CV
CAYMAN ISLANDS;KY
CENTRAL AFRICAN REPUBLIC;CF
CHAD;TD
CHILE;CL
CHINA;CN
CHRISTMAS ISLAND;CX
COCOS (KEELING) ISLANDS;CC
COLOMBIA;CO
COMOROS;KM
CONGO;CG
CONGO, THE DEMOCRATIC REPUBLIC OF THE;CD
COOK ISLANDS;CK
COSTA RICA;CR
CÔTE D''IVOIRE;CI
CROATIA;HR
CUBA;CU
CYPRUS;CY
CZECH REPUBLIC;CZ
DENMARK;DK
DJIBOUTI;DJ
DOMINICA;DM
DOMINICAN REPUBLIC;DO
ECUADOR;EC
EGYPT;EG
EL SALVADOR;SV
EQUATORIAL GUINEA;GQ
ERITREA;ER
ESTONIA;EE
ETHIOPIA;ET
FALKLAND ISLANDS (MALVINAS);FK
FAROE ISLANDS;FO
FIJI;FJ
FINLAND;FI
FRANCE;FR
FRENCH GUIANA;GF
FRENCH POLYNESIA;PF
FRENCH SOUTHERN TERRITORIES;TF
GABON;GA
GAMBIA;GM
GEORGIA;GE
GERMANY;DE
GHANA;GH
GIBRALTAR;GI
GREECE;GR
GREENLAND;GL
GRENADA;GD
GUADELOUPE;GP
GUAM;GU
GUATEMALA;GT
GUERNSEY;GG
GUINEA;GN
GUINEA-BISSAU;GW
GUYANA;GY
HAITI;HT
HEARD ISLAND AND MCDONALD ISLANDS;HM
HOLY SEE (VATICAN CITY STATE);VA
HONDURAS;HN
HONG KONG;HK
HUNGARY;HU
ICELAND;IS
INDIA;IN
INDONESIA;ID
IRAN, ISLAMIC REPUBLIC OF;IR
IRAQ;IQ
IRELAND;IE
ISLE OF MAN;IM
ISRAEL;IL
ITALY;IT
JAMAICA;JM
JAPAN;JP
JERSEY;JE
JORDAN;JO
KAZAKHSTAN;KZ
KENYA;KE
KIRIBATI;KI
KOREA, DEMOCRATIC PEOPLE''S REPUBLIC OF;KP
KOREA, REPUBLIC OF;KR
KUWAIT;KW
KYRGYZSTAN;KG
LAO PEOPLE''S DEMOCRATIC REPUBLIC;LA
LATVIA;LV
LEBANON;LB
LESOTHO;LS
LIBERIA;LR
LIBYAN ARAB JAMAHIRIYA;LY
LIECHTENSTEIN;LI
LITHUANIA;LT
LUXEMBOURG;LU
MACAO;MO
MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF;MK
MADAGASCAR;MG
MALAWI;MW
MALAYSIA;MY
MALDIVES;MV
MALI;ML
MALTA;MT
MARSHALL ISLANDS;MH
MARTINIQUE;MQ
MAURITANIA;MR
MAURITIUS;MU
MAYOTTE;YT
MEXICO;MX
MICRONESIA, FEDERATED STATES OF;FM
MOLDOVA, REPUBLIC OF;MD
MONACO;MC
MONGOLIA;MN
MONTENEGRO;ME
MONTSERRAT;MS
MOROCCO;MA
MOZAMBIQUE;MZ
MYANMAR;MM
NAMIBIA;NA
NAURU;NR
NEPAL;NP
NETHERLANDS;NL
NETHERLANDS ANTILLES;AN
NEW CALEDONIA;NC
NEW ZEALAND;NZ
NICARAGUA;NI
NIGER;NE
NIGERIA;NG
NIUE;NU
NORFOLK ISLAND;NF
NORTHERN MARIANA ISLANDS;MP
NORWAY;NO
OMAN;OM
PAKISTAN;PK
PALAU;PW
PALESTINIAN TERRITORY, OCCUPIED;PS
PANAMA;PA
PAPUA NEW GUINEA;PG
PARAGUAY;PY
PERU;PE
PHILIPPINES;PH
PITCAIRN;PN
POLAND;PL
PORTUGAL;PT
PUERTO RICO;PR
QATAR;QA
REUNION;RE
ROMANIA;RO
RUSSIAN FEDERATION;RU
RWANDA;RW
SAINT BARTHÉLEMY;BL
SAINT HELENA;SH
SAINT KITTS AND NEVIS;KN
SAINT LUCIA;LC
SAINT MARTIN;MF
SAINT PIERRE AND MIQUELON;PM
SAINT VINCENT AND THE GRENADINES;VC
SAMOA;WS
SAN MARINO;SM
SAO TOME AND PRINCIPE;ST
SAUDI ARABIA;SA
SENEGAL;SN
SERBIA;RS
SEYCHELLES;SC
SIERRA LEONE;SL
SINGAPORE;SG
SLOVAKIA;SK
SLOVENIA;SI
SOLOMON ISLANDS;SB
SOMALIA;SO
SOUTH AFRICA;ZA
SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS;GS
SPAIN;ES
SRI LANKA;LK
SUDAN;SD
SURINAME;SR
SVALBARD AND JAN MAYEN;SJ
SWAZILAND;SZ
SWEDEN;SE
SWITZERLAND;CH
SYRIAN ARAB REPUBLIC;SY
TAIWAN, PROVINCE OF CHINA;TW
TAJIKISTAN;TJ
TANZANIA, UNITED REPUBLIC OF;TZ
THAILAND;TH
TIMOR-LESTE;TL
TOGO;TG
TOKELAU;TK
TONGA;TO
TRINIDAD AND TOBAGO;TT
TUNISIA;TN
TURKEY;TR
TURKMENISTAN;TM
TURKS AND CAICOS ISLANDS;TC
TUVALU;TV
UGANDA;UG
UKRAINE;UA
UNITED ARAB EMIRATES;AE
UNITED KINGDOM;GB
UNITED STATES;US
UNITED STATES MINOR OUTLYING ISLANDS;UM
URUGUAY;UY
UZBEKISTAN;UZ
VANUATU;VU
VENEZUELA;VE
VIET NAM;VN
VIRGIN ISLANDS, BRITISH;VG
VIRGIN ISLANDS, U.S.;VI
WALLIS AND FUTUNA;WF
WESTERN SAHARA;EH
YEMEN;YE
ZAMBIA;ZM
ZIMBABWE;ZW
'
    ]

    WALocale class >> fromString: aString [
	<category: 'instance creation'>
	| language country delimeter |
	delimeter := (aString includes: $_) ifTrue: [$_] ifFalse: [$-].
	language := aString copyUpTo: delimeter.
	country := aString copyAfter: delimeter.
	country isEmpty ifTrue: [country := nil].
	^self language: language country: country
    ]

    WALocale class >> initialize [
	<category: 'class initialization'>
	self parseLanguageString.
	self parseCountryString
    ]

    WALocale class >> iso2Countries [
	<category: 'accessing'>
	^iso2Countries
    ]

    WALocale class >> iso2Languages [
	<category: 'accessing'>
	^iso2Languages
    ]

    WALocale class >> iso3Languages [
	<category: 'accessing'>
	^iso3Languages
    ]

    WALocale class >> language: aLanguageString country: aCounryString [
	<category: 'instance creation'>
	^(self new)
	    language: aLanguageString;
	    country: aCounryString;
	    yourself
    ]

    WALocale class >> languageList [
	<category: 'accessing'>
	^'aar||aa|Afar|afar
abk||ab|Abkhazian|abkhaze
ace|||Achinese|aceh
ach|||Acoli|acoli
ada|||Adangme|adangme
ady|||Adyghe; Adygei|adyghé
afa|||Afro-Asiatic (Other)|afro-asiatiques, autres langues
afh|||Afrihili|afrihili
afr||af|Afrikaans|afrikaans
ain|||Ainu|aïnou
aka||ak|Akan|akan
akk|||Akkadian|akkadien
alb|sqi|sq|Albanian|albanais
ale|||Aleut|aléoute
alg|||Algonquian languages|algonquines, langues
alt|||Southern Altai|altai du Sud
amh||am|Amharic|amharique
ang|||English, Old (ca.450-1100)|anglo-saxon (ca.450-1100)
anp|||Angika|angika
apa|||Apache languages|apache
ara||ar|Arabic|arabe
arc|||Official Aramaic (700-300 BCE); Imperial Aramaic (700-300 BCE)|araméen d''empire (700-300 BCE)
arg||an|Aragonese|aragonais
arm|hye|hy|Armenian|arménien
arn|||Mapudungun; Mapuche|mapudungun; mapuche; mapuce
arp|||Arapaho|arapaho
art|||Artificial (Other)|artificielles, autres langues
arw|||Arawak|arawak
asm||as|Assamese|assamais
ast|||Asturian; Bable; Leonese; Asturleonese|asturien; bable; léonais; asturoléonais
ath|||Athapascan languages|athapascanes, langues
aus|||Australian languages|australiennes, langues
ava||av|Avaric|avar
ave||ae|Avestan|avestique
awa|||Awadhi|awadhi
aym||ay|Aymara|aymara
aze||az|Azerbaijani|azéri
bad|||Banda languages|banda, langues
bai|||Bamileke languages|bamilékés, langues
bak||ba|Bashkir|bachkir
bal|||Baluchi|baloutchi
bam||bm|Bambara|bambara
ban|||Balinese|balinais
baq|eus|eu|Basque|basque
bas|||Basa|basa
bat|||Baltic (Other)|baltiques, autres langues
bej|||Beja; Bedawiyet|bedja
bel||be|Belarusian|biélorusse
bem|||Bemba|bemba
ben||bn|Bengali|bengali
ber|||Berber (Other)|berbères, autres langues
bho|||Bhojpuri|bhojpuri
bih||bh|Bihari|bihari
bik|||Bikol|bikol
bin|||Bini; Edo|bini; edo
bis||bi|Bislama|bichlamar
bla|||Siksika|blackfoot
bnt|||Bantu (Other)|bantoues, autres langues
bos||bs|Bosnian|bosniaque
bra|||Braj|braj
bre||br|Breton|breton
btk|||Batak languages|batak, langues
bua|||Buriat|bouriate
bug|||Buginese|bugi
bul||bg|Bulgarian|bulgare
bur|mya|my|Burmese|birman
byn|||Blin; Bilin|blin; bilen
cad|||Caddo|caddo
cai|||Central American Indian (Other)|indiennes d''Amérique centrale, autres langues
car|||Galibi Carib|karib; galibi; carib
cat||ca|Catalan; Valencian|catalan; valencien
cau|||Caucasian (Other)|caucasiennes, autres langues
ceb|||Cebuano|cebuano
cel|||Celtic (Other)|celtiques, autres langues
cha||ch|Chamorro|chamorro
chb|||Chibcha|chibcha
che||ce|Chechen|tchétchène
chg|||Chagatai|djaghataï
chi|zho|zh|Chinese|chinois
chk|||Chuukese|chuuk
chm|||Mari|mari
chn|||Chinook jargon|chinook, jargon
cho|||Choctaw|choctaw
chp|||Chipewyan; Dene Suline|chipewyan
chr|||Cherokee|cherokee
chu||cu|Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic|slavon d''église; vieux slave; slavon liturgique; vieux bulgare
chv||cv|Chuvash|tchouvache
chy|||Cheyenne|cheyenne
cmc|||Chamic languages|chames, langues
cop|||Coptic|copte
cor||kw|Cornish|cornique
cos||co|Corsican|corse
cpe|||Creoles and pidgins, English based (Other)|créoles et pidgins anglais, autres
cpf|||Creoles and pidgins, French-based (Other)|créoles et pidgins français, autres
cpp|||Creoles and pidgins, Portuguese-based (Other)|créoles et pidgins portugais, autres
cre||cr|Cree|cree
crh|||Crimean Tatar; Crimean Turkish|tatar de Crimé
crp|||Creoles and pidgins (Other)|créoles et pidgins divers
csb|||Kashubian|kachoube
cus|||Cushitic (Other)|couchitiques, autres langues
cze|ces|cs|Czech|tchèque
dak|||Dakota|dakota
dan||da|Danish|danois
dar|||Dargwa|dargwa
day|||Land Dayak languages|dayak, langues
del|||Delaware|delaware
den|||Slave (Athapascan)|esclave (athapascan)
dgr|||Dogrib|dogrib
din|||Dinka|dinka
div||dv|Divehi; Dhivehi; Maldivian|maldivien
doi|||Dogri|dogri
dra|||Dravidian (Other)|dravidiennes, autres langues
dsb|||Lower Sorbian|bas-sorabe
dua|||Duala|douala
dum|||Dutch, Middle (ca.1050-1350)|néerlandais moyen (ca. 1050-1350)
dut|nld|nl|Dutch; Flemish|néerlandais; flamand
dyu|||Dyula|dioula
dzo||dz|Dzongkha|dzongkha
efi|||Efik|efik
egy|||Egyptian (Ancient)|égyptien
eka|||Ekajuk|ekajuk
elx|||Elamite|élamite
eng||en|English|anglais
enm|||English, Middle (1100-1500)|anglais moyen (1100-1500)
epo||eo|Esperanto|espéranto
est||et|Estonian|estonien
ewe||ee|Ewe|éwé
ewo|||Ewondo|éwondo
fan|||Fang|fang
fao||fo|Faroese|féroïen
fat|||Fanti|fanti
fij||fj|Fijian|fidjien
fil|||Filipino; Pilipino|filipino; pilipino
fin||fi|Finnish|finnois
fiu|||Finno-Ugrian (Other)|finno-ougriennes, autres langues
fon|||Fon|fon
fre|fra|fr|French|français
frm|||French, Middle (ca.1400-1600)|français moyen (1400-1600)
fro|||French, Old (842-ca.1400)|français ancien (842-ca.1400)
frr|||Northern Frisian|frison septentrional
frs|||Eastern Frisian|frison oriental
fry||fy|Western Frisian|frison occidental
ful||ff|Fulah|peul
fur|||Friulian|frioulan
gaa|||Ga|ga
gay|||Gayo|gayo
gba|||Gbaya|gbaya
gem|||Germanic (Other)|germaniques, autres langues
geo|kat|ka|Georgian|géorgien
ger|deu|de|German|allemand
gez|||Geez|guèze
gil|||Gilbertese|kiribati
gla||gd|Gaelic; Scottish Gaelic|gaélique; gaélique écossais
gle||ga|Irish|irlandais
glg||gl|Galician|galicien
glv||gv|Manx|manx; mannois
gmh|||German, Middle High (ca.1050-1500)|allemand, moyen haut (ca. 1050-1500)
goh|||German, Old High (ca.750-1050)|allemand, vieux haut (ca. 750-1050)
gon|||Gondi|gond
gor|||Gorontalo|gorontalo
got|||Gothic|gothique
grb|||Grebo|grebo
grc|||Greek, Ancient (to 1453)|grec ancien (jusqu''à 1453)
gre|ell|el|Greek, Modern (1453-)|grec moderne (après 1453)
grn||gn|Guarani|guarani
gsw|||Swiss German; Alemannic|alémanique
guj||gu|Gujarati|goudjrati
gwi|||Gwich''in|gwich''in
hai|||Haida|haida
hat||ht|Haitian; Haitian Creole|haïtien; créole haïtien
hau||ha|Hausa|haoussa
haw|||Hawaiian|hawaïen
heb||he|Hebrew|hébreu
her||hz|Herero|herero
hil|||Hiligaynon|hiligaynon
him|||Himachali|himachali
hin||hi|Hindi|hindi
hit|||Hittite|hittite
hmn|||Hmong|hmong
hmo||ho|Hiri Motu|hiri motu
hsb|||Upper Sorbian|haut-sorabe
hun||hu|Hungarian|hongrois
hup|||Hupa|hupa
iba|||Iban|iban
ibo||ig|Igbo|igbo
ice|isl|is|Icelandic|islandais
ido||io|Ido|ido
iii||ii|Sichuan Yi; Nuosu|yi de Sichuan
ijo|||Ijo languages|ijo, langues
iku||iu|Inuktitut|inuktitut
ile||ie|Interlingue; Occidental|interlingue
ilo|||Iloko|ilocano
ina||ia|Interlingua (International Auxiliary Language Association)|interlingua (langue auxiliaire internationale)
inc|||Indic (Other)|indo-aryennes, autres langues
ind||id|Indonesian|indonésien
ine|||Indo-European (Other)|indo-européennes, autres langues
inh|||Ingush|ingouche
ipk||ik|Inupiaq|inupiaq
ira|||Iranian (Other)|iraniennes, autres langues
iro|||Iroquoian languages|iroquoises, langues (famille)
ita||it|Italian|italien
jav||jv|Javanese|javanais
jbo|||Lojban|lojban
jpn||ja|Japanese|japonais
jpr|||Judeo-Persian|judéo-persan
jrb|||Judeo-Arabic|judéo-arabe
kaa|||Kara-Kalpak|karakalpak
kab|||Kabyle|kabyle
kac|||Kachin; Jingpho|kachin; jingpho
kal||kl|Kalaallisut; Greenlandic|groenlandais
kam|||Kamba|kamba
kan||kn|Kannada|kannada
kar|||Karen languages|karen, langues
kas||ks|Kashmiri|kashmiri
kau||kr|Kanuri|kanouri
kaw|||Kawi|kawi
kaz||kk|Kazakh|kazakh
kbd|||Kabardian|kabardien
kha|||Khasi|khasi
khi|||Khoisan (Other)|khoisan, autres langues
khm||km|Central Khmer|khmer central
kho|||Khotanese|khotanais
kik||ki|Kikuyu; Gikuyu|kikuyu
kin||rw|Kinyarwanda|rwanda
kir||ky|Kirghiz; Kyrgyz|kirghiz
kmb|||Kimbundu|kimbundu
kok|||Konkani|konkani
kom||kv|Komi|kom
kon||kg|Kongo|kongo
kor||ko|Korean|coréen
kos|||Kosraean|kosrae
kpe|||Kpelle|kpellé
krc|||Karachay-Balkar|karatchai balkar
krl|||Karelian|carélien
kro|||Kru languages|krou, langues
kru|||Kurukh|kurukh
kua||kj|Kuanyama; Kwanyama|kuanyama; kwanyama
kum|||Kumyk|koumyk
kur||ku|Kurdish|kurde
kut|||Kutenai|kutenai
lad|||Ladino|judéo-espagnol
lah|||Lahnda|lahnda
lam|||Lamba|lamba
lao||lo|Lao|lao
lat||la|Latin|latin
lav||lv|Latvian|letton
lez|||Lezghian|lezghien
lim||li|Limburgan; Limburger; Limburgish|limbourgeois
lin||ln|Lingala|lingala
lit||lt|Lithuanian|lituanien
lol|||Mongo|mongo
loz|||Lozi|lozi
ltz||lb|Luxembourgish; Letzeburgesch|luxembourgeois
lua|||Luba-Lulua|luba-lulua
lub||lu|Luba-Katanga|luba-katanga
lug||lg|Ganda|ganda
lui|||Luiseno|luiseno
lun|||Lunda|lunda
luo|||Luo (Kenya and Tanzania)|luo (Kenya et Tanzanie)
lus|||Lushai|lushai
mac|mkd|mk|Macedonian|macédonien
mad|||Madurese|madourais
mag|||Magahi|magahi
mah||mh|Marshallese|marshall
mai|||Maithili|maithili
mak|||Makasar|makassar
mal||ml|Malayalam|malayalam
man|||Mandingo|mandingue
mao|mri|mi|Maori|maori
map|||Austronesian (Other)|malayo-polynésiennes, autres langues
mar||mr|Marathi|marathe
mas|||Masai|massaï
may|msa|ms|Malay|malais
mdf|||Moksha|moksa
mdr|||Mandar|mandar
men|||Mende|mendé
mga|||Irish, Middle (900-1200)|irlandais moyen (900-1200)
mic|||Mi''kmaq; Micmac|mi''kmaq; micmac
min|||Minangkabau|minangkabau
mis|||Uncoded languages|langues non codées
mkh|||Mon-Khmer (Other)|môn-khmer, autres langues
mlg||mg|Malagasy|malgache
mlt||mt|Maltese|maltais
mnc|||Manchu|mandchou
mni|||Manipuri|manipuri
mno|||Manobo languages|manobo, langues
moh|||Mohawk|mohawk
mol||mo|Moldavian|moldave
mon||mn|Mongolian|mongol
mos|||Mossi|moré
mul|||Multiple languages|multilingue
mun|||Munda languages|mounda, langues
mus|||Creek|muskogee
mwl|||Mirandese|mirandais
mwr|||Marwari|marvari
myn|||Mayan languages|maya, langues
myv|||Erzya|erza
nah|||Nahuatl languages|nahuatl, langues
nai|||North American Indian|indiennes d''Amérique du Nord, autres langues
nap|||Neapolitan|napolitain
nau||na|Nauru|nauruan
nav||nv|Navajo; Navaho|navaho
nbl||nr|Ndebele, South; South Ndebele|ndébélé du Sud
nde||nd|Ndebele, North; North Ndebele|ndébélé du Nord
ndo||ng|Ndonga|ndonga
nds|||Low German; Low Saxon; German, Low; Saxon, Low|bas allemand; bas saxon; allemand, bas; saxon, bas
nep||ne|Nepali|népalais
new|||Nepal Bhasa; Newari|nepal bhasa; newari
nia|||Nias|nias
nic|||Niger-Kordofanian (Other)|nigéro-congolaises, autres langues
niu|||Niuean|niué
nno||nn|Norwegian Nynorsk; Nynorsk, Norwegian|norvégien nynorsk; nynorsk, norvégien
nob||nb|Bokmål, Norwegian; Norwegian Bokmål|norvégien bokmål
nog|||Nogai|nogaï; nogay
non|||Norse, Old|norrois, vieux
nor||no|Norwegian|norvégien
nqo|||N''Ko|n''ko
nso|||Pedi; Sepedi; Northern Sotho|pedi; sepedi; sotho du Nord
nub|||Nubian languages|nubiennes, langues
nwc|||Classical Newari; Old Newari; Classical Nepal Bhasa|newari classique
nya||ny|Chichewa; Chewa; Nyanja|chichewa; chewa; nyanja
nym|||Nyamwezi|nyamwezi
nyn|||Nyankole|nyankolé
nyo|||Nyoro|nyoro
nzi|||Nzima|nzema
oci||oc|Occitan (post 1500); Provençal|occitan (après 1500); provençal
oji||oj|Ojibwa|ojibwa
ori||or|Oriya|oriya
orm||om|Oromo|galla
osa|||Osage|osage
oss||os|Ossetian; Ossetic|ossète
ota|||Turkish, Ottoman (1500-1928)|turc ottoman (1500-1928)
oto|||Otomian languages|otomangue, langues
paa|||Papuan (Other)|papoues, autres langues
pag|||Pangasinan|pangasinan
pal|||Pahlavi|pahlavi
pam|||Pampanga; Kapampangan|pampangan
pan||pa|Panjabi; Punjabi|pendjabi
pap|||Papiamento|papiamento
pau|||Palauan|palau
peo|||Persian, Old (ca.600-400 B.C.)|perse, vieux (ca. 600-400 av. J.-C.)
per|fas|fa|Persian|persan
phi|||Philippine (Other)|philippines, autres langues
phn|||Phoenician|phénicien
pli||pi|Pali|pali
pol||pl|Polish|polonais
pon|||Pohnpeian|pohnpei
por||pt|Portuguese|portugais
pra|||Prakrit languages|prâkrit
pro|||Provençal, Old (to 1500)|provençal ancien (jusqu''à 1500)
pus||ps|Pushto; Pashto|pachto
qaa-qtz|||Reserved for local use|réservée à l''usage local
que||qu|Quechua|quechua
raj|||Rajasthani|rajasthani
rap|||Rapanui|rapanui
rar|||Rarotongan; Cook Islands Maori|rarotonga; maori des îles Cook
roa|||Romance (Other)|romanes, autres langues
roh||rm|Romansh|romanche
rom|||Romany|tsigane
rum|ron|ro|Romanian|roumain
run||rn|Rundi|rundi
rup|||Aromanian; Arumanian; Macedo-Romanian|aroumain; macédo-roumain
rus||ru|Russian|russe
sad|||Sandawe|sandawe
sag||sg|Sango|sango
sah|||Yakut|iakoute
sai|||South American Indian (Other)|indiennes d''Amérique du Sud, autres langues
sal|||Salishan languages|salish, langues
sam|||Samaritan Aramaic|samaritain
san||sa|Sanskrit|sanskrit
sas|||Sasak|sasak
sat|||Santali|santal
scc|srp|sr|Serbian|serbe
scn|||Sicilian|sicilien
sco|||Scots|écossais
scr|hrv|hr|Croatian|croate
sel|||Selkup|selkoupe
sem|||Semitic (Other)|sémitiques, autres langues
sga|||Irish, Old (to 900)|irlandais ancien (jusqu''à 900)
sgn|||Sign Languages|langues des signes
shn|||Shan|chan
sid|||Sidamo|sidamo
sin||si|Sinhala; Sinhalese|singhalais
sio|||Siouan languages|sioux, langues
sit|||Sino-Tibetan (Other)|sino-tibétaines, autres langues
sla|||Slavic (Other)|slaves, autres langues
slo|slk|sk|Slovak|slovaque
slv||sl|Slovenian|slovène
sma|||Southern Sami|sami du Sud
sme||se|Northern Sami|sami du Nord
smi|||Sami languages (Other)|sami, autres langues
smj|||Lule Sami|sami de Lule
smn|||Inari Sami|sami d''Inari
smo||sm|Samoan|samoan
sms|||Skolt Sami|sami skolt
sna||sn|Shona|shona
snd||sd|Sindhi|sindhi
snk|||Soninke|soninké
sog|||Sogdian|sogdien
som||so|Somali|somali
son|||Songhai languages|songhai, langues
sot||st|Sotho, Southern|sotho du Sud
spa||es|Spanish; Castilian|espagnol; castillan
srd||sc|Sardinian|sarde
srn|||Sranan Tongo|sranan tongo
srr|||Serer|sérère
ssa|||Nilo-Saharan (Other)|nilo-sahariennes, autres langues
ssw||ss|Swati|swati
suk|||Sukuma|sukuma
sun||su|Sundanese|soundanais
sus|||Susu|soussou
sux|||Sumerian|sumérien
swa||sw|Swahili|swahili
swe||sv|Swedish|suédois
syc|||Classical Syriac|syriaque classique
syr|||Syriac|syriaque
tah||ty|Tahitian|tahitien
tai|||Tai (Other)|thaïes, autres langues
tam||ta|Tamil|tamoul
tat||tt|Tatar|tatar
tel||te|Telugu|télougou
tem|||Timne|temne
ter|||Tereno|tereno
tet|||Tetum|tetum
tgk||tg|Tajik|tadjik
tgl||tl|Tagalog|tagalog
tha||th|Thai|thaï
tib|bod|bo|Tibetan|tibétain
tig|||Tigre|tigré
tir||ti|Tigrinya|tigrigna
tiv|||Tiv|tiv
tkl|||Tokelau|tokelau
tlh|||Klingon; tlhIngan-Hol|klingon
tli|||Tlingit|tlingit
tmh|||Tamashek|tamacheq
tog|||Tonga (Nyasa)|tonga (Nyasa)
ton||to|Tonga (Tonga Islands)|tongan (Îles Tonga)
tpi|||Tok Pisin|tok pisin
tsi|||Tsimshian|tsimshian
tsn||tn|Tswana|tswana
tso||ts|Tsonga|tsonga
tuk||tk|Turkmen|turkmène
tum|||Tumbuka|tumbuka
tup|||Tupi languages|tupi, langues
tur||tr|Turkish|turc
tut|||Altaic (Other)|altaïques, autres langues
tvl|||Tuvalu|tuvalu
twi||tw|Twi|twi
tyv|||Tuvinian|touva
udm|||Udmurt|oudmourte
uga|||Ugaritic|ougaritique
uig||ug|Uighur; Uyghur|ouïgour
ukr||uk|Ukrainian|ukrainien
umb|||Umbundu|umbundu
und|||Undetermined|indéterminée
urd||ur|Urdu|ourdou
uzb||uz|Uzbek|ouszbek
vai|||Vai|vaï
ven||ve|Venda|venda
vie||vi|Vietnamese|vietnamien
vol||vo|Volapük|volapük
vot|||Votic|vote
wak|||Wakashan languages|wakashennes, langues
wal|||Walamo|walamo
war|||Waray|waray
was|||Washo|washo
wel|cym|cy|Welsh|gallois
wen|||Sorbian languages|sorabes, langues
wln||wa|Walloon|wallon
wol||wo|Wolof|wolof
xal|||Kalmyk; Oirat|kalmouk; oïrat
xho||xh|Xhosa|xhosa
yao|||Yao|yao
yap|||Yapese|yapois
yid||yi|Yiddish|yiddish
yor||yo|Yoruba|yoruba
ypk|||Yupik languages|yupik, langues
zap|||Zapotec|zapotèque
zbl|||Blissymbols; Blissymbolics; Bliss|symboles Bliss; Bliss
zen|||Zenaga|zenaga
zha||za|Zhuang; Chuang|zhuang; chuang
znd|||Zande languages|zandé, langues
zul||zu|Zulu|zoulou
zun|||Zuni|zuni
zxx|||No linguistic content|pas de contenu linguistique
zza|||Zaza; Dimili; Dimli; Kirdki; Kirmanjki; Zazaki|zaza; dimili; dimli; kirdki; kirmanjki; zazaki'
    ]

    WALocale class >> parseCountryString [
	<category: 'class initialization'>
	| string lines |
	iso2Countries := Dictionary new.
	string := self countryList.
	lines := string lines.
	lines allButFirst collect: 
		[:each | 
		| parts |
		parts := each findTokens: $;.
		parts size >= 2 ifTrue: [iso2Countries at: parts second put: parts first]]
    ]

    WALocale class >> parseLanguageString [
	<category: 'class initialization'>
	| string lines |
	iso2Languages := Dictionary new.
	iso3Languages := Dictionary new.
	string := self languageList.
	lines := string lines.
	lines do: 
		[:each | 
		| threeCode twoCode language firstIndex secondIndex thirdIndex fourthIndex |
		firstIndex := each indexOf: $|.
		secondIndex := each indexOf: $| startingAt: firstIndex + 1.
		thirdIndex := each indexOf: $| startingAt: secondIndex + 1.
		fourthIndex := each indexOf: $| startingAt: thirdIndex + 1.
		threeCode := each copyFrom: 1 to: firstIndex - 1.
		twoCode := each copyFrom: secondIndex + 1 to: thirdIndex - 1.
		language := each copyFrom: thirdIndex + 1 to: fourthIndex - 1.
		iso3Languages at: threeCode put: language.
		twoCode isEmpty ifFalse: [iso2Languages at: twoCode put: language]]
    ]

    country [
	<category: 'accessing'>
	^country
    ]

    country: aString [
	<category: 'accessing'>
	country := aString
    ]

    countryName [
	<category: 'accessing'>
	^self class iso2Countries at: self country
    ]

    language [
	<category: 'accessing'>
	^language
    ]

    language: aString [
	<category: 'accessing'>
	language := aString
    ]

    languageName [
	<category: 'accessing'>
	^self language size = 2 
	    ifTrue: [self class iso2Languages at: self language]
	    ifFalse: [self class iso3Languages at: self language]
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPut: $(;
	    nextPutAll: self seasideString;
	    nextPut: $)
    ]

    seasideString [
	<category: 'converting'>
	^String streamContents: 
		[:stream | 
		stream nextPutAll: self language.
		self country isNil 
		    ifFalse: 
			[stream
			    nextPut: $-;
			    nextPutAll: self country]]
    ]
]



Object subclass: WAMain [
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: 'WAMain subclasses are used to initialize applications when a new session is started.

Subclasses must implement the following messages:
	start:
		Does the initializing 
'>

    application [
	"Answer the application to which this entry point is associated."

	<category: 'accessing'>
	^self session application
    ]

    session [
	"Answer the session to which this entry point is associated."

	<category: 'accessing'>
	^WACurrentSession value
    ]

    start: aRequest [
	"The main entry point into a session."

	<category: 'processing'>
	self subclassResponsibility
    ]
]



WAMain subclass: WARenderLoopMain [
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: 'When a new session on a WAApplication is started WARenderLoopMain initializes the application, that is it:
 
	creates the top level component of the application, 
	informs each component(WAPresenter) of the application that the session started (via WAPresenter>>initialRequest:)
	starts a WARenderLoop to handle the request
'>

    call: aComponent [
	<category: 'processing'>
	^self renderLoopClass new call: aComponent
    ]

    createRoot [
	<category: 'creational'>
	^self rootClass new
    ]

    renderLoopClass [
	<category: 'accessing'>
	^WARenderLoop
    ]

    rootClass [
	<category: 'accessing'>
	^self application preferenceAt: #rootComponent
    ]

    start: aRequest [
	<category: 'processing'>
	| root |
	root := self createRoot.
	root visiblePresentersDo: [:each | each initialRequest: aRequest].
	(self renderLoopClass new root: root) run
    ]
]



WARenderLoopMain subclass: WAAuthMain [
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    createRoot [
	<category: 'creational'>
	^(super createRoot)
	    addDecoration: (WABasicAuthentication new authenticator: self);
	    yourself
    ]

    verifyPassword: password forUser: username [
	<category: 'testing'>
	^self application login = username 
	    and: [self application password = password]
    ]
]



Object subclass: WAMimeType [
    | main sub parameters |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: 'A WAMimeType abstracts a Internet media type, it is a two-part identifier for file formats on the Internet.

Instance Variables
	main:		<String>
	parameters:		<WASmallDictionary>
	sub:		<String>

main
	- the main type

parameters
	- a lazily initialized dictionary of optional parameters

sub
	- the subtype
'>

    WAMimeType class >> fromString: aString [
	<category: 'instance creation'>
	| main endOfSub sub parts parameters |
	main := aString copyUpTo: $/.
	endOfSub := aString indexOf: $;.
	endOfSub := endOfSub = 0 ifTrue: [aString size] ifFalse: [endOfSub - 1].
	sub := aString copyFrom: main size + 2 to: endOfSub.
	endOfSub = aString size ifTrue: [^self main: main sub: sub].
	parts := (aString copyFrom: endOfSub + 1 to: aString size) findTokens: ';'.
	parameters := WASmallDictionary new.
	parts do: 
		[:each | 
		parameters at: (each copyUpTo: $=) trimSeparators
		    put: (each copyAfter: $=) trimSeparators].
	^self 
	    main: main
	    sub: sub
	    parameters: parameters
    ]

    WAMimeType class >> main: aMainString sub: aSubString [
	<category: 'instance creation'>
	^(self new)
	    main: aMainString;
	    sub: aSubString;
	    yourself
    ]

    WAMimeType class >> main: aMainString sub: aSubString parameters: aDictionary [
	<category: 'instance creation'>
	^(self main: aMainString sub: aSubString)
	    parameters: aDictionary;
	    yourself
    ]

    = other [
	<category: 'comparing'>
	^(other isKindOf: WAMimeType) 
	    and: [self main = other main and: [self sub = other sub]]
    ]

    charset: aString [
	<category: 'parameters'>
	self parameters at: 'charset' put: aString
    ]

    hash [
	<category: 'comparing'>
	^self main hash bitXor: self sub hash
    ]

    isBinary [
	<category: 'testing'>
	| subTypes |
	self main = 'text' ifTrue: [^false].
	self main = 'application' ifFalse: [^true].
	subTypes := self sub findTokens: '+'.
	^subTypes noneSatisfy: [:each | #('x-javascript' 'xml') includes: each]
    ]

    isNonStandard [
	"tests if the receiver is a non-standard mime type that is not registered with IANA"

	<category: 'testing'>
	^(self main startsWith: 'x-') or: 
		[(self main startsWith: 'X-') 
		    or: [(self sub startsWith: 'x-') or: [self sub startsWith: 'X-']]]
    ]

    isVendorSpecific [
	"tests if the receiver is a vendor specific mimetype"

	<category: 'testing'>
	^self sub startsWith: 'vnd.'
    ]

    main [
	<category: 'accessing'>
	^main
    ]

    main: aString [
	<category: 'accessing'>
	main := aString
    ]

    matches: aMimeType [
	"aMimeType is the pattern to match, it is a normal WAMimeType instance where main or sub can be wildcards"

	<category: 'testing'>
	^(aMimeType main = '*' or: [aMimeType main = self main]) 
	    and: [aMimeType sub = '*' or: [aMimeType sub = self sub]]
    ]

    parameterAt: aKey put: aValue [
	<category: 'parameters'>
	self parameters at: aKey put: aValue
    ]

    parameters [
	<category: 'accessing'>
	parameters isNil ifTrue: [parameters := WASmallDictionary new].
	^parameters
    ]

    parameters: aDictionary [
	<category: 'accessing'>
	parameters := aDictionary
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPut: $(;
	    nextPutAll: self seasideString;
	    nextPut: $)
    ]

    sub [
	<category: 'accessing'>
	^sub
    ]

    sub: aString [
	<category: 'accessing'>
	sub := aString
    ]

    toMimeType [
	<category: 'converting'>
	^self
    ]

    seasideString [
	<category: 'converting'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: self main;
		    nextPut: $/;
		    nextPutAll: self sub.
		parameters isNil 
		    ifFalse: 
			[parameters keysAndValuesDo: 
				[:key :value | 
				stream
				    nextPut: $;;
				    nextPutAll: key;
				    nextPut: $=;
				    nextPutAll: value]]]
    ]
]



Object subclass: WAOpeningConditionalComment [
    | condition |
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'Opens a WAConditionalComment and encodes the condition.'>

    WAOpeningConditionalComment class >> condition: aString [
	<category: 'instance creation'>
	^(self new)
	    condition: aString;
	    yourself
    ]

    condition [
	<category: 'accessing'>
	^condition
    ]

    condition: aString [
	<category: 'accessing'>
	condition := aString
    ]

    encodeOn: aDocument [
	<category: 'printing'>
	aDocument
	    nextPutAll: '<!--[';
	    nextPutAll: self condition;
	    nextPutAll: ']>'
    ]
]



WAOpeningConditionalComment subclass: WAOpeningRevealedConditionalComment [
    
    <category: 'Seaside-Core-Document-Elements'>
    <comment: 'Opens a WARevealedConditionalComment and encodes the condition.'>

    encodeOn: aDocument [
	<category: 'printing'>
	aDocument
	    nextPutAll: '<!--[';
	    nextPutAll: self condition;
	    nextPutAll: ']><!-->'
    ]
]



Object subclass: WAPresenter [
    
    <category: 'Seaside-Core-Component'>
    <comment: nil>

    WAPresenter class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    application [
	<category: 'convenience'>
	^self session application
    ]

    fieldsAt: key [
	"Returns the string value associated to the key in the argument given to your webapplication. The argument can have been sent by a form or written at the end of the url (using ...?key=value construction). If key is not found, an error is sent."

	<category: 'convenience'>
	^self session fieldsAt: key
    ]

    fieldsAt: key ifAbsent: aBlock [
	"Returns the string value associated to the key in the argument given to your webapplication. The argument can have been sent by a form or written at the end of the url (using ...?key=value construction). If key is not found, aBlock is evaluated."

	<category: 'convenience'>
	^self session fieldsAt: key ifAbsent: aBlock
    ]

    fieldsAt: key ifPresent: aBlock [
	"Returns the string value associated to the key in the argument given to your webapplication. The argument can have been sent by a form or written at the end of the url (using ...?key=value construction). If the key is present, execute the block and give it the value as a parameter. Otherwise, answer nil."

	<category: 'convenience'>
	^self session fieldsAt: key ifPresent: aBlock
    ]

    handleAnswer: anObject [
	<category: 'call/answer'>
	self subclassResponsibility
    ]

    initialRequest: aRequest [
	"When a new session is started, all visible presenters (components or tasks) receive this message with the request as argument.
	 
	 A common usage for this is to initialize their state depending on the URL of the request. This is one building block for bookmarkable URL. The other is updateUrl: where you can manipulate the anchor urls generated by Seaside.
	 
	 You can not use #call: in here. Consider using a WATask instead and sending #call: in #go.
	 
	 See WABrowser for examples."

	<category: 'request processing'>
	
    ]

    initialize [
	<category: 'initialization'>
	
    ]

    isDecoration [
	<category: 'decoration'>
	^false
    ]

    nextPresentersDo: aBlock [
	<category: 'tree'>
	self subclassResponsibility
    ]

    preferenceAt: aSymbol [
	<category: 'convenience'>
	^self application preferenceAt: aSymbol
    ]

    preferenceAt: aSymbol put: anObject [
	<category: 'convenience'>
	^self application preferenceAt: aSymbol put: anObject
    ]

    processCallbackStream: aCallbackStream [
	<category: 'request processing'>
	aCallbackStream processCallbacksWithOwner: self.
	self processChildCallbacks: aCallbackStream.
	aCallbackStream processCallbacksWithOwner: self
    ]

    processChildCallbacks: aStream [
	<category: 'request processing'>
	self nextPresentersDo: [:ea | ea processCallbackStream: aStream]
    ]

    registerForBacktracking [
	<category: 'deprecated'>
	self 
	    deprecatedApi: '#registerForBacktracking is not supported, implement #states to backtrack your object'
    ]

    renderContentOn: aRenderer [
	<category: 'rendering'>
	self nextPresentersDo: [:ea | ea renderWithContext: aRenderer context]
    ]

    renderWithContext: aRenderingContext [
	<category: 'rendering'>
	| html callbacks |
	callbacks := aRenderingContext callbacksFor: self.
	html := self rendererClass context: aRenderingContext callbacks: callbacks.
	(self showHalo and: [aRenderingContext isDebugMode]) 
	    ifTrue: [(WAHalo for: self) renderContentOn: html]
	    ifFalse: [self renderContentOn: html].
	html flush
    ]

    rendererClass [
	"Override this method if you want a custom renderer."

	<category: 'rendering'>
	^WARenderCanvas
    ]

    script [
	"The same as #style except that it is for JavaScript. This is rarely used, consider using WAFileLibrary or exernal files instead."

	<category: 'rendering'>
	^nil
    ]

    session [
	<category: 'convenience'>
	^WACurrentSession value
    ]

    showHalo [
	<category: 'rendering'>
	^true
    ]

    states [
	"Answer a collection of states that should be backtracked."

	<category: 'accessing'>
	^#()
    ]

    style [
	"Returns a CSS stylesheet associated with this component. This stylesheet will be added to <head> section of the html document so it will be global and not scoped.
	 
	 This is done for all visible components (see class comment of WAComponent for what visible means).
	 
	 Nice for demos but consider using WAFileLibrary or exernal files instead."

	<category: 'rendering'>
	^nil
    ]

    updateRoot: anHtmlRoot [
	"This method allows you customize the <head> section of an HTML document. The API is very similar to the 'Canvas API' for rendering in the <body> section (where you 'draw' in #renderContentOn:).
	 
	 anHtmlRoot is an instance of WAHtmlRoot
	 
	 Whenever you override this method don't forget to send super"

	<category: 'updating'>
	self script isNil ifFalse: [anHtmlRoot addScript: self script].
	self style isNil ifFalse: [anHtmlRoot addStyle: self style]
    ]

    updateStates: aSnapshot [
	"This method allows to register objects for backtracking. Don't forget to send super in all cases."

	<category: 'updating'>
	self states do: [:each | aSnapshot register: each]
    ]

    updateUrl: aUrl [
	<category: 'updating'>
	
    ]

    withNextPresentersDo: aBlock [
	<category: 'tree'>
	aBlock value: self.
	self nextPresentersDo: [:ea | ea withNextPresentersDo: aBlock]
    ]
]



WAPresenter subclass: WAComponent [
    | decoration |
    
    <category: 'Seaside-Core-Component'>
    <comment: 'I am a class representing a graphical element of a seaside application. A component has state (instance variables, that might be backtracked using #states), behavior decorations, children and an appearance that is specified in #renderContentOn:. A component might chose to display another component with #call:.

Child Components:
It is common for a component to display instances of other components while rendering itself.  It does this by passing them into the #render: method of WACanvas.  For example, this #renderContentOn: method simply renders a heading and then displays a counter component 
immediately below it:

	renderContentOn: html
		html heading level3; with: ''My Counter''.
		html render: myCounter.

It''s important that you use #render:, rather than directly calling the #renderContentOn: method of the subcomponent. The following is *not* correct:

	renderContentOn: html
		html heading level3; with: ''My Counter''.
		myCounter renderContentOn: html.   "DON''T DO THIS".

These subcomponents are usually instance variables of the component that is "embedding" them.  They are commonly created as part of the components #initialize method:

	initialize
		myCounter := WACounter new.

They may also be stored in a collection. One fairly common pattern is to keep a lazily initialized dictionary of subcomponents that match a collection of model items. For example, if you wanted a BudgetItemRow subcomponent for each member of budgetItems, you might do something like this:

	initialize
		budgetRows := Dictionary new.

	rowForItem: anItem
		^budgetRows at: anItem ifAbsentPut: [ BudgetItemRow item: anItem ].

	renderContentOn: html
		self budgetItems
			do: [ :each | html render: (self rowForItem: each) ]
			separatedBy: [ html horizontalLine ].

Each parent component *must* implement a #children method that returns a collection of all of the subcomponents that it might display on the next render. For the above two examples, #children might look like this:

	children
		^Array with: myCounter

or this:

	children
		^self budgetItems collect: [ :each | self rowForItem: each ].
		
Call/Answer:
If a subcomponent makes a #call: to another component, that component will appear in place of the subcomponent.  In the first example, if myCounter made a #call: to DateSelector, that DateSelector would appear in the context of the counter''s parent, with the ''My Counter'' heading 
above it.

Since a subcomponent has not been #call:''d, in general #answer: is a no-op.  However, the parent may attach an #onAnswer: block to the subcomponent to be notified if it sends #answer:. This allows one component to be used both from #call: and through embedding. For example:

	initialize
		dateSelector := WADateSelector new 
			onAnswer: [ :date | self dateChosen: date ].
			
Visibility:
A component is visible if
- it is the root component of an application
- a child of of a visible component (returned by #children) that has not been #call:''d
- passed as an argument to #call: on a visible component'>

    WAComponent class >> canBeRoot [
	"When returning true, the component can be registered as a standalone application from the config interface."

	<category: 'testing'>
	^false
    ]

    WAComponent class >> description [
	<category: 'accessing'>
	^self name
    ]

    WAComponent class >> headerForExampleBrowser [
	<category: 'accessing'>
	^self name = self description 
	    ifTrue: [self name]
	    ifFalse: [self description , ' (' , self name , ')']
    ]

    WAComponent class >> registerAsApplication: aString [
	"Use this to programatically register a component as an appliction."

	<category: 'registration'>
	| application |
	application := WAApplication register: aString.
	application preferenceAt: #rootComponent put: self.
	^application
    ]

    WAComponent class >> registerAsAuthenticatedApplication: aString [
	"Like #registerAsApplication: but addtionally adds password protection. You will be prompted for a susername and password."

	<category: 'registration'>
	| application user password |
	application := self registerAsApplication: aString.
	application configuration addAncestor: WAAuthConfiguration new.
	user := SeasidePlatformSupport 
		    request: 'Please choose a username for\the application ' withCRs 
			    , aString printString.
	password := SeasidePlatformSupport 
		    request: 'Please enter a password for ' , aString printString.
	application preferenceAt: #login put: user.
	application preferenceAt: #password put: password.
	^application
    ]

    activeComponent [
	<category: 'convenience'>
	self visiblePresentersDo: [:ea | ea isDecoration ifFalse: [^ea]]
    ]

    addDecoration: newDecoration [
	<category: 'decorations'>
	| prev dec |
	prev := nil.
	dec := self decoration.
	[dec ~~ self and: [self decoration: dec shouldWrap: newDecoration]] 
	    whileTrue: 
		[prev := dec.
		dec := dec owner].
	newDecoration owner: dec.
	prev ifNil: [self decoration: newDecoration]
	    ifNotNil: [:foo | prev owner: newDecoration].
	^newDecoration
    ]

    addMessage: aString [
	"adds a decoration that renders a level 3 heading with <aString> around the receiver
	 returns this decoration so don't forget #yourself"

	<category: 'convenience'>
	^self addDecoration: (WAMessageDecoration new message: aString)
    ]

    allDecorationsDo: aBlock [
	<category: 'iterating'>
	| ea |
	ea := self decoration.
	[ea notNil and: [ea ~~ self]] whileTrue: 
		[aBlock value: ea.
		ea := ea owner]
    ]

    answer [
	<category: 'call/answer'>
	self answer: self
    ]

    answer: anObject [
	"Give back control to the component from which the receiver was called from. When returning, a component can additionally return anObject to the caller."

	<category: 'call/answer'>
	self decorationChainDo: [:each | each handleAnswer: anObject]
    ]

    asComponent [
	<category: 'convenience'>
	^self
    ]

    authenticateWith: anAuthenticator during: aBlock [
	<category: 'decorations'>
	^self 
	    decorateWith: (WABasicAuthentication new authenticator: anAuthenticator)
	    during: aBlock
    ]

    call: aComponent [
	"Pass control from the receiver to aComponent. The receiver will be temporarily replaced with aComponent. Code can return from here later on by sending #answer: to aComponent."

	<category: 'call/answer'>
	^AnswerContinuation currentDo: 
		[:cc | 
		self show: aComponent onAnswer: cc.
		WARenderNotification signal]
    ]

    children [
	"This method is really important. It should return a collection of all subcomponents of the current component that will be rendered in #renderContentOn:. Components that are displayed using #call: are *not* children.
	 
	 If the contents returned by this method change over time make sure to return them in #states as well, otherwise the back button will fail."

	<category: 'accessing'>
	^#()
    ]

    childrenDo: aBlock [
	<category: 'iterating'>
	self children do: [:ea | ea ifNotNil: [:foo | aBlock value: ea]]
    ]

    chooseFrom: aCollection [
	"Choose an item from the given aCollection. Answer the selected item."

	<category: 'convenience'>
	^self chooseFrom: aCollection caption: ''
    ]

    chooseFrom: aCollection caption: aString [
	"Choose an item from the given aCollection with caption aString. Answer the selected item."

	<category: 'convenience'>
	^self call: ((WAChoiceDialog new options: aCollection)
		    addMessage: aString;
		    yourself)
    ]

    confirm: aString [
	"Display a yes/no dialog with caption queryString. Answer true if the
	 response is yes, false if no. This is a modal question -- the user must
	 respond yes or no."

	<category: 'convenience'>
	^self call: ((WAYesOrNoDialog new)
		    addMessage: aString;
		    yourself)
    ]

    decorateWith: aDecoration during: aBlock [
	<category: 'decorations'>
	| val |
	self addDecoration: aDecoration.
	val := aBlock value.
	self removeDecoration: aDecoration.
	^val
    ]

    decoration [
	<category: 'accessing'>
	^decoration contents
    ]

    decoration: aDecoration [
	<category: 'accessing'>
	decoration contents: aDecoration
    ]

    decoration: oldDecoration shouldWrap: newDecoration [
	<category: 'decorations'>
	^(oldDecoration isGlobal and: [newDecoration isGlobal not]) 
	    or: [oldDecoration isDelegation and: [newDecoration isLocal]]
    ]

    decorationChainDo: aBlock [
	<category: 'decorations'>
	aBlock value: self decoration
    ]

    delegations [
	<category: 'accessing'>
	| delegations |
	delegations := OrderedCollection new.
	self 
	    allDecorationsDo: [:ea | ea isDelegation ifTrue: [delegations add: ea]].
	^delegations
    ]

    handleAnswer: anObject [
	<category: 'call/answer'>
	^false
    ]

    home [
	<category: 'accessing'>
	self delegations do: [:ea | self removeDecoration: ea]
    ]

    inform: aString [
	"Display a dialog with aString to the user until he clicks 'OK'"

	<category: 'convenience'>
	self call: ((WAFormDialog new)
		    addMessage: aString;
		    yourself)
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self initializeDecoration
    ]

    initializeDecoration [
	<category: 'initialize-release'>
	decoration := WAValueHolder with: self
    ]

    isolate: aBlock [
	<category: 'convenience'>
	| txn val |
	txn := WATransaction new.
	val := self decorateWith: txn during: aBlock.
	txn close.
	^val
    ]

    nextPresentersDo: aBlock [
	<category: 'iterating'>
	self childrenDo: [:ea | ea decorationChainDo: aBlock]
    ]

    onAnswer: aBlock [
	"Adds an answer handler aBlock to the receiver."

	<category: 'call/answer'>
	^self addDecoration: (WAAnswerHandler new block: aBlock)
    ]

    removeDecoration: aDecoration [
	<category: 'decorations'>
	| dec |
	dec := self decoration.
	dec = aDecoration 
	    ifTrue: 
		[self decoration: dec owner.
		^self].
	[dec notNil] whileTrue: 
		[dec owner = aDecoration 
		    ifTrue: 
			[dec owner: aDecoration owner.
			^self]
		    ifFalse: [dec := dec owner]]
    ]

    renderOn: aRenderer [
	"Do not override this methods on your component, override instead #renderContentOn: and in addition to not invoke directly renderContentOn: on subcomponent in such method but use instead html render: subcomponent."

	<category: 'rendering'>
	self 
	    decorationChainDo: [:each | each renderWithContext: aRenderer context]
    ]

    request: aString [
	"Display an input dialog whose question is queryString and answer the string the user accepts."

	<category: 'convenience'>
	^self request: aString default: ''
    ]

    request: aString default: initialString [
	<category: 'convenience'>
	^self 
	    request: aString
	    label: nil
	    default: initialString
    ]

    request: requestString label: labelString [
	<category: 'convenience'>
	^self 
	    request: requestString
	    label: labelString
	    default: ''
    ]

    request: requestString label: labelString default: initialString [
	<category: 'convenience'>
	^self call: ((WAInputDialog new)
		    label: labelString;
		    default: initialString;
		    addMessage: requestString;
		    yourself)
    ]

    show: aComponent [
	"Pass control from the receiver to aComponent. The receiver will be temporarily replaced with aComponent. As opposed to #call: sending this message does not block and immediately returns."

	<category: 'call/answer'>
	self show: aComponent onAnswer: [:value | ]
    ]

    show: aComponent onAnswer: aBlock [
	"Pass control from the receiver to aComponent. The receiver will be temporarily replaced with aComponent. When #answer: is sent to aComponent, aBlock is evaluated. This can be used for continuation passing style programmation of a control flow. #show:onAnswer: does not block."

	<category: 'call/answer'>
	self 
	    show: aComponent
	    onAnswer: aBlock
	    delegation: ((WADelegation new)
		    delegate: aComponent;
		    yourself)
    ]

    show: aComponent onAnswer: aBlock delegation: aDelegation [
	<category: 'call/answer'>
	| event |
	event := nil.
	event := aComponent onAnswer: 
			[:value | 
			aDelegation remove.
			event remove.
			aBlock value: value].
	self addDecoration: aDelegation
    ]

    updateStates: aSnapshot [
	<category: 'updating'>
	super updateStates: aSnapshot.
	aSnapshot register: decoration
    ]

    validateWith: aBlock [
	<category: 'convenience'>
	^self addDecoration: (WAValidationDecoration new validateWith: aBlock)
    ]

    visiblePresentersDo: aBlock [
	<category: 'iterating'>
	self decorationChainDo: [:ea | ea withNextPresentersDo: aBlock]
    ]
]



WAComponent subclass: WAAlphabeticBatchedList [
    | items currentPage |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WAAlphabeticBatchedList organizes a collection of items into pages for display. A page contains all items whose string representation (item displayString) starts with the same character. WAAlphabeticBatchedList only displays the navigation (alphabet with links) for the list. Your code needs to display the current page.

Use WAAlphabeticBatchedList>>items: to set the collections of items.
Use WAAlphabeticBatchedList>>batch to get the items to display on the current page

See WABatchTest for example of usage.
Select "Batch" tab of the Functional Seaside Test Suite to run an example  (http://127.0.0.1:xxxx/seaside/tests/alltests)

Instance Variables:
	currentPage	<Character>	the character of the curent page
	items	<(Collection of: (Object ))> collection of the items managed by WAAlphabeticBatchedList. Collection is sorted before items are displayed.
'>

    allPages [
	<category: 'accessing-calculated'>
	^$A to: $Z
    ]

    batch [
	<category: 'accessing-calculated'>
	^items 
	    select: [:each | each seasideString asUppercase first = self currentPage]
    ]

    currentPage [
	<category: 'accessing'>
	^currentPage ifNil: [currentPage := self validPages first]
    ]

    currentPage: aCharacter [
	<category: 'accessing'>
	currentPage := aCharacter
    ]

    isOnFirstPage [
	<category: 'testing'>
	^self validPages first = self currentPage
    ]

    isOnLastPage [
	<category: 'testing'>
	^self validPages last = self currentPage
    ]

    items [
	<category: 'accessing'>
	^items
    ]

    items: aCollection [
	<category: 'accessing'>
	items := aCollection
    ]

    nextPage [
	<category: 'actions'>
	self isOnLastPage 
	    ifFalse: [currentPage := self validPages after: currentPage]
    ]

    previousPage [
	<category: 'actions'>
	self isOnFirstPage 
	    ifFalse: [currentPage := self validPages before: currentPage]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	items isEmpty 
	    ifFalse: 
		[(html div)
		    id: 'batch';
		    with: 
			    [self renderPreviousOn: html.
			    self renderPagesOn: html.
			    self renderNextOn: html]]
    ]

    renderNextOn: html [
	<category: 'rendering'>
	html space.
	self isOnLastPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self nextPage];
		    with: '>>']
	    ifTrue: [html text: '>>']
    ]

    renderPagesOn: html [
	<category: 'rendering'>
	self allPages do: 
		[:char | 
		currentPage = char 
		    ifFalse: 
			[(self validPages includes: char) 
			    ifTrue: 
				[(html anchor)
				    callback: [self currentPage: char];
				    with: char]
			    ifFalse: [html text: char]]
		    ifTrue: [html strong: char]]
	    separatedBy: [html space]
    ]

    renderPreviousOn: html [
	<category: 'rendering'>
	self isOnFirstPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self previousPage];
		    with: '<<']
	    ifTrue: [html text: '<<'].
	html space
    ]

    states [
	<category: 'accessing'>
	^Array with: self
    ]

    validPages [
	<category: 'accessing-calculated'>
	^(items collect: [:each | each seasideString asUppercase first]) asSet 
	    asSortedCollection
    ]
]



WAComponent subclass: WABatchSelection [
    | batcher linkSelector textSelector |
    
    <category: 'Seaside-Core-Components-Dialogs'>
    <comment: 'WABatchSelection displays a list of objects. The list is show N (currently 8) items per page, with links to navigate to other pages if needed. Objects in the list must implement one method that returns text description of the item and one method that returns a name or label used as the link users click to select the item. The text description is displayed below the link.

Example
	items := OrderedCollection new.
	1 to: 20 do: [:each | items add: (Contact new name: each; phoneNumber: ''54321'';yourself)].
	selection := WABatchSelection items: items link: #name text: #phoneNumber.
	result := self call: selection.

	where the Contact class has methodsinstance vars "phoneNumber" and "name", with
	setter & getter methods.

Instance Variables:
	batcher	<WABatchedList>	description of batcher
	linkSelector	<Symbol>	method sent to items in list for link text
	textSelector	<Symbol>	method sent to items in list for text description

'>

    WABatchSelection class >> items: aCollection link: linkSelector text: textSelector [
	<category: 'instance-creation'>
	^(self new)
	    items: aCollection;
	    linkSelector: linkSelector;
	    textSelector: textSelector;
	    yourself
    ]

    batchSize [
	<category: 'accessing'>
	^batcher batchSize
    ]

    batchSize: aSize [
	<category: 'accessing'>
	batcher batchSize: aSize
    ]

    children [
	<category: 'accessing'>
	^Array with: batcher
    ]

    choose: anItem [
	<category: 'commands'>
	self answer: anItem
    ]

    items: aCollection [
	<category: 'accessing'>
	batcher := (WABatchedList new)
		    items: aCollection;
		    batchSize: 8;
		    yourself
    ]

    linkSelector: aSymbol [
	<category: 'accessing'>
	linkSelector := aSymbol
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html unorderedList: 
		[batcher batch do: 
			[:each | 
			(html anchor)
			    callback: [self choose: each];
			    with: (each perform: linkSelector).
			html break.
			html text: (each perform: textSelector).
			html paragraph]].
	(html div)
	    style: 'text-align: center';
	    with: batcher
    ]

    textSelector: aSymbol [
	<category: 'accessing'>
	textSelector := aSymbol
    ]
]



WAComponent subclass: WABatchedList [
    | items batchSize currentPage |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WABatchedList helps display a collection of items across multiple pages. WABatchedList organizes a collection into pages (or batches) of batchSize items each and renders navigation links for a user to moved between pages. WABatchedList>>batch returns the items to display in the current page or batch. Your code has to display the items.

See WABatchSelection for example of usage.

Instance Variables:
	batchSize	<Integer>	number of items to display on a single page
	currentPage	<Integer>	 index of current page, starts a 1
	items	<SequenceableCollection of Objects>	objects organized into pages for display

'>

    WABatchedList class >> example [
	<category: 'accessing'>
	^(self new)
	    items: (1 to: 100);
	    yourself
    ]

    batch [
	<category: 'accessing-calculated'>
	^self items copyFrom: self startIndex to: self endIndex
    ]

    batchSize [
	<category: 'accessing'>
	^batchSize
    ]

    batchSize: aNumber [
	<category: 'accessing'>
	batchSize := aNumber
    ]

    currentPage [
	<category: 'accessing'>
	^currentPage
    ]

    currentPage: aNumber [
	<category: 'accessing'>
	currentPage := aNumber
    ]

    endIndex [
	<category: 'accessing-calculated'>
	^self currentPage * self batchSize min: self items size
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self batchSize: 10.
	self currentPage: 1
    ]

    isOnFirstPage [
	<category: 'testing'>
	^self currentPage = 1
    ]

    isOnLastPage [
	<category: 'testing'>
	^self currentPage = self maxPages
    ]

    items [
	<category: 'accessing'>
	^items
    ]

    items: aCollection [
	<category: 'accessing'>
	items := aCollection
    ]

    maxPages [
	<category: 'accessing-calculated'>
	^(self items size / self batchSize) ceiling
    ]

    nextPage [
	<category: 'actions'>
	self isOnLastPage ifFalse: [self currentPage: self currentPage + 1]
    ]

    pageRange [
	<category: 'accessing-calculated'>
	^self pageRangeStart to: self pageRangeEnd
    ]

    pageRangeEnd [
	<category: 'accessing-calculated'>
	^self maxPages min: self currentPage + 9
    ]

    pageRangeStart [
	<category: 'accessing-calculated'>
	^1 max: self currentPage - 9
    ]

    previousPage [
	<category: 'actions'>
	self isOnFirstPage ifFalse: [self currentPage: self currentPage - 1]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self maxPages > 0 
	    ifTrue: 
		[(html div)
		    id: 'batch';
		    with: 
			    [self renderPreviousOn: html.
			    self renderPagesOn: html.
			    self renderNextOn: html]]
    ]

    renderNextOn: html [
	<category: 'rendering'>
	html space.
	self isOnLastPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self nextPage];
		    with: '>>']
	    ifTrue: [html text: '>>']
    ]

    renderPagesOn: html [
	<category: 'rendering'>
	self pageRange do: 
		[:index | 
		self currentPage = index 
		    ifFalse: 
			[(html anchor)
			    callback: [self currentPage: index];
			    with: index]
		    ifTrue: [html strong: index]]
	    separatedBy: [html space]
    ]

    renderPreviousOn: html [
	<category: 'rendering'>
	self isOnFirstPage 
	    ifFalse: 
		[(html anchor)
		    callback: [self previousPage];
		    with: '<<']
	    ifTrue: [html text: '<<'].
	html space
    ]

    startIndex [
	<category: 'accessing-calculated'>
	^(self currentPage - 1) * self batchSize + 1
    ]

    states [
	<category: 'accessing'>
	^Array with: self
    ]
]



WAComponent subclass: WADateSelector [
    | day month year startYear endYear |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WADateSelector displays dropdown menus (html select) allowing a user to delect a date within a range. "startYear" and "endYear" define the range of selectable dates. Date displayed in month, day, year format. WADateSelector>>date returns date user selected as a Date object.

See WADateSelectorTest for sample of usage.
Select "Date Selector" tab of the Functional Seaside Test Suite to run an example  (http://127.0.0.1:xxxx/seaside/tests/alltests)

Instance Variables:
	day	<Integer 1-31> selected day
	endYear	<Integer>	end of range of dates user is allowed to select, not required to use 4 digits
	month	<Integer 1-12>	selected month
	startYear	<Integer>	 start of range of dates user is allowed to select, not required to use 4 digits
	year	<Integer>	selected year

'>

    date [
	<category: 'accessing'>
	(self 
	    privateIsValidDay: day
	    monthNumber: month
	    year: year) ifFalse: [self error: 'Invalid date'].
	^self dateClass 
	    newDay: day
	    monthNumber: month
	    year: year
    ]

    date: aDate [
	<category: 'accessing'>
	day := aDate dayOfMonth.
	month := aDate monthIndex.
	year := aDate year
    ]

    dateClass [
	<category: 'private'>
	^Date
    ]

    dateIsValid [
	<category: 'testing'>
	[self date] on: Error do: [:e | ^false].
	^true
    ]

    day [
	<category: 'accessing'>
	^day
    ]

    day: anObject [
	<category: 'accessing'>
	^day := anObject
    ]

    days [
	<category: 'accessing'>
	^1 to: 31
    ]

    endYear [
	<category: 'accessing'>
	^endYear
    ]

    endYear: anInteger [
	<category: 'accessing'>
	endYear := anInteger
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	startYear := Date today year - 1.
	endYear := Date today year + 5.
	self date: self dateClass today
    ]

    labelForDay: aNumber [
	<category: 'accessing'>
	^aNumber
    ]

    labelForMonth: aNumber [
	<category: 'accessing'>
	^Date nameOfMonth: aNumber
    ]

    labelForYear: aNumber [
	<category: 'accessing'>
	^aNumber
    ]

    month [
	<category: 'accessing'>
	^month
    ]

    month: anObject [
	<category: 'accessing'>
	^month := anObject
    ]

    months [
	<category: 'accessing'>
	^1 to: 12
    ]

    privateIsValidDay: theDay monthNumber: theMonth year: theYear [
	<category: 'private'>
	| daysInMonth |
	(theMonth between: 1 and: 12) ifFalse: [^false].
	daysInMonth := Date daysInMonthNumber: theMonth forYear: theYear.
	^theDay between: 1 and: daysInMonth
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html select)
	    list: self months;
	    on: #month of: self;
	    labels: [:each | self labelForMonth: each].
	(html select)
	    list: self days;
	    on: #day of: self;
	    labels: [:each | self labelForDay: each].
	(html select)
	    list: self yearRange;
	    on: #year of: self;
	    labels: [:each | self labelForYear: each].
	self dateIsValid ifFalse: [self renderValidationErrorOn: html]
    ]

    renderValidationErrorOn: html [
	<category: 'rendering'>
	(html span)
	    class: 'error';
	    with: 'invalid date'
    ]

    startYear [
	<category: 'accessing'>
	^startYear
    ]

    startYear: anInteger [
	<category: 'accessing'>
	startYear := anInteger
    ]

    year [
	<category: 'accessing'>
	^year
    ]

    year: anObject [
	<category: 'accessing'>
	^year := anObject
    ]

    yearRange [
	<category: 'accessing'>
	^self startYear to: self endYear
    ]
]



WAComponent subclass: WADateTable [
    | rows startDate endDate datesCache |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WADateTable renders a table containing dates from startDate to endDate. The table contains one column for each date from startDate to endDate. The top row of the table groups columns by month and labels each month (January 2008). The second row contains the date of each month (1-31) in the date range. The table also contains "rows size" rows. The first column of these rows contains the contents of the instance variable "rows". Rest of the cells are empty.

Basically this is an abstract superclass for WASelectionDateTable

Instance Variables:
	datesCache	<(SequenceableCollection of: Date>	contains a date object for each date in the range startDate-endDate
	endDate	<Date>	end date of the range displayed in the table
	rows	<SequenceableCollection>	labels of the rows
	startDate	<Date>	start date of the range displayed in the table

'>

    datesDo: aBlock separatedBy: monthlyBlock [
	<category: 'enumerating'>
	| month |
	month := datesCache first monthIndex.
	datesCache do: 
		[:date | 
		date monthIndex = month 
		    ifFalse: 
			[month := date monthIndex.
			monthlyBlock value].
		aBlock value: date].
	monthlyBlock value
    ]

    endDate: aDate [
	<category: 'accessing'>
	endDate := aDate.
	self updateDatesCache
    ]

    monthsAndLengthsDo: aTwoArgumentBlock [
	<category: 'enumerating'>
	| count last |
	count := 0.
	last := nil.
	self datesDo: 
		[:each | 
		count := count + 1.
		last := each]
	    separatedBy: 
		[aTwoArgumentBlock value: last month value: count.
		count := 0]
    ]

    renderCellForDate: aDate row: anObject index: aNumber on: html [
	<category: 'rendering'>
	html tableData: [html space]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html table)
	    class: 'DateTable';
	    border: 1;
	    with: 
		    [html tableRow: [self renderMonthHeadingsOn: html].
		    html tableRow: [self renderDayHeadingsOn: html].
		    rows keysAndValuesDo: 
			    [:index :each | 
			    html tableRow: 
				    [self 
					renderRow: each
					index: index
					on: html]]]
    ]

    renderDayHeadingsOn: html [
	<category: 'rendering'>
	self renderHeadingSpacerOn: html.
	self datesDo: 
		[:date | 
		(html tableHeading)
		    class: 'DayHeading';
		    with: date dayOfMonth]
	    separatedBy: [self renderHeadingSpacerOn: html]
    ]

    renderHeadingForRow: anObject on: html [
	<category: 'rendering'>
	(html tableHeading)
	    class: 'RowHeading';
	    with: anObject
    ]

    renderHeadingSpacerOn: html [
	<category: 'rendering'>
	html tableData: ''
    ]

    renderMonthHeadingsOn: html [
	<category: 'rendering'>
	self monthsAndLengthsDo: 
		[:month :length | 
		self renderHeadingSpacerOn: html.
		(html tableHeading)
		    colSpan: length;
		    class: 'MonthHeading';
		    with: 
			    [html text: month name.
			    html space.
			    html text: month year]]
    ]

    renderRow: anObject index: aNumber on: html [
	<category: 'rendering'>
	self renderHeadingForRow: anObject on: html.
	self datesDo: 
		[:date | 
		self 
		    renderCellForDate: date
		    row: anObject
		    index: aNumber
		    on: html]
	    separatedBy: [self renderHeadingSpacerOn: html]
    ]

    rows: aCollection [
	<category: 'accessing'>
	rows := aCollection
    ]

    startDate: aDate [
	<category: 'accessing'>
	startDate := aDate.
	self updateDatesCache
    ]

    updateDatesCache [
	<category: 'actions'>
	| date |
	(startDate isNil or: [endDate isNil]) ifTrue: [^self].
	datesCache := OrderedCollection new.
	date := startDate.
	[date > endDate] whileFalse: 
		[datesCache add: date.
		date := date next]
    ]
]



WADateTable subclass: WASelectionDateTable [
    | cellBlock dateSelectionStart dateSelectionEnd rowSelectionStart rowSelectionEnd |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WASelectionDateTable renders a table containing dates and rows. A user can select a continuous block of cells in the table.  The table contains one column for each date from startDate to endDate. The top row of the table groups columns by month and labels each month (January 2008). The second row contains the date of each month  (1-30) in the date range. The table also contains "rows size" rows. The first column of these rows contains the contents of the instance variable "rows". Rest of the cells contents are given by "cellBlock". 

Instance Variables:
	cellBlock	<BlockClosure [:rowIndex :date | ]>	returns text for the cell in row "rowIndex" and column for "date"
	dateSelectionEnd	<Date>	last selected date
	dateSelectionStart	<Date>	first selected date
	rowSelectionEnd	<Integer>	index of last selected row
	rowSelectionStart	<Integer>	index of first selected row

'>

    clearSelection [
	<category: 'selecting'>
	dateSelectionStart := dateSelectionEnd := rowSelectionStart := rowSelectionEnd := nil
    ]

    colorForDate: aDate rowIndex: aNumber [
	<category: 'private'>
	^(self hasSelection 
	    and: [self selectionContainsDate: aDate rowIndex: aNumber]) 
		ifTrue: ['lightgrey']
		ifFalse: ['white']
    ]

    endDate: aDate [
	<category: 'accessing'>
	self clearSelection.
	super endDate: aDate
    ]

    endDateSelection [
	<category: 'private'>
	^dateSelectionStart 
	    ifNotNil: [:foo | dateSelectionStart max: dateSelectionEnd]
    ]

    endRow [
	<category: 'private'>
	^rowSelectionStart max: rowSelectionEnd
    ]

    endRowSelection [
	<category: 'private'>
	^rowSelectionStart 
	    ifNotNil: [:foo | rows at: (rowSelectionStart max: rowSelectionEnd)]
    ]

    hasSelection [
	<category: 'testing'>
	^dateSelectionStart notNil
    ]

    renderCellForDate: aDate row: anObject index: aNumber on: html [
	<category: 'rendering'>
	| text |
	(html tableData)
	    style: 'background-color: ' , (self colorForDate: aDate rowIndex: aNumber);
	    align: 'center';
	    with: 
		    [text := cellBlock value: anObject value: aDate.
		    (html anchor)
			callback: [self selectDate: aDate rowIndex: aNumber];
			with: text]
    ]

    rows: aCollection [
	<category: 'accessing'>
	self clearSelection.
	super rows: aCollection
    ]

    rowsAndDatesDisplay: aBlock [
	<category: 'private'>
	cellBlock := aBlock
    ]

    selectAll [
	<category: 'editor access'>
	dateSelectionStart := startDate.
	dateSelectionEnd := endDate.
	rowSelectionStart := 1.
	rowSelectionEnd := rows size
    ]

    selectDate: aDate rowIndex: rowIndex [
	<category: 'private'>
	self hasSelection 
	    ifFalse: 
		[dateSelectionStart := dateSelectionEnd := aDate.
		rowSelectionStart := rowSelectionEnd := rowIndex]
	    ifTrue: 
		[dateSelectionEnd := aDate.
		rowSelectionEnd := rowIndex]
    ]

    selectedRows [
	<category: 'private'>
	^rows copyFrom: self startRow to: self endRow
    ]

    selectionContainsDate: aDate rowIndex: aNumber [
	<category: 'private'>
	^((aDate between: dateSelectionStart and: dateSelectionEnd) 
	    or: [aDate between: dateSelectionEnd and: dateSelectionStart]) and: 
		    [(aNumber between: rowSelectionStart and: rowSelectionEnd) 
			or: [aNumber between: rowSelectionEnd and: rowSelectionStart]]
    ]

    startDate: aDate [
	<category: 'accessing'>
	self clearSelection.
	super startDate: aDate
    ]

    startDateSelection [
	<category: 'private'>
	^dateSelectionStart 
	    ifNotNil: [:foo | dateSelectionStart min: dateSelectionEnd]
    ]

    startRow [
	<category: 'private'>
	^rowSelectionStart min: rowSelectionEnd
    ]

    startRowSelection [
	<category: 'private'>
	^rowSelectionStart 
	    ifNotNil: [:foo | rows at: (rowSelectionStart min: rowSelectionEnd)]
    ]

    style [
	<category: 'rendering'>
	^'td a {text-decoration: none}'
    ]
]



WAComponent subclass: WADateTimeSelector [
    | dateSelector timeSelector |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WADateTimeSelector allows the user to select a date and time in a given range dropdown menus (html select). Actual work done by WADateSelector and WATimeSelector. Date range is default range of WADateSelector.

See WADateSelectorTest for sample of usage.
Select "Date Selector" tab of the Functional Seaside Test Suite to run an example  (http://127.0.0.1:xxxx/seaside/tests/alltests)

Instance Variables:
	dateSelector	<WADateSelector>	presents date selection to user
	timeSelector	<WATimeSelector>	presents time selection to user

'>

    children [
	<category: 'accessing'>
	^Array with: dateSelector with: timeSelector
    ]

    dateAndTime [
	<category: 'accessing'>
	^DateTime date: dateSelector date time: timeSelector time
    ]

    dateAndTime: anObject [
	<category: 'accessing'>
	dateSelector date: anObject asDate.
	timeSelector time: anObject asTime
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	dateSelector := WADateSelector new.
	timeSelector := WATimeSelector new
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html span: dateSelector.
	html span: [html strong: ' : '].
	html span: timeSelector
    ]
]



WAComponent subclass: WAFormDialog [
    | validationError form |
    
    <category: 'Seaside-Core-Components-Dialogs'>
    <comment: 'WAFormDialog is an empty html form. Used in WAComponent>>inform: to create a dialog component that displays text and an "Ok" button to close the component. See subclasses for sample usage & more functionality.

Instance Variables:
	form	<WAFormDecoration> Decorator that generates form tags
	validationError	<String>	Text descriping invalid data entered by user. Displayed when not nil. Set to nil when user submits form.
'>

    addForm [
	<category: 'actions'>
	form := WAFormDecoration new buttons: self buttons.
	self addDecoration: form
    ]

    addFormByDefault [
	<category: 'testing'>
	^true
    ]

    buttons [
	<category: 'accessing'>
	^#(#ok)
    ]

    defaultButton [
	<category: 'accessing'>
	^self buttons first
    ]

    divClass [
	<category: 'accessing'>
	^self class name
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self addFormByDefault ifTrue: [self addForm]
    ]

    isValid [
	<category: 'testing'>
	^validationError isNil
    ]

    model [
	<category: 'accessing'>
	^self
    ]

    ok [
	<category: 'actions'>
	self answer
    ]

    removeForm [
	<category: 'actions'>
	form ifNotNil: [:foo | self removeDecoration: form]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html hiddenInput callback: [validationError := nil].
	validationError 
	    ifNotNil: [:foo | self renderValidationError: validationError on: html].
	(html div)
	    class: self divClass;
	    with: [self renderDialogOn: html]
    ]

    renderDialogOn: html [
	<category: 'rendering'>
	
    ]

    renderSpacerRowOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'dialog-spacer';
	    with: [html space]
    ]

    renderValidationError: aString on: html [
	<category: 'rendering'>
	(html span)
	    class: 'dialog-validation';
	    with: aString
    ]

    validationError: aString [
	<category: 'validation'>
	validationError := aString
    ]
]



WAFormDialog subclass: WAChoiceDialog [
    | options selection |
    
    <category: 'Seaside-Core-Components-Dialogs'>
    <comment: 'WAChoiceDialog produces a form with select tag (dropdown menu) on a collection of options and "Ok" and "Cancel" buttons. Options can be any object. Returns actual object selected or nil if user select "Cancel". WAChoiceDialog is used to implement the chooseFrom:caption: convenience method in WAComponent.

	| selection |
	selection := WAChoiceDialog options: #(''Smalltalk'' ''Perl'' ''Python'' ''Ruby'' 9).
	result := self call: selection.
	self inform: result printString

Instance Variables:
	options	<Collection of Objects> objects in list
	selection	<Object>	object selected by user or nil if user cancels

'>

    WAChoiceDialog class >> example [
	<category: 'examples'>
	^self options: #('Smalltalk' 'Perl' 'Python' 'Ruby')
    ]

    WAChoiceDialog class >> options: aCollection [
	<category: 'instance-creation'>
	^self new options: aCollection
    ]

    buttons [
	<category: 'accessing'>
	^#(#ok #cancel)
    ]

    cancel [
	<category: 'actions'>
	self answer: nil
    ]

    ok [
	<category: 'actions'>
	self answer: selection
    ]

    options [
	<category: 'accessing'>
	^options
    ]

    options: aCollection [
	<category: 'accessing'>
	options := aCollection
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html select)
	    list: options;
	    selected: selection;
	    callback: [:value | selection := value]
    ]
]



WAFormDialog subclass: WALabelledFormDialog [
    
    <category: 'Seaside-Core-Components-Dialogs'>
    <comment: 'WALabelledFormDialog is an abstract class for generating html forms. Given a data model WALabelledFormDialog displays a label and input field for each instance variable of interest. User supplied data is placed in the data model.

Subclasses need to implment the methods labelForSelector:, model, and rows. The "model" method just returns the object whose fields we wish to populate with date. The "rows" method returns a collections of symbols. One symbol for each row of data in the dialog. The symbol is used generate the accessor methods for the data in the model. The method "labelForSelector:" returns the labels for each row and each submit button in the form.

A standard text input field is used for each row of data. To use other html widgets for input for = a datum implement the method renderXXXOn: where XXX is the symbol for the row. See "renderNameOn:" in example below.

The default form has one button "Ok". Override the "buttons" method to change the text or number of submit buttons on the form. Override the "defaultButton" method to indicate which button is the default. For each button in the form the subclass needs a method with the same name as the button, which is called when the user clicks that button. See example below.

LabelledFormDialogExample subclass of WALabelledFormDialog instance methods
	initialize
		super initialize.
		contact := Contact new. "contact is an inst var"
		self addMessage: ''Please enter the followning information''.

	model
		^ contact

	ok
		self answer: contact

	cancel
		self answer

	rows
		^ #(name phoneNumber)

	buttons
		#(ok cancel)

	labelForSelector: aSymbol
		aSymbol == #name ifTrue: [^''Your Name''].
		aSymbol == #phoneNumber ifTrue: [^''Phone Number''].
		aSymbol == #ok ifTrue: [^''Ok''].
		aSymbol == #cancel ifTrue: [^''Cancel''].
		^ super labelForSelector: aSymbol

	renderNameOn: html 
		"Show how to specily special input instead of using simple text field."
		(html select)
				list: #(''Roger'' ''Pete'');
				selected: ''Roger'';
				callback: [:v | contact name: v]

Contact Class used above has instance variables name, phoneNumber with standard getter and setter methods
'>

    renderDefaultFieldForSelector: aSymbol on: html [
	<category: 'rendering'>
	html textInput on: aSymbol of: self model
    ]

    renderDialogOn: html [
	<category: 'rendering'>
	self rows do: 
		[:ea | 
		ea = #- 
		    ifTrue: [self renderSpacerRowOn: html]
		    ifFalse: [self renderRowForSelector: ea on: html]]
    ]

    renderFieldForSelector: aSymbol on: html [
	<category: 'rendering'>
	| renderSelector |
	renderSelector := self renderingSelectorFor: aSymbol.
	(self respondsTo: renderSelector) 
	    ifTrue: [self perform: renderSelector with: html]
	    ifFalse: [self renderDefaultFieldForSelector: aSymbol on: html]
    ]

    renderLabelForSelector: aSymbol on: html [
	<category: 'rendering'>
	html text: (self labelForSelector: aSymbol)
    ]

    renderRowForSelector: aSymbol on: html [
	<category: 'rendering'>
	(html div)
	    id: 'dialog-row-' , aSymbol;
	    class: 'dialog-row';
	    with: 
		    [(html span)
			class: 'dialog-form-label';
			with: [self renderLabelForSelector: aSymbol on: html].
		    (html span)
			class: 'dialog-form-field';
			with: [self renderFieldForSelector: aSymbol on: html]]
    ]

    renderTableRowsOn: html [
	<category: 'rendering'>
	self rows do: 
		[:ea | 
		ea = #- 
		    ifTrue: [self renderSpacerRowOn: html]
		    ifFalse: [self renderRowForSelector: ea on: html]]
    ]

    renderingSelectorFor: aSymbol [
	<category: 'rendering'>
	^('render' , aSymbol capitalized , 'On:') asSymbol
    ]

    rows [
	<category: 'accessing'>
	^#()
    ]

    style [
	<category: 'accessing'>
	^'
.dialog-row {
	clear: both;
	/*set position: relative to handle the ie disappearing text bug*/
	position: relative;
	margin-top: 3px;
}

.dialog-form-label {
	width: 100px;
	float: left;
	text-align: right;
	padding: 2px 6px;
	margin-right: 4px;
	margin-top: 2px;
}

.dialog-form-field {
	text-align: left;
	padding: 2px;
	margin-top: 2px;
	float: left;
}

.dialog-buttons {
	clear: both;
	padding: 10px;
	text-align: center
}

.dialog-spacer {
	clear: both;
	height: 10px;
}
	'
    ]
]



WAFormDialog subclass: WAYesOrNoDialog [
    
    <category: 'Seaside-Core-Components-Dialogs'>
    <comment: 'WAYesOrNoDialog displays a yes/no dialog. Returns boolean indicating user selection. See WAComponent>>confirm: for sample usage and easy way to use WAYesOrNoDialog.'>

    buttons [
	<category: 'accessing'>
	^#(#yes #no)
    ]

    no [
	<category: 'accessing'>
	self answer: false
    ]

    yes [
	<category: 'accessing'>
	self answer: true
    ]
]



WAComponent subclass: WAInputDialog [
    | label value |
    
    <category: 'Seaside-Core-Components-Dialogs'>
    <comment: 'WAInputDialog generates a simple form with a text input field and a submit button. The instance variable "value" is used for initial value of the text field and hold the text entered by user. WAInputDialog answers with text entered by user (value of "value"). See WAComponent>>request:label:default: for sample use and easy way to use WAInputDialog.

Instance Variables:
	label	<String>	label of submit button
	value	<Object | String>	
'>

    default: aString [
	<category: 'accessing'>
	value := aString
    ]

    label [
	<category: 'accessing'>
	^label ifNil: [label := 'OK']
    ]

    label: aString [
	<category: 'accessing'>
	label := aString
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html form)
	    defaultAction: [self answer: value];
	    with: 
		    [html textInput on: #value of: self.
		    html space.
		    (html submitButton)
			callback: [self answer: value];
			text: self label]
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aString [
	<category: 'accessing'>
	value := aString
    ]
]



WAComponent subclass: WAMiniCalendar [
    | monthIndex year date canSelectBlock selectBlock |
    
    <comment: 'WAMiniCalendar renders a monthly calendar. Users can navigate by month, year, or select a year and a month. Users can select a date in the calendar. Set canSelectBlock to control which dates a user can select. Use selectBlock to perform an action when a user selects a date. WAMiniCalendar>>date returns the selected date.

Select "Mini Calendar" tab of the Functional Seaside Test Suite to run an example  (http://127.0.0.1:xxxx/seaside/tests/alltests)

Instance Variables:
	canSelectBlock	<BlockClosure with date argument>	return true if date argument should be rendered with a link, ie user can select that date
	date	<WAValueHolder on a date>	Selected date
	monthIndex	<WAValueHolder on an Integer>	Currently displayed month
	year	<WAValueHolder on an Integer>	Currently displayed year
	selectBlock	<BlockClosure with date argument> called when user selects a date

'>
    <category: 'Seaside-Core-Components-Widgets'>

    WAMiniCalendar class >> canBeRoot [
	<category: 'testing'>
	^true
    ]

    WAMiniCalendar class >> example [
	<category: 'testing'>
	^self new
    ]

    canSelect: aDate [
	<category: 'testing'>
	^canSelectBlock value: aDate
    ]

    canSelectBlock: aBlock [
	<category: 'accessing'>
	canSelectBlock := aBlock
    ]

    month [
	<category: 'accessing'>
	^Date newDay: 1 monthNumber: self monthIndex year: self year
    ]

    month: aMonth [
	<category: 'accessing'>
	self monthIndex: aMonth monthIndex.
	self year: aMonth year
    ]

    selectBlock: aBlock [
	<category: 'accessing'>
	selectBlock := aBlock
    ]

    states [
	<category: 'accessing'>
	^Array 
	    with: date
	    with: monthIndex
	    with: year
    ]

    date [
	<category: 'accessing-delegated'>
	^date contents
    ]

    date: aDate [
	<category: 'accessing-delegated'>
	date contents: aDate.
	monthIndex contents: aDate monthIndex.
	year contents: aDate year
    ]

    monthIndex [
	<category: 'accessing-delegated'>
	^monthIndex contents
    ]

    monthIndex: anInteger [
	<category: 'accessing-delegated'>
	monthIndex contents: anInteger
    ]

    year [
	<category: 'accessing-delegated'>
	^year contents
    ]

    year: anIntegerOrString [
	<category: 'accessing-delegated'>
	year 
	    contents: ([anIntegerOrString asInteger] on: Error do: [:error | 1900])
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	monthIndex := WAValueHolder with: Date today monthIndex.
	year := WAValueHolder with: Date today year.
	date := WAValueHolder new.
	canSelectBlock := [:value | true].
	selectBlock := [:value | self answer: value]
    ]

    monthNames [
	<category: 'localization'>
	^(1 to: 12) collect: [:each | Date nameOfMonth: each]
    ]

    weekDays [
	<category: 'localization'>
	^(1 to: 7) collect: [:i | (Date nameOfDay: i) first: 3]
    ]

    monthName [
	<category: 'private'>
	^Date nameOfMonth: self monthIndex
    ]

    monthHeading [
	<category: 'private'>
	^self monthName , ' ' , self year seasideString
    ]

    weeksDo: aBlock [
	<category: 'private'>
	| day nextMonth |
	day := Date 
		    newDay: 1
		    monthIndex: self monthIndex
		    year: self year.
	day := day subtractDays: day dayOfWeek.
	nextMonth := self monthIndex \\ 12 + 1.
	[day monthIndex = nextMonth] whileFalse: 
		[aBlock value: day.
		day := day addDays: 7]
    ]

    renderCellForDate: aDate on: html [
	<category: 'rendering'>
	html tableData: 
		[(aDate monthIndex = self monthIndex and: [aDate year = self year]) 
		    ifTrue: 
			[(html span)
			    class: (self date = aDate ifTrue: ['calendarArchiveDate']);
			    with: 
				    [(self canSelect: aDate) 
					ifTrue: 
					    [(html anchor)
						callback: [self select: aDate];
						with: aDate dayOfMonth]
					ifFalse: [html text: aDate dayOfMonth]]]]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'calendar';
	    with: 
		    [(html span)
			class: 'calendarCaption';
			with: [self renderMonthHeadingOn: html].
		    html table: 
			    [(html tableRow)
				class: 'calendarTitle';
				with: [self weekDays do: [:each | html tableData: each]].
			    self weeksDo: [:week | self renderRowForWeek: week on: html]].
		    self renderMonthNavigationOn: html.
		    html
			space;
			space.
		    self renderYearNavigationOn: html]
    ]

    renderMonthHeadingOn: html [
	<category: 'rendering'>
	html form: 
		[(html select)
		    list: (1 to: 12);
		    on: #monthIndex of: self;
		    labels: [:index | Date nameOfMonth: index].
		(html textInput)
		    maxLength: 4;
		    on: #year of: self.
		html submitButton text: 'Refresh']
    ]

    renderMonthNavigationOn: html [
	<category: 'rendering'>
	| tab |
	tab := #(12 1 2 3 4 5 6 7 8 9 10 11 12 1).
	(html span)
	    class: 'calendarPrevious';
	    with: 
		    [(html anchor)
			callback: 
				[self monthIndex = 1 
				    ifTrue: 
					[self
					    monthIndex: 12;
					    year: self year - 1]
				    ifFalse: [self monthIndex: self monthIndex - 1]];
			with: ((self monthNames at: (tab at: self monthIndex)) first: 3)].
	html space.
	(html span)
	    class: 'calendarNext';
	    with: 
		    [(html anchor)
			callback: 
				[self monthIndex = 12 
				    ifTrue: 
					[self
					    monthIndex: 1;
					    year: self year + 1]
				    ifFalse: [self monthIndex: self monthIndex + 1]];
			with: ((self monthNames at: (tab at: self monthIndex + 2)) first: 3)]
    ]

    renderRowForWeek: initialDay on: html [
	<category: 'rendering'>
	html tableRow: 
		[0 to: 6
		    do: [:each | self renderCellForDate: (initialDay addDays: each) on: html]]
    ]

    renderYearNavigationOn: html [
	<category: 'rendering'>
	(html span)
	    class: 'calendarPrevious';
	    with: 
		    [(html anchor)
			callback: [self year: self year - 1];
			with: self year - 1].
	html space.
	(html span)
	    class: 'calendarNext';
	    with: 
		    [(html anchor)
			callback: [self year: self year + 1];
			with: self year + 1]
    ]

    select: aDate [
	<category: 'action'>
	self date: aDate.
	selectBlock value: aDate
    ]
]




WAComponent subclass: WANavigation [
    | selection |
    
    <category: 'Seaside-Core-Components-Frames'>
    <comment: nil>

    initialize [
	<category: 'initialize'>
	super initialize.
	selection := WAValueHolder new
    ]

    labelForOption: anObject [
	<category: 'query'>
	^anObject seasideString
    ]

    options [
	<category: 'initialize'>
	^#()
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'kalsey';
	    with: 
		    [(html div)
			class: 'navigation-options';
			with: [self renderOptionsOn: html].
		    (html div)
			class: 'navigation-content';
			with: [self renderSelectionOn: html]]
    ]

    renderOptionsOn: html [
	<category: 'rendering'>
	(html unorderedList)
	    list: self options;
	    selected: self selection;
	    callback: [:value | self select: value];
	    labels: [:each | self labelForOption: each]
    ]

    renderSelectionOn: html [
	<category: 'rendering'>
	
    ]

    select: anObject [
	<category: 'selection'>
	selection contents: anObject.
	self selectionChanged
    ]

    selection [
	<category: 'selection'>
	^selection contents
    ]

    selectionChanged [
	<category: 'selection'>
	
    ]

    states [
	<category: 'selection'>
	^Array with: selection
    ]
]



WANavigation subclass: WASimpleNavigation [
    | components |
    
    <category: 'Seaside-Core-Components-Frames'>
    <comment: 'I''m a simple tab panel, that can be styled with stylesheets. New tabs can be added using #add:label:'>

    add: aComponent label: aString [
	<category: 'behavior'>
	components add: aString -> aComponent
    ]

    children [
	<category: 'accessing'>
	^Array with: self selectedComponent
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	components := OrderedCollection new
    ]

    labels [
	"Return the tabs labels"

	<category: 'accessing'>
	^self options
    ]

    options [
	<category: 'accessing'>
	^components collect: [:each | each key]
    ]

    renderSelectionOn: html [
	<category: 'rendering'>
	html render: self selectedComponent
    ]

    selectedComponent [
	<category: 'accessing'>
	^(components detect: [:each | each key = self selection] ifNone: [^nil]) 
	    value
    ]
]



WAComponent subclass: WANavigationBar [
    | actionsSelector owner |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WANavigationBar provides navigation links for a component, the WANavigationBar''s owner. WANavigationBar is vertical in that all items in the bar are rendered in a column. WANavigationBar''s owner typically is a top level component that renders a number of children components, including the WANavigationBar. When a user selects an item in the WANavigationBar a message is sent to the owner, so it can change.

The owner component needs to implement the method indicated by the instance variable "actionsSelector", the default value is "actions". This method returns a collections of symbols. The symbols become the list of items in the navigation bar. The first letter of the symbol is capitalized when displayed. If the symbol represents a 0-argument method it is rendered as a link. When the user clicks on the link the original symbol is send as a message to the owner component. If the symbol represents a 1-argument method it is rendered as a label followed by a text input box. The user has to know that they hit enter after filling the text box.

Instance Variables:
	actionsSelector	<ByteSymbol>	Symbol sent to owner to get a list of items to be listed in the navigation bar. Default value is "actions".
	owner	<WAComponent>	This is the navigation bar for the component "owner".'>

    actions [
	<category: 'accessing'>
	^self target perform: actionsSelector
    ]

    actionsSelector: aSymbol [
	<category: 'accessing'>
	actionsSelector := aSymbol
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	actionsSelector := #actions
    ]

    owner: anObject [
	<category: 'accessing'>
	owner := anObject
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self actions do: 
		[:symbol | 
		symbol numArgs = 0 
		    ifTrue: [self renderLink: symbol on: html]
		    ifFalse: [self renderInput: symbol on: html]]
    ]

    renderInput: aSymbol on: html [
	<category: 'rendering'>
	html form: 
		[html strong: aSymbol capitalized.
		html space.
		html textInput 
		    callback: [:value | self target perform: aSymbol with: value]]
    ]

    renderLink: aSymbol on: html [
	<category: 'rendering'>
	html anchor on: aSymbol of: self target.
	html break
    ]

    target [
	<category: 'accessing'>
	^owner activeComponent
    ]
]



WAComponent subclass: WAPath [
    | stack |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WAPath represents a path navigation (breadcrumbs) for a web page and displays standard breadcrumbs(xxx >> yyy >> zzz). WAPath maintains a stack of associations, one for each "location" or "page" in the path. The association key is the text that is displayed in the breadcrimb. The association value is an object of your choosing, which your code uses to restore that "page". 

To add to the path use the method WAPath>>pushSegment: anObject name: ''lulu''. The name: arguement is the association key, the segment: argument is the association value.

The method WAPath>>currentSegment returns object associated with the current "page". Your code is not notified when the user clicks on a link in the WAPath object. So when you render a page call WAPath>>currentSegment to get the current object, and generate the page accordingly.

See WAInspector for example use.

Use WATrail to handle breadcrumbs for sequences of call: and answers:.

Instance Variables:
	stack	<Array of associations(String->Object) > History of the page. Keys -> display string, values -> object used in helping generating page.

'>

    WAPath class >> example [
	<category: 'example'>
	^(self new)
	    pushSegment: 123 name: 'xxx';
	    pushSegment: 456 name: 'yyy';
	    pushSegment: 789 name: 'zzz';
	    yourself
    ]

    choose: anAssociation [
	"Install a new stack of navigation from the old one and the specified association."

	<category: 'behavior'>
	| newStack |
	newStack := Array new writeStream.
	stack do: 
		[:ea | 
		newStack nextPut: ea.
		ea == anAssociation 
		    ifTrue: 
			[stack := newStack contents.
			^self]]
    ]

    currentSegment [
	<category: 'accessing'>
	^stack isEmpty ifTrue: [nil] ifFalse: [stack last value]
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	stack := #()
    ]

    pushSegment: anObject name: aString [
	<category: 'behavior'>
	stack := stack , (Array with: aString -> anObject)
    ]

    renderContentOn: html [
	<category: 'rendering'>
	stack isEmpty ifTrue: [^self].
	(html div)
	    id: 'path';
	    with: 
		    [stack allButLast do: 
			    [:assoc | 
			    (html anchor)
				callback: [self choose: assoc];
				with: assoc key.
			    html text: ' >> '].
		    html strong: stack last key]
    ]

    states [
	<category: 'accessing'>
	^Array with: self
    ]
]



WAComponent subclass: WASelection [
    | items labelBlock |
    
    <category: 'Seaside-Core-Components-Dialogs'>
    <comment: 'WASelection creates a selectable list. Items can be any object. If optional labelBlock is not given the string versions of the items are displayed to user, otherwise labelBlock is used to generate the text to display for each item. Returns the item selected by user, (not the index nor the text shown the user). 

	| selection |
	selection := WASelection new.
	selection items: #(1 ''cat'' ''rat'').
	selection 
		labelBlock: [:item | item = 1 ifTrue: [''First''] ifFalse: [item asUppercase]].
	result := self call: selection.
	self inform: result printString

Instance Variables:
	items	<Array of Objects> 	
	labelBlock	<One arg Block>	

'>

    initialize [
	<category: 'initialization'>
	super initialize.
	items := #().
	labelBlock := [:each | each seasideString]
    ]

    items [
	<category: 'accessing'>
	^items
    ]

    items: aCollection [
	<category: 'accessing'>
	items := aCollection
    ]

    labelBlock [
	<category: 'accessing'>
	^labelBlock
    ]

    labelBlock: aBlock [
	<category: 'accessing'>
	labelBlock := aBlock
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html unorderedList)
	    list: self items;
	    labels: self labelBlock;
	    callback: [:value | self answer: value]
    ]
]



WAComponent subclass: WATableReport [
    | sortColumn isReversed columns rowPeriod rowColors rows |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WATableReport presents tabular data. A WATableReport contains a collections of objects, one per row, and a collection of WAReportColumns. The WAReportColumn objects are configured to produce the text for the table cell based on the each row object. Each column has a header and an optional column sum. The table can be sorted on a column by clicking its header, unless the column handles rendering on the canvas itself. A table can be given a set of html colors (rowColors), used to colors the rows to aid in viewing. 

For more information see:
	Example - WATableReportTestm (initialization code below)
	WATableReport Tutorial - http://www.cdshaffer.com/david/Seaside/WATableReport/index.html

Instance Variables:
	columns	<Collection of WAReportColumn>	Each WAReportColumn produces the text for each table cell in a column  
	isReversed	<Boolean>	true if the current sort column is to be sorted in reverse order
	rowColors	<Collection of String/Symbol>	Each element is a string for an html color, which is used as a background color for table rows
	rowPeriod	<Integer>	Each color in rowColors is used for rowPeriod consectutive rows before using the next row color.
	rows	<Collection of Object>	Each element of the collection provides the data for a row in the table.
	sortColumn	<WAValueHolder on WAReportColumn>	Column used to sort the the table rows

Example:
	WATableReport new
		rows: WAComponent allSubclasses asArray;
		columns: (OrderedCollection new
			add: (WAReportColumn
				selector: #fullName title: ''Name''
				onClick: [ :each | self inform: each description ]);
			add: ((WAReportColumn
				selector: #canBeRoot title: ''Can Be Root'')
				sortBlock: [ :a :b | a ]);
			add: (WAReportColumn
				renderBlock: [ :each :html | html emphasis: each description ]
				title: ''Description'');
			yourself);
		rowColors: #(lightblue lightyellow);
		rowPeriod: 1;
		yourself'>

    chooseRow: aRow column: aColumn [
	<category: 'private'>
	aColumn chooseRow: aRow
    ]

    colorForRowNumber: aNumber [
	<category: 'private'>
	^rowColors at: (aNumber - 1) // rowPeriod \\ rowColors size + 1
	    ifAbsent: ['white']
    ]

    columns: anArray [
	<category: 'accessing'>
	columns := anArray
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	isReversed := false.
	rows := #().
	columns := #().
	sortColumn := WAValueHolder new.
	rowColors := #('white' 'lightyellow').
	rowPeriod := 3
    ]

    isReversed [
	<category: 'testing'>
	^isReversed
    ]

    renderColumn: aColumn row: aRow on: html [
	<category: 'rendering'>
	| text |
	aColumn canRender 
	    ifTrue: [^html tableData: [aColumn renderValue: aRow on: html]].
	text := aColumn textForRow: aRow.
	text isEmpty ifTrue: [text := ' '].
	html tableData: 
		[aColumn canChoose 
		    ifFalse: [html text: text]
		    ifTrue: 
			[(html anchor)
			    callback: [self chooseRow: aRow column: aColumn];
			    with: text]]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	html table: 
		[self renderTableHeaderOn: html.
		self renderRowsOn: html.
		self renderTableFooterOn: html]
    ]

    renderFooterForColumn: aColumn on: html [
	<category: 'rendering'>
	html tableHeading: (aColumn totalForRows: rows)
    ]

    renderHeaderForColumn: aColumn on: html [
	<category: 'rendering'>
	html tableHeading: 
		[aColumn canSort 
		    ifTrue: 
			[(html anchor)
			    callback: [self sortColumn: aColumn];
			    with: aColumn title]
		    ifFalse: [html text: aColumn title]]
    ]

    renderRowNumber: index item: row on: html [
	<category: 'rendering'>
	(html tableRow)
	    style: 'background-color: ' , (self colorForRowNumber: index);
	    with: 
		    [columns do: 
			    [:each | 
			    self 
				renderColumn: each
				row: row
				on: html]]
    ]

    renderRowsOn: html [
	<category: 'rendering'>
	self rows keysAndValuesDo: 
		[:i :row | 
		self 
		    renderRowNumber: i
		    item: row
		    on: html]
    ]

    renderTableFooterOn: html [
	<category: 'rendering'>
	html 
	    tableRow: [columns do: [:each | self renderFooterForColumn: each on: html]]
    ]

    renderTableHeaderOn: html [
	<category: 'rendering'>
	html 
	    tableRow: [columns do: [:each | self renderHeaderForColumn: each on: html]]
    ]

    reverse [
	<category: 'state variables'>
	isReversed := isReversed not
    ]

    rowColors: colorArray [
	<category: 'accessing'>
	rowColors := colorArray
    ]

    rowPeriod: aNumber [
	<category: 'accessing'>
	rowPeriod := aNumber
    ]

    rows [
	<category: 'accessing'>
	| r |
	self sortColumn ifNil: [^rows].
	r := self sortColumn sortRows: rows.
	^self isReversed ifTrue: [r reversed] ifFalse: [r]
    ]

    rows: anArray [
	<category: 'accessing'>
	rows := anArray
    ]

    sortColumn [
	<category: 'state variables'>
	^sortColumn contents
    ]

    sortColumn: anObject [
	<category: 'state variables'>
	isReversed := anObject = self sortColumn and: [isReversed not].
	sortColumn contents: anObject
    ]

    states [
	<category: 'accessing'>
	^Array with: sortColumn
    ]
]



WAComponent subclass: WATask [
    
    <category: 'Seaside-Core-Component'>
    <comment: 'I am a subclass of WAComponent, specialized for defining workflow.  The difference between a task and a component is the following:

Both of them are reusable, embeddable, callable pieces of user interface. A component has state (instance variables), behavior (it may change its state, and it may also choose to display other components with #call:), and appearance (it renders HTML). A Task has only the first two - it doesn''t render any HTML directly, but only through the components it calls. This is useful when what you want to encapsulate/embed/call is purely a process (show this component, then this one, then this one).

The key method for WATask is #go - as soon as a task is displayed, this method will get invoked, and will presumably #call: other components.

In terms of implementation, you can think of a WATask in the following way: it is a component which renders two things:
- a link whose callback invokes the #go method
- a header that immediately redirects to the URL of that link

Subclasses must not implement #renderContentOn:

An example can be found in WAConvenienceTest.
'>

    decoration: oldDecoration shouldWrap: newDecoration [
	<category: 'decorations'>
	^(oldDecoration isGlobal and: [newDecoration isGlobal not]) 
	    or: [oldDecoration isLocal and: [newDecoration isDelegation]]
    ]

    go [
	<category: 'processing'>
	self subclassResponsibility
    ]

    updateRoot: aHtmlRoot [
	<category: 'processing'>
	| callbacks url |
	super updateRoot: aHtmlRoot.
	callbacks := WACallbackRegistry context: aHtmlRoot context owner: self.
	url := aHtmlRoot context actionUrl withParameter: (callbacks 
			    registerActionCallback: [[self answer: self go] repeat]).
	self session redirectTo: url
    ]
]



WAComponent subclass: WATimeSelector [
    | second hour minute startHour endHour |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WATimeSelector displays dropdown menus (html select) allowing a user to delect a time within a range. "startHour" and "endHour" define the range of selectable times. Time is displayed in 24 hour format. WATimeSelector>>time returns time user selected as a Time object.

See WADateSelectorTest for sample of usage.
Select "Date Selector" tab of the Functional Seaside Test Suite to run an example  (http://127.0.0.1:xxxx/seaside/tests/alltests)

Instance Variables:
	endHour	<Integer 0-23>	end of time interval for selectable times
	hour	<Integer 0-23>	selected hour
	minute	<Integer 0-59>	selected minute
	second	<Integer 0-59>	selected second
	startHour	<Integer 0-23>	start of time interval for selectable times
'>

    date: aDate [
	<category: 'accessing'>
	second := aDate dayOfMonth.
	hour := aDate monthIndex.
	minute := aDate year
    ]

    days [
	<category: 'accessing'>
	^1 to: 31
    ]

    endHour [
	<category: 'accessing'>
	^endHour
    ]

    endHour: anInteger [
	<category: 'accessing'>
	endHour := anInteger
    ]

    hour [
	<category: 'accessing'>
	^hour
    ]

    hour: anObject [
	<category: 'accessing'>
	^hour := anObject
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	startHour := 0.
	endHour := 23.
	self time: Time midnight
    ]

    minute [
	<category: 'accessing'>
	^minute
    ]

    minute: anObject [
	<category: 'accessing'>
	^minute := anObject
    ]

    privateIsValidSecond: theSecond hourNumber: theHour minuteNumber: theMinute [
	<category: 'private'>
	^(theHour between: 0 and: 23) 
	    and: [(theMinute between: 0 and: 59) and: [theSecond between: 0 and: 59]]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html select)
	    list: (0 to: 23);
	    on: #hour of: self.
	(html select)
	    list: (0 to: 59);
	    on: #minute of: self.
	(html select)
	    list: (0 to: 59);
	    on: #second of: self.
	self timeIsValid ifFalse: [self renderValidationErrorOn: html]
    ]

    renderValidationErrorOn: html [
	<category: 'rendering'>
	(html span)
	    class: 'error';
	    with: 'invalid time'
    ]

    second [
	<category: 'accessing'>
	^second
    ]

    second: anObject [
	<category: 'accessing'>
	^second := anObject
    ]

    startHour [
	<category: 'accessing'>
	^startHour
    ]

    startHour: anInteger [
	<category: 'accessing'>
	startHour := anInteger
    ]

    time [
	<category: 'accessing'>
	(self 
	    privateIsValidSecond: second
	    hourNumber: hour
	    minuteNumber: minute) ifFalse: [self error: 'Invalid time'].
	^self timeClass 
	    hours: hour
	    minutes: minute
	    seconds: second
    ]

    time: aTime [
	<category: 'accessing'>
	second := aTime second.
	hour := aTime hour.
	minute := aTime minute
    ]

    timeClass [
	<category: 'private'>
	^Time
    ]

    timeIsValid [
	<category: 'testing'>
	[self time] on: Error do: [:e | ^false].
	^true
    ]
]



WAComponent subclass: WATrail [
    | root |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WATrail implements breadcrumbs for pages generated using a sequence of WAComponent>>call: methods. Each component in the call sequence that is to appear in the breadcrumb must implement the method "trailName", which returns the text displayed in the breadcrumb. 

Instantiate (WATrail on: rootComponent) an WATrail object on the first component (root) of the breadcrumb. When the root component, or subsequent component, transfers control via "self call:" the WATrail object is automatically updated and will display the correct call sequence in the breadcrumb. When a user clicks on a link in the breadcrumb the call sequence is automatically updated.

The breadcrumb is placed in a div with class "trail" and each crumb is separated with the character ''>'', which is inside a span of class "separator" to aid in using CSS to format the breadcrumbs.

Instance Variables:
	root	<WAComponent>	first component in the breadcrumb and in the call sequence.

'>

    WATrail class >> on: anObject [
	<category: 'instance creation'>
	^self new root: anObject
    ]

    renderContentOn: html [
	<category: 'rendering'>
	| last selected |
	last := nil.
	(html div)
	    class: 'trail';
	    with: 
		    [root visiblePresentersDo: 
			    [:each | 
			    (each isDecoration and: [each isDelegation]) 
				ifTrue: 
				    [(each component respondsTo: #trailName) 
					ifTrue: 
					    [last := each.
					    (html anchor)
						callback: [each remove];
						with: each component trailName.
					    (html span)
						class: 'separator';
						with: self separator]]].
		    selected := last ifNil: [root] ifNotNil: [:foo | last delegate].
		    (selected respondsTo: #trailName) ifTrue: [html text: selected trailName]]
    ]

    root: anObject [
	<category: 'accessing'>
	root := anObject
    ]

    separator [
	<category: 'accessing'>
	^' > '
    ]
]



WAComponent subclass: WATree [
    | root selected expanded childrenBlock labelBlock canSelectBlock selectBlock |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WATree implements a tree menu, which supports nesting, collapsing and expanding. Prefixes items with "+/-" to indicate items that can be expanded/collapsed.

See class methods for simple example.


Instance Variables:
	canSelectBlock	<BlockClosure [:nodeInTree | ]>	returns true if user can select the argument of the block, if true node is an anchor
	childrenBlock	<BlockClosure [:nodeInTree | ]>	returns children (or subnodes) of the given node in the tree, sent to all nodes
	expanded	<IdentitySet>	Collection of all nodes that are currently expanded
	labelBlock	<[:nodeInTree | ]> returns text to display for given node
	root	<Object>	root or top level node in tree, childrenBlock is used to determine roots subnodes
	selectBlock	<BlockClosure [:selectedNode | ]>	called when an node is selected, put a callback to your code here
	selected	<Object>	currently selected node


'>

    WATree class >> exampleCollectionClasses [
	<category: 'examples'>
	^(self new)
	    root: Collection;
	    labelBlock: [:class | class name];
	    childrenBlock: [:class | class subclasses];
	    yourself
    ]

    WATree class >> exampleObjectExplorer [
	<category: 'examples'>
	^(self new)
	    root: 'dispatcher' -> WADispatcher default;
	    labelBlock: [:assoc | assoc key seasideString , ': ' , assoc value printString];
	    childrenBlock: [:assoc | assoc value inspectorFields];
	    yourself
    ]

    WATree class >> root: anObject [
	<category: 'instance-creation'>
	^(self new)
	    root: anObject;
	    yourself
    ]

    WATree class >> root: anObject path: anArray [
	<category: 'instance-creation'>
	^(self root: anObject)
	    expandAll: anArray;
	    selected: anArray last;
	    yourself
    ]

    canSelect: aNode [
	<category: 'testing'>
	^self selectBlock notNil 
	    and: [self canSelectBlock isNil or: [self canSelectBlock value: aNode]]
    ]

    canSelectBlock [
	<category: 'accessing-configuration'>
	^canSelectBlock
    ]

    canSelectBlock: aBlock [
	<category: 'accessing-configuration'>
	canSelectBlock := aBlock
    ]

    childrenBlock [
	<category: 'accessing-configuration'>
	^childrenBlock
    ]

    childrenBlock: aBlock [
	<category: 'accessing-configuration'>
	childrenBlock := aBlock
    ]

    childrenOf: aNode [
	<category: 'accessing-nodes'>
	| children |
	children := self childrenBlock value: aNode.
	^children ifNil: [Array new]
    ]

    collapse: aNode [
	<category: 'actions'>
	expanded remove: aNode
    ]

    expand: aNode [
	<category: 'actions'>
	expanded add: aNode
    ]

    expandAll: aCollection [
	<category: 'actions'>
	expanded addAll: aCollection
    ]

    hasChildren: aNode [
	<category: 'testing'>
	^(self childrenOf: aNode) isEmpty not
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	expanded := IdentitySet new.
	self selectBlock: [:node | self answer: node].
	self childrenBlock: [:node | Array new].
	self labelBlock: [:node | node seasideString]
    ]

    isExpanded: aNode [
	<category: 'testing'>
	^expanded includes: aNode
    ]

    labelBlock [
	<category: 'accessing-configuration'>
	^labelBlock
    ]

    labelBlock: aBlock [
	<category: 'accessing-configuration'>
	labelBlock := aBlock
    ]

    labelOf: aNode [
	<category: 'accessing-nodes'>
	^self labelBlock value: aNode
    ]

    renderContentOn: html [
	<category: 'rendering'>
	self renderTreeOn: html
    ]

    renderNode: aNode on: html [
	<category: 'rendering-nodes'>
	html listItem: 
		[self renderNodeButton: aNode on: html.
		self renderNodeLabel: aNode on: html.
		self renderNodeChildren: aNode on: html]
    ]

    renderNodeButton: aNode on: html [
	<category: 'rendering-nodes'>
	| isExpanded |
	(html span)
	    class: 'button';
	    with: 
		    [(self hasChildren: aNode) 
			ifTrue: 
			    [isExpanded := self isExpanded: aNode.
			    self 
				renderNodeButtonLink: aNode
				action: (DirectedMessage 
					receiver: self
					selector: (isExpanded ifTrue: [#collapse:] ifFalse: [#expand:])
					argument: aNode)
				text: (isExpanded ifTrue: ['-'] ifFalse: ['+'])
				on: html]]
    ]

    renderNodeButtonLink: aNode action: aBlock text: anObject on: html [
	<category: 'rendering-nodes'>
	(html anchor)
	    callback: aBlock;
	    with: anObject
    ]

    renderNodeChildren: aNode on: html [
	<category: 'rendering-nodes'>
	| children |
	children := self childrenOf: aNode.
	children isEmpty 
	    ifFalse: 
		[(self isExpanded: aNode) 
		    ifTrue: 
			[html 
			    unorderedList: [children do: [:each | self renderNode: each on: html]]]]
    ]

    renderNodeLabel: aNode on: html [
	<category: 'rendering-nodes'>
	| label |
	(html span)
	    class: 'label';
	    class: (self selected == aNode ifTrue: ['active'] ifFalse: ['inactive']);
	    with: 
		    [label := self labelOf: aNode.
		    (self canSelect: aNode) 
			ifFalse: [html render: label]
			ifTrue: 
			    [self 
				renderNodeLabelLink: aNode
				action: (DirectedMessage 
					receiver: self
					selector: #select:
					argument: aNode)
				text: label
				on: html]]
    ]

    renderNodeLabelLink: aNode action: aBlock text: anObject on: html [
	<category: 'rendering-nodes'>
	(html anchor)
	    callback: aBlock;
	    with: anObject
    ]

    renderTreeOn: html [
	<category: 'rendering'>
	html unorderedList: [self renderNode: self root on: html]
    ]

    root [
	<category: 'accessing'>
	^root
    ]

    root: aNode [
	<category: 'accessing'>
	root := aNode
    ]

    select: aNode [
	<category: 'actions'>
	(self canSelect: aNode) 
	    ifTrue: 
		[self selected: aNode.
		self selectBlock isNil ifFalse: [self selectBlock value: aNode]]
    ]

    selectBlock [
	<category: 'accessing-configuration'>
	^selectBlock
    ]

    selectBlock: aBlock [
	<category: 'accessing-configuration'>
	selectBlock := aBlock
    ]

    selected [
	<category: 'accessing'>
	^selected
    ]

    selected: aNode [
	<category: 'accessing'>
	selected := aNode
    ]

    states [
	<category: 'accessing'>
	^Array with: expanded
    ]
]



WAPresenter subclass: WADecoration [
    | next |
    
    <category: 'Seaside-Core-Component'>
    <comment: 'I am an abstract decoration around instances of WAComponent. I can be added to aComponent by calling #addDecoration: and I change the basic behaviour or look of a component. There are several methods that can be overriden to archive this:

- #renderContentOn: to emit xhtml around the decorated component. Call #renderOwnerOn: to let the owner emit its output.

- #processChildCallbacks: to intercept the callback processing of the owner.

- #handleAnswer: to intercept the answer processing.'>

    asComponent [
	<category: 'convenience'>
	^self component
    ]

    component [
	<category: 'accessing'>
	^self owner isDecoration 
	    ifTrue: [self owner component]
	    ifFalse: [self owner]
    ]

    handleAnswer: anObject [
	<category: 'call/answer'>
	(self owner handleAnswer: anObject) 
	    ifFalse: [self handleAnswer: anObject continueWith: [^false]].
	^true
    ]

    handleAnswer: anObject continueWith: aBlock [
	<category: 'processing'>
	aBlock value
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	next := WAValueHolder new
    ]

    isDecoration [
	<category: 'testing'>
	^true
    ]

    isDelegation [
	<category: 'testing'>
	^false
    ]

    isGlobal [
	<category: 'testing'>
	^false
    ]

    isLocal [
	<category: 'testing'>
	^(self isGlobal or: [self isDelegation]) not
    ]

    nextPresentersDo: aBlock [
	<category: 'iterating'>
	aBlock value: self owner
    ]

    owner [
	<category: 'accessing'>
	^next contents
    ]

    owner: aPresenter [
	<category: 'accessing'>
	next contents: aPresenter
    ]

    remove [
	<category: 'actions'>
	self component removeDecoration: self
    ]

    renderOwnerOn: html [
	<category: 'rendering'>
	self owner isNil ifFalse: [self owner renderWithContext: html context]
    ]

    showHalo [
	<category: 'rendering'>
	^false
    ]

    updateStates: aSnapshot [
	<category: 'updating'>
	super updateStates: aSnapshot.
	aSnapshot register: next
    ]
]



WADecoration subclass: WAAnswerHandler [
    | block |
    
    <category: 'Seaside-Core-Component'>
    <comment: nil>

    block: aBlock [
	<category: 'accessing'>
	block := aBlock
    ]

    handleAnswer: anObject continueWith: aBlock [
	<category: 'processing'>
	block value: anObject
    ]
]



WADecoration subclass: WABasicAuthentication [
    | authenticator realm |
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'WABasicAuthentication password protects its component using the standard Http basic authentication, which passes usernames & passwords in clear text. You must set the authenticator, which validates usernames and passwords.

Seaside has a number of ways to authenticate a user: WAComponent>>registerAsAuthenticatedApplication:, WAAuthMain, WAAuthConfiguration. One can also use a task or a session to authenticate. These methods can be used to authenicate a session or application rather than a single component.

Instance Variables:
	authenticator	<Authenticator>	Any object that implements the method verifyPassword:forUser:
	realm	<String>	An http realm is a string used to identify a set of pages that are convered by the same login

'>

    authenticator: anAuthenticator [
	<category: 'accessing'>
	authenticator := anAuthenticator
    ]

    isGlobal [
	<category: 'testing'>
	^true
    ]

    processChildCallbacks: aStream [
	<category: 'processing'>
	(self verifyRequest: self session currentRequest) 
	    ifTrue: [super processChildCallbacks: aStream]
	    ifFalse: [self respondWithChallenge]
    ]

    realm [
	<category: 'accessing'>
	^realm ifNil: [self session application basePath]
    ]

    realm: aString [
	<category: 'accessing'>
	realm := aString
    ]

    respondWithChallenge [
	<category: 'processing'>
	self session returnResponse: (WAResponse basicAuthWithRealm: self realm)
    ]

    updateRoot: aStream [
	<category: 'processing'>
	(self verifyRequest: self session currentRequest) 
	    ifTrue: [super updateRoot: aStream]
	    ifFalse: [self respondWithChallenge]
    ]

    verifyRequest: aRequest [
	<category: 'processing'>
	^authenticator verifyPassword: aRequest password forUser: aRequest user
    ]
]



WADecoration subclass: WADelayedAnswerDecoration [
    | delay |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WADelayedAnswerDecoration adds a delay in displaying a component. 

See WADelayTest for sample usage.
Select ''Delay" tab of the Functional Seaside Test Suite to run an example  (http://127.0.0.1:xxxx/seaside/tests/alltests)

Instance Variables:
	delay	<Integer>	delay length in seconds 

'>

    delay [
	<category: 'accessing'>
	^delay ifNil: [1]
    ]

    delay: aNumber [
	<category: 'accessing'>
	delay := aNumber
    ]

    updateRoot: aRoot [
	<category: 'path'>
	| callbacks url |
	callbacks := WACallbackRegistry context: aRoot context owner: self.
	url := aRoot context actionUrl 
		    withParameter: (callbacks registerActionCallback: [self component answer]).
	aRoot meta redirectAfter: self delay to: url seasideString
    ]
]



WADecoration subclass: WADelegation [
    | delegate |
    
    <category: 'Seaside-Core-Component'>
    <comment: nil>

    delegate [
	<category: 'accessing'>
	^delegate
    ]

    delegate: aComponent [
	<category: 'accessing'>
	delegate := aComponent
    ]

    isDelegation [
	<category: 'testing'>
	^true
    ]

    nextPresentersDo: aBlock [
	<category: 'iterating'>
	delegate decorationChainDo: aBlock
    ]
]



WADecoration subclass: WAFormDecoration [
    | buttons |
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'A WAFormDecoration places its component inside an html form tag. The buttons inst var must be set. The component that a WAFormDecoration decorates must implement the method "defaultButton", which returns the string/symbol of the default button (one selected by default) of the form. Don''t place any decorators between WAFormDecoration and its component otherwise "defaultButton" method fails. For each string/symbol in the buttons inst var the decorated component must implement a method of the same name, which is called when the button is selected.

Instance Variables
	buttons:		<Collection of strings or symbols>

buttons
	- list of strings or symbols, each string/symbol is the label (first letter capitalized) for a button and the name of the callback method on component when button is pressed, 
'>

    buttons [
	<category: 'accessing'>
	^buttons
    ]

    buttons: selectorArray [
	<category: 'accessing'>
	buttons := selectorArray
    ]

    defaultAction [
	<category: 'actions'>
	self component perform: self component defaultButton
    ]

    renderButtonForSelector: aSymbol on: html [
	<category: 'rendering'>
	html submitButton on: aSymbol of: self component
    ]

    renderButtonsOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'dialog-buttons';
	    with: 
		    [self buttons do: 
			    [:each | 
			    (html span)
				class: 'dialog-button-' , each;
				with: [self renderButtonForSelector: each on: html]]]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html form)
	    defaultAction: [self defaultAction];
	    with: 
		    [self renderOwnerOn: html.
		    self renderButtonsOn: html]
    ]
]



WADecoration subclass: WAMessageDecoration [
    | message |
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'I add a string message on top of the WAComponent I decorate. For example if change WACounter>>initialize as below the text "Counter Example" will appear on above the counter when rendered.

WACounter>>initialize
	super initialize.
	self count: 0.
	self addMessage: ''Counter Example''	"added line"

'>

    message: aString [
	<category: 'accessing'>
	message := aString
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html heading)
	    level3;
	    with: message.
	self renderOwnerOn: html
    ]
]



WADecoration subclass: WASessionProtector [
    | remoteAddress |
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'I bind a session to an IP address.

The problem I solve is when you navigate from a Seaside "page" to a different page then this page will have enough information to hijack your old session. This can happen for example with blogs that display the referer.

I don''t work for users that have the same IP. This is the case if they are NATed (universities, companies, ...). I can be circumvened if the application is not behind an Apache proxy.

An alternative to solve the same problem is to use a session cookie.

Usage:
In your root component class implement

initialize
	super initialize.
	self addDecoration: WASessionProtector new'>

    isGlobal [
	<category: 'testing'>
	^true
    ]

    processChildCallbacks: aStream [
	<category: 'forwarding'>
	(self verifyRequest: self session currentRequest) 
	    ifTrue: [super processChildCallbacks: aStream]
	    ifFalse: [self respondNotVerified]
    ]

    remoteAddressFromRequest: aRequest [
	<category: 'accessing'>
	^aRequest headerAt: 'x-forwarded-for'
	    ifAbsent: [aRequest nativeRequest remoteAddress]
    ]

    renderContentOn: html [
	<category: 'forwarding'>
	self renderOwnerOn: html
    ]

    respondNotVerified [
	<category: 'forwarding'>
	self session redirectTo: self session application basePath
    ]

    storedRemoteAddress [
	<category: 'accessing'>
	remoteAddress isNil 
	    ifTrue: 
		[remoteAddress := self 
			    remoteAddressFromRequest: self session currentRequest].
	^remoteAddress
    ]

    updateRoot: html [
	<category: 'forwarding'>
	super updateRoot: html.
	(self verifyRequest: self session currentRequest) 
	    ifFalse: [self respondNotVerified]
    ]

    verifyRequest: aRequest [
	<category: 'testing'>
	^(self remoteAddressFromRequest: aRequest) = self storedRemoteAddress
    ]
]



WADecoration subclass: WATransaction [
    | active |
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'WATransaction ensures that the component it decorates is not repeated once the "transaction" is completed. For example once a user has submitted an order you don''t want them to use the web browser''s back button to accidentally resubmit the order. WATransaction does not support rollbacks.

Normally you will not use this class directly. Instead use WAComponent>>isolate: in a task.

Instance Variables:
	active	<Boolean>	false indicates the transaction is over.
'>

    close [
	<category: 'open/close'>
	active := false
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	active := true
    ]

    isGlobal [
	<category: 'testing'>
	^true
    ]

    processChildCallbacks: aStream [
	<category: 'forwarding'>
	^active 
	    ifTrue: [super processChildCallbacks: aStream]
	    ifFalse: [self session pageExpired]
    ]

    renderContentOn: html [
	<category: 'rendering'>
	active 
	    ifTrue: [self renderOwnerOn: html]
	    ifFalse: [self session pageExpired]
    ]
]



WADecoration subclass: WAValidationDecoration [
    | message validationBlock exceptionClass |
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'A WAValidationDecoration validates its component form data when the component returns using "answer" or "answer:". A WAValidationDecoration can be added to component via the method "validateWith:" as below.

	SampleLoginComponent>>intialize
		form := WAFormDecoration new buttons: self buttons.
		self addDecoration: form.
		self validateWith: [:answerArgOrSelf | answerArgOrSelf validate].
		self addMessage: ''Please enter the following information''.

If component returns via "answer:" the answer: argument is passed to the validate block. If the component returns using "answer" the sender of "answer" is passed to the validate block.

Instance Variables
	exceptionClass:		<Notification>
	message:		<String>
	validationBlock:		<one arg block>

exceptionClass
	- Type of notication that is raised by validation code when validation fails. Default value is WAValidationNotification

message
	- String message displayed on validation failure. Obtained from the notification

validationBlock
	- One arg block, 
'>

    exceptionClass [
	<category: 'accessing'>
	^exceptionClass ifNil: [exceptionClass := WAValidationNotification]
    ]

    exceptionClass: aClass [
	<category: 'accessing'>
	exceptionClass := aClass
    ]

    handleAnswer: anObject [
	<category: 'call/answer'>
	^(super handleAnswer: anObject) or: [(self validate: anObject) not]
    ]

    handleAnswer: anObject continueWith: aBlock [
	<category: 'request processing'>
	(self validate: anObject) ifTrue: [aBlock value]
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	message := WAValueHolder new
    ]

    renderContentOn: html [
	<category: 'rendering'>
	message contents isNil 
	    ifFalse: 
		[(html div)
		    class: 'validation-error';
		    with: message contents].
	self renderOwnerOn: html
    ]

    states [
	<category: 'accessing'>
	^Array with: message
    ]

    validate: anObject [
	<category: 'request processing'>
	
	[validationBlock value: anObject.
	message contents: nil.
	^true] 
		on: self exceptionClass
		do: [:exception | message contents: exception messageText].
	^false
    ]

    validateWith: aBlock [
	<category: 'convenience'>
	validationBlock := aBlock
    ]
]



WADecoration subclass: WAWindowDecoration [
    | title cssClass |
    
    <category: 'Seaside-Core-Components-Decorations'>
    <comment: 'WAWindowDecoration adds a simple title and close button in a bordered area at the top of the page. When closed button is selected nil is "answer"ed. Useful for a quick & dirty dialog window. Used by WAPlugin and SCTestRunner.

Instance Variables:
	cssClass	<String>	String added to "window-title " to generate cssClass for the title
	title	<String>	title of page
'>

    WAWindowDecoration class >> title: aTitle [
	<category: 'instance creation'>
	^(self new)
	    title: aTitle;
	    yourself
    ]

    cssClass: aString [
	<category: 'accessing'>
	cssClass := aString
    ]

    isGlobal [
	<category: 'testing'>
	^true
    ]

    renderCloseButtonOn: html [
	<category: 'rendering'>
	(html anchor)
	    title: 'Close';
	    callback: [self component answer: nil];
	    with: [html html: '&times;']
    ]

    renderContentOn: html [
	<category: 'rendering'>
	(html div)
	    class: 'window';
	    with: 
		    [(html div)
			class: 'window-titlebar';
			with: 
				[(html div)
				    class: 'window-title';
				    class: cssClass;
				    with: title.
				(html div)
				    class: 'window-close';
				    with: [self renderCloseButtonOn: html]].
		    (html div)
			class: 'window-content';
			with: [self renderOwnerOn: html]]
    ]

    title: aString [
	<category: 'accessing'>
	title := aString
    ]
]



Object subclass: WAProcessMonitor [
    | mutex process semaphore |
    
    <category: 'Seaside-Core-Utilities'>
    <comment: 'WAProcessMonitor executes a block in a new process. Ensures that only one such block is executed at a time. See method critical:ifError:

Instance Variables:
	mutex	<Semaphore>	Used to sure that only one block is executed at a time
	process	<Process>	New process used to execute block
	semaphore	<Semaphore>	Used to signal when process is done

'>

    WAProcessMonitor class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    critical: aBlock ifError: anErrorBlock [
	"Evaluate aBlock as a mutual exclusive block within a new processes and wait for the process to finish. Evaluate anErrorBlock in case of a problem. Answer the result of evaluating the blocks. Note, that the semaphore needs to be an instance-variable, otherwise continuations might screw up the debugger."

	<category: 'mutual exclusion'>
	| value |
	mutex critical: 
		[semaphore := SeasidePlatformSupport semaphoreClass new.
		process := 
			[[value := aBlock on: Error do: anErrorBlock] ensure: [semaphore signal]] 
				newProcess.
		process resume.
		semaphore wait.
		process := nil].
	^value
    ]

    initialize [
	<category: 'initialization'>
	mutex := SeasidePlatformSupport semaphoreClass forMutualExclusion
    ]

    terminate [
	<category: 'controlling'>
	process ifNotNil: [:foo | process terminate]
    ]
]



Object subclass: WAQualifiedValue [
    | value quality |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: 'A WAQualifiedValue is an Object with an assigned quality value.

Instance Variables
	quality:		<Float>
	value:		<Object>

quality
	- between 0.0 and 1.0 or Float infinity if no value is given

value
	- the qualified object'>

    WAQualifiedValue class >> fromString: aString [
	<category: 'instance creation'>
	^Array streamContents: 
		[:stream | 
		| values |
		values := aString findTokens: ','.
		values do: 
			[:each | 
			| value quality |
			(each includes: $;) 
			    ifTrue: 
				[value := self valueClass fromString: (each copyUpTo: $;) trimSeparators.
				quality := FloatD 
					    readFrom: ((each copyAfter: $;) copyAfter: $=) readStream]
			    ifFalse: 
				[value := self valueClass fromString: each trimSeparators.
				quality := FloatD infinity].
			stream nextPut: (self value: value quality: quality)]]
    ]

    WAQualifiedValue class >> value: anObject quality: aFloat [
	<category: 'instance creation'>
	^(self new)
	    value: anObject;
	    quality: aFloat;
	    yourself
    ]

    WAQualifiedValue class >> valueClass [
	<category: 'private'>
	self subclassResponsibility
    ]

    quality [
	<category: 'accessing'>
	^quality
    ]

    quality: aFloat [
	<category: 'accessing'>
	quality := aFloat
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]
]



WAQualifiedValue subclass: WAAccept [
    
    <category: 'Seaside-Core-HTTP'>
    <comment: nil>

    WAAccept class >> valueClass [
	<category: 'private'>
	^WAMimeType
    ]
]



WAQualifiedValue subclass: WAAcceptLanguage [
    
    <category: 'Seaside-Core-HTTP'>
    <comment: nil>

    WAAcceptLanguage class >> valueClass [
	<category: 'private'>
	^WALocale
    ]
]



Object subclass: WARadioGroup [
    | canvas key |
    
    <category: 'Seaside-Core-Canvas'>
    <comment: nil>

    WARadioGroup class >> canvas: aRenderCanvas [
	<category: 'accessing'>
	^self basicNew initializeWithCanvas: aRenderCanvas
    ]

    initializeWithCanvas: aRenderCanvas [
	<category: 'initialize-release'>
	canvas := aRenderCanvas.
	key := aRenderCanvas callbacks registerDispatchCallback
    ]

    key [
	<category: 'accessing'>
	^key
    ]

    radioButton [
	<category: 'public api'>
	^canvas radioButton group: self
    ]
]



Object subclass: WARedirectHandler [
    
    <category: 'Seaside-Core-Session'>
    <comment: nil>

    WARedirectHandler class >> redirectPageExpiredTo: aUrl [
	<category: 'actions'>
	^self new redirectPageExpiredTo: aUrl
    ]

    WARedirectHandler class >> redirectTo: aUrl [
	<category: 'actions'>
	^self new redirectTo: aUrl
    ]

    redirectPageExpiredTo: aUrl [
	<category: 'actions'>
	^(WAResponse 
	    refreshWithMessage: 'That page has expired.'
	    location: aUrl seasideString
	    delay: 3)
	    gone;
	    yourself
    ]

    redirectTo: aUrl [
	<category: 'actions'>
	^WAResponse redirectTo: aUrl seasideString
    ]
]



Object subclass: WARenderLoop [
    | root |
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    application [
	"Answer the application to which this entry point is associated."

	<category: 'accessing-conveniance'>
	^self session application
    ]

    call: aComponent [
	<category: 'processing'>
	^AnswerContinuation currentDo: 
		[:cc | 
		aComponent onAnswer: cc.
		self root: aComponent.
		self run]
    ]

    renderContinuationClass [
	<category: 'accessing-properties'>
	^self application preferenceAt: #renderContinuationClass
    ]

    root [
	<category: 'accessing'>
	^root
    ]

    root: aComponent [
	<category: 'accessing'>
	root := aComponent.
	self application decorationClasses 
	    do: [:each | root addDecoration: each new]
    ]

    run [
	<category: 'processing'>
	(self renderContinuationClass root: self root) run
    ]

    session [
	"Answer the session to which this entry point is associated."

	<category: 'accessing-conveniance'>
	^WACurrentSession value
    ]
]



Object subclass: WARenderingContext [
    | session actionUrl count callbacks document mode properties |
    
    <category: 'Seaside-Core-Callbacks'>
    <comment: nil>

    WARenderingContext class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    absoluteUrlForResource: aString [
	<category: 'accessing'>
	| url |
	(aString isNil or: [aString includesSubString: '://']) ifTrue: [^aString].
	url := self session application resourceBaseUrl.
	url ifNil: [^aString].
	^url , aString
    ]

    actionUrl [
	"Answer the value of actionUrl"

	<category: 'accessing'>
	^actionUrl
    ]

    actionUrl: anObject [
	<category: 'accessing'>
	actionUrl := anObject
    ]

    advanceKey [
	<category: 'callbacks'>
	| key |
	key := self nextKey.
	self increaseKey.
	^key
    ]

    callbackAt: aString [
	<category: 'callbacks'>
	^callbacks at: aString ifAbsent: []
    ]

    callbackStreamForRequest: aRequest [
	<category: 'callbacks'>
	^WACallbackStream callbacks: callbacks request: aRequest
    ]

    callbacksFor: anObject [
	<category: 'callbacks'>
	^WACallbackRegistry context: self owner: anObject
    ]

    clearMode [
	<category: 'modes'>
	mode := nil
    ]

    count [
	<category: 'accessing'>
	^count
    ]

    count: anInteger [
	<category: 'accessing'>
	count := anInteger
    ]

    debugMode [
	<category: 'modes'>
	mode := #debug
    ]

    document [
	"Answer the value of document"

	<category: 'accessing'>
	^document
    ]

    document: anObject [
	"Set the value of document"

	<category: 'accessing'>
	document := anObject
    ]

    increaseKey [
	<category: 'callbacks'>
	count contents: count contents + 1
    ]

    initialize [
	<category: 'initialize-release'>
	count := WAValueHolder with: 1.
	callbacks := Dictionary new
    ]

    isDebugMode [
	<category: 'modes'>
	^mode = #debug
    ]

    nextKey [
	<category: 'callbacks'>
	^count contents seasideString
    ]

    properties [
	<category: 'accessing'>
	^properties ifNil: [properties := Dictionary new]
    ]

    propertyAt: key ifAbsent: aBlock [
	<category: 'accessing'>
	^self properties at: key ifAbsent: aBlock
    ]

    propertyAt: key put: value [
	<category: 'accessing'>
	^self properties at: key put: value
    ]

    registry [
	<category: 'documents'>
	^WACurrentSession value application
    ]

    release [
	<category: 'initialize-release'>
	super release.
	document := nil
    ]

    session [
	<category: 'accessing'>
	^session
    ]

    session: aSession [
	<category: 'accessing'>
	session := aSession
    ]

    storeCallback: aCallback [
	<category: 'callbacks'>
	| key |
	key := self advanceKey.
	callbacks at: (aCallback convertKey: key) put: aCallback.
	^key
    ]

    urlForDocument: anObject [
	<category: 'documents'>
	^self urlForDocument: anObject mimeType: nil
    ]

    urlForDocument: anObject mimeType: mimeString [
	<category: 'documents'>
	^self 
	    urlForDocument: anObject
	    mimeType: mimeString
	    fileName: nil
    ]

    urlForDocument: anObject mimeType: mimeType fileName: fileName [
	<category: 'documents'>
	^(self registry urlForRequestHandler: (WADocumentHandler 
		    document: anObject
		    mimeType: mimeType
		    fileName: fileName)) 
	    seasideString
    ]
]



Object subclass: WAReportColumn [
    | clickBlock formatBlock hasTotal title sortBlock valueBlock |
    
    <category: 'Seaside-Core-Components-Widgets'>
    <comment: 'WAReportColumn displays a column, one cell at a time, of a WAReportTable. Columns can be sorted, have a title, can have a total, and its element can be links. The valueBlock obtains the output (an object) to display for each row from the row''s object.  The formatBlock is used to convert the valueBlock output to a string. If you need html markup to display the result, use the two argument form of valueBlock. However, columns with two argument valueBlock can not be sorted. See class methods for shortcut methods for setting the value block. 

For more information see:
	WATableReport

Instance Variables:
	clickBlock	<BlockClosure [:rowObject | ]>	When clickBlock is set items in column will be anchors. clickBlock is called with the selected object when anchor is clicked on. Typically clickBlock calls a component which generates a new page.
	formatBlock	<BlockClosure [:object | ]>	Should convert the result of the one-argument valueBlock to the string to be displayed. If formatBlock is nil then  "displayString" is sent to the result of valueBlock for the display string for this column.  
	hasTotal	<Boolean>	If true the column will display the sum of all elements in the column, sum is displayed in the last row.
	sortBlock	<BlockClosure [:a :b | ]>	Used to sort the element in the column. Arguments are the value from the one argument valueBlock
	title	<String>	Column header 
	valueBlock	<BlockClosure [:rowObject | ] or [:rowObject :aWARenderCanvas |] >	
		[:rowObject | ] this form results in an object that is to be displayed in a column cell, argument is the object for a given row (see WATableReport)
		[:rowObject :aWARenderCanvas |] this form is to render the value for a column cell from rowObject directly on aWRenderCanvas

'>

    WAReportColumn class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    WAReportColumn class >> renderBlock: aBlock title: aString [
	<category: 'instance creation'>
	^(self new)
	    title: aString;
	    valueBlock: aBlock;
	    yourself
    ]

    WAReportColumn class >> selector: aSymbol [
	<category: 'instance creation'>
	^self selector: aSymbol title: aSymbol capitalized
    ]

    WAReportColumn class >> selector: aSymbol title: aString [
	<category: 'instance creation'>
	^self 
	    selector: aSymbol
	    title: aString
	    onClick: nil
    ]

    WAReportColumn class >> selector: aSymbol title: aString onClick: aBlock [
	<category: 'instance creation'>
	^(self new)
	    title: aString;
	    selector: aSymbol;
	    clickBlock: aBlock;
	    yourself
    ]

    canChoose [
	<category: 'public'>
	^clickBlock notNil
    ]

    canRender [
	<category: 'rendering'>
	^valueBlock numArgs > 1
    ]

    canSort [
	<category: 'public'>
	^self canRender not and: [sortBlock notNil]
    ]

    chooseRow: row [
	<category: 'public'>
	^clickBlock value: row
    ]

    clickBlock: aBlock [
	<category: 'accessing'>
	clickBlock := aBlock
    ]

    columnClickBlock: aBlock [
	<category: 'accessing'>
	self clickBlock: [:r | aBlock value: (self valueForRow: r)]
    ]

    formatBlock: anObject [
	<category: 'accessing'>
	formatBlock := anObject
    ]

    hasTotal: aBoolean [
	<category: 'accessing'>
	hasTotal := aBoolean
    ]

    index: aNumber [
	<category: 'accessing'>
	valueBlock := [:row | row at: aNumber]
    ]

    initialize [
	<category: 'initialize-release'>
	formatBlock := [:x | x seasideString].
	sortBlock := [:a :b | a <= b].
	valueBlock := [:row | nil].
	clickBlock := nil.
	title := 'Untitled'.
	hasTotal := false
    ]

    renderValue: anObject on: html [
	<category: 'rendering'>
	valueBlock value: anObject value: html
    ]

    selector: aSymbol [
	<category: 'accessing'>
	valueBlock := [:row | row perform: aSymbol]
    ]

    sortBlock: anObject [
	<category: 'accessing'>
	sortBlock := anObject
    ]

    sortRows: anArray [
	<category: 'public'>
	| assocs |
	assocs := anArray collect: [:ea | ea -> (self valueForRow: ea)].
	assocs := assocs 
		    asSortedCollection: [:a :b | sortBlock value: a value value: b value].
	^assocs collect: [:ea | ea key]
    ]

    textForRow: row [
	<category: 'public'>
	^formatBlock value: (self valueForRow: row)
    ]

    title [
	<category: 'public'>
	^title
    ]

    title: aString [
	<category: 'accessing'>
	title := aString
    ]

    totalForRows: aCollection [
	<category: 'public'>
	^hasTotal 
	    ifFalse: ['']
	    ifTrue: 
		[formatBlock value: (aCollection detectSum: [:r | self valueForRow: r])]
    ]

    valueBlock: aBlock [
	<category: 'accessing'>
	valueBlock := aBlock
    ]

    valueForRow: row [
	<category: 'public'>
	^valueBlock value: row
    ]
]



Object subclass: WARequest [
    | url fields headers cookies method nativeRequest responseStream |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: 'I am a server independent http request object. Instance of me can be aquired through WASession >> #currentRequest'>

    WARequest class >> blankRequest [
	<category: 'instance-creation'>
	^self 
	    method: 'GET'
	    url: ''
	    headers: Dictionary new
	    fields: Dictionary new
	    cookies: Dictionary new
    ]

    WARequest class >> method: methodString url: urlString headers: headDict fields: fieldDict cookies: cookieDict [
	<category: 'instance-creation'>
	^self new 
	    setMethod: methodString
	    url: urlString
	    headers: headDict
	    fields: fieldDict
	    cookies: cookieDict
    ]

    WARequest class >> method: methodString url: urlString headers: headDict fields: fieldDict cookies: cookieDict nativeRequest: anObject [
	<category: 'instance-creation'>
	^(self 
	    method: methodString
	    url: urlString
	    headers: headDict
	    fields: fieldDict
	    cookies: cookieDict)
	    nativeRequest: anObject;
	    yourself
    ]

    accept [
	<category: 'accessing-headers'>
	^self headerAt: 'accept'
    ]

    acceptCharset [
	<category: 'accessing-headers'>
	^self headerAt: 'accept-charset'
    ]

    acceptEncoding [
	<category: 'accessing-headers'>
	^self headerAt: 'accept-encoding'
    ]

    acceptLanguage [
	<category: 'accessing-headers'>
	^self headerAt: 'accept-language'
    ]

    at: key [
	<category: 'accessing'>
	^fields at: key
    ]

    at: key ifAbsent: aBlock [
	<category: 'accessing'>
	^fields at: key ifAbsent: aBlock
    ]

    at: key ifPresent: aBlock [
	<category: 'accessing'>
	^fields at: key ifPresent: aBlock
    ]

    authorization [
	"Answer the basic authorization string from the request. This is the username and the password separated by a colon."

	<category: 'private'>
	| authorization |
	authorization := self headerAt: 'Authorization'
		    ifAbsent: [self headerAt: 'authorization'].
	^authorization isNil ifFalse: [self decodeAuthorization: authorization]
    ]

    cookieAt: aKey [
	<category: 'accessing-cookies'>
	^cookies ifNotNil: [:foo | cookies at: aKey ifAbsent: []]
    ]

    cookies [
	<category: 'accessing-cookies'>
	^cookies ifNil: [cookies := Dictionary new]
    ]

    decodeAuthorization: aString [
	<category: 'private'>
	^SeasidePlatformSupport base64Decode: (aString findTokens: ' ') last
    ]

    fields [
	<category: 'accessing'>
	^fields
    ]

    headerAt: aKey [
	<category: 'accessing'>
	^self headerAt: aKey ifAbsent: []
    ]

    headerAt: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	^headers at: aKey ifAbsent: aBlock
    ]

    headers [
	<category: 'accessing'>
	^headers
    ]

    host [
	<category: 'accessing-headers'>
	^self headerAt: 'host'
    ]

    includesKey: key [
	<category: 'testing'>
	^fields includesKey: key
    ]

    isGet [
	<category: 'testing'>
	^self method asUppercase = 'GET'
    ]

    isPrefetch [
	<category: 'testing'>
	^(self headerAt: 'HTTP_X_MOZ') = 'prefetch'
    ]

    isXmlHttpRequest [
	<category: 'testing'>
	^(self headerAt: 'x-requested-with') = 'XMLHttpRequest'
    ]

    method [
	<category: 'accessing'>
	^method
    ]

    nativeRequest [
	<category: 'accessing'>
	^nativeRequest
    ]

    nativeRequest: aRequest [
	<category: 'accessing'>
	nativeRequest := aRequest
    ]

    password [
	"Answer the password from basic authentication."

	<category: 'accessing'>
	| authorization |
	^(authorization := self authorization) isNil 
	    ifFalse: [authorization copyAfter: $:]
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    space;
	    nextPutAll: self method.
	aStream
	    space;
	    nextPutAll: self url
    ]

    referer [
	<category: 'accessing-headers'>
	^self headerAt: 'referer'
    ]

    responseStream [
	<category: 'accessing'>
	^responseStream
    ]

    responseStream: aStream [
	<category: 'accessing'>
	responseStream := aStream
    ]

    setMethod: methodString url: urlString headers: headDict fields: fieldDict cookies: cookieDict [
	<category: 'private'>
	method := methodString.
	url := urlString.
	headers := headDict.
	fields := fieldDict.
	cookies := cookieDict
    ]

    url [
	<category: 'accessing'>
	^url
    ]

    user [
	"Answer the username from basic authentication."

	<category: 'accessing'>
	| authorization |
	^(authorization := self authorization) isNil 
	    ifFalse: [authorization copyUpTo: $:]
    ]

    userAgent [
	<category: 'accessing-headers'>
	^self headerAt: 'user-agent'
    ]
]



Object subclass: WARequestHandler [
    | parent |
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'WARequestHandler is an abstract class whose subclasses handle http requests. Most of the methods are either empty or return a default value. 

Subclasses must implement the following messages:
	handleRequest:	process the request

Instance Variables:
	parent	<WADispatcher | WAApplication | nil> What owns or manages the handler. WADispatchers manage WADispatchers & WAApplications, WAApplications own WASessions

'>

    WARequestHandler class >> new [
	<category: 'instance-creation'>
	^self basicNew initialize
    ]

    description [
	"Answer a descriptive text of the receiver."

	<category: 'accessing'>
	^String new
    ]

    handleRequest: aRequest [
	"Handle aRequest and answer a response."

	<category: 'processing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initialization'>
	
    ]

    isActive [
	<category: 'testing'>
	^true
    ]

    isApplication [
	<category: 'testing'>
	^false
    ]

    isDispatcher [
	<category: 'testing'>
	^false
    ]

    isEntryPoint [
	<category: 'testing'>
	^false
    ]

    parent [
	"Answer the parent request handler of the receiver."

	<category: 'accessing'>
	^parent
    ]

    path [
	"Answer the path elements of the receiving request handler."

	<category: 'accessing'>
	^self parent isNil 
	    ifTrue: [OrderedCollection with: self name]
	    ifFalse: [self parent path addLast: self name]
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	parent := nil
    ]

    setParent: aRequestHandler [
	<category: 'initialization'>
	parent := aRequestHandler
    ]

    unregistered [
	<category: 'processing'>
	
    ]
]



WARequestHandler subclass: WADocumentHandler [
    | document mimeDocument mimeType fileName |
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'WADocumentHandler handles requests for images, text documents and binary files (byte arrays). This class is not normally used directly. A number of WA*Tag classes implement document:mimeType:fileName: which use WADocumentHandler. Given a document document:mimeType:fileName: creates a WADocumentHandler on the document, registers the handler with a dispatcher, and adds the correct url in the tag for the document.

Instance Variables:
	document	<ByteArray | GIFImage | Image | String | WACachedDocument | any class that understands #asMIMEDocumentType:>	contents of the document
	fileName	<String>	file containing the document to be sent as an attachment, nil if no such file
	mimeDocument	<MIMEDocument>	MIMEDocument object representing this document and mimeType, generates stream used to write document for the response. 
	mimeType	<String>	standard HTTP mime type
'>

    WADocumentHandler class >> document: anObject mimeType: mimeString fileName: fileString [
	<category: 'instance-creation'>
	^self basicNew 
	    initializeWithDocument: anObject
	    mimeType: mimeString
	    fileName: fileString
    ]

    = other [
	<category: 'comparing'>
	^other species = self species 
	    and: [other document = self document and: [other mimeType = self mimeType]]
    ]

    document [
	<category: 'accessing'>
	^document
    ]

    handleRequest: aRequest [
	<category: 'actions'>
	^self response
    ]

    hash [
	<category: 'comparing'>
	^self document hash bitXor: self mimeType hash
    ]

    initializeWithDocument: anObject mimeType: mimeString fileName: fileString [
	<category: 'initialization'>
	document := anObject.
	mimeString isNil ifFalse: [mimeType := mimeString toMimeType].
	fileName := fileString
    ]

    mimeDocument [
	<category: 'accessing'>
	^mimeDocument 
	    ifNil: [mimeDocument := document asMIMEDocumentType: mimeType]
    ]

    mimeType [
	<category: 'accessing'>
	^mimeType
    ]

    response [
	<category: 'accessing'>
	| response |
	response := WAResponse new.
	response contents: self mimeDocument contentStream.
	response 
	    contentType: (mimeType ifNil: [self mimeDocument contentType toMimeType]).
	response cacheForever.
	fileName ifNotNil: [:foo | response attachmentWithFileName: fileName].
	^response
    ]
]



WARequestHandler subclass: WAEntryPoint [
    | name configuration |
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'WAEntryPoint represents a named entry point to a request handler.

Given a seaside application URL, http://localhost:8008/seaside/tests/alltests, the path parts of the url are mapped to WARequestHandlers. "seaside" & "tests" map to WADispatchers, "alltests" maps to a WAApplication. These individual path parts are used as the names of the WARequestHandlers. WAEntryPoint is an abstract class that handles the name of WARequestHandlers. WAEntryPoint constructs the proper url path for this handler.

Instance Variables:
	name	<String>	the name or path part of this handler

'>

    WAEntryPoint class >> concreteSubclasses [
	<category: 'accessing'>
	^self allSubclasses reject: [:each | each isAbstract]
    ]

    WAEntryPoint class >> description [
	<category: 'accessing'>
	^nil
    ]

    WAEntryPoint class >> isAbstract [
	<category: 'testing'>
	^self description isNil
    ]

    WAEntryPoint class >> named: aString [
	<category: 'instance-creation'>
	^self new setName: aString
    ]

    WAEntryPoint class >> register: aString [
	<category: 'instance-creation'>
	^self register: aString in: WADispatcher default
    ]

    WAEntryPoint class >> register: aString in: aDispatcher [
	<category: 'instance-creation'>
	| path dispatcher |
	path := aString findTokens: '/'.
	dispatcher := path allButLast inject: aDispatcher
		    into: 
			[:result :each | 
			result entryPoints at: each
			    ifAbsent: [result register: (WADispatcher named: each)]].
	^dispatcher register: (self named: path last)
    ]

    basePath [
	<category: 'accessing'>
	^self parent isNil 
	    ifTrue: [self name isEmpty ifTrue: [''] ifFalse: ['/' , self name]]
	    ifFalse: [self parent basePath , '/' , self name]
    ]

    baseUrl [
	<category: 'public'>
	^(WAUrl new)
	    addToPath: self basePath;
	    yourself
    ]

    configuration [
	"Answer a default user configuration for the receiver."

	<category: 'preferences'>
	^configuration ifNil: [configuration := self defaultConfiguration]
    ]

    defaultConfiguration [
	<category: 'configuration'>
	^WAUserConfiguration new
    ]

    description [
	<category: 'accessing'>
	^self class description
    ]

    isEntryPoint [
	<category: 'testing'>
	^true
    ]

    isRoot [
	<category: 'testing'>
	^false
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	configuration := configuration copy
    ]

    preferenceAt: aSymbol [
	<category: 'preferences'>
	^self configuration valueAt: aSymbol
    ]

    preferenceAt: aSymbol put: anObject [
	<category: 'preferences'>
	^self configuration valueAt: aSymbol put: anObject
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' named: ';
	    print: self name
    ]

    setName: aString [
	<category: 'initialization'>
	name := aString
    ]
]



WAEntryPoint subclass: WADispatcher [
    | entryPoints defaultName |
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'WADispatcher takes http requests and dispatches them to the correct handler (WAApplication, WAFileHandler, WANotFoundHandler, etc). 

WADispatcher class>>default is the top level dispatcher. When a Seaside application is registered as "foo" the application is added to the top level dispatcher. The application is added to the entryPoints of the dispatcher at the key "foo". If a Seaside application is registered as "bar/foo" then the application isadded to a  dispatcher''s entryPoints at the key "foo". That dispatcher is in the top level dispatcher''s  entryPoints at the key "bar". 
  
When a http request is received it is sent to WADispatcher class>>default to find the correct handler for the request. If a handler exists for the request is sent to that handler. Otherwise the request is sent to WANotFoundHandler.

The VW port maintains multiple copies of the tree of dispatchers rooted at WADispatcher class>>default. One copy is for each different URL that can reach Seaside (http://..../seaside/go/counter - normal, http://..../counter - SeasideShortPath, http://..../seaside/stream/counter - streaming). 

Instance Variables:
	defaultName	<String>
	entryPoints	<(Dictionary of: (WAApplication | WADispatcher | WAFileHandler))>	 the keys are strings, which are the names and URL path segments for the handler at that key
	lastUpdate	<TimeStamp>	Time the dispatcher was last changed
	version	<SmallInteger>	Each time the dispatcher is changed the version is increased by 1
'>

    WADispatcher class [
	| default |
	
    ]

    WADispatcher class >> default [
	<category: 'accessing'>
	^default 
	    ifNil: [default := self named: SeasidePlatformSupport defaultDispatcherName]
    ]

    WADispatcher class >> description [
	<category: 'accessing'>
	^'Dispatcher'
    ]

    WADispatcher class >> resetAll [
	"To have this todo list somewhere,
	 May be used in the WADispatcher tests"

	<category: 'initialization'>
	default := nil.
	WAEntryPoint allSubclasses do: [:each | each initialize].
	WAComponent allSubclasses do: [:each | each initialize]
    ]

    defaultName [
	<category: 'accessing'>
	^defaultName
    ]

    defaultName: aString [
	<category: 'accessing'>
	defaultName := aString
    ]

    entryPointAt: aString [
	<category: 'accessing'>
	^(aString findTokens: '/') inject: self
	    into: [:dispatcher :token | dispatcher entryPoints at: token]
    ]

    entryPoints [
	<category: 'accessing'>
	^entryPoints
    ]

    handleRequest: aRequest [
	<category: 'processing'>
	aRequest isPrefetch ifTrue: [^WAResponse forbidden: aRequest url].
	^(self handlerForRequest: aRequest) handleRequest: aRequest
    ]

    handlerForRequest: aRequest [
	<category: 'processing'>
	^self handlerForRequest: aRequest relativeTo: self basePath
    ]

    handlerForRequest: aRequest relativeTo: aString [
	<category: 'processing'>
	| fullUrl relativeUrl handlerName |
	fullUrl := aRequest url.
	(aString isEmpty or: [fullUrl startsWith: aString]) 
	    ifTrue: 
		[relativeUrl := fullUrl allButFirst: aString size.
		handlerName := (relativeUrl notEmpty and: [relativeUrl first = $/]) 
			    ifTrue: [(relativeUrl findTokens: '/') at: 1 ifAbsent: [self defaultName]]
			    ifFalse: [self defaultName].
		^self entryPoints at: handlerName
		    ifAbsent: 
			[self entryPoints at: self defaultName ifAbsent: [WANotFoundHandler new]]].
	^WANotFoundHandler new
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	entryPoints := Dictionary new
    ]

    isDispatcher [
	<category: 'testing'>
	^true
    ]

    isRoot [
	<category: 'testing'>
	^self parent isNil
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	entryPoints := entryPoints 
		    valuesCollect: [:each | each copy setParent: self]
    ]

    register: anEntryPoint [
	<category: 'registration'>
	anEntryPoint name 
	    ifNil: [self error: 'Unable to add unnamed entry point.'].
	entryPoints at: anEntryPoint name put: (anEntryPoint setParent: self).
	^anEntryPoint
    ]

    unregister: anEntryPoint [
	<category: 'registration'>
	entryPoints removeKey: anEntryPoint name ifAbsent: [^nil].
	^anEntryPoint unregistered
    ]
]



WAEntryPoint subclass: WAFileHandler [
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'Seaside serves static files using WALibrary subclasses. WAFileHandler handles all requests for WALibrary files (or methods) for all applications on the Seaside server. WAFileHandler is registered with the default WADispatcher automatically.'>

    WAFileHandler class [
	| default |
	
    ]

    WAFileHandler class >> default [
	<category: 'accessing'>
	^default
    ]

    WAFileHandler class >> description [
	<category: 'accessing'>
	^'File Library'
    ]

    WAFileHandler class >> initialize [
	<category: 'initialization'>
	default := self register: 'files'
    ]

    handleRequest: aRequest [
	<category: 'processing'>
	^self responseAt: (aRequest url findTokens: $/)
	    ifAbsent: [self notFound: aRequest url]
    ]

    libraries [
	<category: 'accessing'>
	^self libraryRootClasses gather: [:each | each allSubclasses]
    ]

    librariesDo: aOneArgumentBlock [
	<category: 'private'>
	self libraryRootClasses 
	    do: [:each | each allSubclassesDo: aOneArgumentBlock]
    ]

    libraryAt: aSymbol ifAbsent: aBlock [
	<category: 'accessing'>
	self librariesDo: [:each | (each handlesFolder: aSymbol) ifTrue: [^each]].
	^aBlock value
    ]

    libraryRootClasses [
	<category: 'private'>
	^WALibrary subclasses
    ]

    notFound: aString [
	<category: 'private'>
	^WAResponse notFound: aString
    ]

    responseAt: aPath ifAbsent: aBlock [
	<category: 'private'>
	| libraryName fileName libraryClass |
	libraryName := aPath at: aPath size - 1.
	fileName := aPath last.
	libraryClass := self libraryAt: libraryName asSymbol
		    ifAbsent: [^aBlock value].
	^libraryClass documentAt: fileName ifAbsent: aBlock
    ]
]



WAEntryPoint subclass: WAFileSystem [
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: nil>

    WAFileSystem class >> description [
	<category: 'accessing'>
	^'File Directory'
    ]

    asAbsoluteUrl: aFileName relativeTo: aRequest [
	<category: 'private'>
	| url |
	url := aRequest url.
	^(url isEmpty or: [url last ~= $/]) 
	    ifTrue: [url , '/' , aFileName]
	    ifFalse: [url , aFileName]
    ]

    defaultConfiguration [
	<category: 'configuration'>
	^super defaultConfiguration addAncestor: WAFileSystemConfiguration new
    ]

    directory [
	<category: 'accessing'>
	^self configuration valueAt: #directory
    ]

    handleRequest: aRequest [
	<category: 'processing'>
	^[self processRequest: aRequest] on: Error
	    do: [:err | WAResponse notFound: aRequest url]
    ]

    listing [
	<category: 'accessing'>
	^self configuration valueAt: #listing
    ]

    listing: aString forRequest: aRequest [
	<category: 'private'>
	^(WARenderCanvas builder)
	    fullDocument: true;
	    rootBlock: [:html | html title: aRequest url];
	    render: 
		    [:html | 
		    (html heading)
			level: 1;
			with: aRequest url.
		    html unorderedList: 
			    [(SeasidePlatformSupport filesIn: aString) do: 
				    [:each | 
				    | localName |
				    localName := SeasidePlatformSupport localNameOf: each.
				    html listItem: 
					    [(html anchor)
						url: (self asAbsoluteUrl: localName relativeTo: aRequest);
						with: localName]]]]
    ]

    mimetypeForRequest: aRequest [
	<category: 'private'>
	^SeasidePlatformSupport mimeDocumentClass guessTypeFromName: aRequest url
    ]

    pathForRequest: aRequest [
	<category: 'private'>
	^self directory , (aRequest url allButFirst: self basePath size)
    ]

    processDirectory: aString request: aRequest [
	<category: 'processing'>
	^(WAResponse new)
	    contentType: 'text/html';
	    nextPutAll: (self listing: aString forRequest: aRequest)
    ]

    processFile: aString request: aRequest [
	<category: 'processing'>
	^WAResponse 
	    document: (SeasidePlatformSupport contentsOfFile: aString binary: true)
	    mimeType: (self mimetypeForRequest: aRequest)
	    fileName: (aRequest url copyAfterLast: $/)
    ]

    processRequest: aRequest [
	<category: 'processing'>
	| path |
	path := self pathForRequest: aRequest.
	^(self listing and: [path endsWith: '/']) 
	    ifTrue: [self processDirectory: path request: aRequest]
	    ifFalse: [self processFile: path request: aRequest]
    ]
]



WAEntryPoint subclass: WARegistry [
    | keysByHandler handlersByKey mutex |
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'WARegistry maintains sessions for a Seaside application. Each session has a key, which is the _s part of Seaside URLs and is embedded in links on pages generated by Seaside. WARegistry checks requests for session keys. If one exists, the request is sent to the proper session. If not the request is a new request so handleDefaultRequest: is called so subclasses can handle the request.

Subclasses must implement the following messages:
	handleDefaultRequest:
		Handle a request without a session key, ie a new request.

Instance Variables:
	handlersByKey	<Dictionary of <session key(string),WASession>>	provides easy access to the session for a session key
	keysByHandler	<Dictionary of <WASession, session key(string)>>	provides easy access to the session key of a session
	mutex	<Semaphore>	Used to insure keysByHandler & handlersByKey are updated atomically
'>

    WARegistry class >> clearAllHandlers [
	<category: 'initialization'>
	self allSubinstancesDo: [:each | each clearHandlers]
    ]

    clearHandlers [
	<category: 'public'>
	| handlers |
	self mutex critical: 
		[handlers := handlersByKey.
		handlersByKey := SeasidePlatformSupport reducedConflictDictionary new.
		keysByHandler := SeasidePlatformSupport reducedConflictDictionary new].
	handlers 
	    ifNotNil: [:foo | [handlers do: [:each | each unregistered]] fork]
    ]

    ensureKeyForHandler: anObject [
	<category: 'public'>
	^(self keyOrNilForHandler: anObject) 
	    ifNil: [self registerRequestHandler: anObject]
    ]

    expiryPathFor: aRequest [
	<category: 'private'>
	^aRequest url
    ]

    handleDefaultRequest: aRequest [
	<category: 'private'>
	self subclassResponsibility
    ]

    handleExpiredRequest: aRequest [
	<category: 'private'>
	| url |
	aRequest isXmlHttpRequest ifTrue: [^WAResponse new forbidden].
	url := WAUrl new.
	url addToPath: (self expiryPathFor: aRequest).
	url takeServerParametersFromRequest: aRequest.
	aRequest isGet 
	    ifTrue: 
		[aRequest fields keysAndValuesDo: 
			[:key :value | 
			(url isSeasideField: key) ifFalse: [url addParameter: key value: value]]].
	^self redirectResponseFor: url
    ]

    handleKeyRequest: aRequest [
	<category: 'private'>
	"Under some circumstances, HTTP fields are collections of values"

	| key handler keyString |
	key := 
		[keyString := aRequest at: self handlerField.
		(keyString isKindOf: OrderedCollection) 
		    ifTrue: [keyString := keyString first].
		WAExternalID fromString: keyString] 
			on: Error
			do: [:e | nil].
	handler := handlersByKey at: key ifAbsent: [nil].
	^(handler notNil and: [handler isActive]) 
	    ifTrue: [handler handleRequest: aRequest]
	    ifFalse: [self handleExpiredRequest: aRequest]
    ]

    handleRequest: aRequest [
	<category: 'public'>
	^(aRequest fields includesKey: self handlerField) 
	    ifTrue: [self handleKeyRequest: aRequest]
	    ifFalse: [self handleDefaultRequest: aRequest]
    ]

    handlerField [
	<category: 'private'>
	^'_s'
    ]

    initialize [
	<category: 'private'>
	super initialize.
	self clearHandlers
    ]

    isSeasideField: aString [
	<category: 'private'>
	^aString notEmpty and: [aString first = $_]
    ]

    keyOrNilForHandler: anObject [
	<category: 'private'>
	^self mutex critical: [keysByHandler at: anObject ifAbsent: [nil]]
    ]

    mutex [
	<category: 'private'>
	^mutex 
	    ifNil: [mutex := SeasidePlatformSupport semaphoreClass forMutualExclusion]
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	self clearHandlers.
	mutex := nil
    ]

    redirectResponseFor: aUrl [
	<category: 'private'>
	^WAResponse redirectTo: aUrl seasideString
    ]

    registerRequestHandler: anObject [
	<category: 'private'>
	| key |
	key := WAExternalID new: 16.
	self shouldCollectHandlers ifTrue: [self unregisterExpiredHandlers].
	self mutex critical: 
		[handlersByKey at: key put: anObject.
		keysByHandler at: anObject put: key].
	^key
    ]

    shouldCollectHandlers [
	<category: 'private'>
	^handlersByKey size \\ 10 = 0
    ]

    unregisterExpiredHandlers [
	"Private - Unregisters the receiver expired handlers."

	<category: 'private'>
	| expired newHandlersByKey newKeysByHandler |
	expired := OrderedCollection new.
	newHandlersByKey := SeasidePlatformSupport reducedConflictDictionary new.
	newKeysByHandler := SeasidePlatformSupport reducedConflictDictionary new.
	self mutex critical: 
		[handlersByKey keysAndValuesDo: 
			[:key :value | 
			value isActive 
			    ifFalse: [expired add: value]
			    ifTrue: 
				[newHandlersByKey at: key put: value.
				newKeysByHandler at: value put: key]].
		handlersByKey := newHandlersByKey.
		keysByHandler := newKeysByHandler].
	[expired do: [:each | each unregistered]] fork
    ]

    unregistered [
	<category: 'private'>
	super unregistered.
	self clearHandlers
    ]

    urlForRequestHandler: anObject [
	<category: 'public'>
	| key url |
	key := self ensureKeyForHandler: anObject.
	url := self baseUrl.
	url addParameter: self handlerField value: key seasideString.
	^url
    ]
]



WARegistry subclass: WAApplication [
    
    <category: 'Seaside-Core-Session'>
    <comment: 'WAApplication is the starting point for a Seaside application. When a WAComponent is registered as a top level component a WAApplication object is added to a WADispatcher. The dispatcher forwards all requests to the WAApplication, which in turn forwards them to the correct WASession object. WAApplication''s parent class WARegistry maintains a list of all active sessions to the application. 

"configuration" contains a chain of WAConfituration classes that define attributes of the application. The attribute "rootComponent", for example, defines the top level WAComponent class for the application. The configuration chain includes WAUserConfiguration, WAGlobalConfiguration, WARenderLoopConfiguration and WASessionConfiguration. Other configurations can be added to the chain when the top level application is registered with a dispatcher. (See below)

"libraries" is a collection of WALibrary classes, which are used to serve css, javascript and images used by the application. These may be in methods or in files. Sometimes these libraries are replaced by static files served by Apache. See WAFileLibrary class comment for more information.

Registering an Application.
	An application can be registered with a dispatcher by using the Seaside configuration page or via code. Below MyComponent is a subclass of WAComponent. The following registers the component as an application, gives some values to attributes (or preferences) and adds a library and a configuration. 

MyComponent class>>initialize
	"self initialize"
	| application |
	application := self registerAsApplication: ''sample''.
	application preferenceAt: #sessionClass put: Glorp.WAGlorpSession.
	application addLibrary: SampleLibrary.
	application configuration addAncestor: GlorpConfiguration new.
	application preferenceAt: #glorpDatabasePlatform put: Glorp.PostgreSQLPlatform.
	application preferenceAt: #databaseServer put: ''127.0.0.1''.
	application preferenceAt: #databaseConnectString put: ''glorptests''.

MyComponent>>someInstanceMethod
	"example of how to access attributes (preferences)"
	self session application preferenceAt: #glorpDatabasePlatform'>

    WAApplication class >> description [
	<category: 'accessing'>
	^'Application'
    ]

    addLibrary: aLibraryClass [
	<category: 'libraries'>
	self preferenceAt: #libraries put: (self libraries copyWith: aLibraryClass)
    ]

    baseUrl [
	<category: 'accessing'>
	| serverPath |
	serverPath := self serverPath.
	^(serverPath isNil 
	    ifTrue: [super baseUrl]
	    ifFalse: [WAUrl new addToPath: serverPath])
	    scheme: self serverProtocol;
	    hostname: self serverHostname;
	    port: self serverPort;
	    yourself
    ]

    decorationClasses [
	<category: 'configuration'>
	^self preferenceAt: #decorationClasses
    ]

    defaultConfiguration [
	<category: 'configuration'>
	^super defaultConfiguration addAncestor: WARenderLoopConfiguration new
    ]

    deploymentMode [
	<category: 'configuration'>
	^self preferenceAt: #deploymentMode
    ]

    handleDefaultRequest: aRequest [
	<category: 'request handling'>
	^(self sessionClass new setParent: self) handleRequest: aRequest
    ]

    handleExpiredRequest: aRequest [
	<category: 'request handling'>
	| response |
	response := super handleExpiredRequest: aRequest.
	(aRequest cookieAt: self handlerCookieName) isNil 
	    ifFalse: [response deleteCookieAt: self handlerCookieName].
	^response
    ]

    handleRequest: aRequest [
	<category: 'request handling'>
	| cookie |
	cookie := aRequest cookieAt: self handlerCookieName.
	cookie isNil 
	    ifFalse: [aRequest fields at: self handlerField ifAbsentPut: [cookie]].
	^super handleRequest: aRequest
    ]

    handlerCookieName [
	<category: 'accessing'>
	^self name
    ]

    isApplication [
	<category: 'testing'>
	^true
    ]

    libraries [
	<category: 'configuration'>
	^self preferenceAt: #libraries
    ]

    login [
	<category: 'configuration'>
	^self preferenceAt: #login
    ]

    password [
	<category: 'configuration'>
	^self preferenceAt: #password
    ]

    redirectHandler [
	<category: 'configuration'>
	^self preferenceAt: #redirectHandler
    ]

    removeLibrary: aLibraryClass [
	<category: 'libraries'>
	self preferenceAt: #libraries
	    put: (self libraries copyWithout: aLibraryClass)
    ]

    resourceBaseUrl [
	<category: 'configuration'>
	^self preferenceAt: #resourceBaseUrl
    ]

    rootComponent [
	<category: 'configuration'>
	^self preferenceAt: #rootComponent
    ]

    serverHostname [
	<category: 'configuration'>
	^self preferenceAt: #serverHostname
    ]

    serverPath [
	<category: 'configuration'>
	^self preferenceAt: #serverPath
    ]

    serverPort [
	<category: 'configuration'>
	^self preferenceAt: #serverPort
    ]

    serverProtocol [
	<category: 'configuration'>
	^self preferenceAt: #serverProtocol
    ]

    sessionClass [
	<category: 'configuration'>
	^self preferenceAt: #sessionClass
    ]

    sessionExpirySeconds [
	<category: 'configuration'>
	^self preferenceAt: #sessionExpirySeconds
    ]

    updateRoot: anHtmlRoot [
	<category: 'request handling'>
	self libraries do: [:each | each default updateRoot: anHtmlRoot]
    ]

    updateUrl: anUrl [
	<category: 'request handling'>
	
    ]

    useSessionCookie [
	<category: 'configuration'>
	^self preferenceAt: #useSessionCookie
    ]
]



WARequestHandler subclass: WAExpiringHandler [
    | lastAccess expired timeout |
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'WAExpiringHandler is an abstract class that times out when the time between requests is longer than the value of "timeout"

Subclasses must implement the following messages:
	incomingRequest:
		subclass handles the request in this method

Instance Variables:
	expired	<Boolean>	True if handler has times out
	lastAccess	<Time>	Time the handler was last accessed
	timeout	<Integer>	Length of time in seconds handler will timeout without a request
'>

    defaultTimeoutSeconds [
	<category: 'defaults'>
	^600
    ]

    expire [
	<category: 'actions'>
	expired := true
    ]

    expired [
	<category: 'testing'>
	^expired
    ]

    handleRequest: aRequest [
	<category: 'processing'>
	lastAccess := Time secondClock.
	^self incomingRequest: aRequest
    ]

    incomingRequest: aRequest [
	<category: 'processing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	expired := false
    ]

    isActive [
	<category: 'testing'>
	^self expired not and: [self secondsSinceLastAccess < self timeoutSeconds]
    ]

    lastAccess [
	<category: 'accessing'>
	^lastAccess ifNil: [lastAccess := Time secondClock]
    ]

    secondsSinceLastAccess [
	<category: 'accessing'>
	^Time secondClock - self lastAccess
    ]

    timeoutSeconds [
	<category: 'accessing'>
	^timeout ifNil: [timeout := self defaultTimeoutSeconds]
    ]

    timeoutSeconds: aNumber [
	<category: 'accessing'>
	timeout := aNumber
    ]
]



WAExpiringHandler subclass: WASession [
    | continuations lastContinuation escapeContinuation monitor currentRequest scripts jumpTo cookiesEnabled |
    
    <category: 'Seaside-Core-Session'>
    <comment: 'I am a Seaside session. A new instance of me gets created when an user accesses an application for the first time and is persistent as long as the user is interacting with it.

This class is intended to be subclasses by applications that need global state, like a user. Custom state can be added by creating instance variables and storing it there. The session can be retrieved by #session if inside a component or task or by evaluating: WACurrentSession value

If the session has not been used for #defaultTimeoutSeconds, it is garbage collected by the system. To manually expire a session call #expire.

A good way to clear all sessions is the following code:

WARegistry clearAllHandlers.
Smalltalk garbageCollect'>

    actionField [
	<category: 'accessing'>
	^'_k'
    ]

    actionUrlForContinuation: aContinuation [
	<category: 'accessing'>
	^self 
	    actionUrlForKey: (continuations store: (lastContinuation := aContinuation))
    ]

    actionUrlForKey: aString [
	<category: 'accessing'>
	| url |
	url := self application urlForRequestHandler: self.
	self useSessionCookie 
	    ifTrue: [url parameters removeKey: self application handlerField].
	url takeServerParametersFromRequest: currentRequest.
	url addParameter: self actionField value: aString.
	jumpTo ifNotNil: [:foo | url fragment: jumpTo].
	^url
    ]

    addLoadScript: aString [
	<category: 'scripts'>
	^(scripts ifNil: [scripts := OrderedCollection new]) add: aString
    ]

    application [
	<category: 'accessing'>
	^parent
    ]

    baseUrl [
	<category: 'accessing'>
	^self parent baseUrl
    ]

    charSet [
	<category: 'http'>
	^WAResponse defaultValueForCharSet	"utf-8"
    ]

    checkCookiesField [
	<category: 'private'>
	^'_c'
    ]

    clearJumpTo [
	<category: 'scripts'>
	jumpTo := nil
    ]

    clearLoadScripts [
	<category: 'scripts'>
	scripts := nil
    ]

    closePopup [
	<category: 'responding'>
	^self respond: 
		[:url | 
		(WAResponse new)
		    nextPutAll: '<html><script>';
		    nextPutAll: 'self.close();';
		    nextPutAll: 'self.opener.location=self.opener.location';
		    nextPutAll: '</script></html>';
		    yourself]
    ]

    closePopupAndContinue [
	<category: 'responding'>
	^self respond: 
		[:url | 
		(WAResponse new)
		    nextPutAll: '<html><script>';
		    nextPutAll: 'self.close();';
		    nextPutAll: 'self.opener.location=';
		    nextPutAll: url seasideString printString;
		    nextPutAll: '</script></html>';
		    yourself]
    ]

    closePopupWithoutReloadingOpener [
	<category: 'responding'>
	^self respond: 
		[:url | 
		(WAResponse new)
		    nextPutAll: '<html><script>';
		    nextPutAll: 'self.close();';
		    nextPutAll: '</script></html>';
		    yourself]
    ]

    contentType [
	<category: 'http'>
	^(WAMimeType fromString: self mimeType)
	    charset: self charSet;
	    yourself
    ]

    currentRequest [
	"Returns the current http request, instance of WARequest"

	<category: 'accessing'>
	^currentRequest
    ]

    currentRequest: aRequest [
	"for testing only"

	<category: 'private'>
	currentRequest := aRequest
    ]

    defaultTimeoutSeconds [
	<category: 'expiring'>
	^(self application isNil or: [self application sessionExpirySeconds isNil]) 
	    ifFalse: [self application sessionExpirySeconds]
	    ifTrue: [super defaultTimeoutSeconds]
    ]

    errorHandler [
	<category: 'accessing-preferences'>
	^self application preferenceAt: #errorHandler
    ]

    fieldsAt: key [
	<category: 'request handling'>
	^self currentRequest at: key
    ]

    fieldsAt: key ifAbsent: aBlock [
	<category: 'request handling'>
	^self currentRequest at: key ifAbsent: aBlock
    ]

    fieldsAt: key ifPresent: aBlock [
	<category: 'request handling'>
	^self currentRequest at: key ifPresent: aBlock
    ]

    incomingRequest: aRequest [
	<category: 'request handling'>
	((aRequest fields includesKey: 'terminate') 
	    and: [self application deploymentMode not]) 
		ifTrue: 
		    [monitor terminate.
		    ^WAResponse new nextPutAll: 'Process terminated'].
	^monitor critical: [self responseForRequest: aRequest]
	    ifError: [:error | self errorHandler internalError: error]
    ]

    initialize [
	<category: 'initializing'>
	super initialize.
	continuations := WALRUCache new.
	monitor := WAProcessMonitor new.
	cookiesEnabled := true
    ]

    jumpToAnchor: aString [
	<category: 'scripts'>
	jumpTo := aString
    ]

    mainClass [
	<category: 'accessing-preferences'>
	^self application preferenceAt: #mainClass
    ]

    mimeType [
	<category: 'http'>
	^WAResponse defaultValueForMimeType	"text/html"
    ]

    newSessionUrl [
	<category: 'responding'>
	^self baseUrl takeServerParametersFromRequest: currentRequest
    ]

    onLoadScripts [
	<category: 'scripts'>
	^scripts ifNil: [#()]
    ]

    onRespond: aBlock [
	<category: 'responding'>
	| previous |
	previous := escapeContinuation.
	escapeContinuation := 
		[:response | 
		aBlock value: response.
		previous value: response]
    ]

    outputDocumentClass [
	"To be subclassed as needed"

	<category: 'accessing'>
	^WAHtmlStreamDocument
    ]

    pageExpired [
	<category: 'expiring'>
	((lastContinuation isKindOf: WASessionContinuation) 
	    and: [lastContinuation states notNil]) 
		ifTrue: [lastContinuation states restore].
	self 
	    respond: [:url | self application redirectHandler redirectPageExpiredTo: url].
	WAPageExpired signal
    ]

    pageIntentionallyLeftBlank [
	<category: 'responding'>
	self returnResponse: WAResponse new
    ]

    performRequest: aRequest [
	<category: 'processing'>
	| key continuation |
	key := aRequest fields at: self actionField
		    ifAbsent: [^self start: aRequest].
	((aRequest fields includesKey: self checkCookiesField) 
	    and: [aRequest cookies isEmpty]) ifTrue: [cookiesEnabled := false].
	(key isKindOf: OrderedCollection) ifTrue: [key := key first].
	continuation := continuations at: key
		    ifAbsent: [^self unknownRequest: aRequest].
	^continuation value: aRequest
    ]

    redirect [
	<category: 'redirecting'>
	^self respond: [:url | self redirectResponseFor: url]
    ]

    redirectResponseFor: aUrl [
	<category: 'redirecting'>
	^self application redirectHandler redirectTo: aUrl
    ]

    redirectTo: anUrl [
	<category: 'redirecting'>
	self returnResponse: (self redirectResponseFor: anUrl)
    ]

    redirectWithCookie: aCookie [
	<category: 'redirecting'>
	| response |
	self respond: 
		[:url | 
		url addParameter: self checkCookiesField.
		response := self redirectResponseFor: url.
		response addCookie: aCookie.
		response]
    ]

    redirectWithMessage: aString delay: aNumber [
	<category: 'redirecting'>
	self respond: 
		[:url | 
		WAResponse 
		    refreshWithMessage: aString
		    location: url seasideString
		    delay: aNumber]
    ]

    registerObjectForBacktracking: anObject [
	<category: 'deprecated'>
	self 
	    deprecatedApi: '#registerObjectForBacktracking: is not supported, implement #states to backtrack your object'
    ]

    respond: aBlock [
	<category: 'responding'>
	^ResponseContinuation currentDo: [:cc | self respond: aBlock onAnswer: cc]
    ]

    respond: aBlock onAnswer: aContinuation [
	<category: 'responding'>
	| url response |
	url := self actionUrlForContinuation: aContinuation.
	response := aBlock value: url.
	self returnResponse: response
    ]

    responseForRequest: aRequest [
	<category: 'request handling'>
	currentRequest := aRequest.
	^self withEscapeContinuation: 
		[WACurrentSession use: self
		    during: [self withErrorHandler: [self performRequest: aRequest]]]
    ]

    returnResponse: aResponse [
	"aborts all further processing and directly returns aResponse
	 aResponse instance of WAResponse"

	<category: 'responding'>
	escapeContinuation value: aResponse
    ]

    script: aString [
	<category: 'responding'>
	self redirectWithMessage: '<script>' , aString , '</script>' delay: 0
    ]

    sessionCookie [
	<category: 'accessing'>
	^WACookie key: self application handlerCookieName
	    value: (self application ensureKeyForHandler: self) seasideString
    ]

    start: aRequest [
	<category: 'processing'>
	self useSessionCookie 
	    ifTrue: [self redirectWithCookie: self sessionCookie].
	^self mainClass new start: aRequest
    ]

    unknownRequest: aRequest [
	<category: 'request handling'>
	self start: aRequest
    ]

    unregistered [
	<category: 'private'>
	super unregistered.
	self expire
    ]

    updateRoot: anHtmlRoot [
	<category: 'updating'>
	self application updateRoot: anHtmlRoot.
	anHtmlRoot meta contentType: self contentType.
	anHtmlRoot meta contentScriptType: 'text/javascript' toMimeType.
	(anHtmlRoot htmlAttributes)
	    at: 'xmlns' put: 'http://www.w3.org/1999/xhtml';
	    at: 'xml:lang' put: 'en';
	    at: 'lang' put: 'en'.
	anHtmlRoot beXhtml10Strict.
	anHtmlRoot title: 'Seaside'
    ]

    updateStates: aSnapshot [
	<category: 'updating'>
	
    ]

    updateUrl: anUrl [
	<category: 'updating'>
	self application updateUrl: anUrl
    ]

    useSessionCookie [
	<category: 'accessing-preferences'>
	^cookiesEnabled and: [self application useSessionCookie]
    ]

    withErrorHandler: aBlock [
	<category: 'request handling'>
	^
	[aBlock on: Error
	    do: 
		[:e | 
		self errorHandler handleError: e.
		WAPageExpired signal]] 
		on: Warning
		do: 
		    [:w | 
		    self errorHandler handleWarning: w.
		    WAPageExpired signal]
    ]

    withEscapeContinuation: aBlock [
	<category: 'request handling'>
	^EscapeContinuation currentDo: 
		[:cc | 
		escapeContinuation := cc.
		aBlock value.
		self pageIntentionallyLeftBlank]
    ]
]



WARequestHandler subclass: WANotFoundHandler [
    
    <category: 'Seaside-Core-RequestHandler'>
    <comment: 'WANotFoundHandler handles requests whose urls don''t map to a Seaside application.

'>

    handleRequest: aRequest [
	<category: 'actions'>
	^WAResponse notFound: aRequest url
    ]
]



Object subclass: WAResponse [
    | contentType headers cookies status stream |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: 'I am a server independent http response object. I am used in conjunction with WASession >> returnResponse:'>

    WAResponse class >> basicAuthWithRealm: aString [
	<category: 'instance creation'>
	^self new basicAuthenticationRealm: aString
    ]

    WAResponse class >> defaultHttpVersion [
	<category: 'defaults'>
	^'HTTP/1.0'
    ]

    WAResponse class >> defaultValueForCharSet [
	<category: 'defaults'>
	^'utf-8'
    ]

    WAResponse class >> defaultValueForContentType [
	<category: 'defaults'>
	^(WAMimeType fromString: self defaultValueForMimeType)
	    charset: self defaultValueForCharSet;
	    yourself
    ]

    WAResponse class >> defaultValueForMimeType [
	<category: 'defaults'>
	^'text/html'
    ]

    WAResponse class >> document: anObject mimeType: mimeType [
	<category: 'instance creation'>
	| document |
	document := anObject asMIMEDocumentType: mimeType.
	^(self new)
	    contentType: (mimeType ifNil: [document contentType toMimeType]);
	    cacheForever;
	    nextPutAll: document content;
	    yourself
    ]

    WAResponse class >> document: anObject mimeType: mimeString fileName: fileString [
	<category: 'instance creation'>
	^(self document: anObject mimeType: mimeString)
	    attachmentWithFileName: fileString;
	    yourself
    ]

    WAResponse class >> forbidden: locationString [
	| response content |
	response := self new forbidden.
	content := (WARenderCanvas builder)
		    fullDocument: true;
		    rootBlock: [:root | root title: 'Internal Error'];
		    render: 
			    [:html | 
			    (html heading)
				level1;
				with: 'Error: you are forbidden to access "', locationString, '".'].
	response nextPutAll: content.
	^response
    ]

    WAResponse class >> internalError: anError [
	<category: 'instance creation'>
	| response content |
	response := self new internalError.
	content := (WARenderCanvas builder)
		    fullDocument: true;
		    rootBlock: [:root | root title: 'Internal Error'];
		    render: 
			    [:html | 
			    (html heading)
				level1;
				with: 'Internal Error'.
			    (html heading)
				level2;
				with: anError description.
			    (SeasidePlatformSupport walkbackStringsFor: anError) 
				do: [:each | html text: each]
				separatedBy: [html break]].
	response nextPutAll: content.
	^response
    ]

    WAResponse class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    WAResponse class >> notFound: locationString [
	<category: 'instance creation'>
	| response content |
	response := self new notFound.
	content := (WARenderCanvas builder)
		    fullDocument: true;
		    rootBlock: [:root | root title: 'Internal Error'];
		    render: 
			    [:html | 
			    (html heading)
				level1;
				with: 'Error: "', locationString, '" not found.'].
	response nextPutAll: content.
	^response
    ]

    WAResponse class >> redirectTo: locationString [
	<category: 'responding'>
	^self new redirectTo: locationString
    ]

    WAResponse class >> refreshWithMessage: aString location: locationString delay: aNumber [
	<category: 'instance creation'>
	| document |
	document := (WARenderCanvas builder)
		    fullDocument: true;
		    rootBlock: [:root | root redirectTo: locationString delay: aNumber];
		    render: 
			    [:html | 
			    html heading level1 with: aString.
			    html text: 'You are being redirected to '.
			    (html anchor)
				url: locationString;
				with: locationString].
	^self new nextPutAll: document
    ]

    addCookie: aCookie [
	<category: 'accessing-cookies'>
	cookies ifNil: [cookies := Set new].
	cookies add: aCookie
    ]

    attachmentWithFileName: aString [
	<category: 'convenience'>
	self headerAt: 'Content-Disposition'
	    put: 'attachment; filename="' , aString , '"'
    ]

    authenticationFailed [
	<category: 'status'>
	self status: 401
    ]

    basicAuthenticationRealm: aString [
	<category: 'convenience'>
	self headerAt: 'WWW-Authenticate' put: 'Basic realm="' , aString , '"'.
	self authenticationFailed
    ]

    beXML [
	<category: 'convenience'>
	contentType sub = 'html' ifTrue: [contentType sub: 'xml']
    ]

    cacheForever [
	<category: 'convenience'>
	self removeHeaderAt: 'Cache-Control'.
	self removeHeaderAt: 'Pragma'.
	self headerAt: 'Expires' put: 'Thu, 01 Jan 2095 12:00:00 GMT'
    ]

    contentType [
	<category: 'accessing'>
	^contentType
    ]

    contentType: mimeTypeOrString [
	<category: 'accessing'>
	contentType := mimeTypeOrString toMimeType
    ]

    contents [
	<category: 'accessing'>
	^stream reset
    ]

    contents: aStream [
	<category: 'accessing'>
	stream := aStream
    ]

    cookieAt: key put: value [
	<category: 'accessing-cookies'>
	^self addCookie: (WACookie key: key value: value)
    ]

    cookies [
	<category: 'accessing-cookies'>
	^cookies ifNil: [#()]
    ]

    deleteCookieAt: key [
	"Delete the cookie in the browser"

	<category: 'accessing-cookies'>
	self addCookie: ((WACookie key: key value: '')
		    expireIn: (Duration days: -10000);
		    yourself)
    ]

    doNotCache [
	<category: 'convenience'>
	self headerAt: 'Expires' put: 'Thu, 11 Jun 1980 12:00:00 GMT'.
	self headerAt: 'Cache-Control' put: 'no-cache, must-revalidate'.
	self headerAt: 'Pragma' put: 'no-cache'
    ]

    forbidden [
	<category: 'status'>
	self status: 403
    ]

    gone [
	<category: 'status'>
	self status: 410
    ]

    headerAt: aString [
	<category: 'accessing-headers'>
	^self headers detect: [:each | each key = aString] ifNone: [nil]
    ]

    headerAt: aKeyString put: aValueObject [
	<category: 'accessing-headers'>
	self headers add: aKeyString -> aValueObject
    ]

    headers [
	<category: 'accessing-headers'>
	headers isNil ifTrue: [headers := OrderedCollection new].
	^headers
    ]

    httpVersion [
	<category: 'convenience'>
	^self class defaultHttpVersion
    ]

    initialize [
	<category: 'initialize-release'>
	| session |
	stream := SeasidePlatformSupport readWriteStream.
	status := 200.
	session := WACurrentSession value.
	contentType := session isNil 
		    ifFalse: [session contentType]
		    ifTrue: [self class defaultValueForContentType]
    ]

    internalError [
	<category: 'status'>
	self status: 500
    ]

    nextPut: aCharacter [
	<category: 'streaming'>
	stream nextPut: aCharacter asCharacter
    ]

    nextPutAll: aString [
	<category: 'streaming'>
	aString do: [:ea | self nextPut: ea]
    ]

    notFound [
	<category: 'status'>
	self status: 404
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    space;
	    nextPutAll: self status seasideString
    ]

    redirect [
	<category: 'status'>
	self status: 302
    ]

    redirectTo: aString [
	<category: 'convenience'>
	self headerAt: 'Location' put: aString.
	self redirect
    ]

    release [
	<category: 'initialize-release'>
	stream := cookies := headers := nil.
	super release
    ]

    removeHeaderAt: aString [
	<category: 'accessing-headers'>
	headers isNil ifTrue: [^self].
	headers := self headers reject: [:each | each key = aString]
    ]

    space [
	<category: 'streaming'>
	stream space
    ]

    status [
	<category: 'accessing'>
	^status
    ]

    status: aNumber [
	<category: 'accessing'>
	status := aNumber
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]

    writeHeadersOn: aStream [
	<category: 'writing'>
	self headers associationsDo: 
		[:assoc | 
		aStream
		    nextPutAll: assoc key;
		    nextPutAll: ': ';
		    nextPutAll: assoc value seasideString.
		aStream crlf].
	cookies ifNotNil: 
		[:foo | 
		cookies do: 
			[:each | 
			aStream nextPutAll: 'Set-Cookie: '.
			each writeOn: aStream.
			aStream crlf]].
	aStream
	    nextPutAll: 'Content-Type: ';
	    nextPutAll: self contentType seasideString.
	aStream crlf
    ]

    writeOn: aStream [
	<category: 'writing'>
	self writeStatusOn: aStream.
	self writeHeadersOn: aStream.
	aStream crlf.
	aStream nextPutAll: stream contents
    ]

    writeStatusOn: aStream [
	<category: 'writing'>
	aStream
	    nextPutAll: self httpVersion;
	    space;
	    nextPutAll: self status seasideString;
	    crlf
    ]
]



WAResponse subclass: WAStreamResponse [
    | writtenHeaders |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: nil>

    WAStreamResponse class >> on: aStream [
	<category: 'instance-creation'>
	^self new stream: aStream
    ]

    hasWrittenHeaders [
	<category: 'accessing'>
	^writtenHeaders
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	writtenHeaders := false
    ]

    stream [
	<category: 'accessing'>
	self writeOn: stream.
	^stream
    ]

    writeOn: aStream [
	<category: 'private'>
	self hasWrittenHeaders 
	    ifFalse: 
		[self writeStatusOn: aStream.
		self writeHeadersOn: aStream.
		aStream crlf.
		writtenHeaders := true]
    ]
]



Object subclass: WARoot [
    
    <category: 'Seaside-Core-Document'>
    <comment: nil>

    WARoot class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    close: aDocument [
	<category: 'writing'>
	
    ]

    open: aDocument [
	<category: 'writing'>
	
    ]
]



WARoot subclass: WAHtmlRoot [
    | context docType htmlAttrs headAttrs bodyAttrs headElements title styles scripts |
    
    <category: 'Seaside-Core-Document'>
    <comment: nil>

    WAHtmlRoot class >> context: aRenderingContext [
	<category: 'instance-creation'>
	^self new setContext: aRenderingContext
    ]

    absoluteUrlForResource: aString [
	<category: 'private'>
	^context absoluteUrlForResource: aString
    ]

    add: aHtmlElement [
	"Add a HTML head element to the receiver."

	<category: 'adding'>
	^headElements add: aHtmlElement
    ]

    addScript: aString [
	"Include the script aString into the receiver."

	<category: 'adding'>
	scripts ifNil: [scripts := OrderedCollection new].
	(scripts includes: aString) ifFalse: [scripts add: aString]
    ]

    addStyle: aString [
	"Include the style-sheet aString into the receiver."

	<category: 'adding'>
	styles ifNil: [styles := OrderedCollection new].
	(styles includes: aString) ifFalse: [styles add: aString]
    ]

    base [
	<category: 'elements'>
	^self add: (WABaseElement root: self)
    ]

    beXhtml10Strict [
	<category: 'doctype'>
	self 
	    docType: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    ]

    beXhtml10Transitional [
	<category: 'doctype'>
	self 
	    docType: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    ]

    beXhtml11 [
	<category: 'doctype'>
	self 
	    docType: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
    ]

    bodyAttributes [
	<category: 'accessing-attributes'>
	^bodyAttrs ifNil: [bodyAttrs := WAHtmlAttributes new]
    ]

    close: aDocument [
	<category: 'writing'>
	self writeFootOn: aDocument
    ]

    contentBase: urlString [
	<category: 'convenience'>
	self base url: urlString
    ]

    context [
	<category: 'accessing'>
	^context
    ]

    docType [
	<category: 'doctype'>
	^docType
    ]

    docType: aString [
	"Set the document-type of the receiver. The table at http://www.w3.org/TR/2002/NOTE-xhtml-media-types-20020430/ summarizes the recommendation to content authors for labeling their XHTML documents:
	 
	 Media type				XHTML 1.0 (HTML compatible)	XHTML 1.0 (other)	XHTML Basic / 1.1	XHTML+MathML
	 text/html				MAY							SHOULD NOT			SHOULD NOT			SHOULD NOT
	 application/xhtml+xml	SHOULD							SHOULD				SHOULD				SHOULD
	 application/xml			MAY							MAY				MAY				MAY
	 text/xml					MAY							MAY				MAY				MAY"

	<category: 'doctype'>
	docType := aString
    ]

    headAttributes [
	<category: 'accessing-attributes'>
	^headAttrs ifNil: [headAttrs := WAHtmlAttributes new]
    ]

    htmlAttributes [
	<category: 'accessing-attributes'>
	^htmlAttrs ifNil: [htmlAttrs := WAHtmlAttributes new]
    ]

    if [
	<category: 'elements'>
	^WAConditionalComment root: self
    ]

    initialize [
	<category: 'initialization'>
	headElements := OrderedCollection new.
	title := docType := String new
    ]

    javascript [
	<category: 'elements'>
	^(self script)
	    beJavascript;
	    yourself
    ]

    link [
	<category: 'elements'>
	^self add: (WALinkElement root: self)
    ]

    meta [
	<category: 'elements'>
	^self add: (WAMetaElement root: self)
    ]

    open: aDocument [
	<category: 'writing'>
	self writeHeadOn: aDocument
    ]

    redirectTo: aLocationString delay: aNumber [
	<category: 'convenience'>
	self meta redirectAfter: aNumber to: aLocationString
    ]

    revealedIf [
	<category: 'elements'>
	^WARevealedConditionalComment root: self
    ]

    script [
	<category: 'elements'>
	^self add: (WAScriptElement root: self)
    ]

    setContext: aRenderingContext [
	<category: 'initialization'>
	context := aRenderingContext
    ]

    stylesheet [
	<category: 'elements'>
	^(self link)
	    beStylesheet;
	    beCss;
	    yourself
    ]

    title [
	<category: 'accessing-properties'>
	^title
    ]

    title: aString [
	<category: 'accessing-properties'>
	title := aString
    ]

    writeElementsOn: aDocument [
	<category: 'writing'>
	aDocument
	    openTag: 'title';
	    nextPutAll: title;
	    closeTag: 'title'.
	headElements do: [:each | aDocument print: each]
    ]

    writeFootOn: aDocument [
	<category: 'writing'>
	aDocument closeTag: 'body'.
	aDocument closeTag: 'html'
    ]

    writeHeadOn: aDocument [
	<category: 'writing'>
	aDocument nextPutAll: docType.
	aDocument openTag: 'html' attributes: htmlAttrs.
	aDocument openTag: 'head' attributes: headAttrs.
	self writeElementsOn: aDocument.
	self writeStylesOn: aDocument.
	self writeScriptsOn: aDocument.
	aDocument closeTag: 'head'.
	aDocument openTag: 'body' attributes: bodyAttrs
    ]

    writeScriptsOn: aDocument [
	<category: 'writing'>
	scripts ifNil: [^self].
	scripts do: 
		[:each | 
		aDocument print: ((WAScriptElement root: self)
			    beJavascript;
			    document: each;
			    yourself)]
    ]

    writeStylesOn: aDocument [
	<category: 'writing'>
	styles ifNil: [^self].
	styles do: 
		[:each | 
		aDocument print: ((WALinkElement root: self)
			    beStylesheet;
			    beCss;
			    document: each;
			    yourself)]
    ]
]



Object subclass: WASessionContinuation [
    | root states |
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    WASessionContinuation class >> root: aComponent [
	<category: 'instance-creation'>
	^self new initializeWithRoot: aComponent
    ]

    application [
	"Answer the application to which this handler is associated."

	<category: 'accessing'>
	^self session application
    ]

    handleRequest: aRequest [
	<category: 'processing'>
	self subclassResponsibility
    ]

    initializeWithRoot: aComponent [
	<category: 'initialization'>
	root := aComponent
    ]

    newRedirectContinuation [
	"Answer a new redirect handler."

	<category: 'creational'>
	^(self application preferenceAt: #redirectContinuationClass) 
	    root: self root
    ]

    newRenderContinuation [
	"Answer a new render continuation."

	<category: 'creational'>
	^(self application preferenceAt: #renderContinuationClass) root: self root
    ]

    newResponse [
	"Answer a new response object and assign the current request stream."

	<category: 'creational'>
	| stream response |
	stream := self request responseStream.
	response := stream isNil 
		    ifTrue: [WAResponse new]
		    ifFalse: [WAStreamResponse on: stream].
	^response doNotCache
    ]

    newStates [
	<category: 'creational'>
	^WASnapshot new
    ]

    request [
	"Answer the current request object."

	<category: 'accessing'>
	^self session currentRequest
    ]

    respond: aBlock [
	<category: 'processing'>
	| response |
	states := self newStates.
	response := self newResponse.
	aBlock value: response.
	self updateStates: states.
	self session returnResponse: response
    ]

    root [
	"Answer the root component instance. Usually this component is instantiated with the first reuqest."

	<category: 'accessing'>
	^root
    ]

    run [
	<category: 'processing'>
	self subclassResponsibility
    ]

    session [
	"Answer the session to which this handler is associated."

	<category: 'accessing'>
	^WACurrentSession value
    ]

    states [
	<category: 'accessing'>
	^states
    ]

    updateRoot: aHtmlRoot [
	<category: 'updating'>
	self session updateRoot: aHtmlRoot.
	self root visiblePresentersDo: [:each | each updateRoot: aHtmlRoot]
    ]

    updateStates: aSnapshot [
	<category: 'updating'>
	self session updateStates: aSnapshot.
	self root visiblePresentersDo: 
		[:each | 
		(each isDecoration and: [each isDelegation]) 
		    ifTrue: [each component updateStates: aSnapshot].
		each updateStates: aSnapshot]
    ]

    updateUrl: anUrl [
	<category: 'updating'>
	self session updateUrl: anUrl.
	self root visiblePresentersDo: [:each | each updateUrl: anUrl]
    ]

    url [
	<category: 'accessing'>
	| url |
	url := self session actionUrlForContinuation: self.
	self updateUrl: url.
	^url
    ]

    value: aRequest [
	"Resume processing of aRequest. To ensure valid application state restore all registered states."

	<category: 'evaluating'>
	states ifNotNil: [:foo | states restore].
	self handleRequest: aRequest
    ]
]



WASessionContinuation subclass: WARedirectContinuation [
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    handleRequest: aRequest [
	<category: 'processing'>
	self newRenderContinuation run
    ]

    run [
	<category: 'processing'>
	self respond: [:response | response redirectTo: self url seasideString]
    ]
]



WASessionContinuation subclass: WARenderContinuation [
    | context |
    
    <category: 'Seaside-Core-RenderLoop'>
    <comment: nil>

    componentsNotFound: aCollection [
	<category: 'private'>
	WAComponentsNotFoundError 
	    signal: 'Components not found while processing callbacks: ' 
		    , aCollection seasideString
    ]

    context [
	"Answer the current context of this request."

	<category: 'accessing'>
	^context
    ]

    handleRequest: aRequest [
	<category: 'processing'>
	aRequest isXmlHttpRequest 
	    ifTrue: [self session onRespond: [:r | states snapshot]].
	self withNotificationHandler: [self processCallbacks: aRequest].
	((self shouldRedirect: aRequest) 
	    ifTrue: [self newRedirectContinuation]
	    ifFalse: [self newRenderContinuation]) run
    ]

    newContext [
	<category: 'creational'>
	^(WARenderingContext new)
	    session: self session;
	    actionUrl: self url;
	    yourself
    ]

    newDocumentOn: aResponse [
	<category: 'creational'>
	^WAHtmlStreamDocument new stream: aResponse stream
    ]

    newHtmlRoot [
	<category: 'creational'>
	| htmlRoot |
	htmlRoot := WAHtmlRoot context: self context.
	htmlRoot bodyAttributes 
	    at: 'onload'
	    append: 'onLoad()'
	    separator: ';'.
	self updateRoot: htmlRoot.
	^htmlRoot
    ]

    processCallbacks: aRequest [
	<category: 'private'>
	| lastPosition callbackStream |
	lastPosition := nil.
	callbackStream := context callbackStreamForRequest: aRequest.
	[callbackStream position = lastPosition] whileFalse: 
		[lastPosition := callbackStream position.
		self root 
		    decorationChainDo: [:each | each processCallbackStream: callbackStream]].
	callbackStream atEnd 
	    ifFalse: [self unprocessedCallbacks: callbackStream upToEnd]
    ]

    processRendering: aResponse [
	<category: 'private'>
	| document htmlRoot |
	document := self newDocumentOn: aResponse.
	context document: document.
	htmlRoot := self newHtmlRoot.
	document open: htmlRoot.
	self root decorationChainDo: [:each | each renderWithContext: context].
	self writeOnLoadOn: document.
	document close: htmlRoot.
	context release
    ]

    render [
	<category: 'actions'>
	self session clearJumpTo.
	context := self newContext.
	self respond: [:response | self processRendering: response]
    ]

    run [
	<category: 'processing'>
	self withNotificationHandler: [self render]
    ]

    shouldRedirect: aRequest [
	<category: 'testing'>
	^aRequest isGet not or: [(aRequest fields includesKey: '_n') not]
    ]

    unprocessedCallbacks: aCollection [
	<category: 'private'>
	| owners |
	owners := (aCollection collect: [:each | each owner]) asSet asArray.
	self componentsNotFound: owners
    ]

    withNotificationHandler: aBlock [
	<category: 'private'>
	^aBlock on: WARenderNotification , WAPageExpired do: [:n | ]
    ]

    writeOnLoadOn: aDocument [
	<category: 'private'>
	| attributes |
	attributes := WAHtmlAttributes new.
	attributes at: 'type' put: 'text/javascript'.
	aDocument 
	    openTag: 'script'
	    attributes: attributes
	    closed: false.
	aDocument nextPutAll: '/*<![CDATA[*/function onLoad(){'.
	self session onLoadScripts 
	    do: [:each | aDocument nextPutAll: each seasideString]
	    separatedBy: [aDocument nextPutAll: ';'].
	aDocument nextPutAll: '}/*]]>*/'.
	aDocument closeTag: 'script'.
	self session clearLoadScripts
    ]
]



Object subclass: WASmallDictionary [
    | size keys values |
    
    <category: 'Seaside-Core-Utilities'>
    <comment: 'I am an implementation of a dictionary. Compared to other dictionaries I am very efficient for small sizes, speed- and space-wise. I also remember the order in which elements are added, some of my users might depend on that. My implementation features some ideas from the RefactoringBrowser.'>

    WASmallDictionary class >> new [
	<category: 'instance-creation'>
	^self new: 3
    ]

    WASmallDictionary class >> new: anInteger [
	<category: 'instance-creation'>
	^self basicNew initialize: anInteger
    ]

    associations [
	"Answer a Collection containing the receiver's associations."

	<category: 'accessing'>
	| result |
	result := WriteStream on: (Array new: self size).
	self associationsDo: [:assoc | result nextPut: assoc].
	^result contents
    ]

    associationsDo: aBlock [
	<category: 'enumerating'>
	self keysAndValuesDo: [:key :value | aBlock value: key -> value]
    ]

    at: aKey [
	"Answer the value associated with aKey. Raise an exception, if no such key is defined."

	<category: 'accessing'>
	^self at: aKey ifAbsent: [self errorKeyNotFound]
    ]

    at: aKey ifAbsent: aBlock [
	"Answer the value associated with aKey. Evaluate aBlock, if no such key is defined."

	<category: 'accessing'>
	| index |
	index := self findIndexFor: aKey.
	^index = 0 ifFalse: [values at: index] ifTrue: [aBlock value]
    ]

    at: aKey ifAbsentPut: aBlock [
	"Answer the value associated with aKey. Evaluate aBlock, if no such key is defined and store the return value."

	<category: 'accessing'>
	| index |
	index := self findIndexFor: aKey.
	^index = 0 
	    ifFalse: [values at: index]
	    ifTrue: [self privateAt: aKey put: aBlock value]
    ]

    at: aKey ifPresent: aBlock [
	"Lookup aKey in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

	<category: 'accessing'>
	| index |
	index := self findIndexFor: aKey.
	^index = 0 ifFalse: [aBlock value: (values at: index)]
    ]

    at: aKey put: aValue [
	"Set the value of aKey to be aValue."

	<category: 'accessing'>
	| index |
	index := self findIndexFor: aKey.
	^index = 0 
	    ifFalse: [values at: index put: aValue]
	    ifTrue: [self privateAt: aKey put: aValue]
    ]

    errorKeyNotFound [
	<category: 'private'>
	self error: 'Key not found'
    ]

    findIndexFor: aKey [
	<category: 'private'>
	1 to: size do: [:index | (keys at: index) = aKey ifTrue: [^index]].
	^0
    ]

    grow [
	<category: 'private'>
	| newKeys newValues |
	newKeys := Array new: 2 * size.
	newValues := Array new: 2 * size.
	1 to: size
	    do: 
		[:index | 
		newKeys at: index put: (keys at: index).
		newValues at: index put: (values at: index)].
	keys := newKeys.
	values := newValues
    ]

    includesKey: aKey [
	"Answer whether the receiver has a key equal to aKey."

	<category: 'testing'>
	^(self findIndexFor: aKey) ~= 0
    ]

    initialize: anInteger [
	<category: 'initialization'>
	size := 0.
	keys := Array new: anInteger.
	values := Array new: anInteger
    ]

    isEmpty [
	<category: 'testing'>
	^size = 0
    ]

    keys [
	<category: 'enumerating'>
	^keys copyFrom: 1 to: size
    ]

    keysAndValuesDo: aBlock [
	<category: 'enumerating'>
	1 to: size
	    do: [:index | aBlock value: (keys at: index) value: (values at: index)]
    ]

    keysDo: aBlock [
	<category: 'enumerating'>
	1 to: size do: [:each | aBlock value: (keys at: each)]
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	keys := keys copy.
	values := values copy
    ]

    privateAt: aKey put: aValue [
	<category: 'private'>
	size = keys size ifTrue: [self grow].
	keys at: (size := size + 1) put: aKey.
	^values at: size put: aValue
    ]

    removeKey: aKey [
	"Remove aKey from the receiver, raise an exception if the element is missing."

	<category: 'accessing'>
	^self removeKey: aKey ifAbsent: [self errorKeyNotFound]
    ]

    removeKey: aKey ifAbsent: aBlock [
	"Remove aKey from the receiver, evaluate aBlock if the element is missing."

	<category: 'accessing'>
	| index value |
	index := self findIndexFor: aKey.
	index = 0 ifTrue: [^aBlock value].
	value := values at: index.
	index to: size - 1
	    do: 
		[:i | 
		keys at: i put: (keys at: i + 1).
		values at: i put: (values at: i + 1)].
	keys at: size put: nil.
	values at: size put: nil.
	size := size - 1.
	^value
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    values [
	<category: 'enumerating'>
	^values copyFrom: 1 to: size
    ]

    valuesDo: aBlock [
	<category: 'enumerating'>
	1 to: size do: [:index | aBlock value: (values at: index)]
    ]
]



WASmallDictionary subclass: WAHtmlAttributes [
    
    <category: 'Seaside-Core-Document'>
    <comment: 'I represent the attributes of a XHTML tag. Compared to my superclass I ignore requests to add a nil-values. I also don''t throw an exception when accessing a key that doesn''t exist, but instead return nil.'>

    addClass: aString [
	"Add an additional CSS class aString to the receiver."

	<category: 'convenience'>
	self 
	    at: 'class'
	    append: aString
	    separator: ' '
    ]

    addStyle: aString [
	"Add an additional CSS style definition aString to the receiver."

	<category: 'convenience'>
	self 
	    at: 'style'
	    append: aString
	    separator: ';'
    ]

    at: aKey append: aValue [
	"Append aValue to the attribute aKey. If already present, concatenate it with a space. Ignore the request if aValue is nil."

	<category: 'accessing'>
	^self 
	    at: aKey
	    append: aValue
	    separator: ' '
    ]

    at: aKey append: aValue separator: aString [
	"Append aValue to the attribute aKey. If already present, concatenate it with aString. Ignore the request if aValue is nil."

	<category: 'accessing'>
	aValue ifNil: [^self at: aKey].
	^self at: aKey
	    put: (String streamContents: 
			[:stream | 
			self at: aKey
			    ifPresent: 
				[:value | 
				stream nextPutAll: value seasideString.
				stream nextPutAll: aString].
			stream nextPutAll: aValue seasideString])
    ]

    encodeOn: aDocument [
	"Encode the receivers attribute onto aDocument. Note that this implementation reqires those two checks for true and false exactly the way they are here, to reliable encode boolean attributes in an XHTML compliant way."

	<category: 'encoding'>
	self keysAndValuesDo: 
		[:key :value | 
		value == false 
		    ifFalse: 
			[aDocument
			    nextPut: $ ;
			    nextPutAll: key;
			    nextPutAll: '="'.
			value == true 
			    ifTrue: [aDocument nextPutAll: key]
			    ifFalse: [aDocument print: value].
			aDocument nextPut: $"]]
    ]

    errorKeyNotFound [
	<category: 'private'>
	^nil
    ]

    privateAt: aKey put: aValue [
	<category: 'private'>
	aValue ifNil: [^nil].
	^super privateAt: aKey put: aValue
    ]
]



Object subclass: WAUrl [
    | scheme username password hostname port path parameters fragment |
    
    <category: 'Seaside-Core-HTTP'>
    <comment: 'I represent all portions of an URL as described by the RFC 1738. I include scheme, username, password, hostname, port, path, parameters, and fragment.

Portions of this code are based on code of Kazuki Yasumatsu and Paolo Bonzini.

Instance Variables
	scheme:			<String> or nil
	username:		<String> or nil
	password:		<String> or nil
	hostname:		<String> or nil
	port:			<Integer> or nil
	path:			<OrderedCollection> or nil
	parameters:		<Dictionary>
	fragment:		<String> or nil'>

    WAUrl class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    = anUrl [
	<category: 'comparing'>
	^self class = anUrl class and: [self printString = anUrl printString]
    ]

    addParameter: aString [
	<category: 'adding'>
	self addParameter: aString value: nil
    ]

    addParameter: keyString value: valueString [
	<category: 'adding'>
	self parameters at: keyString put: valueString
    ]

    addToPath: aString [
	<category: 'adding'>
	self path addAll: (aString findTokens: '/')
    ]

    encodeFragmentOn: aDocument [
	<category: 'encoding'>
	fragment ifNil: [^self].
	aDocument nextPut: $#.
	aDocument urlEncoder nextPutAll: fragment
    ]

    encodeOn: aDocument [
	<category: 'encoding'>
	self encodeOn: aDocument usingHtmlEntities: true
    ]

    encodeOn: aDocument usingHtmlEntities: aBoolean [
	<category: 'encoding'>
	self encodeServerOn: aDocument.
	self encodePathOn: aDocument.
	self encodeParametersOn: aDocument usingHtmlEntities: aBoolean.
	self encodeFragmentOn: aDocument
    ]

    encodeParametersOn: aDocument usingHtmlEntities: aBoolean [
	<category: 'encoding'>
	| first |
	first := true.
	parameters ifNil: [^self].
	parameters keysAndValuesDo: 
		[:key :value | 
		aDocument nextPutAll: (first 
			    ifTrue: 
				[first := false.
				'?']
			    ifFalse: [aBoolean ifTrue: ['&amp;'] ifFalse: ['&']]).
		aDocument urlEncoder nextPutAll: key.
		value ifNotNil: 
			[:foo | 
			aDocument nextPut: $=.
			aDocument urlEncoder nextPutAll: value seasideString]]
    ]

    encodePathOn: aDocument [
	<category: 'encoding'>
	path ifNil: [^self].
	aDocument nextPut: $/.
	path do: [:each | aDocument urlEncoder nextPutAll: each]
	    separatedBy: [aDocument nextPut: $/]
    ]

    encodeServerOn: aDocument [
	<category: 'encoding'>
	hostname ifNil: [^self].
	aDocument
	    nextPutAll: scheme;
	    nextPutAll: '://'.
	username notNil 
	    ifTrue: 
		[aDocument urlEncoder nextPutAll: username.
		password notNil 
		    ifTrue: 
			[aDocument nextPut: $:.
			aDocument urlEncoder nextPutAll: password].
		aDocument nextPut: $@].
	aDocument urlEncoder nextPutAll: hostname.
	port notNil 
	    ifTrue: 
		[((scheme = 'http' and: [port = 80]) 
		    or: [scheme = 'https' and: [port = 443]]) 
			ifFalse: 
			    [aDocument
				nextPut: $:;
				print: port]]
    ]

    fragment [
	"Answer the fragment part of the URL."

	<category: 'accessing'>
	^fragment
    ]

    fragment: aString [
	<category: 'accessing'>
	fragment := aString
    ]

    hash [
	<category: 'comparing'>
	^self hostname hash bitXor: self path hash
    ]

    hostname [
	"Answer the host part of the URL."

	<category: 'accessing'>
	^hostname
    ]

    hostname: aString [
	<category: 'accessing'>
	hostname := aString
    ]

    initialize [
	<category: 'initialization'>
	scheme := 'http'
    ]

    isSeasideField: aString [
	<category: 'private'>
	^aString notEmpty 
	    and: [aString first = $_ or: [aString allSatisfy: [:each | each isDigit]]]
    ]

    parameters [
	<category: 'accessing'>
	^parameters ifNil: [parameters := WASmallDictionary new]
    ]

    parameters: aDictionary [
	<category: 'accessing'>
	parameters := aDictionary
    ]

    password [
	"Answer the password part of the URL."

	<category: 'accessing'>
	^password
    ]

    password: aString [
	<category: 'accessing'>
	password := aString
    ]

    path [
	"Answer the path part of the URL."

	<category: 'accessing'>
	^path ifNil: [path := OrderedCollection new]
    ]

    path: aCollection [
	"Set the path part of the URL to aCollection."

	<category: 'accessing'>
	path := aCollection
    ]

    port [
	"Answer the port number part of the URL."

	<category: 'accessing'>
	^port
    ]

    port: aNumber [
	<category: 'accessing'>
	port := aNumber
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	scheme := scheme copy.
	username := username copy.
	password := password copy.
	hostname := hostname copy.
	port := port copy.
	path := path copy.
	parameters := parameters copy.
	fragment := fragment copy
    ]

    printOn: aStream [
	<category: 'printing'>
	| document |
	document := WAHtmlStreamDocument new.
	document stream: aStream.
	self encodeOn: document usingHtmlEntities: false
    ]

    removeParameters [
	<category: 'private'>
	parameters := nil
    ]

    scheme [
	"Answer the URL's scheme."

	<category: 'accessing'>
	^scheme
    ]

    scheme: aString [
	"we really expect a String here, Old versions (2.7) expected a Symbol you can still pass a Symbol and get away with it but don't expect this behavior to be supported in future versions."

	<category: 'accessing'>
	scheme := aString seasideString
    ]

    takeServerParametersFromRequest: aRequest [
	<category: 'private'>
	| httpHost |
	hostname ifNil: 
		[httpHost := aRequest headerAt: 'host' ifAbsent: [^self].
		hostname := httpHost copyUpTo: $:.
		(httpHost includes: $:) 
		    ifTrue: [port := (httpHost copyAfter: $:) asInteger]]
    ]

    username [
	"Answer the username part of the URL."

	<category: 'accessing'>
	^username
    ]

    username: aString [
	<category: 'accessing'>
	username := aString
    ]

    with: pathString [
	<category: 'copying'>
	^(self copy)
	    addToPath: pathString;
	    yourself
    ]

    withParameter: aString [
	<category: 'copying'>
	^(self copy)
	    addParameter: aString;
	    yourself
    ]

    withParameter: aString value: valueString [
	<category: 'copying'>
	^(self copy)
	    addParameter: aString value: valueString;
	    yourself
    ]

    withoutParameters [
	<category: 'copying'>
	^(self copy)
	    removeParameters;
	    yourself
    ]
]



Object subclass: WAValueHolder [
    | contents |
    
    <category: 'Seaside-Core-Utilities'>
    <comment: 'I wrap a single object. I am like value holder except that I am portable and don''t include the Model cruft in Squeak.'>

    WAValueHolder class >> with: anObject [
	<category: 'instance-creation'>
	^self new contents: anObject
    ]

    contents [
	<category: 'accessing'>
	^contents
    ]

    contents: anObject [
	<category: 'accessing'>
	contents := anObject
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' contents: ';
	    print: self contents
    ]
]



WAValueHolder subclass: WAStateHolder [
    
    <category: 'Seaside-Core-Utilities'>
    <comment: 'I am only where for migration purposes. Don''t use WAStateHolder anymore. Backtracking is now done using #states. If you need an object that wraps a single value use WAValueHolder.'>

    WAStateHolder class >> new [
	<category: 'instance-creation'>
	self deprecatedApi.
	^super new
    ]
]



UndefinedObject extend [

    encodeOn: aDocument [
	<category: '*Seaside-Core'>
	
    ]

    renderOn: html [
	<category: '*Seaside-Core'>
	
    ]

]



Dictionary extend [

    inspectorFields [
	<category: '*Seaside-Core'>
	^self
    ]

    valuesCollect: aBlock [
	<category: '*Seaside-Core'>
	| result |
	result := self species new: self size.
	self 
	    keysAndValuesDo: [:key :value | result at: key put: (aBlock value: value)].
	^result
    ]

]



Exception extend [

    possibleCauses [
	<category: '*Seaside-Core'>
	^#()
    ]

]



MessageNotUnderstood extend [

    possibleCauses [
	<category: '*Seaside-Core'>
	| causes |
	self receiver isNil 
	    ifFalse: [^#('you sent a message this type of object doesn''t understand')].
	causes := #('the receiver of the message is nil' 'a class extension hasn''t been loaded correctly' 'you sent the wrong message') 
		    asOrderedCollection.
	self message selector = #contents 
	    ifTrue: 
		[causes 
		    addFirst: 'you forgot to send "super initialize" in a initialize method of a component or task'].
	^causes
    ]

]



Integer extend [

    printStringAsCents [
	<category: '*Seaside-Core'>
	^'$' , (self // 100) seasideString , '.' , (self \\ 100) asTwoCharacterString
    ]

]



Eval [
    WAExternalID initialize.
    WACachedDocument initialize.
    WAGlobalConfiguration initialize.
    WAHtmlEncoder initialize.
    WAUrlEncoder initialize.
    WAFileLibrary initialize.
    WALocale initialize.
    WAFileHandler initialize
]

