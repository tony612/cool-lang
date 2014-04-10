/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

int commentDepth = 0;
int strError = 0;

%}

/*
 * Define names for regular expressions here.
 */

DARROW                =>
CLASS                 class
ELSE                  (?i:else)
FI                    fi
IF                    if
IN                    in
INHERITS              inherits
LET                   let
LOOP                  loop
POOL                  pool
THEN                  then
WHILE                 while
CASE                  case
ESAC                  esac
OF                    of
NEW                   new
ISVOID                isvoid
STR_CONST             \"(.|\\\n)*\"
INT_CONST             [0-9]+
BOOL_CONST            t(?i:rue)|f(?i:alse)
TYPEID                [A-Z][a-zA-Z0-9_]*
OBJECTID              [a-z][a-zA-Z0-9_]*
ASSIGN                <-
NOT                   not

STR_NON_ESCAPE_ERROR  \"[^\"]*[^\\\"]?\n

WHITE_SPACE  [ \t\r]+

%x     COMMENT STRING


%%

"(*" {
  BEGIN(COMMENT);
  commentDepth++;
}

<COMMENT>"*)" {
  commentDepth--;
  if (commentDepth == 0) {
    BEGIN(INITIAL);
  }
}
<COMMENT>[^(\*))\n] {}
<COMMENT>\n     { curr_lineno++; }

\n      { curr_lineno++; }
{CLASS}      { return (CLASS); }
{ELSE}      { return (ELSE); }
{FI}      { return (FI); }
{IF}      { return (IF); }
{IN}      { return (IN); }
{INHERITS}    { return (INHERITS); }
{LET}      { return (LET); }
{LOOP}      { return (LOOP); }
{POOL}      { return (POOL); }
{THEN}      { return (THEN); }
{WHILE}      { return (WHILE); }
{CASE}      { return (CASE); }
{ESAC}      { return (ESAC); }
{OF}      { return (OF); }
{DARROW}    { return (DARROW); }
{NEW}      { return (NEW); }
{ISVOID}    { return (ISVOID); }

  /* {STR_NON_ESCAPE_ERROR}  { */
  /*   cool_yylval.error_msg = "Unterminated string constant"; */
  /*   curr_lineno++; */
  /*   return (ERROR); */
  /* }; */

<INITIAL>\"      {
  string_buf_ptr = string_buf;
  strError = 0;
  BEGIN(STRING);
}
<STRING>\"    {
  BEGIN(INITIAL);

  if (strError == 0) {
  cool_yylval.symbol = stringtable.add_string(string_buf);
  *string_buf_ptr = '\0';

  return (STR_CONST);
  } else {
    strError = 0;
  }
}
<STRING>\0    {
  cool_yylval.error_msg = "String contains null character";
  strError = 1;
  return (ERROR);
}
<STRING>\n    {
  cool_yylval.error_msg = "Unterminated string constant";
  curr_lineno++;
  strError = 1;
  return (ERROR);
}
<STRING>\\n  *string_buf_ptr++ = '\n';
<STRING>\\t  *string_buf_ptr++ = '\t';
<STRING>\\b  *string_buf_ptr++ = '\b';
<STRING>\\f  *string_buf_ptr++ = '\f';

<STRING>\\(.|\n) {
  *string_buf_ptr++ = yytext[1];
}

<STRING>[^\\\n\"\0]+        {
  char *yptr = yytext;

  while ( *yptr ) { *string_buf_ptr++ = *yptr++; }
}
  /* {STR_CONST}    { */
  /*   // printf("string Const"); */
  /*   int len = strlen(yytext); */
  /*   if (len > MAX_STR_CONST) { */
  /*     cool_yylval.error_msg = "String constant too long"; */
  /*     return (ERROR); */
  /*   } */
  /*   char* str = new char[len - 2]; */
  /*   // printf("%d", len); */
  /*   // printf("%d", strchr(yytext, '\0')); */
  /*   for (int i = 1;i < len - 1;i++) { */
  /*     char c = yytext[i]; */
  /*     if (c == '\0') { */
  /*       //if (i < len - 2 && yytext[i + 1] == '0') { */
  /*       cool_yylval.error_msg = "String contains null character"; */
  /*       return (ERROR); */
  /*       //} */
  /*     } */
  /*     str[i - 1] = c; */
  /*   } */
  /*   cool_yylval.symbol = stringtable.add_string(str); */
  /*   return (STR_CONST); */
  /* } */

t(?i:rue)  {
  cool_yylval.boolean = 1;
  return (BOOL_CONST);
}
f(?i:alse)  {
  cool_yylval.boolean = 0;
  return (BOOL_CONST);
}
{OBJECTID}    {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (OBJECTID);
}
{TYPEID}    {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (TYPEID);
}
{INT_CONST}    {
  cool_yylval.symbol = inttable.add_string(yytext);
  return (INT_CONST);
}
{ASSIGN}    { return (ASSIGN); }
{NOT}      { return (NOT); }

"+"      { return 0 + '+'; }
"-"      { return 0 + '-'; }
"*"      { return 0 + '*'; }
"/"      { return 0 + '/'; }
"="      { return 0 + '='; }
"("      { return 0 + '('; }
")"      { return 0 + ')'; }
"{"      { return 0 + '{'; }
"}"      { return 0 + '}'; }
";"      { return 0 + ';'; }
":"      { return 0 + ':'; }
"."      { return 0 + '.'; }
","      { return 0 + ','; }
"<"      { return 0 + '<'; }
"~"      { return 0 + '~'; }

{WHITE_SPACE}    { }

.      {
  cool_yylval.error_msg = yytext;
  return (ERROR);
}

%%
