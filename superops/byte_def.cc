/////////////////////////////// -*- C++ -*- ///////////////////////////
//
//	Program to extract superoperators from a GNU Smalltalk image.
//	byte.def creation routines.
//
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
//
// Copyright 2003, 2007 Free Software Foundation, Inc.
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
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>

namespace {

struct bytecode {
  static bytecode *bytecodes[256];

  std::string str;
  int num;

  bytecode (int _num);
  bytecode (int _num, const char *_str);
  virtual void write_byte_def (std::ostream &os);
  virtual void write_byte_def_ext_arg (std::ostream &os, int arg) = 0;
  virtual void write_byte_def_fixed_arg (std::ostream &os, int arg) = 0;
  virtual void write_byte_def_var_arg (std::ostream &os) = 0;
};

struct bytecode_elementary : bytecode {
  const char *name;
  bytecode_elementary (int _num, const char *_name, const char *_str);
};

struct bytecode_noarg : bytecode_elementary {
  bytecode_noarg (int _num, const char *_name, const char *_str);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_fast_send : bytecode_noarg {
  bytecode_fast_send (int _num, const char *_name, const char *_str);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
};

struct bytecode_invalid : bytecode {
  bytecode_invalid (int _num);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_unary : bytecode_elementary {
  bytecode_unary (int _num, const char *_name, const char *_str);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_ext : bytecode_elementary {
  bytecode_ext (int _num, const char *_name, const char *_str);
  void write_byte_def (std::ostream &os);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_jump : bytecode_elementary {
  const char *sign;
  bytecode_jump (int _num, const char *_name, bool minus, const char *_str);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_binary : bytecode_elementary {
  bytecode_binary (int _num, const char *_name, const char *_str);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_send : bytecode_elementary {
  bytecode_send (int _num, const char *_name, const char *_str);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_send_imm : bytecode_elementary {
  bytecode_send_imm (int _num, const char *_name, const char *_str);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_superoperator : bytecode {
  bytecode *bc1, *bc2;
  int fixed_arg;

  bytecode_superoperator (int _num, int _bc1, int _bc2, int _arg);
};

struct bytecode_with_fixed_arg_1 : bytecode_superoperator {
  bytecode_with_fixed_arg_1 (int _num, int _bc1, int _bc2, int _arg);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

struct bytecode_with_fixed_arg_2 : bytecode_superoperator {
  bytecode_with_fixed_arg_2 (int _num, int _bc1, int _bc2, int _arg);
  void write_byte_def_ext_arg (std::ostream &os, int arg);
  void write_byte_def_fixed_arg (std::ostream &os, int arg);
  void write_byte_def_var_arg (std::ostream &os);
};

void
bytecode::write_byte_def (std::ostream & os)
{
  os << "/* " << str << " */" << std::endl;
  os << num << " {" << std::endl;
  os << "  extract opcode (8), arg_lsb (8);" << std::endl;
  write_byte_def_var_arg (os);
  os << "}" << std::endl << std::endl;
};

bytecode::bytecode (int _num):
  num (_num), str ()
{
  bytecodes[num] = this;
};

bytecode::bytecode (int _num, const char *_str):
  num (_num), str (_str)
{
  bytecodes[num] = this;
};

bytecode_elementary::bytecode_elementary (int _num, const char *_name,
					  const char *_str):
  bytecode (_num, _str), name (_name)
{
};

bytecode_noarg::bytecode_noarg (int _num, const char *_name,
				const char *_str):
  bytecode_elementary (_num, _name, _str)
{
};

void
bytecode_noarg::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  write_byte_def_fixed_arg (os, arg);
}

void
bytecode_noarg::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << ';' << std::endl;
}

void
bytecode_noarg::write_byte_def_var_arg (std::ostream & os)
{
  write_byte_def_fixed_arg (os, 0);
}

bytecode_fast_send::bytecode_fast_send (int _num, const char *_name,
					const char *_str):
  bytecode_noarg (_num, _name, _str)
{
};

void
bytecode_fast_send::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << (num & 15) << ");" << std::endl;
}

bytecode_invalid::bytecode_invalid (int _num):
  bytecode (_num, "invalid bytecode")
{
};

void
bytecode_invalid::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  abort ();
}

void
bytecode_invalid::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  abort ();
}

void
bytecode_invalid::write_byte_def_var_arg (std::ostream & os)
{
  os << "  dispatch INVALID (" << num << ", arg | arg_lsb);" << std::endl;
}

bytecode_unary::bytecode_unary (int _num, const char *_name,
				const char *_str):
  bytecode_elementary (_num, _name, _str)
{
};

void
bytecode_unary::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << (arg << 8) << " | arg_lsb);"
    << std::endl;
}

void
bytecode_unary::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << arg << ");" << std::endl;
}

void
bytecode_unary::write_byte_def_var_arg (std::ostream & os)
{
  os << "  dispatch " << name << " (arg | arg_lsb);" << std::endl;
}

bytecode_ext::bytecode_ext (int _num, const char *_name, const char *_str):
  bytecode_elementary (_num, _name, _str)
{
};

void
bytecode_ext::write_byte_def (std::ostream & os)
{
  os << "/* " << str << " */" << std::endl;
  os << num << " {" << std::endl;
  os << "  extract opcode (8), arg_lsb (8);" << std::endl;
  write_byte_def_var_arg (os);
  os << "  continue;" << std::endl;
  os << "}" << std::endl << std::endl;
};

void
bytecode_ext::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  write_byte_def_fixed_arg (os, arg);
  write_byte_def_var_arg (os);
}

void
bytecode_ext::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  arg = (arg | " << arg << ") << 8);" << std::endl;
}

