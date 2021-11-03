// Constantes
#define SUM 0
#define SUB 1
#define MUL 2
#define OVERFLOW 16
#define UNDERFLOW -1
#define ERROR 16

// Código
int calculator (register int num1, register int num2, register int oper) {
   register int result = 0;

   switch (oper) {
      case SUM:
         result = num1 + num2;
      break;
      case SUB:
         result = num1 - num2;
      break;
      case MUL:
         result = num1 * num2;
      break; 
      default:
         result = ERROR;
   }

   if (result <= UNDERFLOW || result >= OVERFLOW)
      result = ERROR;
   
   return result;
}