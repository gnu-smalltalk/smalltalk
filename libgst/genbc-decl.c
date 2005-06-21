/* A Bison parser, made by GNU Bison 1.875a.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.

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
#define YYBISON 1

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     MATCH_BYTECODES = 258,
     DECL_BEGIN = 259,
     DECL_END = 260,
     DECL_BREAK = 261,
     DECL_CONTINUE = 262,
     DECL_DISPATCH = 263,
     DECL_EXTRACT = 264,
     DECL_DOTS = 265,
     NUMBER = 266,
     ID = 267,
     EXPR = 268
   };
#endif
#define MATCH_BYTECODES 258
#define DECL_BEGIN 259
#define DECL_END 260
#define DECL_BREAK 261
#define DECL_CONTINUE 262
#define DECL_DISPATCH 263
#define DECL_EXTRACT 264
#define DECL_DOTS 265
#define NUMBER 266
#define ID 267
#define EXPR 268




/* Copy the first part of user declarations.  */
#line 33 "genbc-decl.y"

#include "genbc.h"
#include "avltrees.h"

#define yyparse decl_yyparse
#define yydebug decl_yydebug
#define YYERROR_VERBOSE
#define YYPRINT yyprint

typedef struct bytecode_info {
  avl_node_t avl;
  const char *name;
  struct field_info *fields;
} bytecode_info;

typedef struct field_info {
  struct field_info *next, **pnext;
  const char *name;
} field_info;

typedef struct var_info {
  avl_node_t avl;
  const char *name;
} var_info;

typedef struct opcode {
  struct opcode *next;
  int first;
  int last;
  char *code;
} opcode;

static void define_decl (int first, int last, char *code);
static void define_bytecode (const char *id, field_info *fields);
static void define_var (const char *id);
static void define_field (const char *id, int bits);
static char *extraction_code (int bits);
static void emit_var_names (var_info *node, const char *prefix, const char *suffix, const char *next_prefix);
static int filprintf (Filament *fil, const char *format, ...);
static bytecode_info *get_bytecode (const char *name);

int curr_bit_offset = 0, synthetic = 256;
bytecode_info *bytecode_root, *curr_bytecode;
field_info *curr_field;
var_info *var_root;
opcode *first = NULL, **p_next = &first;
Filament *curr_fil;
char *begin_code, *end_code;



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
#line 88 "genbc-decl.y"
typedef union YYSTYPE {
  struct field_info *field;
  const char *ctext;
  char *text;
  int num;
} YYSTYPE;
/* Line 191 of yacc.c.  */
#line 160 "genbc-decl.c"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 214 of yacc.c.  */
#line 172 "genbc-decl.c"

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
	 || (YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE))				\
      + YYSTACK_GAP_MAXIMUM)

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
#define YYFINAL  13
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   75

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  21
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  24
/* YYNRULES -- Number of rules. */
#define YYNRULES  47
/* YYNRULES -- Number of states. */
#define YYNSTATES  73

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   268

