%language "c++"
%skeleton "lalr1.cc"
%require "3.2"

%define api.token.raw
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose

%code requires
{
#include <map>
#include <list>
#include <vector>
#include <string>
#include <iostream>
#include <algorithm>
#include <cstddef>
#include <cstdlib>
#include "State.hh"
#include "Driver.hh"

} // code req

%param { MLE::Driver& ProgramDriver }

%code {
#include "Driver.hh"
yy::parser::symbol_type yylex(MLE::Driver& ProgramDriver);

inline void CLEAN(MLE::Driver& ProgramDriver) {
    ProgramDriver.Range.Start.reset();
    ProgramDriver.Range.End.reset();
}

}

%token NUM
%token CMD
%token TEXT
%token RANGE_WILDCARD
%token COMMA
%token WRITE
%token NEWLINE
%token QUIT
%token APPEND
%token INSERT
%token PRINT
%token LIST
%token CHG
%token DEL
%token QUICK_DEL

%type<size_t> NUM

%%

entries:    entries entry
|   %empty
;

entry:  comms
|   error                       { CLEAN(ProgramDriver); yyclearin; yyerrok; }
;

comms: comms comm
|   %empty                      { /* skip */ }
;

comm:   WRITE                   {   // =====================================================
                                    ProgramDriver.Save();
                                    yyclearin;
                                    yyerrok;
                                }
|       NUM INSERT              {   // =====================================================
                                    CLEAN(ProgramDriver);
                                    char line[256];
                                    
                                    while (true) {
                                        std::cout << "-> ";
                                        std::cin.getline(line, 256);
                                        if (!std::strcmp(line, ".")) {
                                            break;
                                        } else if (!std::strcmp(line, "\\n")) {
                                            ProgramDriver.ProgramState->MainBuffer->push_back("\n");
                                            continue;
                                        } else if (!std::strcmp(line, "\\.")) {
                                            ProgramDriver.ProgramState->MainBuffer->push_back(".");
                                        } else if (std::strcmp(line, "\0")) {
                                            ProgramDriver.ProgramState->MainBuffer->insert(
                                                ProgramDriver.ProgramState->MainBuffer->begin() + $1 - 1,
                                                line
                                            );
                                        }
                                    }

                                    ProgramDriver.ProgramState->NeedWarning = true;
                                    yyclearin;
                                    yyerrok;
                                }
|       range PRINT             {   // =====================================================
                                    auto RangeStart_ = ProgramDriver.Range.Start.value();
                                    auto RangeEnd_ = ProgramDriver.Range.End.value();
                                    CLEAN(ProgramDriver);

                                    for (
                                            size_t i = RangeStart_;
                                            i <= RangeEnd_;
                                            i++
                                    ) {
                                        try {
                                            std::cout << i << "\t" <<
                                                ProgramDriver.ProgramState->MainBuffer->at(i - 1)
                                                << "\n";
                                        } catch (...) {
                                            break;
                                        }
                                    }
                                    CLEAN(ProgramDriver);
                                }
|       range DEL               {   // =====================================================
                                    auto RangeStart_ = ProgramDriver.Range.Start.value();
                                    auto RangeEnd_ = ProgramDriver.Range.End.value();
                                    CLEAN(ProgramDriver);
                                    
                                    if ((RangeStart_ - 1) >= ProgramDriver.ProgramState->MainBuffer->size()) {
                                            std::cout << "Line " << RangeStart_ << " nonexistent\n";
                                            break;
                                    }
                                    for (; RangeStart_ <= RangeEnd_; RangeStart_++) {
                                        ProgramDriver.ProgramState->MainBuffer->erase(
                                            ProgramDriver.ProgramState->MainBuffer->begin() + 
                                            (RangeStart_ - 1));
                                    }
                                    ProgramDriver.ProgramState->NeedWarning = true;
                                }
|       APPEND                  {   // =====================================================
                                    CLEAN(ProgramDriver);
                                    char line[256];
                                    
                                    while (true) {
                                        std::cout << "-> ";
                                        std::cin.getline(line, 256);
                                        if (!std::strcmp(line, ".")) {
                                            break;
                                        } else if (!std::strcmp(line, "\\n")) {
                                            ProgramDriver.ProgramState->MainBuffer->push_back("\n");
                                            continue;
                                        } else if (!std::strcmp(line, "\\.")) {
                                            ProgramDriver.ProgramState->MainBuffer->push_back(".");
                                        } else if (std::strcmp(line, "\0")) {
                                            ProgramDriver.ProgramState->MainBuffer->push_back(line);
                                        }
                                    }

                                    ProgramDriver.ProgramState->NeedWarning = true;
                                    yyclearin;
                                    yyerrok;                                 
                                }
