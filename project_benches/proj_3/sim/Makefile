export ECE745_PROJECT_HOME ?= $(PWD)/../../..

include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/parameter_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile	
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile

GEN_TRANS_TYPE ?= wb_transaction
TEST_SEED ?= 1234567890


clean: 
	rm -rf work *.wlf transcript
	rm -rf *.ucdb

comp_I2C_MB:
	vcom -cover bcefst ../rtl/iicmb_int_pkg.vhd
	vcom -cover bcefst ../rtl/iicmb_pkg.vhd
	vcom -cover bcefst ../rtl/mbyte.vhd
	vcom -cover bcefst ../rtl/mbit.vhd
	vcom -cover bcefst ../rtl/bus_state.vhd
	vcom -cover bcefst ../rtl/filter.vhd
	vcom -cover bcefst ../rtl/conditioner.vhd
	vcom -cover bcefst ../rtl/conditioner_mux.vhd
	vcom -cover bcefst ../rtl/iicmb_m.vhd
	vcom -cover bcefst ../rtl/regblock.vhd
	vcom -cover bcefst ../rtl/wishbone.vhd
	vcom -cover bcefst ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_parameter_pkg comp_i2c_pkg comp_wb_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

debug: clean compile simulate

run: clean compile

run_cli:
	vsim -c -coverage -sv_seed $(TEST_SEED) -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value i2cmb_test; coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: run run_cli

merge_coverage: 
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb
	
view_coverage:
	vsim -viewcov ./sim_and_testplan_merged.ucdb

view_test:
	vsim -c -cvgperinstance -viewcov wb_transaction.1234567890.ucdb -do "coverage report -output final_report.txt -srcfile=* -detail -option -cvg; quit -f"
