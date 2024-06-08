//+------------------------------------------------------------------+
//|                                                   mm_rsi_bot.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//---
enum STRATEGY_MODE_INPUT {
   MM_ONLY,
   RSI_ONLY,
   RSI_AND_MM,
};
//---

//+------------------------------------------------------------------+
//|                    Inputs                                        |
//+------------------------------------------------------------------+

sinput string s0; // ---- inputs -----
input STRATEGY_MODE_INPUT strategy = MM_ONLY;

sinput string s1; // --------- mm -------------
input int mm_rapida_periodo = 12;
input int mm_lenta_periodo = 32;
input ENUM_TIMEFRAMES mm_tempo_grafico = PERIOD_CURRENT;
input ENUM_MA_METHOD mm_metodo = MODE_EMA;
input ENUM_APPLIED_PRICE mm_preco = PRICE_CLOSE;

sinput string s2; // --------- RSI -----------
input int ifr_pediod = 5;
input ENUM_TIMEFRAMES ifr_tempo_grafico = PERIOD_CURRENT;
input ENUM_APPLIED_PRICE ifr_preco = PRICE_CLOSE;

input int ifr_sobrecompra = 70;
input int ifr_sobrevenda = 30;

sinput string s3; // -----------------------------
input int num_lots = 100;
input double TK = 60;
input double SL = 30;

sinput string s4; // ----------------------------
input string hora_limite_fecha_ip = "17:40";

//+------------------------------------------------------------------+
//| Indicators                                                                  |
//+------------------------------------------------------------------+

int mm_rapida_handler;
double mm_rapido_buffer[];

int mm_lenta_handler;
double mm_lenta_buffer[];

int ifr_handle;
double ifr_buffer[];

int magic_number = 12312321; // bot id

MqlRates candles[];
MqlTick tick;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   mm_rapida_handler = iMA(_Symbol, mm_tempo_grafico, mm_rapida_periodo, 0, mm_metodo, mm_preco);
   mm_lenta_handler = iMA(_Symbol, mm_tempo_grafico, mm_lenta_periodo, 0, mm_metodo, mm_preco);
   
   ifr_handle = iRSI(_Symbol, ifr_tempo_grafico, ifr_pediod, ifr_preco);
   
   if(mm_lenta_handler < 0 || mm_rapida_handler < 0 || ifr_handle < 0){
      Alert("Erro: ", GetLastError());
      return (-1);
   }
   
   CopyRates(_Symbol, _Period, 0, 4, candles);
   ArraySetAsSeries(candles, true);
   
   ChartIndicatorAdd(0,0,mm_rapida_handler);
   ChartIndicatorAdd(0,0,mm_lenta_handler);
   ChartIndicatorAdd(0,1,ifr_handle);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(mm_lenta_handler);
   IndicatorRelease(mm_rapida_handler);
   IndicatorRelease(ifr_handle);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {
//---
  //drawVerticalLine("L1", tick.time);
  CopyBuffer(mm_rapida_handler, 0,0,4, mm_rapido_buffer);
  CopyBuffer(mm_lenta_handler, 0,0,4, mm_lenta_buffer);
  
  CopyBuffer(ifr_handle, 0,0,4, ifr_buffer);
 
 CopyRates(_Symbol, _Period, 0,4, candles);
 
 ArraySetAsSeries(mm_rapido_buffer, true);
 ArraySetAsSeries(mm_lenta_buffer, true);
 ArraySetAsSeries(ifr_buffer, true);
 
 SymbolInfoTick(_Symbol, tick);
 
 
 bool compra_mm_cross = mm_rapido_buffer[0] > mm_lenta_buffer[0] && 
                        mm_rapido_buffer[2] < mm_lenta_buffer[2];
                        
 bool compra_ifr = ifr_buffer[0] <= ifr_sobrevenda;
 
 bool venda_mm_cross = mm_rapido_buffer[0] < mm_lenta_buffer[0] && 
                        mm_rapido_buffer[2] > mm_lenta_buffer[2];
                        
 bool venda_ifr = ifr_buffer[0] >= ifr_sobrecompra;
 
 
    bool Comprar = false;
    bool Vender = false;
    
    if(strategy == MM_ONLY){
       Comprar = compra_mm_cross;
       Vender = venda_mm_cross;
    } else if(strategy == RSI_ONLY){
      Comprar = compra_ifr;
       Vender = venda_ifr;
    } else {
      Comprar = compra_ifr && compra_mm_cross;
       Vender = venda_ifr && venda_mm_cross;
    }
    
    bool newCandle = temosUmaNovaVela();
    
    if(newCandle){
      if(Comprar && PositionSelect(_Symbol) == false){
         drawVerticalLine("COMPRA", candles[1].time);
         comprarAMercado();
      }

      if(Vender && PositionSelect(_Symbol) == false){
         drawVerticalLine("VENDA", candles[1].time);
         vendaAMercado();
      }
    }
  
  
   // We will clode the operation based on minutes that this operation is opened
   if(TimeToString(TimeCurrent(), TIME_MINUTES) == hora_limite_fecha_ip && PositionSelect(_Symbol) == true){
      Print("FORCE CLOSE");
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
         //fecharCompra();
      } else {
        // fecharVenda();
      }
   }
  
 }
