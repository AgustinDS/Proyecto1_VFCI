// Módulo Checker

class checker #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
	trans_sb_mbx sb_chckr_mbx;	// Mailbox checker-scoreboard
  	trans_bus bus_chckr_mbx;	// Mailbox checker-monitor
  	trans_bus auxiliar;		// Item auxiliar para emular el fifo de cada dispositivo

  	trans_bus #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) trans_item; 		//Mensaje para comunicación con el monitor
  	trans_bus #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) aux_item [$];
  	trans_scoreboard #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) sb_item;	// Mensaje para comunicación con el scoreborard
	
	function new();
		aux_item = {};
	endfunction
endclass
