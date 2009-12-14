SystemEventManager subclass: EventDispatcher [
    | events |

    removeActionsWithReceiver: anObject forEvent: anEvent [
	"Stop sending system notifications to an object"

	| dict |
	dict := events keys at: anEvent ifAbsent: [ ^ self ].
	dict removeKey: anObject ifAbsent: [ ^ self ].
    ]

    when: eachEvent send: oneArgumentSelector to: anObject [
	"Notifies an object of any events in the eventsCollection. Send it back a message 
	#oneArgumentSelector, with as argument the particular system event instance"

	| dict |
	dict := events at: eachEvent ifAbsentPut: [ WeakKeyIdentityDictionary new ].
	dict at: anObject put: oneArgumentSelector
    ]

    triggerEvent: anEventSelector with: anEvent [

	| dict |
	dict := events at: anEventSelector ifAbsent: [ ^ self ].
	dict associationsDo: [ :each |
	    each key perform: each value with: anEvent ]
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	events := Dictionary new
    ]
]