void
bytecode_ext::write_byte_def_var_arg (std::ostream & os)
{
  os << "  arg = (arg | arg_lsb) << 8;" << std::endl;
}

bytecode_jump::bytecode_jump (int _num, const char *_name, bool minus,
			      const char *_str):
  bytecode_elementary (_num, _name, _str)
{
  sign = minus ? "IP - IP0 - " : "IP - IP0 + ";
}

void
bytecode_jump::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << sign << '(' << (arg << 8)
    << " | arg_lsb));" << std::endl;
}

void
bytecode_jump::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << sign << arg << "));" << std::endl;
}

void
bytecode_jump::write_byte_def_var_arg (std::ostream & os)
{
  os << "  dispatch " << name << " (" << sign << "(arg | arg_lsb));"
    << std::endl;
}

bytecode_binary::bytecode_binary (int _num, const char *_name,
				  const char *_str):
  bytecode_elementary (_num, _name, _str)
{
};

void
bytecode_binary::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (arg | arg_lsb, "
    << arg << ");" << std::endl;
}

void
bytecode_binary::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << (arg >> 8) << ", "
    << (arg & 255) << ");" << std::endl;
}

void
bytecode_binary::write_byte_def_var_arg (std::ostream & os)
{
  os << "  dispatch " << name << " (arg >> 8, arg_lsb);" << std::endl;
}

bytecode_send::bytecode_send (int _num, const char *_name, const char *_str):
  bytecode_elementary (_num, _name, _str)
{
};

void
bytecode_send::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (arg | arg_lsb, "
    << (num & 1) << ", " << arg << ");" << std::endl;
}

void
bytecode_send::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << (arg >> 8) << ", "
    << (num & 1) << ", " << (arg & 255) << ");" << std::endl;
}

void
bytecode_send::write_byte_def_var_arg (std::ostream & os)
{
  os << "  dispatch " << name << " (arg >> 8, "
    << (num & 1) << ", arg_lsb);" << std::endl;
}

bytecode_send_imm::bytecode_send_imm (int _num, const char *_name,
				      const char *_str):
  bytecode_elementary (_num, _name, _str)
{
};

