#ifndef __state_hpp__
#define __state_hpp__

#include <string>
#include <vector>

namespace MLE {

#include <memory>

struct State {
    std::string Path; // Current file path
    std::unique_ptr<std::vector<std::string>> MainBuffer;
    bool HelpMode; // Print error messages
    bool NeedWarning; // saving file
};

}

#endif /* __state_hpp__ */