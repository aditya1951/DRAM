# DRAM
# DRAM Controller Module Documentation

## Overview
This Verilog module implements a DRAM controller with read/write operations, parity-based error handling, and refresh simulation. Manages a 1M x 32-bit memory array with single-cycle operations.

## Module Interface
| Signal       | Direction | Width | Description                     |
|--------------|-----------|-------|---------------------------------|
| row          | input     | 10    | Row address (0-1023)            |
| col          | input     | 10    | Column address (0-1023)         |
| data_in      | input     | 32    | Write data with parity          |
| read         | input     | 1     | Read enable (active high)       |
| write        | input     | 1     | Write enable (active high)      |
| data_out     | output    | 32    | Read data (tri-state when idle) |
| refresh      | input     | 1     | Refresh trigger                 |
| clk          | input     | 1     | System clock (posedge trigger)  |

## State Machine
stateDiagram-v2
[*] --> INITIALIZATION
INITIALIZATION --> IDLE
IDLE --> READ: read=1
IDLE --> WRITE: write=1
IDLE --> REFRESH: refresh=1
READ --> IDLE
WRITE --> IDLE
REFRESH --> IDLE

## Key Features
### 1. Memory Architecture
- **Organization**: 1024 rows × 1024 columns
- **Word Size**: 32 bits (31 data bits + 1 parity bit)
- **Capacity**: 4 MB (1,048,576 × 32 bits)

### 2. Error Handling
- **Parity Scheme**: Even parity (MSB as parity bit)
- **Detection**: XOR reduction of all 32 bits
- **Correction**: Auto-complement MSB on error detection
- **Simulation Alerts**:
$display("Error detected in the input");
$display("Error is fixed by complementing the parity bit");

### 3. Refresh Mechanism
- **Simulation**: Full-array dummy write every refresh cycle
- **Timing**: Completes in 1 clock cycle (simplified model)
- **Real-World Note**: Actual DRAM requires distributed refresh (7.8μs interval)

## Timing Characteristics
| Operation | Latency | Throughput |
|-----------|---------|------------|
| Read      | 1 cycle | 1 word/cycle |
| Write     | 1 cycle | 1 word/cycle |
| Refresh   | 1 cycle | Full array  |

## Usage Guide
### Write Sequence
/ Write to row 255, column 128
@(posedge clk) begin
write <= 1'b1;
row <= 10'd255; // 0x0FF
col <= 10'd128; // 0x080
data_in <= 32'h89ABCDE0; // Auto-parity calculation
end
// Completes in 1 clock cycle


### Read Sequence
// Read from row 255, column 128
@(posedge clk) begin
read <= 1'b1;
row <= 10'd255;
col <= 10'd128;
end
// data_out valid next cycle:
// 32'h09ABCDE0 (if original had parity error)

## Design Considerations
### Parity Implementation
- **Bit Position**: MSB (bit 31) serves as parity
- **Calculation**: 
parity = ^data_in; // XOR reduction
- **Correction Logic**:
{~data_in, data_in[30:0]} // Flip MSB on error

### Refresh Limitations
- **Simulation Artifact**: Full-array refresh in 1 cycle
- **Real-World Adaptation**:
- Implement row-wise refresh
- Add refresh counter
- Support CAS-before-RAS refresh

## Configuration Parameters
| Parameter         | Value  | Description               |
|-------------------|--------|---------------------------|
| INTIALIZARTION    | 0      | Initialization state      |
| IDLE              | 1      | Standby state             |
| READ              | 2      | Read operation state      |
| WRITE             | 3      | Write operation state     |
| REFRESH           | 4      | Refresh operation state   |

> **Warning**: Contains non-standard parity-based error correction. Not suitable for production environments requiring SECDED ECC.

## Simulation Notes
1. **Initialization**: Clears all memory locations to zero
2. **Contention Handling**: Priority order (refresh > write > read)
3. **Tri-State Output**: data_out = 32'bz when inactive

## Revision History
- v1.0 (2025-06-09): Initial release
- v1.1 (2025-06-10): Added parity error messages

