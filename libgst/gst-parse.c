/* A Bison parser, made by GNU Bison 1.875.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Written by Richard Stallman by simplifying the original so called
   ``semantic'' parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Using locations.  */
#define YYLSP_NEEDED 1

/* If NAME_PREFIX is specified substitute the variables and functions
   names.  */
#define yyparse _gst_yyparse
#define yylex   _gst_yylex
#define yyerror _gst_yyerror
#define yylval  _gst_yylval
#define yychar  _gst_yychar
#define yydebug _gst_yydebug
#define yynerrs _gst_yynerrs
#define yylloc _gst_yylloc

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INTERNAL_TOKEN = 258,
     SCOPE_SEPARATOR = 259,
     ASSIGNMENT = 260,
     SHEBANG = 261,
     IDENTIFIER = 262,
     KEYWORD = 263,
     STRING_LITERAL = 264,
     SYMBOL_LITERAL = 265,
     BINOP = 266,
     INTEGER_LITERAL = 267,
     BYTE_LITERAL = 268,
     FLOATD_LITERAL = 269,
     FLOATE_LITERAL = 270,
     FLOATQ_LITERAL = 271,
     CHAR_LITERAL = 272,
     SCALED_DECIMAL_LITERAL = 273,
     LARGE_INTEGER_LITERAL = 274
   };
#endif
#define INTERNAL_TOKEN 258
#define SCOPE_SEPARATOR 259
#define ASSIGNMENT 260
#define SHEBANG 261
#define IDENTIFIER 262
#define KEYWORD 263
#define STRING_LITERAL 264
#define SYMBOL_LITERAL 265
#define BINOP 266
#define INTEGER_LITERAL 267
#define BYTE_LITERAL 268
#define FLOATD_LITERAL 269
#define FLOATE_LITERAL 270
#define FLOATQ_LITERAL 271
#define CHAR_LITERAL 272
#define SCALED_DECIMAL_LITERAL 273
#define LARGE_INTEGER_LITERAL 274




/* Copy the first part of user declarations.  */
#line 31 "gst-parse.y"

#include "gst.h"
#include "gstpriv.h"
#include <stdio.h>
#if defined (STDC_HEADERS)
#include <string.h>
#endif

#define YYPRINT(file, type, value)   _gst_yyprint (file, type, &value)

#define YYERROR_VERBOSE 1

static inline mst_Boolean           is_unlikely_selector (register const char *str);


/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 52 "gst-parse.y"
typedef union YYSTYPE {
  char		cval;
  long double	fval;
  intptr_t	ival;
  char		*sval;
  byte_object	boval;
  OOP		oval;
  tree_node	node;
} YYSTYPE;
/* Line 191 of yacc.c.  */
#line 147 "gst-parse.c"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

#if ! defined (YYLTYPE) && ! defined (YYLTYPE_IS_DECLARED)
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


/* Copy the second part of user declarations.  */


/* Line 214 of yacc.c.  */
#line 171 "gst-parse.c"

#if ! defined (yyoverflow) || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# if YYSTACK_USE_ALLOCA
#  define YYSTACK_ALLOC alloca
# else
#  ifndef YYSTACK_USE_ALLOCA
#   if defined (alloca) || defined (_ALLOCA_H)
#    define YYSTACK_ALLOC alloca
#   else
#    ifdef __GNUC__
#     define YYSTACK_ALLOC __builtin_alloca
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
# else
#  if defined (__STDC__) || defined (__cplusplus)
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   define YYSIZE_T size_t
#  endif
#  define YYSTACK_ALLOC malloc
#  define YYSTACK_FREE free
# endif
#endif /* ! defined (yyoverflow) || YYERROR_VERBOSE */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (YYLTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short yyss;
  YYSTYPE yyvs;
    YYLTYPE yyls;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE) + sizeof (YYLTYPE))	\
      + 2 * YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  register YYSIZE_T yyi;		\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (0)
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif

#if defined (__STDC__) || defined (__cplusplus)
   typedef signed char yysigned_char;
#else
   typedef short yysigned_char;
#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  6
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   446

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  35
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  64
/* YYNRULES -- Number of rules. */
#define YYNRULES  147
/* YYNRULES -- Number of states. */
#define YYNSTATES  208

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   274

