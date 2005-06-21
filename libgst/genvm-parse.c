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
     ID = 258,
     EXPR = 259,
     NUMBER = 260,
     VM_OPERATION = 261,
     VM_TABLE = 262,
     VM_BYTECODE = 263,
     VM_DOTS = 264,
     VM_MINUSMINUS = 265
   };
#endif
#define ID 258
#define EXPR 259
#define NUMBER 260
#define VM_OPERATION 261
#define VM_TABLE 262
#define VM_BYTECODE 263
#define VM_DOTS 264
#define VM_MINUSMINUS 265




/* Copy the first part of user declarations.  */
#line 31 "genvm-parse.y"

#include "avltrees.h"
#include "genvm.h"
#include "genvm-parse.h"

#define YYERROR_VERBOSE 1

typedef struct id_list {
  struct id_list *next;
  struct id_list **pnext;
  char id[1];
} id_list;

typedef struct operation_info {
  avl_node_t avl;
  const char *name;
  struct id_list *args;
  struct id_list *in, *out, *read;
  int n_in, n_out, n_read;
  int needs_prepare_stack;
  int needs_branch_label;
  int instantiations;
  const char *code;
} operation_info;

typedef struct operation_list {
  struct operation_list *next;
  struct operation_list **pnext;
  operation_info *op;
  id_list *args;
} operation_list;

typedef struct table_info {
  char *name;
  char *entry[256];
  id_list *pool;
} table_info;

#define YYPRINT(fp, tok, val) yyprint (fp, tok, &val)

static int filprintf (Filament *fil, const char *format, ...);
static void yyprint (FILE *fp, int tok, YYSTYPE *val);
static void yyerror (const char *s);
static operation_info *define_operation (const char *name);
static void set_curr_op_stack (id_list *in, id_list *out);
static operation_list *append_to_operation_list (operation_list *list, const char *name, id_list *args);
static id_list *append_to_id_list (id_list *list, const char *id);
static int emit_id_list (const id_list *list, const char *sep, const char *before, const char *after);
static void set_table (table_info *t, int from, int to, char *value);
static void free_id_list (id_list *list);
static void emit_var_declarations (const char *base, const char *type, int i, int n);
static void emit_var_defines (id_list *list, int sp);
static void emit_operation_invocation (operation_info *op, id_list *args, int sp, int deepest_write);
static void emit_operation_list (operation_list *list);
static void emit_stack_update (int sp, int deepest_write, const char *before, const char *after);
static void free_operation_list (operation_list *list);
static table_info *define_table (char *name);
static void emit_table (table_info *t);
static void free_table (table_info *t);

int counter = 0;
int c_code_on_brace = 0;
int c_args_on_paren = 0;
int errors = 0;
Filament *curr_fil, *out_fil;
operation_info *curr_op, *op_root;
table_info *curr_table;
int from, to;



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
#line 105 "genvm-parse.y"
typedef union YYSTYPE {
  struct operation_list *oplist;
  struct operation_info *op;
  struct table_info *tab;
  struct id_list *id;
  const char *ctext;
  char *text;
  int num;
} YYSTYPE;
/* Line 191 of yacc.c.  */
#line 177 "genvm-parse.c"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 214 of yacc.c.  */
#line 189 "genvm-parse.c"

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
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   50

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  18
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  27
/* YYNRULES -- Number of rules. */
#define YYNRULES  44
/* YYNRULES -- Number of states. */
#define YYNSTATES  70

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   265

