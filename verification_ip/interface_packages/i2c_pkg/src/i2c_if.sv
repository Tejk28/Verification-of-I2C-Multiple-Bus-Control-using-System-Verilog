
interface i2c_if #(
	int I2C_ADDR_WIDTH = 7,
	int I2C_DATA_WIDTH = 8,
	int NUM_I2C_BUSSES =1
)

(
	input wire  [NUM_I2C_BUSSES-1:0] scl_i,
	input wire  [NUM_I2C_BUSSES-1:0] sda_i,
	output tri  [NUM_I2C_BUSSES-1:0] sda_o
	
);

import parameter_pkg::*;

parameter bit ACK = 1'b0;
parameter bit NACK = 1'b1;
parameter bit slave_address = 7'h22;

bit restart;
bit stop_signal;
bit restart_signal;
bit start_signal;
bit addr_captured;

bit sda_oe;
bit value_to_be_driven;
bit variable;
int start_bit=0;
int stop_bit;
bit a_nack;
bit [I2C_DATA_WIDTH-1:0] data_to_read;

bit [I2C_ADDR_WIDTH:0] l_addr;
bit [I2C_DATA_WIDTH-1:0] l_data;
//monitor flag
int restart_m =0;
bit address_capture_flag;
bit provide_data_flag;
bit data_capture_flag;

assign sda_o = sda_oe ? 1'bz : value_to_be_driven;

task send_ack();
     @(negedge scl_i);
     sda_oe = ACK;
     value_to_be_driven = 1'b0;
     @(negedge scl_i);
     sda_oe = NACK;
endtask: send_ack

task reset_bus();
	sda_oe = 1'b1;
endtask

//****************************************************************************************************************
//                                  Task 1: Wait for I2C Tranfer
// Start, Stop, Restart,  Address Capture and Data to write is detected in this task. 
// Operation is determined by the 0th bit of captured address, if bit is 0, op = Write and task is continued, else
//if bit is 1, operation dedtected is Read, and wait of I2C task is terminated by disabling the fork.
//Start is dedected and the three threads of Stop and Restart Data to be written is done.
//****************************************************************************************************************

