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
	packageFile := PackageFile
	    on: fileName
	    baseDirectories: (self baseDirsFor: fileName).

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
	('rm -f %1' bindWith: self) displayNl
    ]

    emitSymlink: dest [
	self isDirectory ifTrue: [ ^(Directory name: dest) emitMkdir ].

	('cp -pf %1 %2'
		bindWith: self
		with: (File name: dest)) displayNl
    ]

    emitInstall: dest [
	| mode |
	mode := self isExecutable ifTrue: [ 8r755 ] ifFalse: [ 8r644 ].
	('$INSTALL -m %1 %2 %3'
		bindWith: (mode printString: 8)
		with: self
		with: (File name: dest)) displayNl
    ]
]

Directory extend [
    emitMkdir [
	('$mkdir_p %1' bindWith: self) displayNl
    ]
]

| installDir mode listFiles destdir files packageFiles helpString |

mode := #install.
listFiles := OrderedCollection new.
installDir := Directory image.
destdir := ''.
packageFiles := OrderedCollection new.
packages := PackageFiles new.

helpString := 
'Usage:
    gst-package [OPTION]... FILES...

    -n, --dry-run               print commands rather than running them
	--test                  run unit tests after merging
	--no-load               don''t load the Smalltalk files in the image
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
        "--no-load, --image-file, --dry-run are processed by gst-package."
        arguments: '-h|--help --no-load --uninstall --dist
            -t|--target-directory: --list-files: --list-packages
            --srcdir: --distdir|--destdir: -n|--dry-run -I|--image-file:'

        do: [ :opt :arg |
            opt = 'help' ifTrue: [
                helpString displayOn: stderr.
                ObjectMemory quit: 0 ].

            opt = 'uninstall' ifTrue: [ mode := #uninstall ].
            opt = 'dist' ifTrue: [ mode := #dist ].
            opt = 'target-directory' ifTrue: [ installDir := arg ].
            opt = 'list-files' ifTrue: [ listFiles add: arg ].
            opt = 'list-packages' ifTrue: [ mode := #list ].
            opt = 'srcdir' ifTrue: [ packages srcdir: arg ].
            opt = 'destdir' ifTrue: [ destdir := arg ].

            opt isNil ifTrue: [ packageFiles add: arg ] ].

    "Validate the installation and source directory."
    mode = #dist
        ifTrue: [
	    destdir isEmpty ifTrue: [
	        self error: 'using --dist without specifying --distdir' ].
	    installDir := '' ]
        ifFalse: [
	    ((Directory name: installDir) name ~= installDir
	        and: [ destdir notEmpty ]) ifTrue: [
		    self error: '--destdir used with relative target directory' ] ].

    packages addAllFiles: packageFiles.

    "Process --uninstall, --list-packages, --list-files now, then exit."
    mode = #uninstall ifTrue: [
        packages do: [ :each || baseDir |
	    baseDir := Directory append: each relativeDirectory to: installDir.
	    each allFiles do: [ :file || destName |
	        destName := destdir, (Directory append: file to: baseDir).
	        (File name: destName) emitRemove ] ].

        ObjectMemory quit ].

    mode = #list ifTrue: [
        packages do: [ :each | each name displayNl ].
        ObjectMemory quit ].

    listFiles isEmpty ifFalse: [
        listFiles do: [ :each || package |
	    package := packages at: each.
	    package allFiles do: [ :file |
		(package findPathFor: file) displayNl ] ].
        ObjectMemory quit ].


    "Create the installation directory.  Then, if we are installing, add
     packages.xml to the list and merge the supplied packages files with it.
     This is temporary, as installation will create .star packages later on."

    installDir := destdir, installDir.
    (Directory name: installDir) emitMkdir.

    "This is also temporary.  To merge the packages.xml file, we need to
     really create the file.  This screws up --dry-run but, again, it's
     temporary."
    ((Directory name: installDir) name subStrings: $/)
	inject: (Directory name: '/')
	into: [ :old :each || dir |
	    dir := old directoryAt: each.
	    dir exists ifFalse: [ dir := Directory create: dir name ].
	    dir ].

    mode = #dist ifFalse: [
        | destFile mergeResult |
        destFile := File name: installDir, '/packages.xml'.
	mergeResult := packages copy.
        destFile exists ifTrue: [
	    "In this case, we can pass problematic packages through."
	    [ mergeResult addFile: destFile name ]
		on: Kernel.PackageNotAvailable
		do: [ :ex | ex resume ] ].

        destFile withWriteStreamDo: [ :s | mergeResult printOn: s ] ].

    packages do: [ :each || dirs files baseDir |
	files := mode = #dist
	    ifTrue: [ each files ]
	    ifFalse: [ each allFiles ].

        dirs := files collect: [ :file |
	    Directory append: (File pathFor: file) to: each relativeDirectory ].

        dirs asSet asSortedCollection do: [ :dir |
	    destName := Directory append: dir to: installDir.
	    (Directory name: destName) emitMkdir ].

	baseDir := Directory append: each relativeDirectory to: installDir.
        files do: [ :file || srcFile destName |
	    srcFile := File name: (each findPathFor: file).
	    destName := Directory append: file to: baseDir.

            mode = #dist
	        ifTrue: [ srcFile emitSymlink: destName ]
	        ifFalse: [ srcFile emitInstall: destName ] ] ]
]
    on: Error
    do: [ :ex |
	('gst-package: ', ex messageText) displayOn: stderr.
	"ex pass." ObjectMemory quit: 1 ].
