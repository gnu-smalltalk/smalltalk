/* C code produced by gperf version 3.0.1 */
/* Command-line: gperf -k'1-3,6,$' -r builtins.gperf  */

#if !((' ' == 32) && ('!' == 33) && ('"' == 34) && ('#' == 35) \
      && ('%' == 37) && ('&' == 38) && ('\'' == 39) && ('(' == 40) \
      && (')' == 41) && ('*' == 42) && ('+' == 43) && (',' == 44) \
      && ('-' == 45) && ('.' == 46) && ('/' == 47) && ('0' == 48) \
      && ('1' == 49) && ('2' == 50) && ('3' == 51) && ('4' == 52) \
      && ('5' == 53) && ('6' == 54) && ('7' == 55) && ('8' == 56) \
      && ('9' == 57) && (':' == 58) && (';' == 59) && ('<' == 60) \
      && ('=' == 61) && ('>' == 62) && ('?' == 63) && ('A' == 65) \
      && ('B' == 66) && ('C' == 67) && ('D' == 68) && ('E' == 69) \
      && ('F' == 70) && ('G' == 71) && ('H' == 72) && ('I' == 73) \
      && ('J' == 74) && ('K' == 75) && ('L' == 76) && ('M' == 77) \
      && ('N' == 78) && ('O' == 79) && ('P' == 80) && ('Q' == 81) \
      && ('R' == 82) && ('S' == 83) && ('T' == 84) && ('U' == 85) \
      && ('V' == 86) && ('W' == 87) && ('X' == 88) && ('Y' == 89) \
      && ('Z' == 90) && ('[' == 91) && ('\\' == 92) && (']' == 93) \
      && ('^' == 94) && ('_' == 95) && ('a' == 97) && ('b' == 98) \
      && ('c' == 99) && ('d' == 100) && ('e' == 101) && ('f' == 102) \
      && ('g' == 103) && ('h' == 104) && ('i' == 105) && ('j' == 106) \
      && ('k' == 107) && ('l' == 108) && ('m' == 109) && ('n' == 110) \
      && ('o' == 111) && ('p' == 112) && ('q' == 113) && ('r' == 114) \
      && ('s' == 115) && ('t' == 116) && ('u' == 117) && ('v' == 118) \
      && ('w' == 119) && ('x' == 120) && ('y' == 121) && ('z' == 122) \
      && ('{' == 123) && ('|' == 124) && ('}' == 125) && ('~' == 126))
/* The character set is not based on ISO-646.  */
error "gperf generated tables don't work with this execution character set. Please report a bug to <bug-gnu-gperf@gnu.org>."
#endif

#line 15 "builtins.gperf"

/* Process with gperf -k'1-3,6,$' -r

   This table was generated starting from a 5 megabyte image
   including Blox (TK), the GTK bindings, the Browser (and hence
   the parser), TCP, NetClients, I18N, NumericalMethods, GDBM,
   MD5, and MySQL, starting from the output of this script

        | b |
        b := Bag new.
        CompiledMethod allInstances do: [ :each || n |
            each literals do: [ :each |
                each isSymbol ifTrue: [ b add: each ]
            ].
        ].

        Transcript nl.
        b sortedByCount from: 1 to: 226 keysAndValuesDo: [ :i :each |
	    ('%1;				NULL, %2,	%3'
		bindWith: each value with: each value numArgs with: i + 31)
		    displayNl ]!  */
enum
  {
    TOTAL_KEYWORDS = 251,
    MIN_WORD_LENGTH = 1,
    MAX_WORD_LENGTH = 31,
    MIN_HASH_VALUE = 59,
    MAX_HASH_VALUE = 1044
  };

/* maximum key range = 986, duplicates = 0 */

#ifdef __GNUC__
__inline
#else
#ifdef __cplusplus
inline
#endif
#endif
static unsigned int
_gst_hash_selector (str, len)
     register const char *str;
     register unsigned int len;
{
  static unsigned short asso_values[] =
    {
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,   92, 1045,
      1045, 1045,  203,  226,  114,   93, 1045,   83, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,  144, 1045,
       249,   62,   49, 1045, 1045,  125, 1045,  131,  197,  137,
       243, 1045, 1045,  241, 1045,  221,   27, 1045,  134,  178,
       218, 1045,   83,  219,   75, 1045,  212, 1045, 1045, 1045,
      1045, 1045,  110, 1045, 1045, 1045, 1045,  192,  212,   39,
       188,  183,    3,  210,    6,    0,   82,   55,  161,  253,
        63,  134,  106,   99,   51,  212,  155,  161,  223,    3,
       170,  121,   30, 1045,   29, 1045,  178, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045, 1045,
      1045, 1045, 1045, 1045, 1045, 1045
    };
  register int hval = len;

  switch (hval)
    {
      default:
        hval += asso_values[(unsigned char)str[5]];
      /*FALLTHROUGH*/
      case 5:
      case 4:
      case 3:
        hval += asso_values[(unsigned char)str[2]];
      /*FALLTHROUGH*/
      case 2:
        hval += asso_values[(unsigned char)str[1]];
      /*FALLTHROUGH*/
      case 1:
        hval += asso_values[(unsigned char)str[0]];
        break;
    }
  return hval + asso_values[(unsigned char)str[len - 1]];
}

