"======================================================================
|
|   SUnit Test Cases for the Socket Code
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2011 Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther.
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

TestCase subclass: SocketTest [
    testDoNotCrashOnSendto [
        "
         The objective of this test is to check if the c code is
         crashing with 'invalid' input.
        "
        | socket addrLen datagram |
        socket := DatagramSocket new.

	"Passing the wrong bits to the call out will abort."
	addrLen := CInt gcValue: 0.
        socket implementation
            accept: -1 peer: nil addrLen: addrLen;
            bind: -1 to: nil addrLen: 0;
            connect: -1 to: nil addrLen: 0;
            getPeerName: -1 addr: nil addrLen: addrLen;
            getSockName: -1 addr: nil addrLen: addrLen;
            receive: -1 buffer: nil size: 0 flags: 0 from: nil size: addrLen.

	"Pass a datagram with no destination."
	datagram := Datagram new.
	socket nextPut: datagram.
    ]

    testDoNotCrashWithWrongTypes [
        "The objective is to see if wrong types for a cCallout will
         make the VM crash or not. It should also check if these calls
         raise the appropriate exception."
        | socket impl |

        socket := DatagramSocket new.
        impl := socket implementation.

        self should: [impl accept: -1 peer: nil addrLen: 0] raise: SystemExceptions.PrimitiveFailed.
        self should: [impl getPeerName: -1 addr: nil addrLen: 0] raise: SystemExceptions.PrimitiveFailed.
        self should: [impl getSockName: -1 addr: nil addrLen: 0] raise: SystemExceptions.PrimitiveFailed.
        self should: [impl receive: -1 buffer: nil size: 0 flags: 0 from: nil size: 0] raise: SystemExceptions.PrimitiveFailed.
    ]
]
