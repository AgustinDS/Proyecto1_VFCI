// Item del Mailbox Driver-Agente / Monitor-Checker
class bs_gnrtr_n_rbtr_item #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
  
  bit pndng[bits-1:0][drvrs-1:0];
  bit push[bits-1:0][drvrs-1:0];
  bit pop[bits-1:0][drvrs-1:0];
  bit [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
  rand bit [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];
	
  function void print();
  	int i;
  	int d;
  	for(i=0; i < bits; i=i+1) begin
    	for(d=0; d < drvrs; d=d+1) begin
          $display ("Dispositivo %d, Pending: %b, Push: %b, Pop: %b, D_push: %b, D_pop: %b", d, pndng[i][d], push[i][d], pop[i][d], D_pop[i][d], D_push[i][d]);
  		end
  	end
  endfunction
  
endclass


// Interfaz entre Driver/Monitor y DUT

interface fifo_if #(parameter bits =1, parameter drvrs = 4, parameter pckg_sz = 16) (input bit clk);
  
  logic pndng[bits-1:0][drvrs-1:0];
  logic push[bits-1:0][drvrs-1:0];
  logic pop[bits-1:0][drvrs-1:0];
  logic [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
  logic [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];
  logic rst;
endinterface

//Clase que emula los dispositivos del bus

class device;
	mailbox dev_mbx;
  	
  	bs_gnrtr_n_rbtr_item dev_item;
  
  	bs_gnrtr_n_rbtr_item fifo[$];
  
  	//function push;
      	// Push
    //endfunction
  
	//function pop;
    	// Pop
   	//endfunction
  	
  	
  
endclass

class monitor;
  
endclass
