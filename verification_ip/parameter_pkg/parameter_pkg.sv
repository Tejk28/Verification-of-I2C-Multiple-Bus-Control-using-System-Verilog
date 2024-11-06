package parameter_pkg;

 typedef enum logic { 
         WRITE=1'b0, 
         READ = 1'b1 
 } i2c_op_t;

 parameter int WB_ADDR_WIDTH = 2;
 parameter int WB_DATA_WIDTH = 8;
 parameter int NUM_I2C_BUSSES = 1;
 parameter int I2C_ADDR_WIDTH = 7;
 parameter int I2C_DATA_WIDTH = 8;

 
endpackage
