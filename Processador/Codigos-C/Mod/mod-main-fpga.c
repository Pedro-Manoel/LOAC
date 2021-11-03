// Pedro Manoel
// Código: Mod

/*
   Descrição:
      Calcula e retorna o módulo de um número pelo outro, desde
      que ambos não sejam zero.    
   
   Entradas:
      num1: primeiro número, SWI[4:0]
      num2: segundo número, SWI[4:0]
      
   Saídas:
      Se num1 == num2 == 0, então sáida = 0, LED[4:0]
      Senão, saída = num1 mod num2, LED[4:0]   
*/

#include "mod.h"
void __attribute__ ((naked)) main() { // naked significa desconsiderar a pilha, nao precisa salvar nada na pilha
   volatile int * const io = (int *)(0x3F*4); // apontador para entrada/saida
  
   int num1, num2;
   num1 = *io; // primeiro pega num1 de SWI[4:0]
   num2 = *io; // no clock seguinte num2
   *io = mod(num1, num2); // resultado vai para saida - LED[4:0]
}