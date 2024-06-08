//+------------------------------------------------------------------+
//|                                                CandleExample.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


MqlRates candles[];

MqlTick tick;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(2);
   
   // Copy rates into my candles
   // last 3 candles
   CopyRates(_Symbol, _Period, 0, 3, candles);
   
   // Set last candle is 0... if i dont use if, the index 0 wont be the last candle
   ArraySetAsSeries(candles, true);
   
   
   
   //  -----
   
   SymbolInfoTick(_Symbol, tick);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   //Print("Open price = ", candles[0].open);
   //Print("Closure price = ", candles[0].close);
   //Print("=================");
   
   //Print("Last = ", tick.last);
   //Print("Last = ", tick.time);
   //Print("Last = ", tick.volume);
   
   //+------------------------------------------------------------------+
   //| Comment at screen                                                |
   //+------------------------------------------------------------------+
   string screen_caption = "Opened = " + DoubleToString(candles[0].open)+"\n" +
                           "Closure = " + DoubleToString(candles[0].close) + "\n";
                           
Comment(screen_caption);         
//Alert(screen_caption);                        
  }
//+------------------------------------------------------------------+
