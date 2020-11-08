// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Transacciones del testbench de un bus serial
// 
// 
// Transacciones:
// 
// [Test:Generator]
// Contenido aleatorio/específico Origen aleatorio/específico Destino aleatorio/específico Secuencias de transacciones aleatorias
//
// [Driver/Monitor:Agente/Checker]
// Retardo/Dato/Tiempo/Tipo/Origen/Destino
//
// [Checker:Scoreboard]
// Tiempo_envío/Tiempo_recibido/Latencia/Origen/Destino/Dato/Resultado
//
// [Test:Scoreboard]
// Retardo_promedio/Reporte_Completo/Porcentaje_fallos/Porcentaje_éxitos
//
// [Test:Generator]
// Push/Pop/Reset



///////////////////////////////////////////////////////////////////////////////////////////////
//Definición de enumeraciones [Tipo_de_accion--Solicitud_scoreboard--Instrucciones_Generador]//
///////////////////////////////////////////////////////////////////////////////////////////////
typedef enum {trans, reset} tipo_acc; 

typedef enum {retardo_promedio,completo,porcentaje_fails,porcentaje_succ} solicitud_sb;

typedef enum {llenado_aleatorio,trans_aleatoria,trans_especifica,sec_trans_aleatorias,or_al,or_esp,dest_al,dest_esp} instrucciones_gen;


/////////////////////////////////
//Driver/Monitor:Agente/Checker//
/////////////////////////////////
class trans_bus #(parameter pckg_sz = 16,parameter drvrs=4;
	rand int retardo;
	rand bit [pckg_sz-1:0] dato;
	int tiempo;
	rand tipo_acc tipo;
	int max_retardo;
	rand bit [pckg_sz-1:pckg_sz-8] Origen;
	rand bit [pckg_sz-1:pckg_sz-8] Destino;

	constraint const_retardo{retardo<max_retardo; retardo>0;}
	constraint dest{dato[pckg_sz-1:pckg_sz-8]=Destino ; Destino<=drvrs}


	function new(int ret=0, bit [pckg_sz-1:0] dt=0,int tmp=0,tipo_acc tpo=Push, int retrdo_mx=10,bit [drvr_bit-1:0] org=0);
		this.retardo=ret;
		this.dato=dt;
		this.tiempo=tmp;
		this.tipo=tpo;
		this.max_retardo=retrdo_mx;
		this.Origen=org;
		this.Destino=dt[pckg_sz-1:pckg_sz-8];
	endfunction

	function void print (string tag = "");
		$display("[%g] %s Tipo=%s Tiempo=%g Retardo=%g dato=0x%h Origen=0x%h Destino=0x%h",$time,tag,this.tipo,this.tiempo,this.retardo,
			this.dato,this.Origen,this.Destino);
	endfunction
endclass


//////////////////////////////////
//Transacción Monitor:Scoreboard//
//////////////////////////////////
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
		this.latencia=this.tiempo_recibido-this.tiempo_envio;
	endtask

	function print (string tag);
    $display("[%g] %s dato=0x%h,origen=0x%h,destino=0x%h,t_push=%g,t_pop=%g,cmplt=%g,ovrflw=%g,undrflw=%g,rst=%g,ltncy=%g", 
             $time,
             tag, 
             this.dato_transmitido,
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




////////////////////////////////////////////
//Definicion de mailboxes de tipo definido//
////////////////////////////////////////////
typedef mailbox #(trans_bus) trans_bus_mbx;

typedef mailbox #(trans_scoreboard) trans_sb_mbx;

typedef mailbox #(solicitud_sb) comando_test_sb_mbx;

typedef mailbox #(instrucciones_gen) comando_test_agent_mbx;



////////////////////////////////////////////////////////////////////////
//Definicion de interface entre driver/monitor al bus de tipo definido//
////////////////////////////////////////////////////////////////////////
interface bus_if #(parameter pckg_sz = 16, parameter drvrs = 4,parameter bits = 1) (
  input clk
);
  logic reset;
  logic pndng[bits-1:0][drvrs-1:0];
  logic push[bits-1:0][drvrs-1:0];
  logic pop[bits-1:0][drvrs-1:0];
  logic [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
  logic [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];

endinterface
