"======================================================================
|
|   LC_MESSAGES support (GNU gettext MO files)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU Lesser
| General Public License for more details.
|
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"



LocaleConventions subclass: LcMessages [
    
    <comment: 'This object is a factory of LcMessagesDomain objects'>
    <category: 'i18n-Messages'>

    LcMessages class >> category [
	"Answer the environment variable used to determine the default
	 locale"

	<category: 'accessing'>
	^#LC_MESSAGES
    ]

    LcMessages class >> selector [
	"Answer the selector that accesses the receiver when sent to a Locale
	 object."

	<category: 'accessing'>
	^#messages
    ]

    territoryDirectory: rootDirectory [
	"Answer the directory holding MO files for the language, specific to
	 the territory, given the root directory of the locale data."

	<category: 'accessing'>
	^(super territoryDirectory: rootDirectory) , '/LC_MESSAGES'
    ]

    territoryDirectory [
	"Answer the directory holding MO files for the language, specific to
	 the territory"

	<category: 'accessing'>
	^self territoryDirectory: Locale rootDirectory
    ]

    languageDirectory: rootDirectory [
	"Answer the directory holding MO files for the language, given the
	 root directory of the locale data."

	<category: 'accessing'>
	^(super languageDirectory: rootDirectory) , '/LC_MESSAGES'
    ]

    languageDirectory [
	"Answer the directory holding MO files for the language"

	<category: 'accessing'>
	^self languageDirectory: Locale rootDirectory
    ]

    ? aString [
	"Answer an object for the aString domain, querying both the
	 language catalog (e.g. pt) and the territory catalog (e.g. pt_BR
	 or pt_PT)."

	<category: 'opening MO files'>
	^self domain: aString
    ]

    domain: aString [
	"Answer an object for the aString domain, querying both the
	 language catalog (e.g. pt) and the territory catalog (e.g. pt_BR
	 or pt_PT)."

	<category: 'opening MO files'>
	^self domain: aString localeDirectory: Locale rootDirectory
    ]

    domain: aString localeDirectory: rootDirectory [
	"Answer an object for the aString domain, querying both the
	 language catalog (e.g. pt) and the territory catalog (e.g. pt_BR
	 or pt_PT). The localeDirectory is usually '<installprefix>/share/locale'."

	<category: 'opening MO files'>
	| primary secondary |
	self isPosixLocale ifTrue: [^self dummyDomain].
	primary := self domain: aString
		    directory: (self territoryDirectory: rootDirectory).
	secondary := self domain: aString
		    directory: (self languageDirectory: rootDirectory).

	"If we got only one catalog, just use it. If we got more than one
	 catalog, combine them through a LcMessagesTerritoryDomain."
	primary isNil 
	    ifTrue: 
		[secondary isNil ifFalse: [^secondary].
		^self dummyDomain].
	secondary isNil ifTrue: [^primary].
	^(LcMessagesTerritoryDomain basicNew)
	    id: self id;
	    primary: primary secondary: secondary yourself
    ]

    domain: aString directory: dirName [
	"Answer an object for the aString domain, looking in the given
	 directory for a valid MO file."

	<category: 'private'>
	| catalog |
	self isPosixLocale ifTrue: [^self dummyDomain].
	^LcMessagesDomain id: self id
	    on: dirName / aString , '.mo'
    ]

    dummyDomain [
	"Answer a dummy domain that does not do a translation"

	<category: 'private'>
	^LcMessagesDummyDomain basicNew id: self id
    ]
]



