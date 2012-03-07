"======================================================================
|
|   Smalltalk package installer
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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

[PackageLoader fileInPackage: 'NetClients'] on: Error do: [:ex | ex return].


DynamicVariable subclass: CurrentCommand [
]


Package extend [
    srcdir [
	^self baseDirectories last
    ]

    isStarPackageBody [
	^self baseDirectories first isKindOf: VFS.ArchiveFile
    ]

    starFileName [
	| dir |
	self isStarPackageBody ifFalse: [ self halt ].
	^self baseDirectories first asString
    ]

    runCommand: aCommand [
	self isStarPackageBody
	    ifTrue: [ aCommand runOnStar: self ]
	    ifFalse: [ aCommand runOnPackage: self ]
    ]
]

Kernel.PackageContainer subclass: StarPackageFile [
    | name |

    StarPackageFile class >> on: aFile [
	^self new file: aFile; yourself
    ]

    StarPackageFile class >> on: aFile name: aString [
	^self new file: aFile; name: aString; yourself
    ]

    baseDirectoriesFor: aPackage [
	^self file zip
    ]

    name [
	^name
    ]

    name: aString [
	name := aString
    ]

    refresh: loadDate [
	| package |
	package := Kernel.StarPackage file: self file.
	name isNil ifFalse: [ package name: self name ].
        self packages at: package name put: package loadedPackage
    ]
]

Kernel.PackageContainer subclass: RemotePackageFile [
    RemotePackageFile class >> on: aFile [
	^self new file: aFile; yourself
    ]

    testPackageValidity: package [ ]

    refresh: loadDate [
        | file |
	self file withReadStreamDo: [ :fileStream |
	    self parse: fileStream ]
    ]
]

Kernel.PackageContainer subclass: PackageFile [
    | srcdir |

    PackageFile class >> on: aFile [
	^self new file: aFile; yourself
    ]

    srcdir [
	^srcdir
    ]

    srcdir: aString [
	srcdir := aString
    ]

    baseDirectoriesFor: aPackage [
	| srcdirFile builddirPrefix |
	self srcdir isNil ifTrue: [ ^{ file path } ].

	"See if the file is in srcdir or builddir.  In any case, we want to
	 look for files first in the builddir, and secondarily in srcdir."
	srcdirFile := self file pathFrom: self srcdir.
	builddirPrefix := Directory working pathFrom: self srcdir.
	^(srcdirFile startsWith: builddirPrefix, Directory pathSeparatorString)
	    ifFalse: [ {
		"file is in srcdir."
		(File name: srcdirFile) parent.
		self file parent } ]
	    ifTrue: [ {
		"file is in builddir."
		self file parent.
		(self srcdir / (self file pathFrom: Directory working)) parent } ]
    ]

    refresh: loadDate [
        | file |
	self file withReadStreamDo: [ :fileStream |
	    self parse: fileStream ]
    ]
]


DynamicVariable subclass: MainPackage []

Kernel.PackageContainer subclass: PackageCheckout [
    | url checkoutDirectory |

    PackageCheckout class >> cacheRoot [
	^Directory userBase / 'cache'
    ]

    PackageCheckout class >> on: anURL [
	^self new url: anURL; yourself
    ]

    baseDirectoriesFor: aPackage [
	| mainPackage |
	mainPackage := MainPackage value.
	mainPackage isNil ifTrue: [ ^{ self checkoutDirectory } ].
	aPackage = mainPackage ifTrue: [ ^{ self checkoutDirectory } ].

	^{ mainPackage baseDirectories first
	    / (aPackage name copyFrom: mainPackage name size + 2) }
    ]

    checkoutDirectory [
	| dir name |
	checkoutDirectory isNil ifTrue: [
	    name := '%1__%2__%3' % {
		url scheme. url host.
		NetClients.URL encode: url path }.
	    checkoutDirectory := self class cacheRoot / name ].
	^checkoutDirectory
    ]

    checkout [
	self subclassResponsibility
    ]

    url [
	^url
    ]

    url: anURL [
	url := anURL
    ]

    parseFile: aFile [
	aFile withReadStreamDo: [ :fileStream |
	    self parse: fileStream ]
    ]

    parse: aFileStream [
	| addedPackages mainPackage |
	addedPackages := super parse: aFileStream.
	addedPackages size > 1 ifTrue: [ ^addedPackages ].

	mainPackage := addedPackages first.
	MainPackage use: mainPackage during: [
	    mainPackage prerequisites do: [ :each || file |
	        ((each startsWith: mainPackage name, '-') and: [
		    (file := mainPackage baseDirectories first
		        / (each copyFrom: mainPackage name size + 2)
		        / 'package.xml') exists ])
			    ifTrue: [ self parseFile: file ]]].

	^addedPackages
    ]

    refresh: loadDate [
	self checkout.
	(self checkoutDirectory / 'package.xml') exists ifFalse: [
	    Command dryRun ifTrue: [^self].
	    ^self error: 'cannot find package.xml in checked out repository'].

	self file: self checkoutDirectory / 'package.xml'.
	self parseFile: self file.
    ]
]


