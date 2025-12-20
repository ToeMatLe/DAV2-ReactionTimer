module RandomGen (
    input logic clk,
    input logic rst, // Active high, resets LFSR to a non-zero seed
    input logic generate_num, // When high, generate the next number
    output logic [7:0] random_number
);
    // Implement the shift and XOR feedback.
    // Remember to initialize the register to a non-zero value
    logic feedback;
    always_ff @(posedge clk or rst) begin 
        if (rst) begin 
            random_number <= 8'b11010100; // Random seed
        end if else (generate_num) begin 
            feedback <= random_number[7] XOR random_number[5] XOR random_number[4] XOR random_number[3];
            random_number <= {random_number[6:0], feedback};
        end
    end
endmodule