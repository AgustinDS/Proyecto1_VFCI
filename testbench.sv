`timescale 1ns/1ps
`include "Library.sv"
`include "Transactions.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "checker.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "ambiente.sv"
`include "test.sv"

///////////////////////////////////
// Módulo para correr la prueba  //
///////////////////////////////////


module testbench; 
  reg clk;
  parameter pckg_sz=16;
  parameter drvrs=4;
  parameter Fif_Size=10;
  parameter bit drvrs_al=0;
  parameter bit fif_z_al=0;
  


  test #(.pckg_sz(pckg_sz),.drvrs(drvrs),.Fif_Size(Fif_Size)) t0;

  bus_if  #(.pckg_sz(pckg_sz),.drvrs(drvrs)) inf(.clk(clk));

  always #5 clk = ~clk;
///DUT

  initial begin

  	//if (drvrs_al) begin
    	//drvrs=$urandom();
  	//end
  	//if (fif_z_al) begin
     	//Fif_Size=$urandom();
  	//end

    clk = 0;
    t0 = new();
    t0.inf = inf;
    t0.ambiente_inst.driver_inst.vif =inf;
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