struct _gst_builtin_selectors_names_t
  {
    char _gst_builtin_selectors_names_str59[sizeof("|")];
    char _gst_builtin_selectors_names_str99[sizeof(">")];
    char _gst_builtin_selectors_names_str108[sizeof("pi")];
    char _gst_builtin_selectors_names_str125[sizeof("=")];
    char _gst_builtin_selectors_names_str143[sizeof("cr")];
    char _gst_builtin_selectors_names_str167[sizeof("/")];
    char _gst_builtin_selectors_names_str175[sizeof(">=")];
    char _gst_builtin_selectors_names_str185[sizeof("&")];
    char _gst_builtin_selectors_names_str187[sizeof("-")];
    char _gst_builtin_selectors_names_str188[sizeof("==")];
    char _gst_builtin_selectors_names_str193[sizeof("->")];
    char _gst_builtin_selectors_names_str202[sizeof("width")];
    char _gst_builtin_selectors_names_str214[sizeof("first")];
    char _gst_builtin_selectors_names_str229[sizeof(",")];
    char _gst_builtin_selectors_names_str243[sizeof("y")];
    char _gst_builtin_selectors_names_str251[sizeof("//")];
    char _gst_builtin_selectors_names_str254[sizeof("sizeof")];
    char _gst_builtin_selectors_names_str255[sizeof("new")];
    char _gst_builtin_selectors_names_str288[sizeof("findIndexOrNil:")];
    char _gst_builtin_selectors_names_str289[sizeof("ln")];
    char _gst_builtin_selectors_names_str296[sizeof("container")];
    char _gst_builtin_selectors_names_str304[sizeof("~=")];
    char _gst_builtin_selectors_names_str307[sizeof("with:")];
    char _gst_builtin_selectors_names_str315[sizeof("with:with:")];
    char _gst_builtin_selectors_names_str317[sizeof("origin")];
    char _gst_builtin_selectors_names_str318[sizeof("narrow")];
    char _gst_builtin_selectors_names_str332[sizeof("\\\\")];
    char _gst_builtin_selectors_names_str336[sizeof("flush")];
    char _gst_builtin_selectors_names_str337[sizeof("rows:")];
    char _gst_builtin_selectors_names_str341[sizeof("x")];
    char _gst_builtin_selectors_names_str348[sizeof("primSize")];
    char _gst_builtin_selectors_names_str354[sizeof("wait")];
    char _gst_builtin_selectors_names_str375[sizeof("<=")];
    char _gst_builtin_selectors_names_str387[sizeof("nl")];
    char _gst_builtin_selectors_names_str397[sizeof("new:")];
    char _gst_builtin_selectors_names_str399[sizeof("foregroundColor:")];
    char _gst_builtin_selectors_names_str402[sizeof("zero")];
    char _gst_builtin_selectors_names_str404[sizeof("copy")];
    char _gst_builtin_selectors_names_str406[sizeof("origin:corner:")];
    char _gst_builtin_selectors_names_str407[sizeof("*")];
    char _gst_builtin_selectors_names_str410[sizeof("initialize:")];
    char _gst_builtin_selectors_names_str416[sizeof("skip:")];
    char _gst_builtin_selectors_names_str420[sizeof("hash")];
    char _gst_builtin_selectors_names_str426[sizeof("checkError")];
    char _gst_builtin_selectors_names_str428[sizeof("bindWith:")];
    char _gst_builtin_selectors_names_str429[sizeof("size")];
    char _gst_builtin_selectors_names_str432[sizeof("copyWith:")];
    char _gst_builtin_selectors_names_str433[sizeof("bindWith:with:")];
    char _gst_builtin_selectors_names_str443[sizeof("includes:")];
    char _gst_builtin_selectors_names_str446[sizeof("includesKey:")];
    char _gst_builtin_selectors_names_str447[sizeof("invalidArgsError:")];
    char _gst_builtin_selectors_names_str448[sizeof("initialize")];
    char _gst_builtin_selectors_names_str451[sizeof("print:")];
    char _gst_builtin_selectors_names_str453[sizeof("+")];
    char _gst_builtin_selectors_names_str456[sizeof("inject:into:")];
    char _gst_builtin_selectors_names_str461[sizeof("thisContext")];
    char _gst_builtin_selectors_names_str463[sizeof("primAt:")];
    char _gst_builtin_selectors_names_str464[sizeof("min:")];
    char _gst_builtin_selectors_names_str467[sizeof("primAt:put:")];
    char _gst_builtin_selectors_names_str472[sizeof("connected")];
    char _gst_builtin_selectors_names_str476[sizeof("current")];
    char _gst_builtin_selectors_names_str478[sizeof("connectIfClosed")];
    char _gst_builtin_selectors_names_str483[sizeof("key")];
    char _gst_builtin_selectors_names_str486[sizeof("copyFrom:to:")];
    char _gst_builtin_selectors_names_str487[sizeof("printOn:")];
    char _gst_builtin_selectors_names_str488[sizeof("on:")];
    char _gst_builtin_selectors_names_str489[sizeof("sign")];
    char _gst_builtin_selectors_names_str491[sizeof("upTo:")];
    char _gst_builtin_selectors_names_str492[sizeof("width:height:")];
    char _gst_builtin_selectors_names_str494[sizeof("count")];
    char _gst_builtin_selectors_names_str498[sizeof("with:do:")];
    char _gst_builtin_selectors_names_str499[sizeof("<")];
    char _gst_builtin_selectors_names_str504[sizeof("primitive")];
    char _gst_builtin_selectors_names_str505[sizeof("height")];
    char _gst_builtin_selectors_names_str507[sizeof("checkResponse")];
    char _gst_builtin_selectors_names_str510[sizeof("not")];
    char _gst_builtin_selectors_names_str512[sizeof("isNil")];
    char _gst_builtin_selectors_names_str513[sizeof("coefficients:")];
    char _gst_builtin_selectors_names_str515[sizeof("primitiveFailed")];
    char _gst_builtin_selectors_names_str519[sizeof("contents")];
    char _gst_builtin_selectors_names_str520[sizeof("bitShift:")];
    char _gst_builtin_selectors_names_str521[sizeof("sqrt")];
    char _gst_builtin_selectors_names_str522[sizeof("close")];
    char _gst_builtin_selectors_names_str523[sizeof("position")];
    char _gst_builtin_selectors_names_str525[sizeof("collect:")];
    char _gst_builtin_selectors_names_str527[sizeof("fromSeconds:")];
    char _gst_builtin_selectors_names_str531[sizeof("peek")];
    char _gst_builtin_selectors_names_str536[sizeof("~~")];
    char _gst_builtin_selectors_names_str537[sizeof("writeStream")];
    char _gst_builtin_selectors_names_str543[sizeof("perform:")];
    char _gst_builtin_selectors_names_str554[sizeof("replaceFrom:to:with:startingAt:")];
    char _gst_builtin_selectors_names_str555[sizeof("receiver")];
    char _gst_builtin_selectors_names_str563[sizeof("instanceClass")];
    char _gst_builtin_selectors_names_str564[sizeof("properties")];
    char _gst_builtin_selectors_names_str568[sizeof("exp")];
    char _gst_builtin_selectors_names_str569[sizeof("bitXor:")];
    char _gst_builtin_selectors_names_str573[sizeof("login")];
    char _gst_builtin_selectors_names_str574[sizeof("errorContents:")];
    char _gst_builtin_selectors_names_str575[sizeof("keys")];
    char _gst_builtin_selectors_names_str576[sizeof("changeState:")];
    char _gst_builtin_selectors_names_str579[sizeof("error:")];
    char _gst_builtin_selectors_names_str580[sizeof("to:")];
    char _gst_builtin_selectors_names_str582[sizeof("keysAndValuesDo:")];
    char _gst_builtin_selectors_names_str583[sizeof("x:y:")];
    char _gst_builtin_selectors_names_str586[sizeof("accumulate:")];
    char _gst_builtin_selectors_names_str596[sizeof("bind:to:of:parameters:")];
    char _gst_builtin_selectors_names_str597[sizeof("printString")];
    char _gst_builtin_selectors_names_str600[sizeof("upToEnd")];
    char _gst_builtin_selectors_names_str601[sizeof("callFrom:into:")];
    char _gst_builtin_selectors_names_str603[sizeof("return:")];
    char _gst_builtin_selectors_names_str604[sizeof("clientPI")];
    char _gst_builtin_selectors_names_str605[sizeof("position:")];
    char _gst_builtin_selectors_names_str606[sizeof("reset")];
    char _gst_builtin_selectors_names_str607[sizeof("create:")];
    char _gst_builtin_selectors_names_str609[sizeof("class")];
    char _gst_builtin_selectors_names_str610[sizeof("yourself")];
    char _gst_builtin_selectors_names_str611[sizeof("stop")];
    char _gst_builtin_selectors_names_str622[sizeof("nextToken")];
    char _gst_builtin_selectors_names_str630[sizeof("readFrom:")];
    char _gst_builtin_selectors_names_str632[sizeof("isEmpty")];
    char _gst_builtin_selectors_names_str635[sizeof("on:do:")];
    char _gst_builtin_selectors_names_str638[sizeof("at:")];
    char _gst_builtin_selectors_names_str643[sizeof("retryRelationalOp:coercing:")];
    char _gst_builtin_selectors_names_str645[sizeof("signalError")];
    char _gst_builtin_selectors_names_str654[sizeof("backgroundColor:")];
    char _gst_builtin_selectors_names_str655[sizeof("parent:")];
    char _gst_builtin_selectors_names_str657[sizeof("name:")];
    char _gst_builtin_selectors_names_str659[sizeof("body")];
    char _gst_builtin_selectors_names_str660[sizeof("step")];
    char _gst_builtin_selectors_names_str661[sizeof("bitOr:")];
    char _gst_builtin_selectors_names_str665[sizeof("parent")];
    char _gst_builtin_selectors_names_str667[sizeof("text")];
    char _gst_builtin_selectors_names_str672[sizeof("parentContext")];
    char _gst_builtin_selectors_names_str676[sizeof("skipSeparators")];
    char _gst_builtin_selectors_names_str680[sizeof("notNil")];
    char _gst_builtin_selectors_names_str681[sizeof("blox")];
    char _gst_builtin_selectors_names_str683[sizeof("body:")];
    char _gst_builtin_selectors_names_str684[sizeof("data:")];
    char _gst_builtin_selectors_names_str686[sizeof("copyEmpty:")];
    char _gst_builtin_selectors_names_str688[sizeof("beep")];
    char _gst_builtin_selectors_names_str689[sizeof("implementation")];
    char _gst_builtin_selectors_names_str690[sizeof("coerce:")];
    char _gst_builtin_selectors_names_str691[sizeof("should:")];
    char _gst_builtin_selectors_names_str692[sizeof("background")];
    char _gst_builtin_selectors_names_str693[sizeof("asOop")];
    char _gst_builtin_selectors_names_str695[sizeof("name")];
    char _gst_builtin_selectors_names_str696[sizeof("isInteger")];
    char _gst_builtin_selectors_names_str697[sizeof("default")];
    char _gst_builtin_selectors_names_str698[sizeof("space")];
    char _gst_builtin_selectors_names_str699[sizeof("tclEval:")];
    char _gst_builtin_selectors_names_str704[sizeof("tclEval:with:")];
    char _gst_builtin_selectors_names_str706[sizeof("bitAnd:")];
    char _gst_builtin_selectors_names_str709[sizeof("tclEval:with:with:")];
    char _gst_builtin_selectors_names_str713[sizeof("shouldNotImplement")];
    char _gst_builtin_selectors_names_str714[sizeof("tclEval:with:with:with:")];
    char _gst_builtin_selectors_names_str715[sizeof("postCopy")];
    char _gst_builtin_selectors_names_str716[sizeof("add:")];
    char _gst_builtin_selectors_names_str717[sizeof("days")];
    char _gst_builtin_selectors_names_str719[sizeof("start")];
    char _gst_builtin_selectors_names_str720[sizeof("variance")];
    char _gst_builtin_selectors_names_str722[sizeof("nameIn:")];
    char _gst_builtin_selectors_names_str723[sizeof("visitNode:")];
    char _gst_builtin_selectors_names_str724[sizeof("last")];
    char _gst_builtin_selectors_names_str731[sizeof("tclResult")];
    char _gst_builtin_selectors_names_str732[sizeof("nextPutAll:")];
    char _gst_builtin_selectors_names_str734[sizeof("signal:")];
    char _gst_builtin_selectors_names_str736[sizeof("signalOn:")];
    char _gst_builtin_selectors_names_str740[sizeof("superclass")];
    char _gst_builtin_selectors_names_str741[sizeof("signalOn:what:")];
    char _gst_builtin_selectors_names_str743[sizeof("signalOn:mustBe:")];
    char _gst_builtin_selectors_names_str746[sizeof("signalOn:withIndex:")];
    char _gst_builtin_selectors_names_str747[sizeof("state")];
    char _gst_builtin_selectors_names_str749[sizeof("at:type:")];
    char _gst_builtin_selectors_names_str750[sizeof("signal")];
    char _gst_builtin_selectors_names_str751[sizeof("completedSuccessfully")];
    char _gst_builtin_selectors_names_str756[sizeof("truncated")];
    char _gst_builtin_selectors_names_str761[sizeof("basicNew")];
    char _gst_builtin_selectors_names_str763[sizeof("max:")];
    char _gst_builtin_selectors_names_str764[sizeof("value")];
    char _gst_builtin_selectors_names_str768[sizeof("become:")];
    char _gst_builtin_selectors_names_str769[sizeof("environment")];
    char _gst_builtin_selectors_names_str770[sizeof("selector")];
    char _gst_builtin_selectors_names_str772[sizeof("at:ifAbsent:")];
    char _gst_builtin_selectors_names_str774[sizeof("isKindOf:")];
    char _gst_builtin_selectors_names_str775[sizeof("at:ifAbsentPut:")];
    char _gst_builtin_selectors_names_str777[sizeof("bytecodeAt:")];
    char _gst_builtin_selectors_names_str779[sizeof("generality")];
    char _gst_builtin_selectors_names_str783[sizeof("exists")];
    char _gst_builtin_selectors_names_str790[sizeof("arguments:")];
    char _gst_builtin_selectors_names_str792[sizeof("ensure:")];
    char _gst_builtin_selectors_names_str794[sizeof("activeProcess")];
    char _gst_builtin_selectors_names_str795[sizeof("store:")];
    char _gst_builtin_selectors_names_str797[sizeof("at:put:")];
    char _gst_builtin_selectors_names_str808[sizeof("asLowercase")];
    char _gst_builtin_selectors_names_str809[sizeof("asNumber")];
    char _gst_builtin_selectors_names_str815[sizeof("displayString")];
    char _gst_builtin_selectors_names_str818[sizeof("random")];
    char _gst_builtin_selectors_names_str824[sizeof("allSatisfy:")];
    char _gst_builtin_selectors_names_str830[sizeof("asVector")];
    char _gst_builtin_selectors_names_str831[sizeof("abs")];
    char _gst_builtin_selectors_names_str834[sizeof("negated")];
    char _gst_builtin_selectors_names_str835[sizeof("removeLast")];
    char _gst_builtin_selectors_names_str839[sizeof("detect:ifNone:")];
    char _gst_builtin_selectors_names_str841[sizeof("asString")];
    char _gst_builtin_selectors_names_str843[sizeof("atAllPut:")];
    char _gst_builtin_selectors_names_str844[sizeof("readStream")];
    char _gst_builtin_selectors_names_str847[sizeof("asOrderedCollection")];
    char _gst_builtin_selectors_names_str849[sizeof("asArray")];
    char _gst_builtin_selectors_names_str850[sizeof("squared")];
    char _gst_builtin_selectors_names_str854[sizeof("asTkString")];
    char _gst_builtin_selectors_names_str857[sizeof("arguments")];
    char _gst_builtin_selectors_names_str859[sizeof("asSortedCollection")];
    char _gst_builtin_selectors_names_str860[sizeof("executeAndWait:arguments:")];
    char _gst_builtin_selectors_names_str861[sizeof("updateViews")];
    char _gst_builtin_selectors_names_str862[sizeof("select:")];
    char _gst_builtin_selectors_names_str864[sizeof("selector:")];
    char _gst_builtin_selectors_names_str865[sizeof("temporaries")];
    char _gst_builtin_selectors_names_str866[sizeof("at:ifPresent:")];
    char _gst_builtin_selectors_names_str869[sizeof("variable")];
    char _gst_builtin_selectors_names_str870[sizeof("value:")];
    char _gst_builtin_selectors_names_str873[sizeof("javaAsInt")];
    char _gst_builtin_selectors_names_str876[sizeof("value:value:")];
    char _gst_builtin_selectors_names_str879[sizeof("source")];
    char _gst_builtin_selectors_names_str880[sizeof("addAll:")];
    char _gst_builtin_selectors_names_str883[sizeof("selectors:receiver:argument:")];
    char _gst_builtin_selectors_names_str884[sizeof("superspace")];
    char _gst_builtin_selectors_names_str886[sizeof("allSubclassesDo:")];
    char _gst_builtin_selectors_names_str888[sizeof("asInteger")];
    char _gst_builtin_selectors_names_str889[sizeof("between:and:")];
    char _gst_builtin_selectors_names_str893[sizeof("basicAt:")];
    char _gst_builtin_selectors_names_str897[sizeof("basicAt:put:")];
    char _gst_builtin_selectors_names_str903[sizeof("species")];
    char _gst_builtin_selectors_names_str905[sizeof("beConsistent")];
    char _gst_builtin_selectors_names_str906[sizeof("numArgs")];
    char _gst_builtin_selectors_names_str916[sizeof("methodDictionary")];
    char _gst_builtin_selectors_names_str920[sizeof("subclassResponsibility")];
    char _gst_builtin_selectors_names_str922[sizeof("assert:")];
    char _gst_builtin_selectors_names_str929[sizeof("javaAsLong")];
    char _gst_builtin_selectors_names_str932[sizeof("addLast:")];
    char _gst_builtin_selectors_names_str954[sizeof("getResponse")];
    char _gst_builtin_selectors_names_str966[sizeof("asClass")];
    char _gst_builtin_selectors_names_str973[sizeof("method")];
    char _gst_builtin_selectors_names_str978[sizeof("asSeconds")];
    char _gst_builtin_selectors_names_str981[sizeof("evaluate")];
    char _gst_builtin_selectors_names_str989[sizeof("status")];
    char _gst_builtin_selectors_names_str998[sizeof("average")];
    char _gst_builtin_selectors_names_str1001[sizeof("asFloat")];
    char _gst_builtin_selectors_names_str1004[sizeof("asSymbol")];
    char _gst_builtin_selectors_names_str1027[sizeof("basicSize")];
    char _gst_builtin_selectors_names_str1034[sizeof("statements")];
    char _gst_builtin_selectors_names_str1044[sizeof("asFloatD")];
  };
