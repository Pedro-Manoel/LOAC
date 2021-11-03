# Descrição

Projeto de um circuito sequencial para o controle de uma bomba de recalque que leva água de uma cisterna para uma caixa d'água. 

Na cisterna é instalado um sensor de nível, que demarca o nível mínimo de água. Na caixa d'água são  instalados dois sensores, que demarcam, respectivamente, o nível máximo e mínimo de água.

Quando a caixa d'água estiver vazia (quantidade de água abaixo do nivel mínimo) e houver água na cisterna (quantidade de água acima ou igual ao nivel mínimo) e os sensores da caixa d'água não apresentarem nenhuma inconsistência, devera ser bombada água da cisterna para a caixa d'água, acionando a bomba de recalque. 

A bomba de recalque, depois de acionada, deverá permanecer funcionando até que a caixa d'água fique completamente cheia (quantidade de água igual ao nivel máximo) e seus sensores não apresentem nenhuma inconsistência, ou a cisterna fique vazia (quantidade de água abaixo do nivel mínimo).

Caso os sensores da caixa d'água apresentem, em algum momento, alguma inconsistência, a bomda d´água deve ser desligada, caso esteja ligada, um sinal de aviso deve ser acionado, após isso o circuito só voltara a funcionar depois de um reset. 