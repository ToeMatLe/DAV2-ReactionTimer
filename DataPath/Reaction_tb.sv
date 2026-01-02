//======================================================
// tb_DataPath.sv
// Simple testbench for your DataPath top module.
//
// What it does:
//  1) Generates a 100 MHz clock
//  2) Applies reset
//  3) "Presses" the start/stop button to move RESET->SET
//  4) Skips the random delay by forcing delay_time high (so SET->GO happens fast)
//  5) Waits for GO (led turns on), then presses button to go GO->SCORE
//  6) Presses again to return SCORE->RESET
//
// NOTE:
// - This TB assumes your module is named DataPath and has ports:
//   clk, rst, start_stop_btn, led, an, seg
// - If you have button edge-detect (recommended), make the pulse width >= 2 clk cycles.
// - Forcing internal signals is a common simulation trick to avoid waiting 0.5–3s delays.
//======================================================
`timescale 1ns/1ps

module Reaction_tb;

  // DUT I/O
  logic clk;
  logic rst;
  logic start_stop_btn;
  logic led;
  logic [3:0] an;
  logic [6:0] seg;

  // Instantiate DUT
  DataPath dut (
    .clk(clk),
    .rst(rst),
    .start_stop_btn(start_stop_btn),
    .led(led),
    .an(an),
    .seg(seg)
  );

  // -------------------------
  // 100 MHz clock: 10 ns period
  // -------------------------
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // -------------------------
  // Tasks
  // -------------------------
  task automatic applyReset();
    begin
      rst = 1'b1;
      start_stop_btn = 1'b0;
      // hold reset a few cycles
      repeat (10) @(posedge clk);
      rst = 1'b0;
      repeat (5) @(posedge clk);
    end
  endtask

  // Button press (level pulse). If you have edge detect, this produces a clean press.
  task automatic pressButton(input int unsigned cyclesHigh = 5);
    begin
      start_stop_btn = 1'b1;
      repeat (cyclesHigh) @(posedge clk);
      start_stop_btn = 1'b0;
      repeat (5) @(posedge clk);
    end
  endtask

  // Wait until led matches expected value (with timeout)
  task automatic waitForLed(input logic expected, input int unsigned timeoutCycles = 200000);
    int unsigned i;
    begin
      for (i = 0; i < timeoutCycles; i++) begin
        @(posedge clk);
        if (led === expected) begin
          $display("[%0t] INFO: led reached %0d", $time, expected);
          disable waitForLed;
        end
      end
      $fatal(1, "[%0t] TIMEOUT: led did not reach %0d within %0d cycles",
             $time, expected, timeoutCycles);
    end
  endtask

  // -------------------------
  // Main stimulus
  // -------------------------
  initial begin
    $display("[%0t] Starting TB...", $time);

    // init
    rst = 1'b0;
    start_stop_btn = 1'b0;

    // Reset DUT
    applyReset();

    // At this point DUT should be in RESET (display 0000, led off)
    if (led !== 1'b0) $display("[%0t] WARN: led not low after reset", $time);

    // Press to go RESET -> SET
    $display("[%0t] Press button: RESET->SET", $time);
    pressButton(5);

    // -------------------------
    // SPEED UP SIM: skip waiting 500–3050 ms
    // Force delay_time high so SET immediately transitions to GO.
    //
    // This requires that delay_time is a visible internal signal in your DataPath.
    // If your signal name differs, change dut.delay_time accordingly.
    // -------------------------
    $display("[%0t] Forcing delay_time high to skip random delay...", $time);
    force dut.delay_time = {($bits(dut.delay_time)){1'b1}}; // max value
    // give combinational logic a moment to see it
    repeat (20) @(posedge clk);
    release dut.delay_time;

    // Wait for GO indication (led should go high in GO)
    waitForLed(1'b1, 50000);

    // Press to go GO -> SCORE (should capture final_time)
    $display("[%0t] Press button: GO->SCORE", $time);
    pressButton(5);

    // LED should turn off in SCORE (depending on your design)
    waitForLed(1'b0, 50000);

    // Press to go SCORE -> RESET
    $display("[%0t] Press button: SCORE->RESET", $time);
    pressButton(5);

    // In RESET, led should be off
    waitForLed(1'b0, 50000);

    $display("[%0t] TB complete.", $time);
    $finish;
  end

endmodule
