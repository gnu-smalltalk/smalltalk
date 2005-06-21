"======================================================================
|
|   Localization and internationalization support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002 Free Software Foundation, Inc.
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

Object subclass: #LocaleData
    instanceVariableNames: 'id'
    classVariableNames: 'ValidLanguages ValidTerritories DefaultTerritories
			 DefaultCharsets Aliases '
    poolDictionaries: ''
    category: 'i18n-Messages'!

LocaleData comment: 
'I am an abstract superclass of objects that represent localization
information.'!

LocaleData subclass: #Locale
    instanceVariableNames: 'numeric time monetary iso messages'
    classVariableNames: 'RootDirectory Posix Default'
    poolDictionaries: ''
    category: 'i18n-Messages'!

Locale comment: 
'This object is an abstract superclass of objects related to the territory
and language in which the program is being used.  Instances of it are
asked about information on the current locale, and provide a means to be
asked for things with a common idiom, the #? binary message.'!

LocaleData subclass: #LocaleConventions
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Messages'!

LocaleConventions comment: 
'I am an abstract superclass of objects that are referred to by a Locale
object.'!

LocaleConventions subclass: #LcPrintFormats
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'i18n-Messages'!

LcPrintFormats comment: 
'LcPrintFormats subclasses have instances that understand #?,
#printString: and #print:on: (the last of which is abstract) which
provide a means to convert miscellaneous objects to Strings according
to the rules that are used in the given locale.'!

!LocaleData class methodsFor: 'database'!

territories
    "ISO3166 territory codes"
    ^#( 'AF' 'AL' 'DZ' 'AS' 'AD' 'AO' 'AI' 'AQ' 'AG' 'AR' 'AM'
	'AW' 'AU' 'AT' 'AZ' 'BS' 'BH' 'BD' 'BB' 'BY' 'BE' 'BZ'
	'BJ' 'BM' 'BT' 'BO' 'BA' 'BW' 'BV' 'BR' 'IO' 'BN' 'BG'
	'BF' 'BI' 'KH' 'CM' 'CA' 'CV' 'KY' 'CF' 'TD' 'CL' 'CN'
	'CX' 'CC' 'CO' 'KM' 'CG' 'CK' 'CR' 'CI' 'HR' 'CU' 'CY'
	'CZ' 'DK' 'DJ' 'DM' 'DO' 'TP' 'EC' 'EG' 'SV' 'GQ' 'EE'
	'ET' 'FK' 'FO' 'FJ' 'FI' 'FR' 'GF' 'PF' 'TF' 'GA' 'GM'
	'GE' 'DE' 'GH' 'GI' 'GR' 'GL' 'GD' 'GP' 'GU' 'GT' 'GN'
	'GW' 'GY' 'HT' 'HM' 'HN' 'HK' 'HU' 'IS' 'IN' 'ID' 'IR'
	'IQ' 'IE' 'IL' 'IT' 'JM' 'JP' 'JO' 'KZ' 'KE' 'KI' 'KP'
	'KR' 'KW' 'KG' 'LA' 'LV' 'LB' 'LS' 'LR' 'LY' 'LI' 'LT'
	'LU' 'MO' 'MG' 'MY' 'MW' 'MV' 'ML' 'MT' 'MH' 'MQ' 'MR'
	'MU' 'MX' 'FM' 'MD' 'MC' 'MN' 'MS' 'MA' 'MZ' 'MM' 'NA'
	'NR' 'NP' 'NL' 'AN' 'NT' 'NC' 'NZ' 'NI' 'NE' 'NG' 'NU'
	'NF' 'MP' 'NO' 'OM' 'PK' 'PW' 'PA' 'PG' 'PY' 'PE' 'PH'
	'PN' 'PL' 'PT' 'PR' 'QA' 'RE' 'RO' 'RU' 'RW' 'SH' 'KN'
	'LC' 'PM' 'VC' 'WS' 'SM' 'ST' 'SA' 'SN' 'SE' 'SL' 'SG'
	'SI' 'SB' 'SO' 'ZA' 'ES' 'LK' 'SD' 'SR' 'SJ' 'SZ' 'SE'
	'CH' 'SY' 'TW' 'TJ' 'TZ' 'TH' 'TG' 'TK' 'TO' 'TT' 'TN'
	'TR' 'TM' 'TC' 'TV' 'UG' 'UA' 'AE' 'GB' 'US' 'UM' 'UY'
	'UZ' 'VU' 'VA' 'VE' 'VN' 'VG' 'VI' 'WF' 'EH' 'YE' 'YU'
	'ZR' 'ZM' 'ZW' 'SK' 'SP' 'CD' 'ER' 'MK' 'YT' 'SC' 'GS')!

