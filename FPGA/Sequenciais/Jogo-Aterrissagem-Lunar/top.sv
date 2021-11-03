// Pedro Manoel
// Um jogo que simula uma aterrissagem lunar

parameter divide_by=100000000;  // divisor do clock de referência
// A frequencia do clock de referencia é 50 MHz.
// A frequencia de clk_2 será de  50 MHz / divide_by

parameter NBITS_INSTR = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NBITS_INSTR-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

  always_comb begin
    // LED <= SWI;
    // SEG <= SWI;
    lcd_WriteData <= SWI;
    lcd_pc <= 'h12;
    lcd_instruction <= 'h34567890;
    lcd_SrcA <= 'hab;
    lcd_SrcB <= 'hcd;
    lcd_ALUResult <= 'hef;
    lcd_Result <= 'h11;
    lcd_ReadData <= 'h33;
    lcd_MemWrite <= SWI[0];
    lcd_Branch <= SWI[1];
    lcd_MemtoReg <= SWI[2];
    lcd_RegWrite <= SWI[3];
    for(int i=0; i<NREGS_TOP; i++)
       if(i != NREGS_TOP/2-1) lcd_registrador[i] <= i+i*16;
       else                   lcd_registrador[i] <= ~SWI;
  end

  // Descrição do circuito conforme: http://lad.ufcg.edu.br/loac/seq_basico.html
  /*
    O jogo consiste em comandar a queima de combustível de um módulo lunar durante a descida 
    para a superfície da lua, de modo que a velocidade de chegada seja igual a zero de forma a não danificar 
    o módulo lunar.

    Este jogo usa três contadores:

    combustível, 8 bits – LED; Este contador inicia (reset SWI[0]) com valor 120 e deve diminuir 
    a cada ciclo de clock pelo valor representado por SWI[7:1]. 
    Observe que o valor do contador de combustível não pode ficar menor do que zero.

    velocidade (velocidade negativa: descendo, velocidade positiva: subindo), 
    12 bits em complemento a 2 – lcd_b; Este contador inicia no valor -50 e deve diminuir 
    pelo valor 5 (aceleração gravitational da lua em m/s²) a cada clock, ou seja, sem queima de combustível, 
    o módulo lunar desce cada vez mais rápido. A cada clock a velocidade deve aumentar pelo 
    valor da quantidade de combustível queimado, supondo que cada unidade de combustível queimada 
    resulta num empurro para cima de 1 m/s².

    altura, 12 bits – lcd_a; Este contador inicia com valor 500. A cada clock, 
    o valor da velocidade deve ser acrescentada. Observe que na descida, com velocidade negativa, 
    a altura diminui. O valor da altura não pode ficar menor do que zero. 
    Quando o valor da altura chega em zero, o jogo termina, ou seja, os demais contadores não 
    alteram mais seus valores. Um novo jogo pode ser iniciado mediante reset.

    O período do clock corresponde a 1 segundo. Os valores acima são dados com base decimal, 
    mas a visualização no LCD é em base hexadecimal.
   
   RESUMO:
    contador de combustível com decremento pelo valor de SWI[7:1]
      reset do contador de combustível
      limitar o contador de combustível para >= 0
   contador de velocidade com decremento de 5 e incremento pelo valor de queima de combustível
      reset do contador de velocidade
   contador de altura com acréscimo do valor da velocidade a cada clock
      reset do contador de altura
      limitar o contador de altura para >= 0
      parar todos os contadores quando altura == 0
  */

  // Declaração das constantes
  parameter NBITS_CONT_COMB = 8; // Número de bits do contador de combustível
  parameter NUM_RESET_COMB = 120; // Número atribuído ao resetar o contador de combustível
  parameter NBITS_REDUCE_COMB = 7; // Número de bits do redutor de combustível
  parameter NBITS_CONT_VELO = 12; // Número de bits do contador de velocidade
  parameter NUM_RESET_VELO = -50; // Número atribuído ao resetar o contador de velocidade
  parameter NUM_REDUCE_VELO = 5; // Número que se deve diminuir do contador de velocidade a cada ciclo de clock
  parameter NBITS_CONT_ALT = 12; // Número de bits do contador de velocidade
  parameter NUM_RESET_ALT = 500; // Número atribuído ao resetar o contador de velocidade
  
  // Declaração das entradas
  logic[NBITS_REDUCE_COMB-1:0] reduce_comb;
  logic reset; // Para resetar o circuito
  
  // Atribuição das entradas
  always_comb begin
    reset <= SWI[0]; 
    reduce_comb <= SWI[7:1];

    SEG[7] <= clk_2; // Indicação da ocorrência do clock
  end

  // Declaração das saídas
  logic[NBITS_CONT_COMB-1:0] cont_comb;
  logic signed[NBITS_CONT_VELO-1:0] cont_velo;
  logic[NBITS_CONT_ALT-1:0] cont_alt;

  // Atribuição das saídas
  always_comb begin
    LED[NBITS_CONT_COMB-1:0] <= cont_comb;
    lcd_b[NBITS_CONT_VELO-1:0] <= cont_velo;
    lcd_a[NBITS_CONT_ALT-1:0] <= cont_alt;
  end
  
  // Funcionalidade do circuito
  always_ff @(posedge clk_2) begin 
    if (reset) begin
      cont_comb <= NUM_RESET_COMB;
      cont_velo <= NUM_RESET_VELO;
      cont_alt <= NUM_RESET_ALT;
    end else begin
      if (cont_alt != 0) begin
        cont_comb <= $signed(cont_comb - reduce_comb) >= 0 
            ? cont_comb - reduce_comb 
            : 0;
        cont_velo <= cont_velo - NUM_REDUCE_VELO + reduce_comb;
        cont_alt <= $signed(cont_alt + cont_velo) >= 0 
            ? cont_alt + cont_velo
            : 0;
      end 
    end 
  end
  
endmodule
