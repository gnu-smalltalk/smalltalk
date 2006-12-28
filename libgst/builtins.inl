/* C code produced by gperf version 3.0.1 */
/* Command-line: gperf -k'1-3,6,$' -r ../../libgst/builtins.gperf  */

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

#line 15 "../../libgst/builtins.gperf"

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
    MIN_HASH_VALUE = 1,
    MAX_HASH_VALUE = 973
  };

/* maximum key range = 973, duplicates = 0 */

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
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 240, 974,
      974, 974,   3,  96,  47,  84, 974,   0, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 187, 974,
      202, 137,  17, 974, 974, 148, 974, 223,  76, 124,
        1, 974, 974,  83, 974, 183,  87, 974, 197,   4,
      182, 974,  61, 242,  63, 974, 203, 974, 974, 974,
      974, 974,  84, 974, 974, 974, 974,  81, 215, 244,
      136, 158, 255, 255, 111,  28,  68,   1,  52,   2,
      128, 206,  18,  10,  67, 142, 196,  24, 174, 173,
      171,  37, 140, 974, 176, 974, 239, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974, 974, 974, 974, 974,
      974, 974, 974, 974, 974, 974
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
    char _gst_builtin_selectors_names_str1[sizeof("/")];
    char _gst_builtin_selectors_names_str2[sizeof("//")];
    char _gst_builtin_selectors_names_str7[sizeof("*")];
    char _gst_builtin_selectors_names_str35[sizeof(">")];
    char _gst_builtin_selectors_names_str75[sizeof("y")];
    char _gst_builtin_selectors_names_str76[sizeof("pi")];
    char _gst_builtin_selectors_names_str95[sizeof(",")];
    char _gst_builtin_selectors_names_str120[sizeof("->")];
    char _gst_builtin_selectors_names_str169[sizeof("-")];
    char _gst_builtin_selectors_names_str192[sizeof("implementation")];
    char _gst_builtin_selectors_names_str193[sizeof("+")];
    char _gst_builtin_selectors_names_str234[sizeof("nl")];
    char _gst_builtin_selectors_names_str236[sizeof("key")];
    char _gst_builtin_selectors_names_str250[sizeof("asOop")];
    char _gst_builtin_selectors_names_str254[sizeof("\\\\")];
    char _gst_builtin_selectors_names_str275[sizeof("=")];
    char _gst_builtin_selectors_names_str286[sizeof("random")];
    char _gst_builtin_selectors_names_str293[sizeof(">=")];
    char _gst_builtin_selectors_names_str297[sizeof("upTo:")];
    char _gst_builtin_selectors_names_str307[sizeof("primSize")];
    char _gst_builtin_selectors_names_str310[sizeof("ln")];
    char _gst_builtin_selectors_names_str312[sizeof("printOn:")];
    char _gst_builtin_selectors_names_str339[sizeof("peek")];
    char _gst_builtin_selectors_names_str342[sizeof("keys")];
    char _gst_builtin_selectors_names_str343[sizeof("x")];
    char _gst_builtin_selectors_names_str349[sizeof("min:")];
    char _gst_builtin_selectors_names_str353[sizeof("|")];
    char _gst_builtin_selectors_names_str363[sizeof("skip:")];
    char _gst_builtin_selectors_names_str368[sizeof("exp")];
    char _gst_builtin_selectors_names_str373[sizeof("name")];
    char _gst_builtin_selectors_names_str376[sizeof("upToEnd")];
    char _gst_builtin_selectors_names_str380[sizeof("cr")];
    char _gst_builtin_selectors_names_str389[sizeof("asFloatD")];
    char _gst_builtin_selectors_names_str400[sizeof("days")];
    char _gst_builtin_selectors_names_str403[sizeof("name:")];
    char _gst_builtin_selectors_names_str404[sizeof("space")];
    char _gst_builtin_selectors_names_str405[sizeof("<")];
    char _gst_builtin_selectors_names_str413[sizeof("==")];
    char _gst_builtin_selectors_names_str419[sizeof("sqrt")];
    char _gst_builtin_selectors_names_str424[sizeof("isNil")];
    char _gst_builtin_selectors_names_str433[sizeof("initialize")];
    char _gst_builtin_selectors_names_str445[sizeof("max:")];
    char _gst_builtin_selectors_names_str447[sizeof("flush")];
    char _gst_builtin_selectors_names_str449[sizeof("hash")];
    char _gst_builtin_selectors_names_str453[sizeof("width")];
    char _gst_builtin_selectors_names_str460[sizeof("primitiveFailed")];
    char _gst_builtin_selectors_names_str463[sizeof("initialize:")];
    char _gst_builtin_selectors_names_str470[sizeof("value")];
    char _gst_builtin_selectors_names_str472[sizeof("size")];
    char _gst_builtin_selectors_names_str475[sizeof("last")];
    char _gst_builtin_selectors_names_str476[sizeof("primitive")];
    char _gst_builtin_selectors_names_str477[sizeof("squared")];
    char _gst_builtin_selectors_names_str478[sizeof("<=")];
    char _gst_builtin_selectors_names_str481[sizeof("&")];
    char _gst_builtin_selectors_names_str482[sizeof("wait")];
    char _gst_builtin_selectors_names_str485[sizeof("skipSeparators")];
    char _gst_builtin_selectors_names_str487[sizeof("isInteger")];
    char _gst_builtin_selectors_names_str489[sizeof("updateViews")];
    char _gst_builtin_selectors_names_str493[sizeof("print:")];
    char _gst_builtin_selectors_names_str494[sizeof("superspace")];
    char _gst_builtin_selectors_names_str496[sizeof("asArray")];
    char _gst_builtin_selectors_names_str503[sizeof("primAt:")];
    char _gst_builtin_selectors_names_str505[sizeof("perform:")];
    char _gst_builtin_selectors_names_str507[sizeof("primAt:put:")];
    char _gst_builtin_selectors_names_str508[sizeof("asFloat")];
    char _gst_builtin_selectors_names_str509[sizeof("copy")];
    char _gst_builtin_selectors_names_str510[sizeof("properties")];
    char _gst_builtin_selectors_names_str513[sizeof("truncated")];
    char _gst_builtin_selectors_names_str514[sizeof("readStream")];
    char _gst_builtin_selectors_names_str515[sizeof("~=")];
    char _gst_builtin_selectors_names_str518[sizeof("step")];
    char _gst_builtin_selectors_names_str521[sizeof("subclassResponsibility")];
    char _gst_builtin_selectors_names_str523[sizeof("writeStream")];
    char _gst_builtin_selectors_names_str524[sizeof("class")];
    char _gst_builtin_selectors_names_str527[sizeof("keysAndValuesDo:")];
    char _gst_builtin_selectors_names_str530[sizeof("position")];
    char _gst_builtin_selectors_names_str532[sizeof("asOrderedCollection")];
    char _gst_builtin_selectors_names_str533[sizeof("nameIn:")];
    char _gst_builtin_selectors_names_str534[sizeof("isEmpty")];
    char _gst_builtin_selectors_names_str535[sizeof("signal")];
    char _gst_builtin_selectors_names_str540[sizeof("asInteger")];
    char _gst_builtin_selectors_names_str544[sizeof("add:")];
    char _gst_builtin_selectors_names_str545[sizeof("methodDictionary")];
    char _gst_builtin_selectors_names_str551[sizeof("first")];
    char _gst_builtin_selectors_names_str553[sizeof("beep")];
    char _gst_builtin_selectors_names_str555[sizeof("signalError")];
    char _gst_builtin_selectors_names_str556[sizeof("parent:")];
    char _gst_builtin_selectors_names_str557[sizeof("sign")];
    char _gst_builtin_selectors_names_str558[sizeof("numArgs")];
    char _gst_builtin_selectors_names_str562[sizeof("invalidArgsError:")];
    char _gst_builtin_selectors_names_str563[sizeof("origin")];
    char _gst_builtin_selectors_names_str564[sizeof("parent")];
    char _gst_builtin_selectors_names_str566[sizeof("stop")];
    char _gst_builtin_selectors_names_str568[sizeof("reset")];
    char _gst_builtin_selectors_names_str569[sizeof("readFrom:")];
    char _gst_builtin_selectors_names_str571[sizeof("parentContext")];
    char _gst_builtin_selectors_names_str573[sizeof("statements")];
    char _gst_builtin_selectors_names_str575[sizeof("zero")];
    char _gst_builtin_selectors_names_str576[sizeof("temporaries")];
    char _gst_builtin_selectors_names_str579[sizeof("allSatisfy:")];
    char _gst_builtin_selectors_names_str580[sizeof("superclass")];
    char _gst_builtin_selectors_names_str581[sizeof("instanceClass")];
    char _gst_builtin_selectors_names_str582[sizeof("state")];
    char _gst_builtin_selectors_names_str583[sizeof("abs")];
    char _gst_builtin_selectors_names_str586[sizeof("x:y:")];
    char _gst_builtin_selectors_names_str589[sizeof("with:")];
    char _gst_builtin_selectors_names_str590[sizeof("position:")];
    char _gst_builtin_selectors_names_str591[sizeof("removeLast")];
    char _gst_builtin_selectors_names_str595[sizeof("bindWith:")];
    char _gst_builtin_selectors_names_str598[sizeof("body")];
    char _gst_builtin_selectors_names_str599[sizeof("addAll:")];
    char _gst_builtin_selectors_names_str600[sizeof("bindWith:with:")];
    char _gst_builtin_selectors_names_str603[sizeof("allSubclassesDo:")];
    char _gst_builtin_selectors_names_str605[sizeof("data:")];
    char _gst_builtin_selectors_names_str611[sizeof("clientPI")];
    char _gst_builtin_selectors_names_str616[sizeof("variance")];
    char _gst_builtin_selectors_names_str617[sizeof("postCopy")];
    char _gst_builtin_selectors_names_str619[sizeof("inject:into:")];
    char _gst_builtin_selectors_names_str620[sizeof("start")];
    char _gst_builtin_selectors_names_str621[sizeof("printString")];
    char _gst_builtin_selectors_names_str623[sizeof("selector")];
    char _gst_builtin_selectors_names_str625[sizeof("species")];
    char _gst_builtin_selectors_names_str628[sizeof("narrow")];
    char _gst_builtin_selectors_names_str630[sizeof("origin:corner:")];
    char _gst_builtin_selectors_names_str634[sizeof("method")];
    char _gst_builtin_selectors_names_str635[sizeof("new")];
    char _gst_builtin_selectors_names_str637[sizeof("asLowercase")];
    char _gst_builtin_selectors_names_str638[sizeof("rows:")];
    char _gst_builtin_selectors_names_str640[sizeof("notNil")];
    char _gst_builtin_selectors_names_str646[sizeof("login")];
    char _gst_builtin_selectors_names_str647[sizeof("exists")];
    char _gst_builtin_selectors_names_str648[sizeof("blox")];
    char _gst_builtin_selectors_names_str650[sizeof("new:")];
    char _gst_builtin_selectors_names_str654[sizeof("at:")];
    char _gst_builtin_selectors_names_str655[sizeof("displayString")];
    char _gst_builtin_selectors_names_str660[sizeof("evaluate")];
    char _gst_builtin_selectors_names_str663[sizeof("bitShift:")];
    char _gst_builtin_selectors_names_str665[sizeof("close")];
    char _gst_builtin_selectors_names_str666[sizeof("current")];
    char _gst_builtin_selectors_names_str667[sizeof("copyEmpty:")];
    char _gst_builtin_selectors_names_str668[sizeof("completedSuccessfully")];
    char _gst_builtin_selectors_names_str669[sizeof("generality")];
    char _gst_builtin_selectors_names_str670[sizeof("javaAsInt")];
    char _gst_builtin_selectors_names_str671[sizeof("signal:")];
    char _gst_builtin_selectors_names_str672[sizeof("error:")];
    char _gst_builtin_selectors_names_str673[sizeof("signalOn:")];
    char _gst_builtin_selectors_names_str675[sizeof("count")];
    char _gst_builtin_selectors_names_str677[sizeof("at:type:")];
    char _gst_builtin_selectors_names_str678[sizeof("signalOn:what:")];
    char _gst_builtin_selectors_names_str679[sizeof("nextPutAll:")];
    char _gst_builtin_selectors_names_str680[sizeof("signalOn:mustBe:")];
    char _gst_builtin_selectors_names_str682[sizeof("container")];
    char _gst_builtin_selectors_names_str683[sizeof("signalOn:withIndex:")];
    char _gst_builtin_selectors_names_str685[sizeof("isKindOf:")];
    char _gst_builtin_selectors_names_str687[sizeof("value:")];
    char _gst_builtin_selectors_names_str688[sizeof("yourself")];
    char _gst_builtin_selectors_names_str690[sizeof("addLast:")];
    char _gst_builtin_selectors_names_str692[sizeof("copyWith:")];
    char _gst_builtin_selectors_names_str693[sizeof("value:value:")];
    char _gst_builtin_selectors_names_str694[sizeof("source")];
    char _gst_builtin_selectors_names_str695[sizeof("height")];
    char _gst_builtin_selectors_names_str696[sizeof("retryRelationalOp:coercing:")];
    char _gst_builtin_selectors_names_str697[sizeof("asVector")];
    char _gst_builtin_selectors_names_str700[sizeof("bitXor:")];
    char _gst_builtin_selectors_names_str701[sizeof("callInto:")];
    char _gst_builtin_selectors_names_str703[sizeof("variable")];
    char _gst_builtin_selectors_names_str705[sizeof("replaceFrom:to:with:startingAt:")];
    char _gst_builtin_selectors_names_str709[sizeof("status")];
    char _gst_builtin_selectors_names_str710[sizeof("asNumber")];
    char _gst_builtin_selectors_names_str711[sizeof("on:")];
    char _gst_builtin_selectors_names_str712[sizeof("arguments")];
    char _gst_builtin_selectors_names_str714[sizeof("checkError")];
    char _gst_builtin_selectors_names_str716[sizeof("errorContents:")];
    char _gst_builtin_selectors_names_str718[sizeof("receiver")];
    char _gst_builtin_selectors_names_str719[sizeof("~~")];
    char _gst_builtin_selectors_names_str724[sizeof("width:height:")];
    char _gst_builtin_selectors_names_str725[sizeof("text")];
    char _gst_builtin_selectors_names_str728[sizeof("with:do:")];
    char _gst_builtin_selectors_names_str729[sizeof("not")];
    char _gst_builtin_selectors_names_str730[sizeof("javaAsLong")];
    char _gst_builtin_selectors_names_str732[sizeof("includes:")];
    char _gst_builtin_selectors_names_str734[sizeof("copyFrom:to:")];
    char _gst_builtin_selectors_names_str735[sizeof("includesKey:")];
    char _gst_builtin_selectors_names_str737[sizeof("asClass")];
    char _gst_builtin_selectors_names_str738[sizeof("visitNode:")];
    char _gst_builtin_selectors_names_str740[sizeof("asSymbol")];
    char _gst_builtin_selectors_names_str741[sizeof("findIndexOrNil:")];
    char _gst_builtin_selectors_names_str742[sizeof("select:")];
    char _gst_builtin_selectors_names_str743[sizeof("return:")];
    char _gst_builtin_selectors_names_str744[sizeof("selector:")];
    char _gst_builtin_selectors_names_str745[sizeof("checkResponse")];
    char _gst_builtin_selectors_names_str747[sizeof("asTkString")];
    char _gst_builtin_selectors_names_str748[sizeof("thisContext")];
    char _gst_builtin_selectors_names_str749[sizeof("body:")];
    char _gst_builtin_selectors_names_str753[sizeof("background")];
    char _gst_builtin_selectors_names_str755[sizeof("assert:")];
    char _gst_builtin_selectors_names_str756[sizeof("asString")];
    char _gst_builtin_selectors_names_str758[sizeof("arguments:")];
    char _gst_builtin_selectors_names_str763[sizeof("selectors:receiver:argument:")];
    char _gst_builtin_selectors_names_str767[sizeof("with:with:")];
    char _gst_builtin_selectors_names_str768[sizeof("tclEval:")];
    char _gst_builtin_selectors_names_str769[sizeof("bitAnd:")];
    char _gst_builtin_selectors_names_str773[sizeof("tclEval:with:")];
    char _gst_builtin_selectors_names_str776[sizeof("bind:to:of:parameters:")];
    char _gst_builtin_selectors_names_str778[sizeof("tclEval:with:with:")];
    char _gst_builtin_selectors_names_str779[sizeof("to:")];
    char _gst_builtin_selectors_names_str780[sizeof("ensure:")];
    char _gst_builtin_selectors_names_str781[sizeof("basicAt:")];
    char _gst_builtin_selectors_names_str783[sizeof("tclEval:with:with:with:")];
    char _gst_builtin_selectors_names_str785[sizeof("basicAt:put:")];
    char _gst_builtin_selectors_names_str789[sizeof("should:")];
    char _gst_builtin_selectors_names_str791[sizeof("accumulate:")];
    char _gst_builtin_selectors_names_str793[sizeof("changeState:")];
    char _gst_builtin_selectors_names_str798[sizeof("foregroundColor:")];
    char _gst_builtin_selectors_names_str800[sizeof("nextToken")];
    char _gst_builtin_selectors_names_str803[sizeof("atAllPut:")];
    char _gst_builtin_selectors_names_str804[sizeof("default")];
    char _gst_builtin_selectors_names_str807[sizeof("asSortedCollection")];
    char _gst_builtin_selectors_names_str809[sizeof("shouldNotImplement")];
    char _gst_builtin_selectors_names_str810[sizeof("backgroundColor:")];
    char _gst_builtin_selectors_names_str811[sizeof("at:ifAbsent:")];
    char _gst_builtin_selectors_names_str814[sizeof("at:ifAbsentPut:")];
    char _gst_builtin_selectors_names_str816[sizeof("basicNew")];
    char _gst_builtin_selectors_names_str819[sizeof("bitOr:")];
    char _gst_builtin_selectors_names_str821[sizeof("create:")];
    char _gst_builtin_selectors_names_str822[sizeof("asSeconds")];
    char _gst_builtin_selectors_names_str826[sizeof("sizeof")];
    char _gst_builtin_selectors_names_str833[sizeof("average")];
    char _gst_builtin_selectors_names_str834[sizeof("activeProcess")];
    char _gst_builtin_selectors_names_str836[sizeof("coefficients:")];
    char _gst_builtin_selectors_names_str839[sizeof("tclResult")];
    char _gst_builtin_selectors_names_str842[sizeof("negated")];
    char _gst_builtin_selectors_names_str846[sizeof("at:ifPresent:")];
    char _gst_builtin_selectors_names_str847[sizeof("basicSize")];
    char _gst_builtin_selectors_names_str852[sizeof("bytecodeAt:")];
    char _gst_builtin_selectors_names_str854[sizeof("at:put:")];
    char _gst_builtin_selectors_names_str856[sizeof("contents")];
    char _gst_builtin_selectors_names_str873[sizeof("environment")];
    char _gst_builtin_selectors_names_str885[sizeof("fromSeconds:")];
    char _gst_builtin_selectors_names_str887[sizeof("detect:ifNone:")];
    char _gst_builtin_selectors_names_str895[sizeof("executeAndWait:arguments:")];
    char _gst_builtin_selectors_names_str901[sizeof("on:do:")];
    char _gst_builtin_selectors_names_str920[sizeof("getResponse")];
    char _gst_builtin_selectors_names_str924[sizeof("store:")];
    char _gst_builtin_selectors_names_str926[sizeof("between:and:")];
    char _gst_builtin_selectors_names_str941[sizeof("collect:")];
    char _gst_builtin_selectors_names_str946[sizeof("beConsistent")];
    char _gst_builtin_selectors_names_str960[sizeof("coerce:")];
    char _gst_builtin_selectors_names_str967[sizeof("connected")];
    char _gst_builtin_selectors_names_str969[sizeof("become:")];
    char _gst_builtin_selectors_names_str973[sizeof("connectIfClosed")];
  };
