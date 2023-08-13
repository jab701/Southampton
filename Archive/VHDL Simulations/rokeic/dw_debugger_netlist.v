
module DW_debugger_inst_DW_debugger_0 ( clk, reset_N, rd_bits, rxd, wr_bits, 
        txd, div_bypass_mode );
  input [55:0] rd_bits;
  output [55:0] wr_bits;
  input clk, reset_N, rxd, div_bypass_mode;
  output txd;
  wire   net4, net5, net6, net7, net8, net9, net10, net11, net12, net13, net14,
         net15, net16, net17, net18, net19, net20, net21, net22, net23, net24,
         net25, net26, net27, net28, net29, net30, net31, net32, net33, net34,
         net35, net173, net37, net38, net39, net40, net41, net42, net43, net44,
         net45, net46, net89, net48, net49, net50, net51, net52, net53, net54,
         net55, net56, net57, net58, net59, clk_ctr_carry, predebug_clk_N,
         next_predebug_clk, debug_clk, \addr[0] , net68, n787, n786,
         rx_char_3_port, rx_char_5_port, rx_char_4_port, state_3_port, net47,
         rx_char_1_port, rx_char_0_port, state_2_port, state_0_port,
         state_4_port, n781, n782, n780, n783, n779, n784, net118, n788,
         net119, n789, net121, n790, net122, n791, net123, n792, net124, n793,
         net125, n794, rx_char_6_port, net130, n796, n797, n798, n799, n800,
         n801, n802, net133, n803, state_1_port, advance, PC_count_inc_0_port,
         PC_U4_carry_1_port, PC_count_inc_1_port, PC_U4_carry_2_port,
         PC_count_inc_2_port, PC_U4_carry_3_port, PC_count_inc_3_port,
         PC_U4_carry_4_port, PC_count_inc_4_port, PC_U4_carry_5_port,
         state_5_port, PC_count_inc_5_port, PC_U4_carry_6_port,
         RX_baud_ctr_d_0_port, net167, RX_baud_ctr_d_3_port, n363, n351,
         TX_n151, net36, n354, net176, net177, net178, state_6_port,
         RX_val250_1_port, TX_bit_ctr_d_0_port, TX_bit_ctr_d_3_port,
         TX_bit_ctr_d_2_port, TX_bit_ctr_d_1_port, net182,
         RX_baud_ctr_d_2_port, net183, n360, net187, n365, RX_bit_ctr_d_1_port,
         n359, RX_bit_ctr_d_2_port, RX_bit_ctr_d_3_port, RX_bit_ctr_d_0_port,
         net188, RX_baud_ctr_d_1_port, n362, TX_baud_ctr_d_1_port,
         rx_char_2_port, TX_baud_ctr_d_0_port, TX_baud_ctr_d_3_port,
         PC_next_count_6_port, PC_next_count_5_port, PC_next_count_4_port,
         PC_next_count_3_port, PC_next_count_2_port, PC_next_count_1_port,
         PC_next_count_0_port, n361, RX_rxd_svd1_N, net211,
         TX_baud_ctr_d_2_port, \MUX/tmp[3][0] , \MUX/tmp[3][1] ,
         \MUX/tmp[3][2] , \MUX/tmp[3][3] , \clk_divider/tercnt_d ,
         \clk_divider/net15 , \clk_divider/net14 , \clk_divider/net13 ,
         \clk_divider/net12 , \clk_divider/next_count[3] ,
         \clk_divider/next_count[2] , \clk_divider/next_count[1] , n10, n11,
         n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25,
         n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39,
         n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53,
         n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67,
         n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81,
         n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95,
         n96, n97, n98, n99, n100, n101, n102, n103, n104, n105, n106, n107,
         n108, n109, n110, n111, n112, n113, n114, n115, n116, n117, n118,
         n119, n120, n121, n122, n123, n124, n125, n126, n127, n128, n129,
         n130, n131, n132, n133, n134, n135, n136, n137, n138, n139, n140,
         n141, n142, n143, n144, n145, n146, n147, n148, n149, n150, n151,
         n152, n153, n154, n155, n156, n157, n158, n159, n160, n161, n162,
         n163, n164, n165, n166, n167, n168, n169, n170, n171, n172, n173,
         n174, n175, n176, n177, n178, n179, n180, n181, n182, n183, n184,
         n185, n186, n187, n188, n189, n190, n191, n192, n193, n194, n195,
         n196, n197, n198, n199, n200, n201, n202, n203, n204, n205, n206,
         n207, n208, n209, n210, n211, n212, n213, n214, n215, n216, n217,
         n218, n219, n220, n221, n222, n223, n224, n225, n226, n227, n228,
         n229, n230, n231, n232, n233, n234, n235, n236, n237, n238, n239,
         n240, n241, n242, n243, n244, n245, n246, n247, n248, n249, n250,
         n251, n252, n253, n254, n255, n256, n257, n258, n259, n260, n261,
         n262, n263, n264, n265, n266, n267, n268, n269, n270, n271, n272,
         n273, n274, n275, n276, n277, n278, n279, n280, n281, n282, n283,
         n284, n285, n286, n287, n288, n289, n290, n291, n292, n293, n294,
         n295, n296, n297, n298, n299, n300, n301, n302, n303, n304, n305,
         n306, n307, n308, n309, n310, n311, n312, n313, n314, n315, n316,
         n317, n318, n319, n320, n321, n322, n323, n324, n325, n326, n327,
         n328, n329, n330, n331, n332, n333, n334, n335, n336, n337, n338,
         n339, n340, n341, n342, n343, n344, n345, n346, n347, n348, n349,
         n350, n352, n353, n355, n356, n357, n358, n364, n366, n367, n368,
         n369, n370, n371, n372, n373, n374, n375, n376, n377, n378, n379,
         n380, n381, n382, n383, n384, n385, n386, n387, n388, n389, n390,
         n391, n392, n393, n394, n395, n396, n397, n398, n399, n400, n401,
         n402, n403, n404, n405, n406, n407, n408, n409, n410, n411, n412,
         n413, n414, n415, n416, n417, n418, n419, n420, n421, n422, n423,
         n424, n425, n426, n427, n428, n429, n430, n431, n432, n433, n434,
         n435, n436;
  wire   [55:0] wr_bits_d;

  GTECH_FD2 ff_debug_clk ( .D(next_predebug_clk), .CP(clk), .CD(reset_N), .QN(
        predebug_clk_N) );
  GTECH_FD2 OUT_FF_0 ( .D(wr_bits_d[0]), .CP(clk), .CD(reset_N), .Q(wr_bits[0]), .QN(net59) );
  GTECH_FD2 OUT_FF_1 ( .D(wr_bits_d[1]), .CP(clk), .CD(reset_N), .Q(wr_bits[1]), .QN(net58) );
  GTECH_FD2 OUT_FF_2 ( .D(wr_bits_d[2]), .CP(clk), .CD(reset_N), .Q(wr_bits[2]), .QN(net57) );
  GTECH_FD2 OUT_FF_3 ( .D(wr_bits_d[3]), .CP(clk), .CD(reset_N), .Q(wr_bits[3]), .QN(net56) );
  GTECH_FD2 OUT_FF_4 ( .D(wr_bits_d[4]), .CP(clk), .CD(reset_N), .Q(wr_bits[4]), .QN(net55) );
  GTECH_FD2 OUT_FF_5 ( .D(wr_bits_d[5]), .CP(clk), .CD(reset_N), .Q(wr_bits[5]), .QN(net54) );
  GTECH_FD2 OUT_FF_6 ( .D(wr_bits_d[6]), .CP(clk), .CD(reset_N), .Q(wr_bits[6]), .QN(net53) );
  GTECH_FD2 OUT_FF_7 ( .D(wr_bits_d[7]), .CP(clk), .CD(reset_N), .Q(wr_bits[7]), .QN(net52) );
  GTECH_FD2 OUT_FF_8 ( .D(wr_bits_d[8]), .CP(clk), .CD(reset_N), .Q(wr_bits[8]), .QN(net51) );
  GTECH_FD2 OUT_FF_9 ( .D(wr_bits_d[9]), .CP(clk), .CD(reset_N), .Q(wr_bits[9]), .QN(net50) );
  GTECH_FD2 OUT_FF_10 ( .D(wr_bits_d[10]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[10]), .QN(net49) );
  GTECH_FD2 OUT_FF_11 ( .D(wr_bits_d[11]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[11]), .QN(net48) );
  GTECH_FD2 OUT_FF_12 ( .D(wr_bits_d[12]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[12]), .QN(net89) );
  GTECH_FD2 OUT_FF_13 ( .D(wr_bits_d[13]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[13]), .QN(net46) );
  GTECH_FD2 OUT_FF_14 ( .D(wr_bits_d[14]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[14]), .QN(net45) );
  GTECH_FD2 OUT_FF_15 ( .D(wr_bits_d[15]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[15]), .QN(net44) );
  GTECH_FD2 OUT_FF_16 ( .D(wr_bits_d[16]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[16]), .QN(net43) );
  GTECH_FD2 OUT_FF_17 ( .D(wr_bits_d[17]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[17]), .QN(net42) );
  GTECH_FD2 OUT_FF_18 ( .D(wr_bits_d[18]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[18]), .QN(net41) );
  GTECH_FD2 OUT_FF_19 ( .D(wr_bits_d[19]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[19]), .QN(net40) );
  GTECH_FD2 OUT_FF_20 ( .D(wr_bits_d[20]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[20]), .QN(net39) );
  GTECH_FD2 OUT_FF_21 ( .D(wr_bits_d[21]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[21]), .QN(net38) );
  GTECH_FD2 OUT_FF_22 ( .D(wr_bits_d[22]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[22]), .QN(net37) );
  GTECH_FD2 OUT_FF_23 ( .D(wr_bits_d[23]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[23]), .QN(net173) );
  GTECH_FD2 OUT_FF_24 ( .D(wr_bits_d[24]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[24]), .QN(net35) );
  GTECH_FD2 OUT_FF_25 ( .D(wr_bits_d[25]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[25]), .QN(net34) );
  GTECH_FD2 OUT_FF_26 ( .D(wr_bits_d[26]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[26]), .QN(net33) );
  GTECH_FD2 OUT_FF_27 ( .D(wr_bits_d[27]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[27]), .QN(net32) );
  GTECH_FD2 OUT_FF_28 ( .D(wr_bits_d[28]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[28]), .QN(net31) );
  GTECH_FD2 OUT_FF_29 ( .D(wr_bits_d[29]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[29]), .QN(net30) );
  GTECH_FD2 OUT_FF_30 ( .D(wr_bits_d[30]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[30]), .QN(net29) );
  GTECH_FD2 OUT_FF_31 ( .D(wr_bits_d[31]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[31]), .QN(net28) );
  GTECH_FD2 OUT_FF_32 ( .D(wr_bits_d[32]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[32]), .QN(net27) );
  GTECH_FD2 OUT_FF_33 ( .D(wr_bits_d[33]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[33]), .QN(net26) );
  GTECH_FD2 OUT_FF_34 ( .D(wr_bits_d[34]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[34]), .QN(net25) );
  GTECH_FD2 OUT_FF_35 ( .D(wr_bits_d[35]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[35]), .QN(net24) );
  GTECH_FD2 OUT_FF_36 ( .D(wr_bits_d[36]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[36]), .QN(net23) );
  GTECH_FD2 OUT_FF_37 ( .D(wr_bits_d[37]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[37]), .QN(net22) );
  GTECH_FD2 OUT_FF_38 ( .D(wr_bits_d[38]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[38]), .QN(net21) );
  GTECH_FD2 OUT_FF_39 ( .D(wr_bits_d[39]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[39]), .QN(net20) );
  GTECH_FD2 OUT_FF_40 ( .D(wr_bits_d[40]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[40]), .QN(net19) );
  GTECH_FD2 OUT_FF_41 ( .D(wr_bits_d[41]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[41]), .QN(net18) );
  GTECH_FD2 OUT_FF_42 ( .D(wr_bits_d[42]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[42]), .QN(net17) );
  GTECH_FD2 OUT_FF_43 ( .D(wr_bits_d[43]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[43]), .QN(net16) );
  GTECH_FD2 OUT_FF_44 ( .D(wr_bits_d[44]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[44]), .QN(net15) );
  GTECH_FD2 OUT_FF_45 ( .D(wr_bits_d[45]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[45]), .QN(net14) );
  GTECH_FD2 OUT_FF_46 ( .D(wr_bits_d[46]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[46]), .QN(net13) );
  GTECH_FD2 OUT_FF_47 ( .D(wr_bits_d[47]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[47]), .QN(net12) );
  GTECH_FD2 OUT_FF_48 ( .D(wr_bits_d[48]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[48]), .QN(net11) );
  GTECH_FD2 OUT_FF_49 ( .D(wr_bits_d[49]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[49]), .QN(net10) );
  GTECH_FD2 OUT_FF_50 ( .D(wr_bits_d[50]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[50]), .QN(net9) );
  GTECH_FD2 OUT_FF_51 ( .D(wr_bits_d[51]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[51]), .QN(net8) );
  GTECH_FD2 OUT_FF_52 ( .D(wr_bits_d[52]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[52]), .QN(net7) );
  GTECH_FD2 OUT_FF_53 ( .D(wr_bits_d[53]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[53]), .QN(net6) );
  GTECH_FD2 OUT_FF_54 ( .D(wr_bits_d[54]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[54]), .QN(net5) );
  GTECH_FD2 OUT_FF_55 ( .D(wr_bits_d[55]), .CP(clk), .CD(reset_N), .Q(
        wr_bits[55]), .QN(net4) );
  GTECH_ADD_AB PC_U4_U0 ( .A(state_0_port), .B(advance), .COUT(
        PC_U4_carry_1_port), .S(PC_count_inc_0_port) );
  GTECH_ADD_AB PC_U4_U1_1 ( .A(state_1_port), .B(PC_U4_carry_1_port), .COUT(
        PC_U4_carry_2_port), .S(PC_count_inc_1_port) );
  GTECH_ADD_AB PC_U4_U1_2 ( .A(state_2_port), .B(PC_U4_carry_2_port), .COUT(
        PC_U4_carry_3_port), .S(PC_count_inc_2_port) );
  GTECH_ADD_AB PC_U4_U1_3 ( .A(state_3_port), .B(PC_U4_carry_3_port), .COUT(
        PC_U4_carry_4_port), .S(PC_count_inc_3_port) );
  GTECH_ADD_AB PC_U4_U1_4 ( .A(state_4_port), .B(PC_U4_carry_4_port), .COUT(
        PC_U4_carry_5_port), .S(PC_count_inc_4_port) );
  GTECH_ADD_AB PC_U4_U1_5 ( .A(state_5_port), .B(PC_U4_carry_5_port), .COUT(
        PC_U4_carry_6_port), .S(PC_count_inc_5_port) );
  GTECH_FD2 addr_reg2_2_label ( .D(n782), .CP(debug_clk), .CD(reset_N), .QN(
        n781) );
  GTECH_FD2 addr_reg2_0_label ( .D(n783), .CP(debug_clk), .CD(reset_N), .QN(
        n780) );
  GTECH_FD2 addr_reg2_1_label ( .D(n784), .CP(debug_clk), .CD(reset_N), .QN(
        n779) );
  GTECH_FD2 TX_TXD_N_reg ( .D(n786), .CP(debug_clk), .CD(reset_N), .QN(txd) );
  GTECH_FD2 TX_done_reg ( .D(n787), .CP(debug_clk), .CD(reset_N), .QN(net68)
         );
  GTECH_FD2 RX_rx_char_reg_1_label ( .D(n788), .CP(debug_clk), .CD(reset_N), 
        .Q(rx_char_1_port) );
  GTECH_FD2 RX_rx_char_reg_5_label ( .D(n789), .CP(debug_clk), .CD(reset_N), 
        .Q(rx_char_5_port) );
  GTECH_FD2 RX_rx_char_reg_2_label ( .D(n790), .CP(debug_clk), .CD(reset_N), 
        .Q(rx_char_2_port) );
  GTECH_FD2 RX_rx_char_reg_4_label ( .D(n791), .CP(debug_clk), .CD(reset_N), 
        .Q(rx_char_4_port) );
  GTECH_FD2 RX_rx_char_reg_0_label ( .D(n792), .CP(debug_clk), .CD(reset_N), 
        .Q(rx_char_0_port) );
  GTECH_FD2 RX_rx_char_reg_3_label ( .D(n793), .CP(debug_clk), .CD(reset_N), 
        .Q(rx_char_3_port) );
  GTECH_FD2 RX_rxd_svd2_N_reg ( .D(RX_rxd_svd1_N), .CP(debug_clk), .CD(reset_N), .QN(net133) );
  GTECH_FD2 RX_bit_ctr_enable_reg ( .D(RX_val250_1_port), .CP(debug_clk), .CD(
        reset_N), .QN(net187) );
  GTECH_FD2 RX_bit_ff_reg ( .D(n794), .CP(debug_clk), .CD(reset_N), .QN(net125) );
  GTECH_FD2 RX_rxd_svd1_N_reg ( .D(n87), .CP(debug_clk), .CD(reset_N), .Q(
        RX_rxd_svd1_N), .QN(net211) );
  GTECH_FD2 RX_rx_char_reg_6_label ( .D(n796), .CP(debug_clk), .CD(reset_N), 
        .Q(rx_char_6_port) );
  GTECH_FD2 RX_rx_bits_reg_0_label ( .D(n797), .CP(debug_clk), .CD(reset_N), 
        .QN(net123) );
  GTECH_FD2 RX_rx_bits_reg_1_label ( .D(n798), .CP(debug_clk), .CD(reset_N), 
        .QN(net118) );
  GTECH_FD2 RX_rx_bits_reg_2_label ( .D(n799), .CP(debug_clk), .CD(reset_N), 
        .QN(net121) );
  GTECH_FD2 RX_rx_bits_reg_3_label ( .D(n800), .CP(debug_clk), .CD(reset_N), 
        .QN(net124) );
  GTECH_FD2 RX_rx_bits_reg_4_label ( .D(n801), .CP(debug_clk), .CD(reset_N), 
        .QN(net122) );
  GTECH_FD2 RX_rx_bits_reg_5_label ( .D(n802), .CP(debug_clk), .CD(reset_N), 
        .QN(net119) );
  GTECH_FD2 RX_rx_bits_reg_6_label ( .D(n803), .CP(debug_clk), .CD(reset_N), 
        .QN(net130) );
  GTECH_FD2 PC_U1_3_3 ( .D(PC_next_count_3_port), .CP(debug_clk), .CD(reset_N), 
        .Q(state_3_port) );
  GTECH_FD2 PC_U1_3_2 ( .D(PC_next_count_2_port), .CP(debug_clk), .CD(reset_N), 
        .Q(state_2_port) );
  GTECH_FD2 PC_U1_3_4 ( .D(PC_next_count_4_port), .CP(debug_clk), .CD(reset_N), 
        .Q(state_4_port) );
  GTECH_FD2 PC_U1_3_1 ( .D(PC_next_count_1_port), .CP(debug_clk), .CD(reset_N), 
        .Q(state_1_port) );
  GTECH_FD2 PC_U1_3_0 ( .D(PC_next_count_0_port), .CP(debug_clk), .CD(reset_N), 
        .Q(state_0_port) );
  GTECH_FD2 TX_baud_ctr_F1_5 ( .D(TX_baud_ctr_d_0_port), .CP(debug_clk), .CD(
        reset_N), .QN(net176) );
  GTECH_FD2 TX_baud_ctr_F0 ( .D(TX_baud_ctr_d_3_port), .CP(debug_clk), .CD(
        reset_N), .Q(TX_baud_ctr_d_2_port), .QN(net36) );
  GTECH_FD2 TX_baud_ctr_F1 ( .D(TX_baud_ctr_d_2_port), .CP(debug_clk), .CD(
        reset_N), .QN(net177) );
  GTECH_FD2 TX_baud_ctr_F1_4 ( .D(TX_baud_ctr_d_1_port), .CP(debug_clk), .CD(
        reset_N), .Q(TX_baud_ctr_d_0_port), .QN(n354) );
  GTECH_FD2 TX_bit_ctr_F1_5 ( .D(TX_bit_ctr_d_0_port), .CP(debug_clk), .CD(
        reset_N), .QN(n361) );
  GTECH_FD2 TX_bit_ctr_F0 ( .D(TX_bit_ctr_d_3_port), .CP(debug_clk), .CD(
        reset_N), .QN(n362) );
  GTECH_FD2 TX_bit_ctr_F1 ( .D(TX_bit_ctr_d_2_port), .CP(debug_clk), .CD(
        reset_N), .QN(n363) );
  GTECH_FD2 TX_bit_ctr_F1_4 ( .D(TX_bit_ctr_d_1_port), .CP(debug_clk), .CD(
        reset_N), .QN(n351) );
  GTECH_FD2 TX_bit_ff_reg ( .D(TX_n151), .CP(debug_clk), .CD(reset_N), .Q(
        net47) );
  GTECH_FD2 RX_bit_ctr_F1_5 ( .D(RX_bit_ctr_d_0_port), .CP(debug_clk), .CD(
        reset_N), .QN(n360) );
  GTECH_FD2 RX_bit_ctr_F0 ( .D(RX_bit_ctr_d_3_port), .CP(debug_clk), .CD(
        reset_N), .QN(n359) );
  GTECH_FD2 RX_bit_ctr_F1 ( .D(RX_bit_ctr_d_2_port), .CP(debug_clk), .CD(
        reset_N), .QN(n365) );
  GTECH_FD2 RX_bit_ctr_F1_4 ( .D(RX_bit_ctr_d_1_port), .CP(debug_clk), .CD(
        reset_N), .Q(net183) );
  GTECH_FD2 RX_baud_ctr_F1_5 ( .D(RX_baud_ctr_d_0_port), .CP(debug_clk), .CD(
        reset_N), .QN(net167) );
  GTECH_FD2 RX_baud_ctr_F0 ( .D(RX_baud_ctr_d_3_port), .CP(debug_clk), .CD(
        reset_N), .Q(net182) );
  GTECH_FD2 RX_baud_ctr_F1 ( .D(RX_baud_ctr_d_2_port), .CP(debug_clk), .CD(
        reset_N), .QN(net188) );
  GTECH_FD2 RX_baud_ctr_F1_4 ( .D(RX_baud_ctr_d_1_port), .CP(debug_clk), .CD(
        reset_N), .Q(net178) );
  GTECH_FD2 PC_U1_3_6 ( .D(PC_next_count_6_port), .CP(debug_clk), .CD(reset_N), 
        .Q(state_6_port) );
  GTECH_FD2 PC_U1_3_5 ( .D(PC_next_count_5_port), .CP(debug_clk), .CD(reset_N), 
        .Q(state_5_port) );
  GTECH_MUX8 \MUX/MX8_1_1_3  ( .D0(rd_bits[3]), .D1(rd_bits[7]), .D2(
        rd_bits[11]), .D3(rd_bits[15]), .D4(rd_bits[19]), .D5(rd_bits[23]), 
        .D6(rd_bits[27]), .D7(rd_bits[31]), .A(\addr[0] ), .B(n16), .C(n18), 
        .Z(\MUX/tmp[3][3] ) );
  GTECH_MUX8 \MUX/MX8_1_1_2  ( .D0(rd_bits[2]), .D1(rd_bits[6]), .D2(
        rd_bits[10]), .D3(rd_bits[14]), .D4(rd_bits[18]), .D5(rd_bits[22]), 
        .D6(rd_bits[26]), .D7(rd_bits[30]), .A(\addr[0] ), .B(n16), .C(n18), 
        .Z(\MUX/tmp[3][2] ) );
  GTECH_MUX8 \MUX/MX8_1_1_1  ( .D0(rd_bits[1]), .D1(rd_bits[5]), .D2(
        rd_bits[9]), .D3(rd_bits[13]), .D4(rd_bits[17]), .D5(rd_bits[21]), 
        .D6(rd_bits[25]), .D7(rd_bits[29]), .A(\addr[0] ), .B(n16), .C(n18), 
        .Z(\MUX/tmp[3][1] ) );
  GTECH_MUX8 \MUX/MX8_1_1_0  ( .D0(rd_bits[0]), .D1(rd_bits[4]), .D2(
        rd_bits[8]), .D3(rd_bits[12]), .D4(rd_bits[16]), .D5(rd_bits[20]), 
        .D6(rd_bits[24]), .D7(rd_bits[28]), .A(\addr[0] ), .B(n16), .C(n18), 
        .Z(\MUX/tmp[3][0] ) );
  GTECH_FD2 \clk_divider/U2_1  ( .D(\clk_divider/tercnt_d ), .CP(clk), .CD(
        reset_N), .Q(clk_ctr_carry) );
  GTECH_FD2 \clk_divider/U1_3_3  ( .D(\clk_divider/next_count[3] ), .CP(clk), 
        .CD(reset_N), .QN(\clk_divider/net12 ) );
  GTECH_FD2 \clk_divider/U1_3_2  ( .D(\clk_divider/next_count[2] ), .CP(clk), 
        .CD(reset_N), .QN(\clk_divider/net13 ) );
  GTECH_FD2 \clk_divider/U1_3_1  ( .D(\clk_divider/next_count[1] ), .CP(clk), 
        .CD(reset_N), .QN(\clk_divider/net14 ) );
  GTECH_FD2 \clk_divider/U1_3_0  ( .D(n81), .CP(clk), .CD(reset_N), .QN(
        \clk_divider/net15 ) );
  GTECH_NOT U3 ( .A(n295), .Z(n10) );
  GTECH_NOT U4 ( .A(n239), .Z(n11) );
  GTECH_NOT U5 ( .A(n169), .Z(n12) );
  GTECH_NOT U6 ( .A(n110), .Z(n13) );
  GTECH_NOT U7 ( .A(n109), .Z(n14) );
  GTECH_NOT U8 ( .A(n781), .Z(n15) );
  GTECH_NOT U9 ( .A(n780), .Z(n16) );
  GTECH_NOT U10 ( .A(n103), .Z(n17) );
  GTECH_NOT U11 ( .A(n779), .Z(n18) );
  GTECH_NOT U12 ( .A(n328), .Z(n19) );
  GTECH_NOT U13 ( .A(n123), .Z(n20) );
  GTECH_NOT U14 ( .A(n350), .Z(n21) );
  GTECH_NOT U15 ( .A(n383), .Z(n22) );
  GTECH_NOT U16 ( .A(n368), .Z(n23) );
  GTECH_NOT U17 ( .A(n352), .Z(n24) );
  GTECH_NOT U18 ( .A(n119), .Z(n25) );
  GTECH_NOT U19 ( .A(rx_char_1_port), .Z(n26) );
  GTECH_NOT U20 ( .A(rx_char_5_port), .Z(n27) );
  GTECH_NOT U21 ( .A(rx_char_2_port), .Z(n28) );
  GTECH_NOT U22 ( .A(n422), .Z(n29) );
  GTECH_NOT U23 ( .A(rx_char_4_port), .Z(n30) );
  GTECH_NOT U24 ( .A(rx_char_0_port), .Z(n31) );
  GTECH_NOT U25 ( .A(rx_char_3_port), .Z(n32) );
  GTECH_NOT U26 ( .A(net187), .Z(n33) );
  GTECH_NOT U27 ( .A(n125), .Z(n34) );
  GTECH_NOT U28 ( .A(rx_char_6_port), .Z(n35) );
  GTECH_NOT U29 ( .A(net130), .Z(n36) );
  GTECH_NOT U30 ( .A(n139), .Z(n37) );
  GTECH_NOT U31 ( .A(n182), .Z(n38) );
  GTECH_NOT U32 ( .A(n296), .Z(n39) );
  GTECH_NOT U33 ( .A(n282), .Z(n40) );
  GTECH_NOT U34 ( .A(n202), .Z(n41) );
  GTECH_NOT U35 ( .A(n138), .Z(n42) );
  GTECH_NOT U36 ( .A(n189), .Z(n43) );
  GTECH_NOT U37 ( .A(n280), .Z(n44) );
  GTECH_NOT U38 ( .A(n215), .Z(n45) );
  GTECH_NOT U39 ( .A(n151), .Z(n46) );
  GTECH_NOT U40 ( .A(n155), .Z(n47) );
  GTECH_NOT U41 ( .A(n152), .Z(n48) );
  GTECH_NOT U42 ( .A(state_3_port), .Z(n49) );
  GTECH_NOT U43 ( .A(\addr[0] ), .Z(n50) );
  GTECH_NOT U44 ( .A(n209), .Z(n51) );
  GTECH_NOT U45 ( .A(n203), .Z(n52) );
  GTECH_NOT U46 ( .A(n185), .Z(n53) );
  GTECH_NOT U47 ( .A(n228), .Z(n54) );
  GTECH_NOT U48 ( .A(n161), .Z(n55) );
  GTECH_NOT U49 ( .A(n200), .Z(n56) );
  GTECH_NOT U50 ( .A(n384), .Z(n57) );
  GTECH_NOT U51 ( .A(state_2_port), .Z(n58) );
  GTECH_NOT U52 ( .A(n164), .Z(n59) );
  GTECH_NOT U53 ( .A(n376), .Z(n60) );
  GTECH_NOT U54 ( .A(n216), .Z(n61) );
  GTECH_NOT U55 ( .A(n165), .Z(n62) );
  GTECH_NOT U56 ( .A(state_4_port), .Z(n63) );
  GTECH_NOT U57 ( .A(n231), .Z(n64) );
  GTECH_NOT U58 ( .A(n154), .Z(n65) );
  GTECH_NOT U59 ( .A(n145), .Z(n66) );
  GTECH_NOT U60 ( .A(n153), .Z(n67) );
  GTECH_NOT U61 ( .A(state_1_port), .Z(n68) );
  GTECH_NOT U62 ( .A(state_0_port), .Z(n69) );
  GTECH_NOT U63 ( .A(net176), .Z(n70) );
  GTECH_NOT U64 ( .A(net177), .Z(n71) );
  GTECH_NOT U65 ( .A(n361), .Z(n72) );
  GTECH_NOT U66 ( .A(n362), .Z(n73) );
  GTECH_NOT U67 ( .A(n363), .Z(n74) );
  GTECH_NOT U68 ( .A(n351), .Z(n75) );
  GTECH_NOT U69 ( .A(n360), .Z(n76) );
  GTECH_NOT U70 ( .A(n365), .Z(n77) );
  GTECH_NOT U71 ( .A(net183), .Z(n78) );
  GTECH_NOT U72 ( .A(state_6_port), .Z(n79) );
  GTECH_NOT U73 ( .A(state_5_port), .Z(n80) );
  GTECH_NOT U74 ( .A(n88), .Z(n81) );
  GTECH_NOT U75 ( .A(n90), .Z(n82) );
  GTECH_NOT U76 ( .A(\clk_divider/net13 ), .Z(n83) );
  GTECH_NOT U77 ( .A(\clk_divider/net14 ), .Z(n84) );
  GTECH_NOT U78 ( .A(clk), .Z(n85) );
  GTECH_NOT U79 ( .A(rd_bits[55]), .Z(n86) );
  GTECH_NOT U80 ( .A(rxd), .Z(n87) );
  GTECH_AND_NOT U81 ( .A(n84), .B(\clk_divider/net12 ), .Z(n89) );
  GTECH_OR_NOT U82 ( .A(n89), .B(\clk_divider/net15 ), .Z(n88) );
  GTECH_MUXI2 U83 ( .A(n88), .B(\clk_divider/net15 ), .S(\clk_divider/net14 ), 
        .Z(\clk_divider/next_count[1] ) );
  GTECH_NAND2 U84 ( .A(n88), .B(n84), .Z(n90) );
  GTECH_NOR3 U85 ( .A(\clk_divider/net14 ), .B(\clk_divider/net15 ), .C(n89), 
        .Z(n91) );
  GTECH_MUX2 U86 ( .A(n90), .B(n91), .S(\clk_divider/net13 ), .Z(
        \clk_divider/next_count[2] ) );
  GTECH_OAI2N2 U87 ( .A(\clk_divider/net12 ), .B(n82), .C(n83), .D(n91), .Z(
        \clk_divider/next_count[3] ) );
  GTECH_NOR3 U88 ( .A(\clk_divider/net12 ), .B(\clk_divider/net15 ), .C(n84), 
        .Z(\clk_divider/tercnt_d ) );
  GTECH_MUXI2 U89 ( .A(n25), .B(net50), .S(n92), .Z(wr_bits_d[9]) );
  GTECH_MUXI2 U90 ( .A(n93), .B(net51), .S(n92), .Z(wr_bits_d[8]) );
  GTECH_MUXI2 U91 ( .A(n94), .B(net52), .S(n95), .Z(wr_bits_d[7]) );
  GTECH_MUXI2 U92 ( .A(n96), .B(net53), .S(n95), .Z(wr_bits_d[6]) );
  GTECH_MUXI2 U93 ( .A(n25), .B(net54), .S(n95), .Z(wr_bits_d[5]) );
  GTECH_MUXI2 U94 ( .A(net4), .B(n94), .S(n97), .Z(wr_bits_d[55]) );
  GTECH_MUXI2 U95 ( .A(net5), .B(n96), .S(n97), .Z(wr_bits_d[54]) );
  GTECH_MUXI2 U96 ( .A(net6), .B(n25), .S(n97), .Z(wr_bits_d[53]) );
  GTECH_MUXI2 U97 ( .A(net7), .B(n93), .S(n97), .Z(wr_bits_d[52]) );
  GTECH_AND_NOT U98 ( .A(n98), .B(n99), .Z(n97) );
  GTECH_MUXI2 U99 ( .A(net8), .B(n94), .S(n100), .Z(wr_bits_d[51]) );
  GTECH_MUXI2 U100 ( .A(net9), .B(n96), .S(n100), .Z(wr_bits_d[50]) );
  GTECH_MUXI2 U101 ( .A(n93), .B(net55), .S(n95), .Z(wr_bits_d[4]) );
  GTECH_OR2 U102 ( .A(n101), .B(n102), .Z(n95) );
  GTECH_MUXI2 U103 ( .A(net10), .B(n25), .S(n100), .Z(wr_bits_d[49]) );
  GTECH_MUXI2 U104 ( .A(net11), .B(n93), .S(n100), .Z(wr_bits_d[48]) );
  GTECH_AND_NOT U105 ( .A(n103), .B(n99), .Z(n100) );
  GTECH_MUXI2 U106 ( .A(n94), .B(net12), .S(n104), .Z(wr_bits_d[47]) );
  GTECH_MUXI2 U107 ( .A(n96), .B(net13), .S(n104), .Z(wr_bits_d[46]) );
  GTECH_MUXI2 U108 ( .A(n25), .B(net14), .S(n104), .Z(wr_bits_d[45]) );
  GTECH_MUXI2 U109 ( .A(n93), .B(net15), .S(n104), .Z(wr_bits_d[44]) );
  GTECH_OR2 U110 ( .A(n101), .B(n105), .Z(n104) );
  GTECH_MUXI2 U111 ( .A(n94), .B(net16), .S(n106), .Z(wr_bits_d[43]) );
  GTECH_MUXI2 U112 ( .A(n96), .B(net17), .S(n106), .Z(wr_bits_d[42]) );
  GTECH_MUXI2 U113 ( .A(n25), .B(net18), .S(n106), .Z(wr_bits_d[41]) );
  GTECH_MUXI2 U114 ( .A(n93), .B(net19), .S(n106), .Z(wr_bits_d[40]) );
  GTECH_OR2 U115 ( .A(n107), .B(n105), .Z(n106) );
  GTECH_MUXI2 U116 ( .A(n94), .B(net56), .S(n108), .Z(wr_bits_d[3]) );
  GTECH_MUXI2 U117 ( .A(n94), .B(net20), .S(n14), .Z(wr_bits_d[39]) );
  GTECH_MUXI2 U118 ( .A(n96), .B(net21), .S(n14), .Z(wr_bits_d[38]) );
  GTECH_MUXI2 U119 ( .A(net22), .B(n25), .S(n109), .Z(wr_bits_d[37]) );
  GTECH_MUXI2 U120 ( .A(net23), .B(n93), .S(n109), .Z(wr_bits_d[36]) );
  GTECH_NOR2 U121 ( .A(n99), .B(n101), .Z(n109) );
  GTECH_MUXI2 U122 ( .A(n94), .B(net24), .S(n13), .Z(wr_bits_d[35]) );
  GTECH_MUXI2 U123 ( .A(n96), .B(net25), .S(n13), .Z(wr_bits_d[34]) );
  GTECH_MUXI2 U124 ( .A(net26), .B(n25), .S(n110), .Z(wr_bits_d[33]) );
  GTECH_MUXI2 U125 ( .A(net27), .B(n93), .S(n110), .Z(wr_bits_d[32]) );
  GTECH_NOR2 U126 ( .A(n99), .B(n107), .Z(n110) );
  GTECH_NAND2 U127 ( .A(n111), .B(n112), .Z(n99) );
  GTECH_MUXI2 U128 ( .A(net28), .B(n94), .S(n113), .Z(wr_bits_d[31]) );
  GTECH_MUXI2 U129 ( .A(net29), .B(n96), .S(n113), .Z(wr_bits_d[30]) );
  GTECH_MUXI2 U130 ( .A(n96), .B(net57), .S(n108), .Z(wr_bits_d[2]) );
  GTECH_MUXI2 U131 ( .A(net30), .B(n25), .S(n113), .Z(wr_bits_d[29]) );
  GTECH_MUXI2 U132 ( .A(net31), .B(n93), .S(n113), .Z(wr_bits_d[28]) );
  GTECH_AND_NOT U133 ( .A(n98), .B(n114), .Z(n113) );
  GTECH_MUXI2 U134 ( .A(net32), .B(n94), .S(n115), .Z(wr_bits_d[27]) );
  GTECH_MUXI2 U135 ( .A(net33), .B(n96), .S(n115), .Z(wr_bits_d[26]) );
  GTECH_MUXI2 U136 ( .A(net34), .B(n25), .S(n115), .Z(wr_bits_d[25]) );
  GTECH_MUXI2 U137 ( .A(net35), .B(n93), .S(n115), .Z(wr_bits_d[24]) );
  GTECH_NOR2 U138 ( .A(n17), .B(n114), .Z(n115) );
  GTECH_MUXI2 U139 ( .A(net173), .B(n94), .S(n116), .Z(wr_bits_d[23]) );
  GTECH_MUXI2 U140 ( .A(net37), .B(n96), .S(n116), .Z(wr_bits_d[22]) );
  GTECH_MUXI2 U141 ( .A(net38), .B(n25), .S(n116), .Z(wr_bits_d[21]) );
  GTECH_MUXI2 U142 ( .A(net39), .B(n93), .S(n116), .Z(wr_bits_d[20]) );
  GTECH_AND_NOT U143 ( .A(n98), .B(n102), .Z(n116) );
  GTECH_MUXI2 U144 ( .A(n25), .B(net58), .S(n108), .Z(wr_bits_d[1]) );
  GTECH_MUXI2 U145 ( .A(net40), .B(n94), .S(n117), .Z(wr_bits_d[19]) );
  GTECH_MUXI2 U146 ( .A(net41), .B(n96), .S(n117), .Z(wr_bits_d[18]) );
  GTECH_MUXI2 U147 ( .A(net42), .B(n25), .S(n117), .Z(wr_bits_d[17]) );
  GTECH_MUXI2 U148 ( .A(net43), .B(n93), .S(n117), .Z(wr_bits_d[16]) );
  GTECH_NOR2 U149 ( .A(n17), .B(n102), .Z(n117) );
  GTECH_MUXI2 U150 ( .A(n94), .B(net44), .S(n118), .Z(wr_bits_d[15]) );
  GTECH_MUXI2 U151 ( .A(n96), .B(net45), .S(n118), .Z(wr_bits_d[14]) );
  GTECH_MUXI2 U152 ( .A(n25), .B(net46), .S(n118), .Z(wr_bits_d[13]) );
  GTECH_MUXI2 U153 ( .A(n93), .B(net89), .S(n118), .Z(wr_bits_d[12]) );
  GTECH_OR2 U154 ( .A(n114), .B(n101), .Z(n118) );
  GTECH_NAND2 U155 ( .A(n120), .B(n112), .Z(n101) );
  GTECH_MUXI2 U156 ( .A(n94), .B(net48), .S(n92), .Z(wr_bits_d[11]) );
  GTECH_MUXI2 U157 ( .A(n96), .B(net49), .S(n92), .Z(wr_bits_d[10]) );
  GTECH_OR2 U158 ( .A(n114), .B(n107), .Z(n92) );
  GTECH_NAND3 U159 ( .A(n112), .B(n16), .C(n781), .Z(n114) );
  GTECH_MUXI2 U160 ( .A(n93), .B(net59), .S(n108), .Z(wr_bits_d[0]) );
  GTECH_OR2 U161 ( .A(n107), .B(n102), .Z(n108) );
  GTECH_NAND3 U162 ( .A(n112), .B(n780), .C(n781), .Z(n102) );
  GTECH_NAND2 U163 ( .A(n121), .B(n112), .Z(n107) );
  GTECH_AND5 U164 ( .A(n57), .B(n49), .C(n122), .D(n123), .E(n124), .Z(n112)
         );
  GTECH_XNOR2 U165 ( .A(predebug_clk_N), .B(clk_ctr_carry), .Z(
        next_predebug_clk) );
  GTECH_MUX2 U166 ( .A(net133), .B(n36), .S(n125), .Z(n803) );
  GTECH_MUXI2 U167 ( .A(net119), .B(net130), .S(n34), .Z(n802) );
  GTECH_MUXI2 U168 ( .A(net122), .B(net119), .S(n34), .Z(n801) );
  GTECH_MUXI2 U169 ( .A(net124), .B(net122), .S(n34), .Z(n800) );
  GTECH_MUXI2 U170 ( .A(net121), .B(net124), .S(n34), .Z(n799) );
  GTECH_MUXI2 U171 ( .A(net118), .B(net121), .S(n34), .Z(n798) );
  GTECH_MUXI2 U172 ( .A(net123), .B(net118), .S(n34), .Z(n797) );
  GTECH_MUXI2 U173 ( .A(net130), .B(n35), .S(n126), .Z(n796) );
  GTECH_MUXI2 U174 ( .A(n127), .B(net125), .S(n128), .Z(n794) );
  GTECH_AND_NOT U175 ( .A(n129), .B(net125), .Z(n127) );
  GTECH_MUXI2 U176 ( .A(net124), .B(n32), .S(n126), .Z(n793) );
  GTECH_MUXI2 U177 ( .A(net123), .B(n31), .S(n126), .Z(n792) );
  GTECH_MUXI2 U178 ( .A(net122), .B(n30), .S(n126), .Z(n791) );
  GTECH_MUXI2 U179 ( .A(net121), .B(n28), .S(n126), .Z(n790) );
  GTECH_MUXI2 U180 ( .A(net119), .B(n27), .S(n126), .Z(n789) );
  GTECH_MUXI2 U181 ( .A(net118), .B(n26), .S(n126), .Z(n788) );
  GTECH_NAND5 U182 ( .A(n365), .B(n76), .C(n34), .D(net183), .E(n359), .Z(n126) );
  GTECH_NOR4 U183 ( .A(n73), .B(n130), .C(n19), .D(n74), .Z(n787) );
  GTECH_AND_NOT U184 ( .A(n131), .B(n130), .Z(n786) );
  GTECH_OAI21 U185 ( .A(n75), .B(n73), .C(n132), .Z(n131) );
  GTECH_MUXI2 U186 ( .A(n133), .B(n134), .S(n74), .Z(n132) );
  GTECH_NAND2 U187 ( .A(n135), .B(n136), .Z(n134) );
  GTECH_NAND3 U188 ( .A(n361), .B(n351), .C(n137), .Z(n136) );
  GTECH_AOI222 U189 ( .A(rx_char_1_port), .B(n138), .C(n139), .D(n140), .E(n38), .F(n141), .Z(n137) );
  GTECH_NAND2 U190 ( .A(n142), .B(n143), .Z(n141) );
  GTECH_AOI222 U191 ( .A(n144), .B(n145), .C(n54), .D(n146), .E(n147), .F(n148), .Z(n143) );
  GTECH_NAND2 U192 ( .A(n149), .B(n150), .Z(n148) );
  GTECH_MUXI2 U193 ( .A(n151), .B(n152), .S(n153), .Z(n150) );
  GTECH_AOI21 U194 ( .A(n49), .B(n154), .C(n155), .Z(n149) );
  GTECH_OAI22 U195 ( .A(state_4_port), .B(n156), .C(n69), .D(n47), .Z(n146) );
  GTECH_OA21 U196 ( .A(n153), .B(n48), .C(n157), .Z(n156) );
  GTECH_OA21 U197 ( .A(n39), .B(n53), .C(n158), .Z(n142) );
  GTECH_AO21 U198 ( .A(n159), .B(n160), .C(n161), .Z(n158) );
  GTECH_AOI222 U199 ( .A(n145), .B(n162), .C(n163), .D(n164), .E(n165), .F(
        n151), .Z(n160) );
  GTECH_OA21 U200 ( .A(n57), .B(n41), .C(n166), .Z(n159) );
  GTECH_MUX2 U201 ( .A(n167), .B(n168), .S(n63), .Z(n166) );
  GTECH_OAI21 U202 ( .A(n169), .B(n170), .C(n171), .Z(n140) );
  GTECH_MUXI2 U203 ( .A(n172), .B(n173), .S(n73), .Z(n135) );
  GTECH_OAI21 U204 ( .A(n174), .B(n175), .C(n176), .Z(n173) );
  GTECH_NAND3 U205 ( .A(n177), .B(n75), .C(n178), .Z(n176) );
  GTECH_OA21 U206 ( .A(n42), .B(n28), .C(n179), .Z(n178) );
  GTECH_AO21 U207 ( .A(n180), .B(n181), .C(n182), .Z(n179) );
  GTECH_AOI222 U208 ( .A(n54), .B(n183), .C(n184), .D(n69), .E(n185), .F(n186), 
        .Z(n181) );
  GTECH_OAI21 U209 ( .A(state_2_port), .B(n41), .C(n187), .Z(n186) );
  GTECH_AND_NOT U210 ( .A(n64), .B(n163), .Z(n187) );
  GTECH_OR_NOT U211 ( .A(n144), .B(n188), .Z(n184) );
  GTECH_OAI21 U212 ( .A(n151), .B(n189), .C(n147), .Z(n188) );
  GTECH_NAND3 U213 ( .A(n190), .B(n62), .C(n191), .Z(n183) );
  GTECH_MUXI2 U214 ( .A(n68), .B(n192), .S(n48), .Z(n191) );
  GTECH_AND_NOT U215 ( .A(n154), .B(state_4_port), .Z(n192) );
  GTECH_AO21 U216 ( .A(n48), .B(n52), .C(n59), .Z(n190) );
  GTECH_AOI2N2 U217 ( .A(n155), .B(n147), .C(n193), .D(n161), .Z(n180) );
  GTECH_AND4 U218 ( .A(n194), .B(n195), .C(n196), .D(n197), .Z(n193) );
  GTECH_OA21 U219 ( .A(n67), .B(n46), .C(n198), .Z(n197) );
  GTECH_MUXI2 U220 ( .A(n199), .B(n165), .S(n49), .Z(n198) );
  GTECH_AND_NOT U221 ( .A(n63), .B(n64), .Z(n165) );
  GTECH_AND_NOT U222 ( .A(n200), .B(n68), .Z(n199) );
  GTECH_OR_NOT U223 ( .A(n63), .B(n201), .Z(n196) );
  GTECH_AO21 U224 ( .A(n58), .B(n202), .C(n203), .Z(n201) );
  GTECH_NAND3 U225 ( .A(n171), .B(n204), .C(n139), .Z(n177) );
  GTECH_NAND2 U226 ( .A(n169), .B(n170), .Z(n171) );
  GTECH_AO21 U227 ( .A(n138), .B(rx_char_5_port), .C(n361), .Z(n175) );
  GTECH_MUXI2 U228 ( .A(n138), .B(n205), .S(n38), .Z(n174) );
  GTECH_AND3 U229 ( .A(n206), .B(n207), .C(n208), .Z(n205) );
  GTECH_AOI2N2 U230 ( .A(state_1_port), .B(n144), .C(n209), .D(n53), .Z(n208)
         );
  GTECH_OAI21 U231 ( .A(n210), .B(n211), .C(n55), .Z(n207) );
  GTECH_OAI21 U232 ( .A(n49), .B(n64), .C(n212), .Z(n211) );
  GTECH_AO21 U233 ( .A(n63), .B(n153), .C(n45), .Z(n212) );
  GTECH_MUXI2 U234 ( .A(n59), .B(state_2_port), .S(state_1_port), .Z(n210) );
  GTECH_OAI21 U235 ( .A(n213), .B(n214), .C(n54), .Z(n206) );
  GTECH_OAI2N2 U236 ( .A(n59), .B(n51), .C(n63), .D(n215), .Z(n214) );
  GTECH_OAI21 U237 ( .A(n216), .B(n49), .C(n217), .Z(n213) );
  GTECH_AOI21 U238 ( .A(state_1_port), .B(n152), .C(n218), .Z(n217) );
  GTECH_MUX2 U239 ( .A(n219), .B(n220), .S(n72), .Z(n172) );
  GTECH_AOI222 U240 ( .A(n221), .B(n139), .C(rx_char_3_port), .D(n138), .E(n38), .F(n222), .Z(n220) );
  GTECH_NAND2 U241 ( .A(n223), .B(n224), .Z(n222) );
  GTECH_OA21 U242 ( .A(n225), .B(n53), .C(n226), .Z(n224) );
  GTECH_OA21 U243 ( .A(n227), .B(n228), .C(n229), .Z(n226) );
  GTECH_NAND4 U244 ( .A(n147), .B(n66), .C(n67), .D(n49), .Z(n229) );
  GTECH_AOI222 U245 ( .A(n189), .B(n65), .C(n230), .D(n63), .E(n231), .F(n200), 
        .Z(n227) );
  GTECH_OA21 U246 ( .A(state_3_port), .B(state_1_port), .C(n232), .Z(n225) );
  GTECH_AND_NOT U247 ( .A(n168), .B(n231), .Z(n232) );
  GTECH_AOI2N2 U248 ( .A(n68), .B(n144), .C(n233), .D(n161), .Z(n223) );
  GTECH_AND4 U249 ( .A(n168), .B(n234), .C(n40), .D(n235), .Z(n233) );
  GTECH_OA21 U250 ( .A(state_4_port), .B(n67), .C(n236), .Z(n235) );
  GTECH_OR3 U251 ( .A(state_1_port), .B(state_3_port), .C(n237), .Z(n236) );
  GTECH_AND_NOT U252 ( .A(n238), .B(n11), .Z(n221) );
  GTECH_OA21 U253 ( .A(n239), .B(n37), .C(n240), .Z(n219) );
  GTECH_AOI2N2 U254 ( .A(n138), .B(rx_char_6_port), .C(n241), .D(n182), .Z(
        n240) );
  GTECH_AOI222 U255 ( .A(n55), .B(n242), .C(n243), .D(n215), .E(n54), .F(n244), 
        .Z(n241) );
  GTECH_OAI21 U256 ( .A(n231), .B(n245), .C(n246), .Z(n244) );
  GTECH_OAI21 U257 ( .A(state_3_port), .B(n247), .C(n248), .Z(n246) );
  GTECH_AND_NOT U258 ( .A(n66), .B(n153), .Z(n248) );
  GTECH_XNOR2 U259 ( .A(n249), .B(n63), .Z(n247) );
  GTECH_OR_NOT U260 ( .A(n64), .B(n58), .Z(n249) );
  GTECH_OA21 U261 ( .A(n58), .B(n63), .C(n250), .Z(n245) );
  GTECH_AND_NOT U262 ( .A(n48), .B(n215), .Z(n250) );
  GTECH_AND_NOT U263 ( .A(n185), .B(n154), .Z(n243) );
  GTECH_NAND4 U264 ( .A(n251), .B(n252), .C(n52), .D(n195), .Z(n242) );
  GTECH_OR3 U265 ( .A(state_3_port), .B(state_4_port), .C(n65), .Z(n195) );
  GTECH_OR3 U266 ( .A(n63), .B(state_0_port), .C(n45), .Z(n252) );
  GTECH_MUXI2 U267 ( .A(n162), .B(n253), .S(n68), .Z(n251) );
  GTECH_OR_NOT U268 ( .A(n164), .B(n41), .Z(n253) );
  GTECH_OR_NOT U269 ( .A(n200), .B(n48), .Z(n162) );
  GTECH_OAI21 U270 ( .A(n254), .B(n255), .C(n256), .Z(n133) );
  GTECH_AND_NOT U271 ( .A(n257), .B(n362), .Z(n256) );
  GTECH_NAND3 U272 ( .A(n258), .B(n75), .C(n259), .Z(n257) );
  GTECH_AOI2N2 U273 ( .A(n239), .B(n139), .C(n42), .D(n30), .Z(n259) );
  GTECH_OAI21 U274 ( .A(n260), .B(n261), .C(n38), .Z(n258) );
  GTECH_OAI2N2 U275 ( .A(n53), .B(n168), .C(n155), .D(n147), .Z(n261) );
  GTECH_OR_NOT U276 ( .A(n41), .B(state_1_port), .Z(n168) );
  GTECH_OAI21 U277 ( .A(n262), .B(n49), .C(n263), .Z(n260) );
  GTECH_OA21 U278 ( .A(n61), .B(n264), .C(n265), .Z(n263) );
  GTECH_NAND3 U279 ( .A(n55), .B(n68), .C(n237), .Z(n265) );
  GTECH_AND2 U280 ( .A(n266), .B(state_0_port), .Z(n237) );
  GTECH_AOI21 U281 ( .A(state_2_port), .B(state_4_port), .C(n200), .Z(n266) );
  GTECH_OAI21 U282 ( .A(n163), .B(n152), .C(n54), .Z(n264) );
  GTECH_AND_NOT U283 ( .A(n49), .B(n52), .Z(n163) );
  GTECH_AOI222 U284 ( .A(n154), .B(n54), .C(n267), .D(n268), .E(n231), .F(n185), .Z(n262) );
  GTECH_XNOR2 U285 ( .A(n200), .B(state_0_port), .Z(n268) );
  GTECH_AND_NOT U286 ( .A(n269), .B(n161), .Z(n267) );
  GTECH_OAI2N2 U287 ( .A(n63), .B(n52), .C(n68), .D(n200), .Z(n269) );
  GTECH_AO21 U288 ( .A(n138), .B(rx_char_0_port), .C(n72), .Z(n255) );
  GTECH_OAI21 U289 ( .A(n270), .B(n37), .C(n271), .Z(n254) );
  GTECH_AO21 U290 ( .A(n272), .B(n273), .C(n182), .Z(n271) );
  GTECH_AOI222 U291 ( .A(n55), .B(n274), .C(n147), .D(n275), .E(n144), .F(n69), 
        .Z(n273) );
  GTECH_AND_NOT U292 ( .A(n276), .B(n277), .Z(n144) );
  GTECH_OAI21 U293 ( .A(state_0_port), .B(n58), .C(n278), .Z(n275) );
  GTECH_AOI21 U294 ( .A(n49), .B(n209), .C(n218), .Z(n278) );
  GTECH_AND2 U295 ( .A(n54), .B(state_4_port), .Z(n147) );
  GTECH_OR4 U296 ( .A(n230), .B(n218), .C(n279), .D(n44), .Z(n274) );
  GTECH_AOI222 U297 ( .A(n203), .B(n164), .C(n189), .D(n231), .E(n154), .F(
        n200), .Z(n280) );
  GTECH_OAI21 U298 ( .A(state_1_port), .B(n40), .C(n281), .Z(n279) );
  GTECH_OR3 U299 ( .A(n49), .B(n63), .C(n67), .Z(n281) );
  GTECH_AND_NOT U300 ( .A(state_3_port), .B(n52), .Z(n218) );
  GTECH_OR2 U301 ( .A(n276), .B(n277), .Z(n161) );
  GTECH_OA22 U302 ( .A(n283), .B(n53), .C(n284), .D(n228), .Z(n272) );
  GTECH_NAND2 U303 ( .A(n277), .B(n276), .Z(n228) );
  GTECH_AND4 U304 ( .A(n285), .B(n47), .C(n286), .D(n287), .Z(n284) );
  GTECH_AOI222 U305 ( .A(n69), .B(n49), .C(n153), .D(n200), .E(n215), .F(n63), 
        .Z(n287) );
  GTECH_OR_NOT U306 ( .A(n64), .B(state_2_port), .Z(n286) );
  GTECH_AND_NOT U307 ( .A(n69), .B(state_1_port), .Z(n231) );
  GTECH_AO21 U308 ( .A(n66), .B(n59), .C(n48), .Z(n285) );
  GTECH_AND_NOT U309 ( .A(n58), .B(n49), .Z(n152) );
  GTECH_AND2 U310 ( .A(n288), .B(n42), .Z(n139) );
  GTECH_OA21 U311 ( .A(n283), .B(n39), .C(n182), .Z(n288) );
  GTECH_OAI21 U312 ( .A(n289), .B(n53), .C(n42), .Z(n182) );
  GTECH_OR_NOT U313 ( .A(n122), .B(n290), .Z(n138) );
  GTECH_NAND3 U314 ( .A(n43), .B(n63), .C(n291), .Z(n290) );
  GTECH_AND_NOT U315 ( .A(n277), .B(n276), .Z(n185) );
  GTECH_OA21 U316 ( .A(n63), .B(n80), .C(n79), .Z(n276) );
  GTECH_OA21 U317 ( .A(n80), .B(n56), .C(n79), .Z(n277) );
  GTECH_OA21 U318 ( .A(n52), .B(n292), .C(n293), .Z(n283) );
  GTECH_AND_NOT U319 ( .A(n294), .B(n230), .Z(n293) );
  GTECH_AND2 U320 ( .A(n153), .B(state_2_port), .Z(n230) );
  GTECH_AND_NOT U321 ( .A(n69), .B(n68), .Z(n153) );
  GTECH_AO21 U322 ( .A(n46), .B(n51), .C(state_0_port), .Z(n294) );
  GTECH_AOI21 U323 ( .A(n239), .B(n10), .C(n170), .Z(n270) );
  GTECH_AND2 U324 ( .A(n295), .B(n11), .Z(n170) );
  GTECH_AOI2N2 U325 ( .A(n16), .B(n296), .C(n296), .D(n297), .Z(n295) );
  GTECH_AOI222 U326 ( .A(\MUX/tmp[3][0] ), .B(n781), .C(n298), .D(n299), .E(
        n111), .F(n300), .Z(n297) );
  GTECH_NAND2 U327 ( .A(n301), .B(n302), .Z(n300) );
  GTECH_AOI22 U328 ( .A(rd_bits[36]), .B(n120), .C(rd_bits[32]), .D(n121), .Z(
        n302) );
  GTECH_AOI22 U329 ( .A(rd_bits[48]), .B(n103), .C(rd_bits[52]), .D(n98), .Z(
        n301) );
  GTECH_MUX2 U330 ( .A(rd_bits[44]), .B(rd_bits[40]), .S(n50), .Z(n298) );
  GTECH_OAI21 U331 ( .A(n204), .B(n12), .C(n238), .Z(n239) );
  GTECH_AND3 U332 ( .A(n303), .B(n39), .C(n304), .Z(n238) );
  GTECH_MUX2 U333 ( .A(\MUX/tmp[3][3] ), .B(n305), .S(n15), .Z(n304) );
  GTECH_AND2 U334 ( .A(n306), .B(n307), .Z(n305) );
  GTECH_OAI21 U335 ( .A(n18), .B(n308), .C(n16), .Z(n307) );
  GTECH_MUXI2 U336 ( .A(rd_bits[47]), .B(rd_bits[43]), .S(n50), .Z(n308) );
  GTECH_AOI2N2 U337 ( .A(n86), .B(n98), .C(rd_bits[51]), .D(n17), .Z(n306) );
  GTECH_NAND3 U338 ( .A(n111), .B(n779), .C(n309), .Z(n303) );
  GTECH_MUXI2 U339 ( .A(rd_bits[39]), .B(rd_bits[35]), .S(n50), .Z(n309) );
  GTECH_OA22 U340 ( .A(n779), .B(n39), .C(n296), .D(n310), .Z(n169) );
  GTECH_AOI222 U341 ( .A(\MUX/tmp[3][1] ), .B(n781), .C(n311), .D(n299), .E(
        n111), .F(n312), .Z(n310) );
  GTECH_NAND2 U342 ( .A(n313), .B(n314), .Z(n312) );
  GTECH_AOI22 U343 ( .A(rd_bits[37]), .B(n120), .C(rd_bits[33]), .D(n121), .Z(
        n314) );
  GTECH_AOI22 U344 ( .A(rd_bits[49]), .B(n103), .C(rd_bits[53]), .D(n98), .Z(
        n313) );
  GTECH_MUX2 U345 ( .A(rd_bits[45]), .B(rd_bits[41]), .S(n50), .Z(n311) );
  GTECH_MUXI2 U346 ( .A(n781), .B(n315), .S(n39), .Z(n204) );
  GTECH_NAND3 U347 ( .A(n316), .B(n157), .C(n167), .Z(n296) );
  GTECH_OR_NOT U348 ( .A(n47), .B(n69), .Z(n167) );
  GTECH_OR_NOT U349 ( .A(n66), .B(n49), .Z(n157) );
  GTECH_AOI222 U350 ( .A(\MUX/tmp[3][2] ), .B(n781), .C(n317), .D(n299), .E(
        n111), .F(n318), .Z(n315) );
  GTECH_NAND2 U351 ( .A(n319), .B(n320), .Z(n318) );
  GTECH_AOI22 U352 ( .A(rd_bits[38]), .B(n120), .C(rd_bits[34]), .D(n121), .Z(
        n320) );
  GTECH_AND2 U353 ( .A(n779), .B(n50), .Z(n121) );
  GTECH_AND_NOT U354 ( .A(n779), .B(n50), .Z(n120) );
  GTECH_AOI22 U355 ( .A(rd_bits[50]), .B(n103), .C(rd_bits[54]), .D(n98), .Z(
        n319) );
  GTECH_AND_NOT U356 ( .A(\addr[0] ), .B(n779), .Z(n98) );
  GTECH_AND_NOT U357 ( .A(n18), .B(\addr[0] ), .Z(n103) );
  GTECH_AND2 U358 ( .A(n780), .B(n15), .Z(n111) );
  GTECH_NOR2 U359 ( .A(n18), .B(n105), .Z(n299) );
  GTECH_OR_NOT U360 ( .A(n781), .B(n16), .Z(n105) );
  GTECH_MUX2 U361 ( .A(rd_bits[46]), .B(rd_bits[42]), .S(n50), .Z(n317) );
  GTECH_MUX2 U362 ( .A(n18), .B(n119), .S(n321), .Z(n784) );
  GTECH_MUXI2 U363 ( .A(n780), .B(n93), .S(n321), .Z(n783) );
  GTECH_MUXI2 U364 ( .A(n781), .B(n96), .S(n321), .Z(n782) );
  GTECH_AND4 U365 ( .A(n282), .B(n124), .C(n322), .D(n21), .Z(n321) );
  GTECH_OA21 U366 ( .A(n291), .B(n122), .C(n323), .Z(n322) );
  GTECH_AO21 U367 ( .A(n58), .B(state_1_port), .C(n203), .Z(n323) );
  GTECH_AND_NOT U368 ( .A(n63), .B(n41), .Z(n282) );
  GTECH_MUXI2 U369 ( .A(predebug_clk_N), .B(n85), .S(div_bypass_mode), .Z(
        debug_clk) );
  GTECH_OR_NOT U370 ( .A(n124), .B(net68), .Z(advance) );
  GTECH_XNOR2 U371 ( .A(n69), .B(state_2_port), .Z(\addr[0] ) );
  GTECH_XNOR2 U372 ( .A(net47), .B(n324), .Z(TX_n151) );
  GTECH_OAI21 U373 ( .A(n362), .B(n325), .C(n326), .Z(TX_bit_ctr_d_3_port) );
  GTECH_MUXI2 U374 ( .A(n327), .B(n328), .S(n72), .Z(n326) );
  GTECH_AND_NOT U375 ( .A(n325), .B(n75), .Z(n327) );
  GTECH_MUXI2 U376 ( .A(n363), .B(n329), .S(n325), .Z(TX_bit_ctr_d_2_port) );
  GTECH_OR2 U377 ( .A(n330), .B(n362), .Z(n329) );
  GTECH_MUXI2 U378 ( .A(n351), .B(n363), .S(n325), .Z(TX_bit_ctr_d_1_port) );
  GTECH_OAI21 U379 ( .A(n361), .B(n325), .C(n19), .Z(TX_bit_ctr_d_0_port) );
  GTECH_AND2 U380 ( .A(n325), .B(n75), .Z(n328) );
  GTECH_AND2 U381 ( .A(n331), .B(net47), .Z(n325) );
  GTECH_AOI21 U382 ( .A(n130), .B(n330), .C(n324), .Z(n331) );
  GTECH_AND4 U383 ( .A(n363), .B(n351), .C(n72), .D(n73), .Z(n330) );
  GTECH_OAI21 U384 ( .A(n332), .B(n333), .C(net68), .Z(n130) );
  GTECH_OAI2N2 U385 ( .A(state_0_port), .B(n63), .C(n61), .D(state_3_port), 
        .Z(n333) );
  GTECH_OAI21 U386 ( .A(n291), .B(n122), .C(n334), .Z(n332) );
  GTECH_AO21 U387 ( .A(n292), .B(n43), .C(state_6_port), .Z(n334) );
  GTECH_AND_NOT U388 ( .A(n80), .B(n79), .Z(n122) );
  GTECH_XNOR2 U389 ( .A(n354), .B(net176), .Z(TX_baud_ctr_d_3_port) );
  GTECH_AND_NOT U390 ( .A(n324), .B(net177), .Z(TX_baud_ctr_d_1_port) );
  GTECH_NAND4 U391 ( .A(net36), .B(n354), .C(n70), .D(n71), .Z(n324) );
  GTECH_OR_NOT U392 ( .A(n124), .B(n335), .Z(RX_val250_1_port) );
  GTECH_OR3 U393 ( .A(n336), .B(n337), .C(n125), .Z(n335) );
  GTECH_AND5 U394 ( .A(n365), .B(n78), .C(net133), .D(n360), .E(n359), .Z(n336) );
  GTECH_OAI22 U395 ( .A(n338), .B(n339), .C(n359), .D(n33), .Z(
        RX_bit_ctr_d_3_port) );
  GTECH_XNOR2 U396 ( .A(n360), .B(net183), .Z(n338) );
  GTECH_OAI2N2 U397 ( .A(n359), .B(n339), .C(n77), .D(net187), .Z(
        RX_bit_ctr_d_2_port) );
  GTECH_OAI2N2 U398 ( .A(n365), .B(n339), .C(net183), .D(net187), .Z(
        RX_bit_ctr_d_1_port) );
  GTECH_OAI2N2 U399 ( .A(n78), .B(n339), .C(n76), .D(net187), .Z(
        RX_bit_ctr_d_0_port) );
  GTECH_OR_NOT U400 ( .A(n337), .B(n33), .Z(n339) );
  GTECH_MUX2 U401 ( .A(RX_baud_ctr_d_0_port), .B(n340), .S(net167), .Z(
        RX_baud_ctr_d_3_port) );
  GTECH_AND_NOT U402 ( .A(n128), .B(net178), .Z(n340) );
  GTECH_AND2 U403 ( .A(net182), .B(n128), .Z(RX_baud_ctr_d_2_port) );
  GTECH_AND_NOT U404 ( .A(n128), .B(net188), .Z(RX_baud_ctr_d_1_port) );
  GTECH_AND2 U405 ( .A(net178), .B(n128), .Z(RX_baud_ctr_d_0_port) );
  GTECH_AND2 U406 ( .A(n341), .B(n129), .Z(n128) );
  GTECH_XNOR2 U407 ( .A(net133), .B(net211), .Z(n129) );
  GTECH_OR4 U408 ( .A(net167), .B(net178), .C(net182), .D(net188), .Z(n341) );
  GTECH_MUXI2 U409 ( .A(n342), .B(n343), .S(n344), .Z(PC_next_count_6_port) );
  GTECH_XNOR2 U410 ( .A(state_6_port), .B(PC_U4_carry_6_port), .Z(n343) );
  GTECH_AND3 U411 ( .A(n345), .B(n20), .C(n346), .Z(n342) );
  GTECH_OA21 U412 ( .A(n347), .B(n41), .C(n348), .Z(n346) );
  GTECH_MUXI2 U413 ( .A(n349), .B(n24), .S(n350), .Z(n348) );
  GTECH_AND_NOT U414 ( .A(n353), .B(state_6_port), .Z(n349) );
  GTECH_OAI21 U415 ( .A(state_0_port), .B(n355), .C(n66), .Z(n353) );
  GTECH_AND_NOT U416 ( .A(n68), .B(n69), .Z(n145) );
  GTECH_OAI21 U417 ( .A(n23), .B(n57), .C(n356), .Z(n345) );
  GTECH_MUX2 U418 ( .A(n357), .B(PC_count_inc_5_port), .S(n344), .Z(
        PC_next_count_5_port) );
  GTECH_NAND2 U419 ( .A(n358), .B(n364), .Z(n357) );
  GTECH_OAI21 U420 ( .A(n69), .B(n366), .C(n367), .Z(n364) );
  GTECH_AO21 U421 ( .A(n368), .B(n155), .C(n347), .Z(n366) );
  GTECH_AND_NOT U422 ( .A(n49), .B(n57), .Z(n155) );
  GTECH_AOI21 U423 ( .A(n369), .B(n21), .C(n370), .Z(n358) );
  GTECH_AO21 U424 ( .A(n69), .B(n355), .C(n371), .Z(n369) );
  GTECH_AND3 U425 ( .A(n291), .B(state_1_port), .C(n200), .Z(n371) );
  GTECH_MUX2 U426 ( .A(n372), .B(PC_count_inc_4_port), .S(n344), .Z(
        PC_next_count_4_port) );
  GTECH_NAND2 U427 ( .A(n373), .B(n374), .Z(n372) );
  GTECH_OA21 U428 ( .A(n21), .B(n22), .C(n375), .Z(n374) );
  GTECH_OA21 U429 ( .A(n376), .B(n292), .C(n377), .Z(n375) );
  GTECH_OA21 U430 ( .A(n58), .B(n41), .C(n378), .Z(n373) );
  GTECH_MUX2 U431 ( .A(n379), .B(PC_count_inc_3_port), .S(n344), .Z(
        PC_next_count_3_port) );
  GTECH_NAND4 U432 ( .A(n352), .B(n380), .C(n381), .D(n382), .Z(n379) );
  GTECH_AOI2N2 U433 ( .A(state_2_port), .B(n383), .C(n59), .D(n368), .Z(n382)
         );
  GTECH_OR_NOT U434 ( .A(n384), .B(n385), .Z(n381) );
  GTECH_AO21 U435 ( .A(n80), .B(n202), .C(n356), .Z(n385) );
  GTECH_MUX2 U436 ( .A(n386), .B(PC_count_inc_2_port), .S(n344), .Z(
        PC_next_count_2_port) );
  GTECH_NAND2 U437 ( .A(n387), .B(n388), .Z(n386) );
  GTECH_OA21 U438 ( .A(state_5_port), .B(n22), .C(n389), .Z(n388) );
  GTECH_MUX2 U439 ( .A(n390), .B(PC_count_inc_1_port), .S(n344), .Z(
        PC_next_count_1_port) );
  GTECH_NAND2 U440 ( .A(n387), .B(n391), .Z(n390) );
  GTECH_OA21 U441 ( .A(n347), .B(n41), .C(n380), .Z(n391) );
  GTECH_AND_NOT U442 ( .A(n58), .B(n80), .Z(n347) );
  GTECH_AND2 U443 ( .A(n392), .B(n393), .Z(n387) );
  GTECH_OA21 U444 ( .A(n367), .B(n41), .C(n394), .Z(n392) );
  GTECH_OR3 U445 ( .A(n370), .B(n355), .C(n350), .Z(n394) );
  GTECH_MUX2 U446 ( .A(n395), .B(PC_count_inc_0_port), .S(n344), .Z(
        PC_next_count_0_port) );
  GTECH_AOI21 U447 ( .A(n396), .B(n124), .C(n370), .Z(n344) );
  GTECH_AND3 U448 ( .A(n337), .B(n34), .C(net133), .Z(n124) );
  GTECH_OR5 U449 ( .A(net182), .B(net188), .C(net178), .D(net125), .E(net167), 
        .Z(n125) );
  GTECH_NOR4 U450 ( .A(n77), .B(n359), .C(n360), .D(net183), .Z(n337) );
  GTECH_OAI2N2 U451 ( .A(n397), .B(state_5_port), .C(n398), .D(n291), .Z(n396)
         );
  GTECH_AND2 U452 ( .A(state_5_port), .B(n79), .Z(n291) );
  GTECH_NAND3 U453 ( .A(n399), .B(n400), .C(n401), .Z(n398) );
  GTECH_OAI21 U454 ( .A(n402), .B(n403), .C(n63), .Z(n401) );
  GTECH_OAI2N2 U455 ( .A(n51), .B(n22), .C(n69), .D(n215), .Z(n403) );
  GTECH_OAI21 U456 ( .A(n21), .B(n194), .C(n404), .Z(n402) );
  GTECH_OR3 U457 ( .A(n46), .B(n65), .C(n368), .Z(n404) );
  GTECH_AND_NOT U458 ( .A(state_2_port), .B(n49), .Z(n151) );
  GTECH_OR3 U459 ( .A(n367), .B(n289), .C(n61), .Z(n400) );
  GTECH_AND_NOT U460 ( .A(n63), .B(n69), .Z(n216) );
  GTECH_AND2 U461 ( .A(n234), .B(n316), .Z(n289) );
  GTECH_NAND2 U462 ( .A(n209), .B(state_3_port), .Z(n316) );
  GTECH_OR_NOT U463 ( .A(n57), .B(state_3_port), .Z(n234) );
  GTECH_AND_NOT U464 ( .A(state_1_port), .B(n58), .Z(n384) );
  GTECH_OR3 U465 ( .A(n56), .B(n49), .C(n65), .Z(n399) );
  GTECH_AND_NOT U466 ( .A(n58), .B(state_4_port), .Z(n200) );
  GTECH_OA22 U467 ( .A(n405), .B(n60), .C(n406), .D(n79), .Z(n397) );
  GTECH_OA22 U468 ( .A(n65), .B(n45), .C(n21), .D(n292), .Z(n406) );
  GTECH_OR_NOT U469 ( .A(n69), .B(n49), .Z(n292) );
  GTECH_AND_NOT U470 ( .A(n49), .B(n58), .Z(n215) );
  GTECH_OA21 U471 ( .A(n69), .B(n407), .C(n65), .Z(n405) );
  GTECH_AND_NOT U472 ( .A(state_1_port), .B(n69), .Z(n154) );
  GTECH_MUXI2 U473 ( .A(n408), .B(n350), .S(n51), .Z(n407) );
  GTECH_AND_NOT U474 ( .A(n68), .B(state_2_port), .Z(n209) );
  GTECH_OR_NOT U475 ( .A(n368), .B(n367), .Z(n408) );
  GTECH_NAND4 U476 ( .A(n409), .B(n389), .C(n378), .D(n393), .Z(n395) );
  GTECH_AND4 U477 ( .A(n20), .B(n377), .C(n410), .D(n411), .Z(n393) );
  GTECH_AOI22 U478 ( .A(n189), .B(n356), .C(n164), .D(n23), .Z(n411) );
  GTECH_AND2 U479 ( .A(n60), .B(n80), .Z(n356) );
  GTECH_AND_NOT U480 ( .A(n49), .B(state_2_port), .Z(n189) );
  GTECH_OR3 U481 ( .A(n69), .B(n376), .C(n52), .Z(n410) );
  GTECH_OR3 U482 ( .A(n23), .B(n21), .C(n352), .Z(n377) );
  GTECH_OR2 U483 ( .A(n370), .B(n367), .Z(n352) );
  GTECH_AND3 U484 ( .A(n49), .B(n80), .C(n376), .Z(n370) );
  GTECH_AND_NOT U485 ( .A(n63), .B(n79), .Z(n376) );
  GTECH_AND_NOT U486 ( .A(n21), .B(n59), .Z(n123) );
  GTECH_AND_NOT U487 ( .A(state_0_port), .B(n63), .Z(n164) );
  GTECH_MUXI2 U488 ( .A(n412), .B(n413), .S(n21), .Z(n378) );
  GTECH_OAI21 U489 ( .A(state_1_port), .B(n41), .C(n414), .Z(n413) );
  GTECH_OR3 U490 ( .A(state_3_port), .B(state_6_port), .C(n355), .Z(n414) );
  GTECH_NOR4 U491 ( .A(n119), .B(n96), .C(n94), .D(n93), .Z(n355) );
  GTECH_OA21 U492 ( .A(n31), .B(n30), .C(n415), .Z(n93) );
  GTECH_AND2 U493 ( .A(n416), .B(n417), .Z(n415) );
  GTECH_AND5 U494 ( .A(n418), .B(n416), .C(n419), .D(n417), .E(n32), .Z(n94)
         );
  GTECH_OR_NOT U495 ( .A(rx_char_0_port), .B(n420), .Z(n417) );
  GTECH_OA21 U496 ( .A(n26), .B(n419), .C(n28), .Z(n96) );
  GTECH_NAND3 U497 ( .A(n418), .B(n416), .C(n421), .Z(n119) );
  GTECH_MUX2 U498 ( .A(n30), .B(n419), .S(n26), .Z(n421) );
  GTECH_OR3 U499 ( .A(n29), .B(rx_char_0_port), .C(n26), .Z(n416) );
  GTECH_OR_NOT U500 ( .A(n31), .B(n420), .Z(n418) );
  GTECH_AND2 U501 ( .A(rx_char_2_port), .B(n422), .Z(n420) );
  GTECH_AND_NOT U502 ( .A(n202), .B(n367), .Z(n412) );
  GTECH_AND5 U503 ( .A(n30), .B(n35), .C(n423), .D(n424), .E(n425), .Z(n367)
         );
  GTECH_AO21 U504 ( .A(n31), .B(rx_char_3_port), .C(n26), .Z(n425) );
  GTECH_OR_NOT U505 ( .A(rx_char_0_port), .B(n426), .Z(n423) );
  GTECH_AO21 U506 ( .A(n27), .B(n26), .C(rx_char_2_port), .Z(n426) );
  GTECH_OA21 U507 ( .A(n58), .B(n380), .C(n194), .Z(n389) );
  GTECH_NAND2 U508 ( .A(n202), .B(n203), .Z(n194) );
  GTECH_AND_NOT U509 ( .A(n68), .B(n58), .Z(n203) );
  GTECH_NAND3 U510 ( .A(state_5_port), .B(state_0_port), .C(n23), .Z(n380) );
  GTECH_MUXI2 U511 ( .A(n427), .B(n428), .S(n350), .Z(n409) );
  GTECH_OAI21 U512 ( .A(n429), .B(n32), .C(n430), .Z(n350) );
  GTECH_OAI21 U513 ( .A(n29), .B(n431), .C(n432), .Z(n430) );
  GTECH_AND2 U514 ( .A(n419), .B(n433), .Z(n432) );
  GTECH_OR3 U515 ( .A(n30), .B(rx_char_6_port), .C(n27), .Z(n433) );
  GTECH_OR3 U516 ( .A(n29), .B(rx_char_2_port), .C(n31), .Z(n419) );
  GTECH_AO21 U517 ( .A(rx_char_0_port), .B(rx_char_1_port), .C(n429), .Z(n431)
         );
  GTECH_AND_NOT U518 ( .A(n30), .B(n434), .Z(n422) );
  GTECH_AND_NOT U519 ( .A(n383), .B(state_5_port), .Z(n428) );
  GTECH_AND_NOT U520 ( .A(n368), .B(n41), .Z(n383) );
  GTECH_NAND3 U521 ( .A(n424), .B(n429), .C(n435), .Z(n368) );
  GTECH_MUXI2 U522 ( .A(n434), .B(n436), .S(n30), .Z(n435) );
  GTECH_AO21 U523 ( .A(n27), .B(n31), .C(rx_char_6_port), .Z(n436) );
  GTECH_NAND2 U524 ( .A(rx_char_6_port), .B(n32), .Z(n434) );
  GTECH_AND2 U525 ( .A(n26), .B(n28), .Z(n429) );
  GTECH_MUXI2 U526 ( .A(rx_char_0_port), .B(rx_char_5_port), .S(rx_char_3_port), .Z(n424) );
  GTECH_AND_NOT U527 ( .A(n202), .B(n58), .Z(n427) );
  GTECH_AND_NOT U528 ( .A(state_0_port), .B(n49), .Z(n202) );
endmodule


module DW_debugger_inst ( clk, resetn, rd_bits, wr_bits, rxd, txd, div_bypass
 );
  input [55:0] rd_bits;
  output [55:0] wr_bits;
  input clk, resetn, rxd, div_bypass;
  output txd;


  DW_debugger_inst_DW_debugger_0 Debug ( .clk(clk), .reset_N(resetn), 
        .rd_bits(rd_bits), .rxd(rxd), .wr_bits(wr_bits), .txd(txd), 
        .div_bypass_mode(div_bypass) );
endmodule

