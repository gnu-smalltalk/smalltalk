"=====================================================================
|
|   ObjectMemory method definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2003 Free Software Foundation, Inc.
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
| 330, Boston, MA 02111-1307, USA.  
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

initialize
    "Initialize the globals"

    "This method is called after all the kernel Smalltalk classes have been
     loaded.  It generally performs any initializations that might depend on
     the full Smalltalk class hierarchy being defined. After this is file is
     loaded, some 'advanced' class definitions are loaded (CFuncs, Autoload,
     exception handling, ...) and then the binary image is saved."

    Object initialize.
    Fraction initialize.
    LargeInteger initialize.
    Date initialize.
    Time initialize.
    FileDescriptor initialize.
    Delay initialize.
    Namespace initialize.
    Processor initialize.
    Smalltalk addFeature: #Kernel.
    KernelInitialized := true.
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

ObjectMemory initialize!