static struct _gst_builtin_selectors_names_t _gst_builtin_selectors_names_contents =
  {
    "|",
    ">",
    "pi",
    "=",
    "cr",
    "/",
    ">=",
    "&",
    "-",
    "==",
    "->",
    "width",
    "first",
    ",",
    "y",
    "//",
    "sizeof",
    "new",
    "findIndexOrNil:",
    "ln",
    "container",
    "~=",
    "with:",
    "with:with:",
    "origin",
    "narrow",
    "\\\\",
    "flush",
    "rows:",
    "x",
    "primSize",
    "wait",
    "<=",
    "nl",
    "new:",
    "foregroundColor:",
    "zero",
    "copy",
    "origin:corner:",
    "*",
    "initialize:",
    "skip:",
    "hash",
    "checkError",
    "bindWith:",
    "size",
    "copyWith:",
    "bindWith:with:",
    "includes:",
    "includesKey:",
    "invalidArgsError:",
    "initialize",
    "print:",
    "+",
    "inject:into:",
    "thisContext",
    "primAt:",
    "min:",
    "primAt:put:",
    "connected",
    "current",
    "connectIfClosed",
    "key",
    "copyFrom:to:",
    "printOn:",
    "on:",
    "sign",
    "upTo:",
    "width:height:",
    "count",
    "with:do:",
    "<",
    "primitive",
    "height",
    "checkResponse",
    "not",
    "isNil",
    "coefficients:",
    "primitiveFailed",
    "contents",
    "bitShift:",
    "sqrt",
    "close",
    "position",
    "collect:",
    "fromSeconds:",
    "peek",
    "~~",
    "writeStream",
    "perform:",
    "replaceFrom:to:with:startingAt:",
    "receiver",
    "instanceClass",
    "properties",
    "exp",
    "bitXor:",
    "login",
    "errorContents:",
    "keys",
    "changeState:",
    "error:",
    "to:",
    "keysAndValuesDo:",
    "x:y:",
    "accumulate:",
    "bind:to:of:parameters:",
    "printString",
    "upToEnd",
    "callFrom:into:",
    "return:",
    "clientPI",
    "position:",
    "reset",
    "create:",
    "class",
    "yourself",
    "stop",
    "nextToken",
    "readFrom:",
    "isEmpty",
    "on:do:",
    "at:",
    "retryRelationalOp:coercing:",
    "signalError",
    "backgroundColor:",
    "parent:",
    "name:",
    "body",
    "step",
    "bitOr:",
    "parent",
    "text",
    "parentContext",
    "skipSeparators",
    "notNil",
    "blox",
    "body:",
    "data:",
    "copyEmpty:",
    "beep",
    "implementation",
    "coerce:",
    "should:",
    "background",
    "asOop",
    "name",
    "isInteger",
    "default",
    "space",
    "tclEval:",
    "tclEval:with:",
    "bitAnd:",
    "tclEval:with:with:",
    "shouldNotImplement",
    "tclEval:with:with:with:",
    "postCopy",
    "add:",
    "days",
    "start",
    "variance",
    "nameIn:",
    "visitNode:",
    "last",
    "tclResult",
    "nextPutAll:",
    "signal:",
    "signalOn:",
    "superclass",
    "signalOn:what:",
    "signalOn:mustBe:",
    "signalOn:withIndex:",
    "state",
    "at:type:",
    "signal",
    "completedSuccessfully",
    "truncated",
    "basicNew",
    "max:",
    "value",
    "become:",
    "environment",
    "selector",
    "at:ifAbsent:",
    "isKindOf:",
    "at:ifAbsentPut:",
    "bytecodeAt:",
    "generality",
    "exists",
    "arguments:",
    "ensure:",
    "activeProcess",
    "store:",
    "at:put:",
    "asLowercase",
    "asNumber",
    "displayString",
    "random",
    "allSatisfy:",
    "asVector",
    "abs",
    "negated",
    "removeLast",
    "detect:ifNone:",
    "asString",
    "atAllPut:",
    "readStream",
    "asOrderedCollection",
    "asArray",
    "squared",
    "asTkString",
    "arguments",
    "asSortedCollection",
    "executeAndWait:arguments:",
    "updateViews",
    "select:",
    "selector:",
    "temporaries",
    "at:ifPresent:",
    "variable",
    "value:",
    "javaAsInt",
    "value:value:",
    "source",
    "addAll:",
    "selectors:receiver:argument:",
    "superspace",
    "allSubclassesDo:",
    "asInteger",
    "between:and:",
    "basicAt:",
    "basicAt:put:",
    "species",
    "beConsistent",
    "numArgs",
    "methodDictionary",
    "subclassResponsibility",
    "assert:",
    "javaAsLong",
    "addLast:",
    "getResponse",
    "asClass",
    "method",
    "asSeconds",
    "evaluate",
    "status",
    "average",
    "asFloat",
    "asSymbol",
    "basicSize",
    "statements",
    "asFloatD"
  };
