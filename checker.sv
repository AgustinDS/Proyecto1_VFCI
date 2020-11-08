// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Checker del testbench del Bus Serial.

class checker #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 32, parameter broadcast = {8{1'b1}});
	trans_sb_mbx chckr_sb_mbx;	// Mailbox checker-scoreboard
  	trans_bus chckr_mntr_mbx;	// Mailbox checker-monitor
  	trans_bus chckr_agnt_mbx;	// Mailbox para recibir las transacciones enviadas al driver, se debe conectar al mbx agente-driver
  	// trans_bus auxiliar;		// Item auxiliar para emular el fifo de cada dispositivo

  	trans_bus #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) from_mntr; 		//Mensaje para comunicación con el monitor
  	trans_bus #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) from_agnt;
  	trans_scoreboard #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) sb_item;	// Mensaje para comunicación con el scoreborard
	
	///////////////////////////////////////////// Ver esto /////////////////////////////////
	function new();
		//this.aux_item = {};
		//this.cont_aux = 0;
	endfunction
	
	task run;
		$display("[%g] El checker fue inicializado.", $time);
		sb_item = new();
		forever begin
			// sb_item = new();
			sb_item.clean();
			chckr_agnt_mbx.get(from_agnt);
			trans_item.print("Checker: Transacción recibida desde el agente.");
			case(trans_item.tipo)
				trans: begin
					// Esperar delay / pos o neg edge
					// Obtener D_push y push del monitor para dispistivo destino
					// Ver que los otros dispositivos tengan push en 0
					// Comparar dato del monitor con el del agente
					// Enviar resultado al sb
				end
				
				reset: begin
					// Esperar delay/pos o neg edge
					// Recibir info del mntr y ver que todo sea 0!!!
				end
				
				broadcast: begin
					// Esperar delay / pos o neg edge
					// Obtener D_push y push del monitor para todos los dispositivos excepto origen
					// Comparar dato del monitor con el del agente y verificar señal de push
					// Enviar resultado al sb
				end
		end
	endtask
endclass
