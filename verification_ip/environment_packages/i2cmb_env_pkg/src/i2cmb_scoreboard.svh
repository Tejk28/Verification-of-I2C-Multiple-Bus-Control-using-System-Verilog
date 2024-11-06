class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));


  T trans_in;
  T trans_out;
  //int arr_size;


  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction


  virtual function void nb_transport(input T input_trans, output T output_trans);

    trans_in = input_trans;
    //trans_in.in_data = new[trans_in.data.size()];
    //foreach(trans_in.data[i])
      //trans_in.in_data[i] = trans_in.data[i]; 
    $display({get_full_name()," nb_transport: expected transaction ",input_trans.convert2string()});
    output_trans = trans_out;

  endfunction

  virtual function void nb_put(T trans);

    $display({get_full_name()," nb_put: actual transaction ",trans.convert2string()});
  
  endfunction
endclass

