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
#line 147 "../../libgst/gst-parse.c"
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
#line 171 "../../libgst/gst-parse.c"

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
#define YYLAST   431

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  35
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  64
/* YYNRULES -- Number of rules. */
#define YYNRULES  147
/* YYNRULES -- Number of states. */
#define YYNSTATES  207

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
      75,    76,    78,    80,    83,    87,    89,    92,    95,    96,
      99,   103,   105,   108,   109,   112,   115,   120,   122,   126,
     130,   131,   133,   135,   138,   140,   143,   146,   150,   152,
     154,   156,   158,   160,   162,   164,   168,   172,   176,   178,
     182,   184,   186,   188,   190,   192,   194,   196,   198,   200,
     202,   204,   206,   208,   210,   212,   214,   216,   218,   221,
     224,   227,   231,   235,   239,   241,   244,   246,   248,   250,
     252,   255,   259,   263,   267,   269,   272,   277,   282,   287,
     291,   295,   299,   304,   308,   312,   316,   320,   324,   330,
     331,   334,   337,   341,   343,   345,   347,   349,   351,   354,
     356,   358,   360,   362,   364,   368,   370,   372,   374,   376,
     379,   382,   386,   389,   392,   396,   398,   401
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
      51,    52,    -1,    13,    53,    14,    -1,    54,    -1,    53,
      54,    -1,    49,    87,    -1,    -1,    12,    12,    -1,    12,
      56,    12,    -1,    47,    -1,    56,    47,    -1,    -1,    61,
      59,    -1,    58,    59,    -1,    58,    24,    61,    59,    -1,
      60,    -1,    58,    24,    60,    -1,    58,    24,     1,    -1,
      -1,    24,    -1,    62,    -1,    25,    62,    -1,    64,    -1,
      63,    64,    -1,    66,     5,    -1,    63,    66,     5,    -1,
      65,    -1,    86,    -1,    96,    -1,    66,    -1,    67,    -1,
      83,    -1,    82,    -1,    26,     1,    23,    -1,    26,     1,
      27,    -1,    26,    62,    27,    -1,     7,    -1,    66,     4,
       7,    -1,    68,    -1,    69,    -1,    70,    -1,    71,    -1,
      72,    -1,    73,    -1,    79,    -1,    80,    -1,    15,    -1,
      17,    -1,    18,    -1,    19,    -1,    22,    -1,    21,    -1,
      16,    -1,    10,    -1,    20,    -1,     9,    -1,    28,    74,
      -1,    28,    77,    -1,    26,    27,    -1,    26,     1,    23,
      -1,    26,     1,    27,    -1,    26,    75,    27,    -1,    76,
      -1,    75,    76,    -1,    74,    -1,    77,    -1,    67,    -1,
       7,    -1,    29,    30,    -1,    29,     1,    23,    -1,    29,
       1,    30,    -1,    29,    78,    30,    -1,    69,    -1,    78,
      69,    -1,    28,    31,     1,    23,    -1,    28,    31,     1,
      32,    -1,    28,    31,    66,    32,    -1,    28,    28,    81,
      -1,    26,     1,    23,    -1,    26,     1,    27,    -1,    26,
      55,    57,    27,    -1,    31,     1,    23,    -1,    31,     1,
      32,    -1,    31,    57,    32,    -1,    29,     1,    23,    -1,
      29,     1,    30,    -1,    29,    84,    55,    57,    30,    -1,
      -1,    85,    46,    -1,    33,    47,    -1,    85,    33,    47,
      -1,    88,    -1,    91,    -1,    94,    -1,    65,    -1,    88,
      -1,    87,    45,    -1,    65,    -1,    88,    -1,    91,    -1,
      65,    -1,    88,    -1,    89,    46,    90,    -1,    90,    -1,
      91,    -1,    90,    -1,    91,    -1,    92,    95,    -1,    49,
      93,    -1,    95,    49,    93,    -1,    86,    97,    -1,    34,
      98,    -1,    97,    34,    98,    -1,    45,    -1,    46,    90,
      -1,    95,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   108,   108,   112,   113,   117,   124,   125,   131,   132,
     136,   137,   145,   154,   162,   165,   170,   176,   190,   194,
     198,   205,   209,   210,   211,   212,   216,   223,   227,   235,
     242,   245,   251,   255,   265,   274,   278,   290,   314,   317,
     321,   328,   332,   343,   346,   350,   354,   362,   366,   371,
     379,   381,   385,   392,   402,   403,   410,   414,   422,   423,
     424,   430,   431,   432,   433,   434,   441,   447,   454,   458,
     465,   466,   467,   468,   469,   470,   471,   472,   476,   480,
     484,   488,   492,   496,   503,   510,   517,   524,   533,   537,
     544,   548,   555,   561,   568,   572,   580,   581,   582,   583,
     602,   606,   613,   619,   626,   630,   640,   647,   653,   667,
     674,   681,   687,   701,   708,   714,   723,   730,   736,   744,
     747,   759,   763,   773,   774,   775,   779,   780,   784,   798,
     799,   800,   804,   805,   809,   818,   819,   823,   824,   828,
     835,   839,   849,   856,   860,   868,   872,   876
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
       0,     1,     1,     2,     3,     1,     2,     2,     0,     2,
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
     139,     0,     0,    35,    17,    33,    15,    11,     0,    65,
      66,    67,     0,    99,    90,    98,    96,     0,    94,    97,
       0,   109,     0,   100,   104,     0,     0,     0,   116,   117,
     121,    43,     0,   120,   113,   114,   115,    49,    48,    50,
      57,    69,   145,     0,   147,   143,     0,   132,    61,   133,
     134,   132,   133,   137,   138,   140,     0,   126,    37,   127,
      34,    36,    14,    91,    92,    93,    95,     0,    43,   101,
     102,   103,   105,   106,   107,   108,     0,   122,    46,   146,
     144,   141,   110,   111,     0,   118,   112
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short yydefgoto[] =
{
      -1,     3,     4,     5,    21,    22,    23,    89,    90,    14,
      15,    16,    27,    17,    18,    82,    83,    84,   122,   123,
      24,    33,    52,    53,   108,    54,    55,    56,    57,    58,
      59,    60,    61,    62,    63,    64,    65,    66,    67,   136,
     137,   138,   139,   145,    68,    69,   141,    70,    71,   102,
     103,    72,    73,    74,    75,    76,    77,    78,   175,    79,
     164,    80,   116,   165
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -109
static const short yypact[] =
{
     131,  -109,  -109,    44,    75,   256,  -109,  -109,  -109,  -109,
    -109,  -109,  -109,  -109,    58,  -109,    65,    86,    65,    74,
      47,   207,  -109,   101,   348,    89,  -109,  -109,    65,  -109,
    -109,  -109,  -109,    72,  -109,    27,  -109,  -109,  -109,  -109,
    -109,  -109,  -109,  -109,  -109,  -109,  -109,    99,   302,    64,
     173,   230,    84,    98,  -109,   102,  -109,    99,  -109,   132,
      22,  -109,  -109,  -109,  -109,  -109,  -109,  -109,  -109,  -109,
    -109,  -109,    79,   116,   394,   413,  -109,   409,    86,  -109,
    -109,    86,   348,    89,  -109,  -109,  -109,  -109,   112,   129,
     130,  -109,   152,   127,   325,   139,    21,    56,  -109,  -109,
       0,    65,    58,    63,    10,   123,  -109,   141,  -109,  -109,
    -109,  -109,    76,   169,  -109,    75,   144,  -109,    99,    99,
      86,    99,    17,  -109,  -109,  -109,  -109,  -109,    27,  -109,
    -109,  -109,   154,  -109,  -109,  -109,  -109,   371,  -109,  -109,
     279,  -109,    23,  -109,  -109,    13,    24,    20,  -109,  -109,
    -109,   348,    65,  -109,  -109,  -109,  -109,  -109,  -109,   102,
    -109,  -109,  -109,    99,    86,  -109,    75,   177,   182,   180,
    -109,   198,   402,  -109,   417,  -109,    99,  -109,   116,  -109,
    -109,  -109,  -109,  -109,  -109,  -109,  -109,   237,   348,  -109,
    -109,  -109,  -109,  -109,  -109,  -109,   166,  -109,  -109,  -109,
    -109,  -109,  -109,  -109,   170,  -109,  -109
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -109,  -109,   190,  -109,  -109,   179,  -109,    87,   214,  -109,
     -66,   -67,   -16,  -109,   -17,  -109,  -109,   137,  -109,   119,
     -11,  -109,   -50,  -109,   -49,   114,   135,    85,  -109,   186,
    -108,   -52,   -75,  -109,   -87,  -109,  -109,  -109,  -109,   185,
    -109,   107,   204,  -109,  -109,  -109,  -109,  -109,  -109,  -109,
    -109,  -109,   133,  -103,  -109,   -98,  -105,  -109,    91,  -109,
     191,  -109,  -109,   104
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -137
static const short yytable[] =
{
      28,   105,    29,    25,    32,   112,   110,   117,   118,   144,
     167,   171,    85,   177,   174,   169,   172,    87,   179,   135,
     170,   173,   142,   148,   113,     8,   113,   114,    88,    40,
     149,   180,   124,   154,     7,     8,   153,    40,     9,    10,
      11,    12,   155,   191,     6,   147,   189,   193,   163,   162,
     -16,   143,   195,   190,    26,   167,   194,   146,   192,    31,
     169,   119,   135,    36,   121,   199,   168,   168,   171,   168,
      20,   174,    26,   172,     9,    10,    11,    12,   173,    26,
     113,   160,     7,     8,    86,   150,     9,    10,    11,    12,
      94,   151,    95,    96,     8,    97,   152,    30,   119,   163,
     162,   196,    81,   176,     1,   121,    36,   106,    37,    38,
     198,   168,   117,   115,    39,    40,    41,    42,    43,    44,
      45,    46,   107,     7,   168,    48,   109,    49,    50,   188,
      51,    -4,    91,    93,     1,   126,   197,     2,   204,  -126,
    -132,   -51,   157,  -129,  -129,  -129,  -129,   176,    36,   119,
      37,    38,   127,   128,   131,   156,    39,    40,    41,    42,
      43,    44,    45,    46,   -51,   140,    47,    48,   -51,    49,
      50,   -51,    51,   -51,   100,   129,   161,   183,   166,   130,
    -119,   184,  -119,  -119,  -126,  -119,   113,  -127,  -119,  -119,
    -119,  -119,  -119,  -119,  -119,  -119,   205,   206,  -119,  -119,
      34,  -119,  -119,  -119,  -119,  -126,   101,    -3,    19,  -129,
    -129,  -129,  -129,    35,   -38,   182,   -38,   -38,    13,    20,
     125,   158,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,
     -38,   104,   -38,   -38,    98,   -38,   -38,    36,   -38,    37,
      38,   181,   159,   111,   186,    39,    40,    41,    42,    43,
      44,    45,    46,    99,   178,    47,    48,    19,    49,    50,
     202,    51,   -43,   -38,   203,   -38,   -38,   201,    20,   120,
     200,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,   -38,
     187,   -38,   -38,     0,   -38,   -38,   -38,   -38,   -38,   -38,
       0,    20,     0,     0,   -38,   -38,   -38,   -38,   -38,   -38,
     -38,   -38,     0,    92,   -38,   -38,   -38,   -38,   -38,    36,
     -38,    37,    38,     0,     0,     0,     0,    39,    40,    41,
      42,    43,    44,    45,    46,     0,   132,     0,    48,     0,
      49,    50,   133,    51,    37,    38,     0,     0,     0,     0,
      39,    40,    41,    42,    43,    44,    45,    46,     0,     0,
       0,    94,   134,    49,    96,    36,     0,    37,    38,     0,
       0,     0,     0,    39,    40,    41,    42,    43,    44,    45,
      46,     0,     0,    47,    48,     0,    49,    50,   133,    51,
      37,    38,     0,     0,     0,     0,    39,    40,    41,    42,
      43,    44,    45,    46,     0,     0,     0,    94,   185,    49,
      96,  -127,  -133,     0,     0,  -130,  -130,  -130,  -130,  -127,
       0,     0,     0,  -130,  -130,  -130,  -130,  -136,     0,     0,
    -131,  -131,  -131,  -131,     9,    10,    11,    12,  -131,  -131,
    -131,  -131
};

static const short yycheck[] =
{
      17,    51,    18,    14,    20,    57,    55,    73,    75,    96,
     118,   119,    28,   121,   119,   118,   119,    33,   121,    94,
     118,   119,     1,    23,     4,     8,     4,     5,     1,    16,
      30,    14,    82,    23,     7,     8,   103,    16,    11,    12,
      13,    14,    32,    30,     0,    97,    23,    23,   115,   115,
      23,    30,    32,    30,     7,   163,    32,     1,   145,    12,
     163,    78,   137,     7,    81,   163,   118,   119,   176,   121,
      12,   176,     7,   176,    11,    12,    13,    14,   176,     7,
       4,     5,     7,     8,    12,   101,    11,    12,    13,    14,
      26,   102,    28,    29,     8,    31,    33,    23,   115,   166,
     166,   151,    13,   120,     3,   122,     7,    23,     9,    10,
     159,   163,   178,    34,    15,    16,    17,    18,    19,    20,
      21,    22,    24,     7,   176,    26,    24,    28,    29,   140,
      31,     0,    47,    48,     3,    23,   152,     6,   188,     7,
       8,     0,     1,    11,    12,    13,    14,   164,     7,   166,
       9,    10,    23,    23,    27,    32,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    26,    25,    26,    27,    28,
      29,    30,    31,    32,     1,    23,     7,    23,    34,    27,
       7,    27,     9,    10,     7,    12,     4,     7,    15,    16,
      17,    18,    19,    20,    21,    22,    30,    27,    25,    26,
      21,    28,    29,    30,    31,     7,    33,     0,     1,    11,
      12,    13,    14,    23,     7,   128,     9,    10,     4,    12,
      83,   107,    15,    16,    17,    18,    19,    20,    21,    22,
      23,     1,    25,    26,    49,    28,    29,     7,    31,     9,
      10,   122,   107,    57,   137,    15,    16,    17,    18,    19,
      20,    21,    22,    49,   121,    25,    26,     1,    28,    29,
      23,    31,    32,     7,    27,     9,    10,   176,    12,    78,
     166,    15,    16,    17,    18,    19,    20,    21,    22,    23,
       1,    25,    26,    -1,    28,    29,     7,    31,     9,    10,
      -1,    12,    -1,    -1,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,     1,    25,    26,    27,    28,    29,     7,
      31,     9,    10,    -1,    -1,    -1,    -1,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,     1,    -1,    26,    -1,
      28,    29,     7,    31,     9,    10,    -1,    -1,    -1,    -1,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    -1,
      -1,    26,    27,    28,    29,     7,    -1,     9,    10,    -1,
      -1,    -1,    -1,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    -1,    25,    26,    -1,    28,    29,     7,    31,
       9,    10,    -1,    -1,    -1,    -1,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    -1,    -1,    26,    27,    28,
      29,     7,     8,    -1,    -1,    11,    12,    13,    14,     7,
      -1,    -1,    -1,    11,    12,    13,    14,     8,    -1,    -1,
      11,    12,    13,    14,    11,    12,    13,    14,    11,    12,
      13,    14
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
      95,    49,    53,    54,    57,    52,    23,    23,    23,    23,
      27,    27,     1,     7,    27,    67,    74,    75,    76,    77,
      26,    81,     1,    30,    69,    78,     1,    66,    23,    30,
      47,    55,    33,    46,    23,    32,    32,     1,    60,    61,
       5,     7,    45,    46,    95,    98,    34,    65,    66,    88,
      90,    65,    88,    90,    91,    93,    49,    65,    87,    88,
      14,    54,    42,    23,    27,    27,    76,     1,    55,    23,
      30,    30,    69,    23,    32,    32,    57,    47,    59,    90,
      98,    93,    23,    27,    57,    30,    27
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
		  yyval.node = yyvsp[0].node;
		}
    break;

  case 36:
#line 279 "gst-parse.y"
    {
		  if (yyvsp[-1].node && yyvsp[0].node)
		    _gst_add_node (yyvsp[-1].node, yyvsp[0].node);

		  yyval.node = yyvsp[-1].node ? yyvsp[-1].node : yyvsp[0].node; 
		}
    break;

  case 37:
#line 291 "gst-parse.y"
    {
		  if (yyvsp[0].node
		      && yyvsp[0].node->nodeType == TREE_CONST_EXPR
		      && !_gst_had_error)
		    yyval.node = _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node);
		  else if (yyvsp[0].node
			   && !_gst_had_error)
		    {
		      tree_node stmt = _gst_make_statement_list (&yyloc, yyvsp[0].node); 
		      OOP result = _gst_execute_statements (NULL, stmt, true);
		      tree_node arg = _gst_make_oop_constant (&yyloc, result); 
		      _gst_had_error = !result;
		      yyval.node = _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, arg);
		    }
		  else
		    yyval.node = NULL;
		}
    break;

  case 38:
