// --=================================================================--
// This confidential and proprietary software may be used only as
// authorised by a licensing agreement from ARM Limited
//   (c) COPYRIGHT 2001 ARM Limited
//       ALL RIGHTS RESERVED
// The entire notice above must be reproduced on all authorised
// copies and copies may only be made to the extent permitted
// by a licensing agreement from ARM Limited.
//
// ---------------------------------------------------------------------
// Version and Release Control Information:
//
// File Name           : ahb_sram_ctl_zbt.v
// File Revision       : 0.1, David Flynn
// File Revision       : 0.2, Matthew Swabey
// File Revision       : 0.3, Matthew Swabey
// File Revision       : 0.4, Matthew Swabey
// File Revision       : 0.5, Matthew Swabey
//
// Release Information : taped out but not tested
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
//  Purpose             : AHB zero-wait-state 32-bit SRAM controller
//
//  use standard compiled flow-through SSRAM (byte-wide)
//  * reads all pipelined with AHB
//  * writes buffered and scheduled for next AHB write or idle cycle
//  * coherency logic supports read-after-write accesses
//    [i.e. if read address matches buffered write then write data
//     returned]
//  * supports byte-write so coherency is per-byte resolution
//    [i.e. ensure word read after byte write returns coherent data]
//  * Write enables bundled together to support multi we SRAM
// ---------------------------------------------------------------------

module ahb_sram_ctl_zbt
   (
//    cfgbigend
//   ,dmaread  // 0 = normal access, 1 = snoop write addresss->read
// AHB inputs
   HCLK
   ,HRESETn
   ,HADDR
   ,HTRANS
   ,HWRITE
   ,HSIZE
   //,HBURST unused
   //,HPROT unused
   ,HWDATA
   ,HSEL
   ,HREADY_in
// AHB outputs
   ,HRDATA
   ,HREADY
   ,HRESP
// SSRAM interface
   ,RAMADDR
   ,RAMWDATA
   ,RAMRDATA
   ,RAMDATAEN
   ,RAMCLK
   ,RAMWEBYTEn
   ,RAMOEn
   ,RAMCEn
   );

parameter SRAM_ADDR_WIDTH = 10;
parameter SRAM_ADDR_MSB = SRAM_ADDR_WIDTH - 1;

//input         cfgbigend;
//input         dmaread;

input         HCLK;
input         HRESETn;
input  [31:0] HADDR;
input  [ 1:0] HTRANS;
input  [ 1:0] HSIZE;   
input         HWRITE;
input  [31:0] HWDATA;
input         HSEL;
input         HREADY_in;

output [31:0] HRDATA;
output        HREADY;
output [ 1:0] HRESP;
    
output [SRAM_ADDR_MSB:2] RAMADDR;
output [31:0] RAMWDATA;
input  [31:0] RAMRDATA;
output        RAMDATAEN;
output        RAMCLK;
output [ 3:0] RAMWEBYTEn;
output        RAMOEn;
output        RAMCEn;

// local signals

wire          read_sel;     // valid read select
wire          write_sel;    // valid write select
wire          ram_sel;      // ram access select
wire          raddr_match;   // read address match buffered write
wire   [ 3:0] rdbypass;     // read-data bypass (from write buffer)
wire   [ 1:0] byteaddr;     // endian-modified byte address
wire   [ 3:0] maskwrite;    // byte lane masked write decoding

reg           write_cyc;    // write cycle (valid HWDATA)
reg     [3:0] write_pend;   // write pending (per byte lane)
reg    [31:0] wdata;        // write data register
reg [SRAM_ADDR_MSB:2] raddr; //read address register
reg [SRAM_ADDR_MSB:2] waddr; //write address register
reg     [1:0] wsize;        // write size register
reg     [1:0] wbyteaddr;    // write byte addressing register
reg           wbigend;      // bigend config registered
wire		cfgbigend;
wire		dmaread;

wire   [ 3:0] ramwe;
wire          ramoe;
wire          ramce;
wire          ramwr;

assign cfgbigend = 1'b0;
assign dmaread = 1'b0;

//-------------------------------------------------------------------
// valid AHB access cycle
assign read_sel  = HREADY_in & HTRANS[1] & ((HSEL & ~HWRITE) |  dmaread);
assign write_sel = HREADY_in & HTRANS[1] & ((HSEL &  HWRITE) & ~dmaread);