static struct _gst_builtin_selectors_names_t _gst_builtin_selectors_names_contents =
  {
    "/",
    "//",
    "*",
    ">",
    "y",
    "pi",
    ",",
    "->",
    "-",
    "implementation",
    "+",
    "nl",
    "key",
    "asOop",
    "\\\\",
    "=",
    "random",
    ">=",
    "upTo:",
    "primSize",
    "ln",
    "printOn:",
    "peek",
    "keys",
    "x",
    "min:",
    "|",
    "skip:",
    "exp",
    "name",
    "upToEnd",
    "cr",
    "asFloatD",
    "days",
    "name:",
    "space",
    "<",
    "==",
    "sqrt",
    "isNil",
    "initialize",
    "max:",
    "flush",
    "hash",
    "width",
    "primitiveFailed",
    "initialize:",
    "value",
    "size",
    "last",
    "primitive",
    "squared",
    "<=",
    "&",
    "wait",
    "skipSeparators",
    "isInteger",
    "updateViews",
    "print:",
    "superspace",
    "asArray",
    "primAt:",
    "perform:",
    "primAt:put:",
    "asFloat",
    "copy",
    "properties",
    "truncated",
    "readStream",
    "~=",
    "step",
    "subclassResponsibility",
    "writeStream",
    "class",
    "keysAndValuesDo:",
    "position",
    "asOrderedCollection",
    "nameIn:",
    "isEmpty",
    "signal",
    "asInteger",
    "add:",
    "methodDictionary",
    "first",
    "beep",
    "signalError",
    "parent:",
    "sign",
    "numArgs",
    "invalidArgsError:",
    "origin",
    "parent",
    "stop",
    "reset",
    "readFrom:",
    "parentContext",
    "statements",
    "zero",
    "temporaries",
    "allSatisfy:",
    "superclass",
    "instanceClass",
    "state",
    "abs",
    "x:y:",
    "with:",
    "position:",
    "removeLast",
    "bindWith:",
    "body",
    "addAll:",
    "bindWith:with:",
    "allSubclassesDo:",
    "data:",
    "clientPI",
    "variance",
    "postCopy",
    "inject:into:",
    "start",
    "printString",
    "selector",
    "species",
    "narrow",
    "origin:corner:",
    "method",
    "new",
    "asLowercase",
    "rows:",
    "notNil",
    "login",
    "exists",
    "blox",
    "new:",
    "at:",
    "displayString",
    "evaluate",
    "bitShift:",
    "close",
    "current",
    "copyEmpty:",
    "completedSuccessfully",
    "generality",
    "javaAsInt",
    "signal:",
    "error:",
    "signalOn:",
    "count",
    "at:type:",
    "signalOn:what:",
    "nextPutAll:",
    "signalOn:mustBe:",
    "container",
    "signalOn:withIndex:",
    "isKindOf:",
    "value:",
    "yourself",
    "addLast:",
    "copyWith:",
    "value:value:",
    "source",
    "height",
    "retryRelationalOp:coercing:",
    "asVector",
    "bitXor:",
    "callInto:",
    "variable",
    "replaceFrom:to:with:startingAt:",
    "status",
    "asNumber",
    "on:",
    "arguments",
    "checkError",
    "errorContents:",
    "receiver",
    "~~",
    "width:height:",
    "text",
    "with:do:",
    "not",
    "javaAsLong",
    "includes:",
    "copyFrom:to:",
    "includesKey:",
    "asClass",
    "visitNode:",
    "asSymbol",
    "findIndexOrNil:",
    "select:",
    "return:",
    "selector:",
    "checkResponse",
    "asTkString",
    "thisContext",
    "body:",
    "background",
    "assert:",
    "asString",
    "arguments:",
    "selectors:receiver:argument:",
    "with:with:",
    "tclEval:",
    "bitAnd:",
    "tclEval:with:",
    "bind:to:of:parameters:",
    "tclEval:with:with:",
    "to:",
    "ensure:",
    "basicAt:",
    "tclEval:with:with:with:",
    "basicAt:put:",
    "should:",
    "accumulate:",
    "changeState:",
    "foregroundColor:",
    "nextToken",
    "atAllPut:",
    "default",
    "asSortedCollection",
    "shouldNotImplement",
    "backgroundColor:",
    "at:ifAbsent:",
    "at:ifAbsentPut:",
    "basicNew",
    "bitOr:",
    "create:",
    "asSeconds",
    "sizeof",
    "average",
    "activeProcess",
    "coefficients:",
    "tclResult",
    "negated",
    "at:ifPresent:",
    "basicSize",
    "bytecodeAt:",
    "at:put:",
    "contents",
    "environment",
    "fromSeconds:",
    "detect:ifNone:",
    "executeAndWait:arguments:",
    "on:do:",
    "getResponse",
    "store:",
    "between:and:",
    "collect:",
    "beConsistent",
    "coerce:",
    "connected",
    "become:",
    "connectIfClosed"
  };
