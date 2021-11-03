// Pedro Manoel
// Lista HDL: Display de 7 segmentos

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
    LED <= SWI;
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
  parameter LETRA_MIN_b = 'h7c;
  parameter LETRA_C = 'h39;
  parameter LETRA_MIN_c = 'h58;
  parameter LETRA_MIN_d = 'h5e;
  parameter LETRA_E = 'h79;
  parameter LETRA_F = 'h71;
  parameter LETRA_MIN_g = 'h6f;
  parameter LETRA_H = 'h76;
  parameter LETRA_MIN_h = 'h74;
  parameter LETRA_MIN_i = 'h10;
  parameter LETRA_I = 'h6;
  parameter LETRA_J = 'h1e;
  parameter LETRA_L = 'h38;
  parameter LETRA_MIN_n = 'h54;
  parameter LETRA_O = 'h3f;
  parameter LETRA_MIN_o = 'h5c;
  parameter LETRA_P = 'h73;
  parameter LETRA_MIN_q = 'h67;
  parameter LETRA_MIN_r = 'h50;
  parameter LETRA_S = 'h6d;
  parameter LETRA_MIN_t = 'h78;
  parameter LETRA_U = 'h3e;
  parameter LETRA_MIN_v = 'h1c;
  parameter LETRA_MIN_y = 'h6e;
  parameter GRAU = 'h63;

  // Declaração das entradas do 1º, 2º e 3º circuito
  logic u, v, w, x, y, z;

  // Atribuição das entradas do 1º, 2º e 3º circuito
  always_comb begin
    u <= SWI[5];
    v <= SWI[4];
    w <= SWI[3];
    x <= SWI[2];
    y <= SWI[1];
    z <= SWI[0];
  end

  //--------------------------------------------------------------------
  

  // 4º Circuito: classificador de nota

  // Descrição
  /* 
    “A” (Aprovado por média) se a nota do aluno for igual ou superior a 7 pontos;
    “F” (Final) se a nota do aluno for maior ou igual a 4 e menor que 7 pontos;
    “P” (Perdeu a disciplina) se a nota do aluno for inferior a 4 pontos. 
  */

  // Declaração das constantes 
  parameter NBITS_NOTA = 4; // quantidade de bits da nota, 0 <= nota <= 9

  // Declaração da entrada
  logic[NBITS_NOTA - 1:0] nota;

  // Atribuição da entrada
  always_comb nota <= SWI[3:0];
    
  // Declaração da sáida
  logic mostra_situacao; // 1: mostra a situação; 0: mostra a nota

  // Atribuição da saída
  always_comb mostra_situacao <= SWI[7];
  
  // Funcionalidade dos circuitos
  always_comb begin
    
    // Funcionalidade do classificador de notas (4º Circuito)
    if (mostra_situacao) begin
      if (nota >= 7) SEG <= LETRA_A;
      else if (nota <= 3) SEG <= LETRA_P;
      else SEG <= LETRA_F;
    end
    else begin
    
      // 1º e 2º Circuito
      // Descrição do 1º circuito: Coloque as entradas w,x,y,z em chaves SWI[3:0] e mostre os símbolos 0 até 9 no display 
      // Descrição do 2º circuito: Coloque as entradas w,x,y,z em chaves SWI[3:0] e mostre os dígitos hexadecimais correspondentes no display
      // Funcionalidade dos circuitos
      case({w, x, y, z})
        'b0000: SEG <= NUM_0;
        'b0001: SEG <= NUM_1;
        'b0010: SEG <= NUM_2;
        'b0011: SEG <= NUM_3;
        'b0100: SEG <= NUM_4;
        'b0101: SEG <= NUM_5;
        'b0110: SEG <= NUM_6;
        'b0111: SEG <= NUM_7;
        'b1000: SEG <= NUM_8;
        'b1001: SEG <= NUM_9;
        'b1010: SEG <= LETRA_A;
        'b1011: SEG <= LETRA_MIN_b;
        'b1100: SEG <= LETRA_C;
        'b1101: SEG <= LETRA_MIN_d;
        'b1110: SEG <= LETRA_E;
        'b1111: SEG <= LETRA_F;
      endcase
              
      // 3º Circuito
      // Descrição: Coloque as entradas em chaves SWI[5:0] e mostre, a partir do valor 16 da entrada, os símbolos A até o no display
      // Funcionalidade do circuito	
      case({u, v, w, x, y, z})
        'b010000: SEG <= LETRA_A;
        'b010001: SEG <= LETRA_MIN_b;
        'b010010: SEG <= LETRA_C;
        'b010011: SEG <= LETRA_MIN_c;
        'b010100: SEG <= LETRA_MIN_d;
        'b010101: SEG <= LETRA_E;
        'b010110: SEG <= LETRA_F;
        'b010111: SEG <= LETRA_MIN_g;
        'b011000: SEG <= LETRA_H;
        'b011001: SEG <= LETRA_MIN_h;
        'b011010: SEG <= LETRA_MIN_i;
        'b011011: SEG <= LETRA_I;
        'b011100: SEG <= LETRA_J;
        'b011101: SEG <= LETRA_L;
        'b011110: SEG <= LETRA_MIN_n;
        'b011111: SEG <= LETRA_O; 
        'b100000: SEG <= LETRA_MIN_o; 
        'b100001: SEG <= LETRA_P; 
        'b100010: SEG <= LETRA_MIN_q; 
        'b100011: SEG <= LETRA_MIN_r; 
        'b100100: SEG <= LETRA_S; 
        'b100101: SEG <= LETRA_MIN_t; 
        'b100110: SEG <= LETRA_U; 
        'b100111: SEG <= LETRA_MIN_v; 
        'b101000: SEG <= LETRA_MIN_y; 
        'b101001: SEG <= GRAU; 
      endcase
      
    end
  end

endmodule
