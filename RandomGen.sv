module RandomGen (
    input logic clk,
    input logic rst,           // Active high reset
    input logic generate_num,  // When high, advance LFSR
    output logic [7:0] random_number
);
    // Combinational feedback tap
    logic feedback;
    assign feedback =
        random_number[7] ^
        random_number[5] ^
        random_number[4] ^
        random_number[3];

    // Implement the shift
    // Remember to initialize the register to a non-zero value
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            random_number <= 8'b1101_0100; // Non-zero seed
        end else if (generate_num) begin
            random_number <= {random_number[6:0], feedback};
        end
    end
endmodule
