class master_xtn extends uvm_sequence_item;
   
   `uvm_object_utils(master_xtn)
   
   bit Hclk,Hresetn;
   bit [1:0]Hresp;
   bit Hreadyin;
   bit Hreadyout;
   bit [31:0] Hrdata; //o/p so not random
   
   rand bit Hwrite;
   rand bit [2:0]Hsize;
   rand bit [1:0]Htrans;
   rand bit [31:0]Haddr;
   rand bit [2:0]Hburst;
   rand bit [31:0]Hwdata;
   rand bit [9:0]length;  //unspecified length
   
   
   constraint valid_size{Hsize inside {[0:2]};} 
       //since Hrdata and Hwdata are 32 bits wide
	     //2^0=1 byte of Hwdata,2^1=2 bytes,2^2=4 bytes of data
   
   constraint valid_length{(2^Hsize)*length <= 1024;} 
        //length should not cross 1Kb

   constraint valid_haddr{(Hsize == 1) ->Haddr % 2 == 0;
                          (Hsize == 2) ->Haddr % 4 == 0;} 
                          // address should always be even
   

    constraint valid_haddr1{Haddr inside {[32'h8000_0000 : 32'h8000_03ff],
                                          [32'h8400_0000 : 32'h8400_03ff],
                                          [32'h8800_0000 : 32'h8800_03ff],
                                          [32'h8c00_0000 : 32'h8c00_03ff]};} 
                                          // 4 slaves
        
    extern function new(string name="master_xtn");
    extern function void do_print(uvm_printer printer);
endclass


//------------Constructor---------//
	function master_xtn::new(string name = "master_xtn");
	   super.new(name);
  endfunction


//------------do_ptint------------//
  function void master_xtn::do_print(uvm_printer printer);
     super.do_print(printer);

      printer.print_field("Haddr", this.Haddr, 32, UVM_HEX);
      printer.print_field("Hwdata", this.Hwdata, 32, UVM_HEX);
      printer.print_field("Hwrite", this.Hwrite, 1, UVM_DEC);
      printer.print_field("Htrans", this.Htrans, 2, UVM_DEC);
      printer.print_field("Hsize", this.Hsize, 2, UVM_DEC);
      printer.print_field("Hburst", this.Hburst, 3, UVM_HEX);
      printer.print_field("Hrdata", this.Hrdata, 32, UVM_HEX);
      printer.print_field("length", this.length, 10, UVM_DEC);
  endfunction
