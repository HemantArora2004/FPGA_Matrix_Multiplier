# Set variables
set work_dir [file normalize [file join [file dirname [info script]] ..]]
set vsim_path "C:\intelFPGA\20.1\modelsim_ase\win32aloem"


    # Navigate to working directory
    cd $work_dir
    
    # Compile design files
    vlog ../Source/memory_access_control.sv
    vlog ../Simulation/memory_access_control_tb.sv
    
    # Elaborate the top-level module
    vsim mem_tb
    
    # Run simulation
    run -all
    
    # Display waveform
    add wave -r *
    wave zoom full
    wave open
    
    # Set some UI preferences
    configure wave -namecolwidth 150
    


# Exit TCL
exit