#define _gst_builtin_selectors_names ((const char *) &_gst_builtin_selectors_names_contents)

static unsigned char lengthtable[] =
  {
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  2,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,
     0,  0,  0,  0,  0,  0,  0,  2,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  1,  0,  1,  2,  0,  0,  0,  0,  2,  0,  0,
     0,  0,  0,  0,  0,  0,  5,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  5,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  2,
     0,  0,  6,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0, 15,  2,  0,  0,  0,  0,
     0,  0,  9,  0,  0,  0,  0,  0,  0,  0,  2,  0,  0,  5,
     0,  0,  0,  0,  0,  0,  0, 10,  0,  6,  6,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  0,  0,  0,
     5,  5,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  8,  0,
     0,  0,  0,  0,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  4,  0, 16,  0,  0,  4,  0,  4,  0,
    14,  1,  0,  0, 11,  0,  0,  0,  0,  0,  5,  0,  0,  0,
     4,  0,  0,  0,  0,  0, 10,  0,  9,  4,  0,  0,  9, 14,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  9,  0,  0, 12, 17,
    10,  0,  0,  6,  0,  1,  0,  0, 12,  0,  0,  0,  0, 11,
     0,  7,  4,  0,  0, 11,  0,  0,  0,  0,  9,  0,  0,  0,
     7,  0, 15,  0,  0,  0,  0,  3,  0,  0, 12,  8,  3,  4,
     0,  5, 13,  0,  5,  0,  0,  0,  8,  1,  0,  0,  0,  0,
     9,  6,  0, 13,  0,  0,  3,  0,  5, 13,  0, 15,  0,  0,
     0,  8,  9,  4,  5,  8,  0,  8,  0, 12,  0,  0,  0,  4,
     0,  0,  0,  0,  2, 11,  0,  0,  0,  0,  0,  8,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0, 31,  8,  0,  0,  0,  0,
     0,  0,  0, 13, 10,  0,  0,  0,  3,  7,  0,  0,  0,  5,
    14,  4, 12,  0,  0,  6,  3,  0, 16,  4,  0,  0, 11,  0,
     0,  0,  0,  0,  0,  0,  0,  0, 22, 11,  0,  0,  7, 14,
     0,  7,  8,  9,  5,  7,  0,  5,  8,  4,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  9,  0,  0,  0,  0,  0,  0,  0,
     9,  0,  7,  0,  0,  6,  0,  0,  3,  0,  0,  0,  0, 27,
     0, 11,  0,  0,  0,  0,  0,  0,  0,  0, 16,  7,  0,  5,
     0,  4,  4,  6,  0,  0,  0,  6,  0,  4,  0,  0,  0,  0,
    13,  0,  0,  0, 14,  0,  0,  0,  6,  4,  0,  5,  5,  0,
    10,  0,  4, 14,  7,  7, 10,  5,  0,  4,  9,  7,  5,  8,
     0,  0,  0,  0, 13,  0,  7,  0,  0, 18,  0,  0,  0, 18,
    23,  8,  4,  4,  0,  5,  8,  0,  7, 10,  4,  0,  0,  0,
     0,  0,  0,  9, 11,  0,  7,  0,  9,  0,  0,  0, 10, 14,
     0, 16,  0,  0, 19,  5,  0,  8,  6, 21,  0,  0,  0,  0,
     9,  0,  0,  0,  0,  8,  0,  4,  5,  0,  0,  0,  7, 11,
     8,  0, 12,  0,  9, 15,  0, 11,  0, 10,  0,  0,  0,  6,
     0,  0,  0,  0,  0,  0, 10,  0,  7,  0, 13,  6,  0,  7,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11,  8,  0,  0,
     0,  0,  0, 13,  0,  0,  6,  0,  0,  0,  0,  0, 11,  0,
     0,  0,  0,  0,  8,  3,  0,  0,  7, 10,  0,  0,  0, 14,
     0,  8,  0,  9, 10,  0,  0, 19,  0,  7,  7,  0,  0,  0,
    10,  0,  0,  9,  0, 18, 25, 11,  7,  0,  9, 11, 13,  0,
     0,  8,  6,  0,  0,  9,  0,  0, 12,  0,  0,  6,  7,  0,
     0, 28, 10,  0, 16,  0,  9, 12,  0,  0,  0,  8,  0,  0,
     0, 12,  0,  0,  0,  0,  0,  7,  0, 12,  7,  0,  0,  0,
     0,  0,  0,  0,  0,  0, 16,  0,  0,  0, 22,  0,  7,  0,
     0,  0,  0,  0,  0, 10,  0,  0,  8,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0, 11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     7,  0,  0,  0,  0,  0,  0,  6,  0,  0,  0,  0,  9,  0,
     0,  8,  0,  0,  0,  0,  0,  0,  0,  6,  0,  0,  0,  0,
     0,  0,  0,  0,  7,  0,  0,  7,  0,  0,  8,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  9,  0,  0,  0,  0,  0,  0, 10,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  8
  };

