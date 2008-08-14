String extend [

    matches: aString [
	<category: '*magritte-model-testing'>
	aString isEmpty ifTrue: [^true].
	^(aString includesAnyOf: '*#') 
	    ifTrue: [aString match: self]
	    ifFalse: [self includesSubstring: aString caseSensitive: false]
    ]

]



Error subclass: MAError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I represent a generic Magritte error.'>

    displayString [
	<category: 'printing'>
	^self printString
    ]
]



MAError subclass: MAPropertyError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: nil>
]



MAError subclass: MAReadError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that gets raised when there is problem reading serialized data.'>
]



MAError subclass: MAValidationError [
    | resumable |
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am a generic validation error. I reference the description that caused the validation error.'>

    MAValidationError class >> description: aDescription signal: aString [
	<category: 'instance-creation'>
	^(self new)
	    setDescription: aDescription;
	    signal: aString;
	    yourself
    ]

    beResumable [
	<category: 'accessing'>
	resumable := true
    ]

    isResumable [
	<category: 'testing'>
	^resumable
    ]

    printOn: aStream [
	<category: 'printing'>
	(self tag isDescription and: [self tag label notNil]) 
	    ifTrue: 
		[aStream
		    nextPutAll: self tag label;
		    nextPutAll: ': '].
	aStream nextPutAll: self messageText
    ]

    setDescription: aDescription [
	<category: 'initialization'>
	self tag: aDescription.
	resumable := false
    ]
]



MAValidationError subclass: MAConditionError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a user-defined condition is failing.'>
]



MAValidationError subclass: MAConflictError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever there is an edit conflict.'>
]



MAValidationError subclass: MAKindError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a description is applied to the wrong type of data.'>
]



MAValidationError subclass: MAMultipleErrors [
    | collection |
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever there are multiple validation rules failing.'>

    MAMultipleErrors class >> description: aDescription errors: aCollection signal: aString [
	<category: 'instance-creation'>
	^(self new)
	    setDescription: aDescription;
	    setCollection: aCollection;
	    signal: aString;
	    yourself
    ]

    collection [
	<category: 'accessing'>
	^collection
    ]

    printOn: aStream [
	<category: 'printing'>
	self collection do: [:each | aStream print: each]
	    separatedBy: [aStream nextPut: Character nl]
    ]

    setCollection: aCollection [
	<category: 'initialization'>
	collection := aCollection
    ]
]



MAValidationError subclass: MARangeError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a described value is out of bounds.'>
]



MAValidationError subclass: MARequiredError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a required value is not supplied.'>
]



MAError subclass: MAWriteError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that gets raised when there is problem writing serialized data.'>
]



nil subclass: MAProxyObject [
    | realSubject |
    
    <comment: 'I represent an abstract proxy object, to be refined by my subclasses.'>
    <category: 'Magritte-Model-Utility'>

    MAProxyObject class >> on: anObject [
	<category: 'instance creation'>
	^self basicNew realSubject: anObject
    ]

    copy [
	"It doesn't make sense to copy proxies in most cases, the real-subject needs to be looked up and will probably return a new instance on every call anyway."

	<category: 'copying'>
	^self
    ]

    doesNotUnderstand: aMessage [
	<category: 'private'>
	^self realSubject perform: aMessage selector
	    withArguments: aMessage arguments
    ]

    isMorph [
	"Answer ==false==, since I am no morph. Squeak is calling this method after image-startup and might lock if I do not answer to this message."

	<category: 'private'>
	^false
    ]

    isNil [
	"This method is required to properly return ==true== if the ==realSubject== is ==nil==."

	<category: 'testing'>
	^self realSubject isNil
    ]

    printOn: aStream [
	"Print the receiver on ==aStream== but within square-brackets to show that it is a proxied instance."

	<category: 'printing'>
	aStream
	    nextPut: $[;
	    print: self realSubject;
	    nextPut: $]
    ]

    printString [
	<category: 'printing'>
	^String streamContents: [:stream | self printOn: stream]
    ]

    realSubject [
	<category: 'accessing'>
	^realSubject
    ]

    realSubject: anObject [
	<category: 'accessing'>
	realSubject := anObject
    ]
]



MAProxyObject subclass: MADynamicObject [
    
    <comment: 'A dynamic object can be used for almost any property within Magritte that is not static but calculated dynamically. This is a shortcut to avoid having to build context sensitive descriptions manually over and over again, however there are a few drawbacks: 

- Some messages sent to this proxy, for example ==#class== and ==#value==, might not get resolved properly.
- Raising an unhandled exception will not always open a debugger on your proxy, because tools are unable to properly work with the invalid object and might even crash your image.'>
    <category: 'Magritte-Model-Utility'>

    realSubject [
	<category: 'accessing'>
	^super realSubject on: SystemExceptions.UnhandledException do: [:err | nil]
    ]
]



ArrayedCollection extend [

    copyWithAll: aCollection [
	<category: '*magritte-model'>
	^(self species new: self size + aCollection size)
	    replaceFrom: 1
		to: self size
		with: self
		startingAt: 1;
	    replaceFrom: self size + 1
		to: self size + aCollection size
		with: aCollection
		startingAt: 1;
	    yourself
    ]

]



Class extend [

    descriptionContainer [
	"Return the default description container."

	<category: '*magritte-model-configuration'>
	^(Magritte.MAPriorityContainer new)
	    label: self label;
	    yourself
    ]

    label [
	"Answer a human-readable name of the receiving class. This implementation tries to be smart and return a nice label, unfortunately for a lot of classes this doesn't work well so subclasses might want to override this method and return soemthing more meaningfull to end-users."

	<category: '*magritte-model-accessing'>
	| start input |
	start := self name findFirst: [:each | each isLowercase].
	input := (self name copyFrom: (1 max: start - 1) to: self name size) 
		    readStream.
	^String streamContents: 
		[:stream | 
		[input atEnd] whileFalse: 
			[stream nextPut: input next.
			(input atEnd or: [input peek isLowercase]) 
			    ifFalse: [stream nextPut: Character space]]]
    ]

]



Collection extend [

    asMultilineString [
	<category: '*magritte-model'>
	^String streamContents: 
		[:stream | 
		self do: [:each | stream nextPutAll: each]
		    separatedBy: [stream nextPut: Character nl]]
    ]

    copyWithAll: aCollection [
	<category: '*magritte-model'>
	^(self copy)
	    addAll: aCollection;
	    yourself
    ]

    copyWithoutFirst: anObject [
	<category: '*magritte-model'>
	| done |
	done := false.
	^self 
	    reject: [:each | (each = anObject and: [done not]) and: [done := true]]
    ]

]



BlockClosure extend [

    asDynamicObject [
	"Answer an object that will automatically evaluate the receiver when it receives a message. It will eventually pass the message to the resulting object. Use with caution, for details see *MADynamicObject*."

	<category: '*magritte-model'>
	^Magritte.MADynamicObject on: self
    ]

]



SequenceableCollection extend [

    asAccessor [
	<category: '*magritte-model'>
	^Magritte.MAChainAccessor accessors: self
    ]

    moveDown: anObject [
	<category: '*magritte-model'>
	| first second |
	first := self identityIndexOf: anObject ifAbsent: [^0].
	second := first < self size ifTrue: [first + 1] ifFalse: [^first].
	self swap: first with: second.
	^second
    ]

    moveUp: anObject [
	<category: '*magritte-model'>
	| first second |
	first := self identityIndexOf: anObject ifAbsent: [^0].
	second := first > 1 ifTrue: [first - 1] ifFalse: [^first].
	self swap: first with: second.
	^second
    ]

    reduce: aBlock [
       <category: '*magritte-model'>
       | result |
       self isEmpty ifTrue: [^nil].
       result := self first.
       2 to: self size
           do: [:index | result := aBlock value: result value: (self at: index)].
       ^result
    ]

]



Symbol extend [

    asAccessor [
	<category: '*magritte-model-converting'>
	^Magritte.MASelectorAccessor selector: self
    ]

    isDescriptionDefinition [
	"Answer wheter the receiver is a method selector following the naming conventions of a description definition."

	<category: '*magritte-model-testing'>
	^self isDescriptionSelector and: [self isUnary]
    ]

    isDescriptionExtension: aSelector [
	"Answer wheter the receiver is a method selector following the naming conventions of a description extension to aSelector."

	<category: '*magritte-model-testing'>
	^self isDescriptionSelector 
	    and: [self numArgs = 1 and: [self startsWith: aSelector]]
    ]

    isDescriptionSelector [
	"Answer wheter the receiver is a method selector following the naming conventions of a  description selector."

	<category: '*magritte-model-testing'>
	^self ~= #description and: [self startsWith: #description]
    ]

]



Object subclass: MAAdaptiveModel [
    | description values |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I am an adaptive model referencing a dynamic description of myself and a dictionary mapping those descriptions to actual values.'>

    MAAdaptiveModel class >> description: aDescription [
	<category: 'instance creation'>
	^(self new)
	    description: aDescription;
	    yourself
    ]

    MAAdaptiveModel class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    defaultDescription [
	<category: 'accessing-configuration'>
	^MAContainer new
    ]

    defaultDictionary [
	<category: 'accessing-configuration'>
	^Dictionary new
    ]

    description [
	"Answer the description of the receiver."

	<category: 'accessing'>
	^description
    ]

    description: aDescription [
	<category: 'accessing'>
	description := aDescription
    ]

    initialize [
	<category: 'initialization'>
	self description: self defaultDescription.
	self values: self defaultDictionary
    ]

    readUsing: aDescription [
	"Answer the actual value of ==aDescription== within the receiver, ==nil== if not present."

	<category: 'model'>
	^self values at: aDescription ifAbsent: [nil]
    ]

    values [
	"Answer a dictionary mapping description to actual values."

	<category: 'accessing'>
	^values
    ]

    values: aDictionary [
	<category: 'accessing'>
	values := aDictionary
    ]

    write: anObject using: aDescription [
	"Set ==anObject== to be that actual value of the receiver for ==aDescription==."

	<category: 'model'>
	self values at: aDescription put: anObject
    ]
]



Object subclass: MADescriptionBuilder [
    | cache |
    
    <category: 'Magritte-Model-Utility'>
    <comment: nil>

    Default := nil.

    MADescriptionBuilder class >> default [
	<category: 'accessing'>
	^Default
    ]

    MADescriptionBuilder class >> default: aBuilder [
	<category: 'accessing'>
	Default := aBuilder
    ]

    MADescriptionBuilder class >> for: anObject [
	<category: 'building'>
	^self default for: anObject
    ]

    MADescriptionBuilder class >> initialize [
	<category: 'initialization'>
	self default: MANamedBuilder new
    ]

    MADescriptionBuilder class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    build: anObject [
	<category: 'private'>
	self subclassResponsibility
    ]

    finalize [
	<category: 'initialization'>
	super finalize.
	self flush
    ]

    flush [
	<category: 'actions'>
	cache := IdentityDictionary new
    ]

    for: anObject [
	<category: 'accessing'>
	^cache at: anObject ifAbsentPut: [self build: anObject]
    ]

    initialize [
	<category: 'initialization'>
	self flush
    ]
]



MADescriptionBuilder subclass: MANamedBuilder [
    
    <category: 'Magritte-Model-Utility'>
    <comment: 'I dynamically build container descriptions from class-side methods using a simple naming convention for the selector names:

# The method ==#defaultContainer== is called to retrieve the container instance.
# All the unary methods starting with the selector ==#description== are called and should return a valid description to be added to the container.
# All the keyword messages with one argument having a prefix of a method selected in step 2 will be called with the original description to further refine its definition.'>

    build: anObject [
	<category: 'private'>
	| selectors container description |
	selectors := anObject class allSelectors 
		    select: [:each | each isDescriptionSelector].
	container := self 
		    build: anObject
		    for: self containerSelector
		    in: selectors.
	^(selectors select: [:each | each isDescriptionDefinition]) 
	    inject: (cache at: anObject put: container)
	    into: 
		[:result :each | 
		self containerSelector = each 
		    ifFalse: 
			[description := self 
				    build: anObject
				    for: each
				    in: selectors.
			description isDescription ifTrue: [result add: description]].
		result]
    ]

    build: anObject for: aSelector in: aCollection [
	<category: 'private'>
	^(aCollection select: [:each | each isDescriptionExtension: aSelector]) 
	    inject: (anObject perform: aSelector)
	    into: [:result :each | anObject perform: each with: result]
    ]

    containerSelector [
	<category: 'configuration'>
	^#descriptionContainer
    ]
]



