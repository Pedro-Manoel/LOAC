// Pedro Manoel
// Contador 4 bits

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
    reset SWI[0]
    contagem decrescente - SWI[1]
    contagem com incremento de 3 - SWI[2]
    contagem com reset, incremento de 1/3 e crescente/decrescente – SWI[0] + SWI[1] + SWI[2]
    congelamento da ccontagem - SWI[3]
    saturação (parada da contagem) quando chega em 15 ou 0 - SWI[4]
    contagem com congelamento e saturação – SWI[3] + SWI[4]

    contagem com reset, incremento de 1/3 , crescente/decrescente, congelamento e saturação – 
    SWI[0] + SWI[1] + SWI[2] + SWI[3] + SWI[4]
  */

  // Declaração das constantes
  parameter NUM_0 = 'h3f;
  parameter NUM_1 = 'h06;
  parameter NUM_2 = 'h5b;
  parameter NUM_3 = 'h4f;
  parameter NUM_4 = 'h66;
  parameter NUM_5 = 'h6d;
  parameter NUM_6 = 'h7d;
  parameter NUM_7 = 'h7;
  parameter NUM_8 = 'h7f;
  parameter NUM_9 = 'h6F;
  parameter LETRA_A = 'h77;
  parameter LETRA_b = 'h7c;
  parameter LETRA_C = 'h39;
  parameter LETRA_d = 'h5e;
  parameter LETRA_E = 'h79;
  parameter LETRA_F = 'h71;
  parameter NBITS_COUNT = 4; // Número de bits do contador
  parameter NUM_RESET_CONT = 0; // Número atribuído ao resetar o contador

  // Declaração das entradas
  logic reset, decrescente, incremento_3, congela, satura;
  
  // Atribuição das entradas
  always_comb begin
    reset <= SWI[0];
    decrescente <= SWI[1];
    incremento_3 <= SWI[2];
    congela <= SWI[3];
    satura <= SWI[4]; 
  end

  // Declaração das saídas
  logic[NBITS_COUNT-1: 0] contador;

  // Atribuição das saídas
  always_comb begin
    LED <= contador; // Saída nos leds
    lcd_a <= contador; // Saída no lcd a
    case (contador) // Saída no display de 7 segmentos
      1: SEG <= NUM_1;
      2: SEG <= NUM_2;
      3: SEG <= NUM_3;
      4: SEG <= NUM_4;
      5: SEG <= NUM_5;
      6: SEG <= NUM_6;
      7: SEG <= NUM_7;
      8: SEG <= NUM_8;
      9: SEG <= NUM_9;
      10: SEG <= LETRA_A;
      11: SEG <= LETRA_b;
      12: SEG <= LETRA_C;
      13: SEG <= LETRA_d;
      14: SEG <= LETRA_E;
      15: SEG <= LETRA_F;
      default: SEG <= NUM_0;
    endcase
  end
  
  // Funcionalidade do circuito
  always_ff @(posedge clk_2) begin
    if (reset)
      contador <= NUM_RESET_CONT;
    else begin
      if (congela || (satura && (contador == 15 || contador == 0))) 
        contador <= contador;
      else if (decrescente)
        contador <= contador - (incremento_3 ? 3 : 1);
      else 
        contador <= contador + (incremento_3 ? 3 : 1);
    end
  end
  
endmodule