#line 314 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 39:
#line 318 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 40:
#line 322 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 41:
#line 329 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 42:
#line 333 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-1].node, _gst_make_variable_list (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 43:
#line 343 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 44:
#line 347 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node;
		}
    break;

  case 45:
#line 351 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node;
		}
    break;

  case 46:
#line 355 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-3].node, yyvsp[-1].node);
		  yyval.node = yyvsp[-3].node;
		}
    break;

  case 47:
#line 363 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 48:
#line 367 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, yyvsp[0].node); 
		  yyval.node = yyvsp[-2].node;
		}
    break;

  case 49:
#line 372 "gst-parse.y"
    {
		  yyval.node = yyvsp[-2].node;
		  yyerrok;
		  _gst_had_error = true;
		}
    break;

  case 52:
#line 386 "gst-parse.y"
    {
		  yyval.node = _gst_make_statement_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 53:
#line 393 "gst-parse.y"
    {
		  yyval.node = _gst_make_statement_list (&yyloc,
						_gst_make_return (&yyloc, yyvsp[0].node));
		}
    break;

  case 55:
#line 404 "gst-parse.y"
    {
		  yyval.node = _gst_make_assign (&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 56:
#line 411 "gst-parse.y"
    {
		  yyval.node = _gst_make_assignment_list (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 57:
#line 415 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_assignment_list (&yyloc, yyvsp[-1].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 65:
#line 435 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 66:
#line 442 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 67:
#line 448 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 68:
#line 455 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable (&yyloc, yyvsp[0].sval); 
		}
    break;

  case 69:
#line 459 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_variable (&yyloc, yyvsp[0].sval)); 
		}
    break;

  case 78:
#line 477 "gst-parse.y"
    {
		  yyval.node = _gst_make_int_constant (&yyloc, yyvsp[0].ival); 
		}
    break;

  case 79:
#line 481 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant (&yyloc, yyvsp[0].fval, CONST_FLOATD); 
		}
    break;

  case 80:
#line 485 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant (&yyloc, yyvsp[0].fval, CONST_FLOATE); 
		}
    break;

  case 81:
#line 489 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant (&yyloc, yyvsp[0].fval, CONST_FLOATQ); 
		}
    break;

  case 82:
