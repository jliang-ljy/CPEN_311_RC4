`timescale 1ns/1ps

module tb8_CapitalLetter;

    // Inputs
    reg [7:0] data;
    reg start;
    reg clk;

    // Outputs
    wire [7:0] address;
    wire finishcheck;
    wire wrong_message;
    wire yes_message;
    wire Capital_progress;
    wire Inhere;
    wire LED_wrong;

    // Instantiate the Unit Under Test (UUT)
    CapitalLetter uut (
        .data(data),
        .address(address),
        .finishcheck(finishcheck),
        .start(start),
        .clk(clk),
        .wrong_message(wrong_message),
        .yes_message(yes_message),
        .Capital_progress(Capital_progress),
        .Inhere(Inhere),
        .LED_wrong(LED_wrong)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        // Initialize Inputs
        data = 8'b0;
        start = 0;

        // Wait for the global reset
        #20;

        // Start the FSM
        start = 1;
        #10; // Hold start high for one clock cycle
        start = 0;

        // Generate incremental address and data
        fork
            begin: data_generator
                integer addr;
                addr = 0;
                forever begin
                    #10;
                    data = addr[7:0]; // Assign data based on address
                    addr = addr + 1;
                end
            end
        join_none

        // Wait and observe FSM progression
        wait (Capital_progress == 1); // Wait until FSM is active

        // Wait for some cycles to let FSM process
        repeat (100) @(posedge clk);

        // Trigger second start
        start = 1;
        #10; // Hold start high for one clock cycle
        start = 0;

        // Wait and observe FSM progression again
        wait (Capital_progress == 1); // Wait until FSM is active

        // Wait for some more cycles
        repeat (100) @(posedge clk);

        // Finish the simulation
        $finish;
    end

    // Monitor to observe the FSM behavior
    initial begin
        $monitor("Time: %0t, state: %b, address: %d, data: %d, finishcheck: %b, wrong_message: %b, yes_message: %b, Capital_progress: %b, Inhere: %b, LED_wrong: %b",
                 $time, uut.state, address, data, finishcheck, wrong_message, yes_message, Capital_progress, Inhere, LED_wrong);
    end

endmodule
