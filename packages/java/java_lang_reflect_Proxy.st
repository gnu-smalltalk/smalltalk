"======================================================================
|
|   Java run-time support.  java.lang.reflect.Proxy native methods.
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

!JavaVM methodsFor: 'java.lang.reflect.Proxy'!

java_lang_reflect_Proxy_getProxyClass0_java_lang_ClassLoader: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'getProxyClass0(Ljava/lang/ClassLoader;[Ljava/lang/Class;)Ljava/lang/Class;'
        for: #{Java.java.lang.reflect.Proxy} static: true>
    ^nil
!

java_lang_reflect_Proxy_getProxyData0_java_lang_ClassLoader: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'getProxyData0(Ljava/lang/ClassLoader;[Ljava/lang/Class;)Ljava/lang/reflect/Proxy$ProxyData;'
        for: #{Java.java.lang.reflect.Proxy} static: true>
    ^nil
!

java_lang_reflect_Proxy_generateProxyClass0_java_lang_ClassLoader: arg1 java_lang_reflect_Proxy$ProxyData: arg2
    <javaNativeMethod: #'generateProxyClass0(Ljava/lang/ClassLoader;Ljava/lang/reflect/Proxy$ProxyData;)Ljava/lang/Class;'
        for: #{Java.java.lang.reflect.Proxy} static: true>
    ^nil
! !
