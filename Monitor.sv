// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Modulo Monitor del testbench de un bus serial
//
//

class monitor #(parameter pckg_sz=16,parameter drvrs=4,parameter Fif_Size=10,parameter brodcst={8{1'b1}});
  virtual bus_if #(.pckg_sz(pckg_sz),.drvrs(drvrs)) vif;
  trans_bus_mbx mntor_chkr_mbx;
  int espera;

    bit [pckg_sz-1:0] D_in [drvrs][$:Fif_Size]; //FIFOS emuladas 
  

  task run();
   $display("[%g] El monitor fue inicializado",$time);
    

    @(posedge vif.clk);
      forever begin
      trans_bus #(.pckg_sz(pckg_sz),.drvrs(drvrs)) transaction;
            

      $display("[%g] el monitor esta enviado el dato al checker",$time);        
      espera = 0;
      @(posedge vif.clk);
      $display("Transacciones pendientes en el mbx mntor_chkr = %g",mntor_chkr_mbx.num());

      while(espera < transaction.retardo)begin
        @(posedge vif.clk);
            espera = espera+1;
      end

      if (vif.D_push[0][0][pckg_sz-1:pckg_sz-8]==brodcst) begin
        transaction.tipo=broadcast;
        foreach(vif.push[0][i]) begin
          if (vif.push[0][i]) begin
              D_in[i].push_back(vif.D_push[0][i]);
              transaction.dato=D_in[i].pop_front;
          end
        end
        mntor_chkr_mbx.put(transaction);
        $display("[%g] Operación completada",$time);
        transaction.tiempo=$time;
        transaction.print("Monitor: Transaccion enviada al checker");
      end else
      begin
        foreach(vif.push[0][i]) begin
          fork
            forever @(posedge vif.clk) begin              
              if (vif.reset) begin
                transaction.tipo=reset;
                D_in[i].push_back(vif.D_push[0][i]);
                $display("[%g] Operación completada",$time);
                transaction.tiempo=$time;
                transaction.dato=D_in[i].pop_front;
                mntor_chkr_mbx.put(transaction);
                transaction.print("Monitor: Transaccion enviada al checker"); 
              end else 
              begin
                if (vif.push[0][i]) begin
                  transaction.tipo=trans;
                  D_in[i].push_back(vif.D_push[0][i]);
                  $display("[%g] Operación completada",$time);
                  transaction.tiempo=$time;
                  transaction.dato=D_in[i].pop_front;
                  mntor_chkr_mbx.put(transaction);
                  transaction.print("Monitor: Transaccion enviada al checker"); 
                end
              end 
            end
          join_none
        end
      end

      @(posedge vif.clk);
    end
  endtask
endclass