void
bytecode_send_imm::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << (arg << 8) << " | arg_lsb, "
    << (num & 1) << ");" << std::endl;
}

void
bytecode_send_imm::write_byte_def_fixed_arg (std::ostream & os, int arg)
{
  os << "  dispatch " << name << " (" << arg << ", "
    << (num & 1) << ");" << std::endl;
}

void
bytecode_send_imm::write_byte_def_var_arg (std::ostream & os)
{
  os << "  dispatch " << name << " (arg | arg_lsb, "
    << (num & 1) << ");" << std::endl;
}

bytecode_superoperator::bytecode_superoperator (int _num, int _bc1, int _bc2,
						int _arg):
  bytecode (_num), bc1 (bytecodes[_bc1]), bc2 (bytecodes[_bc2]),
  fixed_arg (_arg)
{
  if (!bc1 || !bc2)
    abort ();
}

bytecode_with_fixed_arg_1::bytecode_with_fixed_arg_1 (int _num, int _bc1,
						      int _bc2, int _arg):
  bytecode_superoperator (_num, _bc1, _bc2, _arg)
{
  std::string::iterator i;
  std::ostringstream os;
  os << _arg;

  str.append (bc1->str);
  str.append ("\n   ");
  str.append (bc2->str);
  for (i = str.begin (); *i != '*'; i++);
  str.replace (i, i + 1, os.str ());
}

void
bytecode_with_fixed_arg_1::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  abort ();
}

void
bytecode_with_fixed_arg_1::write_byte_def_fixed_arg (std::ostream & os,
						     int arg)
{
  bc1->write_byte_def_fixed_arg (os, fixed_arg);
  bc2->write_byte_def_fixed_arg (os, arg);
}

void
bytecode_with_fixed_arg_1::write_byte_def_var_arg (std::ostream & os)
{
  bc1->write_byte_def_fixed_arg (os, fixed_arg);
  bc2->write_byte_def_var_arg (os);
}

bytecode_with_fixed_arg_2::bytecode_with_fixed_arg_2 (int _num, int _bc1,
						      int _bc2, int _arg):
  bytecode_with_fixed_arg_2::bytecode_superoperator (_num, _bc1, _bc2, _arg)
{
  std::string::iterator i;
  std::ostringstream os;
  os << _arg;

  str.append (bc1->str);
  str.append ("\n   ");
  str.append (bc2->str);
  for (i = str.end (); *--i != '*';);
  str.replace (i, i + 1, os.str ());
}

void
bytecode_with_fixed_arg_2::write_byte_def_ext_arg (std::ostream & os, int arg)
{
  abort ();
}

void
bytecode_with_fixed_arg_2::write_byte_def_fixed_arg (std::ostream & os,
						     int arg)
{
  if (bc1 == bytecodes[EXT_BYTE])
    bc2->write_byte_def_fixed_arg (os, (arg << 8) + fixed_arg);
  else
    {
      bc1->write_byte_def_fixed_arg (os, arg);
      bc2->write_byte_def_fixed_arg (os, fixed_arg);
    }
}

void
bytecode_with_fixed_arg_2::write_byte_def_var_arg (std::ostream & os)
{
  if (bc1 == bytecodes[EXT_BYTE])
    bc2->write_byte_def_ext_arg (os, fixed_arg);
  else
    {
      bc1->write_byte_def_var_arg (os);
      bc2->write_byte_def_fixed_arg (os, fixed_arg);
    }
}

bytecode *bytecode::bytecodes[256];

