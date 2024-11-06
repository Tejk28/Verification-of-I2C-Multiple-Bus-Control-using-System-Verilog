class i2c_driver extends ncsu_component#(.T(i2c_transaction));

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name,parent);
  endfunction

  virtual i2c_if bus;
  i2c_configuration configuration;
  i2c_transaction i2c_trans;
  bit transfer_complete;
  bit [I2C_DATA_WIDTH-1:0] read_data1 [] = new[32];
  bit [I2C_DATA_WIDTH-1:0] read_data2 [];
  bit checkpoint =0; 
  int read_data_start = 'd63;

 
  function void set_configuration(i2c_configuration cfg);
    this.configuration = cfg;
  endfunction

  virtual task bl_put(input T trans);
    #5ns;
    bus.wait_for_i2c_transfer(trans.op, trans.data);

    if(trans.op ==1)
    begin
      if(trans.checkpoint == 0) 
      begin: task_2 
        for(int i=0; i<32; i++)
        begin
          read_data1[i] = 8'd100 + i;
        end
        bus.provide_read_data(read_data1, transfer_complete);
      end: task_2
      else if(trans.checkpoint == 1) 
      begin: task_3
        read_data2 = '{read_data_start};
        read_data_start--;
        bus.provide_read_data(read_data2, transfer_complete);       
      end: task_3

    end
  endtask

  
endclass
