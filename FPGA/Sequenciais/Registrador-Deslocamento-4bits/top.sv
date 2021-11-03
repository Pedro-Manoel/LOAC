// Pedro Manoel
// Registrador de deslocamento 4 bit com entrada serial

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
    Registrador de deslocamento 4 bit com entrada serial
      entrada serial e reset – SWI[0] + SWI[1]
      carregamento paralelo – SWI[2] aciona carregamento de SWI[7:4]
      entrada serial, reset e carregamento paralelo – SWI[0] + SWI[1] + SWI[2]
  */

  // Declaração das constantes
  parameter NBITS_REG = 4; // Número de bits do registrador
  parameter NUM_REG_RESET = 0; // Número atribuido ao resetar o registrador

  // Declaração das entradas
  logic entrada_serial, reset, carregamento_paralelo;
  logic[NBITS_REG-1:0] entrada_paralela;
  
  // Atribuição das entradas
  always_comb begin
    entrada_serial <= SWI[0];
    reset <= SWI[1];
    carregamento_paralelo <= SWI[2];
    entrada_paralela <= SWI[7:4];

    SEG[7] <= clk_2; // Indicação da ocorrência do clock
  end

  // Declaração da saída
  logic[NBITS_REG-1:0] registrador;

  // Atribuição das saídas
  always_comb begin
    LED <= registrador;
  end
  
  // Funcionalidade do circuito
  always_ff @(posedge clk_2) begin 
    if (reset)
      registrador <= NUM_REG_RESET;
    else begin
      if (carregamento_paralelo)
        registrador <= entrada_paralela;
      else begin
        registrador[3] <= entrada_serial;
        registrador[2:0] <= registrador[3:1];
      end
    end
    
  end
  
endmodule