#line 493 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_object_constant (&yyloc, yyvsp[0].boval); 
		}
    break;

  case 83:
#line 497 "gst-parse.y"
    {
		  yyval.node = _gst_make_oop_constant (&yyloc, yyvsp[0].oval); 
		}
    break;

  case 84:
#line 504 "gst-parse.y"
    {
		  yyval.node = _gst_make_int_constant (&yyloc, yyvsp[0].ival); 
		}
    break;

  case 85:
#line 511 "gst-parse.y"
    {
		  yyval.node = _gst_make_symbol_constant (&yyloc, _gst_intern_ident (&yyloc, yyvsp[0].sval)); 
		}
    break;

  case 86:
#line 518 "gst-parse.y"
    {
		  yyval.node = _gst_make_char_constant (&yyloc, yyvsp[0].cval); 
		}
    break;

  case 87:
#line 525 "gst-parse.y"
    {
		  yyval.node = _gst_make_string_constant (&yyloc, yyvsp[0].sval); 
		}
    break;

  case 88:
#line 534 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 89:
#line 538 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 90:
#line 545 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constant (&yyloc, NULL); 
		}
    break;

  case 91:
#line 549 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 92:
#line 556 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 93:
#line 562 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constant (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 94:
#line 569 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_elt (&yyloc, yyvsp[0].node); 
		}
    break;

  case 95:
