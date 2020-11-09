// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Checker del testbench del Bus Serial.

class checkr #(parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
	trans_sb_mbx chckr_sb_mbx=new;	// Mailbox checker-scoreboard
  	trans_bus_mbx chckr_mntr_mbx=new;	// Mailbox checker-monitor
  	trans_bus_mbx chckr_agnt_mbx=new;	// Mailbox para recibir las transacciones enviadas al driver, se debe conectar al mbx agente-driver

  	trans_bus #(.drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) from_mntr; 	//Mensaje para comunicación con el monitor
  	trans_bus #(.drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) from_agnt;	// Mensaje para recibir información del agente
  	trans_scoreboard #(.pckg_sz(pckg_sz)) sb_item;					// Mensaje para comunicación con el scoreboard
	
	task run;
		$display("[%g] El checker fue inicializado.", $time);
		sb_item = new();
      	from_agnt =new();
      	from_mntr =new();
		forever begin
			sb_item = new();
			sb_item.clean();
			chckr_agnt_mbx.get(from_agnt);
			from_agnt.print("Checker: Transacción recibida desde el agente.");
			chckr_mntr_mbx.get(from_mntr);
			from_mntr.print("Checker: Transacción recibida desde el monitor.");
			if(from_mntr.tipo == from_agnt.tipo) begin
				case(from_mntr.tipo)
					trans: begin
						if(from_mntr.dato == from_agnt.dato) begin
							$display("[%g] Checker: Transacción completada con éxito.", $time);
							// Enviar al scoreboard
							sb_item.dato_transmitido=from_agnt.dato;
							sb_item.dato_recibido=from_mntr.dato;
							sb_item.Origen=from_agnt.Origen;
							sb_item.Destino=from_agnt.Destino;
							sb_item.tiempo_envio=from_agnt.tiempo;
							sb_item.tiempo_recibido=from_mntr.tiempo;
							sb_item.completado=1;
							sb_item.latencia_calc;
							sb_item.tipo=from_mntr.tipo;
							
							chckr_sb_mbx.put(sb_item);
						end else
						begin
							$display("[%g] Checker: [ERROR] Dato incorrecto recibido en el dispositivo.", $time);
							// Enviar al scoreboard
							sb_item.dato_transmitido=from_agnt.dato;
							sb_item.dato_recibido=from_mntr.dato;
							sb_item.Origen=from_agnt.Origen;
							sb_item.Destino=from_agnt.Destino;
							sb_item.tiempo_envio=from_agnt.tiempo;
							sb_item.tiempo_recibido=from_mntr.tiempo;
							sb_item.completado=0;
							sb_item.latencia_calc;
							sb_item.tipo=from_agnt.tipo;
							
							chckr_sb_mbx.put(sb_item);
						end
					end
				
					reset: begin
						if(from_mntr.dato == {pckg_sz{1'b0}}) begin
							$display("[%g] Checker: Reset completado con éxito.", $time);
							// Enviar al scoreboard
							sb_item.dato_recibido=from_mntr.dato;
							sb_item.tiempo_envio=from_agnt.tiempo;
							sb_item.tiempo_recibido=from_mntr.tiempo;
							sb_item.completado=1;
							sb_item.latencia_calc;
							sb_item.tipo=from_agnt.tipo;
							
							chckr_sb_mbx.put(sb_item);
						end else
						begin
							$display("[%g] Checker: [ERROR] Reset no se realizó correctamente.", $time);
							// Enviar al scoreboard
							sb_item.dato_recibido=from_mntr.dato;
							sb_item.tiempo_envio=from_agnt.tiempo;
							sb_item.tiempo_recibido=from_mntr.tiempo;
							sb_item.completado=0;
							sb_item.latencia_calc;
							sb_item.tipo=from_agnt.tipo;
							
							chckr_sb_mbx.put(sb_item);
						end
					end
					
					broadcast: begin
						if(from_mntr.dato == from_agnt.dato) begin
							$display("[%g] Checker: Broadcast completado con éxito.", $time);
							// Enviar al scoreboard
							sb_item.dato_transmitido=from_agnt.dato;
							sb_item.dato_recibido=from_mntr.dato;
							sb_item.Origen=from_agnt.Origen;
							sb_item.Destino=from_agnt.Destino;
							sb_item.tiempo_envio=from_agnt.tiempo;
							sb_item.tiempo_recibido=from_mntr.tiempo;
							sb_item.completado=1;
							sb_item.latencia_calc;
							sb_item.tipo=from_mntr.tipo;
							
							chckr_sb_mbx.put(sb_item);
						end else
						begin
							$display("[%g] Checker: [ERROR] Dato incorrecto recibido en el dispositivo.", $time);
							// Enviar al scoreboard
							sb_item.dato_transmitido=from_agnt.dato;
							sb_item.dato_recibido=from_mntr.dato;
							sb_item.Origen=from_agnt.Origen;
							sb_item.Destino=from_agnt.Destino;
							sb_item.tiempo_envio=from_agnt.tiempo;
							sb_item.tiempo_recibido=from_mntr.tiempo;
							sb_item.completado=0;
							sb_item.latencia_calc;
							sb_item.tipo=from_agnt.tipo;
							
							chckr_sb_mbx.put(sb_item);
						end
					end
				endcase
			end else
			begin
				$display("[%g] Checker: [ERROR] El tipo de transacción recibida del monitor no coincide con la del agente.", $time);
				// Enviar al scoreboard
				sb_item.Origen=from_mntr.Origen;
				sb_item.Destino=from_mntr.Destino;
				sb_item.tiempo_envio=from_agnt.tiempo;
				sb_item.tiempo_recibido=from_mntr.tiempo;
				sb_item.completado=0;
				sb_item.latencia_calc;
				sb_item.tipo=from_agnt.tipo;
							
				chckr_sb_mbx.put(sb_item);
			end
		end
	endtask
endclass

