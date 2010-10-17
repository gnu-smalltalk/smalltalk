Object subclass: Announcement [
    
    <category: 'Announcements'>
    <comment: nil>

    Announcement class >> , anAnnouncementClass [
	<category: 'adding'>
	^AnnouncementClassCollection with: self with: anAnnouncementClass
    ]

    Announcement class >> asAnnouncement [
	<category: 'converting'>
	^self new
    ]

    Announcement class >> do: aBlock [
	"Act as a collection."

	<category: 'enumerating'>
	aBlock value: self
    ]

    Announcement class >> includes: aClass [
	"Act as a collection."

	<category: 'testing'>
	^self = aClass
    ]

    asAnnouncement [
	<category: 'converting'>
	^self
    ]
]



Object subclass: Announcer [
    | registry announcementBaseClass |
    
    <category: 'Announcements'>
    <comment: nil>

    Announcer class >> new [
        <category: 'instance creation'>
        ^self basicNew initialize
    ]

    announce: anObject [
	"Deliver anObject to the registered subscribers. anObject should respond to #asAnnouncement and return with an instance of announcementBaseClass. The return value is the announcement which can be modified by the subscribers."

	<category: 'announcements'>
	| announcement actualClass |
	announcement := anObject asAnnouncement.
	actualClass := announcement class.
	registry subscriptionsFor: actualClass announce: announcement.
	[actualClass == announcementBaseClass] whileFalse: 
		[actualClass := actualClass superclass.
		registry subscriptionsFor: actualClass announce: announcement].
	^announcement
    ]

    announcementBaseClass [
	"This is the base class of the classhierarchy which can be used as announcements in this announcer."

	<category: 'accessing'>
	^announcementBaseClass
    ]

    announcementBaseClass: aClass [
	"Set the base class of the classhierarchy which can be used as announcements in this announcer. Changing it while having registered subscriptions is very dangerous."

	<category: 'accessing'>
	(aClass ~= announcementBaseClass and: [registry isEmpty not]) 
	    ifTrue: 
		[Warning 
		    signal: 'Changing the base class of the announcement hierarchy may hang the image!'].
	announcementBaseClass := aClass
    ]

    initialize [
	<category: 'initialization'>
	registry := SubscriptionRegistry new.
	announcementBaseClass := Announcement
    ]

    mayAnnounce: anAnnouncementClass [
	"Decide if this announcer may announce an instance of anAnnanAnnouncementClass."

	<category: 'announcements'>
	^anAnnouncementClass == announcementBaseClass 
	    or: [anAnnouncementClass inheritsFrom: announcementBaseClass]
    ]

    on: anAnnouncementClassOrCollection do: aBlock [
	"For compatibiliy with Announcements package."

	<category: 'subscriptions'>
	^self when: anAnnouncementClassOrCollection do: aBlock
    ]

    on: anAnnouncementClassOrCollection send: aSelector to: anObject [
	"For compatibiliy with Announcements package."

	<category: 'subscriptions'>
	^self 
	    when: anAnnouncementClassOrCollection
	    send: aSelector
	    to: anObject
    ]

    subscriptionRegistry [
	<category: 'accessing'>
	^registry
    ]

    unsubscribe: anObject [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := registry subscriptionsOf: anObject.
	subscriptions isEmpty 
	    ifTrue: [self error: 'No subscriptions for ' , anObject asString].
	registry removeSubscriptions: subscriptions
    ]

    unsubscribe: anObject from: anAnnouncementClassOrCollection [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := registry subscriptionsOf: anObject
		    for: anAnnouncementClassOrCollection.
	subscriptions isEmpty 
	    ifTrue: 
		[self error: (anObject asString , ' has no subscriptions on ') 
			    , anAnnouncementClassOrCollection asString].
	registry removeSubscriptions: subscriptions
    ]

    when: anAnnouncementClassOrCollection do: aBlock [
	<category: 'subscriptions'>
	^self 
	    when: anAnnouncementClassOrCollection
	    do: aBlock
	    for: aBlock
    ]

    when: anAnnouncementClassOrCollection do: aBlock for: anObject [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := SubscriptionCollection new.
	anAnnouncementClassOrCollection do: 
		[:each | 
		| subscription |
		(self mayAnnounce: each) 
		    ifFalse: [self error: self asString , ' may not announce ' , each asString].
		subscription := registry subscriptionClass 
			    newWithAction: aBlock
			    announcer: self
			    announcementClass: each
			    subscriber: anObject.
		subscriptions add: subscription.
		registry register: subscription].
	^subscriptions
    ]

    when: anAnnouncementClassOrCollection send: aSelector to: anObject [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := SubscriptionCollection new.
	anAnnouncementClassOrCollection do: 
		[:each | 
		| subscription |
		(self mayAnnounce: each) 
		    ifFalse: [self error: self asString , ' may not announce ' , each asString].
		subscription := registry subscriptionClass 
			    newWithSelector: aSelector
			    announcer: self
			    announcementClass: each
			    subscriber: anObject.
		subscriptions add: subscription.
		registry register: subscription].
	^subscriptions
    ]
]



