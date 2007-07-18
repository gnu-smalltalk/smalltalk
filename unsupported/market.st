"Market balancing price model"

"smalltalk version 1.9"

"6/1/95"

"copyright 1995, Richard E. Hawkins"

"all rights reserved"



Object subclass: Agent [
    | cash doneForDay inventory id |
    
    <category: nil>
    <comment: 'I am the root agent class for AL models!'>

    lastID := nil.
    hour := nil.
    date := nil.
    nHours := nil.
    World := nil.
    nCostToShop := nil.

    Agent class >> classInit: modelSpecs [
	"how boring"

	<category: 'instance creation'>
	
    ]

    Agent class >> new [
	<category: 'instance creation'>
	| r |
	r := super new.
	r init.
	^r
    ]

    Agent class >> newID [
	"this returns a new, unique, id number"

	<category: 'instance creation'>
	lastID := lastID + 1.
	^lastID
    ]

    init [
	<category: 'instance initialization'>
	id := Agent newID.
	cash := 0.
	inventory := 0
	"'Whee!  ive been inited' printNl"
    ]

    tellID [
	<category: 'methods for variable acces'>
	^id
    ]

    tellInv [
	<category: 'methods for variable acces'>
	^inventory
    ]

    tellCash [
	<category: 'methods for variable acces'>
	^cash
    ]

    setCash: newCash [
	<category: 'methods for variable acces'>
	cash := newCash
    ]

    perish [
	<category: 'methods for variable acces'>
	inventory := 0
    ]

    addCash: howMuch [
	<category: 'methods for variable acces'>
	cash := cash + howMuch
    ]

    newDay [
	<category: 'methods for variable acces'>
	self perish.
	doneForDay = false
    ]
]



"the person will be the dominant agent type"



Agent subclass: Person [
    
    <category: nil>
    <comment: 'I am a person, and I live in Hawkinsville.'>

    lastID := nil.
    nDailyCash := nil.
    initYet := nil.

    Person class >> new [
	<category: 'instance creation'>
	| r |
	initYet = nil 
	    ifTrue: 
		[nDailyCash := 20000.
		initYet := true].
	r := super new.
	r init.
	^r
    ]

    init [
	<category: 'instance initialization'>
	^super init
    ]
]



"!Person methodsFor: 'methods for daily initialization'!"

"nothing here, really"

"! !"

" *** end of class Person *** "



Person subclass: Merchant [
    | myPrices myTransactions mySales myLostTransactions myLostSales gHrTolerance gHrCh0 gHrCh1 gHrCh2 |
    
    <category: nil>
    <comment: 'I am a Merchant, and I live in Hawkinsville.'>

    nDailyInventory := nil.
    lastID := nil.
    hChanges := nil.
    dChanges := nil.

    Merchant class >> classInit: modelSpecs [
	<category: 'instance creation'>
	lastID := 0.
	nDailyInventory := modelSpecs tellDailyInventory
    ]

    Merchant class >> new [
	<category: 'instance creation'>
	| r |
	r := super new.
	r init.
	^r
    ]

    init: modelSpecs [
	<category: 'instance initialization'>
	super init.

	"an array to keep track of prices by hour"
	myPrices := Array new: 5	"nHours"
    ]

    newDay [
	<category: 'methods for daily initialization'>
	| temp |
	super NewDay.	"get general agent newday stuff"
	inventory = nDailyInventory.

	"put the adjusted closing price into a temporary spot"
	temp := myPrices at: nHours + 1.

	"flush the data"
	[:array | array atAllPut: 0] myPrices myTransactions mySales 
	    myLostTransactions myLostSale
    ]

    tellPrice [
	<category: 'methods for general behavior'>
	^myPrices at: hour
    ]

    endHour [
	<category: 'methods for general behavior'>
	self setPrice.
	super endHour
    ]

    endOfDay [
	"end of day merchant behavior"

	"compile the days information"

	"this will compile the data for each log"

	"additionally, it will compile to the master log, whose"

	"identity is known to the class"

	<category: 'methods for general behavior'>
	[:dayLog | dayLog sumUp] myPrices myTransactions mySales 
	    myLostTransactions myLostSale.
	self setPrice.
	super endOfDay
    ]

    setPrice [
	<category: 'methods for general behavior'>
	hour = 'endOfDay' ifTrue: [self setPriceDay] ifFalse: [self setPriceHour]
    ]

    setPriceHour [
	<category: 'methods for general behavior'>
	| dev change |
	dev := self myDev d
    ]

    gHrTolerance [
	<category: 'methods for general behavior'>
	gHrCh0 gHrCh1 gHrCh2
    ]

    myDev [
	"write this!!! ***"

	<category: 'methods for general behavior'>
	
    ]
]



