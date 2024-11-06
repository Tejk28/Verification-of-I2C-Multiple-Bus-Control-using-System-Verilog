class i2c_monitor extends ncsu_component#(.T(i2c_transaction));
  
  i2c_configuration configuration;
  virtual i2c_if bus;

  T monitored_trans;
  ncsu_component #(T) agent;
  bit [6:0] i2c_addr;
  bit [7:0] i2c_data[];
  i2c_op_t wren;

  function new(string name="", ncsu_component#(T) parent = null);
    super.new(name,parent);
  endfunction
  
  function void set_configuration(i2c_configuration configuration);
    this.configuration = configuration;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction



  virtual task run();
    forever 
    begin
      monitored_trans = new();
      if(enable_transaction_viewing) 
       begin
       monitored_trans.start_time = $time;
       end
       //bus.monitor();
       bus.monitor(i2c_addr,i2c_data,wren);
       monitored_trans.addr = i2c_addr;
       monitored_trans.data = i2c_data;
       monitored_trans.op = wren;
       if(wren == 0)
       begin
         $display("*********************************************************************************************************");
         $display("time:%t, %m, I2C_BUS WRITE Transfer: addr- %x, data - %x, op -%x         ",$time, i2c_addr, i2c_data, wren);
         $display("*********************************************************************************************************");
       end
       else begin
         $display("*********************************************************************************************************");
         $display("time:%t, %m, I2C_BUS READ Transfer: addr- %x, data - %x, op - %x         ",$time, i2c_addr, i2c_data, wren);
         $display("*********************************************************************************************************");
       end
       agent.nb_put(monitored_trans);
       if(enable_transaction_viewing) 
       begin
         monitored_trans.end_time = $time;
       end

       monitored_trans.convert2string;
      
    end
  endtask

endclass
