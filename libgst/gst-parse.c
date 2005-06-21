/* A Bison parser, made from /home/utente/devel-gst-stable/libgst/gst-parse.y, by GNU bison 1.49b.  */

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
   Boston, MA 02110-1301, USA.  */

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
#define YYBISON	1

/* Pure parsers.  */
#define YYPURE	1

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

/* Copy the first part of user declarations.  */
#line 31 "gst-parse.y"

#include "gst.h"
#include "gstpriv.h"
#include <stdio.h>
#if defined(STDC_HEADERS)
#include <string.h>
#endif

#define YYPRINT(file, type, value)   _gst_yyprint (file, type, &value)

#define YYERROR_VERBOSE 1

static inline mst_Boolean           is_unlikely_selector (register const char *str);


/* Tokens.  */
#ifndef YYTOKENTYPE
# if defined (__STDC__) || defined (__cplusplus)
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     PRIMITIVE_START = 258,
     INTERNAL_TOKEN = 259,
     SCOPE_SEPARATOR = 260,
     ASSIGNMENT = 261,
     IDENTIFIER = 262,
     KEYWORD = 263,
     STRING_LITERAL = 264,
     SYMBOL_KEYWORD = 265,
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
# endif
  /* POSIX requires `int' for tokens in interfaces.  */
# define YYTOKENTYPE int
#endif /* !YYTOKENTYPE */
#define PRIMITIVE_START 258
#define INTERNAL_TOKEN 259
#define SCOPE_SEPARATOR 260
#define ASSIGNMENT 261
#define IDENTIFIER 262
#define KEYWORD 263
#define STRING_LITERAL 264
#define SYMBOL_KEYWORD 265
#define BINOP 266
#define INTEGER_LITERAL 267
#define BYTE_LITERAL 268
#define FLOATD_LITERAL 269
#define FLOATE_LITERAL 270
#define FLOATQ_LITERAL 271
#define CHAR_LITERAL 272
#define SCALED_DECIMAL_LITERAL 273
#define LARGE_INTEGER_LITERAL 274




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

#ifndef YYSTYPE
#line 52 "gst-parse.y"
typedef union {
  char		cval;
  long double	fval;
  long		ival;
  char		*sval;
  byte_object	boval;
  OOP		oval;
  tree_node	node;
} yystype;
/* Line 188 of /usr/share/bison/yacc.c.  */
#line 148 "gst-parse.c"
# define YYSTYPE yystype
# define YYSTYPE_IS_TRIVIAL 1
#endif

#ifndef YYLTYPE
typedef struct yyltype
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} yyltype;
# define YYLTYPE yyltype
# define YYLTYPE_IS_TRIVIAL 1
#endif

/* Copy the second part of user declarations.  */


/* Line 208 of /usr/share/bison/yacc.c.  */
#line 169 "gst-parse.c"

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
# define YYSTACK_GAP_MAX (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE) + sizeof (YYLTYPE))	\
      + 2 * YYSTACK_GAP_MAX)

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
	    (To)[yyi] = (From)[yyi];	\
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
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAX;	\
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  15
#define YYLAST   434

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  33
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  58
/* YYNRULES -- Number of rules. */
#define YYNRULES  136
/* YYNRULES -- Number of states. */
#define YYNSTATES  195

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   274

