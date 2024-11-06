class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

i2cmb_env_configuration configuration;
wb_transaction coverage_transaction;


function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
endfunction

function new(string name ="", ncsu_component_base  parent = null);
  super.new(name,parent);
endfunction

endclass