static struct builtin_selector _gst_builtin_selectors_hash[] =
  {
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 186 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str59,                  			NULL, 1,       152},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 42 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str99,                  			NULL, 1,        GREATER_THAN_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 189 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str108,					NULL, 0,       155},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 45 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str125,                  			NULL, 1,        EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 109 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str143,                 			NULL, 0,       75},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 48 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str167,                  			NULL, 1,        DIVIDE_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 44 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str175,                 			NULL, 1,        GREATER_EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 276 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str185,                  			NULL, 1,       242},
    {-1,NULL,-1,-1},
#line 40 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str187,                  			NULL, 1,        MINUS_SPECIAL},
#line 63 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str188,                 			NULL, 1,        SAME_OBJECT_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 120 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str193,                 			NULL, 1,       86},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 206 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str202,              			NULL, 0,       172},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 84 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str214,              			NULL, 0,       50},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 72 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str229,                  			NULL, 1,       38},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 114 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str243,                  			NULL, 0,       80},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 52 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str251,                 			NULL, 1,        INTEGER_DIVIDE_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 187 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str254,             			NULL, 0,       153},
#line 118 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str255,                			NULL, 0,       84},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 281 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str288,    			NULL, 1,       247},
#line 171 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str289,                 			NULL, 0,       137},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 82 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str296,          			NULL, 0,       48},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 46 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str304,                 			NULL, 1,        NOT_EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 98 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str307,              			NULL, 1,       64},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 122 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str315,         			NULL, 2,       88},
    {-1,NULL,-1,-1},
