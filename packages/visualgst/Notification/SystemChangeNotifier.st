EventMultiplexer subclass: SystemChangeNotifier [
    SystemChangeNotifier class [ | root | ]

    | eventSource silenceLevel |

    initialize [
	<category: 'initialize'>

        super initialize.
	eventSource := EventDispatcher new.
        self add: eventSource.
	silenceLevel := 0
    ]

    doSilently: aBlock [
        "Perform the block, and ensure that no system notification are broadcasted while doing so."
	<category: 'public'>

	| result |
	silenceLevel := silenceLevel + 1.
	[result := aBlock value] ensure: [silenceLevel > 0 ifTrue: [silenceLevel := silenceLevel - 1]].
	^ result
    ]

    isBroadcasting [
	<category: 'public'>

	^ silenceLevel = 0
    ]

    noMoreNotificationsFor: anObject [
	"Stop sending system notifications to an object."

	eventSource removeActionsWithReceiver: anObject
    ]

    notify: anObject ofAllSystemChangesUsing: oneArgumentSelector [
	"Notifies an object of any system changes."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: self allSystemEvents
	    using: oneArgumentSelector
    ]

    notify: anObject ofSystemChangesOfChange: changeKind using: oneArgumentSelector [
	"Notifies an object of system changes of the specified changeKind (#added, #removed, ...). Evaluate 'AbstractEvent allChangeKinds' to get the complete list."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: (self systemEventsForChange: changeKind)
	    using: oneArgumentSelector
    ]

    notify: anObject ofSystemChangesOfItem: itemKind change: changeKind using: oneArgumentSelector [
	"Notifies an object of system changes of the specified itemKind (#class, #category, ...) and changeKind (#added, #removed, ...). This is the finest granularity possible.
	Evaluate 'AbstractEvent allChangeKinds' to get the complete list of change kinds, and 'AbstractEvent allItemKinds to get all the possible item kinds supported."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: (Bag with: (self systemEventsForItem: itemKind change: changeKind))
	    using: oneArgumentSelector
    ]

    notify: anObject ofSystemChangesOfItem: itemKind  using: oneArgumentSelector [
	"Notifies an object of system changes of the specified itemKind (#class, #method, #protocol, ...). Evaluate 'AbstractEvent allItemKinds' to get the complete list."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: (self systemEventsForItem: itemKind)
	    using: oneArgumentSelector
    ]

    namespaceAdded: aNamespace [
	<category: 'system triggers'>

	self trigger: (AddedEvent namespace: aNamespace)
    ]

    namespaceRemoved: aNamespace [
        <category: 'system triggers'>

        self trigger: (RemovedEvent namespace: aNamespace)
    ]

    classCategoryAdded: aClassCategory [
	<category: 'system triggers'>

        self trigger: (AddedEvent
			    classCategory: aClassCategory)
    ]

    classCategoryRemoved: aClassCategory [
	<category: 'system triggers'>

        self trigger: (RemovedEvent
			    classCategory: aClassCategory)
    ]

    classCategoryRenamedFrom: anOldClassCategoryName to: aNewClassCategoryName [
	<category: 'system triggers'>

        self trigger: (RenamedEvent
		    classCategoryRenamedFrom: anOldClassCategoryName 
		    to: aNewClassCategoryName)
    ]

    class: aClass recategorizedFrom: oldCategory to: newCategory [
	<category: 'system triggers'>

        self trigger: (RecategorizedEvent 
		class: aClass
		category: newCategory
		oldCategory: oldCategory)
    ]

    classAdded: aClass [
        <category: 'system triggers'>

        self trigger: (AddedEvent class: aClass)
    ]

    classRemoved: aClass [
	<category: 'system triggers'>

        self trigger: (RemovedEvent class: aClass)
    ]

    classAdded: aClass inCategory: aCategoryName [
	<category: 'system triggers'>

	self trigger: (AddedEvent class: aClass category: aCategoryName)
    ]

    classCommented: aClass [
	"A class with the given name was commented in the system."
	<category: 'system triggers'>

	self trigger: (CommentedEvent class: aClass)
    ]

    classCommented: aClass inCategory: aCategoryName [
	"A class with the given name was commented in the system."
	<category: 'system triggers'>

	self trigger: (CommentedEvent class: aClass category: aCategoryName)
    ]

    classDefinitionChangedFrom: oldClass to: newClass [
	<category: 'system triggers'>

	self trigger: (ModifiedEvent classDefinitionChangedFrom: oldClass to: newClass)
    ]

    classRemoved: aClass fromCategory: aCategoryName [
	<category: 'system triggers'>

	self trigger: (RemovedEvent class: aClass category: aCategoryName)
    ]

    classRenamed: aClass from: oldClassName to: newClassName inCategory: aCategoryName [
	<category: 'system triggers'>

        self trigger: (RenamedEvent 
		class: aClass
		category: aCategoryName
		oldName: oldClassName
		newName: newClassName)
    ]

    classReorganized: aClass [
	<category: 'system triggers'>

	self trigger: (ReorganizedEvent class: aClass)
    ]

    evaluated: textOrStream [
	<category: 'system triggers'>

	^ self evaluated: textOrStream context: nil
    ]

    evaluated: expression context: aContext [
	<category: 'system triggers'>

	self trigger: (DoItEvent 
		expression: expression
		context: aContext)
    ]

    categoryAdded: aCategory inClass: aClass [
        "A category was added to aClass"
        <category: 'system triggers'>

        self trigger: (AddedEvent
                category: aCategory
                class: aClass)
    ]

    categoryRemoved: aCategory inClass: aClass [
        "A category was removed to aClass"
        <category: 'system triggers'>

        self trigger: (RemovedEvent
                category: aCategory
                class: aClass)
    ]

    methodAdded: aCompiledMethod [
	<category: 'system triggers'>

	self trigger: (AddedEvent method: aCompiledMethod)
    ]

    methodRemoved: aCompiledMethod [
        <category: 'system triggers'>

        self trigger: (RemovedEvent method: aCompiledMethod)
    ]

    methodAdded: aMethod selector: aSymbol inClass: aClass [
	"A method with the given selector was added to aClass, but not put in a protocol."
	<category: 'system triggers'>

	self trigger: (AddedEvent
		method: aMethod 
		selector: aSymbol
		class: aClass)
    ]

    methodAdded: aMethod selector: aSymbol inClass: aClass requestor: requestor [
	"A method with the given selector was added to aClass, but not put in a protocol."
	<category: 'system triggers'>

	self trigger: (AddedEvent
		method: aMethod 
		selector: aSymbol
		class: aClass
		requestor: requestor)
    ]

    methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass [
	"A method with the given selector was added to aClass in protocol aCategoryName."
	<category: 'system triggers'>

    self trigger: (AddedEvent
		method: aMethod
		selector: aSymbol
		protocol: aCategoryName
		class: aClass)
    ]

    methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass requestor: requestor [
        "A method with the given selector was added to aClass in protocol aCategoryName."
	<category: 'system triggers'>

	self trigger: (AddedEvent
		method: aMethod
		selector: aSymbol
		protocol: aCategoryName
		class: aClass
		requestor: requestor)
    ]

    methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass [
	<category: 'system triggers'>

        self trigger: (ModifiedEvent
		    methodChangedFrom: oldMethod
		    to: newMethod
		    selector: aSymbol 
		    inClass: aClass)
    ]

    methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor [
	<category: 'system triggers'>

        self trigger: (ModifiedEvent
		    methodChangedFrom: oldMethod
		    to: newMethod
		    selector: aSymbol 
		    inClass: aClass
		    requestor: requestor)
    ]

    methodRemoved: aMethod selector: aSymbol class: aClass [
        "A method with the given selector was removed from the class."
	<category: 'system triggers'>

        self trigger: (RemovedEvent
		method: aMethod 
		selector: aSymbol
		class: aClass)
    ]

    methodRemoved: aMethod selector: aSymbol inProtocol: protocol class: aClass [
        "A method with the given selector was removed from the class."
	<category: 'system triggers'>

        self trigger: (RemovedEvent
		method: aMethod 
		selector: aSymbol
		protocol: protocol
		class: aClass)
    ]

    selector: selector recategorizedFrom: oldCategory to: newCategory inClass: aClass [
	<category: 'system triggers'>

	self trigger: (RecategorizedEvent 
		method: (aClass compiledMethodAt: selector ifAbsent: [nil])
		protocol: newCategory
		class: aClass
		oldProtocol: oldCategory)
    ]

    notify: anObject ofEvents: eventsCollection using: oneArgumentSelector [
	"Notifies an object of any events in the eventsCollection. Send it back a message #oneArgumentSelector, with as argument the particular system event instance."
	<category: 'private'>

	eventsCollection do: [:eachEvent |
	    eventSource when: eachEvent send: oneArgumentSelector to: anObject]
    ]

    releaseAll [
    "Release all the dependents so that nobody receives notifications anymore."

    "Done for cleaning up the system."
    "self uniqueInstance releaseAll"
	<category: 'private'>

	eventSource releaseActionMap
    ]

    setBroadcasting [
	<category: 'private'>

        silenceLevel := 0
    ]

    trigger: event [
	<category: 'private'>

        self isBroadcasting ifTrue: [event trigger: self]

"   | caughtExceptions |
    caughtExceptions := OrderedCollection new.
    self isBroadcasting ifTrue: [
	[(eventSource actionForEvent: event eventSelector) valueWithArguments: (Array with: event)] on: Exception do: [:exc | caughtExceptions add: exc]].
    caughtExceptions do: [:exc | exc resignalAs: exc class new]"
    ]

    allSystemEvents [
	<category: 'private-event lists'>

	^ AbstractEvent systemEvents
    ]

    systemEventsForChange: changeKind [
	<category: 'private-event lists'>

        | selectorBlock |
        selectorBlock := AbstractEvent eventSelectorBlock.
        ^AbstractEvent allItemKinds 
		collect: [:itemKind | selectorBlock value: itemKind value: changeKind]
    ]

    systemEventsForItem: itemKind [
	<category: 'private-event lists'>

        | selectorBlock |
	selectorBlock := AbstractEvent eventSelectorBlock.
        ^AbstractEvent allChangeKinds 
	   collect: [:changeKind | selectorBlock value: itemKind value: changeKind]
    ]

    systemEventsForItem: itemKind change: changeKind [
	<category: 'private-event lists'>

	^ AbstractEvent eventSelectorBlock value: itemKind value: changeKind
    ]

    SystemChangeNotifier class >> categoryKind [
	<category: 'item kinds'>

	^ AbstractEvent categoryKind
    ]

    SystemChangeNotifier class >> classKind [
	<category: 'item kinds'>

	^ AbstractEvent classKind
    ]

    SystemChangeNotifier class >> namespaceKind [
        <category: 'item kinds'>

        ^ AbstractEvent namespaceKind
    ]

    SystemChangeNotifier class >> expressionKind [
	<category: 'item kinds'>

        ^ AbstractEvent expressionKind
    ]

    SystemChangeNotifier class >> methodKind [
	<category: 'item kinds'>

	^ AbstractEvent methodKind
    ]

    SystemChangeNotifier class >> protocolKind [
	<category: 'item kinds'>

	^ AbstractEvent protocolKind
    ]


    SystemChangeNotifier class >> root [
	<category: 'public'>

        root ifNil: [root := self new].
	^root
    ]
]


