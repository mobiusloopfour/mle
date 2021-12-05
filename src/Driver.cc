#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "Driver.hh"
#include "Parser.hh"
#include "State.hh"

namespace yy {
// Report an error to the user.
auto parser::error(const std::string &msg) -> void { std::cerr << msg << '\n'; }
} // namespace yy

namespace MLE {

Driver::Driver() {
    this->ProgramState = std::make_unique<MLE::State>((MLE::State){
        .Path = "\0",
        .MainBuffer = std::make_unique<std::vector<std::string>>(),
        .HelpMode = false,
        .NeedWarning = false,
    });

    this->Range = {
        .Start = std::nullopt,
        .End = std::nullopt,
    };
}

auto Driver::Parse() -> void {
    yy::parser parse(*this);
    parse();
}

auto Driver::ScanBegin() -> void { return; }

auto Driver::ScanEnd() -> void { return; }

auto Driver::ParseOption(char const *s, char const *name) -> void {
    if (std::strcmp(s, "-h") || std::strcmp(s, "--help")) {
        std::cout << "Usage: " << name << " [ option ] path\n";
    } else {
        ParseOption("-h", name);
    }
}

auto Driver::Save() -> int {
    std::ofstream Stream(ProgramState->Path);

    if (Stream.bad())
        return 1;

    for (auto str : *(ProgramState->MainBuffer)) {
        if (str == "\0")
            continue;
        Stream << str << std::endl;
    }

    Stream.close();
    ProgramState->NeedWarning = false;
    return 0;
}

auto Driver::Open() const -> int {
    std::ifstream Stream(ProgramState->Path);
    char InBuffer[256]; // TODO: cry

    if (Stream.bad())
        return 1;

    while (Stream.getline(InBuffer, 256))
        ProgramState->MainBuffer->push_back(InBuffer);

    Stream.close();
    return 0;
}

} // namespace MLE

auto main(int argc, char const *argv[]) -> int {

    MLE::Driver ProgramDriver;

    if (argc == 2)
        ProgramDriver.ProgramState->Path = argv[1];
    else if (argc == 3) {
        ProgramDriver.ParseOption(argv[1], argv[0]);
        ProgramDriver.ProgramState->Path = argv[2];
    } else {
        ProgramDriver.ParseOption("-h", argv[0]);
        exit(EXIT_FAILURE);
    }

    assert(!ProgramDriver.Open()); // returns zero on success

    ProgramDriver.Parse();
    exit(EXIT_SUCCESS);
}