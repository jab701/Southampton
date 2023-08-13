/*
------------------------------------------------------------------------
--
--                  (C) COPYRIGHT 2000-2008 SYNOPSYS INC.
--                          ALL RIGHTS RESERVED
--
-- This software and the associated documentation are confidential and
-- proprietary to Synopsys, Inc.  Your use or disclosure of this software
-- is subject to the terms and conditions of a written license agreement
-- between you, or your company, and Synopsys, Inc.
--
--  The entire notice above must be reproduced on all authorized copies.
--
-- File :                       DW_apb.v
-- Author:                      Chris Gilbert
-- Date :                       $Date: 2008/06/29 $
-- Version      :               $Revision: #27 $
-- Abstract     :               Top level for DW_apb
--                              This module maps the apb submodules
--                              together.
--
--          DW_ocb_amba_constants.v      // generic amba definitions
--          DW_apb_constants.v           // definitions for Bridge
--          DW_apb_cc_constants.v        // coreConsultant Parameters
--          DW_apb_ahbsif.v              // AHB slave interface
--          DW_apb_dcdr.v                // APB address decoder
--          DW_apb_slcr.v                // APB write data slicer
--          DW_apb_deslcr.v              // APB read data deslicer 
--          DW_apb_prdmux.v              // PRDATA mux from slaves
--          DW_apb_psel.v
--
-- The module is structured as shown:-
--
--                                  ______
--                                 |      |
--                                 | slcr |-----------> pwdata
--                           ----->|      |
-- hrdata <---------------  |      |______|
--                        | |          |        prdmux
--            __________  | |   -------           /|
-- haddr  -->|          |---   |    ________     / |<-- prdata_s0
-- htrans -->|          | |    |   |        |   |  |       .
--           |  ahbsif  |  --------| deslcr |<--|  |       .
--           |          |      |   |________|   |  |       .
-- hwrite -->|          |------|       |         \ |<-- prdata_s15
-- hwdata -->|          |      |       |          \|
--           |__________|      |----------------------> paddr
--            | |     |        |
-- pclk_en ---  |     |        |    ------
--              |     |         -->| dcdr |
--              |     |            |      |
--              |     |             ------
--              |     |                |
--              |     |             ______     -------> psel_s0
--              |     |            |      |   /            .
--              |      ----------->| psel |---             .
--              |                  |______|   \            .    
--              |                              -------> psel_s15
--              |
--               -------------------------------------> penable
--                                          \ 
--                                            --------> pwrite
--
--
//
// Please refer to the databook for full details on the signals.
//
// These are found in the "Signal Description" section of the "Signals" chapter.
// There are details on the following
//   % Input Delays
//   % Output Delays
//   Any False Paths
//   Any Multicycle Paths
//   Any Asynchronous Signals
//
-- =====================================================================
*/
`include "DW_amba_constants.v"
`include "DW_apb_cc_constants.v"
`include "DW_apb_constants.v"

module i_apb_DW_apb (         // system clock and reset
                        hclk, 
               hresetn,
               // AHB control signals - i/p to DW_apb
               haddr, 
               hready, 
               hsel,
               htrans, 
               hwrite,
               hsize, 
               hburst,
               // DW_apb control response signals to AHB
               hresp, 
               hready_resp,
               // AHB write data, read data
               hwdata, 
               hrdata,
               // clock enable signal for DW_apb
               // indicates a PCLK rising edge.
               pclk_en,
               // APB control signals output by DW_apb
               paddr, 
               penable, 
               pwrite,
               // APB write data (to all slaves)
               pwdata,
               psel_s3,
               psel_s2,
               psel_s1,
               psel_s0,
               prdata_s3,
               prdata_s2,
               prdata_s1,
               prdata_s0
               );
//-----------------
// IO declarations
//-----------------
input                         hclk;
// AHB system clock
input                         hresetn;
// AHB system reset

input [`HADDR_WIDTH-1:0]      haddr;
// AHB address bus
input                         hready;
// AHB ready signal
input                         hsel;
// AHB APB select line
input [`HTRANS_WIDTH-1:0]     htrans;
// AHB transfer type bus
input                         hwrite;
// AHB write signal
input [`HSIZE_WIDTH-1:0]      hsize;
// AHB transfer type bus
input [`HBURST_WIDTH-1:0]     hburst;
// AHB transfer type bus

input [`AHB_DATA_WIDTH-1:0]   hwdata;
// AHB write data bus
output [`AHB_DATA_WIDTH-1:0]  hrdata;
// AHB read data bus

output                        hready_resp;
// hready output
output [`HRESP_WIDTH-1:0]     hresp;
// AHB response bus

