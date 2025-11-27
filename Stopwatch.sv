module Stopwatch (
    input logic clk,        // Input clock (1 kHz)
    input logic rst,        // Active high reset
    input logic start_watch, // Start signal
    output logic [$clog2(10000)-1:0] elapsed_time // Time in ms (needs to hold up to 9999)
);
// Stopwatch implementation would go here
// Your logic here:
    // 1. Declare a wire/logic for the 1kHz clock signal.
    // 2. Instantiate your clock_divider module.
    // 3. On the rising edge of your new 1kHz clock,
    //    if start_watch is high, increment elapsed_time.
    // 4. The counter should reset to 0 with rst.

logic receive;
Clock_Divider clkdiv(
    clk_in.(clk),
    clk_out.(receive)
);

// Use the clk from the clk divider
always_ff @(posedge receive) begin 
    if (start_watch) begin 
        elapsed_time <= elapsed_time + 1;
    end else if (rst) begin
        elapsed_time <= 0;
    end
end
endmodule
