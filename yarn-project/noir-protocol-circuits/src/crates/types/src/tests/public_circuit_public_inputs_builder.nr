use crate::{
    abis::{
        call_context::CallContext,
        historical_block_data::HistoricalBlockData,
        public_circuit_public_inputs::PublicCircuitPublicInputs,
    },
    address::Address,
    contrakt::{
        storage_read::StorageRead,
        storage_update_request::StorageUpdateRequest,
    },
    hash::NUM_FIELDS_PER_SHA256,
    tests::fixtures,
    utils::bounded_vec::BoundedVec,
};
use dep::aztec::constants_gen::{
    MAX_NEW_COMMITMENTS_PER_CALL,
    MAX_NEW_L2_TO_L1_MSGS_PER_CALL,
    MAX_NEW_NULLIFIERS_PER_CALL,
    MAX_PUBLIC_CALL_STACK_LENGTH_PER_CALL,
    MAX_PUBLIC_DATA_READS_PER_CALL,
    MAX_PUBLIC_DATA_UPDATE_REQUESTS_PER_CALL,
    RETURN_VALUES_LENGTH,
};

struct PublicCircuitPublicInputsBuilder {
    call_context: CallContext,
    args_hash: Field,
    return_values: BoundedVec<Field, RETURN_VALUES_LENGTH>,
    contract_storage_update_requests: BoundedVec<StorageUpdateRequest, MAX_PUBLIC_DATA_UPDATE_REQUESTS_PER_CALL>,
    contract_storage_reads: BoundedVec<StorageRead, MAX_PUBLIC_DATA_READS_PER_CALL>,
    public_call_stack: BoundedVec<Field, MAX_PUBLIC_CALL_STACK_LENGTH_PER_CALL>,
    new_commitments: BoundedVec<Field, MAX_NEW_COMMITMENTS_PER_CALL>,
    new_nullifiers: BoundedVec<Field, MAX_NEW_NULLIFIERS_PER_CALL>,
    new_l2_to_l1_msgs: BoundedVec<Field, MAX_NEW_L2_TO_L1_MSGS_PER_CALL>,
    unencrypted_logs_hash: [Field; NUM_FIELDS_PER_SHA256],
    unencrypted_log_preimages_length: Field,
    historical_block_data: HistoricalBlockData,
    prover_address: Address,
}

impl PublicCircuitPublicInputsBuilder {
    pub fn new() -> Self {
        let mut public_inputs: PublicCircuitPublicInputsBuilder = dep::std::unsafe::zeroed();
        public_inputs.call_context.msg_sender = fixtures::MSG_SENDER;
        public_inputs.historical_block_data = fixtures::HISTORICAL_BLOCK_DATA;
        public_inputs
    }

    pub fn finish(self) -> PublicCircuitPublicInputs {
        PublicCircuitPublicInputs {
            call_context: self.call_context,
            args_hash: self.args_hash,
            return_values: self.return_values.storage,
            contract_storage_update_requests: self.contract_storage_update_requests.storage,
            contract_storage_reads: self.contract_storage_reads.storage,
            public_call_stack: self.public_call_stack.storage,
            new_commitments: self.new_commitments.storage,
            new_nullifiers: self.new_nullifiers.storage,
            new_l2_to_l1_msgs: self.new_l2_to_l1_msgs.storage,
            unencrypted_logs_hash: self.unencrypted_logs_hash,
            unencrypted_log_preimages_length: self.unencrypted_log_preimages_length,
            historical_block_data: self.historical_block_data,
            prover_address: self.prover_address,
        }
    }
}