PackageCheckout subclass: SvnPackageCheckout [
    checkout [
	| realUrl command saveDir |
	self checkoutDirectory exists
	    ifFalse: [
	        self checkoutDirectory emitMkdir.
		realUrl := url copy.
		url scheme = 'svn+http' ifTrue: [ realUrl scheme: 'http' ].
		url host = '' ifTrue: [ realUrl := realUrl path ].
	        command := 'svn checkout %1 .' % {realUrl} ]
	    ifTrue: [
		command := 'svn update' ].

        ('cd %1 && ' % { self checkoutDirectory }, command) displayNl.
        saveDir := Directory working.
	Command
	    execute: [
	        Directory working: self checkoutDirectory.
		Smalltalk system: command ]
	    ensure: [ Directory working: saveDir ]
    ]
]


PackageCheckout subclass: GitPackageCheckout [
    checkout [
	| realUrl command saveDir |
	self checkoutDirectory exists
	    ifFalse: [
	        self checkoutDirectory emitMkdir.
		realUrl := url copy.
		url scheme ~ 'git+(https?|rsync)' ifTrue: [
		     realUrl scheme: (url scheme copyFrom: 5) ].
		url host = '' ifTrue: [ realUrl := realUrl path ].
	        command := 'git clone --depth 1 %1 .' % {realUrl} ]
	    ifTrue: [
		command := 'git pull' ].

        ('cd %1 && ' % { self checkoutDirectory }, command) displayNl.
        saveDir := Directory working.
	Command
	    execute: [
	        Directory working: self checkoutDirectory.
		Smalltalk system: command ]
	    ensure: [ Directory working: saveDir ].

	url fragment isNil ifFalse: [
	    command := 'git checkout origin/%1' % {url fragment}.

            ('cd %1 && ' % { self checkoutDirectory }, command) displayNl.
	    Command
	        execute: [
	            Directory working: self checkoutDirectory.
		    Smalltalk system: command ]
	        ensure: [ Directory working: saveDir ] ]
    ]
]


Kernel.PackageDirectories subclass: PackageFiles [
    | srcdir |

    parseStarFile: file [
	^(StarPackageFile on: file)
	    refresh;
	    yourself
    ]

    parseStarFile: file name: aString [
	^(StarPackageFile on: file name: aString)
	    refresh;
	    yourself
    ]

    parseXMLFile: file [
	^(PackageFile on: file)
	    srcdir: self srcdir;
	    refresh;
	    yourself
    ]

    parse: fileName [
	| file packageFile |
	file := File name: fileName.
	^('*.star' match: fileName)
	    ifFalse: [ self parseXMLFile: file ]
	    ifTrue: [ self parseStarFile: file ]
    ]

    addURL: urlString [
	| url localFile package found |
	url := NetClients.URL fromString: urlString.

	"Remote package.xml: download it to find the `real' URL."
	('*.xml' match: url path)
	    ifTrue: [
		localFile := File name: url entity localFileName.
		package := RemotePackageFile on: localFile.
		package parse: url readStream.
		found := false.
		package packages do: [ :each |
		    (each url notNil and: [each url notEmpty]) ifTrue: [
			found := true.
		        each url = urlString ifTrue: [
			    ^self error: 'infinite loop in package.xml urls' ].
			self addURL: each url ]].
		found ifTrue: [^self].
		^self error: 'url element not found in remote XML file' ].

	"Remote .star file: download it and install."
	('*.star' match: url path)
	    ifTrue: [
		^self add: (self
		    parseStarFile: (File name: url entity localFileName)
		    name: (File stripPathFrom: (File stripExtensionFrom: url path))) ].
	
	(url scheme ~ '^svn(\+|$)')
	    ifTrue: [
		^self add: ((SvnPackageCheckout on: url)
		    refresh;
		    yourself) ].
	
	(url scheme ~ '^git(\+|$)')
	    ifTrue: [
		^self add: ((GitPackageCheckout on: url)
		    refresh;
		    yourself) ].

	(url scheme ~ '^(https?|ftp|file)$')
	    ifTrue: [ self error: 'invalid URL %1' % {url} ]
	    ifFalse: [ self error: 'unknown protocol %1' % {url scheme} ]
    ]

    addFile: fileName [
	self add: (self parse: fileName).
    ]

    filesDo: aBlock [
	(dirs collect: [ :each | each fileName ]) asSet do: aBlock
    ]

    srcdir [
	^srcdir
    ]

    srcdir: aString [
	srcdir := aString
    ]
]

