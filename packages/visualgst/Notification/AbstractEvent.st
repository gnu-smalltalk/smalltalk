Object subclass: AbstractEvent [
    | item itemKind environment |

    item [
	<category: 'accessing'>
	"Return the item that triggered the event (typically the name of a class, a category, a protocol, a method)."

	^ item
    ]

    itemCategory [
	<category: 'accessing'>

	^ self environmentAt: self class categoryKind
    ]

    itemClass [
	<category: 'accessing'>

	^ self environmentAt: self class classKind
    ]

    itemExpression [
	<category: 'accessing'>

	^ self environmentAt: self class expressionKind
    ]

    itemKind [
	<category: 'accessing'>
	"Return the kind of the item of the event (#category, #class, #protocol, #method, ...)"

	^ itemKind
    ]

    itemMethod [
	<category: 'accessing'>

	^ self environmentAt: self class methodKind
    ]

    itemProtocol [
	<category: 'accessing'>

	^ self environmentAt: self class protocolKind
    ]

    itemRequestor [
	<category: 'accessing'>

	^ self environmentAt: #requestor
    ]

    itemSelector [
	<category: 'accessing'>

	^ self environmentAt: #selector
    ]

    printOn: aStream [
	<category: 'printing'>

	self printEventKindOn: aStream.
	aStream
	    nextPutAll: ' Event for item: ';
	    print: self item;
	    nextPutAll: ' of kind: ';
	    print: self itemKind
    ]

    isAdded [
	<category: 'testing'>

	^ false
    ]

    isCategoryKnown [
	<category: 'testing'>

	^ self itemCategory notNil
    ]

    isCommented [
	<category: 'testing'>

	^ false
    ]

    isDoIt [
	<category: 'testing'>

	^ false
    ]

    isModified [
	<category: 'testing'>

	^ false
    ]

    isProtocolKnown [
	<category: 'testing'>

	^ self itemCategory notNil
    ]

    isRecategorized [
	<category: 'testing'>

	^ false
    ]

    isRemoved [
	<category: 'testing'>

	^ false
    ]

    isRenamed [
	<category: 'testing'>

	^ false
    ]

    isReorganized [
	<category: 'testing'>

	^ false
    ]

    trigger: anEventManager [
	<cateogyr: 'triggering'>
	"Trigger the event manager."

	anEventManager triggerEvent: self eventSelector with: self
    ]

    changeKind [
	<category: 'private-accessing'>

	^ self class changeKind
    ]

    environmentAt: anItemKind [
	<category: 'private-accessing'>

	(self itemKind = anItemKind) ifTrue: [^self item].
	^ environment at: anItemKind ifAbsent: [nil]
    ]

    eventSelector [
	<category: 'private-accessing'>

	^ self class eventSelectorBlock value: itemKind value: self changeKind
    ]

    item: anItem kind: anItemKind [
	<category: 'private-accessing'>

	item := anItem.
	itemKind := anItemKind.
	environment := Dictionary new
    ]

    itemCategory: aCategory [
	<category: 'private-accessing'>

	environment at: self class categoryKind put: aCategory
    ]

    itemClass: aClass [
	<category: 'private-accessing'>

	environment at: self class classKind put: aClass
    ]

    itemExpression: anExpression [
	<category: 'private-accessing'>

	environment at: self class expressionKind put: anExpression
    ]

    itemMethod: aMethod [
	<category: 'private-accessing'>

	environment at: self class methodKind put: aMethod
    ]

    itemProtocol: aProtocol [
	<category: 'private-accessing'>

	environment at: self class protocolKind put: aProtocol
    ]

    itemRequestor: requestor [
	<category: 'private-accessing'>

	environment at: #requestor put: requestor
    ]

    itemSelector: aSymbol [
	<category: 'private-accessing'>

	environment at: #selector put: aSymbol
    ]

    AbstractEvent class >> allChangeKinds [
	<category: 'accessing'>
	"AbstractEvent allChangeKinds"

	^ AbstractEvent allSubclasses collect: [:cl | cl changeKind]
    ]

    AbstractEvent class >> allItemKinds [
	<category: 'accessing'>
	"self allItemKinds"

	| result |
	result := OrderedCollection new.
	AbstractEvent class methodDictionary do: [ :each | 
	    each methodCategory = 'item kinds' ifTrue: [ result add: (self perform: each selector) ] ].
	^ result
    ]

    AbstractEvent class >> changeKind [
	<category: 'accessing'>
	"Return a symbol, with a : as last character, identifying the change kind."

	self subclassResponsibility
    ]

    AbstractEvent class >> eventSelectorBlock [
	<category: 'accessing'>

	^ [:itemKind :changeKind | itemKind, changeKind, 'Event:']
    ]

    AbstractEvent class >> itemChangeCombinations [
	<category: 'accessing'>

	^ self supportedKinds collect: [:itemKind | self eventSelectorBlock value: itemKind value: self changeKind]
    ]

    AbstractEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take. By default this is all the kinds in the system. But subclasses can override this to limit the choices. For example, the SuperChangedEvent only works with classes, and not with methods, instance variables, ..."

	^ self allItemKinds
    ]

    AbstractEvent class >> systemEvents [
	<category: 'accessing'>
	"Return all the possible events in the system. Make a cross product of 
	the items and the change types."
	"self systemEvents"

	^self allSubclasses
	    inject: OrderedCollection new
	    into: [:allEvents :eventClass | allEvents addAll: eventClass itemChangeCombinations; yourself]
    ]

    AbstractEvent class >> namespace: aNamespace [
	<category: 'instance creation'>

	^ self item: aNamespace kind: AbstractEvent namespaceKind
    ]

    AbstractEvent class >> classCategory: aName [
	<category: 'instance creation'>

	^ self item: aName kind: AbstractEvent categoryKind
    ]

    AbstractEvent class >> class: aClass [
	<category: 'instance creation'>

	^ self item: aClass kind: AbstractEvent classKind
    ]

    AbstractEvent class >> method: aCompiledMethod [
        <category: 'instance creation'>

        ^ self item: aCompiledMethod kind: AbstractEvent methodKind
    ]

    AbstractEvent class >> class: aClass category: cat [
	<category: 'instance creation'>
 
	| instance |
	instance := self class: aClass.
	instance itemCategory: cat.
	^ instance
    ]

    AbstractEvent class >> item: anItem kind: anItemKind [
	<category: 'instance creation'>

	^ self basicNew item: anItem kind: anItemKind
    ]

    AbstractEvent class >> category: aCategory class: aClass [
        <category: 'instance creation'>

        | instance |
        instance := self item: aCategory kind: self categoryKind.
        instance itemClass: aClass.
        ^ instance
    ]

    AbstractEvent class >> method: aMethod class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self item: aMethod kind: self methodKind.
	instance itemClass: aClass.
	^ instance
    ]

    AbstractEvent class >> method: aMethod protocol: prot class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod class: aClass.
	instance itemProtocol: prot.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self item: aMethod kind: self methodKind.
	instance itemSelector: aSymbol.
	instance itemClass: aClass.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol class: aClass requestor: requestor [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod selector: aSymbol class: aClass.
	instance itemRequestor: requestor.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol protocol: prot class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod selector: aSymbol class: aClass.
	instance itemProtocol: prot.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol protocol: prot class: aClass requestor: requestor [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod selector: aSymbol protocol: prot class: aClass.
	instance itemRequestor: requestor.
	^ instance
    ]

    AbstractEvent class >> new [
	<category: 'instance creation'>
	"Override new to trigger an error, since we want to use specialized methods to create basic and higher-level events."

	^ self error: 'Instances can only be created using specialized instance creation methods.'
    ]

    AbstractEvent class >> categoryKind [
	<category: 'item kinds'>

	^ #category
    ]

    AbstractEvent class >> classKind [
	<category: 'item kinds'>

	^ #class
    ]

    AbstractEvent class >> namespaceKind [
        <category: 'item kinds'>

        ^ #namespace
    ]

    AbstractEvent class >> expressionKind [
	<category: 'item kinds'>

	^ #expression
    ]

    AbstractEvent class >> methodKind [
	<category: 'item kinds'>

	^ #method
    ]

    AbstractEvent class >> protocolKind [
	<category: 'item kinds'>

	^ #protocol
    ]

    AbstractEvent class >> comment1 [
	<category: 'temporary'>

"Smalltalk organization removeElement: #ClassForTestingSystemChanges3
Smalltalk garbageCollect 
Smalltalk organizati

classify:under:


SystemChangeNotifier root releaseAll
SystemChangeNotifier root noMoreNotificationsFor: aDependent.


aDependent := SystemChangeNotifierTest new.
SystemChangeNotifier root
    notifyOfAllSystemChanges: aDependent
    using: #event:

SystemChangeNotifier root classAdded: #Foo inCategory: #FooCat



| eventSource dependentObject |
eventSource := EventManager new.
dependentObject := Object new.

register - dependentObject becomes dependent:
eventSource
    when: #anEvent send: #error to: dependentObject.

unregister dependentObject:
eventSource removeDependent: dependentObject.

[eventSource triggerEvent: #anEvent]
    on: Error
    do: [:exc | self halt: 'Should not be!!']."
    ]

    AbstractEvent class >> comment2 [
	<category: 'temporary'>

"HTTPSocket useProxyServerNamed: 'proxy.telenet.be' port: 8080
TestRunner open

--------------------
We propose two orthogonal groups to categorize each event:
(1) the 'change type':
    added, removed, modified, renamed
    + the composite 'changed' (see below for an explanation)
(2) the 'item type':
    class, method, instance variable, pool variable, protocol, category
    + the composite 'any' (see below for an explanation).
The list of supported events is the cross product of these two lists (see below for an explicit enumeration of the events).

Depending on the change type, certain information related to the change is always present (for adding, the new things that was added, for removals, what was removed, for renaming, the old and the new name, etc.).

Depending on the item type, information regarding the item is present (for a method, which class it belongs to). 

Certain events 'overlap', for example, a method rename triggers a class change. To capture this I impose a hierarchy on the 'item types' (just put some numbers to clearly show the idea. They don't need numbers, really. Items at a certain categories are included by items one category number higher):
level 1 category
level 2 class
level 3 instance variable, pool variable, protocol, method.

Changes propagate according to this tree: any 'added', 'removed' or 'renamed' change type in level X triggers a 'changed' change type in level X - 1. A 'modified' change type does not trigger anything special.
For example, a method additions triggers a class modification. This does not trigger a category modification.

Note that we added 'composite events': wildcards for the 'change type' ('any' - any system additions) and for the 'item type' ('Changed' - all changes related to classes), and one for 'any change systemwide' (systemChanged).

This result is this list of Events:

classAdded
classRemoved
classModified
classRenamed (?)
classChanged (composite)

methodAdded
methodRemoved
methodModified
methodRenamed (?)
methodChanged (composite)

instanceVariableAdded
instanceVariableRemoved
instanceVariableModified 
instanceVariableRenamed (?)
instanceVariableChanged (composite)

protocolAdded
protocolRemoved
protocolModified
protocolRenamed (?)
protocolChanged (composite)

poolVariableAdded
poolVariableRemoved
poolVariableModified
poolVariableRenamed (?)
poolChanged (composite)

categoryAdded
categoryRemoved
categoryModified
categeryRenamed (?)
categoryChanged (composite)

anyAdded (composite)
anyRemoved (composite)
anyModified (composite)
anyRenamed (composite)

anyChanged (composite)



To check: can we pass somehow the 'source' of the change (a browser, a file-in, something else) ? Maybe by checking the context, but should not be too expensive either... I found this useful in some of my tools, but it might be too advanced to have in general. Tools that need this can always write code to check it for them.  But is not always simple...


Utilities (for the recent methods) and ChangeSet are the two main clients at this moment.

Important: make it very explicit that the event is send synchronously (or asynchronously, would we take that route).


		    category
			class
			    comment
			    protocol
				method
OR
		category
		Smalltalk
		    class
			comment
			protocol
			method
??



			Smalltalk   category
				\   /
				class
			    /	  | \
			comment  |  protocol
				  | /
				method

"
    ]

    AbstractEvent class >> comment3 [
	<category: 'temporary'>
"Things to consider for trapping:
ClassOrganizer>>#changeFromCategorySpecs:
    Problem: I want to trap this to send the appropriate bunch of ReCategorization events, but ClassOrganizer instances do not know where they belong to (what class, or what system); it just uses symbols. So I cannot trigger the change, because not enough information is available. This is a conceptual problem: the organization is stand-alone implementation-wise, while conceptually it belongs to a class. The clean solution could be to reroute this message to a class, but this does not work for all of the senders (that would work from the browserm but not for the file-in).

Browser>>#categorizeAllUncategorizedMethods
    Problem: should be trapped to send a ReCategorization event. However, this is model code that should not be in the Browser. Clean solution is to move it out of there to the model, and then trap it there (or reroute it to one of the trapped places).

Note: Debugger>>#contents:notifying: recompiles methods when needed, so I trapped it to get updates. However, I need to find a way to write a unit test for this. Haven't gotten around yet for doing this though...
"
    ]
]
