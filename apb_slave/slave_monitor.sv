 class slave_monitor extends uvm_monitor;

   `uvm_component_utils(slave_monitor)
   
   virtual apb_if.APB_MON_MP vif;
   slave_xtn xtnn;
   slave_agt_config apb_cfg;
 	 uvm_analysis_port #(slave_xtn) monitor_port;
    
   extern function new(string name="slave_monitor",uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);
   extern task run_phase(uvm_phase phase);
   extern task collect_data;    
   extern function void report_phase(uvm_phase phase);
endclass


//------------------Constructor----------------------//
	function slave_monitor::new(string name="slave_monitor",uvm_component parent);
	   super.new(name,parent);
 		 monitor_port=new("monitor_port",this);
  endfunction


//-----------------------Build Phase-----------------------//
	function void slave_monitor::build_phase(uvm_phase phase);
	   if(!uvm_config_db #(slave_agt_config)::get(this,"","slave_agt_config",apb_cfg))
    `uvm_fatal("MONITOR","cannot get config data");
   	super.build_phase(phase);
  endfunction


//-------------- connect_phase ----------------------//
	function void slave_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
		vif=apb_cfg.vif;
  endfunction


//----------------Run Phase-----------------------------//
  task slave_monitor::run_phase(uvm_phase phase);
    repeat(3) 
    @(vif.apb_mon_cb); 
    forever begin
    collect_data();
    end
  endtask


//------------------collect data------------------//
  task slave_monitor::collect_data();
 

  xtnn=slave_xtn::type_id::create("slave_xtn"); 
   @(vif.apb_mon_cb);                         // printing ahb monitor
   while(!vif.apb_mon_cb.Penable==1'b1)
   @(vif.apb_mon_cb);
   
   xtnn.Paddr=vif.apb_mon_cb.Paddr;
   xtnn.Pwrite=vif.apb_mon_cb.Pwrite;
   xtnn.Pselx=vif.apb_mon_cb.Pselx;  //collect control info

     if(vif.apb_mon_cb.Pwrite==1'b0)
       begin
       xtnn.Prdata=vif.apb_mon_cb.Prdata; //collect data
       end
        else
       begin
       xtnn.Pwdata=vif.apb_mon_cb.Pwdata;
       end
       
     @(vif.apb_mon_cb);
     monitor_port.write(xtnn);
     `uvm_info("APB MONITOR",$sformatf("Printing from monitor \n %s",xtnn.sprint()),UVM_LOW)
     apb_cfg.mon_data_count++;
   endtask
  

//------------------- report phase ---------------------//
  function void slave_monitor::report_phase(uvm_phase phase);
      `uvm_info(get_type_name(), $sformatf("Report:APB_Monitor Collected %0d Transactions",apb_cfg.mon_data_count), UVM_LOW)
  endfunction










