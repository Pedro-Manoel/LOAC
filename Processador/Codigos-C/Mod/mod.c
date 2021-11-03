int mod (register int num1, register int num2) {
   register int result = 0;
   
   if (num1 + num2 != 0)
      result = num1 % num2;

   return result;
}