Object subclass: Subscription [
    | announcer announcementClass subscriber interceptors selector |
    
    <category: 'Announcements'>
    <comment: nil>

    action [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    action: aValuable [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    addInterceptor: aBlock [
	<category: 'interceptors'>
	aBlock numArgs > 3 
	    ifTrue: 
		[self error: 'The interceptor block should have 0, 1, 2 or 3 arguments!'].
	interceptors ifNil: [interceptors := OrderedCollection new].
	interceptors add: aBlock
    ]

    announcementClass [
	<category: 'accessing'>
	^announcementClass
    ]

    announcementClass: aClass [
	<category: 'accessing'>
	announcementClass := aClass
    ]

    announcer [
	<category: 'accessing'>
	^announcer
    ]

    announcer: anAnnouncer [
	<category: 'accessing'>
	announcer := anAnnouncer
    ]

    deliver: anAnnouncement from: anAnnouncer [
	<category: 'delivery'>
	self subclassResponsibility
    ]

    removeInterceptor [
	<category: 'interceptors'>
	interceptors removeLast.
	interceptors isEmpty ifTrue: [interceptors := nil]
    ]

    selector [
	<category: 'accessing'>
	^selector
    ]

    selector: aSelector [
	<category: 'accessing'>
	selector := aSelector
    ]

    subscriber [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    subscriber: anObject [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    value: anAnnouncement [
	<category: 'delivery'>
	self subclassResponsibility
    ]
]



Subscription subclass: StrongSubscription [
    | action |
    
    <category: 'Announcements'>
    <comment: nil>

    StrongSubscription class >> blockFor: anObject withSelector: aSelector [
	<category: 'private'>
	| args |
	args := aSelector numArgs.
	args = 0 ifTrue: [^[anObject perform: aSelector]].
	args = 1 
	    ifTrue: 
		[^[:anAnnouncement | anObject perform: aSelector with: anAnnouncement]].
	args = 2 
	    ifTrue: 
		[^
		[:anAnnouncement :anAnnouncer | 
		anObject 
		    perform: aSelector
		    with: anAnnouncement
		    with: anAnnouncer]].
	self error: 'Couldn''t create block'
    ]

    StrongSubscription class >> newWithAction: aBlock announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	^(self new)
	    action: aBlock;
	    announcer: anAnnouncer;
	    announcementClass: anAnnouncementClass;
	    subscriber: anObject;
	    yourself
    ]

    StrongSubscription class >> newWithSelector: aSelector announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	| block |
	block := self blockFor: anObject withSelector: aSelector.
	^(self new)
	    action: block;
	    announcer: anAnnouncer;
	    announcementClass: anAnnouncementClass;
	    subscriber: anObject;
	    selector: aSelector;
	    yourself
    ]

    action [
	<category: 'accessing'>
	^action
    ]

    action: aValuable [
	<category: 'accessing'>
	action := aValuable
    ]

    deliver: anAnnouncement from: anAnnouncer [
	<category: 'delivery'>
	^action cull: anAnnouncement cull: anAnnouncer
    ]

    subscriber [
	<category: 'accessing'>
	^subscriber
    ]

    subscriber: anObject [
	<category: 'accessing'>
	subscriber := anObject
    ]

    value: anAnnouncement [
	<category: 'delivery'>
	interceptors ifNil: [^action cull: anAnnouncement cull: announcer].
	interceptors do: 
		[:each | 
		each 
		    cull: anAnnouncement
		    cull: announcer
		    cull: self]
    ]
]



StrongSubscription subclass: WeakSubscription [
    
    <category: 'Announcements'>
    <comment: nil>

    WeakSubscription class >> blockFor: anObject withSelector: aSelector [
	<category: 'private'>
	| args |
	args := aSelector numArgs.
	args = 0 
	    ifTrue: [^[(anObject at: 1) ifNotNil: [:o | o perform: aSelector]]].
	args = 1 
	    ifTrue: 
		[^
		[:anAnnouncement | 
		(anObject at: 1) 
		    ifNotNil: [:o | o perform: aSelector with: anAnnouncement]]].
	args = 2 
	    ifTrue: 
		[^
		[:anAnnouncement :anAnnouncer | 
		(anObject at: 1) ifNotNil: 
			[:o | 
			o 
			    perform: aSelector
			    with: anAnnouncement
			    with: anAnnouncer]]].
	self error: 'Couldn''t create block'
    ]

    WeakSubscription class >> newWithAction: aBlock announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	| subscription |
	subscription := aBlock == anObject 
		    ifTrue: 
			[WeakBlockSubscription 
			    newForAnnouncer: anAnnouncer
			    announcementClass: anAnnouncementClass
			    subscriber: anObject]
		    ifFalse: 
			[super 
			    newWithAction: aBlock
			    announcer: anAnnouncer
			    announcementClass: anAnnouncementClass
			    subscriber: anObject].
	anObject 
	    toFinalizeSend: #removeSubscription:
	    to: anAnnouncer subscriptionRegistry
	    with: subscription.
	^subscription
    ]

    WeakSubscription class >> newWithSelector: aSelector announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	| subscription block |
	block := self blockFor: (WeakArray with: anObject) withSelector: aSelector.
	subscription := (self new)
		    action: block;
		    announcer: anAnnouncer;
		    announcementClass: anAnnouncementClass;
		    subscriber: anObject;
		    selector: aSelector;
		    yourself.
	anObject 
	    toFinalizeSend: #removeSubscription:
	    to: anAnnouncer subscriptionRegistry
	    with: subscription.
	^subscription
    ]

    subscriber [
	<category: 'accessing'>
	^subscriber at: 1
    ]

    subscriber: anObject [
	<category: 'accessing'>
	subscriber := WeakArray with: anObject
    ]
]



