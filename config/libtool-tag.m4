dnl I'd like this to be edited in -*- Autoconf -*- mode...
dnl
dnl GST_LIBTOOL_TAG(TAGNAME, LANGUAGE, ADDITIONAL-CODE)
dnl Define an additional libtool tag called TAGNAME based on the
dnl language LANGUAGE (which can be C, CXX, F77, GCJ), with
dnl the additional tests in ADDITIONAL-CODE performed before
dnl appending the configuration to the libtool script.
dnl
AC_DEFUN([GST_LIBTOOL_TAG], [

tagname=$1
m4_define([GST_SRC_TAG], m4_if([$2], [], [$1], [$2]))
m4_define([GST_SRC_TAG], m4_if(GST_SRC_TAG, [CC], [], GST_SRC_TAG))

_LT_AC_TAGVAR(build_libtool_need_lc, $1)=$_LT_AC_TAGVAR(build_libtool_need_lc, GST_SRC_TAG)
_LT_AC_TAGVAR(with_gcc, $1)=$_LT_AC_TAGVAR(with_gcc, GST_SRC_TAG)
_LT_AC_TAGVAR(compiler, $1)=$_LT_AC_TAGVAR(compiler, GST_SRC_TAG)
_LT_AC_TAGVAR(CC, $1)=$_LT_AC_TAGVAR(CC, GST_SRC_TAG)
_LT_AC_TAGVAR(LD, $1)=$_LT_AC_TAGVAR(LD, GST_SRC_TAG)
_LT_AC_TAGVAR(lt_prog_compiler_wl, $1)=$_LT_AC_TAGVAR(lt_prog_compiler_wl, GST_SRC_TAG)
_LT_AC_TAGVAR(lt_prog_compiler_pic, $1)=$_LT_AC_TAGVAR(lt_prog_compiler_pic, GST_SRC_TAG)
_LT_AC_TAGVAR(lt_prog_compiler_static, $1)=$_LT_AC_TAGVAR(lt_prog_compiler_static, GST_SRC_TAG)
_LT_AC_TAGVAR(lt_prog_compiler_no_builtin_flag, $1)=$_LT_AC_TAGVAR(lt_prog_compiler_no_builtin_flag, GST_SRC_TAG)
_LT_AC_TAGVAR(export_dynamic_flag_spec, $1)=$_LT_AC_TAGVAR(export_dynamic_flag_spec, GST_SRC_TAG)
_LT_AC_TAGVAR(thread_safe_flag_spec, $1)=$_LT_AC_TAGVAR(thread_safe_flag_spec, GST_SRC_TAG)
_LT_AC_TAGVAR(whole_archive_flag_spec, $1)=$_LT_AC_TAGVAR(whole_archive_flag_spec, GST_SRC_TAG)
_LT_AC_TAGVAR(enable_shared_with_static_runtimes, $1)=$_LT_AC_TAGVAR(enable_shared_with_static_runtimes, GST_SRC_TAG)
_LT_AC_TAGVAR(old_archive_cmds, $1)=$_LT_AC_TAGVAR(old_archive_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(old_archive_from_new_cmds, $1)=$_LT_AC_TAGVAR(old_archive_from_new_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(predep_objects, $1)=$_LT_AC_TAGVAR(predep_objects, GST_SRC_TAG)
_LT_AC_TAGVAR(postdep_objects, $1)=$_LT_AC_TAGVAR(postdep_objects, GST_SRC_TAG)
_LT_AC_TAGVAR(predeps, $1)=$_LT_AC_TAGVAR(predeps, GST_SRC_TAG)
_LT_AC_TAGVAR(postdeps, $1)=$_LT_AC_TAGVAR(postdeps, GST_SRC_TAG)
_LT_AC_TAGVAR(compiler_lib_search_path, $1)=$_LT_AC_TAGVAR(compiler_lib_search_path, GST_SRC_TAG)
_LT_AC_TAGVAR(archive_cmds, $1)=$_LT_AC_TAGVAR(archive_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(archive_expsym_cmds, $1)=$_LT_AC_TAGVAR(archive_expsym_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(postinstall_cmds, $1)=$_LT_AC_TAGVAR(postinstall_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(postuninstall_cmds, $1)=$_LT_AC_TAGVAR(postuninstall_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(old_archive_from_expsyms_cmds, $1)=$_LT_AC_TAGVAR(old_archive_from_expsyms_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(allow_undefined_flag, $1)=$_LT_AC_TAGVAR(allow_undefined_flag, GST_SRC_TAG)
_LT_AC_TAGVAR(no_undefined_flag, $1)=$_LT_AC_TAGVAR(no_undefined_flag, GST_SRC_TAG)
_LT_AC_TAGVAR(export_symbols_cmds, $1)=$_LT_AC_TAGVAR(export_symbols_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_libdir_flag_spec, $1)=$_LT_AC_TAGVAR(hardcode_libdir_flag_spec, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_libdir_flag_spec_ld, $1)=$_LT_AC_TAGVAR(hardcode_libdir_flag_spec_ld, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_libdir_separator, $1)=$_LT_AC_TAGVAR(hardcode_libdir_separator, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_automatic, $1)=$_LT_AC_TAGVAR(hardcode_automatic, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_action, $1)=$_LT_AC_TAGVAR(hardcode_action, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_direct, $1)=$_LT_AC_TAGVAR(hardcode_direct, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_minus_L, $1)=$_LT_AC_TAGVAR(hardcode_minus_L, GST_SRC_TAG)
_LT_AC_TAGVAR(hardcode_shlibpath_var, $1)=$_LT_AC_TAGVAR(hardcode_shlibpath_var, GST_SRC_TAG)
_LT_AC_TAGVAR(link_all_deplibs, $1)=$_LT_AC_TAGVAR(link_all_deplibs, GST_SRC_TAG)
_LT_AC_TAGVAR(always_export_symbols, $1)=$_LT_AC_TAGVAR(always_export_symbols, GST_SRC_TAG)
_LT_AC_TAGVAR(module_cmds, $1)=$_LT_AC_TAGVAR(module_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(module_expsym_cmds, $1)=$_LT_AC_TAGVAR(module_expsym_cmds, GST_SRC_TAG)
_LT_AC_TAGVAR(lt_cv_prog_compiler_c_o, $1)=$_LT_AC_TAGVAR(lt_cv_prog_compiler_c_o, GST_SRC_TAG)
_LT_AC_TAGVAR(exclude_expsyms, $1)=$_LT_AC_TAGVAR(exclude_expsyms, GST_SRC_TAG)
_LT_AC_TAGVAR(include_expsyms, $1)=$_LT_AC_TAGVAR(include_expsyms, GST_SRC_TAG)

$3
AC_MSG_NOTICE([appending configuration tag \"$tagname\" to $ofile])
AC_LIBTOOL_CONFIG($1)
tagname=
])
