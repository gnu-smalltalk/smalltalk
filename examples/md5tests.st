"======================================================================
|
|   MD5 tests declarations
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

TestCase subclass: #MD5Test
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Modules'!

!MD5Test methodsFor: 'test vectors'!

nullDigest
    ^#[16rD4 16r1D 16r8C 16rD9 16r8F 16r00 16rB2 16r04
       16rE9 16r80 16r09 16r98 16rEC 16rF8 16r42 16r7E]!

hexNullDigest
    ^'d41d8cd98f00b204e9800998ecf8427e'!

abcDigest
    ^#[16r90 16r01 16r50 16r98 16r3C 16rD2 16r4F 16rB0
       16rD6 16r96 16r3F 16r7D 16r28 16rE1 16r7F 16r72]!

hexAbcDigest
    ^'900150983cd24fb0d6963f7d28e17f72'!

abcdefDigest
    ^#[16rE8 16r0B 16r50 16r17 16r09 16r89 16r50 16rFC
       16r58 16rAA 16rD8 16r3C 16r8C 16r14 16r97 16r8E]!

hexAbcdefDigest
    ^'e80b5017098950fc58aad83c8c14978e'!

size64
    ^(2 to: 37) inject: '' into: [ :a :b | a, b printString ]!

size64Digest
    ^#[16r16 16r5B 16r2B 16r14 16rEC 16rCD 16rE0 16r3D
       16rE4 16r74 16r2A 16r2F 16r93 16r90 16rE1 16rA1]!

hexSize64Digest
    ^'165b2b14eccde03de4742a2f9390e1a1'!

size128
    ^(2 to: 69) inject: '' into: [ :a :b | a, b printString ]!

size128Digest
    ^#[16r59 16rBD 16rA0 16r9A 16r8B 16r3E 16r1D 16r18
       16r62 16r37 16rED 16r0F 16rED 16r34 16rD8 16r7A]!

hexSize128Digest
    ^'59bda09a8b3e1d186237ed0fed34d87a'!

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

!MD5Test methodsFor: 'testing'!

testDigestOf
    self allTestCases do: [ :each |
        self assert: (MD5 digestOf: each key) = each value ]!

testHexDigestOf
    self allHexTestCases do: [ :each |
        self assert: (MD5 hexDigestOf: each key) = each value ]!

testNextPut
    self allTestCases do: [ :each |
        | md5 |
        md5 := MD5 new.
        each key do: [ :ch | md5 nextPut: ch ].
        self assert: md5 digest = each value ]!

testNextPutAll
    self allTestCases do: [ :each |
        | md5 |
        md5 := MD5 new.
        md5 nextPutAll: each key readStream.
        self assert: md5 digest = each value ]!

testPartial
    | md5 |
    md5 := MD5 new.
    md5 nextPutAll: 'abc'.
    self assert: md5 partialDigest = self abcDigest.
    md5 nextPutAll: 'def'.
    self assert: md5 partialDigest = self abcdefDigest.
    self assert: md5 digest = self abcdefDigest!

testPartialHex
    | md5 |
    md5 := MD5 new.
    md5 nextPutAll: 'abc'.
    self assert: md5 partialHexDigest = self hexAbcDigest.
    md5 nextPutAll: 'def'.
    self assert: md5 partialHexDigest = self hexAbcdefDigest.
    self assert: md5 hexDigest = self hexAbcdefDigest! !
