//+-------------------------------------------------------------------------------------+
//|                                                                    FiboFractals.mq4 |
//|                                                                           Scriptong |
//|                                                                   scriptong@mail.ru |
//+-------------------------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "scriptong@mail.ru"


//---- input parameters
extern double    Lots = 0.1;
extern string    A1 = "Параметры Stochastic";
extern int       KPeriod = 5;
extern int       DPeriod = 5;
extern int       Slowing = 3;
extern string    A2 = "==================================";

extern double    HighLevel = 80;
extern double    LowLevel = 20;
extern string    A3 = "Уровень входа по Фибо";
extern double    FiboOpen = 123.6;
extern string    A4 = "==================================";
extern string    A5 = "Уровень выхода по Фибо";
extern double    FiboProfit = 261.8;
extern string    A6 = "==================================";
extern string    A7 = "Уровень стопа по Фибо";
extern double    FiboStop = 1000;
extern string    A8 = "==================================";
extern string    A9 = "Цвета каждой из Фибо-сеток";
extern color     FiboUpColor = Yellow;
extern color     FiboDnColor = Violet;
extern string    A10 = "==================================";
extern string    A11 = "Максимальное количество позиций, открытых в одну сторону";
extern int       MaxOrders = 5;
extern string    A12 = "==================================";
extern string    OpenOrderSound = "ok.wav";
extern int       MagicNumber = 10012;   // Сам магик умножаем на 100, в младшем разряде -
                                                    // порядковый номер ордера в пирамиде

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
// - 1 - == Сбор информации об условиях торговли ========================================   
   Tick = MarketInfo(Symbol(), MODE_TICKSIZE);                         // минимальный тик    
   Spread = ND(MarketInfo(Symbol(), MODE_SPREAD)*Point);                 // текущий спрэд
   StopLevel = ND(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point);  // текущий уровень стопов 
   FreezeLevel = ND(MarketInfo(Symbol(), MODE_FREEZELEVEL)*Point);   // уровень заморозки
   MinLot = MarketInfo(Symbol(), MODE_MINLOT);    // минимальный разрешенный объем сделки
   MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);   // максимальный разрешенный объем сделки
   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);          // шаг приращения объема сделки
// - 1 - == Окончание блока =============================================================

// - 2 - == Приведение объема сделки к допустимому и проверка корректности объема =======   
   Lots = LotRound(Lots);                  // округление объема до ближайшего допустимого
// - 2 - == Окончание блока =============================================================
   
// - 3 - ====================== Проверка корректности входных параметров ================
   if (FiboOpen < 100)
     {
      Comment("Параметр FiboOpen должен быть больше 100. Советник отключен!");
      Print("Параметр FiboOpen должен быть больше 100. Советник отключен!");
      return(0);
     }
   if (FiboProfit <= FiboOpen)
     {
      Comment("Параметр FiboProfit должен быть больше, чем FiboOpen. Советник отключен!");
      Print("Параметр FiboProfit должен быть больше, чем FiboOpen. Советник отключен!");
      return(0);
     }
   if (FiboStop < 100)
     {
      Comment("Параметр FiboStop должен быть больше 100. Советник отключен!");
      Print("Параметр FiboStop должен быть больше 100. Советник отключен!");
      return(0);
     }
   if (MaxOrders < 1 || MaxOrders > 99)
     {
      Comment("Параметр MaxOrders должен быть от 1 до 100. Советник отключен!");
      Print("Параметр MaxOrders должен быть от 1 до 100. Советник отключен!");
      return(0);
     }
// - 3 - =============================== Окончание блока ================================
   
// - 4 - ====================== Инициализация переменных ================================
   FiboStopL = -(FiboStop-100)/100;
   FiboOpenL = FiboOpen/100;
   FiboProfitL = FiboProfit/100;
// - 4 - =============================== Окончание блока ================================
    
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
//| Приведение значений к точности одного пункта                                        |
//+-------------------------------------------------------------------------------------+
double ND(double A)
{
 return(NormalizeDouble(A, Digits));
}    
  
//+-------------------------------------------------------------------------------------+
//| Приведение значений к точности одного тика                                          |
//+-------------------------------------------------------------------------------------+
double NP(double A)
{
 return(MathRound(A/Tick)*Tick);
}  