input                         pclk_en;
// enable strobe for PCLK

output [`PADDR_WIDTH-1:0]     paddr;
// APB address
output                        penable;
// APB penable strobe


// Slave Selects for the APB slaves.
output                        psel_s0; 
output                        psel_s1;
output                        psel_s2;
output                        psel_s3;

output [`APB_DATA_WIDTH-1:0]  pwdata;
// APB write data
output                        pwrite;
// APB write strobe
 
// read data busses from APB slaves
input [`APB_DATA_WIDTH-1:0]    prdata_s0;
input [`APB_DATA_WIDTH-1:0]    prdata_s1;
input [`APB_DATA_WIDTH-1:0]    prdata_s2;
input [`APB_DATA_WIDTH-1:0]    prdata_s3;



//
// Depending on the number of slaves that are specified then the
// input will not be there. By declaring a wire with the same
// name allows the code to compile and for dc_shell to remove the
// code that would be associated with the signal
//

wire  [`APB_DATA_WIDTH-1:0]    prdata_s0;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s1;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s2;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s3;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s4;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s5;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s6;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s7;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s8;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s9;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s10;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s11;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s12;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s13;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s14;
wire  [`APB_DATA_WIDTH-1:0]    prdata_s15;

//---------------------------
// wire and reg declarations
//---------------------------

wire [`HRESP_WIDTH-1:0]        hresp;
wire [`PADDR_WIDTH-1:0]        paddr;
wire [`AHB_DATA_WIDTH-1:0]     hwdata;
wire [`APB_DATA_WIDTH-1:0]     pwdata;
wire                           penable;
wire                           pwrite;
wire                           hready_resp;
wire                           psel_s0;
wire                           psel_s1;
wire                           psel_s2;
wire                           psel_s3;
wire                           psel_s4;
wire                           psel_s5;
wire                           psel_s6;
wire                           psel_s7;
wire                           psel_s8;
wire                           psel_s9;
wire                           psel_s10;
wire                           psel_s11;
wire                           psel_s12;
wire                           psel_s13;
wire                           psel_s14;
wire                           psel_s15;

// Bussed version of the prdata bus from each slave
wire [`PRDATABUS_WIDTH-1:0]     prdatabus;
wire [`MAX_PRDATABUS_WIDTH-1:0] max_prdatabus;
// Big or Little Endian System
wire                           big_endian_sel; 
// output from prdmux
wire [`APB_DATA_WIDTH-1:0]     prdata_int;
// interconnect between ahbsif and slcr - 32 bits wide
wire [`HWDATA32_WIDTH-1:0]    pwdata_int;
// max width bus, prdmux to deslcr, prevents port width mismatches
reg  [`MAX_APB_DATA_WIDTH-1:0] prdata_apb;
// deslcr output to ahbsif, maximally configured to remove pkging
wire [`MAX_AHB_DATA_WIDTH-1:0] hrdata_max;
// write data bus from ahbsif to slcr, max width to remove packaging
reg  [`MAX_AHB_DATA_WIDTH-1:0] hwdata_max;
// write data bus to slaves, max width to remove packaging
// pwdata is sliced from this bus
wire [`MAX_APB_DATA_WIDTH-1:0] pwdata_apb;
// timing strobe for DW_apb_psel and any other modules that need to know
// when the APB is active, used to gate psel signals to slaves
wire                           psel_en;
// enable for DW_apb_psel
wire [`MAX_APB_SLAVES-1:0]     psel_apb;
// from psel to top level
wire [`NUM_APB_SLAVES-1:0]     psel_int;
// i/p to psel and prdmux
wire [1:0]                     paddr_wr;
// Selects the pwdata from pwdata_int, only changes when the address changes.
//--------------------------------------------
// instantiate the AHB Slave interface module
//--------------------------------------------

  i_apb_DW_apb_ahbsif
   U_DW_apb_ahbsif (
    .big_endian_sel (big_endian_sel),
    .hclk           (hclk),
    .hresetn        (hresetn),
    .haddr          (haddr),
    .hready         (hready),
    .hsel           (hsel),
    .htrans         (htrans),
    .hwrite         (hwrite),
    .hwdata_max     (hwdata_max),
    .hready_resp    (hready_resp),
    .hresp          (hresp),
    .pclk_en        (pclk_en),
    .paddr          (paddr),
    .paddr_wr       (paddr_wr),
    .pwdata_int     (pwdata_int),
    .pwrite         (pwrite),
    .penable        (penable),
    .psel_en        (psel_en)
  );

