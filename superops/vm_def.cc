/////////////////////////////// -*- C++ -*- ///////////////////////////
//
//	Program to extract superoperators from a GNU Smalltalk image.
//	vm.def creation routines.
//
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
//
// Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
// Written by Paolo Bonzini.
//
// This file is part of GNU Smalltalk.
//
// GNU Smalltalk is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2, or (at your option) any later
// version.
//
// GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
//
// You should have received a copy of the GNU General Public License along with
// GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
// Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//
///////////////////////////////////////////////////////////////////////

#if defined __GNUC__ && __GNUC__ < 3
#error Sorry, you need a recent C++ compiler to compile this program.
#endif

#include "byte_def.h"
#include "vm_def.h"
#include <cstdlib>
#include <iostream>
#include <fstream>

namespace {

struct bytecode {
  static bytecode *bytecodes[256];

  int num;

  bytecode (int _num);
  virtual void write_prefetch (std::ostream &os);
  virtual void write_vm_def (std::ostream &os);
  virtual void write_vm_def_ext_arg (std::ostream &os, int arg) = 0;
  virtual void write_vm_def_fixed_arg (std::ostream &os, int arg) = 0;
  virtual void write_vm_def_var_arg (std::ostream &os) = 0;
};

struct bytecode_elementary : bytecode {
  const char *name;
  bytecode_elementary (int _num, const char *_name);
};

struct bytecode_noarg : bytecode_elementary {
  bytecode_noarg (int _num, const char *_name);
  void write_vm_def_ext_arg (std::ostream &os, int arg);
  void write_vm_def_fixed_arg (std::ostream &os, int arg);
  void write_vm_def_var_arg (std::ostream &os);
};

struct bytecode_unary : bytecode_elementary {
  bytecode_unary (int _num, const char *_name);
  void write_vm_def_ext_arg (std::ostream &os, int arg);
  void write_vm_def_fixed_arg (std::ostream &os, int arg);
  void write_vm_def_var_arg (std::ostream &os);
};

struct bytecode_jump : bytecode_unary {
  bytecode_jump (int _num, const char *_name);
  void write_prefetch (std::ostream &os);
};

struct bytecode_ext : bytecode_noarg {
  bytecode_ext (int _num, const char *_name);
  void write_vm_def (std::ostream &os);
  void write_vm_def_ext_arg (std::ostream &os, int arg);
};

struct bytecode_binary : bytecode_elementary {
  bytecode_binary (int _num, const char *_name);
  void write_vm_def_ext_arg (std::ostream &os, int arg);
  void write_vm_def_fixed_arg (std::ostream &os, int arg);
  void write_vm_def_var_arg (std::ostream &os);
};

struct bytecode_superoperator : bytecode {
  bytecode *bc1, *bc2;
  int fixed_arg;

