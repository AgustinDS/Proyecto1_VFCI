// Módulo Checker

class checker #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
	trans_sb_mbx chckr_sb_mbx;	// Mailbox checker-scoreboard
  	trans_bus chckr_mntr_mbx;	// Mailbox checker-monitor
  	trans_bus auxiliar;		// Item auxiliar para emular el fifo de cada dispositivo

  	trans_bus #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) trans_item; 		//Mensaje para comunicación con el monitor
  	trans_bus #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) aux_item [$];
  	trans_scoreboard #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) sb_item;	// Mensaje para comunicación con el scoreborard
	
	int cont_aux;
	
	function new();
		this.aux_item = {};
		this.cont_aux = 0;
	endfunction
	
	task run;
		$display("[%g] El checker fue inicializado.", $time);
		sb_item = new();
		forever begin
			sb_item = new();
			sb_item.clean();
			chckr_mntr_mbx.get(trans_item);
			trans_item.print("Checker: Transacción recibida desde el monitor.");
			case(trans_item.tipo)
				Push: begin
				
				end
				
				Pop begin
				
				end
				
				reset begin
				
				end
		end
	endtask
endclass
