"Market balancing price model"

"smalltalk version 1.9"

"6/1/95"

"copyright 1995, Richard E. Hawkins"
"all rights reserved"




Object subclass: #Agent
       instanceVariableNames: 'cash doneForDay inventory id '
       classVariableNames: 'lastID hour date nHours World nCostToShop'
       poolDictionaries: ''
       category: nil !

Agent comment: 'I am the root agent class for AL models!'!

!Agent class methodsFor: 'instance creation'!

    classInit: modelSpecs

	"how boring"
	!    

new

    |r|

    r := super new.
    r init.

    ^r

	!

newID
    "this returns a new, unique, id number"

    lastID := lastID + 1.

    ^lastID	


	! !


!Agent  methodsFor: 'instance initialization'!

init
    

    id := (Agent newID ).
    cash := 0.
    inventory := 0    
	"   'Whee!  ive been inited' printNl"

	! !


!Agent  methodsFor: 'methods for variable acces'!

tellID
    ^id
	!

tellInv
    ^inventory
	!

tellCash
    ^cash

	!

    setCash: newCash
	cash := newCash.
	!

perish
    inventory := 0
	!

    addCash: howMuch
	cash := cash + howMuch
	    !

newDay
    self perish .
    doneForDay = false




	! !



"the person will be the dominant agent type"




Agent  subclass: #Person
       instanceVariableNames: ''
       classVariableNames: 'lastID nDailyCash initYet '
       poolDictionaries:''
       category: nil !




Person  comment: 'I am a person, and I live in Hawkinsville.'!

!Person   class methodsFor: 'instance creation'!



new

    |r|

    (initYet = nil) 
	ifTrue: 
	    [    nDailyCash := 20000.
		 initYet := true].
    r := super new.
    r init.
    ^r
	

	! !

!Person methodsFor: 'instance initialization'!

init
    
    

    ^ super init
	! !







"!Person methodsFor: 'methods for daily initialization'!"


"nothing here, really"


"! !"


" *** end of class Person *** "


Person  subclass: #Merchant
	instanceVariableNames: 'myPrices myTransactions mySales myLostTransactions myLostSales gHrTolerance gHrCh0 gHrCh1 gHrCh2'
	classVariableNames: 'nDailyInventory  lastID hChanges dChanges'
	poolDictionaries: ''
	category: nil !


Merchant comment: 'I am a Merchant, and I live in Hawkinsville.'!

!Merchant class methodsFor: 'instance creation'!

    classInit: modelSpecs
	lastID :=0.
	nDailyInventory := (modelSpecs tellDailyInventory) 
	    !

new

    |r|

    r := super new.
    r init.
    ^r
	

	! !



!Merchant methodsFor: 'instance initialization'!

    init: modelSpecs

	super init.

	"an array to keep track of prices by hour"
	myPrices := (Array new: 5)   "nHours"
	    ! !




!Merchant methodsFor: 'methods for daily initialization'!


newDay
    
    | temp | 
    super NewDay. "get general agent newday stuff"
    
    inventory = nDailyInventory.
    
    "put the adjusted closing price into a temporary spot"
    temp :=  myPrices at: (nHours+1).
    
    "flush the data "

    [:array | array atAllPut: 0 ] 

	myPrices myTransactions mySales myLostTransactions myLostSale


	! !





"!Merchant methodsFor: 'methods for variable access2'!"
!Merchant methodsFor: 'methods for general behavior'!



tellPrice

    ^myPrices at: hour

!
 
endHour

    self setPrice.
	super endHour
!

endOfDay

    "end of day merchant behavior"

"compile the days information"

"this will compile the data for each log"
"additionally, it will compile to the master log, whose"
"identity is known to the class"
    [:dayLog | dayLog sumUp ] 
	myPrices myTransactions mySales myLostTransactions myLostSale.

	self setPrice.
	super endOfDay
!

setPrice
    (hour = 'endOfDay')
	ifTrue: [self setPriceDay]
	ifFalse: [self setPriceHour].

!

setPriceHour

