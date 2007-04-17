"=====================================================================
|
|   ObjectMemory method definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2003, 2005, 2006 Free Software Foundation, Inc.
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

Object subclass: #ObjectMemory
       instanceVariableNames: 'bytesPerOOP bytesPerOTE
	edenSize survSpaceSize oldSpaceSize fixedSpaceSize
	edenUsedBytes survSpaceUsedBytes oldSpaceUsedBytes
	fixedSpaceUsedBytes rememberedTableEntries
	numScavenges numGlobalGCs numCompactions numGrowths
	numOldOOPs numFixedOOPs numWeakOOPs numOTEs numFreeOTEs
	timeBetweenScavenges timeBetweenGlobalGCs timeBetweenGrowths
  	timeToScavenge timeToCollect timeToCompact
  	reclaimedBytesPerScavenge tenuredBytesPerScavenge
	reclaimedBytesPerGlobalGC reclaimedPercentPerScavenge
	allocFailures allocMatches allocSplits allocProbes'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

ObjectMemory comment: 'I provide a few methods that enable one to tune the
virtual machine''s usage of memory.  In addition, I can signal to my
dependants some `events'' that can happen during the virtual machine''s
life.

ObjectMemory has both class-side and instance-side methods.  In general,
class-side methods provide means to tune the parameters of the memory
manager, while instance-side methods are used together with the #current
class-side method to take a look at statistics on the memory manager''s
state.'!


!ObjectMemory class methodsFor: 'saving the image'!

snapshot
    "Save a snapshot on the image file that was loaded on startup."
    self snapshot: File image
! !


!ObjectMemory class methodsFor: 'initialization'!

changed: aSymbol
    aSymbol == #aboutToQuit
	ifTrue: [
	    "Wait until all processes are done"
	    Processor activeProcess priority: Processor rockBottomPriority.
	    [ super changed: aSymbol ]
		forkAt: Processor userSchedulingPriority ]
	ifFalse: [
	    super changed: aSymbol ]!

initialize
    "Initialize the globals"

    "This method is called after all the kernel Smalltalk classes have been
     loaded.  It generally performs any initializations that might depend on
     the full Smalltalk class hierarchy being defined. After this is file is
     loaded, some 'advanced' class definitions are loaded (CFuncs, Autoload,
     exception handling, ...) and then the binary image is saved."

    Object initialize.
    Class initialize.
    Fraction initialize.
    LargeInteger initialize.
    Date initialize.
    Time initialize.
    FileDescriptor initialize.
    Delay initialize.
    Namespace initialize.
    Processor initialize.
    SystemDictionary initialize.
    self changed: #returnFromSnapshot
! !

!ObjectMemory class methodsFor: 'accessing'!

current
    "Return a snapshot of the VM's memory management statistics."
    ^self new update
! !

!ObjectMemory methodsFor: 'accessing'!

bytesPerOOP
    "Answer the number of bytes that is taken by an ordinary
     object pointer (in practice, a field such as a named instance
     variable)."
    ^bytesPerOOP!

bytesPerOTE
    "Answer the number of bytes that is taken by an object
     table entry (in practice, the overhead incurred by every
     object in the system, with the sole exception of SmallIntegers)."
    ^bytesPerOTE!

edenSize
    "Answer the number of bytes in the `eden' area of the young
     generation (in practice, the number of allocated bytes between
     two scavenges)."
    ^edenSize!

survSpaceSize
    "Answer the number of bytes in the `survivor' area of the young
     generation (the area to which young objects are relocated during
     scavenges)."
    ^survSpaceSize!

fixedSpaceSize
    "Answer the number of bytes in the special heap devoted to
     objects that the garbage collector cannot move around in memory."
    ^fixedSpaceSize!

oldSpaceSize
    "Answer the number of bytes in the old generation."
    ^oldSpaceSize!

edenUsedBytes
    "Answer the number of bytes that are currently filled in the
     `eden' area of the young generation."
    ^edenUsedBytes!

survSpaceUsedBytes
    "Answer the number of bytes that are currently filled in the
     `survivor' area of the young generation."
    ^survSpaceUsedBytes!

oldSpaceUsedBytes
    "Answer the number of bytes that are currently filled in the
     old generation."
    ^oldSpaceUsedBytes!

fixedSpaceUsedBytes
    "Answer the number of bytes that are currently filled in the
     special heap devoted to objects that the garbage collector
     cannot move around in memory."
    ^oldSpaceUsedBytes!

numScavenges
    "Answer the number of scavenges (fast collections of the young
     generation) that happened since the VM was started."
    ^numScavenges!

numGlobalGCs
    "Answer the number of global garbage collections (collection
     of the entire heap) that happened since the VM was started."
    ^numGlobalGCs!

