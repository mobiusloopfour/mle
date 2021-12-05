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

%type<size_t> NUM

%%

entries:    entries entry
|   %empty
;

entry:  comms
|   error                       { yyclearin; yyerrok; }
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
                                    char line[256];
                                    
                                    while (true) {
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
                                    for (
                                            size_t i = ProgramDriver.Range.Start.value();
                                            i <= ProgramDriver.Range.End.value();
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
                                    ProgramDriver.Range.Start = std::nullopt;
                                    ProgramDriver.Range.End = std::nullopt;
                                }
|       APPEND                  {   // =====================================================
                                    char line[256];
                                    
                                    while (true) {
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
|       CHG NUM                 {   // =====================================================
                                    char line[256];
                                    std::cin.getline(line, 256);
                                    try {
                                        ProgramDriver.ProgramState->MainBuffer->at($2 - 1) = line;
                                        ProgramDriver.ProgramState->NeedWarning = true;
                                    } catch (...) { 
                                        std::cout << "Line " << $2 << " nonexistent\n";
                                    }
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
                                    yyclearin;
                                    yyerrok;
                                }
|       LIST                    {   // =====================================================
                                    size_t i = 1;
                                    for (auto str: *(ProgramDriver.ProgramState->MainBuffer)) {
                                        std::cout << i++ << "\t" << str << '\n';
                                    }
                                }
;

range: range_literal COMMA range_literal
;

range_literal: RANGE_WILDCARD   {   // =====================================================
                                    if (!ProgramDriver.Range.Start.has_value()) {
                                        ProgramDriver.Range.Start = 1;
                                    } else if (!ProgramDriver.Range.End.has_value()) {
                                        ProgramDriver.Range.End = ProgramDriver.ProgramState->MainBuffer->size();
                                    } else {
                                        std::cout << "Logic error (RANGE_WILDCARD)\n";
                                        while (true) {
                                            std::cout << "Quit without saving? [y/n] ";
                                            char Response;
                                            
                                            std::cin >> Response;
                                            if (Response == 'n') {
                                                break;
                                            } else if (Response == 'y') {
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
                                    } else if (!ProgramDriver.Range.End.has_value()) {
                                        ProgramDriver.Range.End = $1;
                                    } else {
                                        std::cout << "Logic error (NUM)\n";
                                        while (true) {
                                            std::cout << "Quit without saving? [y/n] ";
                                            char Response;
                                            
                                            std::cin >> Response;
                                            if (Response == 'n') {
                                                break;
                                            } else if (Response == 'y') {
                                                exit(-2);
                                            } else {
                                                continue;
                                            }
                                        }
                                    }
                                }
;
%%