#define YYTRANSLATE(X) \
  ((unsigned)(X) <= YYMAXUTOK ? yytranslate[X] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    21,     2,    26,     2,     2,     2,     2,
      24,    25,     2,     2,     2,     2,    22,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    31,    32,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    27,     2,    28,    23,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    29,    12,    30,     2,     2,     2,     2,
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
       5,     6,     7,     8,     9,    10,    11,    13,    14,    15,
      16,    17,    18,    19,    20
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned short yyprhs[] =
{
       0,     0,     3,     6,     8,     9,    11,    13,    16,    18,
      23,    27,    30,    34,    37,    38,    43,    45,    48,    50,
      52,    54,    56,    58,    61,    65,    67,    68,    72,    74,
      75,    78,    82,    84,    87,    88,    91,    94,    99,   101,
     105,   109,   110,   112,   114,   117,   119,   122,   125,   129,
     131,   133,   135,   137,   139,   141,   143,   147,   151,   155,
     157,   161,   163,   165,   167,   169,   171,   173,   175,   177,
     179,   181,   183,   185,   187,   189,   191,   194,   197,   199,
     201,   203,   205,   207,   209,   212,   215,   218,   222,   226,
     230,   232,   235,   237,   239,   241,   243,   246,   250,   254,
     258,   260,   263,   268,   273,   278,   282,   286,   290,   295,
     299,   303,   307,   311,   315,   321,   322,   325,   328,   332,
     334,   336,   338,   341,   343,   345,   349,   351,   353,   356,
     359,   363,   366,   369,   373,   375,   378
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const signed char yyrhs[] =
{
      34,     0,    -1,    35,    40,    -1,    36,    -1,    -1,     4,
      -1,    37,    -1,    36,    37,    -1,    38,    -1,    38,    35,
      39,    21,    -1,    49,    51,    21,    -1,     1,    21,    -1,
      40,    21,    39,    -1,     1,    21,    -1,    -1,    41,    49,
      47,    51,    -1,    42,    -1,    43,    44,    -1,    45,    -1,
       7,    -1,    11,    -1,    12,    -1,     7,    -1,    46,    44,
      -1,    45,    46,    44,    -1,     8,    -1,    -1,     3,     7,
      48,    -1,    11,    -1,    -1,    12,    12,    -1,    12,    50,
      12,    -1,    44,    -1,    50,    44,    -1,    -1,    55,    53,
      -1,    52,    53,    -1,    52,    22,    55,    53,    -1,    54,
      -1,    52,    22,    54,    -1,    52,    22,     1,    -1,    -1,
      22,    -1,    56,    -1,    23,    56,    -1,    58,    -1,    57,
      58,    -1,    60,     6,    -1,    57,    60,     6,    -1,    59,
      -1,    81,    -1,    88,    -1,    60,    -1,    61,    -1,    78,
      -1,    77,    -1,    24,     1,    21,    -1,    24,     1,    25,
      -1,    24,    56,    25,    -1,     7,    -1,    60,     5,     7,
      -1,    62,    -1,    63,    -1,    64,    -1,    66,    -1,    67,
      -1,    68,    -1,    74,    -1,    75,    -1,    13,    -1,    15,
      -1,    16,    -1,    17,    -1,    20,    -1,    19,    -1,    14,
      -1,    26,    65,    -1,    26,     9,    -1,     7,    -1,    43,
      -1,    10,    -1,     8,    -1,    18,    -1,     9,    -1,    26,
      69,    -1,    26,    72,    -1,    24,    25,    -1,    24,     1,
      21,    -1,    24,     1,    25,    -1,    24,    70,    25,    -1,
      71,    -1,    70,    71,    -1,    69,    -1,    72,    -1,    61,
      -1,    65,    -1,    27,    28,    -1,    27,     1,    21,    -1,
      27,     1,    28,    -1,    27,    73,    28,    -1,    63,    -1,
      73,    63,    -1,    26,    29,     1,    21,    -1,    26,    29,
       1,    30,    -1,    26,    29,    60,    30,    -1,    26,    26,
      76,    -1,    24,     1,    21,    -1,    24,     1,    25,    -1,
      24,    49,    51,    25,    -1,    29,     1,    21,    -1,    29,
       1,    30,    -1,    29,    51,    30,    -1,    27,     1,    21,
      -1,    27,     1,    28,    -1,    27,    79,    49,    51,    28,
      -1,    -1,    80,    43,    -1,    31,    44,    -1,    80,    31,
      44,    -1,    82,    -1,    84,    -1,    86,    -1,    83,    42,
      -1,    59,    -1,    82,    -1,    85,    43,    83,    -1,    83,
      -1,    84,    -1,    85,    87,    -1,    46,    85,    -1,    87,
      46,    85,    -1,    81,    89,    -1,    32,    90,    -1,    89,
      32,    90,    -1,    42,    -1,    43,    83,    -1,    87,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   103,   103,   105,   106,   109,   116,   118,   121,   123,
     131,   141,   148,   152,   157,   160,   174,   179,   183,   189,
     193,   195,   198,   205,   210,   217,   221,   226,   232,   238,
     243,   247,   253,   258,   265,   270,   274,   278,   285,   290,
     295,   303,   305,   308,   315,   323,   325,   331,   336,   343,
     345,   346,   349,   351,   352,   353,   354,   361,   367,   373,
     378,   384,   386,   387,   388,   389,   390,   391,   392,   395,
     400,   404,   408,   412,   416,   422,   429,   434,   440,   445,
     449,   453,   460,   467,   474,   479,   485,   490,   497,   503,
     509,   514,   521,   523,   524,   525,   541,   546,   553,   559,
     565,   570,   577,   585,   591,   602,   609,   617,   623,   633,
     641,   647,   653,   661,   667,   673,   678,   692,   697,   704,
     706,   707,   710,   721,   723,   726,   733,   735,   738,   745,
     750,   758,   765,   770,   777,   782,   786
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "\"<primitive: ...>\"", "INTERNAL_TOKEN", 
  "\"'.' or '::'\"", "\"'_' or ':='\"", "\"identifier\"", 
  "\"keyword message\"", "\"string literal\"", "\"symbol literal\"", 
  "\"binary message\"", "'|'", "\"integer literal\"", "BYTE_LITERAL", 
  "\"floating-point literal\"", "FLOATE_LITERAL", "FLOATQ_LITERAL", 
  "\"character literal\"", "\"scaled decimal literal\"", 
  "LARGE_INTEGER_LITERAL", "'!'", "'.'", "'^'", "'('", "')'", "'#'", 
  "'['", "']'", "'{'", "'}'", "':'", "';'", "$accept", "program", 
  "internal_marker", "file_in", "doit_and_method_list", "doit", 
  "method_list", "method", "message_pattern", "unary_selector", 
  "binary_selector", "variable_name", "keyword_variable_list", "keyword", 
  "primitive", "primitive_end", "temporaries", "variable_names", 
  "statements", "statements.1", "optional_dot", "statement", 
  "return_statement", "expression", "assigns", "simple_expression", 
  "primary", "variable_primary", "literal", "number", "small_number", 
  "symbol_constant", "symbol", "character_constant", "string", 
  "array_constant", "array", "array_constant_list", "array_constant_elt", 
  "byte_array", "byte_array_constant_list", "variable_binding", 
  "compile_time_constant", "compile_time_constant_body", 
  "array_constructor", "block", "opt_block_variables", 
  "block_variable_list", "message_expression", "unary_expression", 
  "unary_object_description", "binary_expression", 
  "binary_object_description", "keyword_expression", 
  "keyword_binary_object_description_list", "cascaded_message_expression", 
  "semi_message_list", "message_elt", 0
};
#endif

/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   124,   267,   268,   269,   270,   271,   272,   273,
     274,    33,    46,    94,    40,    41,    35,    91,    93,   123,
     125,    58,    59
};

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    33,    34,    34,    34,    35,    36,    36,    37,    37,
      38,    38,    39,    39,    39,    40,    41,    41,    41,    42,
      43,    43,    44,    45,    45,    46,    47,    47,    48,    49,
      49,    49,    50,    50,    51,    51,    51,    51,    52,    52,
      52,    53,    53,    54,    55,    56,    56,    57,    57,    58,
      58,    58,    59,    59,    59,    59,    59,    59,    59,    60,
      60,    61,    61,    61,    61,    61,    61,    61,    61,    62,
      62,    62,    62,    62,    62,    63,    64,    64,    65,    65,
      65,    65,    66,    67,    68,    68,    69,    69,    69,    69,
      70,    70,    71,    71,    71,    71,    72,    72,    72,    72,
      73,    73,    74,    74,    74,    75,    76,    76,    76,    77,
      77,    77,    78,    78,    78,    79,    79,    80,    80,    81,
      81,    81,    82,    83,    83,    84,    85,    85,    86,    87,
      87,    88,    89,    89,    90,    90,    90
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     2,     1,     0,     1,     1,     2,     1,     4,
       3,     2,     3,     2,     0,     4,     1,     2,     1,     1,
       1,     1,     1,     2,     3,     1,     0,     3,     1,     0,
       2,     3,     1,     2,     0,     2,     2,     4,     1,     3,
       3,     0,     1,     1,     2,     1,     2,     2,     3,     1,
       1,     1,     1,     1,     1,     1,     3,     3,     3,     1,
       3,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     2,     2,     1,     1,
       1,     1,     1,     1,     2,     2,     2,     3,     3,     3,
       1,     2,     1,     1,     1,     1,     2,     3,     3,     3,
       1,     2,     4,     4,     4,     3,     3,     3,     4,     3,
       3,     3,     3,     3,     5,     0,     2,     2,     3,     1,
       1,     1,     2,     1,     1,     3,     1,     1,     2,     2,
       3,     2,     2,     3,     1,     2,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
       0,     0,     5,     0,     0,     0,     0,     6,     8,    34,
      11,    22,    30,    32,     0,     1,    19,    25,    20,    21,
       2,    29,    16,     0,    18,     0,     7,     0,    59,    83,
      69,    75,    70,    71,    72,    82,    74,    73,     0,     0,
       0,     0,     0,     0,    41,    38,    41,    43,     0,    45,
      49,    52,    53,    61,    62,    63,    64,    65,    66,    67,
      68,    55,    54,    50,   119,   126,   120,     0,   121,    51,
      31,    33,    26,    17,     0,    23,     0,     0,     0,    44,
       0,     0,    78,    81,    77,    80,     0,     0,     0,     0,
      79,    76,    84,    85,     0,     0,    29,     0,     0,     0,
      10,     0,    36,    42,    35,    46,    52,     0,    47,     0,
     131,   122,     0,     0,   128,     0,    34,    24,    13,     9,
       0,    56,    57,    58,     0,    86,    94,    95,    92,     0,
      90,    93,     0,   105,     0,    96,   100,     0,     0,     0,
     112,   113,   117,    34,     0,   116,   109,   110,   111,    40,
      39,    41,    48,    60,   134,     0,   136,   132,     0,   123,
      52,   124,   125,   127,   129,     0,     0,    15,    12,    87,
      88,    89,    91,     0,    34,    97,    98,    99,   101,   102,
     103,   104,     0,   118,    37,   135,   133,   130,    28,    27,
     106,   107,     0,   114,   108
};

