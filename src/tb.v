`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test.py
    input clk,
    input rst,
    output [6:0] segments
   );

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    wire [7:0] inputs = {8'b0};
    wire [7:0] outputs;
    assign segments = outputs[6:0];

    // instantiate the DUT
    tt_um_template dut(
        `ifdef GL_TEST
            .vccd1( 1'b1),
            .vssd1( 1'b0),
        `endif
        .ui_in  (inputs),
        .uo_out (outputs),
        .clk (clk),
        .rst_n (~rst)
        );

endmodule