module SevenSegDigit (
    input logic [3:0] digit,       // 4-bit input digit (0-9)
    output logic [6:0] seg_out     // 7-segment output (a-g)
);
// A=0, B=1, C=2, D=3, E=4, F=5, G=6
always_comb begin
    case(digit)
        4'b0000: seg_out = 7'b1111110; 
        4'b0001: seg_out = 7'b0110000;
        4'b0010: seg_out = 7'b1101101;
        4'b0011: seg_out = 7'b1111001;
        4'b0100: seg_out = 7'b0110011;
        4'b0101: seg_out = 7'b1011011;  
        4'b0110: seg_out = 7'b1011111;
        4'b0111: seg_out = 7'b1110000;
        4'b1000: seg_out = 7'b1111111;
        4'b1001: seg_out = 7'b1111011;
        default: seg_out = 7'b0000000; // Blank 
    endcase
end

endmodule
