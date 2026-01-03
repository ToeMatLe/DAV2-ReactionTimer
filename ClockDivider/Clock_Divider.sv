module Clock_Divider #(
    // 1 MHz  = 1,000 kHz
    // 100 MHz  = 100,000 kHz
    // 100 MHz  = 1 kHz * 100,000
    parameter DIVISOR = 50000  // Division factor to get from 100 MHz to 1 kHz. Divide by 2 to get 50% duty cycle
) (
    input logic clk_in,    // Input clock (100 MHz) gives 1 or 0
    input logic rst,       // Active high reset, probably connected to a pin
    output logic clk_out   // Output clock (1 kHz) gives 1 or 0
);

// Count up to 2^16 = 65536. Needed only 50000
logic [16:0] counter; 

// 50% Duty cycle, think square wave
always_ff @(posedge clk_in or posedge rst) begin
    if (rst) begin
        clk_out <= 0;
        counter <= 0;
    end else begin
        // Logic: count up until DIVISOR Count and switch between on/off
         if (counter == DIVISOR-1) begin
            clk_out <= ~clk_out;
            counter <= 0;
        end else begin 
            counter <= counter + 1;
        end
    end
end
endmodule