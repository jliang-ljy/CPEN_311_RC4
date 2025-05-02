`define resetiing   5'b00000 
`define Key_plus    5'b00001 
`define Shuffling   5'b00010 
`define Decoding    5'b00011 
`define Caplet      5'b00100 
`define Idle1       5'b00101 
`define Idle2       5'b00110 
`define Idle3       5'b00111 
`define Idle4       5'b01000
`define Idle5       5'b01001 
`define Idle6       5'b01010 
 




`default_nettype none

module lab4_core(
    input logic clock,
    input logic reset,
    input logic start,
    output logic [7:0] counter_value,
	 output logic [7:0] data,
    output logic[7:0] address,
    output logic finish,
	 output logic [7:0] q,
     output logic write_enable,
     input logic [9:0] switch,
     output logic [3:0] out1,
     output logic [3:0] out2,
     output logic [3:0] out3,
     output logic [3:0] out4,
     output logic [3:0] out5,
     output logic [3:0] out6
     
    //output logic write_enable
);

logic [7:0] address_decode; //address output from fsm_decode to s_memory
logic write_enable_decode;  //write enable output from fsm_decode to s_memory
logic [7:0] data_decode;    //data output from fsm_decode to s_memory

logic [7:0] address_rom;    //address output from fsm_decode to r_rom
//logic [7:0] data_rom;       //data output from fsm_decode to r_rom
logic [7:0] q_rom;          //data output from r_rom to fsm_decode

logic [7:0] address_tw;     //selected address output from the fsms to s_memory
logic [7:0] data_tw;        //selected data output from the fsms to s_memory
logic wren_tw;              //selected write enable output from the fsms to s_memory


logic [7:0] address_bmem_decode;   //address output from fsm_decode to b_memory
logic [7:0] data_bmem;             //data output from fsm_decode to b_memory
logic write_enable_bmem;           //write enable output from fsm_decode to b_memory
logic [7:0] q_bmem;                //data output from b_memory to fsm_decode

//assign address = address_tw;

logic start_swap;

logic [7:0] data_swap;            //data output from fsm_shuffle to s_memory
logic [7:0] address_swap;         //address output from fsm_shuffle to s_memory
logic write_enable_swap;          //write enable output from fsm_shuffle to s_memory\

//logic [1:0] startnext;          //centralised selection and handshake signal for the fsms and s_memory
logic start_shuffle = 1'b0;              //start signal from the fsm_write_memory to fsm_shuffle
logic start_decode = 1'b0;        //start signal from the fsm_shuffle to fsm_decode

logic decode_finish;              //finish signal from fsm_decode to the fsms

logic [7:0] data_write_mem;       //data output from fsm_write_memory to s_memory
logic [7:0] address_write_mem;    //address output from fsm_write_memory to s_memory
logic write_enable_write_mem;     //write enable output from fsm_write_memory to s_memory
logic FSM_start_2;                 // Second start for Loop

logic [7:0] address_bmem_capital; //address output from fsm_shuffle to s_memory
logic [7:0] address_bmem;

logic core_start_shuffle;
logic decode_start;
logic shuffle_finish;

logic fsm_progress ; 
logic shuffle_progress ;
logic decode_progress;
logic capital_progress = 1'b0;

logic yes_message;
logic wrong_message;
logic capital_finish;
logic [23:0] secret_message = 24'b000000000000000000000000; //actually secret key!!!
logic inhere; 

logic [1:0] Delete1 = 2'b00;

logic [4:0] state = 5'b00000; 
logic flag;

logic [7:0] I_test;
logic [7:0] J_test;




assign data = data_tw;
assign write_enable = wren_tw;


     




      fsm_write_memory fsm_write_memory_inst(
          .inclk(clock),
          .start(start),
          .counter_value(data_write_mem), //output to s_memory
          .address(address_write_mem), //output to s_memory
          .write_enable(write_enable_write_mem),
          .startnext(start_shuffle),
          .fsm_progress(fsm_progress),
          .second_start(capital_finish)
      );
     

                  
     fsm_shuffle datass(
           .address(address_swap), //output
           .data_in(q),
           .startnext(start_shuffle), //startnext[0] = 1 since this point
           .clk(clock),
           .data_out(data_swap), //output
           .write_enable(write_enable_swap),
           .finish(start_decode), //startnext[1]
           .secret(secret_message), //this is actually the secret key
           .shuffle_progress(shuffle_progress),
           .I_test(I_test),
           .J_test(J_test)
      );
      


     fsm_decode fsm_decode_inst(
          .inclk(clock),
          .start(start_decode), //startnext[1] = 1 since this point
          .reset(reset),
          .switch(switch),
          .data_smem(q), //input from s_memory
          .data_rom(q_rom), //input from r_rom
          .data_out_smem(data_decode),
          .data_out_bmem(data_bmem),
          .address_out_smem(address_decode),
          .address_out_bmem(address_bmem_decode),
          .address_out_rom(address_rom),
          .finish(decode_finish),
          .write_enable_smem(write_enable_decode),
          .write_enable_bmem(write_enable_bmem),
          .decode_progress(decode_progress)
      );
      

    /*
    startnext[0] since shuffling, 1
    startnext[1] since decoding, 1
    */
    
    //Solely designed for s_memory
    
     assign address_tw = shuffle_progress ? address_swap : (decode_progress ? address_decode : address_write_mem) ;
     assign data_tw = shuffle_progress ? data_swap : (decode_progress ? data_decode : data_write_mem);
     assign wren_tw = shuffle_progress ? write_enable_swap : (decode_progress ? write_enable_decode : write_enable_write_mem);
     assign address_bmem = capital_progress ? address_bmem_capital : address_bmem_decode; 
     /*
     assign address_tw = start_shuffle ? address_swap : address_write_mem;
     assign data_tw = start_shuffle ? data_swap : data_write_mem;
     assign wren_tw = start_shuffle ? write_enable_swap : write_enable_write_mem;
     */

    s_memory s_memory_inst(
      .address(address_tw),
      .clock(clock),
      .data(data_tw),
      .wren(wren_tw),
      .q(q)
    );
    


    b_memory b_memory_inst(
      .address(address_bmem),
      .clock(clock),
      .data(data_bmem),
      .wren(write_enable_bmem),
      .q(q_bmem)
    );



    r_rom r_rom_inst(
      .address(address_rom),
      .clock(clock),
      .q(q_rom)
    );

    CapitalLetter CapMe(
      .data(q_bmem),
      .address(address_bmem_capital),
      .finishcheck(capital_finish), //finish but wrong, need to start the entire fsms process again, trigger fsm_write_memory again
      .start(decode_finish),
      .clk(clock),
      .wrong_message(wrong_message),
      .yes_message(yes_message),
      .Capital_progress(capital_progress), //this "progress" signal means the CapitalLetter is working and commuicating with b_memory
      .Inhere(inhere)
    );
          
        always_ff@(posedge clock)
             if(wrong_message == 1'b1 )
                   begin 
                   secret_message <= secret_message + 1'b1; //secret_key incremented by 1 and start over again
                   Delete1 <= Delete1 + 1'b1;
                   end 

                   else 
                   begin 
                   secret_message <= secret_message;
   
                   end 

 assign counter_value[6:0] = I_test[6:0];
 assign counter_value[7] = start_shuffle;  

 assign out1 = secret_message[3:0];
 assign out2 = secret_message[7:4];
 assign out3 = secret_message[11:8];
 assign out4 = secret_message[15:12];
 assign out5 = secret_message[19:16];
 assign out6 = secret_message[23:20];

endmodule

`default_nettype wire