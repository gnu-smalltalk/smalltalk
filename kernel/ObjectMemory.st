"=====================================================================
|
|   ObjectMemory method definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2003, 2005, 2006, 2008, 2009
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: ObjectMemory [
    | bytesPerOOP bytesPerOTE edenSize survSpaceSize oldSpaceSize fixedSpaceSize edenUsedBytes survSpaceUsedBytes oldSpaceUsedBytes fixedSpaceUsedBytes rememberedTableEntries numScavenges numGlobalGCs numCompactions numGrowths numOldOOPs numFixedOOPs numWeakOOPs numOTEs numFreeOTEs timeBetweenScavenges timeBetweenGlobalGCs timeBetweenGrowths timeToScavenge timeToCollect timeToCompact reclaimedBytesPerScavenge tenuredBytesPerScavenge reclaimedBytesPerGlobalGC reclaimedPercentPerScavenge allocFailures allocMatches allocSplits allocProbes |
    
    <category: 'Language-Implementation'>
    <comment: 'I provide a few methods that enable one to tune the
virtual machine''s usage of memory.  In addition, I can signal to my
dependants some `events'' that can happen during the virtual machine''s
life.

ObjectMemory has both class-side and instance-side methods.  In general,
class-side methods provide means to tune the parameters of the memory
manager, while instance-side methods are used together with the #current
class-side method to take a look at statistics on the memory manager''s
state.'>

    ObjectMemory class >> changed: aSymbol [
	<category: 'initialization'>
	| sema prio |
	prio := aSymbol == #returnFromSnapshot
	    ifTrue: [Processor highIOPriority]
	    ifFalse: [Processor userSchedulingPriority].

	Processor activePriority < prio
	    ifTrue: [
		sema := Semaphore new.

		"Ensure that modules and libraries are initialized before
		 anything else happens."
		[DLD update: aSymbol. super changed: aSymbol. 
		sema signal]
		    forkAt: prio.
		sema wait]
	    ifFalse: [
		DLD update: aSymbol. super changed: aSymbol].

	"Before quitting, wait until all processes are done."
	aSymbol == #aboutToQuit ifTrue: [
	    Processor activeProcess priority: Processor idlePriority.
	    Processor yield].
    ]

    ObjectMemory class >> initialize [
	"Initialize the globals"

	"This method is called after all the kernel Smalltalk classes have been
	 loaded.  It generally performs any initializations that might depend on
	 the full Smalltalk class hierarchy being defined. After this is file is
	 loaded, some 'advanced' class definitions are loaded (CFuncs, Autoload,
	 exception handling, ...) and then the binary image is saved."

	<category: 'initialization'>
	Object initialize.
	Class initialize.
	Fraction initialize.
	LargeInteger initialize.
	Date initialize.
	Time initialize.
	FileDescriptor initialize.
	Namespace initialize.
	Processor initialize.
	SystemDictionary initialize.
	self changed: #returnFromSnapshot
    ]

    ObjectMemory class >> current [
	"Return a snapshot of the VM's memory management statistics."

	<category: 'accessing'>
	^self new update
    ]

    ObjectMemory class >> addressOfOOP: anObject [
	"Returns the address of the OOP (object table slot) for anObject.
	 The address is an Integer and will not change over time (i.e. is
	 immune from garbage collector action) except if the virtual machine
	 is stopped and restarted."

	<category: 'builtins'>
	<primitive: VMpr_Memory_addressOfOOP>
	SystemExceptions InvalidArgument signalOn: anObject
	    reason: 'Cannot extract address of an immediate OOP'
    ]

    ObjectMemory class >> addressOf: anObject [
	"Returns the address of the actual object that anObject
	 references.  Note that, with the exception of fixed objects
	 this address is only valid until the next garbage collection;
	 thus it's pretty risky to count on the address returned by
	 this method for very long."

	<category: 'builtins'>
	<primitive: VMpr_Memory_addressOf>
	SystemExceptions InvalidArgument signalOn: anObject
	    reason: 'Cannot extract address of an immediate OOP'
    ]

    ObjectMemory class >> scavenge [
	"Force a minor garbage collection"

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_scavenge>
	^self primitiveFailed
    ]

    ObjectMemory class >> globalGarbageCollect [
	"Force a full garbage collection"

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_globalGarbageCollect>
	^self primitiveFailed
    ]

    ObjectMemory class >> compact [
	"Force a full garbage collection, including compaction of oldspace"

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_compact>
	^self primitiveFailed
    ]

    ObjectMemory class >> incrementalGCStep [
	"Do a step in the incremental garbage collection."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_incrementalGCStep>
	^self primitiveFailed
    ]

    ObjectMemory class >> finishIncrementalGC [
	"Do a step in the incremental garbage collection."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_finishIncrementalGC>
	^self primitiveFailed
    ]

    ObjectMemory class >> abort [
	"Quit the Smalltalk environment, dumping core."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_abort>
	
    ]

    ObjectMemory class >> quit [
	"Quit the Smalltalk environment. Whether files are closed and
	 other similar cleanup occurs depends on the platform"

	<category: 'builtins'>
	self quit: 0
    ]

    ObjectMemory class >> quit: exitStatus [
	"Quit the Smalltalk environment, passing the exitStatus integer
	 to the OS. Files are closed and other similar cleanups occur."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_quit>
	SystemExceptions.WrongClass signalOn: exitStatus mustBe: SmallInteger
    ]

    ObjectMemory class >> smoothingFactor [
	"Answer the factor (between 0 and 1) used to smooth the statistics
	 provided by the virtual machine about memory handling.  0 disables
	 updating the averages, 1 disables the smoothing (the statistics
	 return the last value)."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_getSmoothingFactor>
	^self primitiveFailed
    ]

    ObjectMemory class >> smoothingFactor: rate [
	"Set the factor (between 0 and 1) used to smooth the statistics
	 provided by the virtual machine about memory handling.  0 disables
	 updating the averages, 1 disables the smoothing (the statistics
	 return the last value)."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_setSmoothingFactor>
	rate class == FloatD 
	    ifTrue: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: rate
		    mustBeBetween: 0
		    and: 1]
	    ifFalse: [^self spaceGrowRate: rate asFloatD]
    ]

    ObjectMemory class >> spaceGrowRate [
	"Answer the rate with which the amount of memory used by the system grows"

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_getSpaceGrowRate>
	^self primitiveFailed
    ]

    ObjectMemory class >> spaceGrowRate: rate [
	"Set the rate with which the amount of memory used by the system grows"

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_setSpaceGrowRate>
	rate class == FloatD 
	    ifTrue: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: rate
		    mustBeBetween: 0.01
		    and: 500.0]
	    ifFalse: [^self spaceGrowRate: rate asFloatD]
    ]

    ObjectMemory class >> bigObjectThreshold [
	"Answer the smallest size for objects that are allocated outside
	 the main heap in the hope of providing more locality of reference
	 between small objects."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_getBigObjectThreshold>
	^self primitiveFailed
    ]

    ObjectMemory class >> bigObjectThreshold: bytes [
	"Set the smallest size for objects that are allocated outside
	 the main heap in the hope of providing more locality of reference
	 between small objects.  bytes must be a positive SmallInteger."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_setBigObjectThreshold>
	bytes isSmallInteger 
	    ifTrue: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: bytes
		    mustBeBetween: 0
		    and: SmallInteger largest]
	    ifFalse: [SystemExceptions.WrongClass signalOn: bytes mustBe: SmallInteger]
    ]

    ObjectMemory class >> growThresholdPercent [
	"Answer the percentage of the amount of memory used by the system grows
	 which has to be full for the system to allocate more memory"

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_getGrowThresholdPercent>
	^self primitiveFailed
    ]

    ObjectMemory class >> growThresholdPercent: growPercent [
	"Set the percentage of the amount of memory used by the system grows
	 which has to be full for the system to allocate more memory"

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_setGrowThresholdPercent>
	growPercent class == FloatD 
	    ifTrue: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: growPercent
		    mustBeBetween: 0.01
		    and: 100.0]
	    ifFalse: [^self growThresholdPercent: growPercent asFloatD]
    ]

    ObjectMemory class >> growTo: numBytes [
	"Grow the amount of memory used by the system grows to numBytes."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_growTo>
	^self primitiveFailed
    ]

    ObjectMemory class >> primSnapshot: aString [
	"Save an image on the aString file"

	<category: 'private - builtins'>
	<primitive: VMpr_ObjectMemory_snapshot>
	^aString isString 
	    ifFalse: [SystemExceptions.WrongClass signalOn: aString mustBe: String]
	    ifTrue: [File checkError]
    ]

    ObjectMemory class >> snapshot [
	"Save a snapshot on the image file that was loaded on startup."

	<category: 'saving the image'>
	^self primSnapshot: File image asString
    ]

    ObjectMemory class >> snapshot: aString [
	"Save an image on the aString file"

	<category: 'saving the image'>
	^self primSnapshot: aString asString
    ]

    ObjectMemory class >> gcMessage [
	"Answer whether messages indicating that garbage collection is taking
	 place are printed on stdout"

	<category: 'builtins'>
	^Smalltalk getTraceFlag: 3
    ]

    ObjectMemory class >> gcMessage: aBoolean [
	"Set whether messages indicating that garbage collection is taking
	 place are printed on stdout"

	<category: 'builtins'>
	^Smalltalk setTraceFlag: 3 to: aBoolean
    ]

    bytesPerOOP [
	"Answer the number of bytes that is taken by an ordinary
	 object pointer (in practice, a field such as a named instance
	 variable)."

	<category: 'accessing'>
	^bytesPerOOP
    ]

    bytesPerOTE [
	"Answer the number of bytes that is taken by an object
	 table entry (in practice, the overhead incurred by every
	 object in the system, with the sole exception of SmallIntegers)."

	<category: 'accessing'>
	^bytesPerOTE
    ]

    edenSize [
	"Answer the number of bytes in the `eden' area of the young
	 generation (in practice, the number of allocated bytes between
	 two scavenges)."

	<category: 'accessing'>
	^edenSize
    ]

    survSpaceSize [
	"Answer the number of bytes in the `survivor' area of the young
	 generation (the area to which young objects are relocated during
	 scavenges)."

	<category: 'accessing'>
	^survSpaceSize
    ]

    fixedSpaceSize [
	"Answer the number of bytes in the special heap devoted to
	 objects that the garbage collector cannot move around in memory."

	<category: 'accessing'>
	^fixedSpaceSize
    ]

    oldSpaceSize [
	"Answer the number of bytes in the old generation."

	<category: 'accessing'>
	^oldSpaceSize
    ]

    edenUsedBytes [
	"Answer the number of bytes that are currently filled in the
	 `eden' area of the young generation."

	<category: 'accessing'>
	^edenUsedBytes
    ]

    survSpaceUsedBytes [
	"Answer the number of bytes that are currently filled in the
	 `survivor' area of the young generation."

	<category: 'accessing'>
	^survSpaceUsedBytes
    ]

    oldSpaceUsedBytes [
	"Answer the number of bytes that are currently filled in the
	 old generation."

	<category: 'accessing'>
	^oldSpaceUsedBytes
    ]

    fixedSpaceUsedBytes [
	"Answer the number of bytes that are currently filled in the
	 special heap devoted to objects that the garbage collector
	 cannot move around in memory."

	<category: 'accessing'>
	^oldSpaceUsedBytes
    ]

    numScavenges [
	"Answer the number of scavenges (fast collections of the young
	 generation) that happened since the VM was started."

	<category: 'accessing'>
	^numScavenges
    ]

    numGlobalGCs [
	"Answer the number of global garbage collections (collection
	 of the entire heap) that happened since the VM was started."

	<category: 'accessing'>
	^numGlobalGCs
    ]

    numCompactions [
	"Answer the number of oldspace compactions that happened since
	 the VM was started."

	<category: 'accessing'>
	^numCompactions
    ]

    numGrowths [
	"Answer the number of times that oldspace was grown since
	 the VM was started."

	<category: 'accessing'>
	^numGrowths
    ]

    numOldOOPs [
	"Answer the number of objects that reside in the old generation."

	<category: 'accessing'>
	^numOldOOPs
    ]

    numFixedOOPs [
	"Answer the number of objects that the garbage collector
	 cannot move around in memory."

	<category: 'accessing'>
	^numFixedOOPs
    ]

    numWeakOOPs [
	"Answer the number of weak objects that the garbage collector
	 is currently tracking."

	<category: 'accessing'>
	^numWeakOOPs
    ]

    numOTEs [
	"Answer the number of entries that are currently allocated for the
	 object table."

	<category: 'accessing'>
	^numOTEs
    ]

    numFreeOTEs [
	"Answer the number of entries that are currently free in the
	 object table."

	<category: 'accessing'>
	^numFreeOTEs
    ]

    timeBetweenScavenges [
	"Answer the average number of milliseconds between two scavenges
	 (fast collections of the young generation)."

	<category: 'accessing'>
	^timeBetweenScavenges
    ]

    timeBetweenGlobalGCs [
	"Answer the average number of milliseconds between two global
	 garbage collections."

	<category: 'accessing'>
	^timeBetweenGlobalGCs
    ]

    timeBetweenGrowths [
	"Answer the average number of milliseconds between decisions to
	 grow the heap."

	<category: 'accessing'>
	^timeBetweenGrowths
    ]

    timeToScavenge [
	"Answer the average number of milliseconds that a scavenge takes
	 (fast collections of the young generation)."

	<category: 'accessing'>
	^timeToScavenge
    ]

    timeToCollect [
	"Answer the average number of milliseconds that a global
	 garbage collection takes."

	<category: 'accessing'>
	^timeToCollect
    ]

    timeToCompact [
	"Answer the average number of milliseconds that compacting the
	 heap takes.  This the same time that is taken by growing the
	 heap."

	<category: 'accessing'>
	^timeToCompact
    ]

    reclaimedBytesPerScavenge [
	"Answer the average number of bytes that are found to be garbage
	 during a scavenge."

	<category: 'accessing'>
	^reclaimedBytesPerScavenge
    ]

    tenuredBytesPerScavenge [
	"Answer the average number of bytes that are promoted to oldspace
	 during a scavenge."

	<category: 'accessing'>
	^tenuredBytesPerScavenge
    ]

    reclaimedBytesPerGlobalGC [
	"Answer the average number of bytes that are found to be garbage
	 during a global garbage collections."

	<category: 'accessing'>
	^reclaimedBytesPerGlobalGC
    ]

    reclaimedPercentPerScavenge [
	"Answer the average percentage of allocated bytes that are found
	 to be garbage during a scavenge.  If this number falls below 60-70
	 you should definitely increment the size of the eden, because you
	 risk that scavenging is eating a considerable fraction of your
	 execution time; do the measurement on a restarted
	 image, so that the extra tenuring incurred when creating long-lived
	 objects such as classes or methods is not considered."

	<category: 'accessing'>
	^reclaimedPercentPerScavenge
    ]

    allocFailures [
	"Answer the number of times that the old-space allocator found
	 no block that was at least as big as requested, and had to ask
	 the operating system for more memory."

	<category: 'accessing'>
	^allocFailures
    ]

    allocMatches [
	"Answer the number of times that the old-space allocator found
	 a block that was exactly as big as requested."

	<category: 'accessing'>
	^allocMatches
    ]

    allocSplits [
	"Answer the number of times that the old-space allocator could not
	 find a block that was exactly as big as requested, and had to split
	 a larger free block in two parts."

	<category: 'accessing'>
	^allocSplits
    ]

    allocProbes [
	"Answer the number of free blocks that the old-space allocator had
	 to examine so far to allocate all the objects that are in old-space"

	<category: 'accessing'>
	^allocProbes
    ]

    scavengesBeforeTenuring [
	"Answer the number of scavenges that an object must on average
	 survive before being promoted to oldspace; this is however only
	 an estimate because objects that are reachable from oldspace have
	 a higher probability to be tenured soon, while objects that are
	 only reachable from thisContext have a lower probability to be
	 tenured.  Anyway, if this number falls below 2-3 you should
	 definitely increment the size of eden and/or of survivor space,
	 because you are tenuring too often and relying too much on
	 global garbage collection to keep your heap clean; do the
	 measurement on a restarted image, so that the extra tenuring
	 incurred when creating long-lived objects such as classes or
	 methods is not considered."

	<category: 'derived information'>
	^self survSpaceSize / self tenuredBytesPerScavenge
    ]

    update [
	"Update the values in the object to the current state of the VM."

	<category: 'builtins'>
	<primitive: VMpr_ObjectMemory_update>
	self primitiveFailed
    ]
]



Eval [
    ObjectMemory initialize
]