Object subclass: MAFileModel [
    | filename mimetype filesize |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I represent a file with filename, mimetype and contents within the Magritte framework.

There are different file-models that you can use with Magritte. The idea is that you set the ==#kind:== of an MAFileDescription to one of the subclasses of ==*MAFileModel*==.'>

    MimeTypes := nil.

    MAFileModel class >> defaultMimeType [
	<category: 'accessing-defaults'>
	^'application/octet-stream'
    ]

    MAFileModel class >> defaultMimeTypes [
	<category: 'accessing-defaults'>
	^#('ai' 'application/postscript' 'aif' 'audio/x-aiff' 'aifc' 'audio/x-aiff' 'aiff' 'audio/x-aiff' 'asc' 'text/plain' 'au' 'audio/basic' 'avi' 'video/x-msvideo' 'bcpio' 'application/x-bcpio' 'bin' 'application/octet-stream' 'c' 'text/plain' 'cc' 'text/plain' 'ccad' 'application/clariscad' 'cdf' 'application/x-netcdf' 'class' 'application/octet-stream' 'cpio' 'application/x-cpio' 'cpt' 'application/mac-compactpro' 'csh' 'application/x-csh' 'css' 'text/css' 'dcr' 'application/x-director' 'dir' 'application/x-director' 'dms' 'application/octet-stream' 'doc' 'application/msword' 'drw' 'application/drafting' 'dvi' 'application/x-dvi' 'dwg' 'application/acad' 'dxf' 'application/dxf' 'dxr' 'application/x-director' 'eps' 'application/postscript' 'etx' 'text/x-setext' 'exe' 'application/octet-stream' 'ez' 'application/andrew-inset' 'f' 'text/plain' 'f90' 'text/plain' 'fli' 'video/x-fli' 'gif' 'image/gif' 'gtar' 'application/x-gtar' 'gz' 'application/x-gzip' 'h' 'text/plain' 'hdf' 'application/x-hdf' 'hh' 'text/plain' 'hqx' 'application/mac-binhex40' 'htm' 'text/html' 'html' 'text/html' 'ice' 'x-conference/x-cooltalk' 'ief' 'image/ief' 'iges' 'model/iges' 'igs' 'model/iges' 'ips' 'application/x-ipscript' 'ipx' 'application/x-ipix' 'jpe' 'image/jpeg' 'jpeg' 'image/jpeg' 'jpg' 'image/jpeg' 'js' 'application/x-javascript' 'kar' 'audio/midi' 'latex' 'application/x-latex' 'lha' 'application/octet-stream' 'lsp' 'application/x-lisp' 'lzh' 'application/octet-stream' 'm' 'text/plain' 'man' 'application/x-troff-man' 'me' 'application/x-troff-me' 'mesh' 'model/mesh' 'mid' 'audio/midi' 'midi' 'audio/midi' 'mif' 'application/vnd.mif' 'mime' 'www/mime' 'mov' 'video/quicktime' 'movie' 'video/x-sgi-movie' 'mp2' 'audio/mpeg' 'mp3' 'audio/mpeg' 'mpe' 'video/mpeg' 'mpeg' 'video/mpeg' 'mpg' 'video/mpeg' 'mpga' 'audio/mpeg' 'ms' 'application/x-troff-ms' 'msh' 'model/mesh' 'nc' 'application/x-netcdf' 'oda' 'application/oda' 'pbm' 'image/x-portable-bitmap' 'pdb' 'chemical/x-pdb' 'pdf' 'application/pdf' 'pgm' 'image/x-portable-graymap' 'pgn' 'application/x-chess-pgn' 'png' 'image/png' 'pnm' 'image/x-portable-anymap' 'pot' 'application/mspowerpoint' 'ppm' 'image/x-portable-pixmap' 'pps' 'application/mspowerpoint' 'ppt' 'application/mspowerpoint' 'ppz' 'application/mspowerpoint' 'pre' 'application/x-freelance' 'prt' 'application/pro_eng' 'ps' 'application/postscript' 'qt' 'video/quicktime' 'ra' 'audio/x-realaudio' 'ram' 'audio/x-pn-realaudio' 'ras' 'image/cmu-raster' 'rgb' 'image/x-rgb' 'rm' 'audio/x-pn-realaudio' 'roff' 'application/x-troff' 'rpm' 'audio/x-pn-realaudio-plugin' 'rtf' 'text/rtf' 'rtx' 'text/richtext' 'scm' 'application/x-lotusscreencam' 'set' 'application/set' 'sgm' 'text/sgml' 'sgml' 'text/sgml' 'sh' 'application/x-sh' 'shar' 'application/x-shar' 'silo' 'model/mesh' 'sit' 'application/x-stuffit' 'skd' 'application/x-koan' 'skm' 'application/x-koan' 'skp' 'application/x-koan' 'skt' 'application/x-koan' 'smi' 'application/smil' 'smil' 'application/smil' 'snd' 'audio/basic' 'sol' 'application/solids' 'spl' 'application/x-futuresplash' 'src' 'application/x-wais-source' 'step' 'application/STEP' 'stl' 'application/SLA' 'stp' 'application/STEP' 'sv4cpio' 'application/x-sv4cpio' 'sv4crc' 'application/x-sv4crc' 'swf' 'application/x-shockwave-flash' 't' 'application/x-troff' 'tar' 'application/x-tar' 'tcl' 'application/x-tcl' 'tex' 'application/x-tex' 'texi' 'application/x-texinfo' 'texinfo' 'application/x-texinfo' 'tif' 'image/tiff' 'tiff' 'image/tiff' 'tr' 'application/x-troff' 'tsi' 'audio/TSP-audio' 'tsp' 'application/dsptype' 'tsv' 'text/tab-separated-values' 'txt' 'text/plain' 'unv' 'application/i-deas' 'ustar' 'application/x-ustar' 'vcd' 'application/x-cdlink' 'vda' 'application/vda' 'viv' 'video/vnd.vivo' 'vivo' 'video/vnd.vivo' 'vrml' 'model/vrml' 'wav' 'audio/x-wav' 'wrl' 'model/vrml' 'xbm' 'image/x-xbitmap' 'xlc' 'application/vnd.ms-excel' 'xll' 'application/vnd.ms-excel' 'xlm' 'application/vnd.ms-excel' 'xls' 'application/vnd.ms-excel' 'xlw' 'application/vnd.ms-excel' 'xml' 'text/xml' 'xpm' 'image/x-xpixmap' 'xwd' 'image/x-xwindowdump' 'xyz' 'chemical/x-pdb' 'zip' 'application/zip')
    ]

    MAFileModel class >> initialize [
	<category: 'initialization'>
	MimeTypes := Dictionary new.
	1 to: self defaultMimeTypes size
	    by: 2
	    do: 
		[:index | 
		MimeTypes at: (self defaultMimeTypes at: index)
		    put: (self defaultMimeTypes at: index + 1)]
    ]

    MAFileModel class >> mimetypeFor: aString [
	<category: 'accessing'>
	^self mimetypes at: aString ifAbsent: [self defaultMimeType]
    ]

    MAFileModel class >> mimetypes [
	<category: 'accessing'>
	^MimeTypes
    ]

    MAFileModel class >> new [
	<category: 'instance-creation'>
	^self basicNew initialize
    ]

    = anObject [
	<category: 'comparing'>
	^self species = anObject species and: 
		[self filename = anObject filename and: [self mimetype = anObject mimetype]]
    ]

    contents [
	"Answer the contents of the file. This method is supposed to be overridden by concrete subclasses."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    contents: aByteArray [
	"Set the contents of the receiver. This method is supposed to be overridden by concrete subclasses."

	<category: 'accessing'>
	filesize := aByteArray size
    ]

    extension [
	"Answer the file-extension."

	<category: 'accessing-dynamic'>
	^self filename copyAfterLast: $.
    ]

    filename [
	"Answer the filename of the receiver."

	<category: 'accessing'>
	^filename
    ]

    filename: aString [
	<category: 'accessing'>
	filename := aString
    ]

    filesize [
	"Answer the size of the file."

	<category: 'accessing-dynamic'>
	^filesize
    ]

    finalize [
	"Cleanup after a file is removed, subclasses might require to specialize this method."

	<category: 'initialization'>
	self initialize
    ]

    hash [
	<category: 'comparing'>
	^self filename hash bitXor: self mimetype hash
    ]

    initialize [
	<category: 'initialization'>
	filesize := 0.
	filename := 'unknown'.
	mimetype := self class defaultMimeType
    ]

    isApplication [
	"Return ==true== if the mimetype of the receiver is application-data. This message will match types like: application/postscript, application/zip, application/pdf, etc."

	<category: 'testing-types'>
	^self maintype = 'application'
    ]

    isAudio [
	"Return ==true== if the mimetype of the receiver is audio-data. This message will match types like: audio/basic, audio/tone, audio/mpeg, etc."

	<category: 'testing-types'>
	^self maintype = 'audio'
    ]

    isEmpty [
	<category: 'testing'>
	^self filesize = 0
    ]

    isImage [
	"Return ==true== if the mimetype of the receiver is image-data. This message will match types like: image/jpeg, image/gif, image/png, image/tiff, etc."

	<category: 'testing-types'>
	^self maintype = 'image'
    ]

    isText [
	"Return ==true== if the mimetype of the receiver is text-data. This message will match types like: text/plain, text/html, text/sgml, text/css, text/xml, text/richtext, etc."

	<category: 'testing-types'>
	^self maintype = 'text'
    ]

    isVideo [
	"Return ==true== if the mimetype of the receiver is video-data. This message will match types like: video/mpeg, video/quicktime, etc."

	<category: 'testing-types'>
	^self maintype = 'video'
    ]

    maintype [
	"Answer the first part of the mime-type."

	<category: 'accessing-dynamic'>
	^self mimetype copyUpTo: $/
    ]

    mimetype [
	"Answer the mimetype of the receiver."

	<category: 'accessing'>
	^mimetype
    ]

    mimetype: aString [
	<category: 'accessing'>
	mimetype := aString
    ]

    subtype [
	"Answer the second part of the mime-type."

	<category: 'accessing-dynamic'>
	^self mimetype copyAfter: $/
    ]
]



MAFileModel subclass: MAExternalFileModel [
    | location |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I manage the file-data I represent on the file-system. From the programmer this looks the same as if the file would be in memory (==*MAMemoryFileModel*==), as it is transparently loaded and written out as necessary.

- The ==#baseDirectory== is the place where Magritte puts its file-database. Keep this value to nil to make it default to a subdirectory next to the Squeak image.
- The ==#baseUrl== is a nice optimization to allow Apache (or any other Web Server) to directly serve the files. ==#baseUrl== is an absolute URL-prefix that is used to generate the path to the file. If you have specified one the file data does not go trough the image anymore, but instead is directly served trough the properly configured Web Server.

The files are currently stored using the following scheme:

=/files/9d/bsy8kyp45g0q7blphknk48zujap2wd/earthmap1k.jpg
=1     2   3                              4

#Is the #baseDirectory as specified in the settings.
#Are 256 directories named ''00'' to ''ff'' to avoid having thousands of files in the same directory. Unfortunately this leads to problems with the Squeak file primitives and some filesystems don''t handle that well. This part is generated at random.
#This is a secure id, similar to the Seaside session key. It is generated at random and provides a security system that even works trough Apache (you have to disable directory listings of course): if you don''t know the file-name you cannot access the file.
#This is the original file-name. Subclasses might want to store other cached versions of the same file there, for example resized images, etc.'>

    MAExternalFileModel class [
	| baseDirectory baseUrl |
	
    ]

    MAExternalFileModel class >> baseDirectory [
	<category: 'accessing'>
	^baseDirectory ifNil: [Directory working / 'files']
    ]

    MAExternalFileModel class >> baseDirectory: aStringOrDirectory [
	"Defines the base-directory where the files are stored. If this value is set to nil, it default to a subdirectory of of the current image-location."

	<category: 'accessing'>
	baseDirectory := aStringOrDirectory isString 
		    ifTrue: [aStringOrDirectory asFile]
		    ifFalse: [aStringOrDirectory]
    ]

    MAExternalFileModel class >> baseUrl [
	<category: 'accessing'>
	^baseUrl
    ]

    MAExternalFileModel class >> baseUrl: aString [
	"Defines the base-URL where the files are served from, when using an external web server. This setting is left to nil by default, causing the files to be served trough the image."

	<category: 'accessing'>
	baseUrl := aString isNil 
		    ifFalse: 
			[aString last = $/ ifFalse: [aString] ifTrue: [aString copyUpToLast: $/]]
    ]

    MAExternalFileModel class >> initialize [
	<category: 'initialization'>
	baseDirectory := baseUrl := nil
    ]

    baseDirectory [
	<category: 'configuration'>
	^self class baseDirectory
    ]

    baseUrl [
	<category: 'configuration'>
	^self class baseUrl
    ]

    contents [
	<category: 'accessing'>
	| stream |
	^(self directory exists and: [self directory includes: self filename]) 
	    ifFalse: [ByteArray new]
	    ifTrue: 
		[stream := self readStream.
		[stream contents asByteArray] ensure: [stream close]]
    ]

    contents: aByteArray [
	<category: 'accessing'>
	| stream |
	stream := self writeStream.
	[stream nextPutAll: aByteArray asByteArray] ensure: [stream close].
	super contents: aByteArray
    ]

    directory [
	<category: 'accessing-dynamic'>
	^self location inject: self baseDirectory
	    into: [:result :each | result / each]
    ]

    finalize [
	<category: 'initialization'>
	| directory |
	directory := self directory.
	directory exists ifTrue: [directory all remove].
	"[(directory := directory parent) entries isEmpty] 
	    whileTrue: [directory all remove]."
	super finalize.
	location := nil
    ]

    location [
	<category: 'accessing-dynamic'>
	^location 
	    ifNil: [location := self uniqueLocation: self locationDefinition]
    ]

    locationDefinition [
	<category: 'configuration'>
	^#(#(2 '63450af8d9c2e17b') #(30 'iaojv41bw67e0tud5m9rgplqfy8x3cs2kznh'))
    ]

    postCopy [
	<category: 'copying'>
	| previous |
	super postCopy.
	previous := self contents.
	location := nil.
	self contents: previous
    ]

    readStream [
	<category: 'accessing-dynamic'>
	^(self directory / self filename) readStream
    ]

    uniqueLocation: aLocationDefinition [
	"Finds an unique path to be used and create the necessary sub directories."

	<category: 'private'>
	| valid result directory definition |
	valid := false.
	result := Array new: aLocationDefinition size.
	[valid] whileFalse: 
		[directory := self baseDirectory createDirectories.
		result keysAndValuesDo: 
			[:index :value | 
			definition := aLocationDefinition at: index.
			result at: index
			    put: ((String new: definition first) 
				    collect: [:each | definition second atRandom]).
			directory := directory / (result at: index).
			directory exists 
			    ifFalse: 
				[directory createDirectories.
				valid := true]]].
	^result
    ]

    writeStream [
	<category: 'accessing-dynamic'>
	^(self directory / self filename) writeStream
    ]
]



MAFileModel subclass: MAMemoryFileModel [
    | contents |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I represent a file using a ByteArray in the object memory. I am not practicable for big files: use me for development and testing only.'>

    contents [
	<category: 'accessing'>
	^contents ifNil: [contents := ByteArray new]
    ]

    contents: aByteArray [
	<category: 'accessing'>
	super contents: aByteArray.
	contents := aByteArray asByteArray
    ]

    finalize [
	<category: 'initialization'>
	super finalize.
	contents := nil
    ]
]



Object subclass: MAObject [
    | properties |
    
    <category: 'Magritte-Model-Core'>
    <comment: 'I provide functionality available to all Magritte objects. I implement a dictionary of properties, so that extensions can easily store additional data.'>

    MAObject class >> initialize [
	<category: 'initialization'>
	MACompatibility openWorkspace: self license titled: 'Magritte License'
    ]

    MAObject class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    MAObject class >> license [
	"Return a string with the license of the package. This string shall not be removed or altered in any case."

	<category: 'accessing'>
	^'The MIT License

Copyright (c) 2003-' , Date today year asString 
	    , ' Lukas Renggli, renggli at gmail.com

Copyright (c) 2003-' 
		, Date today year asString 
		, ' Software Composition Group, University of Bern, Switzerland

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
    ]

    MAObject class >> new [
	"Create a new instance of the receiving class and checks if it is concrete."

	<category: 'instance-creation'>
	self isAbstract ifTrue: [self error: self name , ' is abstract.'].
	^self basicNew initialize
    ]

    MAObject class >> withAllConcreteClasses [
	<category: 'reflection'>
	^Array streamContents: 
		[:stream | 
		self withAllConcreteClassesDo: [:each | stream nextPut: each]]
    ]

    MAObject class >> withAllConcreteClassesDo: aBlock [
	<category: 'reflection'>
	self 
	    withAllSubclassesDo: [:each | each isAbstract ifFalse: [aBlock value: each]]
    ]

    = anObject [
	"Answer whether the receiver and the argument represent the same object. This default implementation checks if the species of the compared objects are the same, so that superclasses might call super before performing their own check. Also redefine the message ==#hash== when redefining this message."

	<category: 'comparing'>
	^self species = anObject species
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	
    ]

    errorPropertyNotFound: aSelector [
	<category: 'private'>
	MAPropertyError signal: 'Property ' , aSelector , ' not found.'
    ]

    hasProperty: aKey [
	"Test if the property ==aKey== is defined within the receiver."

	<category: 'testing'>
	^self properties includesKey: aKey
    ]

    hash [
	"Answer a SmallInteger whose value is related to the receiver's identity. Also redefine the message ==#= == when redefining this message."

	<category: 'comparing'>
	^self species hash
    ]

    initialize [
	<category: 'initialization'>
	
    ]

    postCopy [
	"This method is called whenever a shallow copy of the receiver is made. Redefine this method in subclasses to copy other fields as necessary. Never forget to call super, else class invariants might be violated."

	<category: 'copying'>
	super postCopy.
	properties := properties copy
    ]

    properties [
	"Answer the property dictionary of the receiver."

	<category: 'accessing'>
	^properties ifNil: [properties := Dictionary new]
    ]

    propertyAt: aKey [
	"Answer the value of the property ==aKey==, raises an error if the property doesn't exist."

	<category: 'accessing'>
	^self propertyAt: aKey ifAbsent: [self errorPropertyNotFound: aKey]
    ]

    propertyAt: aKey ifAbsent: aBlock [
	"Answer the value of the property ==aKey==, or the result of ==aBlock== if the property doesn't exist."

	<category: 'accessing'>
	^self properties at: aKey ifAbsent: aBlock
    ]

    propertyAt: aKey ifAbsentPut: aBlock [
	"Answer the value of the property ==aKey==, or if the property doesn't exist adds and answers the result of evaluating ==aBlock==."

	<category: 'accessing'>
	^self properties at: aKey ifAbsentPut: aBlock
    ]

    propertyAt: aKey ifPresent: aBlock [
	"Lookup the property ==aKey==, if it is present, answer the value of evaluating ==aBlock== block with the value. Otherwise, answer ==nil==."

	<category: 'accessing'>
	^self properties at: aKey ifPresent: aBlock
    ]

    propertyAt: aKey put: aValue [
	"Adds or replaces the property ==aKey== with ==aValue==."

	<category: 'accessing'>
	^self properties at: aKey put: aValue
    ]
]



MAObject subclass: MAAccessor [
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am the abstract superclass to all accessor strategies. Accessors are used to implement different ways of accessing (reading and writing) data from instances using a common protocol: data can be uniformly read and written using ==#readFrom:== respectively ==#write:to:==.'>

    asAccessor [
	<category: 'converting'>
	^self
    ]

    canRead: aModel [
	"Test if ==aModel== can be read."

	<category: 'testing'>
	^false
    ]

    canWrite: aModel [
	"Test if ==aModel== can be written."

	<category: 'testing'>
	^false
    ]

    printOn: aStream [
	<category: 'printing'>
	self storeOn: aStream
    ]

    read: aModel [
	"Read from ==aModel== using the access-strategy of the receiver."

	<category: 'model'>
	^nil
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    store: self class;
	    nextPutAll: ' new'
    ]

    write: anObject to: aModel [
	"Write ==anObject== to ==aModel== using the access-strategy of the receiver."

	<category: 'model'>
	
    ]
]



MAAccessor subclass: MADelegatorAccessor [
    | next |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'My access strategy is to delegate to the next accessor. I am not that useful all by myself, but subclasses might override certain methods to intercept access.'>

    MADelegatorAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADelegatorAccessor class >> on: anAccessor [
	<category: 'instance-creation'>
	^self new next: anAccessor
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self next = anObject next]
    ]

    canRead: aModel [
	<category: 'testing'>
	^self next canRead: aModel
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self next canWrite: aModel
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self next hash
    ]

    next [
	<category: 'accessing'>
	^next
    ]

    next: anAccessor [
	<category: 'accessing'>
	next := anAccessor asAccessor
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	next := next copy
    ]

    read: aModel [
	<category: 'model'>
	^self next read: aModel
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' on: ';
	    store: self next;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	self next write: anObject to: aModel
    ]
]



