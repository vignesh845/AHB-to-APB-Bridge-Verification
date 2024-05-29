class slave_xtn extends uvm_sequence_item;
   `uvm_object_utils(slave_xtn)
   
   bit Penable;       //indicates second cycle of apb transfer
	 bit Pwrite;        //High for apb write access,Low for apb read access
   bit [3:0]Pselx;    //indicates slave device is select and data t/f is required
   bit [31:0]Paddr;   //apb address bus,driven by the peripheral bus bridge unit
   bit [31:0]Pwdata;  //driven by peripheral bus bridge unit during write cycle
   rand bit [31:0]Prdata;  //driven by the selected slave during read cycles.
   
    extern function new(string name = "slave_xtn");
    extern function void do_print(uvm_printer printer);
endclass

//------------Constructor---------//
	function slave_xtn::new(string name = "slave_xtn");
	   super.new(name);
  endfunction
  
  
//------------- Do print---------//
  function void slave_xtn::do_print(uvm_printer printer);
	   super.do_print(printer);

	    printer.print_field("Pselx",  this.Pselx,   4, UVM_DEC);
	    printer.print_field("Pwrite",  this.Pwrite,  1, UVM_DEC);
	    printer.print_field("Penable",this.Penable, 1, UVM_DEC);
	    printer.print_field("Paddr",  this.Paddr,  32, UVM_HEX);
	    printer.print_field("Pwdata", this.Pwdata, 32, UVM_HEX);
	    printer.print_field("Prdata", this.Prdata, 32, UVM_HEX);
endfunction
