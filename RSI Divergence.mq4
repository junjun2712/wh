#property copyright   "Copyright © 2014, The lazy trader"
#property link        "http://www.the-lazy-trader.com"
#property description "Hidden and regular RSI divergence indicator"
#property version     "1.0"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_level1 30
#property indicator_level2 70
#property indicator_minimum 0
#property indicator_maximum 100

#define arrowsDisplacement 0.0003

input string                RSI_settings                     = "----------------------------------------------------------------------";
input int                   RSI_period                       = 14;
input ENUM_APPLIED_PRICE    RSI_applied_price                = 0;
input string                Indicator_settings               = "----------------------------------------------------------------------";
input bool                  DrawIndicatorTrendLines          = true;
input bool                  DrawPriceTrendLines              = true;
input bool                  DisplayAlert                     = true;
input bool                  DisplayClassicalDivergences      = true;
input bool                  DisplayHiddenDivergences         = false;
input color                 LongColour                       = clrLimeGreen;
input color                 ShortColour                      = clrDeepPink;
input uchar                 LongArrowCode                    = 233;
input uchar                 ShortArrowCode                   = 234;
input int                   ArrowSize                        = 0;
input color                 RSIColour                        = clrGoldenrod;
input ENUM_LINE_STYLE       RSIStyle                         = 0;
input int                   RSIWidth                         = 1;

//---- buffers
double bullishDivergence[];
double bearishDivergence[];
double rsi[];
double divergencesType[];
double divergencesRSIDiff[];
double divergencesPriceDiff[];

//----
static datetime lastAlertTime;
static string   indicatorName;
string RSILine,PriceLine;

void OnInit()
{int t1;
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,EMPTY,ArrowSize,LongColour);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,ArrowSize,ShortColour);
   SetIndexStyle(2,DRAW_LINE,RSIStyle,RSIWidth,RSIColour);
   t1=3; while(t1<=5) {SetIndexStyle(t1,DRAW_NONE); t1++;}

//----   
   SetIndexBuffer(0, bullishDivergence);
   SetIndexBuffer(1, bearishDivergence);
   SetIndexBuffer(2, rsi);  
   SetIndexBuffer(3, divergencesType);   
   SetIndexBuffer(4, divergencesRSIDiff);   
   SetIndexBuffer(5, divergencesPriceDiff);   
//----   
   SetIndexArrow(0,LongArrowCode);
   SetIndexArrow(1,ShortArrowCode);
//----
   indicatorName=StringConcatenate("RSI Divergence (",RSI_period,", ",RSI_applied_price,")");
   SetIndexDrawBegin(3,RSI_period);
   IndicatorDigits(Digits() + 2);
   IndicatorShortName(indicatorName);

RSILine="RSIDiv RSI "; PriceLine="RSIDiv Price ";
}

void OnDeinit(const int reason) {if (!IsTesting()) {RemoveObjects("RSIDiv ");}}

int start()
{
   int countedBars = IndicatorCounted();
   if (countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);   
   return(0);
}



void CalculateIndicator(int countedBars)
{
    for(int i = Bars - countedBars; i >= 0; i--)
    {
        CalculateRSI(i);
        CatchBullishDivergence(i + 2);
        CatchBearishDivergence(i + 2);
    }              
}



void CalculateRSI(int x1)
{
    rsi[x1] = iRSI(Symbol(),PERIOD_CURRENT,RSI_period,RSI_applied_price,x1);             
}



