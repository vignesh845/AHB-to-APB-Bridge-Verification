class sb extends uvm_scoreboard;
   `uvm_component_utils(sb)
   
   uvm_tlm_analysis_fifo #(master_xtn)fifo_mh;
   uvm_tlm_analysis_fifo #(slave_xtn)fifo_sh;
  
   env_config e_cfg;
   master_xtn mxtn;
   slave_xtn sxtn;
   master_xtn mcov;
   slave_xtn scov;
  
   
   covergroup ahb_cg;
   option.per_instance=1;
   //option.at_least=1;
      HBUR57:coverpoint mcov.Hburst {bins hburst_bin[]={[0:7]};}
      HS1Z3 :coverpoint mcov.Hsize  {bins hsize_bin={0,1,2};}
      H7R4N5:coverpoint mcov.Htrans {bins htrans_bin[]={[2:3]};}
      HWR173:coverpoint mcov.Hwrite {bins hwrite_bin={1};}
      H4DDR :coverpoint mcov.Haddr  {bins haddr_bin1= {[32'h8000_0000:32'h8000_03ff]};
                                      bins haddr_bin2= {[32'h8400_0000:32'h8400_03ff]};
                                      bins haddr_bin3= {[32'h8800_0000:32'h8800_03ff]};
                                      bins haddr_bin4= {[32'h8c00_0000:32'h8c00_03ff]};
                                      }
      HWD474:coverpoint mcov.Hwdata {bins hwdata_bin= {[32'h0000_0000:32'hffff_ffff]};}
 		  HRD474:coverpoint mcov.Hrdata {bins hrdata_bin= {[32'h0000_0000:32'hffff_ffff]};}
      
   C1: cross HS1Z3,HWR173,H7R4N5,HWD474;
   C2: cross HS1Z3,HWR173,HRD474; //track the values of two or more coverpoints as a roup
   endgroup  
   
   
   
   covergroup apb_cg;
    option.per_instance=1;  //enable to view coverage report for each instance
    //option.at_least=1;
      EN4BL3:coverpoint scov.Penable;
      PWD474:coverpoint scov.Pwdata{bins pwdata_bin= {[32'h0000_0000:32'hffff_ffff]};}
      PRD474:coverpoint scov.Prdata{bins prdata_bin= {[32'h0000_0000:32'hffff_ffff]};}
      PWR173:coverpoint scov.Pwrite{bins Pwrite_bin={1};}
      P4DDR :coverpoint scov.Paddr {bins paddr_bin1 ={[32'h8000_0000:32'h8000_03ff]};
                                      bins paddr_bin2= {[32'h8400_0000:32'h8400_03ff]};
                                      bins paddr_bin3= {[32'h8800_0000:32'h8800_03ff]};
                                      bins paddr_bin4= {[32'h8c00_0000:32'h8c00_03ff]}; 
                                      }
      PS3LX  :coverpoint scov.Pselx {bins slave1={4'b0001};
                                     bins slave2={4'b0010};
                                     bins slave3={4'b0100};
                                     bins slave4={4'b1000}; }                            
   endgroup
   
   
   extern function new(string name="sb",uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern task run_phase(uvm_phase phase);
   extern function void check();
   extern function void compare(bit[31:0] Hdata,[31:0]Pdata,[31:0]Haddr,[31:0]Paddr); 
endclass

   master_xtn mxtn;
   slave_xtn sxtn;
   bit [31:0] ahb_addr[$];
   bit [31:0] ahb_data_write[$];
   bit [31:0] ahb_data_read[$];
   
   bit [31:0] apb_addr[$];
   bit [31:0] apb_data_write[$];
   bit [31:0] apb_data_read[$];




/*//////////////////// Constructor \\\\\\\\\\\\\\\\*/
   function sb::new(string name="sb",uvm_component parent);
	    super.new(name,parent);
 
      fifo_mh=new("fifo_mh",this);
      fifo_sh=new("fifo_sh",this);
      
      ahb_cg=new();
      apb_cg=new();
      
      mcov=new();
      scov=new();
      
      mxtn=new();
      sxtn=new();
   endfunction
/*\\\\\\\\\\\\\\\\\\\\\\//////////////////////////*/

   
   


/*""""""""""""""""""" Build_Phase '''''''''''''''''*/
   function void sb::build_phase(uvm_phase phase);
     super.build_phase(phase);
       if(!uvm_config_db #(env_config)::get(this,"","env_config",e_cfg))
       `uvm_fatal("SB","cannot get config data");
   
   endfunction
/*'''''''''''''''''''''''"""""""""""""""""""""""""*/