File extend [
    emitZipDir: dir [
	| saveDir |
	self emitRemove.
	('cd %1 && %2 -n .st:.xml -qr %3 .' % { dir. Command zip. self }) displayNl.
        saveDir := Directory working.
	Command
	    execute: [
	        Directory working: dir name.
		Smalltalk
		     system: '%1 -n .st:.xml -qr %2 .'
                     withArguments: { Command zip. self }
	    ]
	    ensure: [ Directory working: saveDir ]
    ]

    emitRemove [
	('rm -f %1' % { self }) displayNl.
	Command execute: [
	    self exists ifTrue: [ self remove ] ].
    ]

    emitSymlink: dest [
	| destFile |
	('%1 -f %2 %3' % { Command symLink. self. dest }) displayNl.
	Command execute: [
	    destFile := File name: dest.
	    destFile exists ifTrue: [ destFile remove ].
	    destFile symlinkFrom: self name ].
    ]

    emitInstall: dest [
	| destFile srcStream destStream mode |
	mode := self isExecutable ifTrue: [ 8r755 ] ifFalse: [ 8r644 ].
	destFile := File name: dest.
	('%1 -m %2 %3 %4' % {
	    Command install. mode printString: 8. self. destFile })
		displayNl.
	Command
	    execute: [
	        destFile exists ifTrue: [ destFile remove ].
	        srcStream := self readStream.
		destStream := destFile writeStream.
	        destStream nextPutAll: srcStream.
	    ]
	    ensure: [
		destStream isNil ifFalse: [ destStream close ].
		srcStream isNil ifFalse: [ srcStream close ].
		destFile mode: mode
	    ].
    ]

    emitMkdir [
	| doThat |
	self exists ifTrue: [ ^self ].
	Command execute: [ self parent emitMkdir ].
	('mkdir %1' % { self }) displayNl.
	Command execute: [ Directory create: self name ].
    ]
]

Object subclass: Command [
    | installDir options |

    Command class >> selectionOptions [
	^#()
    ]

    Command class >> current [
	^CurrentCommand value
    ]
    Command class >> execute: aBlock [
	self dryRun ifFalse: [ aBlock value ]
    ]
    Command class >> execute: aBlock ensure: ensureBlock [
	self dryRun ifFalse: [ aBlock ensure: ensureBlock ]
    ]
    Command class >> dryRun [
	^self current isOption: 'dry-run'
    ]

    Command class >> zip [
	^(Smalltalk getenv: 'XZIP') ifNil: [ 'zip' ]
    ]
    Command class >> install [
	^(Smalltalk getenv: 'INSTALL') ifNil: [ 'install' ]
    ]
    Command class >> symLink [
	^(Smalltalk getenv: 'LN_S') ifNil: [ 'ln -s' ]
    ]

    options [
	| optionsCollection |
	optionsCollection := OrderedCollection new.
	options keysDo: [ :opt |
	    (options at: opt) do: [ :arg |
	        optionsCollection add: opt->arg ]].
	^optionsCollection
    ]

    options: aCollection [
	options := Dictionary new.
	aCollection do: [ :assoc |
	    (options at: assoc key ifAbsentPut: [ OrderedCollection new ])
	        addLast: assoc value.
	    (self isValidOption: assoc key) ifFalse: [
	        self error: ('--%1 invalid for this mode' % {assoc key}) ] ]
    ]

    isValidOption: aString [
	^#('srcdir' 'target-directory' 'destdir' 'image-file'
	   'dry-run' 'kernel-directory' 'verbose') includes: aString
    ]

    isOption: aString [ ^options includesKey: aString ]
    optionsAt: aString [ ^options at: aString ]
    optionAt: aString [ ^self optionAt: aString ifAbsent: [ nil ] ]

    optionAt: aString ifAbsent: aBlock [
	| value |
	value := options at: aString ifAbsent: [ ^aBlock value ].
	value size > 1 ifTrue: [ self error: '--%1 given multiple times' % {aString} ].
	^value first
    ]

    validateDestDir: destdir installDir: instDir [ 
	instDir isNil ifTrue: [ ^self ].
	(instDir asFile isAbsolute not and: [ destdir notEmpty ])
            ifTrue: [
		self error: '--destdir used with relative target directory' ]
    ]

    prolog [
	| destdir instDir |
	destdir := self optionAt: 'destdir' ifAbsent: [ '' ].
	instDir := self optionAt: 'target-directory' ifAbsent: [ nil ].

	self validateDestDir: destdir installDir: instDir.
	installDir :=
	    File name: destdir, (instDir ifNil: [ self defaultInstallDir asString ])
    ]

    defaultInstallDir [ ^Directory image ]
    installDir [ ^installDir ]

    defaultFiles [ ^#() ]
    runOnAll: args [ self subclassResponsibility ]

    executeOnAll: args [
	CurrentCommand use: self during: [
	    | packageArgs |
	    self prolog.
	    packageArgs := args.
            packageArgs isEmpty ifTrue: [ packageArgs := self defaultFiles ].
            packageArgs isEmpty ifTrue: [ self error: 'no packages given' ].
	    self runOnAll: packageArgs]
    ]
]


