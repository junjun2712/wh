//+-------------------------------------------------------------------------------------+
//|                                                                    FiboFractals.mq4 |
//|                                                                           Scriptong |
//|                                                                   scriptong@mail.ru |
//+-------------------------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "scriptong@mail.ru"


//---- input parameters
extern double    Lots = 0.1;
extern string    A1 = "��������� Stochastic";
extern int       KPeriod = 5;
extern int       DPeriod = 5;
extern int       Slowing = 3;
extern string    A2 = "==================================";

extern double    HighLevel = 80;
extern double    LowLevel = 20;
extern string    A3 = "������� ����� �� ����";
extern double    FiboOpen = 123.6;
extern string    A4 = "==================================";
extern string    A5 = "������� ������ �� ����";
extern double    FiboProfit = 261.8;
extern string    A6 = "==================================";
extern string    A7 = "������� ����� �� ����";
extern double    FiboStop = 1000;
extern string    A8 = "==================================";
extern string    A9 = "����� ������ �� ����-�����";
extern color     FiboUpColor = Yellow;
extern color     FiboDnColor = Violet;
extern string    A10 = "==================================";
extern string    A11 = "������������ ���������� �������, �������� � ���� �������";
extern int       MaxOrders = 5;
extern string    A12 = "==================================";
extern string    OpenOrderSound = "ok.wav";
extern int       MagicNumber = 10012;   // ��� ����� �������� �� 100, � ������� ������� -
                                                    // ���������� ����� ������ � ��������

bool Activate, FreeMarginAlert, FatalError, IsPendings;
double Tick, Spread, StopLevel, FreezeLevel, MinLot, MaxLot, LotStep, FiboOpenL, 
       FiboStopL, FiboProfitL, UpOpen, UpTarget, UpStop, DnOpen, DnTarget, DnStop;
int Signal, LUpN, LDnN, Count;
datetime LastBar = 0;

//+-------------------------------------------------------------------------------------+
//| expert initialization function                                                      |
//+-------------------------------------------------------------------------------------+
int init()
  {
   FatalError = False;
   Activate = False;
// - 1 - == ���� ���������� �� �������� �������� ========================================   
   Tick = MarketInfo(Symbol(), MODE_TICKSIZE);                         // ����������� ���    
   Spread = ND(MarketInfo(Symbol(), MODE_SPREAD)*Point);                 // ������� �����
   StopLevel = ND(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point);  // ������� ������� ������ 
   FreezeLevel = ND(MarketInfo(Symbol(), MODE_FREEZELEVEL)*Point);   // ������� ���������
   MinLot = MarketInfo(Symbol(), MODE_MINLOT);    // ����������� ����������� ����� ������
   MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);   // ������������ ����������� ����� ������
   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);          // ��� ���������� ������ ������
// - 1 - == ��������� ����� =============================================================

// - 2 - == ���������� ������ ������ � ����������� � �������� ������������ ������ =======   
   Lots = LotRound(Lots);                  // ���������� ������ �� ���������� �����������
// - 2 - == ��������� ����� =============================================================
   
// - 3 - ====================== �������� ������������ ������� ���������� ================
   if (FiboOpen < 100)
     {
      Comment("�������� FiboOpen ������ ���� ������ 100. �������� ��������!");
      Print("�������� FiboOpen ������ ���� ������ 100. �������� ��������!");
      return(0);
     }
   if (FiboProfit <= FiboOpen)
     {
      Comment("�������� FiboProfit ������ ���� ������, ��� FiboOpen. �������� ��������!");
      Print("�������� FiboProfit ������ ���� ������, ��� FiboOpen. �������� ��������!");
      return(0);
     }
   if (FiboStop < 100)
     {
      Comment("�������� FiboStop ������ ���� ������ 100. �������� ��������!");
      Print("�������� FiboStop ������ ���� ������ 100. �������� ��������!");
      return(0);
     }
   if (MaxOrders < 1 || MaxOrders > 99)
     {
      Comment("�������� MaxOrders ������ ���� �� 1 �� 100. �������� ��������!");
      Print("�������� MaxOrders ������ ���� �� 1 �� 100. �������� ��������!");
      return(0);
     }
// - 3 - =============================== ��������� ����� ================================
   
// - 4 - ====================== ������������� ���������� ================================
   FiboStopL = -(FiboStop-100)/100;
   FiboOpenL = FiboOpen/100;
   FiboProfitL = FiboProfit/100;
// - 4 - =============================== ��������� ����� ================================
    
   Activate = True;
   
//----
   return(0);
  }