#line 239 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str317,             			NULL, 0,       205},
#line 69 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str318,             			NULL, 0,       35},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 49 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str332,               			NULL, 1,        REMAINDER_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 157 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str336,              			NULL, 0,       123},
#line 181 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str337,              			NULL, 1,       147},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 112 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str341,                  			NULL, 0,       78},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 162 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str348,           			NULL, 0,       128},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 233 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str354,               			NULL, 0,       199},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 43 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str375,                 			NULL, 1,        LESS_EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 76 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str387,                 			NULL, 0,       42},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 66 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str397,               			NULL, 1,        NEW_COLON_SPECIAL},
    {-1,NULL,-1,-1},
#line 180 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str399,   			NULL, 1,       146},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 209 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str402,               			NULL, 0,       175},
    {-1,NULL,-1,-1},
#line 99 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str404,               			NULL, 0,       65},
    {-1,NULL,-1,-1},
#line 267 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str406,     			NULL, 2,       233},
#line 47 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str407,                  			NULL, 1,        TIMES_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 107 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str410,        			NULL, 1,       73},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 272 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str416,              			NULL, 1,       238},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 145 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str420,               			NULL, 0,       111},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 203 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str426,         			NULL, 0,       169},
    {-1,NULL,-1,-1},
#line 269 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str428,          			NULL, 1,       235},
#line 57 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str429,               			NULL, 0,        SIZE_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 283 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str432,          			NULL, 1,       249},
#line 210 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str433,     			NULL, 2,       176},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 95 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str443,          			NULL, 1,       61},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 188 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str446,       			NULL, 1,       154},
#line 254 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str447,  			NULL, 1,       220},
#line 103 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str448,         			NULL, 0,       69},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 101 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str451,             			NULL, 1,       67},
    {-1,NULL,-1,-1},
#line 39 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str453,                  			NULL, 1,        PLUS_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 196 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str456,       			NULL, 2,       162},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 67 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str461,        			NULL, 0,        THIS_CONTEXT_SPECIAL},
    {-1,NULL,-1,-1},
#line 148 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str463,            			NULL, 1,       114},
#line 205 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str464,               			NULL, 1,       171},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 247 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str467,        			NULL, 2,       213},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 164 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str472,          			NULL, 0,       130},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 198 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str476,            			NULL, 0,       164},
    {-1,NULL,-1,-1},
