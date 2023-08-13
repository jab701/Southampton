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
-- File :                       DW_apb_constants.v
-- Author:                      Chris Gilbert
-- Date :                       $Date: 2008/06/29 $
-- Version      :               $Revision: #15 $
-- Abstract     :               This module contains definitions that 
--                              are used by the DW_apb_ahbsif module.
--
--                              These definitions are included as a
--                              separate module as this is the easiest
--                              way of packaging them, since the actual
--                              values of these constants depends on the
--                              configuration of the APB system.
--
-- Modification History:        Refer to CVS log
-- =====================================================================
*/


// Description:  Maximum number of slaves in subsystem
// DefaultValue: 16
// MinValue:     -2147483648
// MaxValue:     2147483647
`define MAX_APB_SLAVES 16


// Description:  Maximum AHB Data Width
// DefaultValue: 256
// MinValue:     -2147483648
// MaxValue:     2147483647
`define MAX_AHB_DATA_WIDTH 256


// Description:  Maximum APB Data Width
// DefaultValue: 32
// MinValue:     -2147483648
// MaxValue:     2147483647
`define MAX_APB_DATA_WIDTH 32

//
// Not defined as a reuse pragma so macro will not be resolved.
// For testbench purposes
//
`define PRDATABUS_WIDTH `APB_DATA_WIDTH*`NUM_APB_SLAVES


// Description:  Maximum width of bussed prdata bus
// DefaultValue: 512
// MinValue:     -2147483648
// MaxValue:     2147483647
`define MAX_PRDATABUS_WIDTH 512


// Description:  Maximum width of data to store
// DefaultValue: 32
// MinValue:     -2147483648
// MaxValue:     2147483647
`define HWDATA32_WIDTH 32
