"======================================================================
|
|   Smalltalk package installer
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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


Package extend [
    isStarPackageBody [
	^'*.star#uzip' match: self baseDirectories first
    ]

    starFileName [
	| dir |
	self isStarPackageBody ifFalse: [ self halt ].
	dir := self baseDirectories first.
	^dir copyFrom: 1 to: dir size - 5 ]

    runCommand: aCommand [
	self isStarPackageBody
	    ifTrue: [ aCommand runOnStar: self ]
	    ifFalse: [ aCommand runOnPackage: self ]
    ]
]

Kernel.PackageDirectory subclass: PackageFile [
    refreshStarList []

    refreshPackageList [
        | file |
	file := FileStream open: fileName mode: FileStream read.
	[ self parse: file baseDirectories: baseDirectories ]
	    ensure: [ file close ].
    ]
]

Kernel.PackageDirectories subclass: PackageFiles [
    | srcdir |

    addAllFiles: aCollection [
	aCollection do: [ :each | self addFile: each ]
    ]

    addFile: fileName [
	| packageFile |
	packageFile := ('*.star' match: fileName)
	    ifFalse: [
		PackageFile
		    on: fileName
		    baseDirectories: (self baseDirsFor: fileName) ]
	    ifTrue: [
		PackageFile
		    on: fileName, '#uzip/package.xml'
		    baseDirectories: fileName, '#uzip' ].

	packageFile refresh.
	self add: packageFile.
    ]

    baseDirsFor: fileName [
	^self srcdir isNil
	    ifTrue: [ { (File name: fileName) path } ]
	    ifFalse: [ { (File name: fileName) path. srcdir } ]
    ]

    srcdir [
	^srcdir
    ]

    srcdir: aString [
	srcdir := aString
    ]
]

File extend [
    emitRemove [
	('rm -f %1' % { self }) displayNl
    ]

    emitSymlink: dest [
	self isDirectory ifTrue: [ ^(Directory name: dest) emitMkdir ].
	('$LN_S -f %1 %2' % { self. File name: dest }) displayNl
    ]

    emitInstall: dest [
	| mode |
	mode := self isExecutable ifTrue: [ 8r755 ] ifFalse: [ 8r644 ].
	('$INSTALL -m %1 %2 %3'
	    % { mode printString: 8. self. File name: dest }) displayNl
    ]
]

Directory extend [
    emitMkdir [
	('$mkdir_p %1' % { self }) displayNl
    ]
]

Object subclass: Command [
    | packages installDir |

    validateDestDir: destdir installDir: instDir [ 
	instDir isNil ifTrue: [ ^self ].
	((Directory name: instDir) name ~= instDir
	    and: [ destdir notEmpty ]) ifTrue: [
		self error: '--destdir used with relative target directory' ]
    ]

    destDir: destdir installDir: instDir [
	self validateDestDir: destdir installDir: installDir.
	instDir isNil
	    ifTrue: [ installDir := destdir, self defaultInstallDir ]
	    ifFalse: [ installDir := destdir, instDir ]
    ]

    defaultInstallDir [ ^Directory image ]
    installDir [ ^installDir ]

    packages [
	packages isNil ifTrue: [ packages := PackageFiles new ].
	^packages 
    ]

    srcdir: aString [ self packages srcdir: aString ]
    addAllFiles: aCollection [ self packages addAllFiles: aCollection ]

    run [ self packages do: [ :pkg | pkg runCommand: self ] ]
    runOnStar: self [ self runOnPackage: self ]
    runOnPackage: self [ ]

    listFiles: listFiles [
        listFiles do: [ :each || package |
	    package := self packages at: each.
	    package allFiles do: [ :file |
		(package findPathFor: file) displayNl ] ]
    ]
]

Command subclass: PkgDist [
    validateDestDir: destdir installDir: installDir [ 
	destdir isEmpty ifTrue: [
	    self error: 'using --dist without specifying --distdir' ].
    ]

    defaultInstallDir [ ^'' ]
    runOnPackage: aPackage [
	| dirs files baseDir |
	files := aPackage files.
        dirs := files collect: [ :file |
	    Directory append: (File pathFor: file) to: aPackage relativeDirectory ].

        dirs asSet asSortedCollection do: [ :dir || destName |
	    destName := Directory append: dir to: self installDir.
	    (Directory name: destName) emitMkdir ].

	baseDir := Directory append: aPackage relativeDirectory to: self installDir.
        files do: [ :file || srcFile destName |
	    srcFile := File name: (aPackage findPathFor: file).
	    destName := Directory append: file to: baseDir.
	    srcFile emitSymlink: destName ]
    ]
]

