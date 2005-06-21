"======================================================================
|
|   Smalltalk TCP/IP sockets - Datagram class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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


Object subclass: #Datagram
	  instanceVariableNames: 'data address port'
	  classVariableNames: ''
	  poolDictionaries: ''
	  category: 'Sockets-Protocols'
!


!Datagram class methodsFor: 'instance creation'!

data: aByteArray
    "Answer a new datagram with the specified data."
    ^self new
	data: aByteArray;
	yourself
!

data: aByteArray address: ipAddress port: port
    "Answer a new datagram with the specified target socket, and
     aByteArray as its data."
    ^self new
	data: aByteArray;
	address: ipAddress;
	port: port;
	yourself
!

object: object objectDumper: od address: ipAddress port: port
    "Serialize the object onto a ByteArray, and create a Datagram with
     the object as its contents, and the specified receiver.  Serialization
     takes place through ObjectDumper passed as `od', and the stream
     attached to the ObjectDumper is resetted every time.  Using this
     method is indicated if different objects that you're sending are
     likely to contain references to the same objects."
    od stream reset.
    od dump: object.
    ^self
	data: od stream contents
	address: ipAddress
	port: port
!

object: object address: ipAddress port: port
    "Serialize the object onto a ByteArray, and create a Datagram
     with the object as its contents, and the specified receiver.
     Note that each invocation of this method creates a separate
     ObjectDumper; if different objects that you're sending are likely
     to contain references to the same objects, you should use
     #object:objectDumper:address:port:."
    | stream |
    stream := ByteStream on: (ByteArray new: 100).
    ObjectDumper dump: object to: stream.
    ^self
	data: stream contents
	address: ipAddress
	port: port
! !

!Datagram methodsFor: 'accessing'!

address
    "Answer the address of the target socket"
    ^address
!

address: ipAddress
    "Set the address of the target socket"
    address := ipAddress
!

data
    "Answer the data attached to the datagram"
    ^data
!

data: aByteArray
    "Set the data attached to the datagram"
    data := aByteArray
!

get
    "Parse the data attached to the datagram through a newly created
     ObjectDumper, and answer the resulting object.  This method is
     complementary to #object:address:port:."
    ^ObjectDumper loadFrom: (ByteStream on: self data)
!

getThrough: objectDumper
    "Parse the data attached to the datagram through the given
     ObjectDumper without touching the stream to which it is
     attached, and answer the resulting object.  The state of
     the ObjectDumper, though, is updated.  This method is
     complementary to #object:objectDumper:address:port:."
    | result saveStream |
    saveStream := objectDumper stream.
    objectDumper stream: (ByteStream on: self data).
    result := objectDumper load.
    objectDumper stream: saveStream.
    ^result
!

port
    "Answer the IP port of the target socket"
    ^port
!

port: thePort
    "Set the IP port of the target socket"
    port := thePort
! !
