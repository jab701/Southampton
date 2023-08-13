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
-- The entire notice above must be reproduced on all authorized copies.
--
-- File :                       DW_apb_gpio_cc_constants.v
-- Date :                       $Date: 2008/10/16 $
-- Version      :               $Revision: #41 $
-- Abstract     :               cC constants for DW_apb_gpio
--
------------------------------------------------------------------------
*/


// Description:  GPIO_ADD_ENCODED_PARAMS: 
//               Adding the encoded parameters gives firmware an easy and quick way  
//               of identifying the DesignWare component within an I/O memory map.  
//               Some critical design-time options determine how a driver should  
//               interact with the peripheral. There is a minimal area overhead when 
//               you include these parameters. Additionally, this option allows a  
//               self-configurable single driver to be developed for each component.
// DefaultValue: true
// EnumValues:   0x0 0x1
// ValueRange:   false true
`define GPIO_ADD_ENCODED_PARAMS 1'h1


// Description:  APB_DATA_WIDTH: 
//               Width of APB Data Bus to which 
//               this component is attached.
// DefaultValue: 32
// EnumValues:   8 16 32
`define APB_DATA_WIDTH 32


// Description:  GPIO_NUM_PORTS: 
//               Selects the number of ports supported.
// DefaultValue: 4
// EnumValues:   1 2 3 4
`define GPIO_NUM_PORTS 1


// Description:  GPIO_ID: 
//               Include/Exclude ID register.  
//               If set to Include, provides an ID code value (set with GPIO_ID_NUM) 
//               that the system can read.
// DefaultValue: Include
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_ID 1


// Description:  GPIO_ID_WIDTH: 
//               GPIO ID Register Width. 
//               The width of the identification code that is configured in 
//               GPIO_ID_NUM.
// DefaultValue: 32
// MinValue:     1
// MaxValue:     32
`define GPIO_ID_WIDTH 32


`define POW_2_GPIO_ID_WIDTH 32'hffffffff


// Description:  GPIO_ID_NUM: 
//               GPIO ID Value. The ID code value that the system reads back when the device 
//               identification is present.
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     =@POW_2_GPIO_ID_WIDTH
`define GPIO_ID_NUM 32'h55378008


// Description:  Include/Exclude Revision ID register. 
//               If set then a GPIO Revision ID register is instantiated.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_REV_ID 0


// Description:  GPIO Revision ID Register Width. 
//               Holds the width of the GPIO Revision ID register.
// DefaultValue: 32
// MinValue:     1
// MaxValue:     32
`define GPIO_REV_ID_WIDTH 32


// Description:  GPIO Revision ID Value.  
//               Holds the GPIO Revision ID value.
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     =sHdl::MaxValFromWidth
`define GPIO_REV_ID_NUM 32'h0


// Description:  GPIO_PWIDTH_A: 
//               Width of Port A.  
//               This parameter configures the width of Port A.
// DefaultValue: 8
// MinValue:     1
// MaxValue:     32
`define GPIO_PWIDTH_A 8


// Description:  GPIO_HW_PORTA: 
//               Port A Auxiliary H/W Support. 
//               Port A can be configured with this parameter to have external, 
//               auxiliary hardware signals controlling the data and the  
//               direction of Port A 
//               rather than the software. If set to 0,  
//               then the functionality for the hardwaresoftware 
//               multiplexing is not implemented.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_HW_PORTA 0


// Description:  GPIO_PORTA_SINGLE_CTL: 
//               Port A Hardware/Software Control. 
//               If set, all bits of Port A are either entirely under software control 
//               (if Port A Auxiliary H/W is excluded) or entirely under hardware 
//               control (if Port A Auxiliary H/W is included). If this parameter is not 
//               set, then the "gpio_sw_porta" register determines which bits of the  
//               port are under hardware control and which are under software control.
// DefaultValue: true
// EnumValues:   0 1
// ValueRange:   false true
`define GPIO_PORTA_SINGLE_CTL 1


// Description:  GPIO_DFLT_DIR_A: 
//               Default direction of Port A. 
//               This parameter configures the default direction of Port A after 
//               power-on reset.
// DefaultValue: Input
// EnumValues:   0 1
// ValueRange:   Input Output
`define GPIO_DFLT_DIR_A 0


// Description:  GPIO_DFLT_SRC_A: 
//               Default mode if auxiliary h/w  
//               supported on port A. Sets the default mode of Port A after  
//               Power On Reset to either S/W or H/W.
// DefaultValue: S/W
// EnumValues:   0 1
// ValueRange:   S/W H/W
`define GPIO_DFLT_SRC_A 0


// Description:  GPIO_DEBOUNCE: 
//               Include Debounce logic.  
//               Include the capability of debouncing interrupts using an external 
//               slow clock.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_DEBOUNCE 1