MADelegatorAccessor subclass: MAChainAccessor [
    | accessor |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy used to chain two access strategies. To read and write a value the ==accessor== is performed on the given model and the result is passed into the ==next== accessor.'>

    MAChainAccessor class >> accessor: anAccessor next: aNextAccessor [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use #on:accessor: instead.'.
	^self on: anAccessor accessor: aNextAccessor
    ]

    MAChainAccessor class >> accessors: aSequenceableCollection [
	<category: 'instance-creation'>
	aSequenceableCollection isEmpty 
	    ifTrue: 
		[self error: 'Unable to create accessor sequence from empty collection.'].
	aSequenceableCollection size = 1 
	    ifTrue: [^aSequenceableCollection first asAccessor].
	^self on: aSequenceableCollection first asAccessor
	    accessor: (self accessors: aSequenceableCollection allButFirst)
    ]

    MAChainAccessor class >> on: anAccessor accessor: anotherAccessor [
	<category: 'instance-creation'>
	^(self on: anAccessor) accessor: anotherAccessor
    ]

    MAChainAccessor class >> selectors: aSequenceableCollection [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use #accessors: instead.'.
	^self accessors: aSequenceableCollection
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self accessor = anObject accessor]
    ]

    accessor [
	<category: 'accessing'>
	^accessor
    ]

    accessor: anAccessor [
	<category: 'accessing'>
	accessor := anAccessor
    ]

    canRead: aModel [
	<category: 'testing'>
	^(super canRead: aModel) 
	    and: [self accessor canRead: (self next read: aModel)]
    ]

    canWrite: aModel [
	<category: 'testing'>
	^(super canRead: aModel) 
	    and: [self accessor canWrite: (self next read: aModel)]
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self accessor hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	accessor := accessor copy
    ]

    read: aModel [
	<category: 'model'>
	^self accessor read: (super read: aModel)
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' on: ';
	    store: self next;
	    nextPutAll: ' accessor: ';
	    store: self accessor;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	self accessor write: anObject to: (super read: aModel)
    ]
]



MAAccessor subclass: MADictionaryAccessor [
    | key |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy to be used on dictionaries. I use my ==key== to read from and write to indexed collections.'>

    MADictionaryAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADictionaryAccessor class >> key: aSymbol [
	<category: 'instance-creation'>
	^(self new)
	    key: aSymbol;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self key = anObject key]
    ]

    canRead: aModel [
	<category: 'testing'>
	^true
    ]

    canWrite: aModel [
	<category: 'testing'>
	^true
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self key hash
    ]

    key [
	<category: 'accessing'>
	^key
    ]

    key: aKey [
	<category: 'accessing'>
	key := aKey
    ]

    read: aModel [
	<category: 'model'>
	^aModel at: self key ifAbsent: [nil]
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' key: ';
	    store: self key;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	aModel at: self key put: anObject
    ]
]



MAAccessor subclass: MAIdentityAccessor [
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am a read-only access strategy and I answer the model itself when being read.'>

    MAIdentityAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    canRead: aModel [
	<category: 'testing'>
	^true
    ]

    read: aModel [
	<category: 'model'>
	^aModel
    ]

    write: anObject to: aModel [
	<category: 'model'>
	MAWriteError signal: 'Not supposed to write to ' , aModel asString , '.'
    ]
]



MAAccessor subclass: MANullAccessor [
    | uuid |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am a null access strategy and I should be neither read nor written. I am still comparable to other strategies by holding onto a unique-identifier.'>

    MANullAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MANullAccessor class >> new [
	<category: 'instance-creation'>
	^self uuid: MACompatibility uuid
    ]

    MANullAccessor class >> uuid: anUUID [
	<category: 'instance-creation'>
	^(self basicNew)
	    uuid: anUUID;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self uuid = anObject uuid]
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self uuid hash
    ]

    read: aModel [
	<category: 'model'>
	MAReadError signal: 'This message is not appropriate for this object'
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' uuid: ';
	    store: self uuid;
	    nextPut: $)
    ]

    uuid [
	<category: 'accessing'>
	^uuid
    ]

    uuid: anObject [
	<category: 'accessing'>
	uuid := anObject
    ]

    write: anObject to: aModel [
	<category: 'model'>
	MAWriteError signal: 'This message is not appropriate for this object'
    ]
]



MAAccessor subclass: MAPluggableAccessor [
    | readBlock writeBlock |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy defined by two block-closures. The read-block expects the model as its first argument and is used to retrieve a value. The write-block expects the model as its first and the value as its second argument and is used to write a value to the model.'>

    MAPluggableAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAPluggableAccessor class >> read: aReadBlock write: aWriteBlock [
	<category: 'instance creation'>
	^(self new)
	    readBlock: aReadBlock;
	    writeBlock: aWriteBlock;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: 
		[self readBlock = anObject readBlock 
		    and: [self writeBlock = anObject writeBlock]]
    ]

    canRead: aModel [
	<category: 'testing'>
	^self readBlock notNil
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self writeBlock notNil
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: (self readBlock hash bitXor: self writeBlock hash)
    ]

    read: aModel [
	<category: 'model'>
	^self readBlock value: aModel
    ]

    readBlock [
	<category: 'accessing'>
	^readBlock
    ]

    readBlock: aBlock [
	<category: 'accessing'>
	readBlock := aBlock
    ]

    storeBlock: aBlock on: aStream [
	<category: 'printing'>
	aStream nextPutAll: aBlock decompile asString allButFirst allButLast
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' read: '.
	self storeBlock: self readBlock on: aStream.
	aStream nextPutAll: ' write: '.
	self storeBlock: self writeBlock on: aStream.
	aStream nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	self writeBlock value: aModel value: anObject
    ]

    writeBlock [
	<category: 'accessing'>
	^writeBlock
    ]

    writeBlock: aBlock [
	<category: 'accessing'>
	writeBlock := aBlock
    ]
]



MAAccessor subclass: MASelectorAccessor [
    | readSelector writeSelector |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am the most common access strategy defined by a read- and a write-selector. I am mostly used together with standard getters and setters as usually defined by the accessing protocol. If there is only a read-selector specified, the write selector will be deduced automatically by adding a colon to the read-selector.'>

    MASelectorAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MASelectorAccessor class >> read: aSelector [
	<category: 'instance creation'>
	^self read: aSelector write: nil
    ]

    MASelectorAccessor class >> read: aReadSelector write: aWriteSelector [
	<category: 'instance creation'>
	^(self new)
	    readSelector: aReadSelector;
	    writeSelector: aWriteSelector;
	    yourself
    ]

    MASelectorAccessor class >> selector: aSelector [
	<category: 'instance creation'>
	^(self new)
	    selector: aSelector;
	    yourself
    ]

    MASelectorAccessor class >> write: aSelector [
	<category: 'instance creation'>
	^self read: nil write: aSelector
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: 
		[self readSelector = anObject readSelector 
		    and: [self writeSelector = anObject writeSelector]]
    ]

    canRead: aModel [
	<category: 'testing'>
	^self readSelector notNil and: [aModel respondsTo: self readSelector]
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self writeSelector notNil and: [aModel respondsTo: self writeSelector]
    ]

    hash [
	<category: 'comparing'>
	^super hash 
	    bitXor: (self readSelector hash bitXor: self writeSelector hash)
    ]

    read: aModel [
	<category: 'model'>
	^aModel perform: self readSelector
    ]

    readSelector [
	<category: 'accessing'>
	^readSelector
    ]

    readSelector: aSelector [
	<category: 'accessing'>
	readSelector := aSelector
    ]

    selector [
	<category: 'accessing-dynamic'>
	^self readSelector
    ]

    selector: aSelector [
	<category: 'accessing-dynamic'>
	self readSelector: aSelector asSymbol.
	self writeSelector: (aSelector asString copyWith: $:) asSymbol
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' read: ';
	    store: self readSelector;
	    nextPutAll: ' write: ';
	    store: self writeSelector;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	aModel perform: self writeSelector with: anObject
    ]

    writeSelector [
	<category: 'accessing'>
	^writeSelector
    ]

    writeSelector: aSelector [
	<category: 'accessing'>
	writeSelector := aSelector
    ]
]



MASelectorAccessor subclass: MAAutoSelectorAccessor [
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am very similar to my super-class *MASelectorAccessor*, however I do create instance variables and accessor methods automatically if necessary. I am especially useful for prototyping. I never change existing accessor methods.'>

    categoryName [
	<category: 'accessing'>
	^#'accessing-generated'
    ]

    createReadAccessor: aClass [
	<category: 'private'>
	(aClass selectors includes: self readSelector) ifTrue: [^self].
	aClass 
	    compile: (String streamContents: 
			[:stream | 
			stream
			    nextPutAll: self readSelector, ' [';
			    cr.
			stream
			    tab;
			    nextPutAll: '^ ';
			    nextPutAll: self readSelector, ' ]'])
	    classified: self categoryName
    ]

    createVariable: aClass [
	<category: 'private'>
	(aClass allInstVarNames includes: self readSelector) ifTrue: [^self].
	aClass addInstVarName: self readSelector
    ]

    createWriteAccessor: aClass [
	<category: 'private'>
	(aClass selectors includes: self writeSelector) ifTrue: [^self].
	aClass 
	    compile: (String streamContents: 
			[:stream | 
			stream
			    nextPutAll: self writeSelector;
			    space;
			    nextPutAll: 'anObject [';
			    cr.
			stream
			    tab;
			    nextPutAll: self readSelector;
			    nextPutAll: ' := anObject ]'])
	    classified: self categoryName
    ]

    read: aModel [
	<category: 'model'>
	(self canRead: aModel) 
	    ifFalse: 
		[self createVariable: aModel class.
		self createReadAccessor: aModel class].
	^super read: aModel
    ]

    write: anObject to: aModel [
	<category: 'model'>
	(self canWrite: aModel) 
	    ifFalse: 
		[self createVariable: aModel class.
		self createWriteAccessor: aModel class].
	super write: anObject to: aModel
    ]
]



MAAccessor subclass: MAVariableAccessor [
    | name |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy that directly reads from and writes to instance variables. I strongly violate encapsulation and most of the time I should be replaced by an instance of *MASelectorAccessor*.'>

    MAVariableAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAVariableAccessor class >> name: aString [
	<category: 'instance creation'>
	^(self new)
	    name: aString asSymbol;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self name = anObject name]
    ]

    canRead: aModel [
	<category: 'testing'>
	^aModel class allInstVarNames includes: self name
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self canRead: aModel
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self name hash
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    read: aModel [
	<category: 'model'>
	^aModel instVarNamed: self name
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' name: ';
	    store: self name;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	aModel instVarNamed: self name put: anObject
    ]
]