#define YYTRANSLATE(YYX) 						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    23,     2,    28,     2,     2,     2,     2,
      26,    27,     2,     2,     2,     2,    24,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    33,    34,
      13,     2,    14,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    29,     2,    30,    25,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    31,    12,    32,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    15,    16,    17,
      18,    19,    20,    21,    22
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned short yyprhs[] =
{
       0,     0,     3,     6,     9,    10,    12,    14,    15,    17,
      20,    22,    27,    31,    34,    38,    41,    42,    47,    49,
      52,    54,    56,    58,    60,    62,    64,    66,    69,    73,
      75,    76,    78,    80,    83,    87,    90,    94,    96,    97,
     100,   104,   106,   109,   110,   113,   116,   121,   123,   127,
     131,   132,   134,   136,   139,   141,   144,   147,   151,   153,
     155,   157,   159,   161,   163,   165,   169,   173,   177,   179,
     183,   185,   187,   189,   191,   193,   195,   197,   199,   201,
     203,   205,   207,   209,   211,   213,   215,   217,   219,   222,
     225,   228,   232,   236,   240,   242,   245,   247,   249,   251,
     253,   256,   260,   264,   268,   270,   273,   278,   283,   288,
     292,   296,   300,   305,   309,   313,   317,   321,   325,   331,
     332,   335,   338,   342,   344,   346,   348,   350,   352,   355,
     357,   359,   361,   363,   365,   369,   371,   373,   375,   377,
     380,   383,   387,   390,   393,   397,   399,   402
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const yysigned_char yyrhs[] =
{
      36,     0,    -1,    37,    43,    -1,    38,    39,    -1,    -1,
       3,    -1,     6,    -1,    -1,    40,    -1,    39,    40,    -1,
      41,    -1,    41,    37,    42,    23,    -1,    55,    57,    23,
      -1,     1,    23,    -1,    43,    23,    42,    -1,     1,    23,
      -1,    -1,    44,    55,    50,    57,    -1,    45,    -1,    46,
      47,    -1,    48,    -1,     7,    -1,    11,    -1,    12,    -1,
      13,    -1,    14,    -1,     7,    -1,    49,    47,    -1,    48,
      49,    47,    -1,     8,    -1,    -1,    51,    -1,    52,    -1,
      51,    52,    -1,    13,    53,    14,    -1,    49,    54,    -1,
      53,    49,    54,    -1,    87,    -1,    -1,    12,    12,    -1,
      12,    56,    12,    -1,    47,    -1,    56,    47,    -1,    -1,
      61,    59,    -1,    58,    59,    -1,    58,    24,    61,    59,
      -1,    60,    -1,    58,    24,    60,    -1,    58,    24,     1,
      -1,    -1,    24,    -1,    62,    -1,    25,    62,    -1,    64,
      -1,    63,    64,    -1,    66,     5,    -1,    63,    66,     5,
      -1,    65,    -1,    86,    -1,    96,    -1,    66,    -1,    67,
      -1,    83,    -1,    82,    -1,    26,     1,    23,    -1,    26,
       1,    27,    -1,    26,    62,    27,    -1,     7,    -1,    66,
       4,     7,    -1,    68,    -1,    69,    -1,    70,    -1,    71,
      -1,    72,    -1,    73,    -1,    79,    -1,    80,    -1,    15,
      -1,    17,    -1,    18,    -1,    19,    -1,    22,    -1,    21,
      -1,    16,    -1,    10,    -1,    20,    -1,     9,    -1,    28,
      74,    -1,    28,    77,    -1,    26,    27,    -1,    26,     1,
      23,    -1,    26,     1,    27,    -1,    26,    75,    27,    -1,
      76,    -1,    75,    76,    -1,    74,    -1,    77,    -1,    67,
      -1,     7,    -1,    29,    30,    -1,    29,     1,    23,    -1,
      29,     1,    30,    -1,    29,    78,    30,    -1,    69,    -1,
      78,    69,    -1,    28,    31,     1,    23,    -1,    28,    31,
       1,    32,    -1,    28,    31,    66,    32,    -1,    28,    28,
      81,    -1,    26,     1,    23,    -1,    26,     1,    27,    -1,
      26,    55,    57,    27,    -1,    31,     1,    23,    -1,    31,
       1,    32,    -1,    31,    57,    32,    -1,    29,     1,    23,
      -1,    29,     1,    30,    -1,    29,    84,    55,    57,    30,
      -1,    -1,    85,    46,    -1,    33,    47,    -1,    85,    33,
      47,    -1,    88,    -1,    91,    -1,    94,    -1,    65,    -1,
      88,    -1,    87,    45,    -1,    65,    -1,    88,    -1,    91,
      -1,    65,    -1,    88,    -1,    89,    46,    90,    -1,    90,
      -1,    91,    -1,    90,    -1,    91,    -1,    92,    95,    -1,
      49,    93,    -1,    95,    49,    93,    -1,    86,    97,    -1,
      34,    98,    -1,    97,    34,    98,    -1,    45,    -1,    46,
      90,    -1,    95,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   108,   108,   112,   113,   117,   124,   125,   131,   132,
     136,   137,   145,   154,   162,   165,   170,   176,   190,   194,
     198,   205,   209,   210,   211,   212,   216,   223,   227,   235,
     242,   245,   251,   255,   265,   274,   278,   287,   310,   313,
     317,   324,   328,   339,   342,   346,   350,   358,   362,   367,
     375,   377,   381,   388,   398,   399,   406,   410,   418,   419,
     420,   426,   427,   428,   429,   430,   437,   443,   450,   454,
     461,   462,   463,   464,   465,   466,   467,   468,   472,   476,
     480,   484,   488,   492,   499,   506,   513,   520,   529,   533,
     540,   544,   551,   557,   564,   568,   576,   577,   578,   579,
     598,   602,   609,   615,   622,   626,   636,   643,   649,   663,
     670,   677,   683,   697,   704,   710,   719,   726,   732,   740,
     743,   755,   759,   769,   770,   771,   775,   776,   780,   794,
     795,   796,   800,   801,   805,   814,   815,   819,   820,   824,
     831,   835,   845,   852,   856,   864,   868,   872
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "INTERNAL_TOKEN", "\"'.' or '::'\"", 
  "\"'_' or ':='\"", "\"#!\"", "\"identifier\"", "\"keyword message\"", 
  "\"string literal\"", "\"symbol literal\"", "\"binary message\"", "'|'", 
  "'<'", "'>'", "\"integer literal\"", "BYTE_LITERAL", 
  "\"floating-point literal\"", "FLOATE_LITERAL", "FLOATQ_LITERAL", 
  "\"character literal\"", "\"scaled decimal literal\"", 
  "LARGE_INTEGER_LITERAL", "'!'", "'.'", "'^'", "'('", "')'", "'#'", 
  "'['", "']'", "'{'", "'}'", "':'", "';'", "$accept", "program", 
  "internal_marker", "opt_shebang", "file_in", "doit_and_method_list", 
  "doit", "method_list", "method", "message_pattern", "unary_selector", 
  "binary_selector", "variable_name", "keyword_variable_list", "keyword", 
  "attributes", "attributes.1", "attribute", "attribute_body", 
  "attribute_argument", "temporaries", "variable_names", "statements", 
  "statements.1", "optional_dot", "statement", "return_statement", 
  "expression", "assigns", "simple_expression", "primary", 
  "variable_primary", "literal", "number", "small_number", 
  "symbol_constant", "character_constant", "string", "array_constant", 
  "array", "array_constant_list", "array_constant_elt", "byte_array", 
  "byte_array_constant_list", "variable_binding", "compile_time_constant", 
  "compile_time_constant_body", "array_constructor", "block", 
  "opt_block_variables", "block_variable_list", "message_expression", 
  "unary_message_receiver", "unary_expression", "binary_message_receiver", 
  "binary_message_argument", "binary_expression", 
  "keyword_message_receiver", "keyword_message_argument", 
  "keyword_expression", "keyword_message_arguments", 
  "cascaded_message_expression", "semi_message_list", "message_elt", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   124,    60,    62,   267,   268,   269,   270,   271,
     272,   273,   274,    33,    46,    94,    40,    41,    35,    91,
      93,   123,   125,    58,    59
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    35,    36,    36,    36,    37,    38,    38,    39,    39,
      40,    40,    41,    41,    42,    42,    42,    43,    44,    44,
      44,    45,    46,    46,    46,    46,    47,    48,    48,    49,
      50,    50,    51,    51,    52,    53,    53,    54,    55,    55,
      55,    56,    56,    57,    57,    57,    57,    58,    58,    58,
      59,    59,    60,    61,    62,    62,    63,    63,    64,    64,
      64,    65,    65,    65,    65,    65,    65,    65,    66,    66,
      67,    67,    67,    67,    67,    67,    67,    67,    68,    68,
      68,    68,    68,    68,    69,    70,    71,    72,    73,    73,
      74,    74,    74,    74,    75,    75,    76,    76,    76,    76,
      77,    77,    77,    77,    78,    78,    79,    79,    79,    80,
      81,    81,    81,    82,    82,    82,    83,    83,    83,    84,
      84,    85,    85,    86,    86,    86,    87,    87,    88,    89,
      89,    89,    90,    90,    91,    92,    92,    93,    93,    94,
      95,    95,    96,    97,    97,    98,    98,    98
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     2,     2,     0,     1,     1,     0,     1,     2,
       1,     4,     3,     2,     3,     2,     0,     4,     1,     2,
       1,     1,     1,     1,     1,     1,     1,     2,     3,     1,
       0,     1,     1,     2,     3,     2,     3,     1,     0,     2,
       3,     1,     2,     0,     2,     2,     4,     1,     3,     3,
       0,     1,     1,     2,     1,     2,     2,     3,     1,     1,
       1,     1,     1,     1,     1,     3,     3,     3,     1,     3,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     2,     2,
       2,     3,     3,     3,     1,     2,     1,     1,     1,     1,
       2,     3,     3,     3,     1,     2,     4,     4,     4,     3,
       3,     3,     4,     3,     3,     3,     3,     3,     5,     0,
       2,     2,     3,     1,     1,     1,     1,     1,     2,     1,
       1,     1,     1,     1,     3,     1,     1,     1,     1,     2,
       2,     3,     2,     2,     3,     1,     2,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
       7,     5,     6,     0,     0,     0,     1,    21,    29,    22,
      23,    24,    25,     2,    38,    18,     0,    20,     0,     0,
       0,     0,     8,    10,    43,    30,    26,    19,     0,    27,
      13,    39,    41,     0,     9,     0,    68,    87,    85,    78,
      84,    79,    80,    81,    86,    83,    82,     0,     0,     0,
       0,     0,     0,    50,    47,    50,    52,     0,    54,    58,
      61,    62,    70,    71,    72,    73,    74,    75,    76,    77,
      64,    63,    59,     0,   123,     0,   135,   124,     0,   125,
      60,     0,    43,    31,    32,    28,    40,    42,     0,     0,
       0,    53,     0,     0,     0,     0,     0,     0,    88,    89,
       0,     0,    38,     0,     0,     0,    12,     0,    45,    51,
      44,    55,    61,     0,    56,     0,   142,   128,     0,     0,
     139,     0,     0,    17,    33,    15,    11,     0,    65,    66,
      67,     0,    99,    90,    98,    96,     0,    94,    97,     0,
     109,     0,   100,   104,     0,     0,     0,   116,   117,   121,
      43,     0,   120,   113,   114,   115,    49,    48,    50,    57,
      69,   145,     0,   147,   143,     0,   132,    61,   133,   134,
     132,   133,   137,   138,   140,     0,    35,   126,    37,   127,
      34,     0,    14,    91,    92,    93,    95,     0,    43,   101,
     102,   103,   105,   106,   107,   108,     0,   122,    46,   146,
     144,   141,    36,   110,   111,     0,   118,   112
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short yydefgoto[] =
{
      -1,     3,     4,     5,    21,    22,    23,    89,    90,    14,
      15,    16,    27,    17,    18,    82,    83,    84,   122,   176,
      24,    33,    52,    53,   108,    54,    55,    56,    57,    58,
      59,    60,    61,    62,    63,    64,    65,    66,    67,   135,
     136,   137,   138,   144,    68,    69,   140,    70,    71,   102,
     103,    72,    73,    74,    75,    76,    77,    78,   174,    79,
     163,    80,   116,   164
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -114
static const short yypact[] =
{
     136,  -114,  -114,    72,   106,   255,  -114,  -114,  -114,  -114,
    -114,  -114,  -114,  -114,    71,  -114,   100,   107,   100,    85,
      90,   206,  -114,   113,   347,   108,  -114,  -114,   100,  -114,
    -114,  -114,  -114,    99,  -114,    81,  -114,  -114,  -114,  -114,
    -114,  -114,  -114,  -114,  -114,  -114,  -114,   370,   301,   149,
     172,   229,   101,    98,  -114,   110,  -114,   370,  -114,   119,
      20,  -114,  -114,  -114,  -114,  -114,  -114,  -114,  -114,  -114,
    -114,  -114,    91,   130,   416,   428,  -114,    66,   107,  -114,
    -114,   107,   347,   108,  -114,  -114,  -114,  -114,   120,   121,
     122,  -114,    -1,   124,   324,   126,    14,    53,  -114,  -114,
      17,   100,    71,    22,     6,   132,  -114,   140,  -114,  -114,
    -114,  -114,    38,   146,  -114,   106,   142,  -114,   370,   370,
     107,   370,    82,  -114,  -114,  -114,  -114,    81,  -114,  -114,
    -114,    29,  -114,  -114,  -114,  -114,   393,  -114,  -114,   278,
    -114,    23,  -114,  -114,     7,    18,    16,  -114,  -114,  -114,
     347,   100,  -114,  -114,  -114,  -114,  -114,  -114,   110,  -114,
    -114,  -114,   370,   107,  -114,   106,   147,   170,   176,  -114,
     197,   424,  -114,   432,  -114,   370,  -114,  -114,   130,  -114,
    -114,   370,  -114,  -114,  -114,  -114,  -114,    36,   347,  -114,
    -114,  -114,  -114,  -114,  -114,  -114,   155,  -114,  -114,  -114,
    -114,  -114,  -114,  -114,  -114,   159,  -114,  -114
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -114,  -114,   173,  -114,  -114,   174,  -114,    87,   195,  -114,
     -66,   -64,   -16,  -114,   -17,  -114,  -114,   129,  -114,    52,
     -11,  -114,   -50,  -114,   -49,   112,   133,    39,  -114,   160,
    -105,   -52,   -63,  -114,   -86,  -114,  -114,  -114,  -114,   171,
    -114,   105,   193,  -114,  -114,  -114,  -114,  -114,  -114,  -114,
    -114,  -114,  -113,  -100,  -114,   -91,  -110,  -114,    68,  -114,
     175,  -114,  -114,    94
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -137
static const short yytable[] =
{
      28,   105,    29,    25,    32,   112,   110,   117,   178,   173,
     143,   118,    85,   166,   170,   141,   177,    87,   168,   171,
     113,   179,   128,    40,   113,   114,   129,   169,   172,   153,
      40,   134,   123,     9,    10,    11,    12,   191,   154,   152,
     147,   193,   113,   159,   142,   146,   189,   148,   195,   161,
     194,   162,   183,   190,   145,   151,   184,   166,   192,   203,
      36,   119,   168,   204,   121,   173,   167,   167,   178,   167,
     170,   199,     6,   134,  -136,   171,   177,  -131,  -131,  -131,
    -131,   179,    88,    20,   172,   149,    91,    93,     7,     8,
       8,   150,     9,    10,    11,    12,   180,    26,   119,   161,
     196,   162,    31,   175,   -16,   181,    26,    26,    30,   198,
     167,    86,   117,     7,     8,     8,     1,     9,    10,    11,
      12,    81,   107,   167,   106,   115,  -126,  -132,   188,   167,
    -129,  -129,  -129,  -129,   109,   197,    -4,     7,   205,     1,
     -51,   156,     2,   125,   126,   127,   175,    36,   119,    37,
      38,   130,   139,   160,  -126,    39,    40,    41,    42,    43,
      44,    45,    46,   -51,   155,    47,    48,   -51,    49,    50,
     -51,    51,   -51,   100,   113,    94,   165,    95,    96,  -119,
      97,  -119,  -119,  -127,  -119,   206,   207,  -119,  -119,  -119,
    -119,  -119,  -119,  -119,  -119,    34,    35,  -119,  -119,    13,
    -119,  -119,  -119,  -119,  -126,   101,    -3,    19,  -129,  -129,
    -129,  -129,   124,   -38,   182,   -38,   -38,   111,    20,   157,
      98,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,
     104,   -38,   -38,   202,   -38,   -38,    36,   -38,    37,    38,
     158,   186,    99,   201,    39,    40,    41,    42,    43,    44,
      45,    46,     0,   120,    47,    48,    19,    49,    50,   200,
      51,   -43,   -38,     0,   -38,   -38,     0,    20,     0,     0,
     -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   187,
     -38,   -38,     0,   -38,   -38,   -38,   -38,   -38,   -38,     0,
      20,     0,     0,   -38,   -38,   -38,   -38,   -38,   -38,   -38,
     -38,     0,    92,   -38,   -38,   -38,   -38,   -38,    36,   -38,
      37,    38,     0,     0,     0,     0,    39,    40,    41,    42,
      43,    44,    45,    46,     0,   131,     0,    48,     0,    49,
      50,   132,    51,    37,    38,     0,     0,     0,     0,    39,
      40,    41,    42,    43,    44,    45,    46,     0,     0,     0,
      94,   133,    49,    96,    36,     0,    37,    38,     0,     0,
       0,     0,    39,    40,    41,    42,    43,    44,    45,    46,
       0,     0,    47,    48,     0,    49,    50,    36,    51,    37,
      38,     0,     0,     0,     0,    39,    40,    41,    42,    43,
      44,    45,    46,     0,     0,     0,    48,     0,    49,    50,
     132,    51,    37,    38,     0,     0,     0,     0,    39,    40,
      41,    42,    43,    44,    45,    46,     0,     0,     0,    94,
     185,    49,    96,  -127,  -133,     0,     0,  -130,  -130,  -130,
    -130,  -127,     0,     0,     0,  -130,  -130,  -130,  -130,     9,
      10,    11,    12,  -131,  -131,  -131,  -131
};

static const short yycheck[] =
{
      17,    51,    18,    14,    20,    57,    55,    73,   121,   119,
      96,    75,    28,   118,   119,     1,   121,    33,   118,   119,
       4,   121,    23,    16,     4,     5,    27,   118,   119,    23,
      16,    94,    82,    11,    12,    13,    14,    30,    32,   103,
      23,    23,     4,     5,    30,    97,    23,    30,    32,   115,
      32,   115,    23,    30,     1,    33,    27,   162,   144,    23,
       7,    78,   162,    27,    81,   175,   118,   119,   181,   121,
     175,   162,     0,   136,     8,   175,   181,    11,    12,    13,
      14,   181,     1,    12,   175,   101,    47,    48,     7,     8,
       8,   102,    11,    12,    13,    14,    14,     7,   115,   165,
     150,   165,    12,   120,    23,   122,     7,     7,    23,   158,
     162,    12,   178,     7,     8,     8,     3,    11,    12,    13,
      14,    13,    24,   175,    23,    34,     7,     8,   139,   181,
      11,    12,    13,    14,    24,   151,     0,     7,   188,     3,
       0,     1,     6,    23,    23,    23,   163,     7,   165,     9,
      10,    27,    26,     7,     7,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    32,    25,    26,    27,    28,    29,
      30,    31,    32,     1,     4,    26,    34,    28,    29,     7,
      31,     9,    10,     7,    12,    30,    27,    15,    16,    17,
      18,    19,    20,    21,    22,    21,    23,    25,    26,     4,
      28,    29,    30,    31,     7,    33,     0,     1,    11,    12,
      13,    14,    83,     7,   127,     9,    10,    57,    12,   107,
      49,    15,    16,    17,    18,    19,    20,    21,    22,    23,
       1,    25,    26,   181,    28,    29,     7,    31,     9,    10,
     107,   136,    49,   175,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    78,    25,    26,     1,    28,    29,   165,
      31,    32,     7,    -1,     9,    10,    -1,    12,    -1,    -1,
      15,    16,    17,    18,    19,    20,    21,    22,    23,     1,
      25,    26,    -1,    28,    29,     7,    31,     9,    10,    -1,
      12,    -1,    -1,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,     1,    25,    26,    27,    28,    29,     7,    31,
       9,    10,    -1,    -1,    -1,    -1,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,     1,    -1,    26,    -1,    28,
      29,     7,    31,     9,    10,    -1,    -1,    -1,    -1,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    -1,    -1,
      26,    27,    28,    29,     7,    -1,     9,    10,    -1,    -1,
      -1,    -1,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    -1,    25,    26,    -1,    28,    29,     7,    31,     9,
      10,    -1,    -1,    -1,    -1,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    -1,    -1,    26,    -1,    28,    29,
       7,    31,     9,    10,    -1,    -1,    -1,    -1,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    -1,    -1,    26,
      27,    28,    29,     7,     8,    -1,    -1,    11,    12,    13,
      14,     7,    -1,    -1,    -1,    11,    12,    13,    14,    11,
      12,    13,    14,    11,    12,    13,    14
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     3,     6,    36,    37,    38,     0,     7,     8,    11,
      12,    13,    14,    43,    44,    45,    46,    48,    49,     1,
      12,    39,    40,    41,    55,    55,     7,    47,    49,    47,
      23,    12,    47,    56,    40,    37,     7,     9,    10,    15,
      16,    17,    18,    19,    20,    21,    22,    25,    26,    28,
      29,    31,    57,    58,    60,    61,    62,    63,    64,    65,
      66,    67,    68,    69,    70,    71,    72,    73,    79,    80,
      82,    83,    86,    87,    88,    89,    90,    91,    92,    94,
      96,    13,    50,    51,    52,    47,    12,    47,     1,    42,
      43,    62,     1,    62,    26,    28,    29,    31,    74,    77,
       1,    33,    84,    85,     1,    57,    23,    24,    59,    24,
      59,    64,    66,     4,     5,    34,    97,    45,    46,    49,
      95,    49,    53,    57,    52,    23,    23,    23,    23,    27,
      27,     1,     7,    27,    67,    74,    75,    76,    77,    26,
      81,     1,    30,    69,    78,     1,    66,    23,    30,    47,
      55,    33,    46,    23,    32,    32,     1,    60,    61,     5,
       7,    45,    46,    95,    98,    34,    65,    66,    88,    90,
      65,    88,    90,    91,    93,    49,    54,    65,    87,    88,
      14,    49,    42,    23,    27,    27,    76,     1,    55,    23,
      30,    30,    69,    23,    32,    32,    57,    47,    59,    90,
      98,    93,    54,    23,    27,    57,    30,    27
};

#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# if defined (__STDC__) || defined (__cplusplus)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# endif
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrlab1

/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");\
      YYERROR;							\
    }								\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)         \
  Current.first_line   = Rhs[1].first_line;      \
  Current.first_column = Rhs[1].first_column;    \
  Current.last_line    = Rhs[N].last_line;       \
  Current.last_column  = Rhs[N].last_column;
#endif

/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (&yylval, &yylloc, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval, &yylloc)
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (0)

# define YYDSYMPRINT(Args)			\
do {						\
  if (yydebug)					\
    yysymprint Args;				\
} while (0)

# define YYDSYMPRINTF(Title, Token, Value, Location)		\
do {								\
  if (yydebug)							\
    {								\
      YYFPRINTF (stderr, "%s ", Title);				\
      yysymprint (stderr, 					\
                  Token, Value, Location);	\
      YYFPRINTF (stderr, "\n");					\
    }								\
} while (0)

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (cinluded).                                                   |
`------------------------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_stack_print (short *bottom, short *top)
#else
static void
yy_stack_print (bottom, top)
    short *bottom;
    short *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (/* Nothing. */; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_reduce_print (int yyrule)
#else
static void
yy_reduce_print (yyrule)
    int yyrule;
#endif
{
  int yyi;
  unsigned int yylineno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %u), ",
             yyrule - 1, yylineno);
  /* Print the symbols being reduced, and their result.  */
  for (yyi = yyprhs[yyrule]; 0 <= yyrhs[yyi]; yyi++)
    YYFPRINTF (stderr, "%s ", yytname [yyrhs[yyi]]);
  YYFPRINTF (stderr, "-> %s\n", yytname [yyr1[yyrule]]);
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (Rule);		\
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YYDSYMPRINT(Args)
# define YYDSYMPRINTF(Title, Token, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   SIZE_MAX < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#if YYMAXDEPTH == 0
# undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  register const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  register char *yyd = yydest;
  register const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

#endif /* !YYERROR_VERBOSE */



#if YYDEBUG
/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yysymprint (FILE *yyoutput, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
#else
static void
yysymprint (yyoutput, yytype, yyvaluep, yylocationp)
    FILE *yyoutput;
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;
  (void) yylocationp;

  if (yytype < YYNTOKENS)
    {
      YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
# ifdef YYPRINT
      YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
    }
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  switch (yytype)
    {
      default:
        break;
    }
  YYFPRINTF (yyoutput, ")");
}

#endif /* ! YYDEBUG */
/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yydestruct (int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
#else
static void
yydestruct (yytype, yyvaluep, yylocationp)
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;
  (void) yylocationp;

  switch (yytype)
    {

      default:
        break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM);
# else
int yyparse ();
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */






/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM)
# else
int yyparse (YYPARSE_PARAM)
  void *YYPARSE_PARAM;
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  /* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;
/* Location data for the lookahead symbol.  */
YYLTYPE yylloc;

  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  short	yyssa[YYINITDEPTH];
  short *yyss = yyssa;
  register short *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  register YYSTYPE *yyvsp;

  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
  YYLTYPE *yylerrsp;

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* When reducing, the number of symbols on the RHS of the reduced
     rule.  */
  int yylen;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;
  yylsp = yyls;
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short *yyss1 = yyss;
	YYLTYPE *yyls1 = yyls;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyoverflowlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	short *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyoverflowlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);
	YYSTACK_RELOCATE (yyls);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YYDSYMPRINTF ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %s, ", yytname[yytoken]));

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
  *++yylsp = yylloc;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location. */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 109 "gst-parse.y"
    {
		  _gst_reset_compilation_category ();
		}
    break;

  case 5:
#line 118 "gst-parse.y"
    {
		  _gst_clear_method_start_pos (); 
		}
    break;

  case 11:
#line 138 "gst-parse.y"
    {
		  _gst_skip_compilation = false;
		  _gst_reset_compilation_category ();
		}
    break;

  case 12:
#line 147 "gst-parse.y"
    {
		  if (yyvsp[-1].node && !_gst_had_error)
		    _gst_execute_statements (yyvsp[-2].node, yyvsp[-1].node, false);

		  _gst_free_tree ();
		  _gst_had_error = false;
		}
    break;

  case 13:
#line 155 "gst-parse.y"
    {
		  _gst_had_error = false;
		  yyerrok;
		}
    break;

  case 14:
#line 163 "gst-parse.y"
    {
		}
    break;

  case 15:
#line 166 "gst-parse.y"
    {
		  _gst_had_error = false;
		  yyerrok;
		}
    break;

  case 17:
#line 177 "gst-parse.y"
    {
		  yyval.node = _gst_make_method (&yyloc, yyvsp[-3].node, yyvsp[-2].node, yyvsp[-1].node, yyvsp[0].node); 
		  if (!_gst_had_error && !_gst_skip_compilation) {
		    _gst_compile_method (yyval.node, false, true);
		    _gst_clear_method_start_pos ();
		  }

		  _gst_free_tree ();
		  _gst_had_error = false;
		}
    break;

  case 18:
#line 191 "gst-parse.y"
    {
		  yyval.node = _gst_make_unary_expr (&yyloc, NULL, yyvsp[0].sval); 
		}
    break;

  case 19:
#line 195 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr (&yyloc, NULL, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 20:
#line 199 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr (&yyloc, NULL, yyvsp[0].node); 
		}
    break;

  case 26:
#line 217 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable (&yyloc, yyvsp[0].sval); 
		}
    break;

  case 27:
#line 224 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 28:
#line 228 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 30:
#line 242 "gst-parse.y"
    {
		  yyval.node = NULL;
		}
    break;

  case 31:
#line 246 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node;
		}
    break;

  case 32:
#line 252 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node;
		}
    break;

  case 33:
#line 256 "gst-parse.y"
    {
		  if (yyvsp[-1].node && yyvsp[0].node)
		    _gst_add_node (yyvsp[-1].node, yyvsp[0].node);

		  yyval.node = yyvsp[-1].node ? yyvsp[-1].node : yyvsp[0].node;
		}
    break;

  case 34:
#line 266 "gst-parse.y"
    {
		  if (yyvsp[-1].node)
		    yyval.node = _gst_make_attribute_list (&yyloc, yyvsp[-1].node); 
		  else
		    yyval.node = NULL;
		}
    break;

  case 35:
#line 275 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node ? _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node) : NULL; 
		}
    break;

  case 36:
#line 279 "gst-parse.y"
    {
		  if (yyvsp[-2].node && yyvsp[0].node)
		    _gst_add_node (yyvsp[-2].node, _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node));

		  yyval.node = yyvsp[-2].node ? yyvsp[-2].node : yyvsp[0].node; 
		}
    break;

  case 37:
#line 288 "gst-parse.y"
    {
		  OOP result;
		  if (yyvsp[0].node && !_gst_had_error)
		    {
		      tree_node stmt = _gst_make_statement_list (&yyloc, yyvsp[0].node); 
		      result = _gst_execute_statements (NULL, stmt, true);
		      _gst_had_error = !result;
		    }
		  else
		    result = NULL;

		  if (result)
		    yyval.node = _gst_make_oop_constant (&yyloc, result); 
		  else
		    yyval.node = NULL;
		}
    break;

  case 38:
#line 310 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 39:
#line 314 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 40:
#line 318 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 41:
#line 325 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 42:
#line 329 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-1].node, _gst_make_variable_list (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 43:
#line 339 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 44:
#line 343 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node;
		}
    break;

  case 45:
#line 347 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node;
		}
    break;

  case 46:
#line 351 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-3].node, yyvsp[-1].node);
		  yyval.node = yyvsp[-3].node;
		}
    break;

  case 47:
#line 359 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 48:
#line 363 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, yyvsp[0].node); 
		  yyval.node = yyvsp[-2].node;
		}
    break;

  case 49:
#line 368 "gst-parse.y"
    {
		  yyval.node = yyvsp[-2].node;
		  yyerrok;
		  _gst_had_error = true;
		}
    break;

  case 52:
#line 382 "gst-parse.y"
    {
		  yyval.node = _gst_make_statement_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 53:
#line 389 "gst-parse.y"
    {
		  yyval.node = _gst_make_statement_list (&yyloc,
						_gst_make_return (&yyloc, yyvsp[0].node));
		}
    break;

  case 55:
#line 400 "gst-parse.y"
    {
		  yyval.node = _gst_make_assign (&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 56:
#line 407 "gst-parse.y"
    {
		  yyval.node = _gst_make_assignment_list (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 57:
#line 411 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_assignment_list (&yyloc, yyvsp[-1].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 65:
#line 431 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 66:
#line 438 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 67:
#line 444 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 68:
#line 451 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable (&yyloc, yyvsp[0].sval); 
		}
    break;

  case 69:
#line 455 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_variable (&yyloc, yyvsp[0].sval)); 
		}
    break;

  case 78:
#line 473 "gst-parse.y"
    {
		  yyval.node = _gst_make_int_constant (&yyloc, yyvsp[0].ival); 
		}
    break;

  case 79:
#line 477 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant (&yyloc, yyvsp[0].fval, CONST_FLOATD); 
		}
    break;

  case 80:
#line 481 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant (&yyloc, yyvsp[0].fval, CONST_FLOATE); 
		}
    break;

  case 81:
#line 485 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant (&yyloc, yyvsp[0].fval, CONST_FLOATQ); 
		}
    break;

  case 82:
#line 489 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_object_constant (&yyloc, yyvsp[0].boval); 
		}
    break;

  case 83:
#line 493 "gst-parse.y"
    {
		  yyval.node = _gst_make_oop_constant (&yyloc, yyvsp[0].oval); 
		}
    break;

  case 84:
#line 500 "gst-parse.y"
    {
		  yyval.node = _gst_make_int_constant (&yyloc, yyvsp[0].ival); 
		}
    break;

  case 85:
#line 507 "gst-parse.y"
    {
		  yyval.node = _gst_make_symbol_constant (&yyloc, _gst_intern_ident (&yyloc, yyvsp[0].sval)); 
		}
    break;

  case 86:
#line 514 "gst-parse.y"
    {
		  yyval.node = _gst_make_char_constant (&yyloc, yyvsp[0].cval); 
		}
    break;

  case 87:
#line 521 "gst-parse.y"
    {
		  yyval.node = _gst_make_string_constant (&yyloc, yyvsp[0].sval); 
		}
    break;

  case 88:
#line 530 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 89:
#line 534 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 90:
#line 541 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constant (&yyloc, NULL); 
		}
    break;

  case 91:
#line 545 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 92:
#line 552 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 93:
#line 558 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constant (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 94:
#line 565 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_elt (&yyloc, yyvsp[0].node); 
		}
    break;

  case 95:
#line 569 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-1].node, _gst_make_array_elt (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 99:
#line 580 "gst-parse.y"
    {
		  OOP symbolOOP = _gst_intern_string (yyvsp[0].sval);
		  if (symbolOOP == _gst_true_symbol) {
		    yyval.node = _gst_make_oop_constant (&yyloc, _gst_true_oop);
		  } else if (symbolOOP == _gst_false_symbol) {
		    yyval.node = _gst_make_oop_constant (&yyloc, _gst_false_oop);
		  } else if (symbolOOP == _gst_nil_symbol) {
		    yyval.node = _gst_make_oop_constant (&yyloc, _gst_nil_oop);
		  } else {
		    _gst_errorf ("expected true, false or nil");
		    YYERROR;
		  }
		}
    break;

  case 100:
#line 599 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_array_constant (&yyloc, NULL); 
		}
    break;

  case 101:
#line 603 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 102:
#line 610 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 103:
#line 616 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_array_constant (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 104:
#line 623 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_elt (&yyloc, yyvsp[0].node); 
		}
    break;

  case 105:
#line 627 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-1].node, _gst_make_array_elt (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 106:
#line 637 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 107:
#line 644 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 108:
#line 651 "gst-parse.y"
    {
		  yyval.node = _gst_make_binding_constant (&yyloc, yyvsp[-1].node); 
		  if (!yyval.node) {
		    _gst_errorf ("invalid variable binding");
		    YYERROR;
		  }
		}
    break;

  case 109:
#line 664 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node;
		}
    break;

  case 110:
#line 671 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = _gst_make_oop_constant (&yyloc, _gst_nil_oop); 
		}
    break;

  case 111:
#line 678 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = _gst_make_oop_constant (&yyloc, _gst_nil_oop); 
		}
    break;

  case 112:
#line 684 "gst-parse.y"
    {
		  OOP result = _gst_nil_oop;
		  if (yyvsp[-1].node && !_gst_had_error)
		    result = _gst_execute_statements (yyvsp[-2].node, yyvsp[-1].node, true);

		  yyval.node = _gst_make_oop_constant (&yyloc,
					       result ? result : _gst_nil_oop); 
		}
    break;

  case 113:
#line 698 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 114:
#line 705 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 115:
#line 711 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constructor (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 116:
#line 720 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 117:
#line 727 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 118:
#line 733 "gst-parse.y"
    {
		  yyval.node = _gst_make_block (&yyloc, yyvsp[-3].node, yyvsp[-2].node, yyvsp[-1].node); 
		}
    break;

  case 119:
#line 740 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 120:
#line 744 "gst-parse.y"
    {
		  if (yyvsp[0].sval[0] != '|') {
		    YYFAIL;
		  } else if (yyvsp[0].sval[1] == '\0') {	/* | */
		  } else if (yyvsp[0].sval[1] == '|') {   /* || */
		    _gst_unread_char ('|');
		  }
		}
    break;

  case 121:
#line 756 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 122:
#line 760 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_variable_list (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 128:
#line 781 "gst-parse.y"
    {
		  if (is_unlikely_selector (yyvsp[0].sval))
		    {
		      _gst_warningf ("sending `%s', most likely you "
			             "forgot a period", yyvsp[0].sval);
		    }
		  yyval.node = _gst_make_unary_expr (&yyloc, yyvsp[-1].node, yyvsp[0].sval); 
		}
    break;

  case 134:
#line 806 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr (&yyloc, yyvsp[-2].node, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 139:
#line 825 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr (&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 140:
#line 832 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 141:
#line 836 "gst-parse.y"
    {
		   _gst_add_node (yyvsp[-2].node, _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node));
		   yyval.node = yyvsp[-2].node; 
		}
    break;

  case 142:
