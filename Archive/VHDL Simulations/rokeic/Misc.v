// To hold clk, reset and all other misc. items

`timescale 1us / 100ps


// A small async assert sync deassert reset block with scan bypass

module reset_async_sync (
    sync_resetn,
    clk,
    scan_bypass,
    resetn
  );

    input	clk;
    input	resetn;
    input	scan_bypass;
    output	sync_resetn;

    wire	clk;
    wire	resetn;
    wire	scan_bypass;
    wire	sync_resetn;
    wire	sync_resetn_pre;
    reg		sync_resetn_mid;

    assign sync_resetn = (scan_bypass) ? resetn : sync_resetn_pre;
    assign sync_resetn_pre = (~resetn) ? 1'b0 : sync_resetn_mid;

    always@(posedge clk)
    begin: RESET_SYNC
	if (resetn == 1'b0) begin
	    sync_resetn_mid <= 1'b0;
	end
	else if (resetn == 1'b1) begin
	    sync_resetn_mid <= 1'b1;
	end   
    end

endmodule