numCompactions
    "Answer the number of oldspace compactions that happened since
     the VM was started."
    ^numCompactions!

numGrowths
    "Answer the number of times that oldspace was grown since
     the VM was started."
    ^numGrowths!

numOldOOPs
    "Answer the number of objects that reside in the old generation."
    ^numOldOOPs!

numFixedOOPs
    "Answer the number of objects that the garbage collector
     cannot move around in memory."
    ^numFixedOOPs!

numWeakOOPs
    "Answer the number of weak objects that the garbage collector
     is currently tracking."
    ^numWeakOOPs!

numOTEs
    "Answer the number of entries that are currently allocated for the
     object table."
    ^numOTEs!

numFreeOTEs
    "Answer the number of entries that are currently free in the
     object table."
    ^numFreeOTEs!

timeBetweenScavenges
    "Answer the average number of milliseconds between two scavenges
     (fast collections of the young generation)."
    ^timeBetweenScavenges!

timeBetweenGlobalGCs
    "Answer the average number of milliseconds between two global
     garbage collections."
    ^timeBetweenGlobalGCs!

timeBetweenGrowths
    "Answer the average number of milliseconds between decisions to
     grow the heap."
    ^timeBetweenGrowths!

timeToScavenge
    "Answer the average number of milliseconds that a scavenge takes
     (fast collections of the young generation)."
    ^timeToScavenge!

timeToCollect
    "Answer the average number of milliseconds that a global
     garbage collection takes."
    ^timeToCollect!

timeToCompact
    "Answer the average number of milliseconds that compacting the
     heap takes.  This the same time that is taken by growing the
     heap."
    ^timeToCompact!

reclaimedBytesPerScavenge
    "Answer the average number of bytes that are found to be garbage
     during a scavenge."
    ^reclaimedBytesPerScavenge!

tenuredBytesPerScavenge
    "Answer the average number of bytes that are promoted to oldspace
     during a scavenge."
    ^tenuredBytesPerScavenge!

reclaimedBytesPerGlobalGC
    "Answer the average number of bytes that are found to be garbage
     during a global garbage collections."
    ^reclaimedBytesPerGlobalGC!

reclaimedPercentPerScavenge
    "Answer the average percentage of allocated bytes that are found
     to be garbage during a scavenge.  If this number falls below 60-70
     you should definitely increment the size of the eden, because you
     risk that scavenging is eating a considerable fraction of your
     execution time; do the measurement on a restarted
     image, so that the extra tenuring incurred when creating long-lived
     objects such as classes or methods is not considered."
    ^reclaimedPercentPerScavenge!

allocFailures
    "Answer the number of times that the old-space allocator found
     no block that was at least as big as requested, and had to ask
     the operating system for more memory."
    ^allocFailures!

allocMatches
    "Answer the number of times that the old-space allocator found
     a block that was exactly as big as requested."
    ^allocMatches!

allocSplits
    "Answer the number of times that the old-space allocator could not
     find a block that was exactly as big as requested, and had to split
     a larger free block in two parts."
    ^allocSplits!

allocProbes
    "Answer the number of free blocks that the old-space allocator had
     to examine so far to allocate all the objects that are in old-space"
    ^allocProbes!


!ObjectMemory methodsFor: 'derived information'!

scavengesBeforeTenuring
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
    ^self survSpaceSize / self tenuredBytesPerScavenge! !

!ObjectMemory class methodsFor: 'builtins'!

addressOfOOP: anObject
    "Returns the address of the OOP (object table slot) for anObject.
     The address is an Integer and will not change over time (i.e. is
     immune from garbage collector action) except if the virtual machine
     is stopped and restarted."

    <primitive: VMpr_Memory_addressOfOOP>
    SystemExceptions InvalidArgument
	signalOn: anObject
	reason: 'Cannot extract address of an immediate OOP'
!

addressOf: anObject
    "Returns the address of the actual object that anObject
     references.  Note that, with the exception of fixed objects
     this address is only valid until the next garbage collection;
     thus it's pretty risky to count on the address returned by
     this method for very long."
    <primitive: VMpr_Memory_addressOf>
    SystemExceptions InvalidArgument
	signalOn: anObject
	reason: 'Cannot extract address of an immediate OOP'
!

scavenge
    "Force a minor garbage collection"
    <primitive: VMpr_ObjectMemory_scavenge>
    ^self primitiveFailed
!

globalGarbageCollect
    "Force a full garbage collection"
    <primitive: VMpr_ObjectMemory_globalGarbageCollect>
    ^self primitiveFailed
!

compact
    "Force a full garbage collection, including compaction of oldspace"
    <primitive: VMpr_ObjectMemory_compact>
    ^self primitiveFailed
!

