//Version: 4
//Time: Sunday, November 13, 2006
//+------------------------------------------------------------------+
//|                       XP Moving Average                          | 
//|                                                         xpMA.mq4 |
//|                                         Developed by Coders Guru |
//|                                            http://www.xpworx.com |
//+------------------------------------------------------------------+

#property link      "http://www.xpworx.com"


#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Maroon
#property indicator_color3 DarkBlue

#define MODE_DEMA 4
#define MODE_TEMA 5
#define MODE_T3MA 6
#define MODE_JMA 7

/* Moving average types constants:
------------------------------------
MODE_SMA       0     Simple moving average, 
MODE_EMA       1     Exponential moving average, 
MODE_SMMA      2     Smoothed moving average, 
MODE_LWMA      3     Linear weighted moving average.
MODE_DEMA      4     Double Exponential Moving Average. 
MODE_TEMA      5     Triple Exponential Moving Average.
MODE_T3MA      6     T3 Moving Average. 
MODE_JMA       7     Jurik Moving Average. 

------------------------------------*/

/* Applied price constants:
-------------------------------
PRICE_CLOSE    0     Close price. 
PRICE_OPEN     1     Open price. 
PRICE_HIGH     2     High price. 
PRICE_LOW      3     Low price. 
PRICE_MEDIAN   4     Median price, (high+low)/2. 
PRICE_TYPICAL  5     Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6     Weighted close price, (high+low+close+close)/4.
--------------------------------- */

 
extern   int      MA_Period               = 10;
extern   int      MA_Type                 = MODE_TEMA;
extern   int      MA_Applied              = PRICE_CLOSE;
extern   double   T3MA_VolumeFactor       = 0.8;
extern   double   JMA_Phase               = 0;
extern   int      Step_Period             = 1;
extern   bool     DebugMode               = false;

bool     Alert_On                = false;
bool     Arrows_On               = false;
int      UpArrowCode             = 233;
int      DownArrowCode           = 234;
color    UpArrowColor            = DarkGoldenrod;
color    DownArrowColor          = FireBrick;
int      UpArrowSize             = 1;
int      DownArrowSize           = 1;


double UpBuffer[];
double DownBuffer[];
double Buffer3[];
double buffer[];
double tempbuffer[];
double matriple[];
double signal[];

int init()
{
   DeleteAllObjects();
   IndicatorBuffers(7); 

   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,3);
   SetIndexBuffer(2,UpBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,3);
   SetIndexBuffer(1,DownBuffer);
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,3);
   SetIndexBuffer(0,Buffer3);
   
   SetIndexBuffer(3,signal);
   SetIndexBuffer(4,buffer);
   SetIndexBuffer(5,tempbuffer);
   SetIndexBuffer(6,matriple);
   
   SetIndexLabel(0,"XP Moving Average");
   SetIndexLabel(1,"UpBuffer");
   SetIndexLabel(2,"DownBuffer");
   SetIndexLabel(3,"Signal");
   
   return(0);
}

int deinit()
{
   DeleteAllObjects();
   return(0);
}



void start()
{
   int limit;
   int i = 0;
   
   int counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   //if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars-1;
   
   switch (MA_Type)
   {
      case 0:
      case 1:
      case 2:
      case 3:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMA(NULL,0,MA_Period,0,MA_Type,MA_Applied,i);
                  }
            }
            break;
      
      case 4:
            {
                  for(i=0; i<limit; i++)
                  {
                     tempbuffer[i] = iMA(NULL,0,MA_Period,0,MODE_EMA,MA_Applied,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     matriple[i] = iMAOnArray(tempbuffer,0,MA_Period,0,MODE_EMA,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMAOnArray(matriple,0,MA_Period,0,MODE_EMA,i);
                  }
            }
            break;
      
      case 5:
            {
                  for(i=0; i<limit; i++)
                  {
                     tempbuffer[i] = iMA(NULL,0,MA_Period,0,MODE_EMA,MA_Applied,i);
                  }
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iMAOnArray(tempbuffer,0,MA_Period,0,MODE_EMA,i);
                  }
            }
            break;
      
      case 6:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,0,"T3MA",MA_Period,T3MA_VolumeFactor,0,i);
                  }
            }
            break;
      case 7:
            {
                  for(i=0; i<limit; i++)
                  {
                     buffer[i] = iCustom(NULL,0,"JMA",MA_Period,JMA_Phase,0,i);
                  }
            }
            break;
   }

   for(int shift=0; shift<limit; shift++)
   {
       UpBuffer[shift] = buffer[shift];
       DownBuffer[shift] = buffer[shift];
       Buffer3[shift] = buffer[shift];
   }                   
   
   /*for(shift=0; shift<limit; shift++)
   {
      if (buffer[shift]<buffer[shift+1])
      {
         UpBuffer[shift] = EMPTY_VALUE;
      }
      else if (buffer[shift]>buffer[shift+1] )
      {
         DownBuffer[shift] = EMPTY_VALUE;
      } 
     else
      {
         UpBuffer[shift] = CLR_NONE;
         DownBuffer[shift] = CLR_NONE;
      }
   }*/
   
   for(shift=0; shift<limit; shift++)
   {
      double dMA = 0;
      for(int k = shift+1; k <= shift+Step_Period; k++){
         dMA += buffer[k];
      }
      dMA = dMA / Step_Period;

      if (buffer[shift] < dMA)
      {
         UpBuffer[shift] = EMPTY_VALUE;
      }
      else if (buffer[shift]>dMA)
      {
         DownBuffer[shift] = EMPTY_VALUE;
      } 
      else
      {
         UpBuffer[shift] = EMPTY_VALUE;
         DownBuffer[shift] = EMPTY_VALUE;
      }
   }
   for(shift=0; shift<limit; shift++)
   {
         signal[shift]=0;
         if(UpBuffer[shift+1] == EMPTY_VALUE &&  UpBuffer[shift] != EMPTY_VALUE && Buffer3[shift+1] != UpBuffer[shift] )
            {
               DrawObject(1,shift,buffer[shift] - (10*Point));
               signal[shift]=1;
            }
            
         if(DownBuffer[shift+1] == EMPTY_VALUE &&  DownBuffer[shift] != EMPTY_VALUE && Buffer3[shift+1] != DownBuffer[shift])
           {
               DrawObject(2,shift,buffer[shift] + (15*Point));
               signal[shift]=-1;
           }
   } 
                     
   if(UpBuffer[1] == EMPTY_VALUE &&  UpBuffer[0] != EMPTY_VALUE && Buffer3[1] != UpBuffer[0])
      AlertOnce(Symbol()+ ":" + PeriodToText() + "  -  Up Signal",1);
   if(DownBuffer[1] == EMPTY_VALUE &&  DownBuffer[0] != EMPTY_VALUE && Buffer3[1] != DownBuffer[0])   
      AlertOnce(Symbol()+ ":" + PeriodToText() + "  -  Down Signal",2);
   
   if(DebugMode)
   { 
      TakeScreenShot(40);
   }

   return(0);
}