#line 573 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-1].node, _gst_make_array_elt (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 99:
#line 584 "gst-parse.y"
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
#line 603 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_array_constant (&yyloc, NULL); 
		}
    break;

  case 101:
#line 607 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 102:
#line 614 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 103:
#line 620 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_array_constant (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 104:
#line 627 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_elt (&yyloc, yyvsp[0].node); 
		}
    break;

  case 105:
#line 631 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-1].node, _gst_make_array_elt (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 106:
#line 641 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 107:
#line 648 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 108:
#line 655 "gst-parse.y"
    {
		  yyval.node = _gst_make_binding_constant (&yyloc, yyvsp[-1].node); 
		  if (!yyval.node) {
		    _gst_errorf ("invalid variable binding");
		    YYERROR;
		  }
		}
    break;

  case 109:
#line 668 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node;
		}
    break;

  case 110:
#line 675 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = _gst_make_oop_constant (&yyloc, _gst_nil_oop); 
		}
    break;

  case 111:
#line 682 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = _gst_make_oop_constant (&yyloc, _gst_nil_oop); 
		}
    break;

  case 112:
#line 688 "gst-parse.y"
    {
		  OOP result = _gst_nil_oop;
		  if (yyvsp[-1].node && !_gst_had_error)
		    result = _gst_execute_statements (yyvsp[-2].node, yyvsp[-1].node, true);

		  yyval.node = _gst_make_oop_constant (&yyloc,
					       result ? result : _gst_nil_oop); 
		}
    break;

  case 113:
