%option yylineno
%option c++
%option prefix="SimplexParser"

%{

namespace  SimplexParser {
    class Driver;
}

#include <iostream>
#include "SimplexParser.hpp"
#include "lexer.h"
typedef SimplexParser::Parser::token token;
typedef SimplexParser::Parser::token_type token_type;
#define yyterminate() return token::TEOF
extern int line_number;	/* defined in parser.ypp */

using namespace std;

#ifndef DEBUG
    bool verbose = false;
#endif
#ifdef DEBUG
    bool verbose = true;
#endif

%}


whitespace  [ \t]+
digit       [0-9]+
id          [a-zA-Z_][a-zA-Z0-9_]*
%x comment

%%

{whitespace}    { /* On ignore */}

"//"                    BEGIN(comment);   //
<comment>[^\n]          break;            //
<comment>\n             {                 // Comments handling
                          BEGIN(INITIAL); //
                          line_number++;  //
                        }                 //

\n+             { if(verbose){cout<<"EOL ";} line_number++; return(token::EOL); }
">="            { if(verbose){cout<<"GE ";} return(token::GE); }
"<="            { if(verbose){cout<<"LE ";} return(token::LE); }
"="             { if(verbose){cout<<"EQ ";} return(token::EQ); }
"=="            { if(verbose){cout<<"EQ ";} return(token::EQ); }
"-"             { if(verbose){cout<<"MINUS ";} return(token::MINUS); }
"\+"            { if(verbose){cout<<"PLUS ";} return(token::PLUS); }
"\*"            { if(verbose){cout<<"TIMES ";} return(token::TIMES); }
"/"             { if(verbose){cout<<"FRAC ";} return(token::FRAC); }
"MAXIMIZE"      { if(verbose){cout<<"MAXIMIZE ";} return(token::MAXIMIZE); }
"MINIMIZE"      { if(verbose){cout<<"MINIMIZE ";} return(token::MINIMIZE); }
"SUBJECT TO"    { if(verbose){cout<<"SUBJECT_TO ";} return(token::SUBJECT_TO); }
"SUBJECT_TO"    { if(verbose){cout<<"SUBJECT_TO ";} return(token::SUBJECT_TO); }
"BOUNDS"        { if(verbose){cout<<"BOUNDS ";} return(token::BOUNDS); }
"VARIABLES"     { if(verbose){cout<<"VARIABLES ";} return(token::VARIABLES); }

{digit}  {
  //yylval->entier = atoi(yytext);
  yylval->rat = new mpq_class(std::string(yytext), 10);
  if(verbose){cout<<"INT("<<*yylval->rat<<") ";}
  return(token::INT);
}

{id}  {
  string s;
  string text(yytext);
  int nbBrackets = 0;
  for(int i=0;i<text.size();++i)
  {
    if(text[i] == '_')
    {
      s += "_{";
      ++nbBrackets;
    }
    else
      s += text[i];
  }
  for(int i=0;i<nbBrackets;++i)
    s += '}';
  yylval->str = new std::string(s);
  if(verbose){cout<<"VARIABLE("<<*yylval->str<<") ";}
  return(token::VARIABLE);
}

.               { std::cerr<<"line "<<line_number<<": error: illegal character"<<std::endl; exit(1); }
