`timescale 1ns/1ps
`include "Library.sv"
`include "Transactions.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "checker.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "ambiente.sv"

///////////////////////////////////
// Módulo para correr la prueba  //
///////////////////////////////////



class rand_param
	rand bit [7:0] drv;
	rand int Fife;

  	constraint dispositivos {drv>0;drv<256;}
  	constraint Prof_fifos {Fife>0;Fife<500;}

endclass    

module testbench; 
  reg clk;
  parameter pckg_sz=16;
  parameter drvrs=4;
  parameter Fif_Size=10;
  parameter bit drvrs_al=0;
  parameter bit fif_z_al=0;

  test #(.pckg_sz(pckg_sz),.drvrs(drvrs),.Fif_Size(Fif_Size)) t0;

  bus_if  #(.pckg_sz(pckg_sz),.drvrs(drvrs)) _if(.clk(clk));

  always #5 clk = ~clk;
///DUT

  initial begin
  	rand_param rand_params=new;
  	rand_params.randomize();
  	if (drvrs_al) begin
  		defparam t0.drvrs=rand_params.drv;
  		defparam t0.Fif_Size=rand_params.Fife;
  	end
  	if (fif_z_al) begin
  		defparam _if.drvrs=rand_params.drv;
  	end

    clk = 0;
    t0 = new();
    t0._if = _if;
    t0.ambiente_inst.driver_inst.vif = _if;
    fork
      t0.run();
    join_none
  end
 
  always@(posedge clk) begin
    if ($time > 100000)begin
      $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
      $finish;
    end
  end
endmodule






