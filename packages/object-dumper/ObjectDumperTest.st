"======================================================================
|
|   Test ObjectDumper operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2002, 2007, 2008, 2009 Free Software Foundation.
| Written by Paolo Bonzini and Markus Fritsche
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

TestCase subclass: AbstractObjectDumperTest [
	<category: 'tests'>

        AbstractObjectDumperTest class >> isAbstract [
		<category: 'testing'>
                ^self == AbstractObjectDumperTest
        ]

        reloadedObjectsFor: anArray [
		<category: 'testing'>
                self subclassResponsibility
        ]

        reloadedObjectFor: anObject [
		<category: 'testing'>
		^(self reloadedObjectsFor: {anObject}) first
        ]

        array [
		<category: 'test vectors'>
		^#('asdf' 1 2 $a)
        ]

	testClass [
		<category: 'test cases'>
		| object |
		object := self reloadedObjectFor: Array.
		self assert: object == Array.
	]

	testSmallInteger [
		<category: 'test cases'>
		| object |
		object := self reloadedObjectFor: 1.
		self assert: object = 1.
	]

	testString [
		<category: 'test cases'>
		| object |
		object := self reloadedObjectFor: 'asdf'.
		self assert: object = 'asdf'.
	]

	testArray [
		<category: 'test cases'>
		| object |
		object := self reloadedObjectFor: self array. 
		self assert: object = self array.
	]

	testReference [
		<category: 'test cases'>
		| objects |
		objects := self reloadedObjectsFor: {self array first. self array}. 
		self assert: objects first == objects second first.
	]

	testClassReference [
		<category: 'test cases'>
		| objects |
		objects := self reloadedObjectsFor: {self array class. self array}. 
		self assert: objects first = objects second class.
	]

	testMethod [
		<category: 'test cases'>
		| object method |
		method := Object >> #yourself.
		object := self reloadedObjectFor: method.
		self assert: object == method.
	]

	testRecursive [
		<category: 'test cases'>
		| object array |
		array := Array new: 1.
		array at: 1 put: array.
		object := self reloadedObjectFor: array.
		self assert: object == (object at: 1).
	]

	testRepeated [
		<category: 'test cases'>
		| objects |
		objects := self reloadedObjectsFor: {self array first. self array first}. 
		self assert: objects first == objects second.
	]

	testSingleton [
		<category: 'test cases'>
                | object |
		object := self reloadedObjectFor: Processor.
		self assert: object == Processor.
	]
]

AbstractObjectDumperTest subclass: ObjectDumperRWStreamTest [
        
        reloadedObjectsFor: anArray [
		<category: 'testing'>
                | stream dumper |
		stream := (String new: 1024) readWriteStream.
		dumper := ObjectDumper on: stream.
		anArray do: [ :each | dumper dump: each ].
		stream reset.
		dumper := ObjectDumper on: stream.
		^anArray collect: [ :each | dumper load ]
	]
]

AbstractObjectDumperTest subclass: ObjectDumperReadStreamTest [
        
        reloadedObjectsFor: anArray [
		<category: 'testing'>
                | stream dumper |
		stream := (String new: 1024) writeStream.
		dumper := ObjectDumper on: stream.
		anArray do: [ :each | dumper dump: each ].
		dumper := ObjectDumper on: stream readStream.
		^anArray collect: [ :each | dumper load ]
	]

        testEmpty [
		<category: 'test cases'>
                | stream x y |
		stream := String new readStream.
		y := [ (ObjectDumper on: stream) load ]
	    			on: SystemExceptions.EndOfStream
	    			do: [ :ex | x := true. ex resume: ex defaultAction ].
		self assert: y isNil.
		self assert: x
        ]
]

AbstractObjectDumperTest subclass: ObjectDumperReadStreamWithCopyTest [
        
        reloadedObjectsFor: anArray [
		<category: 'testing'>
                | stream dumper |
		stream := (String new: 1024) writeStream.
		dumper := ObjectDumper on: stream.
		anArray do: [ :each | dumper dump: each ].
		dumper := ObjectDumper on: stream contents readStream.
		^anArray collect: [ :each | dumper load ]
	]
]