|       NUM CHG                 {   // =====================================================
                                    CLEAN(ProgramDriver);
                                    char line[256];
                                    std::cout << "-> ";
                                    std::cin.getline(line, 256);
                                    try {
                                        ProgramDriver.ProgramState->MainBuffer->at($1 - 1) = line;
                                        ProgramDriver.ProgramState->NeedWarning = true;
                                    } catch (...) { 
                                        std::cout << "Line " << $1 << " nonexistent\n";
                                    }
                                    yyclearin;
                                    yyerrok;  
                                }
|       NUM QUICK_DEL           {   // =====================================================
                                    CLEAN(ProgramDriver);
                                    if ($1 > ProgramDriver.ProgramState->MainBuffer->size()) {
                                        std::cout << "Line " << $1 << " nonexistent\n";
                                    } else {
                                        ProgramDriver.ProgramState->MainBuffer->erase(
                                            ProgramDriver.ProgramState->MainBuffer->begin() +
                                            $1 - 1);
                                        ProgramDriver.ProgramState->NeedWarning = true;
                                    }
                                    CLEAN(ProgramDriver);
                                    yyclearin;
                                    yyerrok;  
                                }
|       QUIT                    {   // =====================================================
                                    // quirks: extra newline for the answer!
                                    if (ProgramDriver.ProgramState->NeedWarning) {
                                        while (true) {
                                            std::cout << "Quit without saving? [y/n] ";
                                            char Response;
                                            
                                            std::cin >> Response;
                                            if (Response == 'n') {
                                                break;
                                            } else if (Response == 'y') {
                                                exit(0);
                                            } else {
                                                continue;
                                            }
                                        }
                                    } else {
                                        exit(0); 
                                    }
                                    CLEAN(ProgramDriver);
                                    yyclearin;
                                    yyerrok;
                                }
|       LIST                    {   // =====================================================
                                    size_t i = 1;
                                    for (auto str: *(ProgramDriver.ProgramState->MainBuffer)) {
                                        std::cout << i++ << "\t" << str << '\n';
                                    }
                                    CLEAN(ProgramDriver);
                                }
;

range: range_literal COMMA range_literal
;

range_literal: RANGE_WILDCARD   {   // =====================================================
                                    if (!ProgramDriver.Range.Start.has_value()) {
                                        ProgramDriver.Range.Start = 1;
                                        ProgramDriver.Range.End.reset();
                                    } else if (!ProgramDriver.Range.End.has_value()) {
                                        ProgramDriver.Range.End = ProgramDriver.ProgramState->MainBuffer->size();
                                    } else {
                                        CLEAN(ProgramDriver);
                                        std::cout << "Logic error (RANGE_WILDCARD)\n";
                                        while (true) {
                                            std::cout << "Quit or continue in an undefined state? [q/c] ";
                                            char Response;
                                            
                                            std::cin >> Response;
                                            if (Response == 'c') {
                                                break;
                                            } else if (Response == 'q') {
                                                exit(-1);
                                            } else {
                                                continue;
                                            }
                                        }
                                    }
                                }
|   NUM                         {   // =====================================================
                                    if (!ProgramDriver.Range.Start.has_value()) {
                                        ProgramDriver.Range.Start = $1;
                                        ProgramDriver.Range.End.reset();
                                    } else if (!ProgramDriver.Range.End.has_value()) {
                                        ProgramDriver.Range.End = $1;
                                    } else {
                                        std::cout << "Logic error (NUM)\n";
                                        while (true) {
                                            CLEAN(ProgramDriver);
                                            std::cout << "Quit or continue in an undefined state? [q/c] ";
                                            char Response;
                                            
                                            std::cin >> Response;
                                            if (Response == 'c') {
                                                break;
                                            } else if (Response == 'q') {
                                                exit(-2);
                                            } else {
                                                continue;
                                            }
                                        }
                                    }
                                }
;
%%