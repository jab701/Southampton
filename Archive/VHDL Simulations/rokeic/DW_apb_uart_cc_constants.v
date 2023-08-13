// ------------------------------------------------------------------------
// 
//                   (C) COPYRIGHT 2003-2008 SYNOPSYS INC.
//                             ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this software
//  is subject to the terms and conditions of a written license agreement
//  between you, or your company, and Synopsys, Inc.
// 
//  The entire notice above must be reproduced on all authorized copies.
// 
//  File :                       DW_apb_uart_cc_constants.v
//  Author:                      LehKui Ong & Marc Wall
//  Date :                       $Date: 2008/10/16 $
//  Version      :               $Revision: #111 $
//  Abstract     :               parameter file for the UART.
// 
//  =====================================================================



// Description:  APB_DATA_WIDTH: 
//               Width of APB data bus to which this component is attached. Note that 
//               even though the data width can be set to 8, 16 or 32, only the lowest 8 
//               data bits are ever used, since register access is on 32-bit boundaries. 
//               All other bits are held at static 0.
// DefaultValue: 32
// EnumValues:   8 16 32
`define APB_DATA_WIDTH 32


// Description:  Maximum allowed APB Data bus width.
// DefaultValue: 32
// MinValue:     -2147483648
// MaxValue:     2147483647
`define MAX_APB_DATA_WIDTH 32


// Description:  FIFO_MODE: 
//               Receiver and Transmitter FIFO depth in bytes. A setting of NONE means 
//               no FIFOs, which implies the 16450-compatible mode of operation. Most 
//               enhanced features are unavailable in the 16450 mode such as the Auto 
//               Flow Control and Programmable THRE interrupt modes. Setting a FIFO 
//               depth greater than 256 restricts the FIFO Memory to External only. For 
//               more details, refer to the "FIFO Support" section of the functional 
//               specification.
// DefaultValue: 16
// EnumValues:   0 16 32 64 128 256 512 1024 2048
// ValueRange:   NONE 16 32 64 128 256 512 1024 2048
`define FIFO_MODE 0


// Description:  MEM_SELECT_USER: 
//               Selects between external, user-supplied memory or internal DesignWare 
//               memory (DW_ram_r_w_s_dff) for the receiver and transmitter FIFOs. FIFO 
//               depths greater than 256 restrict FIFO Memory selection to external. In 
//               addition, selection of internal memory restricts the Memory Read Port 
//               Type to Dflip-flop-based, synchronous read port RAMs.
// DefaultValue: External
// EnumValues:   0 1
// ValueRange:   External Internal
`define MEM_SELECT_USER 0


`define MEM_SELECT 0



// Description:  MEM_MODE_USER: 
//               This non-changeable parameter has been retained in this release of the 
//               DW_apb_uart for backward compatibility with pre-3.00a versions of this 
//               component.
// DefaultValue: 0
// MinValue:     -2147483648
// MaxValue:     2147483647
`define MEM_MODE_USER 0


`define MEM_MODE 0


// Description:  SIR_LP_MODE: 
//               Configures the peripheral to operate in a low-power IrDA SIR mode. As 
//               the DW_apb_uart does not support a low-power mode with a counter system 
//               to maintain a 1.63us infrared pulse, Asynchronous Serial Clock Support 
//               will be automatically enabled, and the sclk must be fixed to 1.8432Mhz. 
//               This provides a 1.63us sir_out_n pulse at 115.2kbaud.
// DefaultValue: Disabled
// EnumValues:   0 1
// ValueRange:   Disabled Enabled
`define SIR_LP_MODE 0


// Description:  SIR_LP_RX: 
//               Configures the peripheral to to have SiR low power pulse reception 
//               capabalities. Two additional Low power Divisor Registers are implemented 
//               and must be written with a divisor that will give a baud rate of 115.2k 
//               for the low power pulse detection functionality to operate correctly.
// DefaultValue: Disabled
// EnumValues:   0 1
// ValueRange:   Disabled Enabled
`define SIR_LP_RX 0


// Description:  CLOCK_MODE: 
//               When set to Disabled, the DW_apb_uart is implemented with one system 
//               clock (pclk). When set to Enabled, two system clocks (pclk and sclk) 
//               are implemented in order to accommodate accurate serial baud rate 
//               settings, as well as APB bus interface requirements. Selecting Disabled, 
//               or a one-system clock, greatly restricts system clock settings 
//               available for accurate baud rates. For more details, refer to "Clock 
//               Support" section of the data book.
// DefaultValue: Disabled
// EnumValues:   1 2
// ValueRange:   Disabled Enabled
`define CLOCK_MODE 1



