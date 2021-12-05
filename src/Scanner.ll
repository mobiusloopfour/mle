%{
#include <string>
#include <vector>
#include <iostream>
#include <cstddef>
#include <cstdio>
#include "State.hh"
#include "Parser.hh"

#define YY_DECL \
    yy::parser::symbol_type yylex(MLE::Driver& ProgramDriver)

yy::parser::symbol_type make_NUM (const std::string &s);

%}

%option noyywrap

%%


[ \n\t]+    { /* do nuffin */                                   }

[0-9]+      { return yy::parser::make_NUM(std::stoi(yytext));   }

q           { return yy::parser::make_QUIT();                   }

a           { return yy::parser::make_APPEND();                 }

i           { return yy::parser::make_INSERT();                 }

c           { return yy::parser::make_CHG();                    }

l           { return yy::parser::make_LIST();                   }

V           { std::cout << "WARNING: Unimplemented\n";          }

w           { return yy::parser::make_WRITE();                  }

p           { return yy::parser::make_PRINT();                  }

"$"         { return yy::parser::make_RANGE_WILDCARD();         }

,           { return yy::parser::make_COMMA();                  }

"@"         { std::cout << "Cursor" << std::endl;               }

. {
    std::cout << "?\n";
}

%%

yy::parser::symbol_type
make_NUM(const std::string &s)
{
    errno = 0;
    long n = strtol(s.c_str(), NULL, 10);
    if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE)) {
        std::cout << "Bad number\n";
    }

    return yy::parser::make_NUM((size_t) n);
}