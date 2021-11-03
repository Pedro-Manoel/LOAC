// Pedro Manoel
// Código - PairOrAdd

/*
   Descrição:
      Dado um número define se é par ou ímpar.
   
   Entradas:
      O número é passado nas entradas, SWI[4:0].

   Saídas:
      Se o número for par acende o LED[0], senão, ou seja é ímpar, acende o LED[1].
*/

#include "pairOrOdd.h"

void __attribute__ ((naked)) main () { // naked significa desconsiderar a pilha, nao precisa salvar nada na pilha
   volatile int * const io = (int *)(0x3F*4); // apontador para entrada/saida
   
   int num;
   num = *io; // pega o número de SWI[4:0]
   *io = pairOrOdd(num); // resultado vai para saida - LED[4:0]
}