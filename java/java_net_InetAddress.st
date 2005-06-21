"======================================================================
|
|   Java run-time support.  java.net.InetAddress native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.net.InetAddress'!

java_net_InetAddress_aton_java_lang_String: arg1
    <javaNativeMethod: #'aton(Ljava/lang/String;)[B'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
!

java_net_InetAddress_lookup_java_lang_String: arg1 java_net_InetAddress: arg2 boolean: arg3
    <javaNativeMethod: #'lookup(Ljava/lang/String;Ljava/net/InetAddress;Z)[Ljava/net/InetAddress;'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
!

java_net_InetAddress_getFamily_byteArray: arg1
    <javaNativeMethod: #'getFamily([B)I'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
!

java_net_InetAddress_getLocalHostname
    <javaNativeMethod: #'getLocalHostname()Ljava/lang/String;'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
! !