ValueHolder subclass: MADescriptionHolder [
    
    <category: 'Magritte-Examples'>
    <comment: nil>

    MADescriptionHolder class >> descriptionClasses [
	<category: 'accessing'>
	^(OrderedCollection new)
	    add: MAStringDescription;
	    add: MAMemoDescription;
	    add: MASymbolDescription;
	    add: MAPasswordDescription;
	    add: MABooleanDescription;
	    add: MASingleOptionDescription;
	    add: MAMultipleOptionDescription;
	    add: MAToOneRelationDescription;
	    add: MAToManyRelationDescription;
	    add: MANumberDescription;
	    add: MADurationDescription;
	    add: MADateDescription;
	    add: MATimeDescription;
	    add: MATimeStampDescription;
	    add: MATokenDescription;
	    add: MAFileDescription;
	    add: MAClassDescription;
	    add: MATableDescription;
	    yourself
    ]

    MADescriptionHolder class >> descriptionValue [
	<category: 'meta'>
	^(MASingleOptionDescription new)
	    options: self descriptionClasses;
	    reference: MAClassDescription new;
	    groupBy: #grouping;
	    selectorAccessor: 'contents';
	    label: 'Type';
	    priority: 20;
	    yourself
    ]

    MADescriptionHolder class >> groupChoice [
	<category: 'groups'>
	^(Set new)
	    add: MABooleanDescription;
	    add: MASingleOptionDescription;
	    add: MAMultipleOptionDescription;
	    add: MAToOneRelationDescription;
	    add: MAToManyRelationDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupMagnitude [
	<category: 'groups'>
	^(Set new)
	    add: MANumberDescription;
	    add: MADurationDescription;
	    add: MADateDescription;
	    add: MATimeDescription;
	    add: MATimeStampDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupMisc [
	<category: 'groups'>
	^(Set new)
	    add: MAFileDescription;
	    add: MAClassDescription;
	    add: MATableDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupOf: aClass [
	<category: 'api'>
	(self groupText includes: aClass) ifTrue: [^'Text'].
	(self groupChoice includes: aClass) ifTrue: [^'Choice'].
	(self groupMagnitude includes: aClass) ifTrue: [^'Magnitude'].
	(self groupPick includes: aClass) ifTrue: [^'Pick'].
	(self groupMisc includes: aClass) ifTrue: [^'Miscellaneous'].
	^'Other'
    ]

    MADescriptionHolder class >> groupPick [
	<category: 'groups'>
	^(Set new)
	    add: MATokenDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupText [
	<category: 'groups'>
	^(Set new)
	    add: MAStringDescription;
	    add: MAMemoDescription;
	    add: MASymbolDescription;
	    add: MAPasswordDescription;
	    yourself
    ]

    initialize [
	<category: 'initialize-release'>
	self contents: self class descriptionClasses first
    ]
]


MAObject subclass: MADescription [
    | accessor |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am the root of the description hierarchy in Magritte and I provide most of the basic properties available to all descriptions. If you would like to annotate your model with a description have a look at the different subclasses of myself.

!Example
If your model has an instance variable called ==title== that should be used to store the title of the object, you could add the following description to your class:

=Document class>>descriptionTitle
=	^ MAStringDescription new
=		autoAccessor: #title;
=		label: ''Title'';
=		priority: 20;
=		beRequired;
=		yourself.

The selector ==#title== is the name of the accessor method used by Magritte to retrieve the value from the model. In the above case Magritte creates the accessor method and the instance variable automatically, if necessary. The label is used to give the field a name and will be printed next to the input box if a visual GUI is created from this description.

The write-accessor is automatically deduced by adding a colon to the read-selector, in this example ==#title:==. You can specify your own accessor strategy using one of the subclasses of ==*MAAccessor*==. If you have multiple description within the same object, the ==#priority:# field is used to order them. Assign a low priority to have descriptions traversed first.'>

    MADescription class >> accessor: anAccessor [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self new accessor: anAccessor
    ]

    MADescription class >> accessor: anAccessor label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: anAccessor
	    label: aString
	    priority: self defaultPriority
    ]

    MADescription class >> accessor: anAccessor label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: anAccessor
	    label: aString
	    priority: aNumber
	    default: self defaultDefault
    ]

    MADescription class >> accessor: anAccessor label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^(self new)
	    accessor: anAccessor;
	    label: aString;
	    priority: aNumber;
	    default: anObject;
	    yourself
    ]

    MADescription class >> auto: aSelector [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAAutoSelectorAccessor selector: aSelector)
    ]

    MADescription class >> auto: aSelector label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAAutoSelectorAccessor selector: aSelector) label: aString
    ]

    MADescription class >> auto: aSelector label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAAutoSelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> auto: aSelector label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAAutoSelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> grouping [
	<category: '*magritte-seaside-examples'>
	^MADescriptionHolder groupOf: self
    ]

    MADescription class >> defaultAccessor [
	<category: 'accessing-defaults'>
	^MANullAccessor new
    ]

    MADescription class >> defaultComment [
	<category: 'accessing-defaults'>
	^nil
    ]

    MADescription class >> defaultConditions [
	<category: 'accessing-defaults'>
	^Array new
    ]

    MADescription class >> defaultDefault [
	<category: 'accessing-defaults'>
	^nil
    ]

    MADescription class >> defaultGroup [
	<category: 'accessing-defaults'>
	^nil
    ]

    MADescription class >> defaultLabel [
	<category: 'accessing-defaults'>
	^String new
    ]

    MADescription class >> defaultPersistent [
	<category: 'accessing-defaults'>
	^true
    ]

    MADescription class >> defaultPriority [
	<category: 'accessing-defaults'>
	^0
    ]

    MADescription class >> defaultReadonly [
	<category: 'accessing-defaults'>
	^false
    ]

    MADescription class >> defaultRequired [
	<category: 'accessing-defaults'>
	^false
    ]

    MADescription class >> defaultStringReader [
	<category: 'accessing-defaults'>
	^MAStringReader
    ]

    MADescription class >> defaultStringWriter [
	<category: 'accessing-defaults'>
	^MAStringWriter
    ]

    MADescription class >> defaultUndefined [
	<category: 'accessing-defaults'>
	^String new
    ]

    MADescription class >> defaultValidator [
	<category: 'accessing-defaults'>
	^MAValidatorVisitor
    ]

    MADescription class >> defaultVisible [
	<category: 'accessing-defaults'>
	^true
    ]

    MADescription class >> descriptionComment [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #comment;
	    label: 'Comment';
	    priority: 110;
	    default: self defaultComment;
	    yourself
    ]

    MADescription class >> descriptionDefault [
	<category: 'accessing-description'>
	^self isAbstract 
	    ifFalse: 
		[(self new)
		    accessor: #default;
		    label: 'Default';
		    priority: 130;
		    default: self defaultDefault;
		    yourself]
    ]

    MADescription class >> descriptionGroup [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #group;
	    default: self defaultGroup;
	    label: 'Group';
	    priority: 105;
	    yourself
    ]

    MADescription class >> descriptionLabel [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #label;
	    label: 'Label';
	    priority: 100;
	    default: self defaultLabel;
	    yourself
    ]

    MADescription class >> descriptionName [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #name;
	    label: 'Kind';
	    priority: 0;
	    beReadonly;
	    yourself
    ]

    MADescription class >> descriptionPriority [
	<category: 'accessing-description'>
	^(MANumberDescription new)
	    accessor: #priority;
	    label: 'Priority';
	    priority: 130;
	    default: self defaultPriority;
	    beRequired;
	    yourself
    ]

    MADescription class >> descriptionReadonly [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #readonly;
	    label: 'Readonly';
	    priority: 200;
	    default: self defaultReadonly;
	    yourself
    ]

    MADescription class >> descriptionRequired [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #required;
	    label: 'Required';
	    priority: 220;
	    default: self defaultRequired;
	    yourself
    ]

    MADescription class >> descriptionStringReader [
	<category: 'accessing-description'>
	^(MASingleOptionDescription new)
	    accessor: #stringReader;
	    label: 'String Reader';
	    priority: 300;
	    default: self defaultStringReader;
	    options: [self defaultStringReader withAllSubclasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MADescription class >> descriptionStringWriter [
	<category: 'accessing-description'>
	^(MASingleOptionDescription new)
	    accessor: #stringWriter;
	    label: 'String Writer';
	    priority: 310;
	    default: self defaultStringWriter;
	    options: [self defaultStringWriter withAllSubclasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MADescription class >> descriptionUndefined [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #undefined;
	    label: 'Undefined String';
	    priority: 140;
	    default: self defaultUndefined;
	    yourself
    ]

    MADescription class >> descriptionValidator [
	<category: 'accessing-description'>
	^(MASingleOptionDescription new)
	    accessor: #validator;
	    label: 'Validator';
	    priority: 250;
	    default: self defaultValidator;
	    options: [self defaultValidator withAllSubclasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MADescription class >> descriptionVisible [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #visible;
	    label: 'Visible';
	    priority: 210;
	    default: self defaultVisible;
	    yourself
    ]

    MADescription class >> null [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MANullAccessor uuid: MACompatibility uuid)
    ]

    MADescription class >> null: anUuid [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MANullAccessor uuid: anUuid)
    ]

    MADescription class >> null: anUuid label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MANullAccessor uuid: anUuid) label: aString
    ]

    MADescription class >> null: anUuid label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MANullAccessor uuid: anUuid)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> null: anUuid label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MANullAccessor uuid: anUuid)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
	    label: aString
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> selector: aSelector [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MASelectorAccessor selector: aSelector)
    ]

    MADescription class >> selector: aSelector label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MASelectorAccessor selector: aSelector) label: aString
    ]

    MADescription class >> selector: aSelector label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MASelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> selector: aSelector label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MASelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> selectors: anArray [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAChainAccessor selectors: anArray)
    ]

    MADescription class >> selectors: anArray label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAChainAccessor selectors: anArray) label: aString
    ]

    MADescription class >> selectors: anArray label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAChainAccessor selectors: anArray)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> selectors: anArray label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAChainAccessor selectors: anArray)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    , aDescription [
	"Concatenate the receiver and ==aDescription== to one composed description. Answer a description container containing both descriptions."

	<category: 'operators'>
	^(self asContainer copy)
	    addAll: aDescription asContainer;
	    yourself
    ]

    <= anObject [
	"Answer whether the receiver should precede ==anObject== in a priority container."

	<category: 'operators'>
	^self priority <= anObject priority
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self accessor = anObject accessor]
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitDescription: self
    ]

    accessor [
	"Answer the access-strategy of the model-value described by the receiver."

	<category: 'accessing'>
	^accessor ifNil: [accessor := self class defaultAccessor]
    ]

    accessor: anObject [
	<category: 'accessing'>
	accessor := anObject asAccessor
    ]

    addCondition: aCondition [
	<category: 'validation'>
	self addCondition: aCondition labelled: aCondition asString
    ]

    addCondition: aCondition labelled: aString [
	"Add ==aCondition== as an additional validation condition to the receiver and give it the label ==aString==. The first argument is either a block-context, a composite of the subclasses of ==*MACondition*==, or any other object that responds to ==#value:== with ==true== or ==false==."

	<category: 'validation'>
	self conditions: (self conditions 
		    copyWith: (Association key: aCondition value: aString))
    ]

    asContainer [
	"Answer a description container of the receiver."

	<category: 'converting'>
	self subclassResponsibility
    ]

    autoAccessor: aSelector [
	"Uses ==aSelector== to read from the model. Creates read and write accessors and instance-variables if necessary. This is very conveniant for prototyping and can later be changed to a ==*selectorAccessor:*== using a simple rewrite rule."

	<category: 'accessors'>
	self accessor: (MAAutoSelectorAccessor selector: aSelector)
    ]

    beHidden [
	<category: 'actions'>
	self visible: false
    ]

    beOptional [
	<category: 'actions'>
	self required: false
    ]

    beReadonly [
	<category: 'actions'>
	self readonly: true
    ]

    beRequired [
	<category: 'actions'>
	self required: true
    ]

    beVisible [
	<category: 'actions'>
	self visible: true
    ]

    beWriteable [
	<category: 'actions'>
	self readonly: false
    ]

    chainAccessor: anArray [
	"Uses ==anArray== of selectors to read from the model."

	<category: 'accessors'>
	self accessor: (MAChainAccessor accessors: anArray)
    ]

    comment [
	"Answer a comment or help-text giving a hint what this description is used for. GUIs that are built from this description might display it as a tool-tip."

	<category: 'accessing-properties'>
	^self propertyAt: #comment ifAbsent: [self class defaultComment]
    ]

    comment: aString [
	<category: 'accessing-properties'>
	self propertyAt: #comment put: aString
    ]

    conditions [
	"Answer a collection of additional conditions that need to be fulfilled so that the described model is valid. Internally the collection associates conditions, that are either blocks or subclasses of *MACondition*, with an error string."

	<category: 'accessing-properties'>
	^self propertyAt: #conditions ifAbsent: [self class defaultConditions]
    ]

    conditions: anArray [
	<category: 'accessing-properties'>
	self propertyAt: #conditions put: anArray
    ]

    conflictErrorMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #conflictErrorMessage
	    ifAbsent: ['Input is conflicting with concurrent modification']
    ]

    conflictErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #conflictErrorMessage put: aString
    ]

    default [
	<category: 'accessing'>
	^nil
    ]

    default: anObject [
	<category: 'accessing'>
	
    ]

    fromString: aString [
	"Answer an object being parsed from ==aString==."

	<category: 'strings'>
	^self fromString: aString reader: self stringReader
    ]

    fromString: aString reader: aParser [
	"Answer an object being parsed from ==aString== using ==aParser==."

	<category: 'strings'>
	^aParser read: aString readStream description: self
    ]

    fromStringCollection: aCollection [
	"Answer a collection of objects being parsed from ==aCollection== of strings."

	<category: 'strings'>
	^self fromStringCollection: aCollection reader: self stringReader
    ]

    fromStringCollection: aCollection reader: aParser [
	"Answer a collection of objects being parsed from ==aCollection== of strings using ==aParser==."

	<category: 'strings'>
	^aCollection collect: [:each | self fromString: each reader: aParser]
    ]

    group [
	"Answer the group of the receiving description. The group is a string used to categorize and group descriptions. Certain display interpreters with be able to use this information to improve the useability."

	<category: 'accessing-properties'>
	^self propertyAt: #group ifAbsent: [self class defaultGroup]
    ]

    group: aString [
	"Answer the group of the receiving description. The group is a string used to categorize and group descriptions. Certain display interpreters with be able to use this information to improve the useability."

	<category: 'accessing-properties'>
	^self propertyAt: #group put: aString
    ]

    hasChildren [
	"Answer ==true== if the receiver has any child-descriptions. A description container usually has children."

	<category: 'testing'>
	^false
    ]

    hasComment [
	"Answer ==true== if the the receiver has got a non empty comment."

	<category: 'testing'>
	^self comment isEmptyOrNil not
    ]

    hasLabel [
	"Answer ==true== if the the receiver has got a non empty label."

	<category: 'testing'>
	^self label isEmptyOrNil not
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self accessor hash
    ]

    isContainer [
	"Answer ==true== if the receiver is a description container."

	<category: 'testing'>
	^false
    ]

    isDescription [
	"Answer ==true== if the receiver is a description."

	<category: 'testing'>
	^true
    ]

    isGrouped [
	<category: 'testing'>
	^false
    ]

    isReadonly [
	<category: 'testing'>
	^self readonly
    ]

    isRequired [
	<category: 'testing'>
	^self required
    ]

    isSatisfiedBy: anObject [
	"Answer ==true== if ==anObject== is a valid instance of the receiver's description."

	<category: 'validation'>
	[self validate: anObject] on: MAValidationError do: [:err | ^false].
	^true
    ]

    isSortable [
	"Answer ==true== if the described object can be trivially sorted, e.g. it answers to #<=."

	<category: 'testing'>
	^false
    ]

    isVisible [
	<category: 'testing'>
	^self visible
    ]

    kind [
	"Answer the base-class (type) the receiver is describing. The default implementation answers the most generic class: Object, the root of the Smalltalk class hierarchy. Subclasses might refine this choice."

	<category: 'accessing-configuration'>
	^Object
    ]

    kindErrorMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #kindErrorMessage ifAbsent: ['Invalid input given']
    ]

    kindErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #kindErrorMessage put: aString
    ]

    label [
	"Answer the label of the receiving description. The label is mostly used as an identifier that is printed next to the input field when building a GUI from the receiver."

	<category: 'accessing-properties'>
	^self propertyAt: #label ifAbsent: [self class defaultLabel]
    ]

    label: aString [
	<category: 'accessing-properties'>
	self propertyAt: #label put: aString
    ]

    multipleErrorsMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #multipleErrorsMessage ifAbsent: ['Multiple errors']
    ]

    multipleErrorsMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #multipleErrorsMessage put: aString
    ]

    name [
	"Answer the name of the description, a human-readable string describing the type."

	<category: 'accessing-configuration'>
	^self class label
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	accessor := accessor copy
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' label: ';
	    print: self label.
	aStream
	    nextPutAll: ' comment: ';
	    print: self comment
    ]

    priority [
	"Answer a number that is the priority of the receiving description. Priorities are used to give descriptions an explicit order by sorting them according to this number."

	<category: 'accessing-properties'>
	^self propertyAt: #priority ifAbsent: [self class defaultPriority]
    ]

    priority: aNumber [
	<category: 'accessing-properties'>
	self propertyAt: #priority put: aNumber
    ]

    propertyAccessor: aSelector [
	"Uses ==aSelector== to read from the property dictionary of the model."

	<category: 'accessors'>
	self accessor: ((MAChainAccessor on: #properties) 
		    accessor: (MADictionaryAccessor key: aSelector))
    ]

    readonly [
	"Answer ==true== if the model described by the receiver is read-only."

	<category: 'accessing-properties'>
	^self propertyAt: #readonly ifAbsent: [self class defaultReadonly]
    ]

    readonly: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #readonly put: aBoolean
    ]

    required [
	"Answer ==true== if the model described by the receiver is required, this is it cannot be ==nil==."

	<category: 'accessing-properties'>
	^self propertyAt: #required ifAbsent: [self class defaultRequired]
    ]

    required: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #required put: aBoolean
    ]

    requiredErrorMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #requiredErrorMessage
	    ifAbsent: ['Input is required but no input given']
    ]

    requiredErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #requiredErrorMessage put: aString
    ]

    selectorAccessor: aSelector [
	"Uses ==aSelector== to read from the model."

	<category: 'accessors'>
	self accessor: (MASelectorAccessor selector: aSelector)
    ]

    stringReader [
	"Answer a Visitor that can be used to parse the model described by the receiver from a string."

	<category: 'accessing-strings'>
	^self propertyAt: #stringReader ifAbsent: [self class defaultStringReader]
    ]

    stringReader: aClass [
	<category: 'accessing-strings'>
	self propertyAt: #stringReader put: aClass
    ]

    stringWriter [
	"Answer a Visitor that can be used to convert the model described by the receiver to a string."

	<category: 'accessing-strings'>
	^self propertyAt: #stringWriter ifAbsent: [self class defaultStringWriter]
    ]

    stringWriter: aClass [
	<category: 'accessing-strings'>
	self propertyAt: #stringWriter put: aClass
    ]

    toString: anObject [
	"Answer a string being formatted from ==anObject==."

	<category: 'strings'>
	^self toString: anObject writer: self stringWriter
    ]

    toString: anObject writer: aFormatter [
	"Answer a string being formatted from ==anObject== using ==aFormatter==."

	<category: 'strings'>
	^aFormatter write: anObject description: self
    ]

    toStringCollection: aCollection [
	"Answer a collection of strings being formatted from ==aCollection==."

	<category: 'strings'>
	^self toStringCollection: aCollection writer: self stringWriter
    ]

    toStringCollection: aCollection writer: aFormatter [
	"Answer a collection of strings being formatted from ==aCollection== using ==aFormatter==."

	<category: 'strings'>
	^aCollection collect: [:each | self toString: each writer: aFormatter]
    ]

    undefined [
	"Answer a string that is printed whenever the model described by the receiver is ==nil==."

	<category: 'accessing-strings'>
	^(self propertyAt: #undefined ifAbsent: [self class defaultUndefined]) 
	    ifNil: [self class defaultUndefined]
    ]

    undefined: aString [
	<category: 'accessing-strings'>
	self propertyAt: #undefined put: aString
    ]

    validate: anObject [
	"Validate ==anObject== in the context of the describing-receiver, raises an error in case of a problem. If ==anObject== is ==nil== and not required, most tests will be skipped. Do not override this message, instead have a look at ==#validateSpecific:== what is usually a better place to define the behaviour your description requires."

	<category: 'validation'>
	self validator on: anObject description: self
    ]

    validateConditions: anObject [
	"Validate ==anObject== to satisfy all its custom conditions."

	<category: 'validation-private'>
	self conditions do: 
		[:each | 
		(each key value: anObject) 
		    ifFalse: [MAConditionError description: self signal: each value]]
    ]

    validateKind: anObject [
	"Validate ==anObject== to be of the right kind."

	<category: 'validation-private'>
	(anObject isKindOf: self kind) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]

    validateRequired: anObject [
	"Validate ==anObject== not to be ==nil== if it is required."

	<category: 'validation-private'>
	(self isRequired and: [anObject isNil]) 
	    ifTrue: [MARequiredError description: self signal: self requiredErrorMessage]
    ]

    validateSpecific: anObject [
	"Validate ==anObject== to satisfy its descriptions specific validation rules. Subclasses mostly want to override this method."

	<category: 'validation-private'>
	
    ]

    validator [
	"Answer a Visitor that can be used to validate the model described by the receiver."

	<category: 'accessing-properties'>
	^self propertyAt: #validator ifAbsent: [self class defaultValidator]
    ]

    validator: aClass [
	<category: 'accessing-properties'>
	self propertyAt: #validator put: aClass
    ]

    visible [
	"Answer ==true== if the model described by the receiver is visible, as an opposite to hidden."

	<category: 'accessing-properties'>
	^self propertyAt: #visible ifAbsent: [self class defaultVisible]
    ]

    visible: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #visible put: aBoolean
    ]
]



