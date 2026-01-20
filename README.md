# Mini CPU – Verilog RTL Project

This repository contains a Mini CPU that I designed and implemented in Verilog as a
learning-oriented but engineering-driven RTL project.

I built this CPU step by step, starting from a basic instruction fetch mechanism and
gradually adding a control FSM, a simple datapath, branching support, and a HALT state.
The focus of the project is not performance, but clarity, correctness, and full
understanding of the RTL design flow.

The design is fully synthesizable and was later packaged as a Vivado IP core to practice
a realistic FPGA integration flow.

---

## Project Goals

The main goals of this project were:

- Practice full RTL ownership, from instruction definition to verification  
- Design a simple multi-cycle CPU using an explicit FSM  
- Write clean, readable, and synthesizable Verilog  
- Verify functionality using a self-checking testbench  
- Gain experience packaging RTL as a Vivado IP core  

This project was intentionally kept simple to ensure that every design decision is
fully understood and traceable.

---

## Key Features

- 8-bit datapath and 16-bit instruction format defined by me  
- FSM-based control (no pipeline, by design)  
- Explicit FETCH / DECODE / EXEC / WB / HALT states  
- 4-entry general-purpose register file  
- Conditional branching (BNE) implemented in the control FSM  
- Dedicated HALT state that stops program execution  
- Self-checking testbench used to validate instruction behavior  
- Packaged as a Vivado IP core and integrated into a block design  

---

## Architecture Overview

The CPU follows a simple multi-cycle architecture controlled by a finite state machine.
Each instruction is executed across multiple clock cycles, which keeps the datapath
simple and makes the control logic explicit and easy to debug.

Main architectural parameters:

- Data width: 8 bits  
- Instruction width: 16 bits  
- Program Counter (PC): 8 bits  
- Instruction memory: 256 × 16  
- Register file: 4 × 8-bit registers  

There is no data memory and no pipelining. These choices were made intentionally to
focus on control logic, instruction sequencing, and verification.

---

## Instruction Format

Each instruction is 16 bits wide and divided as follows:

[15:12] Opcode
[11:10] Destination register (rd)
[9:8] Source register (rs)
[7:0] Immediate value (imm8)

This simple format allowed me to implement arithmetic and branching instructions while
keeping decode logic straightforward.

---

## Supported ISA

| Opcode | Instruction     | Description          |
|--------|-----------------|----------------------|
| ADD    | ADD rd, rs      | Register addition    |
| ADDI   | ADDI rd, imm    | Immediate addition   |
| SUB    | SUB rd, rs      | Subtraction          |
| CMP    | CMP rd, rs      | Compare (flags only) |
| BNE    | BNE rd, rs, imm | Branch if not equal  |
| HALT   | HALT            | Stop CPU execution   |

---

## Control FSM

The CPU is controlled by a Finite State Machine (FSM) with the following states:

- FETCH:   Read instruction from instruction memory  
- DECODE:  Decode opcode and operands  
- EXEC:    Perform ALU operation or branch decision  
- WB:      Write results back to the register file  
- HALT:    Stop CPU execution  

Separating instruction execution into explicit states helped with debugging and made
the control flow very clear in simulation.

---

## Verification

The project includes a **self-checking testbench** that:

- Initializes instruction memory and registers  
- Executes a loop using BNE  
- Verifies correct HALT behavior  
- Checks final register values  
- Detects timeout conditions  

Verification is done entirely in simulation and focuses on functional correctness rather
than performance or timing closure.

### Demo Program

R0 = N
R1 = 1
R2 = 0

loop:
ADDI R2, 1
SUB R0, R1
BNE R0, R3, loop
HALT

Expected result:

- R0 = 0  
- R2 = N  
- CPU enters HALT state  

---

## Vivado IP Packaging

After completing RTL development and verification, I packaged the CPU as a Vivado IP
core. This allowed me to:

- Define clean RTL interfaces  
- Integrate the CPU into a Vivado block design  
- Practice an FPGA-style IP reuse workflow  

This step was added to simulate a more realistic FPGA development environment.

---

## Design Decisions and Limitations

Some features were intentionally not implemented:

- No pipelining  
- No data memory  
- No interrupts or exceptions  

These limitations were chosen to keep the design focused and manageable, and to ensure
that the control logic and verification are fully understood.

---

## How to Run the Simulation

1. Compile the RTL and testbench files in your preferred simulator  
2. Run the testbench  
3. Observe FSM transitions, register updates, and HALT behavior in the waveform  

---

## 📁 Repository Structure

    mini-cpu-verilog/
    ├── rtl/
    │   ├── mini_cpu.v
    │   └── mini_cpu_wrapper_sim.v
    │
    ├── tb/
    │   └── mini_cpu_demo_TB.v
    │
    ├── docs/
    │   └── images/
    │       ├── Block_Diagram_Full_System.jpeg
    │       ├── Simulation_Waveform.jpeg
    │       └── TCL_Console_results.jpeg
    │
    └── README.md

---

## Visuals

### Full System Block Diagram
Mini CPU packaged as a Vivado IP and integrated into a block design.

![Block Diagram](docs/images/Block_Diagram_Full_System.jpeg)

### Simulation Waveform
Simulation showing full system operation, PC progression, register updates, and HALT behavior.

![Simulation Waveform](docs/images/Simulation_Waveform.jpeg)

### TCL Console Results
Self-checking testbench output demonstrating successful execution and PASS indication.

![TCL Console Results](docs/images/TCL_Console_results.jpeg)

---

## Tools

- Verilog HDL  
- Xilinx Vivado  

---

## Notes

This project was built as a **learning and demonstration platform** for RTL design,
verification, and system-level thinking, and is suitable for discussion in FPGA / RTL
design interviews.

Feedback and suggestions are always welcome.
