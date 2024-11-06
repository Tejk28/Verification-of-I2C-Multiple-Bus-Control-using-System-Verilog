class wb_agent extends ncsu_component#(.T(wb_transaction));
  
    wb_configuration configuration;
    wb_driver driver;
    wb_monitor monitor;
    wb_coverage coverage;
    ncsu_component #(T) subscribers[$];
  
    virtual wb_if#(2,8) bus;
  
    function new(string name="", ncsu_component_base parent = null);
      super.new(name,parent);
      if(!(ncsu_config_db#(virtual wb_if#(2,8))::get("u_test.env.wb_agt", this.bus)))
      begin
      $display("wb_agent::ncsu_config_db::get() call for BFM handle failed for name");
      $finish;
      end
    endfunction
 
    function void set_configuration(wb_configuration configuraion);
      this.configuration = configuration;
    endfunction
 
    virtual function void build();
      driver = new("driver",this);
      driver.set_configuration(configuration);
      driver.build();
      driver.bus = this.bus;
      monitor = new("monitor",this);
      monitor.set_configuration(configuration);
      monitor.set_agent(this);
      monitor.enable_transaction_viewing =1;
      monitor.build();
      monitor.bus = this.bus;
      coverage = new("coverage",this);
      coverage.set_configuration(configuration);
      coverage.build();
      connect_subscriber(coverage);
      
    endfunction
 
    virtual function void nb_put(T trans);
      foreach (subscribers[i]) subscribers[i].nb_put(trans);
    endfunction
 
    virtual task bl_put(wb_transaction trans);
      driver.bl_put(trans);
    endtask

    virtual task bl_put_no_intr(wb_transaction trans);
      driver.bl_put_no_intr(trans);
    endtask
 
    virtual function void connect_subscriber(ncsu_component#(T) subscriber);
      subscribers.push_back(subscriber);
    endfunction
 
       virtual task run();
      fork
        monitor.run();
      join_none
 
    endtask

    task get_wb_read_data(input bit[1:0]addr, output bit[7:0]data);
      monitor.get_read_data(addr, data);
    endtask

  endclass