/*[][][][][][][][][][ Run_Phase )()()()()()()()()()*/
   task sb::run_phase(uvm_phase phase);
   
   fork
   `uvm_info("SB","Inside run phase",UVM_LOW)
   
    begin
    forever
      begin
        fifo_mh.get(mxtn);    
        ahb_addr.push_back(mxtn.Haddr);
        ahb_data_write.push_back(mxtn.Hwdata);
        ahb_data_read.push_back(mxtn.Hrdata);
        
        mcov=mxtn;
        ahb_cg.sample();  //For getting sample at particular point
      end
    end
    
    begin
    forever
      begin
        fifo_sh.get(sxtn);
        apb_addr.push_back(sxtn.Paddr);
        apb_data_write.push_back(sxtn.Pwdata);
        apb_data_read.push_back(sxtn.Prdata);
        
        scov=sxtn;
        apb_cg.sample();
      end
     end
   join
   check();
   endtask
/*()()()()()()()()()()()()[][][][][][][][][][][][]*/





/*+++++++++++++++++++++ Check ---------------------*/
   function void sb::check();
   
   mxtn.Haddr=ahb_addr.pop_front();
   mxtn.Hwdata=ahb_data_write.pop_front();
   mxtn.Hrdata=ahb_data_read.pop_front();
   sxtn.Paddr=apb_addr.pop_front();
   sxtn.Pwdata=apb_data_write.pop_front();
   sxtn.Prdata=apb_data_read.pop_front();
   
   
   if(mxtn.Hwrite)
       begin
          case(mxtn.Hsize)
          
          2'b00: begin
            if(mxtn.Haddr[1:0]==2'b00)
            compare(mxtn.Hwdata[7:0],sxtn.Pwdata[7:0],mxtn.Haddr,sxtn.Paddr);
            if(mxtn.Haddr[1:0]==2'b01)
            compare(mxtn.Hwdata[15:8],sxtn.Pwdata[7:0],mxtn.Haddr,sxtn.Paddr);
            if(mxtn.Haddr[1:0]==2'b10)
            compare(mxtn.Hwdata[23:16],sxtn.Pwdata[7:0],mxtn.Haddr,sxtn.Paddr);
            if(mxtn.Haddr[1:0]==2'b11)
            compare(mxtn.Hwdata[31:24],sxtn.Pwdata[7:0],mxtn.Haddr,sxtn.Paddr);
            end
            
          2'b01: begin
            if(mxtn.Haddr[1:0]==2'b00)
            compare(mxtn.Hwdata[15:0],sxtn.Pwdata[15:0],mxtn.Haddr,sxtn.Paddr);
            if(mxtn.Haddr[1:0]==2'b10)
            compare(mxtn.Hwdata[31:16],sxtn.Pwdata[15:0],mxtn.Haddr,sxtn.Paddr);
            end
            
          2'b10: begin
             compare(mxtn.Hwdata[31:0],sxtn.Pwdata[31:0],mxtn.Haddr,sxtn.Paddr);
             end
          endcase
       end
       
     else
       begin
          case(mxtn.Hsize)
          
          2'b00:begin
            if(mxtn.Haddr[1:0] == 2'b00)
            compare(mxtn.Hrdata[7:0],sxtn.Prdata[7:0],mxtn.Haddr,sxtn.Paddr);
            else if(mxtn.Haddr[1:0] == 2'b01)
            compare(mxtn.Hrdata[7:0],sxtn.Prdata[15:8],mxtn.Haddr,sxtn.Paddr);
            else if(mxtn.Haddr[1:0] == 2'b10)
            compare(mxtn.Hrdata[7:0],sxtn.Prdata[23:16],mxtn.Haddr,sxtn.Paddr);
            else if(mxtn.Haddr[1:0] == 2'b11)
            compare(mxtn.Hrdata[7:0],sxtn.Prdata[31:24],mxtn.Haddr,sxtn.Paddr);
            end
            
          2'b01:begin
            if(mxtn.Haddr[1:0] == 2'b00)
            compare(mxtn.Hrdata[15:0],sxtn.Prdata[15:0],mxtn.Haddr,sxtn.Paddr);
            if(mxtn.Haddr[1:0] == 2'b10)
            compare(mxtn.Hrdata[15:0],sxtn.Prdata[31:16],mxtn.Haddr,sxtn.Paddr);
            end
               
          2'b10:begin
          compare(mxtn.Hrdata[31:0],sxtn.Prdata[31:0],mxtn.Haddr,sxtn.Paddr);
          end
          endcase
       end
   endfunction
/*----------------------+++++++++++++++++++++++++++*/





/*<<<<<<<<<<<<<<<<<<<< Compare >>>>>>>>>>>>>>>>>>>*/
   function void sb::compare(bit[31:0] Hdata,[31:0]Pdata,[31:0]Haddr,[31:0]Paddr);
    
      if(Haddr==Paddr)
     begin
       $display("SB Address Compared Successful");
     end
     else
     begin
       $display("SB Address Compared Unsuccessful");
     end
     
     
     if(Hdata==Pdata)
     begin
       $display("SB   Data  Compared Successful");
     end
     else
     begin
       $display("SB   Data  Compared Unsuccessful");
     end
     
     
       $display("Haddr =%0h",mxtn.Haddr); 
       $display("Hwdata=%0h",mxtn.Hwdata);
       $display("Hrdata=%0h",mxtn.Hrdata); 
       
       $display("Paddr =%0h",sxtn.Paddr);
       $display("Pwdata=%0h",sxtn.Pwdata); 
       $display("Prdata=%0h",sxtn.Prdata);
   endfunction
/*<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>*/
   
   





















