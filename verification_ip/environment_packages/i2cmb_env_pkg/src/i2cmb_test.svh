class i2cmb_test extends ncsu_component#(.T(i2c_transaction));
//class i2cmb_test extends ncsu_component;

i2cmb_env_configuration cfg;
i2cmb_environment env;
i2cmb_generator gen;
string test_name;

 function new(string name="", ncsu_component_base parent = null);
  super.new(name, parent);

  if(!$value$plusargs("GEN_TEST_TYPE=%s", test_name)) begin
   $display("FATAL: +GEN_TEST_TYPE plusarg not found in command line");
   $fatal;
  end  

  $display("%m GEN_TEST_TYPE = %s",test_name);
  cfg=new("cfg");
  //cfg.i2cmb_coverage();
  env=new("env");
  env.set_configuration(cfg);
  env.build();
  gen=new("gen");
  gen.set_i2c_agent(env.get_i2c_agent());
  gen.set_wb_agent(env.get_wb_agent());
   
 endfunction

 virtual task run();
  env.run();
  if(test_name == "invalid_test") 
    gen.invalid_test();
  else if(test_name == "default_values")
    gen.default_values();
  else if(test_name == "random_write")
    gen.random_write();
  else if(test_name == "fsm_test")
    gen.fsm_test();
  else
    gen.run();
  
 endtask


endclass
