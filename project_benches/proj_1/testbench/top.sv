`timescale 1ns / 10ps

//`include "../../../verification_ip/interface_packages/i2c_pkg/src/i2c_if.sv"
//i2c_if_sv_unit::i2c_op_t op;

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;
parameter int I2C_DATA_WIDTH = 8;
parameter int I2C_ADDR_WIDTH = 7;

bit  clk;
bit  rst;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
triand  [NUM_I2C_BUSSES-1:0] sda;

wire [NUM_I2C_BUSSES-1:0] scl_i;
wire [NUM_I2C_BUSSES-1:0] sda_i;
wire [NUM_I2C_BUSSES-1:0] sda_o;
bit [I2C_ADDR_WIDTH-1:0] l_addr;

bit [7:0] write_data [];
bit transfer_complete;
int checkpoint;
bit [WB_ADDR_WIDTH-1:0] adr_m;
bit [WB_DATA_WIDTH-1:0] data_m;
bit we_m;
bit [7:0] addr_mon;
bit [I2C_DATA_WIDTH-1:0] data_mon[];
int op_mon;
int op;
int alternate_write =64;

// ****************************************************************************
// Clock generator
initial begin: clk_gen
	clk = 1'b0;
	forever begin 
	#10 clk = ~clk;
	end

end: clk_gen 

// ****************************************************************************
// Reset generator
initial begin: rst_gen
	#113ns rst = 1'b0;
end: rst_gen

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript


initial begin: wb_monitoring
    @(clk);
    forever 
    begin
      wb_bus.master_monitor(adr_m, data_m, we_m);
      if(we_m)
      begin
	$display("time:%0t - From Wishbone WRITE TRANSFER address: %h, data: %h, we: %h",$time, adr_m, data_m, we_m);
	
        $display("time:%0t - From Wishbone READ TRANSFER address: %h, data: %h, we: %h",$time, adr_m, data_m, we_m);
      end  
    end
end: wb_monitoring


// ****************************************************************************
// I2C monitor display
initial begin: i2c_monitor
addr_mon = 'd0;
   @(clk);
   forever
   begin
     i2c_bus.monitor(addr_mon, data_mon, op_mon);
     $write("\n\ntime:%0t - %s  Address: %h, Data: %h\n\n ",$time, (op_mon ? "I2C Bus READ Transfer" : "I2C Bus WRITE Transfer"), addr_mon, data_mon[0] );      

   end   
end: i2c_monitor 


// ****************************************************************************
// ****************************************************************************
// I2C task operation

initial begin

 bit [I2C_DATA_WIDTH-1:0] read_data1 [];
 bit [I2C_DATA_WIDTH-1:0] read_data2 [];
 int read_data_start;
 read_data1 = new[32];
// read_data2 = new[1];
 read_data_start = 'd63;
// read_data2 = new[64];
 forever 
   begin

    // transfer_complete = 1'b0;
     i2c_bus.wait_for_i2c_transfer(op, write_data);
     //$display("Time = %t, wait for i2c transfer over",$time);
     //$display("Time = %t, operation is %d",$time,op); 
     //$display("Time = %t, checkpoint is %d",$time,checkpoint);
     //$display("Time = %t, writes transfer is = %p",$time,write_data);       
     if(op == 1)
     begin
        if(checkpoint == 1)
        begin
           //$display("inside checkpoint1 ");
           //for(int i=0; i<64;i++)
           //begin
           // read_data2[i] = 8'd63 - i;
           //$display("read data 1 at loop no:%d is %p",i,read_data2);
           //end
           read_data2 = '{read_data_start};
           read_data_start--;
           i2c_bus.provide_read_data(read_data2, transfer_complete);
           //$display("************************************************************Read transfer for alernate read is = %p",read_data2);
           //$display("i2c provide read data when task 3 is called is over");
           
        end
        else if(checkpoint == 0)
        begin
               
           for(int i = 0; i < 32; i++)
           begin
	     read_data1[i] = 8'd100 + i;
           end
           i2c_bus.provide_read_data(read_data1, transfer_complete);
           //$display("Read transfer is = %p",read_data1);
           //$display("i2c provide read data when task 2 is called is over");
        end
     end
     //else if(op == 0)
     //begin
     //   $display("inside else block");
     //   foreach(write_data[i]) begin
     //   $display("***********************************************writes transfer is = %d",write_data);
     //   end       
     //end
     /*
     if(op == 0)
        $display("writes transfer is = %p",write_data);       
     else if(op == 1)
     begin
      
        for(int i = 0; i < 32; i++)
        begin
	read_data1[i] = 8'd100 + i;
        end
        $display("i2c provide read data in called from top.sv ");
        i2c_bus.provide_read_data(read_data1, transfer_complete);
        $display("Read transfer is = %p",read_data1);
        $display("i2c provide read data is over");
       
     end
     */
   end

