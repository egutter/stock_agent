Ejercicio
Un agente de bolsa quiere evaluar las decisiones que toma para comprar y vender acciones.

Como el agente tiene varias estrategias diferentes para comprar o vender, necesita un programa que pueda evaluar estas estrategias para un mes histórico en particular e indicarle, cuál de todas las estrategias posibles es la más conveniente.

Para cada mes el agente tiene una cantidad de dinero en efectivo y un listado de acciones para varias empresas con la cotización diaria de cada acción (ver ejemplo). Por cada una de estas cotizaciones diarias el agente decide si comprar o vender la acción en base a una de las estrategias disponibles.

Las estrategias que quiere evaluar son:

Estrategia 1)
a) comprar una acción si el precio cayó al menos un 1% con respecto a la cotización del día anterior
b) vender una acción si el precio subió 2% o más con respecto al día anterior

Estrategia 2)
a) comprar una acción, si sucede 1a) o si el precio equivale al menos al doble del promedio de las cotizaciones de la acción hasta esa fecha
b) vender una acción luego de 5 días de haberla comprado

Al final la ejecución del programa se debe informar cuál fue la estrategia que ganó más dinero.
Además es necesario llevar un registro de todas las compras/ventas que se hayan realizado en cada estrategia para un posterior análisis más detallado.

Tener en cuenta que:
- Cada vez que se decide realizar una compra, esta consiste en invertir 1000 pesos comprando todas las acciones que se puedan comprar con ese dinero según la cotización de la fecha
- Cada vez que se decide vender una acción, se venden todo lo que se haya comprado de esa acción
- El último día del mes no pueden quedar acciones sin vender, si quedaron acciones porque no se activó ninguna decisión de venta, se deben vender todas al precio de ese día y quedarse sólo con dinero en efectivo
- El programa inicia con 1 millón de pesos en efectivo

Aclaraciones:
- No es necesario implementar persistencia ni UI
- Realizar el ejercicio mediante TDD

Ejemplo del listado de acciones con su cotización:
Accion, Fecha, Precio

YPF, 1/4/2014, $290
TS, 1/4/2014, $215,5
GGAL, 1/4/2014, $13,45
YPF, 2/4/2014, $294
TS, 2/4/2014, $216,5
GGAL, 2/4/2014, $13,25
YPF, 3/4/2014, $288
TS, 3/4/2014, $216
GGAL, 3/4/2014, $12,80

etc...


---------------------------

Exercise A broker wants to evaluate the decisions to buy and sell shares.
As the agent has several different strategies for buying or selling, you need a program that can evaluate these strategies for a particular month historical and indicate which of all possible strategies is most suitable.

For each month the agent has an amount of cash and a list of actions for various companies with the daily price of each share (see example).
For each of these daily quotes the agent decides whether to buy or sell stocks based on one of the strategies available.

The strategies you want to evaluate are:

Strategy 1)
a) buy a stock if the price dropped at least 1% compared to the previous trading day
b) sell a stock if the price rose 2% or more from the previous day

Strategy 2)
a) buy a stock, if it happens 1a) or if the price is equal to at least twice the average quotation of the share until that date
b) sell a stock after five days of having purchased

the end execution program should be informed what was the strategy that won more money.

It is also necessary to keep records of all purchases / sales have been made in each strategy for further detailed analysis.

Note that:
- Each time you choose to buy, this is to invest 1000 dollars buying all the shares that can be bought with that money according to the quotation date
- Whenever you decide to sell a stock, sold everything that was purchased from that action
- The last day of the month can not be shares without selling, if they were actions because any decision to sell was not activated, must sell all the price of that day and keep only cash
- The program starts with 1 million dollars in cash

Notes:
- No need to implement persistence or UI
- Perform the exercise by TDD

Example list of actions with your quote:
action, Date, price
YPF, 1/4/2014, $290
TS, 1/4/2014, $215,5
GGAL, 1/4/2014, $13,45
YPF, 2/4/2014, $294
TS, 2/4/2014, $216,5
GGAL, 2/4/2014, $13,25
YPF, 3/4/2014, $288
TS, 3/4/2014, $216
GGAL, 3/4/2014, $12,80
