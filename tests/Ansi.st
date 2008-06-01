Object subclass: #MsgParmSpec
    instanceVariableNames: 'parmName parmProtocols parmAliasingAttribute '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

Object subclass: #MsgReturnSpec
    instanceVariableNames: 'returnValueProtocols returnValueAliasingAttribute '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCase subclass: #TestCaseProtocol
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseProtocol subclass: #TestCaseHelper
    instanceVariableNames: 'testCase '
    classVariableNames: ' '
    poolDictionaries: ''
    category: ''!

TestCaseHelper class instanceVariableNames: 'testSelectors '!

TestCaseHelper subclass: #CollectionStreamHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #GettableStreamHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #WriteStreamHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #SequencedReadableCollectionHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #SequencedStreamHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #CollectionHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #SequencedCollectionHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #ReadableStringHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #SequencedContractibleCollectionHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #PuttableStreamHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #AbstractDictionaryHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseProtocol subclass: #MainTestCase
    instanceVariableNames: 'messages helpers '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ExceptionSetANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #IdentityDictionaryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ExceptionClassANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #SelectorANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ArrayFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ObjectClassANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #NilANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #FloatANSITest
    instanceVariableNames: 'smallInt2 largeNegInt2000000000 largePosInt2000000000 float2 fractionHalf sclDec2s3 numList '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ReadWriteStreamFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ScaledDecimalANSITest
    instanceVariableNames: 'smallInt2 largeNegInt2000000000 largePosInt2000000000 float2 fractionHalf sclDec2s3 numList '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #NotificationANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #CharacterANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ZeroDivideANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #TranscriptANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #MessageNotUnderstoodANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #SequencedStreamTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #BagFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ErrorClassANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #WarningClassANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #OrderedCollectionFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #DurationANSITest
    instanceVariableNames: 'off0123 smallInt2 largeNegInt2000000000 largePosInt2000000000 float2 fractionHalf numList '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ZeroDivideFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #IntervalFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ReadStreamFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ByteArrayFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ExceptionANSITest
    instanceVariableNames: 'unchanged changed value '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #MonadicBlockANSITest
    instanceVariableNames: 'blk1args '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #DurationFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #SortedCollectionFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #DateAndTimeANSITest
    instanceVariableNames: 'd19970426t8 '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ReadWriteStreamANSITest
    instanceVariableNames: 'readWriteStream '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #DateAndTimeFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #FractionFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ErrorANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #StringFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ReadFileStreamANSITest
    instanceVariableNames: 'readFileStream '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #FailedMessageANSITest
    instanceVariableNames: 'failedMsg '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #ObjectHelper
    instanceVariableNames: 'object '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #IntegerANSITest
    instanceVariableNames: 'smallInt2 largeNegInt2000000000 largePosInt2000000000 float2 fractionHalf sclDec2s3 numList '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #FileStreamFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #WarningANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #IdentityDictionaryFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #FractionANSITest
    instanceVariableNames: 'smallInt2 largeNegInt2000000000 largePosInt2000000000 float2 fractionHalf sclDec2s3 numList '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #MessageNotUnderstoodSelectorANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #NiladicBlockANSITest
    instanceVariableNames: 'blk0args canonicalObject '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #NotificationClassANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #ObjectANSITest
    instanceVariableNames: 'object '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #SetFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #ExtensibleCollectionHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #DyadicValuableANSITest
    instanceVariableNames: 'blk2args '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #WriteStreamFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedStreamTest subclass: #WriteStreamANSITest
    instanceVariableNames: 'writeStream '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #WriteFileStreamANSITest
    instanceVariableNames: 'writeFileStream '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

Object subclass: #ProtocolANYSpec
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

ProtocolANYSpec subclass: #ProtocolSpec
    instanceVariableNames: 'name conformsTo description messageSpecifications '
    classVariableNames: 'DefaultConvTable FixNum OperatorTable Protocols UnaryConvTable UndefinedConformsToNames ClassProtocols '
    poolDictionaries: ''
    category: ''!

MsgReturnSpec subclass: #MsgReturnRuleSpec
    instanceVariableNames: 'ruleSourceCode ruleBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #FloatCharacterizationANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #CharacterFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedStreamTest subclass: #ReadStreamANSITest
    instanceVariableNames: 'readStream '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

Object subclass: #ProtocolMsgSpec
    instanceVariableNames: 'selector parameterSpecifications returnValueSpecifications specSections '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #DictionaryFactoryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #BooleanANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

MainTestCase subclass: #CollectionTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

CollectionTest subclass: #SequencedReadableCollectionTest
    instanceVariableNames: 'canonicalObjects'
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

CollectionTest subclass: #IntervalANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedReadableCollectionTest subclass: #StringANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

CollectionTest subclass: #DictionaryANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

CollectionTest subclass: #SetANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedReadableCollectionTest subclass: #SymbolANSITest
    instanceVariableNames: 'smalltalkSymbol '
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedReadableCollectionTest subclass: #OrderedCollectionANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

CollectionTest subclass: #BagANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedReadableCollectionTest subclass: #ByteArrayANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedReadableCollectionTest subclass: #SortedCollectionANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

SequencedReadableCollectionTest subclass: #ArrayANSITest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

TestCaseHelper subclass: #ReadStreamHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: ''!

!ReadStreamHelper methodsFor: nil!

testXupToX

	self canonicalObject reset.
	self value: [self canonicalObject upTo: $ ]
		should: [:r | r = 'this' & self canonicalObject next = $i]
		conformTo: self protocol selector: #upTo:.

	self value: [self canonicalObject upTo: $X]
		should: [:r | r = 's a string' & self canonicalObject atEnd]
		conformTo: self protocol selector: #upTo:.

	self value: [self canonicalObject upTo: $a]
		should: [:r | r isEmpty]
		conformTo: self protocol selector: #upTo:.!

object: anObject!

testXnextX

	self canonicalObject reset.
	self value: [self canonicalObject next: 3]
		should: [:r | r asArray = 'thi' asArray]
		conformTo: self protocol selector: #'next:'.

	self value: [self canonicalObject next: 0]
		should: [:r | r isEmpty]
		conformTo: self protocol selector: #'next:'.

	"Errors: amount < 0."
	self value: [self canonicalObject next: -1]
		shouldRaise: Error.!

canonicalObject

	^testCase canonicalObject!

protocol
	^#'ReadStream'! !

!ReadStreamHelper class methodsFor: nil!

initialize
	"ReadStreamHelper  initialize"
	super initialize! !

!CollectionTest methodsFor: nil!

conformanceOfPutElementOnXatAllXputX: aString
	"Do Nothing, Has no conformance issue"!

conformanceOfPutElementOnXatXputX: aString
	"Do Nothing, Has no conformance issue"!

returnTypeHasLimitedElementTypes

	^false!

conformanceOfPutElementOnXatAllPutX: aString
	"Do Nothing, Has no conformance issue"! !

!CollectionTest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: CollectionHelper! !

!SequencedReadableCollectionTest methodsFor: nil!

canonicalObjects
	| helper |
	canonicalObjects isNil ifFalse: [ ^canonicalObjects ].
	helper := helpers detect: [ :each | each class == SequencedReadableCollectionHelper ].
	canonicalObjects := helper canonicalObjects.
	^canonicalObjects!

!BooleanANSITest methodsFor: nil!

testXandX
	" <boolean>#and: "
	#'Fundamental'.
	self value: [ true and: [true] ] should: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	self value: [ true and: [nil isNil] ] should: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	self value: [ true and: [false] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	self value: [ true and: [nil notNil] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	self value: [ true and: [nil selector] ]
		shouldRaise: MessageNotUnderstood.

	self value: [ false and: [true] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	self value: [ false and: [nil isNil] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	self value: [ false and: [false] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	self value: [ false and: [nil notNil] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'and:'.
	"No error:"
	self value: [ false and: [nil selector] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'and:'.!

testXnot
	" <boolean>#not "
	#'Fundamental'.
	self value: [true not] should: [:r | r = false]
		conformTo: #'boolean' selector: #'not'.
	self value: [false not] should: [:r | r = true]
		conformTo: #'boolean' selector: #'not'.!

testXxorX
	" <boolean>#xor: "
	#'Fundamental'.
	self value: [true xor: true] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'xor:'.
	self value: [true xor: false] should: [:r | r]
		conformTo: #'boolean' selector: #'xor:'.
	self value: [false xor: true] should: [:r | r]
		conformTo: #'boolean' selector: #'xor:'.
	self value: [false xor: false] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'xor:'.!

protocol
	^#boolean!

canonicalObject
	^true!

testXifFalseXifTrueX
	" <boolean>#ifFalse:ifTrue: "
	#'Fundamental'.
	self value: [ false
				ifFalse: [0]
				ifTrue: [nil selector] ]
		should: [:r | r = 0]
		conformTo: #'boolean' selector: #'ifFalse:ifTrue:'.
	self value: [ true
				ifFalse: [nil selector]
				ifTrue: [1] ]
		should: [:r | r = 1]
		conformTo: #'boolean' selector: #'ifFalse:ifTrue:'.!

testXandOp
	" <boolean>#& "
	#'Fundamental'.
	self value: [true & true] should: [:r | r]
		conformTo: #'boolean' selector: #'&'.
	self value: [true & false] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'&'.
	self value: [false & true] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'&'.
	self value: [false & false] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'&'.!

testXorX
	" <boolean>#or: "
	#'Fundamental'.
	self value: [ true or: [true] ] should: [:r | r]
		conformTo: #'boolean' selector: #'or:'.
	self value: [ true or: [false] ] should: [:r | r]
		conformTo: #'boolean' selector: #'or:'.
	"No error:"
	self value: [ true or: [nil selector] ] should: [:r | r]
		conformTo: #'boolean' selector: #'or:'.

	self value: [ false or: [true] ] should: [:r | r]
		conformTo: #'boolean' selector: #'or:'.
	self value: [ false or: [nil isNil] ] should: [:r | r]
		conformTo: #'boolean' selector: #'or:'.
	self value: [ false or: [false] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'or:'.
	self value: [ false or: [nil notNil] ] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'or:'.

	self value: [ false or: [nil selector] ]
		shouldRaise: MessageNotUnderstood.!

testXifTrueX
	" <boolean>#ifTrue: "
	#'Fundamental'.
	self value: [ true ifTrue: [1] ] should: [:r | r = 1]
		conformTo: #'boolean' selector: #'ifTrue:'.
	self value: [ false ifTrue: [1] ] should: [:r | true "unspecified"]
		conformTo: #'boolean' selector: #'ifTrue:'.!

testXifFalseX
	" <boolean>#ifFalse: "
	#'Fundamental'.
	self value: [ false ifFalse: [0] ] should: [:r | r = 0]
		conformTo: #'boolean' selector: #'ifFalse:'.
	self value: [ true ifFalse: [0] ] should: [:r | true "unspecified"]
		conformTo: #'boolean' selector: #'ifFalse:'.!

testXprintString
	" <boolean>#printString "
	#'Fundamental'.
	self value: [true printString] should: [:r | r = 'true']
		conformTo: #'boolean' selector: #'printString'.
	self value: [false printString] should: [:r | r = 'false']
		conformTo: #'boolean' selector: #'printString'.!

testXeqvX
	" <boolean>#eqv: "
	#'Fundamental'.
	self value: [true eqv: true] should: [:r | r]
		conformTo: #'boolean' selector: #'eqv:'.
	self value: [true eqv: false] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'eqv:'.
	self value: [false eqv: true] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'eqv:'.
	self value: [false eqv: false] should: [:r | r]
		conformTo: #'boolean' selector: #'eqv:'.!

testXorOp
	" <boolean>#| "
	#'Fundamental'.
	self value: [true | true] should: [:r | r]
		conformTo: #'boolean' selector: #'|'.
	self value: [true | false] should: [:r | r]
		conformTo: #'boolean' selector: #'|'.
	self value: [false | true] should: [:r | r]
		conformTo: #'boolean' selector: #'|'.
	self value: [false | false] shouldnt: [:r | r]
		conformTo: #'boolean' selector: #'|'.!

testXifTrueXifFalseX
	" <boolean>#ifTrue:ifFalse: "
	#'Fundamental'.
	self value: [ true
				ifTrue: [ 1 ]
				ifFalse: [ nil selector ] ]
		should: [:r | r = 1]
		conformTo: #'boolean' selector: #'ifTrue:ifFalse:'.
	self value: [ false
				ifTrue: [ nil selector ]
				ifFalse: [ 0 ] ]
		should: [:r | r = 0]
		conformTo: #'boolean' selector: #'ifTrue:ifFalse:'.! !

!DictionaryFactoryANSITest methodsFor: nil!

protocol
^#'Dictionary factory'!

testXwithAllX
	" <Dictionary factory>#withAll: "
	#'Collection'.!

testXnewX
	" <Dictionary factory>#new: "
	#'Collection'.!

canonicalObject
	^Dictionary!

testXnew
	" <Dictionary factory>#new "
	#'Collection'.! !

!ProtocolMsgSpec methodsFor: nil!

hasReturnValue
	"Answer true if receiver has return value specifications, else false."

	^ returnValueSpecifications notNil!

isConformingReturn: returnObject 
	"Answer true if the result, returnObject, of sending the receiver conforms to the specified return value, else false."
	| returnClass |
	#todo."??? is no return value an error or compliant ???"
	self hasReturnValue ifFalse: [^ true].
	self isReturnValueSpecByRule ifTrue: [^ false].
	returnClass := returnObject class.
	self specForEachReturnValueList
		do: [:returnSpec | (returnSpec isConformingReturnClass: returnClass)
				ifTrue: [^ true]].
	^ false!

specForEachReturnValueList
	"Answer the specification for each message return value list of the receiver."

	returnValueSpecifications isNil ifTrue: [^ self class defaultReturnValueSpecificationCollection].
	^ returnValueSpecifications!

specSections
	"Answer the specification sections of the receiver. 
	Note: specSections must be a <Dictionary> of <symbol> keys and <readableString> values.  Keys are: #'Synopsis' #'DefinedIn' #'Definition' #'RefinedIn' #'Refinement' #'Errors'."

	specSections isNil ifTrue: [^ self protocolManager defaultSpecSectionsCollection].
	^ specSections!

messageSelector
	"Answer the selector of the receiver."

	^ selector!

messageDefinition
	"Answer the definition of the receiver, or an empty string."

	#todo."??? should this be the proto is component of or Definition: sec proto ???"
	specSections isNil ifTrue: [^ String new].
	^ specSections at: #'Definition' ifAbsent: [String new]!

messageSynopsis
	"Answer the synopsis of the receiver, or an empty string."

	#todo."??? should this be the proto is component of or Definition: sec proto ???"
	specSections isNil ifTrue: [^ String new].
	^ specSections at: #'Synopsis' ifAbsent: [String new]!

hasParms
	"Answer true if receiver has parameter specifications, else false."

	^ parameterSpecifications notNil!

isConformingReturn: returnObject opRECEIVER: receiver conformTo: protocolName selector: msgSelector 
	"Answer true if the result, returnObject, of sending the receiver conforms to the protocol in which it is used, or any protocol that conforms to that protocol, else false."

	#todo."??? Figure out how to do this test ???"
	^ self isConformingReturn: returnObject!

allReferredToProtocolNames
	"Answer a list of protocol names referred to by the receiver."
	| referredToNames protocolName |
	referredToNames := Set new.
	protocolName := self definedInProtocolName.
	protocolName notNil ifTrue: [referredToNames add: protocolName].
	protocolName := self refinedInProtocolName.
	protocolName isNil ifFalse: [referredToNames add: protocolName].
	self specForEachParmList do: [:msgSpecParm | referredToNames addAll: msgSpecParm parmProtocolNames].
	self specForEachReturnValueList
		do: [:msgSpecReturn | (msgSpecReturn isKindOf: self protocolManager protocolMsgReturnValueRuleSpec)
				ifFalse: [referredToNames addAll: msgSpecReturn returnValueProtocolNames]].
	^ referredToNames!

messagePattern
	"Answer the message pattern of the receiver."
	| aStream colonCnt parmNames |
	parmNames := (self specForEachParmList collect: [:msgParmSpec | msgParmSpec parmName]) asArray.
	(selector includes: $:)
		ifFalse: 
			[parmNames size = 0 ifTrue: [^ selector asString].
			parmNames size = 1 ifTrue: [^ selector asString , ' ' , (parmNames at: 1)].
			self error: 'Mis-matched parms & selector.'].
	aStream := WriteStream on: (String new: 200).
	colonCnt := 0.
	selector
		do: [:char | char = $:
				ifTrue: 
					[colonCnt := colonCnt + 1.
					aStream nextPutAll: ': '.
					aStream nextPutAll: (parmNames at: colonCnt).
					colonCnt = parmNames size ifFalse: [aStream space]]
				ifFalse: [aStream nextPut: char]].
	^ aStream contents!

printOn: targetStream 
	"Append to targetStream a text representation of the receiver as a developer would want to see it (inspector, etc)."

	#todo."??? fix ???"
	targetStream nextPutAll: self class name;
	 nextPut: $(;
	 nextPutAll: self messageSelector;
	 nextPut: $(.
	self specForEachParmList do: [:parmSpec | targetStream nextPutAll: parmSpec parmName]
		separatedBy: [targetStream space].
	targetStream nextPutAll: ') '.
	"	self specForEachReturnValueList 
	do: [ :returnSpec | targetStream nextPutAll: returnSpec parmName ] 
	separatedBy: [targetStream space].
	"
	targetStream nextPut: $)!

definedInProtocolName
	"Answer the protocol name in which the receiver is defined, or nil."

	#todo."??? should this be the proto is component of or Definition: sec proto ???"
	specSections isNil ifTrue: [^ nil].
	^ specSections at: #'DefinedIn' ifAbsent: []!

setSelector: selectorIn specSections: specSectionsIn specForEachParmList: parmSpecsIn specForEachReturnValueList: returnValueSpecsIn 
	"Private -  
	Note: Assumes all parms have been checked for validity."

	selector := selectorIn.
	specSections := specSectionsIn.
	parameterSpecifications := parmSpecsIn.
	returnValueSpecifications := returnValueSpecsIn!

specForEachParmList
	"Answer the specification for each message parameter list of the receiver."

	parameterSpecifications isNil ifTrue: [^ self class defaultParameterSpecificationCollection].
	^ parameterSpecifications!

isReturnValueSpecByRule
	"Answer true if the receiver return value protocol is detirmined by a rule, else false."

	returnValueSpecifications isNil ifTrue: [
		^false. 
	].
	^returnValueSpecifications any isKindOf: (self protocolManager protocolMsgReturnValueRuleSpec)!

isConformingReturn: returnObject ruleReceiver: receiver operand: operand 
	"Answer true if the result, returnObject, of sending the receiver conforms to the specified return value, else false."

	#todo."??? is no return value an error or compliant ???"
	self hasReturnValue ifFalse: [^ true].
	self isReturnValueSpecByRule ifFalse: [^ false].
	^ self specForEachReturnValueList asArray first
		isConformingReturnClass: returnObject class
		ruleReceiver: receiver
		operand: operand!

fileOutOnSIFFiler: programFiler protocol: protocolName 
	"File out the receiver definition and its message definitions on ANSI SIF filer, programFiler."
	| parmString returnIsRuleSw returnOrRule tmpStream |
	#todo. "??? Add annotations ???"
	parmString := '#()'.
	self hasParms
		ifTrue: 
			[tmpStream := WriteStream on: (String new: 200).
			tmpStream nextPutAll: '#( '.
			self specForEachParmList do: [:msgParmSpec | msgParmSpec storeSIFOn: tmpStream]
				separatedBy: [tmpStream space].
			tmpStream nextPutAll: ' )'.
			parmString := tmpStream contents].
	returnIsRuleSw := false.
	returnOrRule := '#()'.
	self hasReturnValue
		ifTrue: [self isReturnValueSpecByRule
				ifTrue: 
					[returnIsRuleSw := true.
					returnOrRule := self specForEachReturnValueList asArray first returnValueRuleBlockSource]
				ifFalse: 
					[tmpStream := WriteStream on: (String new: 200).
					tmpStream nextPutAll: '#( '.
					self specForEachReturnValueList do: [:msgReturnSpec | msgReturnSpec storeSIFOn: tmpStream]
						separatedBy: [tmpStream space].
					tmpStream nextPutAll: ' )'.
					returnOrRule := tmpStream contents]].
	programFiler
		fileOutProtocol: protocolName
		message: self messagePattern
		synopsis: self messageSynopsis
		definedIn: self definedInProtocolName
		definition: self messageDefinition
		refinedIn: self refinedInProtocolName
		refinement: self messageRefinement
		parameters: parmString
		returnIsRule: returnIsRuleSw
		returnValuesOrRule: returnOrRule
		errors: self messageErrors
		annotations: Dictionary new!

hash
	"Answer the hash value for the receiver."

	#todo."I'm not sure this tests effectively for the same elements?????"
	^ self messageSelector hash!

refinedInProtocolName
	"Answer the protocol name in which the receiver is refined, or nil."

	#todo."??? should this be the proto is component of or Refinement: sec proto ???"
	specSections isNil ifTrue: [^ nil].
	^ specSections at: #'RefinedIn' ifAbsent: []!

messageErrors
	"Answer the errors of the receiver, or an empty string."

	#todo."??? should this be the proto is component of or Definition: sec proto ???"
	specSections isNil ifTrue: [^ String new].
	^ specSections at: #'Errors' ifAbsent: [String new]!

<= comperand 
	"Answer whether the receiver's message selector is less than or equal to comperand's message selector. 
	Note: This is to allow protocol message selectors to be sorted with the default sort block."

	(comperand isKindOf: self protocolManager protocolMsgSpec)
		ifFalse: [self error: 'Comperand not a ProtocolSpec.'].
	^ self messageSelector <= comperand messageSelector!

= comperand 
	"Answer whether the receiver is considered equal (contains same elements) to comperand.  They are equal if both are instances of the same class and have the same message selector."

	#todo."I'm not sure this tests effectively for the same elements?????"
	^ (comperand isKindOf: self protocolManager protocolMsgSpec)
		and: [self messageSelector == comperand messageSelector]!

messageRefinement
	"Answer the refinement of the receiver, or an empty string."

	#todo."??? should this be the proto is component of or Definition: sec proto ???"
	specSections isNil ifTrue: [^ String new].
	^ specSections at: #'Refinement' ifAbsent: [String new]!

isConformingReturn: returnObject ruleReceiver: receiver 
	"Answer true if the result, returnObject, of sending the receiver conforms to the specified return value, else false."

	#todo."??? is no return value an error or compliant ???"
	self hasReturnValue ifFalse: [^ true].
	self isReturnValueSpecByRule ifFalse: [^ false].
	^ self specForEachReturnValueList asArray first isConformingReturnClass: returnObject class ruleReceiver: receiver! !

!ProtocolMsgSpec class methodsFor: nil!

newSelector: selector specSections: specSections specsForEachParm: parmSpecs specsForEachReturnValue: retValSpecs 
	"Answer a new protocol message specification with selector, selector, specSections, specSections, a list of specifications for each parameter, parmSpecs, and a list of specifications for each return value, retValSpecs.
	Note: specSections must be a <Dictionary> of <symbol> keys and <readableString> values, parmSpecs must be a <collection> of <protocolMessageParmSpec>s, retValSpecs, a <collection> of <protocolMessageReturnSpec>s."

	^ self
		privateNewSelector: selector
		specSectionsOrNil: specSections
		specForEachParmOrListOrNil: parmSpecs
		specForEachReturnValueOrListOrNil: retValSpecs!

privateMessagePatternParmListOrNil: parmSpecsIn selector: selectorIn 
	"Private - Answer the message pattern of the receiver."
	| aStream colonCnt parmNames parmSpecsTmp |
	parmSpecsIn isNil
		ifTrue: [parmSpecsTmp := Set new]
		ifFalse: [parmSpecsTmp := parmSpecsIn].
	parmNames := (parmSpecsTmp collect: [:msgParmSpec | msgParmSpec parmName]) asArray.
	(selectorIn includes: $:)
		ifFalse: 
			[parmNames size = 0 ifTrue: [^ selectorIn asString].
			parmNames size = 1 ifTrue: [^ selectorIn asString , ' ' , (parmNames at: 1)].
			self error: 'Mis-matched parms & selectorIn.'].
	aStream := WriteStream on: (String new: 200).
	colonCnt := 0.
	selectorIn do: [:char |
		char = $:
			ifTrue: 
				[colonCnt := colonCnt + 1.
				aStream nextPutAll: ': '.
				aStream nextPutAll: (parmNames at: colonCnt).
				colonCnt = parmNames size ifFalse: [aStream space]]
			ifFalse: [aStream nextPut: char]].
	^ aStream contents!

privateValidReturnValueOrListOrNil: retValSpecsIn ifError: errorBlock 
	"Private -"
	| retValSpecsTmp |
	retValSpecsIn isNil ifTrue: [^ nil].
	(retValSpecsIn isKindOf: self protocolManager protocolMsgReturnValueSpec)
		ifTrue: 
			[retValSpecsTmp := self defaultReturnValueSpecificationCollection.
			retValSpecsTmp add: retValSpecsIn.
			^ retValSpecsTmp].
	(retValSpecsIn isKindOf: Collection)
		ifFalse: [^ errorBlock value].
	retValSpecsIn isEmpty ifTrue: [^ nil].
	retValSpecsTmp := self defaultReturnValueSpecificationCollection.
	retValSpecsIn
		do: 
			[:rvSpec | 
			(rvSpec isKindOf: self protocolManager protocolMsgReturnValueSpec)
				ifFalse: [^ errorBlock value].
			retValSpecsTmp add: rvSpec].
	^ retValSpecsTmp!

privateValidParmOrListOrNil: parmSpecsIn selector: selectorIn ifError: errorBlock 
	"Private -"
	| parmSpecsTmp colonCnt |
	(parmSpecsIn isKindOf: self protocolManager protocolMsgParmSpec)
		ifTrue: [self privateMessagePatternParmListOrNil: (Set with: parmSpecsIn)
				selector: selectorIn]
		ifFalse: [self privateMessagePatternParmListOrNil: parmSpecsIn selector: selectorIn].
	parmSpecsIn isNil ifTrue: [^ nil].
	(parmSpecsIn isKindOf: self protocolManager protocolMsgParmSpec)
		ifTrue: 
			[parmSpecsTmp := self defaultParameterSpecificationCollection.
			parmSpecsTmp add: parmSpecsIn.
			^ parmSpecsTmp].
	(parmSpecsIn isKindOf: Collection)
		ifFalse: [^ errorBlock value].
	parmSpecsIn isEmpty ifTrue: [^ nil].
	colonCnt := (selectorIn select: [:char | char = $:]) size.
	colonCnt > 0
		ifTrue: [colonCnt = parmSpecsIn size ifFalse: [self error: 'Protocol msg. spec. number of parms do not match selector.']]
		ifFalse: [parmSpecsIn size = 0 | (parmSpecsIn size = 1) ifFalse: [self error: 'Protocol msg. spec. number of parms do not match selector.']].
	parmSpecsTmp := self defaultParameterSpecificationCollection.
	parmSpecsIn
		do: 
			[:parmSpec | 
			(parmSpec isKindOf: self protocolManager protocolMsgParmSpec)
				ifFalse: [^ errorBlock value].
			parmSpecsTmp add: parmSpec].
	^ parmSpecsTmp!

privateNewSelector: selectorIn specSectionsOrNil: specSectionsIn specForEachParmOrListOrNil: parmSpecsIn specForEachReturnValueOrListOrNil: retValSpecsIn 
	"Private -"
	| newProtocolMsgSpec specSectionsTmp parmSpecsTmp retValSpecsTmp |
	(selectorIn isKindOf: Symbol)
		ifFalse: [self error: 'Protocol msg. spec. selector not a Symbol.'].
	specSectionsTmp := self privateValidSpecSectionsOrNil: specSectionsIn ifError: [^ self error: 'Protocol msg. spec. spec. sections not a Dictionary.'].
	parmSpecsTmp := self
				privateValidParmOrListOrNil: parmSpecsIn
				selector: selectorIn
				ifError: [^ self error: 'Protocol msg. spec. parm not a Collection of ProtocolMsgSpec or nil.'].
	retValSpecsTmp := self privateValidReturnValueOrListOrNil: retValSpecsIn ifError: [^ self error: 'Protocol ret. val. spec. not a Collection of MsgReturnSpec or nil.'].
	newProtocolMsgSpec := super basicNew.
	newProtocolMsgSpec
		setSelector: selectorIn
		specSections: specSectionsTmp
		specForEachParmList: parmSpecsTmp
		specForEachReturnValueList: retValSpecsTmp.
	^ newProtocolMsgSpec!

new
	"Raise an exception as this is an inappropriate message."

	^ self shouldNotImplement!

privateValidSpecSectionsOrNil: specSectionsIn ifError: errorBlock 
	"Private -"
	specSectionsIn isNil ifTrue: [^ nil].
	(specSectionsIn isKindOf: Dictionary)
		ifFalse: [^ errorBlock value].
	specSectionsIn isEmpty ifTrue: [^ nil].
	^ specSectionsIn!

defaultParameterSpecificationCollection
	"Private - Answer a <Set>, the default parameter specification collection object."

	^ Set new!

defaultReturnValueSpecificationCollection
	"Private - Answer a <Set>, the default return value specification collection object."

	^ Set new! !

!ReadStreamANSITest methodsFor: nil!

protocol
	^#'ReadStream'!

setUp

	super setUp.
	readStream := ReadStream on: 'this is a string'!

canonicalObject

	^readStream! !

!ReadStreamANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: GettableStreamHelper.
	aBlock value: CollectionStreamHelper.
	aBlock value: ReadStreamHelper.! !

!CharacterFactoryANSITest methodsFor: nil!

testXcr
	" <Character factory>#cr "
	#'Fundamental'.
	self value: [Character cr]
		should: [:r | true "implementation defined "]
		conformTo: #'Character factory' selector: #'cr'.!

testXspace
	" <Character factory>#space "
	#'Fundamental'.
	self value: [Character space]
		should: [:r | true "implementation defined "]
		conformTo: #'Character factory' selector: #'space'.!

protocol
	^#'Character factory'!

testXlf
	" <Character factory>#lf "
	#'Fundamental'.
	self value: [Character lf]
		should: [:r | true "implementation defined "]
		conformTo: #'Character factory' selector: #'lf'.!

testXtab
	" <Character factory>#tab "
	#'Fundamental'.
	self value: [Character tab]
		should: [:r | true "implementation defined "]
		conformTo: #'Character factory' selector: #'tab'.!

canonicalObject
	^Character!

testXcodePointX
	" <Character factory>#codePoint: "
	#'Fundamental'.
	self value: [Character codePoint: ($a codePoint)] should: [:r | r = $a]
		conformTo: #'Character factory' selector: #'codePoint:'.

	self value: [Character codePoint: 3000000] shouldRaise: Error.! !

!ArrayANSITest methodsFor: nil!

emptyCollection

	^self canonicalObject class new!

canonicalElement

	^self canonicalObject at: 2!

canonicalObject
	^#(1 2 3 4) copy!

protocol
	^#Array! !

!ArrayANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: SequencedCollectionHelper.
	aBlock value: SequencedReadableCollectionHelper! !

!FloatCharacterizationANSITest methodsFor: nil!

testXe
	" <floatCharacterization>#e "
	#'Numeric'.!

testXfminDenormalized
	" <floatCharacterization>#fminDenormalized "
	#'Numeric'.!

testXfmax
	" <floatCharacterization>#fmax "
	#'Numeric'.!

testXprecision
	" <floatCharacterization>#precision "
	#'Numeric'.!

testXepsilon
	" <floatCharacterization>#epsilon "
	#'Numeric'.!

testXpi
	" <floatCharacterization>#pi "
	#'Numeric'.!

protocol
	^#'floatCharacterization'!

canonicalObject
	^Float!

testXemin
	" <floatCharacterization>#emin "
	#'Numeric'.!

testXfminNormalized
	" <floatCharacterization>#fminNormalized "
	#'Numeric'.!

testXfmin
	" <floatCharacterization>#fmin "
	#'Numeric'.!

testXemax
	" <floatCharacterization>#emax "
	#'Numeric'.!

testXdenormalized
	" <floatCharacterization>#denormalized "
	#'Numeric'.!

testXradix
	" <floatCharacterization>#radix "
	#'Numeric'.! !

!MsgReturnRuleSpec methodsFor: nil!

returnProtocolName: receiver

	^self ruleBlock value: receiver!

returnValueRuleBlockSource: blockSource 
	"Set the rule block source code that when evaluated with appropiate values answers the protocol message return value conforms-to protocol name."

	ruleBlock := nil.
	ruleSourceCode := blockSource.
	(ruleSourceCode includes: $^) ifFalse: [^self].
	ruleSourceCode := ruleSourceCode select: [:c | c ~~ $^]!

printOn: targetStream 
	"Append to targetStream a text representation of the receiver as a developer would want to see it (inspector, etc)."

	targetStream nextPutAll: self class name;
	 nextPut: $(;
	 nextPutAll: self returnValueRuleBlockSource;
	 nextPut: $)!

returnValueAliasingAttribute
	"Signal an error as the receiver specifies no behavior."

	self error: 'Protocol msg. return value rule specifies no aliasing attribute.'!

newRetValRuleSourceCode: ruleBlockSource 
	"Private - ."

	ruleBlock := nil.
	ruleSourceCode := ruleBlockSource.
	(ruleSourceCode includes: $^) ifFalse: [^self].
	ruleSourceCode := ruleSourceCode select: [:c | c ~~ $^]!

isConformingReturnClass: returnClass ruleReceiver: receiver operand: operand
	"Answer true if the class, returnClass, of the result of sending a message conforms to the receiver, else false."
	| returnProtocolName |
#todo. "??? bug does not allow return in block ???"
	returnProtocolName := self ruleBlock value: receiver value: operand.
	^returnClass conformsToProtocolNamed: returnProtocolName.!

returnValueProtocolNames
	"Signal an error as the receiver specifies no behavior."

	self error: 'Protocol msg. return value rule specifies no protocol.'!

isConformingReturnClass: returnClass ruleReceiver: receiver
	"Answer true if the class, returnClass, of the result of sending a message conforms to the receiver, else false."
	 | returnProtocolName |
#todo. "??? bug does not allow return in block ???"
	returnProtocolName := self ruleBlock value: receiver.
	^returnClass conformsToProtocolNamed: returnProtocolName.!

ruleBlock

	ruleBlock isNil ifTrue: [ruleBlock := Compiler evaluate: ruleSourceCode].
	^ruleBlock!

returnValueRuleBlockSource
	"Answer the rule block source code that when evaluated with appropiate values answers the protocol message return value conforms-to protocol name."

	^ ruleSourceCode! !

!MsgReturnRuleSpec class methodsFor: nil!

newRetValRuleSourceCode: ruleBlockSource 
	"Answer a new return value specification representing a protocol message's return value conforms-to protocol determined by evaluating the rule, ruleBlockSource, with appropiate values."

	^ self privateNewRetValRuleSourceCode: ruleBlockSource!

privateNewRetValRuleSourceCode: ruleBlockSource 
	"Private - ."

	(ruleBlockSource isKindOf: String)
		ifFalse: [self error: 'Protocol msg. return value rule block source not a String.'].
	^ self basicNew newRetValRuleSourceCode: ruleBlockSource;
	 yourself! !

!ProtocolANYSpec methodsFor: nil!

conformsToMessageSelectors
	"Answer all of selectors which make up all protocols to which the receiver conforms."
	| tmpList |
	tmpList := self protocolManager defaultMessageSpecificationCollection.
	self allConformsToProtocolNames do: [:aProtocollName | tmpList addAll: (self protocolManager protocolNamed: aProtocollName) messageSelectors].
	^ tmpList!

removeSelector: unused 
	"Signal an error as the receiver specifies no behavior."

	self error: 'Protocol <' , self protocolName , '> specifies no behavior.'!

removeSelector: unused1 ifAbsent: unused2 
	"Signal an error as the receiver specifies no behavior."

	self error: 'Protocol <' , self protocolName , '> specifies no behavior.'!

wrkAllConformsToMessageSelectorsTo: aDict visited: visitedProtocols 
	self messageSelectors do: [:aMessageSelector |
		(aDict includesKey: aMessageSelector)
			ifFalse: [aDict at: aMessageSelector put: self protocolName]].
	visitedProtocols add: self protocolName.
	self conformsToProtocolNames do: [:aProtoName |
		(visitedProtocols includes: aProtoName)
			ifFalse: [(self protocolManager protocolNamed: aProtoName)
				wrkAllConformsToMessageSelectorsTo: aDict
				visited: visitedProtocols]]!

messageSelectors
	"Answer an empty list of of selectors which make up the receiver's protocol."

	^ self protocolManager defaultMessageSpecificationCollection!

protocolName
	"Answer the name of the receiver."

	^ self protocolManager protocolANYName!

renameToProtocolName: unused 
	"Signal an error as the receiver can not be renamed."

	self error: 'Protocol <' , self protocolName , '> can not be renamed.'!

removeAllSelectors: unused 
	"Signal an error as the receiver specifies no behavior."

	self error: 'Protocol <' , self protocolName , '> specifies no behavior.'!

allConformsToProtocolNames
	"Answer the names of all protocols to which the receiver conforms including super protocols."
	| tmpList |
	tmpList := self conformsToProtocolNames.
	self conformsToProtocolNames do: [:aProtocollName | tmpList addAll: (self protocolManager protocolNamed: aProtocollName) allConformsToProtocolNames].
	^ tmpList!

fileOutOnSIFFiler: programFiler 
	"Do nothing as the receiver is created by protocol initialization."

	^ self!

messageOrNilAtSelector: selector
	"Answer nil <ANY> protocol by definition can't have any messages."
	"2000/06/23 Harmon, R. Added to fix bug when TestCaseANSI >>
			#assertSend: is sent with a selector not defined in the
			target protocol or any of its inherited protocols."

	^nil!

printOn: targetStream 
	"Append to targetStream a text representation of the receiver as a developer would want to see it (inspector, etc)."

	targetStream nextPut: $<;
	 nextPutAll: self protocolName;
	 nextPut: $>;
	 nextPut: $(.
	self messageSelectors do: [:selector | targetStream nextPutAll: selector]
		separatedBy: [targetStream nextPutAll: ', '].
	targetStream nextPut: $)!

allMessageSelectors
	"Answer all of selectors which make up the receiver's protocol and all protocols to which the receiver conforms."
	| tmpList |
	tmpList := self messageSelectors.
	self allConformsToProtocolNames do: [:aProtocollName | tmpList addAll: (self protocolManager protocolNamed: aProtocollName) messageSelectors].
	^ tmpList!

conformingBehaviors
	"Answer all classes in class then metaclass hierarchy order (i.e. superclasses first) as all conform to the receiver. 
	Note: Return value is a <OrderedCollection> of  class or metaclass objects."
	| answer |
	answer := OrderedCollection new: 10.
	Smalltalk allClasses do: [:class | 
		answer addLast: class.
		answer addLast: class class].
	^ answer!

messages
	"Answer an empty list of of message specifications of the receiver."

	^ self protocolManager defaultMessageSpecificationCollection!

hash
	"Answer the hash value for the receiver."

	^ self protocolName hash!

selectorsInBehavior: classOrMetaclass 
	"Answer an empty list of selectors ofcorresponding messages as all classes and metaclasses conform to the receiver but it specifies no behavior."

	^ Set new!

<= comperand 
	"Answer whether the receiver is less than or equal to comperand. 
	Note: This is to allow protocols to be sorted with the default sort block."

	(comperand isKindOf: self protocolManager protocol)
		| (comperand isKindOf: self protocolManager protocolANY) ifFalse: [self error: 'Comperand not a ProtocolSpec.'].
	^ self protocolName asLowercase <= comperand protocolName asLowercase!

conformsToProtocolNames
	"Answer an empty list of protocol names to which the receiver conforms."

	^ self protocolManager defaultConformsToCollection!

= comperand 
	"Answer whether the receiver is considered equal (contains same elements) to comperand."

	^ (comperand isKindOf: self protocolManager protocol)
		and: [self protocolName == comperand protocolName]!

protocolDescription
	"Answer a description of the receiver."

	^ 'A protocol to which all other protocols conform.' copy!

displayOn: targetStream 
	"Append the receiver to targetStream in a format that a user would want to see."

	targetStream nextPut: $<;
	 nextPutAll: self protocolName;
	 nextPut: $>!

addUndefinedProtocolNames

	^ self!

includesSelector: unused 
	"Answer false as the receiver specifies no behavior."

	^ false! !

!ProtocolANYSpec class methodsFor: nil!

new
	"Raise an exception as this is an inappropriate message."

	^ self shouldNotImplement!

privateNewProtocolANY
	"Private -"
	| newProtocol |
	newProtocol := self basicNew.
	^ newProtocol! !

!WriteFileStreamANSITest methodsFor: nil!

testXflush
	" <puttableStream>#flush "
	#'File Stream'.!

testXnextPutX
	" <puttableStream>#nextPut: "
	#'File Stream'.!

testXisEmpty
	" <sequencedStream>#isEmpty "
	#'File Stream'.!

protocol
	^#'writeFileStream'!

testXtab
	" <puttableStream>#tab "
	#'File Stream'.!

setUp
	super setUp.
	" This method will create a file named 'ansiTestFile.junk' in the current directory
	if it does not already exist. "

	"writeFileStream := FileStream write: 'ansiTestFile.junk'"!

testXspace
	" <puttableStream>#space "
	#'File Stream'.!

testXsetToEnd
	" <sequencedStream>#setToEnd "
	#'File Stream'.!

testXpositionX
	" <sequencedStream>#position: "
	#'File Stream'.!

testXisBinary
	" <FileStream>#isBinary "
	#'File Stream'.!

tearDown
	"writeFileStream close"!

testXcontents
	" <FileStream>#contents "
	#'File Stream'.!

testXreset
	" <sequencedStream>#reset "
	#'File Stream'.!

testXisText
	" <FileStream>#isText "
	#'File Stream'.!

testXclose
	" <sequencedStream>#close "
	#'File Stream'.!

testXexternalType
	" <FileStream>#externalType "
	#'File Stream'.!

testXcr
	" <puttableStream>#cr "
	#'File Stream'.!

testXnextPutAllX
	" <puttableStream>#nextPutAll: "
	#'File Stream'.!

canonicalObject
	^writeFileStream!

testXposition
	" <sequencedStream>#position "
	#'File Stream'.! !

!WriteStreamANSITest methodsFor: nil!

protocol
	^#'WriteStream'!

setUp
	super setUp.
	writeStream := WriteStream with: 'this is a string' copy!

canonicalObject
	^writeStream! !

!WriteStreamANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: PuttableStreamHelper.
	aBlock value: CollectionStreamHelper.
	aBlock value: WriteStreamHelper.! !

!WriteStreamFactoryANSITest methodsFor: nil!

protocol
	^#'WriteStream factory'!

canonicalObject
	^WriteStream!

testXwithX

	self value: [self canonicalObject with: 'this is a string']
		should: [:r | r position = ('this is a string' size)
					& r contents = 'this is a string']
		conformTo: self protocol selector: #'with:'.! !

!DyadicValuableANSITest methodsFor: nil!

testXvalueWithArgumentsX
	" <valuable>#valueWithArguments: "
	#'Valuable'.
	self value: [blk2args valueWithArguments: #(1 2)]
		should: [:r | r = #(1 2)]
		conformTo: #'valuable' selector: #'valueWithArguments:'.!

testXargumentCount
	" <dyadicValuable>#argumentCount "
	#'Valuable'.
	self value: [blk2args argumentCount] should: [:r | r = 2]
		conformTo: #'dyadicValuable' selector: #'argumentCount'.!

protocol
	^#'dyadicValuable'!

setUp
	super setUp.
	blk2args := [ :arg1 :arg2 | Array with: arg1 with: arg2 ].!

testXvalueXvalueX
	" <dyadicValuable>#value:value: "
	#'Valuable'.
	self value: [blk2args value: 1 value: 2] should: [:r | r = #(1 2)]
		conformTo: #'dyadicValuable' selector: #'value:value:'.!

canonicalObject
	^blk2args! !

!ExtensibleCollectionHelper methodsFor: nil!

testXaddAllX
	" <extensibleCollection>#addAll: "
	| extensibleCollection addCollection compareCollection |
	#'Collection'.
	extensibleCollection := self object.
	self
		value: [extensibleCollection addAll: #(666 777)]	
		should: [:result | (extensibleCollection includes: 777) and: [extensibleCollection includes: 666]]
		conformTo: #extensibleCollection
		selector: #addAll:.
	addCollection := OrderedCollection with: 555 with: 444.
	extensibleCollection := self object.
	compareCollection := self object.
	self should: [(addCollection do: [:each | extensibleCollection add: each]) = (compareCollection addAll: addCollection)]!

testXremoveX
	" <extensibleCollection>#remove: "
	| extensibleCollection sampleValue |
	#'Collection'.

	extensibleCollection := self object.
	extensibleCollection do: [ :each | sampleValue := each].
	self
		value: [ extensibleCollection remove: sampleValue ]	
		should: [:result | (extensibleCollection includes: sampleValue) not ]
		conformTo: #extensibleCollection
		selector: #remove:!

testXaddX
	" <extensibleCollection>#add: "
	| extensibleCollection |
	#'Collection'.
	extensibleCollection := self object.
	self
		value: [ extensibleCollection add: 777 ]	
		should: [:result | extensibleCollection includes: 777]
		conformTo: #extensibleCollection
		selector: #add:!

testXremoveAllX
	" <extensibleCollection>#removeAll: "
	| extensibleCollection removeAll |
	#'Collection'.

	extensibleCollection := self object.
	removeAll := self object.
	self
		value: [ 	extensibleCollection removeAll: removeAll]	
		should: [:result | extensibleCollection isEmpty ]
		conformTo: #extensibleCollection
		selector: #removeAll:!

object: anObject!

testXremoveXifAbsentX
	" <extensibleCollection>#remove:ifAbsent: "
	| extensibleCollection sampleValue |
	#'Collection'.
	
	extensibleCollection := self object.
	extensibleCollection do: [ :each | sampleValue := each].
	self
		value: [ extensibleCollection remove: sampleValue ifAbsent: [#foo]]	
		should: [:result | result = sampleValue ]
		conformTo: #extensibleCollection
		selector: #remove:ifAbsent:.
	self
		value: [ extensibleCollection remove: sampleValue ifAbsent: [#foo]]	
		should: [:result | result = #foo ]
		conformTo: #extensibleCollection
		selector: #remove:ifAbsent:!

object
	^testCase canonicalObject! !

!SetFactoryANSITest methodsFor: nil!

testXwithX
	" <Set factory>#with: "
	#'Collection'.!

testXwithXwithX
	" <Set factory>#with:with: "
	#'Collection'.!

testXnew
	" <Set factory>#new "
	#'Collection'.!

protocol
	^#'Set factory'!

testXnewX
	" <Set factory>#new: "
	#'Collection'.!

testXwithAllX
	" <Set factory>#withAll: "
	#'Collection'.!

canonicalObject
	^Set!

testXwithXwithXwithX
	" <Set factory>#with:with:with: "
	#'Collection'.!

testXwithXwithXwithXwithX
	" <Set factory>#with:with:with:with: "
	#'Collection'.! !

!ObjectANSITest methodsFor: nil!

protocol
	^#Object!

setUp
	super setUp.
	object := Object new.!

canonicalObject
	^object! !

!NotificationClassANSITest methodsFor: nil!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXallSubclasses
	" <classDescription>#allSubclasses "
	#'Exception'.!

testXname
	" <classDescription>#name "
	#'Exception'.!

testXsuperclass
	" <classDescription>#superclass "
	#'Exception'.!

protocol
	^#'Notification class'!

testXconcatenateOp
	" <exceptionSelector>#, "
	#'Exception'.!

testXallSuperclasses
	" <classDescription>#allSuperclasses "
	#'Exception'.!

testXnew
	" <Notification class>#new "
	#'Exception'.
	self value: [Notification new]
		should: [:r | true "??? r = Notification signal ???"]
		conformTo: #'Notification class' selector: #'new'.!

testXsignal
	" <Exception class>#signal "
	#'Exception'.!

canonicalObject
	^Notification!

testXhandlesX
	" <Exception class>#handles: "
	#'Exception'.!

testXsubclasses
	" <classDescription>#subclasses "
	#'Exception'.! !

!NiladicBlockANSITest methodsFor: nil!

setUp
	super setUp.
	blk0args := [ Array new ].
	canonicalObject := [3+4]!

testXonXdoX
	" <niladicBlock>#on:do: "
	#'Valuable'.
	self value: [ [#( 1 2 ) size] on: Error do: [ :error | error return: -1] ]
		should: [:r | r = 2]
		conformTo: #'niladicBlock' selector: #'on:do:'.

	self value: [[Error signal. 0] on: Error do: [:error | error return: -1]]
		should: [:r | r = -1]
		conformTo: #'niladicBlock' selector: #'on:do:'.!

testXwhileTrueX
	" <niladicValuable>#whileTrue: "
	| sum |
	#'Valuable'.
	sum := 0.
	self value: [ [sum < 4 ] whileTrue: [sum := sum + 1] ]
		should: [:r | sum = 4]
		conformTo: #'niladicValuable' selector: #'whileTrue:'.

	sum := 0.
	self value: [ [sum < 0 ] whileTrue: [sum := sum + 1] ]
		should: [:r | sum = 0]
		conformTo: #'niladicValuable' selector: #'whileTrue:'.!

testXensureX
	" <niladicBlock>#ensure: "
	| flag tmp |
	#'Valuable'.
	flag := 0.
	self value: [	[#( 1 2 ) size] ensure: [flag := 1] ]
		should: [:r | r = 2 & flag = 1]
		conformTo: #'niladicBlock' selector: #'ensure:'.

#'todo'."I don't think this is a good test."
	flag := 0.
	[tmp := [#( 1 2 ) siz] ensure: [ flag := 1 ].
	] on: MessageNotUnderstood do: [ :mnu | mnu return ].
	self value: [tmp] should: [:r | flag = 1]
		conformTo: #'niladicBlock' selector: #'ensure:'.

	self value: [ [#( 1 2 ) siz] ensure: [ flag := 1 ] ]
		shouldRaise: MessageNotUnderstood.

#'todo'."or this ."
	flag := 0.

	[tmp := [Error signal] ensure: [ flag := 1 ].
	] on: Error do: [ :error | error return ].
	self value: [ tmp ] should: [:r | flag = 1]
		conformTo: #'niladicBlock' selector: #'ensure:'.
	self value: [ [Error signal] ensure: [ flag := 1 ] ]
		shouldRaise: Error.

#'testAnom'. "??? I think the ensure block should not be evaluated as per:
	Activation of an exception handler from within the receiver is not in and of itself an abnormal termination.  However, if the exception handler for an exception that is not resumable results in termination of the receiver or if its handler block contains a return statement that results in abnormal termination of the receiver, then terminationBlock will be evaluated after evaluation of the exception handler.
 
	flag := 0.
	[tmp := [Notification signal] ensure: [ flag := 1 ].
	] on: Notification do: [ :notification | notification resume ].
	self value: [ tmp ] should: [:r | flag = 0]
		conformTo: #'niladicBlock' selector: #'ensure:'.
???"
	self value: [ [Notification signal] ensure: [] ]
		shouldRaise: Notification.!

protocol
	^#'niladicBlock'!

testXargumentCount
	" <niladicValuable>#argumentCount "
	#'Valuable'.
	self value: [blk0args argumentCount] should: [:r | r = 0]
		conformTo: #'niladicValuable' selector: #'argumentCount'.!

testXwhileTrue
	" <niladicValuable>#whileTrue "
	| sum |
	#'Valuable'.
	sum := 0.
	self value: [ [(sum := sum + 1) < 4 ] whileTrue ]
		should: [:r | sum = 4]
		conformTo: #'niladicValuable' selector: #'whileTrue'.!

testXvalueWithArgumentsX
	" <valuable>#valueWithArguments: "
	#'Valuable'.
	self value: [blk0args valueWithArguments: #()] should: [:r | r = #()]
		conformTo: #'valuable' selector: #'valueWithArguments:'.!

testXwhileFalse
	" <niladicValuable>#whileFalse "
	| sum |
	#'Valuable'.
	sum := 0.
	self value: [ [(sum := sum + 1) >= 3] whileFalse]
		should: [:r | sum = 3]
		conformTo: #'niladicValuable' selector: #'whileFalse'.!

testXvalue
	" <niladicValuable>#value "
	#'Valuable'.
	self value: [blk0args value] should: [:r | r = #()]
		conformTo: #'niladicValuable' selector: #'value'.!

canonicalObject
	^canonicalObject!

testXifCurtailedX
	" <niladicBlock>#ifCurtailed: "
	| flag tmp |
	#'Valuable'.
	self value: [ [flag := 0] ifCurtailed: [flag := 1] ]
		should: [:r | r = 0 & flag = 0]
		conformTo: #'niladicBlock' selector: #'ifCurtailed:'.

	[tmp := [Notification signal. 0] ifCurtailed: [flag := 1].
	] on: Notification do: [ :notification | notification resume ].
	self value: [ tmp ] should: [:r | r = 0 & flag = 0]
		conformTo: #'niladicBlock' selector: #'ifCurtailed:'.!

testXwhileFalseX
	" <niladicValuable>#whileFalse: "
	| element aReadStream |
	#'Valuable'.
	aReadStream := ReadStream on: (Array with: 1 with: 2 with: 3).
	self value: [[aReadStream atEnd] whileFalse: [
					element := aReadStream next]]
		should: [:r | element = 3]
		conformTo: #'niladicValuable' selector: #'whileFalse:'.

	element := 0.
	self value: [ [element = 0] whileFalse: [element := 1] ]
		should: [:r | element =  0]
		conformTo: #'niladicValuable' selector: #'whileFalse:'.! !

!MessageNotUnderstoodSelectorANSITest methodsFor: nil!

testXhandlesX
	" <MessageNotUnderstoodSelector>#handles: "
	#'Exception'.
	self value: [	[ MessageNotUnderstood signal
				] on: MessageNotUnderstood do: [ :mnu |
					mnu return: (MessageNotUnderstood handles: mnu) ] ]
		should: [:r | r]
		conformTo: #'MessageNotUnderstoodSelector' selector: #'handles:'.

	" ??? should! "
	self value: [	[ MessageNotUnderstood signal
				] on: MessageNotUnderstood do: [ :mnu |
					mnu return: (Error handles: mnu) ] ]
		should: [:r | r]
		conformTo: #'MessageNotUnderstoodSelector' selector: #'handles:'.!

testXconcatenateOp
	" <exceptionSelector>#, "
	#'Exception'.!

canonicalObject
	^MessageNotUnderstood!

protocol
	^#MessageNotUnderstoodSelector! !

!FractionANSITest methodsFor: nil!

testXasScaledDecimalX
	" <number>#asScaledDecimal: "
	#'Numeric'.
	self value: [(1/2) asScaledDecimal: 2]
		should: [:r | r = 0.5s2 & (r scale = 2)]
		conformTo: #'number' selector: #'asScaledDecimal:'.
	self value: [(-1/2) asScaledDecimal: 2]
		should: [:r | r = -0.5s2 & (r scale = 2)]
		conformTo: #'number' selector: #'asScaledDecimal:'.!

testXtoXbyXdoX
	" <number>#to:by:do: "
	#'Numeric'.!

testXasInteger
	" <number>#asInteger "
	#'Numeric'.
	self value: [(1/3) asInteger] should: [:r | r = 0]
		conformTo: #'number' selector: #'asInteger'.
	self value: [(1/2) asInteger] should: [:r | r = 1]
		conformTo: #'number' selector: #'asInteger'.
	self value: [(-1/2) asInteger] should: [:r | r = -1]
		conformTo: #'number' selector: #'asInteger'.!

testXdenominator
	" <Fraction>#denominator "
	#'Numeric'.!

testXmaxX
	" <magnitude>#max: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [(1/2) max: 3] should: [:r | r = 3]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [(-9000000000/2) max: -2000000000]
		should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [(1/2) max: 2000000003] should: [:r | r = 2000000003]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [(1/2) max: 3.0] should: [:r | r = 3.0]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [(1/2) max: (5/2)] should: [:r | r = (5/2)]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [(1/2) max: 3.0s3] should: [:r | r = 3.0s3]
		conformTo: #'magnitude' selector: #'max:'.

	"Num max: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) max: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'max:'
	].!

testXnotEqualityOp
	" <Object>#~= "
	#'Numeric'.
"	The value of receiver ~= comparand is true if and only if the value of
comparand ~= receiver would also be true.
"
	self value: [fractionHalf ~= (2/3)]
		should: [:r | r] conformTo: #'Object' selector: #'~='.

	self value: [smallInt2 ~= (6/2)]
		should: [:r | r] conformTo: #'Object' selector: #'~='.

	self value: [fractionHalf ~= fractionHalf]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.

	self value: [smallInt2 ~= (4/2)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver  and min or max are not comparable"

	self value: [(1/2) between: 0 and: 3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/ -2) between: -2000000003 and: 0]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: 0 and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: 0.0 and: 3.0]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: (1/4) and: (5/2)]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: 0.0s3 and: 3.0s3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	self value: [(1/2) between: -2000000001 and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: 0.0 and: 3.0s3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"Num between: Num and: Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx)
					between: (numList at: ndx)
					and: (numList at: ndx)]
			should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'
	].

	self value: [(1/2) between: 3 and: 4]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: -2000000003 and: -2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: 2000000003 and: 2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: 3.0 and: 5.0]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: (5/2) and: (7/2)]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [(1/2) between: 3.0s3 and: 5.0s3]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"??? min not min but max and vice versa -> false ???"
	self value: [(1/2) between: 3 and: 1]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.!

testXabs
	" <number>#abs (Return Values: <RECEIVER>) "
	| rcvr |
	#'Numeric'.
	rcvr := 1/2.
	self value: [rcvr abs] should: [:r | r = (1/2)]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := -1/2.
	self value: [rcvr abs] should: [:r | r = (1/2)]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.!

testXraisedToIntegerX
	" <number>#raisedToInteger: (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 51/10.
	self value: [rcvr raisedToInteger: 0] should: [:r | r = 1]
		conformTo: #'number' selector: #'raisedToInteger:' opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 1] should: [:r | r = rcvr]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 2] should: [:r | r = (2601/100)]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr negated raisedToInteger: 2]
		should: [:r | r = (2601/100)]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: -2] should: [:r | r = ( 100/2601)]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	"It is erroneous if the operand does not conform
		to the protocol <integer>."
	self value: [rcvr raisedToInteger: (51/10)]
		shouldRaise: Error.!

testXasFraction
	" <number>#asFraction "
	#'Numeric'.
	self value: [(1/2) asFraction] should: [:r | r = (1/2)]
		conformTo: #'number' selector: #'asFraction'.
	self value: [(-1/2) asFraction] should: [:r | r = (-1/2)]
		conformTo: #'number' selector: #'asFraction'.!

testXisKindOfX
	" <Object>#isKindOf: "
	#'Numeric'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
#todo. "Fix find a test for unspecified rule above ???"
	self value: [fractionHalf isKindOf: Fraction]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Metaclass tests:"
	self value: [fractionHalf class isKindOf: (Fraction class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Inherit tests:"
	self value: [fractionHalf class isKindOf: (Number class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	self value: [fractionHalf isKindOf: Symbol]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.!

testXtruncated
	" <number>#truncated "
	#'Numeric'.
	self value: [(1/3) truncated] should: [:r | r = 0]
		conformTo: #'number' selector: #'truncated'.
	self value: [(3/2) truncated] should: [:r | r = 1]
		conformTo: #'number' selector: #'truncated'.
	self value: [(-1/2) truncated] should: [:r | r = 0]
		conformTo: #'number' selector: #'truncated'.!

testXroundToX
	" <number>#roundTo: (returnRule - :receiver :operand) "
	| retVals frac |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	frac := (51/10).
	retVals := #(6 0 0 6.0 5 6.000s3).
	1 to: numList size do: [ :ndx |
		self value: [frac roundTo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'roundTo:'
			ruleReceiver: frac operand: (numList at: ndx)
	].

	self should: [(0.0 roundTo: fractionHalf) = 0.0]!

testXasFloat
	" <number>#asFloat "
	#'Numeric'.
	self value: [(1/2) asFloat] should: [:r | r = 0.5]
		conformTo: #'number' selector: #'asFloat'.
	self value: [(-1/2) asFloat] should: [:r | r = -0.5]
		conformTo: #'number' selector: #'asFloat'.!

testXremX
	" <number>#rem: "
	| retVals ndx num2 frac |
	#'Numeric'.
	"Within the limits of representation, the following invariant should hold:
		(receiver quo: operand)*operand + (receiver rem: operand) = receiver"
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	numList := #( 5 5.0 5.0s3 ).
	frac := (53/2).
	retVals := Array with: (3/2) with: 1.5 with: (3/2).
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self value: [frac rem: num]
			should: [:r | r = (retVals at: ndx)
					& ((frac quo: num) * num + (frac rem: num)
						= frac)]
			conformTo: #'number' selector: #'rem:'
	].

	numList := numList collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self value: [frac rem: num]
			should: [:r | r = (retVals at: ndx)
					& ((frac quo: num) * num + (frac rem: num)
						= frac)]
			conformTo: #'number' selector: #'rem:'
	].

	frac := (-53/2).
	numList := #( 5 5.0 5.0s3 ).
	retVals := retVals collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self should: [(frac rem: num) = (retVals at: ndx)
					& ((frac quo: num) * num + (frac rem: num)
						= frac)]
	].

	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self should: [(frac rem: num) = (retVals at: ndx)
					& ((frac quo: num) * num + (frac rem: num)
						= frac)]
	].

	frac := (53/2).
	num2 := (5/2).
	self value: [frac rem: num2]
		should: [:r | r = (3/2)
				& ((frac quo: num2) * num2 + (frac rem: num2)
					= frac)]
		conformTo: #'number' selector: #'rem:'.

	frac := (20000000003/2).
	numList := #( -2000000000 2000000000 ).
	numList do: [ :num |
		self value: [frac rem: num]
			should: [:r | r = (3/2)
					& ((frac quo: num) * num + (frac rem: num)
						= frac)]
			conformTo: #'number' selector: #'rem:'
	].

	"If either the receiver or operand are of type <Float> and the operand has a value of zero, the result is implementation defined.  The implementation may signal the ZeroDivide exception or provide a continuation value "
	self value: [fractionHalf rem: 0.0] shouldRaise: ZeroDivide.
	self value: [fractionHalf rem: 0] shouldRaise: ZeroDivide.!

testXnotIdentityOp
	" <Object>#~~ "
	#'Numeric'.
"	The value of receiver ~~ comparand is true if and only if the value of comparand ~~ receiver would also be true.
"
	self should: [fractionHalf ~~ (2/3) and: [(2/3) ~~ fractionHalf]].

	self value: [fractionHalf ~~ (2/3)]
		should: [:r | r] conformTo: #'Object' selector: #'~~'.

	self value: [smallInt2 ~~ (6/2)]
		should: [:r | r] conformTo: #'Object' selector: #'~~'.

	self value: [fractionHalf ~~ fractionHalf]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~~'.

	self value: [smallInt2 ~~ (4/2)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~~'.!

testXtoXbyX
	" <number>#to:by: "
	#'Numeric'.!

testXequalityOp
	" <number>#= "
	#'Numeric'.
"	receiver = comparand	=>
	receiver hash = comparand hash
"
	self value: [fractionHalf = fractionHalf]
		should: [:r | r & (fractionHalf hash = fractionHalf hash) ]
		conformTo: #'number' selector: #'='.
	self value: [ fractionHalf = (5/2) ]
		shouldnt: [ :r | r | (fractionHalf hash = (5/2) hash) ]
		conformTo: #'number' selector: #'='.

"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	self value: [ fractionHalf = 2 ]
		should: [ :r | r  ifTrue: [ fractionHalf hash = 2 hash ]
							ifFalse: [ fractionHalf hash ~= 2 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ fractionHalf = -2000000000 ]
		should: [ :r | r ifTrue: [ fractionHalf hash = -2000000000 hash ]
						ifFalse: [ fractionHalf hash ~= -2000000000 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ fractionHalf = 2000000000 ]
		should: [ :r | r ifTrue: [ fractionHalf hash = 2000000000 hash ]
						ifFalse: [ fractionHalf hash ~= 2000000000 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ fractionHalf = 0.5 ]
		should: [ :r | r ifTrue: [ fractionHalf hash = 0.5 hash ]
						ifFalse: [ fractionHalf hash ~= 0.5 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ fractionHalf = 0.5s3 ]
		should: [ :r | r ifTrue: [ fractionHalf hash = 0.5s3 hash ]
						ifFalse: [ fractionHalf hash ~= 0.5s3 hash ]  ]
		conformTo: #'number' selector: #'='.!

testXstrictlyPositive
	" <number>#strictlyPositive "
	#'Numeric'.
	self value: [(1/2) strictlyPositive] should: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.

	self value: [(-1/2) strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.!

testXidentityOp
	" <Object>#== "
	#'Numeric'.
"	The value of receiver == comparand is true if and only if the value of comparand == receiver would also be true. If the value of receiver == comparand is true then the receiver and comparand must have equivalent identity hash values.  Or more formally:

	receiver == comparand =>
	receiver identityHash = comparand identityHash
"
	self value: [fractionHalf == fractionHalf]
		should: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [smallInt2 == (4/2)]
		should: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [fractionHalf == (2/3)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [smallInt2 == (6/2)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.!

testXnegated
	" <number>#negated (Return Values: <RECEIVER>) "
	| rcvr |
	#'Numeric'.
	rcvr := 3/2.
	self value: [rcvr negated] should: [:r | r = (-3/2)]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.
	rcvr := -3/2.
	self value: [rcvr negated] should: [:r | r = (3/2)]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.!

testXisMemberOfX
	" <Object>#isMemberOf: "
	#'Numeric'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
#todo. "Fix find a test for unspecified rule above ???"
	self value: [fractionHalf isMemberOf: Fraction]
		should: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	"Metaclass tests:"
	self value: [fractionHalf class isMemberOf: (Fraction class)]
		should: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	"Fail inherit tests:"
	self value: [fractionHalf class isMemberOf: (Number class)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	self value: [fractionHalf isMemberOf: Float]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.!

testXsquared
	" <number>#squared (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 51/10.
	self value: [rcvr squared] should: [:r | r = (2601/100)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

	rcvr := -51/10.
	self value: [rcvr squared] should: [:r | r = (2601/100)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.!

testXremainderIntegerDivideOp
	" <number>#\\ (returnRule - :receiver :operand) "
	"The remainder has the same sign as operand.
	Within the limits of representation, the following invariant should hold:

		(receiver // operand) * operand + (receiver \\ operand) = receiver
 "
	| retVals recList ndx |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	recList := #( 26 -26000000006 26000000006 26.0 0 26.0s3 ) copy.
	recList at: 5 put: (53/2).
	retVals := #( 0 1 0 0.5 1 0 ) copy.
	retVals at: 1 put: (1/2).
	retVals at: 3 put: (1/2).
	retVals at: 6 put: (1/2).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ (3/2)]
			should: [:r | r = (retVals at: ndx)
					& ((rec // (3/2)) * (3/2) + (rec \\ (3/2)) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  (3/2).
	].

	"The remainder has the same sign as operand."
	retVals := #(-1 0 -1 -1.0 0 -1.000s3 ) copy.
	retVals at: 2 put: (-1/2).
	retVals at: 5 put: (-1/2).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ (-3/2)]
			should: [:r | r = (retVals at: ndx)
					& ((rec // (-3/2)) * (-3/2) + (rec \\ (-3/2)) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  (-3/2).
	].

	self should: [(53/2) \\ (3/2) = 1
				& (((53/2) // (3/2)) * (3/2) + ((53/2) \\ (3/2)) = (53/2))].
	self should: [(53/2) \\ (-3/2) = (-1/2)
				& (((53/2) // (-3/2)) * (-3/2) + ((53/2) \\ (-3/2)) = (53/2))].

	self should: [0 \\ fractionHalf = 0].

	"If the operand is zero, the ZeroDivide must be signaled."
	self value: [fractionHalf \\ 0] shouldRaise: ZeroDivide.!

testXraisedToX
	" <number>#raisedTo: "
	| numVals retVals |
	#'Numeric'.
	numVals := #(2 2.0 0 2.0s3 ) copy.
	numVals at: 3 put: (1/2).
	retVals := #(0 0.25 0.7071067811865475 0.25 ) copy.
	retVals at: 1 put: (1/4).
	1 to: numVals size do: [ :ndx |
		self value: [fractionHalf raisedTo: (numVals at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'.
	].


	retVals := #(4 4.0 1.414213562373095 4.0 ).
	1 to: numVals size do: [ :ndx |
		self value: [fractionHalf raisedTo: ((numVals at: ndx) negated)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'
	].

	self value: [fractionHalf raisedTo: 0.0] should: [:r | r = 1]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [0.0 raisedTo: fractionHalf] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [fractionHalf raisedTo: 1.0] should: [:r | r = fractionHalf]
		conformTo: #'number' selector: #'raisedTo:'.

	"It is erroneous if the receiver equals zero
		and the operand is less than or equal to zero,"
	self value: [0.0 raisedTo: (fractionHalf negated)]
		shouldRaise: Error.

	"	or if the receiver is less than zero."
	self value: [fractionHalf negated raisedTo: 2.0]
		shouldRaise: Error.!

testXceiling
	" <number>#ceiling "
	#'Numeric'.
	self value: [(1/3) ceiling] should: [:r | r = 1]
		conformTo: #'number' selector: #'ceiling'.
	self value: [(1/2) ceiling] should: [:r | r = 1]
		conformTo: #'number' selector: #'ceiling'.
	self value: [(-1/2) ceiling] should: [:r | r = 0]
		conformTo: #'number' selector: #'ceiling'.!

testXreciprocal
	" <number>#reciprocal (returnRule - :receiver) "
	#'Numeric'.
	self value: [fractionHalf reciprocal] should: [:r | r = 2]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: fractionHalf!

testXaddOp
	" <number>#+ (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := Array new: 6.
	retVals at: 1 put: (5/2).

	retVals at: 2 put: (-3999999999/2).
	retVals at: 3 put: (4000000001/2).
	retVals at: 4 put: 2.5.
	retVals at: 5 put: 1.
	retVals at: 6 put: (5/2).
	1 to: numList size do: [ :ndx |
		self value: [fractionHalf + (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'+'
			ruleReceiver: fractionHalf operand: (numList at: ndx)
	].!

testXidentityHash
	" <Object>#identityHash "
	#'Numeric'.
	self value: [fractionHalf identityHash]
		should: [:r | r = fractionHalf identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [smallInt2 identityHash]
		should: [:r | r = (4/2) identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [fractionHalf identityHash]
		shouldnt: [:r | r = (2/3) identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [smallInt2 identityHash]
		shouldnt: [:r | r = (6/2) identityHash]
		conformTo: #'Object' selector: #'identityHash'.!

testXintegerDivideOp
	" <number>#// "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	"The sign of the result is positive if the receiver and operand
		have the same sign, and negative if the signs are different."
	retVals := #(666666666 -1 0 666666666 2666666666 666666666 ).
	1 to: numList size do: [ :ndx |
		self value: [(4000000000/3) // (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'.
	].

"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #( -666666667 0 -1 -666666667 -2666666667 -666666667 ).
	1 to: numList size do: [ :ndx |
		self value: [(4000000000/3) // ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'
	].

	self should: [(256/5) // (50/5) = 5].

	self should: [(126/5) // 5 = 5].
	self should: [(125000000001/5) // 5000000000 = 5].
	self should: [(-125000000001/5) // -5000000000 = 5].
	self should: [(131/5) // 5.1 = 5].
	self should: [(131/5) // 5.1s1 = 5].

	self value: [0 // fractionHalf] should: [:r | r = 0]
		conformTo: #'number' selector: #'//'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [fractionHalf // 0] shouldRaise: ZeroDivide.!

testXpositive
	" <number>#positive "
	#'Numeric'.
	self value: [(1/2) positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [(-1/2) positive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'positive'.!

testXgreaterThanOrEqualToOp
	" <magnitude>#>= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small >= Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(1/3) >= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [(-9000000005/3) >= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [(1/4) >= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.

	"Num >= Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) >= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'>='
	].

	"Big >= Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(11/2) >= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [(9000000005/3) >= 2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [(-1000000005/3) >= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [(11/2) >= (1/2)] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.!

testXtoX
	" <number>#to: "
	| start middleNdx stop2 |
	#'Numeric'.
	start := (1/2).
	numList := #( 2 2.0 0 2.0s3 ) copy.
	numList at: 3 put: (3/2).
	numList do: [ :stop |
		self value: [start to: stop]
			should: [:r | (r size = 2)
					". . . the last element in the sequence . . . is . . .[:]
						receiver + ((stop - receiver) // 1)"
					& (r last = (start + ((stop - start) // 1)))
					"The elements conform to the receiver's protocol."
					& (r allSatisfy: [ :elem |
						elem class conformsToProtocolNamed: #'Fraction'])
			]
			conformTo: #'number' selector: #'to:'
	].

	start := (3/2).
	stop2 := (4000000001/2).
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'Fraction'])
		]
		conformTo: #'number' selector: #'to:'.

	start := (-4000000001/2).
	stop2 := (-3/2).
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'Fraction'])
		]
		conformTo: #'number' selector: #'to:'.

	"The interval answered will be empty if the receiver is greater than stop."
	self value: [(1/2) to: (-1/2)]
		should: [:r | (r isEmpty)] conformTo: #'number' selector: #'to:'!

canonicalObject
	^1/3!

testXasFloatE
	" <number>#asFloatE "
	#'Numeric'.
	self value: [(1/2) asFloatE] should: [:r | r = 0.5]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [(-1/2) asFloatE] should: [:r | r = -0.5]
		conformTo: #'number' selector: #'asFloatE'.!

testXgreaterThanOp
	" <number>#> "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small > Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(1/3) > tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [(-9000000005/3) > -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [(1/4) > (1/2)] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.

	"Num > Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) > (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'>'
	].

	"Big > Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(11/2) > tstNum] should: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [(9000000005/3) > 2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [(-1000000005/3) > -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [(11/2) > (1/2)] should: [:r | r]
		conformTo: #'number' selector: #'>'.!

testXdivideOp
	" <number>#/ (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := Array new: 6.
	retVals at: 1 put: (1/4).
	retVals at: 2 put: (-1/4000000000).
	retVals at: 3 put: (1/4000000000).
	retVals at: 4 put: 0.25.
	retVals at: 5 put: 1.
	retVals at: 6 put:  (1/4).
	1 to: numList size do: [ :ndx |
		self value: [fractionHalf / (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'/'
			ruleReceiver: fractionHalf operand: (numList at: ndx)
	].

	self value: [0 / fractionHalf] should: [:r | r = 0]
		conformTo: #'number' selector: #'/'
		ruleReceiver: fractionHalf operand: 0.

	"The implementation must signal the ZeroDivide exception."
	self value: [fractionHalf / 0] shouldRaise: ZeroDivide.!

testXprintString
	" <Fraction>#printString "
	#'Numeric'.
	self value: [(1/2) printString] should: [:r | r = '1/2']
		conformTo: #'Fraction' selector: #'printString'.
	self value: [(1/ -2) printString] should: [:r | r = '-1/2']
		conformTo: #'Fraction' selector: #'printString'.
	self value: [(3/33) printString] should: [:r | r = '1/11']
		conformTo: #'Fraction' selector: #'printString'.!

testXfloor
	" <number>#floor "
	#'Numeric'.
	self value: [(1/3) floor] should: [:r | r = 0]
		conformTo: #'number' selector: #'floor'.
	self value: [(1/2) floor] should: [:r | r = 0]
		conformTo: #'number' selector: #'floor'.
	self value: [(3/2) floor] should: [:r | r = 1]
		conformTo: #'number' selector: #'floor'.
	self value: [(-1/2) floor] should: [:r | r = -1]
		conformTo: #'number' selector: #'floor'.!

testXtoXdoX
	" <number>#to:do: "
	#'Numeric'.!

setUp
	super setUp.
	smallInt2 := 2.
	largeNegInt2000000000 := -2000000000.
	largePosInt2000000000 := 2000000000.
	float2 := 2.0d0.
	fractionHalf := 1/2.
	sclDec2s3 := 2.0s3.
	numList := Array new: 6.
	numList at: 1 put: smallInt2.
	numList at: 2 put: largeNegInt2000000000.
	numList at: 3 put: largePosInt2000000000.
	numList at: 4 put: float2.
	numList at: 5 put: fractionHalf.

	numList at: 6 put: sclDec2s3.!

testXsign
	" <number>#sign "
	#'Numeric'.
	self value: [(1/2) sign] should: [:r | r = 1]
		conformTo: #'number' selector: #'sign'.
	self value: [(-1/2) sign] should: [:r | r = -1]
		conformTo: #'number' selector: #'sign'.!

testXminX
	" <magnitude>#min: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [(1/2) min: 0] should: [:r | r = 0]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [(-2000000000/2) min: -2000000000]
		should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [(9000000000/2) min: 2000000003]
		should: [:r | r = 2000000003]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [(1/2) min: 0.0] should: [:r | r = 0.0]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [(1/2) min: (1/4)] should: [:r | r = (1/4)]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [(1/2) min: 0.1s3] should: [:r | r = 0.1s3]
		conformTo: #'magnitude' selector: #'min:'.

	"Num min: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) min: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'min:'
	].!

testXrounded
	" <number>#rounded "
	#'Numeric'.
	self value: [(1/3) rounded] should: [:r | r = 0]
		conformTo: #'number' selector: #'rounded'.
	self value: [(1/2) rounded] should: [:r | r = 1]
		conformTo: #'number' selector: #'rounded'.
	self value: [(-1/2) rounded] should: [:r | r = -1]
		conformTo: #'number' selector: #'rounded'.!

testXtruncateToX
	" <number>#truncateTo: (returnRule - :receiver :operand) "
	| retVals frac |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	frac := (51/10).
	retVals := #(4 0 0 4.0 5 4).
	1 to: numList size do: [ :ndx |
		self value: [frac truncateTo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'truncateTo:'
			ruleReceiver: frac operand: (numList at: ndx)
	].

	self should: [(0.0 truncateTo: fractionHalf) = 0.0].!

testXfractionPart
	" <number>#fractionPart (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	"Within the limits of representation, the following invariants should hold:

		receiver integerPart + receiver fractionPart = receiver
		receiver \\1 = receiver fractionPart	(RAH - erroneous, add #'abs')
"
	rcvr := (3/2).
	self value: [rcvr fractionPart]
		should: [:r | r = (1/2) & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := (-3/2).
	self value: [rcvr fractionPart]
		should: [:r | r = (-1/2) & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.!

testXnegative
	" <number>#negative "
	#'Numeric'.
	self value: [(-1/2) negative] should: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [(1/2) negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.!

testXsubtractOp
	" <number>#- (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := Array new: 6.
	retVals at: 1 put: (-3/2).
	retVals at: 2 put: (4000000001/2).
	retVals at: 3 put: (-3999999999/2).
	retVals at: 4 put: -1.5.
	retVals at: 5 put: 0.
	retVals at: 6 put: (-3/2).
	1 to: numList size do: [ :ndx |
		self value: [fractionHalf - (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'-'
			ruleReceiver: fractionHalf operand: (numList at: ndx)
	].!

testXcopy
	" <Object>#copy (Return Values: <RECEIVER>) "
	#'Numeric'.
"	Return a new object that must be as similar as possible to the receiver in its initial state and behavior.  Any operation that changes the state of the new object should not as a side-effect change the state or behavior of the receiver.  Similarly, any change to the receiver should not as a side-effect change the new object.
	If the receiver is an identity object, return the receiver.
"
#todo. "??? add change-side-effect test ???"
	self value: [fractionHalf copy]
		should: [:r | (r = fractionHalf) ]
		conformTo: #'Object' selector: #'copy' opRECEIVER: fractionHalf.!

testXhash
	" <Object>#hash "
	#'Numeric'.
"	Any two objects that are considered equivalent using the #= message must have the same hash value.  More formally:

	receiver = comparand	=>
	receiver hash = comparand hash
"
#'testAnom'. "??? <Object> test of equivalence seems to confilict
				with <Number> convert then test.
	self shouldnt: [smallInt2 = float2].
	self shouldnt: [smallInt2 hash = float2 hash].
 ???"
	self value: [fractionHalf hash]
		should: [:r | r = fractionHalf hash]
		conformTo: #'Object' selector: #'hash'.

	self value: [fractionHalf hash]
		shouldnt: [:r | r = (2/3) hash] conformTo: #'Object' selector: #'hash'.!

protocol
	^#'Fraction'!

testXasFloatD
	" <number>#asFloatD "
	#'Numeric'.
	self value: [(1/2) asFloatD] should: [:r | r = 0.5]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [(-1/2) asFloatD] should: [:r | r = -0.5]
		conformTo: #'number' selector: #'asFloatD'.!

testXlessThanOrEqualToOp
	" <magnitude>#<= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small <= Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(1/3) <= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [(-9000000005/3) <= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [(1/4) <= (1/2)] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.

	"Num <= Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) <= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'<='
	].

	"Big <= Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(11/2) <= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [(9000000005/3) <= 2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [(-1000000005/3) <= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [(11/2) <= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.!

testXintegerPart
	" <number>#integerPart (returnRule - :receiver) "
	| rcvr |
	#'Numeric'.
	rcvr := (1/2).
	self value: [rcvr integerPart] should: [:result | result = 0]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := (3/2).
	self value: [rcvr integerPart] should: [:result | result = 1]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := (-3/2).
	self value: [rcvr integerPart] should: [:result | result = -1]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.!

testXquoX
	" <number>#quo: "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #( 666666666 0 0 666666666 2666666666 666666666 ).
	1 to: numList size do: [ :ndx |
		self value: [(4000000000/3) quo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'.
	].

"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #( -666666666 0 0 -666666666 -2666666666 -666666666 ).
	1 to: numList size do: [ :ndx |
		self value: [(4000000000/3) quo: ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'
	].

	self should: [((256/5) quo: (50/5)) = 5].

	self should: [((126/5) quo: 5) = 5].
	self should: [((125000000001/5) quo: 5000000000) = 5].
	self should: [((-125000000001/5) quo: -5000000000) = 5].
	self should: [((131/5) quo: 5.1) = 5].
	self should: [((131/5) quo: 5.1s1) = 5].

	self value: [0 quo: fractionHalf] should: [:r | r = 0]
		conformTo: #'number' selector: #'quo:'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [fractionHalf quo: 0] shouldRaise: ZeroDivide.!

testXasFloatQ
	" <number>#asFloatQ "
	#'Numeric'.
	self value: [(1/2) asFloatQ] should: [:r | r = 0.5]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [(-1/2) asFloatQ] should: [:r | r = -0.5]
		conformTo: #'number' selector: #'asFloatQ'.!

testXmultiplyOp
	" <number>#* (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(1 -1000000000 1000000000 1.0 0 1) copy.
	retVals at: 5 put: (1/4).
	1 to: numList size do: [ :ndx |
		self value: [fractionHalf * (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'*'
			ruleReceiver: fractionHalf operand: (numList at: ndx)
	].!

testXnumerator
	" <Fraction>#numerator "
	#'Numeric'.!

testXlessThanOp
	" <number>#< "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small < Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(1/3) < tstNum] should: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [(-9000000005/3) < -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [(1/4) < (1/2)] should: [:r | r]
		conformTo: #'number' selector: #'<'.

	"Num < Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) < (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'<'
	].

	"Big < Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [(11/2) < tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [(9000000005/3) < 2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [(-1000000005/3) < -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [(11/2) < (1/2)] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.!

testXsqrt
	" <number>#sqrt "
	self value: [(2601/100) sqrt] should: [:r | r closeTo: 5.1]
		conformTo: #'number' selector: #'sqrt'.
	self value: [(1/4) sqrt] should: [:r | r = 0.5]
		conformTo: #'number' selector: #'sqrt'! !

!IdentityDictionaryFactoryANSITest methodsFor: nil!

protocol
	^#'IdentityDictionary factory'!

testXwithAllX
	" <IdentityDictionary factory>#withAll: "
	#'Collection'.!

testXnewX
	" <IdentityDictionary factory>#new: "
	#'Collection'.!

canonicalObject
	^IdentityDictionary!

testXnew
	" <IdentityDictionary factory>#new "
	#'Collection'.! !

!WarningANSITest methodsFor: nil!

testXresignalAsX
	" <signaledException>#resignalAs: "
	#'Exception'.!

testXretryUsingX
	" <signaledException>#retryUsing: "
	#'Exception'.!

testXmessageText
	" <exceptionDescription>#messageText "
	#'Exception'.!

testXresume
	" <signaledException>#resume "
	#'Exception'.!

testXreturn
	" <signaledException>#return "
	#'Exception'.!

testXresumeX
	" <signaledException>#resume: "
	#'Exception'.!

testXreturnX
	" <signaledException>#return: "
	#'Exception'.!

protocol
	^#Warning!

testXsignal
	" <exceptionSignaler>#signal "
	#'Exception'.!

testXdescription
	" <exceptionDescription>#description "
	#'Exception'.!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXtag
	" <exceptionDescription>#tag "
	#'Exception'.!

testXmessageTextX
	" <exceptionBuilder>#messageText: (Return Values: <RECEIVER>) "
	#'Exception'.!

testXouter
	" <signaledException>#outer "
	#'Exception'.!

testXpass
	" <signaledException>#pass "
	#'Exception'.!

testXretry
	" <signaledException>#retry "
	#'Exception'.!

testXisResumable
	" <Notification>#isResumable "
	#'Exception'.!

testXisNested
	" <signaledException>#isNested "
	#'Exception'.!

canonicalObject
	^Warning new!

testXdefaultAction
	" <Warning>#defaultAction "
	| tmp theText |
	#'Exception'.
	theText := 'the text'.
	self value: [[	Warning signal: 'the text'
			] on: Warning do: [ :aWarning |
				tmp := aWarning messageText ]]
		should: [:r | true "UNSPECIFIED" & tmp = theText]
		conformTo: #'Warning' selector: #'defaultAction'.! !

!FileStreamFactoryANSITest methodsFor: nil!

testXreadX
	" <FileStream factory>#read: "
	#'File Stream'.!

testXwriteXmodeX
	" <FileStream factory>#write:mode: "
	#'File Stream'.!

protocol
	^#'FileStream factory'!

testXwriteX
	" <FileStream factory>#write: "
	#'File Stream'.!

testXwriteXmodeXcheckXtypeX
	" <FileStream factory>#write:mode:check:type: "
	#'File Stream'.!

canonicalObject
	^FileStream!

testXreadXtypeX
	" <FileStream factory>#read:type: "
	#'File Stream'.! !

!IntegerANSITest methodsFor: nil!

testXbitXorX
	" <integer>#bitXor: "
	#'Numeric'.!

testXpositive
	" <number>#positive "
	#'Numeric'.
	self value: [2 positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [2000000000 positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [0 positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [-2 positive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [-2000000000 positive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'positive'.!

testXidentityHash
	" <Object>#identityHash "
	#'Numeric'.
	self value: [smallInt2 identityHash]
		should: [:r | r = smallInt2 identityHash]
		conformTo: #'Object' selector: #'identityHash'.
	self value: [largeNegInt2000000000 identityHash]
		should: [:r | r = largeNegInt2000000000 identityHash]
		conformTo: #'Object' selector: #'identityHash'.
	self value: [largePosInt2000000000 identityHash]
		should: [:r | r = largePosInt2000000000 identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [smallInt2 identityHash]
		should: [:r | r = (4/2) identityHash]
		conformTo: #'Object' selector: #'identityHash'.
	self value: [smallInt2 identityHash]
		should: [:r | r = (3 - 1) identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [smallInt2 identityHash]
		shouldnt: [:r | r = 3 identityHash]
		conformTo: #'Object' selector: #'identityHash'.
	self value: [largeNegInt2000000000 identityHash]
		shouldnt: [:r | r = 2000000001 identityHash]
		conformTo: #'Object' selector: #'identityHash'.
	self value: [largePosInt2000000000 identityHash]
		shouldnt: [:r | r = 2000000001 identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [smallInt2 identityHash]
		shouldnt: [:r | r = (6/2) identityHash]
		conformTo: #'Object' selector: #'identityHash'.
	self value: [smallInt2 identityHash]
		shouldnt: [:r | r = (2 + 1) identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self shouldnt: [smallInt2 identityHash = float2 identityHash].!

testXlessThanOrEqualToOp
	" <magnitude>#<= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small <= Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [1 <= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [-2000000005 <= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [0 <= (1/2)] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.

	"Num <= Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) <= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'<='
	].

	"Big <= Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5 <= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [9000000000 <= 2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [-1000000005 <= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [9 <= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.!

setUp
	super setUp.
	smallInt2 := 2.
	largeNegInt2000000000 := -2000000000.
	largePosInt2000000000 := 2000000000.
	float2 := 2.0d0.
	fractionHalf := 1/2.
	sclDec2s3 := 2.0s3.
	numList := Array new: 6.
	numList at: 1 put: smallInt2.
	numList at: 2 put: largeNegInt2000000000.
	numList at: 3 put: largePosInt2000000000.
	numList at: 4 put: float2.
	numList at: 5 put: fractionHalf.


	numList at: 6 put: sclDec2s3.!

testXabs
	" <number>#abs (Return Values: <RECEIVER>) "
	| rcvr |
	#'Numeric'.
	rcvr := 2.
	self value: [rcvr abs] should: [:r | r = 2]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := -2.
	self value: [rcvr abs] should: [:r | r = 2]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := -2000000000.
	self value: [rcvr abs] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := 2000000000.
	self value: [rcvr abs] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := 0.
	self value: [rcvr abs] should: [:r | r = 0]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.!

testXstrictlyPositive
	" <number>#strictlyPositive "
	#'Numeric'.
	self value: [2 strictlyPositive] should: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.
	self value: [2000000000 strictlyPositive] should: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.

	self value: [0 strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.
	self value: [-2 strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.
	self value: [-2000000000 strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.!

testXraisedToIntegerX
	" <number>#raisedToInteger: (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 2.
	self value: [rcvr raisedToInteger: 0] should: [:r | r = 1]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 1] should: [:r | r = rcvr]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 2] should: [:r | r = 4]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr negated raisedToInteger: 2] should: [:r | r = 4]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: -2] should: [:r | r = (1/4)]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

#'todo'."??? these take 5-10 min.
	self value: [rcvr raisedToInteger: 2000000000]
		should: [:r | r =  ???]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.
	self value: [rcvr raisedToInteger: -2000000000]
		should: [:r | r =  ???]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.
"
	rcvr := 2000000000.
	self value: [rcvr raisedToInteger: 2]
		should: [:r | r = 4000000000000000000]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	rcvr := -2000000000.
	self value: [rcvr raisedToInteger: 2]
		should: [:r | r = 4000000000000000000]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	"It is erroneous if the operand does not conform to the protocol <integer>."
	self value: [2 raisedToInteger: 2.0] shouldRaise: Error.
	self value: [0 raisedToInteger: -2] shouldRaise: ZeroDivide.!

testXaddOp
	" <number>#+ (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

	retVals := #(4 -1999999998 2000000002 4.0s3 0 4.0) copy.
	retVals at: 5 put: (5/2).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 + (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'+'
			ruleReceiver: smallInt2 operand: (numList at: ndx)
	].

	retVals := #(-1999999998 -4000000000 0 -1999999998.0s3 0 -1999999998.0) copy.
	retVals at: 5 put: (-3999999999/2).
	1 to: numList size do: [ :ndx |
		self value: [largeNegInt2000000000 + (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'+'
			ruleReceiver: largeNegInt2000000000
			operand: (numList at: ndx)
	].

	retVals := #(2000000002 0 4000000000 2000000002.0s3 0 2000000002.0) copy.
	retVals at: 5 put: (4000000001/2).
	1 to: numList size do: [ :ndx |
		self value: [largePosInt2000000000 + (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'+'
			ruleReceiver: largePosInt2000000000
			operand: (numList at: ndx)
	].!

testXgreaterThanOp
	" <number>#> "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small > Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [1 > tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [-2000000005 > -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [0 > (1/2)] shouldnt: [:r | r] conformTo: #'number' selector: #'>'.

	"Num > Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) > (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'>'
	].

	"Big > Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5 > tstNum] should: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [9000000000 > 2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [-1000000005 > -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [9 > (1/2)] should: [:r | r] conformTo: #'number' selector: #'>'.!

testXnotIdentityOp
	" <Object>#~~ "
	#'Numeric'.
"	The value of receiver ~~ comparand is true if and only if the value of comparand ~~ receiver would also be true.
"
	self should: [smallInt2 ~~ float2 and: [float2 ~~ smallInt2]].

	self value: [smallInt2 ~~ 3]
		should: [:r | r] conformTo: #'Object' selector: #'~~'.
	self value: [largeNegInt2000000000 ~~ 2000000001]
		should: [:r | r] conformTo: #'Object' selector: #'~~'.
	self value: [largePosInt2000000000 ~~ 2000000001]
		should: [:r | r] conformTo: #'Object' selector: #'~~'.

	self value: [smallInt2 ~~ (6/2)]
		should: [:r | r] conformTo: #'Object' selector: #'~~'.
	self value: [smallInt2 ~~ (2 + 1)]
		should: [:r | r] conformTo: #'Object' selector: #'~~'.

	self value: [smallInt2 ~~ smallInt2]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~~'.
	self value: [largeNegInt2000000000 ~~ largeNegInt2000000000]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~~'.
	self value: [largePosInt2000000000 ~~ largePosInt2000000000]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~~'.

	self value: [smallInt2 ~~ (4/2)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~~'.
	self value: [smallInt2 ~~ (3 - 1)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~~'.!

testXtoX
	" <number>#to: "
	| start middleNdx stop2 |
	#'Numeric'.
	start := 1.
	numList := #( 2 2.0 0 2.0s3 ) copy.
	numList at: 3 put: (5/2).
	numList do: [ :stop |
		self value: [start to: stop]
			should: [:r | (r size = 2)
					". . . the last element in the sequence . . . is . . .[:]
						receiver + ((stop - receiver) // 1)"
					& (r last = (start + ((stop - start) // 1)))
					"The elements conform to the receiver's protocol."
					& (r allSatisfy: [ :elem |
						elem class conformsToProtocolNamed: #'integer'])
			]
			conformTo: #'number' selector: #'to:'
	].

	stop2 := 2000000000.
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'integer'])
		]
		conformTo: #'number' selector: #'to:'.

	start := -2000000000.
	stop2 := -1.
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'integer'])
		]
		conformTo: #'number' selector: #'to:'.

	"The interval answered will be empty if the receiver is greater than stop."
	self value: [1 to: -1]
		should: [:r | (r isEmpty)] conformTo: #'number' selector: #'to:'!

testXminX
	" <magnitude>#min: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [2 min: 1] should: [:r | r = 1]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [-1000000000 min: -2000000000] should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2000000003 min: 2000000001] should: [:r | r = 2000000001]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2 min: 1.0] should: [:r | r = 1.0]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2 min: (3/2)] should: [:r | r = (3/2)]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2 min: 1.0s5] should: [:r | r = 1.0s5]
		conformTo: #'magnitude' selector: #'min:'.

	"Num min: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) min: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'min:'
	].!

testXsign
	" <number>#sign "
	#'Numeric'.
	self value: [2 sign] should: [:r | r = 1]
		conformTo: #'number' selector: #'sign'.
	self value: [2000000000 sign] should: [:r | r = 1]
		conformTo: #'number' selector: #'sign'.
	self value: [0 sign] should: [:r | r = 0]
		conformTo: #'number' selector: #'sign'.
	self value: [-2 sign] should: [:r | r = -1]
		conformTo: #'number' selector: #'sign'.
	self value: [-2000000000 sign] should: [:r | r = -1]
		conformTo: #'number' selector: #'sign'.!

testXnotEqualityOp
	" <Object>#~= "
	#'Numeric'.
"	The value of receiver ~= comparand is true if and only if the value of
comparand ~= receiver would also be true.
"
#'testAnom'. "??? <Object> test of equivalence seems to confilict
				with <Number> convert then test. ???
	self should: [(smallInt2 ~= float2) & (float2 ~= smallInt2)].
"

	self value: [smallInt2 ~= 3]
		should: [:r | r] conformTo: #'Object' selector: #'~='.
	self value: [largeNegInt2000000000 ~= 2000000001]
		should: [:r | r] conformTo: #'Object' selector: #'~='.
	self value: [largePosInt2000000000 ~= 2000000001]
		should: [:r | r] conformTo: #'Object' selector: #'~='.

	self value: [smallInt2 ~= (6/2)]
		should: [:r | r] conformTo: #'Object' selector: #'~='.
	self value: [smallInt2 ~= (2 + 1)]
		should: [:r | r] conformTo: #'Object' selector: #'~='.

	self value: [smallInt2 ~= smallInt2]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.
	self value: [largeNegInt2000000000 ~= largeNegInt2000000000]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.
	self value: [largePosInt2000000000 ~= largePosInt2000000000]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.

	self value: [smallInt2 ~= (4/2)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.
	self value: [smallInt2 ~= (3 - 1)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.!

testXtruncated
	" <number>#truncated "
	self value: [2 truncated] should: [:r | r = 2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2 truncated] should: [:r | r = -2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2000000000 truncated] should: [:r | r = -2000000000]
		conformTo: #'number' selector: #'truncated'.
	self value: [2000000000 truncated] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'truncated'.
	self value: [0 truncated] should: [:r | r = 0]
		conformTo: #'number' selector: #'truncated'.!

testXmaxX
	" <magnitude>#max: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [2 max: 3] should: [:r | r = 3]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [-3000000000 max: -2000000000] should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2000000000 max: 2000000003] should: [:r | r = 2000000003]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2 max: 3.0] should: [:r | r = 3.0]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2 max: (5/2)] should: [:r | r = (5/2)]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2 max: 3.0s3] should: [:r | r = 3.0s3]
		conformTo: #'magnitude' selector: #'max:'.

	"Num max: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) max: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'max:'
	].!

testXgcdX
	" <integer>#gcd: "
	#'Numeric'.!

testXasFloat
	" <number>#asFloat "
	#'Numeric'.
	self value: [2 asFloat] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [-2 asFloat] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [-2000000000 asFloat] should: [:r | r = -2000000000.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [2000000000 asFloat] should: [:r | r = 2000000000.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [0 asFloat] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloat'.!

testXanyMaskX
	" <integer>#anyMask: "
	#'Numeric'.!

testXbitOrX
	" <integer>#bitOr: "
	#'Numeric'.!

testXsqrt
	" <number>#sqrt "
	#'Numeric'.
	self value: [4 sqrt] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'sqrt'.
	self value: [2000000000 sqrt] should: [:r | r closeTo: 44721.3595499958]
		conformTo: #'number' selector: #'sqrt'.
	self value: [0 sqrt] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'sqrt'!

testXasFloatD
	" <number>#asFloatD "
	#'Numeric'.
	self value: [2 asFloatD] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [-2 asFloatD] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [-2000000000 asFloatD] should: [:r | r = -2000000000.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [2000000000 asFloatD] should: [:r | r = 2000000000.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [0 asFloatD] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatD'.!

testXeven
	" <integer>#even "
	#'Numeric'.!

testXnumerator
	" <rational>#numerator "
	#'Numeric'.!

testXasScaledDecimalX
	"2000/06/23 Harmon, R. Changed to fix illegal fixed point literals."
	"The number of significant digits of the answer is the same as the number of decimal digits in the receiver. The scale of the answer is 0."
	self value: [2 asScaledDecimal: 2]
		should: [:r | r = 2s & (r scale = 0)]
		conformTo: #'integer' selector: #'asScaledDecimal:'.
	self value: [-2 asScaledDecimal: 2]
		should: [:r | r = -2s & (r scale = 0)]
		conformTo: #'integer' selector: #'asScaledDecimal:'.
	self value: [-2000000000 asScaledDecimal: 2]
		should: [:r | r = -2000000000s & (r scale = 0)]
		conformTo: #'integer' selector: #'asScaledDecimal:'.
	self value: [2000000000 asScaledDecimal: 2]
		should: [:r | r = 2000000000s & (r scale = 0)]
		conformTo: #'integer' selector: #'asScaledDecimal:'.
	self value: [0 asScaledDecimal: 2] should: [:r | r = 0s & (r scale = 0)]
		conformTo: #'integer' selector: #'asScaledDecimal:'.!

testXasFloatE
	" <number>#asFloatE "
	#'Numeric'.
	self value: [2 asFloatE] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [-2 asFloatE] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [-2000000000 asFloatE] should: [:r | r = -2000000000.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [2000000000 asFloatE] should: [:r | r = 2000000000.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [0 asFloatE] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatE'.!

testXintegerPart
	" <number>#integerPart (returnRule - :receiver) "
	| rcvr |
	#'Numeric'.
	rcvr := 2.
	self value: [rcvr integerPart] should: [:result | result = 2]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := -2.
	self value: [rcvr integerPart] should: [:result | result = -2]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := -2000000000.
	self value: [rcvr integerPart] should: [:result | result = -2000000000]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := 2000000000.
	self value: [rcvr integerPart] should: [:result | result = 2000000000]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := 0.
	self value: [rcvr integerPart] should: [:result | result = 0]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.!

testXrounded
	" <number>#rounded "
	#'Numeric'.
	self value: [2 rounded] should: [:r | r = 2]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2 rounded] should: [:r | r = -2]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2000000000 rounded] should: [:r | r = -2000000000]
		conformTo: #'number' selector: #'rounded'.
	self value: [2000000000 rounded] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'rounded'.
	self value: [0 rounded] should: [:r | r = 0]
		conformTo: #'number' selector: #'rounded'.!

canonicalObject
	^47!

testXprintStringRadixX
	" <integer>#printStringRadix: "
	#'Numeric'.!

testXbitShiftX
	" <integer>#bitShift: "
	#'Numeric'.!

testXisKindOfX
	" <Object>#isKindOf: "
	#'Numeric'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
		#'Fundamental'.
#todo. "Fix find a test for unspecified rule above ???"
	self value: [smallInt2 isKindOf: Integer]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.
	self value: [largeNegInt2000000000 isKindOf: Integer]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.
	self value: [largePosInt2000000000 isKindOf: Integer]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Metaclass tests:"
	self value: [smallInt2 class isKindOf: (Integer class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.
	self value: [largeNegInt2000000000 class isKindOf: (Integer class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.
	self value: [largePosInt2000000000 class isKindOf: (Integer class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Inherit tests:"
	self value: [smallInt2 class isKindOf: (Integer class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.
	self value: [smallInt2 class isKindOf: (Number class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	self value: [smallInt2 isKindOf: Float]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.!

testXtoXbyXdoX
	" <number>#to:by:do: "
	#'Numeric'.!

testXidentityOp
	" <Object>#== "
	#'Numeric'.
"	The value of receiver == comparand is true if and only if the value of comparand == receiver would also be true. If the value of receiver == comparand is true then the receiver and comparand must have equivalent identity hash values.  Or more formally:

	receiver == comparand =>
	receiver identityHash = comparand identityHash
"
	self shouldnt: [smallInt2 == float2].
	self shouldnt: [smallInt2 identityHash == float2 identityHash].

	self value: [smallInt2 == smallInt2]
		should: [:r | r] conformTo: #'Object' selector: #'=='.
	self value: [largeNegInt2000000000 == largeNegInt2000000000]
		should: [:r | r] conformTo: #'Object' selector: #'=='.
	self value: [largePosInt2000000000 == largePosInt2000000000]
		should: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [smallInt2 == (4/2)]
		should: [:r | r] conformTo: #'Object' selector: #'=='.
	self value: [smallInt2 == (3 - 1)]
		should: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [smallInt2 == 3]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.
	self value: [largeNegInt2000000000 == 2000000001]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.
	self value: [largePosInt2000000000 == 2000000001]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [smallInt2 == (6/2)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.
	self value: [smallInt2 == (2 + 1)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.!

testXdivideOp
	" <number>#/ (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(1 0 0 1.0 4 1.000s3) copy.
	retVals at: 2 put: (-1/1000000000).
	retVals at: 3 put: (1/1000000000).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 / (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'/'
			ruleReceiver: smallInt2 operand: (numList at: ndx)
	].

	retVals := #(-1000000000 1 -1 -1000000000.0 -4000000000 -1000000000.000s3).
	1 to: numList size do: [ :ndx |
		self value: [largeNegInt2000000000 / (numList at: ndx)]
			should: [:r | r = (retVals at: ndx) ]
			conformTo: #'number' selector: #'/'
			ruleReceiver: largeNegInt2000000000
			operand: (numList at: ndx)
	].

	retVals := #(1000000000 -1 1 1000000000.0 4000000000 1000000000.000s3).
	1 to: numList size do: [ :ndx |
		self value: [largePosInt2000000000 / (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'/'
			ruleReceiver: largePosInt2000000000
			operand: (numList at: ndx)
	].


	self value: [0 / smallInt2] should: [:r | r = 0]
		conformTo: #'number' selector: #'/'
		ruleReceiver: smallInt2 operand: 0.
	self value: [0 / largeNegInt2000000000] should: [:r | r = 0]
		conformTo: #'number' selector: #'/'
		ruleReceiver: fractionHalf operand: 0.
	self value: [0 / largePosInt2000000000] should: [:r | r = 0]
		conformTo: #'number' selector: #'/'
		ruleReceiver: fractionHalf operand: 0.

	"The implementation must signal the ZeroDivide exception."
	self value: [smallInt2 / 0] shouldRaise: ZeroDivide.
	self value: [largeNegInt2000000000 / 0] shouldRaise: ZeroDivide.
	self value: [largePosInt2000000000 / 0] shouldRaise: ZeroDivide.!

testXgreaterThanOrEqualToOp
	" <magnitude>#>= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small >= Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [1 >= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [-2000000005 >= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [0 >= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.

	"Num >= Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) >= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'>='
	].

	"Big >= Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5 >= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [9000000000 >= 2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [-1000000005 >= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [9 >= (1/2)] should: [:r | r] conformTo: #'magnitude' selector: #'>'.!

testXfloor
	" <number>#floor "
	#'Numeric'.
	self value: [2 floor] should: [:r | r = 2]
		conformTo: #'number' selector: #'floor'.
	self value: [-2 floor] should: [:r | r = -2]
		conformTo: #'number' selector: #'floor'.
	self value: [-2000000000 floor] should: [:r | r = -2000000000]
		conformTo: #'number' selector: #'floor'.
	self value: [2000000000 floor] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'floor'.
	self value: [0 floor] should: [:r | r = 0]
		conformTo: #'number' selector: #'floor'.!

testXasFloatQ
	" <number>#asFloatQ "
	#'Numeric'.
	self value: [2 asFloatQ] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [-2 asFloatQ] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [-2000000000 asFloatQ] should: [:r | r = -2000000000.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [2000000000 asFloatQ] should: [:r | r = 2000000000.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [0 asFloatQ] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatQ'.!

testXroundToX
	" <number>#roundTo: (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(2 0 0 2.0 2 2.000s3).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 roundTo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'roundTo:'
			ruleReceiver: smallInt2 operand: (numList at: ndx)
	].

	self should: [(0 roundTo: smallInt2) = 0]!

testXodd
	" <integer>#odd "
	#'Numeric'.!

testXtoXdoX
	" <number>#to:do: "
	#'Numeric'.!

testXprintOnXbaseXshowRadixX
	" <integer>#printOn:base:showRadix: "
	#'Numeric'.!

testXmultiplyOp
	" <number>#* (returnRule - :receiver :operand) "
	| retVals negInt2 posInt2 |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(4 -4000000000 4000000000 4.0 1 4.000s3).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 * (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'*'
			ruleReceiver: smallInt2 operand: (numList at: ndx)
	].

	retVals := #(-4000000000 4000000000000000000 -4000000000000000000 -4000000000.0 -1000000000 -4000000000.000s3).
	1 to: numList size do: [ :ndx |
		self value: [largeNegInt2000000000 * (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'*'
			ruleReceiver: largeNegInt2000000000
			operand: (numList at: ndx)
	].

	retVals := #(4000000000 -4000000000000000000 4000000000000000000 4000000000.0 1000000000 4000000000.000s3).
	1 to: numList size do: [ :ndx |
		self value: [largePosInt2000000000 * (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'*'
			ruleReceiver: largePosInt2000000000
			operand: (numList at: ndx)
	].

	negInt2 := -2.
	posInt2 := 2.
	self value: [negInt2 * posInt2] should: [:result | result = -4]
		conformTo: #'number' selector: #'*'
		ruleReceiver: negInt2 operand: posInt2.!

testXallMaskX
	" <integer>#allMask: "
	#'Numeric'.!

testXbitAtX
	" <integer>#bitAt: "
	#'Numeric'.!

testXsubtractOp
	" <number>#- (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

	retVals := #(0 2000000002 -1999999998 0.0s3 0 0.0) copy.
	retVals at: 5 put: (3/2).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 - (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'-'
			ruleReceiver: smallInt2 operand: (numList at: ndx)
	].

	retVals := #(-2000000002 0 -4000000000 -2000000002.0s3 0 -2000000002.0) copy.
	retVals at: 5 put: (-4000000001/2).
	1 to: numList size do: [ :ndx |
		self value: [largeNegInt2000000000 - (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'-'
			ruleReceiver: largeNegInt2000000000
			operand: (numList at: ndx)
	].

	retVals := #(1999999998 4000000000 0  1999999998.0s3 0  1999999998.0) copy.
	retVals at: 5 put: (3999999999/2).
	1 to: numList size do: [ :ndx |
		self value: [largePosInt2000000000 - (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'-'
			ruleReceiver: largePosInt2000000000
			operand: (numList at: ndx)
	].!

protocol
	^#'integer'!

testXquoX
	" <number>#quo: "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(1 0 0 1 4 1 ).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 quo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'.
	].

	retVals := #(-1 0 0 -1 -4 -1 ).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 quo: ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'
	].

	self should: [(26 quo: 5.1) = 5].
	self should: [(26 quo: 5) = 5].
	self should: [(25500000000 quo: 5000000000) = 5].
	self should: [(-25500000000 quo: -5000000000) = 5].
	self should: [(26 quo: (51/10)) = 5].
	self should: [(26 quo: 5.1s1) = 5].

	self value: [0 quo: smallInt2] should: [:r | r = 0]
		conformTo: #'number' selector: #'quo:'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [smallInt2 quo: 0] shouldRaise: ZeroDivide.!

testXnegative
	" <number>#negative "
	#'Numeric'.
	self value: [-2 negative] should: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [-2000000000 negative] should: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [2 negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [2000000000 negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [0 negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.!

testXremX
	" <number>#rem: "
	| retVals ndx num2 int |
	#'Numeric'.
	"Within the limits of representation, the following invariant should hold:
		(receiver quo: operand)*operand + (receiver rem: operand) = receiver"
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	numList := #( 5 5.0 5.0s3 ).
	int := 26.
	retVals := #(1 1.0 1.000s3 ).
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self value: [int rem: num]
			should: [:r | r = (retVals at: ndx)
					& ((int quo: num) * num + (int rem: num) = int)]
			conformTo: #'number' selector: #'rem:'
	].

	numList := numList collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self value: [int rem: num]
			should: [:r | r = (retVals at: ndx)
					& ((int quo: num) * num + (int rem: num) = int)]
			conformTo: #'number' selector: #'rem:'
	].

	int := -26.
	numList := #( 5 5.0 5.0s3 ).
	retVals := retVals collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self should: [(int rem: num) = (retVals at: ndx)
					& ((int quo: num) * num + (int rem: num) = int)]
	].

	numList := numList collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self should: [(int rem: num) = (retVals at: ndx)
					& ((int quo: num) * num + (int rem: num) = int)]
	].

	int := 26.
	num2 := (5/2).
	self value: [int rem: num2]
		should: [:r | r = 1
				& ((int quo: num2) * num2 + (int rem: num2) = int)]
		conformTo: #'number' selector: #'rem:'.

	int :=  10000000001.
	numList := #(-2000000000 2000000000).
	retVals := #(1 1.0 1.000s3 ).
	ndx := 0.
	numList do: [ :num |
		self value: [int rem: num]
			should: [:r | r = (retVals at: 1)
					& ((int quo: num) * num + (int rem: num) = int)]
			conformTo: #'number' selector: #'rem:'
	].

	"If either the receiver or operand are of type <Float> and the operand has a value of zero, the result is implementation defined.  The implementation may signal the ZeroDivide exception or provide a continuation value "
	self value: [smallInt2 rem: 0.0] shouldRaise: ZeroDivide.
	self value: [smallInt2 rem: 0] shouldRaise: ZeroDivide.
	self value: [smallInt2 rem: 0s0] shouldRaise: ZeroDivide.!

testXreciprocal
	" <number>#reciprocal (returnRule - :receiver) "
	#'Numeric'.

	self value: [smallInt2 reciprocal] should: [:r | r = (1.0/smallInt2)]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: smallInt2.

	self value: [smallInt2 negated reciprocal]
		should: [:r | r = (1/(smallInt2 negated))]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: (smallInt2 negated).

	self value: [largePosInt2000000000 reciprocal]
		should: [:r | r = (1/largePosInt2000000000)]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: largePosInt2000000000.

	self value: [largeNegInt2000000000 reciprocal]
		should: [:r | r = (1/largeNegInt2000000000)]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: largeNegInt2000000000.

	"Signal a ZeroDivide exception if the receiver is equal to zero."
	self value: [0 reciprocal] shouldRaise: ZeroDivide.!

testXasInteger
	" <number>#asInteger "
	#'Numeric'.
	self value: [2 asInteger] should: [:r | r = 2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2 asInteger] should: [:r | r = -2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2000000000 asInteger] should: [:r | r = -2000000000]
		conformTo: #'number' selector: #'asInteger'.
	self value: [2000000000 asInteger] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'asInteger'.
	self value: [0 asInteger] should: [:r | r = 0]
		conformTo: #'number' selector: #'asInteger'.!

testXsquared
	" <number>#squared (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	self value: [smallInt2 squared] should: [:r | r = 4]
		conformTo: #'number' selector: #'squared' opRECEIVER: smallInt2.

	rcvr := -2.
	self value: [rcvr squared] should: [:r | r = 4]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

	self value: [largeNegInt2000000000 squared]
		should: [:r | r = 4000000000000000000]
		conformTo: #'number' selector: #'squared'
		opRECEIVER: largeNegInt2000000000.

	self value: [largePosInt2000000000 squared]
		should: [:r | r = 4000000000000000000]
		conformTo: #'number' selector: #'squared'
		opRECEIVER: largePosInt2000000000.

	rcvr := 0.
	self value: [rcvr squared] should: [:r | r = 0]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.!

testXbitAtXputX
	" <integer>#bitAt:put: "
	#'Numeric'.!

testXdenominator
	" <rational>#denominator "
	#'Numeric'.!

testXprintString
	" <number>#printString "
	#'Numeric'.
	self value: [2 printString] should: [:r | r = '2']
		conformTo: #'number' selector: #'printString'.
	self value: [-2 printString] should: [:r | r = '-2']
		conformTo: #'number' selector: #'printString'.
	self value: [2000000000 printString] should: [:r | r = '2000000000']
		conformTo: #'number' selector: #'printString'.
	self value: [-2000000000 printString] should: [:r | r = '-2000000000']
		conformTo: #'number' selector: #'printString'.
	self value: [0 printString] should: [:r | r = '0']
		conformTo: #'number' selector: #'printString'.!

testXlessThanOp
	" <number>#< "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small < Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [1 < tstNum] should: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [-2000000005 < -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [0 < (1/2)] should: [:r | r] conformTo: #'number' selector: #'<'.

	"Num < Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) < (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'<'
	].

	"Big < Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5 < tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [9000000000 < 2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [-1000000005 < -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [9 < (1/2)] shouldnt: [:r | r] conformTo: #'number' selector: #'<'.!

testXasFraction
	" <number>#asFraction "
	#'Numeric'.
	self value: [2 asFraction] should: [:r | r = 2]
		conformTo: #'number' selector: #'asFraction'.
	self value: [-2 asFraction] should: [:r | r = -2]
		conformTo: #'number' selector: #'asFraction'.
	self value: [-2000000000 asFraction] should: [:r | r = -2000000000]
		conformTo: #'number' selector: #'asFraction'.
	self value: [2000000000 asFraction] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'asFraction'.
	self value: [0 asFraction] should: [:r | r = 0]
		conformTo: #'number' selector: #'asFraction'.!

testXhighBit
	" <integer>#highBit "
	#'Numeric'.!

testXtoXbyX
	" <number>#to:by: "
	#'Numeric'.!

testXnoMaskX
	" <integer>#noMask: "
	#'Numeric'.!

testXhash
	" <Object>#hash "
	#'Numeric'.
"	Any two objects that are considered equivalent using the #= message must have the same hash value.  More formally:

	receiver = comparand	=>
	receiver hash = comparand hash
"
#'testAnom'. "??? <Object> test of equivalence seems to confilict
				with <Number> convert then test. ???
	self shouldnt: [smallInt2 = float2].
	self shouldnt: [smallInt2 hash = float2 hash].
"
	self value: [smallInt2 hash]
		should: [:r | r = smallInt2 hash]
		conformTo: #'Object' selector: #'hash'.
	self value: [largeNegInt2000000000 hash]
		should: [:r | r = largeNegInt2000000000 hash]
		conformTo: #'Object' selector: #'hash'.
	self value: [largePosInt2000000000 hash]
		should: [:r | r = largePosInt2000000000 hash]
		conformTo: #'Object' selector: #'hash'.

	self value: [smallInt2 hash]
		should: [:r | r = (4/2) hash] conformTo: #'Object' selector: #'hash'.
	self value: [smallInt2 hash]
		should: [:r | r = (3 - 1) hash] conformTo: #'Object' selector: #'hash'.

	self value: [smallInt2 hash]
		shouldnt: [:r | r = 3 hash] conformTo: #'Object' selector: #'hash'.
	self value: [largeNegInt2000000000 hash]
		shouldnt: [:r | r = 2000000001 hash]
		conformTo: #'Object' selector: #'hash'.
	self value: [largePosInt2000000000 hash]
		shouldnt: [:r | r = 2000000001 hash]
		conformTo: #'Object' selector: #'hash'.

	self value: [smallInt2 hash]
		shouldnt: [:r | r = (6/2) hash] conformTo: #'Object' selector: #'hash'.
	self value: [smallInt2 hash]
		shouldnt: [:r | r = (2 + 1) hash] conformTo: #'Object' selector: #'hash'.!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver  and min or max are not comparable"

	self value: [2 between: 1 and: 3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [-2000000002 between: -2000000003 and: -2000000001]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2000000002 between: 2000000001 and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2 between: 1.0 and: 3.0]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2 between: (3/2) and: (5/2)]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2 between: 1.0s3 and: 3.0s3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	self value: [2 between: (3/2) and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2 between: -2000000001.0 and: 3.0s3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"Num between: Num and: Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx)
					between: (numList at: ndx)
					and: (numList at: ndx)]
			should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'
	].

	self value: [2 between: 3 and: 4]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [-2000000000 between: -2000000003 and: -2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2000000000 between: 2000000003 and: 2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2 between: 3.0 and: 5.0]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2 between: (5/2) and: (7/2)]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2 between: 3.0s3 and: 5.0s3]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"??? min not min but max and vice versa -> false ???"
	self value: [2 between: 3 and: 1]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.!

testXlcmX
	" <integer>#lcm: "
	#'Numeric'.!

testXcopy
	" <Object>#copy (Return Values: <RECEIVER>) "
	#'Numeric'.
#todo. "??? add change-side-effect test ???"
	
"
If the receiver is an identity object, return the receiver.
"
	self value: [smallInt2 copy]
		should: [:r | (r = smallInt2) & (r == smallInt2)]
		conformTo: #'Object' selector: #'copy' opRECEIVER: smallInt2.
	self value: [largeNegInt2000000000 copy]
		should: [:r | (r = largeNegInt2000000000) ]
		conformTo: #'Object' selector: #'copy'
		opRECEIVER: largeNegInt2000000000.
	self value: [largePosInt2000000000 copy]
		should: [:r | (r = largePosInt2000000000) ]
		conformTo: #'Object' selector: #'copy'
		opRECEIVER: largePosInt2000000000.!

testXraisedToX
	" <number>#raisedTo: "
	| numVals retVals |
	#'Numeric'.
	numVals := #(2 2.0 0 2.0s3 ) copy.
	numVals at: 3 put: (1/2).
	retVals := #(4 4.0 1.414213562373095 4.0 ) copy.
	1 to: numVals size do: [ :ndx |
		self value: [smallInt2 raisedTo: (numVals at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'.
	].

	retVals := #(0 0.25 0.7071067811865475 0.25 ) copy.
	retVals at: 1 put: (1/4).
	1 to: numVals size do: [ :ndx |
		self value: [smallInt2 raisedTo: ((numVals at: ndx) negated)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'
	].

	self value: [smallInt2 raisedTo: 0] should: [:r | r = 1]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [0 raisedTo: smallInt2] should: [:r | r = 0]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [smallInt2 raisedTo: 1] should: [:r | r = smallInt2]
		conformTo: #'number' selector: #'raisedTo:'.

	"It is erroneous if the receiver equals zero
		and the operand is less than or equal to zero,"
	self value: [0 raisedTo: -2] shouldRaise: Error.

	"	or if the receiver is less than zero."
	self value: [smallInt2 negated raisedTo: 1.1] shouldRaise: Error.!

testXfactorial
	" <integer>#factorial "
	#'Numeric'.!

testXnegated
	" <number>#negated (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 2.
	self value: [rcvr negated] should: [:r | r = -2]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.

	rcvr := -2.
	self value: [rcvr negated] should: [:r | r = 2]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.

	rcvr := -2000000000.
	self value: [rcvr negated] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.

	rcvr := 2000000000.
	self value: [rcvr negated] should: [:r | r = -2000000000]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.

	rcvr := 0.
	self value: [rcvr negated] should: [:r | r = 0]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.!

testXequalityOp
	" <number>#= "
	#'Numeric'.
"
	receiver = comparand	=>
	receiver hash = comparand hash
"
	self value: [smallInt2 = smallInt2]
		should: [:r | r & (smallInt2 hash = smallInt2 hash) ]
		conformTo: #'number' selector: #'='.
	self value: [ smallInt2 = 3 ]
		shouldnt: [ :r | r | (smallInt2 hash = 3 hash) ]
		conformTo: #'number' selector: #'='.
	self value: [largeNegInt2000000000 = largeNegInt2000000000]
		should: [:r | r & (largeNegInt2000000000 hash
						= largeNegInt2000000000 hash) ]
		conformTo: #'number' selector: #'='.
	self value: [largePosInt2000000000 = largePosInt2000000000]
		should: [:r | r & (largePosInt2000000000 hash
						= largePosInt2000000000 hash) ]
		conformTo: #'number' selector: #'='.

"	#( 2 2.0 2.0s3 )."
	self value: [ smallInt2 = 2 ]
		should: [ :r | r  ifTrue: [ smallInt2 hash = 2 hash ]
							ifFalse: [ smallInt2 hash ~= 2 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ smallInt2 = 2.0 ]
		should: [ :r | r ifTrue: [ smallInt2 hash = 2.0 hash ]
						ifFalse: [ smallInt2 hash ~= 2.0 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ 2.5s3 = (5/2) ]
		should: [ :r | r ifTrue: [ 2.5s3 hash = (5/2) hash ]
						ifFalse: [ 2.5s3 hash ~= (5/2) hash ]  ]
		conformTo: #'number' selector: #'='.!

testXremainderIntegerDivideOp
	" <number>#\\ (returnRule - :receiver :operand) "
	"The remainder has the same sign as operand.
	Within the limits of representation, the following invariant should hold:

		(receiver // operand) * operand + (receiver \\ operand) = receiver
 "
	| retVals recList ndx |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	recList := #( 26 -26000000001 26000000001 26.0 0 26.0s3 ) copy.
	recList at: 5 put: (53/2).
	retVals := #(1 4 1 1.0 0 1.000s3 ) copy.
	retVals at: 5 put: (3/2).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ 5]
			should: [:r | r = (retVals at: ndx)
					& ((rec // 5) * 5 + (rec \\ 5) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  5.
	].

	"The remainder has the same sign as operand."
	retVals := #(-4 -1 -4 -4.0 0 -4.000s3 ) copy.
	retVals at: 5 put: (-7/2).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ -5]
			should: [:r | r = (retVals at: ndx)
					& ((rec // -5) * -5 + (rec \\ -5) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  -5.
	].

	self should: [26 \\ 5 = 1 & ((26 // 5) * 5 + (26 \\ 5) = 26)].
	self should: [26 \\ -5 = -4 & ((26 // -5) * -5 + (26 \\ -5) = 26)].

	self should: [0 \\ smallInt2 = 0].
	self should: [0 \\ largeNegInt2000000000 = 0].
	self should: [0 \\ largePosInt2000000000 = 0].

	"If the operand is zero, the implementation may signal
		the ZeroDivide exception or provide a continuation value."
	self value: [smallInt2 \\ 0] shouldRaise: ZeroDivide.
	self value: [largeNegInt2000000000 \\ 0] shouldRaise: ZeroDivide.
	self value: [largePosInt2000000000 \\ 0] shouldRaise: ZeroDivide.!

testXtruncateToX
	" <number>#truncateTo: (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(2 0 0 2.0 2 2.000s3).
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 truncateTo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'truncateTo:'
			ruleReceiver: smallInt2 operand: (numList at: ndx)
	].

	self should: [(0 truncateTo: smallInt2) = 0].!

testXintegerDivideOp
	" <number>#// "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	"The sign of the result is positive if the receiver and operand
		have the same sign, and negative if the signs are different."
	retVals := #(1 -1 0 1 4 1) copy.
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 // (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'.
	].

	retVals := #(-1 0 -1 -1 -4 -1) copy.
	1 to: numList size do: [ :ndx |
		self value: [smallInt2 // ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'
	].

	self should: [26 // 5.1 = 5].
	self should: [26 // 5 = 5].
	self should: [25500000000 // 5000000000 = 5].
	self should: [-25500000000 // -5000000000 = 5].
	self should: [26 // (51/10) = 5].
	self should: [26 // 5.1s1 = 5].

	self value: [0 // smallInt2] should: [:r | r = 0]
		conformTo: #'number' selector: #'//'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [smallInt2 // 0] shouldRaise: ZeroDivide.!

testXceiling
	" <number>#ceiling "
	#'Numeric'.
	self value: [2 ceiling] should: [:r | r = 2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2 ceiling] should: [:r | r = -2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2000000000 ceiling] should: [:r | r = -2000000000]
		conformTo: #'number' selector: #'ceiling'.
	self value: [2000000000 ceiling] should: [:r | r = 2000000000]
		conformTo: #'number' selector: #'ceiling'.
	self value: [0 ceiling] should: [:r | r = 0]
		conformTo: #'number' selector: #'ceiling'.!

testXbitAndX
	" <integer>#bitAnd: "
	#'Numeric'.!

testXfractionPart
	" <number>#fractionPart (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	"Within the limits of representation, the following invariants should hold:

		receiver integerPart + receiver fractionPart = receiver
		receiver \\1 = receiver fractionPart	(RAH - erroneous, add #'abs')
"
	rcvr := 2.
	self value: [rcvr fractionPart]
		should: [:r | r = 0 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := -2.
	self value: [rcvr fractionPart]
		should: [:r | r = 0 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := -2000000000.
	self value: [rcvr fractionPart]
		should: [:r | r = 0 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := 2000000000.
	self value: [rcvr fractionPart]
		should: [:r | r = 0 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := 0.
	self value: [rcvr fractionPart]
		should: [:r | r = 0 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.! !

!ObjectHelper methodsFor: nil!

object: anObject
	object := anObject!

testXperformXwithX
	" <Object>#perform:with: "
	#'Fundamental'.
"	If the receiver does not have a method for selector normal message-not-understood processing is performed as if the computed message hand been sent using a message send expression.
	The perform messages and #respondsTo: must be implemented to produce consistent results.  A message to perform a selector, selector, for a given receiver will result in a message-not-understood condition if and only if the value of receiver respondsTo: selector is false.
	Behavior is undefined if the number of arguments does not match that implicitly required by  the syntactic form of the selector.
"
	self value: [self canonicalObject perform: #'selector' with: #()]
		shouldRaise: MessageNotUnderstood.
	self value: [self canonicalObject perform: #'isNil' with: 1]
		shouldRaise: Error.

	self value: [self canonicalObject perform: #'~~' with: 1]
		should: [:r | r & (self canonicalObject respondsTo: #'~~')]
		conformTo: self protocol selector: #'perform:with:'.!

testXdoesNotUnderstandX
	" <Object>#doesNotUnderstand: "
	#'Fundamental'.

	self value: [self canonicalObject fooXzzYZ] shouldRaise: MessageNotUnderstood.!

testXnotNil
	" <Object>#isNil"
	#Fundamental.
	"	The messages #isNil and #notNil must be implemented to produce 
	consistent results.  For a given receiver if the result of #isNil is true 
	then the result of #notNil must be false.
	"
	self
		value: [self canonicalObject notNil = (self canonicalObject ~~ nil)]
		should: [:r | r]
		conformTo: #Object
		selector: #notNil!

testXerrorX
	" <Object>#error: "
	#'Fundamental'.
	self value: [	[self canonicalObject error: 'dummy'
				]	on: Error
					do: [ :error |  error return: true ].
				]
		should: [:r | r]
		conformTo: self protocol selector: #'error:'.

	self value: [self canonicalObject error: 'dummy'] shouldRaise: Error.!

testXisKindOfX
	" <Object>#isKindOf:"
	#Fundamental.
	"	The return value is unspecified if the receiver is a class object or 
	candidateClass is not a class object.
	"
	#todo.
	"Fix find a test for unspecified rule above ???"
	self
		value: [self canonicalObject isKindOf: Object]
		should: [:r | r]
		conformTo: self protocol
		selector: #isKindOf:.
	"Metaclass tests:"
	self
		value: [self canonicalObject class isKindOf: Object class]
		should: [:r | "unspecified"
			true]
		conformTo: self protocol
		selector: #isKindOf:.
	self
		shouldnt: [self canonicalObject == nil
				ifTrue: [false]
				ifFalse: [self canonicalObject isKindOf: UndefinedObject]]!

testXidentityHash
	" <Object>#identityHash "
	#'Fundamental'.
	self assertSend: #identityHash!

testXperformXwithXwithX
	" <Object>#perform:with:with: "
	#'Fundamental'.
"	If the receiver does not have a method for selector normal message-not-understood processing is performed as if the computed message hand been sent using a message send expression.
	The perform messages and #respondsTo: must be implemented to produce consistent results.  A message to perform a selector, selector, for a given receiver will result in a message-not-understood condition if and only if the value of receiver respondsTo: selector is false.
	Behavior is undefined if the number of arguments does not match that implicitly required by  the syntactic form of the selector.
"
	self value: [self canonicalObject perform: #'selector' with: #() with: #()]
		shouldRaise: MessageNotUnderstood.
	self value: [self canonicalObject perform: #'isNil' with: 1 with: 1]
		shouldRaise: Error.

	self value: [self canonicalObject perform: #perform:with: with: #'~~' with: 1]
		should: [:r | r & (self canonicalObject respondsTo: #perform:with:)]
		conformTo: self protocol selector: #'perform:with:'.!

testXyourself
	| anObject |
	" <Object>#yourself (Return Values: <RECEIVER>) "
	#'Fundamental'.
	anObject := self canonicalObject.
	self value: [anObject yourself] should: [:r | r == anObject]
		conformTo: self protocol selector: #'yourself'!

canonicalObject
	^object!

testXprintOnX
	" <Object>#printOn: "
	| resultStream |
	#'Fundamental'.
"	The string of characters that would be the result of sending the message #printString to the receiver is written to target.
"
	self value: [resultStream := WriteStream on: (String new: 10).
			self canonicalObject printOn: resultStream]
		should: [:r | (resultStream contents) = self canonicalObject printString]
		conformTo: self protocol selector: #'printOn:'.!

testXisNil
	" <Object>#isNil"
	#Fundamental.
	"	The messages #isNil and #notNil must be implemented to produce 
	consistent results.  For a given receiver if the result of #isNil is true 
	then the result of #notNil must be false.
	"
	self
		value: [self canonicalObject isNil = (self canonicalObject == nil)]
		should: [:r | r]
		conformTo: #Object
		selector: #isNil!

testXnotIdentityOp
	" <Object>#== "
	| object1 |
	#'Fundamental'.
"	The value of receiver == comparand is true if and only if the value of comparand == receiver would also be true. If the value of receiver == comparand is true then the receiver and comparand must have equivalent identity hash values.  Or more formally:

	receiver == comparand =>
	receiver identityHash = comparand identityHash
"
	object1 := self canonicalObject.
	self value: [object1 ~~ Object new]
		should: [:r | r ]
		conformTo: self protocol selector: #'~~'.!

testXrespondsToX
	" <Object>#respondsTo: "
	#'Fundamental'.
	self value: [self canonicalObject respondsTo: #'isNil'] should: [:r | r]
		conformTo: self protocol selector: #'respondsTo:'.

	self value: [self canonicalObject respondsTo: #'selector'] shouldnt: [:r | r]
		conformTo: self protocol selector: #'respondsTo:'.!

testXisMemberOfX
	" <Object>#isMemberOf: "
	#'Fundamental'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
#todo. "Fix find a test for unspecified rule above ???"
	self value: [self canonicalObject isMemberOf: self canonicalObject class]
		should: [:r | r] conformTo: self protocol selector: #'isMemberOf:'.
	self shouldnt: [#'aSymbol' isMemberOf: Object].!

testXhash
	" <Object>#hash "
	| |
	#'Fundamental'.
"	Any two objects that are considered equivalent using the #= message must have the same hash value.  More formally:

	receiver = comparand	=>
	receiver hash = comparand hash
"

	self assertSend: #hash!

testXcopy
	" <Object>#copy (Return Values: <RECEIVER>) "
	#'Fundamental'.
	self assertSend: #copy!

testXperformXwithArgumentsX
	" <Object>#perform:withArguments: "
	#'Fundamental'.
"	If the receiver does not have a method for the selector normal message-not-understood processing is performed as if the computed message hand been sent using a message send expression.  If this occurs, selector and arguments could be captured.
	The perform messages and #respondsTo: must be implemented to produce consistent results. A message to perform a selector, selector, for a given receiver will result in a message-not-understood condition if and only if the value of receiver respondsTo: selector is false.
	Behavior is undefined if the number of elements in arguments does not match that implicitly required by  the syntactic form of the selector.
"
	self value: [self canonicalObject perform: #'3+4' withArguments: #()]
		shouldRaise: MessageNotUnderstood.
	self value: [self canonicalObject perform: #'notNil' withArguments: #( 1 )]
		shouldRaise: Error.

	self value: [self canonicalObject perform: #'yourself' withArguments: #()]
		should: [:r | (self canonicalObject respondsTo: #'yourself')]
		conformTo: self protocol selector: #'perform:withArguments:'.!

testXprintString
	" <Object>#printString "
	#'Fundamental'.
	self value: [self canonicalObject printString]
		should: [:r | true]
		conformTo: self protocol selector: #'printString'.!

testXperformXwithXwithXwithX
	" <Object>#perform:with:with:with: "
	#'Fundamental'.

	self notDone!

testXclass
	" <Object>#class "
	#'Fundamental'.
	self value: [self canonicalObject class]
		should: [:r | true]
		conformTo: self protocol selector: #'class'.

	self value: [self canonicalObject class class]
		should: [:r | true "unspecified"]
		conformTo: self protocol selector: #'class'.!

testXequalityOp
	" <Object>#= "
	| newObject object1 |
	#'Fundamental'.
"	The value of receiver = comparand is true if and only if the value of comparand = receiver would also be true. If the value of receiver = comparand is true then the receiver and comparand must have equivalent hash values.  Or more formally:

	receiver = comparand	=>
	receiver hash = comparand hash
"	
	object1 := self canonicalObject.
	self value: [object1 = object1]
		should: [:r | r and: [object1 hash = object1 hash] ]
		conformTo: #'Object' selector: #'='.

	newObject := Object new.
	self should: [(object1 ~= newObject) and: [object1 hash ~= newObject hash] ].!

testXnotEqualityOp
	" <Object>#~= "
	| newObject |
	#'Fundamental'.
"	The value of receiver ~= comparand is true if and only if the value of comparand ~= receiver would also be true.
"
	newObject := Object new.
	self value: [self canonicalObject ~= newObject]
		should: [:r | r & (newObject ~= self canonicalObject)]
		conformTo: self protocol selector: #'~='.

	self value: [self canonicalObject ~= self canonicalObject] shouldnt: [:r | r]
		conformTo: self protocol selector: #'~='.!

testXperformX
	" <Object>#perform: "
	#'Fundamental'.
"	If the receiver does not have a method for selector normal message-not-understood processing is performed as if the computed message hand been sent using a message send expression.
	The perform messages and #respondsTo: must be implemented to produce consistent results.  A message to perform a selector, selector, for a given receiver will result in a message-not-understood condition if and only if the value of receiver respondsTo: selector is false.
	Behavior is undefined if the number of arguments does not match that implicitly required by  the syntactic form of the selector.
"
	self value: [self canonicalObject perform: #'yourself']
		should: [:r | r == r ]
		conformTo: self protocol selector: #'perform:'.

	self value: [self canonicalObject perform: #'3+4']
		shouldRaise: MessageNotUnderstood.!

protocol
	^testCase protocol!

testXidentityOp
	" <Object>#== "
	| newObject object1 |
	#'Fundamental'.
"	The value of receiver == comparand is true if and only if the value of comparand == receiver would also be true. If the value of receiver == comparand is true then the receiver and comparand must have equivalent identity hash values.  Or more formally:

	receiver == comparand =>
	receiver identityHash = comparand identityHash
"
	object1 := self canonicalObject.
	self value: [object1 == object1]
		should: [:r | r and: [object1 identityHash = object1 identityHash] ]
		conformTo: #'Object' selector: #'=='.

	newObject := Object new.
	self should: [(object1 ~~ newObject) and: [object1 identityHash ~~ newObject identityHash] ].! !

!ObjectHelper class methodsFor: nil!

initialize
	super initialize! !

!FailedMessageANSITest methodsFor: nil!

testXselector
	" <failedMessage>#selector "
	#'Fundamental'.

#todo. "???
	self op: [failedMsg := nil.
			self + 1.
			failedMsg selector]
		should: [:r | r = #'+']
		conformTo: #'failedMessage' selector: #'selector'.

	self op: [failedMsg := nil.
			self dum.
			failedMsg selector]
		should: [:r | r = #'dum']
		conformTo: #'failedMessage' selector: #'selector'.

	self op: [failedMsg := nil.
			self dum: 1 dum: 2 dum: 3.
			failedMsg selector]
		should: [:r | r = #'dum:dum:dum:']
		conformTo: #'failedMessage' selector: #'selector'.

???"!

setUp
	"Make a failed message and put it in failedMsg"
	super setUp.
	[nil foo] on: MessageNotUnderstood do: [:ex | failedMsg := ex message].!

testXarguments
	" <failedMessage>#arguments "
	#'Fundamental'.

#todo. "???
	self op: [failedMsg := nil.
			self + 1.
			failedMsg arguments]
		should: [:r | r size = 1 & (r first = 1) ]
		conformTo: #'failedMessage' selector: #'arguments'.

	self op: [failedMsg := nil.
			self dum.
			failedMsg arguments]
		should: [:r | r size = 0]
		conformTo: #'failedMessage' selector: #'arguments'.

	self op: [failedMsg := nil.
			self dum: 1 dum: 2 dum: 3.
			failedMsg arguments]
		should: [:r | r size = 3 & (r first = 1) & (r last = 3) ]
		conformTo: #'failedMessage' selector: #'arguments'.

???"!

canonicalObject
	"Return a Message object, which is created when the VM traps a misunderstood message"
	^failedMsg!

protocol
	^#'failedMessage'! !

!MainTestCase methodsFor: nil!

runCase 
	self setUp.
	[(self receiverFor: testSelector) perform: testSelector]
		on: Error do: [:ex |
			self tearDown.
			ex pass]!

setUp
	| helper1 |
	helpers := Array new.
	self class helperClassesDo: [:each | 
		helper1 := each new.
		helper1 attachTo: self.
		helper1 object: self canonicalObject.
		helpers := helpers copyWith: helper1]!

receiverFor: aSelector 
	(self respondsTo: aSelector) ifTrue: [^self].
	helpers do: [:each | (each respondsTo: aSelector) ifTrue: [^each]].
	self error: 'not a legal test selector'! !

!MainTestCase class methodsFor: nil!

deleteIfUnnecessary: aSelector
	"Warning - only works for Squeak"
	(self hasEmptyMethodFor: aSelector) ifFalse: [^self].
	(self helpersImplement: aSelector) ifTrue: [self removeSelector: aSelector]

"(BagANSITest deleteIfUnnecessary: #testXaddX)"!

suite
	| testSuite testMethods |
	testSuite := TestSuite new.
	self isAbstract ifTrue: [^testSuite].
	testMethods := self testMethods.
	self helperClassesDo: [:eachClass | testMethods addAll: eachClass testMethods].
	testMethods do: [:each | testSuite addTest: (self selector: each)].
	^testSuite!

helpersImplement: aSelector
"(BagANSITest helpersImplement: #testXasSet)"
	self helperClassesDo: [:each | (each selectors includes: aSelector) ifTrue: [^true]].
	^false!

removeAllCodeThatShouldBeInHelpers
	"Warning - only works for Squeak"
	"MainTestCase removeAllCodeThatShouldBeInHelpers"
	self allSubclasses do: [:each | each deleteEmptyMethodsImplementedByHelpers]!

hasEmptyMethodFor: aSelector
	"Warning - only works for Squeak"
	^(self compiledMethodAt: aSelector) size = 9!

isAbstract
	"Assume that concrete testcase classes do not have subclasses."
	^self subclasses isEmpty not!

helperClassesDo: aBlock
	aBlock value: 
(SUnitNameResolver classNamed: #'ObjectHelper').!

deleteEmptyMethodsImplementedByHelpers
	"Warning - only works for Squeak"
	self testMethods do: [:each | self deleteIfUnnecessary: each]! !

!TestCaseProtocol methodsFor: nil!

value: opBlock shouldnt: shouldNotBlock
conformTo: protocolName selector: msgSelector
ruleReceiver: receiver operand: operand
"	| negInt2 posInt2 |	negInt2 := -2.	posInt2 := 2.
	self value: [negInt2 * posInt2] shouldnt: [:result | result = 4]
		conformTo: #'number' selector: #'*'
		ruleReceiver: negInt2 operand: posInt2.
"
	self value: opBlock
		should: [:result | (shouldNotBlock value: result) not]
		conformTo: protocolName
		selector: msgSelector
		ruleReceiver: receiver
		operand: operand!

value: opBlock shouldnt: shouldNotBlock conformTo: protocolName
selector: msgSelector
"	self value: [2 = -2]
		shouldnt: [:result | result] conformTo: #'Object' selector: #'='.
"
	self value: opBlock
		should: [:result | (shouldNotBlock value: result) not]
		conformTo: protocolName
		selector: msgSelector!

value: opBlock shouldnt: shouldNotBlock conformTo: protocolName
selector: msgSelector ruleReceiver: receiver
"	| negFlt2 |	negFlt2 := -2.0.
	self value: [negFlt2 integerPart]
		shouldnt: [:result | result = 2]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: negFlt2.
"
	self value: opBlock
		should: [:result | (shouldNotBlock value: result) not]
		conformTo: protocolName
		selector: msgSelector
		ruleReceiver: receiver!

assertSend: aSelector inProtocol: aSymbol 
	self assertSend: aSelector toObject: self canonicalObject inProtocol: aSymbol.!

notDone
	"change this to self halt when you want to find all methods that are not done"!

value: opBlock should: shouldBlock conformTo: protocolName selector: msgSelector 
	"	self value: [2 = 2] should: [:result | result] conformTo: #'Object' selector: 
	#'='. "
	| msgSpec opResult |
	opResult := opBlock value.
	self assert: (shouldBlock value: opResult).
	[msgSpec := (self protocolManager protocolNamed: protocolName)
				messageAtSelector: msgSelector]
		on: Exception do: [:except | "Generate TestFailure as if originally signaled in except's place."
		self signalFailure: except description].
	msgSpec isReturnValueSpecByRule ifTrue: [self signalFailure: 'Conformence failed - requires rule.'].
	(msgSpec isConformingReturn: opResult)
		ifFalse: [self signalFailure: 'Conformence failed']!

value: opBlock should: shouldBlock conformTo: protocolName selector: msgSelector ruleReceiver: receiver 
	"	| negFlt2 |	negFlt2 := -2.0. 
	self value: [negFlt2 integerPart] should: [:result | result = -2] 
	conformTo: #'number' selector: #'integerPart' ruleReceiver: negFlt2.
	"
	| msgSpec opResult |
	opResult := opBlock value.
	self assert: (shouldBlock value: opResult).
	msgSpec := self msgSpecFor: msgSelector inProtocol: protocolName.
	msgSpec isReturnValueSpecByRule ifFalse: [TestResult failure signal: 'Conformence failed - requires rule.'].
	(msgSpec isConformingReturn: opResult ruleReceiver: receiver)
		ifFalse: [self signalFailure: 'Conformence failed rule value: ' , receiver printString]!

selector: aSelector inProtocol: aSymbol behavesLike: arrays 
	arrays asANSITestArray do: [:each | self
			value: [each first perform: aSelector withArguments: (each copyFrom: 2 to: each size - 1)]
			should: [:r | r = each last]
			conformTo: aSymbol
			selector: aSelector]!

assertSend: aSelector 
	self assertSend: aSelector inProtocol: self protocol.!

msgSpecFor:  msgSelector inProtocol: protocolName
	| msgSpec newEx |
	[msgSpec := (self protocolManager protocolNamed: protocolName)
			messageAtSelector: msgSelector
	] on: Exception do: [ :except |
		"Generate TestFailure as if originally signaled in except's place."
		newEx := TestResult failure new.
		newEx messageText: except description.
		except resignalAs: newEx
	].
	^msgSpec!

assertSend: aSelector toObject: anObject inProtocol: aSymbol 
	| opResult msgSpec |
	opResult := anObject perform: aSelector.
	msgSpec := (self protocolManager protocolNamed: aSymbol)
					messageOrNilAtSelector: aSelector.
	msgSpec isNil ifTrue: [self signalFailure: aSelector , ' is not in protocol ', aSymbol].
	self assert: (msgSpec isConformingReturn: opResult)!

value: opBlock shouldnt: shouldNotBlock conformTo: protocolName
selector: msgSelector 
opRECEIVER: receiver
"	| negFlt2 |	negFlt2 := -2.0.
	self value: [negFlt2 abs] shouldnt: [:result | result = 0.0]
		conformTo: #'number' selector: #'abs' opRECEIVER: negFlt2.
"
	self value: opBlock
		should: [:result | (shouldNotBlock value: result) not]
		conformTo: protocolName
		selector: msgSelector
		opRECEIVER: receiver!

value: opBlock should: shouldBlock conformTo: protocolName selector: msgSelector opRECEIVER: receiver 
	"	| negFlt2 |	negFlt2 := -2.0. 
	self value: [negFlt2 abs] should: [:result | result = 2.0] 
	conformTo: #'number' selector: #'abs' opRECEIVER: negFlt2.
	"
	| msgSpec opResult |
	opResult := opBlock value.
	self assert: (shouldBlock value: opResult).
	msgSpec := self msgSpecFor: msgSelector inProtocol: protocolName.
	(msgSpec
		isConformingReturn: opResult
		opRECEIVER: receiver
		conformTo: protocolName
		selector: msgSelector)
		ifFalse: [self signalFailure: 'Conformence failed return RECEIVER: ' , receiver printString]!

value: opBlock should: shouldBlock conformTo: protocolName selector: msgSelector
ruleReceiver: receiver operand: operand
"	| negInt2 posInt2 |	negInt2 := -2.	posInt2 := 2.
	self value: [negInt2 * posInt2] should: [:result | result = -4]
		conformTo: #'number' selector: #'*'
		ruleReceiver: negInt2 operand: posInt2"
	| msgSpec opResult |
	opResult := opBlock value.
	self assert: (shouldBlock value: opResult).
	msgSpec := self msgSpecFor: msgSelector inProtocol: protocolName.
	msgSpec isReturnValueSpecByRule 
		ifFalse: [self signalFailure: 'Conformence failed - requires rule.'].
	(msgSpec
		isConformingReturn: opResult
		ruleReceiver: receiver
		operand: operand
	) ifFalse: [self signalFailure: ('Conformence failed rule value: ', receiver printString, ' rec: ', operand printString)].! !

!TestCaseProtocol class methodsFor: nil!

fileInSUnitTests
	"File in SUnit unit tests."
	| aFileName devDir SUnitDir sep |
	devDir := 'C:\Dev\'.							"Typical DOS location"
	"devDir := '/usr/local/squeak/rharmon/Dev/'." "Typical Unix location"
	sep := FileDirectory pathNameDelimiter asString.
	SUnitDir := devDir, 'SUnit', sep, 'Squeak', sep, '2.7', sep.
	Transcript cr.
	aFileName := 'SUnit-Tests.st'.
	ChangeSorter
		newChangesFromStream: (FileStream
					readOnlyFileNamed: (SUnitDir, aFileName))
		named: (aFileName sansPeriodSuffix).!

testMethods
^self selectors select: [:each | 'test*' match: each].! !

!SortedCollectionANSITest methodsFor: nil!

testXcopyReplaceAllXwithX
	" <SortedCollection>#copyReplaceAll:with: "
	#'Collection'.!

testXsortBlockX
	" <SortedCollection>#sortBlock: "
	| co |
	co := self canonicalObject.
	self
		value: [co sortBlock:[:a :b | a > b]]
		should: [:r | co first = 4]
		conformTo: #SortedCollection
		selector: #sortBlock:!

testXreverse
	" <SortedCollection>#reverse "
	#'Collection'.!

testXcopyReplaceFromXtoXwithObjectX
	" <SortedCollection>#copyReplaceFrom:to:withObject: "
	#'Collection'.!

testXcopyReplacingXwithObjectX
	" <SortedCollection>#copyReplacing:withObject: "
	#'Collection'.!

protocol
	^#SortedCollection!

testXconcatenateOp
	| cos |
	cos := self canonicalObjects.
	self
		value: [(cos at: #cd), (cos at: #ab)]
		should: [:r | r = (cos at: #abcd)]
		conformTo: #SortedCollection
		selector: #,!

canonicalObject
	^SortedCollection with: 1 with: 2 with: 3 with: 4!

testXaddX
	" <SortedCollection>#add: "
	| cos |
	cos := self canonicalObjects.
	self
		value: [(cos at: #bcd) add: ((cos at: #a) at: 1); yourself]
		should: [:r | r = (cos at: #abcd)]
		conformTo: #SortedCollection
		selector: #add:!

testXcopyReplaceFromXtoXwithX
	" <SortedCollection>#copyReplaceFrom:to:with: "
	#'Collection'.!

testXcollectX
	" <SortedCollection>#collect: "
	#'Collection'.!

canonicalElement

	^self canonicalObject at: 2!

emptyCollection

	^self canonicalObject class new!

testXaddAllX
	" Not found in spec; but SortedCollection needs to refine it."
	| cos |
	cos := self canonicalObjects.
	self
		value: [(cos at: #cd) addAll: (cos at: #ab); yourself]
		should: [:r | r = (cos at: #abcd)]
		conformTo: #SortedCollection
		selector: #addAll:!

testXcomma
	" <SortedCollection>#, "
	#'Collection'.!

testXasSortedCollection
	" <SortedCollection>#asSortedCollection "
	#'Collection'.!

testXsortBlock
	" <SortedCollection>#sortBlock "
"	self halt assertSend: #sortBlock"
	self
		value: [self canonicalObject sortBlock]
		should: [:result | true]
		conformTo: #SortedCollection
		selector: #sortBlock! !

!SortedCollectionANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: ExtensibleCollectionHelper.
	aBlock value: SequencedContractibleCollectionHelper.
	aBlock value: SequencedReadableCollectionHelper.! !

!ReadFileStreamANSITest methodsFor: nil!

testXposition
	" <sequencedStream>#position "
	#'File Stream'.!

canonicalObject
	^readFileStream!

testXisEmpty
	" <sequencedStream>#isEmpty "
	#'File Stream'.!

testXnext
	" <gettableStream>#next "
	#'File Stream'.!

testXdoX
	" <gettableStream>#do: "
	#'File Stream'.!

testXatEnd
	" <gettableStream>#atEnd "
	#'File Stream'.!

testXupToX
	" <readFileStream>#upTo: "
	#'File Stream'.!

testXnextMatchForX
	" <gettableStream>#nextMatchFor: "
	#'File Stream'.!

testXisBinary
	" <FileStream>#isBinary "
	#'File Stream'.!

testXreset
	" <sequencedStream>#reset "
	#'File Stream'.!

testXpositionX
	" <sequencedStream>#position: "
	#'File Stream'.!

testXpeek
	" <gettableStream>#peek "
	#'File Stream'.!

setUp
	super setUp.
	" Requires that a file named 'ansiTestFile.junk' exists in the current directory. "

"	| aPossiblyNewFile |
	aPossiblyNewFile := FileStream write: 'ansiTestFile.junk'.
	aPossiblyNewFile close.
"
"	readFileStream := FileStream read: 'ansiTestFile.junk' "!

testXexternalType
	" <FileStream>#externalType "
	#'File Stream'.!

testXskipToX
	" <gettableStream>#skipTo: "
	#'File Stream'.!

tearDown
	"readFileStream close."!

testXcontents
	" <FileStream>#contents "
	#'File Stream'.!

testXnextLine
	" <gettableStream>#nextLine "
	#'File Stream'.!

protocol
	^#'readFileStream'!

testXisText
	" <FileStream>#isText "
	#'File Stream'.!

testXclose
	" <sequencedStream>#close "
	#'File Stream'.!

testXnextX
	" <readFileStream>#next: "
	#'File Stream'.!

testXsetToEnd
	" <sequencedStream>#setToEnd "
	#'File Stream'.!

testXskipX
	" <gettableStream>#skip: "
	#'File Stream'.!

testXpeekForX
	" <gettableStream>#peekFor: "
	#'File Stream'.! !

!AbstractDictionaryHelper methodsFor: nil!

testXkeysAndValuesDoX
	" <abstractDictionary>#keysAndValuesDo: "

	| canonicalObject sum |
	#Collection.
	canonicalObject := self object.
	sum := 0.
	self
		value: [canonicalObject keysAndValuesDo: [:key :value | sum := sum + key + value]]
		should: [:r | sum = 120]
		conformTo: #abstractDictionary
		selector: #keysAndValuesDo:.
	self should: [canonicalObject keysAndValuesDo: [:key :value | key , 'a']]
		raise: TestResult error!

testXrejectX
	" <abstractDictionary>#reject: (Return Values: <RECEIVER>)"

	"standard says that reject: returns an object of the same type as the receiver,
	which would be either a Dictionary or an IdentityDictionary.  Most Smalltalks
	return an OrderedCollection"

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject reject: [:each | each > 0]]
		should: [:r | r isEmpty]
		conformTo: #abstractDictionary
		selector: #reject:.
	self should: [canonicalObject reject: [:each | each * '2']]
		raise: TestResult error!

testXremoveAllKeysX
	" <abstractDictionary>#removeAllKeys: "

	| canonicalObject keys |
	#Collection.
	canonicalObject := self object.
	keys := canonicalObject keys.
	self value: [canonicalObject removeAllKeys: keys]
		should: [:r | r isEmpty]
		conformTo: #abstractDictionary
		selector: #removeAllKeys:!

object
	^testCase canonicalObject!

testXatX
	" <abstractDictionary>#at: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject at: 1]
		should: [:r | r  == 11]
		conformTo: #abstractDictionary
		selector: #at:!

testXselectX
	" <abstractDictionary>#select: (Return Values: <RECEIVER>)"

	"standard says that select: returns an object of the same type as the receiver,
	which would be either a Dictionary or an IdentityDictionary.  Most Smalltalks
	return an OrderedCollection"

	| canonicalObject |
	#Collection.
	canonicalObject := self  object.
	self value: [canonicalObject select: [:each | each < 0]]
		should: [:r | r isEmpty]
	conformTo: #abstractDictionary
		selector: #select:.
	self should: [canonicalObject select: [:each | each , '2']]
		raise: TestResult error!

object: anObject!

testXatXifAbsentPutX
	" <abstractDictionary>#at:ifAbsentPut: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject at: 3 ifAbsentPut: 99]
		should: [:r | r = 33]
		conformTo: #abstractDictionary
		selector: #at:ifAbsentPut:.
	self value: [canonicalObject at: 7 ifAbsentPut: 99]
		should: [:r | r = 99]
		conformTo: #abstractDictionary
		selector: #at:ifAbsentPut:.
	self value: [canonicalObject at: 17 ifAbsentPut: nil]
		should: [:r | r = nil]
		conformTo: #abstractDictionary
		selector: #at:ifAbsentPut:!

testXaddAllX
	" <abstractDictionary>#addAll: "

	| abstractDictionary canonicalObject |
	#Collection.

	abstractDictionary := self emptyObject.
	canonicalObject := self object.
	self value: [abstractDictionary addAll: canonicalObject]
		should: [:r | r keysDo: [:key | (r at: key) = (canonicalObject at: key)]]
		conformTo: #abstractDictionary
		selector: #addAll:!

testXkeys
	" <abstractDictionary>#keys "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject keys]
		should: [:r | r size = canonicalObject size]
		conformTo: #abstractDictionary
		selector: #keys!

testXremoveAllKeysifAbsentX
	" <abstractDictionary>#removeAllKeys: "

	| canonicalObject keys sum |
	#Collection.
	canonicalObject := self object.
	sum := 0.
	keys := #(111 222).
	self value: 
			[canonicalObject removeAllKeys: keys ifAbsent: [:key | sum := sum + key]]
		should: [:r | sum = 333]
		conformTo: #abstractDictionary
		selector: #removeAllKeys:ifAbsent:.
	sum := 0.
	keys := #($a $b).
	self should: 
			[canonicalObject removeAllKeys: keys ifAbsent: [:key | sum := sum + key]]
		raise: TestResult error!

testXatXputX
	" <abstractDictionary>#at:put: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject at: 3 put: 99]
		should: [:r | r = 99]
		conformTo: #abstractDictionary
		selector: #at:put:.
	self value: [canonicalObject at: 7 put: 7]
		should: [:r | r = 7]
		conformTo: #abstractDictionary
		selector: #at:put:!

testXremoveKeyXifAbsentX
	" <abstractDictionary>#removeKey:ifAbsent: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject removeKey: 2 ifAbsent: [nil]]
		should: [:r | r = 22]
		conformTo: #abstractDictionary
		selector: #removeKey:ifAbsent:.
	canonicalObject := self object.
	self value: [canonicalObject removeKey: 666 ifAbsent: [nil]]
		should: [:r | r isNil]
		conformTo: #abstractDictionary
		selector: #removeKey:ifAbsent:!

testXkeysDoX
	" <abstractDictionary>#keysDo: "

	| sum canonicalObject |
	#Collection.
	canonicalObject := self object.
	sum := 0.
	self value: [canonicalObject keysDo: [:key | sum := sum + key]]
		should: [:r | sum = 10]
		conformTo: #abstractDictionary
		selector: #keysDo:.
	self should: [canonicalObject keysDo: [:key | key , 'a']]
		raise: TestResult error!

testXremoveKeyX
	" <abstractDictionary>#removeKey: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject removeKey: 2]
		should: [:r | r = 22]
		conformTo: #abstractDictionary
		selector: #removeKey:!

testXvalues
	" <abstractDictionary>#values"

	| canonicalObject checkSum |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject values]
		should: 
			[:r | 
			checkSum := r inject: 0 into: [:sum :each | sum + each].
			checkSum = 110]
		conformTo: #abstractDictionary
		selector: #values.!

testXkeyAtValueXifAbsentX
	" <abstractDictionary>#keyAtValue:ifAbsent: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject keyAtValue: 22 ifAbsent: [nil]]
		should: [:r | r = 2]
		conformTo: #abstractDictionary
		selector: #keyAtValue:ifAbsent:.
	self value: [canonicalObject keyAtValue: 666 ifAbsent: [nil]]
		should: [:r | r = nil]
		conformTo: #abstractDictionary
		selector: #keyAtValue:ifAbsent:!

testXincludesKeyX
	" <abstractDictionary>#includesKey: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject includesKey: 1]
		should: [:r | true]
		conformTo: #abstractDictionary
		selector: #includesKey:!

testXcollectX
	" <abstractDictionary>#collect: (Return Values: <RECEIVER>)"

	"standard says that collect: returns an object of the same type as the receiver,
	which would be either a Dictionary or an IdentityDictionary.  Most Smalltalks
	return an OrderedCollection"

	| canonicalObject |
	#Collection.
	canonicalObject := self  object.
	self value: [canonicalObject collect: [:each | each * 2]]
		should: [:r || ok |
		    ok := r size = canonicalObject size.
		    r keysDo: [:each | ok := ok and: [ (r at: each) = ((canonicalObject at: each) * 2)]].
		    ok
		]
		conformTo: #abstractDictionary
		selector: #collect:.
	self should: [canonicalObject collect: [:each | each , '2']]
		raise: TestResult error!

emptyObject
	^testCase emptyCanonicalObject!

testXatXifAbsentX
	" <abstractDictionary>#at:ifAbsent: "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject at: 3 ifAbsent: 99]
		should: [:r | r = 33]
		conformTo: #abstractDictionary
		selector: #at:ifAbsent:.
	self value: [canonicalObject at: 7 ifAbsent: 99]
		should: [:r | r = 99]
		conformTo: #abstractDictionary
		selector: #at:ifAbsent:!

testXkeyAtValueX
	" <abstractDictionary>#keyAtValue "

	| canonicalObject |
	#Collection.
	canonicalObject := self object.
	self value: [canonicalObject keyAtValue: 22]
		should: [:r | r = 2]
		conformTo: #abstractDictionary
		selector: #keyAtValue:.
	self value: [canonicalObject keyAtValue: 666]
		should: [:r | r = nil]
		conformTo: #abstractDictionary
		selector: #keyAtValue:! !

!StringFactoryANSITest methodsFor: nil!

testXwithX
	" <String factory>#with: "
	#'Collection'.!

testXwithXwithX
	" <String factory>#with:with: "
	#'Collection'.!

testXnew
	" <String factory>#new "
	#'Collection'.!

protocol
	^#'String factory'!

testXnewX
	" <String factory>#new: "
	#'Collection'.!

testXwithAllX
	" <String factory>#withAll: "
	#'Collection'.!

canonicalObject
	^String!

testXwithXwithXwithX
	" <String factory>#with:with:with: "
	#'Collection'.!

testXwithXwithXwithXwithX
	" <String factory>#with:with:with:with: "
	#'Collection'.! !

!ErrorANSITest methodsFor: nil!

testXresignalAsX
	" <signaledException>#resignalAs: "
	#'Exception'.!

testXretryUsingX
	" <signaledException>#retryUsing: "
	#'Exception'.!

testXmessageText
	" <exceptionDescription>#messageText "
	#'Exception'.!

testXresume
	" <signaledException>#resume "
	#'Exception'.!

testXreturn
	" <signaledException>#return "
	#'Exception'.!

testXresumeX
	" <signaledException>#resume: "
	#'Exception'.!

testXreturnX
	" <signaledException>#return: "
	#'Exception'.!

protocol
	^#Error!

testXsignal
	" <exceptionSignaler>#signal "
	#'Exception'.!

testXdescription
	" <exceptionDescription>#description "
	#'Exception'.!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXtag
	" <exceptionDescription>#tag "
	#'Exception'.!

testXmessageTextX
	" <exceptionBuilder>#messageText: (Return Values: <RECEIVER>) "
	#'Exception'.!

testXouter
	" <signaledException>#outer "
	#'Exception'.!

testXpass
	" <signaledException>#pass "
	#'Exception'.!

testXretry
	" <signaledException>#retry "
	#'Exception'.!

testXisResumable
	" <Error>#isResumable "
	#'Exception'.
	self value: [ [ Error signal ] on: Error do: [ :aError |
					aError return: aError isResumable ] ]
		shouldnt: [:r | r] conformTo: #'Error' selector: #'isResumable'.!

testXisNested
	" <signaledException>#isNested "
	#'Exception'.

	self value: [ [ Error signal ] on: Error do: [ :exception |
					exception return: exception isNested ] ]
		should: [:r | r = false]
		conformTo: #'signaledException' selector: #'isNested'.!

canonicalObject
	^Error new!

testXdefaultAction
	" <Error>#defaultAction "
	#'Exception'.
#'todo'."??? I don't know what to test here.
	self value: [Error signal] should: [:r | true ??UNSPECIFIED??]
		conformTo: #'Error' selector: #'defaultAction'.
???"

	self value: [Error signal] shouldRaise: Error.! !

!FractionFactoryANSITest methodsFor: nil!

protocol
	^#'Fraction factory'!

canonicalObject
	^Fraction!

testXnumeratorXdenominatorX
	" <Fraction factory>#numerator:denominator: "
	#'Numeric'.! !

!PuttableStreamHelper methodsFor: nil!

object: anObject!

protocol
	^#'puttableStream'!

testXflush

#todo."Don't know how to check this:
Upon return, if the receiver is a write-back stream, the state of the stream backing store must be consistent with the current state of the receiver.
If the receiver is not a write-back stream, the effect of this message is unspecified.
"
	self assertSend: #flush!

testXcr

#todo."Don't know how to check this:
A sequence of character objects that constitute the implementation-defined end-of-line sequence is added to the receiver in the same manner as if the message #nextPutAll: was sent to the receiver with an argument string whose elements are the sequence of characters.
Errors
It is erroneous if any element of the end-of-line sequence is an object that does not conform to the receiver's sequence value type.
"
	self assertSend: #cr!

testXnextPutAllX

#todo."Don't know how to check this:
Has the effect of enumerating the aCollection with the message #do: and adding each element to the receiver with #nextPut:. That is,
aCollection do: [:each | receiver nextPut: each]
"
	self value: [self canonicalObject nextPutAll: 'abc1%ABC']
		should: [:r | true "UNSPECIFIED" ]
		conformTo: self protocol selector: #'nextPutAll:'.

	"Errors: It is erroneous if any element of aCollection is an object
		that does not conform to the receiver's sequence value type."
	self value: [self canonicalObject nextPutAll: #($a 9 $X)]
		shouldRaise: Error.!

testXspace

#todo."Don't know how to check this:
The effect is the same as sending the message #nextPut: to the receiver with an argument that is the object that is the value returned when the message #space is sent to the standard global Character.
"
	self assertSend: #space!

testXnextPutX

#todo."Don't know how to check this:
Appends anObject to the receiver's past sequence values. If the receiver's future sequence values is not empty, removes its first object.
"
	self value: [self canonicalObject nextPut: $a]
		should: [:r | true "UNSPECIFIED" ]
		conformTo: self protocol selector: #'nextPut:'.

	"Errors: It is erroneous if anObject is an object that does not
			conform to the receiver's sequence value type."
	self value: [self canonicalObject nextPut: 9]
		shouldRaise: Error.!

canonicalObject

	^testCase canonicalObject!

testXtab

#todo."Don't know how to check this:
The effect is the same as sending the message #nextPut: to the receiver with an argument that is the object that is the value returned when the message #tab is sent to the standard global Character.
"
	self assertSend: #tab! !

!PuttableStreamHelper class methodsFor: nil!

initialize
	"PuttableStreamHelper  initialize"
	super initialize! !

!DateAndTimeFactoryANSITest methodsFor: nil!

testXnow
	" <DateAndTime factory>#now "
	#'Date and Time'.
	self value: [DateAndTime now] should: [:r | "unspecified" true]
		conformTo: #'DateAndTime factory' selector: #'now'.!

testXyearXdayXhourXminuteXsecondXoffsetX
	" <DateAndTime factory>#year:day:hour:minute:second:offset: "
	#'Date and Time'.
#'todo'. "??? finish impl this. ???"
	"April 26, 1997 CST"
	self value: [DateAndTime year: 1997 day: 116
				hour: 1 minute: 2 second: 3
						offset: (Duration hours: -6 "CST")]
		should: [:r | (r year = 1997) & (r month = 4)
					& (r dayOfMonth = 26)
					& (r hour = 1) & (r minute = 2) & (r second = 3)]
		conformTo: #'DateAndTime factory'
		selector: #'year:day:hour:minute:second:offset:'.!

testXyearXmonthXdayXhourXminuteXsecondX
	" <DateAndTime factory>#year:month:day:hour:minute:second: "
	#'Date and Time'.
#'todo'. "??? finish impl this. ???"
	"April 26, 1997 CST"
	self value: [DateAndTime year: 1997 month: 4 day: 26
						hour: 1 minute: 2 second: 3]
		should: [:r | (r year = 1997) & (r month = 4) & (r dayOfMonth = 26)
					& (r hour = 1) & (r minute = 2) & (r second = 3)]
		conformTo: #'DateAndTime factory'
		selector: #'year:month:day:hour:minute:second:'.!

testXclockPrecision
	" <DateAndTime factory>#clockPrecision "
	#'Date and Time'.
	self value: [DateAndTime clockPrecision]
		should: [:r | "unspecified" true]
		conformTo: #'DateAndTime factory' selector: #'clockPrecision'.!

canonicalObject
	^DateAndTime!

testXyearXdayXhourXminuteXsecondX
	" <DateAndTime factory>#year:day:hour:minute:second: "
	#'Date and Time'.
#'todo'. "??? finish impl this. ???"
	"April 26, 1997 CST"
	self value: [DateAndTime year: 1997 day: 116
				hour: 1 minute: 2 second: 3]
		should: [:r | (r year = 1997) & (r month = 4)
					& (r dayOfMonth = 26)
					& (r hour = 1) & (r minute = 2) & (r second = 3)]
		conformTo: #'DateAndTime factory'
		selector: #'year:day:hour:minute:second:'.!

testXyearXmonthXdayXhourXminuteXsecondXoffsetX
	" <DateAndTime factory>#year:month:day:hour:minute:second:offset: "
	#'Date and Time'.
#'todo'. "??? finish impl this. ???"
	"April 26, 1997 CST"
	self value: [DateAndTime year: 1997 month: 4 day: 26
						hour: 1 minute: 2 second: 3
						offset: (Duration hours: -6 "CST")]
		should: [:r | (r year = 1997) & (r month = 4) & (r dayOfMonth = 26)
					& (r hour = 1) & (r minute = 2) & (r second = 3)]
		conformTo: #'DateAndTime factory'
		selector: #'year:month:day:hour:minute:second:offset:'.!

protocol
	^#'DateAndTime factory'! !

!MsgReturnSpec methodsFor: nil!

printOn: targetStream 
	"Append to targetStream a text representation of the receiver as a developer would want to see it (inspector, etc)."

	targetStream nextPutAll: self class name;
	 nextPut: $(.
	self returnValueProtocolNames do: [:protocolName |
		targetStream nextPut: $<;
		 nextPutAll: protocolName;
		 nextPut: $>]
		separatedBy: [targetStream nextPutAll: '|'].
	targetStream space; nextPutAll: self returnValueAliasingAttribute; nextPut: $)!

storeSIFOn: targetStream 
	"Append to targetStream, a <puttableStream>, the ASCII representation of the receiver in SIF from which the receiver can be rebuilt but NOT reinstantiated via evaluate."

	#todo."??? Find better way to keep SIF knowledge out of model ???"
	targetStream nextPutAll: '#('.
	targetStream space; nextPut: $'.
	returnValueProtocols do: [:protocolName | targetStream nextPutAll: protocolName asString]
		separatedBy: [', ' printOn: targetStream].
	targetStream nextPut: $'.
	targetStream nextPutAll: ' #'.
	returnValueAliasingAttribute asString printOn: targetStream.
	targetStream nextPutAll: ')'!

setProtocolNames: protocolNames aliasing: aliasingAttribute 
	"Private - ."

	returnValueProtocols := protocolNames.
	returnValueAliasingAttribute := aliasingAttribute!

returnValueAliasingAttribute
	"Answer the protocol message return value aliasing attribute."

	^ returnValueAliasingAttribute!

returnValueProtocolNames
	"Answer the protocol names the protocol message return value conforms to."

	^ returnValueProtocols!

isConformingReturnClass: returnClass 
	"Answer true if the class, returnClass, of the result of sending a message conforms to the receiver, else false."

	self returnValueProtocolNames
		do: [:protocolName | (returnClass conformsToProtocolNamed: protocolName)
				ifTrue: [^ true]].
	^ false!

storeSIFString
        "Answer a <readableString>, a representation of the receiver in SIF from which the receiver
can be rebuilt but NOT reinstantiated via evaluate."
        | aStream |
        aStream := WriteStream on: (String new: 50).
        self storeSIFOn: aStream.
        ^ aStream contents! !

!MsgReturnSpec class methodsFor: nil!

privateValidProtocolNames: protocolNamesIn ifError: errorBlock 
	"Private -"
	| protocolNamesTmp |
	(protocolNamesIn isKindOf: Collection)
		ifFalse: [^ errorBlock value].
	protocolNamesTmp := self protocolManager defaultProtocolNameCollection.
	protocolNamesIn
		do: 
			[:protocolName | 
			(protocolName isKindOf: Symbol)
				ifFalse: [^ errorBlock value].
			protocolNamesTmp add: protocolName].
	^ protocolNamesTmp!

privateNewRetValProtocolNames: protocolNames aliasing: aliasingAttribute 
	"Private -"
	| protocolNamesTmp |
	(self aliasingAttributes includes: aliasingAttribute)
		ifFalse: [self error: 'Protocol msg. return value aliasing attribute not valid.'].
	protocolNamesTmp := self privateValidProtocolNames: protocolNames ifError: [^ self error: 'Protocol msg. return value protocol names not a <collection> of <symbol>s.'].
	^ super new setProtocolNames: protocolNamesTmp aliasing: aliasingAttribute!

aliasingAttributes
	"Answer a list of protocol message return value aliasing attribute constants.
	Note: The list is a <Set> of <symbol>s."
	^ Set
		with: self returnValueAliasingAttributeNew
		with: self returnValueAliasingAttributeState
		with: self returnValueAliasingAttributeUnspecified!

newRetValStateProtocolNames: protocolNames 
	"Answer a new return value specification indicating a protocol message's return value has a state aliasing attribute and conforms to the protocols named, protocolNames. 
	Note: protocolNames must be a <collection> of <symbol>s."

	^ self privateNewRetValProtocolNames: protocolNames aliasing: self returnValueAliasingAttributeState!

returnValueAliasingAttributeState
	"Answer a protocol message return value state aliasing attribute constant."

	^ #'state'!

returnValueAliasingAttributeNew
	"Answer a protocol message return value new aliasing attribute constant."

	^ #'new'!

returnValueAliasingAttributeUnspecified
	"Answer a protocol message return value unspecified aliasing attribute constant."

	^ #'unspecified'!

new
	"Raise an exception as this is an inappropriate message."

	^ self shouldNotImplement!

newRetValNewProtocolNames: protocolNames 
	"Answer a new return value specification indicating a protocol message's return value has a new aliasing attribute and conforms to the protocols named, protocolNames. 
	Note: protocolNames must be a <collection> of <symbol>s."

	^ self privateNewRetValProtocolNames: protocolNames aliasing: self returnValueAliasingAttributeNew!

newRetValProtocolNames: protocolNames aliasing: aliasingAttribute 
	"Answer a new return value specification indicating a protocol message's return value conforms to the protocols named, protocolNames, and has an aliasing attribute, aliasingAttribute. 
	Note: protocolNames must be a <collection> of <symbol>s."

	^ self privateNewRetValProtocolNames: protocolNames aliasing: aliasingAttribute!

newRetValUnspecifiedProtocolNames: protocolNames 
	"Answer a new return value specification indicating a protocol message's return value has a unspecified aliasing attribute and conforms to the protocols named, protocolNames."

	^ self privateNewRetValProtocolNames: protocolNames aliasing: self returnValueAliasingAttributeUnspecified! !

!ReadWriteStreamANSITest methodsFor: nil!

protocol
	^#'ReadWriteStream'!

setUp
	super setUp.
	readWriteStream := ReadWriteStream with: 'this is a string'!

canonicalObject
	^readWriteStream! !

!ReadWriteStreamANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: ReadStreamHelper.
	aBlock value: WriteStreamHelper! !

!DateAndTimeANSITest methodsFor: nil!

testXyear
	" <DateAndTime>#year "
	#'Date and Time'.
	self value: [d19970426t8 year] should: [:r | r = 1997]
		conformTo: #'DateAndTime' selector: #'year'.!

testXhour12
	" <DateAndTime>#hour12 "
	#'Date and Time'.
	self value: [d19970426t8 hour12] should: [:r | r = 8]
		conformTo: #'DateAndTime' selector: #'hour12'.!

testXmonthName
	" <DateAndTime>#monthName "
	#'Date and Time'.
	self value: [d19970426t8 monthName] should: [:r | r asString = 'April']
		conformTo: #'DateAndTime' selector: #'monthName'.!

testXmonth
	" <DateAndTime>#month "
	#'Date and Time'.
	self value: [d19970426t8 month] should: [:r | r = 4]
		conformTo: #'DateAndTime' selector: #'month'.!

testXminute
	" <DateAndTime>#minute "
	#'Date and Time'.
	self value: [d19970426t8 minute] should: [:r | r = 0]
		conformTo: #'DateAndTime' selector: #'minute'.!

testXminX
	" <magnitude>#min: "
	#'Date and Time'.!

setUp
	super setUp.
	d19970426t8 := DateAndTime
		year: 1997 month: 4 day: 26
		hour: 8 minute: 0 second: 0.!

testXlessThanOrEqualToOp
	" <magnitude>#<= "
	#'Date and Time'.!

testXgreaterThanOrEqualToOp
	" <magnitude>#>= "
	#'Date and Time'.!

testXaddOp
	" <DateAndTime>#+ "
	#'Date and Time'.
	self value: [d19970426t8
				+ (Duration days: 1 hours: 0 minutes: 0 seconds: 1)]
		should: [:r | r = (DateAndTime year: 1997 month: 4 day: 27
							hour: 8 minute: 0 second: 1)]
		conformTo: #'DateAndTime' selector: #'+'.

	self value: [d19970426t8
				+ (Duration days: -1 hours: 0 minutes: 0 seconds: -1)]
		should: [:r | r = (DateAndTime year: 1997 month: 4 day: 25
							hour: 7 minute: 59 second: 59)]
		conformTo: #'DateAndTime' selector: #'+'.!

testXdayOfWeekName
	" <DateAndTime>#dayOfWeekName "
	#'Date and Time'.
	self value: [d19970426t8 dayOfWeekName] should: [:r | r asString = 'Saturday']
		conformTo: #'DateAndTime' selector: #'dayOfWeekName'.!

testXdayOfWeekAbbreviation
	" <DateAndTime>#dayOfWeekAbbreviation "
	#'Date and Time'.
	self value: [d19970426t8 dayOfWeekAbbreviation]
		should: [:r | r asString = 'Sat']
		conformTo: #'DateAndTime' selector: #'dayOfWeekAbbreviation'.!

testXdayOfMonth
	" <DateAndTime>#dayOfMonth "
	#'Date and Time'.
	self value: [d19970426t8 dayOfMonth] should: [:r | r = 26]
		conformTo: #'DateAndTime' selector: #'dayOfMonth'.!

testXdayOfWeek
	" <DateAndTime>#dayOfWeek "
	#'Date and Time'.
	self value: [d19970426t8 dayOfWeek] should: [:r | r = 7]
		conformTo: #'DateAndTime' selector: #'dayOfWeek'.!

testXasUTC
	" <DateAndTime>#asUTC "
	#'Date and Time'.
#todo. "??? I'm not sure how to test. ???"
	self value: [d19970426t8 asUTC]
		should: [:r | "Invariant:" r offset = Duration zero]
		conformTo: #'DateAndTime' selector: #'asUTC'.!

testXtimeZoneAbbreviation
	" <DateAndTime>#timeZoneAbbreviation "
	"Changed 2000/06/23 Harmon, R. Needs Daylight Savings Fix."
	| offTmp |
	#'Date and Time'.
#'testAnom'.">>>
	offTmp := Duration days: 0 hours: -5 minutes: 0 seconds: 0.

	self value: [(d19970426t8 offset: offTmp) timeZoneAbbreviation]
		should: [:r | r = 'EST']
		conformTo: #'DateAndTime' selector: #'timeZoneAbbreviation'.
<<<"

#todo.">>>Fails because d19970426t7MST is Daylight Savings not Standard.
	offTmp := Duration days: 0 hours: -6 minutes: 0 seconds: 0.
	self value: [(d19970426t8 offset: offTmp) timeZoneAbbreviation]
		should: [:r | r = 'CST']
		conformTo: #'DateAndTime' selector: #'timeZoneAbbreviation'.
<<<"!

testXhour24
	" <DateAndTime>#hour24 "
	#'Date and Time'.
	self value: [d19970426t8 hour24] should: [:r | r = 8]
		conformTo: #'DateAndTime' selector: #'hour24'.!

testXlessThanOp
	" <DateAndTime>#< "
	#'Date and Time'.
	self value: [d19970426t8 < (DateAndTime year: 1997 month: 4 day: 27
							hour: 8 minute: 0 second: 1)]
		should: [:r | r] conformTo: #'DateAndTime' selector: #'<'.
	self value: [d19970426t8 < (DateAndTime year: 2000 month: 4 day: 27
							hour: 8 minute: 0 second: 0)]
		should: [:r | r] conformTo: #'DateAndTime' selector: #'<'.

	self value: [d19970426t8 < (DateAndTime year: 1996 month: 4 day: 27
							hour: 7 minute: 0 second: 0)]
		shouldnt: [:r | r] conformTo: #'DateAndTime' selector: #'<'.!

testXsecond
	" <DateAndTime>#second "
	#'Date and Time'.
	self value: [d19970426t8 second] should: [:r | r = 0]
		conformTo: #'DateAndTime' selector: #'second'.!

testXoffsetX
	" <DateAndTime>#offset: "
	| d19970426t08Tmp off123 |
	#'Date and Time'.
#todo. "??? Add int, flt, frac offset: tests. ???"
	off123 := Duration days: 0 hours: 1 minutes: 2 seconds: 3.
	d19970426t08Tmp := DateAndTime year: 1997 month: 4 day: 26
				hour: 0 minute: 0 second: 0 offset: (Duration zero).
	self value: [(d19970426t08Tmp offset: off123)]
		should: [:r | r = (DateAndTime year: 1997 month: 4 day: 26
						hour: 0 minute: 0 second: 0 offset: off123)]
		conformTo: #'DateAndTime' selector: #'offset:'.
	"Invariant:"
	self should: [(d19970426t08Tmp offset: off123) offset = off123].!

testXgreaterThanOp
	" <DateAndTime>#> "
	#'Date and Time'.
	self value: [(DateAndTime year: 1997 month: 4 day: 27
					hour: 8 minute: 0 second: 1) > d19970426t8]
		should: [:r | r] conformTo: #'DateAndTime' selector: #'>'.
	self value: [(DateAndTime year: 2000 month: 4 day: 27
				hour: 8 minute: 0 second: 0) > d19970426t8]
		should: [:r | r] conformTo: #'DateAndTime' selector: #'>'.

	self value: [(DateAndTime year: 1996 month: 4 day: 27
				hour: 7 minute: 0 second: 0) > d19970426t8]
		shouldnt: [:r | r] conformTo: #'DateAndTime' selector: #'>'.!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Date and Time'.!

testXequalityOp
	" <DateAndTime>#="
	"Changed 2000/06/23 Harmon, R. Needs Daylight Savings Fix."
	| d19970426t8CST d19970426t7MST d19970426t7CST tmp1 tmp2 |
	#'Date and Time'.
	d19970426t8CST := DateAndTime year: 1997 month: 4 day: 26
								hour: 8 minute: 0 second: 0.
	"1997-04-26T08:00:00-06:00 CST"
	self	value: [d19970426t8 = d19970426t8CST]
		should: [:r | r & (d19970426t8 hash = d19970426t8CST hash)]
		conformTo: #DateAndTime selector: #=.

	d19970426t8CST := DateAndTime year: 1997 month: 4 day: 26
								hour: 8 minute: 0 second: 0.
	"1997-04-26T08:00:00-06:00 CST"
	tmp1 := DateAndTime year: 1996 month: 4 day: 26
						hour: 5 minute: 59 second: 50
						offset: (Duration seconds: -10).
	tmp2 := DateAndTime year: 1996 month: 4 day: 26
						hour: 6 minute: 0 second: 10
						offset: (Duration seconds: 10).
	self	value: [tmp1 = tmp2]
		should: [:r | r & (tmp1 hash = tmp2 hash)]
		conformTo: #DateAndTime selector: #=.

	d19970426t7MST := DateAndTime year: 1997 month: 4 day: 26
							hour: 7 minute: 0 second: 0
							offset: (Duration days: 0 hours: -7
									minutes: 0 seconds: 0).
	"1997-04-26T07:00:00-07:00 MST"
#todo.">>>Fails because d19970426t7MST is Daylight Savings not Standard.
	self	value: [d19970426t8 = d19970426t7MST]
		should: [:r | r & (d19970426t8 hash = d19970426t7MST hash)]
		conformTo: #DateAndTime selector: #=.
<<<"
	d19970426t7CST := DateAndTime year: 1996 month: 4 day: 27
								hour: 7 minute: 0 second: 0.
	"1997-04-26T07:00:00-07:00 MST"
	self value: [d19970426t8 = d19970426t7CST]
		shouldnt: [:r | r & (d19970426t8 hash = d19970426t7CST hash)]
		conformTo: #DateAndTime selector: #=!

testXdayOfYear
	" <DateAndTime>#dayOfYear "
	#'Date and Time'.
	self value: [d19970426t8 dayOfYear] should: [:r | r = 116]
		conformTo: #'DateAndTime' selector: #'dayOfYear'.!

testXprintString
	" <DateAndTime>#printString "
	#'Date and Time'.
	self value: [(DateAndTime year: 1997 month: 4 day: 26
				hour: 1 minute: 2 second: 3
				offset: (Duration days: 0 hours: 1 minutes: 2 seconds: 3) 			) printString]
		should: [:r | r = ' 1997-04-26T01:02:03+01:02:3']
		conformTo: #'DateAndTime' selector: #'printString'.

	"Example: 8:33:14.321 PM EST January 5, 1200 B.C. 
		'-1199-01-05T20:33:14.321-05:00'
		8:33:14.321 PM -> 20:33:14.321 24 hour"
#'testAnom'. "??? '  0701-01-05T20:33:14-05:00' wrong--not neg.
		-> '-1199-01-05T20:33:14-05:00'
	self value: [(DateAndTime year: -1199 month: 1 day: 5
				hour: 20 minute: 33 second: 14
				offset: (Duration hours: -5 ??EST??)) printString]
		should: [:r | r = '-1199-01-05T20:33:14.321-05:00']
		conformTo: #'DateAndTime' selector: #'printString'.
???"
	"Example: 12 midnight UTC January 1,  2001 A.D. 
			' 2001-01-01T00:00:00+00:00'"
	self value: [(DateAndTime year: 2001 month: 1 day: 1
				hour: 0 minute: 0 second: 0
				offset: Duration zero) printString]
		should: [:r | r = ' 2001-01-01T00:00:00+00:00']
		conformTo: #'DateAndTime' selector: #'printString'.!

testXmeridianAbbreviation
	" <DateAndTime>#meridianAbbreviation "
	#'Date and Time'.
	self value: [d19970426t8 meridianAbbreviation] should: [:r | r asString = 'AM']
		conformTo: #'DateAndTime' selector: #'meridianAbbreviation'.

	self value: [(DateAndTime year: 1996 month: 2 day: 1
				hour: 12 minute: 0 second: 0 ) meridianAbbreviation]
		should: [:r | r asString = 'PM']
		conformTo: #'DateAndTime' selector: #'meridianAbbreviation'.!

testXsubtractOp
	" <DateAndTime>#- "
	#'Date and Time'.
	"If operand is a <DateAndTime>, answer a <Duration>."
	self value: [d19970426t8 - (DateAndTime year: 1997 month: 4 day: 26
								hour: 7 minute: 0 second: 0)]
		should: [:r | (r isKindOf: Duration)
				& r = (Duration days: 0 hours: 1 minutes: 0 seconds: 0)]
		conformTo: #'DateAndTime' selector: #'-'.
	self value: [d19970426t8 - (DateAndTime year: 1998 month: 4 day: 26
									hour: 7 minute: 0 second: 0)]
		should: [:r | (r isKindOf: Duration)
			& r = (Duration days: -364 hours: -23 minutes: 0 seconds: 0)]
		conformTo: #'DateAndTime' selector: #'-'.
	"If operand is a <Duration>, answer a new <DateAndTime>"
	self value: [d19970426t8 - (Duration days: 1 hours: 0
		minutes: 0 seconds: 1)]
		should: [:r | (r isKindOf: DateAndTime)
					& r = (DateAndTime year: 1997 month: 4 day: 25
							hour: 7 minute: 59 second: 59)]
		conformTo: #'DateAndTime' selector: #'-'.
	self value: [d19970426t8 - (Duration days: -1 hours: 0
		minutes: 0 seconds: -1)]
		should: [:r | (r isKindOf: DateAndTime)
					& r = (DateAndTime year: 1997 month: 4 day: 27
							hour: 8 minute: 0 second: 1)]
		conformTo: #'DateAndTime' selector: #'-'.!

protocol
	^#'DateAndTime'!

canonicalObject
	^DateAndTime year: 2000 month: 3 day: 16 hour: 16 minute: 49 second: 43!

testXisLeapYear
	" <DateAndTime>#isLeapYear "
	#'Date and Time'.
	self value: [d19970426t8 isLeapYear] shouldnt: [:r | r]
		conformTo: #'DateAndTime' selector: #'isLeapYear'.

	self value: [(DateAndTime year: 1996 month: 2 day: 1
				hour: 0 minute: 0 second: 0 ) isLeapYear]
		should: [:r | r]
		conformTo: #'DateAndTime' selector: #'isLeapYear'.!

testXhour
	" <DateAndTime>#hour "
	#'Date and Time'.
	self value: [d19970426t8 hour] should: [:r | r = 8]
		conformTo: #'DateAndTime' selector: #'hour'.!

testXoffset
	" <DateAndTime>#offset "
	| d19970426t8Tmp off123 |
	#'Date and Time'.
	off123 := Duration days: 0 hours: 1 minutes: 2 seconds: 3.
	d19970426t8Tmp := DateAndTime year: 1997 month: 4 day: 26
						hour: 0 minute: 0 second: 0 offset: off123.
	self value: [d19970426t8Tmp offset] should: [:r | r = off123]
		conformTo: #'DateAndTime' selector: #'offset'.!

testXasLocal
	" <DateAndTime>#asLocal "
	#'Date and Time'.
#todo. "??? I'm not sure how to test. ???"
	self value: [d19970426t8 asLocal] should: [:r | true]
		conformTo: #'DateAndTime' selector: #'asLocal'.!

testXmonthAbbreviation
	" <DateAndTime>#monthAbbreviation "
	#'Date and Time'.
	self value: [d19970426t8 monthAbbreviation] should: [:r | r asString = 'Apr']
		conformTo: #'DateAndTime' selector: #'monthAbbreviation'.!

testXtimeZoneName
	" <DateAndTime>#timeZoneName "
	"Changed 2000/06/23 Harmon, R. Needs Daylight Savings Fix."
	| offTmp |
	#'Date and Time'.
#'testAnom'.">>>
	offTmp := Duration days: 0 hours: -5 minutes: 0 seconds: 0.
	self value: [(d19970426t8 offset: offTmp) timeZoneName]
		should: [:r | r = 'EST']
		conformTo: #'DateAndTime' selector: #'timeZoneName'.
<<<"

#todo.">>>Fails because d19970426t7MST is Daylight Savings not Standard.
	offTmp := Duration days: 0 hours: -6 minutes: 0 seconds: 0.
	self value: [(d19970426t8 offset: offTmp) timeZoneName]
		should: [:r | r = 'Central Standard Time']
		conformTo: #'DateAndTime' selector: #'timeZoneName'.
<<<"!

testXmaxX
	" <magnitude>#max: "
	#'Date and Time'.! !

!SequencedContractibleCollectionHelper methodsFor: nil!

object: anObject!

object
	^testCase canonicalObject!

testXremoveLast
	" <sequencedCollection>#removeLast "
	| sequencedCollection getValue getValue2 originalLength |
	#'Collection'.
	sequencedCollection := self object.
	originalLength := sequencedCollection size.
	getValue := sequencedCollection at: originalLength.
	getValue2 := sequencedCollection at: originalLength - 1.
	self 
		value: [sequencedCollection removeLast]
		should: [ :result | result = getValue and: [ ((sequencedCollection at: (originalLength - 1)) = getValue2) and: [ sequencedCollection size = (originalLength - 1) ] ] ]
		conformTo: #sequencedContractibleCollection
		selector: #removeLast.!

testXremoveAtIndexX
	" <sequencedCollection>#removeAtIndex: "
	| sequencedCollection getValue getValue2 |
	#'Collection'.
	sequencedCollection := self object.
	getValue := sequencedCollection at: 1.
	getValue2 := sequencedCollection at: 2.
	self 
		value: [sequencedCollection removeAtIndex: 1]
		should: [ :result | result = getValue and: [ (sequencedCollection at: 1) = getValue2] ]
		conformTo: #sequencedContractibleCollection
		selector: #removeAtIndex:.
	self
		should: [sequencedCollection removeAtIndex: 0]
		raise: TestResult error.
	self
		should: [sequencedCollection removeAtIndex: sequencedCollection size + 1]
		raise: TestResult error.!

testXremoveFirst
	" <sequencedCollection>#removeFirst "
	| sequencedCollection getValue getValue2 originalLength |
	#'Collection'.
	sequencedCollection := self object.
	getValue := sequencedCollection at: 1.
	getValue2 := sequencedCollection at: 2.
	originalLength := sequencedCollection size.
	self 
		value: [sequencedCollection removeFirst]
		should: [ :result | result = getValue and: [ ((sequencedCollection at: 1) = getValue2) and: [ sequencedCollection size = (originalLength - 1) ] ] ]
		conformTo: #sequencedContractibleCollection
		selector: #removeFirst.! !

!ByteArrayANSITest methodsFor: nil!

canonicalElement

	^self canonicalObject at: 2!

conformanceOfPutElementOnXatAllXputX: aString
	self 
		should: [ self canonicalObject atAll: #(1 2) put: aString]
		raise: TestResult error!

conformanceOfPutElementOnXatAllPutX: aString
	self 
		should: [ self canonicalObject atAllPut: aString]
		raise: TestResult error!

protocol
	^#'ByteArray'!

conformanceOfPutElementOnXatXputX: aString
	self 
		should: [ self canonicalObject at: 1 put: aString]
		raise: TestResult error!

canonicalObject
	^ByteArray with: 1 with: 2 with: 3 with: 4!

emptyCollection

	^self canonicalObject class new! !

!ByteArrayANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: SequencedCollectionHelper.
	aBlock value: SequencedReadableCollectionHelper! !

!SortedCollectionFactoryANSITest methodsFor: nil!

testXnew
	" <SortedCollection factory>#new "
	#'Collection'.!

testXwithXwithX
	" <SortedCollection factory>#with:with: "
	#'Collection'.!

testXwithX
	" <SortedCollection factory>#with: "
	#'Collection'.!

protocol
	^#'SortedCollection factory'!

testXsortBlockX
	" <SortedCollection factory>#sortBlock: "
	#'Collection'.!

testXnewX
	" <SortedCollection factory>#new: "
	#'Collection'.!

testXwithAllX
	" <SortedCollection factory>#withAll: "
	#'Collection'.!

canonicalObject
	^SortedCollection!

testXwithXwithXwithX
	" <SortedCollection factory>#with:with:with: "
	#'Collection'.!

testXwithXwithXwithXwithX
	" <SortedCollection factory>#with:with:with:with: "
	#'Collection'.! !

!DurationFactoryANSITest methodsFor: nil!

testXsecondsX
	" <Duration factory>#seconds: "
	#'Date and Time'.
#'todo'. "??? finish impl this. ???"
	"((1 * (24 * 60 * 60) + (1 * (60 * 60)) + (1 * 60) + 1)) -> 90061"
	self value: [(Duration seconds: 3)]
		should: [:r | r = (Duration days: 0 hours: 0 minutes: 0 seconds: 3)]
		conformTo: #'Duration factory' selector: #'seconds:'.!

testXdaysXhoursXminutesXsecondsX
	" <Duration factory>#days:hours:minutes:seconds: "
	#'Date and Time'.
#'todo'. "??? finish impl this. ???"
	self value: [(Duration days: 0 hours: 1 minutes: 2 seconds: 3)]
		should: [:r | r = (Duration days: 0 hours: 1 minutes: 2 seconds: 3)]
		conformTo: #'Duration factory'
		selector: #'days:hours:minutes:seconds:'.!

canonicalObject
	^Duration!

testXzero
	" <Duration factory>#zero "
	#'Date and Time'.
	self value: [Duration zero] should: [:r | r asSeconds = 0]
		conformTo: #'Duration factory' selector: #'seconds:'.!

protocol
	^#'Duration factory'! !

!MonadicBlockANSITest methodsFor: nil!

testXvalueWithArgumentsX
	" <valuable>#valueWithArguments: "
	#'Valuable'.
	self value: [blk1args valueWithArguments: #(1)]
		should: [:r | r = #(1)]
		conformTo: #'valuable' selector: #'valueWithArguments:'.!

testXvalueX
	" <monadicValuable>#value: "
	#'Valuable'.
	self value: [blk1args value: 1] should: [:r | r = #(1)]
		conformTo: #'monadicValuable' selector: #'value:'.!

testXargumentCount
	" <monadicValuable>#argumentCount "
	#'Valuable'.
	self value: [blk1args argumentCount] should: [:r | r = 1]
		conformTo: #'monadicValuable' selector: #'argumentCount'.!

protocol
	^#'monadicBlock'!

setUp
	super setUp.
	blk1args := [ :arg1 | Array with: arg1 ].!

canonicalObject
	^blk1args! !

!BagANSITest methodsFor: nil!

protocol
	^#'Bag'!

canonicalElement

	^2!

returnTypeHasLimitedElementTypes

	^true!

emptyCollection

	^self canonicalObject class new!

limitedElementTypes

	^nil!

testXaddXwithOccurrencesX
	" <Bag>#add:withOccurrences: "
	| it |
	it := Bag new.
	self
		value: [it add: 42 withOccurrences: 3]
		should: [:r | (it occurrencesOf: 42) = 3]
		conformTo: #Bag
		selector: #add:withOccurrences:!

canonicalObject
	^Bag with: 1 with: 2 with: 3 with: 4!

canonicalObject
	^Bag with: 1 with: 2 with: 3 with: 4!

limitedElementType

	^nil! !

!BagANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: ExtensibleCollectionHelper.! !

!ExceptionANSITest methodsFor: nil!

exceptionOuterReturn

	^[[Exception signal]
		on: Exception
		do:
			[:except |
			except outer.
			unchanged := false]]
				on: Exception
				do: [:except | except return: true]!

notificationOuterDefault
"A bug in Squeak's #outer leads this next thing to an infinite loop ..."
"	value := 1.
	value := [Notification signal]
		on: Notification
		do:
			[:except |
			except outer.
			unchanged := false]. 
"!

testXresume
	" <signaledException>#resume "
	value := 1.
	self resumedNotification.
	self should: [(value == nil) and: [unchanged]].
	self setUp.
	changed := self resumedException.
	self should: [changed and: [unchanged]]!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.
	"tested by the zillion other sends of signal"!

setUp
	unchanged := true.
	value := nil.
	changed := false.!

resignalExceptionAsNotification

	| firstTime |
	firstTime := true.
	^[[Exception signal]
		on: Exception
		do:
			[:ex |
			firstTime
				ifTrue:
					[firstTime := false.
					ex resignalAs: Notification new.
					unchanged := false]
				ifFalse: [ex pass]]]
				on: Notification
				do: [:ex | ex return: true]!

testXdefaultAction
	" <exceptionDescription>#defaultAction "
	self should: [Notification signal == nil]!

resumedExceptionWithValue
	^[[Exception signal] 
		on: Exception 
		do: 
			[:except |
			except resume: false.
			unchanged := false]]
				on: Exception
				do:
					[:ex | ex return: true]!

testXretryUsingX
	" <signaledException>#retryUsing: "
	[Exception signal]
		on: Exception
		do:
			[:except |
			except retryUsing: [changed := true].
			unchanged := false].
	self should: [changed and: [unchanged]]!

testXisResumable
	" <exceptionDescription>#isResumable "
	#'Exception'.
	self mustBeBoolean: Exception new isResumable.
	self shouldnt: [Error new isResumable].
	self should: [Notification new isResumable].
	self should: [ZeroDivide new isResumable].
	self should: [MessageNotUnderstood new isResumable].!

mustBeBoolean: anObject
	self should: [anObject == true or: [anObject == false]].!

testXmessageTextX
	" <exceptionBuilder>#messageText: (Return Values: <RECEIVER>) "
	#'Exception'.!

exceptionPass
	" <signaledException>#pass "
	^[[Exception signal]
		on: Exception
		do:
			[:ex |
			ex pass.
			unchanged := false]]
				on: Exception
				do:
					[:ex |
					changed := true.
					ex return]

	"conformTo: #'signaledException' selector: #'pass'."!

testXresignalAsX
	" <signaledException>#resignalAs: "
	changed := self resignalNotificationAsException.
	self should: [changed and: [unchanged]].
	self setUp.
	changed := self resignalExceptionAsNotification.
	self should: [changed and: [unchanged]].!

resumedException
	^[[Exception signal] 
		on: Exception 
		do: 
			[:except |
			except resume: false. "Exception isn't resumable - this throws an exception"
			unchanged := false]]
				on: Exception
				do:
					[:ex | ex return: true]!

resumedNotification
	[value := Notification signal] 
		on: Notification 
		do: 
			[:except |
			except resume.
			unchanged := false]!

testXsignal
	" <exceptionSignaler>#signal "
	#'Exception'.
	"tested by the zillion other sends of signal"!

notificationOuterResume

	[[changed := Notification signal]
		on: Notification
		do:
			[:except |
			except outer.
			unchanged := false]]
				on: Notification
				do: [:except | except resume: true]!

testXdescription
	" <exceptionDescription>#description "
	| exception messageText |
"not sure - spec only says that default should be something 'readable'; well, at least it shouldn't be nil ..."
	self shouldnt: [Exception new description == nil].
	exception := Exception new.
	messageText := 'our chief weapon is fear'.
	exception messageText: messageText.
	self shouldnt: [(exception description indexOfSubCollection: messageText) = 0].!

testXretry
	" <signaledException>#retry "
	| firstTime |
	firstTime := true.
	[firstTime
		ifTrue: [Exception signal] 
		ifFalse: [changed := true]]
			on: Exception 
			do: 
				[:except |
				firstTime := false.
				except retry.
				unchanged := false].
	self should: [changed and: [unchanged]]!

signalNestedException
	^[[Exception signal]
		on: Exception
		do: [:exception | exception return: exception isNested]]
			on: Exception
			do: [:exception | exception return]!

signalExceptionNestedWithError
	^[[Exception signal]
		on: Exception
		do: [:exception | exception return: exception isNested]]
			on: Error
			do: [:error | error return]!

testXreturnX
	" <signaledException>#return: "
	changed := [Exception signal]
		on: Exception
		do:
			[:except |
			except return: true.
			unchanged := false].
	self should: [changed and: [unchanged]]!

testXpass
	" <signaledException>#pass "
	self exceptionPass.
	self should: [changed and: [unchanged]]!

protocol
	^#Exception!

canonicalObject
	^Exception new!

testXresumeX
	" <signaledException>#resume: "
	self resumedNotificationWithValue.
	self should: [changed and: [unchanged]].
	self setUp.
	changed := self resumedExceptionWithValue.
	self should: [changed and: [unchanged]]!

signalUnnestedException
	^[Exception signal]
		on: Exception 
		do: [:exception | exception return: exception isNested]!

testXtag
	" <exceptionDescription>#tag "
	| exception messageText |
	exception := Exception new.
	self should: [exception tag == nil].
	messageText := 'our chief weapon is fear'.
	exception messageText: messageText.
	self should: [exception tag = messageText].
	exception tag: 1.
	self should: [exception tag = 1].!

testXisNested
	" <signaledException>#isNested "
	self shouldnt: [self signalUnnestedException].
	self shouldnt: [self signalExceptionNestedWithError].
	self should: [self signalNestedException].
"	conformTo: #'signaledException' selector: #'isNested'."!

exceptionReturn
	^[Exception signal]
		on: Exception
		do:
			[:except |
			except return.
			unchanged := false]!

resumedNotificationWithValue
	[changed := Notification signal] 
		on: Notification 
		do: 
			[:except |
			except resume: true.
			unchanged := false]!

testXmessageText
	" <exceptionDescription>#messageText "
	| exception messageText |
	exception := Exception new.
	self should: [exception messageText == nil].
	messageText := 'our chief weapon is fear'.
	exception messageText: messageText.
	self should: [exception messageText = messageText].!

resignalNotificationAsException
	^[[Notification signal]
		on: Notification
		do:
			[:ex |
			ex resignalAs: Exception new.
			unchanged := false]]
				on: Exception
				do:
					[:ex | ex return: true]!

testXouter
	" <signaledException>#outer "
	#'Exception'.
	changed := self exceptionOuterReturn.
	self should: [changed and: [unchanged]].
	self setUp.
	value := self notificationOuterDefault.
	self should: [value == nil and: [unchanged]].
	self setUp.
	self notificationOuterResume.
	self should: [changed and: [unchanged]].!

testXreturn
	" <signaledException>#return "
	value := 1.
	value := self exceptionReturn.
	self should: [value == nil and: [unchanged]]! !

!ExceptionANSITest class methodsFor: nil!

suite
	^TestSuite new! !

!ByteArrayFactoryANSITest methodsFor: nil!

testXwithX
	" <ByteArray factory>#with: "
	#'Collection'.!

testXwithXwithX
	" <ByteArray factory>#with:with: "
	#'Collection'.!

testXnew
	" <ByteArray factory>#new "
	#'Collection'.!

protocol
	^#'ByteArray factory'!

testXnewX
	" <ByteArray factory>#new: "
	#'Collection'.!

testXwithAllX
	" <ByteArray factory>#withAll: "
	#'Collection'.!

canonicalObject
	^ByteArray!

testXwithXwithXwithX
	" <ByteArray factory>#with:with:with: "
	#'Collection'.!

testXwithXwithXwithXwithX
	" <ByteArray factory>#with:with:with:with: "
	#'Collection'.! !

!ReadableStringHelper methodsFor: nil!

testXasString

	" <readableString>#asString "
	#'ReadableString'.

	self assertSend: #asString!

testXsameAsX

	" <readableString>#sameAs:"
	#'ReadableString'.!

testXsubStringsX

	" <readableString>#subStrings:"
	#'ReadableString'.!

testXasUppercase

	" <readableString>#asSymbol "
	#'ReadableString'.!

testXasSymbol

	" <readableString>#asSymbol "
	#'ReadableString'.!

testXasLowercase

	" <readableString>#asLowercase "
	#'ReadableString'.

	self assertSend: #asLowercase!

canonicalObject

	^testCase canonicalObject! !

!OrderedCollectionANSITest methodsFor: nil!

testXaddFirstX
	" <OrderedCollection>#addFirst: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addFirst: 111]
		should:[:result | result = 111and: [(orderedCollection at: 1) = 111]]
		conformTo: #OrderedCollection
		selector: #addFirst:!

testXaddAllXafterIndexX
	" <OrderedCollection>#addAll:afterIndex: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addAll: #(111 222) afterIndex: 5]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection addAll: #(111 222) afterIndex: -1]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection addAll: #(333 444) afterIndex: 1 ]
		should: [:result | ((orderedCollection at: 2) = 333) and: [(orderedCollection at: 3) = 444] ]
		conformTo: #OrderedCollection
		selector: #addAll:afterIndex:.
	self
		value: [orderedCollection addAll: #(555 666)  afterIndex: 4]
		should: [:result | ((orderedCollection at: 5) = 555) and: [(orderedCollection at: 6) = 666]]
		conformTo: #OrderedCollection
		selector: #addAll:afterIndex:.
	self
		value: [orderedCollection addAll: #(777 888) afterIndex: 0]
		should: [:result | ((orderedCollection first) = 777) and: [( orderedCollection at: 2) = 888]]
		conformTo: #OrderedCollection
		selector: #addAll:afterIndex:!

testXaddAllXbeforeX
	" <OrderedCollection>#addAll:before: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addAll: #(111 222) before: 5]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection addAll: #(222 333) before: 1]
		should: [:result | (orderedCollection first) = 222 and: [(orderedCollection at: 2) = 333] ]
		conformTo: #OrderedCollection
		selector: #addAll:before:.
	self
		value: [orderedCollection addAll: #(444 555) before: 4]
		should: [:result | (orderedCollection at: orderedCollection size - 2) = 444 and: [(orderedCollection at: orderedCollection size - 1) = 555] ]
		conformTo: #OrderedCollection
		selector: #addAll:before:.
	self
		value: [orderedCollection addAll: #(666 777) before: 555]
		should: [:result | (orderedCollection at: orderedCollection size - 3) = 666 and: [(orderedCollection at: orderedCollection size - 2) = 777] ]
		conformTo: #OrderedCollection
		selector: #addAll:before:!

testXaddAllLastX
	" <OrderedCollection>#addAllLast: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addAllLast: #(111 222)]
		should:[:result | result = #(111 222) and: [(orderedCollection at: orderedCollection size - 1) = 111 and: [(orderedCollection last) = 222]]]
		conformTo: #OrderedCollection
		selector: #addAllLast:!

protocol
	^#OrderedCollection!

testXaddXbeforeX
	" <OrderedCollection>#add:before: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection add: 777 before: 5]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection add: 777 before: 1]
		should: [:result | (result = 777) and: [(orderedCollection first) = 777]]
		conformTo: #OrderedCollection
		selector: #add:before:.
	self
		value: [orderedCollection add: 888 before: 4]
		should: [:result | (result = 888) and: [(orderedCollection at: 5) = 888]]
		conformTo: #OrderedCollection
		selector: #add:before:.
	self
		value: [orderedCollection add: 999 before: 888]
		should: [:result | (result = 999) and: [(orderedCollection at: 5) = 999]]
		conformTo: #OrderedCollection
		selector: #add:before:!

testXaddAllFirstX
	" <OrderedCollection>#addAllFirst: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addAllFirst: #(111 222)]
		should:[:result | result = #(111 222) and: [(orderedCollection at: 1) = 111 and: [(orderedCollection at: 2) = 222]]]
		conformTo: #OrderedCollection
		selector: #addAllFirst:!

canonicalObject
	^OrderedCollection with: 1 with: 2 with: 3 with: 4!

testXaddX
	" <OrderedCollection>#add: "
	| orderedCollection sampleValue |
	#'Collection'.
	
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection add: 777]	
		should: [:result | 
			orderedCollection do: [ :each | sampleValue := each].
			sampleValue = 777]
		conformTo: #OrderedCollection
		selector: #add:!

testXaddXafterIndexX
	" <OrderedCollection>#add:afterIndex: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection add: 555 afterIndex: 5]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection add: 666 afterIndex: -1]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection add: 777 afterIndex: 0]
		should: [:result | (result = 777) and: [(orderedCollection first) = 777]]
		conformTo: #OrderedCollection
		selector: #add:afterIndex:.
	self
		value: [orderedCollection add: 888 afterIndex: 5]
		should: [:result | (result = 888) and: [(orderedCollection last) = 888]]
		conformTo: #OrderedCollection
		selector: #add:afterIndex:.
	self
		value: [orderedCollection add: 999 afterIndex: 1]
		should: [:result | (result = 999) and: [(orderedCollection at: 2) = 999]]
		conformTo: #OrderedCollection
		selector: #add:afterIndex:!

testXaddLastX
	" <OrderedCollection>#addLast: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addLast: 111]
		should:[:result | result = 111and: [(orderedCollection last) = 111]]
		conformTo: #OrderedCollection
		selector: #addLast:!

canonicalElement

	^self canonicalObject at: 2!

emptyCollection

	^self canonicalObject class new!

testXaddAllXafterX
	" <OrderedCollection>#addAll:after: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addAll: #(111 222) after: 5]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection addAll: #(333 444) after: 1]
		should: [:result | ((orderedCollection at: 2) = 333) and: [(orderedCollection at: 3) = 444]]
		conformTo: #OrderedCollection
		selector: #addAll:after:.
	self
		value: [orderedCollection addAll: #(555 666)  after: 4]
		should: [:result | ((orderedCollection at: orderedCollection size - 1) = 555) and: [(orderedCollection last) = 666]]
		conformTo: #OrderedCollection
		selector: #addAll:after:.
	self
		value: [orderedCollection addAll: #(777 888) after: 555]
		should: [:result | ((orderedCollection at: orderedCollection size - 2) = 777) and: [( orderedCollection at: orderedCollection size - 1) = 888]]
		conformTo: #OrderedCollection
		selector: #addAll:after:!

testXaddXafterX
	" <OrderedCollection>#add:after: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection add: 777 after: 5]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection add: 777 after: 1]
		should: [:result | (result = 777) and: [(orderedCollection at: 2) = 777]]
		conformTo: #OrderedCollection
		selector: #add:after:.
	self
		value: [orderedCollection add: 888 after: 4]
		should: [:result | (result = 888) and: [(orderedCollection last) = 888]]
		conformTo: #OrderedCollection
		selector: #add:after:.
	self
		value: [orderedCollection add: 999 after: 777]
		should: [:result | (result = 999) and: [(orderedCollection at: 3) = 999]]
		conformTo: #OrderedCollection
		selector: #add:after:!

testXaddAllXbeforeIndexX
	" <OrderedCollection>#addAll:beforeIndex: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection addAll: #(111 222) beforeIndex: 6]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection addAll: #(111 222) beforeIndex: 0]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection addAll: #(222 333) beforeIndex: 1]
		should: [:result | (orderedCollection first) = 222 and: [(orderedCollection at: 2) = 333] ]
		conformTo: #OrderedCollection
		selector: #addAll:beforeIndex:.
	self
		value: [orderedCollection addAll: #(444 555) beforeIndex: 4]
		should: [:result | (orderedCollection at: 4) = 444 and: [(orderedCollection at: 5) = 555] ]
		conformTo: #OrderedCollection
		selector: #addAll:beforeIndex:.!

testXaddXbeforeIndexX
	" <OrderedCollection>#add:beforeIndex: "
	| orderedCollection |
	#'Collection'.
	orderedCollection := self canonicalObject.
	self
		value: [orderedCollection add: 555 beforeIndex: 6]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection add: 666 beforeIndex: 0]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection add: 666 beforeIndex: -1]	
		shouldRaise: TestResult error.
	self
		value: [orderedCollection add: 777 beforeIndex: 1]
		should: [:result | (result = 777) and: [(orderedCollection first) = 777]]
		conformTo: #OrderedCollection
		selector: #add:beforeIndex:.
	self
		value: [orderedCollection add: 888 beforeIndex: 6]
		should: [:result | (result = 888) and: [(orderedCollection last) = 888]]
		conformTo: #OrderedCollection
		selector: #add:beforeIndex:.
	self
		value: [orderedCollection add: 999 beforeIndex: 2]
		should: [:result | (result = 999) and: [(orderedCollection at: 2) = 999]]
		conformTo: #OrderedCollection
		selector: #add:beforeIndex:! !

!OrderedCollectionANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: ExtensibleCollectionHelper.
	aBlock value: SequencedContractibleCollectionHelper.
	aBlock value: SequencedReadableCollectionHelper.
	aBlock value: SequencedCollectionHelper.! !

!ReadStreamFactoryANSITest methodsFor: nil!

protocol
	^#'ReadStream factory'!

canonicalObject
	^ReadStream!

testXonX

	self value: [self canonicalObject on: 'this is a string']
		should: [:r | r position = 0 & r contents = 'this is a string']
		conformTo: self protocol selector: #'on:'.! !

!IntervalFactoryANSITest methodsFor: nil!

testXfromXtoX
	" <Interval factory>#from:to: "
	#'Collection'.!

canonicalObject
	^Interval!

testXfromXtoXbyX
	" <Interval factory>#from:to:by: "
	#'Collection'.!

protocol
	^#'Interval factory'! !

!ZeroDivideFactoryANSITest methodsFor: nil!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXhandlesX
	" <exceptionSelector>#handles: "
	#'Exception'.!

protocol
	^#'ZeroDivide factory'!

testXdividendX
	" <ZeroDivide factory>#dividend: "
	| dividendTmp msgResult |
	#'Exception'.
	self value: [	[(msgResult := ZeroDivide dividend: 1) signal
				] on: ZeroDivide do: [ :aZeroDivide |
					dividendTmp := aZeroDivide dividend.
					aZeroDivide return: msgResult ] ]
		should: [:r | dividendTmp = 1]
		conformTo: #'ZeroDivide factory' selector: #'dividend:'.!

testXconcatenateOp
	" <exceptionSelector>#, "
	#'Exception'.!

testXsignal
	" <ZeroDivide factory>#signal "
	| msgResult |
	#'Exception'.
	self value: [	[msgResult := (ZeroDivide dividend: 1) signal
				] on: ZeroDivide do: [ :aZeroDivide |
					aZeroDivide return: msgResult ] ]
		should: [:r | true "unspecified"]
		conformTo: #'ZeroDivide factory' selector: #'signal'.!

canonicalObject
	^ZeroDivide!

testXnew
	" <exceptionInstantiator>#new "
	#'Exception'.! !

!DurationANSITest methodsFor: nil!

testXgreaterThanOrEqualToOp
	" <magnitude>#>= "
	#'Date and Time'.!

testXhours
	" <Duration>#hours "
	#'Date and Time'.
	self value: [off0123 hours] should: [:r | r = 1]
		conformTo: #'Duration' selector: #'hours'.
	self value: [(Duration days: 9 hours: 0 minutes: 2 seconds: 0) hours]
		should: [:r | r = 0]
		conformTo: #'Duration' selector: #'hours'.
	self value: [(Duration days: -9 hours: -1 minutes: -2 seconds: -3) hours]
		should: [:r | r = -1]
		conformTo: #'Duration' selector: #'hours'.!

testXminutes
	" <Duration>#minutes "
	#'Date and Time'.
	self value: [off0123 minutes] should: [:r | r = 2]
		conformTo: #'Duration' selector: #'minutes'.
	self value: [(Duration days: 9 hours: 0 minutes: 0 seconds: 0) minutes]
		should: [:r | r = 0]
		conformTo: #'Duration' selector: #'minutes'.
	self value: [(Duration days: -9 hours: -1 minutes: -2 seconds: -3) minutes]
		should: [:r | r = -2]
		conformTo: #'Duration' selector: #'minutes'.!

testXabs
	" <Duration>#abs "
	| absDuration rcvr |
	#'Date and Time'.
	absDuration := Duration days: 0 hours: 1 minutes: 2 seconds: 3.

	self value: [off0123 abs] should: [:r | r = absDuration]
		conformTo: #'Duration' selector: #'abs' opRECEIVER: off0123.

	rcvr := Duration days: 0 hours: -1 minutes: -2 seconds: -3.

	self value: [rcvr abs] should: [:r | r = absDuration]
		conformTo: #'Duration' selector: #'abs' opRECEIVER: rcvr.!

canonicalObject
	^Duration seconds: 500000000!

testXseconds
	" <Duration>#seconds "
	#'Date and Time'.
	self value: [off0123 seconds] should: [:r | r = 3]
		conformTo: #'Duration' selector: #'seconds'.
	self value: [(Duration days: 9 hours: 0 minutes: 0 seconds: 0) seconds]
		should: [:r | r = 0]
		conformTo: #'Duration' selector: #'seconds'.
	self value: [(Duration days: -9 hours: -1 minutes: -2 seconds: -3.5) seconds]
		should: [:r | r = -3.5]
		conformTo: #'Duration' selector: #'seconds'.!

testXaddOp
	" <Duration>#+ "
	#'Date and Time'.
	self value: [off0123 + (Duration days: 1 hours: 1 minutes: 1 seconds: 1)]
		should: [:r | r = (Duration days: 1 hours: 2 minutes: 3 seconds: 4)]
		conformTo: #'Duration' selector: #'+'!

testXmaxX
	" <magnitude>#max: "
	#'Date and Time'.!

testXsubtractOp
	" <Duration>#- "
	#'Date and Time'.
	self value: [off0123 - (Duration days: 1 hours: 1 minutes: 1 seconds: 1)]
		should: [:r | r = (Duration days:-0 hours:-23 minutes:-58 seconds:-58)]
		conformTo: #'Duration' selector: #'-'!

testXprintString
	" <Duration>#printString "
	#'Date and Time'.
	self value: [off0123 printString] should: [:r | r = '0:01:02:03']
		conformTo: #'Duration' selector: #'printString'.
	self value: [(Duration days: 0 hours: -1 minutes: -2 seconds: -3.5) printString]
		should: [:r | r = '-0:01:02:03.5']
		conformTo: #'Duration' selector: #'printString'.
	self value: [(Duration zero) printString] should: [:r | r = '0:00:00:00']
		conformTo: #'Duration' selector: #'printString'.!

testXasSeconds
	" <Duration>#asSeconds "
	#'Date and Time'.
	self value: [off0123 asSeconds] should: [:r | r = 3723]
		conformTo: #'Duration' selector: #'asSeconds'.!

setUp
	super setUp.
	off0123 := Duration days: 0 hours: 1 minutes: 2 seconds: 3.
	smallInt2 := 2.
	largeNegInt2000000000 := -2000000000.
	largePosInt2000000000 := 2000000000.
	float2 := 2.0d0.
	fractionHalf := 1/2.
	numList := Array new: 5.
	numList at: 1 put: smallInt2.
	numList at: 2 put: largeNegInt2000000000.
	numList at: 3 put: largePosInt2000000000.
	numList at: 4 put: float2.
	numList at: 5 put: fractionHalf.!

testXmultiplyOp
	" <Duration>#* "
	| retVals |
	#'Date and Time'.
	retVals := Array new: 5.		"#( 2 -2000000000 2000000000 2.0 1/2 )"
	retVals at: 1 put: (Duration days: 0 hours: 2 minutes: 4 seconds: 6).
	retVals at: 2 put: (Duration days: -86180555 hours: -13
								minutes: -20 seconds: 0).
	retVals at: 3 put: (Duration days: 86180555 hours: 13
								minutes:  20 seconds: 0).
	retVals at: 4 put: (Duration days: 0 hours: 2 minutes: 4 seconds: 6).
	retVals at: 5 put: (Duration days: 0 hours: 0 minutes: 31 seconds: 1.5).
	
	1 to: numList size do: [ :ndx |
		self value: [off0123 * (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'Duration' selector: #'*'
	].!

testXlessThanOp
	" <Duration>#< "
	#'Date and Time'.
	self value: [off0123
				< (Duration days: 1 hours: 1 minutes: 1 seconds: 1)]
		should: [:r | r]
		conformTo: #'Duration' selector: #'<'.

	self value: [off0123
				< (Duration days: 0 hours: 1 minutes: 2 seconds: 3)]
		shouldnt: [:r | r]
		conformTo: #'Duration' selector: #'<'.
	self value: [off0123 < 0] shouldRaise: Error.!

testXdivideOp
	" <Duration>#/ "
	| retVals |
	#'Date and Time'.
	retVals := Array new: 5.
	"If operand is a <number> answer a new <Duration>."
	"#( 2 -2000000000 2000000000 2.0 1/2 )"
	retVals at: 1 put: (Duration days: 0 hours: 0 minutes: 31 seconds: 1.5).
	retVals at: 2 put: (Duration days: -0 hours: 0
								minutes: 0 seconds: -3723/2000000000).
	retVals at: 3 put: (Duration days: 0 hours: 0
								minutes: 0 seconds: 3723/2000000000).
	retVals at: 4 put: (Duration days: 0 hours: 0 minutes: 31 seconds: 1.5).
	retVals at: 5 put: (Duration days: 0 hours: 2 minutes: 4 seconds: 6).
	
#'testAnom'. "??? <Object> float = test give false for  -0:00:00:01.8615e-6
	1 to: numList size do: [ :ndx |
		self value: [off0123 / (numList at: ndx)]
			should: [:r | (r isKindOf: Duration)
						and: [r = (retVals at: ndx)] ]
			conformTo: #'Duration' selector: #'/'
	].
???"
	"If operand is a <Duration> answer a <number>."
	"#( 2 -2000000000 2000000000 2.0 1/2 )"
	retVals at: 1 put: (3723/2).
	retVals at: 2 put: (-3723/2000000000).
	retVals at: 3 put: (3723/2000000000).
	retVals at: 4 put: 1861.5.
	retVals at: 5 put: 7446.0.
	1 to: numList size do: [ :ndx |
		self value: [off0123 / (Duration seconds: (numList at: ndx))]
			should: [:r | (r isKindOf: Number)
						and: [r = (retVals at: ndx)] ]
			conformTo: #'Duration' selector: #'/'
	].
	self value: [off0123 / 0] shouldRaise: ZeroDivide.
	self value: [off0123 / (Duration zero)] shouldRaise: ZeroDivide.!

testXgreaterThanOp
	" <Duration>#> "
	#'Date and Time'.
	self value: [(Duration days: 1 hours: 1 minutes: 1 seconds: 1)
				> off0123]
		should: [:r | r]
		conformTo: #'Duration' selector: #'>'.
	self value: [(Duration days: 0 hours: 1 minutes: 2 seconds: 3)
				> off0123]
		shouldnt: [:r | r]
		conformTo: #'Duration' selector: #'>'.
	self value: [off0123 > 0] shouldRaise: Error.!

testXpositive
	" <Duration>#positive "
	#'Date and Time'.
	self value: [off0123 positive] should: [:r | r]
		conformTo: #'Duration' selector: #'positive'.
	self value: [(Duration days: 0 hours: -1 minutes: -2 seconds: -3) positive]
		shouldnt: [:r | r]
		conformTo: #'Duration' selector: #'positive'.
	self value: [(Duration zero) positive] should: [:r | r]
		conformTo: #'Duration' selector: #'positive'.!

testXequalityOp
	" <Duration>#= "
	| tmpDuration |
	#'Date and Time'.
	tmpDuration := (Duration days: 0 hours: 1 minutes: 2 seconds: 3).
	self value: [off0123 = tmpDuration] should: [:r | r]
		conformTo: #'Duration' selector: #'='.
	self should: [off0123 hash = tmpDuration hash].
	tmpDuration := (Duration days: 1 hours: 1 minutes: 1 seconds: 1).
	self value: [off0123 = tmpDuration] shouldnt: [:r | r]
		conformTo: #'Duration' selector: #'='.
	self shouldnt: [off0123 hash = tmpDuration hash].!

testXdays
	" <Duration>#days "
	#'Date and Time'.
	self value: [off0123 days] should: [:r | r = 0]
		conformTo: #'Duration' selector: #'days'.
	self value: [(Duration days: 9 hours: 0 minutes: 2 seconds: 0) days]
		should: [:r | r = 9]
		conformTo: #'Duration' selector: #'days'.

	self value: [(Duration days: -9 hours: -1 minutes: -2 seconds: -3) days]
		should: [:r | r = -9]
		conformTo: #'Duration' selector: #'days'.!

protocol
	^#'Duration'!

testXnegative
	" <Duration>#negative "
	#'Date and Time'.
	self value: [off0123 negative] shouldnt: [:r | r]
		conformTo: #'Duration' selector: #'negative'.
	self value: [(Duration days: 0 hours: -1 minutes: -2 seconds: -3) negative]
		should: [:r | r]
		conformTo: #'Duration' selector: #'negative'.
	self value: [(Duration zero) negative] shouldnt: [:r | r]
		conformTo: #'Duration' selector: #'negative'.!

testXminX
	" <magnitude>#min: "
	#'Date and Time'.!

testXlessThanOrEqualToOp
	" <magnitude>#<= "
	#'Date and Time'.!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Date and Time'.!

testXnegated
	" <Duration>#negated "
	| negatedDuration rcvr |
	#'Date and Time'.
	negatedDuration := Duration days: 0 hours: -1 minutes: -2 seconds: -3.

	self value: [off0123 negated] should: [:r | r = negatedDuration]
		conformTo: #'Duration' selector: #'negated' opRECEIVER: off0123.

	self value: [negatedDuration negated] should: [:r | r = off0123]
		conformTo: #'Duration' selector: #'negated'
		opRECEIVER: negatedDuration.

	rcvr := Duration zero.

	self value: [rcvr negated] should: [:r | r = (Duration zero)]
		conformTo: #'Duration' selector: #'negated' opRECEIVER: rcvr.! !

!OrderedCollectionFactoryANSITest methodsFor: nil!

testXwithX

	" <OrderedCollection factory>#with: "
	#'Collection'.!

testXwithXwithX
	" <OrderedCollection factory>#with:with: "
	#'Collection'.!

testXnew
	" <OrderedCollection factory>#new "
	#'Collection'.!

protocol
	^#'OrderedCollection factory'!

testXnewX
	" <OrderedCollection factory>#new: "
	#'Collection'.!

testXwithAllX
	" <OrderedCollection factory>#withAll: "
	#'Collection'.!

canonicalObject
	^OrderedCollection!

testXwithXwithXwithX
	" <OrderedCollection factory>#with:with:with: "
	#'Collection'.!

testXwithXwithXwithXwithX
	" <OrderedCollection factory>#with:with:with:with: "
	#'Collection'.! !

!WarningClassANSITest methodsFor: nil!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXallSubclasses
	" <classDescription>#allSubclasses "
	#'Exception'.!

testXname
	" <classDescription>#name "
	#'Exception'.!

testXsuperclass
	" <classDescription>#superclass "
	#'Exception'.!

protocol
	^#'Warning class'!

testXconcatenateOp
	" <exceptionSelector>#, "
	#'Exception'.!

testXallSuperclasses
	" <classDescription>#allSuperclasses "
	#'Exception'.!

testXnew
	" <Warning class>#new "
	#'Exception'.
	self value: [Warning new] should: [:r | true "??? r = Warning signal ???"]
		conformTo: #'Warning class' selector: #'new'.!

testXsignal
	" <Exception class>#signal "
	#'Exception'.!

canonicalObject
	^Warning!

testXhandlesX
	" <Exception class>#handles: "
	#'Exception'.!

testXsubclasses
	" <classDescription>#subclasses "
	#'Exception'.! !

!SymbolANSITest methodsFor: nil!

testXkeysAndValuesDoX
	" <sequencedReadableCollection>#keysAndValuesDo: "
	#'Collection'.!

testXlessThanOp
	" <readableString>#< "
	#'Collection'.!

setUp
	super setUp.
	smalltalkSymbol := #'Smalltalk'.!

testXequalityOp
	" <sequencedReadableCollection>#= "
	#'Collection'.
"	The value of receiver = comparand is true if and only if the value of comparand = receiver would also be true. If the value of receiver = comparand is true then the receiver and comparand must have equivalent hash values.  Or more formally:

	receiver = comparand	=>
	receiver hash = comparand hash
Refinement: <sequenceReadableCollection>
Unless specifically refined, the receiver and operand are equivalent if all of the following are true:
1. The receiver and operand are instances of the same class.
2. They answer the same value for the #size message.
3. For all indices of the receiver, the element in the receiver at a given index is equivalent to the element in operand at the same index.
Element lookup is defined by the #at: message for the receiver and operand.
"
#todo. "??? add Refinement: test ???"
	self value: [smalltalkSymbol = smalltalkSymbol]
		should: [:r | r and: [smalltalkSymbol hash = smalltalkSymbol hash] ]
		conformTo: #'sequencedReadableCollection' selector: #'='.!

emptyCollection

	^#''!

protocol
	^#symbol!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Collection'.!

testXmaxX
	" <magnitude>#max: "
	#'Collection'.!

testXsubStringsX
	" <readableString>#subStrings: "
	#'Collection'.!

testXgreaterThanOrEqualToOp
	" <readableString>#>= "
	#'Collection'.!

testXasSymbol
	" <symbol>#asSymbol (Return Values: <RECEIVER>) "
	#'Collection'.!

testXasString
	" <symbol>#asString "
	#'Collection'.!

testXasLowercase
	" <readableString>#asLowercase "
	#'Collection'.!

returnTypeHasLimitedElementTypes

	^true!

testXidentityHash
	" <Object>#identityHash "
	#'Collection'.
	self value: [smalltalkSymbol identityHash]
		should: [:r | r = smalltalkSymbol identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [smalltalkSymbol identityHash]
		shouldnt: [:r | r = #'smalltalk' identityHash]
		conformTo: #'Object' selector: #'identityHash'.!

testXhash
	" <Object>#hash "
	#'Collection'.
"	Any two objects that are considered equivalent using the #= message must have the same hash value.  More formally:

	receiver = comparand	=>
	receiver hash = comparand hash
"
		#'Fundamental'.
	self shouldnt: [smalltalkSymbol = 'Smalltalk'].
	self shouldnt: [smalltalkSymbol hash = 'Smalltalk' hash].
	self value: [smalltalkSymbol hash]
		should: [:r | r = smalltalkSymbol hash]
		conformTo: #'Object' selector: #'hash'.
	self value: [smalltalkSymbol hash]
		shouldnt: [:r | r = #'smalltalk' hash]
		conformTo: #'Object' selector: #'hash'.!

testXidentityOp
	" <Object>#== "
	#'Collection'.
"	The value of receiver == comparand is true if and only if the value of comparand == receiver would also be true. If the value of receiver == comparand is true then the receiver and comparand must have equivalent identity hash values.  Or more formally:

	receiver == comparand =>
	receiver identityHash = comparand identityHash
"
	self value: [smalltalkSymbol == smalltalkSymbol]
		should: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [smalltalkSymbol == #'smalltalk']
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.!

testXsameAsX
	" <readableString>#sameAs: "
	#'Collection'.!

testXnotIdentityOp
	" <Object>#~~ "
	#'Collection'.
"	The value of receiver ~~ comparand is true if and only if the value of comparand ~~ receiver would also be true.
"
	self value: [smalltalkSymbol ~~ #'smalltalk'] should: [:r | r]
		conformTo: #'Object' selector: #'~~'.

	self value: [smalltalkSymbol ~~ smalltalkSymbol] shouldnt: [:r | r]
		conformTo: #'Object' selector: #'~~'.!

testXasUppercase
	" <readableString>#asUppercase "
	#'Collection'.!

testXlessThanOrEqualToOp
	" <readableString>#<= "
	#'Collection'.!

testXminX
	" <magnitude>#min: "
	#'Collection'.!

canonicalElement

	^self canonicalObject at: 2!

testXgreaterThanOp
	" <readableString>#> "
	#'Collection'.!

testXlast
	" <sequencedReadableCollection>#last "
	#'Collection'.!

testXisKindOfX
	" <Object>#isKindOf: "
	#'Collection'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
#todo. "Fix find a test for unspecified rule above ???"
	self value: [smalltalkSymbol isKindOf: Symbol]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Metaclass tests:"
	self value: [smalltalkSymbol class isKindOf: (Symbol class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Inherit tests:"
	self value: [smalltalkSymbol class isKindOf: (Object class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	self value: [smalltalkSymbol isKindOf: Number]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.!

limitedElementTypes

	^1!

testXcopy
	" <Object>#copy (Return Values: <RECEIVER>) "
	#'Collection'.

#todo. "??? add change-side-effect test ???"
	
"
If the receiver is an identity object, return the receiver.
"
	self value: [smalltalkSymbol copy]
		should: [:r | (r = smalltalkSymbol) & (r == smalltalkSymbol)]
		conformTo: #'Object' selector: #'copy' opRECEIVER: smalltalkSymbol.!

canonicalObject
	^#abcd!

testXnotEqualityOp
	" <Object>#~= "
	#'Collection'.
"	The value of receiver ~= comparand is true if and only if the value of
comparand ~= receiver would also be true.
"
	self value: [smalltalkSymbol ~= #'smalltalk']
		should: [:r | r] conformTo: #'Object' selector: #'~='.

	self value: [smalltalkSymbol ~= smalltalkSymbol]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'~='.!

testXisMemberOfX
	" <Object>#isMemberOf: "
	#'Collection'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
#todo. "Fix find a test for unspecified rule above ???"
	self value: [smalltalkSymbol isMemberOf: Symbol]
		should: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	"Metaclass tests:"
	self value: [smalltalkSymbol class isMemberOf: (Symbol class)]
		should: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	"Fail inherit tests:"
	self value: [smalltalkSymbol class isMemberOf: (Object class)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	self value: [smalltalkSymbol isMemberOf: Number]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.! !

!SymbolANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: SequencedReadableCollectionHelper! !

!ErrorClassANSITest methodsFor: nil!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXallSubclasses
	" <classDescription>#allSubclasses "
	#'Exception'.!

testXname
	" <classDescription>#name "
	#'Exception'.!

testXsuperclass
	" <classDescription>#superclass "
	#'Exception'.!

protocol
	^#'Error class'!

testXconcatenateOp
	" <exceptionSelector>#, "
	#'Exception'.!

testXallSuperclasses
	" <classDescription>#allSuperclasses "
	#'Exception'.!

testXnew
	" <Error class>#new "
	#'Exception'.
	self value: [Error new] should: [:r | true "??? r = Error signal ???"]
		conformTo: #'Error class' selector: #'new'.!

testXsignal
	" <Exception class>#signal "
	#'Exception'.!

canonicalObject
	^Error!

testXhandlesX
	" <Exception class>#handles: "
	#'Exception'.!

testXsubclasses
	" <classDescription>#subclasses "
	#'Exception'.! !

!BagFactoryANSITest methodsFor: nil!

testXwithX
	" <Bag factory>#with: "
	#'Collection'.!

testXwithXwithX
	" <Bag factory>#with:with: "
	#'Collection'.!

testXnew
	" <Bag factory>#new "
	#'Collection'.!

protocol
	^#'Bag factory'!

testXnewX
	" <Bag factory>#new: "
	#'Collection'.!

testXwithAllX
	" <Bag factory>#withAll: "
	#'Collection'.!

canonicalObject
	^Bag!

testXwithXwithXwithX
	" <Bag factory>#with:with:with: "
	#'Collection'.!

testXwithXwithXwithXwithX
	" <Bag factory>#with:with:with:with: "
	#'Collection'.! !

!SequencedCollectionHelper methodsFor: nil!

testXreplaceFromXtoXwithXstartingAtX
	" <sequencedCollection>#replaceFrom:to:with:startingAt: "
	| sequencedCollection putValue |
	#'Collection'.
	sequencedCollection := self object.
	putValue := (self object isKindOf: ByteArray)
		ifTrue: [#(9 8 7)]
		ifFalse: [#($c $b $a)].
	self
		value: [sequencedCollection replaceFrom: 1 to: 2 with: putValue startingAt: 2]
		should: 
			[:result | 
			((sequencedCollection at: 1) = (putValue at: 2))
			& ((sequencedCollection at: 2) = (putValue at: 3))]
		conformTo: #sequencedCollection
		selector: #replaceFrom:to:with:startingAt:.
	self
		should: 
			[sequencedCollection 
				replaceFrom: 0 
				to: 1 
				with: putValue 
				startingAt: 2]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom: sequencedCollection size + 1 
				to: 1 
				with: putValue 
				startingAt: 2]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom: 1 
				to: sequencedCollection size + 1 
				with: putValue
				startingAt: 2]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom:1
				to: 2
				with: #(1 2 3 5)
				startingAt: 4]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom:1
				to: 3
				with: #(1 2)
				startingAt: 0]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom:1
				to: 3
				with: #(1 2)
				startingAt: 3]
		raise: TestResult error!

object: anObject!

object
	^testCase canonicalObject copy!

testXatAllPutX
	" <sequencedCollection>#atAllPut: "
	| sequencedCollection putValue |
	#'Collection'.
	sequencedCollection := self object.
	putValue := (self object isKindOf: ByteArray)
		ifTrue: [9]
		ifFalse: [$a].
	self
		value: [sequencedCollection atAllPut: putValue]
		should: 
			[:result | 
			(sequencedCollection
				detect: [:each | each ~= putValue ]
				ifNone: [nil]) isNil]
		conformTo: #sequencedCollection
		selector: #atAllPut:.
	testCase conformanceOfPutElementOnXatAllPutX: 'ABC'.!

testXatAllXputX
	" <sequencedCollection>#atAll:put: "
	| putValue indices sequencedCollection |
	#'Collection'.
	sequencedCollection := self object.
	indices := #(1 2 3).
	putValue := (self object isKindOf: ByteArray)
		ifTrue: [9]
		ifFalse: [$a].
	self
		value: 
			[sequencedCollection 
				atAll: indices 
				put: putValue]
		should: [:result | 
			(indices 
				detect: [:each | (sequencedCollection at: each) ~= putValue]
				ifNone: [nil]) isNil]
		conformTo: #sequencedCollection
		selector: #atAll:put:.
	testCase conformanceOfPutElementOnXatAllXputX: 'ABC'.
	self
		should: 
			[sequencedCollection 
				atAll: #($a #bee 'See') 
				put: putValue]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				atAll:#(0 1) 
				put: putValue]
		raise: TestResult error.
	self 
		should: 
			[sequencedCollection 
				atAll: (Array 
					with: 1 
					with: sequencedCollection size + 1)
				put: putValue]
		raise: TestResult error!

testXreplaceFromXtoXwithX
	" <sequencedCollection>#replaceFrom:to:with: "
	| sequencedCollection putValue |
	#'Collection'.
	sequencedCollection := self object.
	putValue := (self object isKindOf: ByteArray)
		ifTrue: [#(9 8)]
		ifFalse: [#($b $a)].
	self
		value: [sequencedCollection replaceFrom: 2 to: 3 with: putValue]
		should: 
			[:result | 
			((sequencedCollection at: 2) = (putValue at: 1))
			& ((sequencedCollection at: 3) = (putValue at: 2))]
		conformTo: #sequencedCollection
		selector: #replaceFrom:to:with:.
	self
		should: 
			[sequencedCollection 
				replaceFrom: 0 
				to: 1 
				with: putValue]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom: sequencedCollection size + 1 
				to: 1 
				with: putValue]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom: 1 
				to: 0 
				with: putValue]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom: 1 
				to: sequencedCollection size + 1 
				with: putValue]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom:1
				to: 2
				with: #(1 2 3 5)]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom:1
				to: 3
				with: #(1)]
		raise: TestResult error!

testXatXputX
	" <sequencedCollection>#at:put: "
	| sequencedCollection putValue |
	#'Collection'.
	sequencedCollection := self object.
	putValue := (self object isKindOf: ByteArray)
		ifTrue: [9]
		ifFalse: [$a].
	self 
		value: 
			[sequencedCollection 
				at: 1 
				put: putValue]
		should: [:result | (result = putValue) & ((sequencedCollection at: 1) = putValue)]
		conformTo: #sequencedCollection
		selector: #at:put:.
	testCase conformanceOfPutElementOnXatXputX: 'ABC'.
	self 
		should: 
			[sequencedCollection 
				at: -1 
				put: putValue]
		raise: TestResult error.
	self 
		should: 
			[sequencedCollection 
				at: sequencedCollection size + 1
				put: putValue]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				at: 0
				put: putValue]
		raise: TestResult error.!

testXreplaceFromXtoXwithObjectX
	" <sequencedCollection>#replaceFrom:to:withObject: "
	| sequencedCollection putValue |
	#'Collection'.
	sequencedCollection := self object.
	putValue := (self object isKindOf: ByteArray)
		ifTrue: [9]
		ifFalse: [$a].
	self
		value: 
			[sequencedCollection 
				replaceFrom: 2 
				to: 3 
				withObject: putValue]
		should: 
			[:result | 
			((sequencedCollection at: 2) = putValue)
			& ((sequencedCollection at: 3) = putValue)]
		conformTo: #sequencedCollection
		selector: #replaceFrom:to:withObject:.
	self
		should: 
			[sequencedCollection 
				replaceFrom: 0 
				to: 1 
				withObject: putValue]
		raise: TestResult error.
	self
		should: 
			[sequencedCollection 
				replaceFrom: sequencedCollection size + 1 
				to: 1 
				withObject: putValue]
		raise: TestResult error.
	"self
		should: 
			[sequencedCollection 
				replaceFrom: 1 
				to: -1
				withObject: putValue]
		raise: TestResult error."
	self
		should: 
			[sequencedCollection 
				replaceFrom: 1 
				to: sequencedCollection size + 1 
				withObject: putValue]
		raise: TestResult error! !

!SequencedStreamTest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: SequencedStreamHelper! !

!MessageNotUnderstoodANSITest methodsFor: nil!

testXresignalAsX
	" <signaledException>#resignalAs: "
	#'Exception'.!

testXretryUsingX
	" <signaledException>#retryUsing: "
	#'Exception'.!

testXmessageText
	" <exceptionDescription>#messageText "
	#'Exception'.!

testXresume
	" <signaledException>#resume "
	#'Exception'.!

testXreturn
	" <signaledException>#return "
	#'Exception'.!

testXmessage
	" <MessageNotUnderstood>#message "
	#'Exception'.
	self value: [ [ 1 bob ] on: MessageNotUnderstood do: [ :mnu |
					mnu return: mnu message ] ]
		should: [:r | (r selector = #'bob') & (r arguments = Array new)]
		conformTo: #'MessageNotUnderstood' selector: #'message'.

	self value: [ [ 1 bob: 2 ] on: MessageNotUnderstood do: [ :mnu |
					mnu return: mnu message ] ]
		should: [:r | (r selector = #'bob:') & (r arguments = #( 2 ))]
		conformTo: #'MessageNotUnderstood' selector: #'message'.!

testXresumeX
	" <signaledException>#resume: "
	#'Exception'.!

testXreceiver
	" <MessageNotUnderstood>#receiver "
	#'Exception'.
	self value: [ [ 1 bob ] on: MessageNotUnderstood do: [ :mnu |
					mnu return: mnu receiver ] ]
		should: [:r | r = 1]
		conformTo: #'MessageNotUnderstood' selector: #'receiver'.!

testXreturnX
	" <signaledException>#return: "
	#'Exception'.!

protocol
	^#MessageNotUnderstood!

testXsignal
	" <exceptionSignaler>#signal "
	#'Exception'.!

testXdescription
	" <exceptionDescription>#description "
	#'Exception'.!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXtag
	" <exceptionDescription>#tag "
	#'Exception'.!

testXmessageTextX
	" <exceptionBuilder>#messageText: (Return Values: <RECEIVER>) "
	#'Exception'.!

testXouter
	" <signaledException>#outer "
	#'Exception'.!

testXpass
	" <signaledException>#pass "
	#'Exception'.!

testXretry
	" <signaledException>#retry "
	#'Exception'.!

testXisResumable
	" <MessageNotUnderstood>#isResumable "
	#'Exception'.
	self value: [	[ MessageNotUnderstood signal
				] on: MessageNotUnderstood do: [ :mnu |
					mnu return: mnu isResumable ] ]
		should: [:r | r]
		conformTo: #'MessageNotUnderstood' selector: #'isResumable'.!

testXisNested
	" <signaledException>#isNested "
	#'Exception'.!

canonicalObject
	^MessageNotUnderstood new!

testXdefaultAction
	" <Error>#defaultAction "
	#'Exception'.! !

!TranscriptANSITest methodsFor: nil!

protocol
	^#'Transcript'!

canonicalObject
	^Transcript! !

!TranscriptANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: PuttableStreamHelper! !

!SetANSITest methodsFor: nil!

testXaddAllX
	" <Set>#addAll: "
	| co oldSize |
	co := self canonicalObject.
	oldSize := co size.
	self
		value: [co addAll: co copy]
		should: [:r | co size = oldSize]
		conformTo: #Set
		selector: #addAll:!

canonicalElement

	^2!

testXaddX
	" <Set>#add: "
	| co oldSize |
	co := self canonicalObject.
	oldSize := co size.
	self
		value: [co add: co any]
		should: [:r | co size = oldSize]
		conformTo: #Set
		selector: #add:!

protocol
	^#Set!

canonicalObject
	^Set with: 1 with: 2 with: 3 with: 4!

emptyCollection

	^self canonicalObject class new! !

!SetANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: ExtensibleCollectionHelper.! !

!ZeroDivideANSITest methodsFor: nil!

testXresignalAsX
	" <signaledException>#resignalAs: "
	#'Exception'.!

testXretryUsingX
	" <signaledException>#retryUsing: "
	#'Exception'.!

testXmessageText
	" <exceptionDescription>#messageText "
	#'Exception'.!

testXresume
	" <signaledException>#resume "
	#'Exception'.!

testXreturn
	" <signaledException>#return "
	#'Exception'.!

testXresumeX
	" <signaledException>#resume: "
	#'Exception'.!

testXreturnX
	" <signaledException>#return: "
	#'Exception'.!

protocol
	^#ZeroDivide!

testXsignal
	" <exceptionSignaler>#signal "
	#'Exception'.!

testXdividend
	" <ZeroDivide>#dividend "
	#'Exception'.
	self value: [	[(ZeroDivide dividend: 1) signal
				] on: ZeroDivide do: [ :aZeroDivide |
					aZeroDivide return: (aZeroDivide dividend) ] ]
		should: [:r | r = 1] conformTo: #'ZeroDivide' selector: #'dividend'.!

testXdescription
	" <exceptionDescription>#description "
	#'Exception'.!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXtag
	" <exceptionDescription>#tag "
	#'Exception'.!

testXmessageTextX
	" <exceptionBuilder>#messageText: (Return Values: <RECEIVER>) "
	#'Exception'.!

testXouter
	" <signaledException>#outer "
	#'Exception'.!

testXpass
	" <signaledException>#pass "
	#'Exception'.!

testXretry
	" <signaledException>#retry "
	#'Exception'.!

testXisResumable
	" <ZeroDivide>#isResumable "
	#'Exception'.
	self value: [	[(ZeroDivide dividend: 1) signal
				] on: ZeroDivide do: [ :aZeroDivide |
					aZeroDivide return: aZeroDivide isResumable ] ]
		should: [:r | r] conformTo: #'ZeroDivide' selector: #'isResumable'.!

testXisNested
	" <signaledException>#isNested "
	#'Exception'.!

canonicalObject
	^ZeroDivide new!

testXdefaultAction
	" <Error>#defaultAction "
	#'Exception'.! !

!CharacterANSITest methodsFor: nil!

testXisAlphaNumeric
	" <Character>#isAlphaNumeric "
	#'Fundamental'.
"	Return true if the receiver is either a letter or digit.  Otherwise return false.  In other words character isAlphaNumeric is true if and only if either character isLetter is true or character isDigit is true.
"
	self value: [$A isAlphaNumeric] should: [:r | r & ($A isLetter | $A isDigit)]
		conformTo: #'Character' selector: #'isAlphaNumeric'.
	self value: [$B isAlphaNumeric] should: [:r | r & ($B isLetter | $B isDigit)]
		conformTo: #'Character' selector: #'isAlphaNumeric'.
	self value: [$a isAlphaNumeric] should: [:r | r & ($a isLetter | $a isDigit)]
		conformTo: #'Character' selector: #'isAlphaNumeric'.
	self value: [$1 isAlphaNumeric] should: [:r | r & ($1 isLetter | $1 isDigit)]
		conformTo: #'Character' selector: #'isAlphaNumeric'.

	self value: [$: isAlphaNumeric] shouldnt: [:r | r & ($: isLetter | $: isDigit)]
		conformTo: #'Character' selector: #'isAlphaNumeric'.!

testXasString
	" <Character>#asString "
	#'Fundamental'.
	self selector: #'asString' inProtocol: #'Character' 
		behavesLike: #( #($A 'A') #($B 'B') #($a 'a') #($1 '1') #($: ':') )!

testXasLowercase
	" <Character>#asLowercase "
	#'Fundamental'.
"	If the receiver is equal to the value of a character literal in the receiver row of the following table, the result object must be equal to the value of the corresponding character literal in the result row.

	receiver	$A - $Z
	result		$a - $z

	An implemention may define other #asLowercase mappings.  If the receiver does not correspond to a character in the receiver row of the table and does not have an implementation defined mapping the receiver is returned as the result.
"
	self selector: #'asLowercase' inProtocol: #'Character' 
		behavesLike: #( #($A $a) #($b $b) #($1 $1) #($: $:) )!

testXisLetter
	" <Character>#isLetter "
	| alphaChars |
	#'Fundamental'.
	alphaChars := #( $A $B $C $D $E $F $G $H $I $J $K $L $M
					$N $O $P $Q $R $S $T $U $V $W $X $Y $Z
					$a $b $c $d $e $f $g $h $i $j $k $l $m
					$n $o $p $q $r $s $t $u $v $w $x $y $z ).

	self value: [$A isLetter] should: [:r | r & (alphaChars includes: $A)]
		conformTo: #'Character' selector: #'isLetter'.
	self value: [$B isLetter] should: [:r | r & (alphaChars includes: $B)]
		conformTo: #'Character' selector: #'isLetter'.
	self value: [$a isLetter] should: [:r | r & (alphaChars includes: $a)]
		conformTo: #'Character' selector: #'isLetter'.

	self value: [$1 isLetter] shouldnt: [:r | r & (alphaChars includes: $1)]
		conformTo: #'Character' selector: #'isLetter'.
	self value: [$: isLetter] shouldnt: [:r | r & (alphaChars includes: $:)]
		conformTo: #'Character' selector: #'isLetter'.!

testXasUppercase
	" <Character>#asUppercase "
	#'Fundamental'.
"	If the receiver is equal to the value of a character literal in the receiver row of the following table, the result object must be equal to the value of the corresponding character literal in the result row.

	receiver	$a - $z
	result		$A - $Z

	An implemention may define other #asUppercase mappings.  If the receiver does not correspond to a character in the receiver row of the table and does not have an implementation defined mapping the receiver is returned as the result.
"
	self selector: #'asUppercase' inProtocol: #'Character' 
		behavesLike: #( #($a $A) #($B $B) #($1 $1) #($: $:) )!

testXisUppercase
	" <Character>#isUppercase "
	| upperChars |
	#'Fundamental'.
	upperChars := #( $A $B $C $D $E $F $G $H $I $J $K $L $M
					$N $O $P $Q $R $S $T $U $V $W $X $Y $Z ).

	self value: [$A isUppercase]
		should: [:r | r & (upperChars includes: $A)]
		conformTo: #'Character' selector: #'isUppercase'.
	self value: [$B isUppercase]
		should: [:r | r & (upperChars includes: $B)]
		conformTo: #'Character' selector: #'isUppercase'.

	self value: [$a isUppercase]
		shouldnt: [:r | r & (upperChars includes: $a)]
		conformTo: #'Character' selector: #'isUppercase'.
	self value: [$1 isUppercase]
		shouldnt: [:r | r & (upperChars includes: $1)]
		conformTo: #'Character' selector: #'isUppercase'.
	self value: [$: isUppercase]
		shouldnt: [:r | r & (upperChars includes: $:)]
		conformTo: #'Character' selector: #'isUppercase'.!

protocol
^#Character!

testXcodePoint
	" <Character>#codePoint "
	#'Fundamental'.
"	The following invariant must hold:

	(charFactory codePoint: x) codePoint = x

where charFactory is an object that implements <Character factory> and x is an <integer>.
"
	self value: [$a codePoint]
		should: [:r | (Character codePoint: r) codePoint = r]
		conformTo: #'Character' selector: #'codePoint'.!

canonicalObject
	^ Character space!

testXisDigit
	" <Character>#isDigit "
	#'Fundamental'.

	self 
		selector: #isDigit 
		inProtocol: #Character 
		behavesLike: #(#($1 true) #($A false) #($B false) #($b false) #($: false)).!

testXisLowercase
	" <Character>#isLowercase "
	| lowerChars |
	#'Fundamental'.
	lowerChars := #( $a $b $c $d $e $f $g $h $i $j $k $l $m
					$n $o $p $q $r $s $t $u $v $w $x $y $z ).

	self value: [$a isLowercase]
		should: [:r | r & (lowerChars includes: $a)]
		conformTo: #'Character' selector: #'isLowercase'.

	self value: [$A isLowercase]
		shouldnt: [:r | r & (lowerChars includes: $A)]
		conformTo: #'Character' selector: #'isLowercase'.
	self value: [$B isLowercase]
		shouldnt: [:r | r & (lowerChars includes: $B)]
		conformTo: #'Character' selector: #'isLowercase'.
	self value: [$1 isLowercase]
		shouldnt: [:r | r & (lowerChars includes: $1)]
		conformTo: #'Character' selector: #'isLowercase'.
	self value: [$: isLowercase]
		shouldnt: [:r | r & (lowerChars includes: $:)]
		conformTo: #'Character' selector: #'isLowercase'.! !

!NotificationANSITest methodsFor: nil!

testXresignalAsX
	" <signaledException>#resignalAs: "
	#'Exception'.!

testXretryUsingX
	" <signaledException>#retryUsing: "
	#'Exception'.!

testXmessageText
	" <exceptionDescription>#messageText "
	#'Exception'.!

testXresume
	" <signaledException>#resume "
	#'Exception'.!

testXreturn
	" <signaledException>#return "
	#'Exception'.!

testXresumeX
	" <signaledException>#resume: "
	#'Exception'.!

testXreturnX
	" <signaledException>#return: "
	#'Exception'.!

protocol
	^#Notification!

testXsignal
	" <exceptionSignaler>#signal "
	#'Exception'.!

testXdescription
	" <exceptionDescription>#description "
	#'Exception'.!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.!

testXtag
	" <exceptionDescription>#tag "
	#'Exception'.!

testXmessageTextX
	" <exceptionBuilder>#messageText: (Return Values: <RECEIVER>) "
	#'Exception'.!

testXouter
	" <signaledException>#outer "
	#'Exception'.!

testXpass
	" <signaledException>#pass "
	#'Exception'.!

testXretry
	" <signaledException>#retry "
	#'Exception'.!

testXisResumable
	" <Notification>#isResumable "
	#'Exception'.
	self value: [ [ Notification signal ] on: Notification do: [ :aNotification |
					aNotification return: aNotification isResumable ] ]
		should: [:r | r]
		conformTo: #'Notification' selector: #'isResumable'.!

testXisNested
	" <signaledException>#isNested "
	#'Exception'.!

canonicalObject
	^Notification new!

testXdefaultAction
	" <Notification>#defaultAction "
	#'Exception'.
	self value: [Notification signal] should: [:r | r = nil]
		conformTo: #'Notification' selector: #'defaultAction'.! !

!ScaledDecimalANSITest methodsFor: nil!

testXmultiplyOp
	" <number>#* (returnRule - :receiver :operand) "
	| retVals tmpRec tmpResult |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(4.0s3 -4000000000.0s3 4000000000.0s3 4.0 1 4.0s3).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 * (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'*'
			ruleReceiver: sclDec2s3 operand: (numList at: ndx)
	].

	"If the return value conforms to <scaledDecimal> then the scale of the result is at least the scale of the receiver after conversion if necessary."
	tmpRec := 26.5s2.
	tmpResult := tmpRec * 5.0s1.
	self should: [tmpResult = 132.50s2 & (tmpResult scale >= tmpRec scale)].

	tmpRec := 26.5s2.
	tmpResult := tmpRec * 5.0s4.
	self should: [tmpResult = 132.5000s4 & (tmpResult scale >= tmpRec scale)].

	tmpRec := -26.5s2.
	tmpResult := tmpRec * 5.0s4.
	self should: [tmpResult = -132.5000s4 & (tmpResult scale >= tmpRec scale)].!

testXremX
	" <number>#rem: "
	| num2 sd retVals ndx |
	#'Numeric'.
	"Within the limits of representation, the following invariant should hold:
		(receiver quo: operand)*operand + (receiver rem: operand) = receiver"
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	sd := 26.5s03.
	numList := #( 5 5.0 5.0s3 ).
	retVals := #( 1.500s3 1.5 1.500s3 ).
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self value: [sd rem: num]
			should: [ :r | r = (retVals at: ndx)
					& ((sd quo: num) * num + (sd rem: num) = sd)]
			conformTo: #'number' selector: #'rem:'
	].

	numList := numList collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self value: [sd rem: num]
			should: [ :r | r = (retVals at: ndx)
					& ((sd quo: num) * num + (sd rem: num) = sd)]
			conformTo: #'number' selector: #'rem:'
	].

	sd := -26.5s3.
	numList := #( 5 5.0 5.0s3 ).
	retVals := retVals collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self should: [(sd rem: num) = (retVals at: ndx)
				& ((sd quo: num) * num + (sd rem: num) = sd)]
	].

	numList := numList collect: [ :num | num negated ].
	ndx := 0.
	numList do: [ :num |
		ndx := ndx + 1.
		self should: [(sd rem: num) = (retVals at: ndx)
					& ((sd quo: num) * num + (sd rem: num) = sd)]
	].

	sd := 26.5s3.
	num2 := (5/2).
	self value: [sd rem: num2]
		should: [:r | r = 1.5s3
				& ((sd quo: num2) * num2 + (sd rem: num2) = sd)]
		conformTo: #'number' selector: #'rem:'.

	numList := #( -2000000000 2000000000 ).
	sd :=  10000000001.5s3.
	numList do: [ :num |
		self value: [sd rem: num]
			should: [:r | r = 1.5s3
					& ((sd quo: num) * num + (sd rem: num) = sd)]
			conformTo: #'number' selector: #'rem:'
	].

	"If either the receiver or operand are of type <Float> and the operand has a value of zero, the result is implementation defined.  The implementation may signal the ZeroDivide exception or provide a continuation value "
	self value: [sclDec2s3 rem: 0.0] shouldRaise: ZeroDivide.
	self value: [sclDec2s3 rem: 0] shouldRaise: ZeroDivide.
	self value: [sclDec2s3 rem: 0.0s3] shouldRaise: ZeroDivide.!

testXgreaterThanOrEqualToOp
	" <magnitude>#>= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	self value: [5.1s1 >= 5.1s2] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [-5.1s1 >= -5.9s2] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.

	"Small >= Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3s3 >= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [-2000000005.0s3 >= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [0.25s3 >= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.

	"Num >= Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) >= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'>='
	].

	"Big >= Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0s3 >= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [9000000000s3 >= 2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [-1000000005.0s3 >= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [9.0s3 >= (1/2)] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.!

testXasFloatQ
	" <number>#asFloatQ "
	#'Numeric'.
	self value: [2.0s3 asFloatQ] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [-2.0s3 asFloatQ] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [0.0s3 asFloatQ] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatQ'.!

protocol
	^#'scaledDecimal'!

testXasFloat
	" <number>#asFloat "
	#'Numeric'.
	self value: [2.0s3 asFloat] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [-2.0s3 asFloat] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [0.0s3 asFloat] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloat'.!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver  and min or max are not comparable"

	self value: [2.0s3 between: 1 and: 3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [-2000000002.0s3 between: -2000000003 and: -2000000001]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2000000002.0s3 between: 2000000001 and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0s3 between: 1.0 and: 3.0]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0s3 between: (3/2) and: (5/2)]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0s3 between: 1.0s3 and: 3.0s3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	self value: [2.0s3 between: (3/2) and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0s3 between: -2000000001 and: 3.0]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"Num between: Num and: Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx)
					between: (numList at: ndx)
					and: (numList at: ndx)]
			should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'
	].

	self value: [2.0s3 between: 3 and: 4]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [-2000000000.0s3 between: -2000000003 and: -2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2000000000.0s3 between: 2000000003 and: 2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0s3 between: 3.0 and: 5.0]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0s3 between: (5/2) and: (7/2)]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0s3 between: 3.0s3 and: 5.0s3]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"??? min not min but max and vice versa -> false ???"
	self value: [2.0s3 between: 3 and: 1]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.!

testXpositive
	" <number>#positive "
	#'Numeric'.
	self value: [2.0s3 positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [0.0s3 positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [-2.0s3 positive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'positive'.!

testXreciprocal
	" <number>#reciprocal (returnRule - :receiver) "
	#'Numeric'.
	self value: [sclDec2s3 reciprocal] should: [:r | r = (1.0s2/sclDec2s3)]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: sclDec2s3.

	self value: [sclDec2s3 negated reciprocal]
		should: [:r | r = (1.0s2/(sclDec2s3 negated))]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: (sclDec2s3 negated).

	"Signal a ZeroDivide exception if the receiver is equal to zero."
	self value: [0.0s2 reciprocal] shouldRaise: ZeroDivide.!

testXtruncateToX
	" <number>#truncateTo: (returnRule - :receiver :operand) "
	| retVals save |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(2.000s3 0.000s3 0.000s3 2.0 2 2.000s3).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 truncateTo: (numList at: ndx)]
			should: [:r | (save := r) = (retVals at: ndx)]
			conformTo: #'number' selector: #'truncateTo:'
			ruleReceiver: sclDec2s3 operand: (numList at: ndx)
	].

	self should: [((0 truncateTo: sclDec2s3) = 0s3) & (save scale = 3)].!

testXnegated
	" <number>#negated (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 2.0s3.
	self value: [rcvr negated] should: [:r | r = -2.0s3]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.

	rcvr := -2.0s3.
	self value: [rcvr negated] should: [:r | r = 2.0s3]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.

	rcvr := 0.0s3.
	self value: [rcvr negated] should: [:r | r = 0s3]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.!

testXcopy
	" <Object>#copy (Return Values: <RECEIVER>) "
	#'Numeric'.
"	Return a new object that must be as similar as possible to the receiver in its initial state and behavior.  Any operation that changes the state of the new object should not as a side-effect change the state or behavior of the receiver.  Similarly, any change to the receiver should not as a side-effect change the new object.
	If the receiver is an identity object, return the receiver.
"
#todo. "??? add change-side-effect test ???"
	self value: [sclDec2s3 copy] should: [:r | (r = sclDec2s3) ]
		conformTo: #'Object' selector: #'copy' opRECEIVER: sclDec2s3.!

testXintegerPart
	" <number>#integerPart (returnRule - :receiver) "
	| rcvr |
	#'Numeric'.
	rcvr := 2.5s3.
	self value: [rcvr integerPart] should: [:result | result = 2.0s3]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := 2.0s3.
	self value: [rcvr integerPart] should: [:r | r = 2.0s3]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := -2.0s3.
	self value: [rcvr integerPart] should: [:result | result = -2.0s3]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := 0.0s3.
	self value: [rcvr integerPart] should: [:result | result = 0s3]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.!

testXraisedToX
	" <number>#raisedTo: "
	| numVals retVals |
	#'Numeric'.
	numVals := #(2 2.0 0 2.0s3 ) copy.
	numVals at: 3 put: (1/2).
	retVals := #(4.000s3 4.0 1.414213562373095 4.0 ) copy.
	1 to: numVals size do: [ :ndx |
		self value: [sclDec2s3 raisedTo: (numVals at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'.
	].

	retVals := #(0.250s3 0.25 0.7071067811865475 0.25 ) copy.
	1 to: numVals size do: [ :ndx |
		self value: [sclDec2s3 raisedTo: ((numVals at: ndx) negated)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'
	].

	self value: [sclDec2s3 raisedTo: 0.0s2] should: [:r | r = 1.0s2]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [0.0s2 raisedTo: sclDec2s3] should: [:r | r = 0.0s2]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [sclDec2s3 raisedTo: 1.0s2] should: [:r | r = sclDec2s3]
		conformTo: #'number' selector: #'raisedTo:'.

	"It is erroneous if the receiver equals zero
		and the operand is less than or equal to zero,"
	self value: [0.0s2 raisedTo: -2.0s2] shouldRaise: Error.

	"	or if the receiver is less than zero."
	self value: [sclDec2s3 negated raisedTo: 2.0s2]
		shouldRaise: Error.!

testXasScaledDecimalX
	"2000/06/23 Harmon, R. Changed to fix illegal fixed point literals."

	self value: [2.0s3 asScaledDecimal: 3]
		should: [:r | r = 2.0s3 & (r scale = 3)]
		conformTo: #'number' selector: #'asScaledDecimal:'.
	self value: [-2.0s3 asScaledDecimal: 2]
		should: [:r | r = -2.0s2 & (r scale = 2)]
		conformTo: #'number' selector: #'asScaledDecimal:'.
	self value: [0.0s3 asScaledDecimal: 0]
		should: [:r | r = 0.0s1 & (r scale = 0)]
		conformTo: #'number' selector: #'asScaledDecimal:'.!

testXtoX
	" <number>#to: "
	| start middleNdx stop2 |
	#'Numeric'.
	start := 1.0s3.
	numList := #( 2 2.0 0 2.0s3 ) copy.
	numList at: 3 put: (5/2).
	numList do: [ :stop |
		self value: [start to: stop]
			should: [:r | (r size = 2)
					". . . the last element in the sequence . . . is . . .[:]
						receiver + ((stop - receiver) // 1)"
					& (r last = (start + ((stop - start) // 1)))
					"The elements conform to the receiver's protocol."
					& (r allSatisfy: [ :elem |
						elem class conformsToProtocolNamed: #'scaledDecimal'])
			]
			conformTo: #'number' selector: #'to:'
	].

	stop2 := 2000000000s3.
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'scaledDecimal'])
		]
		conformTo: #'number' selector: #'to:'.

	start := -2000000000.0s3.
	stop2 := -1s3.
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'scaledDecimal'])
		]
		conformTo: #'number' selector: #'to:'.

	"The interval answered will be empty if the receiver is greater than stop."
	self value: [1.0s3 to: -1.0s3]
		should: [:r | (r isEmpty)] conformTo: #'number' selector: #'to:'!

testXtoXbyXdoX
	" <number>#to:by:do: "
	#'Numeric'.!

testXceiling
	" <number>#ceiling "
	#'Numeric'.
	self value: [2.0s3 ceiling] should: [:r | r = 2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [2.1s3 ceiling] should: [:r | r = 3]
		conformTo: #'number' selector: #'ceiling'.
	self value: [2.5s3 ceiling] should: [:r | r = 3]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2.0s3 ceiling] should: [:r | r = -2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2.1s3 ceiling] should: [:r | r = -2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2.5s3 ceiling] should: [:r | r = -2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [0.0s3 ceiling] should: [:r | r = 0]
		conformTo: #'number' selector: #'ceiling'.!

testXasFraction
	"2000/06/23 Harmon, R. Changed to fix illegal fixed point literals."

	self value: [2.0s3 asFraction] should: [:r | r = 2]
		conformTo: #'number' selector: #'asFraction'.
	self value: [-2.5s3 asFraction] should: [:r | r = (-5/2)]
		conformTo: #'number' selector: #'asFraction'.
	self value: [0.0s3 asFraction] should: [:r | r = 0]
		conformTo: #'number' selector: #'asFraction'.

	"Scale less than required to represent value:"
	self value: [0.25s2 asFraction] should: [:r | r = (1/4)]
		conformTo: #'number' selector: #'asFraction'.!

testXlessThanOrEqualToOp
	" <magnitude>#<= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	self value: [5.1s1 <= 5.1s2] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.

	"Small <= Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3s3 <= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [-2000000005.0s3 <= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [0.25s3 <= (1/2)] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.

	"Num <= Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) <= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'<='
	].

	"Big <= Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0s3 <= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [9000000000s3 <= 2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [-1000000005.0s3 <= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [9.0s3 <= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.!

testXsign
	" <number>#sign "
	#'Numeric'.
	self value: [2.0s3 sign] should: [:r | r = 1]
		conformTo: #'number' selector: #'sign'.
	self value: [0.0s3 sign] should: [:r | r = 0]
		conformTo: #'number' selector: #'sign'.
	self value: [-2.0s3 sign] should: [:r | r = -1]
		conformTo: #'number' selector: #'sign'.!

testXsubtractOp
	" <number>#- (returnRule - :receiver :operand) "
	| retVals tmpRec tmpResult |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(0.0s3 2000000002.0s3 -1999999998.0s3 0.0 1.5s3 0.0s3).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 - (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'-'
			ruleReceiver: sclDec2s3 operand: (numList at: ndx)
	].

	"If the return value conforms to <scaledDecimal> then the scale of the result is at least the scale of the receiver after conversion if necessary."
	tmpRec := 26.5s2.
	tmpResult := tmpRec - 5.0s1.
	self should: [tmpResult = 21.50s2 & (tmpResult scale >= tmpRec scale)].

	tmpRec := 26.5s2.
	tmpResult := tmpRec - 5.0s4.
	self should: [tmpResult = 21.5000s4 & (tmpResult scale >= tmpRec scale)].

	tmpRec := -26.5s2.
	tmpResult := tmpRec - 5.0s4.
	self should: [tmpResult =  -31.5000s4 & (tmpResult scale >= tmpRec scale)].!

testXintegerDivideOp
	" <number>#// "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	"The sign of the result is positive if the receiver and operand
		have the same sign, and negative if the signs are different."
	retVals := #(1 -1 0 1 4 1).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 // (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'.
	].

	retVals := #(-1 0 -1 -1 -4 -1).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 // ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'
	].

	self should: [25.5s3 // 5.1s3 = 5].
	self should: [25.5s3 // 5 = 5].
	self should: [25500000000.5s3 // 5000000000 = 5].
	self should: [-25500000000.5s3 // -5000000000 = 5].
	self should: [25.5s3 // (51/10) = 5].
	self should: [25.5s3 // 5.1 = 5].

	self value: [0s // sclDec2s3] should: [:r | r = 0s]
		conformTo: #'number' selector: #'//'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [sclDec2s3 // 0s] shouldRaise: ZeroDivide.!

testXdivideOp
	" <number>#/ (returnRule - :receiver :operand) "
	| retVals tmpRec tmpResult |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(1.0s3 -0.000000001s9 0.000000001s9 1.0 4  1.0s3).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 / (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'/'
			ruleReceiver: sclDec2s3 operand: (numList at: ndx)
	].
	self value: [2.0s15 / -2000000000]
		should: [:r | r = -0.000000001000000s15]
		conformTo: #'number' selector: #'/'
		ruleReceiver: 2.0s15 operand: -2000000000.

	"If the return value conforms to <scaledDecimal> then the scale of the result is at least the scale of the receiver after conversion if necessary."
	tmpRec := 26.5s2.
	tmpResult := tmpRec / 5.0s1.
	self should: [tmpResult = 5.30s2 & (tmpResult scale >= tmpRec scale)].

	tmpRec := 26.5s2.
	tmpResult := tmpRec / 5.0s4.
	self should: [tmpResult = 5.3000s4
					& (tmpResult scale >= tmpRec scale)].

	tmpRec := -26.5s2.
	tmpResult := tmpRec / 5.0s4.
	self should: [tmpResult = -5.3000s4
					& (tmpResult scale >= tmpRec scale)].

	self value: [0.0s / sclDec2s3] should: [:r | r = 0.0s]
		conformTo: #'number' selector: #'/'
		ruleReceiver: sclDec2s3 operand: 0.0s.

	"The implementation must signal the ZeroDivide exception."
	self value: [sclDec2s3 / 0.0s] shouldRaise: ZeroDivide.!

testXfloor
	" <number>#floor "
	#'Numeric'.
	self value: [2.0s3 floor] should: [:r | r = 2]
		conformTo: #'number' selector: #'floor'.
	self value: [2.1s3 floor] should: [:r | r = 2]
		conformTo: #'number' selector: #'floor'.
	self value: [2.5s3 floor] should: [:r | r = 2]
		conformTo: #'number' selector: #'floor'.
	self value: [-2.0s3 floor] should: [:r | r = -2]
		conformTo: #'number' selector: #'floor'.
	self value: [-2.1s3 floor] should: [:r | r = -3]
		conformTo: #'number' selector: #'floor'.
	self value: [-2.5s3 floor] should: [:r | r = -3]
		conformTo: #'number' selector: #'floor'.
	self value: [0.0s3 floor] should: [:r | r = 0]
		conformTo: #'number' selector: #'floor'.!

testXasFloatD
	" <number>#asFloatD "
	#'Numeric'.
	self value: [2.0s3 asFloatD] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [-2.0s3 asFloatD] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [0.0s3 asFloatD] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatD'.!

testXequalityOp
	" <number>#= "
	#'Numeric'.
"
	receiver = comparand	=>
	receiver hash = comparand hash
"
	self value: [sclDec2s3 = sclDec2s3]
		should: [:r | r & (sclDec2s3 hash = sclDec2s3 hash) ]
		conformTo: #'number' selector: #'='.
	self should: [5.1s2 = 5.1s1 & (5.1s2 hash = 5.1s1 hash)].
	self value: [ sclDec2s3 = 2.1s3 ]
		shouldnt: [ :r | r | (sclDec2s3 hash = 2.1s3 hash) ]
		conformTo: #'number' selector: #'='.

"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	self value: [ sclDec2s3 = 2 ]
		should: [ :r | r  ifTrue: [ sclDec2s3 hash = 2 hash ]
							ifFalse: [ sclDec2s3 hash ~= 2 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ -2000000000.0s3 = -2000000000 ]
		should: [ :r | r ifTrue: [ -2000000000.0s3 hash = -2000000000 hash ]
						ifFalse: [ -2000000000.0s3 hash ~= -2000000000 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ 2000000000.0s3 = 2000000000 ]
		should: [ :r | r ifTrue: [ 2000000000.0s3 hash = 2000000000 hash ]
						ifFalse: [ 2000000000.0s3 hash ~= 2000000000 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ sclDec2s3 = 2.0 ]
		should: [ :r | r ifTrue: [ sclDec2s3 hash = 2.0 hash ]
						ifFalse: [ sclDec2s3 hash ~= 2.0 hash ]  ]
		conformTo: #'number' selector: #'='.
	self value: [ 2.5s3 = (5/2) ]
		should: [ :r | r ifTrue: [ 2.5s3 hash = (5/2) hash ]
						ifFalse: [ 2.5s3 hash ~= (5/2) hash ]  ]
		conformTo: #'number' selector: #'='.!

testXasInteger
	" <number>#asInteger "
	#'Numeric'.
	self value: [2.0s3 asInteger] should: [:r | r = 2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [2.1s3 asInteger] should: [:r | r = 2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [2.5s3 asInteger] should: [:r | r = 3]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2.0s3 asInteger] should: [:r | r = -2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2.1s3 asInteger] should: [:r | r = -2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2.5s3 asInteger] should: [:r | r = -3]
		conformTo: #'number' selector: #'asInteger'.
	self value: [0.0s3 asInteger] should: [:r | r = 0]
		conformTo: #'number' selector: #'asInteger'.!

testXmaxX
	" <magnitude>#max: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [2.0s3 max: 3] should: [:r | r = 3]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [-3000000000.0s3 max: -2000000000]
		should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2000000000.0s3 max: 2000000003]
		should: [:r | r = 2000000003]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2.0s3 max: 3.0] should: [:r | r = 3.0]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2.0s3 max: (5/2)] should: [:r | r = (5/2)]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2.0s3 max: 3.0s3] should: [:r | r = 3.0s3]
		conformTo: #'magnitude' selector: #'max:'.

	"Num max: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) max: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'max:'
	].!

testXgreaterThanOp
	" <number>#> "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	self value: [5.1s1 > 5.1s2] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [-5.1s1 > -5.2s2] should: [:r | r]
		conformTo: #'number' selector: #'>'.

	"Small > Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3s3 > tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [-2000000005.0s3 > -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [0.25s3 > (1/2)] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.

	"Num > Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) > (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'>'
	].

	"Big > Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0s3 > tstNum] should: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [9000000000s3 > 2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [-1000000005.0s3 > -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [9.0s3 > (1/2)] should: [:r | r] conformTo: #'number' selector: #'>'.!

testLiterals
	#'Numeric'.
	self should: [123s = 123s0].
	self should: [123s = 123s0].
	self should: [123s0 = 123s0].

	self should: [123.0s = 123.0s1].
	self should: [123s1 = 123.0s1].
	self should: [123.0s1 = 123.0s1].

	self should: [123.000s = 123.000s3].
	self should: [123s3 = 123.000s3].
	self should: [123.0s3 = 123.000s3].
	self should: [123.00s3 = 123.000s3].
	self should: [123.000s3 = 123.000s3].!

testXroundToX
	" <number>#roundTo: (returnRule - :receiver :operand) "
	| retVals save |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(2.000s3 0.000s3 0.000s3 2.0 2 2.000s3).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 roundTo: (numList at: ndx)]
			should: [:r | (save := r) = (retVals at: ndx)]
			conformTo: #'number' selector: #'roundTo:'
			ruleReceiver: sclDec2s3 operand: (numList at: ndx)
	].

	self should: [((0 roundTo: sclDec2s3) = 0s3) & (save scale = 3)]!

testXsqrt
	"2000/06/23 Harmon, R. Changed to fix illegal fixed point literals."

	self value: [26s0 sqrt] should: [:r | r closeTo: 5.099019513592784]
		conformTo: #'number' selector: #'sqrt'.
	self value: [26.0s1 sqrt] should: [:r | r closeTo:  5.099019513592784]
		conformTo: #'number' selector: #'sqrt'.
	self value: [26.01s2 sqrt] should: [:r | r closeTo: 5.1]
		conformTo: #'number' selector: #'sqrt'.
	self value: [26.01s3 sqrt] should: [:r | r closeTo: 5.1]
		conformTo: #'number' selector: #'sqrt'.
	self value: [0.0s3 sqrt] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'sqrt'!

testXabs
	" <number>#abs (Return Values: <RECEIVER>) "
	| rcvr |
	#'Numeric'.
	rcvr := 2.0s3.
	self value: [rcvr abs] should: [:r | r = 2.0s3]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := 2.0s3.
	self value: [rcvr abs] should: [:r | r = 2.0s3]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := 0.0s3.
	self value: [rcvr abs] should: [:r | r = 0s3]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.!

setUp
	super setUp.
	smallInt2 := 2.
	largeNegInt2000000000 := -2000000000.
	largePosInt2000000000 := 2000000000.
	float2 := 2.0d0.
	fractionHalf := 1/2.
	sclDec2s3 := 2.0s3.
	numList := Array new: 6.
	numList at: 1 put: smallInt2.
	numList at: 2 put: largeNegInt2000000000.
	numList at: 3 put: largePosInt2000000000.
	numList at: 4 put: float2.
	numList at: 5 put: fractionHalf.
	numList at: 6 put: sclDec2s3.!

testXremainderIntegerDivideOp
	" <number>#\\ (returnRule - :receiver :operand) "
	"The remainder has the same sign as operand.
	Within the limits of representation, the following invariant should hold:

		(receiver // operand) * operand + (receiver \\ operand) = receiver
 "
	| retVals recList ndx tmpRec tmpResult |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	recList := #( 26 -26000000001 26000000001 26.0 0 26.0s3 ) copy.
	recList at: 5 put: (53/2).
	retVals := #(1.0s3 4.0s3 1.0s3 1.0 0 1.0s3 ) copy.
	retVals at: 5 put: (3/2).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ 5.0s3]
			should: [:r | r = (retVals at: ndx)
					& ((rec // 5.0s3) * 5.0s3 + (rec \\ 5.0s3) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  5.0s3.
	].

	"The remainder has the same sign as operand."
	retVals := #(-4.0s3 -1.0s3 -4.0s3 -4.0 0 -4.0s3 ) copy.
	retVals at: 5 put: (-7/2).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ -5.0s3]
			should: [:r | r = (retVals at: ndx)
					& ((rec // -5.0s3) * -5.0s3 + (rec \\ -5.0s3) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  -5.0s3.
	].

	self should: [26.5s3 \\ 5.0s3 = 1.5s3
				& ((26.5s3 // 5.0s3) * 5.0s3 + (26.5s3 \\ 5.0s3) = 26.5s3)].
	self should: [26.5s3 \\ -5.0s3 = -3.5s3
				& ((26.5s3 // -5.0s3) * -5.0s3 + (26.5s3 \\ -5.0s3) = 26.5s3)].

	"If the return value conforms to <scaledDecimal> then the scale of the result is at least the scale of the receiver after conversion if necessary."
	tmpRec := 26.5s2.
	tmpResult := tmpRec \\ 5.0s1.
	self should: [tmpResult = 1.50s2 & (tmpResult scale >= tmpRec scale)].

	tmpRec := 26.5s2.
	tmpResult := tmpRec \\ 5.0s4.
	self should: [tmpResult = 1.5000s4
				& (tmpResult scale >= tmpRec scale)].

	tmpRec := -26.5s2.
	tmpResult := tmpRec \\ 5.0s4.
	self should: [tmpResult = 3.5000s4
				& (tmpResult scale >= tmpRec scale)].

	self should: [0.0s3 \\ sclDec2s3 = 0.0s3].

	"If the operand is zero, the implementation may signal
		the ZeroDivide exception or provide a continuation value."
	self value: [sclDec2s3 \\ 0.0s3] shouldRaise: ZeroDivide.!

testXscale
	" <scaledDecimal>#scale "
	#'Numeric'.!

testXprintString
	" <number>#printString "
	#'Numeric'.
#'todo'."??? Uncommented fails--compiler error?.
	self value: [26.5s0 printString] should: [:r | r = '26s0']
		conformTo: #'number' selector: #'printString'.
	self value: [26.5s1 printString] should: [:r | r = '26.5s1']
		conformTo: #'number' selector: #'printString'.
	self value: [26.5s2 printString] should: [:r | r = '26.50s2']
		conformTo: #'number' selector: #'printString'.
"	self value: [26.5s3 printString] should: [:r | r = '26.500s3']
		conformTo: #'number' selector: #'printString'.
	self value: [-26.5s1 printString] should: [:r | r = '-26.5s1']
		conformTo: #'number' selector: #'printString'.
	self value: [0.00s printString] should: [:r | r = '0.00s2']
		conformTo: #'number' selector: #'printString'.!

testXstrictlyPositive
	" <number>#strictlyPositive "
	#'Numeric'.
	self value: [2.0s3 strictlyPositive] should: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.

	self value: [0.0s3 strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.
	self value: [-2.0s3 strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.!

canonicalObject
	^sclDec2s3!

testXtruncated
	" <number>#truncated "
	#'Numeric'.
	self value: [2.0s3 truncated] should: [:r | r = 2]
		conformTo: #'number' selector: #'truncated'.
	self value: [2.1s3 truncated] should: [:r | r = 2]
		conformTo: #'number' selector: #'truncated'.
	self value: [2.5s3 truncated] should: [:r | r = 2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2.0s3 truncated] should: [:r | r = -2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2.1s3 truncated] should: [:r | r = -2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2.5s3 truncated] should: [:r | r = -2]
		conformTo: #'number' selector: #'truncated'.
	self value: [0.0s3 truncated] should: [:r | r = 0]
		conformTo: #'number' selector: #'truncated'.!

testXminX
	" <magnitude>#min: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [2.0s3 min: 1] should: [:r | r = 1]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [-1000000000.0s3 min: -2000000000]
		should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2000000003.0s3 min: 2000000001]
		should: [:r | r = 2000000001]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2.0s3 min: 1.0] should: [:r | r = 1.0]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2.0s3 min: (3/2)] should: [:r | r = (3/2)]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2.0s3 min: 1.0s5] should: [:r | r = 1.0s5]
		conformTo: #'magnitude' selector: #'min:'.

	"Num min: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) min: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'min:'
	].!

testXsquared
	" <number>#squared (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 5.1s3.
	self value: [rcvr squared] should: [:r | (r = 26.010s3) & (r scale = 3)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

#'todo'."??? Uncommented fails--compiler error?.
	rcvr := -5.1s3.
	self value: [rcvr squared] should: [:r | (r = 26.010s3) & (r scale = 3)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

	rcvr := 5.1s2.
	self value: [rcvr squared] should: [:r | (r = 26.01s2) & (r scale = 2)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

	rcvr := 5.1s1.
	self value: [rcvr squared] should: [:r | (r = 26.0s1) & (r scale = 1)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

	self halt.
	rcvr := 5.1s0.
	self value: [rcvr squared] should: [:r | (r = 26.010s3) & (r scale = 0)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

	rcvr := 0.0s3.
	self value: [rcvr squared] should: [:r | (r = 0.000s3) & (r scale = 3)]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.
"!

testXtoXbyX
	" <number>#to:by: "
	#'Numeric'.!

testXaddOp
	" <number>#+ (returnRule - :receiver :operand) "
	| retVals tmpRec tmpResult |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(4.0s3 -1999999998.0s3 2000000002.0s3 4.0 0 4.0s3) copy.
	retVals at: 5 put: (5/2).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 + (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'+'
			ruleReceiver: sclDec2s3 operand: (numList at: ndx)
	].

	"If the return value conforms to <scaledDecimal> then the scale of the result is at least the scale of the receiver after conversion if necessary."
	tmpRec := 26.5s2.
	tmpResult := tmpRec + 5.0s1.
	self should: [tmpResult = 31.50s2 & (tmpResult scale >= tmpRec scale)].

	tmpRec := 26.5s2.
	tmpResult := tmpRec + 5.0s4.
	self should: [tmpResult = 31.5000s4 & (tmpResult scale >= tmpRec scale)].

	tmpRec := -26.5s2.
	tmpResult := tmpRec + 5.0s4.
	self should: [tmpResult = -21.5000s4 & (tmpResult scale >= tmpRec scale)].!

testXquoX
	" <number>#quo: "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #( 1 0 0 1 4 1 ).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 quo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'.
	].

	retVals := #( -1 0 0 -1 -4 -1 ).
	1 to: numList size do: [ :ndx |
		self value: [sclDec2s3 quo: ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'
	].

	self should: [(25.5s3 quo: 5.1s3) = 5].
	self should: [(25.5s3 quo: 5) = 5].
	self should: [(25500000000.5s3 quo: 5000000000) = 5].
	self should: [(-25500000000.5s3 quo: -5000000000) = 5].
	self should: [(25.5s3 quo: (51/10)) = 5].
	self should: [(25.5s3 quo: 5.1) = 5].

	self value: [0s quo: sclDec2s3] should: [:r | r = 0s]
		conformTo: #'number' selector: #'quo:'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [sclDec2s3 quo: 0s] shouldRaise: ZeroDivide.!

testXrounded
	" <number>#rounded "
	#'Numeric'.
	self value: [2.0s3 rounded] should: [:r | r = 2]
		conformTo: #'number' selector: #'rounded'.
	self value: [2.1s3 rounded] should: [:r | r = 2]
		conformTo: #'number' selector: #'rounded'.
	self value: [2.5s3 rounded] should: [:r | r = 3]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2.0s3 rounded] should: [:r | r = -2]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2.1s3 rounded] should: [:r | r = -2]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2.5s3 rounded] should: [:r | r = -3]
		conformTo: #'number' selector: #'rounded'.
	self value: [0.0s3 rounded] should: [:r | r = 0]
		conformTo: #'number' selector: #'rounded'.!

testXlessThanOp
	" <number>#< "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."
	self value: [5.1s1 < 5.1s2] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.

	"Small < Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3s3 < tstNum] should: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [-2000000005.0s3 < -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [0.25s3 < (1/2)] should: [:r | r]
		conformTo: #'number' selector: #'<'.

	"Num < Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) < (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'<'
	].

	"Big < Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0s3 < tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [9000000000s3 < 2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [-1000000005.0s3 < -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [9.0s3 < (1/2)] shouldnt: [:r | r] conformTo: #'number' selector: #'<'.!

testXtoXdoX
	" <number>#to:do: "
	#'Numeric'.!

testXfractionPart
	" <number>#fractionPart (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	"Within the limits of representation, the following invariants should hold:

		receiver integerPart + receiver fractionPart = receiver
		receiver \\1 = receiver fractionPart	(RAH - erroneous, add #'abs')
"
	rcvr := 26.5s3.
	self value: [rcvr fractionPart]
		should: [:r | r = 0.5s3 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := -26.5s3.
	self value: [rcvr fractionPart]
		should: [:r | r = -0.5s3 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := 0.0s3.
	self value: [rcvr fractionPart]
		should: [:r | r = 0s3 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := 0.0s3.
	self value: [rcvr fractionPart]
		should: [:r | r = 0s3 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.!

testXraisedToIntegerX
	"2000/06/23 Harmon, R. Changed to fix illegal fixed point literals."
	| rcvr |
	rcvr := 5.1s2.
	self value: [rcvr raisedToInteger: 0] should: [:r | r = 1.0s2]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 1] should: [:r | r = rcvr]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 2] should: [:r | r = 26.01s2]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr negated raisedToInteger: 2] should: [:r | r = 26.01s2]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: -2]
		should: [:r | r = 0.0384467512495194s16]
		conformTo: #'number' selector: #'raisedToInteger:'
		opRECEIVER: rcvr.

	"It is erroneous if the operand does not conform to the protocol <integer>."
	self value: [rcvr raisedToInteger: 2.0s2]
		shouldRaise: Error.

	self value: [0.0s2 raisedToInteger: -2] shouldRaise: ZeroDivide.!

testXasFloatE
	" <number>#asFloatE "
	#'Numeric'.
	self value: [2.0s3 asFloatE] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [-2.0s3 asFloatE] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [0.0s3 asFloatE] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatE'.!

testXnegative
	" <number>#negative "
	#'Numeric'.
	self value: [-2.0s3 negative] should: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [2.0s3 negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [0.0s3 negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.! !

!CollectionHelper methodsFor: nil!

testXasOrderedCollection
	" <collection>#asOrderedCollection "
	#'Collection'.
	self assertSend: #asOrderedCollection!

testXasByteArray
	" <collection>#asByteArray "
	#'Collection'.
	self assertSend: #asByteArray!

testXasBag
	" <collection>#asBag "
	#'Collection'.
	self assertSend: #asBag!

testXoccurrencesOfX
	" <collection>#occurrencesOf: "
	#'Collection'.

	self
		value:
			[self canonicalObject occurrencesOf: self canonicalElement]
		should:
			[:result |
			result = 1]
		conformTo: #'collection'
		selector: #'occurrencesOf:'.

	self
		value:
			[self canonicalObject occurrencesOf: 'Zornfindel']
		should:
			[:result |
			result = 0]
		conformTo: #'collection'
		selector: #'occurrencesOf:'.

	self
		value:
			[self emptyCollection occurrencesOf: 'Zornfindel']
		should:
			[:result |
			result = 0]
		conformTo: #'collection'
		selector: #'occurrencesOf:'!

testXallSatisfyX
	" <collection>#allSatisfy: "
	#'Collection'.

	self
		value:
			[self canonicalObject
				allSatisfy:
					[:each |
					true]]
		should:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'allSatisfy:'.

	self
		value:
			[self canonicalObject
				allSatisfy:
					[:each |
					false]]
		shouldnt:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'allSatisfy:'.

	self
		value:
			[(self canonicalObject
				reject:
					[:each |
					each = self canonicalElement])
				allSatisfy:
					[:each |
					each ~= self canonicalElement]]
		should:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'allSatisfy:'.

	self
		value:
			[self emptyCollection
				allSatisfy:
					[:each |
					true]]
		should:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'allSatisfy:'.

	"self
		value:
			[self canonicalObject
				allSatisfy:
					[:each |
					nil]]
		shouldRaise: TestResult error"!

testXrejectX
	" <collection>#reject: (Return Values: <RECEIVER>)"
	#'Collection'.

	self
		value:
			[self canonicalObject
				reject:
					[:each |
					each = self canonicalElement]]
		should:
			[:result |
			(result includes: self canonicalElement) not]
		conformTo: #'collection'
		selector: #'reject:'.

	"Test empty class."
	self
		value:
			[self emptyCollection
				reject:
					[:each |
					true]]
		should:
			[:result |	
			result isEmpty]
		conformTo: #'collection'
		selector: #'reject:'.

	"self
		value:
			[self canonicalObject
				reject:
					[:each |
					nil]]
	shouldRaise: TestResult error"

	self
		value:
			[self canonicalObject
				reject:
					[:each |
					each gobbledegook]]
		shouldRaise: TestResult error!

object
	^testCase canonicalObject!

emptyCollection
	^testCase emptyCollection!

object: anObject!

testXnotEmpty
	" <collection>#notEmpty "
	#'Collection'.
	self assertSend: #notEmpty!

testXasSortedCollectionX
	" <collection>#asSortedCollection: "
	#'Collection'.

	self
		value:
			[self canonicalObject
				asSortedCollection:
					[:a :b |
					b < a]]
		should:
			[:result |
			result size = self canonicalObject size]
		conformTo: #'collection'
		selector: #'asSortedCollection:'.

	self
		value:
			[self emptyCollection
				asSortedCollection:
					[:a :b |
					b < a]]
		should:
			[:result |
			result size = self emptyCollection size]
		conformTo: #'collection'
		selector: #'asSortedCollection:'.

	"Test a garbage message for any parameter passed into the block."
	self
		value:
			[self canonicalObject
				asSortedCollection:
					[:a :b |
					a gobbledegook]]
		shouldRaise: TestResult error!

testXselectX
	" <collection>#select: (Return Values: <RECEIVER>)"
	#'Collection'.

	self
		value:
			[self canonicalObject
				select:
					[:each |
					each ~= self canonicalElement]]
		should:
			[:result |
			(result includes: self canonicalElement) not]
		conformTo: #'collection'
		selector: #'select:'.

	"Test empty class."
	self
		value:
			[self emptyCollection
				select:
					[:each |
					true]]
		should:
			[:result |	
			result isEmpty]
		conformTo: #'collection'
		selector: #'select:'.

	"self
		value:
			[self canonicalObject
				select:
					[:each |
					nil]]
	shouldRaise: TestResult error."

	self
		value:
			[self canonicalObject
				select:
					[:each |
					each gobbledegook]]
		shouldRaise: TestResult error!

testXrehash
	" <collection>#rehash "
	#'Collection'.
	self assertSend: #rehash!

testXcollectX
	" <collection>#collect: (Return Values: <RECEIVER>)"
	#'Collection'.

	self
		value:
			[self canonicalObject
				collect:
					[:each |
					each ]]
		should:
			[:result |
			result size = self canonicalObject size]
		conformTo: #'collection'
		selector: #'collect:'.

	"Test empty class."
	self
		value:
			[self emptyCollection
				collect:
					[:each |
					true]]
		should:
			[:result |	
			result isEmpty]
		conformTo: #'collection'
		selector: #'collect:'.

	self returnTypeHasLimitedElementTypes
		ifTrue:
			[self
				value:
					[self canonicalObject
						collect:
							[:each |
							self limitedElementTypes]]
				shouldRaise: TestResult error].

	self
		value:
			[self canonicalObject
				collect:
					[:each |
					each gobbledegook]]
		shouldRaise: TestResult error.!

testXasSortedCollection
	" <collection>#asSortedCollection "
	#'Collection'.
	self assertSend: #asSortedCollection!

testXdetectX
	" <collection>#detect: "

	self
		value:
			[self canonicalObject
				detect:
					[:each |
					each = self canonicalElement]]
		should:
			[:result |
			result = self canonicalElement]
		conformTo: #'collection'
		selector: #'detect:'.

	"Test empty class.  What is the appropriate behavior for sending detect: to an empty collection?  Both VA and VW raise element
	not found errors."
	self
		value:
			[self emptyCollection
				detect:
					[:each |
					true]]
		shouldRaise: TestResult error.

	"self
		value:
			[self canonicalObject
				detect:
					[:each |
					nil]]
		shouldRaise: TestResult error."

	self
		value:
			[self canonicalObject
				detect:
					[:each |
					false]]
		shouldRaise: TestResult error.

	self
		value:
			[self canonicalObject
				detect:
					[:each |
					each gobbledegook]]
		shouldRaise: TestResult error!

testXasSet
	" <collection>#asSet "
	#'Collection'.
	self assertSend: #asSet!

returnTypeHasLimitedElementTypes

	^testCase returnTypeHasLimitedElementTypes!

testXisEmpty
	" <collection>#isEmpty "
	#'Collection'.
	self assertSend: #isEmpty!

testXanySatisfyX
	" <collection>#anySatisfy: "
	#'Collection'.

	self
		value:
			[self canonicalObject
				anySatisfy:
					[:each |
					each = self canonicalElement]]
		should:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'anySatisfy:'.

	self
		value:
			[self canonicalObject
				anySatisfy:
					[:each |
					false]]
		shouldnt:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'anySatisfy:'.

	self
		value:
			[(self canonicalObject
				reject:
					[:each |
					each = self canonicalElement])
				anySatisfy:
					[:each |
					each = self canonicalElement]]
		shouldnt:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'anySatisfy:'!

testXdoXseparatedByX
	" <collection>#do:separatedBy: "
	#'Collection'.

	self
		value:
			[self canonicalObject
				do:
					[:each |]
				separatedBy:
					[]]
		should:
			[:result |
			"The ANSI Standard states that the return is UNSPECIFIED.  So, any return is valid."
			true]
		conformTo: #'collection'
		selector: #'do:separatedBy:'.

	"Send message that causes an error in the do: loop."
	self
		value:
			[self canonicalObject
				do:
					[:each |
					each gobbledegook]
				separatedBy:
					[]]
		shouldRaise: TestResult error.

	"Send message that causes an error in the separatedBy: loop."
	self
		value:
			[self canonicalObject
				do:
					[:each |]
				separatedBy:
					[self gobbledegook]]
		shouldRaise: TestResult error.

	self
		value:
			[self emptyCollection
				do:
					[:each |]
				separatedBy:
					[]]
		should:
			[:result |
			"The ANSI Standard states that the return is UNSPECIFIED.  So, any return is valid."
			true]
		conformTo: #'collection'
		selector: #'do:separatedBy:'.!

testXinjectXintoX
	" <collection>#inject:into: "
	#'Collection'.

	self
		value:
			[self canonicalObject
				inject: 1
				into:
					[:value :each |
					(each printString at: 1) asInteger * value]]
		should:
			[:result |
			result > 0]
		conformTo: #'collection'
		selector: #'inject:into:'.

	self
		value:
			[self emptyCollection
				inject: 1
				into:
					[:value :each |
					(each printString at: 1) asInteger * value]]
		should:
			[:result |
			result > 0]
		conformTo: #'collection'
		selector: #'inject:into:'!

testXsize
	" <collection>#size "
	#'Collection'.
	self assertSend: #size!

testXdetectXifNoneX
	" <collection>#detect:ifNone: "
	#'Collection'.

	self
		value:
			[self canonicalObject
				detect:
					[:each |
					each = self canonicalElement]
				ifNone:
					[nil]]
		should:
			[:result |
			result = self canonicalElement]
		conformTo: #'collection'
		selector: #'detect:ifNone:'.

	"Test empty class.  What is the appropriate behavior for sending detect: to an empty collection?  Both VA and VW raise element
	not found errors."
	self
		value:
			[self emptyCollection
				detect:
					[:each |
					true]
				ifNone:
					[#NotFound]]
		should:
			[:result |
			result == #NotFound]
		conformTo: #collection
		selector: #'detect:ifNone:'.

	"self
		value:
			[self canonicalObject
				detect:
					[:each |
					nil]
				ifNone:
					[nil]]
		shouldRaise: TestResult error."

	self
		value:
			[self canonicalObject
				detect:
					[:each |
					false]
				ifNone:
					[#NotFound]]
		should:
			[:result |
			result == #NotFound]
		conformTo: #'collection'
		selector: #'detect:ifNone:'.

	self
		value:
			[self canonicalObject
				detect:
					[:each |
					each gobbledegook]
				ifNone:
					[]]
		shouldRaise: TestResult error.

	self
		value:
			[self canonicalObject
				detect:
					[:each |
					false]
				ifNone:
					[self gobbledegook]]
		shouldRaise: TestResult error.!

canonicalElement
	^testCase canonicalElement!

testXasArray
	" <collection>#asArray "
	#'Collection'.
	self assertSend: #asArray!

limitedElementTypes

	^testCase limitedElementTypes!

testXdoX
	" <sequencedReadableCollection>#do: "
	#'Collection'.


	self
		value:
			[self canonicalObject
				do:
					[:each |]]
		should:
			[:result |
			"The ANSI Standard states that the return is UNSPECIFIED.  So, any return is valid."
			true]
		conformTo: #'collection'
		selector: #'do:'.

	self
		value:
			[self emptyCollection
				do:
					[:each |]]
		should:
			[:result |
			"The ANSI Standard states that the return is UNSPECIFIED.  So, any return is valid."
			true]
		conformTo: #'collection'
		selector: #'do:'.

	"Send message that causes an error in the do: loop."
	self
		value:
			[self canonicalObject
				do:
					[:each |
					each gobbledegook]]
		shouldRaise: TestResult error.!

canonicalObject
	^testCase canonicalObject!

testXincludesX
	" <collection>#includes: "
	#'Collection'.

	self
		value:
			[self canonicalObject includes: self canonicalElement]
		should:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'includes:'.

	self
		value:
			[self canonicalObject includes: 'Zornfindel']
		shouldnt:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'includes:'.

	self
		value:
			[self emptyCollection includes: 'Zornfindel']
		shouldnt:
			[:result |
			result]
		conformTo: #'collection'
		selector: #'includes:'! !

!CollectionHelper class methodsFor: nil!

initialize
	"CollectionHelper  initialize"
	super initialize! !

!SequencedStreamHelper methodsFor: nil!

testXclose

#todo."Don't know how to check this:
If the receiver is a write-back stream update its stream backing store as if the message #flush was sent to the receiver. Then eliminate any association between the receiver and its stream backing store. Any system resources associated with the association should be released. The effect of sending any message to the receiver subsequent to this message is undefined.
"
	self assertSend: #close!

object: anObject!

testXcontents

#todo."Don't know how to check this:"
	self value: [self canonicalObject contents]
		should: [:r | r = 'this is a string'
				& r size = self canonicalObject size]
		conformTo: self protocol selector: #'contents'.!

testXpositionX

	"Errors: If the receiver has any sequence values and amount
			is greater than or equal to the total number
			of sequence values of the receiver."
	self value: [self canonicalObject position: 99]
		shouldRaise: Error.

	self canonicalObject position: 4.

	"past sequence values smaller than amount:"
	self value: [self canonicalObject position: 6]
		should: [:r | true "UNSPECIFIED"]
		conformTo: self protocol selector: #'position:'.

	"past sequence values greater than amount:"
	self value: [self canonicalObject position: 2]
		should: [:r | true "UNSPECIFIED"]
		conformTo: self protocol selector: #'position:'.

	"receiver's past sequence values is equal to amount:"
	self value: [self canonicalObject position: 2]
		should: [:r | true "UNSPECIFIED"]
		conformTo: self protocol selector: #'position:'.

	"Errors: If amount is negative."
	self value: [self canonicalObject position: -1]
		shouldRaise: Error.!

testXposition

	self canonicalObject reset.
	self value: [self canonicalObject position]
		should: [:r | r = 0]
		conformTo: self protocol selector: #'position'.!

testXreset

	self value: [self canonicalObject reset]
		should: [:r | "r UNSPECIFIED"  self canonicalObject position = 0]
		conformTo: self protocol selector: #'reset'.

	self value: [self canonicalObject reset]
		should: [:r | "r UNSPECIFIED"  self canonicalObject position = 0]
		conformTo: self protocol selector: #'reset'.!

testXsetToEnd

	self value: [self canonicalObject setToEnd]
		should: [:r | "r UNSPECIFIED"  self canonicalObject position
								= self canonicalObject contents size]
		conformTo: self protocol selector: #'setToEnd'.!

object
	^testCase canonicalObject!

canonicalObject

	^testCase canonicalObject!

testXisEmpty

	self value: [self canonicalObject isEmpty]
		shouldnt: [:r | r]
		conformTo: self protocol selector: #'isEmpty'.! !

!SequencedStreamHelper class methodsFor: nil!

initialize
	"SequencedStreamHelper  initialize"
	super initialize! !

!ReadWriteStreamFactoryANSITest methodsFor: nil!

protocol
	^#'ReadWriteStream factory'!

canonicalObject
	^ReadWriteStream!

testXwithX

	self value: [self canonicalObject with: 'this is a string']
		should: [:r | r position = 'this is a string' size
					& r contents = 'this is a string']
		conformTo: self protocol selector: #'with:'.! !

!MsgParmSpec methodsFor: nil!

printOn: targetStream 
	"Append to targetStream a text representation of the receiver as a developer would want to see it (inspector, etc)."

	targetStream nextPutAll: self class name;
	 nextPut: $(;
	 nextPutAll: self parmName;
	 space.
	self parmProtocolNames do: [:protocolName | targetStream nextPut: $<;
		 nextPutAll: protocolName;
		 nextPut: $>]
		separatedBy: [targetStream nextPutAll: '|'].
	targetStream space; nextPutAll: self parmAliasingAttribute; nextPut: $)!

setParmName: name protocolNames: protocolNames aliasing: aliasingAttribute 
	"Private - ."
	parmName := name.
	parmProtocols := protocolNames.
	parmAliasingAttribute := aliasingAttribute!

storeSIFOn: targetStream 
	"Append to targetStream, a <puttableStream>, the ASCII representation of the receiver in SIF from which the receiver can be rebuilt but NOT reinstantiated via evaluate."
	#todo."??? Find better way to keep SIF knowledge out of model ???"
	targetStream nextPutAll: '#('.
	parmName asString printOn: targetStream.
	targetStream space; nextPut: $'.
	parmProtocols do: [:protocolName | targetStream nextPutAll: protocolName asString]
		separatedBy: [targetStream space].
	targetStream nextPut: $'.
	targetStream nextPutAll: ' #'.
	parmAliasingAttribute asString printOn: targetStream.
	targetStream nextPutAll: ')'!

parmName
	"Answer the protocol message parameter specification parameter name."

	^ parmName!

parmAliasingAttribute
	"Answer the protocol message parameter specification parameter aliasing attribute."

	^ parmAliasingAttribute!

parmProtocolNames
	"Answer the protocol names this protocol message parameter specification conforms to. 
	Note: The protocol names is a <Set> of <symbol>s."

	^ parmProtocols!

storeSIFString
	"Answer a <readableString>, a representation of the receiver in SIF from which the receiver can be rebuilt but NOT reinstantiated via evaluate."
	| aStream |
	aStream := WriteStream on: (String new: 50).
	self storeSIFOn: aStream.
	^ aStream contents! !

!MsgParmSpec class methodsFor: nil!

newCapturedParmName: nameIn protocolNames: protocolNames 
	"Answer a new protocol message parameter specification for parameter named, nameIn, conforming to the protocols named, protocolNames, and with a captured aliasing attribute. 
	Note: protocolNames must be a <collection> of <symbol>s."

	^ self
		privateNewParmName: nameIn
		protocolNames: protocolNames
		aliasing: self parmAliasingAttributeCaptured!

parmAliasingAttributeCaptured
	"Answer the captured protocol message parameter specification parameter aliasing attribute constant."

	^ #'captured'!

newUncapturedParmName: nameIn protocolNames: protocolNames 
	"Answer a new protocol message parameter specification for parameter named, nameIn, conforming to the protocols named, protocolNames, and with a uncaptured aliasing attribute. 
	Note: protocolNames must be a <collection> of <symbol>s."

	^ self
		privateNewParmName: nameIn
		protocolNames: protocolNames
		aliasing: self parmAliasingAttributeUncaptured!

privateValidProtocolNames: protocolNamesIn ifError: errorBlock 
	"Private -"
	| protocolNamesTmp |
	(protocolNamesIn isKindOf: Collection)
		ifFalse: [^ errorBlock value].
	protocolNamesTmp := self protocolManager defaultProtocolNameCollection.
	protocolNamesIn
		do: 
			[:protocolName | 
			(protocolName isKindOf: Symbol)
				ifFalse: [^ errorBlock value].
			protocolNamesTmp add: protocolName].
	^ protocolNamesTmp!

parmAliasingAttributeUncaptured
	"Answer the uncaptured protocol message parameter specification parameter aliasing attribute constant."

	^ #'uncaptured'!

newParmName: nameIn protocolNames: protocolNames aliasing: attributeIn 
	"Answer a new protocol message parameter specification for parameter named, nameIn, conforming to the protocols named, protocolNames, and with an aliasing attribute, attributeIn. 
	Note: protocolNames must be a <collection> of <symbol>s."

	(self aliasingAttributes includes: attributeIn)
		ifFalse: [self error: 'Protocol msg. parameter aliasing attribute not valid.'].
	^ self
		privateNewParmName: nameIn
		protocolNames: protocolNames
		aliasing: attributeIn!

newUnspecifiedParmName: nameIn protocolNames: protocolNames 
	"Answer a new protocol message parameter specification for parameter named, nameIn, conforming to the protocols named, protocolNames, and with a unspecified aliasing attribute. 
	Note: protocolNames must be a <collection> of <symbol>s."

	^ self
		privateNewParmName: nameIn
		protocolNames: protocolNames
		aliasing: self parmAliasingAttributeUnspecified!

parmAliasingAttributeUnspecified
	"Answer the unspecified protocol message parameter specification parameter aliasing attribute constant."

	^ #'unspecified'!

aliasingAttributes
	"Answer a list of protocol message parameter aliasing attribute constants.
	Note: The list is a <Set> of <symbol>s."

	^ Set
		with: self parmAliasingAttributeCaptured
		with: self parmAliasingAttributeUncaptured
		with: self parmAliasingAttributeUnspecified!

new
	"Raise an exception as this is an inappropriate message."

	^ self shouldNotImplement!

privateNewParmName: nameIn protocolNames: protocolNames aliasing: aliasingAttribute 
	"Private -"
	| protocolNamesTmp |
	(nameIn isKindOf: String)
		ifFalse: [self error: 'parameter name not a String.'].
	protocolNamesTmp := self privateValidProtocolNames: protocolNames ifError: [^ self error: 'Protocol msg.parameter protocol names not a <collection> of <symbol>s.'].
	^ super new
		setParmName: nameIn
		protocolNames: protocolNamesTmp
		aliasing: aliasingAttribute! !

!DictionaryANSITest methodsFor: nil!

emptyCanonicalObject
	^Dictionary new!

testXatX
	" <abstractDictionary>#at: "
	#'Collection'.!

testXincludesKeyX
	" <abstractDictionary>#includesKey: "
	#'Collection'.!

testXatXifAbsentX
	" <abstractDictionary>#at:ifAbsent: "
	#'Collection'.!

testXatXputX
	" <abstractDictionary>#at:put: "
	#'Collection'.!

protocol
	^#'Dictionary'!

canonicalElement

	^self canonicalObject at: 2!

emptyCollection

	^self canonicalObject class new!

canonicalObject
	^Dictionary new at: 1 put: 11; at: 2 put: 22; at:3 put: 33; at:4 put: 44; yourself!

testXaddAllX
	" <abstractDictionary>#addAll: "
	#'Collection'.!

testXatXifAbsentPutX
	" <abstractDictionary>#at:ifAbsentPut: "
	#'Collection'.! !

!DictionaryANSITest class methodsFor: nil!

helperClassesDo: aBlock 
	"refinements must execute before the rest of the helpers"

	aBlock value: AbstractDictionaryHelper.
	super helperClassesDo: aBlock! !

!SequencedReadableCollectionHelper methodsFor: nil!

testXatXifAbsentX
	" <sequencedReadableCollection>#at:ifAbsent: "

	| cos b |
	cos := self canonicalObjects.
	b := (cos at: #b) at: 1.
	self value: [(cos at: #abcd) at: 2 ifAbsent: [nil]]
		should: [:r | r = b]
		conformTo: #sequencedReadableCollection
		selector: #at:ifAbsent:.
	self value: [(cos at: #abcd) at: 47 ifAbsent: [nil]]
		should: [:r | r isNil]
		conformTo: #sequencedReadableCollection
		selector: #at:ifAbsent:!

object: anObject!

testXfindFirstX
	" <sequencedReadableCollection>#findFirst: "
	| cos d b it |
	cos := self canonicalObjects.
	b := (cos at: #b) at: 1.
	d := (cos at: #d) at: 1.
	it := (cos at: #ab), (cos at: #bc).
	self
		value:[it findFirst: [:e | e = b]]
	    should: [:r | r = 2]
		conformTo: #sequencedReadableCollection
		selector: #findFirst:.
	self
		value:[(cos at:#abc) findFirst: [:e | e = d]]
	    should: [:r | r = 0]
		conformTo: #sequencedReadableCollection
		selector: #findFirst:.!

testXindexOfXifAbsentX
	" <sequencedReadableCollection>#indexOf:ifAbsent: "
	| cos c |
	cos := self canonicalObjects.
	c := (cos at:#c) at:1.
	self
		value:[(cos at: #abcd) indexOf: c ifAbsent:[nil]]
	    should: [:r | r = 3]
		conformTo: #sequencedReadableCollection
		selector: #indexOf:ifAbsent:.
	self
		value:[(cos at: #abcd) indexOf: 42 ifAbsent:[nil]]
	    should: [:r | r isNil]
		conformTo: #sequencedReadableCollection
		selector: #indexOf:ifAbsent:.!

testXfindLastX
	" <sequencedReadableCollection>#findLast: "
	| cos d b it |
	cos := self canonicalObjects.
	b := (cos at: #b) at: 1.
	d := (cos at: #d) at: 1.
	it := (cos at: #ab), (cos at: #bc).
	self
		value:[it findLast: [:e | e = b]]
	    should: [:r | r = 3]
		conformTo: #sequencedReadableCollection
		selector: #findLast:.
	self
		value:[(cos at:#abc) findLast: [:e | e = d]]
	    should: [:r | r = 0]
		conformTo: #sequencedReadableCollection
		selector: #findLast:.!

testXcopyReplacingXwithObjectX
	" <sequencedReadableCollection>#copyReplacing:withObject: (Return Values: <RECEIVER>)"
	| cos c a b |
	cos := self canonicalObjects.
	a := cos at:#a.
	b := cos at:#b.
	c := cos at:#c.
   self value:[((cos at:#ab), (cos at:#bc)) copyReplacing:(b at:1) withObject:(c at:1)]
	    should: [:r | r = (a, c, c, c)]
		conformTo: #sequencedReadableCollection
		selector: #copyReplacing:withObject:.!

canonicalObject
	^testCase canonicalObject copy!

testXfromXtoXkeysAndValuesDoX
	" <sequencedReadableCollection>#from:to:keysAndValuesDo: "

	| co col |
	co := self canonicalObject.
	col := Array new: 4.
	self value: [co from: 1 to: 4 keysAndValuesDo: [:i :e | col at: i put: e]]
		should: [:r | col = co asArray]
		conformTo: #sequencedReadableCollection
		selector: #from:to:keysAndValuesDo:!

testXconcatenateOp
	" <sequencedReadableCollection>#, (Return Values: <RECEIVER>)"

	| cos |
	cos := self canonicalObjects.
	self value: [(cos at: #ab) , (cos at: #cd)]
		should: [:r | r = (cos at: #abcd)]
		conformTo: #sequencedReadableCollection
		selector: #,!

testXcopyReplaceAllXwithX
	" <sequencedReadableCollection>#copyReplaceAll:with: (Return Values: <RECEIVER>)"

	| cos |
	cos := self canonicalObjects.
	self value: [(cos at:#abcd) copyReplaceAll:(cos at:#bc) with: (cos at:#bcd)]
		should: [:r | r = ((cos at:#abcd), (cos at:#d)) ]
		conformTo: #sequencedReadableCollection
		selector: #copyReplaceAll:with:.!

testXindexOfX
	" <sequencedReadableCollection>#indexOf: "
	| cos c |
	cos := self canonicalObjects.
	c := (cos at:#c) at:1.
	self
		value:[(cos at: #abcd) indexOf: c]
	    should: [:r | r = 3]
		conformTo: #sequencedReadableCollection
		selector: #indexOf:.
	self
		value:[(cos at: #abcd) indexOf: 42]
	    should: [:r | r = 0]
		conformTo: #sequencedReadableCollection
		selector: #indexOf:.!

testXwithXdoX
	" <sequencedReadableCollection>#with:do: "
	| col cos abc bcd |
	cos := self canonicalObjects.
	abc := cos at:#abc.
	bcd := cos at:#bcd.
	col := OrderedCollection new.
	self
		value: [abc with: bcd do: [:e1 :e2 | col add: (e1 = e2)]]
	    should: [:r | col = #(false false false) asOrderedCollection]
		conformTo: #sequencedReadableCollection
		selector: #with:do:.!

testXcopyWithX
	" <sequencedReadableCollection>#copyWith: (Return Values: <RECEIVER>)"
	| cos d |
	cos := self canonicalObjects.
	d := cos at:#d.
   self value:[(cos at:#abc) copyWith:(d at:1)]
	    should: [:r | r = (cos at: #abcd)]
		conformTo: #sequencedReadableCollection
		selector: #copyWith:!

testXindexOfSubCollectionXstartingAtX
	" <sequencedReadableCollection>#indexOfSubCollection:startingAt: "
	| cos |
	cos := self canonicalObjects.
	self
		value:[(cos at: #abcd) indexOfSubCollection:(cos at:#bc) startingAt:1]
	    should: [:r | r = 2]
		conformTo: #sequencedReadableCollection
		selector: #indexOfSubCollection:startingAt:.
	self
		value:[(cos at: #abcd) indexOfSubCollection:(cos at:#bc) startingAt:3]
	    should: [:r | r = 0]
		conformTo: #sequencedReadableCollection
		selector: #indexOfSubCollection:startingAt:.!

testXfirst
	" <sequencedReadableCollection>#first "
	| cos a |
	cos := self canonicalObjects.
	a := (cos at: #a) at: 1.
	self
		value:[(cos at: #abcd) first]
	    should: [:r | r = a]
		conformTo: #sequencedReadableCollection
		selector: #first.!

testXafterX
	" <sequencedReadableCollection>#after: "
	| co |
	co := self canonicalObject.
	self value: [co after: (co at: 2)]
		should: [:r | r = (co at: 3)]
		conformTo: #sequencedReadableCollection
		selector: #after:!

testXlast
	" <sequencedReadableCollection>#last "
	| cos d |
	cos := self canonicalObjects.
	d := (cos at: #d) at: 1.
	self
		value:[(cos at: #abcd) last]
	    should: [:r | r = d]
		conformTo: #sequencedReadableCollection
		selector: #last.!

testXcopyFromXtoX
	" <sequencedReadableCollection>#copyFrom:to: (Return Values: <RECEIVER>)"

	| cos |
	cos := self canonicalObjects.
	self value: [(cos at: #abcd) copyFrom: 2 to: 3]
		should: [:r | r = (cos at: #bc)]
		conformTo: #sequencedReadableCollection
		selector: #copyFrom:to:.
	self value: [(cos at: #abcd) copyFrom: 3 to: 2]
		should: [:r | r isEmpty]
		conformTo: #sequencedReadableCollection
		selector: #copyFrom:to:!

testXequalityOp
	" <sequencedReadableCollection>#= "
	| copy cos |
	cos := self canonicalObjects.
	copy := (cos at: #abc) copy.
	self
		value:[(cos at:#abc) = copy]
	    should: [:r | r]
		conformTo: #sequencedReadableCollection
		selector: #=.
	self
		value:[(cos at:#ab) = copy]
	    shouldnt: [:r | r]
		conformTo: #sequencedReadableCollection
		selector: #=!

testXindexOfSubCollectionXstartingAtXifAbsentX
	" <sequencedReadableCollection>#indexOfSubCollection:startingAt:ifAbsent: "
	| cos |
	cos := self canonicalObjects.
	self
		value:[(cos at: #abcd) indexOfSubCollection:(cos at:#bc) startingAt:1 ifAbsent:[nil] ]
	    should: [:r | r = 2]
		conformTo: #sequencedReadableCollection
		selector: #indexOfSubCollection:startingAt:ifAbsent:.
	self
		value:[(cos at: #abcd) indexOfSubCollection:(cos at:#bc) startingAt:3 ifAbsent:[nil]]
	    should: [:r | r isNil]
		conformTo: #sequencedReadableCollection
		selector: #indexOfSubCollection:startingAt:ifAbsent:.!

testXreverseDoX
	" <sequencedReadableCollection>#reverseDo: "
	| col cos abc |
	cos := self canonicalObjects.
	abc := cos at:#abc.
	col := OrderedCollection new.
	self
		value: [abc reverseDo: [:e | col add: e]]
	    should: [:r | col = abc reverse asOrderedCollection]
		conformTo: #sequencedReadableCollection
		selector: #reverseDo:.!

testXcopyReplaceFromXtoXwithX
	" <sequencedReadableCollection>#copyReplaceFrom:to:with: (Return Values: <RECEIVER>)"

	| cos |
	cos := self canonicalObjects.
   self value:[(cos at:#abcd) copyReplaceFrom: 3 to: 2 with:(cos at:#bc)]
	    should: [:r | r = ((cos at:#ab), (cos at:#bc), (cos at:#cd))]
		conformTo: #sequencedReadableCollection
		selector: #copyReplaceFrom:to:with:.
   self value:[(cos at:#abcd) copyReplaceFrom: 5 to: 4 with:(cos at:#bc)]
	    should: [:r | r = ((cos at:#abcd), (cos at:#bc))]
		conformTo: #sequencedReadableCollection
		selector: #copyReplaceFrom:to:with:.
   self value:[(cos at:#abcd) copyReplaceFrom: 1 to: 3 with:(cos at:#bc)]
	    should: [:r | r = (cos at:#bcd)]
		conformTo: #sequencedReadableCollection
		selector: #copyReplaceFrom:to:with:.!

testXfromXtoXdoX
	" <sequencedReadableCollection>#from:to:do: "
	| co col |
	co := self canonicalObject.
	col := OrderedCollection new.
	self
		value: [co from: 1 to: co size do: [:e | col add: e]]
	    should: [:r | co asOrderedCollection = col]
		conformTo: #sequencedReadableCollection
		selector: #from:to:do:.!

testXcopyReplaceFromXtoXwithObjectX
	" <sequencedReadableCollection>#copyReplaceFrom:to:withObject: (Return Values: <RECEIVER>)"
	| cos c |
	cos := self canonicalObjects.
	c := (cos at:#c).
   self value:[(cos at:#abcd) copyReplaceFrom: 3 to: 2 withObject:((cos at:#b) at:1)]
	    should: [:r | r = ((cos at:#ab), (cos at:#bcd))]
		conformTo: #sequencedReadableCollection
		selector: #copyReplaceFrom:to:withObject:.
   self value:[(cos at:#abc) copyReplaceFrom: 4 to: 3 withObject:((cos at:#d) at:1)]
	    should: [:r | r = (cos at:#abcd)]
		conformTo: #sequencedReadableCollection
		selector: #copyReplaceFrom:to:withObject:.
   self value:[(cos at:#abc) copyReplaceFrom: 1 to: 2 withObject:(c at:1)]
	    should: [:r | r = (c, c, c)]
		conformTo: #sequencedReadableCollection
		selector: #copyReplaceFrom:to:withObject:.!

testXatX
	" <sequencedReadableCollection>#at: "
	| cos b |
	cos := self canonicalObjects.
	b := (cos at:#b) at:1.
	self value: [(cos at:#abcd) at: 2]
		should: [:r | r = b]
		conformTo: #sequencedReadableCollection
		selector: #at:!

testXbeforeX
	" <sequencedReadableCollection>#before: "

	| co |
	co := self canonicalObject.
	self value: [co before: (co at: 3)]
		should: [:r | r = (co at: 2)]
		conformTo: #sequencedReadableCollection
		selector: #after:!

canonicalObjects
"answer a dictionary of subsequences of the canonical object"
	| can cl |
	can := testCase canonicalObject.
	cl := can species. 
	^(Dictionary new) at: #a put: (cl with: (can at: 1));
		at: #b put: (cl with: (can at: 2));
		at: #c put: (cl with: (can at: 3));
		at: #d put: (cl with: (can at: 4));
		at: #ab put: (cl with: (can at: 1) with: (can at: 2));
		at: #bc put: (cl with: (can at: 2) with: (can at: 3));
		at: #cd put: (cl with: (can at: 3) with: (can at: 4));
		at: #abc put: (cl with: (can at: 1) with: (can at: 2) with: (can at: 3));
		at: #bcd put: (cl with: (can at: 2) with: (can at: 3) with: (can at: 4));
		at: #abcd put: (cl with: (can at: 1) with: (can at: 2) with: (can at: 3) with:(can at: 4));
		yourself!

testXcopyWithoutX
	" <sequencedReadableCollection>#copyWithout: (Return Values: <RECEIVER>)"
	| cos c a b |
	cos := self canonicalObjects.
	a := cos at:#a.
	b := cos at:#b.
	c := cos at:#c.
   self value:[(cos at:#abc) copyWithout:(b at:1)]
	    should: [:r | r = (a, c)]
		conformTo: #sequencedReadableCollection
		selector: #copyWithout:!

testXreverse
	" <sequencedReadableCollection>#reverse (Return Values: <RECEIVER>)"

	| cos abc |
	cos := self canonicalObjects.
	abc := cos at:#abc.
	self
		value: [abc reverse]
		should:
			[:r |
			r size = 3 and:
				[((r at: 1) = (abc at: 3)) and:
					[(r at: 3) = (abc at: 1)]]]
		conformTo: #sequencedReadableCollection
		selector: #reverse! !

!StringANSITest methodsFor: nil!

testXgreaterThanOrEqualToOp
	" <readableString>#>= "
	#'Collection'.!

limitedElementTypes

	^1!

testXsameAsX
	" <readableString>#sameAs: "
	#'Collection'.!

canonicalElement

	^self canonicalObject at: 2!

testXasUppercase
	" <readableString>#asUppercase "
	#'Collection'.!

testXsubStringsX
	" <readableString>#subStrings: "
	#'Collection'.!

returnTypeHasLimitedElementTypes

	^true!

canonicalObject
	^'abcd'!

testXminX
	" <magnitude>#min: "
	#'Collection'.!

testXlessThanOp
	" <readableString>#< "
	#'Collection'.!

testXlessThanOrEqualToOp
	" <readableString>#<= "
	#'Collection'.!

protocol
	^#String!

testXasSymbol
	" <readableString>#asSymbol "
	#'Collection'.!

testXasString
	" <String>#asString "
	#'Collection'.!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Collection'.!

emptyCollection

	^self canonicalObject class new!

testXasLowercase
	" <readableString>#asLowercase "
	#'Collection'.!

testXmaxX
	" <magnitude>#max: "
	#'Collection'.!

testXgreaterThanOp
	" <readableString>#> "
	#'Collection'.! !

!StringANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: SequencedCollectionHelper.
	aBlock value: SequencedReadableCollectionHelper! !

!FloatANSITest methodsFor: nil!

testXlessThanOrEqualToOp
	" <magnitude>#<= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small <= Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3 <= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [-2000000005.0 <= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [0.25 <= (1/2)] should: [:r | r]
		conformTo: #'magnitude' selector: #'<='.

	"Num <= Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) <= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'<='
	].

	"Big <= Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0 <= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'<='
	].
	self value: [9000000000.0 <= 2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [-1000000005.0 <= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.
	self value: [9.0 <= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'<='.!

testXisMemberOfX
	" <Object>#isMemberOf: "
	#'Numeric'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
		#'Fundamental'.
#todo. "Fix find a test for unspecified rule above ???"
	self value: [float2 isMemberOf: FloatD]
		should: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	"Metaclass tests:"
	self value: [float2 class isMemberOf: (FloatD class)]
		should: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	"Fail inherit tests:"
	self value: [float2 class isMemberOf: (Number class)]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.

	self value: [float2 isMemberOf: Symbol]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isMemberOf:'.!

testXquoX
	" <number>#quo: "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(1 0 0 1 4 1 ).
	1 to: numList size do: [ :ndx |
		self value: [float2 quo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'.
	].

	retVals := #(-1 0 0 -1 -4 -1 ).
	1 to: numList size do: [ :ndx |
		self value: [float2 quo: ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'quo:'
	].

	self should: [(25.5 quo: 5.1) = 5].
	self should: [(25.5 quo: 5) = 5].
	self should: [(25500000000.5 quo: 5000000000) = 5].
	self should: [(-25500000000.5 quo: -5000000000) = 5].
	self should: [(25.5 quo: (51/10)) = 5].
	self should: [(25.5 quo: 5.1s1) = 5].

	self value: [0.0 quo: float2] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'quo:'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [float2 quo: 0.0] shouldRaise: ZeroDivide.!

testXnegated
	" <number>#negated (Return Values: <RECEIVER>) "
	| rcvr |
	#'Numeric'.
	rcvr := 2.0.
	self value: [rcvr negated] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.
	rcvr := -2.0.
	self value: [rcvr negated] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.
	rcvr := 0.0.
	self value: [rcvr negated] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'negated' opRECEIVER: rcvr.!

testXasFloatE
	" <number>#asFloatE "
	#'Numeric'.
	self value: [2.0 asFloatE] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [-2.0 asFloatE] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatE'.
	self value: [0.0 asFloatE] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatE'.!

testXraisedToIntegerX
	" <number>#raisedToInteger: (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 5.1.
	self value: [rcvr raisedToInteger: 0] should: [:r | r = 1.0]
		conformTo: #'number' selector: #'raisedToInteger:' opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 1] should: [:r | r = rcvr]
		conformTo: #'number' selector: #'raisedToInteger:' opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: 2] should: [:r | r closeTo: 26.01]
		conformTo: #'number' selector: #'raisedToInteger:' opRECEIVER: rcvr.

	self value: [rcvr negated raisedToInteger: 2] should: [:r | r closeTo: 26.01]
		conformTo: #'number' selector: #'raisedToInteger:' opRECEIVER: rcvr.

	self value: [rcvr raisedToInteger: -2]
		should: [:r | r closeTo: 0.0384467512495194]
		conformTo: #'number' selector: #'raisedToInteger:' opRECEIVER: rcvr.!

testXstrictlyPositive
	" <number>#strictlyPositive "
	#'Numeric'.
	self value: [2.0 strictlyPositive] should: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.

	self value: [0.0 strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.
	self value: [-2.0 strictlyPositive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'strictlyPositive'.!

testXfloorLogX
	" <Float>#floorLog: "
	#'Numeric'.!

testXpositive
	" <number>#positive "
	#'Numeric'.
	self value: [2.0 positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [0.0 positive] should: [:r | r]
		conformTo: #'number' selector: #'positive'.
	self value: [-2.0 positive] shouldnt: [:r | r]
		conformTo: #'number' selector: #'positive'.!

testXradiansToDegrees
	" <Float>#radiansToDegrees "
	#'Numeric'.!

testXintegerPart
	" <number>#integerPart (returnRule - :receiver) "
	| rcvr |
	#'Numeric'.
	rcvr := 2.5.
	self value: [rcvr integerPart] should: [:result | result = 2.0]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := 2.0.
	self value: [rcvr integerPart] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := -2.0.
	self value: [rcvr integerPart] should: [:result | result = -2.0]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.

	rcvr := 0.0.
	self value: [rcvr integerPart] should: [:result | result = 0.0]
		conformTo: #'number' selector: #'integerPart' ruleReceiver: rcvr.!

testXsin
	" <Float>#sin "
	#'Numeric'.!

testXcopy
	" <Object>#copy (Return Values: <RECEIVER>) "
	#'Numeric'.
"	Return a new object that must be as similar as possible to the receiver in its initial state and behavior.  Any operation that changes the state of the new object should not as a side-effect change the state or behavior of the receiver.  Similarly, any change to the receiver should not as a side-effect change the new object.
	If the receiver is an identity object, return the receiver.
"
#todo. "??? add change-side-effect test ???"
	self value: [float2 copy] should: [:r | (r = float2) ]
		conformTo: #'Object' selector: #'copy' opRECEIVER: float2.!

testXreciprocal
	" <number>#reciprocal (returnRule - :receiver) "
	#'Numeric'.
	self value: [float2 reciprocal] should: [:r | r = (1.0/float2)]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: float2.

	self value: [float2 negated reciprocal]
		should: [:r | r = (1.0/(float2 negated))]
		conformTo: #'number' selector: #'reciprocal'
		ruleReceiver: (float2 negated).

	"Signal a ZeroDivide exception if the receiver is equal to zero."
	self value: [0.0 reciprocal] shouldRaise: ZeroDivide.!

testXasScaledDecimalX
	" <number>#asScaledDecimal: "
	#'Numeric'.
	self value: [2.0 asScaledDecimal: 2]
		should: [:r | r = 2.0s2 & (r scale = 2)]
		conformTo: #'number' selector: #'asScaledDecimal:'.
	self value: [-2.0 asScaledDecimal: 2]
		should: [:r | r = -2.0s2 & (r scale = 2)]
		conformTo: #'number' selector: #'asScaledDecimal:'.
	self value: [0.0 asScaledDecimal: 2]
		should: [:r | r = 0.0s2 & (r scale = 2)]
		conformTo: #'number' selector: #'asScaledDecimal:'.!

testXaddOp
	" <number>#+ (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(4.0 -1999999998.0 2000000002.0 4.0 2.5 4.0).
	1 to: numList size do: [ :ndx |
		self value: [float2 + (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'+'
			ruleReceiver: float2 operand: (numList at: ndx)
	].!

testXasFraction
	" <number>#asFraction "
	#'Numeric'.
	self value: [2.0 asFraction] should: [:r | r = 2]
		conformTo: #'number' selector: #'asFraction'.
	self value: [-2.5 asFraction] should: [:r | r = (-5/2)]
		conformTo: #'number' selector: #'asFraction'.
	self value: [0.0 asFraction] should: [:r | r = 0]
		conformTo: #'number' selector: #'asFraction'.!

testXgreaterThanOp
	" <number>#> "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small > Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3 > tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [-2000000005.0 > -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [0.25 > (1/2)] shouldnt: [:r | r]
		conformTo: #'number' selector: #'>'.

	"Num > Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) > (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'>'
	].

	"Big > Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0 > tstNum] should: [:r | r]
			conformTo: #'number' selector: #'>'
	].
	self value: [9000000000.0 > 2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [-1000000005.0 > -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'>'.
	self value: [9.0 > (1/2)] should: [:r | r] conformTo: #'number' selector: #'>'.!

testXexp
	" <Float>#exp "
	#'Numeric'.!

protocol
	^#'Float'!

testXmultiplyOp
	" <number>#* (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(4.0 -4000000000.0 4000000000.0 4.0 1.0 4.0).
	1 to: numList size do: [ :ndx |
		self value: [float2 * (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'*'
			ruleReceiver: float2 operand: (numList at: ndx)
	].!

testXsign
	" <number>#sign "
	#'Numeric'.
	self value: [2.0 sign] should: [:r | r = 1]
		conformTo: #'number' selector: #'sign'.
	self value: [0.0 sign] should: [:r | r = 0]
		conformTo: #'number' selector: #'sign'.
	self value: [-2.0 sign] should: [:r | r = -1]
		conformTo: #'number' selector: #'sign'.!

testXidentityOp
	" <Object>#== "
	#'Numeric'.
"	The value of receiver == comparand is true if and only if the value of comparand == receiver would also be true. If the value of receiver == comparand is true then the receiver and comparand must have equivalent identity hash values.  Or more formally:

	receiver == comparand =>
	receiver identityHash = comparand identityHash
"
	self shouldnt: [smallInt2 == float2].
	self shouldnt: [smallInt2 identityHash == float2 identityHash].

	self value: [float2 == float2]
		should: [:r | r] conformTo: #'Object' selector: #'=='.

	self value: [float2 == 2.1]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'=='.!

testXequalityOp
	" <Float>#= "
	#'Numeric'.
"
	receiver = comparand	=>
	receiver hash = comparand hash
"
	self value: [float2 = float2]
		should: [:r | r & (float2 hash = float2 hash) ]
		conformTo: #'Float' selector: #'='.
	self value: [ float2 = 2.1 ]
		shouldnt: [ :r | r | (float2 hash = 2.1 hash) ]
		conformTo: #'Float' selector: #'='.

"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	self value: [ float2 = 2 ]
		should: [ :r | r  ifTrue: [ float2 hash = 2 hash ]
							ifFalse: [ float2 hash ~= 2 hash ]  ]
		conformTo: #'Float' selector: #'='.
	self value: [ -2000000000.0 = -2000000000 ]
		should: [ :r | r ifTrue: [ -2000000000.0 hash = -2000000000 hash ]
						ifFalse: [ -2000000000.0 hash ~= -2000000000 hash ]  ]
		conformTo: #'Float' selector: #'='.

	self value: [ 2000000000.0 = 2000000000 ]
		should: [ :r | r ifTrue: [ 2000000000.0 hash = 2000000000 hash ]
						ifFalse: [ 2000000000.0 hash ~= 2000000000 hash ]  ]
		conformTo: #'Float' selector: #'='.
	self value: [ 2.5 = (5/2) ]
		should: [ :r | r ifTrue: [ 2.5 hash = (5/2) hash ]
						ifFalse: [ 2.5 hash ~= (5/2) hash ]  ]
		conformTo: #'Float' selector: #'='.
	self value: [ float2 = 2.0s3 ]
		should: [ :r | r ifTrue: [ float2 hash = 2.0s3 hash ]
						ifFalse: [ float2 hash ~= 2.0s3 hash ]  ]
		conformTo: #'Float' selector: #'='.!

testXraisedToX
	" <number>#raisedTo: "
	| numVals retVals |
	#'Numeric'.
	numVals := #(2 2.0 0 2.0s3 ) copy.
	numVals at: 3 put: (1/2).
	retVals := #(4.0 4.0 1.414213562373095 4.0 ).
	1 to: numVals size do: [ :ndx |
		self value: [float2 raisedTo: (numVals at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'.
	].


	retVals := #(0.25 0.25 0.7071067811865475 0.25).
	1 to: numVals size do: [ :ndx |
		self value: [float2 raisedTo: ((numVals at: ndx) negated)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'raisedTo:'
	].

	self value: [float2 raisedTo: 0.0] should: [:r | r = 1.0]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [0.0 raisedTo: float2] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'raisedTo:'.

	self value: [float2 raisedTo: 1.0] should: [:r | r = float2]
		conformTo: #'number' selector: #'raisedTo:'.

	"It is erroneous if the receiver equals zero
		and the operand is less than or equal to zero,"
	self value: [0.0 raisedTo: -2] shouldRaise: Error.

	"	or if the receiver is less than zero."
	self value: [float2 negated raisedTo: 2.0]
		shouldRaise: Error.!

testLiterals
	#'Numeric'.
	self should: [1.1e1 = 11.0].
	self should: [1.1d1 = 11.0].
	self should: [1.1q1 = 11.0].
	"Not ANSI conforming:"
#todo. "??? fix ???"
"	self shouldnt: [1.0q = 1.0].
	self shouldnt: [10e10 = 1.0].
"!

testXceiling
	" <number>#ceiling "
	#'Numeric'.
	self value: [2.0 ceiling] should: [:r | r = 2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [2.1 ceiling] should: [:r | r = 3]
		conformTo: #'number' selector: #'ceiling'.
	self value: [2.5 ceiling] should: [:r | r = 3]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2.0 ceiling] should: [:r | r = -2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2.1 ceiling] should: [:r | r = -2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [-2.5 ceiling] should: [:r | r = -2]
		conformTo: #'number' selector: #'ceiling'.
	self value: [0.0 ceiling] should: [:r | r = 0]
		conformTo: #'number' selector: #'ceiling'.!

testXarcTan
	" <Float>#arcTan "
	#'Numeric'.!

testXrounded
	" <number>#rounded "
	#'Numeric'.
	self value: [2.0 rounded] should: [:r | r = 2]
		conformTo: #'number' selector: #'rounded'.
	self value: [2.1 rounded] should: [:r | r = 2]
		conformTo: #'number' selector: #'rounded'.
	self value: [2.5 rounded] should: [:r | r = 3]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2.0 rounded] should: [:r | r = -2]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2.1 rounded] should: [:r | r = -2]
		conformTo: #'number' selector: #'rounded'.
	self value: [-2.5 rounded] should: [:r | r = -3]
		conformTo: #'number' selector: #'rounded'.
	self value: [0.0 rounded] should: [:r | r = 0]
		conformTo: #'number' selector: #'rounded'.!

testXarcSin
	" <Float>#arcSin "
	#'Numeric'.!

testXdivideOp
	" <number>#/ (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(1.0 -1.0e-9 1.0e-9 1.0 4.0  1.0).
	1 to: numList size do: [ :ndx |
		self value: [float2 / (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'/'
			ruleReceiver: float2 operand: (numList at: ndx)
	].

	self value: [0.0 / float2] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'/'
		ruleReceiver: float2 operand: 0.0!

testXarcCos
	" <Float>#arcCos "
	#'Numeric'.!

testXasFloatD
	" <number>#asFloatD "
	#'Numeric'.
	self value: [2.0 asFloatD] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [-2.0 asFloatD] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatD'.
	self value: [0.0 asFloatD] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatD'.!

testXlogX
	" <Float>#log: "
	#'Numeric'.!

testXln
	" <Float>#ln "
	#'Numeric'.!

testXhash
	" <Object>#hash "
	#'Numeric'.
"	Any two objects that are considered equivalent using the #= message must have the same hash value.  More formally:

	receiver = comparand	=>
	receiver hash = comparand hash
"
	self value: [float2 hash]
		should: [:r | r = float2 hash] conformTo: #'Object' selector: #'hash'.
	self value: [float2 hash]
		shouldnt: [:r | r = 2.1 hash] conformTo: #'Object' selector: #'hash'.!

testXlessThanOp
	" <number>#< "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."

#'todo'."It is erroneous if the receiver and operand are not comparable."
	"Small < Big -> true"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3 < tstNum] should: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [-2000000005.0 < -2000000000] should: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [0.25 < (1/2)] should: [:r | r] conformTo: #'number' selector: #'<'.

	"Num < Num -> false"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) < (numList at: ndx)]
			shouldnt: [:r | r ] conformTo: #'number' selector: #'<'
	].

	"Big < Small -> false"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0 < tstNum] shouldnt: [:r | r]
			conformTo: #'number' selector: #'<'
	].
	self value: [9000000000.0 < 2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [-1000000005.0 < -2000000000] shouldnt: [:r | r]
		conformTo: #'number' selector: #'<'.
	self value: [9.0 < (1/2)] shouldnt: [:r | r] conformTo: #'number' selector: #'<'.!

testXfloor
	" <number>#floor "
	#'Numeric'.
	self value: [2.0 floor] should: [:r | r = 2]
		conformTo: #'number' selector: #'floor'.
	self value: [2.1 floor] should: [:r | r = 2]
		conformTo: #'number' selector: #'floor'.
	self value: [2.5 floor] should: [:r | r = 2]
		conformTo: #'number' selector: #'floor'.
	self value: [-2.0 floor] should: [:r | r = -2]
		conformTo: #'number' selector: #'floor'.
	self value: [-2.1 floor] should: [:r | r = -3]
		conformTo: #'number' selector: #'floor'.
	self value: [-2.5 floor] should: [:r | r = -3]
		conformTo: #'number' selector: #'floor'.
	self value: [0.0 floor] should: [:r | r = 0]
		conformTo: #'number' selector: #'floor'.!

testXtruncated
	" <number>#truncated "
	#'Numeric'.
	self value: [2.0 truncated] should: [:r | r = 2]
		conformTo: #'number' selector: #'truncated'.
	self value: [2.1 truncated] should: [:r | r = 2]
		conformTo: #'number' selector: #'truncated'.
	self value: [2.5 truncated] should: [:r | r = 2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2.0 truncated] should: [:r | r = -2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2.1 truncated] should: [:r | r = -2]
		conformTo: #'number' selector: #'truncated'.
	self value: [-2.5 truncated] should: [:r | r = -2]
		conformTo: #'number' selector: #'truncated'.
	self value: [0.0 truncated] should: [:r | r = 0]
		conformTo: #'number' selector: #'truncated'.!

testXsquared
	" <number>#squared (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	rcvr := 5.1.
	self value: [rcvr squared] should: [:r | r closeTo: 26.01]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.

	rcvr := -5.1.
	self value: [rcvr squared] should: [:r | r closeTo: 26.01]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.
	rcvr := 0.0.
	self value: [rcvr squared] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'squared' opRECEIVER: rcvr.!

testXnotIdentityOp
	" <Object>#~~ "
	#'Numeric'.
"	The value of receiver ~~ comparand is true if and only if the value of comparand ~~ receiver would also be true.
"
	self should: [smallInt2 ~~ float2 and: [float2 ~~ smallInt2]].

	self value: [float2 ~~ 2.1] should: [:r | r]
		conformTo: #'Object' selector: #'~~'.

	self value: [float2 ~~ float2] shouldnt: [:r | r]
		conformTo: #'Object' selector: #'~~'.!

testXdegreesToRadians
	" <Float>#degreesToRadians "
	#'Numeric'.!

testXasFloatQ
	" <number>#asFloatQ "
	#'Numeric'.
	self value: [2.0 asFloatQ] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [-2.0 asFloatQ] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloatQ'.
	self value: [0.0 asFloatQ] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloatQ'.!

testXsubtractOp
	" <number>#- (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(0.0 2000000002.0 -1999999998.0 0.0 1.5 0.0).
	1 to: numList size do: [ :ndx |
		self value: [float2 - (numList at: ndx)]
			should: [:r | r closeTo: (retVals at: ndx)]
			conformTo: #'number' selector: #'-'
			ruleReceiver: float2 operand: (numList at: ndx)
	].!

testXisKindOfX
	" <Object>#isKindOf: "
	#'Numeric'.
"	The return value is unspecified if the receiver is a class object or candidateClass is not a class object.
"
#todo. "Fix find a test for unspecified rule above ???"
	self value: [float2 isKindOf: Float]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Metaclass tests:"
	self value: [float2 class isKindOf: (Float class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	"Inherit tests:"
	self value: [float2 class isKindOf: (Number class)]
		should: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.

	self value: [float2 isKindOf: Symbol]
		shouldnt: [:r | r] conformTo: #'Object' selector: #'isKindOf:'.!

testXcos
	" <Float>#cos "
	#'Numeric'.!

testXprintString
	" <Float>#printString "
	#'Numeric'.
	"Answer a string which is a valid Smalltalk literal representation approximately equal to the receiver. An exponent literal form is produced if the value of the exponent is greater than the precision of the receiver."

	self value: [(2.0e0 raisedToInteger: 1.0e0 class precision + 1) printString ]
		should: [:r | r includes: $e ]
		conformTo: #'Float' selector: #'printString'.
	self value: [(-2.0e0 raisedToInteger: 1.0e0 class precision + 1) printString ]
		should: [:r | r includes: $e ]
		conformTo: #'Float' selector: #'printString'.
	self value: [(2.0e0 raisedToInteger: -1 - 1.0e0 class precision) printString ]
		should: [:r | r includes: $e ]
		conformTo: #'Float' selector: #'printString'.
	self value: [(-2.0e0 raisedToInteger: -1 - 1.0e0 class precision) printString ]
		 should: [:r | r includes: $e ]
		conformTo: #'Float' selector: #'printString'!

testXminX
	" <magnitude>#min: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [2.0 min: 1] should: [:r | r = 1]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [-1000000000.0 min: -2000000000] should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2000000003.0 min: 2000000001] should: [:r | r = 2000000001]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2.0 min: 1.0] should: [:r | r = 1.0]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2.0 min: (3/2)] should: [:r | r = (3/2)]
		conformTo: #'magnitude' selector: #'min:'.
	self value: [2.0 min: 1.0s5] should: [:r | r = 1.0s5]
		conformTo: #'magnitude' selector: #'min:'.

	"Num min: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) min: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'min:'
	].!

testXroundToX
	" <number>#roundTo: (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(2 0 0 2.0 2 2.000s3).
	1 to: numList size do: [ :ndx |
		self value: [float2 roundTo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'roundTo:'
			ruleReceiver: float2 operand: (numList at: ndx)
	].

	self should: [(0.0 roundTo: float2) = 0.0]!

testXremainderIntegerDivideOp
	" <number>#\\ (returnRule - :receiver :operand) "
	"The remainder has the same sign as operand.
	Within the limits of representation, the following invariant should hold:

		(receiver // operand) * operand + (receiver \\ operand) = receiver
 "
	| retVals recList ndx |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	recList := #( 26 -26000000001 26000000001 26.0 0 26.0s3 ) copy.
	recList at: 5 put: (53/2).
	retVals := #(1.0 4.0 1.0 1.0 1.5 1.0 ).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ 5.0]
			should: [:r | r = (retVals at: ndx)
					& ((rec // 5.0) * 5.0 + (rec \\ 5.0) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  5.0.
	].

	"The remainder has the same sign as operand."
	retVals := #(-4.0 -1.0 -4.0 -4.0 -3.5 -4.0 ).
	ndx := 0.
	recList do: [ :rec |
		ndx := ndx + 1.
		self value: [rec \\ -5.0]
			should: [:r | r = (retVals at: ndx)
					& ((rec // -5.0) * -5.0 + (rec \\ -5.0) = rec)]
			conformTo: #'number' selector: #'\\'
			ruleReceiver: rec operand:  -5.0.
	].

	self should: [26.5 \\ 5.0 = 1.5 & ((26.5 // 5.0) * 5.0 + (26.5 \\ 5.0) = 26.5)].
	self should: [26.5 \\ -5.0 = -3.5
					& ((26.5 // -5.0) * -5.0 + (26.5 \\ -5.0) = 26.5)].

	self should: [0.0 \\ float2 = 0.0].

	"If the operand is zero, the implementation may signal
		the ZeroDivide exception or provide a continuation value."
	self value: [float2 \\ 0.0] shouldRaise: ZeroDivide.!

testXnegative
	" <number>#negative "
	#'Numeric'.
	self value: [-2.0 negative] should: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [2.0 negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.
	self value: [0.0 negative] shouldnt: [:r | r]
		conformTo: #'number' selector: #'negative'.!

testXtan
	" <Float>#tan "
	#'Numeric'.!

canonicalObject
	^Float pi   "3.141592653589793"!

testXabs
	" <number>#abs (Return Values: <RECEIVER>) "
	| rcvr |
	#'Numeric'.
	rcvr := 2.0.
	self value: [rcvr abs] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := -2.0.
	self value: [rcvr abs] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.
	rcvr := 0.0.
	self value: [rcvr abs] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'abs' opRECEIVER: rcvr.!

testXintegerDivideOp
	" <number>#// "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	"The sign of the result is positive if the receiver and operand
		have the same sign, and negative if the signs are different."
	retVals := #(1 -1 0 1 4 1).
	1 to: numList size do: [ :ndx |
		self value: [float2 // (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'.
	].

	retVals := #(-1 0 -1 -1 -4 -1).
	1 to: numList size do: [ :ndx |
		self value: [float2 // ((numList at: ndx) negated)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'//'
	].


	self should: [25.5 // 5.1 = 5].
	self should: [25.5 // 5 = 5].
	self should: [25500000000.5 // 5000000000 = 5].
	self should: [-25500000000.5 // -5000000000 = 5].
	self should: [25.5 // (51/10) = 5].
	self should: [25.5 // 5.1s1 = 5].

	self value: [0.0 // float2] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'//'.

	"If the operand has a value of zero the ZeroDivide exception is signaled."
	self value: [float2 // 0.0] shouldRaise: ZeroDivide.!

testXasInteger
	" <number>#asInteger "
	#'Numeric'.
	self value: [2.0 asInteger] should: [:r | r = 2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [2.1 asInteger] should: [:r | r = 2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [2.5 asInteger] should: [:r | r = 3]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2.0 asInteger] should: [:r | r = -2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2.1 asInteger] should: [:r | r = -2]
		conformTo: #'number' selector: #'asInteger'.
	self value: [-2.5 asInteger] should: [:r | r = -3]
		conformTo: #'number' selector: #'asInteger'.
	self value: [0.0 asInteger] should: [:r | r = 0]
		conformTo: #'number' selector: #'asInteger'.!

testXgreaterThanOrEqualToOp
	" <magnitude>#>= "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	"Small >= Big -> false"
	#( 2 2000000000 2.0 2.0s3 ) do: [ :tstNum |
		self value: [0.3 >= tstNum] shouldnt: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [-2000000005.0 >= -2000000000] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [0.25 >= (1/2)] shouldnt: [:r | r]
		conformTo: #'magnitude' selector: #'>='.

	"Num >= Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) >= (numList at: ndx)]
			should: [:r | r ] conformTo: #'magnitude' selector: #'>='
	].

	"Big >= Small -> true"
	#( 2 2.0 2.0s3 ) do: [ :tstNum |
		self value: [5.0 >= tstNum] should: [:r | r]
			conformTo: #'magnitude' selector: #'>='
	].
	self value: [9000000000.0 >= 2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [-1000000005.0 >= -2000000000] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.
	self value: [9.0 >= (1/2)] should: [:r | r]
		conformTo: #'magnitude' selector: #'>='.!

testXremX
	" <number>#rem: "
	| num2 flt |
	#'Numeric'.
	"Within the limits of representation, the following invariant should hold:
		(receiver quo: operand)*operand + (receiver rem: operand) = receiver"
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	numList := #( 5 5.0 5.0s3 ).
	flt := 26.5.
	numList do: [ :num |
		self value: [flt rem: num]
			should: [:r | r = 1.5
					& ((flt quo: num) * num + (flt rem: num) = flt)]
			conformTo: #'number' selector: #'rem:'
	].

	numList := numList collect: [ :num | num negated ].
	numList do: [ :num |
		self value: [flt rem: num]
			should: [:r | r = 1.5
					& ((flt quo: num) * num + (flt rem: num) = flt)]
			conformTo: #'number' selector: #'rem:'
	].

	numList := #( 5 5.0 5.0s3 ).
	flt := -26.5.
	numList do: [ :num |
		self should: [(flt rem: num) = -1.5
				& ((flt quo: num) * num + (flt rem: num) = flt)]
	].

	numList := numList collect: [ :num | num negated ].
	numList do: [ :num |
		self should: [(flt rem: num) = -1.5
					& ((flt quo: num) * num + (flt rem: num) = flt)]
	].

	flt := 26.5.
	num2 := (5/2).
	self value: [flt rem: num2]
		should: [:r | r = 1.5
				& ((flt quo: num2) * num2 + (flt rem: num2) = flt)]
		conformTo: #'number' selector: #'rem:'.

	numList := #( -2000000000 2000000000 ).
	flt :=  10000000001.5.
	numList do: [ :num |
		self value: [flt rem: num]
			should: [:r | r = 1.5
					& ((flt quo: num) * num + (flt rem: num) = flt)]
			conformTo: #'number' selector: #'rem:'
	].

	"If either the receiver or operand are of type <Float> and the operand has a value of zero, the result is implementation defined.  The implementation may signal the ZeroDivide exception or provide a continuation value "
	self value: [float2 rem: 0.0] shouldRaise: ZeroDivide.
	self value: [float2 rem: 0] shouldRaise: ZeroDivide.
	self value: [2 rem: 0.0] shouldRaise: ZeroDivide.!

testXidentityHash
	" <Object>#identityHash "
	#'Numeric'.
	self value: [float2 identityHash]
		should: [:r | r = float2 identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self value: [float2 identityHash]
		shouldnt: [:r | r = 2.1 identityHash]
		conformTo: #'Object' selector: #'identityHash'.

	self shouldnt: [smallInt2 identityHash = float2 identityHash].!

testXsqrt
	" <number>#sqrt "
	#'Numeric'.
	self value: [26.01 sqrt] should: [:r | r closeTo: 5.1]
		conformTo: #'number' selector: #'sqrt'.
	self value: [4.0 sqrt] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'sqrt'.
	self value: [0.0 sqrt] should: [:r | r =  0.0]
		conformTo: #'number' selector: #'sqrt'!

testXmaxX
	" <magnitude>#max: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver and operand are not comparable."

	self value: [2.0 max: 3] should: [:r | r = 3]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [-3000000000.0 max: -2000000000] should: [:r | r = -2000000000]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2000000000.0 max: 2000000003] should: [:r | r = 2000000003]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2.0 max: 3.0] should: [:r | r = 3.0]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2.0 max: (5/2)] should: [:r | r = (5/2)]
		conformTo: #'magnitude' selector: #'max:'.
	self value: [2.0 max: 3.0s3] should: [:r | r = 3.0s3]
		conformTo: #'magnitude' selector: #'max:'.

	"Num max: Num -> Num"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx) max: (numList at: ndx)]
			should: [:r | r = (numList at: ndx)]
			conformTo: #'magnitude' selector: #'max:'
	].!

testXfractionPart
	" <number>#fractionPart (Return Values: <RECEIVER>)"
	| rcvr |
	#'Numeric'.
	"Within the limits of representation, the following invariants should hold:

		receiver integerPart + receiver fractionPart = receiver
		receiver \\1 = receiver fractionPart	(RAH - erroneous, add #'abs')
"
	rcvr := 26.5.
	self value: [rcvr fractionPart]
		should: [:r | r = 0.5 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := -26.5.
	self value: [rcvr fractionPart]
		should: [:r | r = -0.5 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := 26.0.
	self value: [rcvr fractionPart]
		should: [:r | r = 0.0 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.

	rcvr := 0.0.
	self value: [rcvr fractionPart]
		should: [:r | r = 0.0 & (rcvr integerPart + rcvr fractionPart = rcvr)
					& (rcvr \\ 1 = rcvr fractionPart abs)]
		conformTo: #'number' selector: #'fractionPart' opRECEIVER: rcvr.!

testXtoXdoX
	" <number>#to:do: "
	#'Numeric'.!

testXasFloat
	" <number>#asFloat "
	#'Numeric'.
	self value: [2.0 asFloat] should: [:r | r = 2.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [-2.0 asFloat] should: [:r | r = -2.0]
		conformTo: #'number' selector: #'asFloat'.
	self value: [0.0 asFloat] should: [:r | r = 0.0]
		conformTo: #'number' selector: #'asFloat'.!

testXtruncateToX
	" <number>#truncateTo: (returnRule - :receiver :operand) "
	| retVals |
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
	retVals := #(2 0 0 2.0 2 2.000s3).
	1 to: numList size do: [ :ndx |
		self value: [float2 truncateTo: (numList at: ndx)]
			should: [:r | r = (retVals at: ndx)]
			conformTo: #'number' selector: #'truncateTo:'
			ruleReceiver: float2 operand: (numList at: ndx)
	].

	self should: [(0.0 truncateTo: float2) = 0.0].!

testXbetweenXandX
	" <magnitude>#between:and: "
	#'Numeric'.
"	#( 2 -2000000000 2000000000 2.0 1/2 2.0s3 )."
#'todo'."It is erroneous if the receiver  and min or max are not comparable"

	self value: [2.0 between: 1 and: 3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [-2000000002.0 between: -2000000003 and: -2000000001]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2000000002.0 between: 2000000001 and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0 between: 1.0 and: 3.0]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0 between: (3/2) and: (5/2)]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0 between: 1.0s3 and: 3.0s3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	self value: [2.0 between: (3/2) and: 2000000003]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0 between: -2000000001 and: 3.0s3]
		should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"Num between: Num and: Num -> true"
	1 to: numList size do: [ :ndx |
		self value: [(numList at: ndx)
					between: (numList at: ndx)
					and: (numList at: ndx)]
			should: [:r | r] conformTo: #'magnitude' selector: #'between:and:'
	].

	self value: [2.0 between: 3 and: 4]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [-2000000000.0 between: -2000000003 and: -2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2000000000.0 between: 2000000003 and: 2000000005]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0 between: 3.0 and: 5.0]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0 between: (5/2) and: (7/2)]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.
	self value: [2.0 between: 3.0s3 and: 5.0s3]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.

	"??? min not min but max and vice versa -> false ???"
	self value: [2.0 between: 3 and: 1]
		shouldnt: [:r | r] conformTo: #'magnitude' selector: #'between:and:'.!

testXtoXbyXdoX
	" <number>#to:by:do: "
	#'Numeric'.!

setUp
	super setUp.
	smallInt2 := 2.
	largeNegInt2000000000 := -2000000000.
	largePosInt2000000000 := 2000000000.
	float2 := 2.0d0.
	fractionHalf := 1/2.
	sclDec2s3 := 2.0s3.
	numList := Array new: 6.
	numList at: 1 put: smallInt2.
	numList at: 2 put: largeNegInt2000000000.
	numList at: 3 put: largePosInt2000000000.
	numList at: 4 put: float2.
	numList at: 5 put: fractionHalf.

	numList at: 6 put: sclDec2s3.!

testXtoX
	" <number>#to: "
	| start middleNdx stop2 |
	#'Numeric'.
	start := 1.0.
	numList := #( 2 2.0 0 2.0s3 ) copy.
	numList at: 3 put: (5/2).
	numList do: [ :stop |
		self value: [start to: stop]
			should: [:r | (r size = 2)
					". . . the last element in the sequence . . . is . . .[:]
						receiver + ((stop - receiver) // 1)"
					& (r last = (start + ((stop - start) // 1)))
					"The elements conform to the receiver's protocol."
					& (r allSatisfy: [ :elem |
						elem class conformsToProtocolNamed: #'Float'])
			]
			conformTo: #'number' selector: #'to:'
	].

	stop2 := 2000000000.
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'Float'])
		]
		conformTo: #'number' selector: #'to:'.

	start := -2000000000.0.
	stop2 := -1.
	middleNdx := 1000000000.	"Check conformance of first, middle and last."
	self value: [start to: stop2]
		should: [:r | (r size = 2000000000)
				". . . the last element in the sequence . . . is . . .[:]
					receiver + ((stop - receiver) // 1)"
				& (r last = (start + ((stop2 - start) // 1)))
				"The elements conform to the receiver's protocol."
				& ((Array with: (r at: 1)
						with: (r at: middleNdx)
						with: (r at: 3)
				) allSatisfy: [ :elem |
					elem class conformsToProtocolNamed: #'Float'])
		]
		conformTo: #'number' selector: #'to:'.

	"The interval answered will be empty if the receiver is greater than stop."
	self value: [1.0 to: -1.0]
		should: [:r | (r isEmpty)] conformTo: #'number' selector: #'to:'!

testXtoXbyX
	" <number>#to:by: "
	#'Numeric'.! !

!NilANSITest methodsFor: nil!

protocol
	^#'nil'!

testXprintString
	" <nil>#printString "
	#'Fundamental'.
	self value: [nil printString] should: [:r | r = 'nil']
		conformTo: #'nil' selector: #'printString'.!

canonicalObject
	^nil! !

!ObjectClassANSITest methodsFor: nil!

protocol
	^#'Object class'!

testXsubclasses
	"2000/06/23 Harmon, R. Changed to fix missing class in second test."

	self value: [Number subclasses]
		should: [:r |
			 (r allSatisfy: [ :element |
				element class conformsToProtocolNamed: #'classDescription'
			]) & (r isEmpty not)
		]
		conformTo: #'classDescription' selector: #'subclasses'.

	self value: [Symbol subclasses]
		should: [:r |
			 r allSatisfy: [ :element |
				element class conformsToProtocolNamed: #'classDescription'
		]	]
		conformTo: #'classDescription' selector: #'subclasses'.!

testXallSubclasses
	" <classDescription>#allSubclasses "
	#'Fundamental'.
"	Each element of the result collection supports the protocol <classDescription>."
#todo. "can't tell of a class that must be present in ANSI ???"
	self value: [Number allSubclasses]
		should: [:r |
			 (r allSatisfy: [ :element |
				element class conformsToProtocolNamed: #'classDescription'
			]) & (r isEmpty not)
		]
		conformTo: #'classDescription' selector: #'allSubclasses'.
	self value: [Symbol allSubclasses]
		should: [:r |
			 r allSatisfy: [ :element |
				element class conformsToProtocolNamed: #'classDescription'
		]	]
		conformTo: #'classDescription' selector: #'allSubclasses'.!

testXname
	" <classDescription>#name "
	#'Fundamental'.
	self value: [Object name] should: [:r | r asString = 'Object']
		conformTo: #'classDescription' selector: #'name'.!

canonicalObject
	^Object!

testXsuperclass
	" <classDescription>#superclass "
	#'Fundamental'.
"	If the receiver is a class object, return the class objects defined by the class definitions from which the class definition of the receiver directly inherits.  If the class definition of the receiver has no superclasses, return nil."
	#'Fundamental'.
	self value: [Fraction superclass]
		should: [:r | 
			r isNil ifTrue: [
				r conformsToProtocolNamed: #'classDescription'
			] ifFalse: [
				r class conformsToProtocolNamed: #'classDescription'
		]	]
		conformTo: #'classDescription' selector: #'superclass'.

	self value: [Object superclass]
		should: [:r | 
			r isNil ifTrue: [
				r class class conformsToProtocolNamed: #'classDescription'
			] ifFalse: [
				r class conformsToProtocolNamed: #'classDescription'
		]	]
		conformTo: #'classDescription' selector: #'superclass'.!

testXallSuperclasses
	" <classDescription>#allSuperclasses "
	#'Fundamental'.
"	Each element of the result collection supports the protocol <classDescription>."
#todo. "can't tell of a class that must be present in ANSI ???"
	self value: [Fraction allSuperclasses]
		should: [:r |
			 (r allSatisfy: [ :element |
				element class conformsToProtocolNamed: #'classDescription'
			]) & (r isEmpty not)
		]
		conformTo: #'classDescription' selector: #'allSuperclasses'.

	self value: [Object allSuperclasses]
		should: [:r |
			 r allSatisfy: [ :element |
				element class conformsToProtocolNamed: #'classDescription'
		]	]
		conformTo: #'classDescription' selector: #'allSuperclasses'.!

testXnew
	" <Object class>#new "
	#'Fundamental'.
	self value: [Object new] should: [:r | r class = Object]
		conformTo: #'Object class' selector: #'new'.! !

!ArrayFactoryANSITest methodsFor: nil!

testXnew
	" <Array factory>#new "
	#'Collection'.!

testXwithXwithX
	" <Array factory>#with:with: "
	#'Collection'.!

testXwithX
	" <Array factory>#with: "
	#'Collection'.!

protocol
	^#'Array factory'!

testXnewX
	" <Array factory>#new: "
	#'Collection'.!

testXwithAllX
	" <Array factory>#withAll: "
	#'Collection'.!

canonicalObject
	^Array!

testXwithXwithXwithX
	" <Array factory>#with:with:with: "
	#'Collection'.!

canonicalObject
	^Array!

testXwithXwithXwithXwithX
	" <Array factory>#with:with:with:with: "
	#'Collection'.! !

!ProtocolSpec methodsFor: nil!

protocolDescription
	"Answer a description of the receiver."

	description isNil ifTrue: [
		^ self protocolManager defaultEmptyDescription].
	^ description!

displayOn: targetStream 
	"Append the receiver to targetStream in a format that a user would want to see."

	targetStream nextPut: $<;
	 nextPutAll: self protocolName;
	 nextPut: $>!

addUndefinedProtocolNamesInMsgSpec: aProtocolMsgSpec 
	"Private - ."

	aProtocolMsgSpec allReferredToProtocolNames do: [:protoName |
		(self protocolManager includesProtocolNamed: protoName asSymbol)
			ifFalse: [self protocolManager addUndefinedProtocolName: protoName asSymbol]]!

setProtocolName: protocolName 
	"Private - ."

	name := protocolName!

addAllMessages: protocolMsgSpecList 
	"Add if not already present all the protocol messages in the list, protocolMsgSpecList, to the set of messages included in the receiver's protocol.
	Note: protocolMsgSpecList must be a <collection> of <protocolMessageSpec>s,"

	protocolMsgSpecList do: [:msgSpec | self addMessage: msgSpec]!

<= comperand 
	"Answer whether the receiver is less than or equal to comperand. 
	Note: This is to allow protocols to be sorted with the default sort block."

	(comperand isKindOf: self protocolManager protocol)
		| (comperand isKindOf: self protocolManager protocolANY) ifFalse: [self error: 'Comperand not a ProtocolSpec.'].
	^ self protocolName asLowercase <= comperand protocolName asLowercase!

removeSelector: selector ifAbsent: notFoundBlock 
	"Answer the message with selector, selector, after removing it from the receiver."
	| aProtocolMsgSpec |
	aProtocolMsgSpec := messageSpecifications
		detect: [:msgSpec | msgSpec messageSelector = selector]
		ifNone: [^ notFoundBlock value].
	^ messageSpecifications remove: aProtocolMsgSpec!

messages
	"Answer a list of message specifications of the receiver. 
	Note: Return value is a <Set> of <protocolMessageSpec>s,"

	messageSpecifications isNil ifTrue: [
		^ self protocolManager defaultMessageSpecificationCollection].
	^ messageSpecifications!

protocolDescription: newDescription 
	"Set the receiver's description to newDescription. 
	Note: If newDescription is empty then description is set to nil."

	(newDescription isKindOf: String)
		ifFalse: [self error: 'Protocol description not a String.'].
	newDescription isEmpty
		ifTrue: [description := nil]
		ifFalse: [description := newDescription]!

messageSelectors
	"Answer the list of selectors which make up the receiver's protocol. 
	Note: Return value is a <Set> of <symbol>s,"

	messageSpecifications isNil ifTrue: [
		^ self protocolManager defaultMessageSpecificationCollection].
	^ messageSpecifications collect: [:msgSpec | msgSpec messageSelector]!

renameToProtocolName: newName 
	"Rename the receiver protocol to have the new name, newName and update any conforming class or metaclass."
	| conformingList |
	(self protocolManager includesProtocolNamed: newName)
		ifTrue: [^ self error: 'Duplicate protocol name: "' , newName , '".'].
	conformingList := self conformingBehaviors.
	conformingList do: [:classOrMetaclass | classOrMetaclass removeProtocolNamed: self protocolName].
	self setProtocolName: newName.
	self protocolManager privateRehashProtocols.
	conformingList do: [:classOrMetaclass | classOrMetaclass addProtocolNamed: newName]!

newProtocolName: protocolName conformsToProtocolNames: conformsToList
	"Private - ."

	name := protocolName.
	conformsTo := conformsToList!

addUndefinedProtocolNames
	"Private - ."

	messageSpecifications isNil ifTrue: [^ self].
	messageSpecifications do: [:msgSpec | self addUndefinedProtocolNamesInMsgSpec: msgSpec]!

printOn: targetStream 
	"Append to targetStream a text representation of the receiver as a developer would want to see it (inspector, etc)."

	targetStream nextPut: $<;
	 nextPutAll: self protocolName;
	 nextPut: $>;
	 nextPut: $(.
	self messageSelectors do: [:selector | targetStream nextPutAll: selector]
		separatedBy: [targetStream nextPutAll: ', '].
	targetStream nextPut: $)!

includesSelector: selector 
	"Answer whether the receiver includes the selector, selector."

	^ self messageSelectors includes: selector!

fileOutOnSIFFiler: programFiler 
	"File out the receiver definition and its message definitions on ANSI SIF filer, programFiler."

	#todo."??? Add annotations ???"
	programFiler
		fileOutProtocolDefinitionOf: self protocolName
		conformsToProtocolNames: self conformsToProtocolNames
		description: self protocolDescription
		annotations: Dictionary new.
	self messages asSortedCollection do: [:messageSpec | messageSpec fileOutOnSIFFiler: programFiler protocol: self protocolName]!

inheritedMessageOrNilAtSelector: selector
	| msg |
	conformsTo do: [:protocolName | msg := (ProtocolSpec protocolNamed: protocolName)
			messageOrNilAtSelector: selector.
			msg notNil ifTrue: [^msg]].
	^nil!

addMessage: aProtocolMsgSpec 
	"Add if not already present the protocol message, aProtocolMsgSpec, to the set of messages included in the receiver's protocol."

	(aProtocolMsgSpec isKindOf: self protocolManager protocolMsgSpec)
		ifFalse: [self error: 'Protocol message not a ProtocolMsgSpec.'].
	(self includesSelector: aProtocolMsgSpec messageSelector)
		ifFalse: 
			[messageSpecifications isNil ifTrue: [messageSpecifications := self protocolManager defaultMessageSpecificationCollection].
			messageSpecifications add: aProtocolMsgSpec.
			self addUndefinedProtocolNamesInMsgSpec: aProtocolMsgSpec]!

hash
	"Answer the hash value for the receiver."

	^ self protocolName hash!

selectorsInBehavior: classOrMetaclass 
	"If the class or metaclass, classOrMetaclass, conforms to the receiver answer all the selectors in which have corresponding messages, else an empty list. 
	Note: Return value is a <Set> of <symbol>s,"

	(classOrMetaclass conformsToProtocolNamed: self protocolName)
		ifTrue: [^ (classOrMetaclass selectors select: [:selector | self includesSelector: selector]) asSet].
	^ Set new!

removeAllSelectors: selectorList 
	"After removing from the receiver all the messages with selectors, selectorList, answer them. 
	Note: selectorList must be a <collection> of  <symbol>s."
	| messageSpecs |
	messageSpecs := Set new.
	selectorList do: [:selector | messageSpecs add: (self removeSelector: selector)].
	^ messageSpecs!

errorSelectorNotFound: selector 
	"Private -"
	self error: 'Protocol ' , self printString , ' message "' , selector , '" not found'!

zremoveClass: classOrMetaclass 
	"Remove the receiver's name from the class or the metaclass, classOrMetaclass, list of protocol names. 	??not that great an idea???"

	classOrMetaclass removeProtocolNamed: self protocolName!

= comperand 
	"Answer whether the receiver is considered equal (contains same elements) to comperand."

	#todo."I'm not sure this makes any sense (= is ==) because if they have the same name they have to be the same object.  If it makes sense, shouldn't this test if contains same selectors?????"
	^ (comperand isKindOf: self protocolManager protocol)
		and: [self protocolName == comperand protocolName]!

removeSelector: selector 
	"Answer the message with selector, selector, after removing it from the receiver."

	^ self removeSelector: selector
		ifAbsent: [self errorSelectorNotFound: selector]!

messageAtSelector: selector
	"Answer the message spec. at selector."
	| msg |
	msg := self messageOrNilAtSelector: selector.
	msg notNil ifTrue: [^msg].
	self error: 'Protocol message spec. at selector: "', selector, '" not found.'!

messageOrNilAtSelector: selector

	messageSpecifications isNil ifTrue: [
		^self inheritedMessageOrNilAtSelector: selector].
	^messageSpecifications 
		detect: [ :protocol | protocol messageSelector = selector]
		ifNone: [^self inheritedMessageOrNilAtSelector: selector].!

conformingBehaviors
	"Answer all the classes which conform to the receiver in class hierarchy order (i.e. superclasses first). 
	Note: Return value is a <OrderedCollection> of  class or metaclass objects."
	| answer |
	answer := OrderedCollection new: 10.
	Smalltalk allClasses
		do: 
			[:class | 
			(class conformsToProtocolNamed: self protocolName)
				ifTrue: [answer addLast: class].
			(class class conformsToProtocolNamed: self protocolName)
				ifTrue: [answer addLast: class class]].
	^ answer!

protocolName
	"Answer the name of the receiver."

	^ name!

conformsToProtocolNames
	"Answer the protocol names to which the receiver conforms."

	^ conformsTo! !

!ProtocolSpec class methodsFor: nil!

classProtocols
	^ClassProtocols!

installProtocolModelUnitTests
	| ansiDir devDir fileName sep |
	devDir := 'C:\Dev\'.							"Typical DOS location"
	"devDir := '%F:\Dev\'." "Sub. doublequote for % Typical Mac location"
	"devDir := '/usr/local/squeak/rharmon/Dev/'." "Typical Unix location"
	sep := FileDirectory pathNameDelimiter asString.
	ansiDir := devDir , 'ANSI' , sep , 'ANSIGood' , sep , 'Squeak' , sep.
	fileName := 'ProtoUT.sif'.
	ChangeSorter newChangesOf: ["ProgramManager"
		nil current installProgramFileLocator: ansiDir , fileName]
		named: fileName sansPeriodSuffix!

wrkAssocGlobalGenUnitTestsForProtocolGroup: protocolGroupName protocolGlobalsClassSideGenTests: protocolGlobalsClassSideGenTests 
	"Private - Generate unit test stub classes for protocol group named, protocolGroupName.  Parameter protocolGlobalsClassSideGenTests array has the protocol name, correspnding global classes, instance or class side protocol ind, and generate unit test ind.  It will generate the methods specified by protocol and conforms-To protocols in the test class for each protocol global class (or protocol inheritance tree leaf).
	The test method naming convention I use is: 
	 
	instance side protocolmethods:	testInstXselector	testInstXselectorX 
	class side protocol methods:		testClsXselector	testClsXselectorX 
	conformsTo protocol methods:	testConToXselector testConToXselectorX 
	operator (+, ==, /, etc) methods:	testInstXadditionOp	testInstXfixOp1 
	 
	The operator test methods testInstXfixOp1 have to be hand editted to change test method selector to testInstXoperatorNameOp.  Example use: 
	
	"
	| assocGlobalClasses genUnitTestSw isClassSideProtocolSw protocolName |
	protocolGlobalsClassSideGenTests
		do: 
			[:parmArray | 
			protocolName := parmArray at: 1.
			assocGlobalClasses := parmArray at: 2.
			isClassSideProtocolSw := (parmArray at: 3)
						= 'class'.
			genUnitTestSw := (parmArray at: 4)
						= 'UT'.
			self
				wrkAssocProtocolNamed: protocolName
				toClassesNamed: assocGlobalClasses
				isClassSideProtocol: isClassSideProtocolSw.
			genUnitTestSw
				ifTrue: [self
						wrkGenTestClassForProtocol: protocolName
						inProtocolGroupNamed: protocolGroupName
						isClassSideProtocol: isClassSideProtocolSw]]!

newProtocolNamed: protocolName conformsToProtocolNames: conformsToList 
	"Answer a new protocol with the specified name, protocolName that conforms to the protocols named in conformsToList."

	^ self privateNewProtocolNamed: protocolName conformsToProtocolNames: conformsToList!

xCommonTasks
	"The following are tasks comonly performed:"
	"Initialize the list of protocol objects:"
	1 protocolManager initializeProtocols.
	"Remove protocol objects not currently assigned to any class or metaclass 
	(Answers a list.  This might take a while.):"
	1 protocolManager purgeUnused.
	"Remove protocol object:"
	1 protocolManager removeProtocolNamed: #'classDescription'.
	"Answer the sorted list of protocol name symbols:"
	1 protocolManager allProtocolNamesSorted.
	"Answer the list of protocol name symbols:"
	1 protocolManager allProtocolNames.
	"Answer the list of undefined conforms-to protocol name symbols:"
	1 protocolManager undefinedConformsToProtocolNames.
	"Answer the list of conforming classes or metaclasses:"
	(1 protocolManager protocolNamed: #'integer') conformingBehaviors.
	"Answer the list of conforms-to protocol name symbols:"
	(self protocolManager protocolNamed: 'Object class' asSymbol) allConformsToProtocolNames.
	"-> Set (ANY Object instantiator classDescription )"
	"Answer the list of all of selectors which make up the protocol 
	and all protocols to which the it conforms:"
	(self protocolManager protocolNamed: 'Object class' asSymbol) allMessageSelectors.
	"Answer the list of all of selectors which make up the protocol:"
	(self protocolManager protocolNamed: 'Object class' asSymbol) conformsToMessageSelectors.
	1 protocolManager includesProtocolNamed: #'Object'.
	"-> true"
	"Assign or query classes or metaclasses:"
	(SUnitNameResolver classNamed: #'Symbol')
		addProtocolNamed: #'Object'.
	ExceptionSet removeProtocolNamed: #'exceptionSet'.
	ExceptionSet protocolNames.
	"-> Set (exceptionSet )"
	ExceptionSet class protocolNames.
	"->  Set ()"
	ExceptionSet conformsToProtocolNamed: #'Object'.
	"-> true"
	ExceptionSet class conformsToProtocolNamed: #'Object'.
	"-> true"
	Symbol conformsToProtocolNamed: #'Object'.
	"-> true"
	true class protocolNames.
	"-> Set ()"
	true class conformsToProtocolNamed: #'boolean'!

protocolANYName
	"Answer the protocol <ANY> name."

	^ #'ANY'!

defaultMessageSpecificationCollection
	"Private - Answer an <Set>, the default messageSpecification collection."

	^ Set new!

xRemoveMsgSpecSelectors: selectorList fromProtocolNamed: protoName 
	"Answer the list of msg specs with selectors, selectorList, after removing the msg specs from protocol named, protoName.  Example: 
	1 protocolManager 
	xRemoveMsgSpecSelectors: #(#'name') 
	fromProtocolNamed: #'classDescription'
	"
	| proto |
	proto := self protocolManager protocolNamed: protoName.
	^ proto removeAllSelectors: selectorList!

defaultEmptyDescription
	"Private - Answer an <String>, the default empty description."

	^ String new!

purgeUnused
	"Answer a list of protocols which are not currently implemented by any class or metaclass in the system after removing them. 
	Note: This might take a while.  Example: 
	 
	1 protocolManager purgeUnused
	"
	#todo."Fix??? don't forget to leave <ANY> even though no class explicity conforms?? "
	self notYetImplemented!

wrkGenTestClassForProtocol: protocolName inProtocolGroupNamed: protocolGroupName isClassSideProtocol: isClassSideProtocolSw 
	"Private - Generate test suite stub methods for the directly specified messages and all conforms-To protocols of protocol named, protocolName, in protocol group named, protocolGroupName.  Parameter isClassSideProtocolSw indicates an instance or class side protocol. 
	The test method naming convention I use is: 
	 
	instance side protocol methods:	testInstXselector	testInstXselectorX 
	class side protocol methods:		testClsXselector	testClsXselectorX 
	conformsTo protocol methods:	testConToXselector testConToXselectorX 
	operator (+, ==, /, etc) methods:	testInstXadditionOp	testInstXfixOp1 
	 
	The operator test methods testInstXfixOp1 have to be hand editted to change test method selector to testInstXoperatorNameOp.  Example use:
	"
	| protocol testSelName commentTmp aDict visitedProtocols testClass |
	protocol := 1 protocolManager protocolNamed: protocolName asSymbol.
	FixNum := 0.
	testClass := self wrkTestClassForProtocol: protocolName inProtocolGroupNamed: protocolGroupName.
	"Build a message selector->protocol dictionary of the directly specified and all conforms-To protocols messages"
	aDict := Dictionary new.
	visitedProtocols := Set new.
	protocol wrkAllConformsToMessageSelectorsTo: aDict visited: visitedProtocols.
	"Generate test suite methods"
	aDict
		keysAndValuesDo: 
			[:msgSel :aProtocolName | 
			testSelName := self wrkTestMethdodNameFrom: msgSel.
			commentTmp := '" <' , aProtocolName , '>#' , msgSel , ' "'.
			testClass compile: testSelName , '
	' , commentTmp , '
	#''' , protocolGroupName , '''.
'.
			testClass classify: testSelName asSymbol under: 'testing']!

xGlobalsImplementAllMsgsOfProtocolNamed: protoName 
	"Answer the a Dictionary containing the conforming global class or metaclass name and corresponding missing selector symbol of protocol named, protoName.  Example: 
	 
	1 protocolManager 
	xGlobalsImplementAllMsgsOfProtocolNamed: #'Character factory'
	"
	| protocol missingMsg conformingBehaviorObjs |
	protocol := 1 protocolManager protocolNamed: protoName.
	conformingBehaviorObjs := (1 protocolManager protocolNamed: 'Character factory' asSymbol) conformingBehaviors.
	missingMsg := Dictionary new.
	protocol messageSelectors do: [:msgSel | conformingBehaviorObjs
			do: [:classOrMetaclassObj | (classOrMetaclassObj includesSelector: msgSel)
					ifFalse: [missingMsg at: classOrMetaclassObj name put: msgSel]]].
	^ missingMsg!

xRuleSourceOfMsgSelector: selector inProtocolNamed: protoName 
	"Answer the return value rule block source of msg with selector, selector, in protocol named, protoName.  Example: 
	 
	1 protocolManager 
	xRuleSourceOfMsgSelector: #'+' 
	inProtocolNamed: #'number'
	"
	| msgSpec proto |
	proto := self protocolManager protocolNamed: protoName.
	msgSpec := proto messageAtSelector: selector.
	^ msgSpec specForEachReturnValueList asArray first returnValueRuleBlockSource!

allProtocolNamesSorted
	"Answer the names of all Protocols in the system sorted ignoring case."

	^ (Protocols collect: [:protocol | protocol protocolName]) asSortedCollection sortBlock: [:x :y | x asLowercase <= y asLowercase]!

allProtocols
	"Answer all Protocols in the system."

	^ Protocols!

addUndefinedProtocolName: protocolName 
	"Private - ."

	(protocolName isKindOf: Symbol)
		ifFalse: [self error: 'Protocol name not a Symbol.'].
	UndefinedConformsToNames add: protocolName!

fileOutSIFAllProtocolsDescOnFiler: programFiler 
	"Private - File out an all-protocols program description in ANSI SIF format on the programFiler."
	| annotations |
	annotations := Dictionary new.
	annotations at: 'createdByApp' put: self portFunc dialectNameVersionString.
	annotations at: 'createdDateTime' put: self portFunc currentDateTimeString.
	programFiler
		fileOutProgramDescName: 'AllProto'
		prerequisiteProgramNames: (Set with: 'ACSProS')
		programAnnotations: annotations!

allProtocolNames
	"Answer the names of all Protocols in the system."

	^ (Protocols collect: [:protocol | protocol protocolName]) asSet!

unaryReturnProtocolNameReceiver: receiver 
	"Answer the return value conforms-to protocol name of a unary message performing arithmetic, arithmetic progressions, and conversion on numerical quantities sent to receiver."
	| receiverProto |
	receiverProto := self instanceProtocol: receiver.
	^ UnaryConvTable at: receiverProto!

xMessagesAndReturnValuesOfProtocolNamed: protoName 
	"Answer the a string containing the messages and their corresponding return values of protocol named, protoName.  Example: 
	 
	1 protocolManager 
	xMessagesAndReturnValuesOfProtocolNamed: #'instantiator'
	"
	| protocol aStream |
	aStream := WriteStream on: (String new: 500).
	aStream cr.
	protocol := 1 protocolManager protocolNamed: protoName.
	protocol messages asSortedCollection
		do: 
			[:msg | 
			msg messageSelector printOn: aStream.
			aStream nextPutAll: '->'.
			msg specForEachReturnValueList printOn: aStream.
			aStream cr].
	aStream contents!

privateRehashProtocols
	"Private -"

	Protocols rehash!

defaultConformsToCollection
	"Private - Answer an <Set>, the default conformsTo collection."

	^ Set new!

initializeOperatorTable
	"Discard all existing protocols.  Example: 
	 
	self protocolManager initializeOperatorTable
	"

	OperatorTable := Dictionary new.
	OperatorTable at: #'=' put: 'equalityOp'.
	OperatorTable at: #'==' put: 'identityOp'.
	OperatorTable at: #'~=' put: 'notEqualityOp'.
	OperatorTable at: #'~~' put: 'notIdentityOp'.
	OperatorTable at: #'&' put: 'andOp'.
	OperatorTable at: #'|' put: 'orOp'.
	OperatorTable at: #'<' put: 'lessThanOp'.
	OperatorTable at: #'<=' put: 'lessThanOrEqualToOp'.
	OperatorTable at: #'>' put: 'greaterThanOp'.
	OperatorTable at: #'>=' put: 'greaterThanOrEqualToOp'.
	OperatorTable at: #'*' put: 'multiplyOp'.
	OperatorTable at: #'+' put: 'addOp'.
	OperatorTable at: #'-' put: 'subtractOp'.
	OperatorTable at: #'/' put: 'divideOp'.
	OperatorTable at: #'//' put: 'integerDivideOp'.
	OperatorTable at: #'\\' put: 'remainderIntegerDivideOp'.
	OperatorTable at: #',' put: 'concatenateOp'!

privateNewProtocolNamed: protocolName conformsToProtocolNames: conforms 
	"Private -"
	| newProtocol conformsTmp |
	(self includesProtocolNamed: protocolName)
		ifTrue: [^ self error: 'Protocol named "' , protocolName , '" already exists.'].
	conformsTmp := self privateValidConformsToProtocolNames: conforms ifError: [^ self error: 'Protocol conforms-to list not a <collection> of existing protocol name <symbol>s.'].
	(protocolName isKindOf: Symbol)
		ifFalse: [self error: 'Protocol name not a Symbol.'].
	newProtocol := self basicNew.
	newProtocol newProtocolName: protocolName conformsToProtocolNames: conformsTmp.
	Protocols add: newProtocol.
	(UndefinedConformsToNames includes: protocolName)
		ifTrue: [UndefinedConformsToNames remove: protocolName].
	^ newProtocol!

defaultSpecSectionsCollection
	"Private - Answer an <Dictionary>, the default SpecSections collection."

	^ Dictionary new!

renameProtocolNamed: oldName to: newName 
	"Rename the protocol named oldName to have the new name, newName. and update any conforming class or metaclass."
	| targetProtocol |
	targetProtocol := self protocolNamed: oldName.
	targetProtocol renameToProtocolName: newName!

specSectionsFromSynopsis: messageSynopsis definedIn: definedInProtocolName definition: messageDefinition refinedIn: refinedInProtocolName refinement: messageRefinement errors: messageErrors 
	"Private - Create a new specification sections with parms and return it."
	| secDict |
	secDict := self protocolManager defaultSpecSectionsCollection.
	definedInProtocolName isEmpty ifFalse: [secDict at: #'DefinedIn' put: definedInProtocolName].
	messageDefinition isEmpty ifFalse: [secDict at: #'Definition' put: messageDefinition].
	messageErrors isEmpty ifFalse: [secDict at: #'Errors' put: messageErrors].
	refinedInProtocolName isEmpty ifFalse: [secDict at: #'RefinedIn' put: refinedInProtocolName].
	messageRefinement isEmpty ifFalse: [secDict at: #'Refinement' put: messageRefinement].
	messageSynopsis isEmpty ifFalse: [secDict at: #'Synopsis' put: messageSynopsis].
	^ secDict!

protocolMsgParmSpec
	"Answer the protocol message parameter specification class object."

	^ SUnitNameResolver classNamed: #'MsgParmSpec'!

instanceProtocol: number 
	"Answer the conforms-to protocol name of number."

	#(#'integer' #'Float' #'Fraction' #'scaledDecimal' )
		do: [:protoName | (number class conformsToProtocolNamed: protoName)
				ifTrue: [^ protoName]].
	self error: 'Instance does not conforms to any numeric protocol.'!

wrkAssocProtocolNamed: protocolName toClassesNamed: assocGlobalClassesArray isClassSideProtocol: isClassSideProtocolSw 
	"Private - Assign a protocol to a list of ANSI class globals."
	| classSymbol |
	assocGlobalClassesArray
		do: 
			[:className | 
			classSymbol := className asSymbol.
			isClassSideProtocolSw
				ifTrue: [(SUnitNameResolver classNamed: classSymbol) class addProtocolNamed: protocolName]
				ifFalse: [(SUnitNameResolver classNamed: classSymbol)
						addProtocolNamed: protocolName]]!

wrkAllRuleReturnValueList
	"Private - Answers a Dictionary of protocols containing messages with return value specified by a rule.  The key is the protocol name and the value is a Dictionarys of message selector keys and  return value spec. set with one MsgReturnRuleSpec containing the rule source code.  Example use: 
	 
	(FileStream readOnlyFileNamed: 
	'C:\Dev\ANSI\ANSIGood\Squeak\AProtos.st.chg' 
	) fileIn. 
	1 protocolManager wrkAllRuleReturnValueList
	"
	| protocolsWithRuleList msgSelRuleCodeList |
	protocolsWithRuleList := Dictionary new.
	self protocolManager allProtocols do: [:protocol | protocol messages
			do: [:msg | msg isReturnValueSpecByRule
					ifTrue: 
						[msgSelRuleCodeList := protocolsWithRuleList at: protocol protocolName ifAbsent: [protocolsWithRuleList at: protocol protocolName put: Dictionary new].
						msgSelRuleCodeList at: msg messageSelector put: msg specForEachReturnValueList]]].
	^ protocolsWithRuleList!

initializeDefaultConversionTable
	"Discard all existing protocols.  Example: 
	 
	self protocolManager protocol initializeDefaultConversionTable
	"
	| tmp |
	DefaultConvTable := Dictionary new.
	tmp := Dictionary new.
	tmp at: #'integer' put: #'integer'.
	tmp at: #'scaledDecimal' put: #'scaledDecimal'.
	tmp at: #'Fraction' put: #'Fraction'.
	tmp at: #'Float' put: #'Float'.
	DefaultConvTable at: #'integer' put: tmp.
	tmp := Dictionary new.
	tmp at: #'integer' put: #'scaledDecimal'.
	tmp at: #'scaledDecimal' put: #'scaledDecimal'.
	tmp at: #'Fraction' put: #'Fraction'.
	tmp at: #'Float' put: #'Float'.
	DefaultConvTable at: #'scaledDecimal' put: tmp.
	tmp := Dictionary new.
	tmp at: #'integer' put: #'Fraction'.
	tmp at: #'scaledDecimal' put: #'Fraction'.
	tmp at: #'Fraction' put: #'Fraction'.
	tmp at: #'Float' put: #'Float'.
	DefaultConvTable at: #'Fraction' put: tmp.
	tmp := Dictionary new.
	tmp at: #'integer' put: #'Float'.
	tmp at: #'scaledDecimal' put: #'Float'.
	tmp at: #'Fraction' put: #'Float'.
	tmp at: #'Float' put: #'Float'.
	DefaultConvTable at: #'Float' put: tmp!

new
	"ProtocolSpecs must be unique for any particular name, and must be instantiated with the #name: method."

	^ self shouldNotImplement!

initialize
	"Class initialization.  Example: 
	 
	ProtocolSpec initialize
	"

        ClassProtocols := LookupTable new.
	self initializeProtocols.
	self initializeDefaultConversionTable.
	self initializeUnaryConversionTable.
	self initializeOperatorTable!

includesProtocolNamed: protocolName 
	"Answer whether the named protocol exists."

	(protocolName isKindOf: Symbol)
		ifFalse: [self error: 'Protocol name not a Symbol.'].
	Protocols detect: [:protocol | protocol protocolName = protocolName]
		ifNone: [^ false].
	^ true!

parametersFromList: parmList 
	"Private - Create a new protocol message specification with message, messagePattern, etc. to protocol named protocolName."
	| newParmSpecs names |
	newParmSpecs := parmList
				collect: 
					[:anArray | 
					names := (anArray at: 2) subStrings collect: [:nameString | name asSymbol].
					self protocolManager protocolMsgParmSpec
						newParmName: (anArray at: 1)
						protocolNames: names
						aliasing: (anArray at: 3)].
	^ newParmSpecs!

wrkTestClassForProtocol: protocolName inProtocolGroupNamed: protocolGroupName 
	"Private - Answer a unit test class for protocol named, protocolName, in group named, protocolGroupName."
	| testClassName tmp classObj |
	testClassName := String new.
	tmp := protocolName subStrings.
	tmp
		do: 
			[:protocolNameParts | 
			protocolNameParts at: 1 put: (protocolNameParts at: 1) asUppercase.
			testClassName := testClassName , protocolNameParts].
	testClassName := (testClassName , 'ANSITest') asSymbol.
	classObj := [(SUnitNameResolver classNamed: #'TestCaseProtocol')
				subclass: testClassName
				instanceVariableNames: ''
				classVariableNames: ''
				poolDictionaries: ''
				category: 'Tests-ANSI-' , protocolGroupName]
				on: Error
				do: 
					[:except | 
					except messageText: 'Error compiling class definition of : "' , testClassName , '" - ' , except description.
					except resignalAs: Warning].
	^ classObj!

removeProtocolNamed: protocolName 
	"Remove the protocol named, protocolName, from the system. 
	Note: Protocol <ANY> can not be removed."
	| conformingList targetProtocol |
	protocolName = self protocolManager protocolANYName ifTrue: [self error: 'Protocol <' , protocolName , '> can not be removed.'].
	targetProtocol := self protocolNamed: protocolName.
	#todo."fix not to use conformingBehaviors (includes subclasses) but classDescription protocolNames includes: ???"
	conformingList := targetProtocol conformingBehaviors.
	conformingList
		do: [:classOrMetaclass | (classOrMetaclass protocolNames includes: protocolName)
				ifTrue: [classOrMetaclass removeProtocolNamed: protocolName]].
	Protocols remove: targetProtocol ifAbsent: [self error: 'Protocol named: "' , protocolName , '" not found.']!

newMessagePattern: messagePattern forProtocolNamed: protocolName synopsis: messageSynopsis definedIn: definedInProtocolName definition: messageDefinition refinedIn: refinedInProtocolName refinement: messageRefinement parameters: parmList returnValues: returnValuesList errors: messageErrors 
	"Create a new protocol message specification with message, messagePattern, etc. to protocol named protocolName."
	| newParmSpecs newReturnSpec secDict |
	newParmSpecs := self parametersFromList: parmList.
	newReturnSpec := returnValuesList collect: [:anArray | self protocolManager protocolMsgReturnValueSpec newRetValProtocolNames: (Set with: (anArray at: 1) asSymbol)
					aliasing: (anArray at: 2)].
	secDict := self
				specSectionsFromSynopsis: messageSynopsis
				definedIn: definedInProtocolName
				definition: messageDefinition
				refinedIn: refinedInProtocolName
				refinement: messageRefinement
				errors: messageErrors.
	(self protocolNamed: protocolName)
		addMessage: (self protocolMsgSpec
				newSelector: (String methodSelector: messagePattern , ' ') asSymbol
				specSections: secDict
				specsForEachParm: newParmSpecs
				specsForEachReturnValue: newReturnSpec)!

defaultReturnProtocolNameReceiver: receiver operand: operand 
	"Answer the return value conforms-to protocol name of a message performing arithmetic, arithmetic progressions, and conversion on numerical quantities involving receiver and operand.
	Note: The result type of most numeric opeations is based upon the operand type.  The Default Result Type for all operand types except <Fraction> is the type to which the operands have been converted according to the Default ConversionTable.  If the converted operand type is <Fraction> the Default Result Type is <rational>.  In all cases where the type of the return value differs from the default result type  it is noted in the operation's description."
	| receiverProto operandProto convertedOperandType |
	receiverProto := self instanceProtocol: receiver.
	operandProto := self instanceProtocol: operand.
	convertedOperandType := (DefaultConvTable at: receiverProto)
				at: operandProto.
	convertedOperandType = #'Fraction' ifTrue: [^ #'rational'].
	^ convertedOperandType!

newMessagePattern: messagePattern forProtocolNamed: protocolName synopsis: messageSynopsis definedIn: definedInProtocolName definition: messageDefinition refinedIn: refinedInProtocolName refinement: messageRefinement parameters: parmList returnRule: returnValueRule errors: messageErrors 
	"Create a new protocol message specification with message, messagePattern, etc. to protocol named protocolName."
	| newParmSpecs newReturnSpecs secDict |
	newParmSpecs := self parametersFromList: parmList.
	newReturnSpecs := Set with: (self protocolManager protocolMsgReturnValueRuleSpec newRetValRuleSourceCode: returnValueRule).
	secDict := self
				specSectionsFromSynopsis: messageSynopsis
				definedIn: definedInProtocolName
				definition: messageDefinition
				refinedIn: refinedInProtocolName
				refinement: messageRefinement
				errors: messageErrors.
	(self protocolNamed: protocolName)
		addMessage: (self protocolMsgSpec
				newSelector: (String methodSelector: messagePattern , ' ') asSymbol
				specSections: secDict
				specsForEachParm: newParmSpecs
				specsForEachReturnValue: newReturnSpecs)!

protocolsInNameList: protocolNameList 
	"Answer the list of protocols named in protocolNameList."

	^ (protocolNameList collect: [:protocolName | self protocolNamed: protocolName]) asSet!

protocolMsgSpec
	"Answer the protocol message specification class object."

	^ SUnitNameResolver classNamed: #'ProtocolMsgSpec'!

protocolANY
	"Answer the protocol <ANY> class object."

	^ SUnitNameResolver classNamed: #'ProtocolANYSpec'!

initializeUnaryConversionTable
	"Discard all existing protocols.  Example: 
	 
	self protocolManager protocol initializeDefaultConversionTable
	"

	UnaryConvTable := Dictionary new.
	UnaryConvTable at: #'integer' put: #'rational'.
	UnaryConvTable at: #'Fraction' put: #'rational'.
	UnaryConvTable at: #'rational' put: #'rational'.
	UnaryConvTable at: #'scaledDecimal' put: #'scaledDecimal'.
	UnaryConvTable at: #'Float' put: #'Float'!

wrkChkTestsForProtocol: protocolName inProtocolGroupNamed: protocolGroupName isClassSideProtocol: isClassSideProtocolSw 
	"Private - Generate test suite stub methods for the directly specified messages and all conforms-To protocols of protocol named, protocolName, in protocol group named, protocolGroupName.  Parameter isClassSideProtocolSw indicates an instance or class side protocol. 
	The test method naming convention I use is: 
	 
	instance side protocol methods:	testInstXselector	testInstXselectorX 
	class side protocol methods:		testClsXselector	testClsXselectorX 
	conformsTo protocol methods:	testConToXselector testConToXselectorX 
	operator (+, ==, /, etc) methods:	testInstXadditionOp	testInstXfixOp1 
	 
	The operator test methods testInstXfixOp1 have to be hand editted to change test method selector to testInstXoperatorNameOp.  Example use:
	"
	| protocol testSelNameSymbol protocolNameSymbolTmp sourceTmp aDict visitedProtocols testClass s1 s2 |
	protocol := 1 protocolManager protocolNamed: protocolName asSymbol.
	FixNum := 0.
	testClass := self wrkTestClassForProtocol: protocolName inProtocolGroupNamed: protocolGroupName.
	"Build a message selector->protocol dictionary of the directly specified and all conforms-To protocols messages"
	aDict := Dictionary new.
	visitedProtocols := Set new.
	protocol wrkAllConformsToMessageSelectorsTo: aDict visited: visitedProtocols.
	"Generate test suite methods"
	aDict
		keysAndValuesDo: 
			[:msgSel :aProtocolName | 
			testSelNameSymbol := (self wrkTestMethdodNameFrom: msgSel) asSymbol.
			(testClass includesSelector: testSelNameSymbol)
				ifTrue: 
					[sourceTmp := (testClass sourceMethodAt: testSelNameSymbol) asString.
					s1 := (sourceTmp indexOf: $<)
								+ 1.
					s2 := (sourceTmp indexOf: $>)
								- 1.
					protocolNameSymbolTmp := (sourceTmp copyFrom: s1 to: s2) asSymbol.
					self halt.
					protocolNameSymbolTmp = aProtocolName ifFalse: [self halt]]]!

wrkGenerateMethdodsInTestClassNamed: testClassName forProtocolNamed: protocolName inProtocolGroupNamed: protocolGroupName isClassSideProtocol: isClassSideProtocolSw 
	"Private - Generate test suite stub methods in test class named, testClassName, for protocol named, protocolName, in protocol group named, protocolGroupName, that is an instance side protocol (isClassSideProtocolSw = false) or class side protocol (isClassSideProtocolSw = true). 
	I name instance side protocol test methods %testInstXselector% & %testInstXselectorX% for Class >>#selector & Class >>#selector:. 
	I name class side protocol test methods %testClsXselector% &  %testClsXselectorX% for Class >>#selector & Class >>#selector:. 
	I name operator (+, ==, /, etc) test methods %testInstXfixOp1% Class >>#selector & Class >>#+.   I number these fixes sequentially starting with 1. 
	The operator (+, ==, /, etc) test methods %testInstXfixOp1% have to be hand editted to change test method selector to %testInstXadditionOp% (identityOp, divisionOp, etc). 
	Example use: 
	 
	1 protocolManager 
	wrkGenerateMethdodsInTestClassNamed: 'CharacterFactoryProtocolTest' 
	forProtocolNamed: #'Character factory' 
	inProtocolGroupNamed: 'Numeric' 
	isClassSideProtocol: true. 
	1 protocolManager 
	wrkGenerateMethdodsInTestClassNamed: 'CharacterProtocolTest' 
	forProtocolNamed: #'Character' 
	inProtocolGroupNamed: 'Numeric' 
	isClassSideProtocol: false.
	"
	| protocol testSelName instOrClass classOrMetaclassObj fixNum commentTmp opTable |
	opTable := Dictionary new.
	opTable at: #'=' put: 'equalityOp'.
	opTable at: #'==' put: 'identityOp'.
	opTable at: #'~=' put: 'notEqualityOp'.
	opTable at: #'~~' put: 'notIdentityOp'.
	opTable at: #'&' put: 'andOp'.
	opTable at: #'|' put: 'orOp'.
	opTable at: #'<' put: 'lessThanOp'.
	opTable at: #'<=' put: 'lessThanOrEqualToOp'.
	opTable at: #'>' put: 'greaterThanOp'.
	opTable at: #'>=' put: 'greaterThanOrEqualToOp'.
	opTable at: #'*' put: 'multiplyOp'.
	opTable at: #'+' put: 'addOp'.
	opTable at: #'-' put: 'subtractOp'.
	opTable at: #'/' put: 'divideOp'.
	opTable at: #'//' put: 'integerDivideOp'.
	opTable at: #'\\' put: 'remainderIntegerDivideOp'.
	protocol := 1 protocolManager protocolNamed: protocolName.
	"Generate test suite class method >>#suite :"
	classOrMetaclassObj := (SUnitNameResolver classNamed: testClassName asSymbol) class.
	classOrMetaclassObj compile: 'suite
	| testSuite |
	testSuite := TestSuite new.
	self selectors do: [ :selector |
		(selector indexOfSubCollection: ''test'') = 1 ifTrue: [
			testSuite addTest: (self selector: selector)
	]	].
	^testSuite
'.
	classOrMetaclassObj classify: #'suite' under: 'instance creation'.
	"Generate test suite instance methods >>#testInstXetc or >>#testClsXetc :"
	isClassSideProtocolSw
		ifTrue: [instOrClass := 'Cls']
		ifFalse: [instOrClass := 'Inst'].
	fixNum := 0.
	protocol messageSelectors
		do: 
			[:msgSel | 
			msgSel isInfix
				ifTrue: [(opTable includesKey: msgSel)
						ifTrue: [testSelName := 'test' , instOrClass , 'X' , (opTable at: msgSel)]
						ifFalse: 
							[fixNum := fixNum + 1.
							testSelName := 'test' , instOrClass , 'XfixOp' , fixNum printString]]
				ifFalse: [testSelName := 'test' , instOrClass , 'X' , (msgSel asString
									collect: [:char | char = $:
											ifTrue: [$X]
											ifFalse: [char]])].
			commentTmp := '" ' , msgSel , ' "'.
			classOrMetaclassObj := SUnitNameResolver classNamed: testClassName asSymbol.
			classOrMetaclassObj compile: testSelName , '
	' , commentTmp , '
	#''' , protocolGroupName , '''.
'.
			classOrMetaclassObj classify: testSelName asSymbol under: 'testing']!

privateValidConformsToProtocolNames: protocolNamesIn ifError: errorBlock 
	"Private -"
	| protocolNamesTmp |
	(protocolNamesIn isKindOf: Collection)
		ifFalse: [^ errorBlock value].
	protocolNamesIn isEmpty ifTrue: [^ errorBlock value].
	protocolNamesIn isEmpty ifTrue: [^ errorBlock value].
	protocolNamesTmp := self protocolManager defaultProtocolNameCollection.
	protocolNamesIn
		do: 
			[:protocolName | 
			(protocolName isKindOf: Symbol)
				ifFalse: [^ errorBlock value].
			(self protocolManager includesProtocolNamed: protocolName)
				ifFalse: [self protocolManager addUndefinedProtocolName: protocolName].
			protocolNamesTmp add: protocolName].
	^ protocolNamesTmp!

fileOutAllProtocolsSIFFiler: programFiler 
	"File out all protocol definitions on ANSI SIF filer, programFiler."
	| allProtos |
	allProtos := self allProtocols asSortedCollection.
	allProtos remove: (self protocolNamed: self protocolANYName)
		ifAbsent: [].
	self fileOutSIFAllProtocolsDescOnFiler: programFiler.
	allProtos do: [:protocol | protocol fileOutOnSIFFiler: programFiler]!

initializeProtocols
	"Discard all existing protocols.  Example: 
	 
	self protocolManager protocol initializeProtocols
	"
	| nameList |
	(Protocols notNil and: [Protocols size > 1])
		ifTrue: 
			[nameList := String new.
			"Not just protocol <ANY>"
			(Protocols asArray copyFrom: 1 to: (3 min: Protocols size))
				do: [:protocol | nameList := nameList , protocol protocolName]
				separatedBy: [nameList := nameList , ', '].
			Protocols size > 3 ifTrue: [nameList := nameList , ' ...'].
			(self portFunc promptYesNo: 'You are about to lose protocols (' , nameList , ').  Do it?')
				ifFalse: ["Do NOT discard existing protocols."
					^ self]].
	UndefinedConformsToNames := self defaultProtocolNameCollection.
	Protocols := self defaultProtocolCollection.
	Protocols add: (SUnitNameResolver classNamed: #'ProtocolANYSpec') privateNewProtocolANY!

defaultProtocolCollection
	"Private - Answer an <Set>, the default protocol collection."

	^ Set new!

installProtocolDocReader
	"Extracts the parts of ANSI style protocol specs from the proposed ANSI Smalltalk standard document and builds the protocol objects."
	| ansiDir devDir fileName sep |
	devDir := 'C:\Dev\'.							"Typical DOS location"
	"devDir := '/usr/local/squeak/rharmon/Dev/'." "Typical Unix location"
	"devDir := '%F:\Dev\'." "Sub. doublequote for % Typical Mac location"
	sep := FileDirectory pathNameDelimiter asString.
	ansiDir := devDir , 'ANSI' , sep , 'ANSIGood' , sep , 'Squeak' , sep.
	fileName := 'PDocRdr.sif'.
	ChangeSorter newChangesOf: ["ProgramManager"
		nil current installProgramFileLocator: ansiDir , fileName]
		named: fileName sansPeriodSuffix!

errorProtocolNotFound: protocolName 
	"Private -"

	self error: 'Protocol <' , protocolName , '> not found'!

protocolNamed: protocolName 
	"Answer the protocol named protocolName."

	(protocolName isKindOf: Symbol)
		ifFalse: [self error: 'Protocol name not a Symbol.'].
	^ Protocols detect: [:protocol | protocol protocolName = protocolName]
		ifNone: [self error: 'Protocol named: "' , protocolName , '" not found.']!

wrkTestMethdodNameFrom: messageSelector 
	"Private - Answer a generated test suite stub method name from messageSelector. fixNum which may be incremented if a test methdod name is generated that must be fixed up by hand."
	| testSelName |
	messageSelector isInfix
		ifTrue: [(OperatorTable includesKey: messageSelector)
				ifTrue: [testSelName := 'testX' , (OperatorTable at: messageSelector)]
				ifFalse: 
					[FixNum := FixNum + 1.
					testSelName := 'testXfixOp' , FixNum printString]]
		ifFalse: [testSelName := 'testX' , (messageSelector asString
							collect: [:char | char = $:
									ifTrue: [$X]
									ifFalse: [char]])].
	^ testSelName!

protocolMsgReturnValueRuleSpec
	"Answer the protocol message return value rule specification class object."

	^ SUnitNameResolver classNamed: #'MsgReturnRuleSpec'!

undefinedConformsToProtocolNames
	"Answer the undefined conforms-to protocol names in the system."

	^ UndefinedConformsToNames!

protocol
	"Answer the protocol class object."

	^ SUnitNameResolver classNamed: #'ProtocolSpec'!

protocolMsgReturnValueSpec
	"Answer the protocol message return value specification class object."

	^ SUnitNameResolver classNamed: #'MsgReturnSpec'!

xMsgSpecListOfSelector: selector inProtocolNamed: protoName 
	"Answer the list of msg specs for msg with selector, selector, in protocol named, protoName.  Example: 
	 
	1 protocolManager 
	xMsgSpecListOfSelector: #',' 
	inProtocolNamed: #'exceptionSelector'
	"
	| msgSpec proto |
	proto := self protocolManager protocolNamed: protoName.
	msgSpec := proto messageAtSelector: selector.
	^ msgSpec specForEachReturnValueList!

fileOutSIFAllProtocolsToFileLocator: pathNameExt 
	"File out all protocol definitions in ANSI SIF to fileLocator, pathNameExt. 
	Note: Protocols are NOT defined in SIF, thus only a reader with macro enhancement will install protocols from the file.  All other conforming readers will ignore the contents as comments."
	| aFileStream programFiler |
	aFileStream := FileStream write: pathNameExt.
	
	[programFiler := self protocolManager newWriterOn: aFileStream.
	"SIF"
	self fileOutAllProtocolsSIFFiler: programFiler]
		ensure: [aFileStream close]!

defaultProtocolNameCollection
	"Private - Answer an <Set>, the default protocol name collection."

	^ Set new! !


!SelectorANSITest methodsFor: nil!

protocol
	^#'selector'!

canonicalObject
	^#isNil! !

!ExceptionClassANSITest methodsFor: nil!

testXsignalX
	" <exceptionSignaler>#signal: "
	#'Exception'.
#'todo'."??? I don't know what to test here.
	[	Exception signal
	] on: Exception do: [ :anException | anException signal: ??? ].

	self op: [xxx] should: [:r | xxx]
		conformTo: #'exceptionDescription' selector: #'signal:'.

	self should: [ [xxx] ensure: [ flag := 1 ] ]
		raise: Exception.
???"!

testXallSubclasses
	" <classDescription>#allSubclasses "
	#'Exception'.!

testXname
	" <classDescription>#name "
	#'Exception'.!

testXsuperclass
	" <classDescription>#superclass "
	#'Exception'.!

protocol
	^#'Exception class'!

testXconcatenateOp
	" <exceptionSelector>#, "
	#'Exception'.
#'todo'."??? Fix"
	self value: [ Exception, Error ]
		should: [:r | true "(r class = (self protocolTestsMgr classAt: 'exceptionSet'))"
					and: [(r handles: (Exception new))
							& (r handles: (Error new))] ]
		conformTo: #'exceptionSelector' selector: #','.!

testXallSuperclasses
	" <classDescription>#allSuperclasses "
	#'Exception'.!

testXnew
	" <Exception class>#new "
	#'Exception'.
	self value: [Exception new] should: [:r | true "??? r = Exception signal ???"]
		conformTo: #'Exception class' selector: #'new'.!

testXsignal
	" <Exception class>#signal "
	#'Exception'.
	self value: [ [Exception signal] on: Exception do: [ :except | except return ] ]
		should: [:r | true "unspecified"]
		conformTo: #'Exception class' selector: #'signal'.!

canonicalObject
	^Exception!

testXhandlesX
	" <Exception class>#handles: "
	#'Exception'.
	self value: [ [ Exception signal ] on: Exception do: [ :except |
					except return: (Exception  handles: except) ] ]
		should: [:r | r]
		conformTo: #'Exception class' selector: #'handles:'.


	self value: [ [ Exception signal ] on: Exception do: [ :except |
					except return: (Error  handles: except) ] ]
		shouldnt: [:r | r]
		conformTo: #'Exception class' selector: #'handles:'.!

testXsubclasses
	" <classDescription>#subclasses "
	#'Exception'.! !

!IdentityDictionaryANSITest methodsFor: nil!

testXasOrderedCollection
	" <collection>#asOrderedCollection "
	#'Collection'.!

testXasByteArray
	" <collection>#asByteArray "
	#'Collection'.!

testXasBag
	" <collection>#asBag "
	#'Collection'.!

testXatX
	" <abstractDictionary>#at: "
	#'Collection'.!

testXoccurrencesOfX
	" <collection>#occurrencesOf: "
	#'Collection'.!

testXallSatisfyX
	" <collection>#allSatisfy: "
	#'Collection'.!

protocol
	^#'IdentityDictionary'!

testXnotEmpty
	" <collection>#notEmpty "
	#'Collection'.!

testXasSortedCollectionX
	" <collection>#asSortedCollection: "
	#'Collection'.!

testXrehash
	" <collection>#rehash "
	#'Collection'.!

testXcollectX
	" <abstractDictionary>#collect: (Return Values: <RECEIVER>)"
	#'Collection'.!

testXasSortedCollection
	" <collection>#asSortedCollection "
	#'Collection'.!

testXasSet
	" <collection>#asSet "
	#'Collection'.!

emptyCanonicalObject
	^IdentityDictionary new!

testXisEmpty
	" <collection>#isEmpty "
	#'Collection'.!

testXanySatisfyX
	" <collection>#anySatisfy: "
	#'Collection'.!

testXatXifAbsentPutX
	" <abstractDictionary>#at:ifAbsentPut: "
	#'Collection'.!

testXdoXseparatedByX
	" <collection>#do:separatedBy: "
	#'Collection'.!

testXinjectXintoX
	" <collection>#inject:into: "
	#'Collection'.!

testXaddAllX
	" <abstractDictionary>#addAll: "
	#'Collection'.!

testXsize
	" <collection>#size "
	#'Collection'.!

testXdetectXifNoneX
	" <collection>#detect:ifNone: "
	#'Collection'.!

testXdetect
	" <collection>#detect: "
	#'Collection'.!

testXincludesKeyX
	" <abstractDictionary>#includesKey: "
	#'Collection'.!

testXasArray
	" <collection>#asArray "
	#'Collection'.!

testXatXifAbsentX
	" <abstractDictionary>#at:ifAbsent: "
	#'Collection'.!

testXdoX
	" <collection>#do: "
	#'Collection'.!

testXatXputX
	" <abstractDictionary>#at:put: "
	#'Collection'.!

canonicalObject
	^IdentityDictionary new at: 1 put: 11; at: 2 put: 22; at:3 put: 33; at:4 put: 44; yourself!

testXincludesX
	" <collection>#includes: "
	#'Collection'.! !

!TestCaseHelper methodsFor: nil!

attachTo: mainTestCase 
	testCase := mainTestCase.!

printOn: aStream

	aStream
		nextPutAll: self class printString;
		nextPutAll: '>>'!

protocol
	^testCase protocol! !

!TestCaseHelper class methodsFor: nil!

suite
	^TestSuite new.!

initialize
	testSelectors := nil!

testMethods
	testSelectors isNil ifTrue: [testSelectors := self selectors select: [:each | 'test*' match: each]].
	^testSelectors! !

!ExceptionSetANSITest methodsFor: nil!

testXhandlesX
	" <exceptionSelector>#handles: "
	#'Exception'.!

testXconcatenateOp
	" <exceptionSet>#, "
	#'Exception'.
#'todo'."??? Fix"
	self value: [ Warning, Error ]
		should: [:r | "(r class = (self protocolTestsMgr classAt: 'exceptionSet'))"
			true		and: [(r handles: (Warning new))
							& (r handles: (Error new))] ]
		conformTo: #'exceptionSet' selector: #','.!

canonicalObject
	^ExceptionSet new!

protocol
	^#'exceptionSet'! !

!WriteStreamHelper methodsFor: nil!

protocol

	^#'WriteStream'!

canonicalObject

	^testCase canonicalObject!

object: anObject! !

!WriteStreamHelper class methodsFor: nil!

initialize
	"WriteStreamHelper  initialize"
	super initialize! !

!IntervalANSITest methodsFor: nil!

testXkeysAndValuesDoX
	" <sequencedReadableCollection>#keysAndValuesDo: "
	#'Collection'.!

canonicalElement

	^2!

emptyCollection

	^1 to: 0!

protocol
	^#Interval!

testXlast
	" <sequencedReadableCollection>#last "
	#'Collection'.!

canonicalObject
	^1 to: 4!

canonicalObject
	^1 to: 4! !

!IntervalANSITest class methodsFor: nil!

helperClassesDo: aBlock
	super helperClassesDo: aBlock.
	aBlock value: SequencedReadableCollectionHelper! !

!GettableStreamHelper methodsFor: nil!

testXnextLine

	self canonicalObject reset.
	self value: [self canonicalObject nextLine]
		should: [:r | true "The result is undefined if there are no future sequence values in the receiver or if the future-sequence values do not include the end-of-line sequence."]
		conformTo: self protocol selector: #'nextLine'.!

testXupToX

	self canonicalObject reset.
	self value: [self canonicalObject upTo: $ ]
		should: [:r | r = 'this' & self canonicalObject next = $i]
		conformTo: self protocol selector: #'upTo:'.

	self value: [self canonicalObject upTo: $X]
		should: [:r | r = 's a string' & self canonicalObject atEnd]
		conformTo: self protocol selector: #'upTo:'.

	self value: [self canonicalObject upTo: $a]
		should: [:r | r isEmpty]
		conformTo: self protocol selector: #'upTo:'.!

testXnext

	self canonicalObject reset.
	self value: [self canonicalObject next]
		should: [:r | r = $t]
		conformTo: self protocol selector: #'next'.!

testXskipToX

	self canonicalObject reset.
	self value: [self canonicalObject skipTo: $a]
		should: [:r | r  & self canonicalObject position = 9]
		conformTo: self protocol selector: #'skipTo:'.

	self value: [self canonicalObject skipTo: $X]
		should: [:r | r = false & self canonicalObject atEnd]
		conformTo: self protocol selector: #'skipTo:'.!

protocol
	^#'gettableStream'!

canonicalObject

	^testCase canonicalObject!

testXdoX
	| list list2 |
	self canonicalObject reset.
	list := OrderedCollection new.
	self value: [self canonicalObject do: [ :elem | list add: elem]]
		should: [:r | list asArray = 'this is a string' asArray]
		conformTo: self protocol selector: #'do:'.

	self canonicalObject setToEnd.
	list2 := OrderedCollection new.
	self value: [self canonicalObject do: [ :elem | list2 add: elem]]
		should: [:r | "r UNSPECIFIED" list2 isEmpty]
		conformTo: self protocol selector: #'do:'.!

testXpeekForX

	self canonicalObject reset.
	self value: [self canonicalObject peekFor: $t]
		should: [:r | r]
		conformTo: self protocol selector: #'peekFor:'.

	self value: [self canonicalObject peekFor: $X]
		shouldnt: [:r | r]
		conformTo: self protocol selector: #'peekFor:'.!

testXatEnd

	self canonicalObject reset.
	self value: [self canonicalObject atEnd]
		shouldnt: [:r | r]
		conformTo: self protocol selector: #'atEnd'.

	self canonicalObject setToEnd.
	self value: [self canonicalObject atEnd]
		should: [:r | r]
		conformTo: self protocol selector: #'atEnd'.!

testXpeek

	self canonicalObject reset.
	self value: [self canonicalObject peek]
		should: [:r | r = $t]
		conformTo: self protocol selector: #'peek'.

	self canonicalObject setToEnd.
	self value: [self canonicalObject peek]
		should: [:r | r = nil]
		conformTo: self protocol selector: #'peek'.!

testXnextX

	self canonicalObject reset.
	self value: [self canonicalObject next: 3]
		should: [:r | r asArray = 'thi' asArray]
		conformTo: self protocol selector: #'next:'.!

object: anObject!

testXnextMatchForX

	self canonicalObject reset.
	self value: [self canonicalObject nextMatchFor: $t]
		should: [:r | r]
		conformTo: self protocol selector: #'nextMatchFor:'.

	self value: [self canonicalObject nextMatchFor: $t]
		shouldnt: [:r | r]
		conformTo: self protocol selector: #'nextMatchFor:'.!

testXskipX

	self canonicalObject reset.
	self value: [self canonicalObject skip: 3]
		should: [:r | "r UNSPECIFIED" self canonicalObject next = $s]
		conformTo: self protocol selector: #'skip:'.

	self canonicalObject position: (self canonicalObject contents size - 1).
	self value: [self canonicalObject skip: 3]
		should: [:r | "r UNSPECIFIED" self canonicalObject next = nil]
		conformTo: self protocol selector: #'skip:'.! !

!GettableStreamHelper class methodsFor: nil!

initialize
	"GettableStreamHelper  initialize"
	super initialize! !

!CollectionStreamHelper methodsFor: nil!

canonicalObject

	^testCase canonicalObject!

testXcontents

	self value: [self canonicalObject contents]
		should: [:r | r = 'this is a string'
				& r size = self canonicalObject size]
		conformTo: self protocol selector: #'contents'.!

object: anObject! !

!CollectionStreamHelper class methodsFor: nil!

initialize
	"CollectionStreamHelper  initialize"
	super initialize! !

!SequenceableCollection methodsFor: nil!

asANSITestArray
	"2000/06/23 Harmon, R. Added to RJs release from SSs stuff."

	^self collect: [:each | 
		each collect: [:each1 | 
			each1 = #true 
				ifTrue: [true] 
				ifFalse: [each1 = #false 
					ifTrue: [false] 
					ifFalse: [each1]]]]! !

!ClassDescription methodsFor: nil!

protocolNames
	"Answer the names of protocols to which the receiver's instances directly conform. 
	Note: This excludes inherited protocols."
	| tmpList |
	#'ACSProS'.
	tmpList := self protocolManager classProtocols at: self ifAbsent: [nil].
	tmpList isNil ifTrue: [^ self protocolManager defaultProtocolNameCollection].
	^ tmpList!

removeProtocolNamed: protocolName 
	"Remove the protocol named, protocolName, from the list of protocols to which the receiver conforms."
	#'ACSProS'.

	self removeProtocolNamed: protocolName ifAbsent: [self protocolManager errorProtocolNotFound: protocolName]!

definedAsProtocolNames
	"Answer the names of protocols to which the receiver's instances directly conform.  If it has no protocols, check super classes until protocols are found 
	Note: This excludes inherited protocols. 
	200/03/04 Harmon, R. Added."
	| tmpList |
	#'ACSProS'.
	tmpList := self protocolManager classProtocols at: self ifAbsent: [nil].
	tmpList isNil ifTrue: [^ self superclass definedAsProtocolNames].
	^ tmpList!

protocols
	"Answer the protocols to which the receiver's instances directly conform. 
	Note: This excludes inherited protocols."
	#'ACSProS'.

	^ self protocolManager protocolsInNameList: self protocolNames!

addProtocolNamed: protocolName 
	"Add the protocol named, protocolName, to the list of protocols to which the receiver conforms."
	| tmpProtocolNames |
	#'ACSProS'.
	tmpProtocolNames := self protocolNames.
	tmpProtocolNames add: protocolName.
	self protocolNames: tmpProtocolNames!

conformsToProtocolNamed: protocolName 
	"Answer whether the receiver conforms to the protocol named protocolName.
	Note: This includes inherited protocols."
	#'ACSProS'.
	^ (self protocolNames includes: protocolName)
		or: [self superclass notNil 
			and: [self superclass conformsToProtocolNamed: protocolName]]!

removeProtocolNamed: protocolName ifAbsent: notFoundBlock 
	"Remove the protocol named, protocolName, from the list of protocols to which the receiver conforms.  Evaluate notFoundBlock if not found."
	| tmpProtocolNames |
	#'ACSProS'.
	tmpProtocolNames := self protocolNames.
	tmpProtocolNames isEmpty ifTrue: [^ notFoundBlock value].
	tmpProtocolNames remove: protocolName ifAbsent: [^ notFoundBlock value].
	self protocolNames: tmpProtocolNames!

protocolNames: protocolNameList 
	"Private - Set the names of protocols to which the receiver's instances directly conform to protocolNameList. 
	Note: This excludes inherited protocols. protocolNameList must be a <collection> of <symbol>s."
	#'ACSProS'.
	(protocolNameList isKindOf: Set)
		ifFalse: [self error: 'Protocol name list not a Set.'].
	protocolNameList isEmpty
		ifTrue: [self protocolManager classProtocols removeKey: self ifAbsent: [] ]
		ifFalse: [self protocolManager classProtocols at: self put: protocolNameList]! !

!TestCase methodsFor: nil!

value: aBlockContext shouldRaise: anException
	| ok |
	#'ACSUEnh'. 
	ok := [ aBlockContext value. false ] on: anException do: [:ex | ex return: true ].
	self assert: ok!

value: aBlockContext shouldntRaise: anException 
	| ok |
	#'ACSUEnh'. 
	ok := [ aBlockContext value. true ] on: anException do: [:ex | ex return: false ].
	self assert: ok! !

!String methodsFor: nil!

trimBlanks
	"Answer a <readableString>, a copy of the receiver from which leading and trailing separators have been trimmed."
	#'ACSProS'.

	^ self trimSeparators! !

!PositionableStream methodsFor: nil!

nextToken
	"Answer a <readableString>, the next token in the receiver's element stream, delimited by elements which answer true to #isSeparator. Answer a nil if there are no more token in the receiver."
	"99/12/02 Harmon, R. A. 	Fixed error & changed to return nil if no
							more tokens to conform to other impls."
	| startPos len |
	#'ACSProS'.
	self skipSeparators.
	self atEnd ifTrue: [^ nil].
	startPos := self position.
	len := 0.
	[self atEnd]
		whileFalse: 
			[self next isSeparator
				ifTrue: 
					[self position: startPos.
					^ self next: len].
			len := len + 1].
	self position: startPos.
	^ self next: len! !

!Object methodsFor: nil!

protocolManager
	"Answer the singleton instance of the protocol manager."
		#'ACSProS'.

	^ProtocolSpec! !

!Set methodsFor: nil!

any
	"Return a random element. Much better than 'asArray first' "

	self do: [:each | ^each].
	self error: 'set is empty'! !

!String class methodsFor: nil!

methodSelector: methodDefinitionString 
	"Private - Answer a <readableString>, the method selector extracted from the instance or class method definition methodDefinitionString if found, or <nil> if not found. 
	Note: This is not bullet proof.
	99/12/02 Harmon, R. A. 	Fixed error. 
	99/12/03 Harmon, R. A. 	Fixed %Definition:% accepted as keyword error."
	| sourceStream selectorStream token |
	#'ACSProS'.
	sourceStream := ReadStream on: methodDefinitionString trimBlanks.
	sourceStream contents isEmpty ifTrue: [^ nil].
	token := sourceStream nextToken.
	token isNil ifTrue: [^ nil].
	token last = $: ifFalse: ["Binary or unary selector."
		^ token].
	selectorStream := WriteStream on: (String new: 20).
	[(token isNil or: [token isEmpty]) not and: [token last = $: & ((token includes: $") not & (token includes: $') not & (token includes: $|) not)]]
		whileTrue: 
			[selectorStream nextPutAll: token.
			sourceStream nextToken.
			"Get keyword."
			token := sourceStream nextToken].
	^ selectorStream contents! !

PuttableStreamHelper initialize.

ObjectHelper initialize.

CollectionStreamHelper initialize.

SequencedStreamHelper initialize.

GettableStreamHelper initialize.

CollectionHelper initialize.

TestCaseHelper initialize.

WriteStreamHelper initialize.

ReadStreamHelper initialize.

ProtocolSpec initialize.
!
