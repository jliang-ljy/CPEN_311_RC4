/*
i = 0, j=0 
 for k = 0 to message_length-1 { // message_length is 32 in our implementation 
 i = i+1 
 j = j+s[i] 
 swap values of s[i] and s[j] 
 f = s[ (s[i]+s[j]) ] 
 decrypted_output[k] = f xor encrypted_input[k] // 8 bit wide XOR function 
 } 
*/

module fsm_decode (
    input logic inclk,
    input logic start,
    input logic reset,
    input logic [9:0] switch,
    input logic [7:0] data_rom,
    input logic [7:0] data_smem,
    output logic [7:0] data_out_smem,
    output logic [7:0] data_out_bmem,
    output logic [7:0] address_out_smem,
    output logic [7:0] address_out_bmem,
    output logic [7:0] address_out_rom,
    output logic finish,
    output logic write_enable_smem,
    output logic write_enable_bmem,
    output logic decode_progress,
    output logic [12:0] check_state
);

//Initialise states
parameter s_idle        = 13'b00000000_00000;
parameter s_inc_i       = 13'b00000001_00000;
parameter s_send_i      = 13'b00000010_00000;
parameter s_get_i       = 13'b00001100_00000;
parameter s_calc_j      = 13'b00000011_00000;
parameter s_send_j      = 13'b00000100_00000;
parameter s_get_j       = 13'b00001101_00000;
parameter s_wr_j_to_i   = 13'b00000101_00001;
parameter s_wr_i_to_j   = 13'b00000110_00001;
parameter s_calc_i_j    = 13'b00001110_00000;
parameter s_send_i_j    = 13'b00000111_00000;
parameter s_get_i_j     = 13'b00001111_00000;
parameter s_send_k      = 13'b00010000_00000;
parameter s_get_enc     = 13'b00010001_00000;
parameter s_calc_xor    = 13'b00011011_00000;
parameter s_wr_xor      = 13'b00001001_00000;
parameter s_inc_k       = 13'b00001010_00000;
parameter s_done        = 13'b00001011_00100;
parameter s_sync_1      = 13'b00100110_00000;
parameter s_sync_2      = 13'b00010010_00000;
parameter s_sync_3      = 13'b00010011_00001;
parameter s_sync_4      = 13'b00010100_00000;
parameter s_sync_5      = 13'b00010101_00000;
parameter s_sync_6      = 13'b00010110_00000;
parameter s_sync_7      = 13'b00010111_00000;
parameter s_sync_8      = 13'b00011000_00000;
parameter s_sync_9      = 13'b00011001_00001;
parameter s_sync_10     = 13'b00011010_00010;
parameter s_sync_11     = 13'b00011100_00000;
parameter s_sync_12     = 13'b00011101_00000;
parameter s_sync_13     = 13'b00011110_00000;
parameter s_sync_14     = 13'b00011111_00000;
parameter s_sync_19     = 13'b00100100_00000;
parameter s_compare     = 13'b00100111_00000;
parameter s_sync_20     = 13'b00101000_00010;
parameter s_sync_21     = 13'b00101001_00000;
parameter s_sync_22     = 13'b00101010_00000;
parameter s_sync_23     = 13'b00101011_00100; 
parameter s_sync_24     = 13'b00101100_00100;

//Declare variables
logic [12:0] state   = s_idle;
logic [7:0] addr_i   = 8'b0;
logic [7:0] addr_j   = 8'b0;
logic [7:0] addr_k   = 8'b0; 
logic [7:0] addr_ij  = 8'b0;
logic [7:0] data_i;
logic [7:0] data_j;
logic [7:0] data_k;
logic [7:0] data_f;
logic [7:0] data_xor;


//Using one-hot assignments for state outputs
assign write_enable_smem = state[0];
assign write_enable_bmem = state[1];
assign finish            = state[2];

