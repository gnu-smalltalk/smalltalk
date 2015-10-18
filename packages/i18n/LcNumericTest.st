"======================================================================
|
|   Localization and internationalization support
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2015 Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"



TestCase subclass: LcNumericTest [

    testComputeNumberOfGroupsEmpty [
        | numeric |
        numeric := LcNumeric language: 'POSIX'.
        numeric instVarNamed: #grouping put: #[].

        self assert: (numeric computeNumberOfGroups: 0) equals: 0.
        self assert: (numeric computeNumberOfGroups: 3) equals: 0.
        self assert: (numeric computeNumberOfGroups: 6) equals: 0.
        self assert: (numeric computeNumberOfGroups: 7) equals: 0.
    ]

    testComputeNumberOfGroupsThreeThree [
        | numeric |
        numeric := LcNumeric language: 'POSIX'.
        numeric instVarNamed: #grouping put: #[3 3].

        self assert: (numeric computeNumberOfGroups: 0) equals: 1.
        self assert: (numeric computeNumberOfGroups: 3) equals: 1.
        self assert: (numeric computeNumberOfGroups: 6) equals: 2.
        self assert: (numeric computeNumberOfGroups: 7) equals: 3.
        self assert: (numeric computeNumberOfGroups: 8) equals: 3.
        self assert: (numeric computeNumberOfGroups: 9) equals: 3.
        self assert: (numeric computeNumberOfGroups: 10) equals: 4.
        self assert: (numeric computeNumberOfGroups: 12) equals: 4.
        self assert: (numeric computeNumberOfGroups: 13) equals: 5.
    ]

    testComputeNumberOfGroupsThreeFixed [
        | numeric |
        numeric := LcNumeric language: 'POSIX'.
        numeric instVarNamed: #grouping put: #[3 255].

        self assert: (numeric computeNumberOfGroups: 0) equals: 1.
        self assert: (numeric computeNumberOfGroups: 3) equals: 1.
        self assert: (numeric computeNumberOfGroups: 6) equals: 1.
        self assert: (numeric computeNumberOfGroups: 7) equals: 1.
        self assert: (numeric computeNumberOfGroups: 9) equals: 1.
        self assert: (numeric computeNumberOfGroups: 10) equals: 1.
    ]

    testEnglishLocale [
        | numeric |
        numeric := I18N.LcNumeric language: 'en_US.UTF-8'.

        "Test with plain integers"
        self assert: (numeric ? 123) equals: '123'.
        self assert: (numeric ? 1234) equals: '1,234'.

        "Test with float and digits"
        self assert: (numeric ? 123.0) equals: '123.0'.
        self assert: (numeric ? 1234.0) equals: '1,234.0'.
        self assert: (numeric ? 12345.0) equals: '12,345.0'.
        self assert: (numeric ? 123456.0) equals: '123,456.0'.
        self assert: (numeric ? 1234567.0) equals: '1,234,567.0'.
        self assert: (numeric ? 12345678.0) equals: '12,345,678.0'.
        self assert: (numeric ? 123456789.0) equals: '123,456,789.0'.
        self assert: (numeric ? 1234567891.0) equals: '1,234,567,891.0'.
        self assert: (numeric ? 12345678912.0) equals: '12,345,678,912.0'.
        self assert: (numeric ? 123456789123.0) equals: '123,456,789,123.0'.
    ]

    testPosixLocale [
        | numeric |
        numeric := I18N.LcNumeric language: 'POSIX'.

        "Test with plain integers"
        self assert: (numeric ? 123) equals: '123'.
        self assert: (numeric ? 1234) equals: '1234'.

        "Test with float and digits"
        self assert: (numeric ? 123.0) equals: '123.0'.
        self assert: (numeric ? 1234.0) equals: '1234.0'.
        self assert: (numeric ? 12345.0) equals: '12345.0'.
        self assert: (numeric ? 123456.0) equals: '123456.0'.
        self assert: (numeric ? 1234567.0) equals: '1234567.0'.
        self assert: (numeric ? 12345678.0) equals: '12345678.0'.
        self assert: (numeric ? 123456789.0) equals: '123456789.0'.
        self assert: (numeric ? 1234567891.0) equals: '1234567891.0'.
        self assert: (numeric ? 12345678912.0) equals: '12345678912.0'.
        self assert: (numeric ? 123456789123.0) equals: '123456789123.0'.
    ]
]
