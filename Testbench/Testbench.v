`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:      Robert Riordan
// Target Device: XC7A100T-csg324 on Digilent Nexys 4 board
// Description:   Calculator testbench
//                Basic testbench to check all keys work as expected
// Created:       08 November 2018
//////////////////////////////////////////////////////////////////////////////////

module Testbench;

// -------------------------------------------------------------------------- //
	
	// Setup
	
	// Inputs
	reg         clock,
	            reset,
	            newKey;
    reg [4:0]   keycode;
    
    // Outputs
    wire [15:0] value;
    
    // Instanciate our module
    CalculatorLogic calc(
                .clock(clock),
                .reset(reset),
                .newKey(newKey),
                .keycode(keycode),
                .value(value);
                );

    locaparam   CONSOLE = 1;
    
    // Contol keys
    // Left most bit is inverted?
    localparam [4:0]    CLEAR   = 5'h1,
                        PLUS    = 5'h2,
                        MUL     = 5'h3,
                        EQUAL   = 5'h4,
                        
                        NULL    = 5'h0;
    
    // Letters
    localparam [4:0]    A       = 5'h1A,
                        B       = 5'h1B,
                        C       = 5'h1C,
                        D       = 5'h1D,
                        E       = 5'h1E,
                        F       = 5'h1F;
    
    // 5MHz Clock
    initial begin
        clock = 0;
        #100;
        forever
            #100
            clock = ~clock;
    end
    
// -------------------------------------------------------------------------- //
    
    // Tasks
    
    // Key press
    task PRESS (input[4:0] key);
        begin
            @ (negedge clock);
            #1 keycode = key ^ 5'h10;
            @ (negedge clock);
            #1 newKey = 1'b1;
            @ (negedge clock);
            #1 newKey = 1'b0;
            repeat (5)
                @ (negedge clock);
            #1 keycode = NULL; 
        end
    endtask
    
    // Check correct
    task CHECK (input[15:0] expect);
        begin
            @ (negedge clock);
            #1;
            if (expect != value)
                begin
                    $fdisplay(CONSOLE, "Error:\n\tTime = %t ps\n\tExpected = %h\n\tActual = %h\n\n", $time, expected, value)
                end
        end
    endtask
    
// -------------------------------------------------------------------------- //
    
    // Testing
    
    initial begin
        reset = 1'b0;
        newKey = 1'b0;
        keycode = NULL;
        @ (negedge clock);
        #200;
        reset = 1'b1;
        @ (negedge clock)
        reset = 1'b0;
        
        #400;
        
        
        // 12 +  3 = 
        PRESS(1);
        CHECK(5'h1);
        PRESS(2);
        CHECK(5'h12);
        PRESS(PLUS);
        CHECK(5'h12);
        PRESS(3);
        CHECK(5'h3);
        PRESS(EQUAL);
        CHECK(5'h15);
        
        #400;
        
        PRESS(CLEAR);
        CHECK(5'h0);
        
        #200;
        
        // 45 x 6 =
        PRESS(4);
        CHECK(5'h4); 
        PRESS(5);
        CHECK(5'h45);
        PRESS(MUL);
        CHECK(05'h45);
        PRESS(6);
        CHECK(5'h6);
        PRESS(EQUAL);
        CHECK(5'h19E);
        
        #400;
        
        PRESS(CLEAR);
        CHECK(5'h0);
        
        // 7 + 8 + 9 =
        PRESS(7);
        CHECK(5'h7);
        PRESS(PLUS);
        CHECK(5'h7);
        PRESS(8);
        CHECK(5'h8);
        PRESS(PLUS);
        CHECK(5'hF);
        PRESS(9);
        CHECK(5'h9);
        PRESS(EQUALS);
        CHECK(5'h18);
        
        // + A x B =
        PRESS(PLUS);
        CHECK(5'h18);
        PRESS(A);
        CHECK(5'hA);
        PRESS(MUL);
        CHECK(5'h102);
        PRESS(B);
        CHECK(5'hB);
        PRESS(EQUALS);
        CHECK(5'hB16);
        
        #400;
        
        PRESS(CLEAR);
        CHECK(5'h0);
        
        $stop
        $stop
    end
    
endmodule
