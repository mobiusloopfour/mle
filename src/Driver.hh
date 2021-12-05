#ifndef __driver_hh__
#define __driver_hh__

#include "State.hh"
#include <cstddef>
#include <string>
#include <optional>

namespace MLE {

struct RangeSet {
    std::optional<size_t> Start;
    std::optional<size_t> End;
};

struct Driver {
    RangeSet Range;
    std::shared_ptr<MLE::State> ProgramState;

    auto ParseOption(char const *s, char const *name) -> void;
    auto Save() -> int;
    auto Open() const -> int;
    auto Parse() -> void;
    auto ScanBegin() -> void;
    auto ScanEnd() -> void;

    Driver();
};

}

#endif // __driver_hh__