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
-- File :                       DW_apb_cc_constants.v
-- Author:                      Chris Gilbert
-- Date :                       $Date: 2008/10/16 $
-- Version      :               $Revision: #37 $
-- Abstract     :               This module contains definitions that
--                              are configured by coreConsultant
--
-- Modification History:        Refer to CVS log
-- =====================================================================
*/


// Description:  HADDR_WIDTH: AHB System Address Width
// DefaultValue: 32
// EnumValues:   32 64
// ValueRange:   32 64
`define HADDR_WIDTH 32


// Description:  PADDR_WIDTH: APB System Address Width
// DefaultValue: 32
// EnumValues:   32 64
// ValueRange:   32 64
`define PADDR_WIDTH 32


// Description:  AHB_DATA_WIDTH: The AHB Databus Width
// DefaultValue: 32
// EnumValues:   32 64 128 256
`define AHB_DATA_WIDTH 32


// Description:  BIG_ENDIAN: 
//               Define the Endianness (Big-Endian or Little-Endian) of the AHB. 
//               The APB subsystem is ALWAYS little endian.
// DefaultValue: Little-Endian
// EnumValues:   0 1
// ValueRange:   Little-Endian Big-Endian
`define BIG_ENDIAN 0


// Description:  APB_DATA_WIDTH: The APB Databus Width
// DefaultValue: 32
// EnumValues:   8 16 32
`define APB_DATA_WIDTH 32


// Description:  NUM_APB_SLAVES: The Number of Slave Ports (1 to 16)
// DefaultValue: 4
// EnumValues:   1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
`define NUM_APB_SLAVES 4


// Description:  R0_APB_SA: 
//               This is used to verify that all the start and end address for each APB 
//               slave are within a region. 
//               This frames the addresses and corresponds to the start address specified 
//               for the APB within the AHB. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00000000
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define R0_APB_SA 32'h04000000


// Description:  R0_APB_EA: 
//               This is used to verify that all the start and end address for each APB 
//               slave are within a region. 
//               This frames the addresses and corresponds to the end address specified 
//               for the APB within the AHB. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000043ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define R0_APB_EA 32'h04003fff


// Description:  START_PADDR_0: 
//               Start Address for APB Slave #0. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00000400
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_0 32'h04000000


// Description:  START_PADDR_1: 
//               Start Address for APB Slave #1. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00000800
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_1 32'h04001000


// Description:  START_PADDR_2: 
//               Start Address for APB Slave #2. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00000c00
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_2 32'h04002000


// Description:  START_PADDR_3: 
//               Start Address for APB Slave #3. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00001000
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_3 32'h04003000


// Description:  START_PADDR_4: 
//               Start Address for APB Slave #4. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00001400
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_4 32'h00001400


// Description:  START_PADDR_5: 
//               Start Address for APB Slave #5. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00001800
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_5 32'h00001800


// Description:  START_PADDR_6: 
//               Start Address for APB Slave #6. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00001c00
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_6 32'h00001c00

//The decoder must be configured as internal (when APB_HAS_XDCDR = 0).

// Description:  START_PADDR_7: 
//               Start Address for APB Slave #7. 
//               This is an absolute address value.
// DefaultValue: 0x00002000
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_7 32'h00002000


// Description:  START_PADDR_8: 
//               Start Address for APB Slave #8. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00002400
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_8 32'h00002400


// Description:  START_PADDR_9: 
//               Start Address for APB Slave #9. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00002800
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_9 32'h00002800


// Description:  START_PADDR_10: 
//               Start Address for APB Slave #10. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00002c00
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_10 32'h00002c00


// Description:  START_PADDR_11: 
//               Start Address for APB Slave #11. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00003000
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_11 32'h00003000


// Description:  START_PADDR_12: 
//               Start Address for APB Slave #12. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00003400
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_12 32'h00003400


// Description:  START_PADDR_13: 
//               Start Address for APB Slave #13. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00003800
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_13 32'h00003800


// Description:  START_PADDR_14: 
//               Start Address for APB Slave #14. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00003c00
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_14 32'h00003c00


// Description:  START_PADDR_15: 
//               Start Address for APB Slave #15. 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00004000
// MinValue:     0x00000000
// MaxValue:     0xfffffc00
`define START_PADDR_15 32'h00004000


// Description:  END_PADDR_0: 
//               End Address for APB Slave #0 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000007ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_0 32'h04000fff


// Description:  END_PADDR_1: 
//               End Address for APB Slave #1 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00000bff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_1 32'h04001fff


// Description:  END_PADDR_2: 
//               End Address for APB Slave #2 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00000fff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_2 32'h04002fff


// Description:  END_PADDR_3: 
//               End Address for APB Slave #3 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000013ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_3 32'h04003fff


// Description:  END_PADDR_4: 
//               End Address for APB Slave #4 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000017ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_4 32'h000017ff


// Description:  END_PADDR_5: 
//               End Address for APB Slave #5 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00001bff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_5 32'h00001bff


// Description:  END_PADDR_6 
//               End Address for APB Slave #6 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00001fff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_6 32'h00001fff


// Description:  END_PADDR_7: 
//               End Address for APB Slave #7 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000023ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_7 32'h000023ff


// Description:  END_PADDR_8: 
//               End Address for APB Slave #8 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000027ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_8 32'h000027ff


// Description:  END_PADDR_9: 
//               End Address for APB Slave #9 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00002bff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_9 32'h00002bff


// Description:  END_PADDR_10: 
//               End Address for APB Slave #10 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00002fff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_10 32'h00002fff


// Description:  END_PADDR_11: 
//               End Address for APB Slave #11 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000033ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_11 32'h000033ff


// Description:  END_PADDR_12: 
//               End Address for APB Slave #12 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000037ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_12 32'h000037ff


// Description:  END_PADDR_13: 
//               End Address for APB Slave #13 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00003bff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_13 32'h00003bff


// Description:  END_PADDR_14: 
//               End Address for APB Slave #14 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x00003fff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_14 32'h00003fff


// Description:  END_PADDR_15: 
//               End Address for APB Slave #15 
//               This is an absolute address value. 
//               The decoder must be configured as internal (when APB_HAS_XDCDR = 0).
// DefaultValue: 0x000043ff
// MinValue:     0x000003ff
// MaxValue:     0xffffffff
`define END_PADDR_15 32'h000043ff


// Description:  APB_HAS_XDCDR: 
//               If True (1), the decoder is external to the DW_apb. 
//               If False (0), the decoder is internal to the DW_apb. 
//               For an internal decoder, the addresses need to be supplied  
//               by the DW_apb at configuration. 
//               An external decoder allows users to connect any decoder
// DefaultValue: false
// EnumValues:   0 1
// ValueRange:   false true
`define APB_HAS_XDCDR 0


`define APB_ENCRYPT