//+-------------------------------------------------------------------------------------+
//| expert deinitialization function                                                    |
//+-------------------------------------------------------------------------------------+
int deinit()
  {
//----
   if (ObjectFind("FiFr_Up") == 0)
      ObjectDelete("FiFr_Up");
   if (ObjectFind("FiFr_Dn") == 0)
      ObjectDelete("FiFr_Dn");
   Comment("");
//----
   return(0);
  }
  
//+-------------------------------------------------------------------------------------+
//| ���������� �������� � �������� ������ ������                                        |
//+-------------------------------------------------------------------------------------+
double ND(double A)
{
 return(NormalizeDouble(A, Digits));
}    
  
//+-------------------------------------------------------------------------------------+
//| ���������� �������� � �������� ������ ����                                          |
//+-------------------------------------------------------------------------------------+
double NP(double A)
{
 return(MathRound(A/Tick)*Tick);
}  

//+-------------------------------------------------------------------------------------+
//| ����������� ��������� �� ������                                                     |
//+-------------------------------------------------------------------------------------+
string ErrorToString(int Error)
{
 switch(Error)
   {
    case 2: return("������������� ����� ������, ���������� � ������������."); 
    case 5: return("� ��� ������ ������ ���������, �������� ��."); 
    case 6: return("��� ����� � ��������, ���������� ������������� ��������."); 
    case 64: return("���� ������������, ���������� � ������������.");
    case 132: return("����� ������."); 
    case 133: return("�������� ���������."); 
    case 149: return("��������� �����������."); 
   }
}

//+-------------------------------------------------------------------------------------+
//| �������� ��������� ������. ���� ����� ��������, �� ��������� True, ����� - False    |
//+-------------------------------------------------------------------------------------+  
bool WaitForTradeContext()
{
 int P = 0;
 // ���� "����"
 while(IsTradeContextBusy() && P < 5)
   {
    P++;
    Sleep(1000);
   }
 // -------------  
 if(P == 5)
   return(False);
 return(True);    
}
  
//+-------------------------------------------------------------------------------------+
//| "����������" �������� �������                                                       |
//| � ������� �� OpenOrder ��������� ����������� ������� ������� � ���������������      |
//| ����������:                                                                         |
//|   0 - ��� ������                                                                    |
//|   1 - ������ ��������                                                               |
//|   2 - ������ �������� Price                                                         |
//|   3 - ������ �������� SL                                                            |
//|   4 - ������ �������� TP                                                            |
//|   5 - ������ �������� Lot                                                           |
//+-------------------------------------------------------------------------------------+
int OpenOrderCorrect(int Type, double Price, double SL, double TP, int Num,
                     bool Redefinition = True)