//-------------------------------------------------------------------
// Write-cycle state follower
  always @ ( posedge HCLK or negedge HRESETn) begin
      if (~HRESETn)
        begin
          raddr      <= 32'b0;
          waddr      <= 32'b0;
          wsize      <= 2'b00;
          wbyteaddr  <= 2'b00;
          wbigend    <= 1'b0;
          write_cyc  <= 1'b0;
          wdata      <= 32'b0;
          write_pend <= 4'b0000;
        end
      else
        begin
          if (read_sel) // capture read address for coherency check
              raddr[SRAM_ADDR_MSB:2]<= HADDR[SRAM_ADDR_MSB:2];
          if (write_sel) // capture write address for buffered write
              waddr[SRAM_ADDR_MSB:2]<= HADDR[SRAM_ADDR_MSB:2];
          if (write_sel) // capture write size for byte decoding
              wsize[1:0] <= HSIZE[1:0];
          if (write_sel) // capture low addresses for byte decoding
              wbyteaddr[1:0] <= HADDR[1:0];
          if (write_sel) // capture bigend setting for byte decoding
              wbigend <= cfgbigend;
          write_cyc <= write_sel; // set flag to capture write data
          if (write_cyc) // captured buffered write data
              wdata[31:0] <= HWDATA[31:0];
          // maintain byte-mask write flags as pending
          // hold until write or idle cycle (non-read access in fact)
          write_pend[0] <= read_sel & (maskwrite[0] | write_pend[0]);
          write_pend[1] <= read_sel & (maskwrite[1] | write_pend[1]);
          write_pend[2] <= read_sel & (maskwrite[2] | write_pend[2]);
          write_pend[3] <= read_sel & (maskwrite[3] | write_pend[3]);
        end
  end // always @ ( posedge HCLK or negedge HRESETn)

//-------------------------------------------------------------------
// byte write enable generation, factoring in endian configuration
assign byteaddr[0] = wbigend ^ wbyteaddr[0];
assign byteaddr[1] = wbigend ^ wbyteaddr[1];
   
assign maskwrite[0] = write_cyc
                    & (wsize[1] | (~byteaddr[1] & (wsize[0] | ~byteaddr[0])));

assign maskwrite[1] = write_cyc
                    & (wsize[1] | (~byteaddr[1] & (wsize[0] |  byteaddr[0])));

assign maskwrite[2] = write_cyc
                    & (wsize[1] | ( byteaddr[1] & (wsize[0] | ~byteaddr[0])));

assign maskwrite[3] = write_cyc
                    & (wsize[1] | ( byteaddr[1] & (wsize[0] |  byteaddr[0])));

//-------------------------------------------------------------------
// coherency support (for read after write of buffered write data
assign raddr_match = (raddr == waddr); // compare word addresses

assign rdbypass[0] = raddr_match & write_pend[0];
assign rdbypass[1] = raddr_match & write_pend[1];
assign rdbypass[2] = raddr_match & write_pend[2];
assign rdbypass[3] = raddr_match & write_pend[3];

assign HRDATA[ 7: 0] = (rdbypass[0]) ? wdata[ 7: 0] : RAMRDATA[ 7: 0];
assign HRDATA[15: 8] = (rdbypass[1]) ? wdata[15: 8] : RAMRDATA[15: 8];
assign HRDATA[23:16] = (rdbypass[2]) ? wdata[23:16] : RAMRDATA[23:16];
assign HRDATA[31:24] = (rdbypass[3]) ? wdata[31:24] : RAMRDATA[31:24];

//-------------------------------------------------------------------
// SSRAM enable (critical path)
// AHB_read select is latest timing, reset are internal cycle timing)
assign ramce = read_sel // highest priority
             | write_cyc // or a write cycle (word/half/byte)
             | (write_pend[3:0] != 4'b000) // any pending byte writes
             ;

assign RAMCEn = ~ramce;

assign RAMWDATA[31: 0] = (write_cyc) ? HWDATA[31:0] : wdata[31:0];


//-------------------------------------------------------------------
// byte write enables for instant or buffered write
assign ramwe[0] = ~read_sel // highest priority
                & (write_cyc & maskwrite[0] | write_pend[0]);
assign RAMWEBYTEn[0] = ~ramwe[0];

assign ramwe[1] = ~read_sel // highest priority
                & (write_cyc & maskwrite[1] | write_pend[1]);
assign RAMWEBYTEn[1] = ~ramwe[1];

assign ramwe[2] = ~read_sel // highest priority
                & (write_cyc & maskwrite[2] | write_pend[2]);
assign RAMWEBYTEn[2] = ~ramwe[2];

assign ramwe[3] = ~read_sel // highest priority
                & (write_cyc & maskwrite[3] | write_pend[3]);
assign RAMWEBYTEn[3] = ~ramwe[3];

//-------------------------------------------------------------------
// ZBT SRAM output drivers
//------------------------------------------------------------------
// ensure that ZBT cannot drive out during a write 
assign RAMOEn = write_cyc;

assign RAMADDR = (read_sel) ?  HADDR[SRAM_ADDR_MSB:2] : waddr;
  
assign RAMCLK = HCLK;

assign HRESP  = 2'b00;

assign HREADY =1'b1;

endmodule