/* YYDEFGOTO[NTERM-NUM]. */
static const short yydefgoto[] =
{
      -1,     4,     5,     6,     7,     8,    77,    78,    21,    22,
      23,    13,    24,    25,   116,   189,     9,    14,    43,    44,
     102,    45,    46,    47,    48,    49,    50,    51,    52,    53,
      54,    55,   127,    56,    57,    58,   128,   129,   130,   131,
     137,    59,    60,   133,    61,    62,    96,    97,    63,    64,
      65,    66,    67,    68,   156,    69,   110,   157
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -107
static const short yypact[] =
{
     199,    22,  -107,    24,    55,    68,   229,  -107,    63,   340,
    -107,  -107,  -107,  -107,    59,  -107,  -107,  -107,  -107,  -107,
    -107,    65,  -107,    75,    77,    75,  -107,    18,  -107,  -107,
    -107,  -107,  -107,  -107,  -107,  -107,  -107,  -107,   361,   295,
     384,   167,   250,    69,    70,  -107,    79,  -107,   361,  -107,
      86,    27,  -107,  -107,  -107,  -107,  -107,  -107,  -107,  -107,
    -107,  -107,  -107,    72,    95,   118,    76,   100,  -107,  -107,
    -107,  -107,   124,  -107,    75,  -107,   107,   110,   113,  -107,
      31,   104,  -107,  -107,  -107,  -107,   319,   106,    20,    34,
    -107,  -107,  -107,  -107,    33,    75,    65,    11,     7,   111,
    -107,   137,  -107,  -107,  -107,  -107,   109,   132,  -107,    68,
     116,  -107,   361,   361,    77,   133,   340,  -107,  -107,  -107,
      18,  -107,  -107,  -107,    74,  -107,  -107,  -107,  -107,   407,
    -107,  -107,   274,  -107,    44,  -107,  -107,    10,    19,    15,
    -107,  -107,  -107,   340,    75,  -107,  -107,  -107,  -107,  -107,
    -107,    79,  -107,  -107,  -107,   361,    77,  -107,    68,  -107,
     138,  -107,   118,  -107,   108,   361,   131,  -107,  -107,  -107,
    -107,  -107,  -107,    88,   340,  -107,  -107,  -107,  -107,  -107,
    -107,  -107,   117,  -107,  -107,   118,  -107,   108,  -107,  -107,
    -107,  -107,   134,  -107,  -107
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -107,  -107,   141,  -107,   163,  -107,    50,   166,  -107,   -62,
     -40,   -12,  -107,   -23,  -107,  -107,   -15,  -107,   -38,  -107,
     -41,    71,    87,    83,  -107,   125,   -97,   -39,   -78,  -107,
     -74,  -107,   135,  -107,  -107,  -107,   149,  -107,    48,   152,
    -107,  -107,  -107,  -107,  -107,  -107,  -107,  -107,  -107,   -95,
    -102,  -106,  -101,  -107,   130,  -107,  -107,    43
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.  */
#define YYTABLE_NINF -108
static const short yytable[] =
{
      90,    74,    71,   111,    99,   104,    72,   163,   126,   106,
     162,    73,   164,    75,   136,   159,   159,   161,   161,    76,
     107,   134,    18,    19,    31,    16,    17,   112,   146,    18,
      19,    11,   107,   108,    31,   138,    12,   147,   177,   -14,
     179,    28,   144,    10,   113,   181,    90,   154,   135,   180,
     139,   126,   121,   185,   140,    15,   122,   145,   159,   163,
     161,   141,   117,   178,   187,   175,    11,     2,   159,   155,
     161,    70,   176,   160,   160,    16,    17,     3,   167,    18,
      19,   143,    11,   142,  -127,    17,   113,  -127,  -127,    90,
     100,   165,   101,  -123,  -123,   169,   154,  -123,  -123,   170,
     111,   103,  -124,  -124,   109,   182,  -124,  -124,    17,   190,
     184,    18,    19,   191,   107,   152,   160,   174,   155,    18,
      19,    79,    81,   111,   112,    16,   160,   115,   118,   123,
     132,   119,   183,   165,   120,   113,   192,   -42,   149,   153,
     166,   148,   188,   107,    28,   193,    29,   112,   158,    27,
      30,    31,    32,    33,    34,    35,    36,    37,   -42,   194,
      38,    39,   -42,    40,    41,   -42,    42,   -42,    94,    26,
     168,    20,   150,   105,  -115,    91,  -115,   172,     0,  -115,
    -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,   151,    92,
    -115,  -115,    93,  -115,  -115,  -115,  -115,   114,    95,    -4,
       1,   186,     0,     2,     0,     0,   -29,     0,   -29,     0,
       0,     3,   -29,   -29,   -29,   -29,   -29,   -29,   -29,   -29,
     -29,     0,   -29,   -29,     0,   -29,   -29,     0,   -29,    -3,
       1,     0,     0,     0,     0,     0,   -29,     0,   -29,     0,
       0,     3,   -29,   -29,   -29,   -29,   -29,   -29,   -29,   -29,
     -29,    98,   -29,   -29,     0,   -29,   -29,    28,   -29,    29,
       0,     0,     0,    30,    31,    32,    33,    34,    35,    36,
      37,     0,     0,    38,    39,   173,    40,    41,     0,    42,
     -34,   -29,     0,   -29,     0,     0,     3,   -29,   -29,   -29,
     -29,   -29,   -29,   -29,   -29,     0,    80,   -29,   -29,   -29,
     -29,   -29,    28,   -29,    29,     0,     0,     0,    30,    31,
      32,    33,    34,    35,    36,    37,     0,     0,     0,    39,
     124,    40,    41,     0,    42,     0,    82,    83,    29,    85,
      18,    19,    30,    31,    32,    33,    34,    35,    36,    37,
       0,     0,     0,    86,   125,    40,    88,    28,     0,    29,
       0,     0,     0,    30,    31,    32,    33,    34,    35,    36,
      37,     0,     0,    38,    39,     0,    40,    41,    28,    42,
      29,     0,     0,     0,    30,    31,    32,    33,    34,    35,
      36,    37,     0,     0,     0,    39,     0,    40,    41,     0,
      42,    82,    83,    84,    85,    18,    19,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    86,     0,
      87,    88,     0,    89,    82,    83,    29,    85,    18,    19,
      30,    31,    32,    33,    34,    35,    36,    37,     0,     0,
       0,    86,   171,    40,    88
};

static const short yycheck[] =
{
      40,    24,    14,    65,    42,    46,    21,   113,    86,    48,
     112,    23,   113,    25,    88,   112,   113,   112,   113,     1,
       5,     1,    11,    12,    14,     7,     8,    67,    21,    11,
      12,     7,     5,     6,    14,     1,    12,    30,    28,    21,
      21,     7,    31,    21,    67,    30,    86,   109,    28,    30,
      89,   129,    21,   155,    21,     0,    25,    97,   155,   165,
     155,    28,    74,   137,   165,    21,     7,     4,   165,   109,
     165,    12,    28,   112,   113,     7,     8,    12,   116,    11,
      12,    96,     7,    95,     8,     8,   109,    11,    12,   129,
      21,   114,    22,     7,     8,    21,   158,    11,    12,    25,
     162,    22,     7,     8,    32,   143,    11,    12,     8,    21,
     151,    11,    12,    25,     5,     6,   155,   132,   158,    11,
      12,    38,    39,   185,   164,     7,   165,     3,    21,    25,
      24,    21,   144,   156,    21,   158,   174,     0,     1,     7,
       7,    30,    11,     5,     7,    28,     9,   187,    32,     8,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    25,
      23,    24,    25,    26,    27,    28,    29,    30,     1,     6,
     120,     5,   101,    48,     7,    40,     9,   129,    -1,    12,
      13,    14,    15,    16,    17,    18,    19,    20,   101,    40,
      23,    24,    40,    26,    27,    28,    29,    67,    31,     0,
       1,   158,    -1,     4,    -1,    -1,     7,    -1,     9,    -1,
      -1,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    -1,    23,    24,    -1,    26,    27,    -1,    29,     0,
       1,    -1,    -1,    -1,    -1,    -1,     7,    -1,     9,    -1,
      -1,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,     1,    23,    24,    -1,    26,    27,     7,    29,     9,
      -1,    -1,    -1,    13,    14,    15,    16,    17,    18,    19,
      20,    -1,    -1,    23,    24,     1,    26,    27,    -1,    29,
      30,     7,    -1,     9,    -1,    -1,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    -1,     1,    23,    24,    25,
      26,    27,     7,    29,     9,    -1,    -1,    -1,    13,    14,
      15,    16,    17,    18,    19,    20,    -1,    -1,    -1,    24,
       1,    26,    27,    -1,    29,    -1,     7,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      -1,    -1,    -1,    24,    25,    26,    27,     7,    -1,     9,
      -1,    -1,    -1,    13,    14,    15,    16,    17,    18,    19,
      20,    -1,    -1,    23,    24,    -1,    26,    27,     7,    29,
       9,    -1,    -1,    -1,    13,    14,    15,    16,    17,    18,
      19,    20,    -1,    -1,    -1,    24,    -1,    26,    27,    -1,
      29,     7,     8,     9,    10,    11,    12,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    24,    -1,
      26,    27,    -1,    29,     7,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    -1,    -1,
      -1,    24,    25,    26,    27
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     1,     4,    12,    34,    35,    36,    37,    38,    49,
      21,     7,    12,    44,    50,     0,     7,     8,    11,    12,
      40,    41,    42,    43,    45,    46,    37,    35,     7,     9,
      13,    14,    15,    16,    17,    18,    19,    20,    23,    24,
      26,    27,    29,    51,    52,    54,    55,    56,    57,    58,
      59,    60,    61,    62,    63,    64,    66,    67,    68,    74,
      75,    77,    78,    81,    82,    83,    84,    85,    86,    88,
      12,    44,    49,    44,    46,    44,     1,    39,    40,    56,
       1,    56,     7,     8,     9,    10,    24,    26,    27,    29,
      43,    65,    69,    72,     1,    31,    79,    80,     1,    51,
      21,    22,    53,    22,    53,    58,    60,     5,     6,    32,
      89,    42,    43,    46,    87,     3,    47,    44,    21,    21,
      21,    21,    25,    25,     1,    25,    61,    65,    69,    70,
      71,    72,    24,    76,     1,    28,    63,    73,     1,    60,
      21,    28,    44,    49,    31,    43,    21,    30,    30,     1,
      54,    55,     6,     7,    42,    43,    87,    90,    32,    59,
      60,    82,    83,    84,    85,    46,     7,    51,    39,    21,
      25,    25,    71,     1,    49,    21,    28,    28,    63,    21,
      30,    30,    51,    44,    53,    83,    90,    85,    11,    48,
      21,    25,    51,    28,    25
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
#define YYEMPTY		-2
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
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");			\
      YYERROR;							\
    }								\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)           \
  Current.first_line   = Rhs[1].first_line;      \
  Current.first_column = Rhs[1].first_column;    \
  Current.last_line    = Rhs[N].last_line;       \
  Current.last_column  = Rhs[N].last_column;
#endif

/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX	yylex (&yylval, &yylloc, YYLEX_PARAM)
#else
# define YYLEX	yylex (&yylval, &yylloc)
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
/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YYDSYMPRINT(Args)
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
/*-----------------------------.
| Print this symbol on YYOUT.  |
`-----------------------------*/

static void
#if defined (__STDC__) || defined (__cplusplus)
yysymprint (FILE* yyout, int yytype, YYSTYPE yyvalue, YYLTYPE yylocation)
#else
yysymprint (yyout, yytype, yyvalue, yylocation)
    FILE* yyout;
    int yytype;
    YYSTYPE yyvalue;
    YYLTYPE yylocation;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvalue;
  (void) yylocation;

  if (yytype < YYNTOKENS)
    {
      YYFPRINTF (yyout, "token %s (", yytname[yytype]);
# ifdef YYPRINT
      YYPRINT (yyout, yytoknum[yytype], yyvalue);
# endif
    }
  else
    YYFPRINTF (yyout, "nterm %s (", yytname[yytype]);

  switch (yytype)
    {
      default:
        break;
    }
  YYFPRINTF (yyout, ")");
}
#endif /* YYDEBUG. */


/*----------------------------------------------------------.
| yyreport_parse_error -- report a parse error in YYSTATE.  |
`----------------------------------------------------------*/

static void
#if defined (__STDC__) || defined (__cplusplus)
yyreport_parse_error (int yystate, int yychar, YYSTYPE yyvalue, YYLTYPE yylloc)
#else
yyreport_parse_error (yystate, yychar, yyvalue, yylloc)
    int yystate;
    int yychar;
    YYSTYPE yyvalue;
    YYLTYPE yylloc;
#endif
{
#if YYERROR_VERBOSE
  int yyn = yypact[yystate];

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
      yysize += yystrlen ("parse error, unexpected ") + 1;
      yysize += yystrlen (yytname[yytype]);
      yymsg = (char *) YYSTACK_ALLOC (yysize);
      if (yymsg != 0)
	{
	  char *yyp = yystpcpy (yymsg, "parse error, unexpected ");
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
	yyerror ("parse error; also virtual memory exhausted");
    }
  else
#endif /* YYERROR_VERBOSE */
    yyerror ("parse error");

  /* Pacify ``unused variable'' warnings.  */
  (void) yystate;
  (void) yychar;
  (void) yyvalue;
  (void) yylloc;
}


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
#if defined (__STDC__) || defined (__cplusplus)
yydestruct (int yytype, YYSTYPE yyvalue, YYLTYPE yylocation)
#else
yydestruct (yytype, yyvalue, yylocation)
    int yytype;
    YYSTYPE yyvalue;
    YYLTYPE yylocation;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvalue;
  (void) yylocation;

  switch (yytype)
    {
      default:
        break;
    }
}



/* The user can define YYPARSE_PARAM as the name of an argument to be passed
   into yyparse.  The argument should have type void *.
   It should actually point to an object.
   Grammar actions can access the variable by casting it
   to the proper pointer type.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
#  define YYPARSE_PARAM_ARG void *YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL
# else
#  define YYPARSE_PARAM_ARG YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL void *YYPARSE_PARAM;
# endif
#else /* !YYPARSE_PARAM */
# define YYPARSE_PARAM_ARG
# define YYPARSE_PARAM_DECL
#endif /* !YYPARSE_PARAM */

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
# ifdef YYPARSE_PARAM
int yyparse (void *);
# else
int yyparse (void);
# endif
#endif




int
yyparse (YYPARSE_PARAM_ARG)
     YYPARSE_PARAM_DECL
{
  /* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of parse errors so far.  */
int yynerrs;
/* Location data for the lookahead symbol.  */
YYLTYPE yylloc;

  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yychar1 = 0;

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

  if (yyssp >= yyss + yystacksize - 1)
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
      if (yystacksize >= YYMAXDEPTH)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
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

      if (yyssp >= yyss + yystacksize - 1)
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

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with.  */

  if (yychar <= 0)		/* This means end of input.  */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more.  */

      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yychar1 = YYTRANSLATE (yychar);

      /* We have to keep this `#if YYDEBUG', since we use variables
	 which are defined only if `YYDEBUG' is set.  */
      YYDPRINTF ((stderr, "Next token is "));
      YYDSYMPRINT ((stderr, yychar1, yylval, yyloc));
      YYDPRINTF ((stderr, "\n"));
    }

  yyn += yychar1;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %d (%s), ",
	      yychar, yytname[yychar1]));

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

