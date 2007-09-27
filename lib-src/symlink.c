#include <windows.h>
#include <errno.h>

/* Windows does not currently have symbolic links - they are actually
   supported in Vista, but for now we get away with copying.  */
int symlink(const char* old_path, const char* new_path)
{
  if (CopyFile(old_path, new_path, TRUE) == 0)
    {
      errno = EPERM;
      return -1;
    }
  else
    return 0;
}
