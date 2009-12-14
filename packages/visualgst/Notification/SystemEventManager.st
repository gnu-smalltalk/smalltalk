Object subclass: SystemEventManager [

    SystemEventManager class >> new [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    yourself
    ]
   
    initialize [
	<category: 'initialize-release'>

        self releaseActionMap
    ]

    triggerEvent: anEventSelector with: anEvent [

	self subclassResponsibility
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	self subclassResponsibility
    ]
]