LocaleData subclass: LcMessagesDomain [
    | lastString lastCache messageCache pluralCache sourceCharset |
    
    <comment: 'This object is an abstract superclass for message domains (catalogs).
It contains methods to create instances of its subclasses, but they are
commonly used only by LcMessages.

Translations are accessed using either #at: or the shortcut binary
messages `?''.	This way, common idioms to access translated strings
will be

     string := NLS? ''abc''.
     string := self? ''abc''.

(in the first case NLS is a class variable, in the second the receiver
implements #? through delegation) which is only five or six characters
longer than the traditional

     string := ''abc''.

(cfr. the _("abc") idiom used by GNU gettext)'>
    <category: 'i18n-Messages'>

    LcMessagesDomain class >> id: anArray on: aFileName [
	"Create an instance of the receiver with a given locale identifier
	 from a path to the MO file"

	<category: 'opening MO files'>
	| stream found file |
	found := false.
	file := aFileName asFile.
	file exists
	    ifTrue: 
		[stream := file readStream.
		found := 
			[stream littleEndianMagicNumber: #[222 18 4 149]
			    bigEndianMagicNumber: #[149 4 18 222].
			stream nextLong = 0] 
				on: Error
				do: [:ex | ex return: false].
		found ifTrue: [stream reset] ifFalse: [stream close]].
	^found 
	    ifTrue: 
		[(LcMessagesMoFileVersion0 basicNew)
		    id: anArray;
		    initialize: stream]
	    ifFalse: [nil]
    ]

    ? aString [
	"Answer the translation of `aString', or answer aString itself
	 if none is available."

	<category: 'querying'>
	^self at: aString
    ]

    at: aString [
	"Answer the translation of `aString', or answer aString itself
	 if none is available."

	<category: 'querying'>
	| translation |
	aString == lastString 
	    ifFalse: 
		[lastString := aString.
		"Check the cache first"
		translation := nil.
		messageCache isNil 
		    ifFalse: [translation := messageCache at: aString ifAbsent: [nil]].
		translation isNil 
		    ifTrue: 
			[translation := self primAt: aString.
			translation isNil 
			    ifTrue: [translation := aString]
			    ifFalse: 
				["Check whether we must transliterate the translation.
				 Note that if we go through the transliteration we
				 automatically build a cache."

				sourceCharset notNil 
				    ifTrue: 
					[translation := (EncodedStream 
						    on: translation
						    from: sourceCharset
						    to: self charset) contents]].
			messageCache isNil ifFalse: [messageCache at: aString put: translation]].
		lastCache := translation].
	^lastCache
    ]

    at: singularString plural: pluralString with: n [
	"Answer either the translation of pluralString with `%1' replaced by
	 n if n ~= 1, or the translation of singularString if n = 1."

	<category: 'querying'>
	| composedString translation translit |
	(composedString := String new: singularString size + pluralString size + 1)
	    replaceFrom: 1
		to: singularString size
		with: singularString
		startingAt: 1;
	    at: singularString size + 1 put: Character nul;
	    replaceFrom: singularString size + 2
		to: composedString size
		with: pluralString
		startingAt: 1.
	translation := self primAtPlural: composedString with: n.
	translation isNil 
	    ifTrue: [^n = 1 ifTrue: [singularString] ifFalse: [pluralString]].

	"Check whether we must transliterate the translation.
	 Note that if we go through the transliteration we
	 automatically build a cache."
	sourceCharset notNil 
	    ifTrue: 
		[translit := pluralCache at: translation ifAbsent: [nil].
		translit isNil 
		    ifTrue: 
			[translit := (EncodedStream 
				    on: translation
				    from: sourceCharset
				    to: self charset) contents.
			pluralCache at: translation put: translit].
		translation := translit].
	^translation
    ]

    at: aString put: anotherString [
	<category: 'querying'>
	self shouldNotImplement
    ]

    translatorInformation [
	"Answer information on the translation, or nil if there is none.
	 This information is stored as the `translation' of an empty string."

	<category: 'querying'>
	| info |
	info := self primAt: ''.
	^info
    ]

    translatorInformationAt: key [
	"Answer information on the translation associated to a given key"

	<category: 'querying'>
	| config valueIndex valueEnd |
	config := self translatorInformation.
	valueIndex := config indexOfSubCollection: key , ': ' ifAbsent: [0].
	valueIndex = 0 ifTrue: [^nil].
	valueEnd := config indexOf: Character nl startingAt: valueIndex.
	valueEnd = 0 ifTrue: [^nil].
	^config copyFrom: valueIndex + key size + 2 to: valueEnd - 1
    ]

    translatorInformationAt: key at: subkey [
	"Answer information on the translation associated to a given key
	 and to a subkey of the key"

	<category: 'querying'>
	| config valueIndex valueEnd |
	config := self translatorInformationAt: key.
	valueIndex := config indexOfSubCollection: subkey , '=' ifAbsent: [0].
	valueIndex = 0 ifTrue: [^nil].
	valueEnd := config 
		    indexOf: $;
		    startingAt: valueIndex
		    ifAbsent: [config size + 1].
	^config copyFrom: valueIndex + subkey size + 1 to: valueEnd - 1
    ]

    shouldCache [
	"Answer whether translations should be cached.  Never override
	 this method to always answer false, because that would cause
	 bugs when transliteration is being used."

	<category: 'handling the cache'>
	^sourceCharset notNil
    ]

    flush [
	"Flush the receiver's cache of translations"

	<category: 'handling the cache'>
	lastString := lastCache := nil.

	"Check if we need to transliterate from one charset to another"
	sourceCharset := self translatorInformationAt: 'Content-Type' at: 'charset'.
	sourceCharset isNil 
	    ifFalse: 
		[sourceCharset asUppercase = self charset asUppercase 
		    ifTrue: [sourceCharset := nil]
		    ifFalse: [sourceCharset := sourceCharset asSymbol]].
	self shouldCache 
	    ifTrue: 
		[messageCache := LookupTable new.
		pluralCache := LookupTable new]
    ]

    primAt: aString [
	"Answer the translation of `aString', or answer nil
	 if none is available.  This sits below the caching and
	 transliteration operated by #?."

	<category: 'private'>
	self subclassResponsibility
    ]

    primAtPlural: composedString with: n [
	"Answer a translation of composedString (two nul-separated strings
	 with the English singular and plural) valid when %1 is replaced
	 with `n', or nil if none could be found.  This sits below the
	 caching and transliteration layer."

	<category: 'private'>
	self subclassResponsibility
    ]
]



LcMessagesDomain subclass: LcMessagesTerritoryDomain [
    | primary secondary |
    
    <comment: 'This object asks for strings to a primary domain (e.g. it_IT)
and a secondary one (e.g. it).'>
    <category: 'i18n-Messages'>

    LcMessagesTerritoryDomain class >> primary: domain1 secondary: domain2 [
	"Answer an instance of the receiver that queries, in sequence,
	 domain1 and domain2"

	<category: 'instance creation'>
	^self new primary: domain1 secondary: domain2
    ]

    primary: domain1 secondary: domain2 [
	<category: 'private'>
	primary := domain1.
	secondary := domain2.
	self flush
    ]

    primary [
	"Answer the first domain"

	<category: 'private'>
	^primary
    ]

    secondary [
	"Answer the second domain"

	<category: 'private'>
	^secondary
    ]

    primAt: aString [
	"Answer the translation of `aString', or answer nil
	 if none is available.  This sits below the caching and
	 transliteration operated by #?."

	<category: 'private'>
	| translation |
	translation := primary primAt: aString.
	translation isNil ifFalse: [^translation].
	^secondary primAt: aString
    ]

    primAtPlural: composedString with: n [
	"Answer a translation of composedString (two nul-separated strings
	 with the English singular and plural) valid when %1 is replaced
	 with `n', or nil if none could be found.  This sits below the
	 caching and transliteration layer."

	<category: 'private'>
	| primaryTranslation |
	primaryTranslation := primary primAtPlural: composedString with: n.
	^primaryTranslation isNil 
	    ifTrue: [secondary primAtPlural: composedString with: n]
	    ifFalse: [primaryTranslation]
    ]

    shouldCache [
	"Answer whether translations should be cached"

	"Yes we cache them here because we bypass the caches in primary
	 and secondary."

	<category: 'private'>
	^true
    ]
]



LcMessagesDomain subclass: LcMessagesDummyDomain [
    
    <comment: 'This object does no attempt to translate strings, returning
instead the same string passed as an argument to #?.'>
    <category: 'i18n-Messages'>

    primAt: aString [
	"Answer the translation of `aString', or answer nil
	 if none is available (which always happens in this class)."

	<category: 'private'>
	^nil
    ]

    primAtPlural: composedString with: n [
	"Answer a translation of composedString (two nul-separated strings
	 with the English singular and plural) valid when %1 is replaced
	 with `n', or nil if none could be found (which always happens in
	 this class)."

	<category: 'private'>
	^nil
    ]
]



LcMessagesDomain subclass: LcMessagesCatalog [
    | file |
    
    <comment: 'This object is an abstract superclass of objects that retrieve
translated strings from a file.'>
    <category: 'i18n-Messages'>

    file [
	"Answer the file from which we read the translations"

	<category: 'private'>
	^file
    ]

    initialize: stream [
	<category: 'private'>
	file := stream.
	self flush
    ]
]



LcMessagesCatalog subclass: LcMessagesMoFileVersion0 [
    | original translated firstCharMap emptyGroup pluralExpression |
    
    <comment: 'This object is an concrete class that retrieves translated strings
from a GNU gettext MO file.  The class method #fileFormatDescription
contains an explanation of the file format.'>
    <category: 'i18n-Messages'>

    DefaultPluralExpressions := nil.

    LcMessagesMoFileVersion0 class >> fileFormatDescription [
	"The Format of GNU MO Files (excerpt of the GNU gettext manual)
	 ==============================================================
	 
	 The format of the generated MO files is best described by a picture,
	 which appears below.
	 
	 The first two words serve the identification of the file.  The magic
	 number will always signal GNU MO files.	 The number is stored in the
	 byte order of the generating machine, so the magic number really is two
	 numbers: `0x950412de' and `0xde120495'.	 The second word describes the
	 current revision of the file format.  For now the revision is 0.  This
	 might change in future versions, and ensures that the readers of MO
	 files can distinguish new formats from old ones, so that both can be
	 handled correctly.  The version is kept separate from the magic number,
	 instead of using different magic numbers for different formats, mainly
	 because `/etc/magic' is not updated often.  It might be better to have
	 magic separated from internal format version identification.
	 
	 Follow a number of pointers to later tables in the file, allowing
	 for the extension of the prefix part of MO files without having to
	 recompile programs reading them.  This might become useful for later
	 inserting a few flag bits, indication about the charset used, new
	 tables, or other things.
	 
	 Then, at offset O and offset T in the picture, two tables of string
	 descriptors can be found.  In both tables, each string descriptor uses
	 two 32 bits integers, one for the string length, another for the offset
	 of the string in the MO file, counting in bytes from the start of the
	 file.  The first table contains descriptors for the original strings,
	 and is sorted so the original strings are in increasing lexicographical
	 order.	The second table contains descriptors for the translated
	 strings, and is parallel to the first table: to find the corresponding
	 translation one has to access the array slot in the second array with
	 the same index.
	 
	 Having the original strings sorted enables the use of simple binary
	 search, for when the MO file does not contain an hashing table, or for
	 when it is not practical to use the hashing table provided in the MO
	 file.  This also has another advantage, as the empty string in a PO
	 file GNU `gettext' is usually *translated* into some system information
	 attached to that particular MO file, and the empty string necessarily
	 becomes the first in both the original and translated tables, making
	 the system information very easy to find.
	 
	 The size S of the hash table can be zero.  In this case, the hash
	 table itself is not contained in the MO file.  Some people might prefer
	 this because a precomputed hashing table takes disk space, and does not
	 win *that* much speed.	The hash table contains indices to the sorted
	 array of strings in the MO file.  Conflict resolution is done by double
	 hashing.  The precise hashing algorithm used is fairly dependent of GNU
	 `gettext' code, and is not documented here.
	 
	 As for the strings themselves, they follow the hash file, and each
	 is terminated with a <NUL>, and this <NUL> is not counted in the length
	 which appears in the string descriptor.	 The `msgfmt' program has an
	 option selecting the alignment for MO file strings.  With this option,
	 each string is separately aligned so it starts at an offset which is a
	 multiple of the alignment value.  On some RISC machines, a correct
	 alignment will speed things up.
	 
	 Nothing prevents a MO file from having embedded <NUL>s in strings.
	 However, the program interface currently used already presumes that
	 strings are <NUL> terminated, so embedded <NUL>s are somewhat useless.
	 But MO file format is general enough so other interfaces would be later
	 possible, if for example, we ever want to implement wide characters
	 right in MO files, where <NUL> bytes may accidently appear.
	 
	 This particular issue has been strongly debated in the GNU `gettext'
	 development forum, and it is expectable that MO file format will evolve
	 or change over time.  It is even possible that many formats may later
	 be supported concurrently.  But surely, we have to start somewhere, and
	 the MO file format described here is a good start.  Nothing is cast in
	 concrete, and the format may later evolve fairly easily, so we should
	 feel comfortable with the current approach.
	 
	 byte
	 +------------------------------------------+
	 0  | magic number = 0x950412de		     |
	 |					     |
	 4  | file format revision = 0		     |
	 |					     |
	 8  | number of strings			     |	== N
	 |					     |
	 12  | offset of table with original strings    |	== O
	 |					     |
	 16  | offset of table with translation strings |	== T
	 |					     |
	 20  | size of hashing table		     |	== S
	 |					     |
	 24  | offset of hashing table		     |	== H
	 |					     |
	 .					     .
	 .    (possibly more entries later)	     .
	 .					     .
	 |					     |
	 O  | length & offset 0th string	----------------.
	 O + 8  | length & offset 1st string	------------------.
	 ...					  ...	| |
	 O + ((N-1)*8)| length & offset (N-1)th string	     |	| |
	 |					     |	| |
	 T  | length & offset 0th translation  ---------------.
	 T + 8  | length & offset 1st translation  -----------------.
	 ...					  ...	| | | |
	 T + ((N-1)*8)| length & offset (N-1)th translation	     |	| | | |
	 |					     |	| | | |
	 H  | start hash table			     |	| | | |
	 ...					  ...	| | | |
	 H + S * 4  | end hash table			     |	| | | |
	 |					     |	| | | |
	 | NUL terminated 0th string  <----------------' | | |
	 |					     |	  | | |
	 | NUL terminated 1st string  <------------------' | |
	 |					     |	    | |
	 ...					  ...	    | |
	 |					     |	    | |
	 | NUL terminated 0th translation  <---------------' |
	 |					     |	      |
	 | NUL terminated 1st translation  <-----------------'
	 |					     |
	 ...					  ...
	 |					     |
	 +------------------------------------------+
	 
	 Locating Message Catalog Files
	 ------------------------------
	 
	 Because many different languages for many different packages have to
	 be stored we need some way to add these information to file message
	 catalog files.	The way usually used in Unix environments is have this
	 encoding in the file name.  This is also done here.  The directory name
	 given in `bindtextdomain's second argument (or the default directory),
	 followed by the value and name of the locale and the domain name are
	 concatenated:
	 
	 DIR_NAME/LOCALE/LC_CATEGORY/DOMAIN_NAME.mo
	 
	 The default value for DIR_NAME is system specific.  For the GNU
	 library, and for packages adhering to its conventions, it's:
	 /usr/local/share/locale
	 
	 LOCALE is the value of the locale whose name is this `LC_CATEGORY'.
	 For `gettext' and `dgettext' this locale is always `LC_MESSAGES'."

	<category: 'documentation'>
	
    ]

    LcMessagesMoFileVersion0 class >> pluralExpressionFor: locale ifAbsent: aBlock [
	"Answer a RunTimeExpression yielding the plural form for the given
	 language and territory, if one is known, else evaluate aBlock and
	 answer it."

	<category: 'plurals'>
	^DefaultPluralExpressions at: locale language , '_' , locale territory
	    ifAbsent: [DefaultPluralExpressions at: locale language ifAbsent: aBlock]
    ]

    LcMessagesMoFileVersion0 class >> initialize [
	"Initialize a table with the expressions computing the plurals
	 for the most common languages"

	<category: 'plurals'>
	DefaultPluralExpressions := LookupTable new: 32.
	#(#(#('hu' 'ja' 'ko' 'tr') '0') #(#('da' 'nl' 'en' 'de' 'nb' 'no' 'nn' 'sv' 'et' 'fi' 'el' 'he' 'it' 'pt' 'es' 'eo') 'n != 1') #(#('fr' 'pt_BR') 'n > 1') #(#('lv') 'n%10==1 && n%100!=11 ? 0 : n != 0 ? 1 : 2') #(#('ga') 'n > 0 && n < 3 ? n-1 : 2') #(#('lt') 'n%10==1 && n%100!=11 ? 0
                   : n%10>=2 && (n%100<10 || n%100>=20) ? 1 : 2') #(#('hr' 'cs' 'ru' 'sk' 'uk') 'n%10==1 && n%100!=11 ? 0 
                   : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2') #(#('pl') 'n==1 ? 0 
                   : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2') #(#('sl') 'n%100==1 ? 0 : n%100==2 ? 1 : n%100==3 || n%100==4 ? 2 : 3')) 
	    do: 
		[:each | 
		"latvian"

		"irish"

		| expr |
		expr := RunTimeExpression on: (each at: 2).
		(each at: 1) 
		    do: [:language | DefaultPluralExpressions at: language put: expr]]
    ]

    shouldCache [
	"Answer true, we always cache translations if they are read from
	 a file"

	<category: 'flushing the cache'>
	^true
    ]

    flush [
	"Flush the cache and reread the catalog's metadata."

	<category: 'flushing the cache'>
	| n oOfs tOfs sOfs hOfs |
	self file position: 8.
	n := self file nextLong.
	oOfs := self file nextLong.
	tOfs := self file nextLong.
	sOfs := self file nextLong.
	hOfs := self file nextLong.
	original := self readSegmentTable: oOfs size: n.
	translated := self readSegmentTable: tOfs size: n.
	self getFirstChars.
	super flush
    ]

    getFirstChars [
	"This implementation does a limited form of bucketing
	 to supply the speed lost by not implementing hashing. This
	 method prepares a table that subdivides strings according
	 to their first character."

	<category: 'private'>
	| lastIndex lastFirst |
	firstCharMap := Array new: 256.
	original doWithIndex: 
		[:segment :n | 
		| interval first |
		segment size = 0 
		    ifTrue: [emptyGroup := n to: n]
		    ifFalse: 
			["Read first character of the string"

			self file position: segment filePos.
			first := self file nextByte + 1.
			interval := firstCharMap at: first.
			interval isNil ifTrue: [firstCharMap at: first put: n]]].
	firstCharMap doWithIndex: 
		[:thisFirst :index | 
		thisFirst notNil 
		    ifTrue: 
			["Store an Interval at the lastIndex-th position"

			lastIndex notNil 
			    ifTrue: [firstCharMap at: lastIndex put: (lastFirst to: thisFirst - 1)].
			lastIndex := index.
			lastFirst := thisFirst]].

	"Finish the last position too"
	lastIndex notNil 
	    ifTrue: [firstCharMap at: lastIndex put: (lastFirst to: original size)]
    ]

    readSegmentTable: offset size: n [
	"Answer a table of n FileStreamSegments loaded from the
	 MO file, starting at the requested offset."

	<category: 'private'>
	self file position: offset.
	^(1 to: n) collect: 
		[:unused | 
		| size |
		size := self file nextLong.
		FileStreamSegment 
		    on: self file
		    startingAt: self file nextLong
		    for: size]
    ]

    binarySearch: aString from: low to: high [
	"Do a binary search on `original', searching for aString"

	<category: 'private'>
	| i j mid originalString result |
	i := low.
	j := high.
	[i > j] whileFalse: 
		[mid := (i + j + 1) // 2.
		originalString := original at: mid.
		originalString isString 
		    ifFalse: [originalString become: originalString asString].
		result := aString compareTo: originalString.
		result = 0 ifTrue: [^mid].
		result < 0 ifTrue: [j := mid - 1] ifFalse: [i := mid + 1]].
	^nil
    ]

    primAt: aString [
	"Translate aString, answer the translation or nil"

	<category: 'private'>
	| group n |
	group := aString isEmpty 
		    ifTrue: [emptyGroup]
		    ifFalse: [firstCharMap at: (aString at: 1) value + 1].
	group isNil ifTrue: [^nil].
	n := self 
		    binarySearch: aString
		    from: group first
		    to: group last.
	^n isNil ifTrue: [nil] ifFalse: [(translated at: n) asString]
    ]

    primAtPlural: composedString with: n [
	"Answer a translation of composedString (two nul-separated strings
	 with the English singular and plural) valid when %1 is replaced
	 with `n', or nil if none could be found.  This sits below the
	 caching and transliteration layer."

	<category: 'private'>
	"Why don't we call #at:, which would have the advantage of caching
	 the plural forms? Because #at: transliterates, and transliterating
	 at this point could cause bugs if nuls are massaged (e.g. UTF7, UCS4)."

	| pluralStrings index endIndex |
	pluralStrings := self primAt: composedString.
	pluralStrings isNil ifTrue: [^nil].

	"Find the start of the string in the composed string"
	index := 1.
	(self pluralFormFor: n) timesRepeat: 
		[index := 1 + (pluralStrings 
				    indexOf: Character nul
				    startingAt: index
				    ifAbsent: [pluralStrings size + 1])].

	"Find the end of the string in the composed string"
	index > pluralStrings size 
	    ifFalse: 
		[endIndex := (pluralStrings 
			    indexOf: Character nul
			    startingAt: index
			    ifAbsent: [pluralStrings size + 1]) - 1.
		^pluralStrings copyFrom: index to: endIndex].

	"Fallback case, use standard rule for Germanic languages."
	^nil
    ]

    pluralFormFor: n [
	"Answer the index of the plural form that must be used for a value
	 of `n'."

	<category: 'private'>
	^self pluralExpression value: n
    ]

    pluralExpression [
	"Answer a RunTimeExpression which picks the correct plural
	 form for the catalog"

	<category: 'private'>
	| config |
	pluralExpression isNil 
	    ifTrue: 
		[config := self translatorInformationAt: 'Plural-Forms' at: 'plural'.
		pluralExpression := config isNil 
			    ifFalse: [RunTimeExpression on: config]
			    ifTrue: 
				[self class pluralExpressionFor: self
				    ifAbsent: [RunTimeExpression on: '(n != 1)']]].
	^pluralExpression
    ]
]



