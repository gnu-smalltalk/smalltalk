"======================================================================
|
|   Netlink module declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2014 Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther
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



Object subclass: Netlink [
    <category: 'Netlink'>
    <comment: 'I help speaking netlink with the kernel. Currently this
    only includes the routing sub-system but might be extended.'>

    Netlink class >> fromDestIPv4: destAddress toLocal: localAddress [
        <category: '*Netlink'>
        "Given a destination IPv4 Address this function will
        determine the local source address that would be used.
        The addresses need to be a ByteArray with four entries."
        <cCall: 'nl_route_source_ipv4' returning: #int args: #(#byteArray #cObject)>
    ]
]
