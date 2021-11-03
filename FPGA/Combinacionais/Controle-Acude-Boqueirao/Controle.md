# Descrição
  
Para manter o controle das águas do açude de boqueirão, está sendo utilizado um sensor que emite quatro sinais possíveis, descritos a seguir.

- `11` - sensor está com defeito ou descalibrado (**d**).
- `10` - volume de água até 30% (Nível baixo, **b**);
- `01` - volume de água acima de 30% e até 80% (Nível normal, **n**);
- `00` - volume de água acima de 80% (Nível alto, **a** ou **A**) 

Para facilitar a visualização da situação do volume de água do açude, deverá ser implementado um circuito digital que apresente os resultados do sensor em um display de 7 segmentos, conforme indicado acima (**b**, **n**, **a** ou **A** e **d**).
  