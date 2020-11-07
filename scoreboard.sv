// Módulo Scoreboard

class scoreboard #(parameter drvrs = 4,parameter drvr_bit=2, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}});
	trans_sb_mbx sb_chckr_mbx;	// Mailbox checker-scoreboard
  	trans_sb_mbx sb_agnt_mbx;	// Mailbox agente-sb
  	
  	trans_scoreboard #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) to_chckr;	// Objeto de transacción para enviar datos hacia el checker
  	trans_scoreboard #(.drvrs(drvrs), .drvr_bit(drvr_bit), .pckg_sz(pckg_sz), .broadcast(broadcast)) from_agnt; // Objeto de transacción para recibir datos del agente
  	
  	

endclass