#line 201 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str478,    			NULL, 0,       167},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 88 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str483,                			NULL, 0,       54},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 100 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str486,       			NULL, 2,       66},
#line 139 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str487,           			NULL, 1,       105},
#line 73 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str488,                			NULL, 1,       39},
#line 229 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str489,               			NULL, 0,       195},
    {-1,NULL,-1,-1},
#line 175 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str491,              			NULL, 1,       141},
#line 213 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str492,      			NULL, 2,       179},
    {-1,NULL,-1,-1},
#line 216 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str494,              			NULL, 0,       182},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 280 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str498,           			NULL, 2,       246},
#line 41 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str499,                  			NULL, 1,        LESS_THAN_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 261 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str504,          			NULL, 0,       227},
#line 258 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str505,             			NULL, 0,       224},
    {-1,NULL,-1,-1},
#line 173 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str507,      			NULL, 0,       139},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 93 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str510,                			NULL, 0,       59},
    {-1,NULL,-1,-1},
#line 59 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str512,              			NULL, 0,        IS_NIL_SPECIAL},
#line 155 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str513,      			NULL, 1,       121},
    {-1,NULL,-1,-1},
#line 106 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str515,    			NULL, 0,       72},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 78 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str519,           			NULL, 0,       44},
#line 51 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str520,          			NULL, 1,        BIT_SHIFT_COLON_SPECIAL},
#line 146 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str521,               			NULL, 0,       112},
#line 94 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str522,              			NULL, 0,       60},
#line 150 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str523,           			NULL, 0,       116},
    {-1,NULL,-1,-1},
#line 86 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str525,           			NULL, 1,       52},
    {-1,NULL,-1,-1},
#line 275 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str527,       			NULL, 1,       241},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 177 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str531,               			NULL, 0,       143},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 227 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str536,                 			NULL, 1,       193},
#line 191 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str537,        			NULL, 0,       157},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 242 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str543,           			NULL, 1,       208},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 197 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str554,        NULL, 4,       163},
#line 176 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str555,           			NULL, 0,       142},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 234 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str563,      			NULL, 0,       200},
#line 81 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str564,         			NULL, 0,       47},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 183 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str568,                			NULL, 0,       149},
#line 50 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str569,            			NULL, 1,        BIT_XOR_COLON_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 244 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str573,              			NULL, 0,       210},
#line 264 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str574,     			NULL, 1,       230},
#line 236 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str575,               			NULL, 0,       202},
#line 228 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str576,       			NULL, 1,       194},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 83 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str579,             			NULL, 1,       49},
#line 130 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str580,                			NULL, 1,       96},
    {-1,NULL,-1,-1},
#line 138 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str582,   			NULL, 1,       104},
#line 179 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str583,               			NULL, 2,       145},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 215 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str586,        			NULL, 1,       181},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 225 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str596,                 NULL, 4,       191},
#line 77 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str597,        			NULL, 0,       43},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 277 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str600,            			NULL, 0,       243},
#line 68 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str601,     			NULL, 2,       34},
    {-1,NULL,-1,-1},
#line 226 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str603,            			NULL, 1,       192},
#line 156 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str604,           			NULL, 0,       122},
#line 250 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str605,          			NULL, 1,       216},
#line 165 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str606,              			NULL, 0,       131},
#line 287 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str607,            			NULL, 1,       253},
    {-1,NULL,-1,-1},
#line 58 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str609,              			NULL, 0,        CLASS_SPECIAL},
#line 71 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str610,           			NULL, 0,       37},
#line 241 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str611,               			NULL, 0,       207},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 246 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str622,          			NULL, 0,       212},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 154 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str630,          			NULL, 1,       120},
    {-1,NULL,-1,-1},
#line 80 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str632,            			NULL, 0,       46},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 160 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str635,             			NULL, 2,       126},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 55 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str638,                			NULL, 1,        AT_COLON_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 200 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str643,            NULL, 2,       166},
    {-1,NULL,-1,-1},
#line 257 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str645,        			NULL, 0,       223},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 243 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str654,   			NULL, 1,       209},
#line 222 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str655,            			NULL, 1,       188},
    {-1,NULL,-1,-1},
#line 144 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str657,              			NULL, 1,       110},
    {-1,NULL,-1,-1},
#line 136 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str659,               			NULL, 0,       102},
#line 125 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str660,               			NULL, 0,       91},
#line 54 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str661,             			NULL, 1,        BIT_OR_COLON_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 127 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str665,             			NULL, 0,       93},
    {-1,NULL,-1,-1},
#line 182 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str667,               			NULL, 0,       148},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 207 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str672,      			NULL, 0,       173},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 266 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str676,     			NULL, 0,       232},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 60 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str680,             			NULL, 0,        NOT_NIL_SPECIAL},
#line 124 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str681,               			NULL, 0,       90},
    {-1,NULL,-1,-1},
#line 185 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str683,              			NULL, 1,       151},
#line 245 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str684,              			NULL, 1,       211},
    {-1,NULL,-1,-1},
#line 166 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str686,         			NULL, 1,       132},
    {-1,NULL,-1,-1},
#line 147 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str688,               			NULL, 0,       113},
#line 172 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str689,     			NULL, 0,       138},
#line 288 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str690,            			NULL, 1,       254},
#line 110 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str691,            			NULL, 1,       76},
#line 284 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str692,         			NULL, 0,       250},
#line 212 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str693,              			NULL, 0,       178},
    {-1,NULL,-1,-1},
#line 79 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str695,               			NULL, 0,       45},
#line 143 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str696,          			NULL, 0,       109},
#line 251 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str697,            			NULL, 0,       217},
#line 117 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str698,              			NULL, 0,       83},
#line 85 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str699,           			NULL, 1,       51},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 274 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str704,      			NULL, 2,       240},
    {-1,NULL,-1,-1},
#line 53 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str706,            			NULL, 1,        BIT_AND_COLON_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 104 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str709, 			NULL, 3,       70},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 119 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str713, 			NULL, 0,       85},
#line 115 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str714,                NULL, 4,       81},
#line 153 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str715,           			NULL, 0,       119},
#line 75 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str716,               			NULL, 1,       41},
#line 273 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str717,               			NULL, 0,       239},
    {-1,NULL,-1,-1},
#line 167 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str719,              			NULL, 0,       133},
#line 230 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str720,           			NULL, 0,       196},
    {-1,NULL,-1,-1},
