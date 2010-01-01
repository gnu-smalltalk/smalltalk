"======================================================================
|
|   Localization and internationalization support
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2005, 2006, 2009 Free Software Foundation, Inc.
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
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: LocaleData [
    | id |
    
    <category: 'i18n-Messages'>
    <comment: 'I am an abstract superclass of objects that represent localization
information.'>

    ValidLanguages := nil.
    ValidTerritories := nil.
    DefaultTerritories := nil.
    DefaultCharsets := nil.
    Aliases := nil.

    LocaleData class >> territories [
	"ISO3166 territory codes"

	<category: 'database'>
	^#('AF' 'AL' 'DZ' 'AS' 'AD' 'AO' 'AI' 'AQ' 'AG' 'AR' 'AM' 'AW' 'AU' 'AT' 'AZ' 'BS' 'BH' 'BD' 'BB' 'BY' 'BE' 'BZ' 'BJ' 'BM' 'BT' 'BO' 'BA' 'BW' 'BV' 'BR' 'IO' 'BN' 'BG' 'BF' 'BI' 'KH' 'CM' 'CA' 'CV' 'KY' 'CF' 'TD' 'CL' 'CN' 'CX' 'CC' 'CO' 'KM' 'CG' 'CK' 'CR' 'CI' 'HR' 'CU' 'CY' 'CZ' 'DK' 'DJ' 'DM' 'DO' 'TP' 'EC' 'EG' 'SV' 'GQ' 'EE' 'ET' 'FK' 'FO' 'FJ' 'FI' 'FR' 'GF' 'PF' 'TF' 'GA' 'GM' 'GE' 'DE' 'GH' 'GI' 'GR' 'GL' 'GD' 'GP' 'GU' 'GT' 'GN' 'GW' 'GY' 'HT' 'HM' 'HN' 'HK' 'HU' 'IS' 'IN' 'ID' 'IR' 'IQ' 'IE' 'IL' 'IT' 'JM' 'JP' 'JO' 'KZ' 'KE' 'KI' 'KP' 'KR' 'KW' 'KG' 'LA' 'LV' 'LB' 'LS' 'LR' 'LY' 'LI' 'LT' 'LU' 'MO' 'MG' 'MY' 'MW' 'MV' 'ML' 'MT' 'MH' 'MQ' 'MR' 'MU' 'MX' 'FM' 'MD' 'MC' 'MN' 'MS' 'MA' 'MZ' 'MM' 'NA' 'NR' 'NP' 'NL' 'AN' 'NT' 'NC' 'NZ' 'NI' 'NE' 'NG' 'NU' 'NF' 'MP' 'NO' 'OM' 'PK' 'PW' 'PA' 'PG' 'PY' 'PE' 'PH' 'PN' 'PL' 'PT' 'PR' 'QA' 'RE' 'RO' 'RU' 'RW' 'SH' 'KN' 'LC' 'PM' 'VC' 'WS' 'SM' 'ST' 'SA' 'SN' 'SE' 'SL' 'SG' 'SI' 'SB' 'SO' 'ZA' 'ES' 'LK' 'SD' 'SR' 'SJ' 'SZ' 'SE' 'CH' 'SY' 'TW' 'TJ' 'TZ' 'TH' 'TG' 'TK' 'TO' 'TT' 'TN' 'TR' 'TM' 'TC' 'TV' 'UG' 'UA' 'AE' 'GB' 'US' 'UM' 'UY' 'UZ' 'VU' 'VA' 'VE' 'VN' 'VG' 'VI' 'WF' 'EH' 'YE' 'YU' 'ZR' 'ZM' 'ZW' 'SK' 'SP' 'CD' 'ER' 'MK' 'YT' 'SC' 'GS')
    ]

    LocaleData class >> languages [
	"ISO639 language codes"

	<category: 'database'>
	^#('aa' 'ab' 'ae' 'af' 'am' 'ar' 'as' 'ay' 'az' 'ba' 'be' 'bg' 'bh' 'bi' 'bn' 'bo' 'br' 'bs' 'ca' 'ce' 'ch' 'co' 'cs' 'cu' 'cv' 'cy' 'da' 'de' 'dz' 'el' 'en' 'eo' 'es' 'et' 'eu' 'fa' 'fi' 'fj' 'fo' 'fr' 'fy' 'ga' 'gd' 'gl' 'gn' 'gu' 'gv' 'ha' 'he' 'hi' 'ho' 'hr' 'hu' 'hy' 'hz' 'ia' 'id' 'ie' 'ik' 'io' 'is' 'it' 'iu' 'ja' 'jv' 'ka' 'ki' 'kj' 'kk' 'kl' 'km' 'kn' 'ko' 'ks' 'ku' 'kv' 'kw' 'ky' 'la' 'lb' 'ln' 'lo' 'lt' 'lv' 'mg' 'mh' 'mi' 'mk' 'ml' 'mn' 'mo' 'mr' 'ms' 'mt' 'my' 'na' 'nb' 'nd' 'ne' 'ng' 'nl' 'nn' 'no' 'nr' 'nv' 'ny' 'oc' 'om' 'or' 'os' 'pa' 'pi' 'pl' 'ps' 'pt' 'qu' 'rm' 'rn' 'ro' 'ru' 'rw' 'sa' 'sc' 'sd' 'se' 'sg' 'sh' 'si' 'sk' 'sl' 'sm' 'sn' 'so' 'sq' 'sr' 'ss' 'st' 'su' 'sv' 'sw' 'ta' 'te' 'tg' 'th' 'ti' 'tk' 'tl' 'tn' 'to' 'tr' 'ts' 'tt' 'tw' 'ty' 'ug' 'uk' 'ur' 'uz' 'vi' 'vo' 'wa' 'wo' 'xh' 'yi' 'yo' 'za' 'zh' 'zu' 'ber' 'bin' 'bnt' 'chr' 'cpe' 'div' 'ful' 'ibo' 'kau' 'kok' 'mni' 'nic' 'pap' 'sit' 'syr' 'ven' 'wen')
    ]

    LocaleData class >> defaultCharset [
	"Answer the default charset used when nothing is specified."

	<category: 'database'>
	^DefaultCharsets at: 'POSIX'
    ]

    LocaleData class >> defaultCharset: aString [
	"Set the default charset used when nothing is specified."

	<category: 'database'>
	DefaultCharsets at: 'POSIX' put: aString asString
    ]

    LocaleData class >> defaults [
	"Answer the default territory-language and language-charset
	 associations."

	<category: 'database'>
	^#(#('POSIX' '' 'UTF-8')
	 #('af' 'ZA' 'ISO-8859-1')
	 #('am' 'ET' 'UTF-8')
	 #('ar' 'SA' 'ISO-8859-6')
	 #('as' 'IN' 'UTF-8')
	 #('az' 'AZ' 'UTF-8')
	 #('be' 'BY' 'CP1251')
	 #('ber' 'MA' 'UTF-8')
	 #('bg' 'BG' 'CP1251')
	 #('bin' 'NG' 'ISO-8859-1')
	 #('bn' 'IN' 'UTF-8')
	 #('bnt' 'TZ' 'ISO-8859-1')
	 #('bo' 'CN' 'UTF-8')
	 #('br' 'FR' 'ISO-8859-1')
	 #('bs' 'BA' 'ISO-8859-2')
	 #('ca' 'ES' 'ISO-8859-1')
	 #('chr' 'US' 'ISO-8859-1')
	 #('cpe' 'US' 'ISO-8859-1')
	 #('cs' 'CZ' 'ISO-8859-2')
	 #('cy' 'GB' 'ISO-8859-14')
	 #('da' 'DK' 'ISO-8859-1')
	 #('de' 'DE' 'ISO-8859-1')
	 #('div' 'MV' 'ISO-8859-1')
	 #('el' 'GR' 'ISO-8859-7')
	 #('en' 'US' 'ISO-8859-1')
	 #('eo' 'XX' 'ISO-8859-3')
	 #('es' 'ES' 'ISO-8859-1')
	 #('et' 'EE' 'ISO-8859-4')
	 #('eu' 'ES' 'ISO-8859-1')
	 #('fa' 'IR' 'UTF-8')
	 #('fi' 'FI' 'ISO-8859-1')
	 #('fo' 'FO' 'ISO-8859-1')
	 #('fr' 'FR' 'ISO-8859-1')
	 #('ful' 'NG' 'ISO-8859-1')
	 #('fy' 'NL' 'ISO-8859-1')
	 #('ga' 'IE' 'ISO-8859-1')
	 #('gd' 'GB' 'ISO-8859-1')
	 #('gl' 'ES' 'ISO-8859-1')
	 #('gn' 'PY' 'ISO-8859-1')
	 #('gu' 'IN' 'UTF-8')
	 #('gv' 'GB' 'ISO-8859-1')
	 #('ha' 'NG' 'ISO-8859-1')
	 #('he' 'IL' 'ISO-8859-8')
	 #('hi' 'IN' 'UTF-8')
	 #('hr' 'HR' 'ISO-8859-2')
	 #('hu' 'HU' 'ISO-8859-2')
	 #('ibo' 'NG' 'ISO-8859-1')
	 #('id' 'ID' 'ISO-8859-1')
	 #('is' 'IS' 'ISO-8859-1')
	 #('it' 'IT' 'ISO-8859-1')
	 #('iu' 'CA' 'UTF-8')
	 #('ja' 'JP' 'EUC-JP')
	 #('ka' 'GE' 'GEORGIAN-PS')
	 #('kau' 'NG' 'ISO-8859-1')
	 #('kk' 'KZ' 'UTF-8')
	 #('kl' 'GL' 'ISO-8859-1')
	 #('km' 'KH' 'UTF-8')
	 #('kn' 'IN' 'UTF-8')
	 #('ko' 'KR' 'EUC-KR')
	 #('kok' 'IN' 'UTF-8')
	 #('ks' 'PK' 'UTF-8')
	 #('kw' 'GB' 'ISO-8859-1')
	 #('ky' 'KG' 'UTF-8')
	 #('la' 'VA' 'ASCII')
	 #('lt' 'LT' 'ISO-8859-13')
	 #('lv' 'LV' 'ISO-8859-13')
	 #('mi' 'NZ' 'ISO-8859-13')
	 #('mk' 'MK' 'ISO-8859-5')
	 #('ml' 'IN' 'UTF-8')
	 #('mn' 'MN' 'KOI8-R')
	 #('mni' 'IN' 'UTF-8')
	 #('mr' 'IN' 'UTF-8')
	 #('ms' 'MY' 'ISO-8859-1')
	 #('mt' 'MT' 'ISO-8859-3')
	 #('my' 'MM' 'UTF-8')
	 #('ne' 'NP' 'UTF-8')
	 #('nic' 'NG' 'ISO-8859-1')
	 #('nl' 'NL' 'ISO-8859-1')
	 #('nn' 'NO' 'ISO-8859-1')
	 #('no' 'NO' 'ISO-8859-1')
	 #('oc' 'FR' 'ISO-8859-1')
	 #('om' 'ET' 'UTF-8')
	 #('or' 'IN' 'UTF-8')
	 #('pa' 'IN' 'UTF-8')
	 #('pap' 'AN' 'UTF-8')
	 #('pl' 'PL' 'ISO-8859-2')
	 #('ps' 'PK' 'UTF-8')
	 #('pt' 'PT' 'ISO-8859-1')
	 #('rm' 'CH' 'ISO-8859-1')
	 #('ro' 'RO' 'ISO-8859-2')
	 #('ru' 'RU' 'KOI8-R')
	 #('sa' 'IN' 'UTF-8')
	 #('se' 'NO' 'UTF-8')
	 #('sh' 'YU' 'ISO-8859-2')
	 #('si' 'LK' 'UTF-8')
	 #('sit' 'CN' 'UTF-8')
	 #('sk' 'SK' 'ISO-8859-2')
	 #('sl' 'SI' 'ISO-8859-2')
	 #('so' 'SO' 'UTF-8')
	 #('sp' 'YU' 'ISO-8859-5')
	 #('sq' 'AL' 'ISO-8859-1')
	 #('sr' 'YU' 'ISO-8859-2')
	 #('sv' 'SE' 'ISO-8859-1')
	 #('sw' 'KE' 'ISO-8859-1')
	 #('syr' 'TR' 'UTF-8')
	 #('ta' 'IN' 'UTF-8')
	 #('te' 'IN' 'UTF-8')
	 #('tg' 'TJ' 'UTF-8')
	 #('th' 'TH' 'TIS-620')
	 #('ti' 'ET' 'UTF-8')
	 #('tk' 'TM' 'UTF-8')
	 #('tl' 'PH' 'ISO-8859-1')
	 #('tr' 'TR' 'ISO-8859-9')
	 #('ts' 'ZA' 'ISO-8859-1')
	 #('tt' 'RU' 'UTF-8')
	 #('uk' 'UA' 'KOI8-U')
	 #('ur' 'PK' 'UTF-8')
	 #('uz' 'UZ' 'ISO-8859-1')
	 #('ven' 'ZA' 'ISO-8859-1')
	 #('vi' 'VN' 'UTF-8')
	 #('wa' 'BE' 'ISO-8859-1')
	 #('wen' 'DE' 'ISO-8859-1')
	 #('xh' 'ZA' 'ISO-8859-1')
	 #('yi' 'US' 'CP1255')
	 #('yo' 'NG' 'ISO-8859-1')
	 #('zh' 'CN' 'GB2312')
	 #('zu' 'ZA' 'ISO-8859-1'))
	"('hy' 'AM'	#'ARMSCII-8')"
	"('lo' 'LA'	#'MULELAO-1')"
	"('sd' ?	?)"
    ]

    LocaleData class >> initialize [
	"Initialize the receiver's class variables."

	<category: 'database'>
	ValidLanguages := self languages asSet.
	ValidTerritories := self territories asSet.
	Aliases := LookupTable new.
	DefaultTerritories := LookupTable new.
	DefaultCharsets := LookupTable new.
	self defaults do: 
		[:each | 
		DefaultTerritories at: (each at: 1) put: (each at: 2).
		DefaultCharsets at: (each at: 1) put: (each at: 3)].
	ObjectMemory addDependent: self
    ]

    LocaleData class >> category [
	<category: 'accessing'>
	^nil
    ]

    LocaleData class >> default [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    LocaleData class >> update: aspect [
	"Flush instances of the receiver when an image is loaded."

	<category: 'accessing'>
	aspect == #returnFromSnapshot ifTrue: [self flush]
    ]

    LocaleData class >> flush [
	"Flush the contents of the instances of each subclass of LocaleData."

	<category: 'accessing'>
	self subclassesDo: [:each | each flush]
    ]

    LocaleData class >> fromString: lang [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    LocaleData class >> language: lang [
	"Answer the local object for the given language."

	<category: 'accessing'>
	^self fromString: lang
    ]

    LocaleData class >> language: lang territory: territory [
	"Answer the local object for the given language and territory."

	<category: 'accessing'>
	^self fromString: lang , '_' , territory
    ]

    LocaleData class >> language: lang territory: territory charset: charset [
	"Answer the local object for the given language, territory and charset."

	<category: 'accessing'>
	^self fromString: lang , '_' , territory , '.' , charset
    ]

    LocaleData class >> new [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    LocaleData class >> posix [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    extractLocaleParts: string [
	"Extract the language, territory and charset from a locale definition
	 string."

	<category: 'private'>
	| spec stream language territory charset |
	spec := string.
	spec isNil & self class category isNil ifTrue: [^nil].
	spec isNil 
	    ifTrue: 
		[spec := Smalltalk getenv: 'LC_ALL'.
		spec = '' ifTrue: [spec := nil]].
	spec isNil 
	    ifTrue: 
		[spec := Smalltalk getenv: self class category.
		spec = '' ifTrue: [spec := nil]].
	spec isNil 
	    ifTrue: 
		[spec := Smalltalk getenv: 'LANG'.
		spec = '' ifTrue: [spec := nil]].
	spec isNil ifTrue: [spec := #POSIX].
	stream := spec readStream.
	language := stream upTo: $_.
	stream atEnd 
	    ifTrue: 
		[^
		{language.
		DefaultTerritories at: language.
		DefaultCharsets at: language}].
	territory := stream upTo: $..
	stream atEnd 
	    ifTrue: 
		[^
		{language.
		territory.
		DefaultCharsets at: language}].
	charset := stream upToEnd.
	^
	{language.
	territory.
	charset}
    ]

    charset [
	"Return the charset supported by the receiver."

	<category: 'accessing'>
	^id isNil ifTrue: [self class defaultCharset] ifFalse: [id at: 3]
    ]

    language [
	"Return the language supported by the receiver."

	<category: 'accessing'>
	^id isNil ifTrue: [nil] ifFalse: [id at: 1]
    ]

    territory [
	"Return the territory supported by the receiver."

	<category: 'accessing'>
	^id isNil ifTrue: [nil] ifFalse: [id at: 2]
    ]

    id [
	"Return the identifier of the locale supported by the receiver."

	<category: 'accessing'>
	^id
    ]

    languageDirectory: rootDirectory [
	"Answer the directory where data files for the current language reside,
	 given the root directory of the locale data."

	<category: 'accessing'>
	^'%1/%2' % 
		{rootDirectory.
		self language}
    ]

    languageDirectory [
	"Answer the directory where data files for the current language reside."

	<category: 'accessing'>
	^self languageDirectory: Locale rootDirectory
    ]

    territoryDirectory: rootDirectory [
	"Answer the directory where data files for the current language,
	 specific to the territory, reside, given the root directory of the
	 locale data."

	<category: 'accessing'>
	^'%1/%2_%3' % 
		{rootDirectory.
		self language.
		self territory}
    ]

    territoryDirectory [
	"Answer the directory where data files for the current language,
	 specific to the territory, reside."

	<category: 'accessing'>
	self isPosixLocale ifTrue: [^self languageDirectory].
	^self territoryDirectory: Locale rootDirectory
    ]

    isPosixLocale [
	"Answer whether the receiver implements the default POSIX behavior
	 for a locale."

	<category: 'accessing'>
	^self language == #POSIX
    ]

    id: anArray [
	"Private - Set which locale the receiver contains data for"

	<category: 'initialization'>
	id := anArray
    ]

    initialize: aString [
	"Set which locale the receiver contains data for, starting
	 from a string describing the locale."

	<category: 'initialization'>
	id := self extractLocaleParts: aString
    ]
]



LocaleData subclass: Locale [
    | numeric time monetary iso messages |
    
    <category: 'i18n-Messages'>
    <comment: 'This object is an abstract superclass of objects related to the territory
and language in which the program is being used.  Instances of it are
asked about information on the current locale, and provide a means to be
asked for things with a common idiom, the #? binary message.'>

    RootDirectory := nil.
    Posix := nil.
    Default := nil.

    Locale class >> rootDirectory [
	"Answer the directory under which locale definition files are found."

	<category: 'initialization'>
	RootDirectory isNil ifTrue: [RootDirectory := self primRootDirectory].
	^RootDirectory
    ]

    Locale class >> rootDirectory: aString [
	"Set under which directory locale definition files are found."

	<category: 'initialization'>
	self flush.
	RootDirectory := aString
    ]

    Locale class >> flush [
	"Flush the information on locales that are not valid across an
	 image save/load."

	<category: 'instance creation'>
	super flush.
	Default := nil
    ]

    Locale class >> default [
	"Answer an instance of the receiver that accesses the default locale."

	<category: 'instance creation'>
	Default isNil ifFalse: [^Default].
	^Default := self language: nil
    ]

    Locale class >> fromString: aString [
	"Answer an instance of the receiver that accesses the given locale
	 (in the form language[_territory][.charset])."

	<category: 'instance creation'>
	^self basicNew initialize: aString
    ]

    Locale class >> posix [
	"Answer an instance of the receiver that accesses the POSIX locale."

	<category: 'instance creation'>
	Posix isNil ifFalse: [^Posix].
	^Posix := self language: #POSIX
    ]

    load: name [
	<category: 'C call-outs'>
	<cCall: 'i18n_load' returning: #string args: #(#self #string)>
	
    ]

    Locale class >> primRootDirectory [
	<category: 'C call-outs'>
	<cCall: 'i18n_localeDirectory' returning: #string args: #()>
	
    ]

    numeric [
	"Answer the LcNumeric object for the locale represented by the receiver."

	<category: 'subobjects'>
	^numeric
    ]

    time [
	"Answer the LcTime object for the locale represented by the receiver."

	<category: 'subobjects'>
	^time
    ]

    messages [
	"Answer the LcMessages object for the locale represented by the receiver."

	<category: 'subobjects'>
	^messages
    ]

    monetary [
	"Answer the LcMonetary object for the locale represented by the receiver."

	<category: 'subobjects'>
	^monetary
    ]

    monetaryIso [
	"Answer the LcMonetaryISO object for the locale represented by the
	 receiver."

	<category: 'subobjects'>
	^iso
    ]

    initialize: aString [
	"Create the receiver and load all of its subobjects"

	<category: 'private'>
	| result |
	super initialize: aString.
	id isNil 
	    ifFalse: 
		[numeric := LcNumeric basicNew id: self id.
		time := LcTime basicNew id: self id.
		monetary := LcMonetary basicNew id: self id.
		iso := LcMonetaryISO basicNew id: self id.
		messages := LcMessages basicNew id: self id]
	    ifTrue: 
		[numeric := LcNumeric basicNew initialize: nil.
		time := LcTime basicNew initialize: nil.
		monetary := LcMonetary basicNew initialize: nil.
		iso := LcMonetaryISO basicNew initialize: nil.
		messages := LcMessages basicNew initialize: nil].
	(result := self load: aString) isNil 
	    ifTrue: [self load: 'C']
	    ifFalse: [id isNil ifFalse: [id at: 3 put: result]]
    ]
]



LocaleData subclass: LocaleConventions [
    
    <category: 'i18n-Messages'>
    <comment: 'I am an abstract superclass of objects that are referred to by a Locale
object.'>

    LocaleConventions class >> selector [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    LocaleConventions class >> default [
	"Answer an instance of the receiver that accesses the default locale."

	<category: 'accessing'>
	^Locale default perform: self selector
    ]

    LocaleConventions class >> fromString: aString [
	"Answer an instance of the receiver that accesses the given locale
	 (in the form language[_territory][.charset])."

	<category: 'accessing'>
	^(Locale fromString: aString) perform: self selector
    ]

    LocaleConventions class >> posix [
	"Answer an instance of the receiver that accesses the POSIX locale."

	<category: 'accessing'>
	^Locale posix perform: self selector
    ]

    LocaleConventions class >> ? anObject [
	"Query the default object, forwarding the message to it."

	<category: 'accessing'>
	^self default ? anObject
    ]

    ? anObject [
	<category: 'accessing'>
	self subclassResponsibility
    ]
]



LocaleConventions subclass: LcPrintFormats [
    
    <category: 'i18n-Messages'>
    <comment: 'LcPrintFormats subclasses have instances that understand #?,
#printString: and #print:on: (the last of which is abstract) which
provide a means to convert miscellaneous objects to Strings according
to the rules that are used in the given locale.'>

    ? anObject [
	"Answer how anObject must be printed according to the receiver's
	 formatting conventions."

	<category: 'printing'>
	| stream |
	stream := WriteStream on: String new.	"### maybe an EncodedStream"
	self print: anObject on: stream.
	^stream contents
    ]

    printString: anObject [
	"Answer how anObject must be printed according to the receiver's
	 formatting conventions."

	<category: 'printing'>
	| stream |
	stream := WriteStream on: String new.	"### maybe an EncodedStream"
	self print: anObject on: stream.
	^stream contents
    ]

    print: anObject on: aStream [
	"Print anObject on aStream according to the receiver's
	 formatting conventions."

	<category: 'printing'>
	self subclassResponsibility
    ]
]



String class extend [

    defaultDefaultEncoding [
	"Answer the default encoding that is used when the user specifies
	 none."

	<category: 'converting'>
	^I18N.Locale default charset
    ]

]



CharacterArray extend [

    compareTo: aCharacterArray [
	"Answer a number < 0 if the receiver is less than aCharacterArray,
	 a number > 0 if it is greater, or 0 if they are equal.  This does
	 a three-way comparison."

	<category: 'comparing'>
	| c1 c2 |
	1 to: (self size min: aCharacterArray size)
	    do: 
		[:i | 
		c1 := (self at: i) value.
		c2 := (aCharacterArray at: i) value.
		c1 = c2 ifFalse: [^c1 - c2]].
	^self size - aCharacterArray size
    ]

]



Eval [
    LocaleData initialize
]