// Description:  AFCE_MODE_USER: 
//               Configures the peripheral to have the 16750-compatible auto flow control 
//               mode. For more details, refer to "Auto Flow Control" section of the 
//               data book.
// DefaultValue: Disabled
// EnumValues:   0 1
// ValueRange:   Disabled Enabled
`define AFCE_MODE_USER 0


`define AFCE_MODE 0


// Description:  THRE_MODE_USER: 
//               Configures the peripheral to have a programmable Transmitter Hold 
//               Register Empty (THRE) interrupt mode. For more information, refer to 
//               "Programmable THRE Interrupt" section of the data book.
// DefaultValue: Disabled
// EnumValues:   0 1
// ValueRange:   Disabled Enabled
`define THRE_MODE_USER 0


`define THRE_MODE 0


// Description:  SIR_MODE: 
//               Configures the peripheral to have IrDA 1.0 SIR mode. For more details, 
//               refer to the "IrDA 1.0 SIR Protocol" in the data book.
// DefaultValue: Disabled
// EnumValues:   0 1
// ValueRange:   Disabled Enabled
`define SIR_MODE 0



// Description:  CLK_GATE_EN: 
//               Configures the peripheral to have a clock gate enable output signal on 
//               the interface that indicates that the device is inactive, so clocks 
//               may be gated.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define CLK_GATE_EN 0




// Description:  FIFO_ACCESS: 
//               Configures the peripheral to have a programmable FIFO access mode. 
//               This is used for test purposes, to allow the receiver FIFO to be 
//               written and the transmit FIFO to be read when FIFO's are implemented 
//               and enabled. When FIFO's are not implemented or not enabled it allows 
//               the RBR to be written and the THR to be read. For more details, refer 
//               to "FIFO Support" section in the data book.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define FIFO_ACCESS 0


// Description:  DMA_EXTRA: 
//               Configures the peripheral to have four additional DMA signals on the 
//               interface so that the device is compatible with the DesignWare DMA 
//               controller interface requirements.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define DMA_EXTRA 0


// Description:  DMA_POL: 
//               Selects the polarity of the DMA interface signals.
// DefaultValue: true
// EnumValues:   0 1
// ValueRange:   false true
`define DMA_POL 1


// Description:  DEBUG: 
//               Configures the peripheral to have on-chip debug pins on the interface.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define DEBUG 0


// Description:  BAUD_CLK: 
//               Configures the peripheral to have a baud clock reference output 
//               (baudout_n) pin on the interface.
// DefaultValue: true
// EnumValues:   0 1
// ValueRange:   false true
`define BAUD_CLK 1


// Description:  ADDITIONAL_FEATURES: 
//               Configures the peripheral to have both the FIFO status registers and 
//               the shadow registers available.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define ADDITIONAL_FEATURES 0


// Description:  FIFO_STAT: 
//               Configures the peripheral to have three additional FIFO status registers.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define FIFO_STAT 0


// Description:  SHADOW: 
//               Configures the peripheral to have seven additional registers that 
//               shadow some of the existing register bits that are regularly modified 
//               by software. These can be used to reduce the software overhead that is 
//               introduced by having to perform read-modify writes.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define SHADOW 0


// Description:  UART_ADD_ENCODED_PARAMS: 
//               Configures the peripheral to have a configuration identification register.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define UART_ADD_ENCODED_PARAMS 0


// Description:  UART_16550_COMPATIBLE: 
//               Configures the peripheral to be fully 16550 compatible. This is achieved 
//               by not having the busy functionality implemented.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define UART_16550_COMPATIBLE 1


// Description:  LATCH_MODE_USER: 
//               This is a non-changeable parameter that is only included for software- 
//               backwards compatibility. That is so that no errors will arise when the 
//               peripheral is used with existing software.
// DefaultValue: 0
// MinValue:     -2147483648
// MaxValue:     2147483647
`define LATCH_MODE_USER 0


`define LATCH_MODE 0


// Description:  PCLK_PER: 
//               This non-changeable parameter has been retained in this release of the 
//               DW_apb_uart for backward compatibility with pre-3.00a versions of this 
//               component.
// DefaultValue: 30
// MinValue:     -2147483648
// MaxValue:     2147483647
`define PCLK_PER 30


