// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Modulo Driver/monitor del testbench de un bus serial
//
//

class driver #(parameter pckg_sz=16,parameter drvrs=4);
	virtual bus_if #(.pckg_sz(pckg_sz),.drvrs(drvrs)) vif;
	trans_bus_mbx agnt_drv_mbx;
	trans_bus_mbx mntor_chkr_mbx;
	int espera;

	task run();
		$$display("[%g] El driver fue inicializado",$time);
		@(posedge vif.clk);
		vif.reset=1;
		@(posedge vif.clk);
		forever begin
			trans_bus #(.pckg_sz(pckg_sz),.drvrs(drvrs)) transaction;
			vif.reset=0;
			
			foreach(vif.pndng[i]) begin
				foreach(vif.pndng[i][j]) begin
					vif.pndng[i][j]=0;
					vif.push[i][j]=0;
					vif.pop[i][j]=0;
					vif.D_pop[i][j]=0;
					vif.D_push[i][j]=0;
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
				trans:begin
					transaction.dato=vif.D_pop[0][Origen];
					vif.D_push[0][Destino]=transaction.dato;

					vif.push[0][Destino]=0;
					vif.pop[0][Origen]=0;
					
					transaction.tiempo = $time;
					drv_chkr_mbx.put(transaction); 
	     			transaction.print("Driver: Transaccion ejecutada");

				end

				reset:begin
					vif.reset=1;

					transaction.tiempo = $time;
					mntor_chkr_mbx;.put(transaction);
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





