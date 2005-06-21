"======================================================================
|
|   Smalltalk TCP/IP sockets classes (loading script).
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


Smalltalk addSubspace: #TCP!
Namespace current: TCP!

| verbose |

verbose := FileStream verbose: true.

#('Buffers.st'				"Support classes"
  'Datagram.st'
  'SocketAddress.st'
  'AbstractSocketImpl.st'		"Low-level socket classes"
  'IPSocketImpl.st'
  'Sockets.st'				"High-level socket classes"
  'Tests.st'
  'cfuncs.st'				"Other initializations"
  'init.st')

do: [ :each | FileStream fileIn: each ].

FileStream verbose: verbose!
Namespace current: Smalltalk!