incrementalGCStep
    "Do a step in the incremental garbage collection."
    <primitive: VMpr_ObjectMemory_incrementalGCStep>
    ^self primitiveFailed
!

finishIncrementalGC
    "Do a step in the incremental garbage collection."
    <primitive: VMpr_ObjectMemory_finishIncrementalGC>
    ^self primitiveFailed
!

abort
    "Quit the Smalltalk environment, dumping core."
    <primitive: VMpr_ObjectMemory_abort>
!

quit
    "Quit the Smalltalk environment. Whether files are closed and
     other similar cleanup occurs depends on the platform"
    self quit: 0
!

quit: exitStatus
    "Quit the Smalltalk environment, passing the exitStatus integer
     to the OS. Files are closed and other similar cleanups occur."
    <primitive: VMpr_ObjectMemory_quit>
    SystemExceptions.WrongClass signalOn: exitStatus mustBe: SmallInteger
!

smoothingFactor
    "Answer the factor (between 0 and 1) used to smooth the statistics
     provided by the virtual machine about memory handling.  0 disables
     updating the averages, 1 disables the smoothing (the statistics
     return the last value)."
    <primitive: VMpr_ObjectMemory_getSmoothingFactor>
    ^self primitiveFailed
!

smoothingFactor: rate
    "Set the factor (between 0 and 1) used to smooth the statistics
     provided by the virtual machine about memory handling.  0 disables
     updating the averages, 1 disables the smoothing (the statistics
     return the last value)."
    <primitive: VMpr_ObjectMemory_setSmoothingFactor>
    rate class == FloatD
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: rate mustBeBetween: 0 and: 1 ]
	ifFalse: [ ^self spaceGrowRate: rate asFloatD ]
!

spaceGrowRate
    "Answer the rate with which the amount of memory used by the system grows"
    <primitive: VMpr_ObjectMemory_getSpaceGrowRate>
    ^self primitiveFailed
!

spaceGrowRate: rate
    "Set the rate with which the amount of memory used by the system grows"
    <primitive: VMpr_ObjectMemory_setSpaceGrowRate>
    rate class == FloatD
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: rate mustBeBetween: 0.01 and: 500.0 ]
	ifFalse: [ ^self spaceGrowRate: rate asFloatD ]
!

bigObjectThreshold
   "Answer the smallest size for objects that are allocated outside
    the main heap in the hope of providing more locality of reference
    between small objects."
    <primitive: VMpr_ObjectMemory_getBigObjectThreshold>
    ^self primitiveFailed
!

bigObjectThreshold: bytes
   "Set the smallest size for objects that are allocated outside
    the main heap in the hope of providing more locality of reference
    between small objects.  bytes must be a positive SmallInteger."

    <primitive: VMpr_ObjectMemory_setBigObjectThreshold>
    bytes isSmallInteger
	ifTrue: [ SystemExceptions.ArgumentOutOfRange
	    signalOn: bytes mustBeBetween: 0 and: SmallInteger largest ]
	ifFalse: [ SystemExceptions.WrongClass
	    signalOn: bytes mustBe: SmallInteger ]
!

growThresholdPercent
    "Answer the percentage of the amount of memory used by the system grows
     which has to be full for the system to allocate more memory"
    <primitive: VMpr_ObjectMemory_getGrowThresholdPercent>
    ^self primitiveFailed
!

growThresholdPercent: growPercent
    "Set the percentage of the amount of memory used by the system grows
     which has to be full for the system to allocate more memory"
    <primitive: VMpr_ObjectMemory_setGrowThresholdPercent>

    growPercent class == FloatD
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: growPercent mustBeBetween: 0.01 and: 100.0 ]
	ifFalse: [ ^self growThresholdPercent: growPercent asFloatD ]
!


growTo: numBytes
    "Grow the amount of memory used by the system grows to numBytes."
    <primitive: VMpr_ObjectMemory_growTo>
    ^self primitiveFailed
!

snapshot: aString
    "Save an image on the aString file"
    <primitive: VMpr_ObjectMemory_snapshot>
    ^aString isString
	ifFalse: [ SystemExceptions.WrongClass signalOn: aString mustBe: String ]
	ifTrue: [ File checkError ]
!

gcMessage
    "Answer whether messages indicating that garbage collection is taking
     place are printed on stdout"
    ^Smalltalk getTraceFlag: 3
!

gcMessage: aBoolean 
    "Set whether messages indicating that garbage collection is taking
     place are printed on stdout"
    ^Smalltalk setTraceFlag: 3 to: aBoolean
! !


!ObjectMemory methodsFor: 'builtins'!

update
    "Update the values in the object to the current state of the VM."
    <primitive: VMpr_ObjectMemory_update>
    self primitiveFailed
! !


ObjectMemory initialize!

