# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

This is coursework for NC State's ECE-310 (Spring 2026): a collection of independent Xilinx Vivado
projects, each implementing a digital design in Verilog and its testbench. There is no top-level
build system tying the projects together — each subdirectory is a self-contained Vivado project.

Target hardware for all projects: **Basys-3 board (Artix-7, part `xc7a35tcpg236-1`)**, Vivado 2025.1,
XSim as the simulator.

## Project layout (per subdirectory)

Every project follows the standard Vivado non-project/GUI-managed directory structure:

```
<ProjectName>/
  <ProjectName>.xpr                       # Vivado project file — open this in Vivado
  <ProjectName>.srcs/sources_1/new/*.v    # design (RTL) sources
  <ProjectName>.srcs/sim_1/new/*_tb.v     # testbenches
  <ProjectName>.srcs/constrs_1/           # XDC pin constraints (when present)
  <ProjectName>.sim/sim_1/behav/xsim/     # generated XSim simulation artifacts (build output)
  <ProjectName>.runs/                     # synthesis/implementation run output (build output, when present)
  <ProjectName>.cache/, .ip_user_files/   # Vivado-generated scratch dirs (build output)
  *.wcfg                                  # saved XSim waveform-viewer layouts
```

The `.cache`, `.sim`, `.runs`, `.ip_user_files`, and `.hw` directories are all Vivado-generated —
never hand-edit files under them. The only files worth reading or editing directly are the `.v`
files under `sources_1/new` and `sim_1/new`, and `.xdc` files under `constrs_1` where present.

Design module naming generally matches the top-level directory name (e.g. `rca_4bit.v` →
module `rca_4bit`), and the paired testbench is `<module>_tb.v` with a top module of the same
name (e.g. `rca_4bit_tb`). A few projects (`Lab7`, `Project_3`, `project_2`) instead use a
`Lab7`/`Project3`/`project2` top module that instantiates several sub-modules defined in the same
file.

Current projects (roughly in the order labs were assigned):
- `rca_4bit` — structural 4-bit ripple-carry adder (Lab 2)
- `Kogge-Stone_Adder` (`ksa_4bit_df`) — 4-bit Kogge-Stone prefix adder (Lab 3)
- `project_2` — signed 8-bit ALU with datapath/control split
- `vending_25c_moore` — Moore FSM for a 25-cent vending machine
- `lab_6` — combinational/sequential exercise
- `shifter_8bit_df` — 8-bit shifter (dataflow)
- `PISO_8bit` / `SIPO_8bit` — parallel-in-serial-out and serial-in-parallel-out shift registers
- `mult_seq_8x8` — sequential 8x8 shift-and-add unsigned multiplier
- `Dadda8x8` — 8x8 Dadda tree multiplier
- `Lab7` — single-digit and 4-digit BCD adders
- `Project_3` — serial BCD ALU built from `SIPO`/`PISO`/BCD-adder sub-blocks over a 41-bit serial packet
- `fp_multiplier` — pipelined Q16.16 fixed-point multiplier (part of a separate multi-person
  "Ray-Sphere Intersection Accelerator" project, not an ECE-310 lab)

## Simulating and testing designs

There is no Vivado CLI on this machine's `PATH`, so full Vivado batch simulation (`xvlog`/`xelab`/`xsim`)
isn't directly runnable from the shell — use the Vivado GUI (open the `.xpr`, run Behavioral Simulation)
for that.

**Icarus Verilog and GTKWave are on `PATH`** and are the fast way to simulate/check a design from the
command line without opening Vivado. From inside a project directory, compile the design + testbench
together and run it, e.g. for `rca_4bit`:

```
iverilog -o sim.vvp rca_4bit.srcs/sources_1/new/rca_4bit.v rca_4bit.srcs/sim_1/new/rca_4bit_tb.v
vvp sim.vvp
```

Testbenches use `$display`/`$monitor` for console output and typically end with `$stop` or run off
the end of their `initial` block — there is no pass/fail assertion framework in use, so "passing" a
testbench means visually checking the printed values against the expected behavior described in the
testbench's comments. If a testbench dumps waveforms (`$dumpfile`/`$dumpvars`, or via the Vivado-generated
`.wcfg`), view the resulting `.vcd`/`.wdb` with `gtkwave`.

`glbl.v` (under `<Project>.sim/sim_1/behav/xsim/`) is Vivado's global-signals stub, only needed when
simulating with Xilinx unisim/IP primitives — most of these designs are plain RTL and don't need it.

## Working on a design

- Match the existing header-comment banner style (Company/Engineer/Create Date/Design Name/... block)
  used in most files when adding a new module.
- Keep the design (`sources_1`) and testbench (`sim_1`) split — don't put stimulus code in the same
  file as the DUT.
- When adding a new lab/project, mirror the existing directory convention
  (`<Name>.srcs/sources_1/new/<Name>.v` + `<Name>.srcs/sim_1/new/<Name>_tb.v`) rather than introducing
  a different layout.