#if YYDEBUG
  /* We have to keep this `#if YYDEBUG', since we use variables which
     are defined only if `YYDEBUG' is set.  */
  if (yydebug)
    {
      int yyi;

      YYFPRINTF (stderr, "Reducing via rule %d (line %d), ",
		 yyn - 1, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (yyi = yyprhs[yyn]; yyrhs[yyi] >= 0; yyi++)
	YYFPRINTF (stderr, "%s ", yytname[yyrhs[yyi]]);
      YYFPRINTF (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif
  switch (yyn)
    {
        case 5:
#line 111 "gst-parse.y"
    {
		  _gst_clear_method_start_pos(); 
		}
    break;

  case 9:
#line 124 "gst-parse.y"
    {
		  _gst_skip_compilation = false;
		  _gst_set_compilation_class(_gst_undefined_object_class);
		}
    break;

  case 10:
#line 134 "gst-parse.y"
    {
		  if (yyvsp[-1].node && !_gst_had_error)
		    _gst_execute_statements(yyvsp[-2].node, yyvsp[-1].node, false);

		  _gst_free_tree();
		  _gst_had_error = false;
		}
    break;

  case 11:
#line 142 "gst-parse.y"
    {
		  _gst_had_error = false;
		  yyerrok;
		}
    break;

  case 12:
#line 150 "gst-parse.y"
    {
		}
    break;

  case 13:
#line 153 "gst-parse.y"
    {
		  _gst_had_error = false;
		  yyerrok;
		}
    break;

  case 15:
#line 162 "gst-parse.y"
    {
		  yyval.node = _gst_make_method(&yyloc, yyvsp[-3].node, yyvsp[-2].node, yyvsp[-1].sval, yyvsp[0].node); 
		  if (!_gst_had_error && !_gst_skip_compilation) {
		    _gst_compile_method(yyval.node, false, true);
		    _gst_clear_method_start_pos();
		  }

		  _gst_free_tree();
		  _gst_had_error = false;
		}
    break;

  case 16:
#line 176 "gst-parse.y"
    {
		  yyval.node = _gst_make_unary_expr(&yyloc, NULL, yyvsp[0].sval); 
		}
    break;

  case 17:
#line 180 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr(&yyloc, NULL, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 18:
#line 184 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr(&yyloc, NULL, yyvsp[0].node); 
		}
    break;

  case 22:
#line 200 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable(&yyloc, yyvsp[0].sval); 
		}
    break;

  case 23:
#line 207 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_list(&yyloc, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 24:
#line 211 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-2].node, _gst_make_keyword_list(&yyloc, yyvsp[-1].sval, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 26:
#line 223 "gst-parse.y"
    {
		  yyval.sval = 0; 
		}
    break;

  case 27:
#line 227 "gst-parse.y"
    {
		  yyval.sval = yyvsp[-1].sval; 
		}
    break;

  case 28:
#line 233 "gst-parse.y"
    {
		  if (strcmp(yyvsp[0].sval, ">") != 0) YYFAIL; 
		}
    break;

  case 29:
#line 240 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 30:
#line 244 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 31:
#line 248 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 32:
#line 255 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable_list(&yyloc, yyvsp[0].node); 
		}
    break;

  case 33:
#line 259 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-1].node, _gst_make_variable_list(&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 34:
#line 267 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 35:
#line 271 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node;
		}
    break;

  case 36:
