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
    
module testbench; 
  reg clk;
  parameter pckg_sz=16;

  rand bit [7:0] drv;
  rand int Fife;

  constraint dispositivos {drv>0;drv<256;}
  constraint Prof_fifos {Fife>0;Fife<500;}

  test #(.pckg_sz(pckg_sz),.drvrs(drv),.Fif_Size(Fife)) t0;

  bus_if  #(.pckg_sz(pckg_sz),.drvrs(drv)) _if;
  always #5 clk = ~clk;
///DUT

  initial begin
    
  	if (drvrs_al) begin
      drv.randomize();
    end else
    begin
      drv=drvrs;
    end

    if (fif_z) begin
      Fife.randomize();
    end else
    begin 
      Fife=Fif_Size;
    end
    
    defparam t0.drvrs=drv;
    defparam t0.Fif_Size=Fife;
    defparam _if.drvrs=drv;

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






