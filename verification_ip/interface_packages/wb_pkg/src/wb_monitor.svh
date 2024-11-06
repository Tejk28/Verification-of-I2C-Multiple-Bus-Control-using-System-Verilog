class wb_monitor extends ncsu_component#(.T(wb_transaction));
 
    wb_configuration configuration;
    virtual wb_if#(2,8) bus;
  
    T monitored_trans;
    ncsu_component #(T) agent;
    bit [6:0] addr_mon;
    bit [7:0] data_mon;
    bit wren_mon;
  
    function new(string name="", ncsu_component#(T) parent = null);
      super.new(name,parent);
    endfunction
 
    function void set_configuration(wb_configuration configuration);
      this.configuration = configuration;
    endfunction
 
    function void set_agent(ncsu_component#(T) agent);
      this.agent = agent;
    endfunction
 
    virtual task run();
    bus.wait_for_reset();
    forever
      begin
        monitored_trans = new("monitored_trans");
        if(enable_transaction_viewing)
        begin
         monitored_trans.start_time = $time;
        end
          //wb_transaction object = new();
          bus.master_monitor(addr_mon, data_mon, wren_mon);
          monitored_trans.addr = addr_mon;
          monitored_trans.data = data_mon;
          monitored_trans.wren = wren_mon;
          agent.nb_put(monitored_trans);
          //monitored_trans.convert2string;
      end
    endtask

    task get_read_data(input bit[1:0] addr, output bit[7:0] data);
      bus.master_read(addr, data); 
    endtask
 
endclass

