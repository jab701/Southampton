// This file was automatically generated by coreAssembler (version C-2009.06-SP1).
// 
// FILENAME : /export/fastcad/disktmp/mas/rokeic/digital/common/src/DW/AMBA_Chain/src/AMBA_Chain.v
// DATE : 08/07/10 20:20:58
// ABSTRACT : Verilog top-level subsystem RTL.
// 

module AMBA_Chain (// Ports for Interface DW_apb_gpio-API
                   DW_apb_gpio_API_gpio_ext_porta,
                   DW_apb_gpio_API_gpio_porta_ddr,
                   DW_apb_gpio_API_gpio_porta_dr,
                   // Ports for Interface HCLK
                   hclk,
                   // Ports for Interface HRESETn
                   hresetn,
                   // Ports for Interface PCLK
                   pclk,
                   // Ports for Interface PRESETn
                   presetn,
                   // Ports for Interface SIO
                   SIO_cts_n,
                   SIO_sin,
                   SIO_rts_n,
                   SIO_sout,
                   // Ports for Interface ex_i_ahb_AHB_Master
                   ex_i_ahb_AHB_Master_haddr,
                   ex_i_ahb_AHB_Master_hburst,
                   ex_i_ahb_AHB_Master_hlock,
                   ex_i_ahb_AHB_Master_hprot,
                   ex_i_ahb_AHB_Master_hsize,
                   ex_i_ahb_AHB_Master_htrans,
                   ex_i_ahb_AHB_Master_hwdata,
                   ex_i_ahb_AHB_Master_hwrite,
                   ex_i_ahb_AHB_Master_hrdata,
                   ex_i_ahb_AHB_Master_hready,
                   ex_i_ahb_AHB_Master_hresp,
                   // Ports for Interface i_ahb_AHB_ZBT_SRAM
                   i_ahb_AHB_ZBT_SRAM_hrdata,
                   i_ahb_AHB_ZBT_SRAM_hready_resp,
                   i_ahb_AHB_ZBT_SRAM_hresp,
                   i_ahb_AHB_ZBT_SRAM_haddr,
                   i_ahb_AHB_ZBT_SRAM_hburst,
                   i_ahb_AHB_ZBT_SRAM_hmastlock,
                   i_ahb_AHB_ZBT_SRAM_hprot,
                   i_ahb_AHB_ZBT_SRAM_hready,
                   i_ahb_AHB_ZBT_SRAM_hsel,
                   i_ahb_AHB_ZBT_SRAM_hsize,
                   i_ahb_AHB_ZBT_SRAM_htrans,
                   i_ahb_AHB_ZBT_SRAM_hwdata,
                   i_ahb_AHB_ZBT_SRAM_hwrite,
                   // Ports for Interface uart_B_SIO
                   uart_B_SIO_cts_n,
                   uart_B_SIO_sin,
                   uart_B_SIO_rts_n,
                   uart_B_SIO_sout,
                   // Ports for Manually exported pins
                   i_apb_pclk_en,
                   i_gpio_dbclk,
                   i_gpio_dbclk_res_n,
                   i_gpio_pclk_intr,
                   i_gpio_scan_mode,
                   i_timers_scan_mode,
                   i_timers_timer_1_clk,
                   i_timers_timer_1_resetn,
                   i_timers_timer_2_clk,
                   i_timers_timer_2_resetn,
                   uart_A_dcd_n,
                   uart_A_dsr_n,
                   uart_A_ri_n,
                   uart_A_scan_mode,
                   uart_B_dcd_n,
                   uart_B_dsr_n,
                   uart_B_ri_n,
                   uart_B_scan_mode,
                   i_ahb_hmaster_data,
                   i_gpio_gpio_intr_flag,
                   i_gpio_gpio_intrclk_en,
                   i_timers_timer_en,
                   i_timers_timer_intr,
                   uart_A_baudout_n,
                   uart_A_dma_rx_req_n,
                   uart_A_dma_tx_req_n,
                   uart_A_dtr_n,
                   uart_A_intr,
                   uart_A_out1_n,
                   uart_A_out2_n,
                   uart_A_rxrdy_n,
                   uart_A_txrdy_n,
                   uart_B_baudout_n,
                   uart_B_dma_rx_req_n,
                   uart_B_dma_tx_req_n,
                   uart_B_dtr_n,
                   uart_B_intr,
                   uart_B_out1_n,
                   uart_B_out2_n,
                   uart_B_rxrdy_n,
                   uart_B_txrdy_n
                   );

   // Ports for Interface DW_apb_gpio-API
   input  [7:0]   DW_apb_gpio_API_gpio_ext_porta;
   output [7:0]   DW_apb_gpio_API_gpio_porta_ddr;
   output [7:0]   DW_apb_gpio_API_gpio_porta_dr;
   // Ports for Interface HCLK
   input          hclk;
   // Ports for Interface HRESETn
   input          hresetn;
   // Ports for Interface PCLK
   input          pclk;
   // Ports for Interface PRESETn
   input          presetn;
   // Ports for Interface SIO
   input          SIO_cts_n;
   input          SIO_sin;
   output         SIO_rts_n;
   output         SIO_sout;
   // Ports for Interface ex_i_ahb_AHB_Master
   input  [31:0]  ex_i_ahb_AHB_Master_haddr;
   input  [2:0]   ex_i_ahb_AHB_Master_hburst;
   input          ex_i_ahb_AHB_Master_hlock;
   input  [3:0]   ex_i_ahb_AHB_Master_hprot;
   input  [2:0]   ex_i_ahb_AHB_Master_hsize;
   input  [1:0]   ex_i_ahb_AHB_Master_htrans;
   input  [31:0]  ex_i_ahb_AHB_Master_hwdata;
   input          ex_i_ahb_AHB_Master_hwrite;
   output [31:0]  ex_i_ahb_AHB_Master_hrdata;
   output         ex_i_ahb_AHB_Master_hready;
   output [1:0]   ex_i_ahb_AHB_Master_hresp;
   // Ports for Interface i_ahb_AHB_ZBT_SRAM
   input  [31:0]  i_ahb_AHB_ZBT_SRAM_hrdata;
   input          i_ahb_AHB_ZBT_SRAM_hready_resp;
   input  [1:0]   i_ahb_AHB_ZBT_SRAM_hresp;
   output [31:0]  i_ahb_AHB_ZBT_SRAM_haddr;
   output [2:0]   i_ahb_AHB_ZBT_SRAM_hburst;
   output         i_ahb_AHB_ZBT_SRAM_hmastlock;
   output [3:0]   i_ahb_AHB_ZBT_SRAM_hprot;
   output         i_ahb_AHB_ZBT_SRAM_hready;
   output         i_ahb_AHB_ZBT_SRAM_hsel;
   output [2:0]   i_ahb_AHB_ZBT_SRAM_hsize;
   output [1:0]   i_ahb_AHB_ZBT_SRAM_htrans;
   output [31:0]  i_ahb_AHB_ZBT_SRAM_hwdata;
   output         i_ahb_AHB_ZBT_SRAM_hwrite;
   // Ports for Interface uart_B_SIO
   input          uart_B_SIO_cts_n;
   input          uart_B_SIO_sin;
   output         uart_B_SIO_rts_n;
   output         uart_B_SIO_sout;
   // Ports for Manually exported pins
   input          i_apb_pclk_en;
   input          i_gpio_dbclk;
   input          i_gpio_dbclk_res_n;
   input          i_gpio_pclk_intr;
   input          i_gpio_scan_mode;
   input          i_timers_scan_mode;
   input          i_timers_timer_1_clk;
   input          i_timers_timer_1_resetn;
   input          i_timers_timer_2_clk;
   input          i_timers_timer_2_resetn;
   input          uart_A_dcd_n;
   input          uart_A_dsr_n;
   input          uart_A_ri_n;
   input          uart_A_scan_mode;
   input          uart_B_dcd_n;
   input          uart_B_dsr_n;
   input          uart_B_ri_n;
   input          uart_B_scan_mode;
   output [3:0]   i_ahb_hmaster_data;
   output         i_gpio_gpio_intr_flag;
   output         i_gpio_gpio_intrclk_en;
   output [1:0]   i_timers_timer_en;
   output [1:0]   i_timers_timer_intr;
   output         uart_A_baudout_n;
   output         uart_A_dma_rx_req_n;
   output         uart_A_dma_tx_req_n;
   output         uart_A_dtr_n;
   output         uart_A_intr;
   output         uart_A_out1_n;
   output         uart_A_out2_n;
   output         uart_A_rxrdy_n;
   output         uart_A_txrdy_n;
   output         uart_B_baudout_n;
   output         uart_B_dma_rx_req_n;
   output         uart_B_dma_tx_req_n;
   output         uart_B_dtr_n;
   output         uart_B_intr;
   output         uart_B_out1_n;
   output         uart_B_out2_n;
   output         uart_B_rxrdy_n;
   output         uart_B_txrdy_n;

   wire [31:0]  i_ahb_haddr;
   wire [2:0]   i_ahb_hburst;
   wire         i_ahb_hready;
   wire         i_ahb_hsel_s1;
   wire [2:0]   i_ahb_hsize;
   wire [1:0]   i_ahb_htrans;
   wire [31:0]  i_ahb_hwdata;
   wire         i_ahb_hwrite;
   wire [31:0]  i_apb_hrdata;
   wire         i_apb_hready_resp;
   wire [1:0]   i_apb_hresp;
   wire [31:0]  i_apb_paddr;
   wire         i_apb_penable;
   wire         i_apb_psel_s0;
   wire         i_apb_psel_s1;
   wire         i_apb_psel_s2;
   wire         i_apb_psel_s3;
   wire [31:0]  i_apb_pwdata;
   wire         i_apb_pwrite;
   wire [31:0]  i_gpio_prdata;
   wire [31:0]  i_timers_prdata;
   wire [31:0]  uart_A_prdata;
   wire [31:0]  uart_B_prdata;

   i_ahb_DW_ahb i_ahb
      (.hclk           (hclk),
       .hresetn        (hresetn),
       .haddr_m1       (ex_i_ahb_AHB_Master_haddr),
       .hburst_m1      (ex_i_ahb_AHB_Master_hburst),
       .hlock_m1       (ex_i_ahb_AHB_Master_hlock),
       .hprot_m1       (ex_i_ahb_AHB_Master_hprot),
       .hsize_m1       (ex_i_ahb_AHB_Master_hsize),
       .htrans_m1      (ex_i_ahb_AHB_Master_htrans),
       .hwdata_m1      (ex_i_ahb_AHB_Master_hwdata),
       .hwrite_m1      (ex_i_ahb_AHB_Master_hwrite),
       .hsel_s1        (i_ahb_hsel_s1),
       .hready_resp_s1 (i_apb_hready_resp),
       .hresp_s1       (i_apb_hresp),
       .hrdata_s1      (i_apb_hrdata),
       .hsel_s2        (i_ahb_AHB_ZBT_SRAM_hsel),
       .hready_resp_s2 (i_ahb_AHB_ZBT_SRAM_hready_resp),
       .hresp_s2       (i_ahb_AHB_ZBT_SRAM_hresp),
       .hrdata_s2      (i_ahb_AHB_ZBT_SRAM_hrdata),
       .haddr          (i_ahb_haddr),
       .hburst         (i_ahb_hburst),
       .hprot          (i_ahb_AHB_ZBT_SRAM_hprot),
       .hsize          (i_ahb_hsize),
       .htrans         (i_ahb_htrans),
       .hwdata         (i_ahb_hwdata),
       .hwrite         (i_ahb_hwrite),
       .hready         (i_ahb_hready),
       .hresp          (ex_i_ahb_AHB_Master_hresp),
       .hrdata         (ex_i_ahb_AHB_Master_hrdata),
       .hmaster        (),
       .hmaster_data   (i_ahb_hmaster_data),
       .hmastlock      (i_ahb_AHB_ZBT_SRAM_hmastlock));

   i_apb_DW_apb i_apb
      (.hclk        (hclk),
       .hresetn     (hresetn),
       .haddr       (i_ahb_haddr),
       .hready      (i_ahb_hready),
       .hsel        (i_ahb_hsel_s1),
       .htrans      (i_ahb_htrans),
       .hwrite      (i_ahb_hwrite),
       .hsize       (i_ahb_hsize),
       .hburst      (i_ahb_hburst),
       .hresp       (i_apb_hresp),
       .hready_resp (i_apb_hready_resp),
       .hwdata      (i_ahb_hwdata),
       .hrdata      (i_apb_hrdata),
       .pclk_en     (i_apb_pclk_en),
       .paddr       (i_apb_paddr),
       .penable     (i_apb_penable),
       .pwrite      (i_apb_pwrite),
       .pwdata      (i_apb_pwdata),
       .psel_s3     (i_apb_psel_s3),
       .psel_s2     (i_apb_psel_s2),
       .psel_s1     (i_apb_psel_s1),
       .psel_s0     (i_apb_psel_s0),
       .prdata_s3   (uart_B_prdata),
       .prdata_s2   (uart_A_prdata),
       .prdata_s1   (i_gpio_prdata),
       .prdata_s0   (i_timers_prdata));

   i_gpio_DW_apb_gpio i_gpio
      (.pclk            (pclk),
       .pclk_intr       (i_gpio_pclk_intr),
       .presetn         (presetn),
       .penable         (i_apb_penable),
       .pwrite          (i_apb_pwrite),
       .pwdata          (i_apb_pwdata),
       .paddr           (i_apb_paddr[6:0]),
       .psel            (i_apb_psel_s1),
       .dbclk           (i_gpio_dbclk),
       .dbclk_res_n     (i_gpio_dbclk_res_n),
       .scan_mode       (i_gpio_scan_mode),
       .gpio_ext_porta  (DW_apb_gpio_API_gpio_ext_porta),
       .gpio_porta_dr   (DW_apb_gpio_API_gpio_porta_dr),
       .gpio_porta_ddr  (DW_apb_gpio_API_gpio_porta_ddr),
       .gpio_intr_flag  (i_gpio_gpio_intr_flag),
       .gpio_intrclk_en (i_gpio_gpio_intrclk_en),
       .prdata          (i_gpio_prdata));

   i_timers_DW_apb_timers i_timers
      (.pclk           (pclk),
       .presetn        (presetn),
       .penable        (i_apb_penable),
       .psel           (i_apb_psel_s0),
       .pwrite         (i_apb_pwrite),
       .paddr          (i_apb_paddr[7:0]),
       .pwdata         (i_apb_pwdata),
       .scan_mode      (i_timers_scan_mode),
       .timer_1_clk    (i_timers_timer_1_clk),
       .timer_2_clk    (i_timers_timer_2_clk),
       .timer_1_resetn (i_timers_timer_1_resetn),
       .timer_2_resetn (i_timers_timer_2_resetn),
       .timer_en       (i_timers_timer_en),
       .timer_intr     (i_timers_timer_intr),
       .prdata         (i_timers_prdata));

   uart_A_DW_apb_uart uart_A
      (.pclk         (pclk),
       .presetn      (presetn),
       .penable      (i_apb_penable),
       .pwrite       (i_apb_pwrite),
       .pwdata       (i_apb_pwdata),
       .paddr        (i_apb_paddr[7:0]),
       .psel         (i_apb_psel_s2),
       .scan_mode    (uart_A_scan_mode),
       .cts_n        (SIO_cts_n),
       .dsr_n        (uart_A_dsr_n),
       .dcd_n        (uart_A_dcd_n),
       .ri_n         (uart_A_ri_n),
       .sin          (SIO_sin),
       .prdata       (uart_A_prdata),
       .dtr_n        (uart_A_dtr_n),
       .rts_n        (SIO_rts_n),
       .out2_n       (uart_A_out2_n),
       .out1_n       (uart_A_out1_n),
       .dma_tx_req_n (uart_A_dma_tx_req_n),
       .dma_rx_req_n (uart_A_dma_rx_req_n),
       .txrdy_n      (uart_A_txrdy_n),
       .rxrdy_n      (uart_A_rxrdy_n),
       .sout         (SIO_sout),
       .baudout_n    (uart_A_baudout_n),
       .intr         (uart_A_intr));

   uart_B_DW_apb_uart uart_B
      (.pclk         (pclk),
       .presetn      (presetn),
       .penable      (i_apb_penable),
       .pwrite       (i_apb_pwrite),
       .pwdata       (i_apb_pwdata),
       .paddr        (i_apb_paddr[7:0]),
       .psel         (i_apb_psel_s3),
       .scan_mode    (uart_B_scan_mode),
       .cts_n        (uart_B_SIO_cts_n),
       .dsr_n        (uart_B_dsr_n),
       .dcd_n        (uart_B_dcd_n),
       .ri_n         (uart_B_ri_n),
       .sin          (uart_B_SIO_sin),
       .prdata       (uart_B_prdata),
       .dtr_n        (uart_B_dtr_n),
       .rts_n        (uart_B_SIO_rts_n),
       .out2_n       (uart_B_out2_n),
       .out1_n       (uart_B_out1_n),
       .dma_tx_req_n (uart_B_dma_tx_req_n),
       .dma_rx_req_n (uart_B_dma_rx_req_n),
       .txrdy_n      (uart_B_txrdy_n),
       .rxrdy_n      (uart_B_rxrdy_n),
       .sout         (uart_B_SIO_sout),
       .baudout_n    (uart_B_baudout_n),
       .intr         (uart_B_intr));

   assign ex_i_ahb_AHB_Master_hready = i_ahb_hready;
   assign i_ahb_AHB_ZBT_SRAM_haddr = i_ahb_haddr;
   assign i_ahb_AHB_ZBT_SRAM_hburst = i_ahb_hburst;
   assign i_ahb_AHB_ZBT_SRAM_hready = i_ahb_hready;
   assign i_ahb_AHB_ZBT_SRAM_hsize = i_ahb_hsize;
   assign i_ahb_AHB_ZBT_SRAM_htrans = i_ahb_htrans;
   assign i_ahb_AHB_ZBT_SRAM_hwdata = i_ahb_hwdata;
   assign i_ahb_AHB_ZBT_SRAM_hwrite = i_ahb_hwrite;

   // Note: i_apb_paddr[31:8] is open

endmodule
