module binary_to_ssd (
    input logic [$clog2(10000)-1:0] binary_in, // 14-bit binary input (0-9999)
    output logic [6:0] display_out [3:0] // 4-digit 7-segment display output 
);
// clog2(10000) = 14
// clog2(10000) - 1 = 13
// Size of place holder = 16 + 13 = 28
logic [28:0] placeholders;

// Double-Dabble Algorithm  
always_comb begin
    placeholders = {16'b0, binary_in};

    for(int i = 0; i < 13; i++) begin
        // Ones Place
        if (placeholders[16:13] >= 4'b0101) begin
            placeholders[16:13] = placeholders[16:13] + 4'b0011; 
        end 
        // Tens Place
        if (placeholders[20:17] >= 4'b0101) begin
            placeholders[20:17] = placeholders[20:17] + 4'b0011; 
        end
        // Hundreds Place
        if (placeholders[24:21] >= 4'b0101) begin
            placeholders[24:21] = placeholders[24:21] + 4'b0011; 
        end
        // Thousands Place
        if (placeholders[28:25] >= 4'b0101) begin
            placeholders[28:25] = placeholders[28:25] + 4'b0011; 
        end
        placeholders = placeholders << 1;
    end 
end
 // Instantiate 7-seg decoders for each decimal digit
    sevenSegmentDigit thousandsDecoder (
        .digit (placeholders[28:25]),
        .seg_out (display_out[3])   
    );
    sevenSegmentDigit hundredsDecoder (
        .digit (placeholders[24:21]),
        .seg_out (display_out[2])
    );
    sevenSegmentDigit tensDecoder (
        .digit (placeholders[20:17]),
        .seg_out (display_out[1])
    );
    sevenSegmentDigit onesDecoder (
        .digit (placeholders[16:13]),
        .seg_out (display_out[0])
    );
endmodule