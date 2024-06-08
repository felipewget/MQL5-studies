//+------------------------------------------------------------------+
//|                                            IndicatorsExample.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//--- Buffers are output on indicators <- pls, custom one indicator

//--- Media movel
int mmHandler;
double mmBuffer[];
//--- IFR
int ifrHandle;
double ifrBufer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(5  );
//--- 
   mmHandler = iMA(_Symbol, _Period, 21, 0,MODE_SMA, PRICE_CLOSE);
   
   ifrHandle = iRSI(_Symbol, _Period, 7, PRICE_CLOSE);
   
   if(mmHandler < 0 || ifrHandle < 0){
      Alert("Error during the loading", GetLastError()); // get last error
      return (-1); // exit
   }
   
   ChartIndicatorAdd(0, 0, mmHandler);
   ChartIndicatorAdd(0, 1, ifrHandle); // 1 because it's another window
   ////
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
   //CopyBuffer(mmHandler, 0, 0, 3, mmBuffer);
   
   //ArraySetAsSeries(mmBuffer, true);
   
   //Print("MM Value", mmBuffer[0]);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   CopyBuffer(mmHandler, 0, 0, 3, mmBuffer);
   
   ArraySetAsSeries(mmBuffer, true);
   
   Print("MM Value", mmBuffer[0]);
   
   ///
   
   CopyBuffer(ifrHandle, 0, 0, 3, ifrBufer);
  }
//+------------------------------------------------------------------+
