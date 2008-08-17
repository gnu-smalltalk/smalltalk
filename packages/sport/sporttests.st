"======================================================================
|
|   Sport-A 2.030 tests by Leandro Caniglia
|
|
 ======================================================================"

"evaluate"



TestCase subclass: SpDateTimeTest [
    
    <comment: nil>
    <category: ''>

    testAddYears2000 [
	<category: #dates>
	| date sp future |
	date := Date 
		    newDay: 29
		    month: #February
		    year: 1996.
	sp := SpDate onDate: date.
	self 
	    shouldnt: [future := sp addYears: 4]
	    raise: Error
	    description: '2000 is a leap year'.
	self assert: future underlyingDate dayOfMonth = 29
	    description: 'Wrong day of month when a leap year is involved'
    ]

    testAddYears2100 [
	<category: #dates>
	| date sp future |
	date := Date 
		    newDay: 29
		    month: #February
		    year: 2096.
	sp := SpDate onDate: date.
	self 
	    shouldnt: [future := sp addYears: 4]
	    raise: Error
	    description: '2100 is not a leap year'.
	self assert: future underlyingDate dayOfMonth = 28
	    description: 'Wrong day of month when a leap year is involved'
    ]

    testAddYearsDec31st [
	<category: #dates>
	| date sp future year end |
	date := Date 
		    newDay: 31
		    month: #December
		    year: Date today year.
	sp := SpDate onDate: date.
	1 to: 10
	    do: 
		[:i | 
		future := sp addYears: i.
		self assert: future underlyingDate year - sp underlyingDate year = i
		    description: '#addYears: did not increment the year'.
		year := future underlyingDate year.
		end := Date 
			    newDay: 31
			    month: #December
			    year: year.
		self assert: future = (SpDate onDate: end)
		    description: '#addYears: moved the last day']
    ]

    testAddYearsJan1st [
	<category: #dates>
	| date sp future |
	date := Date 
		    newDay: 1
		    month: #January
		    year: Date today year.
	sp := SpDate onDate: date.
	1 to: 10
	    do: 
		[:i | 
		future := sp addYears: i.
		self
		    assert: future underlyingDate year - sp underlyingDate year = i
			description: '#addYears: did not increment year';
		    assert: future julianDay = 1 description: '#addYears: moved the first day']
    ]

    testAddYearsLeapFeb [
	<category: #dates>
	| leap sp future date |
	leap := Date 
		    newDay: 29
		    month: #February
		    year: 2008.
	sp := SpDate onDate: leap.
	future := sp addYears: 1.
	self assert: future underlyingDate dayOfMonth = 28
	    description: 'Wrong day of month when a leap year is involved'.
	date := Date 
		    newDay: 28
		    month: #February
		    year: 2007.
	sp := SpDate onDate: date.
	future := sp addYears: 1.
	self assert: future underlyingDate dayOfMonth = 28
	    description: 'Wrong day of month when a leap year is involved'
    ]

    testISO8610 [
	<category: #dates>
	| today date iso |
	today := SpDate today.
	iso := today asISO8610String.
	date := SpDate fromISO8610String: iso.
	self assert: date = today
    ]

    testRFC1123 [
	<category: #timestamps>
	| timestamp |
	self
	    shouldnt: 
		    [timestamp := SpTimestamp 
				fromRFC1123String: 'Sun, 27 May 2007 13:08:36 GMT']
		raise: Error
		description: 'Cannot parse a valid RFC1123 timestamp';
	    assert: timestamp asRFC1123String = 'Sun, 27 May 2007 13:08:36 GMT'
    ]
]



"evaluate"



TestCase subclass: SpErrorTest [
    
    <comment: nil>
    <category: ''>

    testSignalWith [
	<category: #all>
	self 
	    should: 
		[SpExceptionContext 
		    for: [SpAbstractError raiseSignal: 'Hello world!!']
		    on: SpAbstractError
		    do: [:ex | SpError signalWith: ex]]
	    raise: SpError
	    description: 'SpError not raised'
    ]

    testSpError [
	<category: #all>
	self 
	    should: [SpError raiseSignal: 'Ignore']
	    raise: SpError
	    description: 'The exception did not raise'
    ]

    testSpErrorHandler [
	<category: #all>
	| raised |
	raised := false.
	self
	    shouldnt: 
		    [SpExceptionContext 
			for: [SpError raiseSignal: 'Ignore']
			on: SpError
			do: [:ex | raised := true]]
		raise: Exception
		description: 'The exception handler did not work';
	    assert: raised description: 'The exception did not raise'
    ]
]



"evaluate"



TestCase subclass: SpWeakArrayTest [
    
    <comment: nil>
    <category: ''>

    testWeakArray [
	<category: #all>
	| strong weak ok |
	strong := Array with: Object new.
	weak := SpWeakArray withAll: strong.
	strong at: 1 put: 'Smalltalk'.
	5 timesRepeat: [
	    ObjectMemory globalGarbageCollect.	"Should call into SpEnvironment"
	    ok := (weak at: 1) class ~~ Object.
	    ok ifTrue: [ self assert: ok. ^self ] ].

	self assert: ok
    ]
]