// Description:  GPIO_PORTA_INTR: 
//               Port A Interrupt.  
//               If Port A is required to be used as an interrupt source, then set 
//               this to 1.
// DefaultValue: Include
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_PORTA_INTR 1


// Description:  GPIO_INT_POL: 
//               Port A Interrupt Polarity. Sets  
//               the polarity on the output of Port A. The single combined 
//               interrupt and the separate individual interrupts all  
//               share a common polarity.
// DefaultValue: Active Low
// EnumValues:   0 1
// ValueRange:   {Active Low} {Active High}
`define GPIO_INT_POL 1


// Description:  GPIO_INTR_IO: 
//               Port A can be configured to generate multiple interrupt signals 
//               or a single combined interrupt flag. When set to 1, the component generates a 
//               single combined interrupt flag.
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define GPIO_INTR_IO 1


// Description:  GPIO_PA_SYNC_EXT_DATA: 
//               Port A Read Back Data Synchronization. 
//               Controls the inclusion of metastability registers on the read back 
//               path when reading the external input signal gpio_ext_porta from the 
//               gpio_ext_porta memory-mapped registers.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_PA_SYNC_EXT_DATA 0


`define POW_2_GPIO_PWIDTH_A 32'hff


// Description:  GPIO_SWPORTA_RESET: 
//               Power-on-Reset value of 
//               Port A Software Register.  This is the reset value of the 
//               gpio_swporta register.
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     =@POW_2_GPIO_PWIDTH_A
`define GPIO_SWPORTA_RESET 8'h0


// Description:  GPIO_PA_SYNC_INTERRUPTS: 
//               Synchronise Port A interrupts. 
//               Synchronizes Port A interrupts. If set, metastability flip-flops for 
//               Port A interrupts are instantiated as part of the component. Otherwise, 
//               metastabilty flip-flops are not instantiated, and it is assumed that interrupt 
//               synchronization is taken care of outside of the component.
// DefaultValue: Include
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_PA_SYNC_INTERRUPTS 1


// Description:  GPIO_PWIDTH_B: 
//               Width of Port B. Configures the width of Port B.
// DefaultValue: 8
// MinValue:     1
// MaxValue:     32
`define GPIO_PWIDTH_B 8


// Description:  GPIO_HW_PORTB: 
//               Port B Auxiliary H/W Support.  
//               When set to 1, Port B has external, auxiliary hardware signals 
//               controlling the data and the direction of Port B rather than software. If set 
//               to 0, then the functionality for the hardware-software multiplexing is not 
//               implemented.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_HW_PORTB 0


// Description:  GPIO_PORTB_SINGLE_CTL: 
//               Port B Hardware/Software Control. 
//               If set, all bits of Port B are either entirely under software control 
//               (if Port B Auxiliary H/W is excluded) or entirely under hardware 
//               control (if Port B Auxiliary H/W is included). If this parameter is not 
//               set, then the "gpio_sw_portb" register determines which bits of the  
//               port are under hardware control and which are under software control.
// DefaultValue: true
// EnumValues:   0 1
// ValueRange:   false true
`define GPIO_PORTB_SINGLE_CTL 1


// Description:  GPIO_DFLT_DIR_B: 
//               Default direction of Port B.  
//               Sets the default direction of Port B after Power On Reset.
// DefaultValue: Input
// EnumValues:   0 1
// ValueRange:   Input Output
`define GPIO_DFLT_DIR_B 0


// Description:  GPIO_DFLT_SRC_B: 
//               Default mode if auxiliary h/w  
//               supported on port B. The default source of the input data, the output data, and the 
//               control of Port B are configurable. This parameter sets the reset value of the 
//               gpio_portb_ctl register.
// DefaultValue: S/W
// EnumValues:   0 1
// ValueRange:   S/W H/W
`define GPIO_DFLT_SRC_B 0


// Description:  GPIO_PB_SYNC_EXT_DATA: 
//               Port B Read Back Data Synchronization. 
//               Controls the inclusion of metastability registers on the read back 
//               path when reading the external input signal gpio_ext_portb from the 
//               gpio_ext_portb memory-mapped registers.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_PB_SYNC_EXT_DATA 0


`define POW_2_GPIO_PWIDTH_B 32'hff


// Description:  GPIO_SWPORTB_RESET: 
//               Power-on-Reset value of 
//               Port B Software Register.  This is the reset value of the 
//               gpio_swportb register
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     =@POW_2_GPIO_PWIDTH_B
`define GPIO_SWPORTB_RESET 8'h0


// Description:  GPIO_PWIDTH_C: 
//               Width of Port C. Sets the width of Port C.
// DefaultValue: 8
// MinValue:     1
// MaxValue:     32
`define GPIO_PWIDTH_C 8


