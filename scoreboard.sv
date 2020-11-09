// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Scoreboard del testbench del Bus Serial.

class scoreBoard #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
  trans_sb_mbx sb_chckr_mbx;  // Mailbox checker-scoreboard
    trans_sb_mbx sb_agnt_mbx; // Mailbox agente-sb
    
    trans_scoreboard #(.pckg_sz(pckg_sz)) from_chckr; // Objeto de transacción para enviar datos hacia el checker
    trans_scoreboard #(.pckg_sz(pckg_sz)) from_agnt;  // Objeto de transacción para recibir datos del agente
    
    trans_scoreboard scoreboard[$] = {}; // esta es la estructura dinámica que maneja el scoreboard  
    trans_scoreboard completadas[$] = {};
    int ret_tot = 0;
    int transacciones_falladas = 0;
    int transacciones_completadas = 0;
    string d_env, d_recib, origen, destino, t_envio, t_recib, lat, complt, linea_csv;
    
    task run;
      $display("[%g] El scoreboard fue inicializado.", $time);
      $system("echo 'Dato enviado, Dato recibdo, Terminal de procedencia, Terminal de destino, Tiempo de envío, Tiempo de recibido, Latencia, Completado, Tipo de transacción' > output.csv");
      forever begin
        sb_chckr_mbx.get(from_chckr);
        from_chckr.print("[Scoreboard: Guardando transacción recibida desde el checker.");
        scoreboard.push_back(from_chckr);
        newRowOut(from_chckr);
        ret_tot = ret_tot + from_chckr.latencia;
        if(from_chckr.completado == 1) begin
          transacciones_completadas++;
          completadas.push_back(from_chckr);
        end
        else begin
          transacciones_falladas++;
        end
      end
  endtask
  
  // Función para agregar una fila al archivo de salida .csv
  function void newRowOut(const ref trans_scoreboard from_chckr);
          d_env.hextoa(from_chckr.dato_transmitido);
          d_recib.hextoa(from_chckr.dato_recibido);
          origen.hextoa(from_chckr.Origen);
          destino.hextoa(from_chckr.Destino);
          t_envio.itoa(from_chckr.tiempo_envio);
          t_recib.itoa(from_chckr.tiempo_recibido);
          lat.itoa(from_chckr.latencia);
          complt.hextoa(from_chckr.completado);
          linea_csv = {d_env,",",d_recib,",",origen,",",destino,",",t_envio,",",t_recib,",",lat,",",complt};
          $system($sformatf("echo %0s, %0s >> output.txt",linea_csv,from_chckr.tipo));
      endfunction
  
endclass
