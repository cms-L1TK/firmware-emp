set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse /users/sb19423/integration_test/tf_integration_work/proj/tm_vivado_test/in.txt
#add_files -fileset sim_1 -norecurse ../out.txt
add_files -fileset constrs_1 -norecurse /users/sb19423/integration_test/tf_integration_work/proj/tm_vivado_test/../../src/l1tk-for-emp/top/firmware/ucf/constraints.xdc

set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1] 
set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS true [get_runs synth_1]