MADescription subclass: MAContainer [
    | children |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a container holding a collection of descriptions, all instances of subclasses of *MAElementDescription*. I keep my children within an ==OrderedCollection==, but I don''t sort them according to their priority.

I fully support the collection protocol: descriptions can be added and removed. Moreover I implement most enumeration methods, so that users are able to iterate (==do:==), filter (==select:==, ==reject:==), transform (==collect:==), extract (==detect:==, ==detect:ifNone:==), and test (==allSatisfy:==, ==anySatisfy:==, ==noneSatisfy:==) my elements.'>

    MAContainer class >> defaultAccessor [
	<category: 'accessing-defaults'>
	^MAIdentityAccessor new
    ]

    MAContainer class >> defaultCollection [
	<category: 'accessing-defaults'>
	^OrderedCollection new
    ]

    MAContainer class >> descriptionChildren [
	<category: 'accessing-description'>
	^(MAToManyRelationDescription new)
	    accessor: (MASelectorAccessor read: #children write: #setChildren:);
	    classes: [MAElementDescription withAllConcreteClasses] asDynamicObject;
	    default: self defaultCollection;
	    label: 'Elements';
	    priority: 400;
	    beOrdered;
	    yourself
    ]

    MAContainer class >> descriptionDefault [
	<category: 'accessing-description'>
	^nil
    ]

    MAContainer class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAContainer class >> with: aDescription [
	<category: 'instance creation'>
	^(self new)
	    add: aDescription;
	    yourself
    ]

    MAContainer class >> withAll: aCollection [
	<category: 'instance creation'>
	^(self new)
	    addAll: aCollection;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self children = anObject children]
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitContainer: self
    ]

    add: aDescription [
	<category: 'adding'>
	self children add: aDescription
    ]

    addAll: aCollection [
	<category: 'adding'>
	self children addAll: aCollection
    ]

    allSatisfy: aBlock [
	<category: 'enumerating'>
	^self children allSatisfy: aBlock
    ]

    anySatisfy: aBlock [
	<category: 'enumerating'>
	^self children anySatisfy: aBlock
    ]

    asContainer [
	<category: 'converting'>
	^self
    ]

    at: anIndex [
	<category: 'accessing'>
	^self children at: anIndex
    ]

    at: anIndex ifAbsent: aBlock [
	<category: 'accessing'>
	^self children at: anIndex ifAbsent: aBlock
    ]

    children [
	<category: 'accessing'>
	^children
    ]

    collect: aBlock [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children collect: aBlock);
	    yourself
    ]

    copyEmpty [
	<category: 'copying'>
	^(self copy)
	    setChildren: self class defaultCollection;
	    yourself
    ]

    copyFrom: aStartIndex to: anEndIndex [
	<category: 'copying'>
	^(self copy)
	    setChildren: (self children copyFrom: aStartIndex to: anEndIndex);
	    yourself
    ]

    copyWithout: anObject [
	<category: 'copying'>
	^self reject: [:each | each = anObject]
    ]

    copyWithoutAll: aCollection [
	<category: 'copying'>
	^self reject: [:each | aCollection includes: each]
    ]

    detect: aBlock [
	<category: 'enumerating'>
	^self children detect: aBlock
    ]

    detect: aBlock ifNone: anExceptionBlock [
	<category: 'enumerating'>
	^self children detect: aBlock ifNone: anExceptionBlock
    ]

    do: aBlock [
	<category: 'enumerating'>
	self children do: aBlock
    ]

    do: aBlock separatedBy: aSeparatorBlock [
	<category: 'enumerating'>
	self children do: aBlock separatedBy: aSeparatorBlock
    ]

    errorNotFound: aDescription [
	<category: 'private'>
	self error: aDescription class label , ' not found.'
    ]

    hasChildren [
	<category: 'testing'>
	^self notEmpty
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self children hash
    ]

    includes: aDescription [
	<category: 'testing'>
	^self children includes: aDescription
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self setChildren: self class defaultCollection
    ]

    inject: anObject into: aBlock [
	<category: 'enumerating'>
	^self children inject: anObject into: aBlock
    ]

    intersection: aCollection [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children intersection: aCollection);
	    yourself
    ]

    isContainer [
	<category: 'testing'>
	^true
    ]

    isEmpty [
	<category: 'testing'>
	^self children isEmpty
    ]

    keysAndValuesDo: aBlock [
	<category: 'enumerating'>
	self children keysAndValuesDo: aBlock
    ]

    moveDown: aDescription [
	<category: 'moving'>
	self children moveDown: aDescription
    ]

    moveUp: aDescription [
	<category: 'moving'>
	self children moveUp: aDescription
    ]

    noneSatisfy: aBlock [
	<category: 'enumerating'>
	^self children noneSatisfy: aBlock
    ]

    notEmpty [
	<category: 'testing'>
	^self children notEmpty
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	self setChildren: self children copy
    ]

    reject: aBlock [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children reject: aBlock);
	    yourself
    ]

    remove: aDescription [
	<category: 'removing'>
	self children remove: aDescription
	    ifAbsent: [self errorNotFound: aDescription]
    ]

    removeAll [
	<category: 'removing'>
	self setChildren: self class defaultCollection
    ]

    select: aBlock [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children select: aBlock);
	    yourself
    ]

    setChildren: aCollection [
	<category: 'initialization'>
	children := aCollection
    ]

    size [
	<category: 'accessing'>
	^self children size
    ]

    union: aContainer [
	<category: 'enumerating'>
	^(self copy)
	    addAll: (aContainer reject: [:each | self includes: each]);
	    yourself
    ]

    with: aCollection do: aBlock [
	<category: 'enumerating'>
	self children with: aCollection do: aBlock
    ]
]



MAContainer subclass: MAPriorityContainer [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a container holding a collection of descriptions and I keep them sorted according to their priority.'>

    MAPriorityContainer class >> defaultCollection [
	<category: 'accessing-defaults'>
	^SortedCollection new
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitPriorityContainer: self
    ]

    moveDown: aDescription [
	<category: 'moving'>
	self shouldNotImplement
    ]

    moveUp: aDescription [
	<category: 'moving'>
	self shouldNotImplement
    ]

    resort [
	<category: 'actions'>
	self setChildren: self children copy
    ]

    setChildren: aCollection [
	<category: 'initialization'>
	super setChildren: aCollection asSortedCollection
    ]
]



MADescription subclass: MAElementDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description for all basic description types.'>

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitElementDescription: self
    ]

    asContainer [
	<category: 'converting'>
	^MAContainer with: self
    ]

    default [
	<category: 'accessing'>
	^self propertyAt: #default ifAbsent: [self class defaultDefault]
    ]

    default: anObject [
	<category: 'accessing'>
	self propertyAt: #default put: anObject
    ]
]



MAElementDescription subclass: MABooleanDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of the Boolean values ==true== and ==false==. My visual representation could be a check-box.'>

    MABooleanDescription class >> defaultFalseString [
	<category: 'accessing-defaults'>
	^self defaultFalseStrings first
    ]

    MABooleanDescription class >> defaultFalseStrings [
	<category: 'accessing-defaults'>
	^#('false' 'f' 'no' 'n' '0' 'off')
    ]

    MABooleanDescription class >> defaultTrueString [
	<category: 'accessing-defaults'>
	^self defaultTrueStrings first
    ]

    MABooleanDescription class >> defaultTrueStrings [
	<category: 'accessing-defaults'>
	^#('true' 't' 'yes' 'y' '1' 'on')
    ]

    MABooleanDescription class >> descriptionFalseString [
	<category: 'accessing-descriptions'>
	^(MAStringDescription new)
	    accessor: #falseString;
	    default: self defaultFalseString;
	    label: 'False String';
	    priority: 410;
	    yourself
    ]

    MABooleanDescription class >> descriptionRequired [
	<category: 'accessing-descriptions'>
	^nil
    ]

    MABooleanDescription class >> descriptionTrueString [
	<category: 'accessing-descriptions'>
	^(MAStringDescription new)
	    accessor: #trueString;
	    default: self defaultTrueString;
	    label: 'True String';
	    priority: 400;
	    yourself
    ]

    MABooleanDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MABooleanDescription class >> label [
	<category: 'accessing'>
	^'Boolean'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitBooleanDescription: self
    ]

    allOptions [
	<category: 'accessing-selection'>
	^self options
    ]

    allOptionsWith: anObject [
	<category: 'accessing-selection'>
	^self options
    ]

    falseString [
	<category: 'accessing-properties'>
	^self propertyAt: #falseString ifAbsent: [self class defaultFalseString]
    ]

    falseString: aString [
	<category: 'accessing-properties'>
	^self propertyAt: #falseString put: aString
    ]

    falseStrings [
	<category: 'accessing-readonly'>
	^self class defaultFalseStrings
    ]

    isExtensible [
	<category: 'accessing-selection'>
	^false
    ]

    kind [
	<category: 'accessing'>
	^Boolean
    ]

    labelForOption: anObject [
	<category: 'private'>
	anObject == true ifTrue: [^self trueString].
	anObject == false ifTrue: [^self falseString].
	^self undefined
    ]

    options [
	<category: 'accessing-selection'>
	^Array with: false with: true
    ]

    reference [
	<category: 'accessing-selection'>
	^self
    ]

    trueString [
	<category: 'accessing-properties'>
	^self propertyAt: #trueString ifAbsent: [self class defaultTrueString]
    ]

    trueString: aString [
	<category: 'accessing-properties'>
	^self propertyAt: #trueString put: aString
    ]

    trueStrings [
	<category: 'accessing-readonly'>
	^self class defaultTrueStrings
    ]
]



MAElementDescription subclass: MAClassDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of Smalltalk classes, possible values can be any of ==Smalltalk allClasses==.'>

    MAClassDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAClassDescription class >> label [
	<category: 'accessing'>
	^'Class'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitClassDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Class
    ]
]



MAElementDescription subclass: MAFileDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of files, their contents, filename and mime-type. Possible values include instances of *MAFileModel*. My visual representation could be a file-upload dialog.'>

    MAFileDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAFileDescription class >> label [
	<category: 'accessing'>
	^'File'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitFileDescription: self
    ]

    kind [
	<category: 'accessing'>
	^self propertyAt: #modelClass ifAbsent: [MAMemoryFileModel]
    ]

    kind: aClass [
	"Set the file model class to be used."

	<category: 'accessing'>
	self propertyAt: #modelClass put: aClass
    ]
]



MAElementDescription subclass: MAMagnitudeDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description for subclasses of ==Magnitude==. The range of accepted values can be limited using the accessors ==min:== and ==max:==.'>

    MAMagnitudeDescription class >> defaultMax [
	<category: 'accessing-defaults'>
	^nil
    ]

    MAMagnitudeDescription class >> defaultMin [
	<category: 'accessing-defaults'>
	^nil
    ]

    MAMagnitudeDescription class >> descriptionMax [
	<category: 'accessing-description'>
	^(self new)
	    accessor: #max;
	    label: 'Maximum';
	    priority: 410;
	    yourself
    ]

    MAMagnitudeDescription class >> descriptionMin [
	<category: 'accessing-description'>
	^(self new)
	    accessor: #min;
	    label: 'Min';
	    priority: 400;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitMagnitudeDescription: self
    ]

    isSortable [
	<category: 'testing'>
	^true
    ]

    isWithinRange: anObject [
	<category: 'testing'>
	^(self min isNil or: [self min <= anObject]) 
	    and: [self max isNil or: [self max >= anObject]]
    ]

    max [
	<category: 'accessing'>
	^self propertyAt: #max ifAbsent: [self class defaultMax]
    ]

    max: aMagnitudeOrNil [
	"Set the maximum for accepted values, or ==nil== if open."

	<category: 'accessing'>
	^self propertyAt: #max put: aMagnitudeOrNil
    ]

    min [
	<category: 'accessing'>
	^self propertyAt: #min ifAbsent: [self class defaultMin]
    ]

    min: aMagnitudeOrNil [
	"Set the minimum for accepted values, or ==nil== if open."

	<category: 'accessing'>
	^self propertyAt: #min put: aMagnitudeOrNil
    ]

    min: aMinimumObject max: aMaximumObject [
	"Set the minimum and maximum of accepted values, or ==nil== if open."

	<category: 'conveniance'>
	self
	    min: aMinimumObject;
	    max: aMaximumObject
    ]

    rangeErrorMessage [
	<category: 'accessing-messages'>
	| min max |
	^self propertyAt: #rangeErrorMessage
	    ifAbsent: 
		[min := self toString: self min.
		max := self toString: self max.
		(self min notNil and: [self max notNil]) 
		    ifTrue: [^'Input must be between ' , min , ' and ' , max].
		(self min notNil and: [self max isNil]) 
		    ifTrue: [^'Input must be above or equeal to ' , min].
		(self min isNil and: [self max notNil]) 
		    ifTrue: [^'Input must be below or equal to ' , max]]
    ]

    rangeErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #rangeErrorMessage put: aString
    ]

    validateSpecific: anObject [
	<category: 'validation-private'>
	super validateSpecific: anObject.
	(self isWithinRange: anObject) 
	    ifFalse: [MARangeError description: self signal: self rangeErrorMessage]
    ]
]



