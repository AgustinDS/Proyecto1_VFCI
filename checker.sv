// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Checker del testbench del Bus Serial.

class checker #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
	trans_sb_mbx chckr_sb_mbx;	// Mailbox checker-scoreboard
  	trans_bus chckr_mntr_mbx;	// Mailbox checker-monitor
  	trans_bus auxiliar;		// Item auxiliar para emular el fifo de cada dispositivo

  	trans_bus #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) trans_item; 		//Mensaje para comunicación con el monitor
  	trans_bus #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) aux_item [$];
  	trans_scoreboard #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) sb_item;	// Mensaje para comunicación con el scoreborard
	
	int i;
	int j;
	event inicio;
	semaphore bus_sem;
	bit [pckg_sz-1:0] emu_D_push[bits-1:0][drvrs-1:0];
	
	function new();
		this.aux_item = {};
		this.cont_aux = 0;
	endfunction
	
	task bus_emulator;
		bus_sem = new(1);
		foreach(trans_item.pndng[0][i]) begin
			fork
				wait(inicio.triggered);
				if(trans_item.pndng[0][i]) begin
					bus_sem.get(1);
					foreach(trans_item.D_pop[0][j]) begin
						if((trans_item.D_pop[0][j][pckg_sz-1:pckg_sz-8] == j) || (trans_item.D_pop[0][j][pckg_sz-1:pckg_sz-8] == broadcast)) begin
							emu_D_push[0][j] = trans_item.D_pop[0][j];
							auxiliar.put(emu_D_push[0][j]);
						end
					end
				end
			join_none
		end
		// @(negedge bif.clk);
		->inicio;
	endtask
	
	task run;
		$display("[%g] El checker fue inicializado.", $time);
		sb_item = new();
		forever begin
			sb_item = new();
			sb_item.clean();
			chckr_mntr_mbx.get(trans_item);
			trans_item.print("Checker: Transacción recibida desde el monitor.");
			case(trans_item.tipo)
				trans: begin
				
				end
				
				reset: begin
				
				end
				
				broadcast: begin
				
				end
		end
	endtask
endclass