Subscription subclass: WeakBlockSubscription [
    
    <category: 'Announcements'>
    <comment: nil>

    WeakBlockSubscription class >> newForAnnouncer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	^(self new)
	    announcer: anAnnouncer;
	    announcementClass: anAnnouncementClass;
	    subscriber: anObject;
	    yourself
    ]

    action [
	<category: 'accessing'>
	^subscriber at: 1
    ]

    action: aValuable [
	<category: 'accessing'>
	^self shouldNotImplement
    ]

    deliver: anAnnouncement from: anAnnouncer [
	<category: 'delivery'>
	^(subscriber at: 1) 
	    ifNotNil: [:action | action cull: anAnnouncement cull: anAnnouncer]
    ]

    subscriber [
	<category: 'accessing'>
	^subscriber at: 1
    ]

    subscriber: anObject [
	<category: 'accessing'>
	subscriber := WeakArray with: anObject
    ]

    value: anAnnouncement [
	<category: 'delivery'>
	interceptors ifNil: 
		[^(subscriber at: 1) 
		    ifNotNil: [:action | action cull: anAnnouncement cull: announcer]].
	interceptors do: 
		[:each | 
		each 
		    cull: anAnnouncement
		    cull: announcer
		    cull: self]
    ]
]



Object subclass: SubscriptionRegistry [
    | subscriptionsByAnnouncementClasses subscriptionClass |
    
    <category: 'Announcements'>
    <comment: nil>

    SubscriptionRegistry class >> new [
        <category: 'instance creation'>
        ^self basicNew initialize
    ]

    allSubscriptions [
	<category: 'accessing'>
	| result |
	result := SubscriptionCollection new.
	subscriptionsByAnnouncementClasses do: [:each | result addAll: each].
	^result
    ]

    allSubscriptionsDo: aBlock [
	<category: 'accessing'>
	subscriptionsByAnnouncementClasses do: [:each | each do: aBlock]
    ]

    initialize [
	<category: 'initialization'>
	subscriptionsByAnnouncementClasses := IdentityDictionary new.
	subscriptionClass := StrongSubscription
    ]

    isEmpty [
	<category: 'testing'>
	^subscriptionsByAnnouncementClasses isEmpty
    ]

    register: aSubscription [
	<category: 'subscribing'>
	(subscriptionsByAnnouncementClasses at: aSubscription announcementClass
	    ifAbsentPut: [SubscriptionCollection new]) add: aSubscription
    ]

    removeSubscription: aSubscription [
	"Removes a subscription from the registry."

	<category: 'subscribing'>
	| subscriptionCollection |
	subscriptionCollection := subscriptionsByAnnouncementClasses 
		    at: aSubscription announcementClass.
	subscriptionCollection remove: aSubscription ifAbsent: nil.
	subscriptionCollection isEmpty 
	    ifTrue: 
		[subscriptionsByAnnouncementClasses 
		    removeKey: aSubscription announcementClass
		    ifAbsent: nil]
    ]

    removeSubscriptions: aCollection [
	<category: 'subscribing'>
	aCollection do: [:each | self removeSubscription: each]
    ]

    subscriptionClass [
	"This is the default subscription class. All new subscriptions are created with this class."

	<category: 'accessing'>
	^subscriptionClass
    ]

    subscriptionClass: aClass [
	"Set the default subscription class. All new subscriptions are created with this class.
	 aClass should be AXStrongSubscription or AXWeakSubscription."

	<category: 'accessing'>
	subscriptionClass := aClass
    ]

    subscriptionsFor: anAnnouncementClassOrCollection [
	<category: 'accessing'>
	| result |
	result := SubscriptionCollection new.
	anAnnouncementClassOrCollection do: 
		[:each | 
		subscriptionsByAnnouncementClasses at: each
		    ifPresent: [:subscriptionCollection | result addAll: subscriptionCollection]].
	^result
    ]

    subscriptionsFor: anAnnouncementClass announce: anAnnouncement [
	<category: 'private'>
	subscriptionsByAnnouncementClasses at: anAnnouncementClass
	    ifPresent: [:subscriptionCollection | subscriptionCollection value: anAnnouncement]
    ]

    subscriptionsOf: anObject [
	<category: 'accessing'>
	| result |
	result := SubscriptionCollection new.
	self 
	    allSubscriptionsDo: [:each | each subscriber == anObject ifTrue: [result add: each]].
	^result
    ]

    subscriptionsOf: anObject for: anAnnouncementClassOrCollection [
	<category: 'accessing'>
	^(self subscriptionsFor: anAnnouncementClassOrCollection) 
	    select: [:each | each subscriber == anObject]
    ]
]



