/***********************************************************************
 *
 *      C interface to i18n functions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2004, 2005, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include "config.h"
#include "gstpub.h"
#include <locale.h>
#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <langinfo.h>
#include <errno.h>

#if defined(_WIN32) || defined(__CYGWIN32__) || defined(__CYGWIN__) || defined(Win32) || defined(__WIN32)
# define WIN32_LEAN_AND_MEAN /* avoid including junk */
# include <windows.h>
#endif

#define LOCALE_DATA_HEADER \
  OBJ_HEADER; \
  OOP           nameOOP;

typedef struct Locale
{
  LOCALE_DATA_HEADER;
  OOP lcNumericOOP, lcTimeOOP, lcMonetaryOOP, lcMonetaryIsoOOP, lcMessagesOOP;
}
 *Locale;

typedef struct LcTime
{
  LOCALE_DATA_HEADER;
  OOP abdayOOP, dayOOP, abmonOOP, monOOP, amPmOOP, dtFmtOOP,
    dFmtOOP, tFmtOOP, tFmtAmPmOOP, altDigitsOOP;
}
 *LcTime;

#define LC_NUMERIC_HEADER \
  LOCALE_DATA_HEADER; \
  OOP           decimalPointOOP, thousandsSepOOP, groupingOOP

typedef struct LcNumeric
{
  LC_NUMERIC_HEADER;
}
 *LcNumeric;

typedef struct LcMonetary
{
  LC_NUMERIC_HEADER;
  OOP currencySymbolOOP, positiveSignOOP, negativeSignOOP,
    fracDigitsOOP, pCsPrecedesOOP, pSepBySpaceOOP,
    nCsPrecedesOOP, nSepBySpaceOOP, pSignPosnOOP, nSignPosnOOP;
}
 *LcMonetary;

/* structure for the Win32 LANGID -> POSIX language id lookup table.  */
typedef struct LangLookupEntryStruct
{
  int langid;
  char name[16];
}
LangLookupEntry;

extern char *locale_charset ();
static OOP buildArray ();
static const char *loadLocale ();

static VMProxy *vmProxy;

/* Make an Array out of a series of values for NL_ITEM. */
OOP
buildArray (nl_item * nlitems, int count)
{
  int size, i;
  char *arraySrc, *array;
  size = count * 3 + 5;		/* ^#('...' '...' )! */

  for (i = 0; i < count; i++)
    size += strlen (nl_langinfo (nlitems[i]));

  arraySrc = array = alloca (size + 1);

  strcpy (array, "^#(");
  array += 3;
  for (i = 0; i < count; i++)
    array += sprintf (array, "'%s' ", nl_langinfo (nlitems[i]));

  strcpy (array, ")!");

  return (vmProxy->evalExpr (arraySrc));
}

