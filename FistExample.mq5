//+------------------------------------------------------------------+
//|                                                  FistExample.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//| iNCLUDE LIBRARIES                                                |
//+------------------------------------------------------------------+
#include <VirtualKeys.mqh> // paste includes
#include <Canvas/FlameCanvas.mqh> // other folders
//#include <Canvas/Charts/PieChart.mqh>

//CChartCanvas c;


#define ESSA_E_CONSTANTE = 3.54;

int a =1;
double e = 2.4;
float s = 3.4;
bool asd = true;

datetime data = D'2019.04.22 00:00:00';
datetime data2 = D'2019.04.22 00';
datetime data3 = D'2019.04.22';
string asdasd = "asdadas";

int arrayint[3];
//arrayint[0] = 5;

//double arrayint[3] = [3.5,7.8,9.8];
double meuArray[5] = {3.7,87.5,87.8,74.8};


input int numPeriodos = 11;
input string comentarion = "asdsada@adas.com";

enum TEST
  {
   one = 33, two = 154, three = 11,
  };

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);  // De quanto emq uanto tempo o set vai chamar a funcao on timer, nesse caso, 2 segundos
   Print("aerw", 722, "segundo exto");
//---
for(int i=0; i<10;i++)
{
Print("i= ", i+1);
}


for(int i=0;i<ArraySize(meuArray);i++)
  {
   
  }
  
   return(INIT_SUCCEEDED);
  }
  
 void OnDeinit(const int reason)
 {
   EventKillTimer();
   
   Print("removido");
 }

int k = 0;


//+------------------------------------------------------------------+
//|                                               Control + .        |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Print("Every time the pric changes");
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
Print("call call call");

/*
_Symbol

_Period

_Digits

_Point
*/
   
  }


void myFunc(double a, double b)
{
double soma = a + b;

Print("soma ");
}