Command subclass: PkgDownload [
    PkgDownload class >> selectionOptions [
	^#('download')
    ]

    PkgDownload class >> urlBase [
	^'http://smalltalk.gnu.org/project'
    ]

    isValidOption: aString [
	"Let PkgInstall decide later."
	^true
    ]

    prolog []

    runOnAll: args [
	| urls |
	urls := args collect: [ :each || pkg url |
	    pkg := PackageLoader packageAt: each ifAbsent: [ nil ].
	    url := pkg ifNotNil: [ pkg url ].
	    url ifNil: [ '%1/%2/package.xml' % { self class urlBase. each } ] ].
		
	PkgInstall new
            options: self options;
            executeOnAll: urls
    ]
]

Command subclass: PackageCommand [
    | packages |

    buildPackages [
	| srcdir |
	packages := PackageFiles new.
	srcdir := self optionAt: 'srcdir' ifAbsent: [ '.' ].
	(srcdir = '.' or: [ (File fullNameFor: srcdir) = Directory working ])
	    ifTrue: [ srcdir := nil ].

	packages srcdir: srcdir.
	^packages
    ]

    packages [
	packages isNil ifTrue: [ self buildPackages ].
	^packages 
    ]

    srcdir [
	^self packages srcdir ifNil: [ '.' ]
    ]

    addFile: aString [
	aString ~ '^[a-z+]*://'
	    ifTrue: [
		self handleURLs
		    ifFalse: [ self error: 'URLs are not supported by this mode' ]
		    ifTrue: [ self packages addURL: aString ] ]
	    ifFalse: [ self packages addFile: aString ]
    ]

    handleURLs [ ^false ]

    run [ self packages do: [ :pkg | pkg runCommand: self ] ]
    runOnStar: aStarPackage [ self runOnPackage: aStarPackage ]
    runOnPackage: aPackage [ ]

    runOnAll: args [
	args do: [ :each | self addFile: each ].
	self run
    ]
]

