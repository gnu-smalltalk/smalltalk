"======================================================================
|
|   The Richards Benchmark in Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000 Free Software Foundation, Inc.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #RBObject
    instanceVariableNames: ''
    classVariableNames: 'DeviceA DeviceB DevicePacketKind HandlerA HandlerB Idler Worker WorkPacketKind '
    poolDictionaries: ''
    category: 'Examples-Richards'!

RBObject subclass: #Packet
    instanceVariableNames: 'link identity kind datum data '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!

RBObject subclass: #RichardsBenchmark
    instanceVariableNames: 'taskList currentTask currentTaskIdentity taskTable tracing layout queuePacketCount holdCount '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!

RBObject subclass: #TaskState
    instanceVariableNames: 'packetPendingIV taskWaiting taskHolding '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!

RBObject subclass: #DeviceTaskDataRecord
    instanceVariableNames: 'pending '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!

RBObject subclass: #HandlerTaskDataRecord
    instanceVariableNames: 'workIn deviceIn '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!

RBObject subclass: #WorkerTaskDataRecord
    instanceVariableNames: 'destination count '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!

TaskState subclass: #TaskControlBlock
    instanceVariableNames: 'link identity priority input state function handle '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!

RBObject subclass: #IdleTaskDataRecord
    instanceVariableNames: 'control count '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Richards'!


!RBObject methodsFor: 'utilities'!

append: packet head: queueHead
    | mouse link |
    packet link: nil.
    queueHead isNil ifTrue: [^packet].
    mouse := queueHead.
    [(link := mouse link) isNil]
	whileFalse: [mouse := link].
    mouse link: packet.
    ^queueHead! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RBObject class
    instanceVariableNames: ''!


!RBObject class methodsFor: 'initialize'!

initialize
    "RBObject initialize"
    DeviceA := 5.
    DeviceB := 6.
    DevicePacketKind := 1.
    HandlerA := 3.
    HandlerB := 4.
    Idler := 1.
    Worker := 2.
    WorkPacketKind := 2! !

RBObject initialize!




!Packet methodsFor: 'initialize'!

link: aLink identity: anIdentity kind: aKind 
    link := aLink.
    identity := anIdentity. 
    kind := aKind.
    datum := 1.
    data := ByteArray new: 4! !

!Packet methodsFor: 'accessing'!

data
    ^data!

datum
    ^datum!

datum:    someData
    datum := someData!

identity
    ^identity!

identity: anIdentity
    identity := anIdentity!

kind
    ^kind!

link
    ^link!

link: aWorkQueue 
    link := aWorkQueue! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Packet class
    instanceVariableNames: ''!


!Packet class methodsFor: 'instance creation'!

create: link identity: identity kind: kind 
    ^super new
	link: link
	identity: identity
	kind: kind! !



!RichardsBenchmark methodsFor: 'creation'!

createDevice: identity priority: priority work: work state: state 
    | data |
    data := DeviceTaskDataRecord create.
    self
	createTask: identity
	priority: priority
	work: work
	state: state
	function: 
	    [:work :word | | data functionWork |
	    data := word.
	    functionWork := work.
	    functionWork isNil
		ifTrue:
		    [(functionWork := data pending) isNil
			ifTrue: [self wait]
			ifFalse: 
			    [data pending: nil.
			    self queuePacket: functionWork]]
		ifFalse: 
		    [data pending: functionWork.
		    tracing
			ifTrue: 
			    [self trace: functionWork datum].
		    self holdSelf]]
	data: data!

createHandler: identity priority: priority work: work state: state 
    | data |
    data := HandlerTaskDataRecord create.
    self
	createTask: identity
	priority: priority
	work: work
	state: state
	function: 
	    [:work :word | | data workPacket count devicePacket |
	    data := word.
	    work isNil
		ifFalse: [WorkPacketKind == work kind 
		    ifTrue: [data workInAdd: work]
		    ifFalse: [data deviceInAdd: work]].
	    (workPacket := data workIn) isNil
		ifTrue: [self wait]
		ifFalse: 
		    [count := workPacket datum.
		    count > 4
			ifTrue: 
			    [data workIn: workPacket link.
			    self queuePacket: workPacket]
			ifFalse:
			    [(devicePacket := data deviceIn) isNil
				ifTrue: [self wait]
				ifFalse: 
				    [data deviceIn: devicePacket link.
				    devicePacket datum: (workPacket data at: count).
				    workPacket datum: count + 1.
				    self queuePacket: devicePacket]]]]
	data: data!

