class env_config extends uvm_object;

   `uvm_object_utils(env_config)
   
   bit has_ahb_agent = 1;
   bit has_apb_agent = 1;
   int no_of_ahb_agents = 1;
   int no_of_apb_agents = 1;
   bit has_scoreboard = 1;
   bit has_virtual_sequencer = 1;
   bit has_coverage=1;
   
   master_agt_config ahb_cfg[];
   slave_agt_config apb_cfg[];

	 extern function new(string name = "env_config");
endclass


//------------------- constructor -------------//
	function env_config::new(string name = "env_config");
        	super.new(name);
  endfunction