// Redefinition - ��� True ������������ ��������� �� ���������� ����������
//                ��� False - ���������� ������
{
// - 1 - == �������� ������������� ��������� ������� ====================================
 if(AccountFreeMarginCheck(Symbol(), OP_BUY, Lots) <= 0 || GetLastError() == 134) 
  {
   if(!FreeMarginAlert)
    {
     Print("������������ ������� ��� �������� �������. Free Margin = ", 
           AccountFreeMargin());
     FreeMarginAlert = True;
    } 
   return(5);  
  }
 FreeMarginAlert = False;  
// - 1 - == ��������� ����� =============================================================

// - 2 - == ������������� �������� Price, SL � TP ��� ������� ������ ====================   

 RefreshRates();
 switch (Type)
   {
    case OP_BUY: 
                string S = "BUY"; 
                if (MathAbs(Price-Ask)/Point > 3)
                  if (Redefinition) Price = ND(Ask);
                  else              return(2);
                if (ND(TP-Bid) < StopLevel && TP != 0)
                  if (Redefinition) TP = ND(Bid+StopLevel);
                  else              return(4);
                if (ND(Bid-SL) < StopLevel)
                  if (Redefinition) SL = ND(Bid-StopLevel);
                  else              return(3);
                break;
    case OP_SELL: 
                 S = "SELL"; 
                 if (MathAbs(Price-Bid)/Point > 3)
                   if (Redefinition) Price = ND(Bid);
                   else              return(2);
                 if (ND(Ask-TP) < StopLevel) 
                   if (Redefinition) TP = ND(Ask-StopLevel);
                   else              return(4);
                 if (ND(SL-Ask) < StopLevel && SL != 0)
                   if (Redefinition) SL = ND(Ask+StopLevel);
                   else              return(3);
                 break;
    case OP_BUYSTOP: 
                    S = "BUYSTOP";
                    if (ND(Price-Ask) < StopLevel)
                      if (Redefinition) Price = ND(Ask+StopLevel);
                      else              return(2);
                    if (ND(TP-Price) < StopLevel && TP != 0)
                      if (Redefinition) TP = ND(Price+StopLevel);
                      else              return(4);
                    if (ND(Price-SL) < StopLevel)
                      if (Redefinition) SL = ND(Price-StopLevel);
                      else              return(3);
                    break;
    case OP_SELLSTOP: 
                     S = "SELLSTOP";
                     if (ND(Bid-Price) < StopLevel)
                       if (Redefinition) Price = ND(Bid-StopLevel);
                       else              return(2);
                     if (ND(Price-TP) < StopLevel)
                       if (Redefinition) TP = ND(Price-StopLevel);
                       else              return(4);
                     if (ND(SL-Price) < StopLevel && SL != 0)
                       if (Redefinition) SL = ND(Price+StopLevel);
                       else              return(3);
                     break;
    case OP_BUYLIMIT: 
                     S = "BUYLIMIT";
                     if (ND(Ask-Price) < StopLevel)
                      if (Redefinition) Price = ND(Ask-StopLevel);
                      else              return(2);
                     if (ND(TP-Price) < StopLevel && TP != 0)
                       if (Redefinition) TP = ND(Price+StopLevel);
                       else              return(4);
                     if (ND(Price-SL) < StopLevel)
                       if (Redefinition) SL = ND(Price-StopLevel);
                       else              return(3);
                     break;
    case OP_SELLLIMIT: 
                     S = "SELLLIMIT";
                     if (ND(Price - Bid) < StopLevel) 
                       if (Redefinition) Price = ND(Bid+StopLevel);
                       else              return(2);
                     if (ND(Price-TP) < StopLevel)
                       if (Redefinition) TP = ND(Price-StopLevel);
                       else              return(4);
                     if (ND(SL-Price) < StopLevel && SL != 0)
                       if (Redefinition) SL = ND(Price+StopLevel);
                       else              return(3);
                     break;
   }
// - 2 - == ��������� ����� =============================================================
 
 int MN = MagicNumber*100 + Num;
 
// - 3 - == �������� ������ � �������� ��������� ������ =================================   
 if(WaitForTradeContext())  // �������� ������������ ��������� ������
   {  
    Comment("��������� ������ �� �������� ������ ", S, " ...");  
    int ticket=OrderSend(Symbol(), Type, Lots, Price, 3, 
               SL, TP, NULL, MN, 0);// �������� �������
    // ������� �������� ������� ����������� ��������
    if(ticket<0)
      {
       int Error = GetLastError();
       if(Error == 2 || Error == 5 || Error == 6 || Error == 64 
          || Error == 132 || Error == 133 || Error == 149)     // ������ ��������� ������
         {
          Comment("��������� ������ ��� �������� ������� �. �. "+
                   ErrorToString(Error)+" �������� ��������!");
          FatalError = True;
         }
        else 
         Comment("������ �������� ������� ", S, ": ", Error);       // ����������� ������
       return(1);
      }
    // ---------------------------------------------
    
    // ������� �������� �������   
    Comment("������� ", S, " ������� �������!"); 
    PlaySound(OpenOrderSound); 
    return(0); 
    // ------------------------
   }
  else
   {
    Comment("����� �������� ������������ ��������� ������ �������!");
    return(1);  
   } 
// - 3 - == ��������� ����� =============================================================
   
}

//+-------------------------------------------------------------------------------------+
//| ����������� ����-�������                                                            |
//+-------------------------------------------------------------------------------------+
void ShowFibo(bool Up, double HighL, double LowL, datetime TimeL)
{
// - 1 - ========== ����� ����� ������� � ��� �����, � ����������� �� ����������� =======
 if (Up) 
   {
    string name = "FiFr_Up";
    color Color = FiboUpColor;
   } 
 else
  {
   name = "FiFr_Dn"; 
   Color = FiboDnColor;
  } 
// - 1 - ================================ ��������� �����  ==============================
  
// - 2 - ========== ���������� ������ ������� "����� ���������" =========================
 if (ObjectFind(name) < 0)
   {
    ObjectCreate(name, OBJ_FIBO, 0, TimeL, LowL, TimeL, HighL);
    ObjectSet(name, OBJPROP_COLOR, CLR_NONE);            // ������ ����� �������� �������
    ObjectSet(name, OBJPROP_LEVELCOLOR, Color);          // ��������� ����� ����� �������
    ObjectSet(name, OBJPROP_LEVELSTYLE, STYLE_DOT);            // ����� ������� ���������
    ObjectSet(name, OBJPROP_FIBOLEVELS, 5);                         // ���������� �������
    ObjectSet(name, OBJPROP_FIRSTLEVEL, FiboStopL);                      // ������� ����� 
    ObjectSet(name, OBJPROP_FIRSTLEVEL+1, 0);                      // ����������� �������
    ObjectSet(name, OBJPROP_FIRSTLEVEL+2, 1);                     // ������������ ������� 
    ObjectSet(name, OBJPROP_FIRSTLEVEL+3, FiboOpenL);                 // ������� ��������
    ObjectSet(name, OBJPROP_FIRSTLEVEL+4, FiboProfitL);                   // ������� ����
    ObjectSetFiboDescription(name, 0, "Stop Level (%$)");
    ObjectSetFiboDescription(name, 1, "0.0% (%$)");
    ObjectSetFiboDescription(name, 2, "100.0% (%$)");
    ObjectSetFiboDescription(name, 3, "Signal Level (%$)");
    ObjectSetFiboDescription(name, 4, "Target Level (%$)");
   }
  else
   {
    ObjectMove(name, 1, TimeL, HighL);
    ObjectMove(name, 0, TimeL, LowL);
   } 
// - 2 - ================================ ��������� �����  ==============================
}