#line 275 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node;
		}
    break;

  case 37:
#line 279 "gst-parse.y"
    {
		  _gst_add_node (yyvsp[-3].node, yyvsp[-1].node);
		  yyval.node = yyvsp[-3].node;
		}
    break;

  case 38:
#line 287 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 39:
#line 291 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-2].node, yyvsp[0].node); 
		  yyval.node = yyvsp[-2].node;
		}
    break;

  case 40:
#line 296 "gst-parse.y"
    {
		  yyval.node = yyvsp[-2].node;
		  yyerrok;
		  _gst_had_error = true;
		}
    break;

  case 43:
#line 310 "gst-parse.y"
    {
		  yyval.node = _gst_make_statement_list(&yyloc, yyvsp[0].node); 
		}
    break;

  case 44:
#line 317 "gst-parse.y"
    {
		  yyval.node = _gst_make_statement_list(&yyloc,
						_gst_make_return(&yyloc, yyvsp[0].node));
		}
    break;

  case 46:
#line 326 "gst-parse.y"
    {
		  yyval.node = _gst_make_assign(&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 47:
#line 333 "gst-parse.y"
    {
		  yyval.node = _gst_make_assignment_list(&yyloc, yyvsp[-1].node); 
		}
    break;

  case 48:
#line 337 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-2].node, _gst_make_assignment_list(&yyloc, yyvsp[-1].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 56:
#line 355 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 57:
#line 362 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 58:
#line 368 "gst-parse.y"
    {
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 59:
#line 375 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable(&yyloc, yyvsp[0].sval); 
		}
    break;

  case 60:
#line 379 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-2].node, _gst_make_variable(&yyloc, yyvsp[0].sval)); 
		}
    break;

  case 69:
#line 397 "gst-parse.y"
    {
		  yyval.node = _gst_make_int_constant(&yyloc, yyvsp[0].ival); 
		}
    break;

  case 70:
#line 401 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant(&yyloc, yyvsp[0].fval, CONST_FLOATD); 
		}
    break;

  case 71:
