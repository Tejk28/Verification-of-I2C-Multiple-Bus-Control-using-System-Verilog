class wb_transaction extends ncsu_transaction;
   `ncsu_register_object(wb_transaction)
 
    bit[7:0] data;
    bit ack, start, stop;
    bit wren;
    bit[6:0] addr;

    function new(string name="");
      super.new(name );
    endfunction
 
 
    function void print_wb_transaction(wb_transaction trans);
      //foreach(trans.data[i])
      //begin
        $display("Wb_mointor: time:\t, op: %d, addr: %x, data: %x \n",$time, trans.wren, trans.addr, trans.data);
      //end
    endfunction

    virtual function string convert2string();
     //return {super.convert2string(),$sformatf("WB: Time %t : W/R : %d , Addr: 0x%x, Data: 0x%x \n",$time, wren, addr, data)};
     return {$sformatf("WB: Time %t : W/R : %d , Addr: 0x%x, Data: 0x%x \n",$time, wren, addr, data)};
    endfunction
 

endclass

