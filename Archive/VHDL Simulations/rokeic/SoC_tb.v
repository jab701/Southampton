// FPGA_SoC Testbench
//
// TODO
// Connect to the rest of the FPGA_SoC
// Transmit Serial Data to program the SoC to stimulate the output port
//
`include "SoC_inc.v"

module ATb ();
  
real clk_high_period = 0.5/`CLK_FREQ_MHZ*1E3;
real db_serial_baud_period = 1.0/(`DEBUG_SERIAL_BAUD*1.0E-9);

reg clk = 0;
reg resetn = 0;
reg test_enable = 0;
reg db_resetn = 0;
reg db_send_line = 1;
wire db_read_line;

integer null;
integer i;
integer j;
integer k;
integer l;

reg [7:0] db_rx_char = 8'b0;
reg [7:0] db_tx_char = 8'b0;
event db_tx;
integer image;
reg [63:0] ram_image_string = 64'b0;

wire [7:0] gpio_port_a;

//assign gpio_port_a = 8'bZZZZ1111;
//assign gpio_port_b = 8'b0;
//assign gpio_port_c = 8'b0;
//assign gpio_port_d = 8'b0;

//Serial read process. Not robust against glitches
always @(negedge db_read_line) begin
  db_rx_char = 8'b0;    
  #(db_serial_baud_period*1.5) //put us in the middle of the first data bit
  for(i = 0; i < 8; i = i + 1)
  begin 
    db_rx_char = db_rx_char >> 1;
    db_rx_char[7] = db_read_line;
    #db_serial_baud_period 
    null = null;  //Irritatingly we can only delay a statement
  end
  $write ("%c", db_rx_char);
end

//Serial write process.
always @(db_tx) begin
  begin
            
    //$write("*Wrote %c*", db_tx_char);
    db_send_line = 0; //Start Bit
    #db_serial_baud_period
    for(j = 0; j < 8; j = j + 1) begin
      db_send_line = db_tx_char[0];
      
      #db_serial_baud_period
      db_tx_char = db_tx_char >> 1;
    end
    db_send_line = 1; //Stop Bit 
    #(db_serial_baud_period *3)
    null = null;
  end
end

initial begin
//$sdf_annotate("../../dc/export/IBM130_netlist.sdf", SoC);
`ifdef SERIAL_RAM_LOAD
  image = $fopen("./ram.bin","r");
  #(clk_high_period)
  db_resetn = 1;
  #(600*db_serial_baud_period) //Clear the DW_Debugger banner message     
  while(!$feof(image)) begin
    $fgets(ram_image_string, image);
    //$display("%s", ram_image_string);
    if (ram_image_string != 64'b0) begin //Skip the last bogus read from the file
      for(k = 0; k < 8; k = k + 1) begin //Pushout the p X XX\n string
        db_tx_char = ram_image_string[55:48];
        -> db_tx;
        ram_image_string = ram_image_string << 8;
        #(db_serial_baud_period * 12)
        null = null;
      end
    end               
    #(250*db_serial_baud_period) null = null;  
  end
`else
  #(4*clk_high_period)
  db_resetn = 1;
`endif

  #(4*clk_high_period)   
  resetn = 1;
end

always begin
    #clk_high_period clk = ~clk;
end



SoC_wrap SoC_inst (
  .clk(clk),
  .resetn(resetn),
  .db_resetn(db_resetn),
  .test_enable(test_enable),
  .db_rxd(db_send_line),
  .db_txd(db_read_line),
  .gpio_port_a(gpio_port_a)
);

endmodule