OrderedCollection subclass: AnnouncementClassCollection [
    
    <category: 'Announcements'>
    <comment: nil>
    <shape: #inherit>

    , anAnnouncementClass [
	<category: 'adding'>
	^self
	    add: anAnnouncementClass;
	    yourself
    ]
]



OrderedCollection subclass: SubscriptionCollection [
    
    <category: 'Announcements'>
    <comment: nil>
    <shape: #inherit>

    interceptWith: aBlock while: anotherBlock [
	"Evaluate aBlock instead of the action for each of these subscriptions while anotherBlock is being evaluated."

	<category: 'intercept-suspend'>
	self do: [:each | each addInterceptor: aBlock].
	anotherBlock value.
	self do: [:each | each removeInterceptor]
    ]

    make: aSubscriptionClass [
	"Create and register a new subscription of aSubscriptionClass for all the subscriptions in this collection while removing the old subscriptions from the registry."

	<category: 'private'>
	^self collect: 
		[:each | 
		| registry subscription |
		registry := each announcer subscriptionRegistry.
		registry removeSubscription: each.
		subscription := each selector ifNil: 
				[aSubscriptionClass 
				    newWithAction: each action
				    announcer: each announcer
				    announcementClass: each announcementClass
				    subscriber: each subscriber]
			    ifNotNil: 
				[aSubscriptionClass 
				    newWithSelector: each selector
				    announcer: each announcer
				    announcementClass: each announcementClass
				    subscriber: each subscriber].
		registry register: subscription.
		subscription]
    ]

    makeStrong [
	"Create and register a new strong subscription for all the subscriptions in this collection, while removing the old subscriptions from the registry."

	<category: 'weak-strong'>
	^self make: StrongSubscription
    ]

    makeWeak [
	"Create and register a new weak subscription for all the subscriptions in this collection, while removing the old subscriptions from the registry."

	<category: 'weak-strong'>
	^self make: WeakSubscription
    ]

    suspendWhile: aBlock [
	"Suspend all the subscriptions in this collection while aBlock is being evaluated."

	<category: 'intercept-suspend'>
	self interceptWith: [] while: aBlock
    ]

    suspendWhile: aBlock ifAnyMissed: anotherBlock [
	"Suspend all the subscriptions in this collection while aBlock is being evaluated. If any would have been active, evaluate anotherBlock."

	<category: 'intercept-suspend'>
	| anyMissed |
	anyMissed := false.
	self interceptWith: [anyMissed := true] while: aBlock.
	anyMissed ifTrue: [anotherBlock value]
    ]

    value: anAnnouncement [
	<category: 'private'>
	self do: [:each | each value: anAnnouncement]
    ]
]