bytecode_fast_send bc0 (0, "SEND_ARITH", "PLUS_SPECIAL(*)");
bytecode_fast_send bc1 (1, "SEND_ARITH", "MINUS_SPECIAL(*)");
bytecode_fast_send bc2 (2, "SEND_ARITH", "LESS_THAN_SPECIAL(*)");
bytecode_fast_send bc3 (3, "SEND_ARITH", "GREATER_THAN_SPECIAL(*)");
bytecode_fast_send bc4 (4, "SEND_ARITH", "LESS_EQUAL_SPECIAL(*)");
bytecode_fast_send bc5 (5, "SEND_ARITH", "GREATER_EQUAL_SPECIAL(*)");
bytecode_fast_send bc6 (6, "SEND_ARITH", "EQUAL_SPECIAL(*)");
bytecode_fast_send bc7 (7, "SEND_ARITH", "NOT_EQUAL_SPECIAL(*)");
bytecode_fast_send bc8 (8, "SEND_ARITH", "TIMES_SPECIAL(*)");
bytecode_fast_send bc9 (9, "SEND_ARITH", "DIVIDE_SPECIAL(*)");
bytecode_fast_send bc10 (10, "SEND_ARITH", "REMAINDER_SPECIAL(*)");
bytecode_fast_send bc11 (11, "SEND_ARITH", "BIT_XOR_SPECIAL(*)");
bytecode_fast_send bc12 (12, "SEND_ARITH", "BIT_SHIFT_SPECIAL(*)");
bytecode_fast_send bc13 (13, "SEND_ARITH", "INTEGER_DIVIDE_SPECIAL(*)");
bytecode_fast_send bc14 (14, "SEND_ARITH", "BIT_AND_SPECIAL(*)");
bytecode_fast_send bc15 (15, "SEND_ARITH", "BIT_OR_SPECIAL(*)");
bytecode_fast_send bc16 (16, "SEND_SPECIAL", "AT_SPECIAL(*)");
bytecode_fast_send bc17 (17, "SEND_SPECIAL", "AT_PUT_SPECIAL(*)");
bytecode_fast_send bc18 (18, "SEND_SPECIAL", "SIZE_SPECIAL(*)");
bytecode_fast_send bc19 (19, "SEND_SPECIAL", "CLASS_SPECIAL(*)");
bytecode_fast_send bc20 (20, "SEND_SPECIAL", "IS_NIL_SPECIAL(*)");
bytecode_fast_send bc21 (21, "SEND_SPECIAL", "NOT_NIL_SPECIAL(*)");
bytecode_fast_send bc22 (22, "SEND_SPECIAL", "VALUE_SPECIAL(*)");
bytecode_fast_send bc23 (23, "SEND_SPECIAL", "VALUE_COLON_SPECIAL(*)");
bytecode_fast_send bc24 (24, "SEND_SPECIAL", "SAME_OBJECT_SPECIAL(*)");
bytecode_fast_send bc25 (25, "SEND_SPECIAL", "JAVA_AS_INT_SPECIAL(*)");
bytecode_fast_send bc26 (26, "SEND_SPECIAL", "JAVA_AS_LONG_SPECIAL(*)");
bytecode_send bc28 (28, "SEND", "SEND(*)");
bytecode_send bc29 (29, "SEND", "SEND_SUPER(*)");
bytecode_send_imm bc30 (30, "SEND_IMMEDIATE", "SEND_IMMEDIATE(*)");
bytecode_send_imm bc31 (31, "SEND_IMMEDIATE", "SEND_SUPER_IMMEDIATE(*)");
bytecode_unary bc32 (32, "PUSH_TEMPORARY_VARIABLE", "PUSH_TEMPORARY_VARIABLE(*)");
bytecode_binary bc33 (33, "PUSH_OUTER_TEMP", "PUSH_OUTER_TEMP(*)");
bytecode_unary bc34 (34, "PUSH_LIT_VARIABLE", "PUSH_LIT_VARIABLE(*)");
bytecode_unary bc35 (35, "PUSH_RECEIVER_VARIABLE", "PUSH_RECEIVER_VARIABLE(*)");
bytecode_unary bc36 (36, "STORE_TEMPORARY_VARIABLE", "STORE_TEMPORARY_VARIABLE(*)");
bytecode_binary bc37 (37, "STORE_OUTER_TEMP", "STORE_OUTER_TEMP(*)");
bytecode_unary bc38 (38, "STORE_LIT_VARIABLE", "STORE_LIT_VARIABLE(*)");
bytecode_unary bc39 (39, "STORE_RECEIVER_VARIABLE", "STORE_RECEIVER_VARIABLE(*)");
bytecode_jump bc40 (40, "JUMP", true, "JUMP_BACK(*)");
bytecode_jump bc41 (41, "JUMP", false, "JUMP(*)");
bytecode_jump bc42 (42, "POP_JUMP_TRUE", false, "POP_JUMP_TRUE(*)");
bytecode_jump bc43 (43, "POP_JUMP_FALSE", false, "POP_JUMP_FALSE(*)");
bytecode_unary bc44 (44, "PUSH_INTEGER", "PUSH_INTEGER(*)");
bytecode_unary bc45 (45, "PUSH_SPECIAL", "PUSH_SPECIAL(*)");
bytecode_unary bc46 (46, "PUSH_LIT_CONSTANT", "PUSH_LIT_CONSTANT(*)");
bytecode_unary bc47 (47, "POP_INTO_NEW_STACKTOP", "POP_INTO_NEW_STACKTOP(*)");
bytecode_noarg bc48 (48, "POP_STACK_TOP", "POP_STACK_TOP(*)");
bytecode_noarg bc49 (49, "MAKE_DIRTY_BLOCK", "MAKE_DIRTY_BLOCK(*)");
bytecode_noarg bc50 (50, "RETURN_METHOD_STACK_TOP", "RETURN_METHOD_STACK_TOP(*)");
bytecode_noarg bc51 (51, "RETURN_CONTEXT_STACK_TOP", "RETURN_CONTEXT_STACK_TOP(*)");
bytecode_noarg bc52 (52, "DUP_STACK_TOP", "DUP_STACK_TOP(*)");
bytecode_noarg bc53 (53, "EXIT_INTERPRETER", "EXIT_INTERPRETER(*)");
bytecode_unary bc54 (54, "LINE_NUMBER_BYTECODE", "LINE_NUMBER_BYTECODE(*)");
bytecode_ext bc55 (55, "EXT_BYTE", "EXT_BYTE(*)");
bytecode_noarg bc56 (56, "PUSH_SELF", "PUSH_SELF(*)");

}

