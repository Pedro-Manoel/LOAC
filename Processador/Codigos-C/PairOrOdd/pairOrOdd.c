// Constantes
#define PAIR 1
#define ODD 2

// Código
int pairOrOdd (register int num) {
   register int result = 0;
   
   result = (num % 2 == 0) ? PAIR : ODD;

   return result;
}