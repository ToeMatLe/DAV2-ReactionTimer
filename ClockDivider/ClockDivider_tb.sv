`timescale 1ns/1ps

module Clock_Divider_tb;

  // Make DIVISOR small for faster sim, but still test behavior
  localparam int DIVISOR = 5;  // try 20 for quick simulation

  logic clk_in = 0;
  logic rst;
  logic clk_out;

  Clock_Divider #(.DIVISOR(DIVISOR)) dut (
    .clk_in (clk_in),
    .rst    (rst),
    .clk_out(clk_out)
  );

  // 100 MHz clock => 10 ns period
  always #5 clk_in = ~clk_in;

  // Reset sequence, this gives the design time to stabilize.
  initial begin
    rst = 1;
    repeat (3) @(posedge clk_in);
    rst = 0;
  end

  // Count input cycles between clk_out rising edges
  int cycle_count = 0;

  always @(posedge clk_in) begin
    if (rst) cycle_count <= 0;
    else cycle_count <= cycle_count + 1;
  end

  // On each rising edge of clk_out, check the period
  // Since clk_out toggles every DIVISOR cycles, a full period is 2*DIVISOR cycles.
  int last_cycle_count = -1;

  always @(posedge clk_out) begin
    if (!rst) begin
      if (last_cycle_count == -1) begin
        // first edge after reset: just initialize
        last_cycle_count = cycle_count;
      end else begin
        int delta = cycle_count - last_cycle_count;
        $display("[%0t ns] clk_out posedge, cycles since last posedge = %0d (expected %0d)", $time, delta, 2*DIVISOR);

        // Assert the output period is correct
        assert (delta == 2*DIVISOR)
          else $fatal(1, "FAIL: Expected %0d cycles per clk_out period, got %0d",
                      2*DIVISOR, delta);

        last_cycle_count = cycle_count;
      end
    end
  end

  // End sim after a few output periods
  initial begin
    // 1000ns is the limit for this tcl file
    repeat (1000) @(posedge clk_in);
    $display("PASS: Clock divider behaved as expected.");
    $finish;
  end

endmodule