#line 255 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str722,            			NULL, 1,       221},
#line 141 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str723,         			NULL, 1,       107},
#line 102 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str724,               			NULL, 0,       68},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 87 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str731,          			NULL, 0,       53},
#line 70 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str732,        			NULL, 1,       36},
    {-1,NULL,-1,-1},
#line 152 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str734,            			NULL, 1,       118},
    {-1,NULL,-1,-1},
#line 168 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str736,          			NULL, 1,       134},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 192 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str740,         			NULL, 0,       158},
#line 220 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str741,     			NULL, 2,       186},
    {-1,NULL,-1,-1},
#line 134 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str743,   			NULL, 2,       100},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 224 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str746,			NULL, 2,       190},
#line 194 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str747,              			NULL, 0,       160},
    {-1,NULL,-1,-1},
#line 271 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str749,           			NULL, 2,       237},
#line 126 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str750,             			NULL, 0,       92},
#line 190 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str751,                  NULL, 0,       156},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 195 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str756,          			NULL, 0,       161},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 91 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str761,           			NULL, 0,       57},
    {-1,NULL,-1,-1},
#line 137 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str763,               			NULL, 1,       103},
#line 61 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str764,              			NULL, 0,        VALUE_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 279 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str768,            			NULL, 1,       245},
#line 149 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str769,        			NULL, 0,       115},
#line 128 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str770,           			NULL, 0,       94},
    {-1,NULL,-1,-1},
#line 96 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str772,       			NULL, 2,       62},
    {-1,NULL,-1,-1},
#line 140 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str774,          			NULL, 1,       106},
#line 151 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str775,    			NULL, 2,       117},
    {-1,NULL,-1,-1},
#line 289 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str777,        			NULL, 1,       255},
    {-1,NULL,-1,-1},
#line 133 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str779,         			NULL, 0,       99},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 219 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str783,             			NULL, 0,       185},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 193 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str790,         			NULL, 1,       159},
    {-1,NULL,-1,-1},
#line 135 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str792,            			NULL, 1,       101},
    {-1,NULL,-1,-1},
#line 268 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str794,      			NULL, 0,       234},
#line 262 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str795,             			NULL, 1,       228},
    {-1,NULL,-1,-1},
#line 56 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str797,            			NULL, 2,        AT_COLON_PUT_COLON_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 217 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str808,        			NULL, 0,       183},
#line 260 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str809,           			NULL, 0,       226},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 265 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str815,      			NULL, 0,       231},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 238 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str818,             			NULL, 0,       204},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 249 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str824,        			NULL, 1,       215},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 231 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str830,           			NULL, 0,       197},
#line 90 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str831,                			NULL, 0,       56},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 92 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str834,            			NULL, 0,       58},
#line 208 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str835,         			NULL, 0,       174},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 202 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str839,     			NULL, 2,       168},
    {-1,NULL,-1,-1},
#line 108 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str841,           			NULL, 0,       74},
    {-1,NULL,-1,-1},
#line 252 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str843,          			NULL, 1,       218},
#line 113 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str844,         			NULL, 0,       79},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 235 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str847,			NULL, 0,       201},
    {-1,NULL,-1,-1},
#line 218 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str849,            			NULL, 0,       184},
#line 132 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str850,            			NULL, 0,       98},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 89 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str854,         			NULL, 0,       55},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 111 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str857,          			NULL, 0,       77},
    {-1,NULL,-1,-1},
#line 253 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str859, 			NULL, 0,       219},
#line 204 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str860,              NULL, 2,       170},
#line 263 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str861,        			NULL, 0,       229},
#line 221 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str862,            			NULL, 1,       187},
    {-1,NULL,-1,-1},
#line 223 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str864,          			NULL, 1,       189},
#line 211 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str865,        			NULL, 0,       177},
#line 129 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str866,      			NULL, 2,       95},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 278 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str869,           			NULL, 0,       244},
#line 62 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str870,              			NULL, 1,        VALUE_COLON_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 64 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str873,				NULL, 0,	JAVA_AS_INT_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 158 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str876,       			NULL, 2,       124},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 259 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str879,             			NULL, 0,       225},
#line 142 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str880,            			NULL, 1,       108},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 286 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str883,           NULL, 3,       252},
#line 240 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str884,         			NULL, 0,       206},
    {-1,NULL,-1,-1},
#line 256 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str886,   			NULL, 1,       222},
    {-1,NULL,-1,-1},
#line 116 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str888,          			NULL, 0,       82},
#line 199 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str889,       			NULL, 2,       165},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 169 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str893,           			NULL, 1,       135},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 161 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str897,       			NULL, 2,       127},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 123 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str903,            			NULL, 0,       89},
    {-1,NULL,-1,-1},
#line 270 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str905,       			NULL, 0,       236},
#line 121 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str906,            			NULL, 0,       87},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 214 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str916,   			NULL, 0,       180},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 74 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str920,                 NULL, 0,       40},
    {-1,NULL,-1,-1},
#line 105 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str922,            			NULL, 1,       71},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 65 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str929,				NULL, 0,	JAVA_AS_LONG_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 131 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str932,           			NULL, 1,       97},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 232 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str954,        			NULL, 0,       198},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 170 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str966,            			NULL, 0,       136},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 248 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str973,             			NULL, 0,       214},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 282 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str978,          			NULL, 0,       248},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 163 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str981,           			NULL, 0,       129},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 285 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str989,             			NULL, 0,       251},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 174 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str998,            			NULL, 0,       140},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 237 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str1001,            			NULL, 0,       203},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 97 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str1004,           			NULL, 0,       63},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 178 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str1027,          			NULL, 0,       144},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 184 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str1034,         			NULL, 0,       150},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 159 "builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str1044,           			NULL, 0,       125}
  };

#ifdef __GNUC__
__inline
#endif
struct builtin_selector *
_gst_lookup_builtin_selector (str, len)
     register const char *str;
     register unsigned int len;
{
  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      register int key = _gst_hash_selector (str, len);

      if (key <= MAX_HASH_VALUE && key >= 0)
        if (len == lengthtable[key])
          {
            register const char *s = _gst_builtin_selectors_hash[key].offset + _gst_builtin_selectors_names;

            if (*str == *s && !memcmp (str + 1, s + 1, len - 1))
              return &_gst_builtin_selectors_hash[key];
          }
    }
  return 0;
}
