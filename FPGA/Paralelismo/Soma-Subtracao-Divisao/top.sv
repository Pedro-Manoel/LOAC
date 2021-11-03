// Pedro Manoel
// Lista HDL: Soma, Subtração e Divisão

parameter divide_by=100000000; // divisor do clock de referência
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
	
	// Circuito conforme: http://lad.ufcg.edu.br/loac/index.php?n=OAC.Divi
	
    // Constantes
    parameter NBITS_V = 64; // Número de bits da variável v
    parameter NBITS_A = 8; // Número de bits da variável a
    parameter NUM_DIGITS_HEX = 15; // Número de dígitos hexadecimais fracionários
    parameter DIVIDEND = 4; // Dividendo utilizado no circuito

    parameter t = 64'd1 << (DIVIDEND * NUM_DIGITS_HEX);
    parameter m = DIVIDEND * t;
    
    /*
        Funcionalidade do parametro NDIV no circuito

        Se NDIV = 1, então v = v1
        Se NDIV = 2, então v = v2
        Se NDIV = 4, então v = v4
        Se NDIV = 6, então v = v6
        Se NDIV = 8, então v = v8
        :           :            :
        Se NDIV = x, então v = vx, para valores de x = { 2, 4, 6, 8, ... }
    */ 
    parameter NDIV = 16; // Quantidade de quocientes

    // Declaração das entradas
    logic [NBITS_A-1:0] a;

    // Atribuição das entradas
    always_comb a <= SWI[NBITS_A-1:0];

    // Declaração das saídas
    logic [NBITS_V-1:0] v;

    // Atribuição das saídas
    always_comb lcd_b <= v;

    // Funcionalidade do circuito
    always_comb begin
        v = 0;
        if (a > 0)
            for (int i = 0; i < NDIV; i += 1) begin
                if (i % 2 == 0)
                    v = v + (m / (a + (2 * i)));
                else
                    v = v - (m / (a + (2 * i)));
            end
    end

    // Conclusão sobre a atividade
    /*
        Usando NUM_DIGITS_HEX = 15 (15 dígitos hexadecimais fracionários)
        Usando NDIV = 16, que configura vn = v16 (16 quocientes) 
        Foi possível aproveitar-se de 95% dos recursos lógicos da FPGA

        log da FPGA remota
            Total logic elements : 21,192 / 22,320 ( 95 % )
    */  
endmodule