#define _gst_builtin_selectors_names ((const char *) &_gst_builtin_selectors_names_contents)

static unsigned char lengthtable[] =
  {
     0,  1,  2,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  1,  2,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  2,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 14,  1,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  0,  3,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  5,  0,
     0,  0,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  6,  0,  0,  0,  0,  0,  0,  2,
     0,  0,  0,  5,  0,  0,  0,  0,  0,  0,  0,  0,  0,  8,
     0,  0,  2,  0,  8,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  4,  0,  0,  4,  1,  0,  0,  0,  0,  0,  4,
     0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  5,
     0,  0,  0,  0,  3,  0,  0,  0,  0,  4,  0,  0,  7,  0,
     0,  0,  2,  0,  0,  0,  0,  0,  0,  0,  0,  8,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  4,  0,  0,  5,  5,  1,
     0,  0,  0,  0,  0,  0,  0,  2,  0,  0,  0,  0,  0,  4,
     0,  0,  0,  0,  5,  0,  0,  0,  0,  0,  0,  0,  0, 10,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  4,  0,  5,
     0,  4,  0,  0,  0,  5,  0,  0,  0,  0,  0,  0, 15,  0,
     0, 11,  0,  0,  0,  0,  0,  0,  5,  0,  4,  0,  0,  4,
     9,  7,  2,  0,  0,  1,  4,  0,  0, 14,  0,  9,  0, 11,
     0,  0,  0,  6, 10,  0,  7,  0,  0,  0,  0,  0,  0,  7,
     0,  8,  0, 11,  7,  4, 10,  0,  0,  9, 10,  2,  0,  0,
     4,  0,  0, 22,  0, 11,  5,  0,  0, 16,  0,  0,  8,  0,
    19,  7,  7,  6,  0,  0,  0,  0,  9,  0,  0,  0,  4, 16,
     0,  0,  0,  0,  0,  5,  0,  4,  0, 11,  7,  4,  7,  0,
     0,  0, 17,  6,  6,  0,  4,  0,  5,  9,  0, 13,  0, 10,
     0,  4, 11,  0,  0, 11, 10, 13,  5,  3,  0,  0,  4,  0,
     0,  5,  9, 10,  0,  0,  0,  9,  0,  0,  4,  7, 14,  0,
     0, 16,  0,  5,  0,  0,  0,  0,  0,  8,  0,  0,  0,  0,
     8,  8,  0, 12,  5, 11,  0,  8,  0,  7,  0,  0,  6,  0,
    14,  0,  0,  0,  6,  3,  0, 11,  5,  0,  6,  0,  0,  0,
     0,  0,  5,  6,  4,  0,  4,  0,  0,  0,  3, 13,  0,  0,
     0,  0,  8,  0,  0,  9,  0,  5,  7, 10, 21, 10,  9,  7,
     6,  9,  0,  5,  0,  8, 14, 11, 16,  0,  9, 19,  0,  9,
     0,  6,  8,  0,  8,  0,  9, 12,  6,  6, 27,  8,  0,  0,
     7,  9,  0,  8,  0, 31,  0,  0,  0,  6,  8,  3,  9,  0,
    10,  0, 14,  0,  8,  2,  0,  0,  0,  0, 13,  4,  0,  0,
     8,  3, 10,  0,  9,  0, 12, 12,  0,  7, 10,  0,  8, 15,
     7,  7,  9, 13,  0, 10, 11,  5,  0,  0,  0, 10,  0,  7,
     8,  0, 10,  0,  0,  0,  0, 28,  0,  0,  0, 10,  8,  7,
     0,  0,  0, 13,  0,  0, 22,  0, 18,  3,  7,  8,  0, 23,
     0, 12,  0,  0,  0,  7,  0, 11,  0, 12,  0,  0,  0,  0,
    16,  0,  9,  0,  0,  9,  7,  0,  0, 18,  0, 18, 16, 12,
     0,  0, 15,  0,  8,  0,  0,  6,  0,  7,  9,  0,  0,  0,
     6,  0,  0,  0,  0,  0,  0,  7, 13,  0, 13,  0,  0,  9,
     0,  0,  7,  0,  0,  0, 13,  9,  0,  0,  0,  0, 11,  0,
     7,  0,  8,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0, 11,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0, 12,  0, 14,  0,  0,  0,  0,  0,  0,  0, 25,
     0,  0,  0,  0,  0,  6,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11,  0,  0,  0,
     6,  0, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  8,  0,  0,  0,  0, 12,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  7,  0,  0,  0,  0,  0,
     0,  9,  0,  7,  0,  0,  0, 15
  };

