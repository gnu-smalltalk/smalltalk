Object subclass: SystemEventManager [
    | events |

    SystemEventManager class >> new [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    yourself
    ]
   
    initialize [
	<category: 'initialize-release'>

	events := Dictionary new
    ]
 
    removeActionsWithReceiver: anObject [
	"Stop sending system notifications to an object"
    ]

    when: eachEvent send: oneArgumentSelector to: anObject [
	"Notifies an object of any events in the eventsCollection. Send it back a message 
	#oneArgumentSelector, with as argument the particular system event instance"

	| set |
	set := events at: eachEvent ifAbsentPut: [ Set new ].
	set add: (anObject -> oneArgumentSelector)
    ]

    triggerEvent: anEventSelector with: anEvent [

	| set |
	set := events at: anEventSelector ifAbsent: [ ^ self ].
	set do: [ :each |
	    each key perform: each value with: anEvent ]
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	events := Dictionary new
    ]
]

