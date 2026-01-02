`timescale 1ns/1ps
module binary_to_ssd_tb;
logic [13:0] binary_in;
logic [6:0] display_out [3:0];

binary_to_ssd DUT (
    .binary_in(binary_in),
    .display_out(display_out)
);

// Helper task to check BCD digits inside dut.placeholders
task automatic checkBcd(
    input int unsigned val,
    input logic [3:0] th,
    input logic [3:0] hu,
    input logic [3:0] te,
    input logic [3:0] on
);
    begin
        binary_in = val[13:0];
        #10; // allow combinational logic to settle

        assert(dut.placeholders[29:26] == th &&
            dut.placeholders[25:22] == hu &&
            dut.placeholders[21:18] == te &&
            dut.placeholders[17:14] == on)
        else $fatal("FAIL val=%0d  got(th,hu,te,on)=(%0d,%0d,%0d,%0d)",
            val,
            dut.placeholders[29:26],
            dut.placeholders[25:22],
            dut.placeholders[21:18],
            dut.placeholders[17:14]);
    end
endtask

initial begin
    // 0    -> 0000
    checkBcd(0,    4'd0, 4'd0, 4'd0, 4'd0);
    // 1    -> 0001
    checkBcd(1,    4'd0, 4'd0, 4'd0, 4'd1);
    // 10   -> 0010
    checkBcd(10,   4'd0, 4'd0, 4'd1, 4'd0);
    // 16   -> 0016
    checkBcd(16,   4'd0, 4'd0, 4'd1, 4'd6);
    // 99   -> 0099
    checkBcd(99,   4'd0, 4'd0, 4'd9, 4'd9);
    // 999  -> 0999
    checkBcd(999,  4'd0, 4'd9, 4'd9, 4'd9);
    // 9999 -> 9999
    checkBcd(9999, 4'd9, 4'd9, 4'd9, 4'd9);
    $display("PASS: placeholders BCD checks passed");
$finish
end
endmodule