// Description:  SCLK_PER: 
//               This non-changeable parameter has been retained in this release of the 
//               DW_apb_uart for backward compatibility with pre-3.00a versions of this 
//               component.
// DefaultValue: 40
// MinValue:     -2147483648
// MaxValue:     2147483647
`define SCLK_PER 40


// Description:  FIFO_ADDR_WIDTH: 
//               Size of the FIFO address bus. Calculated by log2(FIFO depth).
// DefaultValue: 1
// MinValue:     -2147483648
// MaxValue:     2147483647
`define FIFO_ADDR_WIDTH 1


// Description:  TO_DET_CNT_ENS_WIDTH: 
//               Timeout detect counter enables width, that is the number of signals 
//               required for counter enable purposes in the timeout detection block. 
//               If clock gate enable signal(s) have been configured 8 signals are 
//               required else 3 signals are required.
// DefaultValue: 3
// MinValue:     -2147483648
// MaxValue:     2147483647
`define TO_DET_CNT_ENS_WIDTH 3


`define UART_ADDR_SLICE_LHS 8


// Description:  UART_COMP_VERSION: 
//               Each corekit has a component version. 
//               This is reflected in the ASCII version number which needs to get translated. 
//                
//                0 => 48 -> 30 
//                1 => 49 -> 31 
//                2 => 50 -> 32 
//                A => 65 -> 41 
//                B => 66 -> 42 
//                C => 67 -> 43 
//                
//               Current Version is 3.06* => 33_30_36_2A (ASCII values for 3.06*)
// DefaultValue: 0x3330382a
// MinValue:     0x0
// MaxValue:     0xffffffff
`define UART_COMP_VERSION 32'h3330382a


// Description:  UART_COMP_TYPE: 
//               Software Component Type. 
//               The first 16 bits represents "DW" in ASCII
// DefaultValue: 0x44570110
// MinValue:     0x0
// MaxValue:     0xffffffff
`define UART_COMP_TYPE 32'h44570110


// Description:  UART_ENCODED_FIFO_MODE: 
//               Encoded value of FIFO_MODE parameter for Configuration ID
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     =sHdl::MaxValFromWidth
`define UART_ENCODED_FIFO_MODE 8'h0


// Description:  UART_ENCODED_APB_WIDTH: 
//               Encoded value of APB_DATA_WIDTH parameter for Configuration ID
// DefaultValue: 0x2
// MinValue:     0x0
// MaxValue:     =sHdl::MaxValFromWidth
`define UART_ENCODED_APB_WIDTH 2'h2


// Description:  UART_COMP_PARAM_RST: 
//               Component Parameter Register Reset Value.
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     0xffffffff
`define UART_COMP_PARAM_RST 32'h0


// Description:  UART_SIM_REPORT_DEBUG: 
//               Controls the amount of information being displayed
// DefaultValue: No
// EnumValues:   0 1
// ValueRange:   No Yes
`define UART_SIM_REPORT_DEBUG 0


// Description:  UART_SIM_TERMINATE_ON_CHECKER_FAILURE: 
//               Controls if simulations will terminate on a checker failure.
// DefaultValue: Yes
// EnumValues:   0 1
// ValueRange:   No Yes
`define UART_SIM_TERMINATE_ON_CHECKER_FAILURE 1


// Description:  UART_SIM_SHORT_CHARACTER_STREAM_LENGTH: 
//               Controls the max number of character exchanged during transmit/receive.
// DefaultValue: 1
// MinValue:     0
// MaxValue:     1
`define UART_SIM_SHORT_CHARACTER_STREAM_LENGTH 1


// Description:  UART_SIM_FUNCTIONAL_COVERAGE: 
//               Controls functional coverage,coverage_group_collect in Vera.
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_FUNCTIONAL_COVERAGE 0


// Description:  UART_SIM_RANDOM_SEED: 
//               Controls seed for srandom() in UartTestLib.vr
// DefaultValue: 1
// MinValue:     1
// MaxValue:     9999
`define UART_SIM_RANDOM_SEED 1


// Description:  UART_SIM_TERMINATE_ON_SIOMON_ERROR: 
//               Determines if simulations terminate when the SIOMonitor detects an error
// DefaultValue: 1
// MinValue:     0
// MaxValue:     1
`define UART_SIM_TERMINATE_ON_SIOMON_ERROR 1


