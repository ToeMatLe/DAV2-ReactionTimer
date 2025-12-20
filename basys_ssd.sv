module basys_ssd(
    input logic clk, // 100MHz system clock
    input logic rst, // Active High reset
    input logic [6:0] ssd_in [3:0], // The four digits to display
    output logic [3:0] an, // Which display to drive
    output logic [6:0] seg // The number to display
);

logic receive60Hz;
    // 1 MHz  = 1,000 kHz
    // 1 kHz = 1,000 Hz
    // 100 MHz  = 100,000 kHz
    // 100 MHz  = 1 Hz * 100,000,000
    // 100 MHz  = 60 Hz * 1,666,666
Clock_Divider #(
    .DIVISOR(833333)
) clkdiv (
    .clk_in(clk),
    .rst(rst),
    .clk_out(receive60Hz)
)

// This module exists to counter the limitation that only one anode can be on at a time.
// We will cycle through the anodes at a rate fast enough that it appears all are on
logic [1:0] counter
always_ff @(posedge receive60Hz or rst) begin 
    if (counter == 2'b11) begin 
        counter <= 2'b00;
    end else begin 
        counter <= counter + 1;
    end
end
always_comb begin 
    case (counter)
        2'b00: begin 
            an = 4'b1110;
            seg = ssd_in[0];
        end
        2'b01: begin 
            an = 4'b1101;
            seg = ssd_in[1];
        end
        2'b10: begin 
            an = 4'b1011;
            seg = ssd_in[2];
        end
        2'b11: begin 
            an = 4'b0111;
            seg = ssd_in[3];
        end
    endcase
end
endmodule