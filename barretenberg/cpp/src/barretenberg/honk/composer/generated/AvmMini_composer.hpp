

#pragma once

#include "barretenberg/honk/proof_system/generated/AvmMini_prover.hpp"
#include "barretenberg/honk/proof_system/generated/AvmMini_verifier.hpp"
#include "barretenberg/proof_system/circuit_builder/generated/AvmMini_trace.hpp"
#include "barretenberg/proof_system/composer/composer_lib.hpp"
#include "barretenberg/srs/global_crs.hpp"

namespace proof_system::honk {
template <typename Flavor> class AvmMiniComposer_ {
  public:
    using CircuitConstructor = AvmMiniTraceBuilder;
    using ProvingKey = typename Flavor::ProvingKey;
    using VerificationKey = typename Flavor::VerificationKey;
    using PCS = typename Flavor::PCS;
    using CommitmentKey = typename Flavor::CommitmentKey;
    using VerifierCommitmentKey = typename Flavor::VerifierCommitmentKey;

    // TODO: which of these will we really need
    static constexpr std::string_view NAME_STRING = "AvmMini";
    static constexpr size_t NUM_RESERVED_GATES = 0;
    static constexpr size_t NUM_WIRES = Flavor::NUM_WIRES;

    std::shared_ptr<ProvingKey> proving_key;
    std::shared_ptr<VerificationKey> verification_key;

    // The crs_factory holds the path to the srs and exposes methods to extract the srs elements
    std::shared_ptr<barretenberg::srs::factories::CrsFactory<typename Flavor::Curve>> crs_factory_;

    // The commitment key is passed to the prover but also used herein to compute the verfication key commitments
    std::shared_ptr<CommitmentKey> commitment_key;

    std::vector<uint32_t> recursive_proof_public_input_indices;
    bool contains_recursive_proof = false;
    bool computed_witness = false;

    AvmMiniComposer_()
        requires(std::same_as<Flavor, honk::flavor::AvmMiniFlavor>)
    {
        crs_factory_ = barretenberg::srs::get_crs_factory();
    }

    AvmMiniComposer_(std::shared_ptr<ProvingKey> p_key, std::shared_ptr<VerificationKey> v_key)
        : proving_key(std::move(p_key))
        , verification_key(std::move(v_key))
    {}

    AvmMiniComposer_(AvmMiniComposer_&& other) noexcept = default;
    AvmMiniComposer_(AvmMiniComposer_ const& other) noexcept = default;
    AvmMiniComposer_& operator=(AvmMiniComposer_&& other) noexcept = default;
    AvmMiniComposer_& operator=(AvmMiniComposer_ const& other) noexcept = default;
    ~AvmMiniComposer_() = default;

    std::shared_ptr<ProvingKey> compute_proving_key(CircuitConstructor& circuit_constructor);
    std::shared_ptr<VerificationKey> compute_verification_key(CircuitConstructor& circuit_constructor);

    void compute_witness(CircuitConstructor& circuit_constructor);

    AvmMiniProver_<Flavor> create_prover(CircuitConstructor& circuit_constructor);
    AvmMiniVerifier_<Flavor> create_verifier(CircuitConstructor& circuit_constructor);

    void add_table_column_selector_poly_to_proving_key(barretenberg::polynomial& small, const std::string& tag);

    void compute_commitment_key(size_t circuit_size)
    {
        commitment_key = std::make_shared<CommitmentKey>(circuit_size, crs_factory_);
    };
};

extern template class AvmMiniComposer_<honk::flavor::AvmMiniFlavor>;
using AvmMiniComposer = AvmMiniComposer_<honk::flavor::AvmMiniFlavor>;

} // namespace proof_system::honk
