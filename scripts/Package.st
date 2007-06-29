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
    srcdir [
	^self baseDirectories last
    ]

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

Kernel.PackageDirectory subclass: StarPackageFile [
    refreshStarList: dir [
	| package |
	package := Kernel.StarPackage fileName: self fileName.
        packages at: package name put: package loadedPackage
    ]

    refreshPackageList []
]

Kernel.PackageDirectory subclass: PackageFile [
    refreshStarList: dir []

    refreshPackageList [
        | file |
	file := FileStream open: fileName mode: FileStream read.
	[ self parse: file ]
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
		    baseDirectories: [ self baseDirsFor: fileName ] ]
	    ifTrue: [
		StarPackageFile
		    on: fileName
		    baseDirectories: [ fileName, '#uzip' ] ].

	packageFile refresh.
	self add: packageFile.
    ]

    baseDirsFor: fileName [
	| file srcdirPath builddirPrefix |
	file := File name: fileName.
	self srcdir isNil ifTrue: [ ^{ file path } ].

	"See if the file is in srcdir or builddir.  In any case, we want to
	 look for files first in the builddir, and secondarily in srcdir."
	srcdirPath := file pathFrom: srcdir.
	builddirPrefix := (Directory name: Directory working) pathFrom: srcdir.
	^(srcdirPath startsWith: builddirPrefix, Directory pathSeparatorString)
	    ifFalse: [
		"file is in srcdir."
		{ File pathFor: srcdirPath. file path } ]
	    ifTrue: [ {
		"file is in builddir."
		file path.
		Directory append: (File pathFor: fileName) to: self srcdir } ]
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
	self emitRemove.
	('cmd %1 \$ZIP -qr %2 .' % { dir. self }) displayNl
    ]

    emitRemove [
	('cmd . rm -f %1' % { self }) displayNl
    ]

    emitSymlink: dest [
	('cmd . \$LN_S -f %1 %2' % { self. dest }) displayNl
    ]

    emitInstall: dest [
	| mode |
	mode := self isExecutable ifTrue: [ 8r755 ] ifFalse: [ 8r644 ].
	('cmd . \$INSTALL -m %1 %2 %3'
	    % { mode printString: 8. self. File name: dest }) displayNl
    ]
]

Directory extend [
    emitMkdir [
	('cmd . \$mkdir_p %1' % { self }) displayNl
    ]
]

Object subclass: Command [
    | packages installDir dryRun copy allFiles |

    validateDestDir: destdir installDir: instDir [ 
	instDir isNil ifTrue: [ ^self ].
	((Directory name: instDir) name ~= instDir
	    and: [ destdir notEmpty ]) ifTrue: [
		self error: '--destdir used with relative target directory' ]
    ]

    destDir: destdir installDir: instDir [
	self validateDestDir: destdir installDir: instDir.
	instDir isNil
	    ifTrue: [ installDir := destdir, self defaultInstallDir ]
	    ifFalse: [ installDir := destdir, instDir ]
    ]

    defaultInstallDir [ ^Directory image ]
    installDir [ ^installDir ]

    dryRun [ ^dryRun ]
    dryRun: aBoolean [ dryRun := aBoolean ]
    copy [ ^copy ]
    copy: aBoolean [ copy := aBoolean ]
    allFiles [ ^allFiles ]
    allFiles: aBoolean [ allFiles := aBoolean ]

    packages [
	packages isNil ifTrue: [ packages := PackageFiles new ].
	^packages 
    ]

    srcdir [
	^self packages srcdir ifNil: [ '.' ]
    ]
    srcdir: aString [
	(aString = '.' or: [ (File fullNameFor: aString) = Directory working ])
	    ifTrue: [ self packages srcdir: nil ]
	    ifFalse: [ self packages srcdir: aString ]
    ]

    addAllFiles: aCollection [ self packages addAllFiles: aCollection ]

    prolog [ ]
    run [ self packages do: [ :pkg | pkg runCommand: self ] ]
    runOnStar: aStarPackage [ self runOnPackage: aStarPackage ]
    runOnPackage: aPackage [ ]

    listFiles: listFiles vpath: aBoolean [
	| base vpathBase |
	base := Directory name: self installDir.
	vpathBase := Directory name: self srcdir.

        listFiles do: [ :each || package |
	    package := self packages at: each.
	    package allFiles do: [ :file |
		| path relativePath |
		path := package findPathFor: file.
		relativePath := base pathTo: path.
		(aBoolean and: [ (relativePath indexOfSubCollection: '../') > 0 ])
		    ifTrue: [ relativePath := vpathBase pathTo: path ].

		relativePath displayNl ] ]
    ]
]

