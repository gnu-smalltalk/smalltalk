"======================================================================
|
|   Message digest tests declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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

TestCase subclass: #MessageDigestTest
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!MessageDigestTest methodsFor: 'test vectors'!

nullDigest
    ^self hexToByteArray: self hexNullDigest!

hexNullDigest
    self subclassResponsibility!

abcDigest
    ^self hexToByteArray: self hexAbcDigest!

hexAbcDigest
    self subclassResponsibility!

abcdefDigest
    ^self hexToByteArray: self hexAbcdefDigest!

hexAbcdefDigest
    self subclassResponsibility!

size64
    ^(2 to: 37) inject: '' into: [ :a :b | a, b printString ]!

size64Digest
    ^self hexToByteArray: self hexSize64Digest!

hexSize64Digest
    self subclassResponsibility!

size128
    ^(2 to: 69) inject: '' into: [ :a :b | a, b printString ]!

size128Digest
    ^self hexToByteArray: self hexSize128Digest!

hexSize128Digest
    self subclassResponsibility!

hexToByteArray: hex
    | ba |
    ba := ByteArray new: hex size / 2.
    1 to: hex size by: 2 do: [ :i |
	ba
	    at: i // 2 + 1
	    put: (hex at: i) asUppercase digitValue * 16
		 + (hex at: i + 1) asUppercase digitValue ].
    ^ba!

allTestCases
    ^{ '' -> self nullDigest.
       'abc' -> self abcDigest.
       'abcdef' -> self abcdefDigest.
       self size64 -> self size64Digest.
       self size128 -> self size128Digest }!

allHexTestCases
    ^{ '' -> self hexNullDigest.
       'abc' -> self hexAbcDigest.
       'abcdef' -> self hexAbcdefDigest.
       self size64 -> self hexSize64Digest.
       self size128 -> self hexSize128Digest }!

!MessageDigestTest methodsFor: 'testing'!

testDigestOf
    self allTestCases do: [ :each |
        self assert: (self digestClass digestOf: each key) = each value ]!

testByteArray
    self allTestCases do: [ :each |
        self assert: (self digestClass digestOf: each key asByteArray) = each value ]!

testHexDigestOf
    self allHexTestCases do: [ :each |
        self assert: (self digestClass hexDigestOf: each key) = each value ]!

testNextPut
    self allTestCases do: [ :each |
        | md5 |
        md5 := self digestClass new.
        each key do: [ :ch | md5 nextPut: ch ].
        self assert: md5 digest = each value ]!

testNextPutAll
    self allTestCases do: [ :each |
        | md5 |
        md5 := self digestClass new.
        md5 nextPutAll: each key readStream.
        self assert: md5 digest = each value ]!

testPartial
    | md5 |
    md5 := self digestClass new.
    md5 nextPutAll: 'abc'.
    self assert: md5 partialDigest = self abcDigest.
    md5 nextPutAll: 'def'.
    self assert: md5 partialDigest = self abcdefDigest.
    self assert: md5 digest = self abcdefDigest!

testPartialHex
    | md5 |
    md5 := self digestClass new.
    md5 nextPutAll: 'abc'.
    self assert: md5 partialHexDigest = self hexAbcDigest.
    md5 nextPutAll: 'def'.
    self assert: md5 partialHexDigest = self hexAbcdefDigest.
    self assert: md5 hexDigest = self hexAbcdefDigest! !

MessageDigestTest subclass: #MD5Test
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!MD5Test methodsFor: 'test vectors'!

hexNullDigest
    ^'d41d8cd98f00b204e9800998ecf8427e'!

hexAbcDigest
    ^'900150983cd24fb0d6963f7d28e17f72'!

hexAbcdefDigest
    ^'e80b5017098950fc58aad83c8c14978e'!

hexSize64Digest
    ^'165b2b14eccde03de4742a2f9390e1a1'!

hexSize128Digest
    ^'59bda09a8b3e1d186237ed0fed34d87a'!

digestClass
    ^MD5! !

MessageDigestTest subclass: #SHA1Test
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!SHA1Test methodsFor: 'test vectors'!

hexNullDigest
    ^'da39a3ee5e6b4b0d3255bfef95601890afd80709'!

hexAbcDigest
    ^'a9993e364706816aba3e25717850c26c9cd0d89d'!

hexAbcdefDigest
    ^'1f8ac10f23c5b5bc1167bda84b833e5c057a77d2'!

hexSize64Digest
    ^'6a90ea3e17064652ed5406d3e10eb9ac2ee9a21e'!

hexSize128Digest
    ^'e02f6ccdd12ebf0958e18aea9fed8fbe818a223c'!

digestClass
    ^SHA1! !