// Description:  GPIO_HW_PORTC: 
//               Port C Auxiliary H/W Support. 
//               When set to 1, Port C has external, auxiliary hardware signals 
//               controlling the data and the direction of Port C, rather than software. If set 
//               to 0, then the functionality for the hardware-software multiplexing is not 
//               implemented.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_HW_PORTC 0


// Description:  GPIO_PORTC_SINGLE_CTL: 
//               Port C Hardware/Software Control. 
//               If set, all bits of Port C are either entirely under software control 
//               (if Port C Auxiliary H/W is excluded) or entirely under hardware 
//               control (if Port C Auxiliary H/W is included). If this parameter is not 
//               set, then the "gpio_sw_portc" register determines which bits of the  
//               port are under hardware control and which are under software control.
// DefaultValue: true
// EnumValues:   0 1
// ValueRange:   false true
`define GPIO_PORTC_SINGLE_CTL 1


// Description:  GPIO_DFLT_DIR_C: 
//               Default direction of Port C.  
//               Sets the default direction of Port C after Power On Reset.
// DefaultValue: Input
// EnumValues:   0 1
// ValueRange:   Input Output
`define GPIO_DFLT_DIR_C 0


// Description:  GPIO_DFLT_SRC_C: 
//               Default mode if auxiliary h/w  
//               supported on port C. The default source of the input data, the output data, and the 
//               control of Port C are configurable This parameter sets the reset value of the 
//               gpio_portc_ctl register. 
//               Power On Reset to either S/W or H/W.
// DefaultValue: S/W
// EnumValues:   0 1
// ValueRange:   S/W H/W
`define GPIO_DFLT_SRC_C 0


// Description:  GPIO_PC_SYNC_EXT_DATA: 
//               Port C Read Back Data Synchronization.  
//               Controls inclusion of metastability registers on the read back 
//               path when reading the external input signal gpio_ext_portc from the 
//               gpio_ext_portc memory-mapped registers.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_PC_SYNC_EXT_DATA 0


`define POW_2_GPIO_PWIDTH_C 32'hff


// Description:  GPIO_SWPORTC_RESET: 
//               Power-on-Reset value of 
//               Port C Software Register.  This is the reset value of the 
//               gpio_swportc register
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     =@POW_2_GPIO_PWIDTH_C
`define GPIO_SWPORTC_RESET 8'h0


// Description:  GPIO_PWIDTH_D: 
//               Width of Port D. This parameter configures the width of Port D.
// DefaultValue: 8
// MinValue:     1
// MaxValue:     32
`define GPIO_PWIDTH_D 8


// Description:  GPIO_HW_PORTD: 
//               Port D Auxiliary H/W Support. 
//               When set to 1, Port D has external, auxiliary hardware signals 
//               controlling the data and the direction of Port D, rather than software. If set 
//               to 0, then the functionality for the hardware-software multiplexing is not 
//               implemented.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_HW_PORTD 0


// Description:  GPIO_PORTD_SINGLE_CTL: 
//               Port D Hardware/Software Control. 
//               If set, all bits of Port D are either entirely under software control 
//               (if Port D Auxiliary H/W is excluded) or entirely under hardware 
//               control (if Port C Auxiliary H/W is included). If this parameter is not 
//               set, then the "gpio_sw_portd" register determines which bits of the  
//               port are under hardware control and which are under software control.
// DefaultValue: true
// EnumValues:   0 1
// ValueRange:   false true
`define GPIO_PORTD_SINGLE_CTL 1


// Description:  GPIO_DFLT_DIR_D: 
//               Default direction of Port D.  
//               Sets the default direction of Port D after Power On Reset.
// DefaultValue: Input
// EnumValues:   0 1
// ValueRange:   Input Output
`define GPIO_DFLT_DIR_D 0


// Description:  GPIO_DFLT_SRC_D: 
//               Default mode if auxiliary h/w  
//               supported on port D. The default source of the input data, the output data, and the 
//               control of Port D are configurable This parameter sets the reset value of the 
//               gpio_portd_ctl register.
// DefaultValue: S/W
// EnumValues:   0 1
// ValueRange:   S/W H/W
`define GPIO_DFLT_SRC_D 0


// Description:  GPIO_PD_SYNC_EXT_DATA: 
//               Port D Read Back Data Synchronization. 
//               Controls the inclusion of metastability registers on the read back 
//               path when reading the gpio_ext_portd external input signal from the 
//               gpio_ext_portd memory-mapped registers.
// DefaultValue: Exclude
// EnumValues:   0 1
// ValueRange:   Exclude Include
`define GPIO_PD_SYNC_EXT_DATA 0


`define POW_2_GPIO_PWIDTH_D 32'hff


// Description:  GPIO_SWPORTD_RESET: 
//               Power-on-Reset value of 
//               Port D Software Register. This is the reset value of the 
//               gpio_swportd register
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     =@POW_2_GPIO_PWIDTH_D
`define GPIO_SWPORTD_RESET 8'h0


