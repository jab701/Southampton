/*
------------------------------------------------------------------------
--
--                  (C) COPYRIGHT 2001-2008 SYNOPSYS, INC.
--                            ALL RIGHTS RESERVED
--
--  This software and the associated documentation are confidential and
--  proprietary to Synopsys, Inc.  Your use or disclosure of this
--  software is subject to the terms and conditions of a written
--  license agreement between you, or your company, and Synopsys, Inc.
--
--  The entire notice above must be reproduced on all authorized copies.
--
-- File :                       DW_ahb.v
-- Date :                       $Date: 2008/05/19 $
-- Version      :               $Revision: #68 $
-- Abstract     :               Top-level DW_ahb BusIP
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
------------------------------------------------------------------------
*/

`include "DW_amba_constants.v"
`include "DW_ahb_constants.v"
`include "DW_ahb_cc_constants.v"

module i_ahb_DW_ahb (
  hclk,
               hresetn,
               haddr_m1,
               hburst_m1,
               hlock_m1,
               hprot_m1,
               hsize_m1,
               htrans_m1,
               hwdata_m1,
               hwrite_m1,
               hsel_s1,
               hready_resp_s1,
               hresp_s1,
               hrdata_s1,
               hsel_s2,
               hready_resp_s2,
               hresp_s2,
               hrdata_s2,
               haddr,
               hburst,
               hprot,
               hsize,
               htrans,
               hwdata,
               hwrite,
               hready,
               hresp,
               hrdata,
               hmaster,
               hmaster_data,
               hmastlock
               );

  // ----------------------------------------
  // Parameters inherited from the cc_constant 
  // file, make them not visible from the GUI
  // ----------------------------------------

  // physical parameters
  parameter haddr_width = 32;
  parameter ahb_data_width = 32;


  // memory map parameters
  parameter r1_n_sa_1 = 32'h4000000;
  parameter r1_n_ea_1 = 32'h4003fff;
  parameter r1_n_sa_2 = 32'h0;
  parameter r1_n_ea_2 = 32'hfff;

  // derived parameters
  parameter addrbus_width = 64;
  parameter databus_width = 64;
  parameter hrdatabus_width = 96;

  input                          hclk;
  input                          hresetn;

// Master #1 AHB signals
  input [haddr_width-1:0]        haddr_m1;
  input [`HBURST_WIDTH-1:0]      hburst_m1;
  input                          hlock_m1;
  input [`HPROT_WIDTH-1:0]       hprot_m1;
  input [`HSIZE_WIDTH-1:0]       hsize_m1;
  input [`HTRANS_WIDTH-1:0]      htrans_m1;
  input [ahb_data_width-1:0]     hwdata_m1;
  input                          hwrite_m1;

// Slave #1 AHB signals
  input                          hready_resp_s1;
  input [`HRESP_WIDTH-1:0]       hresp_s1;
  input [ahb_data_width-1:0]     hrdata_s1;
  output                         hsel_s1;

// Slave #2 AHB signals
  input                          hready_resp_s2;
  input [`HRESP_WIDTH-1:0]       hresp_s2;
  input [ahb_data_width-1:0]     hrdata_s2;
  output                         hsel_s2;
  output [haddr_width-1:0]      haddr;
  output [`HBURST_WIDTH-1:0]     hburst;
  output [`HPROT_WIDTH-1:0]      hprot;
  output [`HSIZE_WIDTH-1:0]      hsize;
  output [`HTRANS_WIDTH-1:0]     htrans;
  output [ahb_data_width-1:0]   hwdata;
  output                         hwrite;
  output [`HMASTER_WIDTH-1:0]    hmaster;
  output [`HMASTER_WIDTH-1:0]    hmaster_data;
  output                         hmastlock;
  output                         hready;
  output [`HRESP_WIDTH-1:0]      hresp;
  output [ahb_data_width-1:0]    hrdata;


// Dummy wire declarations for inputs which may have been removed
// by reuse pragmas.

  wire                           ahb_big_endian;
  wire                           remap_n;
  wire                           pause;
  wire                           ahb_sc_arb;
  wire                           ahbarbint;

