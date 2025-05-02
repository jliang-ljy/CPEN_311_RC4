`timescale 1ns/1ps

module tb8_fsm_write_memory;

    // Inputs
    reg inclk;
    reg start;
    reg second_start;

    // Outputs
    wire [7:0] counter_value;
    wire [7:0] address;
    wire finish;
    wire write_enable;
    wire startnext;
    wire fsm_progress;

    // Instantiate the Unit Under Test (UUT)
    fsm_write_memory uut (
        .inclk(inclk),
        .start(start),
        .counter_value(counter_value),
        .address(address),
        .finish(finish),
        .write_enable(write_enable),
        .startnext(startnext),
        .fsm_progress(fsm_progress),
        .second_start(second_start)
    );

    // Clock generation
    initial begin
        inclk = 0;
        forever #5 inclk = ~inclk; // 10ns clock period
    end

    initial begin
        // Initialize Inputs
        start = 0;
        second_start = 0;

        // Wait for the global reset
        #20;

        // Start the FSM
        start = 1;
        #10; // Hold start high for one clock cycle
        start = 0;

        // Wait and observe FSM progression
        wait (fsm_progress == 1); // Wait until FSM is active

        // Wait for some cycles to let FSM process
        repeat (20) @(posedge inclk); // Adjust the wait time

        // Trigger second start
        second_start = 1;
        #10; // Hold second_start high for one clock cycle
        second_start = 0;

        // Wait and observe FSM progression again
        wait (fsm_progress == 1); // Wait until FSM is active

        // Wait for some more cycles
        repeat (40) @(posedge inclk); // Further increase the wait time
        #100;

        // Check if finish becomes high
        if (finish == 1'b1) begin
            $display("Test Passed: FSM reached finish state.");
        end else begin
            $display("Test Failed: FSM did not reach finish state.");
        end

        // Finish the simulation
        $finish;
    end

    // Monitor to observe the FSM behavior
    initial begin
        $monitor("Time: %0t, state: %b, counter_value: %d, address: %d, finish: %b, write_enable: %b, startnext: %b, fsm_progress: %b, second_start: %b",
                 $time, uut.state, counter_value, address, finish, write_enable, startnext, fsm_progress, second_start);
    end

endmodule 