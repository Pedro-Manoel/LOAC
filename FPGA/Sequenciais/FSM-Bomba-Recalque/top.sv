// Pedro Manoel
// Projeto FSM: Bomba de Recalque

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

  // Descrição do Circuito: 
  /*
    Projeto de um circuito sequencial para controle de uma bomba de recalque 
    que leva água de uma cisterna para uma caixa d'água. 
    
    Na cisterna é instalado um sensor de nível, que demarca o nível minimo de água. Na caixa d'água são 
    instalados dois sensores, que demarcam, respectivamente, o nível máximo e mínimo de água.

    Quando a caixa d'água estiver vazia (quantidade de agúa abaixo do nivel mínimo) e houver água 
    na cisterna (quantidade de agúa acima ou igual ao nivel mínimo) e os sensores da caixa d'água não
    apresentaram nenhuma inconsistência, devera ser bombada água da cisterna para a caixa d'água, acionando 
    a bomba de recalque. 
    
    A bomba de recalque, depois de acionada, deverá permanecer funcionando até que a caixa d'água 
    fique completamente cheia (quantidade de agúa igual ao nivel máximo) e seus sensores não 
    apresentem nenhuma inconsistência, ou a cisterna fique vazia (quantidade de agúa abaixo do nivel mínimo).

    Caso os sensores da caixa d'água apresentem, em algum momento, alguma inconsistência, 
    a bomda d´água deve ser desligda, caso esteja ligada, e um sinal de aviso deve ser acionado, 
    após isso o circuito só voltara a funcionar depois de um reset. 
  */

  // Declaração das constantes
  parameter TRUE = 1; // Representação do valor True
  parameter FALSE = 0; // Representação do valor False
  parameter NSTATES = 3; // Número de estados do circuito

  // Declaração das entradas
  logic cisterna_nivel_min, caixa_nivel_max, caixa_nivel_min;
  logic reset;
  
  // Atribuição das entradas
  always_comb begin
    reset <= SWI[7];
    cisterna_nivel_min <= SWI[0];
    caixa_nivel_max <= SWI[1];
    caixa_nivel_min <= SWI[2];
  end

  // Declaração das saídas
  logic bomba_acionada, inconsistencia;
  
  // Declaração dos estados
  enum logic [NSTATES-1 : 0] {bomba_desligada, bomba_ligada, bomba_inconsistencia} state;

  // Funcionalidade do circuito
  always_ff @(posedge clk_2) begin
    if (reset) begin
      bomba_acionada <= FALSE;
      inconsistencia <= FALSE;
      state <= bomba_desligada;
    end else begin
      inconsistencia <= inconsistencia || (caixa_nivel_max && ~caixa_nivel_min);
      
      unique case (state)
         bomba_desligada: begin
           if (inconsistencia) state <= bomba_inconsistencia;
           else if (~caixa_nivel_min && cisterna_nivel_min) begin
             bomba_acionada <= TRUE;
             state <= bomba_ligada;
           end
         end
         bomba_ligada: begin
           if (inconsistencia) state <= bomba_inconsistencia;
           if (caixa_nivel_max || ~cisterna_nivel_min) begin
             bomba_acionada <= FALSE;
             state <= bomba_desligada;
           end
         end
         bomba_inconsistencia: begin
           bomba_acionada <= FALSE;
         end
      endcase
    end
  end

  // Atribuição das saídas
  always_comb begin
    LED[0] <= bomba_acionada;
    LED[2] <= inconsistencia;
    SEG[7] <= clk_2; // clock
  end

endmodule
