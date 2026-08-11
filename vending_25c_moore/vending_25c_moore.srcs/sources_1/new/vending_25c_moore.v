`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Visnu Muthuraman
// 
// Create Date: 03/08/2026 11:14:19 PM
// Design Name: Vending Machine (Moore Machine)
// Module Name: vending_25c_moore
//////////////////////////////////////////////////////////////////////////////////



module vending_25c_moore(
    input clock,
    input reset_n,
    input [1:0] DQ,    // 10c = 2'b10, 25c = 2'b01, 00/11 = invalid
    output reg P,      // Product
    output reg C       // Change
    );
    
    reg [2:0] state, next_state;
    
    parameter S0 = 3'b000, // 0 cents
              S1 = 3'b001, // 10 cents
              S2 = 3'b010, // 20 cents
              S3 = 3'b011, // 25 cents - vend no change
              S4 = 3'b100, // >25 cents - vend and change
              S5 = 3'b101, // unused
              S6 = 3'b110, // unused
              S7 = 3'b111; // unused
    
    // State register with synchronous active-low reset
    always @(posedge clock) begin
        if (!reset_n)
            state <= S0;
        else
            state <= next_state;
    end
    
    // Next-state and outputs
    always @(*) begin
        next_state = state;
        P = 1'b0;
        C = 1'b0;
        
        case (state)
            S0: begin
                P = 0; C = 0;
                if (DQ == 2'b10)      next_state = S1;
                else if (DQ == 2'b01) next_state = S3;
                else                  next_state = S0;
            end
            
            S1: begin
                P = 0; C = 0;
                if (DQ == 2'b10)      next_state = S2;
                else if (DQ == 2'b01) next_state = S4;
                else                  next_state = S1;
            end
            
            S2: begin
                P = 0; C = 0;
                if (DQ == 2'b10)      next_state = S4;
                else if (DQ == 2'b01) next_state = S4;
                else                  next_state = S2;
            end
            
            S3: begin
                P = 1; C = 0;
                if (DQ == 2'b00 || DQ == 2'b11) next_state = S0;
                else if (DQ == 2'b10)           next_state = S1;
                else if (DQ == 2'b01)           next_state = S3;
            end
            
            S4: begin
                P = 1; C = 1;
                if (DQ == 2'b00 || DQ == 2'b11) next_state = S0;
                else if (DQ == 2'b10)           next_state = S1;
                else if (DQ == 2'b01)           next_state = S3;
            end
            
            S5, S6, S7: begin
                P = 0; C = 0;
                next_state = S0;
            end
            
            default: begin
                P = 0; C = 0;
                next_state = S0;
            end
        endcase
    end
    
endmodule
