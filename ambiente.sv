// Curso: EL-5811 Taller de Comunicaciones Electricas
// Tecnologico de Costa Rica (www.tec.ac.cr)
// Código consultado y adaptado: https://estudianteccr.sharepoint.com/sites/VerificacinFuncional/Documentos%20compartidos/General/Test_CR_fifo.zip -Realizado por: RONNY GARCIA RAMIREZ 
// Desarrolladores:
// José Agustín Delgado-Sancho (ahusjads@gmail.com)
// Alonso Vega-Badilla (alonso9v9@gmail.com)
// Este script esta estructurado en System Verilog
// Proposito General:
// Modulo ambiente del testbench de un bus serial
//
//

class ambiente #(parameter pckg_sz=16,parameter drvrs=4,parameter Fif_Size=10);
  // Declaración de los componentes del ambiente
  monitor #(.pckg_sz(pckg_sz),.drvrs(drvrs),.Fif_Size(Fif_Size)) monitor_inst;
  driver #(.pckg_sz(pckg_sz),.drvrs(drvrs),.Fif_Size(Fif_Size)) driver_inst;
  checkr #(.pckg_sz(pckg_sz),.drvrs(drvrs)) checker_inst;
  scoreBoard #(.pckg_sz(pckg_sz),.drvrs(drvrs)) scoreboard_inst;
  agent #(.pckg_sz(pckg_sz),.drvrs(drvrs)) agent_inst;
  
  // Declaración de la interface que conecta el DUT 
  virtual bus_if  #(.pckg_sz(pckg_sz),.drvrs(drvrs)) _if;

  //declaración de los mailboxes
  trans_bus_mbx agnt_drv_mbx;           //mailbox del agente al driver
  trans_bus_mbx chckr_agnt_mbx;
  trans_bus_mbx chckr_mntr_mbx;           //mailbox del driver al checher
  trans_sb_mbx chkr_sb_mbx;
  trans_sb_mbx agnt_sb_mbx;            

  comando_test_agent_mbx test_agent_mbx; //mailbox del test al agente

  function new();
    // Instanciación de los mailboxes
    chckr_agnt_mbx  = new();
    agnt_drv_mbx   = new();
    chkr_sb_mbx    = new();
    chckr_mntr_mbx = new();
    test_agent_mbx = new();
    agnt_sb_mbx    = new();

    // instanciación de los componentes del ambiente
    driver_inst     = new();
    checker_inst    = new();
    scoreboard_inst = new();
    agent_inst      = new();
    monitor_inst    = new();
    
    // conexion de las interfaces y mailboxes en el ambiente
    driver_inst.vif             = _if;
    monitor_inst.vif            = _if;
    
    //driver_inst.drv_chkr_mbx    = drv_chkr_mbx;
    driver_inst.agnt_drv_mbx    = agnt_drv_mbx;
    //checker_inst.drv_chkr_mbx   = drv_chkr_mbx;
    
    checker_inst.chckr_sb_mbx    =chkr_sb_mbx;
    checker_inst.chckr_agnt_mbx  =chckr_agnt_mbx;
    checker_inst.chckr_mntr_mbx  =chckr_mntr_mbx;
    
    scoreboard_inst.sb_chckr_mbx = chkr_sb_mbx;
    
    agent_inst.test_agent_mbx = test_agent_mbx;
    agent_inst.agnt_drv_mbx = agnt_drv_mbx;
    agent_inst.agnt_chkr_mbx = chckr_agnt_mbx;
    
    monitor_inst.mntor_chkr_mbx =chckr_mntr_mbx;
    
  endfunction

  virtual task run();
    $display("[%g]  El ambiente fue inicializado",$time);
    fork
      driver_inst.run();
      checker_inst.run();
      scoreboard_inst.run();
      agent_inst.run();
      monitor_inst.run();
    join_none
  endtask 
endclass
