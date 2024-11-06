`timescale 1ns / 10ps


module top();

import ncsu_pkg::*;
import i2cmb_env_pkg::*;
import i2c_pkg::*;
import wb_pkg::*;
import parameter_pkg::*;


bit  clk;
bit  rst;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
triand  [NUM_I2C_BUSSES-1:0] sda;

wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;

wire [NUM_I2C_BUSSES-1:0] scl_i;
wire [NUM_I2C_BUSSES-1:0] sda_i;
wire [NUM_I2C_BUSSES-1:0] sda_o;
bit [7:0] write_data [];
bit [WB_ADDR_WIDTH-1:0] adr_m;
bit [WB_DATA_WIDTH-1:0] data_m;
bit we_m;
bit [7:0] addr_mon;
bit [I2C_DATA_WIDTH-1:0] data_mon[];
int op_mon;
i2c_op_t op;

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
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  .irq_i(irq),
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
	.sda_o(sda)
);


// ****************************************************************************
i2cmb_test u_test;


// Define the flow of the simulation
initial begin: test_flow

  ncsu_config_db#(virtual i2c_if)::set("u_test.env.i2c_agt", i2c_bus);
  ncsu_config_db#(virtual wb_if#(2,8))::set("u_test.env.wb_agt",wb_bus);

  u_test = new("u_test",null);

  $timeformat(-6,2," us",5);
  //wait(rst == 1)
  u_test.run();
 
  $finish;

end: test_flow

//*****************************************************************************

endmodule