//-----------------------------------------
// Instantiate the address decoder circuit
//-----------------------------------------

  i_apb_DW_apb_dcdr
   U_DW_apb_dcdr (
    .paddr    (paddr),        // input address bus
    .psel_int (psel_int)      // PSEL output bus
  );


//
// Build internal busses from master and slave signals, The following 
// assign statements are generated by a tcl plugin script.
//
   

// end of generated "assign" statements



//--------------------------------------------------------------
// Instantiate the slicer and deslicer modules. These slice the
// hwdata bus onto the pwdata bus based on the paddr lsb's and
// map the prdata_int bus to the appropriate hrdata slice.
// For the case where
// `APB_DATA_WIDTH == `AHB_DATA_WIDTH (== 32 AMBA Rev 2.0 spec)
// these modules equate to feedthroughs
//--------------------------------------------------------------

  i_apb_DW_apb_slcr
   U_DW_apb_slcr (
    .big_endian_sel (big_endian_sel),
    .paddr          (paddr_wr),
    .pwdata_int     (pwdata_int), // write data from AHB
    .pwdata_apb     (pwdata_apb)  // write data to APB
  );

  i_apb_DW_apb_deslcr
   U_DW_apb_deslcr (
    .big_endian_sel (big_endian_sel),
    .paddr          (paddr),
    .prdata_apb     (prdata_apb), // read data from APB
    .hrdata_max     (hrdata_max)  // read data to AHB
  );

//-------------------------------
// Instantiate the read data mux
//-------------------------------

  i_apb_DW_apb_prdmux
   U_DW_apb_prdmux (
    .psel_int   (psel_int),  // Slave select from dcdr
    .prdatabus  (prdatabus), // data from slave(s)
    .prdata_int (prdata_int) // output data
  );