createIdler: identity priority: priority work: work state: state 
    | data |
    data := IdleTaskDataRecord create.
    self
	createTask: identity
	priority: priority
	work: work
	state: state
	function: 
	    [:work :word | | data |
	    data := word.
	    data count: data count - 1.
	    0 = data count
		ifTrue: [self holdSelf]
		ifFalse:
		    [0 = (data control bitAnd: 1)
			ifTrue: 
			    [data control: data control // 2.
			    self release: DeviceA]
			ifFalse: 
			    [data control: (data control // 2 bitXor: 53256).
			    self release: DeviceB]]]
	data: data!

createPacket: link identity: identity kind: kind 
    ^Packet
	create: link
	identity: identity
	kind: kind!

createTask: identity priority: priority work: work state: state function: aBlock data: data 
    | t |
    t := TaskControlBlock
		link: taskList
		create: identity
		priority: priority
		initialWorkQueue: work
		initialState: state
		function: aBlock
		privateData: data.
    taskList := t.
    taskTable at: identity put: t!

createWorker: identity priority: priority work: work state: state 
    | data |
    data := WorkerTaskDataRecord create.
    self
	createTask: identity
	priority: priority
	work: work
	state: state
	function: 
	    [:work :word | | data |
	    data := word.
	    work isNil
		ifTrue: [self wait]
		ifFalse: 
		    [data destination: (HandlerA = data destination
			    ifTrue: [HandlerB]
			    ifFalse: [HandlerA]).
		    work identity: data destination.
		    work datum: 1.
		    1 to: 4 do: 
			[:i | 
			data count: data count + 1.
			data count > 26 ifTrue: [data count: 1].
			work data at: i put: $A asInteger + data count - 1].
		    self queuePacket: work]]
	data: data! !

!RichardsBenchmark methodsFor: 'private'!

findTask: identity 
    | t |
    t := taskTable at: identity.
    t isNil ifTrue: [self error: 'findTask failed'].
    ^t!

holdSelf
    holdCount := holdCount + 1.
    currentTask taskHolding: true.
    ^currentTask link!

initScheduler
    queuePacketCount := holdCount := 0.
    taskTable := Array new: 6.
    taskList := nil!

initTrace: trace
    tracing := trace.
    layout := 0!

queuePacket: packet 
    | t |
    t := self findTask: packet identity.
    t isNil ifTrue: [^nil].
    queuePacketCount := queuePacketCount + 1.
    packet link: nil.
    packet identity: currentTaskIdentity.
    ^t addInput: packet checkPriority: currentTask!

release: identity 
    | t |
    t := self findTask: identity.
    t isNil ifTrue: [^nil].
    t taskHolding: false.
    t priority > currentTask priority
	ifTrue: [^t]
	ifFalse: [^currentTask]!

trace: id 
    layout := layout - 1.
    0 >= layout
	ifTrue: 
	    [Transcript cr.
	    layout := 50].
    Transcript show: id printString!

wait 
    currentTask taskWaiting: true.
    ^currentTask! !

!RichardsBenchmark methodsFor: 'scheduling'!

schedule
    currentTask := taskList. 
    [currentTask isNil]
	whileFalse: 
	    [currentTask isTaskHoldingOrWaiting
		ifTrue: [currentTask := currentTask link]
		ifFalse: 
		    [currentTaskIdentity := currentTask identity.
		    tracing ifTrue: [self trace: currentTaskIdentity].
		    currentTask := currentTask runTask]]! !

!RichardsBenchmark methodsFor: 'initialize'!

start
    ^self start: false
!

start: trace
    | workQ mark1 mark2 mark3 mark4 |
    self initTrace: trace; initScheduler.
    mark1 := Time millisecondClockValue.
    tracing ifTrue: [Transcript show: 'Bench mark starting'; cr].
    self
	createIdler: Idler
	priority: 0
	work: nil
	state: TaskState running.
    workQ := self
		createPacket: nil
		identity: Worker
		kind: WorkPacketKind.
    workQ := self
		createPacket: workQ
		identity: Worker
		kind: WorkPacketKind.
    self
	createWorker: Worker
	priority: 1000
	work: workQ
	state: TaskState waitingWithPacket.
    workQ := self
		createPacket: nil
		identity: DeviceA
		kind: DevicePacketKind.
    workQ := self
		createPacket: workQ
		identity: DeviceA
		kind: DevicePacketKind.
    workQ := self
		createPacket: workQ
		identity: DeviceA
		kind: DevicePacketKind.
    self
	createHandler: HandlerA
	priority: 2000
	work: workQ
	state: TaskState waitingWithPacket.
    workQ := self
		createPacket: nil
		identity: DeviceB
		kind: DevicePacketKind.
    workQ := self
		createPacket: workQ
		identity: DeviceB
		kind: DevicePacketKind.
    workQ := self
		createPacket: workQ
		identity: DeviceB
		kind: DevicePacketKind.
    self
	createHandler: HandlerB
	priority: 3000
	work: workQ
	state: TaskState waitingWithPacket.
    self
	createDevice: DeviceA
	priority: 4000
	work: nil
	state: TaskState waiting.
    self
	createDevice: DeviceB
	priority: 5000
	work: nil
	state: TaskState waiting.
    tracing ifTrue: [Transcript show: 'Starting'; cr].
    mark2 := Time millisecondClockValue.
    self schedule.
    mark3 := Time millisecondClockValue.
    tracing
	ifTrue: 
	    [Transcript show: 'Finished'; cr.
	    Transcript show: 'QueuePacket count = ' ;
		show: queuePacketCount printString;
		show: ' HoldCount = ';
		show: holdCount printString;
		cr.
	    Transcript cr; show: 'End of run'; cr].
    queuePacketCount = 23246 & (holdCount = 9297) ifFalse: [self error: 'wrong result'].
    mark4 := Time millisecondClockValue.
    tracing
	ifTrue:
	    [Transcript show: '***Scheduler time = ';
	        show: (mark3 - mark2) printString;
	        show: ' Total time = ';
	        show: (mark4 - mark1) printString;
	        cr].

  ^mark3 - mark2! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RichardsBenchmark class
    instanceVariableNames: ''!

!RichardsBenchmark class methodsFor: 'instance creation'!

report: string times: count run: aBlock
        "Report the time required to execute the given block."

        | time |
        time := 0.
	count timesRepeat: [ time := time + aBlock value ].
        Transcript show: string, ' ', (time // count) printString, ' milliseconds'; cr.!

standardBenchmark
        "This the combined benchmark."
        "Planner standardBenchmark"

        self report: 'Richards simulations' times: 100 run: [ self start ]!

start: trace
    "RichardsBenchmark start: true"

    ^self new start: trace!

start
    "RichardsBenchmark start"

    ^self new start! !



!TaskState methodsFor: 'initialize'!

packetPending
    packetPendingIV := true.
    taskWaiting := false.
    taskHolding := false!

running
    packetPendingIV := taskWaiting := taskHolding := false!

waiting
    packetPendingIV := taskHolding := false.
    taskWaiting := true!

waitingWithPacket
    taskHolding := false.
    taskWaiting := packetPendingIV := true! !

!TaskState methodsFor: 'accessing'!

isPacketPending
    ^packetPendingIV!

isTaskHolding
    ^taskHolding!

isTaskWaiting
    ^taskWaiting!

taskHolding: aBoolean
    taskHolding := aBoolean!

taskWaiting: aBoolean 
    taskWaiting := aBoolean! !

!TaskState methodsFor: 'testing'!

isRunning
    ^packetPendingIV not and: [taskWaiting not and: [taskHolding not]]!

isTaskHoldingOrWaiting
    ^taskHolding or: [packetPendingIV not and: [taskWaiting]]!

isWaiting
    ^packetPendingIV not and: [taskWaiting and: [taskHolding not]]!

isWaitingWithPacket
    ^packetPendingIV and: [taskWaiting and: [taskHolding not]]! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

TaskState class
    instanceVariableNames: ''!


!TaskState class methodsFor: 'instance creation'!

packetPending
    ^super new packetPending!

running
    ^super new running!

waiting
    ^super new waiting!

waitingWithPacket
    ^super new waitingWithPacket! !



!DeviceTaskDataRecord methodsFor: 'initialize'!

create
    pending := nil! !

!DeviceTaskDataRecord methodsFor: 'accessing'!

pending
    ^pending!

pending: packet 
    pending := packet! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DeviceTaskDataRecord class
    instanceVariableNames: ''!


!DeviceTaskDataRecord class methodsFor: 'instance creation'!

create
    ^super new create! !



!HandlerTaskDataRecord methodsFor: 'initialize'!

create
    workIn := deviceIn := nil! !

!HandlerTaskDataRecord methodsFor: 'accessing'!

deviceIn
    ^deviceIn!

deviceIn: aPacket
    deviceIn := aPacket!

deviceInAdd: packet
    deviceIn := self append: packet head: deviceIn!

workIn
    ^workIn!

workIn: aWorkQueue 
    workIn := aWorkQueue!

workInAdd: packet
    workIn := self append: packet head: workIn! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HandlerTaskDataRecord class
    instanceVariableNames: ''!


!HandlerTaskDataRecord class methodsFor: 'instance creation'!

create
    ^super new create! !



!WorkerTaskDataRecord methodsFor: 'initialize'!

create
    destination := HandlerA.
    count := 0! !

!WorkerTaskDataRecord methodsFor: 'accessing'!

count
    ^count!

count: aCount
    count := aCount!

destination
    ^destination!

destination: aHandler
    destination := aHandler! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

WorkerTaskDataRecord class
    instanceVariableNames: ''!


!WorkerTaskDataRecord class methodsFor: 'instance creation'!

create
    ^super new create! !



!TaskControlBlock methodsFor: 'initialize'!

link: aLink identity: anIdentity priority: aPriority initialWorkQueue: anInitialWorkQueue initialState: anInitialState function: aBlock privateData: aPrivateData 
    link := aLink.
    identity := anIdentity.
    priority := aPriority.
    input := anInitialWorkQueue.
    packetPendingIV := anInitialState isPacketPending.
    taskWaiting := anInitialState isTaskWaiting.
    taskHolding := anInitialState isTaskHolding.
    function := aBlock.
    handle := aPrivateData! !

!TaskControlBlock methodsFor: 'accessing'!

identity
    ^identity!

link
    ^link!

priority
    ^priority! !

!TaskControlBlock methodsFor: 'scheduling'!

addInput: packet checkPriority: oldTask
    input isNil
	ifTrue: 
	    [input := packet.
	    packetPendingIV := true.
	    priority > oldTask priority ifTrue: [^self]]
	ifFalse: 
	    [input := self append: packet head: input].
    ^oldTask!

runTask
    | message |
    self isWaitingWithPacket
	ifTrue: 
	    [message := input.
	    input := message link.
	    input isNil
		ifTrue: [self running]
		ifFalse: [self packetPending]]
	ifFalse: [message := nil].
    ^function value: message value: handle! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

TaskControlBlock class
    instanceVariableNames: ''!


!TaskControlBlock class methodsFor: 'instance creation'!

link: link create: identity priority: priority initialWorkQueue: initialWorkQueue initialState: initialState function: aBlock privateData: privateData 
    ^super new
	link: link
	identity: identity
	priority: priority
	initialWorkQueue: initialWorkQueue
	initialState: initialState
	function: aBlock
	privateData: privateData! !


!IdleTaskDataRecord methodsFor: 'initialize'!

create
    control := 1.
    count := 10000! !

!IdleTaskDataRecord methodsFor: 'accessing'!

control
    ^control!

control: aNumber
    control := aNumber!

count
    ^count!

count: aCount
    count := aCount! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IdleTaskDataRecord class
    instanceVariableNames: ''!


!IdleTaskDataRecord class methodsFor: 'instance creation'!

create
    ^super new create! !

