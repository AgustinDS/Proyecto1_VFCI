// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Scoreboard del testbench del Bus Serial.

class scoreboard #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
	trans_sb_mbx sb_chckr_mbx;	// Mailbox checker-scoreboard
  	trans_sb_mbx sb_agnt_mbx;	// Mailbox agente-sb
  	
  	trans_scoreboard #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) from_chckr; // Objeto de transacción para enviar datos hacia el checker
  	trans_scoreboard #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) from_agnt;  // Objeto de transacción para recibir datos del agente
  	
  	task run;
  		$display("[%g] El scoreboard fue inicializado.", $time);
  		forever begin
  	////////////// #5 REVISAR CUANTO HAY QUE ESPERAR ////////////////////////////////////////////////////////////////////
  			if (sb_agnt_mbx.num > 0) begin
  				sb_agnt_mbx.get(from_chckr);
  				from_agnt.print("Scoreboard: Transacción recibida desde el monitor.");
  				
  			end	
  		end

endclass
