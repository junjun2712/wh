//+------------------------------------------------------------------+
//|                 "Original FileName: Awesome.mq4"   AOwInputs.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//|                                       Inputs Added by rideblitz  |
//|------------------------------------------------------------------+
#property  copyright "Copyright © 2005, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Black
#property  indicator_color2  Green
#property  indicator_color3  Red
//---- inputs 
//---- added by rideblitz
extern int  AOPeriod1=5;
extern int  AOPeriod2=34;
//---- indicator buffers
double     ExtBuffer0[];
double     ExtBuffer1[];
double     ExtBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,4);
   IndicatorDigits(Digits+1);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
//---- name for DataWindow and indicator subwindow label
   string short_name;  //added by rideblitz
   short_name="AO (";  //added by rideblitz
   IndicatorShortName(short_name+AOPeriod1+","+AOPeriod2+")");  //modified by rideblitz
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Awesome Oscillator                                               |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd
   for(int i=0; i<limit; i++)
      ExtBuffer0[i]=iMA(NULL,0,AOPeriod1,0,MODE_SMA,PRICE_MEDIAN,i)-iMA(NULL,0,AOPeriod2,0,MODE_SMA,PRICE_MEDIAN,i); //modified by rideblitz
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
        }
      else
        {
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
        }
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