// Internal concatenated bus of all top-level haddr buses from masters
  wire   [addrbus_width-1:0]     bus_haddr;
  wire   [`HTRANSBUS_WIDTH-1:0]  bus_htrans;
  wire   [`NUM_IAHB_SLAVES:0]    bus_hsel;
  wire   [`INTERNAL_HSEL-1:0]    hsel;
  wire   [`SPLITBUS_WIDTH-1:0]   bus_hsplit;
  wire   [`HRESPBUS_WIDTH-1:0]   bus_hresp;
  wire   [`HREADY_WIDTH-1:0]     bus_hready;
  wire   [hrdatabus_width-1:0]   bus_hrdata;
  wire   [`HBURSTBUS_WIDTH-1:0]  bus_hburst;
  wire   [`HSIZEBUS_WIDTH-1:0]   bus_hsize;
  wire   [`HPROTBUS_WIDTH-1:0]   bus_hprot;
  wire   [`HWRITEBUS_WIDTH-1:0]  bus_hwrite;
  wire   [databus_width-1:0]     bus_hwdata;

  wire   [`HMASTER_WIDTH-1:0]    hmaster_data;
  wire                           hsel_s0;
  wire   [`NUM_AHB_MASTERS:0]    bus_hbusreq;
  wire   [`NUM_AHB_MASTERS:0]    bus_hlock;
  wire   [`NUM_AHB_MASTERS:0]    bus_hgrant;
  wire                           hsel_none;
  wire   [`HRESP_WIDTH-1:0]      hresp_none;
  wire                           hready_resp_none;
  wire   [ahb_data_width-1:0]    hrdata_none;
  wire                           int_pause;
  wire                           int_ahb_sc_arb;
  wire                           int_remap_n;
  wire                           int_ahb_big_endian;
  wire   [`NUM_AHB_MASTERS:1]    ahb_wt_mask;
  wire                           ahb_wt_aps;

  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m15;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m14;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m13;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m12;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m11;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m10;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m9;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m8;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m7;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m6;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m5;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m4;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m3;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m2;
  wire [`AHB_CCL_WIDTH-1:0]      ahb_wt_count_m1;

// These are the signals driven by Master 0, the Internal Dummy
// Master
// The Dummy Master is granted the bus when no other master
// can access the bus.
// The function of the Dummy Master is to drive Default
// Values onto the Address, Data and Control buses when
// no other master can gain access to the bus.

//
// The dummy master
//

  assign bus_haddr[haddr_width-1:0]     = {haddr_width{1'b0}};
  assign bus_htrans[`HTRANS_WIDTH-1:0]   = `IDLE;
  assign bus_hwdata[ahb_data_width-1:0] = {ahb_data_width{1'b0}};
  assign bus_hsize[`HSIZE_WIDTH-1:0]     = `BYTE;
  assign bus_hburst[`HBURST_WIDTH-1:0]   = `SINGLE;
  assign bus_hprot[`HPROT_WIDTH-1:0]     = `NC_NB_P_D;
  assign bus_hwrite[0]                   = `READ;

