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

  
  always #5 clk = ~clk;
  
  
  test #(.pckg_sz(pckg_sz),.drvrs(drvrs),.Fif_Size(Fif_Size)) t0;

  bus_if  #(.pckg_sz(pckg_sz),.drvrs(drvrs)) _if(.clk(clk));

  
  
  
  bs_gnrtr_n_rbtr #(.drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast({8{1'b1}})) uut (
   .clk(clk),
  .reset(_if.reset),
  .pndng(_if.pndng),
  .push(_if.push),
  .pop(_if.pop),
  .D_pop(_if.D_pop),
  .D_push(_if.D_push)
);
  initial begin

    clk = 0;
    t0 = new();
    t0._if = _if;
    t0.ambiente_inst.driver_inst.vif = _if;
    t0.ambiente_inst.monitor_inst.vif = _if;
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






