#!/usr/bin/env gst
"
PackageBuilder.st
by Stefan Schmiedl
with ideas from Nico and Gwen

usage:
PackageBuilder new
  name: 'Iliad-Core';
  namespace: 'Iliad';
  prereq: 'Sport';
  prereq: 'Iconv';
  ...
  testBuilder: (TestBuilder on: 'Tests' withExtension: '.st');
  filein: 'Utilities/IliadObject.st';
  filein: 'Utilities/Support.st';
  ...
  buildXml
"

Object subclass: Indenter [
  <comment: 'Decorate a WriteStream with indenting methods.'>
  |stream indent indentString|

  Indenter class >> on: aStream [ 
    <category: 'instance creation'>
    <comment: 'Answer a new indenter writing to aStream.'>
    ^ self new on: aStream
  ]

  on: aStream  [
    <category: 'initialization'>
    <comment: 'A new indenter starts with no indentation.'>
    stream := aStream.
    indent := ''.
    indentString := '  '
  ]

  indent [
    <category: 'indenting'>
    <comment: 'Write indent to stream. This assumes that stream is currently at the start of a new line.'>
    stream nextPutAll: indent
  ]

  indentMore [
    <category: 'indenting'>
    <comment: 'Increase indentation, see indentLess.'>
    indent := indent , indentString
  ]

  indentLess [ 
    <category: 'indenting'>
    <comment: 'Decrease indentation, see indentMore.'>
    ( indent size < indentString size )
      ifTrue: [ indent := '' ]
      ifFalse: [ 
        indent := indent allButLast: indentString size
      ]
  ]

  nextPutAll: aString [
    <category: 'streaming'>
    stream nextPutAll: aString
  ]

  nextPut: aChar [
    <category: 'streaming'>
    stream nextPut: aChar
  ]

  tag: aString [ 
    <category: 'xml-printing'>
    <comment: 'Write <aString> to stream.'>
    stream nextPut: $<; nextPutAll: aString; nextPut: $>
  ]

  indentNl: aBlock [
    <category: 'printing'>
    <comment: 'Basically printNl with indent. aBlock can use stream as parameter.'>
    self indent.
    aBlock cull: stream.
    stream nl
  ]

  wrap: aString do: aBlock [
    <category: 'xml-printing'>
    <comment: 'Write opening and closing tags on separate lines, use increased indentation in between.'>
    self indentNl: [ self tag: aString ].
    self indentMore.
    aBlock value.
    self indentLess.
    self indentNl: [ self tag: '/',aString ].
  ]

  wrap: aString around: contentString [ 
    <category: 'xml-printing'>
    <comment: 'Write opening and closing tags on the same line as the contentString.'>
    contentString ifNotNil: [
	self indentNl: [ :aStream |
	self
	    tag: aString; 
	    nextPutAll: contentString; 
	    tag: '/',aString]]
  ]

  wrap: aString aroundEachOf: aCollection [
    <category: 'xml-printing'>
    <comment: 'Wrap tag aString around each element of aCollection.'>
    aCollection do: [ :item | self wrap: aString around: item ]
  ]
]


