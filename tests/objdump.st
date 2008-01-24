"======================================================================
|
|   Test ObjectDumper operations
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2002, 2007 Free Software Foundation.
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

Eval [
	stream := ByteStream on: (ByteArray new: 1024).
	(ObjectDumper on: stream) dump: Array.
	stream reset.
	^(ObjectDumper on: stream) load == Array
]

Eval [
	stream := ByteStream on: (ByteArray new: 1024).
	(ObjectDumper on: stream) dump: #('asdf' 1 2 $a). 
	stream reset.
	^(ObjectDumper on: stream) load = #('asdf' 1 2 $a)
]

Eval [
	stream := ByteStream on: (ByteArray new: 1024).
	method := Object >> #yourself.
	(ObjectDumper on: stream) dump: method.
	stream reset.
	^(ObjectDumper on: stream) load == method
]

Eval [
	stream := ByteStream on: (ByteArray new: 1024).
	array := Array new: 1.
	array at: 1 put: array.
	(ObjectDumper on: stream) dump: array.
	stream reset.
	secondArray := (ObjectDumper on: stream) load.
	^secondArray == (secondArray at: 1)
]

Eval [
	stream := ByteStream on: (ByteArray new: 1024).
	(ObjectDumper on: stream) dump: Processor.
	stream reset.
	^(ObjectDumper on: stream) load == Processor
]

Eval [
	stream := ByteStream on: (ByteArray new: 1024).
	(ObjectDumper on: stream) dump: 'asdf'.
	stream reset.
	^(ObjectDumper on: stream) load = 'asdf'
]