languages
    "ISO639 language codes"
    ^#( 'aa' 'ab' 'ae' 'af' 'am' 'ar' 'as' 'ay' 'az' 'ba' 'be'
	'bg' 'bh' 'bi' 'bn' 'bo' 'br' 'bs' 'ca' 'ce' 'ch' 'co'
	'cs' 'cu' 'cv' 'cy' 'da' 'de' 'dz' 'el' 'en' 'eo' 'es'
	'et' 'eu' 'fa' 'fi' 'fj' 'fo' 'fr' 'fy' 'ga' 'gd' 'gl'
	'gn' 'gu' 'gv' 'ha' 'he' 'hi' 'ho' 'hr' 'hu' 'hy' 'hz'
	'ia' 'id' 'ie' 'ik' 'io' 'is' 'it' 'iu' 'ja' 'jv' 'ka'
	'ki' 'kj' 'kk' 'kl' 'km' 'kn' 'ko' 'ks' 'ku' 'kv' 'kw'
	'ky' 'la' 'lb' 'ln' 'lo' 'lt' 'lv' 'mg' 'mh' 'mi' 'mk'
	'ml' 'mn' 'mo' 'mr' 'ms' 'mt' 'my' 'na' 'nb' 'nd' 'ne'
	'ng' 'nl' 'nn' 'no' 'nr' 'nv' 'ny' 'oc' 'om' 'or' 'os'
	'pa' 'pi' 'pl' 'ps' 'pt' 'qu' 'rm' 'rn' 'ro' 'ru' 'rw'
	'sa' 'sc' 'sd' 'se' 'sg' 'sh' 'si' 'sk' 'sl' 'sm' 'sn'
	'so' 'sq' 'sr' 'ss' 'st' 'su' 'sv' 'sw' 'ta' 'te' 'tg'
	'th' 'ti' 'tk' 'tl' 'tn' 'to' 'tr' 'ts' 'tt' 'tw' 'ty'
	'ug' 'uk' 'ur' 'uz' 'vi' 'vo' 'wa' 'wo' 'xh' 'yi' 'yo'
	'za' 'zh' 'zu'
	'ber' 'bin' 'bnt' 'chr' 'cpe' 'div' 'ful' 'ibo' 'kau'
	'kok' 'mni' 'nic' 'pap' 'sit' 'syr' 'ven' 'wen')!

