# trading-robot-1

<b>Overview</b>
</br>
This Trading Robot is based on a MA Crossover strategy, I have been using this strategy to follow trends successfully on the H1, H4 and D1 timeframes 
since July 2020. This is a format of the EA I use, it is not the same as the one I use. I will not reveal the exact values I use and the entirety of my entry and exit rules. 
However, this robot provides a useful framework for my trading strategy, and one can easily customize it to make it fit their trading style.


<b>Instructions to Use</b>
<br>
Auto Trading has to be on, trading stategy will be located in the Experts folder. Fill up the inputs for the technical indicators. 
<br>
As a general guideline, for the moving averages: the smaller the timeframe value, the higher the frequency; and the closer the two MA's timeframes values are to each other, 
the higher the frequency as well.
<br>
Additionally, the entry and exit rules I defined are based on a fixed TP  and trailing SL, these are what fit my trading style, feel free to change that though. 
<br>
I use a VPS to run the bot that way I don't have to worry about closing it. Since I mainly trade on H4 and D1 timeframes, I do not need to worry
about holding over weekends or wide spreads during the 45 minute period right before and after the NYSE Market closes.


<b>NOTES: </b> 
   Slippage in orderSend is dependent on how many digits is given by Broker (if broker doesn;t show mini-pips, a value of 1 = 1 pip. 
   Whereas if broker does show mini pips, a value of 1 = 0.1 pips).
   Lot Size is also dependent upon broker, some brokers have standard lots, so 1 = $100,000 
   of the given currency, and so the smallest order is 0.01 = $1,000 of the given currency. While other brokers don't have this issue. 
   
   I have written the code for this to work on Brokers who offer mini-pips and non-mini pips, as well as Brokers who offer Standard ($100,000)
   ,mini ($10,000) and micro($1,000) lots.
      
<b>Important Additional note:</b>
<br>
This bot will NOT work if deposit currency is in JPY. If your deposit is in JPY, then modify the position sizing function OptimalLotSize
to fit your criteria.

**Proof of Performance:**
![growth_chart_2020_forex_954738_performance](https://user-images.githubusercontent.com/75463789/126431225-38122600-433d-4a48-92a2-1fd34713e00a.JPG)
