class i2c_agent extends ncsu_component#(.T(i2c_transaction));
  
  i2c_configuration configuration;
  i2c_driver driver;
  i2c_monitor monitor;
  i2c_coverage coverage;
  ncsu_component #(T) subscribers[$];

  virtual i2c_if bus;

  function new(string name="", ncsu_component_base parent = null);
    super.new(name,parent);
    if(!(ncsu_config_db#(virtual i2c_if)::get("u_test.env.i2c_agt", this.bus)))
    begin
    $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name");
    $finish;
    end 
  endfunction
  
  virtual function void set_configuration(i2c_configuration configuration);
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

  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction

  virtual task run();
    fork
      monitor.run();
    join_none
  endtask

endclass