void DrawObject(int direction, int bar , double price)
{
   static int count = 0;
   count++;
   string Obj = "";
   if (direction==1) //up arrow
   {
      Obj = "xpMA_up_" + DoubleToStr(count,0);
      ObjectCreate(Obj,OBJ_ARROW,0,Time[bar],price);
      ObjectSet(Obj,OBJPROP_COLOR,UpArrowColor);
      ObjectSet(Obj,OBJPROP_ARROWCODE,UpArrowCode);
      ObjectSet(Obj,OBJPROP_WIDTH,DownArrowSize);
   }
   if (direction==2) //down arrow
   {
      Obj = "xpMA_down_" + DoubleToStr(count,0);
      ObjectCreate(Obj,OBJ_ARROW,0,Time[bar],price);
      ObjectSet(Obj,OBJPROP_COLOR,DownArrowColor);
      ObjectSet(Obj,OBJPROP_ARROWCODE,DownArrowCode);
      ObjectSet(Obj,OBJPROP_WIDTH,DownArrowSize);
   }
   ObjectsRedraw();
}

void DeleteAllObjects()
{
   int objs = ObjectsTotal();
   string name;
   for(int cnt=ObjectsTotal()-1;cnt>=0;cnt--)
   {
      name=ObjectName(cnt);
      if (StringFind(name,"xpMA",0)>-1) ObjectDelete(name);
      ObjectsRedraw();
   }
}

bool AlertOnce(string alert_msg, int ref)
{  
   static int LastAlert_1 = 0;
   static int LastAlert_2 = 0;
   static int LastAlert_3 = 0;
   static int LastAlert_4 = 0;
   
   switch(ref)
   {
      case 1:
         if( LastAlert_1 == 0 || LastAlert_1 < Bars )
         {
            Alert(alert_msg);
            LastAlert_1 = Bars;
            return (1);
         }
      break;
      case 2:
         if( LastAlert_2 == 0 || LastAlert_2 < Bars )
         {
            Alert(alert_msg);
            LastAlert_2 = Bars;
            return (1);
         }
      break;
      case 3:
         if( LastAlert_3 == 0 || LastAlert_3 < Bars )
         {
            Alert(alert_msg);
            LastAlert_3 = Bars;
            return (1);
         }
      break;
      case 4:
         if( LastAlert_4 == 0 || LastAlert_4 < Bars )
         {
            Alert(alert_msg);
            LastAlert_4 = Bars;
            return (1);
         }
      break;
   }
}

void TakeScreenShot(int exit_on = -1)
{
   int count = 1;
   
   if(!GlobalVariableCheck("ssc"))
   {
    GlobalVariableSet("ssc",1);
    count = 1;
   }
   else
   {
      count = GlobalVariableGet("ssc") + 1;
      GlobalVariableSet("ssc",count); 
   }
   
   if ( exit_on > 0 && count > exit_on ) return(0);
   
   string filename = "xpMA\\" + "xpMA_" + Symbol() +  "_" + DoubleToStr(count,0) + ".jpg";
   ScreenShot(filename,320,480);
}
string PeriodToText()
{
   switch (Period())
   {
      case 1:
            return("M1");
            break;
      case 5:
            return("M5");
            break;
      case 15:
            return("M15");
            break;
      case 30:
            return("M30");
            break;
      case 60:
            return("H1");
            break;
      case 240:
            return("H4");
            break;
      case 1440:
            return("D1");
            break;
      case 10080:
            return("W1");
            break;
      case 43200:
            return("MN1");
            break;
   }

}