//------------------------------------
// Instantiate the PSEL_enable module
//------------------------------------

  i_apb_DW_apb_psel
   U_DW_apb_psel (
    .psel_en  (psel_en),
    .psel_int (psel_int),
    .psel_apb (psel_apb[`NUM_APB_SLAVES-1:0])
  );

  assign big_endian_sel = `BIG_ENDIAN;

  assign pwdata = pwdata_apb[`APB_DATA_WIDTH-1:0];

//
// Avoid reuse pragmas on the data bus. Could implement within a module
// where the input is APB_DATA_WIDTH bits wide, the output is 
// MAX_APB_DATA_WIDTH bits wide and as only APB_DATA_WIDTH bits would 
// be used the others would not be needed and would be blown away by 
// dc_shell. As module is synthesised flat this code is left inline 
// here. Likewise for prdata_apb.
//
  always @(hwdata) begin
    hwdata_max = {`MAX_AHB_DATA_WIDTH{1'b0}};
    hwdata_max[`AHB_DATA_WIDTH-1:0] = hwdata[`AHB_DATA_WIDTH-1:0];
  end

  always @(prdata_int) begin
    prdata_apb = {`MAX_APB_DATA_WIDTH{1'b0}};
    prdata_apb[`APB_DATA_WIDTH-1:0] = prdata_int;
  end

  assign hrdata[`AHB_DATA_WIDTH-1:0] = hrdata_max[`AHB_DATA_WIDTH-1:0];


//
// Internally we have one read back data bus which is defined to be the maximum size
// of 32*16 bits wide. Then the prdatabus calculates which bits are required
// by only using the APB_DATA_WIDTH*APB_NNUM_SLAVES
//

  assign max_prdatabus[`APB_DATA_WIDTH-1:0]                         = prdata_s0;
  assign max_prdatabus[(`APB_DATA_WIDTH*2)-1:(`APB_DATA_WIDTH)]     = prdata_s1;
  assign max_prdatabus[(`APB_DATA_WIDTH*3)-1:(`APB_DATA_WIDTH*2)]   = prdata_s2;
  assign max_prdatabus[(`APB_DATA_WIDTH*4)-1:(`APB_DATA_WIDTH*3)]   = prdata_s3;
  assign max_prdatabus[(`APB_DATA_WIDTH*5)-1:(`APB_DATA_WIDTH*4)]   = prdata_s4;
  assign max_prdatabus[(`APB_DATA_WIDTH*6)-1:(`APB_DATA_WIDTH*5)]   = prdata_s5;
  assign max_prdatabus[(`APB_DATA_WIDTH*7)-1:(`APB_DATA_WIDTH*6)]   = prdata_s6;
  assign max_prdatabus[(`APB_DATA_WIDTH*8)-1:(`APB_DATA_WIDTH*7)]   = prdata_s7;
  assign max_prdatabus[(`APB_DATA_WIDTH*9)-1:(`APB_DATA_WIDTH*8)]   = prdata_s8;
  assign max_prdatabus[(`APB_DATA_WIDTH*10)-1:(`APB_DATA_WIDTH*9)]  = prdata_s9;
  assign max_prdatabus[(`APB_DATA_WIDTH*11)-1:(`APB_DATA_WIDTH*10)] = prdata_s10;
  assign max_prdatabus[(`APB_DATA_WIDTH*12)-1:(`APB_DATA_WIDTH*11)] = prdata_s11;
  assign max_prdatabus[(`APB_DATA_WIDTH*13)-1:(`APB_DATA_WIDTH*12)] = prdata_s12;
  assign max_prdatabus[(`APB_DATA_WIDTH*14)-1:(`APB_DATA_WIDTH*13)] = prdata_s13;
  assign max_prdatabus[(`APB_DATA_WIDTH*15)-1:(`APB_DATA_WIDTH*14)] = prdata_s14;
  assign max_prdatabus[(`APB_DATA_WIDTH*16)-1:(`APB_DATA_WIDTH*15)] = prdata_s15;
  assign prdatabus = max_prdatabus[`PRDATABUS_WIDTH-1:0];

//-----------------------------------------------------------
// split out the psel_apb bus to the individual psel signals
// psel_s0 is always present.
//-----------------------------------------------------------

  assign psel_s0 = psel_apb[0];
  assign psel_s1 = psel_apb[1];
  assign psel_s2 = psel_apb[2];
  assign psel_s3 = psel_apb[3];
  assign psel_s4 = psel_apb[4];
  assign psel_s5 = psel_apb[5];
  assign psel_s6 = psel_apb[6];
  assign psel_s7 = psel_apb[7];
  assign psel_s8 = psel_apb[8];
  assign psel_s9 = psel_apb[9];
  assign psel_s10 = psel_apb[10];
  assign psel_s11 = psel_apb[11];
  assign psel_s12 = psel_apb[12];
  assign psel_s13 = psel_apb[13];
  assign psel_s14 = psel_apb[14];
  assign psel_s15 = psel_apb[15];

  `undef APB_ENCRYPT


endmodule