static struct builtin_selector _gst_builtin_selectors_hash[] =
  {
    {-1,NULL,-1,-1},
#line 48 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str1,                  			NULL, 1,        DIVIDE_SPECIAL},
#line 52 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str2,                 			NULL, 1,        INTEGER_DIVIDE_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 47 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str7,                  			NULL, 1,        TIMES_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 42 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str35,                  			NULL, 1,        GREATER_THAN_SPECIAL},
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
#line 114 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str75,                  			NULL, 0,       80},
#line 189 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str76,					NULL, 0,       155},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 72 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str95,                  			NULL, 1,       38},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 120 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str120,                 			NULL, 1,       86},
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
#line 40 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str169,                  			NULL, 1,        MINUS_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 172 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str192,     			NULL, 0,       138},
#line 39 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str193,                  			NULL, 1,        PLUS_SPECIAL},
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
    {-1,NULL,-1,-1},
#line 76 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str234,                 			NULL, 0,       42},
    {-1,NULL,-1,-1},
#line 88 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str236,                			NULL, 0,       54},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 212 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str250,              			NULL, 0,       178},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 49 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str254,               			NULL, 1,        REMAINDER_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 45 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str275,                  			NULL, 1,        EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 238 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str286,             			NULL, 0,       204},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 44 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str293,                 			NULL, 1,        GREATER_EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 175 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str297,              			NULL, 1,       141},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 162 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str307,           			NULL, 0,       128},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 171 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str310,                 			NULL, 0,       137},
    {-1,NULL,-1,-1},
#line 139 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str312,           			NULL, 1,       105},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 177 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str339,               			NULL, 0,       143},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 236 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str342,               			NULL, 0,       202},
#line 112 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str343,                  			NULL, 0,       78},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 205 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str349,               			NULL, 1,       171},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 186 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str353,                  			NULL, 1,       152},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 272 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str363,              			NULL, 1,       238},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 183 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str368,                			NULL, 0,       149},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 79 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str373,               			NULL, 0,       45},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 277 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str376,            			NULL, 0,       243},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 109 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str380,                 			NULL, 0,       75},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 159 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str389,           			NULL, 0,       125},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 273 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str400,               			NULL, 0,       239},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 144 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str403,              			NULL, 1,       110},
#line 117 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str404,              			NULL, 0,       83},
#line 41 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str405,                  			NULL, 1,        LESS_THAN_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 63 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str413,                 			NULL, 1,        SAME_OBJECT_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 146 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str419,               			NULL, 0,       112},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 59 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str424,              			NULL, 0,        IS_NIL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 103 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str433,         			NULL, 0,       69},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 137 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str445,               			NULL, 1,       103},
    {-1,NULL,-1,-1},
#line 157 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str447,              			NULL, 0,       123},
    {-1,NULL,-1,-1},
#line 145 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str449,               			NULL, 0,       111},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 206 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str453,              			NULL, 0,       172},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 106 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str460,    			NULL, 0,       72},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 107 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str463,        			NULL, 1,       73},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 61 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str470,              			NULL, 0,        VALUE_SPECIAL},
    {-1,NULL,-1,-1},
#line 57 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str472,               			NULL, 0,        SIZE_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 102 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str475,               			NULL, 0,       68},
#line 261 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str476,          			NULL, 0,       227},
#line 132 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str477,            			NULL, 0,       98},
#line 43 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str478,                 			NULL, 1,        LESS_EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 276 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str481,                  			NULL, 1,       242},
#line 233 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str482,               			NULL, 0,       199},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 266 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str485,     			NULL, 0,       232},
    {-1,NULL,-1,-1},
#line 143 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str487,          			NULL, 0,       109},
    {-1,NULL,-1,-1},
#line 263 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str489,        			NULL, 0,       229},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 101 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str493,             			NULL, 1,       67},
#line 240 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str494,         			NULL, 0,       206},
    {-1,NULL,-1,-1},
#line 218 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str496,            			NULL, 0,       184},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 148 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str503,            			NULL, 1,       114},
    {-1,NULL,-1,-1},
#line 242 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str505,           			NULL, 1,       208},
    {-1,NULL,-1,-1},
#line 247 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str507,        			NULL, 2,       213},
#line 237 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str508,            			NULL, 0,       203},
#line 99 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str509,               			NULL, 0,       65},
#line 81 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str510,         			NULL, 0,       47},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 195 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str513,          			NULL, 0,       161},
#line 113 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str514,         			NULL, 0,       79},
#line 46 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str515,                 			NULL, 1,        NOT_EQUAL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 125 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str518,               			NULL, 0,       91},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 74 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str521,                 NULL, 0,       40},
    {-1,NULL,-1,-1},
#line 191 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str523,        			NULL, 0,       157},
#line 58 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str524,              			NULL, 0,        CLASS_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 138 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str527,   			NULL, 1,       104},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 150 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str530,           			NULL, 0,       116},
    {-1,NULL,-1,-1},
#line 235 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str532,			NULL, 0,       201},
#line 255 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str533,            			NULL, 1,       221},
#line 80 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str534,            			NULL, 0,       46},
#line 126 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str535,             			NULL, 0,       92},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 116 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str540,          			NULL, 0,       82},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 75 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str544,               			NULL, 1,       41},
#line 214 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str545,   			NULL, 0,       180},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 84 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str551,              			NULL, 0,       50},
    {-1,NULL,-1,-1},
#line 147 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str553,               			NULL, 0,       113},
    {-1,NULL,-1,-1},
#line 257 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str555,        			NULL, 0,       223},
#line 222 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str556,            			NULL, 1,       188},
#line 229 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str557,               			NULL, 0,       195},
#line 121 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str558,            			NULL, 0,       87},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 254 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str562,  			NULL, 1,       220},
#line 239 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str563,             			NULL, 0,       205},
#line 127 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str564,             			NULL, 0,       93},
    {-1,NULL,-1,-1},
#line 241 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str566,               			NULL, 0,       207},
    {-1,NULL,-1,-1},
#line 165 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str568,              			NULL, 0,       131},
#line 154 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str569,          			NULL, 1,       120},
    {-1,NULL,-1,-1},
#line 207 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str571,      			NULL, 0,       173},
    {-1,NULL,-1,-1},
#line 184 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str573,         			NULL, 0,       150},
    {-1,NULL,-1,-1},
#line 209 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str575,               			NULL, 0,       175},
#line 211 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str576,        			NULL, 0,       177},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 249 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str579,        			NULL, 1,       215},
#line 192 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str580,         			NULL, 0,       158},
#line 234 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str581,      			NULL, 0,       200},
#line 194 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str582,              			NULL, 0,       160},
#line 90 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str583,                			NULL, 0,       56},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 179 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str586,               			NULL, 2,       145},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 98 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str589,              			NULL, 1,       64},
#line 250 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str590,          			NULL, 1,       216},
#line 208 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str591,         			NULL, 0,       174},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 269 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str595,          			NULL, 1,       235},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 136 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str598,               			NULL, 0,       102},
#line 142 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str599,            			NULL, 1,       108},
#line 210 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str600,     			NULL, 2,       176},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 256 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str603,   			NULL, 1,       222},
    {-1,NULL,-1,-1},
#line 245 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str605,              			NULL, 1,       211},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 156 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str611,           			NULL, 0,       122},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 230 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str616,           			NULL, 0,       196},
#line 153 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str617,           			NULL, 0,       119},
    {-1,NULL,-1,-1},
#line 196 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str619,       			NULL, 2,       162},
#line 167 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str620,              			NULL, 0,       133},
#line 77 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str621,        			NULL, 0,       43},
    {-1,NULL,-1,-1},
#line 128 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str623,           			NULL, 0,       94},
    {-1,NULL,-1,-1},
#line 123 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str625,            			NULL, 0,       89},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 69 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str628,             			NULL, 0,       35},
    {-1,NULL,-1,-1},
#line 267 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str630,     			NULL, 2,       233},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 248 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str634,             			NULL, 0,       214},
#line 118 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str635,                			NULL, 0,       84},
    {-1,NULL,-1,-1},
#line 217 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str637,        			NULL, 0,       183},
#line 181 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str638,              			NULL, 1,       147},
    {-1,NULL,-1,-1},
#line 60 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str640,             			NULL, 0,        NOT_NIL_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 244 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str646,              			NULL, 0,       210},
#line 219 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str647,             			NULL, 0,       185},
#line 124 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str648,               			NULL, 0,       90},
    {-1,NULL,-1,-1},
#line 66 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str650,               			NULL, 1,        NEW_COLON_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 55 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str654,                			NULL, 1,        AT_SPECIAL},
#line 265 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str655,      			NULL, 0,       231},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 163 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str660,           			NULL, 0,       129},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 51 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str663,          			NULL, 1,        BIT_SHIFT_SPECIAL},
    {-1,NULL,-1,-1},
#line 94 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str665,              			NULL, 0,       60},
#line 198 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str666,            			NULL, 0,       164},
#line 166 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str667,         			NULL, 1,       132},
#line 190 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str668,                  NULL, 0,       156},
#line 133 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str669,         			NULL, 0,       99},
#line 64 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str670,				NULL, 0,	JAVA_AS_INT_SPECIAL},
#line 152 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str671,            			NULL, 1,       118},
#line 83 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str672,             			NULL, 1,       49},
#line 168 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str673,          			NULL, 1,       134},
    {-1,NULL,-1,-1},
#line 216 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str675,              			NULL, 0,       182},
    {-1,NULL,-1,-1},
#line 271 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str677,           			NULL, 2,       237},
#line 220 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str678,     			NULL, 2,       186},
#line 70 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str679,        			NULL, 1,       36},
#line 134 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str680,   			NULL, 2,       100},
    {-1,NULL,-1,-1},
#line 82 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str682,          			NULL, 0,       48},
#line 224 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str683,			NULL, 2,       190},
    {-1,NULL,-1,-1},
#line 140 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str685,          			NULL, 1,       106},
    {-1,NULL,-1,-1},
#line 62 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str687,              			NULL, 1,        VALUE_COLON_SPECIAL},
#line 71 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str688,           			NULL, 0,       37},
    {-1,NULL,-1,-1},
#line 131 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str690,           			NULL, 1,       97},
    {-1,NULL,-1,-1},
#line 283 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str692,          			NULL, 1,       249},
#line 158 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str693,       			NULL, 2,       124},
#line 259 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str694,             			NULL, 0,       225},
#line 258 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str695,             			NULL, 0,       224},
#line 200 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str696,            NULL, 2,       166},
#line 231 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str697,           			NULL, 0,       197},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 50 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str700,            			NULL, 1,        BIT_XOR_SPECIAL},
#line 68 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str701,	     			NULL, 1,       34},
    {-1,NULL,-1,-1},
#line 278 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str703,           			NULL, 0,       244},
    {-1,NULL,-1,-1},
#line 197 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str705,        NULL, 4,       163},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 285 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str709,             			NULL, 0,       251},
#line 260 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str710,           			NULL, 0,       226},
#line 73 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str711,                			NULL, 1,       39},
#line 111 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str712,          			NULL, 0,       77},
    {-1,NULL,-1,-1},
#line 203 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str714,         			NULL, 0,       169},
    {-1,NULL,-1,-1},
#line 264 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str716,     			NULL, 1,       230},
    {-1,NULL,-1,-1},
#line 176 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str718,           			NULL, 0,       142},
#line 227 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str719,                 			NULL, 1,       193},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 213 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str724,      			NULL, 2,       179},
#line 182 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str725,               			NULL, 0,       148},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 280 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str728,           			NULL, 2,       246},
#line 93 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str729,                			NULL, 0,       59},
#line 65 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str730,				NULL, 0,	JAVA_AS_LONG_SPECIAL},
    {-1,NULL,-1,-1},
#line 95 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str732,          			NULL, 1,       61},
    {-1,NULL,-1,-1},
#line 100 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str734,       			NULL, 2,       66},
#line 188 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str735,       			NULL, 1,       154},
    {-1,NULL,-1,-1},
#line 170 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str737,            			NULL, 0,       136},
#line 141 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str738,         			NULL, 1,       107},
    {-1,NULL,-1,-1},
#line 97 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str740,           			NULL, 0,       63},
#line 281 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str741,    			NULL, 1,       247},
#line 221 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str742,            			NULL, 1,       187},
#line 226 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str743,            			NULL, 1,       192},
#line 223 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str744,          			NULL, 1,       189},
#line 173 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str745,      			NULL, 0,       139},
    {-1,NULL,-1,-1},
#line 89 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str747,         			NULL, 0,       55},
#line 67 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str748,        			NULL, 0,        THIS_CONTEXT_SPECIAL},
#line 185 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str749,              			NULL, 1,       151},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 284 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str753,         			NULL, 0,       250},
    {-1,NULL,-1,-1},
#line 105 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str755,            			NULL, 1,       71},
#line 108 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str756,           			NULL, 0,       74},
    {-1,NULL,-1,-1},
#line 193 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str758,         			NULL, 1,       159},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 286 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str763,           NULL, 3,       252},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 122 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str767,         			NULL, 2,       88},
#line 85 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str768,           			NULL, 1,       51},
#line 53 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str769,            			NULL, 1,        BIT_AND_SPECIAL},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 274 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str773,      			NULL, 2,       240},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 225 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str776,                 NULL, 4,       191},
    {-1,NULL,-1,-1},
#line 104 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str778, 			NULL, 3,       70},
#line 130 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str779,                			NULL, 1,       96},
#line 135 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str780,            			NULL, 1,       101},
#line 169 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str781,           			NULL, 1,       135},
    {-1,NULL,-1,-1},
#line 115 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str783,                NULL, 4,       81},
    {-1,NULL,-1,-1},
#line 161 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str785,       			NULL, 2,       127},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 110 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str789,            			NULL, 1,       76},
    {-1,NULL,-1,-1},
#line 215 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str791,        			NULL, 1,       181},
    {-1,NULL,-1,-1},
#line 228 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str793,       			NULL, 1,       194},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 180 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str798,   			NULL, 1,       146},
    {-1,NULL,-1,-1},
#line 246 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str800,          			NULL, 0,       212},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 252 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str803,          			NULL, 1,       218},
#line 251 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str804,            			NULL, 0,       217},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 253 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str807, 			NULL, 0,       219},
    {-1,NULL,-1,-1},
#line 119 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str809, 			NULL, 0,       85},
#line 243 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str810,   			NULL, 1,       209},
#line 96 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str811,       			NULL, 2,       62},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 151 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str814,    			NULL, 2,       117},
    {-1,NULL,-1,-1},
#line 91 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str816,           			NULL, 0,       57},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 54 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str819,             			NULL, 1,        BIT_OR_SPECIAL},
    {-1,NULL,-1,-1},
#line 287 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str821,            			NULL, 1,       253},
#line 282 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str822,          			NULL, 0,       248},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 187 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str826,             			NULL, 0,       153},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 174 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str833,            			NULL, 0,       140},
#line 268 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str834,      			NULL, 0,       234},
    {-1,NULL,-1,-1},
#line 155 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str836,      			NULL, 1,       121},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 87 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str839,          			NULL, 0,       53},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 92 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str842,            			NULL, 0,       58},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 129 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str846,      			NULL, 2,       95},
#line 178 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str847,          			NULL, 0,       144},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 289 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str852,        			NULL, 1,       255},
    {-1,NULL,-1,-1},
#line 56 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str854,            			NULL, 2,        AT_PUT_SPECIAL},
    {-1,NULL,-1,-1},
#line 78 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str856,           			NULL, 0,       44},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 149 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str873,        			NULL, 0,       115},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 275 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str885,       			NULL, 1,       241},
    {-1,NULL,-1,-1},
#line 202 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str887,     			NULL, 2,       168},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 204 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str895,              NULL, 2,       170},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 160 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str901,             			NULL, 2,       126},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 232 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str920,        			NULL, 0,       198},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 262 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str924,             			NULL, 1,       228},
    {-1,NULL,-1,-1},
#line 199 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str926,       			NULL, 2,       165},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 86 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str941,           			NULL, 1,       52},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 270 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str946,       			NULL, 0,       236},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1},
#line 288 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str960,            			NULL, 1,       254},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 164 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str967,          			NULL, 0,       130},
    {-1,NULL,-1,-1},
#line 279 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str969,            			NULL, 1,       245},
    {-1,NULL,-1,-1}, {-1,NULL,-1,-1}, {-1,NULL,-1,-1},
#line 201 "../../libgst/builtins.gperf"
    {(int)(long)&((struct _gst_builtin_selectors_names_t *)0)->_gst_builtin_selectors_names_str973,    			NULL, 0,       167}
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
