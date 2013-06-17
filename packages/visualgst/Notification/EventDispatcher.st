"======================================================================
|
| EventDispatcher class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

SystemEventManager subclass: EventDispatcher [
    | events |

    removeActionsWithReceiver: anObject forEvent: anEvent [
	"Stop sending system notifications to an object"

	| dict |
	dict := events keys at: anEvent ifAbsent: [ ^ self ].
	dict removeKey: anObject ifAbsent: [ ^ self ].
    ]

    when: eachEvent send: oneArgumentSelector to: anObject [
	"Notifies an object of any events in the eventsCollection. Send it back a message 
	#oneArgumentSelector, with as argument the particular system event instance"

	| dict |
	dict := events at: eachEvent ifAbsentPut: [ WeakKeyIdentityDictionary new ].
	dict at: anObject put: oneArgumentSelector
    ]

    triggerEvent: anEventSelector with: anEvent [

	| dict |
	dict := events at: anEventSelector ifAbsent: [ ^ self ].
	dict associationsDo: [ :each |
	    each key perform: each value with: anEvent ]
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	events := Dictionary new
    ]
]

