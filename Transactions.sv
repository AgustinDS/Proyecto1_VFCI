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
// [Agente:Driver]
// Retardo/Dato/Tiempo/Tipo/Origen/Destino
//
// [Agente:Checker]
// Retardo/Dato/Tiempo/Tipo/Origen/Destino
//
// [Monitor:Checker]
// Retardo/Dato/Tiempo/Tipo/Origen/Destino
//
// [Checker:Scoreboard]
// Tiempo_envío/Tiempo_recibido/Latencia/Origen/Destino/Dato/Resultado
//
// [Test:Scoreboard]
// Retardo_promedio/Reporte_Completo/Porcentaje_fallos/Porcentaje_éxitos
//
// [Test:Generator]
// sec_trans_aleatoria,trans_especifica,broadcast_esp,broadcast_al
//
// [Checker:Scoreboard]
// Dato/Origen/Destino/Tenvio/Trecibido/Completado/Tipo/Latencia


///////////////////////////////////////////////////////////////////////////////////////////////
//Definición de enumeraciones [Tipo_de_accion--Solicitud_scoreboard--Instrucciones_Generador]//
///////////////////////////////////////////////////////////////////////////////////////////////
typedef enum {trans,broadcast,reset} tipo_acc; 

typedef enum {retardo_promedio,completo,porcentaje_fails,porcentaje_succ} solicitud_sb;

typedef enum {sec_trans_aleatorias,trans_especifica,broadcast_esp,broadcast_al} instrucciones_agente;


/////////////////////////////////
//Driver/Monitor:Agente/Checker//
/////////////////////////////////
class trans_bus #(parameter pckg_sz = 32,parameter drvrs=4,parameter broadcast={8{1'b1}});
	rand int retardo;
	rand bit [pckg_sz-1:0] dato;
	int tiempo;
	rand tipo_acc tipo;
	int max_retardo;
	rand bit [7:0] Origen;
	rand bit [7:0] Destino;

  constraint const_retardo{retardo<=max_retardo; retardo>=0;}
  	constraint dest{dato[pckg_sz-1:pckg_sz-8]==Destino; Destino>=0;Destino==broadcast||Destino<drvrs;}
  	constraint org{Origen<drvrs;Origen>=0;}
  	constraint org_dest{Origen!=Destino;Origen>=0;Destino>=0;}
  	constraint brds{tipo==broadcast->Destino==broadcast;}

  function new(int ret=0, bit [pckg_sz-1:0] dt=0,int tmp=0,tipo_acc tpo=trans, int retrdo_mx=10,bit [7:0] Org);
		this.retardo=ret;
		this.dato=dt;
		this.tiempo=tmp;
		this.tipo=tpo;
		this.max_retardo=retrdo_mx;
		this.Origen=Org;
		this.Destino=dt[pckg_sz-1:pckg_sz-8];
	endfunction

	function void print (string tag = "");
		$display("[%g] %s Tipo=%s Tiempo=%g Retardo=%g dato=0x%h Origen=0x%h Destino=0x%h",$time,tag,this.tipo,this.tiempo,this.retardo,
			this.dato,this.Origen,this.Destino);
	endfunction
endclass


//////////////////////////////////
//Transacción Checker:Scoreboard//
//////////////////////////////////
class trans_scoreboard #(parameter pckg_sz=16);
	bit [pckg_sz-1:0] dato_transmitido;
	bit [pckg_sz-1:0] dato_recibido;
	bit [7:0] Origen;
	bit [7:0] Destino;
	int tiempo_envio;
	int tiempo_recibido;
	bit completado;
	int latencia;
	tipo_acc tipo;

	function clean ();
		this.dato_transmitido=0;
		this.dato_recibido=0;
		this.Origen=0;
		this.Destino=1;
		this.tiempo_envio=0;
		this.tiempo_recibido=0;
		this.completado=0;
		this.latencia=0;
		this.tipo=reset;
	endfunction

	task latencia_calc;
		this.latencia=this.tiempo_recibido-this.tiempo_envio;
	endtask

	function print (string tag);
      $display("[%g] %s ,Tipo=%s ,dato_enviado=0x%h,dato_recibido=0x%h,origen=0x%h,destino=0x%h,t_enviado=%g,t_recibido=%g,cmplt=%g,ltncy=%g", 
             $time,
             tag,
             this.tipo, 
             this.dato_transmitido,
             this.dato_recibido,
             this.Origen,
             this.Destino, 
             this.tiempo_envio,
             this.tiempo_recibido,
             this.completado,
             this.latencia);
  endfunction

endclass




////////////////////////////////////////////
//Definicion de mailboxes de tipo definido//
////////////////////////////////////////////
typedef mailbox #(trans_bus) trans_bus_mbx;

typedef mailbox #(trans_scoreboard) trans_sb_mbx;

typedef mailbox #(solicitud_sb) comando_test_sb_mbx;

typedef mailbox #(instrucciones_agente) comando_test_agent_mbx;



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
 