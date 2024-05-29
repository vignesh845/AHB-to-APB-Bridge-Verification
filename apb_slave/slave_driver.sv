class slave_driver extends uvm_driver#(slave_xtn);

	`uvm_component_utils(slave_driver)

	virtual apb_if.APB_DR_MP vif;

	slave_xtn xtn;
	slave_agt_config apb_cfg;

	extern function new(string name="slave_driver",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task send_to_dut(slave_xtn xtn);
  extern function void report_phase(uvm_phase phase);	
endclass


//---------Constructor-----------//
	function slave_driver::new(string name="slave_driver",uvm_component parent);
		super.new(name,parent);
  endfunction


//----------Build Phase---------//
	function void slave_driver::build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(slave_agt_config)::get(this,"","slave_agt_config",apb_cfg))
		`uvm_fatal("DRIVER","cannot get config data");
  endfunction


//---------------Connect Phase-------------//
	function void slave_driver::connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif=apb_cfg.vif;
  endfunction


//-----------------Run Phase----------------------------//
  task slave_driver::run_phase(uvm_phase phase);
  req=slave_xtn::type_id::create("slave_xtn", this);
    forever
     send_to_dut(req);
  endtask


//------------------send to dut----------------------------//
  task slave_driver::send_to_dut(slave_xtn xtn);
   begin
    //@(vif.apb_drv_cb);
    while(vif.apb_drv_cb.Pselx===1'b0)
    @(vif.apb_drv_cb);
 
    if(vif.apb_drv_cb.Pwrite==1'b0)
      begin
      vif.apb_drv_cb.Prdata <= {($urandom)%60};
      end
     else
      begin		
      vif.apb_drv_cb.Prdata <= 0;
      end 

    repeat(2)           //master  monitor without comment
    @(vif.apb_drv_cb);

    
    //while(vif.apb_drv_cb.Penable)
    //@(vif.apb_drv_cb);

     apb_cfg.drv_data_count++;
   end
  endtask
 


//----------------------- report phase ---------------------//
  function void slave_driver::report_phase (uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report:APB_DRIVER sent %0d transaction",apb_cfg.drv_data_count),UVM_LOW)
  endfunction

