#include "barretenberg/ecc/curves/bn254/fr.hpp"
#include "barretenberg/proof_system/arithmetization/arithmetization.hpp"
#include <cstdint>
#include <fstream>
#include <iostream>
#include <string>
#include <sys/types.h>
#include <vector>

#include "./AvmMini_trace.hpp"

#include "barretenberg/proof_system/arithmetization/generated/AvmMini_arith.hpp"
#include "barretenberg/proof_system/relations/generated/AvmMini.hpp"

using namespace barretenberg;

namespace proof_system {

using Row = AvmMini_vm::Row<barretenberg::fr>;

void AvmMiniTraceBuilder::build_circuit()
{
    {
        // Number of rows
        size_t n = 256;

        // Basic memory traces validation
        //  m_addr   m_clk   m_val   m_lastAccess   m_rw
        //    2        5       23         0          1
        //    2        8       23         0          0
        //    2        17      15         1          1
        //    5        2       0          0          0
        //    5        24      7          0          1
        //    5        32      7          1          0

        rows.push_back(Row{ .avmMini_first = 1 }); // First row containing only shifted values.

        Row row = Row{
            .avmMini_m_clk = 5,
            .avmMini_m_addr = 2,
            .avmMini_m_val = 23,
            .avmMini_m_lastAccess = 0,
            .avmMini_m_rw = 1,
        };
        rows.push_back(row);

        row = Row{
            .avmMini_m_clk = 8,
            .avmMini_m_addr = 2,
            .avmMini_m_val = 23,
            .avmMini_m_lastAccess = 0,
            .avmMini_m_rw = 0,
        };
        rows.push_back(row);

        row = Row{
            .avmMini_m_clk = 17,
            .avmMini_m_addr = 2,
            .avmMini_m_val = 15,
            .avmMini_m_lastAccess = 1,
            .avmMini_m_rw = 1,
        };
        rows.push_back(row);

        row = Row{
            .avmMini_m_clk = 2,
            .avmMini_m_addr = 5,
            .avmMini_m_val = 0,
            .avmMini_m_lastAccess = 0,
            .avmMini_m_rw = 0,
        };
        rows.push_back(row);

        row = Row{
            .avmMini_m_clk = 24,
            .avmMini_m_addr = 5,
            .avmMini_m_val = 7,
            .avmMini_m_lastAccess = 0,
            .avmMini_m_rw = 1,
        };
        rows.push_back(row);

        row = Row{
            .avmMini_m_clk = 32,
            .avmMini_m_addr = 5,
            .avmMini_m_val = 7,
            .avmMini_m_lastAccess = 1,
            .avmMini_m_rw = 0,
        };
        rows.push_back(row);

        // Set the last flag in the last row
        rows.back().avmMini_last = 1;

        // Fill the rest with zeros.
        for (size_t i = 0; i < n - 7; i++) {
            rows.push_back(Row{});
        }

        // Build the shifts
        // for (size_t i = 1; i < n; i++) {
        //     rows[i - 1].avmMini_m_addr_shift = rows[i].avmMini_m_addr;
        //     rows[i - 1].avmMini_m_rw_shift = rows[i].avmMini_m_rw;
        //     rows[i - 1].avmMini_m_val_shift = rows[i].avmMini_m_val;
        // }

        info("Built circuit with ", rows.size(), " rows");
    }
}
} // namespace proof_system