//+-------------------------------------------------------------------------------------+
//| ���������� ���� ��������� ��������� (�������� � �������)                            |
//+-------------------------------------------------------------------------------------+
bool FindPairFractals()
{
 LUpN = 0;
 LDnN = 0;
 for (int i = 3; i < Bars && (LUpN == 0 || LDnN == 0); i++)
   {
    if (LUpN == 0)
      {
       double Up = iFractals(Symbol(), 0, MODE_UPPER, i);
       if (Up != 0)
         LUpN = i;
      }    
    if (LDnN == 0)
      {
       double Dn = iFractals(Symbol(), 0, MODE_LOWER, i);
       if (Dn != 0)
         LDnN = i;
      }    
   }
 if (i < Bars) return(True);
 
 return(False);  
}


//+-------------------------------------------------------------------------------------+
//| ������ �������� ���� � ������������ �������� �������� �������                       |
//+-------------------------------------------------------------------------------------+
void GetSignal()
{
 Signal = 0;
// - 1 - ====================== ������ ������� �1 (����������� ������ ����)==============
 if (!FindPairFractals()) return(0);// ���������� ��������� �������������� ���� ���������
 ShowFibo(true, Low[LUpN], High[LUpN], Time[LUpN]);       // ����������� ����� ���� �����
 ShowFibo(False, High[LDnN], Low[LDnN], Time[LDnN]);       // ����������� ����� ���� ����
 UpOpen = Low[LUpN] + (High[LUpN] - Low[LUpN])*FiboOpenL;    // ������ ������ ����� �����
 UpTarget = Low[LUpN] + (High[LUpN] - Low[LUpN])*FiboProfitL;//������ ������ ������� ����
 UpStop = Low[LUpN] + (High[LUpN] - Low[LUpN])*FiboStopL;  // ������ ������ ����� ��� BUY
 DnOpen = High[LDnN] - (High[LDnN] - Low[LDnN])*FiboOpenL;    // ������ ������ ����� ����
 DnTarget = High[LDnN] - (High[LDnN] - Low[LDnN])*FiboProfitL;//������ ������ ������ ����
 DnStop = High[LDnN] - (High[LDnN] - Low[LDnN])*FiboStopL;// ������ ������ ����� ��� SELL
// - 1 - ======================= ��������� ����� ========================================

// - 2 - ====================== ������ ������� �2 =======================================
 double SMUp = iStochastic(Symbol(), 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 0, 
                           MODE_MAIN, LUpN);
 double SMDn = iStochastic(Symbol(), 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 0, 
                           MODE_MAIN, LDnN);
// - 2 - ======================= ��������� ����� ========================================
 
// - 3 - == ��������� ������� BUY =======================================================
 if (SMUp < HighLevel)                                   // ����� ������������ ������ BUY
   if (Close[1] >= UpOpen && Close[2] < UpOpen)     // ������ ����������� ������ ��������
     if (Low[iLowest(NULL, 0, MODE_LOW, LUpN)] > UpStop)         // ���� �� ��� ���������
       if (High[iHighest(NULL, 0, MODE_HIGH, LUpN)] < UpTarget)// �� ��� ��������� ������
         Signal = 1;                                                        // ������ BUY
// - 3 - == ��������� ����� =============================================================

// - 4 - == ��������� ������� SELL ======================================================
 if (SMDn > LowLevel)                                   // ����� ������������ ������ SELL
   if (Close[1] <= DnOpen && Close[2] > DnOpen)     // ������ ����������� ������ ��������
     if (Low[iLowest(NULL, 0, MODE_LOW, LDnN)] > DnTarget)     // ������ �� ��� ���������
       if (High[iHighest(NULL, 0, MODE_HIGH, LDnN)] < DnStop)    // �� ��� ��������� ����
         Signal = -1;                                                      // ������ SELL
// - 4 - == ��������� ����� =============================================================
}

