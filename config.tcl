# User config
set script_dir [file dirname [file normalize [info script]]]

# name of your project, should also match the name of the top module
set ::env(DESIGN_NAME) wrapped_wb_hyperram

# add your source files here
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/wrapper.v \
    $::env(DESIGN_DIR)/wb_hyperram/src/wb_hyperram.v \
    $::env(DESIGN_DIR)/wb_hyperram/src/hyperram.v \
    $::env(DESIGN_DIR)/wb_hyperram/src/register_rw.v"    

set ::env(FP_PDN_VOFFSET) 0
set ::env(FP_PDN_VPITCH) 5

# OpenROAD reports unconnected nodes as a warning.
# OpenLane typically treats unconnected node warnings 
# as a critical issue, and simply quits.
#
# We'll be leaving it up to the designer's discretion to
# enable/disable this: if LVS passes you're probably fine
# with this option being turned off.
##set ::env(FP_PDN_CHECK_NODES) 0

# set absolute size of the die to 300 x 300 um
set ::env(DIE_AREA) "0 0 300 300"
set ::env(FP_SIZING) absolute

# define number of IO pads
set ::env(SYNTH_DEFINES) "MPRJ_IO_PADS=38"

# disable inserting additional clk_buffers on design I/O to avoid multiple drivers and collisions
# (In multi design there must be only tristated outputs!)
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(CLOCK_PORT) "wb_clk_i"

# macro needs to work inside Caravel, so can't be core and can't use metal 5
set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5

# define power straps so the macro works inside Caravel's PDN
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

# macro placement
# set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro_placement.cfg

# regular pin order seems to help with aggregating all the macros for the group project
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

# turn off CVC as we have multiple power domains
set ::env(RUN_CVC) 0

set ::env(CELL_PAD) 4
set ::env(RUN_SPEF_EXTRACTION) 0

set filename ./designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

