// Pedro Manoel
// Lista HDL: Soma, Subtração e Multiplicação

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
  parameter PONTO = 'h80;
  parameter NBITS_OPERATORS = 3; // quantidade de bits dos operadores
  parameter NBITS_OPER_RESULT = 7; // quantidade de bits do resultado da operação (6 bits para armazenar o resultado, mais um bit que será utilizado para detectar a ocorrência de overflow ou underflow)
  parameter NBITS_OPER_RESULT_LED = 6; // quantidade de bits do resultado da operação nos leds
  parameter NBITS_OPER_SELECT = 2; // quantidade de bits do seletor da operação

  // Declaração de variáveis
  logic signed[NBITS_OPER_RESULT - 1:0] result; // Variável que armazena o resultado da operação para ser utilizado pelo circuito

  // Declaração das entradas
  logic signed[NBITS_OPERATORS - 1:0] A, B; // operadores
  logic[NBITS_OPER_SELECT - 1:0] F; // seletor da operação

  // Atribuição das entradas
  always_comb begin
    A <= SWI[7:5];
    B <= SWI[2:0];
    F <= SWI[4:3];
  end

  // Declaração das sáidas
  logic signed[NBITS_OPER_RESULT_LED - 1:0] result_LED;
  logic overflow_underflow;
  
  // Atribuição das saídas
  always_comb begin
    LED[NBITS_OPER_RESULT_LED - 1: 0] <= result_LED; 
    LED[7] <= overflow_underflow;

    // atribuindo o resultado da operação no display de 7 segmentos
    case (result) 
      1: SEG <= NUM_1;
      2: SEG <= NUM_2;
      3: SEG <= NUM_3;
      4: SEG <= NUM_4;
      5: SEG <= NUM_5;
      6: SEG <= NUM_6;
      7: SEG <= NUM_7;
      8: SEG <= NUM_8;
      9: SEG <= NUM_9;
     -9: SEG <= NUM_9 + PONTO;
     -8: SEG <= NUM_8 + PONTO;
     -7: SEG <= NUM_7 + PONTO;
     -6: SEG <= NUM_6 + PONTO;
     -5: SEG <= NUM_5 + PONTO;
     -4: SEG <= NUM_4 + PONTO;
     -3: SEG <= NUM_3 + PONTO;
     -2: SEG <= NUM_2 + PONTO;
     -1: SEG <= NUM_1 + PONTO;
     default: SEG <= NUM_0;
    endcase
  end

  // Funcionalidade do circuito
  always_comb begin 
      if (F == 'b00 || F == 'b01) begin
         result <= F == 'b00 ?  A + B : A - B;
         result_LED <= result[(NBITS_OPER_RESULT_LED / 2) - 1: 0]; // resultado em 3 bits no LED
         
         // Limite inferior (underflow) : -(2 ** (NBITS_OPERATORS - 1)); 
         // Limite superior (overflow)  :  (2 ** (NBITS_OPERATORS - 1)) - 1;
         overflow_underflow <= (result < -(2 ** (NBITS_OPERATORS - 1))) || (result > (2 ** (NBITS_OPERATORS - 1)) - 1); 
      end else begin
         if (F == 'b10) begin
            result <= $unsigned(A) * $unsigned(B);
            overflow_underflow <= 0; // não é requisitado para operações com números naturais incluindo o zero
         end else begin
            result <= A * B;

            // Limite inferior (underflow) : -(2 ** (NBITS_OPER_RESULT - 2)); 
            // Limite superior (overflow)  :  (2 ** (NBITS_OPER_RESULT - 2)) - 1;
            overflow_underflow <= (result < -(2 ** (NBITS_OPER_RESULT - 2))) || (result > (2 ** (NBITS_OPER_RESULT - 2)) - 1);
         end
         result_LED <= result[NBITS_OPER_RESULT_LED - 1: 0]; // resultado em 6 bits no LED
      end       
  end

endmodule
