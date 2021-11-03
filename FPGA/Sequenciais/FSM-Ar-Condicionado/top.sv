// Pedro Manoel
// FSM: Ar-condicionado

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

  // Circuito conforme: https://github.com/OpenDevUFCG/Tamburetei/blob/master/loac/leites/maquinasDeEstados/arcondicionado.md

  // Declaração das constantes
  parameter NBITS_TEMP = 3; // Número de bits de uma temperatura <0..7>
  parameter NUM_INCREMENT_TEMP = 1; // Número qur se deve incrementar ou decrementar na temperatura
  parameter NUM_RESET_PADRAO = 0; // Número padrão que se deve atribuir a uma variavel ao resetala
  parameter NUM_LIMIT_TEMP = 7; // Número limite que a temperatura pode chegar
  parameter NBITS_CONT = 4; // Número de bits do contador, <0..10>
  parameter NUM_CORRECTION_CONT = 1; // Número de correção para utilizar os contadores
  parameter NUM_INCREMENT_CONT = 1; // Número que se deve incrementar ao contador a cada ciclo de clock
  parameter NUM_CLOCK_PINGA = 10; // Número de ciclos de clock para o ar-condicionando começar a pingar
  parameter NUM_CLOCK_STOP_PINGA = 4; // Número de ciclos de clock para parrar o pingamento
  parameter TRUE = 1; // Representação do valor True
  parameter FALSE = 0; // Representação do valor False
  parameter NSTATES = 2; // Número de estados do circuito

  // Declaração das entradas
  logic reset, diminuir, aumentar;
  
  // Atribuição das entradas
  always_comb begin
    reset <= SWI[7];
    diminuir <= SWI[0];
    aumentar <= SWI[1];

    LED[7] <= clk_2; // clock
  end

  // Declaração das saídas
  logic[NBITS_TEMP-1:0] temp_real, temp_desejada; 
  logic pingando;

  // Declaração das variáveis utilizadas pelo circuito
  logic[NBITS_CONT-1:0] cont = NUM_CORRECTION_CONT;
  logic[NBITS_CONT-2:0] cont_pinga = NUM_CORRECTION_CONT;
  
  // Declaração dos estados
  enum logic [NSTATES-1 : 0] {temp_estavel, temp_aumenta, temp_diminui} state;

  // Declaração de funções
  function int aumentaTempDesejada;
    return 
      temp_desejada + NUM_INCREMENT_TEMP >= NUM_LIMIT_TEMP 
        ? NUM_LIMIT_TEMP 
        : temp_desejada + NUM_INCREMENT_TEMP;  
  endfunction

  function int diminuiTempDesejada;
    return 
      temp_desejada - NUM_INCREMENT_TEMP >= NUM_LIMIT_TEMP 
        ? NUM_RESET_PADRAO 
        : temp_desejada - NUM_INCREMENT_TEMP;   
  endfunction

  // Funcionalidade do circuito
  always_ff @(posedge clk_2) begin
    if (reset) begin
      pingando <= FALSE;
      temp_real <= NUM_RESET_PADRAO;
      temp_desejada <= NUM_RESET_PADRAO;
      cont <= NUM_RESET_PADRAO;
      cont_pinga <= NUM_RESET_PADRAO;
      state <= temp_estavel;
    end else begin
      cont <= cont + NUM_INCREMENT_CONT;
      
      cont_pinga <= 
        pingando && temp_real == NUM_LIMIT_TEMP 
          ? cont_pinga + NUM_INCREMENT_CONT 
          : cont_pinga; 
      
      pingando <= 
        cont_pinga >= NUM_CLOCK_STOP_PINGA - NUM_CORRECTION_CONT
          ? NUM_RESET_PADRAO
          : cont == NUM_CLOCK_PINGA - NUM_CORRECTION_CONT
              ? TRUE 
              : pingando; 
      
      temp_real <=
        cont % 2 == 0 && temp_desejada != temp_real  
          ? temp_desejada > temp_real 
              ? temp_real + NUM_INCREMENT_TEMP
              : temp_real - NUM_INCREMENT_TEMP
          : temp_real;
    
      unique case (state)
        temp_estavel: begin
          if (aumentar && ~diminuir) begin
            temp_desejada <= aumentaTempDesejada();
            state <= temp_aumenta;
          end 
          else if (~aumentar && diminuir) begin
            temp_desejada <= diminuiTempDesejada();
            state <= temp_diminui;
          end 
        end 
        temp_aumenta: begin
          if (aumentar && ~diminuir) temp_desejada <= aumentaTempDesejada();
          else if (~aumentar && diminuir) begin
            temp_desejada <= diminuiTempDesejada();
            state <= temp_diminui;
          end
          else state <= temp_estavel;
        end 
        temp_diminui: begin
          if (~aumentar && diminuir) temp_desejada <= diminuiTempDesejada();
          else if (aumentar && ~diminuir) begin
            temp_desejada <= aumentaTempDesejada();
            state <= temp_aumenta;
          end
          else state <= temp_estavel;
        end 
      endcase
    end
  end

  // Atribuição das saídas
  always_comb begin 
    lcd_a <= temp_real; // Exibindo a temperatural real no lcd a 
    lcd_b <= temp_desejada; // Exibindo a temperatural desejada no lcd b 
    LED[6:4] <= temp_real; // Exibindo a temperatural real no led
    LED[2:0] <= temp_desejada; // Exibindo a temperatural desejada no led
    LED[3] <= pingando; // Exibindo se está pingando ou não
  end
  
endmodule