#line 405 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant(&yyloc, yyvsp[0].fval, CONST_FLOATE); 
		}
    break;

  case 72:
#line 409 "gst-parse.y"
    {
		  yyval.node = _gst_make_float_constant(&yyloc, yyvsp[0].fval, CONST_FLOATQ); 
		}
    break;

  case 73:
#line 413 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_object_constant(&yyloc, yyvsp[0].boval); 
		}
    break;

  case 74:
#line 417 "gst-parse.y"
    {
		  yyval.node = _gst_make_oop_constant(&yyloc, yyvsp[0].oval); 
		}
    break;

  case 75:
#line 424 "gst-parse.y"
    {
		  yyval.node = _gst_make_int_constant(&yyloc, yyvsp[0].ival); 
		}
    break;

  case 76:
#line 431 "gst-parse.y"
    {
		  yyval.node = _gst_make_symbol_constant(&yyloc, yyvsp[0].node); 
		}
    break;

  case 77:
#line 435 "gst-parse.y"
    {
		  yyval.node = _gst_make_symbol_constant(&yyloc, _gst_intern_ident(&yyloc, yyvsp[0].sval)); 
		}
    break;

  case 78:
#line 442 "gst-parse.y"
    {
		  yyval.node = _gst_intern_ident(&yyloc, yyvsp[0].sval); 
		}
    break;

  case 79:
