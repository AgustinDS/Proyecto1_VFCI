// module bs_gnrtr_n_rbtr #(parameter bits = 1,parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) (
//   input clk,
//   input reset,
//   input  pndng[bits-1:0][drvrs-1:0],
//   output push[bits-1:0][drvrs-1:0],
//   output pop[bits-1:0][drvrs-1:0],
//   input  [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0],
//   output [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0]



// Tipo
// Contenido
// Origen
// Destino
// Retardo
// Tiempo de ejecución
typedef enum {Push, Pop, reset} tipo_acc; 

class trans_bus #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
	rand int retardo;
	rand bit [pckg_sz-1:0] dato;
	int tiempo;
	rand tipo_oper tipo;
	int max_retardo;
	rand bit [drvr_bit-1:0] Origen;
	rand bit [drvr_bit-1:0] Destino;

	constraint const_retardo{retardo<max_retardo; retardo>0;}

	function new(int ret=0, bit [pckg_sz-1:0] dt=0,int tmp=0,tipo_acc tpo=Push, int retrdo_mx=10,bit [drvr_bit-1:0] org=0,bit [drvr_bit-1:0] dst=1);
		this.retardo=ret;
		this.dato=dt;
		this.tiempo=tmp;
		this.tipo=tpo;
		this.max_retardo=retrdo_mx;
		this.Origen=org;
		this.Destino=dst;
	endfunction

	function void print (string tag = "");
		$display("[%g] %s Tipo=%s Tiempo=%g Retardo=%g dato=0x%h Origen=0x%h Destino=0x%h",$time,tag,this.tipo,this.tiempo,this.retardo,
			this.dato,this.Origen,this.Destino);
	endfunction
endclass


interface bus_if #(parameter pckg_sz =16) (
  input clk
);
	logic reset;
	logic pndng;
	logic push;
	logic pop;
	logic [pckg_sz-1:0] D_pop; 
	logic [pckg_sz-1:0] D_push;

endinterface


// T_ envio
// T_ recibido
// Latencia
// Origen
// Dato
// Destino
// Resultado




class trans_scoreboard #(parameter pckg_sz=16,parameter drvr_bit=2);
	bit [pckg_sz-1:0] dato_transmitido;
	bit [drvr_bit-1:0] Origen;
	bit [drvr_bit-1:0] Destino;
	int tiempo_envio;
	int tiempo_recibido;
	bit completado;
	bit overflow;
	bit underflow;
	bit reset;
	int latencia;

	function clean ();
		this.dato_transmitido=0;
		this.Origen=0;
		this.Destino=1;
		this.tiempo_envio=0;
		this.tiempo_recibido=0;
		this.completado=0;
		this.overflow=0;
		this.underflow=0;
		this.reset=0;
		this.latencia=0;
	endfunction

	task latencia_calc;
		this latencia=this.tiempo_recibido-this.tiempo_envio;
	endtask

	function print (string tag);
    $display("[%g] %s dato=0x%h,origen=0x%h,destino=0x%h,t_push=%g,t_pop=%g,cmplt=%g,ovrflw=%g,undrflw=%g,rst=%g,ltncy=%g", 
             $time,
             tag, 
             this.dato_trasnmitido,
             this.Origen,
             this.Destino, 
             this.tiempo_envio,
             this.tiempo_recibido,
             this.completado,
             this.overflow,
             this.underflow,
             this.reset,
             this.latencia);
  endfunction

endclass


// Completo
// Retardo promedio
// Porcentaje de operaciones fallidas
// Cantidad de operaciones realizadas
// Cantidad de pops
// Cantidad de pushes



typedef enum {retardo_promedio,completo,porcentaje_fails,porcentaje_succ,cant_pop,cant_push} solicitud_sb;

/////////////////////////////////////////////////////////////////////////
// Definición de estructura para generar comandos hacia el agente      //
/////////////////////////////////////////////////////////////////////////


// Contenido aleatorio/específico
// Origen aleatorio/específico
// Destino aleatorio/específico

typedef enum {llenado_aleatorio,trans_aleatoria,trans_especifica,sec_trans_aleatorias,or_esp_dst_esp,or_esp_dst_al,or_al_dst_esp,or_al_dst_al} instrucciones_agente;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(trans_bus) trans_bus_mbx;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(trans_scoreboard) trans_sb_mbx;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(solicitud_sb) comando_test_sb_mbx;

///////////////////////////////////////////////////////////////////////////////////////
// Definicion de mailboxes de tipo definido trans_fifo para comunicar las interfaces //
///////////////////////////////////////////////////////////////////////////////////////
typedef mailbox #(instrucciones_agente) comando_test_agent_mbx;