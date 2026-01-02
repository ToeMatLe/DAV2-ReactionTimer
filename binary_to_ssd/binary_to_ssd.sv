module binary_to_ssd (
    input logic [$clog2(10000)-1:0] binary_in, // 14-bit binary input (0-9999)
    output logic [6:0] display_out [3:0] // 4-digit 7-segment display output 
);
// clog2(10000) = 14
// clog2(10000) - 1 = 13, meaning [13:0]
// Size of place holder = 16 + 14 = 30 bits
logic [29:0] placeholders;

// Double-Dabble Algorithm  
always_comb begin
    placeholders = {16'b0, binary_in};

    for(int i = 0; i < 14; i++) begin
        // Ones Place
        if (placeholders[17:14] >= 4'b0101) begin
            placeholders[17:14] = placeholders[17:14] + 4'b0011; 
        end 
        // Tens Place
        if (placeholders[21:18] >= 4'b0101) begin
            placeholders[21:18] = placeholders[21:18] + 4'b0011; 
        end
        // Hundreds Place
        if (placeholders[25:22] >= 4'b0101) begin
            placeholders[25:22] = placeholders[25:22] + 4'b0011; 
        end
        // Thousands Place
        if (placeholders[29:26] >= 4'b0101) begin
            placeholders[29:26] = placeholders[29:26] + 4'b0011; 
        end
        placeholders = placeholders << 1;
    end 
end
 // Instantiate 7-seg decoders for each decimal digit
    SevenSegDigit thousandsDecoder (
        .digit (placeholders[29:26]),
        .seg_out (display_out[3])   
    );
    SevenSegDigit hundredsDecoder (
        .digit (placeholders[25:22]),
        .seg_out (display_out[2])
    );
    SevenSegDigit tensDecoder (
        .digit (placeholders[21:18]),
        .seg_out (display_out[1])
    );
    SevenSegDigit onesDecoder (
        .digit (placeholders[17:14]),
        .seg_out (display_out[0])
    );
endmodule