const char *
loadLocale (OOP localeOOP, const char *string)
{
  char *oldLocale, *ourLocale;
  const char *grouping, *charset;
  struct lconv *lconv;
  Locale locale;
  LcTime lcTime;
  LcNumeric lcNumeric;
  LcMonetary lcMon, lcMonISO;

  static nl_item abdays[7] = { ABDAY_1, ABDAY_2, ABDAY_3, ABDAY_4, ABDAY_5,
    ABDAY_6, ABDAY_7
  };

  static nl_item days[7] =
    { DAY_1, DAY_2, DAY_3, DAY_4, DAY_5, DAY_6, DAY_7 };

  static nl_item abmonths[12] = { ABMON_1, ABMON_2, ABMON_3, ABMON_4, ABMON_5,
    ABMON_6, ABMON_7, ABMON_8, ABMON_9, ABMON_10,
    ABMON_11, ABMON_12
  };

  static nl_item months[12] = { MON_1, MON_2, MON_3, MON_4, MON_5, MON_6,
    MON_7, MON_8, MON_9, MON_10, MON_11, MON_12
  };

  static nl_item ampm[2] = { AM_STR, PM_STR };

  if (string == NULL)
    string = "";

  oldLocale = setlocale (LC_ALL, NULL);
  oldLocale = strdup (oldLocale);

  if (!setlocale (LC_ALL, string))
    {
      free (oldLocale);
      return NULL;
    }

  ourLocale = setlocale (LC_ALL, NULL);
  ourLocale = strdup (ourLocale);

  lconv = localeconv ();

  locale = (Locale) OOP_TO_OBJ (localeOOP);
  lcTime = (LcTime) OOP_TO_OBJ (locale->lcTimeOOP);
  lcTime->abdayOOP = buildArray (abdays, 7);
  lcTime->dayOOP = buildArray (days, 7);
  lcTime->abmonOOP = buildArray (abmonths, 12);
  lcTime->monOOP = buildArray (months, 12);
  lcTime->amPmOOP = buildArray (ampm, 2);
  lcTime->dtFmtOOP = vmProxy->stringToOOP (nl_langinfo (D_T_FMT));
  lcTime->dFmtOOP = vmProxy->stringToOOP (nl_langinfo (D_FMT));
  lcTime->tFmtOOP = vmProxy->stringToOOP (nl_langinfo (T_FMT));
  lcTime->tFmtAmPmOOP = vmProxy->stringToOOP (nl_langinfo (T_FMT_AMPM));
#ifdef ALT_DIGITS
  lcTime->altDigitsOOP = vmProxy->stringToOOP (nl_langinfo (ALT_DIGITS));
#else
  lcTime->altDigitsOOP = vmProxy->stringToOOP ("");
#endif

  grouping = *lconv->grouping == CHAR_MAX ? "" : lconv->grouping;

  lcNumeric = (LcNumeric) OOP_TO_OBJ (locale->lcNumericOOP);
  lcNumeric->decimalPointOOP = vmProxy->stringToOOP (lconv->decimal_point);
  lcNumeric->thousandsSepOOP = vmProxy->stringToOOP (lconv->thousands_sep);
  lcNumeric->groupingOOP =
    vmProxy->byteArrayToOOP (grouping, strlen (grouping));

  grouping = *lconv->mon_grouping == CHAR_MAX ? "" : lconv->mon_grouping;

  lcMon = (LcMonetary) OOP_TO_OBJ (locale->lcMonetaryOOP);
  lcMon->decimalPointOOP = vmProxy->stringToOOP (lconv->mon_decimal_point);
  lcMon->thousandsSepOOP = vmProxy->stringToOOP (lconv->mon_thousands_sep);
  lcMon->groupingOOP = vmProxy->byteArrayToOOP (grouping, strlen (grouping));
  lcMon->currencySymbolOOP = vmProxy->stringToOOP (lconv->currency_symbol);
  lcMon->pCsPrecedesOOP = vmProxy->boolToOOP (lconv->p_cs_precedes != 0);
  lcMon->nCsPrecedesOOP = vmProxy->boolToOOP (lconv->n_cs_precedes != 0);
  lcMon->pSepBySpaceOOP = vmProxy->boolToOOP (lconv->p_sep_by_space != 0);
  lcMon->nSepBySpaceOOP = vmProxy->boolToOOP (lconv->n_sep_by_space != 0);
  lcMon->positiveSignOOP = vmProxy->stringToOOP (lconv->positive_sign);

  if (*lconv->negative_sign || *lconv->positive_sign)
    lcMon->negativeSignOOP = vmProxy->stringToOOP (lconv->negative_sign);
  else
    lcMon->negativeSignOOP = vmProxy->stringToOOP ("-");

  lcMon->fracDigitsOOP =
    vmProxy->intToOOP (lconv->frac_digits < CHAR_MAX ?
		       lconv->frac_digits : 0);

  lcMon->pSignPosnOOP =
    vmProxy->intToOOP (lconv->p_sign_posn < CHAR_MAX ?
		       lconv->p_sign_posn : 4);

  lcMon->nSignPosnOOP =
    vmProxy->intToOOP (lconv->n_sign_posn < CHAR_MAX ?
		       lconv->n_sign_posn : 4);

  lcMonISO = (LcMonetary) OOP_TO_OBJ (locale->lcMonetaryIsoOOP);
  lcMonISO->decimalPointOOP = lcMon->decimalPointOOP;
  lcMonISO->thousandsSepOOP = lcMon->thousandsSepOOP;
  lcMonISO->groupingOOP = lcMon->groupingOOP;

  lcMonISO->currencySymbolOOP = vmProxy->stringToOOP (lconv->int_curr_symbol);
  lcMonISO->fracDigitsOOP =
    vmProxy->intToOOP (lconv->int_frac_digits < CHAR_MAX ?
		       lconv->int_frac_digits : 0);

  /* The reasoning behind these hard-coded values is in the GNU C
     library manual, under the explanation for `localeconv'. */
  lcMonISO->pCsPrecedesOOP = vmProxy->boolToOOP (1);
  lcMonISO->nCsPrecedesOOP = vmProxy->boolToOOP (1);
  lcMonISO->pSepBySpaceOOP = vmProxy->boolToOOP (0);
  lcMonISO->nSepBySpaceOOP = vmProxy->boolToOOP (0);
  lcMonISO->pSignPosnOOP = vmProxy->intToOOP (4);
  lcMonISO->nSignPosnOOP = vmProxy->intToOOP (4);
  lcMonISO->positiveSignOOP = lcMon->positiveSignOOP;
  lcMonISO->negativeSignOOP = lcMon->negativeSignOOP;

  charset = locale_charset ();
  setlocale (LC_ALL, oldLocale);
  free (oldLocale);
  free (ourLocale);

  return charset;
}


const char *
localeDirectory (void)
{
  return LOCALEDIR;
}

