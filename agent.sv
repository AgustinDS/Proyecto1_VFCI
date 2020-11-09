// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Modulo agente del testbench de un bus serial
//
//llenado_aleatorio,trans_aleatoria,trans_especifica,sec_trans_aleatorias

class agent #(parameter pckg_sz=16,parameter drvrs=4);
  trans_bus_mbx agnt_drv_mbx;           // Mailbox del agente al driver
  trans_bus_mbx agnt_chkr_mbx;
  comando_test_agent_mbx test_agent_mbx; // Mailbox del test al agente
  int num_transacciones;                 // Número de transacciones para las funciones del agente
  int max_retardo; 
  int ret_spec;
  bit [7:0] or_spec;
  bit [7:0] dst_spec;
  
  tipo_trans tpo_spec;

  bit [pckg_sz-1:0] dto_spec;
  instrucciones_agente instruccion;      // para guardar la última instruccion leída
  trans_bus #(.pckg_sz(pckg_sz),.drvrs(drvrs)); transaccion;
   
  function new;
    num_transacciones = 2;
    max_retardo = 10;
  endfunction

  task run;
    $display("[%g]  El Agente fue inicializado",$time);
    forever begin
      #1
      if(test_agent_mbx.num() > 0)begin
        $display("[%g]  Agente: se recibe instruccion",$time);
        test_agent_mbx.get(instruccion);
        case(instruccion)
          sec_trans_aleatorias: begin  // Esta instruccion genera num_tranacciones escrituras seguidas del mismo número de lecturas
            for(int i = 0; i < num_transacciones;i++) begin
              transaccion =new;
              transaccion.max_retardo = max_retardo;
              transaccion.randomize();
              std::randomize (transaccion.tipo) with {transaccion.tipo dist{trans:=60,broadcast:=30,reset:=10}; };
              transaccion.print("Agente: transacción creada");
              transaction.tiempo = $time;
              agnt_drv_mbx.put(transaccion);
              agnt_chkr_mbx.put(transaccion);
            end
          end
          trans_especifica: begin  // Esta instrucción genera una transacción específica
            transaccion =new;
            transaccion.tipo = tpo_spec;
            transaccion.dato = dto_spec;
            transaccion.retardo = ret_spec;
            transaccion.Origen= or_spec;
            transaccion.Destino= dst_spec;
            transaccion.print("Agente: transacción creada");
            transaction.tiempo = $time;
            agnt_drv_mbx.put(transaccion);
            agnt_chkr_mbx.put(transaccion);
          end
          broadcast_esp: begin
            transaccion =new;
            transaccion.tipo = broadcast;
            transaccion.dato = dto_spec;
            transaccion.retardo = ret_spec;
            transaccion.Origen= or_spec;
            transaccion.Destino= dst_spec;
            transaccion.print("Agente: transacción creada");
            transaction.tiempo = $time;
            agnt_drv_mbx.put(transaccion);
            agnt_chkr_mbx.put(transaccion);
          end
          broadcast_al: begin
            transaccion =new;
            transaccion.randomize();
            std::randomize (transaccion.tipo) with {transaccion.tipo dist{trans:=60,broadcast:=30,reset:=10}; };
            transaccion.tipo = broadcast;
            transaccion.print("Agente: transacción creada");
            transaction.tiempo = $time;
            agnt_drv_mbx.put(transaccion);
            agnt_chkr_mbx.put(transaccion);
          end
        endcase
      end
    end
  endtask
endclass