Object subclass: TestBuilder [ 
  <comment: 'A testbuilder scrounges the filesystem for smalltalk files and test cases and writes the gathered data in a format suitable for use in package.xml.'>
  | testroot pattern namespace |

  testroot [
    <category: 'accessing'>
    ^ testroot
  ]
  testroot: aString [
    <category: 'accessing'>
    testroot := File name: aString
  ]
  pattern [
    <category: 'accessing'>
    ^ pattern
  ]
  pattern: aString [
    <category: 'accessing'>
    pattern := aString
  ]
  namespace [
    <category: 'accessing'>
    ^ namespace
  ]
  namespace: aString [
    <category: 'accessing'>
    namespace := aString
  ]

  collectFiles [
    <category: 'accessing'>
    <comment: 'Answer a list of files below the testroot directory matching the specified filename pattern.'>
    |files|
    files := OrderedCollection new.
    ( self testroot ) allFilesMatching: self pattern do: [ :f |
      files add: f
    ].
    ^ files
  ]

  collectTestsIn: aCollection [ 
    <category: 'accessing'>
    <comment: 'Answer a list of class names highly suspect of being used in SUnit.'>
    |tests|
    tests := OrderedCollection new.
    aCollection do: [ :file |
      file contents onOccurrencesOfRegex: 'subclass: (.*Test)' do: [ :rr |
        tests add: ( rr at: 1 )
      ]
    ].
    ^ tests
  ]

  renderTests: aCollection on: aStream [
    <category: 'accessing'>
    <comment: 'Write test class names with package namespace.'>
    aStream wrap: 'sunit' do: [ 
      aCollection do: [ :tc |
        aStream indentNl: [ 
          aStream 
            nextPutAll: self namespace;
            nextPut: $.;
            nextPutAll: tc
        ]
      ]
    ]
  ]

  renderXmlOn: aStream [ 
    <category: 'accessing'>
    <comment: 'Write the test subpackage specification to aStream.'>
    aStream wrap: 'test' do: [ |files tests paths|
      files := self collectFiles.
      tests := self collectTestsIn: files.
      paths := files collect: [ :f | self testroot parent pathTo: f ].
      aStream wrap: 'filein' aroundEachOf: paths.
      aStream wrap: 'file' aroundEachOf: paths.
      self renderTests: tests on: aStream.
    ]
  ]
]


Object subclass: PackageBuilder [
  |name url namespace prereqs provides testBuilder start fileins resources|

  PackageBuilder class >> new [
    ^ self basicNew initialize
  ]

  initialize [
    prereqs := OrderedCollection new.
    provides := OrderedCollection new.
    fileins := OrderedCollection new.
    resources := OrderedCollection new.
  ]

  name [
    <category: 'accessing'>
    ^ name
  ]
  name: aString [
    <category: 'accessing'>
    name := aString
  ]
  url [
    <category: 'accessing'>
    ^ url
  ]
  url: aString [
    <category: 'accessing'>
    url := aString
  ]
  namespace [
    <category: 'accessing'>
    ^ namespace
  ]
  namespace: aString [
    <category: 'accessing'>
    namespace := aString
  ]
  prereqs [
    <category: 'accessing'>
    ^ prereqs
  ]
  prereq: aString [
    <category: 'accessing'>
    prereqs add: aString
  ]
  provides [
    <category: 'accessing'>
    ^ provides
  ]
  provides: aString [
    <category: 'accessing'>
    provides add: aString
  ]
  start [
    <category: 'accessing'>
    ^ start
  ]
  start: aString [
    <category: 'accessing'>
    start := aString
  ]
  fileins [
    <category: 'accessing'>
    ^ fileins
  ]
  filein: aString [
    <category: 'accessing'>
    fileins add: aString
  ]

  resource: aString [
    <category: 'accessing'>
    resources add: aString
  ]

  testsBelow: aDirname matching: aPattern [ 
    <category: 'accessing'>
    <comment: 'Make a testbuilder for the given specs.'>
    testBuilder := 
      TestBuilder new
        testroot: aDirname;
        pattern: aPattern;
        namespace: self namespace.
  ]

  renderXmlOn: aStream [
    <category: 'xml-printing'>
    <comment: 'Write a representation to aStream suitable for use in package.xml.'>
    aStream wrap: 'package' do: [ 
      aStream 
        wrap: 'name' around: self name;
        wrap: 'url' around: self url;
        wrap: 'namespace' around: self namespace.
      self prereqs do: [ :p | aStream wrap: 'prereq' around: p ].
      self provides do: [ :p | aStream wrap: 'provides' around: p ].
      testBuilder ifNotNil: [ testBuilder renderXmlOn: aStream ].
      aStream wrap: 'filein' aroundEachOf: fileins.
      aStream wrap: 'file' aroundEachOf: fileins.
      aStream wrap: 'file' aroundEachOf: resources.
      aStream wrap: 'start' around: start.
    ]
  ]

  buildXml [
    <category: 'xml-printing'>
    <comment: 'This convenience method writes the xml package spec to stdout.'>
    self renderXmlOn: ( Indenter on: FileStream stdout )
  ]

]


Eval [
  Smalltalk arguments do: [ :filename | FileStream fileIn: filename ]
]
