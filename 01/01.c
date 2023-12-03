#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// On each line, the calibration value can be found by combining the first digit and the last digit (in that order) 
// to form a single two-digit number.

// Consider your entire calibration document. What is the sum of all of the calibration values?



char *make_string(size_t size)
{
  char *string = calloc(size + 1, sizeof(char));
  string[size - 1] = 0;
  return string;
}

char *expand_string(char *old_string, size_t old_length)
{
  char *new = calloc(old_length * 2, sizeof(char));
  new[(old_length * 2) - 1] = '\0';

  for (int i = 0; i < old_length; i++)
  {
    new[i] = old_string[i];
  }
  free(old_string);
  return new;
}

char *readline(FILE *file_pointer)
{
  if (file_pointer == NULL)
  {
    return NULL;
  }

  size_t str_length = 8;
  char *str = make_string(str_length);

  int char_count = 0;
  char current;

  while ((current = fgetc(file_pointer)) != '\n' && current != EOF)
  {
    if (char_count == str_length)
    {
      str = expand_string(str, str_length);
      str_length *= 2;
    }
    str[char_count] = current;
    char_count++;
  }
  if (current == EOF)
  {
    free(str);
    return NULL;
  }
  return str;
}

int main()
{
  FILE *file_pointer;
  file_pointer = fopen("./input.txt", "r");
  if (file_pointer == NULL)
  {
    perror("File pointer is Null! Bad!");
    return 1;
  }

  char *line;
  while((line = readline(file_pointer)) != NULL)
  {
    printf("%s\n", line);
    free(line);
  }

  if(ferror(file_pointer))
  {
    perror("Error while reading file! Bad!");
    return -1;
  }else{
    return 0;
  }
}