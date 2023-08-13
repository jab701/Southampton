/*
------------------------------------------------------------------------
--
--                   (C) COPYRIGHT 2001-2008 SYNOPSYS INC.
--                             ALL RIGHTS RESERVED
--
-- This software and the associated documentation are confidential and
-- proprietary to Synopsys, Inc.  Your use or disclosure of this software
-- is subject to the terms and conditions of a written license agreement
-- between you, or your company, and Synopsys, Inc.
--
--  The entire notice above must be reproduced on all authorized copies.
--
-- File :                       DW_apb_gpio.v
-- Version      :               $Revision: #24 $
-- Abstract     :               Top level DW_apb_gpio
--                              This APB Slave is a
--                              General Purpose Input/Output
--                              peripheral
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
`include "DW_apb_constants.v"
`include "DW_apb_cc_constants.v"
`include "DW_apb_gpio_cc_constants.v"

module i_gpio_DW_apb_gpio(



  pclk,             // APB Clock     
                   pclk_intr,        // APB Clock used in detection
                   // of edge-sensitive interrupts and
                   // in synchronisation of level-sensitive
                   // interrupts.
                   presetn,          // APB Reset signal (active-low)
                   penable,          // APB Enable Control signal
                   pwrite,           // APB Write Control signal
                   pwdata,           // APB Write Data Bus
                   paddr,            // APB Address Bus
                   psel,             // APB Peripheral Select
                   dbclk,            // Debounce Clock
                   // used to remove glitches from
                   // interrupt signal lines
                   dbclk_res_n,      // Reset from debounce clock domain
                   scan_mode,        // Scan mode enable signal
                   gpio_ext_porta,   // Input data
                   gpio_porta_dr,    // Output Data
                   gpio_porta_ddr,   // Data Direction Control
                   gpio_intr_flag,   // Combined Interrupt Detect Flag
                   gpio_intrclk_en,  // Indicates that pclk_intr must be running
                   // to detect interrupts 
                   prdata// APB Read Data Bus
                   
                   );

  input    pclk;
  input    pclk_intr;
  input    presetn;
  input    penable;
  input    pwrite;
  input    scan_mode;
  input  [`APB_DATA_WIDTH-1:0] pwdata;
  input  [`GPIO_ADDR_SLICE_LHS:0]     paddr;
  input    psel;
  input    dbclk;
  input    dbclk_res_n;
  input [`GPIO_PWIDTH_A-1:0] gpio_ext_porta;

  output [`GPIO_PWIDTH_A-1:0] gpio_porta_dr;
  output [`GPIO_PWIDTH_A-1:0] gpio_porta_ddr;
  output   gpio_intr_flag;
  output   gpio_intrclk_en;
  output [`APB_DATA_WIDTH-1:0] prdata;

  wire                       dbclk;
  wire                       dbclk_res_n;
  wire                       scan_mode;
// leda DFT_002 off
// Internally generated clock detected
// This wire is need as the pclk_intr input can be removed by
// a configuration parameter. If removed the internal signal is not
// used and DC will blow logic away.
  wire                       pclk_intr;
// leda DFT_002 on
  wire [`APB_DATA_WIDTH-1:0] prdata;
  wire [`GPIO_PWIDTH_A-1:0] gpio_swporta_dr;
  wire [`GPIO_PWIDTH_A-1:0] gpio_swporta_ddr;
  wire [`GPIO_CTL_WIDTH_A-1:0] gpio_swporta_ctl;
  wire [`GPIO_PWIDTH_B-1:0] gpio_swportb_dr;
  wire [`GPIO_PWIDTH_B-1:0] gpio_swportb_ddr;
  wire [`GPIO_CTL_WIDTH_B-1:0] gpio_swportb_ctl;
  wire [`GPIO_PWIDTH_C-1:0] gpio_swportc_dr;
  wire [`GPIO_PWIDTH_C-1:0] gpio_swportc_ddr;
  wire [`GPIO_CTL_WIDTH_C-1:0] gpio_swportc_ctl;
  wire [`GPIO_PWIDTH_D-1:0] gpio_swportd_dr;
  wire [`GPIO_PWIDTH_D-1:0] gpio_swportd_ddr;
  wire [`GPIO_CTL_WIDTH_D-1:0] gpio_swportd_ctl;
  wire [`GPIO_PWIDTH_A-1:0] gpio_inten;
  wire [`GPIO_PWIDTH_A-1:0] gpio_intmask;
  wire [`GPIO_PWIDTH_A-1:0] gpio_inttype_level;
  wire [`GPIO_PWIDTH_A-1:0] gpio_int_polarity;
  wire [`GPIO_PWIDTH_A-1:0] gpio_intr;
  wire [`GPIO_PWIDTH_A-1:0] gpio_intr_n;
  wire [`GPIO_PWIDTH_A-1:0] gpio_raw_intstatus;
  wire [`GPIO_PWIDTH_A-1:0] gpio_debounce;
  wire [`GPIO_LS_SYNC_WIDTH-1:0] gpio_ls_sync;
  wire [`GPIO_PWIDTH_A-1:0] gpio_porta_eoi;
  wire [`GPIO_PWIDTH_A-1:0] gpio_ext_porta_rb;
  wire [`GPIO_PWIDTH_B-1:0] gpio_ext_portb_rb;
  wire [`GPIO_PWIDTH_C-1:0] gpio_ext_portc_rb;
  wire [`GPIO_PWIDTH_D-1:0] gpio_ext_portd_rb;
  wire [`GPIO_PWIDTH_A-1:0] gpio_ext_porta;
  wire [`GPIO_PWIDTH_B-1:0] gpio_ext_portb;
  wire [`GPIO_PWIDTH_C-1:0] gpio_ext_portc;
  wire [`GPIO_PWIDTH_D-1:0] gpio_ext_portd;
  wire [`GPIO_PWIDTH_A-1:0] aux_porta_out;
  wire [`GPIO_PWIDTH_B-1:0] aux_portb_out;
  wire [`GPIO_PWIDTH_C-1:0] aux_portc_out;
  wire [`GPIO_PWIDTH_D-1:0] aux_portd_out;
  wire [`GPIO_PWIDTH_A-1:0] aux_porta_en;
  wire [`GPIO_PWIDTH_B-1:0] aux_portb_en;
  wire [`GPIO_PWIDTH_C-1:0] aux_portc_en;
  wire [`GPIO_PWIDTH_D-1:0] aux_portd_en;
  wire [`GPIO_PWIDTH_A-1:0] gpio_porta_dr;
  wire [`GPIO_PWIDTH_B-1:0] gpio_portb_dr;
  wire [`GPIO_PWIDTH_C-1:0] gpio_portc_dr;
  wire [`GPIO_PWIDTH_D-1:0] gpio_portd_dr;
  wire [`GPIO_PWIDTH_A-1:0] gpio_porta_ddr;
  wire [`GPIO_PWIDTH_B-1:0] gpio_portb_ddr;
  wire [`GPIO_PWIDTH_C-1:0] gpio_portc_ddr;
  wire [`GPIO_PWIDTH_D-1:0] gpio_portd_ddr;
  wire [`GPIO_PWIDTH_A-1:0] aux_porta_in;
  wire [`GPIO_PWIDTH_B-1:0] aux_portb_in;
  wire [`GPIO_PWIDTH_C-1:0] aux_portc_in;
  wire [`GPIO_PWIDTH_D-1:0] aux_portd_in;
  wire  gpio_intr_flag;
  wire  gpio_intr_flag_n;
  wire [`GPIO_PWIDTH_A-1:0] gpio_intstatus;


 i_gpio_DW_apb_gpio_apbif
  U_apb_gpio_apbif(
  .pclk(pclk),
  .presetn(presetn),
  .penable(penable),
  .pwrite(pwrite),
  .pwdata(pwdata),
  .paddr(paddr[`GPIO_ADDR_SLICE_LHS:`GPIO_ADDR_SLICE_RHS]),
  .psel(psel),
  .gpio_swporta_dr(gpio_swporta_dr),
  .gpio_swporta_ddr(gpio_swporta_ddr),
  .gpio_swporta_ctl(gpio_swporta_ctl),
  .gpio_swportb_dr(gpio_swportb_dr),
  .gpio_swportb_ddr(gpio_swportb_ddr),
  .gpio_swportb_ctl(gpio_swportb_ctl),
  .gpio_swportc_dr(gpio_swportc_dr),
  .gpio_swportc_ddr(gpio_swportc_ddr),
  .gpio_swportc_ctl(gpio_swportc_ctl),
  .gpio_swportd_dr(gpio_swportd_dr),
  .gpio_swportd_ddr(gpio_swportd_ddr),
  .gpio_swportd_ctl(gpio_swportd_ctl),
  .gpio_inten(gpio_inten),
  .gpio_intmask(gpio_intmask),
  .gpio_inttype_level(gpio_inttype_level),
  .gpio_int_polarity(gpio_int_polarity),
  .gpio_intstatus(gpio_intstatus),
  .gpio_raw_intstatus(gpio_raw_intstatus),
  .gpio_debounce(gpio_debounce),
  .gpio_porta_eoi(gpio_porta_eoi),
  .gpio_ext_porta_rb(gpio_ext_porta_rb),
  .gpio_ext_portb_rb(gpio_ext_portb_rb),
  .gpio_ext_portc_rb(gpio_ext_portc_rb),
  .gpio_ext_portd_rb(gpio_ext_portd_rb),
  .gpio_ls_sync(gpio_ls_sync),
  .prdata(prdata)
);



i_gpio_DW_apb_gpio_ctrl
 U_apb_gpio_ctrl  (
  .pclk(pclk),
  .pclk_intr(pclk_intr),
  .dbclk(dbclk),
  .presetn(presetn),
  .dbclk_res(dbclk_res_n),
  .scan_mode(scan_mode),
  .gpio_swporta_dr(gpio_swporta_dr),
  .gpio_swporta_ddr(gpio_swporta_ddr),
  .gpio_swporta_ctl(gpio_swporta_ctl),
  .gpio_swportb_dr(gpio_swportb_dr),
  .gpio_swportb_ddr(gpio_swportb_ddr),
  .gpio_swportb_ctl(gpio_swportb_ctl),
  .gpio_swportc_dr(gpio_swportc_dr),
  .gpio_swportc_ddr(gpio_swportc_ddr),
  .gpio_swportc_ctl(gpio_swportc_ctl),
  .gpio_swportd_dr(gpio_swportd_dr),
  .gpio_swportd_ddr(gpio_swportd_ddr),
  .gpio_swportd_ctl(gpio_swportd_ctl),
  .gpio_inten(gpio_inten),
  .gpio_intmask(gpio_intmask),
  .gpio_inttype_level(gpio_inttype_level),
  .gpio_int_polarity(gpio_int_polarity),
  .gpio_debounce(gpio_debounce),
  .gpio_porta_eoi(gpio_porta_eoi),
  .gpio_ext_porta(gpio_ext_porta),
  .gpio_ext_portb(gpio_ext_portb),
  .gpio_ext_portc(gpio_ext_portc),
  .gpio_ext_portd(gpio_ext_portd),
  .gpio_ls_sync(gpio_ls_sync),
  .aux_porta_out(aux_porta_out),
  .aux_portb_out(aux_portb_out),
  .aux_portc_out(aux_portc_out),
  .aux_portd_out(aux_portd_out),
  .aux_porta_en(aux_porta_en),
  .aux_portb_en(aux_portb_en),
  .aux_portc_en(aux_portc_en),
  .aux_portd_en(aux_portd_en),
  .gpio_porta_dr(gpio_porta_dr),
  .gpio_portb_dr(gpio_portb_dr),
  .gpio_portc_dr(gpio_portc_dr),
  .gpio_portd_dr(gpio_portd_dr),
  .gpio_porta_ddr(gpio_porta_ddr),
  .gpio_portb_ddr(gpio_portb_ddr),
  .gpio_portc_ddr(gpio_portc_ddr),
  .gpio_portd_ddr(gpio_portd_ddr),
  .aux_porta_in(aux_porta_in),
  .aux_portb_in(aux_portb_in),
  .aux_portc_in(aux_portc_in),
  .aux_portd_in(aux_portd_in),
  .gpio_ext_porta_rb(gpio_ext_porta_rb),
  .gpio_ext_portb_rb(gpio_ext_portb_rb),
  .gpio_ext_portc_rb(gpio_ext_portc_rb),
  .gpio_ext_portd_rb(gpio_ext_portd_rb),
  .gpio_intr_flag(gpio_intr_flag),
  .gpio_intr(gpio_intr),
  .gpio_intr_flag_n(gpio_intr_flag_n),
  .gpio_intr_n(gpio_intr_n),
  .gpio_intr_int(gpio_intstatus),
  .gpio_raw_intstatus(gpio_raw_intstatus),
  .gpio_intrclk_en(gpio_intrclk_en)
);



  `undef GPIO_ENCRYPT

endmodule
