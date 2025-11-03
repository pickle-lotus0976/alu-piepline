`timescale 1ns / 1ps

module alu_tb;
    reg         clk;
    reg         rst_n;
    reg  [15:0] a, b;
    reg  [2:0]  op;
    reg         valid_in;
    wire [15:0] result;
    wire        zero, negative, overflow, valid_out;
    
    // Instantiate DUT
    alu_pipeline dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .op(op),
        .valid_in(valid_in),
        .result(result),
        .zero(zero),
        .negative(negative),
        .overflow(overflow),
        .valid_out(valid_out)
    );
    
    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
        
        // Initialize
        rst_n = 0;
        a = 0;
        b = 0;
        op = 0;
        valid_in = 0;
        
        // Reset
        #20 rst_n = 1;
        #10;
        
        // Test ADD
        a = 16'h1234;
        b = 16'h5678;
        op = 3'b000;
        valid_in = 1;
        #10;
        
        // Test SUB
        a = 16'h8000;
        b = 16'h0001;
        op = 3'b001;
        #10;
        
        // Test AND
        a = 16'hFF00;
        b = 16'h0FF0;
        op = 3'b010;
        #10;
        
        // Test OR
        a = 16'hF0F0;
        b = 16'h0F0F;
        op = 3'b011;
        #10;
        
        // Test XOR
        a = 16'hAAAA;
        b = 16'h5555;
        op = 3'b100;
        #10;
        
        // Test shift left
        a = 16'h0001;
        b = 16'h0004;
        op = 3'b101;
        #10;
        
        // Test shift right
        a = 16'h8000;
        b = 16'h0004;
        op = 3'b110;
        #10;
        
        // Test set less than
        a = 16'hFFFF;  // -1 signed
        b = 16'h0001;
        op = 3'b111;
        #10;
        
        #50;
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time=%0t rst_n=%b a=%h b=%h op=%b result=%h zero=%b neg=%b ovf=%b valid=%b",
                 $time, rst_n, a, b, op, result, zero, negative, overflow, valid_out);
    end

endmodule
