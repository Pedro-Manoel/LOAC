// Pedro Manoel
// Código - Calculator 4 bits

/*
   Descrição:
      Calculadora básica, dado dois números e a operação, ela realiza
      a operação e retorna o resultado, desde que o resultado não ultrapasse 
      os limites inferior(underflow) e superior(overflow).

      A calculadora só utiliza os números de 0 a 15 (4 bits).
      
   Entradas:
      num1: primeiro número, SWI[4:0]
      num2: segundo número, SWI[4:0]
      oper: operação, SWI[4:0]

   Saídas:
      Se oper = 0, então saída = num1 + num2, LED[3:0]
      Se oper = 1, então saída = num1 - num2, LED[3:0]
      Se oper = 2, então saída = num1 * num2, LED[3:0]
      
      Se oper != 0,1 ou 2, então saída = erro, LED[4]
      Se ocorrer underflow ou overflow, então saída = erro, LED[4]
*/

#include "calculator.h"
void __attribute__ ((naked)) main () { // naked significa desconsiderar a pilha, nao precisa salvar nada na pilha
   volatile int * const io = (int *)(0x3F*4); // apontador para entrada/saida
   
   int num1, num2, oper;
   num1 = *io; // primeiro pega num1 de SWI[4:0]
   num2 = *io; // no clock seguinte num2
   oper = *io; // no clock seguinte oper                       
   *io = calculator(num1, num2, oper); // resultado vai para saida - LED[4:0]
}