always_ff @(posedge inclk) begin
    case(state)
        s_idle: begin
            check_state <= s_idle;
            if(start) begin
                state <= s_sync_22;
                decode_progress <= 1'b1;
            end else begin
                state <= s_idle;
                decode_progress <= 1'b0;
            end
        end
        s_sync_22: begin
            check_state <= s_sync_22;
            state <= s_inc_i;
        end
        s_inc_i: begin
            check_state <= s_inc_i;
            state <= s_sync_13;
        end
        s_sync_13: begin
            check_state <= s_sync_13;
            state <= s_send_i;
        end
        s_send_i: begin
            check_state <= s_send_i;
            state <= s_sync_1;
        end
        s_sync_1: begin
            check_state <= s_sync_1;
            state <= s_get_i;
        end
        s_get_i: begin
            check_state <= s_get_i;
            state <= s_sync_12;
        end
        s_sync_12: begin
            check_state <= s_sync_12;
            state <= s_calc_j;
        end
        s_calc_j: begin
            check_state <= s_calc_j;
            state <= s_sync_6;
        end
        s_sync_6: begin
            check_state <= s_sync_6;
            state <= s_send_j;
        end
        s_send_j: begin
            check_state <= s_send_j;
            state <= s_sync_2;
        end
        s_sync_2: begin
            check_state <= s_sync_2;
            state <= s_get_j;
        end
        s_get_j: begin
            check_state <= s_get_j;
            state <= s_sync_14;
        end
        s_sync_14: begin
            check_state <= s_sync_14;
            state <= s_wr_j_to_i;
        end
        s_wr_j_to_i: begin
            check_state <= s_wr_j_to_i;
            state <= s_sync_9;
        end
        s_sync_9: begin
            check_state <= s_sync_9;
            state <= s_wr_i_to_j;
        end
        s_wr_i_to_j: begin
            check_state <= s_wr_i_to_j;
            state <= s_sync_3;
        end
        s_sync_3: begin
            check_state <= s_sync_3;
            state <= s_calc_i_j;
        end
        s_calc_i_j: begin
            check_state <= s_calc_i_j;
            state <= s_sync_8;
        end
        s_sync_8: begin
            check_state <= s_sync_8;
            state <= s_send_i_j;
        end
        s_send_i_j: begin
            check_state <= s_send_i_j;
            state <= s_sync_4;
        end
        s_sync_4: begin
            check_state <= s_sync_4;
            state <= s_get_i_j;
        end
        s_get_i_j: begin
            check_state <= s_get_i_j;
            state <= s_sync_19;
        end
        s_sync_19: begin
            check_state <= s_sync_19;
            state <= s_send_k;
        end
        s_send_k: begin
            check_state <= s_send_k;
            state <= s_sync_5;
        end
        s_sync_5: begin
            check_state <= s_sync_5;
            state <= s_get_enc;
        end
        s_get_enc: begin
            check_state <= s_get_enc;
            state <= s_sync_11;
        end
        s_sync_11: begin
            check_state <= s_sync_11;
            state <= s_calc_xor;
        end
        s_calc_xor: begin
            check_state <= s_calc_xor;
            state <= s_sync_7;
        end
        s_sync_7: begin
            check_state <= s_sync_7;
            state <= s_wr_xor;
        end
        s_wr_xor: begin
            check_state <= s_wr_xor;
            state <= s_sync_10;
        end
        s_sync_10: begin
            check_state <= s_sync_10;
            state <= s_sync_20;
        end
        s_sync_20: begin
            check_state <= s_sync_20;
            state <= s_inc_k;
        end
        s_inc_k: begin
            check_state <= s_inc_k;
            state <= s_compare;
        end
        s_sync_21: begin
            check_state <= s_sync_21;
            state <= s_compare;
        end
        s_compare: begin
            check_state <= s_compare;
            if(addr_k == 8'd32) begin
                state <= s_done;
            end else begin
                state <= s_inc_i;
            end
        end
        s_done: begin
            check_state <= s_done;
            decode_progress <= 1'b0;
            state <= s_sync_23;
        end
        
        s_sync_23: state <= s_sync_24; 

        s_sync_24: state <= s_idle;

        default: begin
            state <= state;
        end
    endcase
end

always_ff @(posedge inclk) begin
    case(state)
        s_inc_i: begin
            addr_i <= addr_i + 8'b00000001;
        end
        s_send_i: begin
            address_out_smem <= addr_i;
        end
        s_get_i: begin
            data_i <= data_smem;
        end
        s_calc_j: begin
            addr_j <= addr_j + data_i;
        end
        s_send_j: begin
            address_out_smem <= addr_j;
        end
        s_get_j: begin
            data_j <= data_smem;
        end
        s_wr_j_to_i: begin
            address_out_smem <= addr_i;
            data_out_smem <= data_j;
        end
        s_wr_i_to_j: begin
            address_out_smem <= addr_j;
            data_out_smem <= data_i;
        end
        s_calc_i_j: begin
            addr_ij <= data_i + data_j;
        end
        s_send_i_j: begin
            address_out_smem <= addr_ij;
        end
        s_get_i_j: begin
            data_f <= data_smem;
        end
        s_send_k: begin
            address_out_rom <= addr_k;
        end
        s_get_enc: begin
            data_k <= data_rom;
        end
        s_calc_xor: begin
            data_xor <= (data_f ^ data_k);
        end
        s_wr_xor: begin
            address_out_bmem <= addr_k;
            data_out_bmem <= data_xor;
        end
        s_inc_k: begin
            addr_k <= addr_k + 8'd1;            
        end

        s_done: begin 
            addr_k <= 8'b0;
            addr_i <= 8'b0;
            addr_j <= 8'b0;
        end 
        /*
        s_compare: begin
            if(addr_k == 8'd32) begin
                addr_k <= 8'b0;
            end
        end*/
        
        default: begin
            address_out_smem <= address_out_smem;
            address_out_bmem <= address_out_bmem;
            address_out_rom  <= address_out_rom;
            data_out_bmem    <= data_out_bmem;
            data_out_smem    <= data_out_smem;
        end
    endcase
end

endmodule