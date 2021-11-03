// Pedro Manoel
// Lista HDL: Lógica combinatória

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

  //--------------------------------------------------------------------
  
  // Circuito: expediente

  // Descrição
  /*
    Entradas:
      noite (passou das 18:00 h) - SWI[4];
      paradas (todas as máquinas estão fora de operação) - SWI[5];
      sexta (é sexta-feira) - SWI[6];
      producao (produção do dia foi atendida) - SWI[7].
    Saída:
      sirene (tocar alarme) - LED[2].
  */

  // Declaração das entradas
  logic noite;
  logic paradas;
  logic sexta;
  logic producao;
  
  // Atribuição das entradas
  always_comb begin
    noite <= SWI[4];
    paradas <= SWI[5];
    sexta <= SWI[6];
    producao <= SWI[7];
  end

  // Declaração da saída
  logic sirene;

  // Atribuição da saída
  always_comb LED[2] <= sirene;

  // Funcionalidade do circuito
  always_comb sirene <= (noite & paradas) | (sexta & producao & paradas);
  
  //--------------------------------------------------------------------




  //--------------------------------------------------------------------
  
  // Circuito: agência

  // Descrição
  /*
    Entrada (Sensores)
      Porta do cofre (cofre = 0 - porta fechada; cofre = 1 - porta aberta) - SWI[0]
      Relógio eletrônico (relogio = 0 -fora do expediente; relogio = 1 -horário de expediente) - SWI[1]
      Interruptor na mesa do gerente (gerente = 0 -alarme desativado; gerente = 1 - alarme ativado) - SWI[2]
    Saída (Atuadores)
      Alarme: 0 -silencioso, 1 -gerando sinal sonoro. - SEG[0]
  */

  // Declaração das entradas
  logic porta_cofre;
  logic relogio;
  logic interruptor;
  
  // Atribuição das entradas
  always_comb begin
    porta_cofre <= SWI[0];
    relogio <= SWI[1];
    interruptor <= SWI[2];
  end

  // Declaração da saída
  logic alarme;
  
  // Atribuição da saída
  always_comb SEG[0] <= alarme;
  
  // Funcionalidade do circuito
  always_comb begin
    if (porta_cofre)
      if (relogio)
        if (interruptor)
          alarme <= 1;
        else
          alarme <= 0;
      else
        alarme <= 1;        
    else
      alarme <= 0;
  end

  //--------------------------------------------------------------------




  //--------------------------------------------------------------------
  
  // Circuito: estufa
  
  // Descrição
  /*
    T1 = 1 para temperatura ≥ 15°C; 0 para temperatura < 15°C; - chave SWI[3]
    T2 = 1 para temperatura ≥ 20°C; 0 para temperatura < 20°C; - chave SWI[4]
    
    Faça o controle da temperatura desta estufa a partir do acionamento 
    de um aquecedor A (LED[6]) ou um resfriador R (LED[7]) sempre que a temperatura interna 
    cair abaixo de 15°C ou subir acima de 20°C, respectivamente. Em caso de inconsistência dos sinais dos 
    sensores de temperatura, um LED vermelho (SEG[7]) deve acender e nem o resfriamento nem o aquecimento 
    deve ser acionados.

    T1 T2| Aquecedor | Resfriador | Inconsistencia
   ------|-----------|------------|----------------
    0  0 |     1     |     0      |       0
    0  1 |     0     |     0      |       1
    1  0 |     0     |     0      |       0
    1  1 |     0     |     1      |       0
  */

  // Declaração das entradas
  logic T1, T2;
  
  // Atribuição das entradas
  always_comb begin
    T1 <= SWI[3];
    T2 <= SWI[4];
  end

  // Declaração das saídas
  logic aquecedor;
  logic resfriador;
  logic inconsistencia;
  
  // Atribuição das saídas
  always_comb begin
    LED[6] <= aquecedor;
    LED[7] <= resfriador;
    SEG[7] <= inconsistencia;
  end

  // Funcionalidade do circuito
  always_comb begin
    aquecedor <= ~(T1 | T2);  // T1 NOR T2
    resfriador <= T1 & T2;   // T1 AND T2
    inconsistencia <= ~T1 & T2;   // (NOT T1) AND T2 
  end

  //--------------------------------------------------------------------




  //--------------------------------------------------------------------
  
  // Circuito: aeronave

  // Descrição
  /*
    As aeronaves normalmente possuem um sinal luminoso que indica se tem lavatório (banheiro) desocupado. 
    Suponha que um avião tenha três lavatórios. Cada lavatório possui um sensor que produz nível 1 em sua saída 
    quando a porta do lavatório está trancada e 0, caso contrário. O primeiro lavatório 
    é exclusivamente para mulheres. Projete um circuito que informa a disponibilidade de lavatório. 
    Use as chaves SWI[0], SWI[1], e SWI[2] como sensores de tranca das respectivas portas. A luz de 
    sinalização que informa se tem algum lavatório livre para mulheres é o LED[0]. A luz de sinalização que 
    informa se tem algum lavatório livre para homens é o LED[1].

    sensor porta lavatorio: 1 porta trancada; 0 porta aberta;
  */

  // Declaração das entradas
  logic porta_lavatorio_A; // para mulher
  logic porta_lavatorio_B; // para homem e mulher
  logic porta_lavatorio_C; // para homem e mulher
  
  // Atribuição das entradas
  always_comb begin
    porta_lavatorio_A <= SWI[0];
    porta_lavatorio_B <= SWI[1];
    porta_lavatorio_C <= SWI[2];
  end

  // Declaração das sáidas
  logic lavatorio_livre_mulher;
  logic lavatorio_livre_homem;
  
  // Atribuição das saídas
  always_comb begin
    LED[0] <= lavatorio_livre_mulher;
    LED[1] <= lavatorio_livre_homem;
  end

  // Funcionalidade do circuito
  always_comb begin
    lavatorio_livre_mulher <= ~porta_lavatorio_A | ~porta_lavatorio_B | ~porta_lavatorio_C;
    lavatorio_livre_homem <= ~porta_lavatorio_B | ~porta_lavatorio_C; 
  end

endmodule
