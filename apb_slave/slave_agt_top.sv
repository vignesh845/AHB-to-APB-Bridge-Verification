class slave_agt_top extends uvm_env;
	
	`uvm_component_utils(slave_agt_top)

	env_config m_cfg;
	slave_agent agt[];
  
  extern function new(string name = "slave_agt_top" , uvm_component parent);
  extern function void build_phase(uvm_phase phase);
endclass


//------------------- Constructor------------------//
	function slave_agt_top::new(string name="slave_agt_top",uvm_component parent);
		super.new(name,parent);
endfunction


//----------------- build_phase ------------------//
	function void slave_agt_top::build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")

		agt =new[m_cfg.no_of_apb_agents];
		foreach(agt[i])
		begin
			agt[i]=slave_agent::type_id::create($sformatf("agt[%0d]", i),this);
			uvm_config_db #(slave_agt_config)::set(this,$sformatf("agt[%0d]*", i), "slave_agt_config", m_cfg.apb_cfg[i]);
		end
  endfunction