#line 702 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 114:
#line 709 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 115:
#line 715 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constructor (&yyloc, yyvsp[-1].node); 
		}
    break;

  case 116:
#line 724 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 117:
#line 731 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 118:
#line 737 "gst-parse.y"
    {
		  yyval.node = _gst_make_block (&yyloc, yyvsp[-3].node, yyvsp[-2].node, yyvsp[-1].node); 
		}
    break;

  case 119:
#line 744 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 120:
#line 748 "gst-parse.y"
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
#line 760 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 122:
#line 764 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_variable_list (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 128:
#line 785 "gst-parse.y"
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
#line 810 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr (&yyloc, yyvsp[-2].node, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 139:
#line 829 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr (&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 140:
#line 836 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 141:
#line 840 "gst-parse.y"
    {
		   _gst_add_node (yyvsp[-2].node, _gst_make_keyword_list (&yyloc, yyvsp[-1].sval, yyvsp[0].node));
		   yyval.node = yyvsp[-2].node; 
		}
    break;

  case 142:
#line 850 "gst-parse.y"
    {
		  yyval.node = _gst_make_cascaded_message (&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 143:
#line 857 "gst-parse.y"
    {
		  yyval.node = _gst_make_message_list (&yyloc, yyvsp[0].node); 
		}
    break;

  case 144:
#line 861 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-2].node, _gst_make_message_list (&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 145:
#line 869 "gst-parse.y"
    {
		   yyval.node = _gst_make_unary_expr (&yyloc, NULL, yyvsp[0].sval); 
		}
    break;

  case 146:
#line 873 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr (&yyloc, NULL, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 147:
#line 877 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr (&yyloc, NULL, yyvsp[0].node); 
		}
    break;


    }

/* Line 991 of yacc.c.  */
#line 2118 "../../libgst/gst-parse.c"

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
  if (0) goto yyerrlab1;
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


#line 883 "gst-parse.y"

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