// Description:  UART_SIM_SCLK_PCLK_RELATIONSHIP: 
//               Control SCLK : PCLK Relationship
// DefaultValue: Identical
// EnumValues:   0 1 2
// ValueRange:   Identical Faster Slower
`define UART_SIM_SCLK_PCLK_RELATIONSHIP 0


// Description:  UART_SIM_SCLK_PERIOD: 
//               Control SCLK period
// DefaultValue: 13
// MinValue:     1
// MaxValue:     200
`define UART_SIM_SCLK_PERIOD 13


// Description:  UART_SIM_DO_SPECIAL_CONDITION: 
//               Control switch to enable/disable special condition testing
// DefaultValue: 1
// MinValue:     0
// MaxValue:     1
`define UART_SIM_DO_SPECIAL_CONDITION 1


// Description:  UART_SIM_SIOMON_ACTIVE_ON_SIN: 
//               Control switch to enable/disable special condition testing
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_SIOMON_ACTIVE_ON_SIN 0


// Description:  UART_SIM_MAX_ITERATION_VAL: 
//               Override parameter: determines the MAXIMUM number of iterations performed for verification
// DefaultValue: 2
// MinValue:     1
// MaxValue:     999
`define UART_SIM_MAX_ITERATION_VAL 2


// Description:  UART_SIM_OVERRIDE: 
//               Override control switch; if enabled, all other Override parameters make sense.
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE 0


// Description:  UART_SIM_OVERRIDE_TRANSFER_DIRECTION_VAL: 
//               Override parameter: determines the TRANSFER_DIRECTION
// DefaultValue: TRANSMIT_TEST
// EnumValues:   0 1 2 3
// ValueRange:   TRANSMIT_TEST RECEIVE_TEST LOOPBACK_TEST EXTRA_TEST
`define UART_SIM_OVERRIDE_TRANSFER_DIRECTION_VAL 0


// Description:  UART_SIM_OVERRIDE_MAX_ITERATION_VAL: 
//               Override parameter: determines the MAXIMUM number of iterations performed for verification
// DefaultValue: 2
// MinValue:     1
// MaxValue:     999
`define UART_SIM_OVERRIDE_MAX_ITERATION_VAL 2


// Description:  UART_SIM_OVERRIDE_MAX_ROUND_VAL: 
//               Override parameter: determines the MAXIMUM number of rounds for each iteration
// DefaultValue: 2
// MinValue:     2
// MaxValue:     20
`define UART_SIM_OVERRIDE_MAX_ROUND_VAL 2


// Description:  UART_SIM_OVERRIDE_IER: 
//               Override parameter: determines if the UART IER parameters are overriden
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_IER 0


// Description:  UART_SIM_OVERRIDE_IER_PTIME_VAL: 
//               Override parameter: determines the override-value for IER's PTIME
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_IER_PTIME_VAL 0


// Description:  UART_SIM_OVERRIDE_IER_EDSSI_VAL: 
//               Override parameter: determines the override-value for IER's EDSSI
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_IER_EDSSI_VAL 0


// Description:  UART_SIM_OVERRIDE_IER_ELSI_VAL: 
//               Override parameter: determines the override-value for IER's ELSI
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_IER_ELSI_VAL 0


// Description:  UART_SIM_OVERRIDE_IER_ETBEI_VAL: 
//               Override parameter: determines the override-value for IER's ETBEI
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_IER_ETBEI_VAL 0


// Description:  UART_SIM_OVERRIDE_IER_ERBFI_VAL: 
//               Override parameter: determines the override-value for IER's ERBFI
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_IER_ERBFI_VAL 0


// Description:  UART_SIM_OVERRIDE_FCR: 
//               Override parameter: determines if the UART FCR parameters are overriden
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_FCR 0


// Description:  UART_SIM_OVERRIDE_FCR_FIFO_EN_VAL: 
//               Override parameter: determines the override-value for FCR's FIFO_EN
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_FCR_FIFO_EN_VAL 0


// Description:  UART_SIM_OVERRIDE_FCR_DMAM_VAL: 
//               Override parameter: determines the override-value for FCR's DMA MODE
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_FCR_DMAM_VAL 0


// Description:  UART_SIM_OVERRIDE_FCR_RT_VAL: 
//               Override parameter: determines the override-value for FCR's RCVR TRIGGER
// DefaultValue: 0
// MinValue:     0
// MaxValue:     3
`define UART_SIM_OVERRIDE_FCR_RT_VAL 0


