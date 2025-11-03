`timescale 1ns / 1ps

module alu_pipeline (
    // Clock and Reset
    input  wire        clk,
    input  wire        rst_n,
    
    // Input Stage
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [2:0]  op,        // Operation select
    input  wire        valid_in,
    
    // Output Stage
    output reg  [15:0] result,
    output reg         zero,      // Result is zero
    output reg         negative,  // Result is negative
    output reg         overflow,  // Overflow occurred
    output reg         valid_out
);

    // Pipeline Stage 1: Input registers
    reg [15:0] a_stage1, b_stage1;
    reg [2:0]  op_stage1;
    reg        valid_stage1;
    
    // Pipeline Stage 2: Computation
    reg [15:0] alu_result;
    reg        alu_zero, alu_negative, alu_overflow;
    
    // Operation definitions
    localparam OP_ADD  = 3'b000;
    localparam OP_SUB  = 3'b001;
    localparam OP_AND  = 3'b010;
    localparam OP_OR   = 3'b011;
    localparam OP_XOR  = 3'b100;
    localparam OP_SLL  = 3'b101;  // Shift left logical
    localparam OP_SRL  = 3'b110;  // Shift right logical
    localparam OP_SLT  = 3'b111;  // Set less than
    
    // Stage 1: Input registration
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_stage1     <= 16'h0000;
            b_stage1     <= 16'h0000;
            op_stage1    <= 3'b000;
            valid_stage1 <= 1'b0;
        end else begin
            a_stage1     <= a;
            b_stage1     <= b;
            op_stage1    <= op;
            valid_stage1 <= valid_in;
        end
    end
    
    // Stage 2: ALU computation
    always @(*) begin
        // Default values
        alu_result   = 16'h0000;
        alu_overflow = 1'b0;
        
        case (op_stage1)
            OP_ADD: begin
                {alu_overflow, alu_result} = {1'b0, a_stage1} + {1'b0, b_stage1};
            end
            
            OP_SUB: begin
                {alu_overflow, alu_result} = {1'b0, a_stage1} - {1'b0, b_stage1};
            end
            
            OP_AND: begin
                alu_result = a_stage1 & b_stage1;
            end
            
            OP_OR: begin
                alu_result = a_stage1 | b_stage1;
            end
            
            OP_XOR: begin
                alu_result = a_stage1 ^ b_stage1;
            end
            
            OP_SLL: begin
                alu_result = a_stage1 << b_stage1[3:0];  // Shift by lower 4 bits
            end
            
            OP_SRL: begin
                alu_result = a_stage1 >> b_stage1[3:0];
            end
            
            OP_SLT: begin
                alu_result = ($signed(a_stage1) < $signed(b_stage1)) ? 16'h0001 : 16'h0000;
            end
            
            default: begin
                alu_result = 16'h0000;
            end
        endcase
        
        // Compute flags
        alu_zero     = (alu_result == 16'h0000);
        alu_negative = alu_result[15];
    end
    
    // Stage 3: Output registration
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result    <= 16'h0000;
            zero      <= 1'b0;
            negative  <= 1'b0;
            overflow  <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            result    <= alu_result;
            zero      <= alu_zero;
            negative  <= alu_negative;
            overflow  <= alu_overflow;
            valid_out <= valid_stage1;
        end
    end

endmodule
