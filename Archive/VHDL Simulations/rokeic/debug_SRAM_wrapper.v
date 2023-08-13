//Behaves like a 32 bit wide sram with byte writes

module debug_SRAM_wrapper (
  clk,
  en,
  resetn,
  webyte, 
  ramaddr, 
  ramwdata, 
  ramrdata,
  access_bits_in,
  access_bits_out
  );
  
  parameter ADDR_WIDTH = 8;
  parameter ADDR_BUS_MSB = ADDR_WIDTH - 1;

  input        clk;
  input  [3:0] en;
  input        resetn;
  input  [3:0] webyte;
  input  [ADDR_BUS_MSB:2] ramaddr;
  input  [31:0] ramwdata;
  output [31:0] ramrdata;
  input  [55:0] access_bits_in;
  output [55:0] access_bits_out;

  wire  clk;
  wire  [3:0] en;
  wire  resetn;
  wire  [3:0] webyte;
  wire  [ADDR_BUS_MSB:2] ramaddr;
  wire  [31:0] ramwdata;
  wire  [31:0] ramrdata;
  wire  [55:0] access_bits_in;
  wire  [55:0] access_bits_out;
  wire  access_en;

  wire  [3:0] mux_en;
  wire  [3:0] mux_webyte;
  wire  [ADDR_BUS_MSB:2] mux_ramaddr;
  wire  [31:0] mux_ramwdata;

  reg	[1:0] en_trig_state;
  reg   set_trig_sync;

parameter [1:0] 
	en_trig_set = 2'b00,
	en_trig_trig = 2'b01,
	en_trig_wait = 2'b10;

always @( posedge clk or negedge resetn) begin
	if(!resetn) begin
	set_trig_sync <= 1'b0;
	end else begin
		set_trig_sync <= access_bits_in[48];
	end
end

always @( posedge clk or negedge resetn) begin
	if(!resetn) begin
	en_trig_state <= en_trig_set;
	end else begin
		case(en_trig_state)
			en_trig_set: begin
				if(access_en & set_trig_sync) begin
					en_trig_state <= en_trig_trig;
				end
			end
			en_trig_trig: begin
					en_trig_state <= en_trig_wait;
			end
			en_trig_wait: begin
				if(access_bits_in[48] == 0) begin
					en_trig_state <= en_trig_set;
				end
			end
		endcase
	end
end

assign mux_en = (access_en) ? {4{en_trig_state == en_trig_trig}} : {en};

assign access_en = access_bits_in[55];
assign mux_webyte = (access_en) ? {4{access_bits_in[49]}} : webyte;
assign mux_ramaddr = (access_en) ? {{ (47-ADDR_BUS_MSB){1'b0}}, access_bits_in[(32+ADDR_BUS_MSB):32]} : ramaddr;
assign mux_ramwdata = (access_en) ? access_bits_in[31:0] : ramwdata;

assign access_bits_out[55] = access_bits_in[55];
assign access_bits_out[54:50] = 32'b0;
assign access_bits_out[49] = access_bits_in[49];
assign access_bits_out[48] = access_bits_in[48];
assign access_bits_out[47:32] = {{ (47-ADDR_BUS_MSB){1'b0}}, access_bits_in[(32+ADDR_BUS_MSB):32]};
assign access_bits_out[31:0] = (access_bits_in[49]) ? access_bits_in[31:0] : ramrdata; //If writing read the data begin written

 
sram32 #(
  .ADDR_WIDTH(ADDR_WIDTH)
  ) sram (
  .clk(clk),
  .en(mux_en[0]),
  .we(mux_webyte),
  .addr(mux_ramaddr),
  .data_in(mux_ramwdata[31:0]),
  .data_out(ramrdata[31:0])
);
  
 
/*sram #(
  .DATA_WIDTH(8),
  .ADDR_WIDTH(`SRAM_ADDR_WIDTH),
  .FILENAME("raminit3.hex")
  ) 
  sram_b3 (
  .clk(clk),
  .en(mux_en[3]),
  .we(mux_webyte[3]),
  .addr(mux_ramaddr),
  .data_in(mux_ramwdata[31:24]),
  .data_out(ramrdata[31:24])
  );
  
sram #(
  .DATA_WIDTH(8),
  .ADDR_WIDTH(`SRAM_ADDR_WIDTH),
  .FILENAME("raminit2.hex")
  ) 
  sram_b2 (
  .clk(clk),
  .en(mux_en[2]),
  .we(mux_webyte[2]),
  .addr(mux_ramaddr),
  .data_in(mux_ramwdata[23:16]),
  .data_out(ramrdata[23:16])
  );
  
sram #(
  .DATA_WIDTH(8),
  .ADDR_WIDTH(`SRAM_ADDR_WIDTH),
  .FILENAME("raminit1.hex")
  ) 
  sram_b1 (
  .clk(clk),
  .en(mux_en[1]),
  .we(mux_webyte[1]),
  .addr(mux_ramaddr),
  .data_in(mux_ramwdata[15:8]),
  .data_out(ramrdata[15:8])
  );
  
sram #(
  .DATA_WIDTH(8),
  .ADDR_WIDTH(`SRAM_ADDR_WIDTH),
  .FILENAME("raminit0.hex")
  ) 
  sram_b0 (
  .clk(clk),
  .en(mux_en[0]),
  .we(mux_webyte[0]),
  .addr(mux_ramaddr),
  .data_in(mux_ramwdata[7:0]),
  .data_out(ramrdata[7:0])
  );  
*/    
endmodule