end

// ****************************************************************************
// Define the flow of the simulation
initial begin: test_flow

logic [WB_DATA_WIDTH-1:0] read_data;
read_data = 'd0;
//int i;

$display("************************************************************\n");
$display("********************-I2C bus Control-***********************\n");


//@(clk);
//enabling IICMB core and interrupts

wb_bus.master_write(0, 8'b11xxxxxx);


//Write byte 0x05 to the DPR. This is the ID of desired I2C bus
wb_bus.master_write(1, 8'b00000101);


//Write byte “xxxxx110” to the CMDR. This is Set Bus command
wb_bus.master_write(2, 8'bxxxxx110);


//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

//--------------------- write 0 to 31 to slave --------------------------

$display("------------------------------------------------------------");
$display("Task 1: writing 32 incrementing values from 0 to 32 to slave");
$display("------------------------------------------------------------");

//Write byte “xxxxx100” to the CMDR. This is Start command
wb_bus.master_write(2, 8'bxxxxx100);


//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

//Write byte 0x44 to the DPR. 
wb_bus.master_write(1, 8'h44);
//Write byte “xxxxx001” to the CMDR. This is Write command.
wb_bus.master_write(2, 8'bxxxxx001);

//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
wait(irq || read_data[7] || read_data[6]) begin
wb_bus.master_read(2, read_data);
end

//clear ack
wait(irq || read_data[7])
begin
wb_bus.master_read(2, read_data);
end
//$display("time: %0t, clearing ack 1, i.e after writing 44 to DPR",$time);

for(int i=0; i < 33; i++)
begin
  wb_bus.master_write(1, i);
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  wb_bus.master_write(2, 8'bxxxxx001);

  // wb_bus.master_monitor(adr_m, data_m, we_m);
  // $display("address: %x, data: %x, we: %x", adr_m, data_m, we_m);

  //Wait for interrupt or until DON bit of CMDR reads '1'.
  wait(irq || read_data[7]) begin
  wb_bus.master_read(2, read_data);
  end

  //clearing ack
  wait(irq || read_data[7]) begin
  wb_bus.master_read(2, read_data);
  end

 // $display("time: %0t, loop ended for %d time",$time,i);
end

//wb_bus.master_monitor(adr_m, data_m, we_m);
//$display("address: %x, data: %x, we: %x", adr_m, data_m, we_m);
//$display("----------stop sending the 32 values------------");


//Write byte “xxxxx101” to the CMDR. This is Stop command.
wb_bus.master_write(2, 8'bxxxxx101);

//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end
//$display("time:%0t, wait for interrupt, after stop command",$time);


//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

checkpoint =0;

//#50000ns;

$display("---------------------------------------------------------------");
$display("Task 2: Reading 32 incrementing values from 100 to 131 to slave");
$display("---------------------------------------------------------------");
//---------------Read back 100 to 131-----------------


//enable core
wb_bus.master_write(0, 8'b11xxxxxx);

//write 5 to DPR 
wb_bus.master_write(1, 8'b00000101);

wb_bus.master_write(2, 8'bxxxxx110);


//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

//Write byte “xxxxx100” to the CMDR. This is Start command
wb_bus.master_write(2, 8'bxxxxx100);


//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

//read command to slave 0x22
wb_bus.master_write(1, 8'h45);
$display("time:%0t, sending address",$time);

//Write byte “xxxxx001” to the CMDR. This is Write command.
wb_bus.master_write(2, 8'bxxxxx001);

//wait for intrrupt
wait(irq || read_data[7] || read_data[6]) begin
wb_bus.master_read(2, read_data);
end

//clearing ack
wait(irq || read_data[7])
begin
wb_bus.master_read(2, read_data);
end

//read 32
for(int i=0;i<31; i++)
begin
  wb_bus.master_write(2, 8'bxxxxx010);

  wait(irq || read_data[7]) begin
  wb_bus.master_read(2, read_data);
  end
 
 //clearing ack
  wait(irq || read_data[7])
  begin
  wb_bus.master_read(2, read_data);
  end
 
   wb_bus.master_read(1, read_data);
 // $display("time: %0t, data read : %d",$time,read_data);
  
end

wb_bus.master_write(2, 8'bxxxxx011);
  
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

wb_bus.master_read(1, read_data);
//$display("time:%0t, data read after nack : %d",$time, read_data);

//------------------restart check-------------------------

//Write byte “xxxxx100” to the CMDR. This is Start command
//wb_bus.master_write(2, 8'bxxxxx100);

//-------------------------------------------------------

//$display("time:%0t, sending stop for reading 32 bits",$time);
//Write byte “xxxxx101” to the CMDR. This is Stop command.
wb_bus.master_write( 2, 8'bxxxxx101);

//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end


//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end
//--------------------Task two complete---------------------

checkpoint =1;
//#50000ns;

//----------------------------------------------------------
//----------------Alternate write and read------------------

$display("---------------------------------------------------------------");
$display("   Task 3: 64 Alternate Reads and Writes incrementing values   ");
$display("---------------------------------------------------------------");

//enable core
wb_bus.master_write(0, 8'b11xxxxxx);

//write 5 to DPR 
wb_bus.master_write(1, 8'b00000101);

//set bus ID
wb_bus.master_write(2, 8'bxxxxx110);


//wait(irq);
//wb_bus.master_read(2, read_data);

//Wait for interrupt or until DON bit of CMDR reads '1'.
wait(irq || read_data[7]) begin
wb_bus.master_read(2, read_data);
end

for (int i=0; i<64;i++)
begin
   
   //for write

   //$display("Time = %t: ALTERNATE WRITE = %d",$time,i);
   //Write byte “xxxxx100” to the CMDR. This is Start command
   //$display("time:%0t, yoyo1",$time);
   wb_bus.master_write(2, 8'bxxxxx100);
   //$display("time:%0t, yoyo2",$time);
   //wait(irq);
   //wb_bus.master_read(2, read_data);

   // Wait for interrupt or until DON bit of CMDR reads '1'.
   //$display("time:%0t, yoyo3",$time);
   wait(irq || read_data[7]) begin
   wb_bus.master_read(2, read_data);
   end
   //$display("time:%0t, yoyo4",$time);
  
   // Wait for interrupt or until DON bit of CMDR reads '1'.
   //$display("time:%0t, yoyo5",$time);
   wait(irq || read_data[7]) begin
   wb_bus.master_read(2, read_data);
   end
   //$display("time:%0t, yoyo6",$time);

   //read command to slave 0x22
   //$display("time:%0t, sending address for alternate write ",$time);
   wb_bus.master_write(1, 8'h44);
   wb_bus.master_write(2, 8'bxxxxx001);
   //$display("time:%0t, sent address for alternate write ",$time);

  // Wait for interrupt or until DON bit of CMDR reads '1'.
   //$display("time:%0t, yoyo7",$time);
   wait(irq || read_data[7]) begin
   wb_bus.master_read(2, read_data);
   end
   //$display("time:%0t, yoyo8",$time);
  
   // Wait for interrupt or until DON bit of CMDR reads '1'.
   //$display("time:%0t, yoyo9",$time);
   wait(irq || read_data[7]) begin
   wb_bus.master_read(2, read_data);
   end
   //$display("time:%0t, yoyo10",$time);

   //Write byte “xxxxx001” to the CMDR. This is Write command.
   //wait(irq);
   //wb_bus.master_read(2, read_data);

   // wait for intrrupt
   //wait(irq || read_data[7]) begin
   //wb_bus.master_read(2, read_data);
   //end

   //clearing ack
   //wait(irq || read_data[7])
   //begin
   //wb_bus.master_read(2, read_data);
   //end

   //$display("writing: %d",alternate_write);   
   wb_bus.master_write(1, alternate_write);
   wb_bus.master_write(2, 8'bxxxxx001);
   alternate_write++ ;
   //$display("time:%0t, yoyo10",$time);
   
  // Wait for interrupt or until DON bit of CMDR reads '1'.
   //$display("time:%0t, yoyo10",$time);
   wait(irq || read_data[7]) begin
   wb_bus.master_read(2, read_data);
   end
   //$display("time:%0t, yoyo10",$time);

   //$display("time:%0t, yoyo10",$time);
   wait(irq || read_data[7]) begin
   wb_bus.master_read(2, read_data);
   end
   //$display("time:%0t, yoyo10",$time);
   
   //Write byte “xxxxx101” to the CMDR. This is Stop command.
  // wb_bus.master_write(2, 8'bxxxxx101);

   //Wait for interrupt or until DON bit of CMDR reads '1'.
   //wait(irq);
   //wb_bus.master_read(2, read_data);
    

    //Wait for interrupt or until DON bit of CMDR reads '1'.
   // #50000ns;

    //----------------for alternate read---------------------
   
    // This is Start command
   //$display("Time = %t: ALTERNATE READ = %d",$time,i);
   wb_bus.master_write(2, 8'bxxxxx100);
   //wait(irq);
   //wb_bus.master_read(2, read_data);

    //Wait for DON.
    wait(irq || read_data[7]) begin
    wb_bus.master_read(2, read_data);
    end
  
    // Wait for interrupt or until DON bit of CMDR reads '1'.
    wait(irq || read_data[7]) begin
    wb_bus.master_read(2, read_data);
    end

    //write address to slave 0x22
    wb_bus.master_write(1, 8'h45);
    //$display("time:%0t, sending address for alternate read ",$time);

    //Write byte “xxxxx001” to the CMDR. This is Write command.
    wb_bus.master_write(2, 8'bxxxxx001);
    //wait(irq);
    //wb_bus.master_read(2, read_data);
    
    //wait for intrrupt
    wait(irq || read_data[7] || read_data[6]) begin
    wb_bus.master_read(2, read_data);
    end

    ////clearing ack
    wait(irq || read_data[7])
    begin
    wb_bus.master_read(2, read_data);
    end
   
    // Read with NACK 
    wb_bus.master_write(2, 8'bxxxxx011);
    wait(irq || read_data[7])
    begin
    wb_bus.master_read(2, read_data);
    end
    
    wait(irq || read_data[7])
    begin
    wb_bus.master_read(2, read_data);
    end
    
    wb_bus.master_read(1, read_data);
    //$display("time:%0t, alternate read is : %d",$time, read_data);

    //stop command 
    wb_bus.master_write( 2, 8'bxxxxx101);

    //Wait for interrupt or until DON bit of CMDR reads '1'.
   //wait(irq);
   //wb_bus.master_read(2, read_data);

    wait(irq || read_data[7]) begin
    wb_bus.master_read(2, read_data);
    end

    //Wait for interrupt or until DON bit of CMDR reads '1'.
    wait(irq || read_data[7]) begin
    wb_bus.master_read(2, read_data);
    end

end

end: test_flow


// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

//*****************************************************************************
//Instantiate I2_C
i2c_if #(
	.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
	.I2C_DATA_WIDTH(I2C_DATA_WIDTH),
	.NUM_I2C_BUSSES(NUM_I2C_BUSSES)
	)
i2c_bus(
	.scl_i(scl),
	.sda_i(sda),
//	.scl_o(scl_i),
	.sda_o(sda)
//	.SDA(sda),
//	.SCL(scl)
);
endmodule
