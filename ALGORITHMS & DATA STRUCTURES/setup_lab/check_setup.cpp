// check_setup.cpp: proves that your compiler builds the C++17 that the labs use.
// The setup scripts build and run it for you. To try it yourself, from this folder:
//   g++ -std=c++17 -Wall -Wextra -pedantic check_setup.cpp -o check_setup
//   ./check_setup
#include <cstddef>
#include <iostream>
#include <map>
#include <optional>
#include <string>
#include <string_view>
#include <type_traits>
#include <vector>

namespace {

// std::optional (C++17): a position, or nothing when the value is missing.
std::optional<std::size_t> indexOf(const std::vector<int>& values, int target) {
    for (std::size_t i = 0; i < values.size(); ++i) {
        if (values[i] == target) {
            return i;
        }
    }
    return std::nullopt;
}

// if constexpr (C++17): the branch is chosen while compiling.
template <typename T>
std::string_view kindOf() {
    if constexpr (std::is_integral_v<T>) {
        return "integral";
    } else {
        return "not integral";
    }
}

}  // namespace

int main() {
    // Structured bindings (C++17): name both halves of each map entry.
    const std::map<std::string, int> labOf{{"arrays", 2}, {"stacks", 5}, {"hashing", 11}};
    int labSum = 0;
    std::size_t letters = 0;
    for (const auto& [topic, lab] : labOf) {
        letters += topic.size();
        labSum += lab;
    }

    const std::vector<int> keys{29, 10, 14, 37, 13};
    const std::optional<std::size_t> found = indexOf(keys, 37);
    const bool missingIsEmpty = !indexOf(keys, 99).has_value();
    const bool ok = found.has_value() && *found == 3 && missingIsEmpty && labSum == 18 && letters == 19 &&
                    kindOf<int>() == "integral" && kindOf<double>() == "not integral";

    std::cout << " C++ toolchain check\n";
#if defined(__clang__)
    std::cout << "   compiler : clang " << __clang_major__ << '.' << __clang_minor__ << '.' << __clang_patchlevel__
              << '\n';
#elif defined(__GNUC__)
    std::cout << "   compiler : g++ " << __GNUC__ << '.' << __GNUC_MINOR__ << '.' << __GNUC_PATCHLEVEL__ << '\n';
#else
    std::cout << "   compiler : not GCC or Clang\n";
#endif
    std::cout << "   language : C++" << (__cplusplus >= 202002L ? "20" : __cplusplus >= 201703L ? "17" : "14 or older")
              << " (__cplusplus = " << __cplusplus << ")\n";
    std::cout << "   result   : "
              << (ok ? "ready for the labs" : "a C++17 feature misbehaved; see setup_lab/README.md") << '\n';
    return ok ? 0 : 1;
}
