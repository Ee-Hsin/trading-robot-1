//+------------------------------------------------------------------+
//|                   trading_robot_trend_following-ma-crossover.mq4 |
//|                                                          Ee Hsin |
//|                                       https://github.com/Ee-Hsin |
//+------------------------------------------------------------------+
#property copyright "Ee Hsin"
#property link      "https://github.com/Ee-Hsin"
#property version   "1.00"
#property strict
#include <CustomFunctions1.mqh>

int magicNB = 55555;

input int smallEmaPeriod = 20;
input int bigEmaPeriod = 40;
input int stopLossEmaPeriod = 50;
input double riskPerTrade = 0.02; //0.02 corresponds to a 2% risk per trade.
input int tradingTimeFrame = 240; //1 corresponds to 1 minute, so this 240 is Every 4 Hours.
input double stopLossDistanceInAtr = 3;
input double tpDistanceInAtr = 8;
int openOrderID;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("Initialized Trend Following with MA Crossover strategy trading robot");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //Close all existing positions of this EA on deinitialization unless timeframe being used is H4 or D1:
   if (tradingTimeFrame < 240){
      int openOrders = OrdersTotal();
   
      for (int i =0; i < openOrders; i++){
         if (OrderSelect(i,SELECT_BY_POS) ==true)
         {
            if (OrderMagicNumber() == magicNB)
            {
               //CLOSE THE ORDERS
            }
         }
   }
   
   }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //Don't forget to Normalize Double when needed.

   //Check for candle refresh with While loop
   //Check for whether it can trade, if auto trading not on, alert user
   //Inside Loop, check for open Orders first. If there alr is an order, update the order SL based on Trailing EMA
   //If there isn;t an order, check for criteria for order, and send out orders accordingly.
   
   //Check for new candle
   if (IsNewCandle()){
      //Check that trading has been enabled
      if (IsTradingAllowed()){
      
         bool canAddNewTrade = true;
         //Check for open orders, set canAddNewTrade as false if we come across an open trade with our magic number.
         int openOrders = OrdersTotal();
         for (int i =0; i < openOrders; i++){
            if (OrderSelect(i,SELECT_BY_POS) ==true)
            {
               if (OrderMagicNumber() == magicNB)
               {
                  //Update stop loss of order based on EMA (Stop loss can't be moved down (if long), or up (if short)
                  int orderType = OrderType();// Short = 1, Long = 0
                  double currStopLoss = OrderStopLoss();
                  double stopLossEma = NormalizeDouble(iMA(NULL,tradingTimeFrame,stopLossEmaPeriod,0,MODE_EMA,PRICE_CLOSE,1),_Digits);
                  
                  double slDistance = MathAbs(currStopLoss - stopLossEma);
                  
                  //Short, so if stopLossEma is smaller than currStoploss by more than 1.5 pips, then only update.
                  if (orderType == 1 && (stopLossEma < currStopLoss) && (slDistance > (GetPipValue() * 1.5))){
                     
                     bool Res = OrderModify(openOrderID,OrderOpenPrice(),stopLossEma,OrderTakeProfit(),0);
                     CheckOrderStatus(Res, openOrderID);
                     
                  //Long, so if stopLossEma is bigger than currStopLoss by more than 1.5 pips, then only update.
                  } else if (orderType == 0 && (stopLossEma > currStopLoss) && (slDistance > (GetPipValue() * 1.5))) {
                     
                     bool Res = OrderModify(openOrderID,OrderOpenPrice(),stopLossEma,OrderTakeProfit(),0);
                     CheckOrderStatus(Res, openOrderID);
                  }
                  
                  //setting canAddNewTrade as false so it doesn't check and possibly send new trades.
                  canAddNewTrade=false;
               }
            }
         }
         //canAddNewTrade= true means that we can add new trade, then CheckIfOpenOrdersByMagicNB does the same thing, but it gives us an extra layer of security.
         if(canAddNewTrade && !CheckIfOpenOrdersByMagicNB(magicNB)){
         
            double prevSmallEma = NormalizeDouble(iMA(NULL,tradingTimeFrame,smallEmaPeriod,0,MODE_EMA,PRICE_CLOSE,2),_Digits);
            double prevBigEma = NormalizeDouble(iMA(NULL,tradingTimeFrame,bigEmaPeriod,0,MODE_EMA,PRICE_CLOSE,2),_Digits);
         
            double smallEma = NormalizeDouble(iMA(NULL,tradingTimeFrame,smallEmaPeriod,0,MODE_EMA,PRICE_CLOSE,1),_Digits);
            double bigEma = NormalizeDouble(iMA(NULL,tradingTimeFrame,bigEmaPeriod,0,MODE_EMA,PRICE_CLOSE,1),_Digits);
            
            //Check for crossover:
            
            //Check if smallEma is now above big Ema, but prev was below or equal to prevBigEma.
            //Go Long:
            if (smallEma > bigEma && prevSmallEma <= prevBigEma) {
               
            }
            
            //Check if smallEma is now below bigEma, but prev was above or equal to prevBigEma.
            //Go Short:
            if (smallEma < bigEma && prevSmallEma >= prevBigEma) {
            
            }
            
         }
         
      }
   }
   
  }
//+------------------------------------------------------------------+