" *** end of class Merchant *** "

"The world is of course populated with Consumers"



Person subclass: Consumer [
    | trysLeft |
    
    <category: nil>
    <comment: 'I am a Consumer, and I live in Hawkinsville.'>

    nDailyCash := nil.
    lastID := nil.
    sinboy := nil.
    nTotMerchants := nil.
    yestPrice := nil.

    Consumer class >> classInit: modelSpecs [
	<category: 'instance creation'>
	lastID := 0.
	nDailyCash := modelSpecs tellDailyCash
    ]

    Consumer class >> new [
	<category: 'instance creation'>
	| r |
	r := super new.
	r init.
	^r
    ]

    init [
	<category: 'instance initialization'>
	^super init
    ]

    at: key put: value [
	<category: 'general behavior'>
	
    ]

    buyStuff: howMany at: price from: myMerch [
	"make sure he can afford it"

	<category: 'general behavior'>
	| iGot quant |
	cash < (price * howMany) 
	    ifTrue: [quant := cash / price]
	    ifFalse: [quant := howMany copy].
	iGot := myMerch sell: quant.
	inventory := inventory + iGot.
	cash := cash - (myMerch getPaid: iGot * price).
	^iGot
    ]

    newDay [
	<category: 'general behavior'>
	super newDay.
	cash := nDailyCash.
	"give us this day. . ."
	World rShopSchedule: self
	"schedule me to shop at a random time"
    ]

    shop [
	"it is definitely time to shop"

	"note that the c++ version called him daily and he checked to see if"

	"it was time to shop"

	"and for that matter, this section could be probably halved in lenght;"

	"this is essentially the c++ code"

	<category: 'general behavior'>
	| myMerch price demand yestPrDemand |
	myMerch := World randMerch.
	price := myMerch tellPrice.
	demand := (self myDemand: myMerch price) - inventory.
	demand < 0 ifTrue: [demand := 0].

	"is it worth buying here?"
	yestPrDemand = self demand: yestPrice.
	price > ((yestPrice + nCostToShop) / yestPrDemand) & (hour < nHours) 
	    & (trysLeft > 0) & (demand > 0) 
	    ifTrue: 
		["this guy is too expensive, try next hour"

		self abortShop]
	    ifFalse: 
		[self 
		    buyStuff: demand
		    at: price
		    from: myMerch].
	inventory < demand ifTrue: [doneForDay := true]
    ]

    myDemand: price [
	"the consumer's demand at the given price"

	"perhaps this can inherit a code segment from modelSpecs"

	<category: 'general behavior'>
	| dem |
	date < 10 
	    ifTrue: [dem := 200 - price]
	    ifFalse: [dem := (200 - price + 25) * sinboy].
	^dem
    ]

    abortShop [
	<category: 'general behavior'>
	cash := cash - nCostToShop.
	trysLeft := trysLeft - 1.
	World shopReSchedule: self.
	^True
    ]
]



"the DayLog class is to keep track of & total hourly transactions"



Array subclass: DayLog [
    | carryOver total |
    
    <category: nil>
    <comment: 'DayLogs are extended arrays with also  endOfDay & total elements'>

    DayLog class >> new [
	<category: 'instance creation'>
	| r |
	r := super new.
	r init.
	^r
    ]

    init [
	<category: 'instance initialization'>
	^super init
    ]

    endOfDay [
	"[:array | array atAllPut: 0 ]
	 
	 myPrices myTransactions mySales myLostTransactions myLostSale"

	"sum the elements into Total"

	<category: 'general behavior'>
	
    ]
]