#line 846 "gst-parse.y"
    {
		  yyval.node = _gst_make_cascaded_message (&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 143:
#line 853 "gst-parse.y"
    {
		  yyval.node = _gst_make_message_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 144:
#line 857 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_message_list (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 145:
#line 865 "gst-parse.y"
    {
		   yyval.node = _gst_make_unary_expr (&yyloc, NULL, yyvsp[0].sval); 
		}
    break;

  case 146:
#line 869 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr (&yyloc, NULL, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 147:
#line 873 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr (&yyloc, NULL, yyvsp[0].node); 
		}
    break;


    }

/* Line 991 of yacc.c.  */
#line 2119 "gst-parse.c"

  yyvsp -= yylen;
  yyssp -= yylen;
  yylsp -= yylen;

  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (YYPACT_NINF < yyn && yyn < YYLAST)
	{
	  YYSIZE_T yysize = 0;
	  int yytype = YYTRANSLATE (yychar);
	  char *yymsg;
	  int yyx, yycount;

	  yycount = 0;
	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  for (yyx = yyn < 0 ? -yyn : 0;
	       yyx < (int) (sizeof (yytname) / sizeof (char *)); yyx++)
	    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	      yysize += yystrlen (yytname[yyx]) + 15, yycount++;
	  yysize += yystrlen ("syntax error, unexpected ") + 1;
	  yysize += yystrlen (yytname[yytype]);
	  yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg != 0)
	    {
	      char *yyp = yystpcpy (yymsg, "syntax error, unexpected ");
	      yyp = yystpcpy (yyp, yytname[yytype]);

	      if (yycount < 5)
		{
		  yycount = 0;
		  for (yyx = yyn < 0 ? -yyn : 0;
		       yyx < (int) (sizeof (yytname) / sizeof (char *));
		       yyx++)
		    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
		      {
			const char *yyq = ! yycount ? ", expecting " : " or ";
			yyp = yystpcpy (yyp, yyq);
			yyp = yystpcpy (yyp, yytname[yyx]);
			yycount++;
		      }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    yyerror ("syntax error; also virtual memory exhausted");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror ("syntax error");
    }

  yylerrsp = yylsp;

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      /* Return failure if at end of input.  */
      if (yychar == YYEOF)
        {
	  /* Pop the error token.  */
          YYPOPSTACK;
	  /* Pop the rest of the stack.  */
	  while (yyss < yyssp)
	    {
	      YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
	      yydestruct (yystos[*yyssp], yyvsp, yylsp);
	      YYPOPSTACK;
	    }
	  YYABORT;
        }

      YYDSYMPRINTF ("Error: discarding", yytoken, &yylval, &yylloc);
      yydestruct (yytoken, &yylval, &yylloc);
      yychar = YYEMPTY;
      *++yylerrsp = yylloc;
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab2;


/*----------------------------------------------------.
| yyerrlab1 -- error raised explicitly by an action.  |
`----------------------------------------------------*/
yyerrlab1:

  /* Suppress GCC warning that yyerrlab1 is unused when no action
     invokes YYERROR.  */
#if defined (__GNUC_MINOR__) && 2093 <= (__GNUC__ * 1000 + __GNUC_MINOR__)
  __attribute__ ((__unused__))
#endif

  yylerrsp = yylsp;
  *++yylerrsp = yyloc;
  goto yyerrlab2;


/*---------------------------------------------------------------.
| yyerrlab2 -- pop states until the error token can be shifted.  |
`---------------------------------------------------------------*/
yyerrlab2:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;

      YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
      yydestruct (yystos[yystate], yyvsp, yylsp);
      yyvsp--;
      yystate = *--yyssp;
      yylsp--;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;
  YYLLOC_DEFAULT (yyloc, yylsp, (yylerrsp - yylsp));
  *++yylsp = yyloc;

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*----------------------------------------------.
| yyoverflowlab -- parser overflow comes here.  |
`----------------------------------------------*/
yyoverflowlab:
  yyerror ("parser stack overflow");
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}


#line 879 "gst-parse.y"

/*     
 * ADDITIONAL C CODE
 */

/* Based on an hash table produced by gperf version 2.7.2
   Command-line: gperf -tn -F ', false' -j1 -k1,2
   with the following input:

   false
   nil
   self
   super
   thisContext
   true
   fe
   ne
   nh
   sr

   A few negatives have been included in the input to avoid that
   messages like #new or #size require a strcmp (their hash value is
   in range if only the six keywords were included), and the length
   has not been included to make the result depend on selectors
   *starting* with two given letters.  With this hash table and this
   implementation, only selectors starting with "fa", "ni", "se",
   "su", "th", "tr" (which are unavoidable) require a strcmp, which is
   a good compromise.  All the others require three array lookups
   (two for the hash function, one to check for the first character)

   An alternative could have been simple trie-like
   code like this:

   return ((*$1 == 's' &&
	    (strcmp ($1+1, "elf") == 0 ||
	     strcmp ($1+1, "uper") == 0)) ||
   
	   (*$1 == 't' &&
	    (strcmp ($1+1, "rue") == 0 ||
	     strcmp ($1+1, "hisContext") == 0)) ||
   
	   (*$1 == 'f' && strcmp ($1+1, "alse") == 0) ||
	   (*$1 == 'n' && strcmp ($1+1, "il") == 0))

   ... but using gperf is more cool :-) */

mst_Boolean
is_unlikely_selector (register const char *str)
{
  /* The first-character table is big enough that
     we skip the range check on the hash value */

  static const char first[31] = 
    "s  s   f  n  tt               ";

  static const char *rest[] =
    {
      "elf",
      NULL,
      NULL,
      "uper",
      NULL,
      NULL,
      NULL,
      "alse",
      NULL,
      NULL,
      "il",
      NULL,
      NULL,
      "hisContext",
      "rue"
    };

  static unsigned char asso_values[] =
    {
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15,  1, 15, 15,
      15,  0,  6, 15,  4,  2, 15, 15, 15, 15,
       8, 15, 15, 15,  5,  0,  9,  3, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15
    };

  register int key = asso_values[(unsigned char)str[1]] + 
    asso_values[(unsigned char)str[0]];

  return
    first[key] == *str &&
    !strcmp (str + 1, rest[key]);
}

