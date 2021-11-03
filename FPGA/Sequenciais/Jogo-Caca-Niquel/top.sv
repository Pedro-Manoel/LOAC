// Pedro Manoel
// Jogo inspirado no caça-níquel

parameter divide_by= 25000000;  // divisor do clock de referência
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
    Implemente dois contadores de 4 bit, ambos com clock clk_2 e reset mediante SWI[0]. 
    O primeiro contador só faz a contagem se SWI[1] for zero. Para SWI[1] igual a ‘1’, o valor do primeiro 
    contador fica travado. O segundo contador pode ser travado por SWI[2]. 
    O valor do primeiro contador aparece em lcd_a, o valor do segundo em lcd_b.

    O objetivo do jogador é de travar os dois contadores na mesma posição.
    Para iniciar o jogo, o jogador deve primeiro desativar o reset.
    Com clk_2 de baixa frequência, é muito fácil travar os dois contadores na mesma posição. 
    Use clk_2 com baixa frequência para fazer os primeiros testes da sua implementação. 
    Aumentando a frequência do clock, só é possível travar os dois contadores no mesmo valor por acaso. 
    Aumente a frequência do clock por meio do parâmetro divide_by.

    Contador 4 bits:
      reset
      travar
      segundo contador com travamento
      mudar visualização do segundo contador para lcd_a, no dígito ao lado do dígito do primeiro contador
      terceiro contador com travamento mediante SWI[3] e visualização no dígito ao lado do dígito do segundo contador
      Limitar a contagem dos três contadores para 6 (contador módulo 6)
  */

  // Declaração das constantes
  parameter NBITS_COUNT = 4; // Número de bits dos contadores
  parameter NUM_LIMIT_COUNT = 6; // Número limite dos contadores
  parameter NUM_INCREMENT = 1; // Número do incremento dos contadores
  parameter NUM_COUNT_RESET = 0; // Número atribuido ao resetar os contadores

  // Declaração das entradas
  logic reset, trava_cont_A, trava_cont_B, trava_cont_C;
  
  // Atribuição das entradas
  always_comb begin
    reset <= SWI[0];
    trava_cont_A <= SWI[1];
    trava_cont_B <= SWI[2];
    trava_cont_C <= SWI[3];
  end

  // Declaração das saídas
  logic[NBITS_COUNT-1:0] cont_A, cont_B, cont_C;

  // Atribuição das saídas
  always_comb begin
    lcd_a[NBITS_COUNT - 1: 0] <= cont_A;
    lcd_a[(2 * NBITS_COUNT) - 1: NBITS_COUNT] <= cont_B;
    lcd_a[(3 * NBITS_COUNT) - 1: (2 * NBITS_COUNT)] <= cont_C;
  end
  
  // Funcionalidade do circuito
  always_ff @(posedge clk_2) begin
    if (reset) begin
      cont_A <= NUM_COUNT_RESET;
      cont_B <= NUM_COUNT_RESET;
      cont_C <= NUM_COUNT_RESET;
    end else begin
       cont_A <= trava_cont_A ? cont_A : (cont_A + NUM_INCREMENT) % (NUM_LIMIT_COUNT + 1);
       cont_B <= trava_cont_B ? cont_B : (cont_B + NUM_INCREMENT) % (NUM_LIMIT_COUNT + 1);
       cont_C <= trava_cont_C ? cont_C : (cont_C + NUM_INCREMENT) % (NUM_LIMIT_COUNT + 1);
    end
  end
  
endmodule
