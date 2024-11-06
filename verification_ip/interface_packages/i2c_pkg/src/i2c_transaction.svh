class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction) 
    
    rand bit[7:0] data[]; 
    bit ack, start, stop, checkpoint;
    i2c_op_t op;
    rand bit[6:0] addr;
    bit [7:0] int_data[];

    function new(string name="");
      super.new();
    endfunction

    function bit compare(i2c_transaction rhs);
      return((this.addr == rhs.addr) &&
             (this.data == rhs.data) &&
             (this.op   == rhs.op));
    endfunction


    virtual function string convert2string();
         return{ $sformatf("I2C: time:%t, op: %d, addr: %x, data: %x \n",$time, op, addr, data)};
    endfunction
endclass
