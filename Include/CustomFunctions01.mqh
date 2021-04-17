//+------------------------------------------------------------------+
//|                                             CustomFunctions1.mqh |
//|                                                          Ee Hsin |
//|                                       https://github.com/Ee-Hsin |
//+------------------------------------------------------------------+
#property copyright "Ee Hsin"
#property link      "https://github.com/Ee-Hsin"
#property strict


bool IsTradingAllowed(){
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

double GetPipValue(){
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
        takeProfit = entryPrice + takeProfitInPips * GetPipValue();
    }else {
        takeProfit = entryPrice - takeProfitInPips * GetPipValue();
    }
    return takeProfit;
}

double CalculateStopLoss(bool isLong, int stopLossInPips, double entryPrice){
    double stopLoss;
    if (isLong){
        stopLoss = entryPrice - stopLossInPips * GetPipValue();
    }else {
        stopLoss = entryPrice + stopLossInPips * GetPipValue();
    }
    return stopLoss;
}

//POSITION SIZING FUNCTIONS BELOW: (NOTE THAT THIS WILL NOT WORK IF YOUR DEPOSIT CURRENCY IS JPY).

//Helper function 
double OptimalLotSize(double maxRiskPrc, int maxLossInPips)
{

  double accEquity = AccountEquity();
  Alert("accEquity: " + accEquity);
  
  double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
  Alert("lotSize: " + lotSize);
  
  double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
  
  //If it is a JPY Currency:
  if(Digits <= 3)
  {
   tickValue = tickValue /100;
  }
  
  Alert("tickValue: " + tickValue);
  
  double maxLossDollar = accEquity * maxRiskPrc;
  Alert("maxLossDollar: " + maxLossDollar);
  
  double maxLossInQuoteCurr = maxLossDollar / tickValue;
  Alert("maxLossInQuoteCurr: " + maxLossInQuoteCurr);
  
  double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * GetPipValue())/lotSize,2);
  
  return optimalLotSize;
 
}

//Basically uses the function above but takes the difference between and entry and stop loss price before passing in the maxLossInPips
double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   int maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
}

//Checks if there is an order open with the magic number.
bool CheckIfOpenOrdersByMagicNB(int magicNB){
   int openOrders = OrdersTotal();
   
   for (int i =0; i < openOrders; i++){
      if (OrderSelect(i,SELECT_BY_POS) ==true)
      {
         if (OrderMagicNumber() == magicNB)
         {
            return true;
         }
      }
   }
   return false;

}

bool IsNewCandle() 
{
   static datetime saved_candle_time;
   if(Time[0]==saved_candle_time){
      return false;
   } else {
      return true;
   }

}

bool CheckOrderStatus( bool res){
    //Checking the result of the OrderModify we send.
    if (Res==true)                     
    {
        Print("Order modified: ",openOrderID);
                                
    }else
    {
        Print("Unable to modify order: ",openOrderID);
    }   
} 