class wb_coverage extends ncsu_component#(.T(wb_transaction));

   wb_configuration configuration;
   
   bit [WB_ADDR_WIDTH-1:0] addr;
   bit wren;
   bit [WB_DATA_WIDTH-1:0] data;
   bit [3:0] fsmr_byte;
   bit csr_wr, csr_rd, dpr_rd, dpr_wr, cmdr_wr, cmdr_rd, fsmr_wr, fsmr_rd;
   register_inits_t register_inits;
   fsmr_bit_t fsmr_bit;
   bus_status_t bus_status;
   bus_cap_status_t bus_cap_status;
   intr_enable_t intr_enable; 
   al_enable_t al_enable;  
 
   covergroup i2cmb_register_cg;
     option.per_instance =1;
     option.name = get_full_name();

     addr_valid: coverpoint addr
                 {
                   bins csr = {2'b00};
                   bins dpr = {2'b01};
                   bins cmdr = {2'b10};
                   bins fsmr = {2'b11};
                 }

      data: coverpoint data 
                 { 
                   bins wb_data = { [0:136] }; 
                 }

      we:   coverpoint wren;
      
      addr_x_we: cross addr_valid, we;
                 
                
      register_field_aliasing: coverpoint addr 
                {

       bins csr_write_other_read = ((csr_wr == 1'b1) => (dpr_rd == 1'b1)), ((csr_wr == 1'b1) => (cmdr_rd == 1'b1)), ((csr_wr == 1'b1) => (fsmr_rd == 1'b1));
       bins dpr_write_other_read = ((dpr_wr == 1'b1) => (csr_rd == 1'b1)), ((dpr_wr == 1'b1) => (cmdr_rd == 1'b1)), ((dpr_wr == 1'b1) => (fsmr_rd == 1'b1));
       bins cmdr_write_other_read = ((cmdr_wr == 1'b1) => (csr_rd == 1'b1)), ((cmdr_wr == 1'b1) => (dpr_rd == 1'b1)), ((cmdr_wr == 1'b1) =>(fsmr_rd == 1'b1));
       bins fsmr_write_other_read = ((fsmr_wr == 1'b1) => (dpr_rd == 1'b1)), ((fsmr_wr == 1'b1) => (cmdr_rd == 1'b1)), ((fsmr_wr == 1'b1) =>(csr_rd == 1'b1));

                }
 
      register_inits: coverpoint register_inits 
                 { 
                    bins enable = {enable};
                    bins set_bus = {set_bus};
                    bins start  = {start};
                    bins stop = {stop};
                    bins write = {write};
                    bins ack_read = {ack_read};
                    bins nack_read = {nack_read};
                 }

      bus_status: coverpoint bus_status
                 {
                   bins bus_busy = {bus_busy};
                   bins bus_not_busy = {bus_not_busy};
                 }

      bus_cap_status: coverpoint bus_cap_status
                 {
                   bins bus_captured = {bus_captured};
                   bins bus_not_captured = {bus_not_captured};
                 }

      intr_enable: coverpoint intr_enable
                 {
                    bins intr_en = {intr_en};
                    bins intr_not_en = {intr_not_en};
                 }
 
      csr_x_intr_x_we: cross addr_valid, intr_enable, we
                 {
                     bins csr_intr_enabl_wr = binsof(addr_valid.csr) && binsof(intr_enable.intr_en) && binsof(we.auto[1]);
                     ignore_bins csr_intr_enabl_rd = binsof(addr_valid.csr) && binsof(intr_enable.intr_en) && binsof(we.auto[0]);
                     ignore_bins csr_intr_not_enabl_wr = binsof(addr_valid.csr) && binsof(intr_enable.intr_not_en) && binsof(we.auto[1]);
                     ignore_bins csr_intr_not_enabl_rd = binsof(addr_valid.csr) && binsof(intr_enable.intr_not_en) && binsof(we.auto[0]);
                     ignore_bins not_csr = binsof(addr_valid.cmdr) || binsof(addr_valid.fsmr) || binsof(addr_valid.dpr);

                 }

      i2cmb_register_inits: cross addr_valid, register_inits 
                 {
                    bins enable_detected = binsof(addr_valid.csr) && binsof(register_inits.enable);
                    bins set_bus         = binsof(addr_valid.cmdr) && binsof(register_inits.set_bus);
                    bins start           = binsof(addr_valid.cmdr) && binsof(register_inits.start);
                    bins stop            = binsof(addr_valid.cmdr) && binsof(register_inits.stop);
                    bins write           = binsof(addr_valid.cmdr) && binsof(register_inits.write);
                    bins nack_read       = binsof(addr_valid.cmdr) && binsof(register_inits.nack_read);
                    bins ack_read        = binsof(addr_valid.cmdr) && binsof(register_inits.ack_read);
                    ignore_bins cmdr_i   = binsof(addr_valid.cmdr) && binsof(register_inits.enable);
                    ignore_bins fsmr_i   = binsof(addr_valid.fsmr);
                    ignore_bins csr_i    = binsof(addr_valid.csr) && (binsof(register_inits.stop) || binsof(register_inits.set_bus) || binsof(register_inits.start) || binsof(register_inits.write) || binsof(register_inits.nack_read) || binsof(register_inits.ack_read));
                    ignore_bins defaults = (binsof(addr_valid.cmdr) || binsof(addr_valid.dpr) || binsof(addr_valid.fsmr)) && binsof(register_inits.enable);
                 }

   endgroup
  
   covergroup fsm_cg;
     option.per_instance =1;
     option.name = get_full_name();

     addr: coverpoint addr
              {
               bins csr = {2'b00};
               bins dpr = {2'b01};
               bins cmdr = {2'b10};
               bins fsmr = {2'b11};
              }
     mbyte_state_cover: coverpoint fsmr_byte
               {
                  bins idle = {4'b0000};
                  bins bus_taken = {4'b0001};
                  bins p_start = {4'b0010};
                  bins start = {4'b0011};
                  bins stop = {4'b0100};
                  bins write = {4'b0101};
                  bins read = {4'b0110};
                  bins wait_state = {4'b0111};
               }

     mbyte_state_transitions: coverpoint fsmr_byte
                 {

                   bins idle_to_idle = (4'b0000 => 4'b0000);
                   ignore_bins idle_to_p_start = (4'b0000 => 4'b0010);
                   ignore_bins p_start_to_start = (4'b0010 => 4'b0011);
                   ignore_bins start_to_bus_taken = (4'b0011 => 4'b0001);
                   bins start_to_idle = (4'b0011 => 4'b0000);	
                   ignore_bins bus_taken_to_bus_taken = (4'b0001 => 4'b0001);
                   ignore_bins bus_taken_to_write = (4'b0001 => 4'b0101);
                   ignore_bins bus_taken_to_read = (4'b0001 => 4'b0110);
                   ignore_bins bus_taken_to_start = (4'b0001 => 4'b0011);
                   ignore_bins bus_taken_to_stop = (4'b0001 => 4'b0100);
                   ignore_bins write_to_write = (4'b0101 => 4'b0101);
                   ignore_bins write_to_bus_take = (4'b0101 => 4'b0001);
                   bins write_to_idle = (4'b0101 => 4'b0000);
                   ignore_bins read_to_read = (4'b0110 => 4'b0110);
                   ignore_bins read_to_bus_taken = (4'b0110 => 4'b0001);
                   ignore_bins read_to_idle = (4'b0110 => 4'b0001);
                   bins stop_to_idle = (4'b0100 => 4'b0000);
                   ignore_bins idle_to_wait = (4'b0000 => 4'b0111);
                   bins wait_to_idle = (4'b0111 => 4'b0000);
        
                 }

     mbit_state_cover: coverpoint fsmr_bit
                 {
                   bins idle      = {4'b0000};
                   bins start_A   = {4'b0001};
                   bins start_B   = {4'b0010};
                   bins start_C   = {4'b0011};
                   bins rw_A      = {4'b0100};
                   bins rw_B      = {4'b0101};
                   bins rw_C      = {4'b0110};
                   bins rw_D      = {4'b0111};
                   bins rw_E      = {4'b1000};
                   bins stop_A    = {4'b1001};
                   bins stop_B    = {4'b1010};
                   bins stop_C    = {4'b1011};
                   bins rstart_A  = {4'b1100};
                   bins rstart_B  = {4'b1101};
                   bins rstart_C  = {4'b1110};

                 }

     mbit_state_transitions: coverpoint fsmr_bit
                 {
                   bins idle_to_idle          = ( idle => idle);
                   bins idle_to_start_A       = (idle => start_A);
                   bins start_A_to_start_B    = (start_A => start_B);
                   bins start_B_to_start_C    = (start_B => start_C);
                   ignore_bins start_C_to_rw_A       = (start_C => rw_A);
                   ignore_bins rw_A_to_rw_B          = (rw_A => rw_B);
                   ignore_bins rw_B_to_rw_C          = (rw_B => rw_C);
                   ignore_bins rw_C_to_rw_D          = (rw_C => rw_D);
                   ignore_bins rw_D_to_rw_E          = (rw_D => rw_E);
                   ignore_bins rw_E_to_rw_A          = (rw_E => rw_A);
                   ignore_bins rw_C_to_idle          = (rw_C => idle);
                   ignore_bins rw_E_to_rstart_A      = (rw_E => rstart_A);
                   ignore_bins rstart_A_to_rstart_B  = (rstart_A => rstart_B);
                   ignore_bins rstart_B_to_rstart_C  = (rstart_B => rstart_C);
                   bins rstart_C_to_start_A   = (rstart_C => start_A);
                   ignore_bins rstart_C_to_idle      = (rstart_C => idle);
                   ignore_bins rw_E_to_stop_A        = (rw_E => stop_A);
                   ignore_bins stop_A_to_stop_B      = (stop_A => stop_B);
                   ignore_bins stop_B_to_stop_C      = (stop_B => stop_C);
                   ignore_bins stop_C_to_idle        = (stop_C => idle);   
                   bins start_C_to_start_C    = (start_C => start_C);
                   ignore_bins start_C_to_stop_A     = (start_C => stop_A);

                 }
   endgroup
 
   function new(string name =" ", ncsu_component #(T) parent = null);
     super.new(name,parent);
     i2cmb_register_cg = new;
     fsm_cg = new;
   endfunction

   function void set_configuration(wb_configuration cfg);
     configuration = cfg;
   endfunction

   virtual function void nb_put(T trans);

     addr = trans.addr;
     data = trans.data;
     register_inits = register_inits_t'(trans.data);
     wren = trans.wren;
     fsmr_byte = trans.data[7:4];
     fsmr_bit = fsmr_bit_t'(trans.data[3:0]);
     bus_status = bus_status_t'(trans.data[5]);
     bus_cap_status = bus_cap_status_t'(trans.data[4]);
     intr_enable = intr_enable_t'(trans.data[6]);
     if(addr == 2'b10)
        al_enable = al_enable_t'(trans.data[5]);

     if (addr == 2'b00 && wren == 1'b0)
         csr_rd = 1'b1;
     else if (addr == 2'b00 && wren == 1'b1)
         csr_wr = 1'b1;
     else begin
         csr_wr = 1'b0;
         csr_rd = 1'b0;
     end

      if (addr == 2'b01 && wren == 1'b0)
      dpr_rd = 1'b1;
    else if (addr == 2'b00 && wren == 1'b1)
      dpr_wr = 1'b1;
    else begin
      dpr_wr = 1'b0;
      dpr_rd = 1'b0;
    end

    if (addr == 2'd02 && wren == 1'b0)
      cmdr_rd = 1'b1;
    else if (addr == 2'b00 && wren == 1'b1)
      cmdr_wr = 1'b1;
    else begin
      cmdr_wr = 1'b0;
      cmdr_rd = 1'b0;
    end

   if (addr == 2'd03 && wren == 1'b0)
      fsmr_rd = 1'b1;
    else if (addr == 2'b00 && wren == 1'b1)
      fsmr_wr = 1'b1;
    else begin
      fsmr_wr = 1'b0;
      fsmr_rd = 1'b0;
    end

    i2cmb_register_cg.sample();
    fsm_cg.sample();

   endfunction         
endclass
