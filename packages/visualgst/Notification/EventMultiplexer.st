SystemEventManager subclass: EventMultiplexer [
    | sources |

    add: anObject [
	"Start sending system notifications to a manager"

        ^ sources add: anObject
    ]

    remove: anObject [
	"Stop sending system notifications to a manager"

        ^ sources remove: anObject ifAbsent: [ nil ]
    ]

    triggerEvent: anEventSelector with: anEvent [

	sources do: [ :each | each triggerEvent: anEventSelector with: anEvent ]
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	sources := WeakIdentitySet new
    ]
]