task wait_for_i2c_transfer(output i2c_op_t op,
			   output bit [I2C_DATA_WIDTH-1:0] write_data []);

  logic RW_bit;
  int array_size;
  op = WRITE;
  reset_bus();
  start_bit = 0;
  stop_signal = 0;
  restart_signal = 0;
  start_signal =0;


  if(start_bit == 0)
    begin
    while(1)
      begin
       @(negedge sda_i);
       if(scl_i == 1)
        begin
             $display("\ntime %0t,------------- Start condition detected-------------\n",$time);
             start_signal = 1'b1;
	     break;
        end
       end
    end 
  start_bit = 0;


  while(1)
    begin//while loop
     for(int i =I2C_ADDR_WIDTH; i>= 0; i--)
      begin
        @(posedge scl_i);
        l_addr[i] = sda_i;
      end
      
      address_capture_flag = 1'b1;
      $display("\ntime =%0t,------------------- Address capture: %h--------------------\n",$time, l_addr);

      send_ack();

      if(l_addr[0] == 1'b0)
      begin
        op = WRITE;
      end
      else
      begin
        op = READ;
        break;
      end


      if(op == WRITE)
      begin
            fork
                  begin
                        forever
                        begin
	                @(posedge sda_i);
                            if(scl_i == 1)
                            begin
                            restart_signal = 0;
                            stop_signal = 1;
                            $display("\ntime:%0t,---------------------Stop condition detected----------------\n",$time);
                            break;
                            end
                        end
                  end
        
                  begin
                        forever
                        begin
                            for(int i =I2C_DATA_WIDTH-1; i>=0; i--)
                            begin
                                @(posedge scl_i);
                                l_data[i] = sda_i;
                            end
                            
                            if (restart_signal == 1'b0) begin
                               array_size = write_data.size();
                               write_data = new[array_size+1](write_data);
                               write_data[array_size] = l_data;
                               send_ack();

                             data_capture_flag = 1'b1;
                            end
                          
                        end
                  end
            
                  begin
                       forever
                       begin
                       @(negedge sda_i);
                           if(scl_i == 1)
                           begin
                               restart_signal = 1;
                               value_to_be_driven=1'b0;
                               $display("time: %0t,\n--------------------- Restart condition detected------------------\n",$time);
                               break;

                           end
                       end
                        for(int i =I2C_ADDR_WIDTH; i>= 0; i--)
	                 begin
	                  @(posedge scl_i);
	                  l_addr[i] = sda_i;
	                
	                 end
                       address_capture_flag = 1'b1;
	               $display("time = %0t,\n----------------- Address capture: %h-------------------\n",$time, l_addr);
                       if(l_addr[0] == 1'b0)
                       begin
                          op = WRITE;
                       end

                       else
                       begin
                          op = READ;
                       end

                        send_ack();
                  end
         


           join_none
           wait(stop_signal || op == READ)
           disable fork;
            

       end
      break;

   end//while end

endtask: wait_for_i2c_transfer 


//****************************************************************************************************************
//                                          Task 2: Provide read Data
//Task is called when read is to be done by DUT, Data is run in an array and based upon ACK or NACK received task 
//is stopped and transfer complete flag is returned.
//****************************************************************************************************************

task provide_read_data ( input bit [I2C_DATA_WIDTH-1:0] read_data [], 

                         output bit transfer_complete);

  int trans_complete_flag;
  //value_to_be_driven =1'b0;
  data_to_read = 8'b00000000;

  for(int i=0; i< read_data.size(); i++)
  begin
    data_to_read  = read_data[i];
    for(int j= I2C_DATA_WIDTH-1 ; j>=0; j--)
    begin
      
      @(posedge scl_i); // to be removed as change done for proj_2
      sda_oe =0;
      value_to_be_driven = data_to_read[j];
      @(negedge scl_i);
    end
    provide_data_flag =1'b1;
    sda_oe = 1;

    @(posedge scl_i)
      if(sda_i ==ACK )
      begin
        @(negedge scl_i); //added for change for proj_2
        trans_complete_flag =0;
      end
      else if(sda_i == NACK) 
      begin
        forever
        begin // Stop condition detected block
          @(posedge sda_i);
          if(scl_i == 1)
          begin
            //sda_oe = 1'b0;
            trans_complete_flag = 1'b1;
            start_bit = 0;
            $display("\n------------------------stop conditiion detected----------------------\n");
            break;
          end
        end
      end
  end
transfer_complete = trans_complete_flag;


endtask:provide_read_data

//****************************************************************************************************************
//                                Task 3: Monitor
// In this task, the address is recorded and set to the output  once the start condition is polled, not in restart.
//The op is set to read or write, and the mode has been collected.
//The bus's data is recorded and sent to the output array "data" until a halt or restart is recognized.
//****************************************************************************************************************

task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr, 
               output bit [I2C_DATA_WIDTH-1:0] data [],
               output i2c_op_t op );

 
  bit RW_bit_flag;
  bit mon_start_detected;
  bit mon_stop_detected;
  addr = 8'h0;


  fork
  
   begin
        while(1)
        begin
          @(negedge sda_i);
          if(scl_i == 1)
          begin
             if(mon_start_detected == 1'b0 && mon_stop_detected == 1'b1) begin
	       mon_start_detected = 1'b1;
               mon_stop_detected = 1'b0;
               break;
             end //mon_start_detected loop

             else if(mon_start_detected == 1'b1 && mon_stop_detected == 1'b0) begin
	       mon_start_detected = 1'b1;
               mon_start_detected = 1'b0;
               break;

             end //restart detected 
          end //if scl_i loop
        end //while loop
    end //thread 1
   

    begin
      wait(address_capture_flag)
      {addr, RW_bit_flag} = l_addr;

      address_capture_flag = 1'b0;
      if(RW_bit_flag == 1'b0)
      begin
        op = WRITE;
      end         
      else
      begin
        op = READ;
      end
    end

    begin
      wait(data_capture_flag)

      data_capture_flag = 1'b0;
      data = new[1];
      data[0] = l_data;

    end

    begin
      wait(provide_data_flag)
      provide_data_flag = 1'b0;
      data = new[1];
      data[0] = data_to_read;
 
    end
   
      begin: stop_condition_thread
        forever
        begin:forever_loop
	 @(posedge sda_i);
         if(scl_i == 1)
         begin
           restart_m = 0;
           mon_stop_detected = 1'b1;
           mon_start_detected = 1'b0;
           break;
         end
        end: forever_loop
      end
  

  join_any
  disable fork;

endtask: monitor


endinterface: i2c_if