void CatchBullishDivergence(int shift)
{int t4;
datetime h1,h2;
string s7;

    if(IsIndicatorTrough(shift) == false)
        return;  
        
    int currentTrough = shift;
    int lastTrough = GetIndicatorLastTrough(shift);

    //--CLASSIC DIVERGENCE--//
    if (DisplayClassicalDivergences)
    {
        if(rsi[currentTrough] > rsi[lastTrough] && Low[currentTrough] < Low[lastTrough])
        {
            bullishDivergence[currentTrough] = rsi[currentTrough] - arrowsDisplacement;
       
            divergencesType[currentTrough] = 1; //"Classic Bullish";
            divergencesRSIDiff[currentTrough] = MathAbs(rsi[currentTrough] - rsi[lastTrough]);
            divergencesPriceDiff[currentTrough] = MathAbs(Low[currentTrough] - Low[lastTrough]);
        
if (DrawPriceTrendLines) {h1=Time[currentTrough]; h2=Time[lastTrough]; s7=StringConcatenate(PriceLine,h1," ",h2); t4=0;
DrawTrendLine(s7,t4,h1,Low[currentTrough],h2,Low[lastTrough],LongColour,STYLE_SOLID,1);}            
                
if (DrawIndicatorTrendLines) {h1=Time[currentTrough]; h2=Time[lastTrough]; s7=StringConcatenate(RSILine,h1," ",h2); t4=ChartWindowFind(0,indicatorName);
DrawTrendLine(s7,t4,h1,rsi[currentTrough],h2,rsi[lastTrough],LongColour,STYLE_SOLID,1);}
                                      
       
            if(DisplayAlert)
                DisplayAlert("Classical RSI bullish divergence on: ", currentTrough);  
        }
    }
   //-----HIDDEN DIVERGENCE--//
   if (DisplayHiddenDivergences)
   {
       if (rsi[currentTrough] < rsi[lastTrough] && Low[currentTrough] > Low[lastTrough])
       {
           bullishDivergence[currentTrough] = rsi[currentTrough] - arrowsDisplacement;
           
           divergencesType[currentTrough] = 2; //"Hidden Bullish";
           divergencesRSIDiff[currentTrough] = MathAbs(rsi[currentTrough] - rsi[lastTrough]);
           divergencesPriceDiff[currentTrough] = MathAbs(Low[currentTrough] - Low[lastTrough]);
               
if (DrawPriceTrendLines) {h1=Time[currentTrough]; h2=Time[lastTrough]; s7=StringConcatenate(PriceLine,h1," ",h2); t4=0;
DrawTrendLine(s7,t4,h1,Low[currentTrough],h2,Low[lastTrough],LongColour,STYLE_DOT,1);}           

if (DrawIndicatorTrendLines) {h1=Time[currentTrough]; h2=Time[lastTrough]; s7=StringConcatenate(RSILine,h1," ",h2); t4=ChartWindowFind(0,indicatorName);
DrawTrendLine(s7,t4,h1,rsi[currentTrough],h2,rsi[lastTrough],LongColour,STYLE_DOT,1);}                                       

           if(DisplayAlert)
               DisplayAlert("Hidden RSI bullish divergence on: ", currentTrough);   
        } 
    }     
}



void CatchBearishDivergence(int shift)
{int t4;
datetime h1,h2;
string s7;

    if(IsIndicatorPeak(shift) == false)
        return;
    int currentPeak = shift;
    int lastPeak = GetIndicatorLastPeak(shift);

    //-- CLASSIC DIVERGENCE --//
    if (DisplayClassicalDivergences)
    {
        if(rsi[currentPeak] < rsi[lastPeak] && High[currentPeak] > High[lastPeak])
        {
            bearishDivergence[currentPeak] = rsi[currentPeak] + arrowsDisplacement;
        
            divergencesType[currentPeak] = 3; //"Classic Bearish";
            divergencesRSIDiff[currentPeak] = MathAbs(rsi[currentPeak] - rsi[lastPeak]);
            divergencesPriceDiff[currentPeak] = MathAbs(Low[currentPeak] - Low[lastPeak]);
      
if (DrawPriceTrendLines) {h1=Time[currentPeak]; h2=Time[lastPeak]; s7=StringConcatenate(PriceLine,h1," ",h2); t4=0;
DrawTrendLine(s7,t4,h1,High[currentPeak],h2,High[lastPeak],ShortColour,STYLE_SOLID,1);}            

                            
if (DrawIndicatorTrendLines) {h1=Time[currentPeak]; h2=Time[lastPeak]; s7=StringConcatenate(RSILine,h1," ",h2); t4=ChartWindowFind(0,indicatorName);
DrawTrendLine(s7,t4,h1,rsi[currentPeak],h2,rsi[lastPeak],ShortColour,STYLE_SOLID,1);}              

           if(DisplayAlert)
               DisplayAlert("Classical RSI bearish divergence on: ", currentPeak);  
         }
     }
     
     //----HIDDEN DIVERGENCE----//
     if (DisplayHiddenDivergences)
     {
         if(rsi[currentPeak] > rsi[lastPeak] && High[currentPeak] < High[lastPeak])
         {
              bearishDivergence[currentPeak] = rsi[currentPeak] + arrowsDisplacement;
              
              divergencesType[currentPeak] = 4;//"Hidden Bearish";
              divergencesRSIDiff[currentPeak] = MathAbs(rsi[currentPeak] - rsi[lastPeak]);
              divergencesPriceDiff[currentPeak] = MathAbs(Low[currentPeak] - Low[lastPeak]);
        
if (DrawPriceTrendLines) {h1=Time[currentPeak]; h2=Time[lastPeak]; s7=StringConcatenate(PriceLine,h1," ",h2); t4=0;
DrawTrendLine(s7,t4,h1,High[currentPeak],h2,High[lastPeak],ShortColour,STYLE_DOT,1);}              

if (DrawIndicatorTrendLines) {h1=Time[currentPeak]; h2=Time[lastPeak]; s7=StringConcatenate(RSILine,h1," ",h2); t4=ChartWindowFind(0,indicatorName);
DrawTrendLine(s7,t4,h1,rsi[currentPeak],h2,rsi[lastPeak],ShortColour,STYLE_DOT,1);}              
   
              if(DisplayAlert)
                  DisplayAlert("Hidden RSI bearish divergence on: ", currentPeak);   
         }   
     }
}



