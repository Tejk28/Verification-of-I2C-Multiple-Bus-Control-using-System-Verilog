class wb_driver extends ncsu_component#(.T(wb_transaction));
  
     virtual wb_if#(2,8) bus;
     wb_transaction wb_trans;
     
     wb_configuration configuration;
     function new(string name = "", ncsu_component_base parent = null);
       super.new(name,parent);
     endfunction
 
     function void set_configuration(wb_configuration cfg);
      configuration = cfg;
     endfunction
 
     virtual task bl_put(input T trans);
      //#5ns;
      //$display("%t %m, called",$time);
      //$display("%t %m, op is: %x",$time, trans.wren);
      if(trans.wren == 0) begin
        bus.master_write(trans.addr, trans.data);
        //$display("%m , addr= %x, data=%x", trans.addr, trans.data);
        bus.wait_for_interrupt();
      end
      else begin
        bus.master_read(trans.addr, trans.data);
        //$display("%m , addr= %x, data=%x", trans.addr, trans.data);
      end
     endtask

     virtual task bl_put_no_intr(input T trans);
     //$display("%t %m, called",$time);
     //$display("%t %m, op is: %x",$time, trans.wren);
      if(trans.wren == 0) begin
        bus.master_write(trans.addr, trans.data);
        //$display("%m , addr= %x, data=%x", trans.addr, trans.data);
      end
      else begin
        bus.master_read(trans.addr, trans.data);
        //$display("%m , addr= %x, data=%x", trans.addr, trans.data);
      end
     endtask

 
  endclass

