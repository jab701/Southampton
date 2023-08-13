`include "SoC_inc.v"
//Very small verilog ram without reset

module sram (
  clk, 
  en, 
  we, 
  addr, 
  data_in, 
  data_out
);

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8;
parameter ADDR_BUS_MSB = ADDR_WIDTH - 1;
parameter DATA_BUS_MSB = DATA_WIDTH - 1;
parameter FILENAME = "raminit.hex";

  input        clk;
  input        en;
  input        we;
  input  [ADDR_BUS_MSB:0] addr;
  input  [DATA_BUS_MSB:0] data_in;
  output [DATA_BUS_MSB:0] data_out;
  
  wire			clk;
  wire			en;
  wire			we;
  wire	[ADDR_BUS_MSB:0] addr;
  wire   [DATA_BUS_MSB:0] data_in; 
  reg    [DATA_BUS_MSB:0] data_out;
  
  reg    [DATA_BUS_MSB:0] ram [(1<<(ADDR_WIDTH))-1:0];
  
  always @(posedge clk)
    begin
      if (en) begin
        if (we) begin
          ram[addr] <= data_in;
	end
        data_out <= ram[addr];
      end
  end

`ifdef SIMULATE
  initial begin
    $readmemh(FILENAME, ram);
    $display("Module: %m, Filename: %s, First word: %x", FILENAME, ram[0]);
  end
`endif

endmodule