#line 446 "gst-parse.y"
    {
		  yyval.node = _gst_intern_ident(&yyloc, yyvsp[0].sval); 
		}
    break;

  case 80:
#line 450 "gst-parse.y"
    {
		  yyval.node = _gst_intern_ident(&yyloc, yyvsp[0].sval); 
		}
    break;

  case 81:
#line 454 "gst-parse.y"
    {
		  yyval.node = _gst_intern_ident(&yyloc, yyvsp[0].sval); 
		}
    break;

  case 82:
#line 462 "gst-parse.y"
    {
		  yyval.node = _gst_make_char_constant(&yyloc, yyvsp[0].cval); 
		}
    break;

  case 83:
#line 469 "gst-parse.y"
    {
		  yyval.node = _gst_make_string_constant(&yyloc, yyvsp[0].sval); 
		}
    break;

  case 84:
#line 476 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 85:
#line 480 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node; 
		}
    break;

  case 86:
#line 487 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constant(&yyloc, NULL); 
		}
    break;

  case 87:
#line 491 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 88:
#line 498 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 89:
#line 504 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constant(&yyloc, yyvsp[-1].node); 
		}
    break;

  case 90:
#line 511 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_elt(&yyloc, yyvsp[0].node); 
		}
    break;

  case 91:
#line 515 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-1].node, _gst_make_array_elt(&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 95:
#line 526 "gst-parse.y"
    {
		  OOP symbolOOP = yyvsp[0].node->v_expr.selector;
		  if (symbolOOP == _gst_true_symbol) {
		    yyval.node = _gst_make_oop_constant(&yyloc, _gst_true_oop);
		  } else if (symbolOOP == _gst_false_symbol) {
		    yyval.node = _gst_make_oop_constant(&yyloc, _gst_false_oop);
		  } else if (symbolOOP == _gst_nil_symbol) {
		    yyval.node = _gst_make_oop_constant(&yyloc, _gst_nil_oop);
		  } else {
		    _gst_errorf ("expected true, false or nil");
		    YYERROR;
		  }
		}
    break;

  case 96:
#line 543 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_array_constant(&yyloc, NULL); 
		}
    break;

  case 97:
#line 547 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 98:
#line 554 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 99:
#line 560 "gst-parse.y"
    {
		  yyval.node = _gst_make_byte_array_constant(&yyloc, yyvsp[-1].node); 
		}
    break;

  case 100:
#line 567 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_elt(&yyloc, yyvsp[0].node); 
		}
    break;

  case 101:
#line 571 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-1].node, _gst_make_array_elt(&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-1].node; 
		}
    break;

  case 102:
#line 579 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 103:
#line 586 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 104:
#line 593 "gst-parse.y"
    {
		  yyval.node = _gst_make_binding_constant(&yyloc, yyvsp[-1].node); 
		  if (!yyval.node) {
		    _gst_errorf ("invalid variable binding");
		    YYERROR;
		  }
		}
    break;

  case 105:
#line 604 "gst-parse.y"
    {
		  yyval.node = yyvsp[0].node;
		}
    break;

  case 106:
#line 611 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = _gst_make_oop_constant(&yyloc, _gst_nil_oop); 
		}
    break;

  case 107:
#line 618 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = _gst_make_oop_constant(&yyloc, _gst_nil_oop); 
		}
    break;

  case 108:
#line 624 "gst-parse.y"
    {
		  OOP result = _gst_nil_oop;
		  if (yyvsp[-1].node && !_gst_had_error)
		    result = _gst_execute_statements(yyvsp[-2].node, yyvsp[-1].node, true);

		  yyval.node = _gst_make_oop_constant(&yyloc, result); 
		}
    break;

  case 109:
#line 635 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 110:
#line 642 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 111:
#line 648 "gst-parse.y"
    {
		  yyval.node = _gst_make_array_constructor(&yyloc, yyvsp[-1].node); 
		}
    break;

  case 112:
