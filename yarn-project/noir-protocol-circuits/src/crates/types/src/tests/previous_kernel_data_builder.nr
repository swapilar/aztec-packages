use crate::{
    abis::{
        combined_constant_data::CombinedConstantData,
        combined_accumulated_data::CombinedAccumulatedDataBuilder,
        historical_block_data::HistoricalBlockData,
        kernel_circuit_public_inputs::KernelCircuitPublicInputs,
        previous_kernel_data::PreviousKernelData,
        public_data_read::PublicDataRead,
        public_data_update_request::PublicDataUpdateRequest,
    },
    hash::NUM_FIELDS_PER_SHA256,
    mocked::{Proof, VerificationKey},
    tests::{
        fixtures,
        testing_harness::build_tx_context,
    },
    transaction::context::TxContext,
};
use dep::aztec::{
    constants_gen::{
        EMPTY_NULLIFIED_COMMITMENT,
        MAX_NEW_COMMITMENTS_PER_TX,
        MAX_NEW_NULLIFIERS_PER_TX,
        MAX_PUBLIC_DATA_READS_PER_TX,
        MAX_PUBLIC_DATA_UPDATE_REQUESTS_PER_TX,
        VK_TREE_HEIGHT,
    },
};

struct PreviousKernelDataBuilder {
    end: CombinedAccumulatedDataBuilder,
    block_data: HistoricalBlockData,
    tx_context: TxContext,
    is_private: bool,
    proof: Proof,
    vk: VerificationKey,
    vk_index: u32,
    vk_path: [Field; VK_TREE_HEIGHT],
}

impl PreviousKernelDataBuilder {
    pub fn new() -> Self {
        let mut end: CombinedAccumulatedDataBuilder = dep::std::unsafe::zeroed();
        end.new_nullifiers.push(321); // 0th nullifier must be non-zero.
        end.nullified_commitments.push(EMPTY_NULLIFIED_COMMITMENT);
        end.private_call_stack.push(1);

        let tx_context = build_tx_context(false);

        PreviousKernelDataBuilder {
            end,
            block_data: fixtures::HISTORICAL_BLOCK_DATA,
            tx_context,
            is_private: true,
            proof: Proof {},
            vk: VerificationKey {},
            vk_index: 0,
            vk_path: [0; VK_TREE_HEIGHT],
        }
    }

    pub fn is_constructor(&mut self) -> Self {
        self.tx_context = build_tx_context(true);
        *self
    }

    pub fn is_public(&mut self) -> Self {
        self.is_private = false;
        *self
    }

    pub fn next_is_public(&mut self) -> Self {
        let _ = self.end.private_call_stack.pop();
        *self
    }

    pub fn append_public_data_update_requests(&mut self, num_updates: Field) {
        let value_offset = self.end.public_data_update_requests.len();
        for i in 0..MAX_PUBLIC_DATA_UPDATE_REQUESTS_PER_TX {
            if i as u64 < num_updates as u64 {
                let update_request = PublicDataUpdateRequest {
                    // The default leaf index is its index + 23.
                    leaf_index: value_offset + i + 23,
                    // The default value is its index + 45.
                    old_value: value_offset + i + 45,
                    // The default value is its index + 678.
                    new_value: value_offset + i + 678,
                };
                self.end.public_data_update_requests.push(update_request);
            }
        }
    }

    pub fn append_public_data_read_requests(&mut self, num_reads: Field) {
        let value_offset = self.end.public_data_reads.len();
        for i in 0..MAX_PUBLIC_DATA_READS_PER_TX {
            if i as u64 < num_reads as u64 {
                let read_request = PublicDataRead {
                    // The default leaf index is its index + 34.
                    leaf_index: value_offset + i + 34,
                    // The default value is its index + 5566.
                    value: value_offset + i + 5566,
                };
                self.end.public_data_reads.push(read_request);
            }
        }
    }

    pub fn add_read_request_for_transient_commitment(&mut self, commitment_index: Field) -> Field {
        let new_read_request_index = self.end.read_requests.len();
        self.end.read_requests.push(self.end.new_commitments.get(commitment_index));
        new_read_request_index
    }

    pub fn append_new_commitments(&mut self, num_new_commitments: Field) {
        let mocked_value_offset = self.end.new_commitments.len() + 1;
        for i in 0..MAX_NEW_COMMITMENTS_PER_TX {
            if i as u64 < num_new_commitments as u64 {
                // The default value is its index + 1.
                self.end.new_commitments.push(i + mocked_value_offset);
            }
        }
    }

    pub fn append_new_nullifiers(&mut self, num_extra_nullifier: Field) {
        let first_nullifier = self.end.new_nullifiers.get(0);
        let mocked_value_offset = first_nullifier + self.end.new_nullifiers.len();
        for i in 1..MAX_NEW_NULLIFIERS_PER_TX {
            if i as u64 <= num_extra_nullifier as u64 {
                // The default value is its index + the value of the first nullifier.
                self.end.new_nullifiers.push(i + mocked_value_offset);
            }
        }
    }

    pub fn set_encrypted_logs(&mut self, hash: [Field; NUM_FIELDS_PER_SHA256], preimages_length: Field) {
        self.end.encrypted_logs_hash = hash;
        self.end.encrypted_log_preimages_length = preimages_length;
    }

    pub fn set_unencrypted_logs(&mut self, hash: [Field; NUM_FIELDS_PER_SHA256], preimages_length: Field) {
        self.end.unencrypted_logs_hash = hash;
        self.end.unencrypted_log_preimages_length = preimages_length;
    }

    pub fn finish(self) -> PreviousKernelData {
        let public_inputs = KernelCircuitPublicInputs {
            end: self.end.finish(),
            constants: CombinedConstantData {
                block_data: self.block_data,
                tx_context: self.tx_context,
            },
            is_private: self.is_private,
        };
        PreviousKernelData {
            public_inputs,
            proof: self.proof,
            vk: self.vk,
            vk_index: self.vk_index,
            vk_path: self.vk_path,
        }
    }
}
