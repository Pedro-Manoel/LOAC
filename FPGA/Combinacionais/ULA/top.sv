// Pedro Manoel
// Lista HDL: ULA

parameter divide_by=100000000;  // divisor do clock de referência
// A frequencia do clock de referencia é 50 MHz.
// A frequencia de clk_2 será de  50 MHz / divide_by

parameter NBITS_INSTR = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG, // display de 7-segmentos
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NBITS_INSTR-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

  always_comb begin
    //LED <= SWI;
    //SEG <= SWI;
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
    lcd_a <= {56'h1234567890ABCD, SWI};
    lcd_b <= {SWI, 56'hFEDCBA09876543};
  end

  //--------------------------------------------------------------------

  // Declaração das constantes
  parameter NBITS_OPER = 2; // número de bits dos operadores
  parameter NBITS_SELECT = 3; // número de bits do seletor das operações
  parameter NBITS_RESULT = 2; // número de bits do resultado da operação
  
  // Declaração das entradas
  logic[NBITS_OPER - 1:0] A, B;
  logic[NBITS_SELECT - 1:0] F;

  // Atribuição das entradas
  always_comb begin
    F <= SWI[6:4];
    A <= SWI[3:2];
    B <= SWI[1:0];
  end

  // Declaração da sáida
  logic[NBITS_RESULT - 1:0] Y;

  // Atribuição da saída
  always_comb LED[NBITS_RESULT - 1:0] <= Y;
  
  // Funcionalidade do circuito
  always_comb begin
    case (F)
      'b000: Y <= A & B;
      'b001: Y <= A | B;
      'b010: Y <= A + B;
      'b011: Y <= 0;
      'b100: Y <= A & ~B;
      'b101: Y <= A | ~B;
      'b110: Y <= A - B;
      'b111: Y <= A < B;
    endcase
    
  end

endmodule
