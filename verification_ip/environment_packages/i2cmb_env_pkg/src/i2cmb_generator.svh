class i2cmb_generator extends ncsu_component;

  wb_transaction wb_trans;
  wb_rand_transaction wb_rand_trans;
  i2c_transaction i2c_trans;
  wb_agent u_wb_agent;
  ncsu_component #(i2c_transaction) u_i2c_agent;
  string trans_name;
  int alternate_write = 64;
  int i2c_rand_data;
  int success;
  bit [WB_DATA_WIDTH-1:0] og_data[4];
  bit [WB_DATA_WIDTH-1:0] post_data[4];

  function new(string name = "", ncsu_component_base parent =null);
    super.new(name,parent);
  endfunction

  //Register_field_Aliasing
  task invalid_test();
  begin
    $display(" %m invalid_test task called");

    $display("INVALID REGISTER ADDRESS TEST");
    
    //Enable core
    wb_trans = new;
    wb_trans.addr = 0;
    wb_trans.data = 8'b11xxxxxx;
    wb_trans.wren = 0;
    u_wb_agent.bl_put_no_intr(wb_trans);
    $display("sent enable core");

    // READ original data of all register address
    wb_trans = new;
    wb_trans.addr = 0;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[0] = wb_trans.data;
    $display("Original data of CSR: %b", og_data[0]);

    
    wb_trans = new;
    wb_trans.addr = 1;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[1] = wb_trans.data;
    $display("Original data of DPR: %b", og_data[1]);


    wb_trans = new;
    wb_trans.addr = 2;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[2] = wb_trans.data;
    $display("Original data of CMDR: %b", og_data[2]);
    
    wb_trans = new;
    wb_trans.addr = 3;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[0] = wb_trans.data;
    $display("Original data of FSMR: %b", og_data[3]);

    //write to register
    wb_trans = new;
    wb_trans.addr = 1;
    wb_trans.wren =0;
    wb_trans.data = 8'h05;
    u_wb_agent.bl_put_no_intr(wb_trans);

    //checking the affect on other registers
    wb_trans = new;
    wb_trans.addr = 0;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[0] = wb_trans.data;
    $display("write data of CSR: %b", post_data[0]);

    wb_trans = new;
    wb_trans.addr = 1;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[1] = wb_trans.data;
    $display("write data of DPR: %b", post_data[1]);

    wb_trans = new;
    wb_trans.addr = 2;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[2] = wb_trans.data;
    $display("write data of CMDR: %b", post_data[2]);
     
    wb_trans = new;
    wb_trans.addr = 3;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[3] = wb_trans.data;
    $display("write data of FSMR: %b", post_data[3]);

    if(post_data[0] == 8'b11100000 && post_data[1] == 8'b00000000 &&
       post_data[2] == 8'b10000000 && post_data[3] == 8'b00000000 )
    begin 
       $display("RESULTS: Correct value obtained");
    end
    else begin
       $display("RESULTS: Incorrect value obtained");
    end
    $display("END TEST");

  end
  endtask

  task default_values();
    
    $display("Default Value Task called");
 
    //Enable core
    wb_trans = new;
    wb_trans.addr = 0;
    wb_trans.data = 8'b11xxxxxx;
    wb_trans.wren = 0;
    u_wb_agent.bl_put_no_intr(wb_trans);
    $display("sent enable core");

    // READ original data of all register address
    wb_trans = new;
    wb_trans.addr = 0;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[0] = wb_trans.data;
    $display("Original data of CSR: %b", og_data[0]);

    
    wb_trans = new;
    wb_trans.addr = 1;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[1] = wb_trans.data;
    $display("Original data of DPR: %b", og_data[1]);


    wb_trans = new;
    wb_trans.addr = 2;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[2] = wb_trans.data;
    $display("Original data of CMDR: %b", og_data[2]);
    
    wb_trans = new;
    wb_trans.addr = 3;
    wb_trans.wren =1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    og_data[0] = wb_trans.data;
    $display("Original data of FSMR: %b", og_data[3]);

    //write to register
    wb_trans = new;
    wb_trans.addr = 3;
    wb_trans.wren =0;
    wb_trans.data = 8'hff;
    u_wb_agent.bl_put_no_intr(wb_trans);

    //checking the affect on other registers
    wb_trans = new;
    wb_trans.addr = 0;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[0] = wb_trans.data;
    $display("write data of CSR: %b", post_data[0]);

    wb_trans = new;
    wb_trans.addr = 1;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[1] = wb_trans.data;
    $display("write data of DPR: %b", post_data[1]);

    wb_trans = new;
    wb_trans.addr = 2;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[2] = wb_trans.data;
    $display("write data of CMDR: %b", post_data[2]);
     
    wb_trans = new;
    wb_trans.addr = 3;
    wb_trans.wren = 1;
    u_wb_agent.bl_put_no_intr(wb_trans);
    post_data[3] = wb_trans.data;
    $display("write data of FSMR: %b", post_data[3]);

    if(post_data[0] == 8'b11100000 && post_data[1] == 8'b00000000 &&
       post_data[2] == 8'b10000000 && post_data[3] == 8'b00000000 )
    begin 
       $display("RESULTS: Correct value obtained");
    end
    else begin
       $display("RESULTS: Incorrect value obtained");
    end
    $display("END TEST");

  endtask 

  task random_write();
    $display("random read task called");
    fork
     begin: i2c_flow
       
       i2c_trans = new;
       u_i2c_agent.bl_put(i2c_trans);
     
     end:i2c_flow

     begin: wb_run

        wb_trans = new;
        $display("\n\n****************************************************************************");
        $display("********************-I2C bus Control for Random Test-***********************\n\n");

        //Enable core
        wb_trans.addr = 0;
        wb_trans.data = 8'b11xxxxxx;
        wb_trans.wren = 0;
        u_wb_agent.bl_put_no_intr(wb_trans);
        
        //set I2C bus ID
        wb_trans = new;
        wb_trans.addr = 1;
        wb_trans.data = 8'h05;
        wb_trans.wren = 0;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //set bus command
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx110;
        wb_trans.wren = 0;
        u_wb_agent.bl_put(wb_trans);

        //Reading in cmdr
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren = 1;
        u_wb_agent.bl_put_no_intr(wb_trans);

        
     
        //--------------------------Task 1: 32 Writes-------------------------
        $display("\n\n------------------------------------------------------------");
        $display("Task 1: writing 64 Random values Ranging from  0 to 127 to slave");
        $display("------------------------------------------------------------\n\n");

        //start command 
        wb_trans = new;
        wb_trans.addr = 2;
        $display("time: %t,%m,  sending start command",$time);
        wb_trans.data = 8'bxxxxx100;
        u_wb_agent.bl_put(wb_trans);

        //sending master read after wait for irq
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);
        
        //sending address; 44 to DPR
        wb_trans = new;
        wb_trans.addr = 1;
        wb_trans.data = 8'h44;
        wb_trans.wren =0;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //write to CMDR
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx001;
        wb_trans.wren =0;
        u_wb_agent.bl_put(wb_trans);

        //sending master read after wait for irq
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //Task -1 Write 32 values d=from 0 to 31
        for(int i=0; i<64; i++)
        begin
          wb_rand_trans = new; //new random transaction
          wb_rand_trans.addr = 1;
          //wb_trans.data = i;
          success = wb_rand_trans.randomize();
          wb_trans.wren =0;
          $display("time: %t, %m, Sending data",$time);
          u_wb_agent.bl_put_no_intr(wb_rand_trans);
        
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx001;
          wb_trans.wren =0;
          u_wb_agent.bl_put(wb_trans);

          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);
        end

        //stop command
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx101;
        wb_trans.wren =0;
        u_wb_agent.bl_put(wb_trans);

        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);

      $finish;
     end: wb_run
    join

  endtask

 task fsm_test();

    $display("fsm_test called");
     
    //Enable core
    wb_trans = new;
    wb_trans.addr = 0;
    wb_trans.data = 8'b11xxxxxx;
    wb_trans.wren = 0;
    u_wb_agent.bl_put_no_intr(wb_trans);
    $display("sent enable core");
   
    //set I2C bus ID
    wb_trans = new;
    wb_trans.addr = 1;
    wb_trans.data = 8'h00;
    wb_trans.wren = 0;
    u_wb_agent.bl_put_no_intr(wb_trans);

    wb_trans = new;
    wb_trans.addr = 2;
    wb_trans.data = 8'bxxxxx010;
    wb_trans.wren =0;
    $display(" arbitration lost command sending to cmdr");
    u_wb_agent.bl_put(wb_trans);

 endtask

 
  virtual task run();
    fork
      begin: i2c_run

        //for task 1: 32 writes and to call wait_for_i2c_transfer
        i2c_trans = new;
        u_i2c_agent.bl_put(i2c_trans);

        //for Task 2: 32 reads
        if(i2c_trans.checkpoint == 0) begin
          i2c_trans = new;
          u_i2c_agent.bl_put(i2c_trans);
        end
      
        //for Task 3
        i2c_trans = new;
        u_i2c_agent.bl_put(i2c_trans);

        if(i2c_trans.checkpoint == 1) begin
          for(int i =63; i>=0; i--) begin
            //for alternate writes
            i2c_trans = new;
            u_i2c_agent.bl_put(i2c_trans);
            //for alternate reads
            i2c_trans = new;
            u_i2c_agent.bl_put(i2c_trans);
          end
        end
        
      end:i2c_run

      begin:  wb_run
      
        wb_trans = new;
        $display("\n\n************************************************************");
        $display("********************-I2C bus Control-***********************\n\n");

        //Enable core
        wb_trans.addr = 0;
        wb_trans.data = 8'b11xxxxxx;
        wb_trans.wren = 0;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //FSMR register
        wb_trans = new;
        wb_trans.addr = 3; 
        wb_trans.wren = 1;
        u_wb_agent.bl_put_no_intr(wb_trans);
        //og_data = wb_trans.data;
        
        //set I2C bus ID
        wb_trans = new;
        wb_trans.addr = 1;
        wb_trans.data = 8'h05;
        wb_trans.wren = 0;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //set bus command
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx110;
        wb_trans.wren = 0;
        u_wb_agent.bl_put(wb_trans);

        //Reading in cmdr
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren = 1;
        u_wb_agent.bl_put_no_intr(wb_trans);

        
     
        //--------------------------Task 1: 32 Writes-------------------------
        $display("\n\n------------------------------------------------------------");
        $display("Task 1: writing 32 incrementing values from 0 to 32 to slave");
        $display("------------------------------------------------------------\n\n");

        //start command 
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx100;
        //$display("time: %t,%m,  sending start command",$time);
        u_wb_agent.bl_put(wb_trans);

        //sending master read after wait for irq
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);
        
        //sending address; 44 to DPR
        wb_trans = new;
        wb_trans.addr = 1;
        wb_trans.data = 8'h44;
        wb_trans.wren =0;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //write to CMDR
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx001;
        wb_trans.wren =0;
        u_wb_agent.bl_put(wb_trans);

        //sending master read after wait for irq
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //Task -1 Write 32 values d=from 0 to 31
        for(int i=0; i<32; i++)
        begin
          wb_trans = new;
          wb_trans.addr = 1;
          wb_trans.data = i;
          wb_trans.wren =0;
          u_wb_agent.bl_put_no_intr(wb_trans);
          //$display("time: %t, %m, Sending data",$time);
        
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx001;
          wb_trans.wren =0;
          u_wb_agent.bl_put(wb_trans);

          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);
        end

        //stop command
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx101;
        wb_trans.wren =0;
        u_wb_agent.bl_put(wb_trans);

        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);

       

        i2c_trans.checkpoint = 0;
        
        //--------------------Task 2: 32 Reads-----------------------------
        $display("\n\n---------------------------------------------------------------");
        $display("Task 2: Reading 32 incrementing values from 100 to 131 to slave");
        $display("---------------------------------------------------------------\n\n");

        //start command 
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx100;
        $display("time: %t, %m sending start command",$time);
        u_wb_agent.bl_put(wb_trans);

        //sending master read after wait for irq
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);
        
        //sending address; 44 to DPR
        wb_trans = new;
        wb_trans.addr = 1;
        wb_trans.data = 8'h45;
        wb_trans.wren =0;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //write to CMDR
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx001;
        wb_trans.wren =0;
        u_wb_agent.bl_put(wb_trans);

        //sending master read after wait for irq
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);

        //Loop for 32 reads
        for(int i=0; i<32;i++) 
        begin

          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx010;
          wb_trans.wren =0;
          $display("time: %t, %m, Receving data",$time);
          u_wb_agent.bl_put(wb_trans);

          //sending master read after wait for irq
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);

        
          wb_trans = new;
          wb_trans.addr = 1;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);
        end

        //Read command
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx011;
        wb_trans.wren =0;
        u_wb_agent.bl_put(wb_trans);

        //sending master read after wait for irq
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);
        
        //stop command
        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.data = 8'bxxxxx101;
        wb_trans.wren =0;
        u_wb_agent.bl_put(wb_trans);

        wb_trans = new;
        wb_trans.addr = 2;
        wb_trans.wren =1;
        u_wb_agent.bl_put_no_intr(wb_trans);

        i2c_trans.checkpoint = 1;

        //--------------------Task 3: Alternate read and write-----------------------------
        $display("\n\n---------------------------------------------------------------");
        $display("    Task 3: 64 Alternate Read and writes incrementing values   ");
        $display("---------------------------------------------------------------\n\n");

        for(int i =0; i<64; i++) begin
          i2c_trans.checkpoint = 1;

          //start command 
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx100;
          u_wb_agent.bl_put(wb_trans);

          //sending master read after wait for irq
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);
        
          //sending address; 44 to DPR
          wb_trans = new;
          wb_trans.addr = 1;
          wb_trans.data = 8'h44;
          wb_trans.wren =0;
          u_wb_agent.bl_put_no_intr(wb_trans);

          //write to CMDR
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx001;
          wb_trans.wren =0;
          u_wb_agent.bl_put(wb_trans);

          //sending master read after wait for irq
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);

          //for alternate writes 
          wb_trans = new;
          wb_trans.addr= 1;
          wb_trans.data = alternate_write;
          wb_trans.wren =0;
          $display("\n time:%t, %m Sending Data for Alternate write",$time);
          u_wb_agent.bl_put_no_intr(wb_trans);
          alternate_write++;

          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx001;
          wb_trans.wren =0;
          u_wb_agent.bl_put(wb_trans);

          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);

          //------alternate reads------------- 
          //repeated start
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx100;
          $display("time: %t, %m,  sending repeated start command",$time);
          u_wb_agent.bl_put(wb_trans);
          

          //sending master read after wait for irq
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);
        
          //sending address; 44 to DPR
          wb_trans = new;
          wb_trans.addr = 1;
          wb_trans.data = 8'h45;
          wb_trans.wren =0;
          u_wb_agent.bl_put_no_intr(wb_trans);

          //write to CMDR
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx001;
          wb_trans.wren =0;
          u_wb_agent.bl_put(wb_trans);

          //sending master read after wait for irq
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);

          //read command
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx011;
          wb_trans.wren =0;
          u_wb_agent.bl_put(wb_trans);

          //sending master read after wait for irq
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);

          wb_trans = new;
          wb_trans.addr = 1;
          wb_trans.wren = 1;
          u_wb_agent.bl_put_no_intr(wb_trans);
            
          //stop command
          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.data = 8'bxxxxx101;
          wb_trans.wren =0;
          u_wb_agent.bl_put(wb_trans);
          

          wb_trans = new;
          wb_trans.addr = 2;
          wb_trans.wren =1;
          u_wb_agent.bl_put_no_intr(wb_trans);

        end

        $finish;

      
      end: wb_run
    join

  endtask

  function void set_i2c_agent(ncsu_component #(i2c_transaction) agent);
    this.u_i2c_agent = agent;
  endfunction

  function void set_wb_agent(wb_agent agent);
    this.u_wb_agent = agent;
  endfunction

endclass