"evaluate"



TestCase subclass: SpEnvironmentTest [
    
    <comment: nil>
    <category: ''>

    testByteArrayFromHexString [
	<category: #all>
	| array |
	array := SpEnvironment byteArrayFromHexString: ''.
	self
	    assert: array class == ByteArray;
	    assert: array isEmpty.
	array := SpEnvironment byteArrayFromHexString: '0'.
	self assert: array = (ByteArray with: 0).
	array := SpEnvironment byteArrayFromHexString: 'F'.
	self assert: array = (ByteArray with: 15).
	array := SpEnvironment byteArrayFromHexString: '1234'.
	self assert: array = (ByteArray with: 18 with: 52).
	array := SpEnvironment byteArrayFromHexString: '1234ABCD'.
	self 
	    assert: array = (ByteArray 
			    with: 18
			    with: 52
			    with: 171
			    with: 205)
    ]

    testCharacterFromInteger [
	<category: #all>
	'abcdefghijklmnstuvwxyz' 
	    do: [:char | self assert: char = (SpEnvironment characterFromInteger: char asInteger)].
	'ABCDEFGHIJKLMNSTUVWXYZ' asUppercase 
	    do: [:char | self assert: char = (SpEnvironment characterFromInteger: char asInteger)].
	'0123456789' 
	    do: [:char | self assert: char = (SpEnvironment characterFromInteger: char asInteger)].
	'~!!@#$%^&*()-_=+[]{}\|/?.>,<;:'' `	"
' 
	    do: [:char | self assert: char = (SpEnvironment characterFromInteger: char asInteger)]
    ]

    testDialect [
	<category: #all>
	| tot |
	tot := 0.
	SpEnvironment isAmbraiSmalltalk ifTrue: [tot := tot + 1].
	SpEnvironment isDolphin ifTrue: [tot := tot + 1].
	SpEnvironment isGNUSmalltalk ifTrue: [tot := tot + 1].
	SpEnvironment isGemStone ifTrue: [tot := tot + 1].
	SpEnvironment isObjectStudio ifTrue: [tot := tot + 1].
	SpEnvironment isSmalltalkX ifTrue: [tot := tot + 1].
	SpEnvironment isSmalltalkXY ifTrue: [tot := tot + 1].
	SpEnvironment isSqueak ifTrue: [tot := tot + 1].
	SpEnvironment isVASmalltalk ifTrue: [tot := tot + 1].
	SpEnvironment isVisualSmalltalk ifTrue: [tot := tot + 1].
	SpEnvironment isVisualWorks ifTrue: [tot := tot + 1].
	self assert: tot = 1
    ]

    testEvaluateIn [
	<category: #all>
	self 
	    assert: (SpEnvironment evaluate: 'Hello World!!' storeString in: nil) 
		    = 'Hello World!!'
    ]

    testHexStringFromByteArray [
	<category: #all>
	| array string |
	array := ByteArray with: 0.
	string := SpEnvironment hexStringFromByteArray: array.
	self assert: string = '00'.
	array := ByteArray with: 15.
	string := SpEnvironment hexStringFromByteArray: array.
	self assert: string = '0F'.
	array := SpEnvironment byteArrayFromHexString: '1234ABCD'.
	string := SpEnvironment hexStringFromByteArray: array.
	self assert: string = '1234ABCD'
    ]

    testStreamPosition [
	<category: #all>
	self assert: '' readStream position = SpEnvironment streamStartPosition
    ]
]



"evaluate"



TestCase subclass: SpStringUtilitiesTest [
    
    <comment: nil>
    <category: ''>

    testStringFromBytes [
	<category: #all>
	| array string |
	array := ByteArray new: 'Smalltalk' size.
	1 to: array size
	    do: [:index | array at: index put: ('Smalltalk' at: index) asInteger].
	string := SpStringUtilities stringFromBytes: array.
	self assert: string = 'Smalltalk'
    ]

    testTokens [
	<category: #all>
	| tokens block empty |
	tokens := SpStringUtilities tokensBasedOn: ',' in: 'a , b , c , d'.
	self assert: tokens asArray = #('a ' ' b ' ' c ' ' d').
	block := SpStringUtilities tokensBasedOn: '-' in: 'a , b , c , d'.
	self assert: block asArray = #('a , b , c , d').
	self
	    shouldnt: [empty := SpStringUtilities tokensBasedOn: ',' in: '']
		raise: Error;
	    assert: empty isEmpty
    ]

    testTrimBlanksFrom [
	<category: #all>
	| string |
	string := SpStringUtilities trimBlanksFrom: ''.
	self assert: string = ''.
	string := SpStringUtilities trimBlanksFrom: '	'.
	self assert: string = ''.
	string := SpStringUtilities trimBlanksFrom: '
'.
	self assert: string = ''.
	string := SpStringUtilities trimBlanksFrom: ' a'.
	self assert: string = 'a'.
	string := SpStringUtilities trimBlanksFrom: 'a '.
	self assert: string = 'a'.
	string := SpStringUtilities trimBlanksFrom: ' a '.
	self assert: string = 'a'
    ]
]