//+-------------------------------------------------------------------------------------+
//| �������� ������ �� ������������ � ����������                                        |
//+-------------------------------------------------------------------------------------+
double LotRound(double L)
{
 return(MathRound(MathMin(MathMax(L, MinLot), MaxLot)/LotStep)*LotStep);
}

//+-------------------------------------------------------------------------------------+
//| ��������� ������� ���� Type � ������������ ���������� ������� ���������������� ����.|
//| ���� ������� �� �������, �� False, ����� True.                                      |
//+-------------------------------------------------------------------------------------+
bool CheckOrders(int Type, datetime FrTime)
{
 Count = 0;
 for (int i = OrdersTotal()-1; i >= 0; i--)
   if (OrderSelect(i, SELECT_BY_POS))
     if (OrderSymbol() == Symbol() && MathFloor(OrderMagicNumber()/100) == MagicNumber)
       if (OrderType() == Type)         // ������� ��������� �������, �������� ������� ��
         {
          if (WaitForTradeContext())  
            {
             if (OrderType() == OP_BUY)
               double Pr = ND(MarketInfo(Symbol(), MODE_BID));
              else
               Pr = ND(MarketInfo(Symbol(), MODE_ASK));
             if (!OrderClose(OrderTicket(), OrderLots(), Pr, 3))        
               return(False);
            }   
         }
        else  // ������� ��������������� ��������� �������. ����������� �������� ��������
         {
          if (OrderOpenTime() > FrTime+Period()*180) // ���� ��������� ������� ������� ��
            return(False);              // ���� �� �������, �� ����� ������� �� ���������
          Count++; 
         } 
 if (Count >= MaxOrders) // �� ��������� ��������� �������������� ������� � �� �� �������
   return(False);                                         // ��� ���������� �� ����������

 return(True);
}

//+-------------------------------------------------------------------------------------+
//| �������� � �������� �������                                                         |
//+-------------------------------------------------------------------------------------+
bool Trades()
{
// - 1 - =================== ��������� ������� �������� ������� ������� =================
 if (Signal > 0)
   if (CheckOrders(OP_SELL, Time[LUpN]))             // ����� �� ������� ��� ���� �������
     if (OpenOrderCorrect(OP_BUY, NP(Ask), UpStop, UpTarget, Count) != 0)
       return(False);
   
// - 1 - ============================== ��������� ����� =================================
       
// - 2 - ================== ��������� ������� �������� �������� ������� =================
 if (Signal < 0)
   if (CheckOrders(OP_BUY, Time[LDnN]))              // ����� �� ������� ��� ���� �������
     if (OpenOrderCorrect(OP_SELL, NP(Bid),DnStop + Spread, DnTarget+Spread, Count) != 0)
       return(False);
// - 2 - ============================== ��������� ����� =================================
           
 return(True);
}

//+-------------------------------------------------------------------------------------+
//| ������� START ��������                                                              |
//+-------------------------------------------------------------------------------------+
int start()
  {
// - 1 -  == ��������� �� ��������� ��������? ===========================================
   if (!Activate || FatalError)             // ����������� ������ ���������, ���� �������
    return(0);           //  init ����������� � �������  ��� ����� ����� ��������� ������
// - 1 -  == ��������� ����� ============================================================
     
// - 2 - == ���� ���������� �� �������� �������� ========================================
   Spread = ND(MarketInfo(Symbol(), MODE_SPREAD)*Point);                  // ������ �����
   StopLevel = ND(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point);  // ������� ������� ������ 
   FreezeLevel = ND(MarketInfo(Symbol(), MODE_FREEZELEVEL)*Point);   // ������� ���������
// - 2 -  == ��������� ����� ============================================================

// - 3 - =========================== �������� �������� ������ ���� ======================
   if (LastBar == Time[0])
     return(0);
// - 3 -  == ��������� ����� ============================================================

// - 4 - ======================== ������ ������� ========================================
   GetSignal();
// - 4 -  == ��������� ����� ============================================================

// - 5 - == �������� ������� ============================================================
   if (Signal != 0)
     if (!Trades())                                          // ��������/�������� ������
       return(0);
// - 5 -  == ��������� ����� ============================================================

   LastBar = Time[0];

   return(0);
  }
