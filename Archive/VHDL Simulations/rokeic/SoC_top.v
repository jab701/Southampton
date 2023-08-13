
// Wrapper for FPGA synthesis - place bidir tech here
`include "SoC_inc.v"

`timescale 1ns/100ps

module SoC_wrap (
    clk,
    resetn,
    db_resetn,
    test_enable,
    gpio_port_a,
    db_rxd,
    db_txd,
    UARTA_rx,
    UARTA_tx,
    UARTA_baudoutn,
    UARTB_rx,
    UARTB_tx,
    UARTB_baudoutn
  );

    //SoC Signals
    input		clk;
    input		resetn;
    input  		db_resetn;
    input  test_enable;

    //Debugger
    input 		db_rxd;
    output 		db_txd;
    
    //GPIO
    inout	[7:0]   gpio_port_a;

    //UARTA
    input UARTA_rx;
    output UARTA_tx;
    output UARTA_baudoutn;

    //UARTB
    input UARTB_rx;
    output UARTB_tx;
    output UARTB_baudoutn;
    
    //SoC Signals
    wire		clk;
    wire		resetn;
    wire  		db_resetn;

    wire	[7:0]	gpio_ext_porta;
    wire	[7:0]	gpio_porta_ddr;
    wire	[7:0]	gpio_porta_dr;


    wire		UARTA_rx;
    wire		UARTA_tx;
    wire		UARTA_baudoutn;

    wire		UARTB_rx;
    wire		UARTB_tx;
    wire		UARTB_baudoutn;

//Bidirectional logic for FPGA.    
gpio_bidir_ctl gpio_ctrl_a (
  .to_pin(gpio_porta_dr),
  .from_pin(gpio_ext_porta),
  .dir(gpio_porta_ddr),
  .pins(gpio_port_a)
);
    
SoC SoC_inst (
    .clk(clk),
    .resetn(resetn),
    .db_resetn(db_resetn),
    .test_enable(test_enable),
    .db_rxd(db_rxd),
    .db_txd(db_txd),
    .UARTA_rx(UARTA_rx),
    .UARTA_tx(UARTA_tx),
    .UARTB_rx(UARTB_rx),
    .UARTB_tx(UARTB_tx),
    .gpio_ext_porta(gpio_ext_porta),
    .gpio_porta_ddr(gpio_porta_ddr),
    .gpio_porta_dr(gpio_porta_dr)

);    

endmodule


module gpio_bidir_ctl (
  from_pin,
  to_pin,
  dir,
  pins
);

parameter WIDTH = 8;

input	[WIDTH-1:0] to_pin;
input	[WIDTH-1:0] dir;
output	[WIDTH-1:0] from_pin;
inout	[WIDTH-1:0] pins;

wire	[WIDTH-1:0] to_pin;
wire	[WIDTH-1:0] dir;
wire	[WIDTH-1:0] from_pin;
wire	[WIDTH-1:0] pins;

genvar i;

generate
  for (i=0; i<WIDTH; i=i+1) begin : BIDIR_CTL
    assign pins[i] = (dir[i]) ? to_pin[i] : 1'bz;
    assign from_pin[i] = pins[i];
  end
endgenerate

endmodule
