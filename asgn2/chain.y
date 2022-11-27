/*  yacc  file for parser for simple cryptographic expressions.
    Graham Farr, Monash University
    Created:  16 July 2017
    Last updated:  13 September 2018
*/

        /*   declarations   */


%{
#include <stdio.h>
#include <string.h>
int yylex(void);
void yyerror(char *);
int yydebug=0;   /*  set to 1 if using with yacc's debug/verbose flags   */
char *reverse(char *);
char *simpleSub(char *, char*);
char *vigenere(char *, char*);
char *locTran(char *, char*);
char *sum(char *, char*);
char *diff(char *, char*);
/*
int  total = 0;
*/
%}

%union {
    /*int iValue;*/
    char *str;
};

%token  <str>  STRING
%token  <str>  REVERSE
%type  <str>  start
%type  <str>  expr

%start  start



%%       /*   rules section   */


start    :    expr  '\n'        {  printf("%s\n", $1);   }
         |         /*  allow "empty" expression  */           {     }
         ;

expr     :    STRING           {  $$ = $1;   }
         |    expr '#' expr    {  $$ = strcat($1,$3);  }
         |    REVERSE '(' STRING  ')'     {  $$ = reverse($3);  }
         ;


%%      /*   programs   */


char *reverse(char *str1)
/*  Reverse the string  str1.
*/
{
  int  n, i;
  char *str;

  n = strlen(str1);

  str = malloc((n+1)*sizeof(char));
  for  (i = 0; i < n; i++)
  {
    str[i] = str1[n-1-i];
  }
  str[n] = (char) 0;
  return  str;
}


char *simpleSub(char *str1, char *str2)
/*  Simple Substitution, using a permutation of the alphabet
    given by the 26-letter string  str2  which is just a
    rearrangement of the string  abcdefghijklmnopqrstuvwxyz
    in which each letter appears exactly once, but not
    necessarily in usual alphabetical order.
    If the usual alphabet is written out above  str2, then
    each letter of the alphabet has a letter underneath it
    which is used as its replacement throughout  str1.
*/
{
  int  n1, n2, i;
  char *str;

  n1 = strlen(str1);
  n2 = strlen(str2);

  str = malloc((n1+1)*sizeof(char));
  for  (i = 0; i < n1; i++)
  {
    str[i] = str2[str1[i] - 'a'];
  }
  str[n1] = (char) 0;
  return  str;
}


char *locTran(char *str1, char *perm)
/*  Local transposition, using permutation given by  perm.
    The permutation is represented as a string whose letters
    are a permuation of  0123...  up to the length of  perm,
    which must be at most 10 digits long.
*/
{
  int  n, w;
  char *str;
  int  n1, i;

  n = strlen(str1);
  w = strlen(perm);

  str = malloc((n+1)*sizeof(char));
  n1 = n - (n % w);
  for  (i = 0; i < n1; i++)
  {
    str[i] = str1[w*(i/w) + (perm[i % w] - '0')];
  }
  for  (i = n1; i < n; i++)
  {
    str[i] = str1[i];
  }

  str[n] = (char) 0;
  return  str;
}

char *vigenere(char *str1, char *str2)
/*  Copies of  str2  are written out, concatenated one after
    the other, until the resulting string is at least as long
    as  str1.  Then every pair of letters that are vertically
    aligned are added mod 26.
*/
{
  int  n1, n2, i;
  char *str;

  n1 = strlen(str1);
  n2 = strlen(str2);

  str = malloc((n1+1)*sizeof(char));
  for  ( i = 0; i < n1; i++)
  {
    str[i] = 'a' + ((str1[i] - 'a') + (str2[i % n2] - 'a')) % 26;
  }
  str[n1] = (char) 0;
  return  str;
}

char *sum(char *str1, char *str2)
/*  Returns the positionwise mod26 sum of the two strings  str1, str2.
    In effect, the two strings are aligned at their beginnings, and
    the letters in each column are added.  The letters are treated as
    numbers in the range  0..25, and are added mod 26, and then the
    resulting number is converted back to a letter.  There are no
    carry digits; the sum in one position (i.e., column) does not
    affect the sum in any other column.  The length of the
    sum is the minimum of the lengths of  str1  and  str2.
    For example, the sum of  one  and  two  is  hjs,  and the sum
    of  alpha  and  beta  is  bpia.
*/
{
  int  n1, n2, n, i;
  char *str;

  n1 = strlen(str1);
  n2 = strlen(str2);
  n = ( n1 <= n2 ? n1 : n2 );

  str = malloc((n+1)*sizeof(char));
  for  (i = 0; i < n; i++)
  {
    str[i] = 'a' + ((str1[i] - 'a') + (str2[i] - 'a')) % 26;
  }
  str[n] = (char) 0;
  return  str;
}


char *diff(char *str1, char *str2)
/*  Returns the positionwise mod26 difference of the two strings  str1, str2.
    In effect, the two strings are aligned at their beginnings, and the
    differences of the letters in each column are taken.  The letters are
    treated as numbers in the range  0..25, and the difference is taken
    mod 26, and then the resulting number is converted back to a letter.
    There are no carry digits; the difference in one position (i.e., column)
    does not affect the difference in any other column.  The length of the
    difference is the minimum of the lengths of  str1  and  str2.
    For example, the difference of  one  and  two  is  hjs,  and the
    difference of  alpha  and  beta  is  bpia.
    This function was created by copying  sum()  and making the necessary
    local changes to do positionwise difference mod 26 rather than
    positionwise sum mod 26.
*/
{
  int  n1, n2, n, i;
  char *str;

  n1 = strlen(str1);
  n2 = strlen(str2);
  n = ( n1 <= n2 ? n1 : n2 );

  str = malloc((n+1)*sizeof(char));
  for  (i = 0; i < n; i++)
  {
    str[i] = 'a' + ((str1[i] - 'a') - (str2[i] - 'a') + 26) % 26;
  }
  str[n] = (char) 0;
  return  str;
}


/*
void yyerror(char *s) {
      fprintf(stderr, "%s\n", s);
      fprintf(stderr, "line %d: %s\n", yylineno, s);
}
*/


int main(void) {
    yyparse();
    return 0;
}