//
// Build internal busses from master and slave signals, The following 
// assign statements are generated by a tcl plugin script.
//
   
  assign bus_haddr[(haddr_width*2)-1:(haddr_width*1)] = haddr_m1;
  assign bus_htrans[3:2] = htrans_m1;
  assign bus_hburst[5:3] = hburst_m1;
  assign bus_hsize[5:3] = hsize_m1;
  assign bus_hprot[7:4] = hprot_m1;
  assign bus_hwrite[1] = hwrite_m1;
  assign bus_hwdata[(ahb_data_width*2)-1:(ahb_data_width*1)] = hwdata_m1;

  assign bus_hbusreq[1] = 1'b1;
  assign bus_hgrant[1] = 1'b1;
  assign bus_hgrant[0] = 1'b0;
  assign bus_hlock[1] = hlock_m1;

  assign bus_hbusreq[0] = 1'b0;
  assign bus_hlock[0] = 1'b0;
  assign bus_hready[0] = 1;
  assign bus_hresp[1:0] = 0;
  assign bus_hrdata[ahb_data_width-1:0] = 0;

  assign bus_hready[1] = hready_resp_s1;
  assign bus_hresp[3:2] = hresp_s1;
  assign bus_hrdata[(ahb_data_width*2)-1:ahb_data_width*1] = hrdata_s1;

  assign bus_hready[2] = hready_resp_s2;
  assign bus_hresp[5:4] = hresp_s2;
  assign bus_hrdata[(ahb_data_width*3)-1:ahb_data_width*2] = hrdata_s2;

  assign hsel_none = hsel[`NUM_IAHB_SLAVES+1];
  assign hsel_s0 = hsel[0];
  assign hsel_s1 = hsel[1];
  assign hsel_s2 = hsel[2];
  assign bus_hsel = hsel[`NUM_IAHB_SLAVES:0];

  assign bus_hsplit[15:0] = {`HSPLIT_WIDTH{1'b0}};
  assign bus_hsplit[31:16] = {`HSPLIT_WIDTH{1'b0}};


// end of generated "assign" statements
   
  i_ahb_DW_ahb_mux
   #(haddr_width, ahb_data_width)
   U_mux (
    .hclk             (hclk),
    .hresetn          (hresetn),
    .bus_haddr        (bus_haddr),
    .bus_hburst       (bus_hburst),
    .hmaster          (hmaster),
    .bus_hprot        (bus_hprot),
    .bus_hsize        (bus_hsize),
    .bus_htrans       (bus_htrans),
    .bus_hwdata       (bus_hwdata),
    .bus_hwrite       (bus_hwrite),
    .hrdata_none      (hrdata_none),
    .hready_resp_none (hready_resp_none),
    .hresp_none       (hresp_none),
    .bus_hready       (bus_hready),
    .bus_hresp        (bus_hresp),
    .bus_hrdata       (bus_hrdata),
    .hsel             (hsel[`NUM_IAHB_SLAVES:0]),
    .hmaster_data     (hmaster_data),
    .haddr            (haddr),
    .hburst           (hburst),
    .hprot            (hprot),
    .hsize            (hsize),
    .htrans           (htrans),
    .hwdata           (hwdata),
    .hwrite           (hwrite),
    .hrdata           (hrdata),
    .hready           (hready),
    .hresp            (hresp)
  );

// To avoid reuse pragmas swap use of port when it is configured to be
// removed.
  assign int_remap_n        = (`REMAP == 1'b1) ? remap_n : 1'b1;
  assign int_ahb_big_endian = (`AHB_XENDIAN == 1'b1) ? ahb_big_endian : 1'b1;
  
  i_ahb_DW_ahb_dcdr
   #(haddr_width, r1_n_sa_1, r1_n_ea_1, r1_n_sa_2, r1_n_ea_2) U_dcdr (
    .haddr            (haddr),
    .remap_n          (int_remap_n),
    .hsel             (hsel)
  );


  assign int_pause      = (`PAUSE == 1'b1) ? pause : 1'b0;
  assign int_ahb_sc_arb = (`AHB_SINGLE_CYCLE_ARBITRATION == 1'b1) ? ahb_sc_arb : 1'b0;



  i_ahb_DW_ahb_arblite
   U_arblite (
    .hclk             (hclk),
    .hresetn          (hresetn),
    .hlock_m1         (hlock_m1),
    .hready           (hready),
    .hmaster          (hmaster),
    .hmastlock        (hmastlock)
  );


  i_ahb_DW_ahb_dfltslv
   #(ahb_data_width)
   U_dfltslv (
    .hclk             (hclk),
    .hresetn          (hresetn),
    .hready           (hready),
    .htrans           (htrans),
    .hsel_none        (hsel_none),
    .hready_resp_none (hready_resp_none),
    .hresp_none       (hresp_none),
    .hrdata_none      (hrdata_none)
  );


    `undef AHB_ENCRYPT 

endmodule