void
gst_initModule (VMProxy * proxy)
{
#ifdef WIN32
#define NLANG 39

#define ENTRY(l, sl, name) { MAKELANGID (l, sl), name }
  static LangLookupEntry langids[NLANG] = {
    ENTRY (LANG_NEUTRAL, SUBLANG_NEUTRAL, "POSIX"),
    ENTRY (LANG_CHINESE, SUBLANG_CHINESE_SIMPLIFIED, "zh_CN.GB-2312"),
    ENTRY (LANG_CHINESE, SUBLANG_CHINESE_TRADITIONAL, "zh_CN.BIG5"),
    ENTRY (LANG_CZECH, SUBLANG_NEUTRAL, "cs_CZ"),
    ENTRY (LANG_DANISH, SUBLANG_NEUTRAL, "da_DK"),
    ENTRY (LANG_DUTCH, SUBLANG_DUTCH, "nl_NL"),
    ENTRY (LANG_DUTCH, SUBLANG_DUTCH_BELGIAN, "nl_BE"),
    ENTRY (LANG_ENGLISH, SUBLANG_ENGLISH_US, "en_US"),
    ENTRY (LANG_ENGLISH, SUBLANG_ENGLISH_UK, "en_GB"),
    ENTRY (LANG_ENGLISH, SUBLANG_ENGLISH_AUS, "en_AU"),
    ENTRY (LANG_ENGLISH, SUBLANG_ENGLISH_CAN, "en_CA"),
    ENTRY (LANG_ENGLISH, SUBLANG_ENGLISH_NZ, "en_NZ"),
    ENTRY (LANG_FINNISH, SUBLANG_NEUTRAL, "fi_FI"),
    ENTRY (LANG_FRENCH, SUBLANG_FRENCH, "fr_FR"),
    ENTRY (LANG_FRENCH, SUBLANG_FRENCH_BELGIAN, "fr_BE"),
    ENTRY (LANG_FRENCH, SUBLANG_FRENCH_CANADIAN, "fr_CA"),
    ENTRY (LANG_FRENCH, SUBLANG_FRENCH_SWISS, "fr_CH"),
    ENTRY (LANG_GERMAN, SUBLANG_GERMAN, "de_DE"),
    ENTRY (LANG_GERMAN, SUBLANG_GERMAN_SWISS, "de_CH"),
    ENTRY (LANG_GERMAN, SUBLANG_GERMAN_AUSTRIAN, "de_AT"),
    ENTRY (LANG_GREEK, SUBLANG_NEUTRAL, "gr_GR"),
    ENTRY (LANG_HUNGARIAN, SUBLANG_NEUTRAL, "hu_HU"),
    ENTRY (LANG_ICELANDIC, SUBLANG_NEUTRAL, "is_IS"),
    ENTRY (LANG_ITALIAN, SUBLANG_ITALIAN, "it_IT"),
    ENTRY (LANG_ITALIAN, SUBLANG_ITALIAN_SWISS, "it_CH"),
    ENTRY (LANG_JAPANESE, SUBLANG_NEUTRAL, "ja_JP.sjis"),
    ENTRY (LANG_KOREAN, SUBLANG_NEUTRAL, "kr_KR"),
    ENTRY (LANG_NORWEGIAN, SUBLANG_NORWEGIAN_BOKMAL, "no_NO"),
    ENTRY (LANG_NORWEGIAN, SUBLANG_NORWEGIAN_NYNORSK, "no@nynorsk"),
    ENTRY (LANG_POLISH, SUBLANG_NEUTRAL, "pl_PL"),
    ENTRY (LANG_PORTUGUESE, SUBLANG_PORTUGUESE, "pt_PT"),
    ENTRY (LANG_PORTUGUESE, SUBLANG_PORTUGUESE_BRAZILIAN, "pt_BR"),
    ENTRY (LANG_RUSSIAN, SUBLANG_NEUTRAL, "ru_RU"),
    ENTRY (LANG_SLOVAK, SUBLANG_NEUTRAL, "sk_SK"),
    ENTRY (LANG_SPANISH, SUBLANG_SPANISH, "es_ES"),
    ENTRY (LANG_SPANISH, SUBLANG_SPANISH_MEXICAN, "es_MX"),
    ENTRY (LANG_SPANISH, SUBLANG_SPANISH_MODERN, "es_ES"),
    ENTRY (LANG_SWEDISH, SUBLANG_NEUTRAL, "se_SE"),
    ENTRY (LANG_TURKISH, SUBLANG_NEUTRAL, "tr_TR")
  };
#undef ENTRY

  LCID lcid = GetUserDefaultLCID ();
  int langid = LANGIDFROMLCID (lcid), i;
  char *pick, envVariable[30];

  pick = NULL;
  for (i = 0; i < NLANG; i++)
    {
      if (langids[i].langid == langid)
	{
	  pick = langids[i].name;
	  break;
	}
    }

  if (pick && i > 0 && !getenv ("LANG"))
    {
      sprintf (envVariable, "LANG=%s", pick);
      putenv (envVariable);
    }
#endif /* WIN32 */

  vmProxy = proxy;
  vmProxy->defineCFunc ("i18n_load", loadLocale);
  vmProxy->defineCFunc ("i18n_localeDirectory", localeDirectory);
}
