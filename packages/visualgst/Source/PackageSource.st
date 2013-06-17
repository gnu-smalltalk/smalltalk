"======================================================================
|
| PackageSource class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

SourceFormatter subclass: PackageSource [

    PackageSource class >> write: aPackage on: stream [
        <category: 'instance creation'>

        ^ (self for: stream)
            package: aPackage;
            output;
            yourself
    ]

    | package |

    package: aPackage [
        <category: 'accessing'>

        package := aPackage
    ]

    printSelector: aSelectorString with: anArgString [
	<category: 'printing'>

        stream
            nextPutAll: aSelectorString;
            nextPutAll: anArgString;
            nextPutAll: ';';
            nl;
            space: 4
    ]

    printSelector: aSelectorString withArray: anArgArray [
        <category: 'printing'>

        anArgArray do: [ :each | self printSelector: aSelectorString with: each ]
    ]

    printName [

        package name ifNil: [ ^ self ].
	self printSelector: ' name: ' with: package name displayString
    ]

    printPackageUrl [

	package url ifNil: [ ^ self ].
	self printSelector: ' url: ' with: package url displayString
    ]

    printPackageNamespace [

        package namespace ifNil: [ ^ self ].
	self printSelector: ' namespace: ' with: package namespace displayString
    ]

    printPackageTest [

        "self test isNil
            ifFalse:
                [stream space: 2.
                self test
                    printOn: stream
                    tag: 'test'
                    indent: 4 + 2.
                stream
                    nl;
                    space: 4]."
    ]

    printPackageProvide [

	self printSelector: ' provides: ' withArray: package features asSortedCollection displayString
    ]

    printPackagePrereq [

	self printSelector: ' prereq: ' withArray: package prerequisites asSortedCollection displayString
    ]

    printPackageSUnit [

	self printSelector: ' sunit: ' withArray: package sunitScripts asSortedCollection displayString
    ]

    printPackageCallout [

	self printSelector: ' callout: ' withArray: package callouts asSortedCollection displayString
    ]

    printPackageLibrary [

	self printSelector: ' library: ' withArray: package libraries asSortedCollection displayString
    ]

    printPackageModule [

	self printSelector: ' module: ' withArray: package modules asSortedCollection displayString
    ]

    printPackageRelativeDirectory [

        package relativeDirectory ifNil: [ ^ self ].
	stream
            nextPutAll: ' directory: ';
            nextPutAll: package relativeDirectory displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageFiles [

        package files size + package builtFiles size > 1 ifTrue: [
	    stream
                nl;
                space: 4 ]
    ]

    printPackageFileins [

        stream
            nextPutAll: ' filein: #';
            nextPutAll: package fileIns displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageFile [

        stream
            nextPutAll: ' file: #';
            nextPutAll: (package files copy removeAll: package fileIns ifAbsent: []; yourself) displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageBuiltFile [

        stream
            nextPutAll: ' built-file: #';
            nextPutAll: package builtFiles displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageStartScript [

        package startScript ifNil: [ ^ self ].
        stream
	    nextPutAll: '  start: ''';
            nextPutAll: package startScript displayString;
	    nextPutAll: ''';';
            nl;
            space: 4
    ]

    printPackageStopScript [

        package stopScript ifNil: [ ^ self ].
        stream
            nextPutAll: '  stop: ''';
	    nextPutAll: package stopScript displayString;
	    nextPutAll: ''';';
            nl;
            space: 4
    ]

    printYourself [
	<category: 'accessing'>

        stream
            nextPutAll: 'yourself';
            nl;
            space: 4
    ]

    output [
        <category: 'accessing'>

        stream
            nextPutAll: 'Package new';
            nl;
            space: 4.

        self 
	    printName;
	    printPackageUrl;
	    printPackageNamespace;
	    printPackageTest;
	    printPackageProvide;
	    printPackagePrereq;
	    printPackageSUnit;
	    printPackageCallout;
	    printPackageLibrary;
	    printPackageModule;
	    printPackageRelativeDirectory;
	    printPackageFiles;
	    printPackageFileins;
	    printPackageFile;
	    printPackageBuiltFile;
	    printPackageStartScript;
	    printPackageStopScript;
	    printYourself
    ]

    parser [
        ^ STInST.GSTParser
    ]
]