MAMagnitudeDescription subclass: MADateDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of dates, possible values are instances of ==Date==. My visual representation could be a date-picker.'>

    MADateDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADateDescription class >> label [
	<category: 'accessing'>
	^'Date'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitDateDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Date
    ]
]



MAMagnitudeDescription subclass: MADurationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of durations, possible values are instances of ==Duration==.'>

    MADurationDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADurationDescription class >> label [
	<category: 'accessing'>
	^'Duration'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitDurationDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Duration
    ]
]



MAMagnitudeDescription subclass: MANumberDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of numbers, possible values are instances of ==Number== and all its subclasses, including ==Integer== and ==Float==. My visual representation could be a number input-box or even a slider-control.'>

    MANumberDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MANumberDescription class >> label [
	<category: 'accessing'>
	^'Number'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitNumberDescription: self
    ]

    beInteger [
	<category: 'conveniance'>
	self addCondition: [:value | value isInteger]
	    labelled: 'No integer was entered'
    ]

    kind [
	<category: 'accessing'>
	^Number
    ]
]



MAMagnitudeDescription subclass: MATimeDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of times, possible values are instances of ==Time==. My visual representation could be a time-picker.'>

    MATimeDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATimeDescription class >> label [
	<category: 'accessing'>
	^'Time'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTimeDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Time
    ]
]



MAMagnitudeDescription subclass: MATimeStampDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of timestamps, possible values are instances of ==DateTime==. My visual representation could be a date- and time-picker.'>

    MATimeStampDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATimeStampDescription class >> label [
	<category: 'accessing'>
	^'Timestamp'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTimeStampDescription: self
    ]

    kind [
	<category: 'accessing'>
	^DateTime
    ]
]



MAElementDescription subclass: MAReferenceDescription [
    | reference |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract superclass for descriptions holding onto another description.
'>

    MAReferenceDescription class >> defaultReference [
	<category: 'accessing-defaults'>
	^MAStringDescription new
    ]

    MAReferenceDescription class >> descriptionReference [
	<category: 'accessing-description'>
	^(MAToOneRelationDescription new)
	    accessor: #reference;
	    classes: [MADescription withAllConcreteClasses] asDynamicObject;
	    label: 'Description';
	    priority: 400;
	    beRequired;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitReferenceDescription: self
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	reference := reference copy
    ]

    reference [
	<category: 'accessing'>
	^reference ifNil: [reference := self class defaultReference]
    ]

    reference: aDescription [
	<category: 'accessing'>
	reference := aDescription
    ]
]



MAReferenceDescription subclass: MAOptionDescription [
    | options |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description of different options the user can choose from. My instance variable ==options== references the options I am representing. The options can be sorted or unsorted.'>

    MAOptionDescription class >> defaultOptions [
	<category: 'accessing-defaults'>
	^OrderedCollection new
    ]

    MAOptionDescription class >> defaultSorted [
	<category: 'accessing-defaults'>
	^false
    ]

    MAOptionDescription class >> descriptionDefault [
	<category: 'accessing-description'>
	^nil
    ]

    MAOptionDescription class >> descriptionOptions [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #optionsTextual;
	    label: 'Options';
	    priority: 410;
	    default: self defaultOptions;
	    yourself
    ]

    MAOptionDescription class >> descriptionSorted [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #sorted;
	    label: 'Sorted';
	    priority: 240;
	    default: self defaultSorted;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitOptionDescription: self
    ]

    allOptions [
	<category: 'accessing-dynamic'>
	^self prepareOptions: self options copy
    ]

    allOptionsWith: anObject [
	<category: 'accessing-dynamic'>
	^self prepareOptions: ((self shouldNotInclude: anObject) 
		    ifFalse: [self options copyWith: anObject]
		    ifTrue: [self options copy])
    ]

    beSorted [
	<category: 'actions'>
	self sorted: true
    ]

    beUnsorted [
	<category: 'actions'>
	self sorted: false
    ]

    isSorted [
	<category: 'testing'>
	^self sorted
    ]

    labelForOption: anObject [
	<category: 'private'>
	self propertyAt: #labels
	    ifPresent: [:labels | labels at: anObject ifPresent: [:value | ^value]].
	^self reference toString: anObject
    ]

    options [
	<category: 'accessing'>
	^options ifNil: [options := self class defaultOptions]
    ]

    options: anArray [
	<category: 'accessing'>
	options := anArray
    ]

    optionsAndLabels: aCollection [
	"Set the options to be the keys of aCollection and the labels to be the values of aCollection."

	<category: 'accessing'>
	self options: (aCollection collect: [:assoc | assoc key]).
	self propertyAt: #labels
	    put: (aCollection inject: IdentityDictionary new
		    into: 
			[:result :assoc | 
			result
			    add: assoc;
			    yourself])
    ]

    optionsTextual [
	<category: 'accessing-textual'>
	^(self reference toStringCollection: self options) asMultilineString
    ]

    optionsTextual: aString [
	<category: 'accessing-textual'>
	| lines |
	lines := (aString ifNil: [String new]) lines.
	^self options: (self reference fromStringCollection: lines)
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	options := options copy
    ]

    prepareOptions: aCollection [
	<category: 'private'>
	^self isSorted 
	    ifFalse: [aCollection asArray]
	    ifTrue: 
		[(aCollection asArray)
		    sort: self sortBlock;
		    yourself]
    ]

    shouldNotInclude: anObject [
	<category: 'accessing-dynamic'>
	^anObject isNil or: [self options includes: anObject]
    ]

    sortBlock [
	<category: 'private'>
	^
	[:a :b | 
	(self reference toString: a) 
	    <= (self reference toString: b)]
    ]

    sorted [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted ifAbsent: [self class defaultSorted]
    ]

    sorted: aBoolean [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted put: aBoolean
    ]

    undefined: aString [
	<category: 'accessing-properties'>
	super undefined: aString.
	self reference isNil ifFalse: [self reference undefined: aString]
    ]
]



MAOptionDescription subclass: MAMultipleOptionDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of multiple options, possible options are stored within the ==options== field, possible values are instances of ==Collection==. My visual representation could be a multi-select list or a group of check-boxes.'>

    MAMultipleOptionDescription class >> defaultDistinct [
	<category: 'accessing-defaults'>
	^false
    ]

    MAMultipleOptionDescription class >> defaultOrdered [
	<category: 'accessing-defaults'>
	^false
    ]

    MAMultipleOptionDescription class >> descriptionDistinct [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #distinct;
	    label: 'Distinct';
	    priority: 250;
	    default: self defaultDistinct;
	    yourself
    ]

    MAMultipleOptionDescription class >> descriptionOrdered [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #ordered;
	    label: 'Ordered';
	    priority: 260;
	    default: self defaultOrdered;
	    yourself
    ]

    MAMultipleOptionDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAMultipleOptionDescription class >> label [
	<category: 'accessing'>
	^'Multiple-Option'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitMultipleOptionDescription: self
    ]

    beDistinct [
	<category: 'actions'>
	self distinct: true
    ]

    beIndefinite [
	<category: 'actions'>
	self distinct: false
    ]

    beOrdered [
	<category: 'actions'>
	self ordered: true
    ]

    beUnordered [
	<category: 'actions'>
	self ordered: false
    ]

    distinct [
	<category: 'accessing-properties'>
	^self propertyAt: #distinct ifAbsent: [self class defaultDistinct]
    ]

    distinct: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #distinct put: aBoolean
    ]

    isDistinct [
	<category: 'testing'>
	^self distinct
    ]

    isOrdered [
	<category: 'testing'>
	^self ordered
    ]

    kind [
	<category: 'accessing'>
	^Collection
    ]

    ordered [
	<category: 'accessing-properties'>
	^self propertyAt: #ordered ifAbsent: [self class defaultOrdered]
    ]

    ordered: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #ordered put: aBoolean
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	(anObject allSatisfy: [:each | self options includes: each]) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]

    validateRequired: anObject [
	<category: 'validating'>
	super validateRequired: anObject.
	(self isRequired and: [anObject isCollection and: [anObject isEmpty]]) 
	    ifTrue: [MARequiredError description: self signal: self requiredErrorMessage]
    ]
]



MAOptionDescription subclass: MASingleOptionDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of a single option, possible values are stored within the ==options== field, but I might also be extensible so that the user can add its own option. My visual representation could be a drop-down list or a group of option-buttons.'>

    MASingleOptionDescription class >> defaultExtensible [
	<category: 'accessing-defaults'>
	^false
    ]

    MASingleOptionDescription class >> descriptionExtensible [
	<category: 'accessing-descriptions'>
	^(MABooleanDescription new)
	    accessor: #extensible;
	    label: 'Extensible';
	    priority: 250;
	    default: self defaultExtensible;
	    yourself
    ]

    MASingleOptionDescription class >> descriptionGroupBy [
	<category: 'accessing-descriptions'>
	^(MASymbolDescription new)
	    selectorAccessor: #groupBy;
	    label: 'Grouped by';
	    priority: 260;
	    default: nil;
	    yourself
    ]

    MASingleOptionDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MASingleOptionDescription class >> label [
	<category: 'accessing'>
	^'Single-Option'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitSingleOptionDescription: self
    ]

    beExtensible [
	<category: 'actions'>
	self extensible: true
    ]

    beLimited [
	<category: 'actions'>
	self extensible: false
    ]

    extensible [
	<category: 'accessing-properties'>
	^self propertyAt: #extensible ifAbsent: [self class defaultExtensible]
    ]

    extensible: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #extensible put: aBoolean
    ]

    groupBy [
	"Answer the selector to be sent to the options objects for determining their group"

	<category: 'accessing-properties'>
	^self propertyAt: #groupBy ifAbsent: [nil]
    ]

    groupBy: aSymbol [
	"aSymbol is the selector to be sent to the options objects for getting their group"

	<category: 'accessing-properties'>
	^self propertyAt: #groupBy put: aSymbol
    ]

    isExtensible [
	<category: 'testing'>
	^self extensible
    ]

    isGrouped [
	<category: 'testing'>
	^self groupBy notNil
    ]

    prepareOptions: aCollection [
	<category: 'private'>
	^self isRequired 
	    ifTrue: [super prepareOptions: aCollection]
	    ifFalse: [(super prepareOptions: aCollection) copyWithFirst: nil]
    ]

    shouldNotInclude: anObject [
	<category: 'accessing-dynamic'>
	^self isExtensible not or: [super shouldNotInclude: anObject]
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	(self isExtensible or: [self options includes: anObject]) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]
]



MAReferenceDescription subclass: MARelationDescription [
    | classes |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description for descriptions representing a relation. My instance variable ==classes== references a collection of possible classes that I can relate to. If required the reference description will be automatically built from this list of classes.'>

    MARelationDescription class >> defaultClasses [
	<category: 'accessing-defaults'>
	^Set new
    ]

    MARelationDescription class >> defaultReference [
	<category: 'accessing-defaults'>
	^nil
    ]

    MARelationDescription class >> descriptionClasses [
	<category: 'accessing-description'>
	^(MAMultipleOptionDescription new)
	    accessor: #classes;
	    label: 'Classes';
	    priority: 400;
	    options: [Smalltalk allClasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MARelationDescription class >> descriptionReference [
	<category: 'accessing-description'>
	^(super descriptionReference)
	    classes: [MAContainer withAllConcreteClasses] asDynamicObject;
	    beOptional;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitRelationDescription: self
    ]

    allClasses [
	<category: 'accessing-dynamic'>
	^(Array withAll: self classes)
	    sort: [:a :b | a label <= b label];
	    yourself
    ]

    classes [
	<category: 'accessing'>
	^classes ifNil: [classes := self class defaultClasses]
    ]

    classes: aCollection [
	<category: 'accessing'>
	classes := aCollection
    ]

    commonClass [
	"Answer a common superclass of the classes of the receiver. The algorithm is implemented to be as efficient as possible. The inner loop will be only executed the first few iterations."

	<category: 'accessing-dynamic'>
	| current |
	self classes isEmpty ifTrue: [^self class descriptionContainer].
	current := self classes anyOne.
	self classes do: 
		[:each | 
		[each includesBehavior: current] 
		    whileFalse: [current := current superclass]].
	^current
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	classes := classes copy
    ]

    reference [
	"The reference within a ==*MARelationDescription*== is calculated automatically from all the classes of the receiver, if set to ==nil==. By setting the reference to a ==*MAContainer*== instance it is possible to customize the reference description."

	<category: 'accessing-dynamic'>
	^super reference ifNil: [self commonClass description]
    ]
]



MARelationDescription subclass: MAToManyRelationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of an one-to-many relationship, possible values are instances of ==Collection==.'>

    MAToManyRelationDescription class >> defaultDefinitive [
	<category: 'accessing-defaults'>
	^false
    ]

    MAToManyRelationDescription class >> defaultOrdered [
	<category: 'accessing-defaults'>
	^false
    ]

    MAToManyRelationDescription class >> defaultSorted [
	<category: 'accessing-defaults'>
	^false
    ]

    MAToManyRelationDescription class >> descriptionDefinitive [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #definitive;
	    label: 'Definitive';
	    priority: 265;
	    default: self defaultDefinitive;
	    yourself
    ]

    MAToManyRelationDescription class >> descriptionOrdered [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #ordered;
	    label: 'Ordered';
	    priority: 260;
	    default: self defaultOrdered;
	    yourself
    ]

    MAToManyRelationDescription class >> descriptionSorted [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #sorted;
	    label: 'Sorted';
	    priority: 240;
	    default: self defaultSorted;
	    yourself
    ]

    MAToManyRelationDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAToManyRelationDescription class >> label [
	<category: 'accessing'>
	^'1:m Relation'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitToManyRelationDescription: self
    ]

    beDefinitive [
	<category: 'actions'>
	self definitive: true
    ]

    beModifiable [
	<category: 'actions'>
	self definitive: false
    ]

    beOrdered [
	<category: 'actions'>
	self ordered: true
    ]

    beSorted [
	<category: 'actions'>
	self sorted: true
    ]

    beUnordered [
	<category: 'actions'>
	self ordered: false
    ]

    beUnsorted [
	<category: 'actions'>
	self sorted: false
    ]

    definitive [
	<category: 'accessing-properties'>
	^self propertyAt: #definitive ifAbsent: [self class defaultDefinitive]
    ]

    definitive: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #definitive put: aBoolean
    ]

    isDefinitive [
	<category: 'testing'>
	^self definitive
    ]

    isOrdered [
	<category: 'testing'>
	^self ordered
    ]

    isSorted [
	<category: 'testing'>
	^self sorted
    ]

    kind [
	<category: 'accessing'>
	^Collection
    ]

    ordered [
	<category: 'accessing-properties'>
	^self propertyAt: #ordered ifAbsent: [self class defaultOrdered]
    ]

    ordered: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #ordered put: aBoolean
    ]

    sorted [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted ifAbsent: [self class defaultSorted]
    ]

    sorted: aBoolean [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted put: aBoolean
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	anObject do: 
		[:object | 
		(self classes 
		    anySatisfy: [:class | object species includesBehavior: class]) 
			ifFalse: [MAKindError description: self signal: self kindErrorMessage]]
    ]

    validateRequired: anObject [
	<category: 'validating'>
	super validateRequired: anObject.
	(self isRequired and: [anObject isCollection and: [anObject isEmpty]]) 
	    ifTrue: [MARequiredError description: self signal: self requiredErrorMessage]
    ]
]



