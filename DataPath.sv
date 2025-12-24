// RESET -> SET -> GO -> SCORE
module DataPath (
    input logic clk,
    input logic rst,
    input logic start_stop_btn,
    output logic led,
    output logic [3:0] an,
    output logic [6:0] seg
); 

logic clkdiv;
Clock_Divider DUT1 (
    .clk_in(clk),
    .rst(rst),
    .clk_out(clkdiv)
);
// Stopwatch
logic [$clog2(10000)-1:0] elapsed_time;
logic startWatch;
Stopwatch DUT2 (
    .clk(clk),
    .rst(rst),
    .start_watch(startWatch), // Only count in GO state
    .elapsed_time(elapsed_time)
);
// RNG
logic [7:0] random_number;
logic startGen;
RandomGen DUT3 (
    .clk(clk),
    .rst(rst),
    .generate_num(startGen), // Running in RESET 
    .random_number(random_number)
);
// Display Pipeline
logic [6:0] display_out [3:0] // 4-digit 7-segment display output 
binary_to_ssd DUT4 (
    .binary_in(elapsed_time),
    .display_out(display_out)
);
basys_ssd DUT5 (
    .clk(clk),
    .rst(rst),
    .ssd_in(display_out),
    .an(an),
    .seg(seg)
);

logic [$clog2(10000)-1:0] delay_time;
statetype next_state;
statetype current_state;
// FSM Implementation
logic [1:0] state;
always_ff @(posedge clk or posedge rst) begin 
    if (rst) begin
        current_state <= RESET;
        delay_time <= 0;
    end else begin
   // Delay counter runs ONLY in SET
    if (current_state == SET) begin
        delay_time <= delay_time + 1;
    end else begin
        current_state <= next_state; // Update state in sequential driver, every clock edge
        delay_time <= 0; // Reset delay_time when not in SET
    end
  end
end

always_comb begin 
    // Default Cases
    led = 1'b0;
    startGen = 1'b0;
    startWatch = 1'b0;
    next_state = current_state; // Hold state by default, if not always goes back to reset

    case (current_state)
        RESET: begin 
            // Logic for RESET state
            startGen = 1'b1; // Start generating random number
            if (start_stop_btn) next_state = SET;
        end
        SET: begin 
            // Logic for SET state
            if (delay_time >= random_number*1000) next_state = GO; 
        end
        GO: begin 
            // Logic for GO state
            led = 1'b1; // Light on for user to react
            startWatch = 1'b1; // Start the stopwatch
            if (start_stop_btn) next_state = SCORE;
        end
        SCORE: begin 
            // Logic for SCORE state
            if (start_stop_btn) next_state = RESET;
        end
    endcase
end
typedef enum logic [1:0] { 
    RESET = 2'b00,
    SET = 2'b01,
    GO = 2'b10,
    SCORE = 2'b11
} statetype;
endmodule