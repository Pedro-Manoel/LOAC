// Pedro Manoel
// Projeto: Controle das águas do açude de boqueirão

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
    lcd_a <= {56'h1234567890ABCD, SWI};
    lcd_b <= {SWI, 56'hFEDCBA09876543};
  end
  
  // Descrição do circuito
  /*
    Para manter o controle das águas do açude de boqueirão, está sendo utilizado um
    sensor que emite quatro sinais possíveis, descritos a seguir.

      11 -> sensor está com defeito ou descalibrado (“d”).
      10 -> volume de água até 30% (Nível baixo, “b”);
      01 -> volume de água acima de 30% e até 80% (Nível normal, “n”);
      00 -> volume de água acima de 80% (Nível alto, “a ou A”) 

    Para facilitar a visualização da situação do volume de água do açude, deverá ser implementado 
    um circuito digital que apresente os resultados do sensor em um display
    de 7 segmentos, conforme indicado acima (“b”, “n”, “a ou A” e “d”).
  */

  // Constantes
  parameter LETRA_A = 'h77;
  parameter LETRA_n = 'h54;
  parameter LETRA_b = 'h7c;
  parameter LETRA_d = 'h5e;
  parameter NBITS_SENSOR = 2; // quantidade de bits do sensor 

  // Declaração da entrada
  logic[NBITS_SENSOR - 1:0] sensor;

  // Atribuição da entrada
  always_comb sensor <= SWI;

  // Funcionalidade do circuito
  always_comb begin
    case(sensor)
      'b00: SEG <= LETRA_A;
      'b01: SEG <= LETRA_n;
      'b10: SEG <= LETRA_b;
      'b11: SEG <= LETRA_d;
    endcase    
  end

endmodule
