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
			from_agnt.print("Checker: Transacción recibida desde el agente.");
			chckr_mntr_mbx.get(from_mntr);
			from_mntr.print("Checker: Transacción recibida desde el monitor.");
			if(from_mntr.tipo == from_agnt.tipo) begin
				case(trans_item.tipo)
					trans: begin
						if(from_mntr.dato == from_agnt.dato) begin
							$display("Checker: Transacción completada con éxito.");
							//sb_item.dato_transmitido
							//sb_item.Origen
							//sb_item.Destino
							//sb_item.tiempo_envio
							//sb_item.tiempo_recibido
							
							// Enviar al scoreboard
						end else
						begin
							$display("Checker: [ERROR] Dato incorrecto recibido en el dispositivo.");
							// Enviar al scoreboard
						end
					end
				
					reset: begin
						if(from_mntr.dato == {16{1'b0}}) begin
							$display("Checker: Reset completado con éxito.");
							// Enviar al scoreboard
						end else
						begin
							$display("Checker: [ERROR] Reset no se realizó correctamente.");
							// Enviar al scoreboard
						end
					end
					
					broadcast: begin
						if(from_mntr.dato == from_agnt.dato) begin
							$display("Checker: Broadcast completado con éxito.");
							// Enviar al scoreboard
						end else
						begin
							$display("Checker: [ERROR] Dato incorrecto recibido en el dispositivo.");
							// Enviar al scoreboard
						end
					end
				endcase
			end else
			begin
				$display("Checker: [ERROR] El tipo de transacción recibida del monitor no coincide con la del agente.");
				// Enviar al scoreboard
			end
		end
	endtask
endclass