FileStream subclass: BigEndianFileStream [
    
    <category: 'i18n-Messages'>
    <comment: 'Unlike ByteStream and FileStream, this retrieves integer numbers in
big-endian (68000, PowerPC, SPARC) order.'>

    nextBytes: n signed: signed [
	"Private - Get an integer out of the next anInteger bytes in the stream"

	<category: 'private - endianness switching'>
	| int |
	int := 0.
	int := self nextByte.
	(signed and: [int > 127]) ifTrue: [int := int - 256].
	int := int bitShift: n * 8 - 8.
	n * 8 - 16 to: 0
	    by: -8
	    do: [:i | int := int + (self nextByte bitShift: i)].
	^int
    ]

    nextPutBytes: n of: anInteger [
	"Private - Store the n least significant bytes of int in big-endian format"

	<category: 'private - endianness switching'>
	| int |
	int := anInteger < 0 
		    ifTrue: [anInteger + (1 bitShift: 8 * n)]
		    ifFalse: [anInteger].
	(8 - n) * 8 to: 0
	    by: 8
	    do: [:i | self nextPutByte: ((int bitShift: i) bitAnd: 255)]
    ]
]



FileSegment subclass: FileStreamSegment [
    
    <category: 'i18n-Messages'>
    <comment: 'Unlike FileSegment, this object assumes that the `file'' instance
variable is a FileStream, not a file name.'>

    withFileDo: aBlock [
	"Evaluate aBlock, passing a FileStream corresponding to the file"

	<category: 'basic'>
	^aBlock value: self getFile
    ]

    fileName [
	"Answer the name of the file containing the segment"

	<category: 'basic'>
	^self getFile name
    ]
]



FileStream extend [

    littleEndianMagicNumber: le bigEndianMagicNumber: be [
	"Change the receiver to a BigEndianFileStream if the
	 next bytes are equal to `be', do nothing if they're equal
	 to `le'; fail if the two parameters have different sizes,
	 or if neither of them matches the next bytes.  The position
	 in the file is not touched if matching fails, else it is
	 moved past the signature."

	<category: 'endianness checking'>
	| magic |
	le size = be size 
	    ifFalse: [self error: 'mismatching sizes for big-endian and little-endian'].
	magic := (self next: le size) asByteArray.
	magic = be ifTrue: [self changeClassTo: I18N.BigEndianFileStream].
	magic = le 
	    ifFalse: 
		[self skip: le size negated.
		self error: 'mismatching magic number']
    ]

]



Eval [
    LcMessagesMoFileVersion0 initialize
]

