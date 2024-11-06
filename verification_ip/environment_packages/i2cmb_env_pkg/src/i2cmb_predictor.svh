class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

  ncsu_component#(i2c_transaction) scoreboard;
  i2c_transaction transport_trans, send_trans;
  i2cmb_env_configuration configuration;

  bit start_detected =0;
  bit addr_captured =0;
  bit [1:0] addr;
  i2c_op_t op;
  bit [7:0] temp_arr[];
  int arr_size;
  

  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);

    
    //Start is predicted using CMDR command, if Start command is sent BY CMDR
    if((trans.addr == 2'b10) && (trans.data[2:0] == 3'b100) && (start_detected == 1'b0))
    begin: start_detection
     start_detected = 1'b1;
     $cast(send_trans, ncsu_object_factory::create("i2c_transaction"));
     scoreboard.nb_transport(send_trans, transport_trans);
     $display("\n");
     $display({get_full_name()," ",trans.convert2string()});
    end: start_detection


    //Restart detection by predictor
    if((trans.addr == 2'b10) && (trans.data[2:0] == 3'b100) && (start_detected == 1'b1))
    begin: Restart_detection
     start_detected = 1'b1;
     $cast(send_trans, ncsu_object_factory::create("i2c_transaction"));
     scoreboard.nb_transport(send_trans, transport_trans);
     $display({get_full_name()," ",trans.convert2string()});
    end: Restart_detection


    //stop detection by predictor
    else if((trans.addr == 2'b10) && (trans.data[2:0] == 3'b101))
    begin: stop_detection
     start_detected = 1'b0;
     addr_captured = 1'b0;
     $cast(send_trans, ncsu_object_factory::create("i2c_transaction"));
     scoreboard.nb_transport(send_trans, transport_trans);
    end: stop_detection
    
    //addr and data  
    if(start_detected == 1'b1) begin
      if(trans.addr == 2'b01) begin
        if(addr_captured == 1'b0) begin
          addr_captured = 1'b1;
          send_trans.op = i2c_op_t'(trans.data[0]);
          send_trans.addr = trans.data[7:1];
          $display({get_full_name()," ",trans.convert2string()});
          scoreboard.nb_transport(send_trans, transport_trans);
          $display("\n");
        end
        else begin
          send_trans.data = temp_arr;
          arr_size = temp_arr.size() +1;
          temp_arr = new[arr_size](temp_arr);
          temp_arr[arr_size -1] = trans.data;
          send_trans.op = i2c_op_t'(trans.data[0]);
          $display({get_full_name()," ",trans.convert2string()});
          scoreboard.nb_transport(send_trans, transport_trans);
          $display("\n");

        end
      end
    end 

  endfunction

endclass