#define YYTRANSLATE(YYX) 						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      15,    16,     2,     2,    13,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    17,
       2,    14,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    11,     2,    12,     2,     2,     2,     2,
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
       5,     6,     7,     8,     9,    10
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned char yyprhs[] =
{
       0,     0,     3,     6,     9,    12,    13,    14,    21,    23,
      25,    29,    32,    34,    38,    41,    43,    46,    51,    54,
      57,    58,    65,    66,    74,    75,    77,    78,    82,    84,
      85,    88,    91,    93,    94,   100,   102,   103,   104,   105,
     115,   118,   119,   125,   128
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const yysigned_char yyrhs[] =
{
      19,     0,    -1,    19,    20,    -1,    19,    39,    -1,    19,
      28,    -1,    -1,    -1,     7,     3,    21,    11,    22,    12,
      -1,    23,    -1,    24,    -1,    23,    13,    26,    -1,    24,
      26,    -1,    26,    -1,    23,    13,    27,    -1,    24,    27,
      -1,    27,    -1,     5,    14,    -1,     5,     9,     5,    14,
      -1,    25,     3,    -1,    25,    28,    -1,    -1,     8,    38,
      29,    11,    30,    12,    -1,    -1,    30,     3,    31,    15,
      32,    16,    17,    -1,    -1,    33,    -1,    -1,    33,    13,
      34,    -1,    34,    -1,    -1,    35,    36,    -1,    36,     4,
      -1,     4,    -1,    -1,    36,    15,    37,    36,    16,    -1,
       3,    -1,    -1,    -1,    -1,     6,     3,    40,    42,    43,
      41,    11,    44,    12,    -1,    42,     3,    -1,    -1,    15,
      42,    10,    42,    16,    -1,    44,     4,    -1,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   133,   133,   134,   135,   137,   141,   140,   146,   147,
     150,   151,   152,   155,   156,   157,   160,   168,   178,   184,
     190,   189,   199,   199,   202,   205,   208,   212,   214,   219,
     219,   224,   226,   229,   228,   234,   237,   242,   244,   241,
     262,   265,   268,   271,   273
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "\"identifier\"", "\"C expression\"", 
  "\"number\"", "\"operation\"", "\"table\"", "\"bytecode\"", "\"..\"", 
  "\"--\"", "'{'", "'}'", "','", "'='", "'('", "')'", "';'", "$accept", 
  "script", "table", "@1", "table_items", "table_items.label", 
  "table_items.descr", "subscripts", "label", "description", "bytecode", 
  "@2", "operation_list", "@3", "opt_c_args", "c_args", "c_arg", "@4", 
  "c_arg_body", "@5", "opt_id", "operation", "@6", "@7", "ids", 
  "stack_balance", "c_code", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   123,   125,    44,    61,    40,    41,    59
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    18,    19,    19,    19,    19,    21,    20,    22,    22,
      23,    23,    23,    24,    24,    24,    25,    25,    26,    27,
      29,    28,    31,    30,    30,    32,    32,    33,    33,    35,
      34,    36,    36,    37,    36,    38,    38,    40,    41,    39,
      42,    42,    43,    44,    44
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     2,     2,     2,     0,     0,     6,     1,     1,
       3,     2,     1,     3,     2,     1,     2,     4,     2,     2,
       0,     6,     0,     7,     0,     1,     0,     3,     1,     0,
       2,     2,     1,     0,     5,     1,     0,     0,     0,     9,
       2,     0,     5,     2,     0
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
       5,     0,     1,     0,     0,    36,     2,     4,     3,    37,
       6,    35,    20,    41,     0,     0,     0,     0,    24,    40,
      41,    38,     0,     0,     8,     9,     0,    12,    15,     0,
       0,     0,     0,    16,     7,     0,    11,    14,    18,    19,
      22,    21,    41,    44,     0,    10,    13,     0,     0,     0,
      17,    26,    42,    43,    39,     0,    25,    28,     0,     0,
      29,    32,    30,    23,    27,    31,    33,     0,     0,    34
};

/* YYDEFGOTO[NTERM-NUM]. */
static const yysigned_char yydefgoto[] =
{
      -1,     1,     6,    14,    23,    24,    25,    26,    27,    28,
       7,    15,    29,    47,    55,    56,    57,    58,    62,    67,
      12,     8,    13,    31,    16,    21,    49
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -24
static const yysigned_char yypact[] =
{
     -24,    20,   -24,     5,     6,    29,   -24,   -24,   -24,   -24,
     -24,   -24,   -24,   -24,    12,    23,     2,    28,   -24,   -24,
     -24,   -24,    -3,    24,    25,    28,    22,   -24,   -24,     7,
      21,    26,    30,   -24,   -24,    28,   -24,   -24,   -24,   -24,
     -24,   -24,   -24,   -24,    27,   -24,   -24,    31,    -2,    17,
     -24,    35,   -24,   -24,   -24,    32,    34,   -24,    36,    33,
     -24,   -24,     3,   -24,   -24,   -24,   -24,    36,     0,   -24
};

/* YYPGOTO[NTERM-NUM].  */
static const yysigned_char yypgoto[] =
{
     -24,   -24,   -24,   -24,   -24,   -24,   -24,   -24,   -23,   -22,
      16,   -24,   -24,   -24,   -24,   -24,   -17,   -24,   -18,   -24,
     -24,   -24,   -24,   -24,   -20,   -24,   -24
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -30
static const yysigned_char yytable[] =
{
      30,    19,    36,    37,    65,    19,    32,    65,     9,    10,
      40,    33,    45,    46,    52,    66,    69,    20,    66,    41,
       2,    53,    48,    17,    19,    38,     3,     4,     5,    54,
       5,    42,    11,    22,    18,    44,    34,    43,    35,   -29,
      61,    50,    39,    64,     0,     0,    51,    60,    59,    68,
      63
};

static const yysigned_char yycheck[] =
{
      20,     3,    25,    25,     4,     3,     9,     4,     3,     3,
       3,    14,    35,    35,    16,    15,    16,    15,    15,    12,
       0,     4,    42,    11,     3,     3,     6,     7,     8,    12,
       8,    10,     3,     5,    11,     5,    12,    11,    13,     4,
       4,    14,    26,    60,    -1,    -1,    15,    13,    16,    67,
      17
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,    19,     0,     6,     7,     8,    20,    28,    39,     3,
       3,     3,    38,    40,    21,    29,    42,    11,    11,     3,
      15,    43,     5,    22,    23,    24,    25,    26,    27,    30,
      42,    41,     9,    14,    12,    13,    26,    27,     3,    28,
       3,    12,    10,    11,     5,    26,    27,    31,    42,    44,
      14,    15,    16,     4,    12,    32,    33,    34,    35,    16,
      13,     4,    36,    17,    34,     4,    15,    37,    36,    16
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
#line 136 "genvm-parse.y"
    { free (yyvsp[0].text); }
    break;

  case 6:
#line 141 "genvm-parse.y"
    { curr_table = define_table (yyvsp[0].text); }
    break;

  case 7:
#line 143 "genvm-parse.y"
    { emit_table (curr_table); free_table (curr_table); }
    break;

  case 16:
#line 161 "genvm-parse.y"
    { from = to = yyvsp[-1].num;
	    if (from < 0 || from > 255)
	      {
		yyerror ("invalid table index");
		from = 0, to = -1;
	      }
	   }
    break;

  case 17:
#line 169 "genvm-parse.y"
    { from = yyvsp[-3].num, to = yyvsp[-1].num;
	    if (from < 0 || to < 0 || from > 255 || to > 255)
	      {
		yyerror ("invalid table index");
		from = 0, to = -1;
	      }
	   }
    break;

  case 18:
#line 179 "genvm-parse.y"
    { set_table (curr_table, from, to, yyvsp[0].text);
	    free (yyvsp[0].text);
	  }
    break;

  case 19:
#line 185 "genvm-parse.y"
    { set_table (curr_table, from, to, yyvsp[0].text);
	    free (yyvsp[0].text);
	  }
    break;

  case 20:
#line 190 "genvm-parse.y"
    { filprintf (out_fil, "%s:\n", yyvsp[0].text); }
    break;

  case 21:
#line 192 "genvm-parse.y"
    { emit_operation_list (yyvsp[-1].oplist);
	    free_operation_list (yyvsp[-1].oplist);
	    filprintf (out_fil, "  NEXT_BC;\n");
	    yyval.text = yyvsp[-4].text;
	  }
    break;

  case 22:
#line 199 "genvm-parse.y"
    { c_args_on_paren = 1; }
    break;

  case 23:
#line 200 "genvm-parse.y"
    { yyval.oplist = append_to_operation_list (yyvsp[-6].oplist, yyvsp[-5].text, yyvsp[-2].id); }
    break;

  case 24:
#line 202 "genvm-parse.y"
    { yyval.oplist = NULL; }
    break;

  case 25:
#line 206 "genvm-parse.y"
    { yyval.id = yyvsp[0].id; }
    break;

  case 26:
#line 208 "genvm-parse.y"
    { yyval.id = NULL; }
    break;

  case 27:
#line 213 "genvm-parse.y"
    { yyval.id = append_to_id_list (yyvsp[-2].id, yyvsp[0].text); free (yyvsp[0].text); }
    break;

  case 28:
#line 215 "genvm-parse.y"
    { yyval.id = append_to_id_list (NULL, yyvsp[0].text); free (yyvsp[0].text); }
    break;

  case 29:
#line 219 "genvm-parse.y"
    { curr_fil = filnew (NULL, 0); }
    break;

  case 30:
#line 221 "genvm-parse.y"
    { yyval.text = fildelete (curr_fil); }
    break;

  case 31:
#line 225 "genvm-parse.y"
    { filcat (curr_fil, yyvsp[0].text); }
    break;

  case 32:
#line 227 "genvm-parse.y"
    { filcat (curr_fil, yyvsp[0].text); }
    break;

  case 33:
#line 229 "genvm-parse.y"
    { filcat (curr_fil, "("); }
    break;

  case 34:
#line 231 "genvm-parse.y"
    { filcat (curr_fil, ")"); }
    break;

  case 35:
#line 235 "genvm-parse.y"
    { yyval.text = yyvsp[0].text; }
    break;

  case 36:
#line 237 "genvm-parse.y"
    { asprintf (&yyval.text, "label%d", ++counter); }
    break;

  case 37:
#line 242 "genvm-parse.y"
    { curr_op = define_operation (yyvsp[0].text); c_code_on_brace = true; }
    break;

  case 38:
#line 244 "genvm-parse.y"
    { curr_fil = filnew (NULL, 0);
	    filprintf (curr_fil, "#line %d \"vm.def\"\n      ", yylineno + 1);
	  }
    break;

  case 39:
#line 248 "genvm-parse.y"
    { filprintf (curr_fil, "\n#line __oline__ \"vm.inl\"");
	    if (curr_op)
	      {
	        curr_op->args = yyvsp[-5].id;
	        curr_op->code = fildelete (curr_fil);
	        curr_op->needs_prepare_stack = strstr(curr_op->code,
					              "PREPARE_STACK") != NULL;
	        curr_op->needs_branch_label = strstr(curr_op->code,
					             "BRANCH_LABEL") != NULL;
	      }
	    yyval.op = curr_op;
	  }
    break;

  case 40:
#line 263 "genvm-parse.y"
    { yyval.id = append_to_id_list (yyvsp[-1].id, yyvsp[0].text); free (yyvsp[0].text); }
    break;

  case 41:
#line 265 "genvm-parse.y"
    { yyval.id = NULL; }
    break;

  case 42:
#line 269 "genvm-parse.y"
    { set_curr_op_stack (yyvsp[-3].id, yyvsp[-1].id); }
    break;

  case 43:
#line 272 "genvm-parse.y"
    { filcat (curr_fil, yyvsp[0].text); }
    break;


    }

/* Line 999 of yacc.c.  */
#line 1306 "genvm-parse.c"

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


#line 276 "genvm-parse.y"


void yyprint (FILE *fp, int tok, YYSTYPE *val)
{
  switch (tok)
    {
      case NUMBER:
        fprintf (fp, "%d", (val)->num);
        break;
      case ID:
      case EXPR:
        fprintf (fp, "%s", (val)->text);
        break;
    }
}

void
yyerror (const char *s)
{
  errors = 1;
  fprintf (stderr, "vm.def:%d: %s\n", yylineno, s);
}

/* Define an operation that is used into a bytecode declaration.
   We use an AVL tree to store them so that we can do fast
   searches, and we can detect duplicates.  */
operation_info *
define_operation (const char *name)
{
  avl_node_t **p = (avl_node_t **) &op_root;
  operation_info *node;
  operation_info *operation = NULL;

  while (*p)
    {
      int cmp;
      operation = (operation_info *) *p;

      cmp = strcmp(name, operation->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
        {
          yyerror ("duplicate operation");
          return NULL;
        }
    }

  node = (operation_info *) calloc(1, sizeof(operation_info));
  node->avl.avl_parent = (avl_node_t *) operation;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->name = name;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &op_root);
  return node;
}

operation_info *
get_operation (const char *name)
{
  avl_node_t **p = (avl_node_t **) &op_root;
  operation_info *operation = NULL;

  while (*p)
    {
      int cmp;
      operation = (operation_info *) *p;

      cmp = strcmp(name, operation->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
        return operation;
    }

  return NULL;
}

operation_list *
append_to_operation_list (operation_list *list, const char *name, id_list *args)
{
  operation_list *node, *result;
  operation_info *op = get_operation (name);

  if (!op)
    {
      yyerror ("undefined operation");
      return list;
    }

  node = calloc (1, sizeof (operation_list));
  if (!list)
    result = node;
  else
    {
      result = list;
      *(result->pnext) = node;
    }

  node->op = op;
  node->args = args;
  result->pnext = &(node->next);
  return result;
}

id_list *
append_to_id_list (id_list *list, const char *name)
{
  int len = strlen (name);
  id_list *node = calloc (1, sizeof (id_list) + len);
  id_list *result;
  memcpy (node->id, name, len);

  if (!list)
    result = node;
  else
    {
      result = list;
      *(result->pnext) = node;
    }

  result->pnext = &(node->next);
  return result;
}

int
emit_id_list (const id_list *list, const char *sep, const char *before, const char *after)
{
  int n = 0;
  if (!list)
    return 0;

  filcat (out_fil, before);
  while (list)
    {
      filcat (out_fil, list->id);
      list = list->next;
      filcat (out_fil, list ? sep : after);
      n++;
    }

  return n;
}

void
free_id_list (id_list *list)
{
  id_list *next;
  while (list)
    {
      next = list->next;
      free (list);
      list = next;
    }
}

void
set_curr_op_stack (id_list *in, id_list *out)
{
  id_list *read = in;
  id_list *list;
  id_list *last_read = NULL;
  if (!curr_op)
    return;

  /* Find the names that are a common prefix for the input and output
     stack, and move them to the READ list.  */
  while (in && out && !strcmp (in->id, out->id))
    {
      id_list *next;
      next = out->next;
      free (out);
      out = next;

      /* The in nodes are still referenced through READ. */
      last_read = in;
      in = in->next;
    }

  if (last_read)
    {
      if (in)
        in->pnext = read->pnext;
      last_read->next = NULL;
      read->pnext = &(last_read->next);
    }
  else
    /* The slots are all read and written, none is just read.  */
    read = NULL;

  curr_op->in = in;
  curr_op->out = out;
  curr_op->read = read;

  /* Compute and save the count, we'll use it to combine the
     stack effects.  */
  for (curr_op->n_in = 0, list = curr_op->in; list; list = list->next, curr_op->n_in++);
  for (curr_op->n_out = 0, list = curr_op->out; list; list = list->next, curr_op->n_out++);
  for (curr_op->n_read = 0, list = curr_op->read; list; list = list->next, curr_op->n_read++);
}

void
free_operation_list (operation_list *list)
{
  operation_list *next;
  while (list)
    {
      next = list->next;
      free_id_list (list->args);
      free (list);
      list = next;
    }
}

void
emit_var_declarations (const char *base, const char *type, int first, int n)
{
  int i;
  if (!n)
    return;

  for (i = first; n--; i++)
    filprintf (out_fil, "%s %s%d", i == first ? type : ",", base, i);

  filprintf (out_fil, ";\n");
}

void
emit_var_defines (id_list *list, int sp)
{
  for (; list; list = list->next, sp++)
    filprintf (out_fil, "#define %s %s%d\n", list->id,
	       (sp <= 0 ? "_stack" : "_extra"), (sp < 0 ? -sp : sp));
}

void
emit_operation_list (operation_list *oplist)
{
  operation_list *list;
  int deepest_read = 0, deepest_write = 0, sp,
      max_height = 0, deepest_write_so_far = 0, i;

  if (!oplist)
    return;

  filprintf (out_fil, "  {\n");

  /* Compute the overall effect on the stack of the superoperator.
     The number of elements that are read is usually op->n_read + op->n_in,
     but in the presence of many operations we need to adjust this for
     the balance left by previous operations; the same also holds for
     the number of written elements, which is usually op->in.

     We also track the maximum height of the stack which is the number
     of _EXTRA variables that we need.  */
  for (sp = 0, list = oplist; list; list = list->next)
    {
      operation_info *op = list->op;
      int balance = op->n_out - op->n_in;
      deepest_read = MAX (deepest_read, op->n_read + op->n_in - sp);
      deepest_write = MAX (deepest_write, op->n_in - sp);
      sp += balance;
      max_height = MAX (max_height, sp);
    }

  /* Declare the variables.  */
  emit_var_declarations ("_stack", "    OOP", 0, deepest_read);
  emit_var_declarations ("_extra", "    OOP", 1, max_height);

  /* Read the input items from the stack.  */
  for (i = deepest_read; --i >= 0; )
    filprintf (out_fil, "    _stack%d = STACK_AT (%d);\n", i, i);

  /* We keep track of the stack effect here too: we pass the current balance
     to emit_operation_invocation so that it can assign the correct
     _STACK/_EXTRA variables to the operands of OP, and we pass the
     number of dirty _STACK variables (tracked by DEEPEST_WRITE_SO_FAR)
     so that it can emit the PREPARE_STACK macro if necessary.  */
  for (sp = 0, list = oplist; list; list = list->next)
    {
      operation_info *op = list->op;
      int balance = op->n_out - op->n_in;
      emit_operation_invocation (op, list->args, sp, deepest_write_so_far);
      deepest_write_so_far = MAX (deepest_write_so_far, op->n_in - sp);
      sp += balance;
    }

  /* Write back to the stack the items that were overwritten, and
     emit pushes/pops if the height of the stack has changed.  */
  emit_stack_update (sp, deepest_write, "    ", ";");

  filprintf (out_fil, "  }\n");
}

void
emit_operation_invocation (operation_info *op, struct id_list *args, int sp, int deepest_write)
{
  id_list *list, *actual;

  filprintf (out_fil, "    /* %s (", op->name);
  emit_id_list (op->read, " ", " ", " |");
  emit_id_list (op->in, " ", " ", "");
  filprintf (out_fil, " --");
  emit_id_list (op->read, " ", " ", " |");
  emit_id_list (op->out, " ", " ", "");
  filprintf (out_fil, " ) */\n");

  filprintf (out_fil, "    do\n");
  filprintf (out_fil, "      {\n");

  /* Evaluate the arguments.  */
  for (list = op->args, actual = args; list && actual;
       list = list->next, actual = actual->next)
    filprintf (out_fil, "\tint %s = %s;\n", list->id, actual->id);

  if (list)
    yyerror ("too few parameters");
  if (actual)
    yyerror ("too many parameters");

  if (op->needs_prepare_stack)
    {
      filprintf (out_fil, "#define PREPARE_STACK() do { \\\n");
      emit_stack_update (sp, deepest_write, "    ", "; \\");
      filprintf (out_fil, "  } while (0)\n");
    }

  if (op->needs_branch_label)
    filprintf (out_fil,
	       "#define BRANCH_LABEL(local_label) %s_%d_##local_label\n",
	       op->name, op->instantiations++);

  /* Associate the temporary variables to the stack positions.  */
  emit_var_defines (op->read, sp - op->n_read - op->n_in + 1);
  emit_var_defines (op->in, sp - op->n_in + 1);
  emit_var_defines (op->out, sp - op->n_in + 1);

  filprintf (out_fil, "%s\n", op->code);

  /* Leave things clean.  */
  if (op->needs_branch_label)
    filprintf (out_fil, "#undef BRANCH_LABEL\n\n");

  if (op->needs_prepare_stack)
    filprintf (out_fil, "#undef PREPARE_STACK\n");

  emit_id_list (op->read, "\n#undef ", "#undef ", "\n");
  emit_id_list (op->in, "\n#undef ", "#undef ", "\n");
  emit_id_list (op->out, "\n#undef ", "#undef ", "\n");

  filprintf (out_fil, "      }\n");
  filprintf (out_fil, "    while (0);\n");
}

void
emit_stack_update (int sp, int deepest_write, const char *before, const char *after)
{
  int i;

  for (i = deepest_write; --i >= MAX(0, -sp); )
    filprintf (out_fil, "%sSTACK_AT (%d) = _stack%d%s\n", before, i, i, after);

  /* Either pop the input items in excess, or push the output ones.  */
  if (sp < 0)
    filprintf (out_fil, "%sPOP_N_OOPS (%d)%s\n", before, -sp, after);
  else
    for (i = 1; i <= sp; i++)
      filprintf (out_fil, "%sPUSH_OOP (_extra%d)%s\n", before, i, after);
}
 
void
emit_table (table_info *t)
{
  int i;
  printf ("  static void *%s[256] = {\n", t->name);
  for (i = 0; i < 256; i += 4)
    printf ("    %s%s, %s%s, %s%s, %s%s%c  /* %3d */\n",
	    t->entry[i] ? "&&" : "",
	    t->entry[i] ? t->entry[i] : "NULL",
	    t->entry[i+1] ? "&&" : "",
	    t->entry[i+1] ? t->entry[i+1] : "NULL",
	    t->entry[i+2] ? "&&" : "",
	    t->entry[i+2] ? t->entry[i+2] : "NULL",
	    t->entry[i+3] ? "&&" : "",
	    t->entry[i+3] ? t->entry[i+3] : "NULL",
	    i + 4 == 256 ? ' ' : ',', i);

  printf ("  };\n\n");
}

table_info *
define_table (char *name)
{
  table_info *t = (table_info *) calloc(1, sizeof(table_info));
  t->name = name;

  return t;  
}

void
set_table (table_info *t, int from, int to, char *value)
{
  int i;
  id_list **p_last = t->pool ? t->pool->pnext : &t->pool;
  id_list *last;
  t->pool = append_to_id_list (t->pool, value);
  last = *p_last;

  for (i = from; i <= to; i++)
    t->entry[i] = last->id;
}

void
free_table (table_info *t)
{
  free_id_list (t->pool);
  free (t->name);
  free (t);
}

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

int
main ()
{
  char *code;
  errors = 0;

  printf ("/* Automatically generated by genvm, do not edit!  */\n");

  out_fil = filnew (NULL, 0);
  if (yyparse () || errors)
    exit (1);

  printf ("  goto jump_around;\n");
  code = fildelete (out_fil);
  fputs (code, stdout);
  printf ("jump_around:\n  ;\n");

  exit (0);
}

