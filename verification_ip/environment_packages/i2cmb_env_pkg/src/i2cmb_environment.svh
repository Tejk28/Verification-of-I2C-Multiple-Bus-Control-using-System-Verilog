class i2cmb_environment extends ncsu_component;

  i2cmb_env_configuration configuration;
  i2c_agent i2c_agt;
  wb_agent wb_agt;
  i2cmb_predictor pred;
  i2cmb_scoreboard scbd;
  i2cmb_coverage coverage;

  function new(string name = "", ncsu_component#(T)  parent = null);
    super.new(name,parent);
  endfunction
 
  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction
 
  virtual function void build();
    $display("%t: %m called", $time);
    i2c_agt = new("i2c_agt",this);
    i2c_agt.set_configuration(configuration.i2c_agent_config);
    i2c_agt.build();
    wb_agt = new("wb_agt",this);
    wb_agt.set_configuration(configuration.wb_agent_config);
    wb_agt.build();
    pred  = new("pred", this);
    pred.set_configuration(configuration);
    pred.build();
    scbd  = new("scbd", this);
    scbd.build();
    coverage = new("coverage", this);
    coverage.set_configuration(configuration);
    coverage.build();
    wb_agt.connect_subscriber(coverage);
    wb_agt.connect_subscriber(pred);
    pred.set_scoreboard(scbd);
    i2c_agt.connect_subscriber(scbd);
  endfunction

  
  function ncsu_component#(i2c_transaction) get_i2c_agent();
    $display("%t: %m called", $time);
    return i2c_agt;
  endfunction
 
  function wb_agent get_wb_agent();
    $display("%t: %m called", $time);
    return wb_agt;
  endfunction
 
  virtual task run();
    $display("%t: %m called", $time);
    i2c_agt.run();
    wb_agt.run();
  endtask

endclass