`define GPIO_RDATA_WIDTH 32


`define GPIO_ADDR_SLICE_RHS 2


`define GPIO_ADDR_SLICE_LHS 6


`define MAX_APB_DATA_WIDTH 32


`define GPIO_LS_SYNC_WIDTH 1


`define GPIO_CTL_WIDTH_A 1


`define GPIO_CTL_WIDTH_B 1


`define GPIO_CTL_WIDTH_C 1


`define GPIO_CTL_WIDTH_D 1


`define GPIO_INDIVIDUAL 0


`define GPIO_COMBINED 1



// Description:  Each corekit has a version number. 
//               This is relected in the ascii version number which needs to get translated. 
//                0 => 48 -> 30 
//                1 => 49 -> 31 
//                2 => 50 -> 32 
//                A => 65 -> 41 
//                B => 66 -> 42 
//                C => 67 -> 43 
//                
//               Current Version is 2.06* => 32_30_36_2A
// DefaultValue: 0x3230372a
// MinValue:     0x0
// MaxValue:     0xffffffff
`define GPIO_VERSION_ID 32'h3230372a


// Description:  Set this parameter to true (1) 
//               if you want the gpio_ext_portX registers 
//               to read back the internal gpio_swportX_drN 
//               registers when the port is configured as an 
//               output (X= A,B,C or D) (N=0..31) 
//               With this parameter set to false (0), 
//               the gpio_ext_portX registers will always reflect 
//               the states of the corresponding component I/O ports. 
//               Setting this parameter to true (1) means that the 
//               gpio_ext_portX registers have the same functionality 
//               as in version 2.01A and earlier coreKits.
// DefaultValue: 0
// MinValue:     0
// MaxValue:     1
`define GPIO_PORTX_READBACK_MUX 0


`define GPIO_ENCODED_APB_WIDTH 2'h2


`define GPIO_ENCODED_PWIDTH_A 5'h7


`define GPIO_ENCODED_PWIDTH_B 5'h7


`define GPIO_ENCODED_PWIDTH_C 5'h7


`define GPIO_ENCODED_PWIDTH_D 5'h7


`define GPIO_ENCODED_ID_WIDTH 5'h1f


`define GPIO_ENCODED_NUM_PORTS 2'h0


// Description:  Catch gpio_porta_ctl reset value
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     0xffffffff
`define GPIO_DFLT_SRC_RESET_A 32'h0


// Description:  Catch gpio_portb_ctl reset value
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     0xffffffff
`define GPIO_DFLT_SRC_RESET_B 32'h0


// Description:  Catch gpio_portc_ctl reset value
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     0xffffffff
`define GPIO_DFLT_SRC_RESET_C 32'h0


// Description:  Catch gpio_portd_ctl reset value
// DefaultValue: 0x0
// MinValue:     0x0
// MaxValue:     0xffffffff
`define GPIO_DFLT_SRC_RESET_D 32'h0


// Description:  Catch gpio_configid_reg2 reset
// DefaultValue: 0x39ce7
// MinValue:     0x0
// MaxValue:     =sHdl::MaxValFromWidth
`define GPIO_CID_REG2 32'h39ce7


// Description:  Catch gpio_configid_reg2 reset value
// DefaultValue: 0x39ce7
// MinValue:     0x0
// MaxValue:     0xffffffff
`define GPIO_CID_RESET_REG2 32'h39ce7


// Description:  Move SymbolicNames to logic value
// DefaultValue: 0x1
// MinValue:     0x0
// MaxValue:     0x1
`define GPIO_L_ID 1'h1

`define GPIO_L_HW_PORTA 1'h0

`define GPIO_L_HW_PORTB 1'h0

`define GPIO_L_HW_PORTC 1'h0

`define GPIO_L_HW_PORTD 1'h0

`define GPIO_L_PORTA_INTR 1'h1

`define GPIO_L_DEBOUNCE 1'h1

`define PORTD_SINGLE_CTL 1'h1

`define PORTC_SINGLE_CTL 1'h1

`define PORTB_SINGLE_CTL 1'h1

`define PORTA_SINGLE_CTL 1'h1


// Description:  Catch gpio_configid_reg1 reset
// DefaultValue: 0x1ff0f2
// MinValue:     0x0
// MaxValue:     =sHdl::MaxValFromWidth
`define GPIO_CID_REG1 32'h1ff0f2


// Description:  Catch gpio_configid_reg1 reset value
// DefaultValue: 0x1ff0f2
// MinValue:     0x0
// MaxValue:     0xffffffff
`define GPIO_CID_RESET_REG1 32'h1ff0f2



`define GPIO_ENCRYPT

