// Initial stab at a toplevel connection
`include "SoC_inc.v"

`timescale 1ns/100ps

// TODO
// clean up names

module SoC (
    clk,
    resetn,
    db_resetn,
    test_enable,
    db_rxd,
    db_txd,
    UARTA_rx,
    UARTA_tx,
    UARTA_baudoutn,
    UARTB_rx,
    UARTB_tx,
    UARTB_baudoutn,
    gpio_ext_porta,
    gpio_porta_ddr,
    gpio_porta_dr
  );

    //SoC Signals
    input		clk;
    input		resetn;
    input  		db_resetn;
    input  		test_enable;

    //Debugger
    input 		db_rxd;
    output 		db_txd;
    
    //UARTA
    input UARTA_rx;
    output UARTA_tx;
    output UARTA_baudoutn;

    //UARTB
    input UARTB_rx;
    output UARTB_tx;
    output UARTB_baudoutn;

    //GPIO
    input	[7:0]	gpio_ext_porta;
    output	[7:0]	gpio_porta_ddr;
    output	[7:0]	gpio_porta_dr;

    //SoC Signals
    wire		clk;
    wire		resetn;
    wire  		db_resetn;
    wire  		test_enable;
    wire  		sync_resetn;
    
    wire	[7:0]	gpio_ext_porta;
    wire	[7:0]	gpio_porta_ddr;
    wire	[7:0]	gpio_porta_dr;

    wire		UARTA_rx;
    wire		UARTA_tx;
    wire		UARTA_baudoutn;
    
    wire		UARTB_rx;
    wire		UARTB_tx;
    wire		UARTB_baudoutn;

    wire        [1:0]   gated_timer_clk;
    wire        [1:0]   timer_clk_en;
    wire                gpio_clk_en;
    wire                gated_gpio_clk;
    
    //Core to AHB Master Socket
    wire [31:0] AHB_Core_haddr;
    wire [2:0]  AHB_Core_hburst;
    wire [3:0]  AHB_Core_hprot;
    wire [2:0]  AHB_Core_hsize;
    wire [1:0]  AHB_Core_htrans;
    wire [31:0] AHB_Core_hwdata;
    wire [31:0] AHB_Core_hrdata;
    wire [1:0]  AHB_Core_hresp;
    wire        AHB_Core_hready;
    wire        AHB_Core_hlock;
    wire        AHB_Core_hwrite;

    //AHB Slave Socket to AHB ZBT SRAM CTL
    wire [31:0] AHB_ZBT_SRAM_haddr;
    wire [1:0]  AHB_ZBT_SRAM_htrans;
    wire [2:0]  AHB_ZBT_SRAM_hsize;
    wire 	AHB_ZBT_SRAM_hwrite;
    wire [31:0] AHB_ZBT_SRAM_hwdata;
    wire        AHB_ZBT_SRAM_hsel;
    wire        AHB_ZBT_SRAM_hready;
    wire [31:0] AHB_ZBT_SRAM_hrdata;
    wire        AHB_ZBT_SRAM_hreadyout;
    wire  [1:0] AHB_ZBT_SRAM_hresp;
    
    //AHB ZBT SRAM CTL to SRAM block
    wire [(`SRAM_ADDR_WIDTH-1):2] ramaddr;
    wire [31:0] ramwdata;
    wire [31:0] ramrdata;
    wire        ramdataen;
    wire        ramclk;
    wire [3:0]  ramwebyte_n;
    wire        ramoe_n;
    wire [3:0]  ramce_n;

    //Peripheral IRQs to core
    wire	uart_A_irq;
    wire	uart_B_irq;
    wire [1:0]	timers_irq;
    wire	timer_irq;
    wire	gpio_irq;

//    parameter 	stcalib = $realtobits(0.01*33.0*1000000);
    parameter 	stcalib = 330000;

reset_async_sync reset_sync (
  .clk(clk),
  .resetn(resetn),
  .scan_bypass(test_enable),
  .sync_resetn(sync_resetn)
  );

MINISWIFT core (
  .HCLK(clk),
  .HRESETn(sync_resetn),
  .HADDR(AHB_Core_haddr),
  .HBURST(AHB_Core_hburst),
  .HMASTLOCK(),
  .HPROT(AHB_Core_hprot),
  .HSIZE(AHB_Core_hsize),
  .HTRANS(AHB_Core_htrans),
  .HWDATA(AHB_Core_hwdata),
  .HWRITE(AHB_Core_hwrite),
  .HRDATA(AHB_Core_hrdata),
  .HREADY(AHB_Core_hready),
  .HRESP(AHB_Core_hresp[0]),
  //.HMASTER(AHB_Core_hmaster),
  .NMI(1'b0),
  .IRQ({timer_irq, gpio_irq, uart_A_irq, uart_B_irq}),
  .TXEV(),
  .RXEV(1'b0),
  .LOCKUP(),
  .SYSRESETREQ(),
  .STCALIB({2'b10, stcalib[23:0]}),   //00000101_00001001_00010000}), //See doc. Currently set for 33Mhz
  .STCLKEN(1'b0),
  .SLEEPING(),
  .SLEEPDEEP(),
  .SLEEPHOLDREQn(1'b0),
  .SLEEPHOLDACKn()
);

//assign gated_timer_clk[0] = (timer_clk_en[0] | test_enable ) ? clk : 1'b0;
//assign gated_timer_clk[1] = (timer_clk_en[1] | test_enable ) ? clk : 1'b0;
assign gated_timer_clk[0] = clk;
assign gated_timer_clk[1] = clk;
//assign timer_irq = timers_irq[1] | timers_irq[0];
//assign gated_gpio_clk = (gpio_clk_en | test_enable ) ? clk : 1'b0;
assign gated_gpio_clk = clk;

AMBA_Chain bus_and_periph (
  .hclk(clk),
  .hresetn(sync_resetn),
  .pclk(clk),
  .presetn(sync_resetn),
  .DW_apb_gpio_API_gpio_ext_porta(gpio_ext_porta),
  .DW_apb_gpio_API_gpio_porta_ddr(gpio_porta_ddr),
  .DW_apb_gpio_API_gpio_porta_dr(gpio_porta_dr),
  .i_gpio_gpio_intr_flag(gpio_irq),
  .i_gpio_gpio_intrclk_en(gpio_clk_en),
  .i_gpio_dbclk(gated_gpio_clk),
  .i_gpio_dbclk_res_n(sync_resetn),
  .i_gpio_pclk_intr(gated_gpio_clk),
  .i_gpio_scan_mode(test_enable), 
  .ex_i_ahb_AHB_Master_haddr(AHB_Core_haddr),
  .ex_i_ahb_AHB_Master_hburst(AHB_Core_hburst),
  .ex_i_ahb_AHB_Master_hprot(AHB_Core_hprot),
  .ex_i_ahb_AHB_Master_hsize(AHB_Core_hsize),
  .ex_i_ahb_AHB_Master_htrans(AHB_Core_htrans),
  .ex_i_ahb_AHB_Master_hwdata(AHB_Core_hwdata),
  .ex_i_ahb_AHB_Master_hrdata(AHB_Core_hrdata),
  .ex_i_ahb_AHB_Master_hresp(AHB_Core_hresp),
  .ex_i_ahb_AHB_Master_hlock(AHB_Core_hlock),
  .ex_i_ahb_AHB_Master_hwrite(AHB_Core_hwrite),
  .ex_i_ahb_AHB_Master_hready(AHB_Core_hready),
  .i_ahb_AHB_ZBT_SRAM_hrdata(AHB_ZBT_SRAM_hrdata),
//  .i_ahb_AHB_ZBT_SRAM_hrdata(32'b0),
  .i_ahb_AHB_ZBT_SRAM_hresp(AHB_ZBT_SRAM_hresp),
  .i_ahb_AHB_ZBT_SRAM_haddr(AHB_ZBT_SRAM_haddr),
  .i_ahb_AHB_ZBT_SRAM_hburst(),
  .i_ahb_AHB_ZBT_SRAM_hprot(),
  .i_ahb_AHB_ZBT_SRAM_hsize(AHB_ZBT_SRAM_hsize),
  .i_ahb_AHB_ZBT_SRAM_htrans(AHB_ZBT_SRAM_htrans),
  .i_ahb_AHB_ZBT_SRAM_hwdata(AHB_ZBT_SRAM_hwdata),
  .i_ahb_AHB_ZBT_SRAM_hready_resp(AHB_ZBT_SRAM_hreadyout),
  .i_ahb_AHB_ZBT_SRAM_hmastlock(),
  .i_ahb_AHB_ZBT_SRAM_hready(AHB_ZBT_SRAM_hready),
  .i_ahb_AHB_ZBT_SRAM_hsel(AHB_ZBT_SRAM_hsel),
  .i_ahb_AHB_ZBT_SRAM_hwrite(AHB_ZBT_SRAM_hwrite),
  .i_apb_pclk_en(1'b1),
  .i_ahb_hmaster_data(), 
  .i_timers_timer_en(timer_clk_en),
  .i_timers_timer_intr(timers_irq),
  .i_timers_scan_mode(test_enable),
  .i_timers_timer_1_clk(gated_timer_clk[0]),
  .i_timers_timer_1_resetn(resetn),
  .i_timers_timer_2_clk(gated_timer_clk[1]),
  .i_timers_timer_2_resetn(resetn),
  .uart_A_dcd_n(1'b1),
  .uart_A_dsr_n(1'b1),
  .uart_A_ri_n(1'b1),
  .uart_A_scan_mode(test_enable),
  .uart_A_baudout_n(UARTA_baudoutn),
  .uart_A_dma_rx_req_n(),
  .uart_A_dma_tx_req_n(),
  .uart_A_dtr_n(),
  .uart_A_intr(uart_A_irq),
  .uart_A_out1_n(),
  .uart_A_out2_n(),
  .uart_A_rxrdy_n(),
  .uart_A_txrdy_n(),
  .SIO_cts_n(1'b1),
  .SIO_sin(UARTA_rx),
  .SIO_rts_n(),
  .SIO_sout(UARTA_tx),
  .uart_B_baudout_n(UARTB_baudoutn),
  .uart_B_dma_rx_req_n(),
  .uart_B_dma_tx_req_n(),
  .uart_B_dtr_n(),
  .uart_B_intr(uart_B_irq),
  .uart_B_out1_n(),
  .uart_B_out2_n(),
  .uart_B_rxrdy_n(),
  .uart_B_dcd_n(1'b1),
  .uart_B_dsr_n(1'b1),
  .uart_B_ri_n(1'b1),
  .uart_B_scan_mode(test_enable),
  .uart_B_SIO_cts_n(1'b1),
  .uart_B_SIO_sin(UARTB_rx),
  .uart_B_SIO_rts_n(),
  .uart_B_SIO_sout(UARTB_tx),
  .uart_B_txrdy_n()
);

AHB_ram32  
  #(
  .SRAM_ADDR_WIDTH(`SRAM_ADDR_WIDTH)
  )
  memory_ctrl
  (
//  .cfgbigend(1'b0),
//  .dmaread(1'b0),
  .hclk(clk),
  .hresetn(sync_resetn),
  .haddr(AHB_ZBT_SRAM_haddr),
  .htrans(AHB_ZBT_SRAM_htrans),
  .hsize(AHB_ZBT_SRAM_hsize[1:0]),
  .hwrite(AHB_ZBT_SRAM_hwrite),
  .hwdata(AHB_ZBT_SRAM_hwdata),
  .hsel(AHB_ZBT_SRAM_hsel),
  .hready(AHB_ZBT_SRAM_hready),
  .hrdata(AHB_ZBT_SRAM_hrdata),
  .hreadyout(AHB_ZBT_SRAM_hreadyout),
  .hresp(AHB_ZBT_SRAM_hresp),
// SSRAM interface
  .ramaddr(ramaddr[(`SRAM_ADDR_WIDTH-1):2]),
  .ramwdata(ramwdata),
  .ramrdata(ramrdata),
  .ramdataen(ramdataen),
  .ramclk(ramclk),
  .ramwebyte_n(ramwebyte_n),
  .ramoe_n(ramoe_n),
  .ramce_n(ramce_n[0])
);


wire [55:0] db_rd_bits;
wire [55:0] db_wr_bits;
wire db_rxd;
wire db_txd;

DW_debugger_inst debugger (
  .clk(clk),
  .resetn(db_resetn),
  .rd_bits(db_rd_bits),
  .wr_bits(db_wr_bits),
  .rxd(db_rxd),
  .txd(db_txd),
  .div_bypass(test_enable)
  );

debug_SRAM_wrapper 
  #(
  .ADDR_WIDTH(`SRAM_ADDR_WIDTH)
  ) SRAM_wrap (
  .clk(ramclk),
  .en(~{4{ramce_n[0]}}),
  .resetn(db_resetn),
  .webyte(~ramwebyte_n),
  .ramaddr(ramaddr[(`SRAM_ADDR_WIDTH-1):2]),
  .ramwdata(ramwdata),
  .ramrdata(ramrdata),
  .access_bits_in(db_wr_bits),
  .access_bits_out(db_rd_bits)
  );
  
endmodule



