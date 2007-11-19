
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#ifdef HAVE_STRINGS_H
# include <strings.h>
#else
# include <string.h>
#endif /* HAVE_STRINGS_H */

#ifdef HAVE_STDLIB_H
# include <stdlib.h>
#endif /* HAVE_STDLIB_H */

#ifdef HAVE_SYS_FILE_H
# include <sys/file.h>
#endif /* HAVE_SYS_FILE_H */

#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif /* HAVE_UNISTD_H */

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif /* HAVE_FCNTL_H */

#include <limits.h>
#include <errno.h>

/* Generate a unique temporary directory name from template.  The last six characters of
   template must be XXXXXX and these are replaced with a string that makes the
   filename unique. */

static int 
my_mkdir (name, mode)
    const char* name;
    mode_t mode;
{
  int retstat;
#ifdef _WIN32
  retstat = mkdir (name);
  if (retstat == 0)
    retstat = chmod (name, mode);
#else
  retstat = mkdir (name, mode);
#endif
  return retstat;
}

char*
mkdtemp (template)
     char *template;
{
  int i, j, n, save_errno;
  char *data = template + strlen(template) - 6;
  save_errno = errno;

  if (data < template) {
    errno = EINVAL;
    return NULL;
  }

  for (n = 0; n <= 5; n++)
    if (data[n] != 'X') {
      errno = EINVAL;
      return NULL;
    }

  for (i = 0; i < INT_MAX; i++) {
    j = i ^ 827714841;             /* Base 36 DOSSUX :-) */
    for (n = 5; n >= 0; n--) {
      data[n] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" [j % 36];
      j /= 36;
    }

    if (my_mkdir(template, 0700) == 0)
    {
        errno = save_errno;
        return template;
    }
  }
    
  errno = EEXIST;
  return NULL;
}
