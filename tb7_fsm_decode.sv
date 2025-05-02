`timescale 1ns/1ps

module tb8_fsm_decode;

    // Inputs
    reg inclk;
    reg start;
    reg reset;
    reg [9:0] switch;
    reg [7:0] data_rom;
    reg [7:0] data_smem;

    // Outputs
    wire [7:0] data_out_smem;
    wire [7:0] data_out_bmem;
    wire [7:0] address_out_smem;
    wire [7:0] address_out_bmem;
    wire [7:0] address_out_rom;
    wire finish;
    wire write_enable_smem;
    wire write_enable_bmem;
    wire decode_progress;
    wire [12:0] check_state;

    // Instantiate the Unit Under Test (UUT)
    fsm_decode uut (
        .inclk(inclk),
        .start(start),
        .reset(reset),
        .switch(switch),
        .data_rom(data_rom),
        .data_smem(data_smem),
        .data_out_smem(data_out_smem),
        .data_out_bmem(data_out_bmem),
        .address_out_smem(address_out_smem),
        .address_out_bmem(address_out_bmem),
        .address_out_rom(address_out_rom),
        .finish(finish),
        .write_enable_smem(write_enable_smem),
        .write_enable_bmem(write_enable_bmem),
        .decode_progress(decode_progress),
        .check_state(check_state)
    );

    // Clock generation
    initial begin
        inclk = 0;
        forever #5 inclk = ~inclk; // 10ns clock period
    end

    initial begin
        // Initialize Inputs
        start = 0;
        reset = 0;
        switch = 10'b0;
        data_rom = 8'b0;
        data_smem = 8'b0;

        // Wait for the global reset
        #20;

        // Start the FSM
        start = 1;
        #10; // Hold start high for one clock cycle
        start = 0;

        // Generate incremental address and data
        fork
            begin: address_generator
                integer addr;
                addr = 0;
                forever begin
                    #10;
                    data_smem = addr[7:0]; // Assign data based on address
                    data_rom = addr[7:0];  // Assign data based on address
                    addr = addr + 1;
                end
            end
        join_none

        // Wait and observe FSM progression
        wait (decode_progress == 1); // Wait until FSM is active

        // Wait for some cycles to let FSM process
        repeat (100) @(posedge inclk);

        // Trigger second start
        start = 1;
        #10; // Hold start high for one clock cycle
        start = 0;

        // Wait and observe FSM progression again
        wait (decode_progress == 1); // Wait until FSM is active

        // Wait for some more cycles
        repeat (100) @(posedge inclk);

        // Finish the simulation
        $finish;
    end

    // Monitor to observe the FSM behavior
    initial begin
        $monitor("Time: %0t, state: %b, address_out_smem: %d, address_out_bmem: %d, address_out_rom: %d, data_out_smem: %d, data_out_bmem: %d, finish: %b, write_enable_smem: %b, write_enable_bmem: %b, decode_progress: %b",
                 $time, check_state, address_out_smem, address_out_bmem, address_out_rom, data_out_smem, data_out_bmem, finish, write_enable_smem, write_enable_bmem, decode_progress);
    end

endmodule