  bytecode_superoperator (int _num, int _bc1, int _bc2, int _arg);
  void write_prefetch (std::ostream &os);
};

struct bytecode_with_fixed_arg_1 : bytecode_superoperator {
  bytecode_with_fixed_arg_1 (int _num, int _bc1, int _bc2, int _arg);
  void write_vm_def_ext_arg (std::ostream &os, int arg);
  void write_vm_def_fixed_arg (std::ostream &os, int arg);
  void write_vm_def_var_arg (std::ostream &os);
};

struct bytecode_with_fixed_arg_2 : bytecode_superoperator {
  bytecode_with_fixed_arg_2 (int _num, int _bc1, int _bc2, int _arg);
  void write_vm_def_ext_arg (std::ostream &os, int arg);
  void write_vm_def_fixed_arg (std::ostream &os, int arg);
  void write_vm_def_var_arg (std::ostream &os);
};

void
bytecode::write_prefetch (std::ostream & os)
{
  os << "    PREFETCH ();" << std::endl;
}

void
bytecode::write_vm_def (std::ostream & os)
{
  os << "  " << num << " = bytecode bc" << num << " {" << std::endl;
  write_prefetch (os);
  write_vm_def_var_arg (os);
  os << "  }" << std::endl << std::endl;
};

bytecode::bytecode (int _num):
  num (_num)
{
  bytecodes[num] = this;
};

bytecode_elementary::bytecode_elementary (int _num, const char *_name):
  bytecode (_num), name (_name)
{
};

bytecode_noarg::bytecode_noarg (int _num, const char *_name):
  bytecode_elementary (_num, _name)
{
};

void
bytecode_noarg::write_vm_def_ext_arg (std::ostream & os, int arg)
{
  write_vm_def_fixed_arg (os, arg);
}

void
bytecode_noarg::write_vm_def_fixed_arg (std::ostream & os, int arg)
{
  os << "    " << name << " ();" << std::endl;
}

void
bytecode_noarg::write_vm_def_var_arg (std::ostream & os)
{
  write_vm_def_fixed_arg (os, 0);
}

bytecode_unary::bytecode_unary (int _num, const char *_name):
  bytecode_elementary (_num, _name)
{
};

void
bytecode_unary::write_vm_def_ext_arg (std::ostream & os, int arg)
{
  os << "    " << name << " (" << (arg << 8) << " | arg);"
    << std::endl;
}

void
bytecode_unary::write_vm_def_fixed_arg (std::ostream & os, int arg)
{
  os << "    " << name << " (" << arg << ");" << std::endl;
}

void
bytecode_unary::write_vm_def_var_arg (std::ostream & os)
{
  os << "    " << name << " (arg);" << std::endl;
}

bytecode_jump::bytecode_jump (int _num, const char *_name):
  bytecode_unary (_num, _name)
{
};

void
bytecode_jump::write_prefetch (std::ostream & os)
{
  os << "    ADVANCE ();" << std::endl;
}

bytecode_ext::bytecode_ext (int _num, const char *_name):
  bytecode_noarg (_num, _name)
{
};

void
bytecode_ext::write_vm_def (std::ostream & os)
{
  os << "  " << num << " = bytecode bc" << num << " {" << std::endl;
  write_vm_def_var_arg (os);
  os << "  }" << std::endl << std::endl;
};

void
bytecode_ext::write_vm_def_ext_arg (std::ostream & os, int arg)
{
  abort ();
}

bytecode_binary::bytecode_binary (int _num, const char *_name):
  bytecode_elementary (_num, _name)
{
};

void
bytecode_binary::write_vm_def_ext_arg (std::ostream & os, int arg)
{
  os << "    " << name << " (arg, " << arg << ");" << std::endl;
}

void
bytecode_binary::write_vm_def_fixed_arg (std::ostream & os, int arg)
{
  os << "    " << name << " (" << (arg >> 8) << ", "
    << (arg & 255) << ");" << std::endl;
}

void
bytecode_binary::write_vm_def_var_arg (std::ostream & os)
{
  os << "    " << name << " (arg >> 8, arg & 255);" << std::endl;
}

bytecode_superoperator::bytecode_superoperator (int _num, int _bc1, int _bc2,
						int _arg):
  bytecode (_num), bc1 (bytecodes[_bc1]), bc2 (bytecodes[_bc2]),
  fixed_arg (_arg)
{
  if (!bc1 || !bc2)
    abort ();
}

void
bytecode_superoperator::write_prefetch (std::ostream & os)
{
  bc2->write_prefetch (os);
}

bytecode_with_fixed_arg_1::bytecode_with_fixed_arg_1 (int _num, int _bc1,
						      int _bc2, int _arg):
  bytecode_superoperator (_num, _bc1, _bc2, _arg)
{
}

void
bytecode_with_fixed_arg_1::write_vm_def_ext_arg (std::ostream & os, int arg)
{
  abort ();
}

void
bytecode_with_fixed_arg_1::write_vm_def_fixed_arg (std::ostream & os,
						     int arg)
{
  bc1->write_vm_def_fixed_arg (os, fixed_arg);
  bc2->write_vm_def_fixed_arg (os, arg);
}

void
bytecode_with_fixed_arg_1::write_vm_def_var_arg (std::ostream & os)
{
  bc1->write_vm_def_fixed_arg (os, fixed_arg);
  bc2->write_vm_def_var_arg (os);
}

bytecode_with_fixed_arg_2::bytecode_with_fixed_arg_2 (int _num, int _bc1,
						      int _bc2, int _arg):
  bytecode_with_fixed_arg_2::bytecode_superoperator (_num, _bc1, _bc2, _arg)
{
}

void
bytecode_with_fixed_arg_2::write_vm_def_ext_arg (std::ostream & os, int arg)
{
  abort ();
}

void
bytecode_with_fixed_arg_2::write_vm_def_fixed_arg (std::ostream & os,
						     int arg)
{
  if (bc1 == bytecodes[EXT_BYTE])
    bc2->write_vm_def_fixed_arg (os, (arg << 8) + fixed_arg);
  else
    {
      bc1->write_vm_def_fixed_arg (os, arg);
      bc2->write_vm_def_fixed_arg (os, fixed_arg);
    }
}

void
bytecode_with_fixed_arg_2::write_vm_def_var_arg (std::ostream & os)
{
  if (bc1 == bytecodes[EXT_BYTE])
    bc2->write_vm_def_ext_arg (os, fixed_arg);
  else
    {
      bc1->write_vm_def_var_arg (os);
      bc2->write_vm_def_fixed_arg (os, fixed_arg);
    }
}

bytecode *bytecode::bytecodes[256];

bytecode_noarg bc0 (0, "PLUS_SPECIAL");
bytecode_noarg bc1 (1, "MINUS_SPECIAL");
bytecode_noarg bc2 (2, "LESS_THAN_SPECIAL");
bytecode_noarg bc3 (3, "GREATER_THAN_SPECIAL");
bytecode_noarg bc4 (4, "LESS_EQUAL_SPECIAL");
bytecode_noarg bc5 (5, "GREATER_EQUAL_SPECIAL");
bytecode_noarg bc6 (6, "EQUAL_SPECIAL");
bytecode_noarg bc7 (7, "NOT_EQUAL_SPECIAL");
bytecode_noarg bc8 (8, "TIMES_SPECIAL");
bytecode_noarg bc9 (9, "DIVIDE_SPECIAL");
bytecode_noarg bc10 (10, "REMAINDER_SPECIAL");
bytecode_noarg bc11 (11, "BIT_XOR_SPECIAL");
bytecode_noarg bc12 (12, "BIT_SHIFT_SPECIAL");
bytecode_noarg bc13 (13, "INTEGER_DIVIDE_SPECIAL");
bytecode_noarg bc14 (14, "BIT_AND_SPECIAL");
bytecode_noarg bc15 (15, "BIT_OR_SPECIAL");
bytecode_noarg bc16 (16, "AT_SPECIAL");
bytecode_noarg bc17 (17, "AT_PUT_SPECIAL");
bytecode_noarg bc18 (18, "SIZE_SPECIAL");
bytecode_noarg bc19 (19, "CLASS_SPECIAL");
bytecode_noarg bc20 (20, "IS_NIL_SPECIAL");
bytecode_noarg bc21 (21, "NOT_NIL_SPECIAL");
bytecode_noarg bc22 (22, "VALUE_SPECIAL");
bytecode_noarg bc23 (23, "VALUE_COLON_SPECIAL");
bytecode_noarg bc24 (24, "SAME_OBJECT_SPECIAL");
bytecode_noarg bc25 (25, "JAVA_AS_INT_SPECIAL");
bytecode_noarg bc26 (26, "JAVA_AS_LONG_SPECIAL");
bytecode_binary bc28 (28, "SEND");
bytecode_binary bc29 (29, "SEND_SUPER");
bytecode_unary bc30 (30, "SEND_IMMEDIATE");
bytecode_unary bc31 (31, "SEND_SUPER_IMMEDIATE");
bytecode_unary bc32 (32, "PUSH_TEMPORARY_VARIABLE");
bytecode_binary bc33 (33, "PUSH_OUTER_TEMP");
bytecode_unary bc34 (34, "PUSH_LIT_VARIABLE");
bytecode_unary bc35 (35, "PUSH_RECEIVER_VARIABLE");
bytecode_unary bc36 (36, "STORE_TEMPORARY_VARIABLE");
bytecode_binary bc37 (37, "STORE_OUTER_TEMP");
bytecode_unary bc38 (38, "STORE_LIT_VARIABLE");
bytecode_unary bc39 (39, "STORE_RECEIVER_VARIABLE");
bytecode_jump bc40 (40, "JUMP_BACK");
bytecode_jump bc41 (41, "JUMP");
bytecode_unary bc42 (42, "POP_JUMP_TRUE");
bytecode_unary bc43 (43, "POP_JUMP_FALSE");
bytecode_unary bc44 (44, "PUSH_INTEGER");
bytecode_unary bc45 (45, "PUSH_SPECIAL");
bytecode_unary bc46 (46, "PUSH_LIT_CONSTANT");
bytecode_unary bc47 (47, "POP_INTO_NEW_STACKTOP");
bytecode_noarg bc48 (48, "POP_STACK_TOP");
bytecode_noarg bc49 (49, "MAKE_DIRTY_BLOCK");
bytecode_noarg bc50 (50, "RETURN_METHOD_STACK_TOP");
bytecode_noarg bc51 (51, "RETURN_CONTEXT_STACK_TOP");
bytecode_noarg bc52 (52, "DUP_STACK_TOP");
bytecode_noarg bc53 (53, "EXIT_INTERPRETER");
bytecode_noarg bc54 (54, "LINE_NUMBER_BYTECODE");
bytecode_ext bc55 (55, "EXT_BYTE");
bytecode_noarg bc56 (56, "PUSH_SELF");

}

vm_def_builder::vm_def_builder () : fs ("vm.def")
{
  fs << "/* Automatically generated by superops.  Do not modify past this line!  */" << std::endl;
  fs << "table normal_byte_codes {" << std::endl;

  for (int i = 0; i < 64; i++)
    {
      if (!bytecode::bytecodes[i])
        bytecode::bytecodes[i] = new bytecode_unary (i, "INVALID");

      bytecode::bytecodes[i]->write_vm_def (fs);
    }
}

vm_def_builder::~vm_def_builder () 
{
  fs << "}";
  std::cout << "genvm script (interpreter) written to vm.def." << std::endl;
}

void vm_def_builder::with_fixed_arg_1 (int new_bc,
				       int bc1, int arg, int bc2)
{
  (new bytecode_with_fixed_arg_1 (new_bc, bc1, bc2, arg))->write_vm_def (fs);
}

void vm_def_builder::with_fixed_arg_2 (int new_bc,
				       int bc1, int bc2, int arg)
{
  (new bytecode_with_fixed_arg_2 (new_bc, bc1, bc2, arg))->write_vm_def (fs);
}

