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

logic [$clog2(10000)-1:0] elapsed_time;
Stopwatch DUT2 (
    .clk(clk),
    .rst(rst),
    .start_watch(start_stop_btn),
    .elapsed_time(elapsed_time)
);
always_ff @(posedge clk or rst) begin 
    if (start_stop_btn) begin 

    end
end


endmodule