bool IsIndicatorPeak(int shift)
{
    if(rsi[shift] >= rsi[shift+1] && rsi[shift] > rsi[shift+2] && rsi[shift] > rsi[shift-1])
        return(true);
    else 
        return(false);
}



bool IsIndicatorTrough(int shift)
{
    if(rsi[shift] <= rsi[shift+1] && rsi[shift] < rsi[shift+2] && rsi[shift] < rsi[shift-1])
        return(true);
    else 
        return(false);
}



int GetIndicatorLastPeak(int shift)
{
    for(int j = shift + 5; j < Bars; j++)
    {
        if(rsi[j] >= rsi[j+1] && rsi[j] > rsi[j+2] &&
           rsi[j] >= rsi[j-1] && rsi[j] > rsi[j-2])
            return(j);
    }
    return(-1);
}



int GetIndicatorLastTrough(int shift)
{
    for(int j = shift + 5; j < Bars; j++)
    {
        if(rsi[j] <= rsi[j+1] && rsi[j] < rsi[j+2] &&
           rsi[j] <= rsi[j-1] && rsi[j] < rsi[j-2])
            return(j);
    }
    return(-1);
}



void DisplayAlert(string message, int shift)
{
    if(shift <= 2 && Time[shift] != lastAlertTime)
    {
        lastAlertTime = Time[shift];
        Alert(message, Symbol(), " , ", Period(), " minutes chart");
    }
}

void DrawTrendLine(string r6,int x1,datetime x6,double f6,datetime x7,double f7,color x3,int x4,int x5)
{if (x6==0 && x7==0 && ObjectFind(0,r6)!=-1) {ObjectDelete(0,r6);}
if (x6>0 || x7>0) {if (ObjectFind(0,r6)==-1) {ObjectCreate(0,r6,OBJ_TREND,x1,0,0,0,0); ObjectSetInteger(0,r6,OBJPROP_RAY,false);} 
ObjectSetInteger(0,r6,OBJPROP_TIME,x6); ObjectSetInteger(0,r6,OBJPROP_TIME,1,x7); ObjectSetDouble(0,r6,OBJPROP_PRICE,f6); ObjectSetDouble(0,r6,OBJPROP_PRICE,1,f7); 
ObjectSetInteger(0,r6,OBJPROP_COLOR,x3); ObjectSetInteger(0,r6,OBJPROP_STYLE,x4); ObjectSetInteger(0,r6,OBJPROP_WIDTH,x5);}}

void RemoveObjects(string r6)
{int t1;

t1=ObjectsTotal(); while(t1>=0) {if (StringFind(ObjectName(t1),r6,0)!=-1) {ObjectDelete(0,ObjectName(t1));} t1--;}}