|dev aDev sDev change|

    dev := (self myDev).
    aDev := (dev abs).
    (dev = 0)
	ifTrue: [sDev := 0]
	ifFalse: [sDev := dev/aDev].
    (aDev > gHrTolerance) ifTrue:
	["stuff is selling at the wrong speed; change price"
	 change := sDev * (gHrCh0 + gHrCh1*aDev + gHrCh2*aDev*aDev).
	 hChanges inc.	 ]
			 ifFalse: [change := 0].
    myPrices setNextHour: change.
!

gHrTolerance gHrCh0 gHrCh1 gHrCh2     

!

setPriceHour
|dev change|

dev := (self myDev)

d

!
myDev
"write this!!! ***"



	! !











" *** end of class Merchant *** "






"The world is of course populated with Consumers"


Person  subclass: #Consumer
	instanceVariableNames: 'trysLeft'
	classVariableNames: 'nDailyCash  lastID sinboy nTotMerchants yestPrice'
	poolDictionaries: ''
	category: nil !





Consumer  comment: 'I am a Consumer, and I live in Hawkinsville.'!

!Consumer class methodsFor: 'instance creation'!

    classInit: modelSpecs
	lastID :=0.
	nDailyCash := (modelSpecs tellDailyCash) 
	    !
new

    |r|

    r := super new.
    r init.
    ^r
	

	! !

!Consumer methodsFor: 'instance initialization'!

init
    
    

    ^ super init
	! !


!Consumer methodsFor: 'general behavior'!
    "seller howMuch price"
smile

!
at: key  put: value
    | index assoc |
    "index := self findKeyIndex: key."
    
     
     
!



buyStuff:  howMany at: price from: myMerch

    "make sure he can afford it"
    |iGot  quant|

    

    (cash < (price * howMany) )
	ifTrue: [ quant  := (cash / price) ]
	ifFalse: [ quant := howMany copy].

    iGot := ( myMerch sell: quant).
    
    inventory := inventory + iGot.
    
    cash := cash - (myMerch getPaid: (iGot * price)).
    ^ iGot

		    
		    
	!


newDay
    
    super newDay.
    cash := nDailyCash.
    "give us this day. . ."
    World rShopSchedule: (self) 
	"schedule me to shop at a random time"

	!



shop

    "it is definitely time to shop"
    "note that the c++ version called him daily and he checked to see if"
    "  it was time to shop"
    "and for that matter, this section could be probably halved in lenght;"
    " this is essentially the c++ code"


    | myMerch price demand yestPrDemand |    

    myMerch := ( World randMerch ).
    
    price :=  (myMerch tellPrice ).
    demand := (self myDemand: myMerch price) - inventory.
    (demand < 0) ifTrue: [demand := 0].
    
    "is it worth buying here?"
    yestPrDemand = self demand: yestPrice.

    ( (price > (yestPrice + nCostToShop/yestPrDemand)) &
	  (hour < nHours) & (trysLeft > 0) & (demand > 0) )
	ifTrue: "this guy is too expensive, try next hour"
	    [ self abortShop ]
	ifFalse: [self buyStuff:  demand at: price from: myMerch ].

    (inventory < demand)
	ifTrue: [doneForDay := true]



	!

    myDemand:  price
	"the consumer's demand at the given price"
	"perhaps this can inherit a code segment from modelSpecs"
	
	| dem |

    (date < 10)
	ifTrue: [dem := 200 - price]
	ifFalse: [dem := 200 - price + 25 * sinboy].

    ^ dem
	!



abortShop
    cash := cash - nCostToShop.
    trysLeft := trysLeft - 1.
    World shopReSchedule: self.
    ^ True
	

! !


"the DayLog class is to keep track of & total hourly transactions"

Array  subclass: #DayLog

	instanceVariableNames: 'carryOver total'
	classVariableNames: ''
	poolDictionaries: ''
	category: nil !



DayLog  comment: 'DayLogs are extended arrays with also  endOfDay & total elements'

!DayLog class methodsFor: 'instance creation'!


new

    |r|

    r := super new.
    r init.
    ^r
	

	! !

!DayLog methodsFor: 'instance initialization'!

init
    ^ super init
	! !

!DayLog methodsFor: 'general behavior'!

endOfDay

 "   [:array | array atAllPut: 0 ] 

	myPrices myTransactions mySales myLostTransactions myLostSale
"
"sum the elements into Total"
! !
