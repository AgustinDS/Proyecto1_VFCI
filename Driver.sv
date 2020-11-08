// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Modulo Driver del testbench de un bus serial
//
//

class driver #(parameter pckg_sz=32,parameter drvrs=4);
	virtual bus_if #(.pckg_sz(pckg_sz),.drvrs(drvrs)) vif;
	trans_bus_mbx agnt_drv_mbx;
	trans_bus_mbx mntor_chkr_mbx;
	int espera;

  	bit [pckg_sz-1:0] D_out[drvrs][$]; //FIFOS emuladas 
	

	task run();
		$$display("[%g] El driver fue inicializado",$time);

		foreach(vif.pop[0][i]) begin
  			fork
  				forever @(posedge vif.clk) begin
  			 		if (vif.pop[0][i]) begin
  			 			vif.D_pop[0][i]=D_out[i].pop_front;
  			 		end
  			 	end
  			 join_none
  		end

		@(posedge vif.clk);
		vif.reset=1;
		@(posedge vif.clk);
		forever begin
			trans_bus #(.pckg_sz(pckg_sz),.drvrs(drvrs)) transaction;
			vif.reset=0;

			foreach(vif.pndng[i]) begin
				foreach(vif.pndng[i][j]) begin
					vif.pndng[i][j]=0;
					vif.D_pop[i][j]=0;
				end 
			end

      		$display("[%g] el Driver espera por una transacción",$time);				
      		espera = 0;
      		@(posedge vif.clk);
      		agnt_drv_mbx.get(transaction);
      		transaction.print("Driver: Transaccion recibida");
      		$display("Transacciones pendientes en el mbx agnt_drv = %g",agnt_drv_mbx.num());

      		while(espera < transaction.retardo)begin
        		@(posedge vif.clk);
          		espera = espera+1;
			end

			case(transaction.tipo)
				broadcast:begin
					
					foreach (D_out[i]) begin	
                      	if (i!=transaction.Origen) begin
							D_out[i].push_back(transaction.dato);
							vif.pndng[0][i]=1;
						end 
					end
					
					transaction.tiempo = $time;
					drv_chkr_mbx.put(transaction); 
	     			transaction.print("Driver: Transaccion ejecutada");
					

				end

				trans:begin
                  	D_out[transaction.Origen].push_back(transaction.dato); //Agregamos el dato enviado en la fifo out del origen
					vif.pndng[0][transaction.Origen]=1;

					transaction.tiempo = $time;
					drv_chkr_mbx.put(transaction); 
	     			transaction.print("Driver: Transaccion ejecutada");

				end

				reset:begin
					vif.reset=1;
					transaction.tiempo = $time;
					mntor_chkr_mbx.put(transaction);
  			 		transaction.print("Driver: Transaccion enviada al checker");
					transaction.print("Driver: Transaccion ejecutada");
				end

				default:begin
					$display("[%g] Driver Error: la transacción recibida no tiene tipo valido",$time);
	   	 			$finish;
				end
			endcase // transaction.tipo
			@(posedge vif.clk);
		end
	endtask
endclass