// Description:  UART_SIM_OVERRIDE_FCR_TET_VAL: 
//               Override parameter: determines the override-value for FCR's TXEMPTY TRIGGER
// DefaultValue: 0
// MinValue:     0
// MaxValue:     3
`define UART_SIM_OVERRIDE_FCR_TET_VAL 0


// Description:  UART_SIM_OVERRIDE_LCR: 
//               Override parameter: determines if the UART LCR parameters are overriden
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_LCR 0


// Description:  UART_SIM_OVERRIDE_LCR_EPS_VAL: 
//               Override parameter: determines the override-value for LCR's EPS
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_LCR_EPS_VAL 0


// Description:  UART_SIM_OVERRIDE_LCR_PEN_VAL: 
//               Override parameter: determines the override-value for LCR's PEN
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_LCR_PEN_VAL 0


// Description:  UART_SIM_OVERRIDE_LCR_STOP_VAL: 
//               Override parameter: determines the override-value for LCR's STOP
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_LCR_STOP_VAL 0


// Description:  UART_SIM_OVERRIDE_LCR_DLS_VAL: 
//               Override parameter: determines the override-value for LCR's DLS
// DefaultValue: 0
// MinValue:     0
// MaxValue:     3
`define UART_SIM_OVERRIDE_LCR_DLS_VAL 0


// Description:  UART_SIM_OVERRIDE_LCR_BREAK_VAL: 
//               Override parameter: determines the override-value for LCR's BREAK
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_LCR_BREAK_VAL 0


// Description:  UART_SIM_OVERRIDE_DLL_DLH: 
//               Override parameter: determines if the UART DLL,DLH parameters are overriden
// DefaultValue: 0
// MinValue:     0
// MaxValue:     255
`define UART_SIM_OVERRIDE_DLL_DLH 0


// Description:  UART_SIM_OVERRIDE_DLL_VAL: 
//               Override parameter: determines the override-value for DLL's value
// DefaultValue: 1
// MinValue:     0
// MaxValue:     255
`define UART_SIM_OVERRIDE_DLL_VAL 1


// Description:  UART_SIM_OVERRIDE_DLH_VAL: 
//               Override parameter: determines the override-value for DLH's value
// DefaultValue: 0
// MinValue:     0
// MaxValue:     255
`define UART_SIM_OVERRIDE_DLH_VAL 0


// Description:  UART_SIM_OVERRIDE_MCR: 
//               Override parameter: determines if the UART MCR parameters are overriden
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_MCR 0


// Description:  UART_SIM_OVERRIDE_MCR_SIRE_VAL: 
//               Override parameter: determines the override-value for MCR's SIRE
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_MCR_SIRE_VAL 0


// Description:  UART_SIM_OVERRIDE_MCR_AFCE_VAL: 
//               Override parameter: determines the override-value for MCR's AFCE
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_MCR_AFCE_VAL 0


// Description:  UART_SIM_OVERRIDE_MCR_LOOPBACK_VAL: 
//               Override parameter: determines the override-value for MCR's LOOPBACK
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_MCR_LOOPBACK_VAL 0


// Description:  UART_SIM_OVERRIDE_RX_ERROR: 
//               Override parameter: determines if Rx errors are to be sent to the UART/DUT
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_RX_ERROR 0


// Description:  UART_SIM_OVERRIDE_RX_PARITY_ERROR: 
//               Override parameter: determines if PARITY errors are to be sent to the UART/DUT
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_RX_PARITY_ERROR 0


// Description:  UART_SIM_OVERRIDE_RX_FRAMING_ERROR: 
//               Override parameter: determines if FRAMING errors are to be sent to the UART/DUT
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_RX_FRAMING_ERROR 0


// Description:  UART_SIM_OVERRIDE_RX_BREAK_CHAR: 
//               Override parameter: determines if BREAK characters are to be sent to the UART/DUT
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_RX_BREAK_CHAR 0


// Description:  UART_SIM_OVERRIDE_SIOTXRX_DRIVE_DCD_DSR_RI: 
//               Override parameter: determines if the DCD/DSR/RI inputs are driven by SIOTxrx
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_SIM_OVERRIDE_SIOTXRX_DRIVE_DCD_DSR_RI 0


// Description:  UART_INCLUDE_LEGACY_BLOCK: 
//               Instantiate legacy UART block in testbench
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define UART_INCLUDE_LEGACY_BLOCK 0







`define WIRE_SIN_TO_SIO 1


`define UART_ENCRYPT