#line 655 "gst-parse.y"
    {
		  yyclearin;
		  _gst_unread_char ('!');
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 113:
#line 662 "gst-parse.y"
    {
		  yyerrok;
		  _gst_had_error = true;
		  yyval.node = NULL; 
		}
    break;

  case 114:
#line 668 "gst-parse.y"
    {
		  yyval.node = _gst_make_block(&yyloc, yyvsp[-3].node, yyvsp[-2].node, yyvsp[-1].node); 
		}
    break;

  case 115:
#line 675 "gst-parse.y"
    {
		  yyval.node = NULL; 
		}
    break;

  case 116:
#line 679 "gst-parse.y"
    {
		  if (yyvsp[0].sval[0] != '|') {
		    YYFAIL;
		  } else if (yyvsp[0].sval[1] == '\0') {	/* | */
		  } else if (yyvsp[0].sval[1] == '|') {   /* || */
		    _gst_unread_char('|');
		  }
		}
    break;

  case 117:
#line 694 "gst-parse.y"
    {
		  yyval.node = _gst_make_variable_list(&yyloc, yyvsp[0].node); 
		}
    break;

  case 118:
#line 698 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-2].node, _gst_make_variable_list(&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 122:
#line 712 "gst-parse.y"
    {
		  if (is_unlikely_selector (yyvsp[0].sval)) {
		    _gst_warningf ("sending `%s', most likely you "
			           "forgot a period", yyvsp[0].sval);
		  }
		  yyval.node = _gst_make_unary_expr(&yyloc, yyvsp[-1].node, yyvsp[0].sval); 
		}
    break;

  case 125:
#line 728 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr(&yyloc, yyvsp[-2].node, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 128:
#line 740 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr(&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 129:
#line 747 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_list(&yyloc, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 130:
#line 752 "gst-parse.y"
    {
		   _gst_add_node(yyvsp[-2].node, _gst_make_keyword_list(&yyloc, yyvsp[-1].sval, yyvsp[0].node));
		   yyval.node = yyvsp[-2].node; 
		}
    break;

  case 131:
#line 760 "gst-parse.y"
    {
		  yyval.node = _gst_make_cascaded_message(&yyloc, yyvsp[-1].node, yyvsp[0].node); 
		}
    break;

  case 132:
#line 767 "gst-parse.y"
    {
		  yyval.node = _gst_make_message_list(&yyloc, yyvsp[0].node); 
		}
    break;

  case 133:
#line 771 "gst-parse.y"
    {
		  _gst_add_node(yyvsp[-2].node, _gst_make_message_list(&yyloc, yyvsp[0].node));
		  yyval.node = yyvsp[-2].node; 
		}
    break;

  case 134:
#line 779 "gst-parse.y"
    {
		   yyval.node = _gst_make_unary_expr(&yyloc, NULL, yyvsp[0].sval); 
		}
    break;

  case 135:
#line 783 "gst-parse.y"
    {
		  yyval.node = _gst_make_binary_expr(&yyloc, NULL, yyvsp[-1].sval, yyvsp[0].node); 
		}
    break;

  case 136:
#line 787 "gst-parse.y"
    {
		  yyval.node = _gst_make_keyword_expr(&yyloc, NULL, yyvsp[0].node); 
		}
    break;


    }

/* Line 1079 of /usr/share/bison/yacc.c.  */
#line 2086 "gst-parse.c"

  yyvsp -= yylen;
  yyssp -= yylen;
  yylsp -= yylen;

#if YYDEBUG
  if (yydebug)
    {
      short *yyssp1 = yyss - 1;
      YYFPRINTF (stderr, "state stack now");
      while (yyssp1 != yyssp)
	YYFPRINTF (stderr, " %d", *++yyssp1);
      YYFPRINTF (stderr, "\n");
    }
#endif

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
      yyreport_parse_error (yystate, yychar, yylval, yylloc);
    }
  goto yyerrlab1;


/*----------------------------------------------------.
| yyerrlab1 -- error raised explicitly by an action.  |
`----------------------------------------------------*/
yyerrlab1:
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
	  while (yyssp > yyss)
	    {
	      YYDPRINTF ((stderr, "Error: popping "));
	      YYDSYMPRINT ((stderr,
			    yystos[*yyssp],
			    *yyvsp, *yylsp));
	      YYDPRINTF ((stderr, "\n"));
	      yydestruct (yystos[*yyssp], *yyvsp, *yylsp);
	      YYPOPSTACK;
	    }
	  YYABORT;
        }

      YYDPRINTF ((stderr, "Discarding token %d (%s).\n",
		  yychar, yytname[yychar1]));
      yydestruct (yychar1, yylval, yylloc);
      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */

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

      YYDPRINTF ((stderr, "Error: popping "));
      YYDSYMPRINT ((stderr,
		    yystos[*yyssp], *yyvsp, *yylsp));
      YYDPRINTF ((stderr, "\n"));

      yydestruct (yystos[yystate], *yyvsp, *yylsp);
      yyvsp--;
      yystate = *--yyssp;
      yylsp--;

#if YYDEBUG
      if (yydebug)
	{
	  short *yyssp1 = yyss - 1;
	  YYFPRINTF (stderr, "Error: state stack now");
	  while (yyssp1 != yyssp)
	    YYFPRINTF (stderr, " %d", *++yyssp1);
	  YYFPRINTF (stderr, "\n");
	}
#endif
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;
  *++yylsp = yylloc;

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


#line 793 "gst-parse.y"

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

   return ((* == 's' &&
	    (strcmp(+1, "elf") == 0 ||
	     strcmp(+1, "uper") == 0)) ||
   
	   (* == 't' &&
	    (strcmp(+1, "rue") == 0 ||
	     strcmp(+1, "hisContext") == 0)) ||
   
	   (* == 'f' && strcmp(+1, "alse") == 0) ||
	   (* == 'n' && strcmp(+1, "il") == 0))

   ... but using gperf is more cool :-) */

mst_Boolean
is_unlikely_selector (register const char *str)
{
  /* The first-character table is big enough that
     we skip the range check on the hash value */

  static char first[31] = 
    "s  s   f  n  tt               ";

  static char *rest[] =
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

