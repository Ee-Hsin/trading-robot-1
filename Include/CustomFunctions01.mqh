//+------------------------------------------------------------------+
//|                                             CustomFunctions1.mqh |
//|                                                          Ee Hsin |
//|                                       https://github.com/Ee-Hsin |
//+------------------------------------------------------------------+
#property copyright "Ee Hsin"
#property link      "https://github.com/Ee-Hsin"
#property strict


bool isTradingAllowed(){
    if (!IsTradeAllowed()){
        Alert("Expert Advisor is not allowed to trade right now, please check the AutoTrader Setting instead");
        return false;
    }

    if (!IsTradeAllowed(Symbol(), TimeCurrent()))
    {
        Alert("Trading not allowed right now for this specific Symbol and Time");
        return false;
    }
    
    return true;
}

double getPipValue(){
   int digits = _Digits;
   //if it is a NON-JPY pair:
   if (digits >= 4){
      return 0.0001;
      
   } //If it is:
   else { 
      return 0.01;
   }
}

double CalculateTakeProfit(bool isLong, int takeProfitInPips, double entryPrice){
    double takeProfit;
    if (isLong){
        takeProfit = entryPrice + takeProfitInPips * getPipValue();
    }else {
        takeProfit = entryPrice - takeProfitInPips * getPipValue();
    }
    return takeProfit;
}

double CalculateStopLoss(bool isLong, int stopLossInPips, double entryPrice){
    double stopLoss;
    if (isLong){
        stopLoss = entryPrice - stopLossInPips * getPipValue();
    }else {
        stopLoss = entryPrice + stopLossInPips * getPipValue();
    }
    return stopLoss;
}
