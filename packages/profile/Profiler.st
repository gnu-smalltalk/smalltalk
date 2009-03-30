"======================================================================
|
|   Basic Profiler tools
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 2006, 2007 Free Software Foundation, Inc.
| Written by Derek Zhou and Paolo Bonzini.
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


Object subclass: Profiler [
    Stack := nil.

    | rawProfile name |

    Profiler class >> profile: aBlock [
	^self new
	    withProfilerDo: aBlock;
	    yourself
    ]

    name [
	^name ifNil: [ 'gst ', (Smalltalk arguments join: ' ') ]
    ]

    name: aString [
	name := aString
    ]

    push [
	Stack isNil ifTrue: [ Stack := OrderedCollection new ].
	Stack addLast: (Smalltalk rawProfile: self rawProfile)
    ]

    pop [
	Smalltalk rawProfile: Stack removeLast
    ]

    rawProfile [
	rawProfile isNil ifTrue: [ rawProfile := IdentityDictionary new ].
	^rawProfile
    ]

    withProfilerDo: aBlock [
	^[ self push. aBlock value ] ensure: [ self pop ]
    ]
]


Warning subclass: NoProfile [
    | method |

    NoProfile class >> for: aMethod [
	^self new method: aMethod; yourself
    ]

    method: aMethod [
	method := aMethod
    ]

    description [
	^'No profile found'
    ]

    messageText [
	^'%1 for %2' % {self description. method}
    ]
]

Object subclass: MethodProfile [
    | selfCost totalCost totalCalls calleeCounts profiler |

    <category: 'Profiling'>
    <comment: 'I store some statistics about a method, including cost and 
call graph'>

    MethodProfile class >> newIn: profiler [
        ^self new initWith: profiler
    ]

    initWith: p [
	<category: 'instance creation'>
        selfCost := 0.
        profiler := p.
	calleeCounts := IdentityDictionary new.
	totalCalls := 0.
    ]

    merge: p select: aBlock [
        "merge with raw profile p, which is an IdentityDictionary"
        p keysAndValuesDo: [ :k :v || profileKey |
	    k == true
		ifTrue: [ selfCost := selfCost + v ]
		ifFalse: [
		    (aBlock value: k) ifTrue: [ self add: v callsTo: k]]].
	totalCost := nil.
    ]

    printOn: aStream [
        aStream nextPutAll: '0 %1' % {selfCost}; nl.
        calleeCounts keysAndValuesDo: [ :callee :n |
            aStream 
                nextPutAll: 'cfi=%1' % {callee methodSourceFile}; nl;
                nextPutAll: 'cfn=%1' % {callee uniquePrintString}; nl;
                nextPutAll: 'calls=%1' % {n}; nl;
                nextPutAll: '* %1' % {self costOf: callee}; nl ].
    ]

    add: n callsTo: callee [
	| calleeProfile |
	calleeProfile := profiler profileAt: callee.
	calleeProfile totalCalls: calleeProfile totalCalls + n.
	calleeCounts
	    at: callee
	    put: n + (calleeCounts at: callee ifAbsent: [0]).
    ]

    selfCost [
        ^selfCost
    ]

    totalCalls [
	^totalCalls
    ]

    totalCalls: n [
	totalCalls := n
    ]

    totalCost [
        totalCost notNil ifTrue: [ ^totalCost ].

	"Return 0 while computing totalCost, to handle loops properly."
	totalCost := 0.

	"TODO: handle loops better."
        totalCost := calleeCounts keys inject: selfCost into: [ :old :callee |
	    old + (self costOf: callee) ].
	^totalCost
    ]

    costOf: callee [
        | calleeProfile |
	calleeProfile := profiler profileAt: callee.
        calleeProfile totalCalls = 0
	    ifTrue: [(NoProfile for: callee) signal. ^0].

        ^(calleeProfile totalCost * (calleeCounts at: callee)
	    + calleeProfile totalCalls - 1)
		// calleeProfile totalCalls
    ]
]


CompiledMethod extend [
    uniquePrintString [
	^self printString
    ]
]

CompiledBlock extend [
    uniquePrintString [
	^'%1 at line %2' % { self. self sourceCodeMap first }
    ]
]

Profiler subclass: CallGraphProfiler [
    | methodProfiles |

    <category: 'Profiler'>
    <comment: 'I store a call tree and associated profiling info'>

    mergeRawProfile [
        self rawProfile keysAndValuesDo: [ :k :v |
	    | method |
	    method := self accountingMethodFor: k.
	    (self profileAt: method)
		merge: v
		select: [ :callee | self isMethodAccounted: callee ]
	].
	rawProfile := nil
    ]

    accountingMethodFor: aMethod [
	^aMethod
    ]

    isMethodAccounted: aMethod [
	^true
    ]

    profileAt: aMethod [
	^methodProfiles
	    at: aMethod
	    ifAbsentPut: [MethodProfile newIn: self]
    ]

    push [
        methodProfiles isNil ifTrue: [
	    methodProfiles := IdentityDictionary new: 256 ].
	super push
    ]

    pop [
	super pop.
	self mergeRawProfile.
    ]

    totalCost [
        ^methodProfiles inject: 0 into: [ :sum :each | sum + each selfCost ]
    ]

    methodCount [
        ^methodProfiles size
    ]

    printOn: aStream [
	"print a callgrind compatible profile report on aStream"
	self printSummaryOn: aStream.
	self printCallGraphOn: aStream.
    ]

    printCallGraphOn: aStream [
	methodProfiles keysAndValuesDo: [ :method :profile |
	    aStream
	        nextPutAll: 'fl=%1' % {method methodSourceFile}; nl;
	        nextPutAll: 'fn=%1' % {method uniquePrintString}; nl.
	    profile printOn: aStream.
	    aStream nl ]
    ]

    printCallGraphToFile: aFile [
	"print a callgrind compatible profile report to a file named aFile"
	| fs |
	fs := aFile asFile writeStream.
	[
	    self
		printHeaderOn: fs;
		printSummaryOn: fs.
	    fs nl.
	    self printCallGraphOn: fs
	] ensure: [ fs close ]
    ]

    printSummaryOn: aStream [
        aStream nextPutAll: 'summary: %1' % {self totalCost}; nl.
    ]
	
    printHeaderOn: aStream [
	aStream 
	    nextPutAll: 'version: 1'; nl;
	    nextPutAll: 'creator: gst-profile'; nl;
	    nextPutAll: 'positions: instr'; nl;
	    nextPutAll: 'cmd: %1' % {self name}; nl;
	    nextPutAll: 'events: Ir'; nl
    ]
]

CallGraphProfiler subclass: MethodCallGraphProfiler [
    accountingMethodFor: aMethod [
	^aMethod method
    ]

    isMethodAccounted: aMethod [
	"Discard blocks, they are accounted for in the parent."
	^aMethod method == aMethod
    ]
]
