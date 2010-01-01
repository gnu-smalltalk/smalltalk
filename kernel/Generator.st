"======================================================================
|
|   Generator Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2003, 2007, 2009 Free Software Foundation, Inc.
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



Stream subclass: Generator [
    | next genCC consCC atEnd |
    
    <category: 'Streams-Generators'>
    <comment: 'A Generator object provides a way to use blocks to define a Stream
of many return values.  The return values are computed one at a time,
as needed, and hence need not even be finite.

A generator block is converted to a Generator with "Generator
on: [...]".  The Generator itself is passed to the block,
and as soon as a message like #next, #peek, #atEnd or #peekFor: is
sent to the generator, execution of the block starts/resumes and
goes on until the generator''s #yield: method is called: then the
argument of #yield: will be the Generator''s next element.  If the
block goes on to the end without calling #yield:, the Generator
will produce no more elements and #atEnd will return true.

You could achieve the effect of generators manually by writing your
own class and storing all the local variables of the generator as
instance variables.  For example, returning a list of integers could
be done by setting a variable to 0, and having the #next method
increment it and return it.  However, for a moderately complicated
generator, writing a corresponding class would be much messier (and
might lead to code duplication or inefficiency if you want to support
#peek, #peekFor: and/or #atEnd): in general, providing a #do:-like
interface is easy, but not providing a Stream-like one (think binary
trees).

The idea of generators comes from other programming languages, in
particular this interface looks much like Scheme streams and Python
generators.  But Python in turn mutuated the idea for example from
Icon, where the idea of generators is central.  In Icon, every
expression and function call behaves like a generator, and if a
statement manages scalars, it automatically uses up all the results
that the corresponding generator provides; on the other hand, Icon
does not represent generators as first-class objects like Python and
Smalltalk do.'>

    Generator class >> on: aBlock [
	"Return a generator and pass it to aBlock.  When #next is sent
	 to the generator, the block will start execution, and will be
	 suspended again as soon as #yield: is sent from the block to
	 the generator."

	<category: 'instance creation'>
	^(self new)
	    forkOn: aBlock;
	    yourself
    ]

    Generator class >> on: aCollection do: aBlock [
	"Return a generator; for each item of aCollection, evaluate aBlock
	 passing the generator and the item."

	<category: 'instance creation'>
	^self on: [:gen | aCollection do: [:each | aBlock value: gen value: each]]
    ]

    Generator class >> inject: aValue into: aBlock [
	"Return an infinite generator; the first item is aValue, the following
	 items are obtained by passing the previous value to aBlock."

	<category: 'instance creation'>
	^self on: 
		[:gen | 
		| last |
		last := aValue.
		
		[gen yield: last.
		last := aBlock value: last] repeat]
    ]

    atEnd [
	"Answer whether more data can be generated."

	<category: 'stream protocol'>
	atEnd isNil ifTrue: [genCC := genCC callCC].
	^atEnd
    ]

    next [
	"Evaluate the generator until it generates the next value or
	 decides that nothing else can be generated."

	<category: 'stream protocol'>
	| result |
	self atEnd ifTrue: [^self pastEnd].
	result := next.
	next := nil.
	atEnd := nil.
	^result
    ]

    peek [
	"Evaluate the generator until it generates the next value or
	 decides that nothing else can be generated, and save the value
	 so that #peek or #next will return it again."

	<category: 'stream protocol'>
	self atEnd ifTrue: [^nil].
	^next
    ]

    peekFor: anObject [
	"Evaluate the generator until it generates the next value or
	 decides that nothing else can be generated, and if it is not equal
	 to anObject, save the value so that #peek or #next will return it
	 again."

	<category: 'stream protocol'>
	self atEnd 
	    ifTrue: 
		[self pastEnd.
		^false].
	^next = anObject 
	    ifTrue: 
		[next := nil.
		atEnd := nil.
		true]
	    ifFalse: [false]
    ]

    yield: anObject [
	"When entering from the generator the code in the block is executed and
	 control flow goes back to the consumer.  When entering from the consumer,
	 the code after the continuation is executed, which resumes execution of
	 the generator block."

	<category: 'stream protocol'>
	atEnd := false.
	next := anObject.
	consCC := consCC callCC.

	"Make sure that an exception (or any other event that causes #yield: not
	 to be invoked again) terminates the generator.  Also, generators should
	 not reenter."
	genCC := nil.
	atEnd := true
    ]

    forkOn: aBlock [
	"When initializing, we just store the current continuation and exit;
	 the ^self is where the control flow is actually split.  When #next is
	 called first, the code after the continuation is executed, which
	 executes the generator block and finally resumes execution of the
	 consumer when the block leaves.
	 
	 This is the only time we create a continuation with a block; after
	 this, we just replace a continuation with another through
	 Continuation>>#callCC."

	<category: 'private - continuations'>
	consCC := Continuation currentDo: 
			[:cc | 
			genCC := cc.
			atEnd := nil.
			^self].
	atEnd := true.
	genCC := nil.
	aBlock value: self.
	consCC oneShotValue
    ]
]

