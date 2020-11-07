////////////////////////////////////////////////////////////////////////////////////////////////////
// Checker/scoreboard: este objeto es responsable de verificar que el comportamiento del DUT sea el esperado //
////////////////////////////////////////////////////////////////////////////////////////////////////
class checker #(parameter width=16, parameter depth =8);
  trans_fifo #(.width(width)) transaccion; //transacción recibida en el mailbox 
  trans_fifo #(.width(width)) auxiliar; //transacción usada como auxiliar para leer el fifo emulado 
  trans_sb   #(.width(width)) to_sb; // transacción usada para comunicarse con el scoreboard
  trans_fifo  emul_fifo[$]; //this queue is going to be used as golden reference for the fifo
  trans_fifo_mbx drv_chkr_mbx; // Este mailbox es el que comunica con el driver/monitor
  trans_sb_mbx  chkr_sb_mbx; // Este mailbox es el que comunica el checker con el scoreboard
  int contador_auxiliar; 

  function new();
    this.emul_fifo = {};
    this.contador_auxiliar = 0;
  endfunction 

  task run;
   $display("[%g]  El checker fue inicializado",$time);
   to_sb = new();
   forever begin
     to_sb = new();
     drv_chkr_mbx.get(transaccion);
     transaccion.print("Checker: Se recibe trasacción desde el driver");
     to_sb.clean();
     case(transaccion.tipo)
       lectura: begin
         if(0 !== emul_fifo.size()) begin //Revisa si el Fifo no está vacía
           auxiliar = emul_fifo.pop_front();
           if(transaccion.dato == auxiliar.dato) begin
             to_sb.dato_enviado = auxiliar.dato;
             to_sb.tiempo_push = auxiliar.tiempo;
             to_sb.tiempo_pop = transaccion.dato;
             to_sb.completado = 1;
             to_sb.calc_latencia();
             to_sb.print("Checker:Transaccion Completada");
             chkr_sb_mbx.put(to_sb);
           end else begin
             transaccion.print("Checker: Error el dato de la transacción no calza con el esperado");
            $display("Dato_leido= %h, Dato_Esperado = %h",transaccion.dato,auxiliar.dato);
            $finish; 
           end
         end else begin // si está vacía genera un underflow 
             to_sb.tiempo_pop = transaccion.tiempo;
             to_sb.underflow = 1;
             to_sb.print("Checker: Underflow");
             chkr_sb_mbx.put(to_sb);
         end
       end
       escritura: begin
         if(emul_fifo.size() == depth)begin // Revisa si la Fifo está llena para generar un overflow
           auxiliar = emul_fifo.pop_front();
           to_sb.dato_enviado = auxiliar.dato;
           to_sb.tiempo_push = auxiliar.tiempo;
           to_sb.overflow = 1;
           to_sb.print("Checker: Overflow");
           chkr_sb_mbx.put(to_sb);
           emul_fifo.push_back(transaccion);
         end else begin  // En caso de no estar llena simplemente guarda el dato en la fifo simulada
           transaccion.print("Checker: Escritura");
           emul_fifo.push_back(transaccion);
         end
       end
       reset: begin // en caso de reset vacía la fifo simulada y envía todos los datos perdidos al SB
         contador_auxiliar = emul_fifo.size();
         for(int i =0; i<contador_auxiliar; i++)begin
           auxiliar = emul_fifo.pop_front();
           to_sb.clean();
           to_sb.dato_enviado = auxiliar.dato;
           to_sb.tiempo_push = auxiliar.tiempo;
           to_sb.reset = 1;
           to_sb.print("Checker: Reset");
           chkr_sb_mbx.put(to_sb);
         end
       end
       default: begin
         $display("[%g] Checker Error: la transacción recibida no tiene tipo valido",$time);
         $finish;
       end
     endcase    
   end 
  endtask
endclass 
