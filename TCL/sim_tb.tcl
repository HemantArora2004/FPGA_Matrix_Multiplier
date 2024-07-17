# Change to the project root directory (one level up from the TCL directory)
cd ..

# Create and set the library
vlib work
vmap work work

# Compile the design and testbench files
vlog ../Source/memory_access_control.sv
vlog ../Simulation/memory_access_control_tb.sv


# Run the simulation
vsim -gui work.memory_access_control_tb

# Add signals to the waveform (optional)
add wave -r /*
run -all