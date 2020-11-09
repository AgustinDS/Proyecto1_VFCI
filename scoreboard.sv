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
  	
  	trans_scoreboard #(.pckg_sz(pckg_sz)) from_chckr; // Objeto de transacción para enviar datos hacia el checker
  	trans_scoreboard #(.pckg_sz(pckg_sz)) from_agnt;  // Objeto de transacción para recibir datos del agente
  	
  	trans_sb scoreboard[$] = {}; // esta es la estructura dinámica que maneja el scoreboard  
  	trans_sb completadas[$] = {};
  	int ret_tot = 0;
  	int transacciones_falladas = 0;
  	int transacciones_completadas = 0;
  	
  	task run;
  		$display("[%g] El scoreboard fue inicializado.", $time);
  		$system();
  		forever begin
  			sb_chckr_mbx.get(from_chckr);
  			from_chckr.print("[%g] Scoreboard: Guardando transacción recibida desde el checker.", $time);
  			scoreboard.push_back(from_chckr);
  			ret_tot = ret_tot + from_chckr.latencia;
  			if(from_chckr.completado == 1) begin
  				transacciones_completadas++;
  				completadas.push_back(from_chckr);
  			end
  			else begin
  				transsacciones_falladas++;
  			end
  		end
	endtask
	
	function void append2outputTXT(const ref checker_item citem);
        payload.hextoa(citem.fpayload);
        receive_device.itoa(citem.receive_device);
        send_device.itoa(citem.send_device);
        treceive.itoa(citem.treceive);
        tsend.itoa(citem.tsend);
        receive_delay.itoa(citem.receive_delay);
        ID.itoa(citem.ID);
        outputTXT_line = {ID,comma,tsend,comma,send_device,comma,payload,comma,treceive,comma,receive_device,comma,receive_delay};
        $system($sformatf("echo %0s >> output.txt",outputTXT_line));
    endfunction
	
endclass