Command subclass: PkgInstall [
    run [
        | destFile mergeResult |
        "Create the installation directory.  Then, if we are installing, add
         packages.xml to the list and merge the supplied packages files with it.
         This is temporary, as installation will create .star packages later on."
        (Directory name: self installDir) emitMkdir.

        "This is also temporary.  To merge the packages.xml file, we need to
         really create the file.  This screws up --dry-run but, again, it's
         temporary.  For distribution it is not necessary, because the distdir
	 should have already been created."
        ((Directory name: self installDir) name subStrings: $/)
	    inject: (Directory name: '/')
	    into: [ :old :each || dir |
	        dir := old directoryAt: each.
	        dir exists ifFalse: [ dir := Directory create: dir name ].
	        dir ].

	"Do merge the package files.  So far we did this in install mode only,
	 but it actually makes more sense to do it in distribution mode."
        destFile := File name: self installDir, '/packages.xml'.
	mergeResult := packages copy.
        destFile exists ifTrue: [
	    "In this case, we can pass problematic packages through."
	    [ mergeResult addFile: destFile name ]
		on: Kernel.PackageNotAvailable
		do: [ :ex | ex resume ] ].

        destFile withWriteStreamDo: [ :s | mergeResult printOn: s ].
	super run
    ]

    runOnPackage: aPackage [
	"Right now this is almost a copy of PkgDist>>#runOnPackage:, but
	 this will change when this will create a .star file."
	| dirs files baseDir |
	files := aPackage allFiles.
        dirs := files collect: [ :file |
	    Directory append: (File pathFor: file) to: aPackage relativeDirectory ].

        dirs asSet asSortedCollection do: [ :dir || destName |
	    destName := Directory append: dir to: self installDir.
	    (Directory name: destName) emitMkdir ].

	baseDir := Directory append: aPackage relativeDirectory to: self installDir.
        files do: [ :file || srcFile destName |
	    srcFile := File name: (aPackage findPathFor: file).
	    destName := Directory append: file to: baseDir.
	    srcFile emitInstall: destName ]
    ]
]

Command subclass: PkgUninstall [
    runOnPackage: aPackage [
	| baseDir |
	baseDir := Directory append: aPackage relativeDirectory to: self installDir.
	aPackage allFiles do: [ :file || destName |
	    destName := (Directory append: file to: baseDir).
	    (File name: destName) emitRemove ]
    ]
]

Command subclass: PkgList [
    validateDestDir: destdir installDir: installDir [ ]
]

PkgList subclass: PkgPackageList [
    runOnPackage: aPackage [ aPackage name displayNl ]
]

| srcdir installDir mode listFiles destdir packageFiles helpString |

mode := PkgInstall.
listFiles := OrderedCollection new.
installDir := nil.
destdir := ''.
srcdir := nil.
packageFiles := OrderedCollection new.
packages := PackageFiles new.

helpString := 
'Usage:
    gst-package [OPTION]... FILES...

    -n, --dry-run               print commands rather than running them
	--test                  run unit tests after merging
	--load                  also load the Smalltalk files in the image
        --uninstall             remove the packages mentioned in the FILES
        --dist                  create symbolic links of non-built files
        --list-files PKG        just output the list of files in the package
        --list-packages         just output the list of packages in the files
	--srcdir DIR            look for non-built files in directory DIR
	--distdir DIR	        for --dist, place files in directory DIR
	--destdir DIR	        prefix the destination directory with DIR
        --target-directory DIR  install the files in DIR (unused for --dist)

	--help                  display this message and exit
	--version               print version information and exit

Except in uninstall and list files mode, gst-package requires write
access to the GNU Smalltalk image directory, and merges the XML package
files on the command line with that file.

The default target directory is $install_dir.'.

[
    Smalltalk
        "--load, --image-file, --dry-run are processed by gst-package.
	 --no-load present for backwards compatibility, it is now the default.
	 --no-install is also present for backwards compatibility."
        arguments: '-h|--help --no-load --load --no-install --uninstall
            --dist -t|--target-directory: --list-files: --list-packages
            --srcdir: --distdir|--destdir: -n|--dry-run -I|--image-file:'

        do: [ :opt :arg |
            opt = 'help' ifTrue: [
                helpString displayOn: stderr.
                ObjectMemory quit: 0 ].

            opt = 'uninstall' ifTrue: [ mode := PkgUninstall ].
            opt = 'dist' ifTrue: [ mode := PkgDist ].
            opt = 'list-packages' ifTrue: [ mode := PkgPackageList ].

            opt = 'target-directory' ifTrue: [ installDir := arg ].
            opt = 'no-install' ifTrue: [ mode := Command ].
            opt = 'list-files' ifTrue: [ mode := PkgList. listFiles add: arg ].
            opt = 'srcdir' ifTrue: [ srcdir := arg ].
            opt = 'destdir' ifTrue: [ destdir := arg ].

            opt isNil ifTrue: [ packageFiles add: arg ] ].

    "Validate the installation and source directory."
    mode new
        destDir: destdir installDir: installDir;
	srcdir: srcdir;
	addAllFiles: packageFiles;
	run;
	listFiles: listFiles
]
    on: Error
    do: [ :ex |
	('gst-package: ', ex messageText, '
') displayOn: stderr.
	"ex pass." ObjectMemory quit: 1 ].