//+-------------------------------------------------------------------------------------+
//| Расшифровка сообщения об ошибке                                                     |
//+-------------------------------------------------------------------------------------+
string ErrorToString(int Error)
{
 switch(Error)
   {
    case 2: return("зафиксирована общая ошибка, обратитесь в техподдержку."); 
    case 5: return("у вас старая версия терминала, обновите ее."); 
    case 6: return("нет связи с сервером, попробуйте перезагрузить терминал."); 
    case 64: return("счет заблокирован, обратитесь в техподдержку.");
    case 132: return("рынок закрыт."); 
    case 133: return("торговля запрещена."); 
    case 149: return("запрещено локирование."); 
   }
}

//+-------------------------------------------------------------------------------------+
//| Ожидание торгового потока. Если поток свободен, то результат True, иначе - False    |
//+-------------------------------------------------------------------------------------+  
bool WaitForTradeContext()
{
 int P = 0;
 // цикл "пока"
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
//| "Правильное" открытие позиции                                                       |
//| В отличие от OpenOrder проверяет соотношение текущих уровней и устанавливаемых      |
//| Возвращает:                                                                         |
//|   0 - нет ошибок                                                                    |
//|   1 - Ошибка открытия                                                               |
//|   2 - Ошибка значения Price                                                         |
//|   3 - Ошибка значения SL                                                            |
//|   4 - Ошибка значения TP                                                            |
//|   5 - Ошибка значения Lot                                                           |
//+-------------------------------------------------------------------------------------+
int OpenOrderCorrect(int Type, double Price, double SL, double TP, int Num,
                     bool Redefinition = True)
// Redefinition - при True доопределять параметры до минимально допустимых
//                при False - возвращать ошибку
{
// - 1 - == Проверка достаточности свободных средств ====================================
 if(AccountFreeMarginCheck(Symbol(), OP_BUY, Lots) <= 0 || GetLastError() == 134) 
  {
   if(!FreeMarginAlert)
    {
     Print("Недостаточно средств для открытия позиции. Free Margin = ", 
           AccountFreeMargin());
     FreeMarginAlert = True;
    } 
   return(5);  
  }
 FreeMarginAlert = False;  
// - 1 - == Окончание блока =============================================================

// - 2 - == Корректировка значений Price, SL и TP или возврат ошибки ====================   

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
// - 2 - == Окончание блока =============================================================
 
 int MN = MagicNumber*100 + Num;
 
// - 3 - == Открытие ордера с ожидание торгового потока =================================   
 if(WaitForTradeContext())  // ожидание освобождения торгового потока
   {  
    Comment("Отправлен запрос на открытие ордера ", S, " ...");  
    int ticket=OrderSend(Symbol(), Type, Lots, Price, 3, 
               SL, TP, NULL, MN, 0);// открытие позиции
    // Попытка открытия позиции завершилась неудачей
    if(ticket<0)
      {
       int Error = GetLastError();
       if(Error == 2 || Error == 5 || Error == 6 || Error == 64 
          || Error == 132 || Error == 133 || Error == 149)     // список фатальных ошибок
         {
          Comment("Фатальная ошибка при открытии позиции т. к. "+
                   ErrorToString(Error)+" Советник отключен!");
          FatalError = True;
         }
        else 
         Comment("Ошибка открытия позиции ", S, ": ", Error);       // нефатальная ошибка
       return(1);
      }
    // ---------------------------------------------
    
    // Удачное открытие позиции   
    Comment("Позиция ", S, " открыта успешно!"); 
    PlaySound(OpenOrderSound); 
    return(0); 
    // ------------------------
   }
  else
   {
    Comment("Время ожидания освобождения торгового потока истекло!");
    return(1);  
   } 
// - 3 - == Окончание блока =============================================================
   
}

//+-------------------------------------------------------------------------------------+
//| Отображение Фибо-уровней                                                            |
//+-------------------------------------------------------------------------------------+
void ShowFibo(bool Up, double HighL, double LowL, datetime TimeL)
{
// - 1 - ========== Выбор имени объекта и его цвета, в зависимости от направления =======
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
// - 1 - ================================ Окончание блока  ==============================
  
// - 2 - ========== Построение одного объекта "линии Фибоначчи" =========================
 if (ObjectFind(name) < 0)
   {
    ObjectCreate(name, OBJ_FIBO, 0, TimeL, LowL, TimeL, HighL);
    ObjectSet(name, OBJPROP_COLOR, CLR_NONE);            // Прячем линию растяжки объекта
    ObjectSet(name, OBJPROP_LEVELCOLOR, Color);          // Установка цвета линий уровней
    ObjectSet(name, OBJPROP_LEVELSTYLE, STYLE_DOT);            // Линии выводим пунктиром
    ObjectSet(name, OBJPROP_FIBOLEVELS, 5);                         // Количество уровней
    ObjectSet(name, OBJPROP_FIRSTLEVEL, FiboStopL);                      // Уровень стопа 
    ObjectSet(name, OBJPROP_FIRSTLEVEL+1, 0);                      // Минимальный уровень
    ObjectSet(name, OBJPROP_FIRSTLEVEL+2, 1);                     // Максимальный уровень 
    ObjectSet(name, OBJPROP_FIRSTLEVEL+3, FiboOpenL);                 // Уровень открытия
    ObjectSet(name, OBJPROP_FIRSTLEVEL+4, FiboProfitL);                   // Уровень цели
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
// - 2 - ================================ Окончание блока  ==============================
}

//+-------------------------------------------------------------------------------------+
//| Нахождение двух последних фракталов (верхнего и нижнего)                            |
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
//| Расчет значений Фибо и формирование сигналов открытия позиций                       |
//+-------------------------------------------------------------------------------------+
void GetSignal()
{
 Signal = 0;
// - 1 - ====================== Расчет сигнала №1 (пересечение уровня Фибо)==============
 if (!FindPairFractals()) return(0);// Нахождение последней сформированной пары фракталов
 ShowFibo(true, Low[LUpN], High[LUpN], Time[LUpN]);       // Отображение линий Фибо вверх
 ShowFibo(False, High[LDnN], Low[LDnN], Time[LDnN]);       // Отображение линий Фибо вниз
 UpOpen = Low[LUpN] + (High[LUpN] - Low[LUpN])*FiboOpenL;    // Расчет уровня входа вверх
 UpTarget = Low[LUpN] + (High[LUpN] - Low[LUpN])*FiboProfitL;//Расчет уровня верхней цели
 UpStop = Low[LUpN] + (High[LUpN] - Low[LUpN])*FiboStopL;  // Расчет уровня стопа для BUY
 DnOpen = High[LDnN] - (High[LDnN] - Low[LDnN])*FiboOpenL;    // Расчет уровня входа вниз
 DnTarget = High[LDnN] - (High[LDnN] - Low[LDnN])*FiboProfitL;//Расчет уровня нижней цели
 DnStop = High[LDnN] - (High[LDnN] - Low[LDnN])*FiboStopL;// Расчет уровня стопа для SELL
// - 1 - ======================= Окончание блока ========================================

// - 2 - ====================== Расчет сигнала №2 =======================================
 double SMUp = iStochastic(Symbol(), 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 0, 
                           MODE_MAIN, LUpN);
 double SMDn = iStochastic(Symbol(), 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 0, 
                           MODE_MAIN, LDnN);
// - 2 - ======================= Окончание блока ========================================
 
// - 3 - == Генерация сигнала BUY =======================================================
 if (SMUp < HighLevel)                                   // можно генерировать сигнал BUY
   if (Close[1] >= UpOpen && Close[2] < UpOpen)     // момент пересечения уровня открытия
     if (Low[iLowest(NULL, 0, MODE_LOW, LUpN)] > UpStop)         // Стоп не был достигнут
       if (High[iHighest(NULL, 0, MODE_HIGH, LUpN)] < UpTarget)// Не был достигнут профит
         Signal = 1;                                                        // Сигнал BUY
// - 3 - == Окончание блока =============================================================

// - 4 - == Генерация сигнала SELL ======================================================
 if (SMDn > LowLevel)                                   // можно генерировать сигнал SELL
   if (Close[1] <= DnOpen && Close[2] > DnOpen)     // момент пересечения уровня открытия
     if (Low[iLowest(NULL, 0, MODE_LOW, LDnN)] > DnTarget)     // Профит не был достигнут
       if (High[iHighest(NULL, 0, MODE_HIGH, LDnN)] < DnStop)    // Не был достигнут стоп
         Signal = -1;                                                      // Сигнал SELL
// - 4 - == Окончание блока =============================================================
}

//+-------------------------------------------------------------------------------------+
//| Проверка объема на корректность и округление                                        |
//+-------------------------------------------------------------------------------------+
double LotRound(double L)
{
 return(MathRound(MathMin(MathMax(L, MinLot), MaxLot)/LotStep)*LotStep);
}

//+-------------------------------------------------------------------------------------+
//| Закрывает позиции типа Type и подсчитывает количество позиций противоположного типа.|
//| Если закрыть не удалось, то False, иначе True.                                      |
//+-------------------------------------------------------------------------------------+
bool CheckOrders(int Type, datetime FrTime)
{
 Count = 0;
 for (int i = OrdersTotal()-1; i >= 0; i--)
   if (OrderSelect(i, SELECT_BY_POS))
     if (OrderSymbol() == Symbol() && MathFloor(OrderMagicNumber()/100) == MagicNumber)
       if (OrderType() == Type)         // Найдена указанная позиция, пытаемся закрыть ее
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
        else  // Найдена противоположная указанной позиция. Увеличиваем значение счетчика
         {
          if (OrderOpenTime() > FrTime+Period()*180) // если найденная позиция открыта по
            return(False);              // тому же сигналу, то новую позицию не открываем
          Count++; 
         } 
 if (Count >= MaxOrders) // Не разрешаем открывать дополнительную позицию в ту же сторону
   return(False);                                         // при превышении их количества

 return(True);
}

//+-------------------------------------------------------------------------------------+
//| Открытие и закрытие позиций                                                         |
//+-------------------------------------------------------------------------------------+
bool Trades()
{
// - 1 - =================== Обработка сигнала открытия длинных позиций =================
 if (Signal > 0)
   if (CheckOrders(OP_SELL, Time[LUpN]))             // Можно ли открыть еще одну позицию
     if (OpenOrderCorrect(OP_BUY, NP(Ask), UpStop, UpTarget, Count) != 0)
       return(False);
   
// - 1 - ============================== Окончание блока =================================
       
// - 2 - ================== Обработка сигнала открытия коротких позиций =================
 if (Signal < 0)
   if (CheckOrders(OP_BUY, Time[LDnN]))              // Можно ли открыть еще одну позицию
     if (OpenOrderCorrect(OP_SELL, NP(Bid),DnStop + Spread, DnTarget+Spread, Count) != 0)
       return(False);
// - 2 - ============================== Окончание блока =================================
           
 return(True);
}

//+-------------------------------------------------------------------------------------+
//| Функция START эксперта                                                              |
//+-------------------------------------------------------------------------------------+
int start()
  {
// - 1 -  == Разрешено ли советнику работать? ===========================================
   if (!Activate || FatalError)             // Отключается работа советника, если функция
    return(0);           //  init завершилась с ошибкой  или имела место фатальная ошибка
// - 1 -  == Окончание блока ============================================================
     
// - 2 - == Сбор информации об условиях торговли ========================================
   Spread = ND(MarketInfo(Symbol(), MODE_SPREAD)*Point);                  // текщий спрэд
   StopLevel = ND(MarketInfo(Symbol(), MODE_STOPLEVEL)*Point);  // текущий уровень стопов 
   FreezeLevel = ND(MarketInfo(Symbol(), MODE_FREEZELEVEL)*Point);   // уровень заморозки
// - 2 -  == Окончание блока ============================================================

// - 3 - =========================== Контроль открытия нового бара ======================
   if (LastBar == Time[0])
     return(0);
// - 3 -  == Окончание блока ============================================================

// - 4 - ======================== Расчет сигнала ========================================
   GetSignal();
// - 4 -  == Окончание блока ============================================================

// - 5 - == Открытие позиций ============================================================
   if (Signal != 0)
     if (!Trades())                                          // Открытие/закрытие сделок
       return(0);
// - 5 -  == Окончание блока ============================================================

   LastBar = Time[0];

   return(0);
  }
