# Define the path to your existing project
set project_path "C:/Users/Hemant/Documents/Programming/XilinxFPGA/Matrix_Multiplier/Matrix_Multiplier.xpr"

# Define a list of Verilog files to synthesize
set verilog_files {
    "C:/Users/Hemant/Documents/Programming/XilinxFPGA/Matrix_Multiplier/Matrix_Multiplier.GitHub/Source/Matrix_Multiplier.sv"
    "C:/Users/Hemant/Documents/Programming/XilinxFPGA/Matrix_Multiplier/Matrix_Multiplier.GitHub/Source/Single_Port_RAM.sv"

}

# Define the path to your constraints file
set constraints_file "C:/Users/Hemant/Documents/Programming/XilinxFPGA/Matrix_Multiplier/Matrix_Multiplier.GitHub/Constraint/Basys-3-Master.xdc"

# Open the existing project
open_project $project_path

# Add specified Verilog files to the project
foreach file $verilog_files {
    add_files $file
}

# Add constraints file to the project
add_files $constraints_file

# Reset synthesis run if needed
reset_run synth_1

# Run synthesis
launch_runs synth_1 -jobs 12

# Wait for synthesis to complete
wait_on_run synth_1