defaults
    "Answer the default territory-language and language-charset
     associations."
    ^#(	('POSIX' ''	#'ISO-8859-1')
	('af' 'ZA'	#'ISO-8859-1')
	('am' 'ET'	#'UTF-8')	"not yet seen on Unix"
	('ar' 'SA'	#'ISO-8859-6')
	('as' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('az' 'AZ'	#'UTF-8')	"not yet seen on Unix"
	('be' 'BY'	#'CP1251')
	('ber' 'MA'	#'UTF-8')	"not yet seen on Unix"
	('bg' 'BG'	#'CP1251')
	('bin' 'NG'	#'ISO-8859-1')	"not yet seen on Unix"
	('bn' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('bnt' 'TZ'	#'ISO-8859-1')	"not yet seen on Unix"
	('bo' 'CN'	#'UTF-8')	"not yet seen on Unix"
	('br' 'FR'	#'ISO-8859-1')	"not yet seen on Unix"
	('bs' 'BA'	#'ISO-8859-2')
	('ca' 'ES'	#'ISO-8859-1')
	('chr' 'US'	#'ISO-8859-1')	"not yet seen on Unix"
	('cpe' 'US'	#'ISO-8859-1')	"not yet seen on Unix"
	('cs' 'CZ'	#'ISO-8859-2')
	('cy' 'GB'	#'ISO-8859-14')
	('da' 'DK'	#'ISO-8859-1')
	('de' 'DE'	#'ISO-8859-1')
	('div' 'MV'	#'ISO-8859-1')	"not yet seen on Unix"
	('el' 'GR'	#'ISO-8859-7')
	('en' 'US'	#'ISO-8859-1')
	('eo' 'XX'	#'ISO-8859-3')	"not yet seen on Unix"
	('es' 'ES'	#'ISO-8859-1')
	('et' 'EE'	#'ISO-8859-4')
	('eu' 'ES'	#'ISO-8859-1')
	('fa' 'IR'	#'UTF-8')
	('fi' 'FI'	#'ISO-8859-1')
	('fo' 'FO'	#'ISO-8859-1')
	('fr' 'FR'	#'ISO-8859-1')
	('ful' 'NG'	#'ISO-8859-1')	"not yet seen on Unix"
	('fy' 'NL'	#'ISO-8859-1')	"not yet seen on Unix"
	('ga' 'IE'	#'ISO-8859-1')
	('gd' 'GB'	#'ISO-8859-1')	"not yet seen on Unix"
	('gl' 'ES'	#'ISO-8859-1')
	('gn' 'PY'	#'ISO-8859-1')	"not yet seen on Unix"
	('gu' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('gv' 'GB'	#'ISO-8859-1')
	('ha' 'NG'	#'ISO-8859-1')	"not yet seen on Unix"
	('he' 'IL'	#'ISO-8859-8')
	('hi' 'IN'	#'UTF-8')
	('hr' 'HR'	#'ISO-8859-2')
	('hu' 'HU'	#'ISO-8859-2')
	"('hy' 'AM'	#'ARMSCII-8')"	"not yet seen on Unix"
	('ibo' 'NG'	#'ISO-8859-1')	"not yet seen on Unix"
	('id' 'ID'	#'ISO-8859-1')
	('is' 'IS'	#'ISO-8859-1')
	('it' 'IT'	#'ISO-8859-1')
	('iu' 'CA'	#'UTF-8')	"not yet seen on Unix"
	('ja' 'JP'	#'EUC-JP')
	('ka' 'GE'	#'GEORGIAN-PS')
	('kau' 'NG'	#'ISO-8859-1')	"not yet seen on Unix"
	('kk' 'KZ'	#'UTF-8')	"not yet seen on Unix"
	('kl' 'GL'	#'ISO-8859-1')
	('km' 'KH'	#'UTF-8')	"not yet seen on Unix"
	('kn' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('ko' 'KR'	#'EUC-KR')
	('kok' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('ks' 'PK'	#'UTF-8')	"not yet seen on Unix"
	('kw' 'GB'	#'ISO-8859-1')
	('ky' 'KG'	#'UTF-8')	"not yet seen on Unix"
	('la' 'VA'	#'ASCII')	"not yet seen on Unix"
	"('lo' 'LA'	#'MULELAO-1')"	"not yet seen on Unix"
	('lt' 'LT'	#'ISO-8859-13')
	('lv' 'LV'	#'ISO-8859-13')
	('mi' 'NZ'	#'ISO-8859-13')
	('mk' 'MK'	#'ISO-8859-5')
	('ml' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('mn' 'MN'	#'KOI8-R')	"not yet seen on Unix"
	('mni' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('mr' 'IN'	#'UTF-8')
	('ms' 'MY'	#'ISO-8859-1')
	('mt' 'MT'	#'ISO-8859-3')
	('my' 'MM'	#'UTF-8')	"not yet seen on Unix"
	('ne' 'NP'	#'UTF-8')	"not yet seen on Unix"
	('nic' 'NG'	#'ISO-8859-1')	"not yet seen on Unix"
	('nl' 'NL'	#'ISO-8859-1')
	('nn' 'NO'	#'ISO-8859-1')
	('no' 'NO'	#'ISO-8859-1')
	('oc' 'FR'	#'ISO-8859-1')
	('om' 'ET'	#'UTF-8')	"not yet seen on Unix"
	('or' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('pa' 'IN'	#'UTF-8')	"not yet seen on Unix"
	('pap' 'AN'	#'UTF-8')	"not yet seen on Unix"
	('pl' 'PL'	#'ISO-8859-2')
	('ps' 'PK'	#'UTF-8')	"not yet seen on Unix"
	('pt' 'PT'	#'ISO-8859-1')
	('rm' 'CH'	#'ISO-8859-1')	"not yet seen on Unix"
	('ro' 'RO'	#'ISO-8859-2')
	('ru' 'RU'	#'KOI8-R')
	('sa' 'IN'	#'UTF-8')	"not yet seen on Unix"
	"('sd' ?	?)"		"not yet seen on Unix"
	('se' 'NO'	#'UTF-8')
	('sh' 'YU'	#'ISO-8859-2')	"obsolete"
	('si' 'LK'	#'UTF-8')	"not yet seen on Unix"
	('sit' 'CN'	#'UTF-8')	"not yet seen on Unix"
	('sk' 'SK'	#'ISO-8859-2')
	('sl' 'SI'	#'ISO-8859-2')
	('so' 'SO'	#'UTF-8')	"not yet seen on Unix"
	('sp' 'YU'	#'ISO-8859-5')	"obsolete"
	('sq' 'AL'	#'ISO-8859-1')
	('sr' 'YU'	#'ISO-8859-2')
	('sv' 'SE'	#'ISO-8859-1')
	('sw' 'KE'	#'ISO-8859-1')	"not yet seen on Unix"
	('syr' 'TR'	#'UTF-8')	"not yet seen on Unix"
	('ta' 'IN'	#'UTF-8')
	('te' 'IN'	#'UTF-8')
	('tg' 'TJ'	#'UTF-8')
	('th' 'TH'	#'TIS-620')
	('ti' 'ET'	#'UTF-8')	"not yet seen on Unix"
	('tk' 'TM'	#'UTF-8')	"not yet seen on Unix"
	('tl' 'PH'	#'ISO-8859-1')
	('tr' 'TR'	#'ISO-8859-9')
	('ts' 'ZA'	#'ISO-8859-1')	"not yet seen on Unix"
	('tt' 'RU'	#'UTF-8')	"not yet seen on Unix"
	('uk' 'UA'	#'KOI8-U')
	('ur' 'PK'	#'UTF-8')
	('uz' 'UZ'	#'ISO-8859-1')
	('ven' 'ZA'	#'ISO-8859-1')	"not yet seen on Unix"
	('vi' 'VN'	#'UTF-8')
	('wa' 'BE'	#'ISO-8859-1')
	('wen' 'DE'	#'ISO-8859-1')	"not yet seen on Unix"
	('xh' 'ZA'	#'ISO-8859-1')	"not yet seen on Unix"
	('yi' 'US'	#'CP1255')
	('yo' 'NG'	#'ISO-8859-1')	"not yet seen on Unix"
	('zh' 'CN'	#'GB2312')
	('zu' 'ZA'	#'ISO-8859-1')	"not yet seen on Unix"
	)!

initialize
    "Initialize the receiver's class variables."
    ValidLanguages := self languages asSet.
    ValidTerritories := self territories asSet.
    Aliases := LookupTable new.
    DefaultTerritories := LookupTable new.
    DefaultCharsets := LookupTable new.

    self defaults do: [ :each |
	DefaultTerritories
	    at: (each at: 1)
	    put: (each at: 2).

	DefaultCharsets
	    at: (each at: 1)
	    put: (each at: 3).
    ].
    
    ObjectMemory addDependent: self! !
    
!LocaleData class methodsFor: 'accessing'!

category
    ^nil!

default
    self subclassResponsibility!

update: aspect
    "Flush instances of the receiver when an image is loaded."
    aspect == #returnFromSnapshot ifTrue: [ self flush ]!

flush
    "Flush the contents of the instances of each subclass of LocaleData."
    self subclassesDo: [ :each | each flush ]!

fromString: lang
    self subclassResponsibility!

language: lang
    "Answer the local object for the given language."
    ^self fromString: lang!

language: lang territory: territory
    "Answer the local object for the given language and territory."
    ^self fromString: lang, '_', territory!

language: lang territory: territory charset: charset
    "Answer the local object for the given language, territory and charset."
    ^self fromString: lang, '_', territory, '.', charset!

new
    self shouldNotImplement!

posix
    self subclassResponsibility! !

!LocaleData methodsFor: 'private'!

extractLocaleParts: string
    "Extract the language, territory and charset from a locale definition
     string."
    | spec stream language territory charset |
    spec := string.
    spec isNil & self class category isNil ifTrue: [ ^nil ].

    spec isNil ifTrue: [
        spec := Smalltalk getenv: 'LC_ALL'.
        spec = '' ifTrue: [ spec := nil ]
    ].
    spec isNil ifTrue: [
        spec := Smalltalk getenv: self class category.
        spec = '' ifTrue: [ spec := nil ]
    ].
    spec isNil ifTrue: [
        spec := Smalltalk getenv: 'LANG'.
        spec = '' ifTrue: [ spec := nil ]
    ].
    spec isNil ifTrue: [ spec := #POSIX ].

    stream := spec readStream.
    language := stream upTo: $_.
    stream atEnd ifTrue: [ ^{
        language.
        DefaultTerritories at: language.
        DefaultCharsets at: language }
    ].

    territory := stream upTo: $. .
    stream atEnd ifTrue: [ ^{
        language. territory.
        DefaultCharsets at: language }
    ].

    charset := stream upToEnd.
    ^{ language. territory. charset }! !

!LocaleData methodsFor: 'accessing'!

charset
    "Return the charset supported by the receiver."
    ^id isNil ifTrue: [ nil ] ifFalse: [ id at: 3 ]!

language
    "Return the language supported by the receiver."
    ^id isNil ifTrue: [ nil ] ifFalse: [ id at: 1 ]!

territory
    "Return the territory supported by the receiver."
    ^id isNil ifTrue: [ nil ] ifFalse: [ id at: 2 ]!

id
    "Return the identifier of the locale supported by the receiver."
    ^id!

languageDirectory: rootDirectory
    "Answer the directory where data files for the current language reside,
     given the root directory of the locale data."
    ^'%1/%2'
	bindWith: rootDirectory
	with: self language!

languageDirectory
    "Answer the directory where data files for the current language reside."
    ^self languageDirectory: Locale rootDirectory!

territoryDirectory: rootDirectory
    "Answer the directory where data files for the current language,
     specific to the territory, reside, given the root directory of the
     locale data."
    ^'%1/%2_%3'
	bindWith: rootDirectory
	with: self language
	with: self territory!

territoryDirectory
    "Answer the directory where data files for the current language,
     specific to the territory, reside."
    self isPosixLocale ifTrue: [ ^self languageDirectory ].
    ^self territoryDirectory: Locale rootDirectory!

isPosixLocale
    "Answer whether the receiver implements the default POSIX behavior
     for a locale."
    ^self language == #POSIX! !

!LocaleData methodsFor: 'initialization'!

id: anArray
    "Private - Set which locale the receiver contains data for"
    id := anArray!

initialize: aString
    "Set which locale the receiver contains data for, starting
     from a string describing the locale."
    id := self extractLocaleParts: aString! !

Locale
    defineCFunc: 'i18n_load'
    withSelectorArgs: 'load: name'
    returning: #string
    args: #(#self #string)!

Locale class
    defineCFunc: 'i18n_localeDirectory'
    withSelectorArgs: 'primRootDirectory'
    returning: #string
    args: #()!

!Locale class methodsFor: 'initialization'!

rootDirectory
    "Answer the directory under which locale definition files are found."
    RootDirectory isNil ifTrue: [ RootDirectory := self primRootDirectory ].
    ^RootDirectory!

rootDirectory: aString
    "Set under which directory locale definition files are found."
    self flush.
    RootDirectory := aString! !

!Locale class methodsFor: 'instance creation'!

flush
    "Flush the information on locales that are not valid across an
     image save/load."
    super flush.
    Default := nil!

default
    "Answer an instance of the receiver that accesses the default locale."
    Default isNil ifFalse: [ ^Default ].
    ^Default := self language: nil!

fromString: aString
    "Answer an instance of the receiver that accesses the given locale
     (in the form language[_territory][.charset])."
    ^self basicNew initialize: aString!

posix
    "Answer an instance of the receiver that accesses the POSIX locale."
    Posix isNil ifFalse: [ ^Posix ].
    ^Posix := self language: #POSIX! !

!Locale methodsFor: 'subobjects'!

numeric
    "Answer the LcNumeric object for the locale represented by the receiver."
    ^numeric!

time
    "Answer the LcTime object for the locale represented by the receiver."
    ^time!

messages
    "Answer the LcMessages object for the locale represented by the receiver."
    ^messages!

monetary
    "Answer the LcMonetary object for the locale represented by the receiver."
    ^monetary!

monetaryIso
    "Answer the LcMonetaryISO object for the locale represented by the
     receiver."
    ^iso! !

!Locale methodsFor: 'private'!

initialize: aString
    "Create the receiver and load all of its subobjects"
    | result |
    super initialize: aString.
    id isNil
	ifFalse: [
	    numeric := LcNumeric basicNew id: self id.
	    time := LcTime basicNew id: self id.
	    monetary := LcMonetary basicNew id: self id.
	    iso := LcMonetaryISO basicNew id: self id.
	    messages := LcMessages basicNew id: self id. ]
	ifTrue: [
	    numeric := LcNumeric basicNew initialize: nil.
	    time := LcTime basicNew initialize: nil.
	    monetary := LcMonetary basicNew initialize: nil.
	    iso := LcMonetaryISO basicNew initialize: nil.
	    messages := LcMessages basicNew initialize: nil. ].

    (result := self load: aString) isNil
	ifTrue: [ self load: 'C' ]
	ifFalse: [ id isNil ifFalse: [ id at: 3 put: result ] ].
! !

!LocaleConventions class methodsFor: 'accessing'!

selector
    self subclassResponsibility!

default
    "Answer an instance of the receiver that accesses the default locale."
    ^Locale default perform: self selector!

fromString: aString
    "Answer an instance of the receiver that accesses the given locale
     (in the form language[_territory][.charset])."
    ^(Locale fromString: aString) perform: self selector!

posix
    "Answer an instance of the receiver that accesses the POSIX locale."
    ^Locale posix perform: self selector!

? anObject
    "Query the default object, forwarding the message to it."
    ^self default ? anObject!

!LocaleConventions methodsFor: 'accessing'!

? anObject
    self subclassResponsibility! !

!LcPrintFormats methodsFor: 'printing'!

? anObject
    "Answer how anObject must be printed according to the receiver's
     formatting conventions."
    | stream |
    stream := WriteStream on: String new.	"### maybe an EncodedStream"
    self print: anObject on: stream.
    ^stream contents!

printString: anObject
    "Answer how anObject must be printed according to the receiver's
     formatting conventions."
    | stream |
    stream := WriteStream on: String new.	"### maybe an EncodedStream"
    self print: anObject on: stream.
    ^stream contents!

print: anObject on: aStream
    "Print anObject on aStream according to the receiver's
     formatting conventions."
    self subclassResponsibility! !


!CharacterArray methodsFor: 'comparing'!

compareTo: aCharacterArray
    "Answer a number < 0 if the receiver is less than aCharacterArray,
    a number > 0 if it is greater, or 0 if they are equal.  This does
    a three-way comparison."
    | c1 c2 |
    1 to: (self size min: aCharacterArray size) do: [ :i |
	c1 := (self at: i) value.
	c2 := (aCharacterArray at: i) value.
	c1 = c2 ifFalse: [ ^c1 - c2 ].
    ].

    ^self size - aCharacterArray size
! !

LocaleData initialize!