#define YYTRANSLATE(YYX) 						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      17,    18,     2,     2,    19,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    14,
       2,    20,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    15,     2,    16,     2,     2,     2,     2,
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
       5,     6,     7,     8,     9,    10,    11,    12,    13
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned char yyprhs[] =
{
       0,     0,     3,     6,     8,    12,    17,    22,    27,    34,
      38,    39,    43,    45,    46,    49,    52,    53,    55,    56,
      61,    63,    65,    67,    70,    71,    73,    75,    76,    79,
      82,    83,    85,    87,    89,    90,    95,    98,   102,   103,
     107,   109,   110,   113,   117,   118,   122,   124
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const yysigned_char yyrhs[] =
{
      22,     0,    -1,    22,    23,    -1,    23,    -1,    12,    24,
      14,    -1,     4,    15,    26,    16,    -1,     5,    15,    26,
      16,    -1,    11,    15,    33,    16,    -1,    11,    10,    11,
      15,    33,    16,    -1,    17,    25,    18,    -1,    -1,    25,
      19,    12,    -1,    12,    -1,    -1,    27,    31,    -1,    28,
      29,    -1,    -1,    20,    -1,    -1,    17,    30,    31,    18,
      -1,    12,    -1,    11,    -1,    13,    -1,    31,    32,    -1,
      -1,    29,    -1,    19,    -1,    -1,    34,    35,    -1,    35,
      36,    -1,    -1,    32,    -1,     6,    -1,     7,    -1,    -1,
       8,    12,    37,    38,    -1,     9,    43,    -1,    17,    39,
      18,    -1,    -1,    39,    19,    40,    -1,    40,    -1,    -1,
      41,    28,    -1,    17,    11,    18,    -1,    -1,    43,    19,
      44,    -1,    44,    -1,    12,    42,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   117,   117,   118,   122,   124,   126,   128,   130,   135,
     138,   142,   150,   160,   160,   166,   167,   170,   173,   172,
     176,   178,   180,   185,   186,   189,   190,   195,   195,   202,
     203,   206,   207,   209,   212,   211,   232,   241,   242,   246,
     247,   251,   251,   264,   265,   269,   270,   274
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "\"MATCH_BYTECODES\"", "\"BEGIN\"", 
  "\"END\"", "\"break\"", "\"continue\"", "\"dispatch\"", "\"extract\"", 
  "\"..\"", "\"number\"", "\"identifier\"", "\"expression\"", "';'", 
  "'{'", "'}'", "'('", "')'", "','", "'='", "$accept", "decls", "decl", 
  "opt_field_list", "field_list", "c_code", "@1", "c_code_expr_body", 
  "c_code_expr_item", "@2", "c_code_body", "c_code_item", "code", "@3", 
  "code_body", "code_item", "@4", "opt_dispatch_args", "dispatch_args", 
  "dispatch_arg", "@5", "opt_size", "bitfields", "bitfield", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,    59,   123,   125,    40,    41,    44,
      61
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    21,    22,    22,    23,    23,    23,    23,    23,    24,
      24,    25,    25,    27,    26,    28,    28,    29,    30,    29,
      29,    29,    29,    31,    31,    32,    32,    34,    33,    35,
      35,    36,    36,    36,    37,    36,    36,    38,    38,    39,
      39,    41,    40,    42,    42,    43,    43,    44
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     2,     1,     3,     4,     4,     4,     6,     3,
       0,     3,     1,     0,     2,     2,     0,     1,     0,     4,
       1,     1,     1,     2,     0,     1,     1,     0,     2,     2,
       0,     1,     1,     1,     0,     4,     2,     3,     0,     3,
       1,     0,     2,     3,     0,     3,     1,     2
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
       0,     0,     0,     0,    10,     0,     3,    13,    13,     0,
      27,     0,     0,     1,     2,     0,    24,     0,     0,     0,
      30,    12,     0,     4,     5,    14,     6,    27,     7,    28,
       9,     0,    21,    20,    22,    18,    26,    17,    25,    23,
       0,    32,    33,     0,     0,    31,    29,    11,    24,     8,
      34,    44,    36,    46,     0,    38,     0,    47,     0,    19,
      41,    35,     0,    45,     0,    40,    16,    43,    37,    41,
      42,    39,    15
};

/* YYDEFGOTO[NTERM-NUM]. */
static const yysigned_char yydefgoto[] =
{
      -1,     5,     6,    12,    22,    15,    16,    70,    38,    48,
      25,    39,    19,    20,    29,    46,    55,    61,    64,    65,
      66,    57,    52,    53
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -8
static const yysigned_char yypact[] =
{
      36,    -5,    -3,    34,     5,     4,    -8,    -8,    -8,    21,
      -8,    22,    28,    -8,    -8,    29,    -8,    35,    37,    38,
      -8,    -8,     2,    -8,    -8,    16,    -8,    -8,    -8,    -6,
      -8,    41,    -8,    -8,    -8,    -8,    -8,    -8,    -8,    -8,
      39,    -8,    -8,    44,    45,    -8,    -8,    -8,    -8,    -8,
      -8,    33,    40,    -8,     6,    43,    47,    -8,    45,    -8,
      -8,    -8,    46,    -8,    12,    -8,    -8,    -8,    -8,    -8,
      26,    -8,    -8
};

/* YYPGOTO[NTERM-NUM].  */
static const yysigned_char yypgoto[] =
{
      -8,    -8,    56,    -8,    -8,    54,    -8,    -8,    -7,    -8,
      17,    42,    48,    -8,    -8,    -8,    -8,    -8,    -8,    -2,
      -8,    -8,    -8,     8
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const unsigned char yytable[] =
{
      41,    42,    43,    44,    13,    32,    33,    34,     1,     2,
       7,    35,     8,    36,    37,     3,     4,    32,    33,    34,
      30,    31,    11,    35,    59,    36,    37,    32,    33,    34,
      68,    69,    18,    35,    21,    36,    37,    32,    33,    34,
       1,     2,    23,    35,     9,    24,    37,     3,     4,    10,
      56,    26,    27,    47,    28,    49,    50,    51,    62,    58,
      60,    14,    17,    72,    67,    54,    63,    71,     0,     0,
       0,    45,     0,     0,     0,    40
};

static const yysigned_char yycheck[] =
{
       6,     7,     8,     9,     0,    11,    12,    13,     4,     5,
      15,    17,    15,    19,    20,    11,    12,    11,    12,    13,
      18,    19,    17,    17,    18,    19,    20,    11,    12,    13,
      18,    19,    11,    17,    12,    19,    20,    11,    12,    13,
       4,     5,    14,    17,    10,    16,    20,    11,    12,    15,
      17,    16,    15,    12,    16,    16,    12,    12,    11,    19,
      17,     5,     8,    70,    18,    48,    58,    69,    -1,    -1,
      -1,    29,    -1,    -1,    -1,    27
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     4,     5,    11,    12,    22,    23,    15,    15,    10,
      15,    17,    24,     0,    23,    26,    27,    26,    11,    33,
      34,    12,    25,    14,    16,    31,    16,    15,    16,    35,
      18,    19,    11,    12,    13,    17,    19,    20,    29,    32,
      33,     6,     7,     8,     9,    32,    36,    12,    30,    16,
      12,    12,    43,    44,    31,    37,    17,    42,    19,    18,
      17,    38,    11,    44,    39,    40,    41,    18,    18,    19,
      28,    40,    29
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
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
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
                  Token, Value);	\
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
yysymprint (FILE *yyoutput, int yytype, YYSTYPE *yyvaluep)
#else
static void
yysymprint (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;

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
yydestruct (int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yytype, yyvaluep)
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;

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



/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



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



#define YYPOPSTACK   (yyvsp--, yyssp--)

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


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


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

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

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


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


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 4:
#line 123 "genbc-decl.y"
    { define_bytecode (yyvsp[-2].text, yyvsp[-1].field); }
    break;

  case 5:
#line 125 "genbc-decl.y"
    { begin_code = yyvsp[-1].text; }
    break;

  case 6:
#line 127 "genbc-decl.y"
    { end_code = yyvsp[-1].text; }
    break;

  case 7:
#line 129 "genbc-decl.y"
    { define_decl (yyvsp[-3].num, yyvsp[-3].num, yyvsp[-1].text); }
    break;

  case 8:
#line 131 "genbc-decl.y"
    { define_decl (yyvsp[-5].num, yyvsp[-3].num, yyvsp[-1].text); }
    break;

  case 9:
#line 136 "genbc-decl.y"
    { yyval.field = yyvsp[-1].field; }
    break;

  case 10:
#line 138 "genbc-decl.y"
    { yyval.field = NULL; }
    break;

  case 11:
#line 143 "genbc-decl.y"
    { struct field_info *f = malloc (sizeof (struct field_info *));
	    define_var (yyvsp[0].text);
	    f->name = yyvsp[0].text;
	    *(yyvsp[-2].field->pnext) = f;
	    yyval.field = yyvsp[-2].field;
	    yyval.field->pnext = &(f->next);
	  }
    break;

  case 12:
#line 151 "genbc-decl.y"
    { struct field_info *f = malloc (sizeof (struct field_info *));
	    define_var (yyvsp[0].text);
	    f->name = yyvsp[0].text;
	    yyval.field = f;
	    yyval.field->pnext = &(f->next);
	  }
    break;

  case 13:
#line 160 "genbc-decl.y"
    { curr_fil = filnew (NULL, 0); }
    break;

  case 14:
#line 162 "genbc-decl.y"
    { yyval.text = fildelete (curr_fil); }
    break;

  case 17:
#line 171 "genbc-decl.y"
    { filccat (curr_fil, '='); }
    break;

  case 18:
#line 173 "genbc-decl.y"
    { filccat (curr_fil, '('); }
    break;

  case 19:
#line 175 "genbc-decl.y"
    { filccat (curr_fil, ')'); }
    break;

  case 20:
#line 177 "genbc-decl.y"
    { filcat (curr_fil, yyvsp[0].text); free (yyvsp[0].text); }
    break;

  case 21:
#line 179 "genbc-decl.y"
    { filprintf (curr_fil, "%d", yyvsp[0].num); }
    break;

  case 22:
#line 181 "genbc-decl.y"
    { filcat (curr_fil, yyvsp[0].ctext); }
    break;

  case 26:
#line 191 "genbc-decl.y"
    { filccat (curr_fil, ','); }
    break;

  case 27:
#line 195 "genbc-decl.y"
    { curr_fil = filnew (NULL, 0); }
    break;

  case 28:
#line 197 "genbc-decl.y"
    { filcat (curr_fil, "  goto MATCH_BYTECODES_END_##name_; ");
	    yyval.text = fildelete (curr_fil); }
    break;

  case 32:
#line 208 "genbc-decl.y"
    { filcat (curr_fil, "goto MATCH_BYTECODES_END_##name_;"); }
    break;

  case 33:
#line 210 "genbc-decl.y"
    { filcat (curr_fil, "goto MATCH_BYTECODES_START_##name_;"); }
    break;

  case 34:
#line 212 "genbc-decl.y"
    { filprintf (curr_fil, "do { \\\n"
				 "\topcode_ = %d; \\\n", synthetic);
	    curr_bytecode = get_bytecode (yyvsp[0].text);
	    if (!curr_bytecode)
	      {
		curr_field = NULL;
		yyerror ("bad bytecode name");
	      }
	    else
	      curr_field = curr_bytecode->fields;
	  }
    break;

  case 35:
#line 224 "genbc-decl.y"
    { if (curr_field)
	      yyerror ("expected field in dispatch");
	    filprintf (curr_fil, "\tgoto MATCH_BYTECODES_##name_##_%s; \\\n", yyvsp[-2].text);
	    filprintf (curr_fil, "    case %d: \\\n"
				 "\t; \\\n"
				 "      } while (0)", synthetic++);
	    free (yyvsp[-2].text);
	  }
    break;

  case 36:
#line 233 "genbc-decl.y"
    { if (yyvsp[0].num % 8)
	      yyerror ("must extract an integer number of bytes");
	    else
	      filprintf (curr_fil, "bp_ = (IP += %d)", yyvsp[0].num / 8);
	  }
    break;

  case 41:
#line 251 "genbc-decl.y"
    { if (curr_field)
	    {
	      filprintf (curr_fil, "\t%s = ", curr_field->name);
	      curr_field = curr_field->next;
	    }
	  else
	    yyerror ("extra field in dispatch");
	}
    break;

  case 42:
#line 260 "genbc-decl.y"
    { filprintf (curr_fil, "; \\\n"); }
    break;

  case 43:
#line 264 "genbc-decl.y"
    { yyval.num = yyvsp[-1].num; }
    break;

  case 44:
#line 265 "genbc-decl.y"
    { yyval.num = 8; }
    break;

  case 45:
#line 269 "genbc-decl.y"
    { yyval.num = yyvsp[-2].num + yyvsp[0].num; }
    break;

  case 46:
#line 270 "genbc-decl.y"
    { yyval.num = yyvsp[0].num; }
    break;

  case 47:
#line 275 "genbc-decl.y"
    { define_field (yyvsp[-1].text, yyvsp[0].num); yyval.num = yyvsp[0].num; }
    break;


    }

/* Line 999 of yacc.c.  */
#line 1309 "genbc-decl.c"

  yyvsp -= yylen;
  yyssp -= yylen;


  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


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
	      yydestruct (yystos[*yyssp], yyvsp);
	      YYPOPSTACK;
	    }
	  YYABORT;
        }

      YYDSYMPRINTF ("Error: discarding", yytoken, &yylval, &yylloc);
      yydestruct (yytoken, &yylval);
      yychar = YYEMPTY;

    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*----------------------------------------------------.
| yyerrlab1 -- error raised explicitly by an action.  |
`----------------------------------------------------*/
yyerrlab1:
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
      yydestruct (yystos[yystate], yyvsp);
      yyvsp--;
      yystate = *--yyssp;

      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;


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


#line 278 "genbc-decl.y"


int
filprintf (Filament *fil, const char *format, ...)
{
  va_list ap;
  STREAM *out = stream_new (fil, SNV_UNLIMITED, NULL, snv_filputc);
  int result;
  va_start (ap, format);
  result = stream_vprintf (out, format, ap);
  va_end (ap);
  stream_delete (out);
  return result;
}

/* Advance the pointer by BITS bits and return the code to 
   extract those bits.  */
char *
extraction_code (int bits)
{
  char *s;
  int n_bit = curr_bit_offset % 8;
  int n_byte = curr_bit_offset / 8;

  if (n_bit + bits <= 8)
    {
      int rshift = 8 - (n_bit + bits);
      int mask = (1 << bits) - 1;
      curr_bit_offset += bits;

      if (n_bit && rshift)
        return my_asprintf ("(IP[%d] >> %d) & %d", n_byte, rshift, mask);

      if (rshift)
        return my_asprintf ("IP[%d] >> %d", n_byte, rshift);

      if (n_bit)
        return my_asprintf ("IP[%d] & %d", n_byte, mask);
      else
        return my_asprintf ("IP[%d]", n_byte);
    }

  /* Else, multi-byte extraction.  */
  if (curr_bit_offset % 8)
    /* Complete the current byte...  */
    {
      int n = 8 - (curr_bit_offset % 8);
      s = extraction_code (n);
      bits -= n;
      n_bit = 0;
      n_byte++;
    }
  else
    /* ... or do a new one.  */
    {
      s = my_asprintf ("IP[%d]", n_byte++);
      curr_bit_offset += 8;
      bits -= 8;
    }

  /* Add entire bytes as long as possible.  */
  while (bits >= 8)
    {
      char *new_s = my_asprintf ("((%s) << 8) | IP[%d]", s, n_byte++);
      free (s);
      s = new_s;
      curr_bit_offset += 8;
      bits -= 8;
    }

  /* And finally any spare bits.  */
  if (bits)
    {
      char *new_s = my_asprintf ("((%s) << 8) | %s", s, extraction_code (bits));
      free (s);
      s = new_s;
    }

  return (s);
}

/* Define a bytecode that is used as an operand to dispatch.
   We use an AVL tree to store them so that we can do fast
   searches, and we can detect duplicates.  */
bytecode_info *
get_bytecode (const char *name)
{
  avl_node_t **p = (avl_node_t **) &bytecode_root;
  bytecode_info *bytecode = NULL;

  while (*p)
    {
      int cmp;
      bytecode = (bytecode_info *) *p;

      cmp = strcmp(name, bytecode->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
	return bytecode;
    }

  return NULL;
}

/* Define a bytecode that is used as an operand to dispatch.
   We use an AVL tree to store them so that we can do fast
   searches, and we can detect duplicates.  */
void
define_bytecode (const char *name, field_info *fields)
{
  avl_node_t **p = (avl_node_t **) &bytecode_root;
  bytecode_info *node;
  bytecode_info *bytecode = NULL;

  while (*p)
    {
      int cmp;
      bytecode = (bytecode_info *) *p;

      cmp = strcmp(name, bytecode->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
	{
	  yyerror ("duplicate bytecode name");
          return;
	}
    }

  node = (bytecode_info *) calloc(1, sizeof(struct bytecode_info));
  node->avl.avl_parent = (avl_node_t *) bytecode;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->name = name;
  node->fields = fields;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &bytecode_root);
}

/* Define a variable that is used to pass the operands of the
   bytecode.  We use an AVL tree to store them so that we can
   output them nicely sorted, and we can eliminate duplicates.  */
void
define_var (const char *name)
{
  avl_node_t **p = (avl_node_t **) &var_root;
  var_info *node;
  var_info *var = NULL;

  while (*p)
    {
      int cmp;
      var = (var_info *) *p;

      cmp = strcmp(name, var->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
        return;
    }

  node = (var_info *) calloc(1, sizeof(struct var_info));
  node->avl.avl_parent = (avl_node_t *) var;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->name = name;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &var_root);
}

/* Define an operation that is BITS bits wide and whose opcodes start
   at OPCODE) and does the ID operation.  */
void
define_decl (int first, int last, char *code)
{
  struct opcode *curr = calloc (1, sizeof (struct opcode));
  curr->first = first;
  curr->last = last;
  curr->code = code;

  *p_next = curr;
  p_next = &(curr->next);

  if ((unsigned) (first | last) > 255)
    yyerror ("Invalid opcode specification");

  curr_bit_offset = 0;
}

/* Define a BITS bits-wide operand named NAME of the current bytecode.  */
void
define_field (const char *name, int bits)
{
  char *s = extraction_code (bits);
  define_var (name);
  filprintf (curr_fil, "%s = %s; \\\n      ", name, s);
  free (s);
}

/* Emit the declarations for the variable names.  NODE is the root of
   the tree, PREFIX ("int" or ",") is emitted before the first variable,
   SUFFIX after every variable, NEXT_PREFIX before every variable but
   the first.  */
void
emit_var_names (var_info *node, const char *prefix, const char *suffix, const char *next_prefix)
{
  if (node->avl.avl_left)
    {
      emit_var_names ((var_info *) node->avl.avl_left, prefix, suffix, next_prefix);
      prefix = next_prefix;
    }

  printf ("%s%s%s", prefix, node->name, suffix);

  if (node->avl.avl_right)
    emit_var_names ((var_info *) node->avl.avl_right, next_prefix, suffix, next_prefix);
}

/* Emit the decision tree for the bytecodes.  */
void
emit_opcodes ()
{
  int n;
  struct opcode *op;

  define_var ("opcode_");
  emit_var_names (var_root, "  int ", "", ", ");
  printf ("; \\\n");

  printf ("  unsigned char *IP = bp_; \\\n");
  printf ("  unsigned char ATTRIBUTE_UNUSED *IP0 = bp_; \\\n");

  emit_var_names (var_root, "  ", " ", "= ");
  printf ("= 0; \\\n");
  if (begin_code)
    printf ("  { \\\n"
	    "  %s \\\n"
	    "  } \\\n", begin_code);

  printf ("MATCH_BYTECODES_START_##name_: \\\n"
  	  "  opcode_ = *IP; \\\n"
  	  "MATCH_BYTECODES_SWITCH_##name_: \\\n"
          "  switch (opcode_) { \\\n");

  for (op = first; op; op = op->next)
    {
      int first_val = op->first;
      int last_val = op->last;

      for (n = 0; first_val <= last_val; first_val++, n++)
	{
	  if (!(n & 3))
	    printf ("%s    ", n ? "\\\n" : "");

	  printf ("case %d: ", first_val);
	}

      printf ("\\\n"
              "    %s\\\n", op->code);
    }

  printf ("  } \\\n"
          "  MATCH_BYTECODES_DISPATCH(MATCH_BYTECODES_##name_) \\\n"
          "MATCH_BYTECODES_END_##name_: \\\n"
	  "%s", end_code ? end_code : "  ;");
}

