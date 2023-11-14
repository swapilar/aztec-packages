
#pragma once
#include "barretenberg/proof_system/arithmetization/arithmetization.hpp"
namespace arithmetization {
class AvmMiniArithmetization : public Arithmetization<15, 0> {
  public:
    using FF = barretenberg::fr;
    struct Selectors {};
};
} // namespace arithmetization
