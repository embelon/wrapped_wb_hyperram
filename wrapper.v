`default_nettype none
`ifdef FORMAL
    `define MPRJ_IO_PADS 38    
`endif
module wrapped_wb_hyperram (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    // wishbone interface
    input wire wb_clk_i,            // clock, runs at system clock
    input wire wb_rst_i,            // main system reset
    input wire wbs_stb_i,           // wishbone write strobe
    input wire wbs_cyc_i,           // wishbone cycle
    input wire wbs_we_i,            // wishbone write enable
    input wire [3:0] wbs_sel_i,     // wishbone write word select
    input wire [31:0] wbs_dat_i,    // wishbone data in
    input wire [31:0] wbs_adr_i,    // wishbone address
    output wire wbs_ack_o,          // wishbone ack
    output wire [31:0] wbs_dat_o,   // wishbone data out

    // Logic Analyzer Signals
    // only provide first 32 bits to reduce wiring congestion
    input  wire [31:0] la_data_in,  // from PicoRV32 to your project
    output wire [31:0] la_data_out, // from your project to PicoRV32
    input  wire [31:0] la_oenb,     // output enable bar (low for active)

    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,  // in to your project
    output wire [`MPRJ_IO_PADS-1:0] io_out, // out fro your project
    output wire [`MPRJ_IO_PADS-1:0] io_oeb, // out enable bar (low active)

    // IRQ
    output wire [2:0] irq,          // interrupt from project to PicoRV32

    // extra user clock
    input wire user_clock2,
    
    // active input, only connect tristated outputs if this is high
    input wire active
);

    // all outputs must be tristated before being passed onto the project
    wire buf_wbs_ack_o;
    wire [31:0] buf_wbs_dat_o;
    wire [31:0] buf_la_data_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_oeb;
    wire [2:0] buf_irq;

    `ifdef FORMAL
    // formal can't deal with z, so set all outputs to 0 if not active
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'b0;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'b0;
    assign la_data_out  = active ? buf_la_data_out  : 32'b0;
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'b0}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'b0}};
    assign irq          = active ? buf_irq          : 3'b0;
    `include "properties.v"
    `else
    // tristate buffers
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'bz;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'bz;
    assign la_data_out  = active ? buf_la_data_out  : 32'bz;
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'bz}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'bz}};
    assign irq          = active ? buf_irq          : 3'bz;
    `endif
    
    wire hb_dq_oen;

    wb_hyperram hyperram (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wbs_stb_i(wbs_stb_i),
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_we_i(wbs_we_i),
        .wbs_sel_i(wbs_sel_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_addr_i(wbs_adr_i),
        .wbs_ack_o(buf_wbs_ack_o),
        .wbs_dat_o(buf_wbs_dat_o),

        .rst_i(la_data_in[0] | !active),            // keep IP in reset if not active / selected

	.hb_rstn_o(buf_io_out[8]),
	.hb_csn_o(buf_io_out[9]),
	.hb_clk_o(buf_io_out[10]),
	.hb_clkn_o(buf_io_out[11]),
	.hb_rwds_o(buf_io_out[12]),
	.hb_rwds_oen(buf_io_oeb[12]),
	.hb_rwds_i(io_in[12]),        
	.hb_dq_o(buf_io_out[20:13]),
	.hb_dq_oen(hb_dq_oen),
	.hb_dq_i(io_in[20:13])
    );

    assign buf_io_oeb[20:13] = {8{hb_dq_oen}};

    // enable outputs for rst, csn, clk, clkn 
    assign buf_io_oeb[11:8] = 4'h0;

endmodule 
`default_nettype wire