MAToManyRelationDescription subclass: MAToManyScalarRelationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'Like MAToManyRelationDescription but for scalar values.'>

    MAToManyScalarRelationDescription class >> label [
	<category: 'accessing'>
	^'1:m scalar Relation'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitToManyScalarRelationDescription: self
    ]
]



MARelationDescription subclass: MAToOneRelationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of an one-to-one relationship.'>

    MAToOneRelationDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAToOneRelationDescription class >> label [
	<category: 'accessing'>
	^'1:1 Relation'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitToOneRelationDescription: self
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	(self classes anySatisfy: [:class | anObject species = class]) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]
]



MAReferenceDescription subclass: MATableDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of tables, their cells and labels. I hold a reference to the description of my cells, that are all described using the same description. Possible values include instances of *MATableModel*.'>

    MATableDescription class >> defaultColumnLabels [
	<category: 'accessing-defaults'>
	^OrderedCollection 
	    with: 'a'
	    with: 'b'
	    with: 'c'
    ]

    MATableDescription class >> defaultRowLabels [
	<category: 'accessing-defaults'>
	^OrderedCollection 
	    with: '1'
	    with: '2'
	    with: '3'
    ]

    MATableDescription class >> descriptionColumnLabels [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #columnLabelsTextual;
	    label: 'Column Labels';
	    priority: 250;
	    yourself
    ]

    MATableDescription class >> descriptionDefault [
	<category: 'accessing-description'>
	^nil
    ]

    MATableDescription class >> descriptionRequired [
	<category: 'accessing-description'>
	^nil
    ]

    MATableDescription class >> descriptionRowLabels [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #rowLabelsTextual;
	    label: 'Row Labels';
	    priority: 250;
	    yourself
    ]

    MATableDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATableDescription class >> label [
	<category: 'accessing'>
	^'Table'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTableDescription: self
    ]

    columnCount [
	<category: 'accessing'>
	^self columnLabels size
    ]

    columnLabels [
	<category: 'accessing-properties'>
	^self propertyAt: #columnLabels ifAbsent: [self class defaultColumnLabels]
    ]

    columnLabels: aCollection [
	<category: 'accessing-properties'>
	self propertyAt: #columnLabels put: aCollection
    ]

    columnLabelsTextual [
	<category: 'accessing-textual'>
	^(MAStringDescription new toStringCollection: self columnLabels) 
	    asMultilineString
    ]

    columnLabelsTextual: aString [
	<category: 'accessing-textual'>
	self 
	    columnLabels: (MAStringDescription new fromStringCollection: aString lines)
    ]

    kind [
	<category: 'accessing'>
	^MATableModel
    ]

    rowCount [
	<category: 'accessing'>
	^self rowLabels size
    ]

    rowLabels [
	<category: 'accessing-properties'>
	^self propertyAt: #rowLabels ifAbsent: [self class defaultRowLabels]
    ]

    rowLabels: aCollection [
	<category: 'accessing-properties'>
	self propertyAt: #rowLabels put: aCollection
    ]

    rowLabelsTextual [
	<category: 'accessing-textual'>
	^(MAStringDescription new toStringCollection: self rowLabels) 
	    asMultilineString
    ]

    rowLabelsTextual: aString [
	<category: 'accessing-textual'>
	self 
	    rowLabels: (MAStringDescription new fromStringCollection: aString lines)
    ]

    validateSpecific: anObject [
	<category: 'validation-private'>
	super validateSpecific: anObject.
	(anObject rowCount ~= self rowCount 
	    or: [anObject columnCount ~= self columnCount]) 
		ifTrue: [MAKindError description: self signal: self kindErrorMessage]
    ]
]



MAReferenceDescription subclass: MATokenDescription [
    | tokens |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of tokens all described by the referenced description, possible values are instances of ==SequenceableCollection==.'>

    MATokenDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATokenDescription class >> label [
	<category: 'accessing'>
	^'Token'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTokenDescription: self
    ]

    kind [
	<category: 'accessing-dynamic'>
	^Array
    ]

    tokens [
	<category: 'accessing'>
	^tokens ifNil: [tokens := #()]
    ]

    tokens: anArray [
	<category: 'accessing'>
	tokens := anArray
    ]
]



MAElementDescription subclass: MAStringDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of strings, possible values are instances of ==String==. My visual representation could be a single line text-field. Use ==*MAMemoDescription*== for multi-line strings.'>

    MAStringDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAStringDescription class >> label [
	<category: 'accessing'>
	^'String'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitStringDescription: self
    ]

    isSortable [
	<category: 'testing'>
	^true
    ]

    kind [
	<category: 'accessing'>
	^String
    ]
]



MAStringDescription subclass: MAMemoDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of multiline strings, possible values are instances of ==String==. My visual representation could be a text-area field.'>

    MAMemoDescription class >> defaultLineCount [
	<category: 'accessing-defaults'>
	^3
    ]

    MAMemoDescription class >> descriptionLineCount [
	<category: 'accessing-description'>
	^(MANumberDescription new)
	    accessor: #lineCount;
	    label: 'Number of Lines';
	    priority: 400;
	    default: self defaultLineCount;
	    beInteger;
	    min: 1;
	    yourself
    ]

    MAMemoDescription class >> label [
	<category: 'accessing'>
	^'Memo'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitMemoDescription: self
    ]

    lineCount [
	<category: 'accessing-properties'>
	^self propertyAt: #lineCount ifAbsent: [self class defaultLineCount]
    ]

    lineCount: anInteger [
	<category: 'accessing-properties'>
	^self propertyAt: #lineCount put: anInteger
    ]
]



MAStringDescription subclass: MAPasswordDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of a password string, possible values are instances of ==String==. My visual representation could be a password field, where there are stars printed instead of the characters the user enters.'>

    MAPasswordDescription class >> label [
	<category: 'accessing'>
	^'Password'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitPasswordDescription: self
    ]

    isObfuscated: anObject [
	<category: 'testing'>
	^anObject notNil and: 
		[anObject isString 
		    and: [anObject isEmpty not and: [anObject allSatisfy: [:each | each = $*]]]]
    ]

    isSortable [
	<category: 'testing'>
	^false
    ]

    obfuscated: anObject [
	<category: 'operators'>
	^String new: (self toString: anObject) size withAll: $*
    ]
]



MAStringDescription subclass: MASymbolDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of symbols, possible values are instances of ==Symbol==.'>

    MASymbolDescription class >> label [
	<category: 'accessing'>
	^'Symbol'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitSymbolDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Symbol
    ]
]



MAObject subclass: MAMemento [
    | model description |
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I am an abstract memento. I reference a model I am working on and the description currently used to describe this model.'>

    MAMemento class >> model: aModel [
	<category: 'instance creation'>
	^self model: aModel description: aModel description
    ]

    MAMemento class >> model: aModel description: aDescription [
	<category: 'instance creation'>
	^(self new)
	    setModel: aModel;
	    setDescription: aDescription;
	    reset;
	    yourself
    ]

    commit [
	"Commit the receiver into the model."

	<category: 'actions'>
	
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    isDifferent: firstDictionary to: secondDictionary [
	<category: 'private'>
	| firstValue secondValue |
	self description do: 
		[:each | 
		(each isVisible and: [each isReadonly not]) 
		    ifTrue: 
			[firstValue := firstDictionary at: each ifAbsent: [nil].
			secondValue := secondDictionary at: each ifAbsent: [nil].
			firstValue = secondValue ifFalse: [^true]]].
	^false
    ]

    model [
	<category: 'accessing'>
	^model
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' model: ';
	    print: self model
    ]

    pull [
	"Utitlity method to pull the model into a dictionary mapping descriptions to values. nil values are replaced with the default ones of the model."

	<category: 'private'>
	| result |
	result := self pullRaw.
	result keysAndValuesDo: 
		[:key :value | 
		value isNil ifTrue: [result at: key put: key default yourself]].
	^result
    ]

    pullRaw [
	<category: 'private'>
	| result |
	result := Dictionary new.
	self description 
	    do: [:each | result at: each put: (self model readUsing: each)].
	^result
    ]

    push: aDictionary [
	"Utitlity method to push a dictionary mapping descriptions to values into the model."

	<category: 'private'>
	aDictionary keysAndValuesDo: 
		[:key :value | 
		(key isVisible and: [key isReadonly not]) 
		    ifTrue: [self model write: value using: key]]
    ]

    reset [
	"Reset the memento from the model."

	<category: 'actions'>
	
    ]

    setDescription: aDescription [
	<category: 'initialization'>
	description := aDescription
    ]

    setModel: aModel [
	<category: 'initialization'>
	model := aModel
    ]

    validate [
	"Check if the data in the receiver would be valid if committed. In case of problems an exception is raised."

	<category: 'actions'>
	self description validate: self
    ]
]



MAMemento subclass: MACachedMemento [
    | cache |
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I cache values being read and written without touching the model. When committing changes, the modifications will be propagated to the model all at once.'>

    MACachedMemento class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    cache [
	<category: 'accessing'>
	^cache
    ]

    commit [
	<category: 'actions'>
	super commit.
	self push: self cache.
	self reset
    ]

    hasChanged [
	"Answer ==true==, if the cached data is different to the data in the model."

	<category: 'testing'>
	^self isDifferent: self cache to: self pullRaw
    ]

    readUsing: aDescription [
	<category: 'private'>
	^self cache at: aDescription
    ]

    reset [
	<category: 'actions'>
	super reset.
	self setCache: self pull
    ]

    setCache: aDictionary [
	<category: 'initialization'>
	cache := aDictionary
    ]

    write: anObject using: aDescription [
	<category: 'private'>
	self cache at: aDescription put: anObject
    ]
]



MACachedMemento subclass: MACheckedMemento [
    | original |
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I cache values as my superclass and also remember the original values of the model at the time the cache is built. With this information I am able to detect edit conflicts and can prevent accidental loss of data by merging the changes.'>

    hasConflict [
	"Answer ==true==, if there is an edit conflict."

	<category: 'testing'>
	^self hasChanged and: [self isDifferent: self original to: self pullRaw]
    ]

    original [
	<category: 'accessing'>
	^original
    ]

    reset [
	<category: 'actions'>
	super reset.
	self setOriginal: self pullRaw
    ]

    setOriginal: aDictionary [
	<category: 'initialization'>
	original := aDictionary
    ]

    validate [
	<category: 'actions'>
	self hasConflict ifFalse: [^super validate].
	self reset.
	MAConflictError description: self description
	    signal: self description conflictErrorMessage
    ]
]



MAMemento subclass: MAStraitMemento [
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I am a memento that forwards read- and write-access directly to the model. I can mostly be replaced with the model itself.'>

    MAStraitMemento class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    readUsing: aDescription [
	<category: 'private'>
	^(self model readUsing: aDescription) ifNil: [aDescription default]
    ]

    write: anObject using: aDescription [
	<category: 'private'>
	self model write: anObject using: aDescription
    ]
]



Object subclass: MASortBlock [
    | accessor selector |
    
    <category: 'Magritte-Model-Utility'>
    <comment: nil>

    MASortBlock class >> accessor: anAccessor selector: aSelector [
	<category: 'instance-creation'>
	^self basicNew initializeAccessor: anAccessor selector: aSelector
    ]

    MASortBlock class >> selector: aSelector [
	<category: 'instance-creation'>
	^self accessor: MAIdentityAccessor new selector: aSelector
    ]

    fixTemps [
	<category: 'actions'>
	
    ]

    initializeAccessor: anAccessor selector: aSelector [
	<category: 'initialize-release'>
	accessor := anAccessor asAccessor.
	selector := aSelector
    ]

    value: aFirstObject value: aSecondObject [
	<category: 'evaluating'>
	^(accessor read: aFirstObject) perform: selector
	    with: (accessor read: aSecondObject)
    ]
]



Object subclass: MATableModel [
    | rowCount columnCount contents |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I am a model class representing a table within the Magritte framework. Internally I store my cells within a flat array, however users may access data giving ''''row'''' and ''''column'''' coordinates with ==#at:at:== and ==#at:at:put:==. I can support reshaping myself, but of course this might lead to loss of data-cells.'>

    MATableModel class >> rows: aRowCount columns: aColumnCount [
	<category: 'instance-creation'>
	^self 
	    rows: aRowCount
	    columns: aColumnCount
	    contents: (Array new: aRowCount * aColumnCount)
    ]

    MATableModel class >> rows: aRowCount columns: aColumnCount contents: anArray [
	<category: 'instance-creation'>
	^(self new)
	    setRowCount: aRowCount;
	    setColumnCount: aColumnCount;
	    setContents: anArray;
	    yourself
    ]

    = aTable [
	<category: 'comparing'>
	^self species = aTable species and: 
		[self rowCount = aTable rowCount and: 
			[self columnCount = aTable columnCount 
			    and: [self contents = aTable contents]]]
    ]

    at: aRowIndex at: aColumnIndex [
	"Answer the contents of ==aRowIndex== and ==aColumnIndex==. Raises an error if the coordinates are out of bounds."

	<category: 'accessing'>
	self checkAt: aRowIndex at: aColumnIndex.
	^self uncheckedAt: aRowIndex at: aColumnIndex
    ]

    at: aRowIndex at: aColumnIndex put: aValue [
	"Set the contents of ==aRowIndex== and ==aColumnIndex==> to ==aValue==. Raises an error if the coordinates are out of bounds."

	<category: 'accessing'>
	self checkAt: aRowIndex at: aColumnIndex.
	^self 
	    uncheckedAt: aRowIndex
	    at: aColumnIndex
	    put: aValue
    ]

    checkAt: aRowIndex at: aColumnIndex [
	<category: 'private'>
	(aRowIndex between: 1 and: self rowCount) 
	    ifFalse: [self error: 'Row subscript out of range.'].
	(aColumnIndex between: 1 and: self columnCount) 
	    ifFalse: [self error: 'Column subscript out of range.']
    ]

    collect: aBlock [
	<category: 'enumeration'>
	| copy |
	copy := self copyEmpty.
	self do: 
		[:row :col :val | 
		copy 
		    at: row
		    at: col
		    put: (aBlock 
			    value: row
			    value: col
			    value: val)].
	^copy
    ]

    columnCount [
	"Answer the column count of the table."

	<category: 'accessing'>
	^columnCount
    ]

    contents [
	<category: 'accessing'>
	^contents
    ]

    copyEmpty [
	<category: 'copying'>
	^self class rows: self rowCount columns: self columnCount
    ]

    copyRows: aRowCount columns: aColumnCount [
	<category: 'copying'>
	| table |
	table := self class rows: aRowCount columns: aColumnCount.
	1 to: (self rowCount min: aRowCount)
	    do: 
		[:row | 
		1 to: (self columnCount min: aColumnCount)
		    do: 
			[:col | 
			table 
			    uncheckedAt: row
			    at: col
			    put: (self uncheckedAt: row at: col)]].
	^table
    ]

    do: aBlock [
	<category: 'enumeration'>
	1 to: self rowCount
	    do: 
		[:row | 
		1 to: self columnCount
		    do: 
			[:col | 
			aBlock 
			    value: row
			    value: col
			    value: (self uncheckedAt: row at: col)]]
    ]

    hash [
	<category: 'comparing'>
	^self contents hash
    ]

    indexAt: aRowIndex at: aColumnIndex [
	<category: 'private'>
	^(aRowIndex - 1) * self columnCount + aColumnIndex
    ]

    pointAt: anIndex [
	<category: 'private'>
	^Point x: (anIndex - 1) // self columnCount + 1
	    y: (anIndex - 1) \\ self columnCount + 1
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	self setContents: self contents copy
    ]

    reshapeRows: aRowCount columns: aColumnCount [
	"Change the size of the receiving table to ==aRowCount== times ==aColumnCount==, throwing away elements that are cut off and initializing empty cells with ==nil==."

	<category: 'operations'>
	self 
	    setContents: (self copyRows: aRowCount columns: aColumnCount) contents.
	self
	    setRowCount: aRowCount;
	    setColumnCount: aColumnCount
    ]

    rowCount [
	"Answer the row count of the table."

	<category: 'accessing'>
	^rowCount
    ]

    setColumnCount: anInteger [
	<category: 'initialization'>
	columnCount := anInteger
    ]

    setContents: anArray [
	<category: 'initialization'>
	contents := anArray
    ]

    setRowCount: anInteger [
	<category: 'initialization'>
	rowCount := anInteger
    ]

    uncheckedAt: aRowIndex at: aColumnIndex [
	<category: 'accessing'>
	^self contents at: (self indexAt: aRowIndex at: aColumnIndex)
    ]

    uncheckedAt: aRowIndex at: aColumnIndex put: aValue [
	<category: 'accessing'>
	^self contents at: (self indexAt: aRowIndex at: aColumnIndex) put: aValue
    ]
]



Object subclass: MAVisitor [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: 'I am a visitor responsible to visit Magritte descriptions. I am an abstract class providing a default implementation for concrete visitors. The protocol I am implementing reflects the hierarchy of *MADescription* with its subclasses so that visiting a specific class automatically calls less specific implementations in case the specific implementation has been left out. The code was automatically created using code on my class-side.'>

    MAVisitor class >> buildVisitorHierarchyForClass: aClass selector: aBlock classified: aSelector [
	"self buildVisitorHierarchyForClass: MADescription selector: [ :class | 'visit' , (class name allButFirst: 2) , ':' ] classified: #'visiting-description'"

	<category: 'private'>
	aClass withAllSubclassesDo: 
		[:class | 
		(class category startsWith: 'Magritte') 
		    ifTrue: 
			[self 
			    compile: (String streamContents: 
					[:stream | 
					stream
					    nextPutAll: (aBlock value: class);
					    nextPutAll: ' anObject';
					    cr.
					class = aClass 
					    ifFalse: 
						[stream
						    tab;
						    nextPutAll: 'self ';
						    nextPutAll: (aBlock value: class superclass);
						    nextPutAll: ' anObject.']])
			    classified: aSelector.
			class 
			    compile: (String streamContents: 
					[:stream | 
					stream
					    nextPutAll: 'acceptMagritte: aVisitor';
					    cr.
					stream
					    tab;
					    nextPutAll: 'aVisitor ';
					    nextPutAll: (aBlock value: class);
					    nextPutAll: ' self.'])
			    classified: #visiting]]
    ]

    visit: anObject [
	"Visit ==anObject== with the receiving visitor."

	<category: 'visiting'>
	anObject acceptMagritte: self
    ]

    visitAll: aCollection [
	"Visit all elements of ==aCollection== with the receiving visitor."

	<category: 'visiting'>
	aCollection do: [:each | self visit: each]
    ]

    visitBooleanDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitClassDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitContainer: anObject [
	<category: 'visiting-description'>
	self visitDescription: anObject
    ]

    visitDateDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitDescription: anObject [
	<category: 'visiting-description'>
	
    ]

    visitDurationDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitElementDescription: anObject [
	<category: 'visiting-description'>
	self visitDescription: anObject
    ]

    visitFileDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitMagnitudeDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitMemoDescription: anObject [
	<category: 'visiting-description'>
	self visitStringDescription: anObject
    ]

    visitMultipleOptionDescription: anObject [
	<category: 'visiting-description'>
	self visitOptionDescription: anObject
    ]

    visitNumberDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitOptionDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]

    visitPasswordDescription: anObject [
	<category: 'visiting-description'>
	self visitStringDescription: anObject
    ]

    visitPriorityContainer: anObject [
	<category: 'visiting-description'>
	self visitContainer: anObject
    ]

    visitReferenceDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]

    visitReportContainer: anObject [
	<category: 'visiting-description'>
	self visitContainer: anObject
    ]

    visitSingleOptionDescription: anObject [
	<category: 'visiting-description'>
	self visitOptionDescription: anObject
    ]

    visitStringDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitSymbolDescription: anObject [
	<category: 'visiting-description'>
	self visitStringDescription: anObject
    ]

    visitTableDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]

    visitTableReference: anObject [
	<category: 'visiting-description'>
	^self visitReferenceDescription: anObject
    ]

    visitTimeDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitTimeStampDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitToManyRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitRelationDescription: anObject
    ]

    visitToManyScalarRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitToManyRelationDescription: anObject
    ]

    visitToOneRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitRelationDescription: anObject
    ]

    visitTokenDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]
]



