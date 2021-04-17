//+------------------------------------------------------------------+
//|                   trading_robot_trend_following-ma-crossover.mq4 |
//|                                                          Ee Hsin |
//|                                       https://github.com/Ee-Hsin |
//+------------------------------------------------------------------+
#property copyright "Ee Hsin"
#property link      "https://www.mql5.com"
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
input int atrPeriod = 14;
input int minAtrInPips = 5;
extern double Slippage=3; //Put the allowed Slippage in pips.
int openOrderID;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("Initialized Trend Following with MA Crossover strategy trading robot");
   
   // Normalization of the slippage (If Broker has 3 or 5 digits, it means that the broker allows mini pips), so we should multiply slippage by 10.
   //If the broker only offers 2 or 4, it measn the broker does not have mini pips, so if we put a value of 1, it means 1 pip instead of 1 mini-pip.
   if(Digits==3 || Digits==5){
      Slippage=Slippage*10;
   }   
   
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
               int orderType = OrderType();// Short = 1, Long = 0
               
               //If it is a Short, we have to buy back at the Ask.
               if (orderType == 1){
                  bool Res = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrNONE);
               //If it is a Long, we have to buy back at the Bid.
               } else if(orderType ==0){
                  bool Res = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrNONE);
               } 
               
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
   //STEPS:
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
                     
                     bool Res = OrderModify(OrderTicket(),OrderOpenPrice(),stopLossEma,OrderTakeProfit(),0);
                     CheckOrderStatus(Res, openOrderID);
                     
                  //Long, so if stopLossEma is bigger than currStopLoss by more than 1.5 pips, then only update.
                  } else if (orderType == 0 && (stopLossEma > currStopLoss) && (slDistance > (GetPipValue() * 1.5))) {
                     
                     bool Res = OrderModify(OrderTicket(),OrderOpenPrice(),stopLossEma,OrderTakeProfit(),0);
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
            
            double ATR = NormalizeDouble(iATR(NULL,tradingTimeFrame,atrPeriod,1),_Digits);
            //Check for crossover:
            
            //Check if smallEma is now above big Ema, but prev was below or equal to prevBigEma .
            //Go Long:
            if (smallEma > bigEma && prevSmallEma <= prevBigEma && ATR > (minAtrInPips * GetPipValue())) {
            
               //Calculate initial stop loss
               double stopLoss = Ask - ATR * stopLossDistanceInAtr;
               stopLoss = NormPrice(stopLoss);
               
               //Calculate Take Profit:
               double takeProfit = Ask + ATR * tpDistanceInAtr;
               takeProfit = NormPrice(takeProfit);
               
               //Calculate Lot Size:
               double optimalLotSize = OptimalLotSize(riskPerTrade,Ask,stopLoss);
                           
               openOrderID = OrderSend(NULL,OP_BUY,optimalLotSize,Ask,Slippage,stopLoss,takeProfit,NULL,magicNB);
               if(openOrderID < 0) Print("order rejected. Order error: " + GetLastError());
            }
            
            //Check if smallEma is now below bigEma, but prev was above or equal to prevBigEma.
            //Go Short:
            if (smallEma < bigEma && prevSmallEma >= prevBigEma && ATR > (minAtrInPips * GetPipValue())) {
               
               //Calculate initial stop loss
               double stopLoss = Bid + ATR * stopLossDistanceInAtr;
               stopLoss = NormPrice(stopLoss);
               
               //Calculate Take Profit:
               double takeProfit = Bid - ATR * tpDistanceInAtr;
               takeProfit = NormPrice(takeProfit);
               
               //Calculate Lot Size:
               double optimalLotSize = OptimalLotSize(riskPerTrade,Bid,stopLoss);
               
               openOrderID = OrderSend(NULL,OP_SELL,optimalLotSize,Bid,Slippage,stopLoss,takeProfit,NULL,magicNB);
               if(openOrderID < 0) Print("order rejected. Order error: " + GetLastError());
               
            }
            
         }
         
      }
   }
   
  }
//+------------------------------------------------------------------+