//+------------------------------------------------------------------+


void drawVerticalLine(string name, datetime dt, color colour = clrAliceBlue){
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_VLINE, 0, dt, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, colour);
}

void comprarAMercado(){
   MqlTradeRequest requisicao; 
   MqlTradeResult resposta;
   
   ZeroMemory(requisicao);
   ZeroMemory(resposta);
   
   // ---- caracteristics
   
   // NormalizeDouble(tick.ask - SL*_Point, _Digits); <- normalize to type od double... 0, 500 for example for mini dolar
   
   requisicao.action = TRADE_ACTION_DEAL;
   requisicao.magic = magic_number;
   requisicao.symbol = _Symbol;
   requisicao.volume = num_lots;
   requisicao.price = NormalizeDouble(tick.ask, _Digits);
   requisicao.sl = NormalizeDouble(tick.ask - SL*_Point, _Digits);
   requisicao.tp= NormalizeDouble(tick.ask + TK*_Point, _Digits);
   requisicao.deviation = 0;
   requisicao.type = ORDER_TYPE_BUY;
   requisicao.type_filling = ORDER_FILLING_FOK;
   
   //---
   
   OrderSend(requisicao, resposta);
   
   if(resposta.retcode == 10008 || resposta.retcode == 10009){
      Print("COMPRA COM SUCESSO!");
   } else {
      Print("erro =/");
   }
}


void vendaAMercado(){
   MqlTradeRequest requisicao; 
   MqlTradeResult resposta;
   
   ZeroMemory(requisicao);
   ZeroMemory(resposta);
   
   // ---- caracteristics
   
   // NormalizeDouble(tick.ask - SL*_Point, _Digits); <- normalize to type od double... 0, 500 for example for mini dolar
   
   requisicao.action = TRADE_ACTION_DEAL;
   requisicao.magic = magic_number;
   requisicao.symbol = _Symbol;
   requisicao.volume = num_lots;
   requisicao.price = NormalizeDouble(tick.bid, _Digits);
   requisicao.sl = NormalizeDouble(tick.bid + SL*_Point, _Digits);
   requisicao.tp= NormalizeDouble(tick.bid - TK*_Point, _Digits);
   requisicao.deviation = 0;
   requisicao.type = ORDER_TYPE_SELL;
   requisicao.type_filling = ORDER_FILLING_FOK;
   
   //---
   
   OrderSend(requisicao, resposta);
   
   if(resposta.retcode == 10008 || resposta.retcode == 10009){
      Print("COMPRA COM SUCESSO!");
   } else {
      Print("erro =/");
   }
}

void fecharCompra(){
   MqlTradeRequest requisicao; 
   MqlTradeResult resposta;
   
   ZeroMemory(requisicao);
   ZeroMemory(resposta);
   
   // ---- caracteristics
   
   requisicao.action = TRADE_ACTION_DEAL;
   requisicao.magic = magic_number;
   requisicao.symbol = _Symbol;
   requisicao.volume = num_lots;
   requisicao.price = 0;
   requisicao.type = ORDER_TYPE_SELL;
   requisicao.type_filling = ORDER_FILLING_RETURN;
   
   //---
   
   OrderSend(requisicao, resposta);
   
   if(resposta.retcode == 10008 || resposta.retcode == 10009){
      Print("COMPRA COM SUCESSO!");
   } else {
      Print("erro =/");
   }
}

void fecharVenda(){
   MqlTradeRequest requisicao; 
   MqlTradeResult resposta;
   
   ZeroMemory(requisicao);
   ZeroMemory(resposta);
   
   // ---- caracteristics
   
   requisicao.action = TRADE_ACTION_DEAL;
   requisicao.magic = magic_number;
   requisicao.symbol = _Symbol;
   requisicao.volume = num_lots;
   requisicao.price = 0;
   requisicao.type = ORDER_TYPE_BUY;
   requisicao.type_filling = ORDER_FILLING_RETURN;
   
   //---
   
   OrderSend(requisicao, resposta);
   
   if(resposta.retcode == 10008 || resposta.retcode == 10009){
      Print("COMPRA COM SUCESSO!");
   } else {
      Print("erro =/");
   }
}

bool temosUmaNovaVela()
{
   static datetime last_time =0;
   
   datetime lastbar_time = (datetime)SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);
   
   if(last_time == 0){
      last_time = lastbar_time;
      return false;
   }
   
   if(last_time != 0){
      last_time = lastbar_time;
      return true;
   }
   
   return false;
}