MAVisitor subclass: MAGraphVisitor [
    | seen object |
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    initialize [
	<category: 'initialization'>
	super initialize.
	seen := IdentitySet new
    ]

    object [
	<category: 'accessing'>
	^object
    ]

    use: anObject during: aBlock [
	<category: 'private'>
	| previous |
	(seen includes: anObject) ifTrue: [^self].
	anObject isNil ifFalse: [seen add: anObject].
	previous := object.
	object := anObject.
	aBlock ensure: [object := previous]
    ]
]



MAGraphVisitor subclass: MAValidatorVisitor [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    MAValidatorVisitor class >> on: anObject description: aDescription [
	<category: 'instance-creation'>
	^self new on: anObject description: aDescription
    ]

    on: anObject description: aDescription [
	<category: 'initialization'>
	self use: anObject during: [self visit: aDescription]
    ]

    validate: anObject using: aDescription [
	<category: 'private'>
	aDescription validateRequired: anObject.
	anObject ifNil: [^self].
	aDescription
	    validateKind: anObject;
	    validateSpecific: anObject;
	    validateConditions: anObject
    ]

    visit: aDescription [
	<category: 'visiting'>
	(aDescription isVisible and: [aDescription isReadonly not]) 
	    ifTrue: [super visit: aDescription]
    ]

    visitContainer: aDescription [
	<category: 'visiting-descriptions'>
	super visitContainer: aDescription.
	self object ifNil: [^self].
	aDescription 
	    do: [:each | self use: (object readUsing: each) during: [self visit: each]]
    ]

    visitDescription: aDescription [
	"Validate the current object using aDescription within an exception handler to avoid running further tests that might cause error-cascades."

	<category: 'visiting-descriptions'>
	[self validate: self object using: aDescription] on: MAValidationError
	    do: 
		[:err | 
		err isResumable 
		    ifTrue: [err pass]
		    ifFalse: 
			[err
			    beResumable;
			    signal]]
    ]

    visitTableDescription: aDescription [
	<category: 'visiting-descriptions'>
	super visitTableDescription: aDescription.
	self object ifNil: [^self].
	self object contents 
	    do: [:each | self use: each during: [self visit: aDescription reference]]
    ]
]



MAVisitor subclass: MAStreamingVisitor [
    | stream object |
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    contents [
	<category: 'streaming'>
	^self stream contents
    ]

    object [
	<category: 'accessing'>
	^object
    ]

    object: anObject [
	<category: 'accessing'>
	object := anObject
    ]

    object: anObject during: aBlock [
	<category: 'private'>
	| previous |
	previous := self object.
	self object: anObject.
	aBlock ensure: [self object: previous]
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]
]



MAStreamingVisitor subclass: MAReader [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    MAReader class >> read: aStream description: aDescription [
	<category: 'instance creation'>
	^self new read: aStream description: aDescription
    ]

    error: aString [
	<category: 'private'>
	MAReadError signal: aString
    ]

    read: aStream description: aDescription [
	<category: 'visiting'>
	self
	    stream: aStream;
	    visit: aDescription.
	^self object
    ]
]



MAReader subclass: MAStringReader [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    read: aStream description: aDescription [
	<category: 'visiting'>
	^aStream atEnd ifFalse: [super read: aStream description: aDescription]
    ]

    visitBooleanDescription: aDescription [
	<category: 'visiting-description'>
	(aDescription trueString = self contents 
	    or: [aDescription trueStrings includes: self contents]) 
		ifTrue: [^self object: true].
	(aDescription falseString = self contents 
	    or: [aDescription falseStrings includes: self contents]) 
		ifTrue: [^self object: false].
	MAReadError signal
    ]

    visitClassDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitContainer: anObject [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitDurationDescription: aDescription [
	<category: 'visiting-description'>
	| contents |
	contents := self contents.
	contents isEmpty ifTrue: [MAReadError signal].
	(contents occurrencesOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents indexOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents occurrencesOf: $.) > 1 ifTrue: [MAReadError signal].
	(contents allSatisfy: [:each | '-0123456789.:' includes: each]) 
	    ifFalse: [MAReadError signal].
	super visitDurationDescription: aDescription
    ]

    visitElementDescription: aDescription [
	"This implementation can be very dangerous and might lead to a potential security hole (this is tested), since the default implementation of #readFrom: in Object evaluates the expression to find its value. Most subclasses like Number, Date, Time, ... override this implementation, but some others (like Boolean) do not."

	<category: 'visiting-description'>
	self object: ([aDescription kind readFrom: self stream] on: Error
		    do: [:err | MAReadError signal: err messageText])
    ]

    visitFileDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitMultipleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self 
	    object: (Array streamContents: 
			[:output | 
			[self stream atEnd] whileFalse: 
				[output 
				    nextPut: (aDescription reference fromString: (self stream upTo: $,)).
				self stream peek = Character space ifTrue: [self stream next]]])
    ]

    visitNumberDescription: aDescription [
	<category: 'visiting-description'>
	| contents |
	contents := self contents.
	contents isEmpty ifTrue: [MAReadError signal].
	(contents occurrencesOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents indexOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents occurrencesOf: $.) > 1 ifTrue: [MAReadError signal].
	(contents allSatisfy: [:each | '+-0123456789.eE' includes: each]) 
	    ifFalse: [MAReadError signal].
	super visitNumberDescription: aDescription
    ]

    visitRelationDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitSingleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self visit: aDescription reference
    ]

    visitStringDescription: aDescription [
	<category: 'visiting-description'>
	self object: self contents
    ]

    visitSymbolDescription: aDescription [
	<category: 'visiting-description'>
	self object: self contents asSymbol
    ]

    visitTableDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitTimeDescription: aDescription [
	<category: 'visiting-description'>
	| string |
	string := self contents.
	(string notEmpty 
	    and: [string allSatisfy: [:each | '0123456789: apm' includes: each]]) 
		ifFalse: [MAReadError signal].
	self object: (aDescription kind readFrom: string readStream)
    ]

    visitTokenDescription: aDescription [
	<category: 'visiting-description'>
	self 
	    object: (aDescription kind streamContents: 
			[:output | 
			[self stream atEnd] whileFalse: 
				[output 
				    nextPut: (aDescription reference fromString: (self stream upTo: $ ))]])
    ]
]



MAStreamingVisitor subclass: MAWriter [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    MAWriter class >> write: anObject [
	<category: 'instance creation'>
	^self new write: anObject
    ]

    MAWriter class >> write: anObject description: aDescription [
	<category: 'instance creation'>
	^self new write: anObject description: aDescription
    ]

    MAWriter class >> write: anObject description: aDescription to: aStream [
	<category: 'instance creation'>
	^self new 
	    write: anObject
	    description: aDescription
	    to: aStream
    ]

    defaultWriteStream [
	<category: 'private'>
	self subclassResponsibility
    ]

    error: aString [
	<category: 'private'>
	MAWriteError signal: aString
    ]

    write: anObject [
	<category: 'visiting'>
	^self write: anObject description: anObject description
    ]

    write: anObject description: aDescription [
	<category: 'visiting'>
	^self 
	    write: anObject
	    description: aDescription
	    to: self defaultWriteStream
    ]

    write: anObject description: aDescription to: aStream [
	<category: 'visiting'>
	self
	    object: anObject;
	    stream: aStream;
	    visit: aDescription.
	^self contents
    ]
]



MAWriter subclass: MAStringWriter [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    defaultWriteStream [
	<category: 'private'>
	^String new writeStream
    ]

    visitBooleanDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: (self object 
		    ifTrue: [aDescription trueString]
		    ifFalse: [aDescription falseString])
    ]

    visitClassDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: self object label
    ]

    visitContainer: aDescription [
	<category: 'visiting-description'>
	aDescription do: 
		[:each | 
		each isVisible 
		    ifTrue: 
			[each stringWriter 
			    write: (self object readUsing: each)
			    description: each
			    to: stream.
			^self]]
    ]

    visitElementDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: self object asString
    ]

    visitFileDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: self object filename
    ]

    visitMultipleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    do: [:each | self object: each during: [self visit: aDescription reference]]
	    separatedBy: [self stream nextPutAll: ', ']
    ]

    visitSingleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self visit: aDescription reference
    ]

    visitTimeDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    print24: true
	    showSeconds: true
	    on: self stream
    ]

    visitTimeStampDescription: aDescription [
	<category: 'visiting-description'>
	(self stream)
	    print: self object asDate;
	    space.
	self stream print: self object asTime
    ]

    visitToManyRelationDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    do: [:each | self object: each during: [self visit: each description]]
	    separatedBy: [self stream nextPutAll: ', ']
    ]

    visitToOneRelationDescription: aDescription [
	<category: 'visiting-description'>
	self visit: self object description
    ]

    visitTokenDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    do: [:each | self object: each during: [self visit: aDescription reference]]
	    separatedBy: [self stream nextPutAll: ' ']
    ]

    write: anObject description: aDescription to: aStream [
	<category: 'visiting'>
	anObject isNil ifTrue: [^aDescription undefined].
	^super 
	    write: anObject
	    description: aDescription
	    to: aStream
    ]
]



Object class extend [

    description [
	<category: '*magritte-model-accessing'>
	^Magritte.MADescriptionBuilder for: self
    ]

]



Object extend [

    description [
	"Return the description of the reciever. Subclasses might override this message to return instance-based descriptions."

	<category: '*magritte-model-accessing'>
	^self class description
    ]

    isDescription [
	<category: '*magritte-model-testing'>
	^false
    ]

    mementoClass [
	"Return a class to be used to remember or cache the receiver, namely a memento object."

	<category: '*magritte-model-accessing'>
	^Magritte.MACheckedMemento
    ]

    readUsing: aDescription [
	"Dispatch the read-access to the receiver using the accessor of aDescription."

	<category: '*magritte-model-model'>
	^aDescription accessor read: self
    ]

    write: anObject using: aDescription [
	"Dispatch the write-access to the receiver of anObject using the accessor of aDescription."

	<category: '*magritte-model-model'>
	aDescription accessor write: anObject to: self
    ]

]



UndefinedObject extend [

    asAccessor [
	<category: '*magritte-model-converting'>
	^Magritte.MANullAccessor new
    ]

    label [
	<category: '*magritte-model-accessing'>
	^'n/a'
    ]

]



Integer extend [

    asFileSize [
	<category: '*magritte-model-converting'>
	#('B' 'KB' 'MB' 'GB' 'TB' 'PB' 'EB' 'ZB' 'YB') inject: self
	    into: 
		[:value :each | 
		value < 1024 
		    ifFalse: [value // 1024]
		    ifTrue: [^value asString , ' ' , each]]
    ]

]



Eval [
    MADescriptionBuilder initialize.
    MAExternalFileModel initialize.
    MAFileModel initialize.
    MAObject initialize
]

