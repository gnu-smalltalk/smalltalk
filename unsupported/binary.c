#include <fcntl.h> /* for open, read, etc */

void
put(fd, c)
int fd;
char c;
{
    write(fd, &c, 1);
}

int
get(fd)
{
    char c;
    read(fd, &c, 1);
    return c;
}

main()
{
    int fd;
    fd = open("mstTeSt", O_WRONLY | O_CREAT); /* write mode + create */
    if (fd < 0) {
      printf("Error: could not open binary test file for writing\n");
      exit(1);
    }
      
    put(fd, '\000');
    put(fd, '\012');
    put(fd, '\012');
    put(fd, '\015');
    put(fd, '\012');
    close(fd);    
    
    fd = open("mstTeSt", O_RDONLY);	/* read mode */
    if (fd < 0) {
      printf("Error: Could not open binary test file\n");
      exit(1);
    }
    if (get(fd) != '\000') exit(1);
    printf("LOSE1\n");
    if (get(fd) != '\012') exit(1);
    printf("LOSE2\n");
    if (get(fd) != '\012') exit(1);
    printf("LOSE3\n");
    if (get(fd) != '\015') exit(1);
    printf("LOSE4\n");
    if (get(fd) != '\012') exit(1);
    printf("Exiting successfully\n");
    exit(0);
}