byte_def_builder::byte_def_builder () : fs ("byte.def")
{
  fs << "/* Automatically generated by superops.  Do not modify past this line!  */" << std::endl;
  for (int i = 0; i < 64; i++)
    {
      if (!bytecode::bytecodes[i])
        bytecode::bytecodes[i] = new bytecode_invalid (i);

      bytecode::bytecodes[i]->write_byte_def (fs);
    }
}

byte_def_builder::~byte_def_builder ()
{
  std::cout << "genbc script (recognizer) written to byte.def." << std::endl;
}

void byte_def_builder::with_fixed_arg_1 (int new_bc,
				       int bc1, int arg, int bc2)
{
  bytecode *bc = new bytecode_with_fixed_arg_1 (new_bc, bc1, bc2, arg);
  bc->write_byte_def (fs);

  std::string short_str = bc->str;
  int n;
  while ((n = short_str.find ("\n ")) > -1)
    short_str.replace (n, 3, ",");

  std::cout << short_str << std::endl;
}

void byte_def_builder::with_fixed_arg_2 (int new_bc,
				       int bc1, int bc2, int arg)
{
  bytecode *bc = new bytecode_with_fixed_arg_2 (new_bc, bc1, bc2, arg);

  bc->write_byte_def (fs);

  std::string short_str = bc->str;
  int n;
  while ((n = short_str.find ("\n ")) > -1)
    short_str.replace (n, 3, ",");

  std::cout << short_str << std::endl;
}