PackageCommand subclass: PkgDist [
    PkgDist class >> selectionOptions [
	^#('dist')
    ]

    validateDestDir: destdir installDir: instDir [ 
	(destdir isEmpty and: [ instDir isNil ]) ifTrue: [
	    self error: 'using --dist without specifying --distdir' ].
    ]

    defaultInstallDir [ ^'' ]
    run [
	super run.

	"Distribute package files, unless they are automatically generated
	 from autoconf."
	packages filesDo: [ :each |
	    | destName autoconfName srcdir |
	    destName := File stripPathFrom: each.
	    srcdir := self srcdir / (File pathFor: each).
	    autoconfName := destName, '.in'.
	    (srcdir includes: autoconfName)
		ifFalse: [
		    self distribute: (File name: each)
			as: destName
			in: nil ] ]
    ]

    isValidOption: aString [
	(#('all-files' 'copy') includes: aString) ifTrue: [^true].
	^super isValidOption: aString
    ]

    distribute: srcFile as: file in: dir [
	| destName baseDir |
	baseDir := self installDir.
	dir isNil ifFalse: [ baseDir := baseDir / dir ].
	destName := baseDir nameAt: file.
	(self isOption: 'copy')
	    ifTrue: [ srcFile emitInstall: destName ]
	    ifFalse: [ srcFile emitSymlink: destName ]
    ]

    runOnPackage: aPackage [
	| dirs files baseDir |
	files := (self isOption: 'all-files')
	    ifTrue: [ aPackage allFiles ]
	    ifFalse: [ aPackage allDistFiles ].

        dirs := files collect: [ :file | File pathFor: file ].
	dirs := dirs asSet remove: '' ifAbsent: [ ]; asSortedCollection.

	baseDir := self installDir.
	aPackage relativeDirectory isNil ifFalse: [
	    baseDir := baseDir / aPackage relativeDirectory ].

	baseDir emitMkdir.
        dirs do: [ :dir | (baseDir / dir) emitMkdir ].

        files do: [ :file || srcFile destName |
	    srcFile := aPackage fullPathOf: file.
	    self distribute: srcFile as: file in: aPackage relativeDirectory ]
    ]
    runOnStar: aPackage [
	self error: 'cannot distribute sources from .star file'
    ]
]

PackageCommand subclass: PkgInstall [
    | tmpDir |
    isValidOption: aString [
	(#('load' 'test') includes: aString) ifTrue: [^true].
	^super isValidOption: aString
    ]

    handleURLs [ ^true ]

    run [
        "Create the installation directory."
        self installDir emitMkdir.
	[ super run ] ensure: [
	    tmpDir isNil ifFalse: [ tmpDir all remove ] ].

	PackageLoader
            flush;
            refresh.
	(Command dryRun not and: [ self isOption: 'load' ])
	    ifTrue: [ ^self loadPackages ].

	(self isOption: 'test') ifTrue: [ self runTests ]
    ]

    runTests [
	"Run SUnit tests, used unless --load is given too."
	| script result |
	script := ''.
	self packages do: [ :each || pkg |
	    pkg := each.
            script := script, ' ', pkg sunitScript.
            pkg test notNil ifTrue: [
                pkg := pkg test.
                script := script, ' ', pkg sunitScript ].
            pkg fileIn ].

	(PackageLoader packageAt: #SUnit) loaded ifFalse: [ ^self ].
	script isEmpty ifTrue: [ ^self ].

	result := TestSuitesScripter run: script quiet: false verbose: false.
	result runCount = result passedCount
	    ifFalse: [ ObjectMemory quit: 1 ]
    ]

    loadPackages [
	"Call gst-load, needed because we added our code to the image."
	| gstPackage execDir gstLoad pat packageList |
	gstPackage := File executable.
	gstPackage stripPath = 'gst-tool'
	    ifTrue: [
		gstLoad := gstPackage.
		pat := '%1 gst-load -I %2 --kernel-directory %3 %4 %5' ]
	    ifFalse: [
		gstLoad := gstPackage directory / 'gst-load'.
		pat := '%1 -I %2 --kernel-directory %3 %4 %5' ].

	packageList := ''.
	self packages
	    do: [ :each | packageList := packageList, ' ', each name ].

	Smalltalk
            system: pat
            withArguments: {
	        gstLoad.
	        File image.
	        Directory kernel.
	        (self isOption: 'test') ifTrue: [ '--test' ] ifFalse: [ '' ].
	        packageList }
    ]

    tmpDir [
	tmpDir isNil ifTrue: [
            tmpDir := Directory createTemporary: Directory temporary / 'gstar-'.
            ('mkdir %1' % { tmpDir }) displayNl ].
	^tmpDir
    ]

    runOnPackage: aPackage [
	| pkg destFile dirs files baseDir |
	baseDir := self tmpDir / aPackage name.
	pkg := aPackage copy.
	pkg relativeDirectory: nil.

	baseDir emitMkdir.
	Command
	    execute: [
	        (baseDir / 'package.xml') withWriteStreamDo: [ :s |
	            pkg printOn: s ].

	        files := pkg allFiles.
                dirs := files collect: [ :file | File pathFor: file ].
	        (dirs asSet remove: '' ifAbsent: []; asSortedCollection)
		    do: [ :dir | (baseDir / dir) emitMkdir ].

                files do: [ :file || srcFile |
	            srcFile := (aPackage fullPathOf: file).
	            srcFile emitSymlink: (baseDir nameAt: file) ].

	        (self installDir / aPackage name, '.star')
		    emitZipDir: baseDir
	    ]
	    ensure: [ baseDir all remove ].
    ]

    runOnStar: aPackage [
	| destFile |
	destFile := self installDir nameAt: aPackage name, '.star'.
	(File name: aPackage starFileName) emitInstall: destFile.
    ]
]

PackageCommand subclass: PkgUninstall [
    PkgUninstall class >> selectionOptions [
	^#('uninstall')
    ]

    run [
        super run.
        packages filesDo: [ :each | (File name: each) emitRemove ]
    ]

    runOnPackage: aPackage [
	| baseDir |
	baseDir := self installDir.
	aPackage relativeDirectory isNil ifFalse: [
	    baseDir := baseDir / aPackage relativeDirectory ].

	aPackage allFiles do: [ :file |
	    (baseDir / file) emitRemove ]
    ]

    runOnStar: aPackage [ ]
]

PackageCommand subclass: ListCommand [
    validateDestDir: destdir installDir: installDir [
	destdir = ''
	    ifFalse: [ self error: '--destdir not needed with --list-files' ].
	installDir isNil
	    ifFalse: [ self error: '--target-directory not needed with --list-files' ]
    ]
    defaultInstallDir [ ^'.' ]
]

ListCommand subclass: PkgList [
    PkgList class >> selectionOptions [
	^#('list-files' 'no-install')
    ]

    isValidOption: aString [
	(#('list-files' 'vpath' 'load') includes: aString) ifTrue: [^true].
	^super isValidOption: aString
    ]

    run [
	| base vpathBase vpath source test listFiles |
	super run.
	listFiles := self optionsAt: 'list-files'.
	vpath := self isOption: 'vpath'.
	source := self isOption: 'load'.
	test := self isOption: 'test'.
	base := self installDir.
	vpathBase := File name: self srcdir.

        listFiles do: [ :each || package files |
	    package := self packages at: each.
	    files := source
		ifFalse: [ package allFiles ]
		ifTrue: [ package fileIns ].

	    (test and: [ source and: [ package test notNil ]])
		ifTrue: [ files := files, package test fileIns ].

	    files do: [ :file |
		| path relativePath |
		path := package fullPathOf: file.
		relativePath := base pathTo: path.
		(vpath and: [ (relativePath indexOfSubCollection: '../') > 0 ])
		    ifTrue: [ relativePath := vpathBase pathTo: path ].

		relativePath displayNl ] ]
    ]
]

ListCommand subclass: PkgPackageList [
    PkgPackageList class >> selectionOptions [
	^#('list-packages')
    ]

    runOnPackage: aPackage [ aPackage name displayNl ]
]

PackageCommand subclass: PkgPrepare [
    | srcFile |
    PkgPrepare class >> selectionOptions [
	^#('prepare')
    ]

    validateDestDir: destdir installDir: installDir [
	destdir = ''
	    ifFalse: [ self error: '--destdir not needed with --prepare' ].
	installDir isNil
	    ifFalse: [ self error: '--target-directory not needed with --prepare' ]
    ]

    defaultFiles [
	(File exists: self srcdir, '/package.xml')
	    ifTrue: [ srcFile := 'package.xml' ].
	(File exists: self srcdir, '/package.xml.in')
	    ifTrue: [ srcFile := 'package.xml.in' ].
	^{ srcFile }
    ]

    addFile: aString [
	| f |
	srcFile isNil ifTrue: [
	    f := self srcdir / aString.
            f exists
	        ifTrue: [ srcFile := (File name: self srcdir) pathTo: f ].

	    f := f, '.in'.
            f exists
	        ifTrue: [ srcFile := (File name: self srcdir) pathTo: f ].

            (File exists: aString)
		ifTrue: [ srcFile := File name: aString ].

	    srcFile isNil ifTrue: [ self error: '%1 not found' % {srcFile} ]
	].

	super addFile: aString.
    ]

    run [
        | base configureAC makefileAM gstIN |
	base := File name: self srcdir.
	configureAC := base at: 'configure.ac'.
	makefileAM := base at: 'Makefile.am'.
	gstIN := base at: 'gst.in'.

	configureAC exists ifFalse: [
	    'creating configure.ac' displayNl.
	    Command dryRun ifFalse: [
	        configureAC withWriteStreamDo: [ :ws | self writeConfigure: ws ] ] ].
	gstIN exists ifFalse: [
	    'creating gst.in' displayNl.
	    Command dryRun ifFalse: [
	        gstIN withWriteStreamDo: [ :ws | self writeGstIn: ws ] ] ].
	makefileAM exists ifFalse: [
	    'creating Makefile.am' displayNl.
	    Command dryRun ifFalse: [
	        makefileAM withWriteStreamDo: [ :ws | self writeMakefile: ws ] ] ]
    ]

    writeGstIn: ws [
	ws nextPutAll:
'#! /bin/sh
abs_top_builddir=@abs_top_builddir@
: ${LIBTOOL=$abs_top_builddir/libtool}

exec $LIBTOOL --mode=execute @PACKAGE_DLOPEN_FLAGS@ @GST@ ${1+"$@"}
'
    ]

    writeConfigure: ws [
	| numPackages pkgName tarName |
	numPackages := 0.
	self packages do: [ :each |
	    pkgName := each name.
	    numPackages := numPackages + 1 ].

	numPackages = 1 ifFalse: [ pkgName := 'XYZ' ].

        tarName := 'gst-',
	    (pkgName asLowercase copyReplacingAllRegex: '[-_ ]+' with: '-').

	ws nextPutAll: ('AC_PREREQ(2.59)
AC_INIT([GNU Smalltalk package %1], [0.0], , %2)
AC_CONFIG_SRCDIR([%3])

AM_INIT_AUTOMAKE

AM_PATH_GST([2.95c], , [AC_MSG_ERROR([GNU Smalltalk not found])])
' % { pkgName. tarName. srcFile }).

	packages filesDo: [ :each |
	    self writeConfigureEntry: each to: ws ].

	ws nextPutAll: '
AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([gst], [chmod +x gst])
AC_OUTPUT
'
    ]

    writeConfigureEntry: each to: ws [
	| pkgName buildPath srcPath pkgSrcDir relPkgSrcDir generated |
	buildPath := Directory working pathTo: each.
	srcPath := (File name: self srcdir) pathTo: each.

	pkgSrcDir := srcPath size < buildPath size
	    ifTrue: [ File pathFor: srcPath ifNone: [ self srcdir ] ]
	    ifFalse: [ File append: (File pathFor: buildPath) to: self srcdir ].

	relPkgSrcDir := (File name: self srcdir) pathTo: pkgSrcDir.

	('*.in' match: each)
	    ifTrue: [
		srcPath := srcPath allButLast: 3.
		buildPath := buildPath allButLast: 3.
		generated := true ]
	    ifFalse: [
		generated := (File name: srcPath, '.in') exists ].

	(File name: each) withReadStreamDo: [ :rs |
	    | pkg |
	    [ pkg := Package parse: rs ]
	        on: Kernel.PackageNotAvailable
	        do: [ :ex | ex resume ].
	    pkgName := pkg name ].

	ws nextPutAll: ('GST_PACKAGE_ENABLE([%1], [%2]' % {
	    pkgName. relPkgSrcDir }).

	generated ifTrue: [
	    ws nextPutAll: (', , , [%1]' % {
		(File name: relPkgSrcDir) pathTo: srcPath }) ].

	ws nextPutAll: ')'; nl.
    ]

    writeMakefile: ws [
	ws nextPutAll:
'AUTOMAKE_OPTIONS = foreign
AM_CPPFLAGS = $(GST_CFLAGS)

## Example:
##
## gst_module_ldflags = -rpath $(gstlibdir) -module \
##        -no-undefined -export-symbols-regex gst_initModule
##
## noinst_HEADERS = md5.h sha1.h
## gstlib_LTLIBRARIES = digest.la
## digest_la_SOURCES = digest.c md5.c sha1.c
## digest_la_LDFLAGS = $(gst_module_ldflags)


### -------------------------------------- ###
### Rules completed by GST_PACKAGE_ENABLE. ###
### -------------------------------------- ###

DISTCLEANFILES = pkgrules.tmp
all-local:
clean-local::
install-data-hook::
dist-hook::
uninstall-local::

@PACKAGE_RULES@
'
    ]
]


Object subclass: PackageManager [
    | mode args options |

    ModeClasses := nil.
    PackageManager class >> classForMode: aString [
	^self modeClasses at: aString ifAbsent: [ nil ]
    ]

    PackageManager class >> modeClasses [
	ModeClasses isNil ifTrue: [
	    ModeClasses := Dictionary new.
	    Command allSubclassesDo: [ :each |
	        each selectionOptions do: [ :opt |
		    ModeClasses at: opt put: each ] ] ].

	^ModeClasses
    ]

    mode [
	mode isNil ifTrue: [ mode := PkgInstall ].
	^mode
    ]

    mode: aClass [
	(mode notNil and: [ mode ~~ aClass ])
	    ifTrue: [ self error: 'multiple modes specified' ].
	mode := aClass
    ]

    options [
	options isNil ifTrue: [ options := OrderedCollection new ].
	^options
    ]

    addOption: opt argument: arg [
	self options add: opt->arg
    ]

    addArgument: arg [
	args isNil ifTrue: [ args := OrderedCollection new ].
	args add: arg
    ]

    helpString [
	^'Usage:
    gst-package [OPTION]... ARGS...

Operation modes:
        --install               make or install STAR packages (default)
        --uninstall             remove the packages mentioned in the FILES
        --dist                  copy files instead of creating STAR files.
        --prepare               create configure.ac or Makefile.am
        --list-files PKG        just output the list of files in the package
        --list-packages         just output the list of packages in the files

        --download, --update    download package from smalltalk.gnu.org or
                                from its specified URL

	--help                  display this message and exit
	--version               print version information and exit

Common suboptions:
    -n, --dry-run               print commands without running them
	--srcdir DIR            look for non-built files in directory DIR
	--distdir DIR	        for --dist, place files in directory DIR
	--destdir DIR	        prefix the destination directory with DIR
        --target-directory DIR  install the files in DIR (unused for --dist)
    -I, --image-file=FILE       load into the specified image
        --kernel-dir=PATH       use the specified kernel directory
    -v, --verbose               print extra information while processing

--install suboptions:
	--test                  run unit tests after merging
	--load                  also load the Smalltalk files in the image

--list-files suboptions:
	--load                  only list files that are filed in when loading
	--test                  with --load, also include unit test files
	--vpath			Omit path to srcdir for files that are there

--dist suboptions:
        --all-files             Process all files, not just non-built ones
        --copy                  Do not create symbolic links

All operation modes except --download (or its synonym --update) accept
paths to package.xml files or .star files, including remote URLs.
--download and --update accept names of packages, which will be searched
in the current system or on smalltalk.gnu.org)
or URLs to package.xml or .star files.

Except in uninstall and list files mode, gst-package requires write
access to the GNU Smalltalk image directory, and merges the XML package
files on the command line with that file.

The default target directory is ', Directory image name, '

'
    ]

    displayHelpAndQuit: anInteger [
	<category: 'help printing'>

        self helpString displayOn:
            (anInteger = 1 ifTrue: [stderr] ifFalse: [stdout]).
        ObjectMemory quit: anInteger
    ]

    parseArguments: args [
        Getopt
            "--kernel-directory and --image-file are processed by gst-tool.
	     --no-load present for backwards compatibility, it is now the
	     default. --no-install is also present for backwards compatibility."
	     parse: args
	     with: '-h|--help --no-load --test --load --no-install --uninstall
                --dist -t|--target-directory: --list-files: --list-packages
                --prepare --srcdir: --distdir|--destdir: -n|--dry-run
		--all-files --vpath --copy -I|--image-file: --kernel-directory:
		--update|--download --version -v|-V|--verbose'

            do: [ :opt :arg || modeClass |
	        opt = 'help' ifTrue: [
		    self displayHelpAndQuit: 0 ].

	        opt = 'version' ifTrue: [
		    ('gst-package - %1' % {Smalltalk version}) displayNl.
		    ObjectMemory quit: 0 ].

		opt = 'verbose' ifTrue: [
		    OutputVerbosity := 1.
		    FileStream verbose: true ].

		modeClass := self class classForMode: opt.
		modeClass notNil ifTrue: [ self mode: modeClass ].

		(modeClass isNil or: [ arg notNil ])
		    ifTrue: [
			opt isNil
			    ifFalse: [ self addOption: opt argument: arg. ]
			    ifTrue: [ self addArgument: arg ]]]
            ifError: [
                self displayHelpAndQuit: 1 ].
    ]

    run [
	| command |
	(args isNil or: [args isEmpty]) ifTrue: [ self displayHelpAndQuit: 1 ].
        command := self mode new.
        command options: self options.
        command executeOnAll: args.
    ]
]


[ PackageManager new
	parseArguments: Smalltalk arguments;
	run
]
    on: Error
    do: [ :ex |
	('gst-package: ', ex messageText, '
') displayOn: stderr.
	ex pass. ObjectMemory quit: 1 ].
