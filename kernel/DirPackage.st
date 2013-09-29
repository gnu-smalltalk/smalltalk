"======================================================================
|
|   Load packages from a directory without loading a Star file.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2013
| Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"

Namespace current: Kernel [

ExternalPackage subclass: DirPackage [
    <category: 'Language-Packaging'>
    <comment: 'I can parse a package.xml from a directory and treat it
    like a package. This allows loading packages from a directory without
    the need of zipping them first.'>

    DirPackage class >> file: aFile [
        ^ self new
            file: aFile;
            yourself
    ]

    directory [
        ^ self file asFile directory.
    ]

    name [
        "Pick the name of the loaded package"
        ^ self loadedPackage name.
    ]

    loadedPackage [
        <category: 'accessing'>
        | file package |
        loadedPackage isNil ifFalse: [^loadedPackage].
        file := self file asFile.
        package := Package parse: file readStream.
        package isNil
            ifTrue: [^self error: 'invalid disabled-package tag inside a star file'].
        package relativeDirectory: file directory.
        package baseDirectories: {file directory}.
        package name isNil
            ifTrue: [^self error: 'package name must not be nil'].
        loadedPackage := package.
        ^loadedPackage
    ]
]

PackageGroup subclass: DirPackageGroup [
    | package |
    <category: 'Language-Packaging'>

    DirPackageGroup class >> initWith: aPackage [
        ^self new
            package: aPackage
    ]

    package: aPackage [
        package := aPackage
    ]

    refresh: aDate [
        "Nothing to do"
    ]

    keys [
        ^OrderedCollection new
            add: package name;
            yourself
    ]

    at: aString ifAbsent: aBlock [
        aString = package name
            ifTrue: [^package].
        ^aBlock value
    ]
]

PackageDirectories extend [
    addFirst: aDirectory [
        <category: '*Language-Kernel'>

        "Used by insertPackage to add the directory first"
        ^dirs addFirst: aDirectory
    ]
]

]

PackageLoader class extend [

    insertPackage: aPackage [
        <category: '*Language-Kernel'>
        "Internal for tools like gst-sunit. Allow to set the package
        so tests using >>#packageAt: will use the right test."
        self refresh.
        root addFirst: (Kernel.DirPackageGroup initWith: aPackage).
    ]

    loadPackageFromFile: aFileName [
        | package |
        <category: '*Language-Kernel'>

        "Make sure that root is initialized."
        self refresh.

        "Add the 'directory' to the packages"
        package := Kernel.DirPackage file: aFileName.

        "And now file it in. Do not use >>fileIn as it will
        attempt to load the package by name."
        self fileInPackages: package prerequisites.
        package primFileIn.

        ^ package
    ]
]
