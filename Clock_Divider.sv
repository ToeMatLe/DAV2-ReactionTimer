module Clock_Divider #(
    // 1 MHz  = 1,000 kHz
    // 100 MHz  = 100,000 kHz
    // 100 MHz  = 1 kHz * 100,000
    parameter DIVISOR = 50000  // Division factor to get from 100 MHz to 1 kHz. Divide by 2 to get 50% duty cycle
) (
    input logic clk_in,    // Input clock (100 MHz)
    input logic rst,       // Active high reset
    output logic clk_out   // Output clock (1 kHz)
);
always_ff @(posedge clk_in) begin
    if (rst) begin
        clk_out <= 0;
    end else begin
        clk_out <= clk_in/DIVISOR;
    end
end
endmodule