Command subclass: ShellCommand [
    emitVariable: aString default: command [
	('%1="%2"' % { aString. (Smalltalk getenv: aString) ifNil: [ command ] })
	    displayNl.
    ]

    prolog [
	('run_cmd=%<:|eval>1' % { dryRun }) displayNl.
	self emitVariable: 'INSTALL' default: 'install-sh'.
	self emitVariable: 'LN_S' default: 'ln -s'.
	self emitVariable: 'ZIP' default: 'zip'.

	stdout nextPutAll:
'case "$INSTALL" in
  */install-sh | *"/install-sh -c" | \
  */install.sh | *"/install.sh -c" | \
  install-sh | "install-sh -c" | \
  install.sh | "install.sh -c")
    display_INSTALL=install
    INSTALL=func_install
    ;;
  *)
    display_INSTALL="$INSTALL"
    ;;
esac

# Simplistic replacement for the install package, used when
# configure chose the install-sh script
func_install ()
{
  while [ $# -gt 4 ]; do
    shift
  done
  set -e
  rm -f "$4"
  cp "$3" "$4"
  chmod $2 "$4"
  set +e
}

# mkdir -p emulation based on the mkinstalldirs script.
mkdir_p ()
{
  for file
  do
    case $file in
      /*) pathcomp=/ ;;
      *)  pathcomp= ;;
    esac
    oIFS=$IFS
    IFS=/
    set fnord $file
    shift
    IFS=$oIFS

    errstatus=0
    for d
    do
      test "x$d" = x && continue
      pathcomp=$pathcomp$d
      case $pathcomp in
        -*) pathcomp=./$pathcomp ;;
      esac

      if test ! -d "$pathcomp"; then
        mkdir "$pathcomp" || lasterr=$?
        test -d "$pathcomp" || errstatus=$lasterr
      fi
      pathcomp=$pathcomp/
    done
  done
  return "$errstatus"
}

cmd () {
  (dir="$1"
  shift
  save_INSTALL=$INSTALL
  INSTALL=$display_INSTALL
  mkdir_p="mkdir -p"
  case "$dir" in
    .) eval echo "$@" ;;
    *) eval echo cd $dir \\\&\\\& "$@" ;;
  esac
  INSTALL=$save_INSTALL
  mkdir_p=mkdir_p
  eval cd "$dir"
  $run_cmd "$@")
}

mkdtemp () {
  # Create a temporary directory $tmp in $TMPDIR (default /tmp).
  # Use mktemp if possible; otherwise fall back on mkdir,
  # with $RANDOM to make collisions less likely.
  : ${TMPDIR=/tmp}

  for i in 1 2 3 4 5 6 7 8 9 10; do
    if test $i = 1 && test "$run_cmd" != :; then
      tmp=`(umask 077 && mktemp -d "$TMPDIR/gstar-XXXXXX") 2>/dev/null`
    else
      tmp=$TMPDIR/foo$$-$RANDOM
      test "$run_cmd" != : && break
      mkdir -m700 "$tmp" 2>/dev/null
    fi
    result=$?
    test -n "$tmp" && test -d "$tmp" && break
    test $i = 10 && exit $?
  done
  trap "rm -rf \"\$tmp\"" 0 1 2 3 15
  echo "mkdir -m700 \"$tmp\""
}

set -e
'.
    ]
]

ShellCommand subclass: PkgDist [
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
	    srcdir := Directory append: (File pathFor: each) to: self srcdir.
	    autoconfName := destName, '.in'.
	    ((Directory name: srcdir) includes: autoconfName)
		ifFalse: [
		    self distribute: (File name: each)
			as: destName
			in: nil ] ]
    ]

    distribute: srcFile as: file in: dir [
	| destName baseDir |
	baseDir := self installDir.
	dir isNil ifFalse: [
	    baseDir := Directory append: dir to: baseDir ].
	destName := Directory append: file to: baseDir.
	copy
	    ifTrue: [ srcFile emitInstall: destName ]
	    ifFalse: [ srcFile emitSymlink: destName ]
    ]

    runOnPackage: aPackage [
	| dirs files baseDir |
	files := allFiles
	    ifTrue: [ aPackage allFiles ]
	    ifFalse: [ aPackage allDistFiles ].

        dirs := files collect: [ :file | File pathFor: file ].
	dirs := dirs asSet asOrderedCollection.

	aPackage relativeDirectory isNil ifFalse: [
	    dirs := dirs collect: [ :dir |
		Directory append: dir to: aPackage relativeDirectory ] ].

        dirs do: [ :dir || destName |
	    destName := Directory append: dir to: self installDir.
	    (Directory name: destName) emitMkdir ].

        files do: [ :file || srcFile destName |
	    srcFile := File name: (aPackage findPathFor: file).
	    self distribute: srcFile as: file in: aPackage relativeDirectory ]
    ]
    runOnStar: aPackage [
	self error: 'cannot distribute sources from .star file'
    ]
]

ShellCommand subclass: PkgInstall [
    run [
        "Create the installation directory."
        (Directory name: self installDir) emitMkdir.
	super run.
    ]

    runOnPackage: aPackage [
	| pkg destFile dirs files baseDir |
        'mkdtemp' displayNl.
	baseDir := '\"\$tmp\"/%1' % { aPackage name }.
	pkg := aPackage copy.
	pkg relativeDirectory: nil.

	('cmd . \$mkdir_p ', baseDir) displayNl.
	('$run_cmd cat \> %1/package.xml << ''__<EOF>__''
%2
__<EOF>__' % { baseDir. pkg }) displayNl.

	files := pkg allFiles.
        dirs := files collect: [ :file | File pathFor: file ].
	dirs asSet asSortedCollection do: [ :dir |
	    ('cmd . \$mkdir_p %1/%2' % { baseDir. dir }) displayNl ].

        files do: [ :file || srcFile destName |
	    srcFile := File name: (aPackage findPathFor: file).
	    ('cmd . \$LN_S -f %1 %2/%3' % { srcFile. baseDir. file }) displayNl ].

	destFile := Directory append: aPackage name, '.star' to: self installDir.
	(File name: destFile) emitZipDir: baseDir.
    ]

    runOnStar: aPackage [
	| destFile |
	destFile := Directory append: aPackage name, '.star' to: self installDir.
	(File name: aPackage starFileName) emitInstall: destFile.
    ]
]

ShellCommand subclass: PkgUninstall [
    run [
        super run.
        packages filesDo: [ :each | (File name: each) emitRemove ]
    ]

    runOnPackage: aPackage [
	| baseDir |
	baseDir := self installDir.
	aPackage relativeDirectory isNil
	    ifFalse: [ baseDir := Directory append: aPackage relativeDirectory to: baseDir ].
	aPackage allFiles do: [ :file || destName |
	    destName := (Directory append: file to: baseDir).
	    (File name: destName) emitRemove ]
    ]

    runOnStar: aPackage [ ]
]

Command subclass: PkgList [
    validateDestDir: destdir installDir: installDir [ ]
]

PkgList subclass: PkgPackageList [
    runOnPackage: aPackage [ aPackage name displayNl ]
]

| srcdir installDir mode listFiles destdir packageFiles helpString dryRun vpath |

mode := PkgInstall.
listFiles := OrderedCollection new.
installDir := nil.
destdir := ''.
srcdir := nil.
packageFiles := OrderedCollection new.
packages := PackageFiles new.
vpath := false.
dryRun := false.
allFiles := false.
copy := false.

helpString := 
'Usage:
    gst-package [OPTION]... FILES...

    -n, --dry-run               print commands rather than running them
	--test                  run unit tests after merging
	--load                  also load the Smalltalk files in the image
        --uninstall             remove the packages mentioned in the FILES
        --dist                  copy files instead of creating STAR files.
        --list-files PKG        just output the list of files in the package
        --list-packages         just output the list of packages in the files
	--srcdir DIR            look for non-built files in directory DIR
	--distdir DIR	        for --dist, place files in directory DIR
	--destdir DIR	        prefix the destination directory with DIR
        --target-directory DIR  install the files in DIR (unused for --dist)

	--help                  display this message and exit
	--version               print version information and exit

--list-files suboptions:
	--vpath			Omit path to srcdir for files that are there

--dist suboptions:
        --all-files             Process all files, not just non-built ones
        --copy                  Do not create symbolic links

Except in uninstall and list files mode, gst-package requires write
access to the GNU Smalltalk image directory, and merges the XML package
files on the command line with that file.

The default target directory is $install_dir.'.

[
    Smalltalk
        "--load and --image-file are processed by gst-package.
	 --no-load present for backwards compatibility, it is now the default.
	 --no-install is also present for backwards compatibility."
        arguments: '-h|--help --no-load --load --no-install --uninstall
            --dist -t|--target-directory: --list-files: --list-packages
            --srcdir: --distdir|--destdir: -n|--dry-run --all-files
	    --vpath --copy -I|--image-file:'

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
            opt = 'dry-run' ifTrue: [ dryRun := true ].
            opt = 'all-files' ifTrue: [ allFiles := true ].
            opt = 'copy' ifTrue: [ copy := true ].
            opt = 'vpath' ifTrue: [ vpath := true ].

            opt isNil ifTrue: [ packageFiles add: arg ] ]
        ifError: [
            helpString displayOn: stderr.
            ObjectMemory quit: 1 ].

    "Validate the installation and source directory."
    mode new
        destDir: destdir installDir: installDir;
	srcdir: srcdir;
	addAllFiles: packageFiles;
	dryRun: dryRun;
	allFiles: allFiles;
	copy: copy;
	prolog;
	run;
	listFiles: listFiles vpath: vpath
]
    on: Error
    do: [ :ex |
	('gst-package: ', ex messageText, '
') displayOn: stderr.
	"ex pass." ObjectMemory quit: 1 ].
