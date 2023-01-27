//+------------------------------------------------------------------+
//|                                 NNFX JohnDeluxe ALGO the 1st.mq4 |
//|                                                 Ricardo Trindade |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ricardo Trindade"
#property version   "1.00"
#property strict
#include "SupportingFunctions.mqh" 

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

//:::::::::::::::::::::::::::::::::::::::
//Strategy Inputs                       |
//:::::::::::::::::::::::::::::::::::::::
extern string  STRATEGY_INTUPS;// = "STRATEGY INTUPS";
extern int     atrPeriod = 14;
extern double  atrStopMultiplier = 1.5;
extern double  riskPerTrade = 2;
extern double  Trade_Ratio = 1.0;
extern int     Max_Bars_C1_Signal_to_Entry = 2;
extern bool    UseATR_base_Rule = false;
extern double  ATR_base_Multiplier = 1.0;

//:::::::::::::::::::::::::::::::::::::::
// C1 Indicator Inputs                  |
//:::::::::::::::::::::::::::::::::::::::
enum Indicator_Type 
{Zero_line_cross, Two_line_cross, Chart_indicator};
Indicator_Type Type_c1 = Zero_line_cross;

input string  C1_CONFIRMATION_INDICATOR_INTUPS;// = "CONFIRMATION INDICATOR INTUPS";
const string IndiNAME_c1 = "NNFX Indicators\\ClarityIndex";

extern int            Lookback  = 14; //Lookback Period
extern int            Smoothing = 14; //Smoothing Period
extern ENUM_MA_METHOD Method    = MODE_EMA; //Smoothing Method

int s1_c1 = Lookback;
int s2_c1 = Smoothing;
ENUM_MA_METHOD s3_c1 = MODE_EMA;
int s4_c1 = 0;
int s5_c1 = 0;
int s6_c1 = 0;
int s7_c1 = 0;

//:::::::::::::::::::::::::::::::::::::::
// C2 Indicator Inputs                  |
//:::::::::::::::::::::::::::::::::::::::
extern string  C2_2ND_CONFIRMATION_INDICATOR_INTUPS;// = "2ND CONFIRMATION INDICATOR INTUPS";
const string IndiNAME_c2 = "NNFX Indicators\\TDI-2";

extern int PeriodTDI=20;

int s1_c2 = PeriodTDI;
int s2_c2 = 0;
int s3_c2 = 0;
int s4_c2 = 0;
int s5_c2 = 0;
int s6_c2 = 0;
int s7_c2 = 0;

//:::::::::::::::::::::::::::::::::::::::
// Volume Indicator Inputs              |
//:::::::::::::::::::::::::::::::::::::::
extern string  VOL_VOLUME_INDICATOR_INTUPS;// = "VOLUME INDICATOR INTUPS";
const string IndiNAME_vol = "NNFX Indicators\\damiani_volatmeter";

extern int       Viscosity=7;
extern int       Sedimentation=50;
extern double    Threshold_level=1.1;
extern bool      lag_supressor=true;

int s1_vol = Viscosity;
int s2_vol = Sedimentation;
double s3_vol = Threshold_level;
bool s4_vol = lag_supressor;
int s5_vol = 0;
int s6_vol = 0;
int s7_vol = 0;

//:::::::::::::::::::::::::::::::::::::::
// Baseline Inputs                      |
//:::::::::::::::::::::::::::::::::::::::
extern string  BASELINE_INTUPS;// = "BASELINE INTUPS";
const string IndiNAME_base = "NNFX Indicators\\N/A Yet";

input int ma_period = 20;
input ENUM_MA_METHOD ma_method = MODE_EMA;



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   if (IsNewCandle()) {
   
      static bool longentry;
      static bool shortentry;
      
      static double long_lot; 
      static double short_lot;
      
      static int order_long;
      static int order_short;
      
      static double LongATRstop1;
      static double ShortATRstop1; 
      
      //===================================================================================================
      //Confirmation indicator 
      //===================================================================================================
      //Two line cross indicator templete__________________________________________________________________
      //Up
      /*
      double up1_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, 1);
      double up2_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, 2);
      
      //Down 
      double down1_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 1, 1);
      double down2_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 1, 2);
      
      bool long_c1   = (up1_c1 > down1_c1) && (up2_c1 <= down2_c1);
      bool short_c1  = (up1_c1 < down1_c1) && (up2_c1 >= down2_c1);
      
      bool isC1_Long  = (up1_c1 > down1_c1);
      bool isC1_Short = (up1_c1 < down1_c1);*/
      
      //Zero line cross indicator templete_________________________________________________________________
      
      //Calling the indicator and its buffers 
      double up1_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, 1);
      double up2_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, 2);
      
      //Condition Long & Short              
      bool signal_l_c1 = (up1_c1 > 0) && (up2_c1 <= 0);
      bool signal_s_c1 = (up1_c1 < 0) && (up2_c1 >= 0);
      
      bool isC1_Long  = (up1_c1 > 0);
      bool isC1_Short = (up1_c1 < 0);
      
      //Bar when condition was true
      int bar_0_c1_l = barsince_c1_signal(0, true, Type_c1, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1);                 
      int bar_0_c1_s = barsince_c1_signal(0, false, Type_c1, IndiNAME_c1,s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1);
      
      int bar_1_c1_l = barsince_c1_signal(1, true, Type_c1, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1);
      int bar_1_c1_s = barsince_c1_signal(1, false, Type_c1, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1);
      
      //===================================================================================================
      //2nd Confirmation indicator 
      //===================================================================================================
      //Zero line cross indicator templete_________________________________________________________________
      /*double up1_c2 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c2, s1_c2, s2_c2, s3_c2, s4_c2, s5_c2, s6_c2, s7_c2, 0, 1);
      double up2_c2 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c2, s1_c2, s2_c2, s3_c2, s4_c2, s5_c2, s6_c2, s7_c2, 0, 2);
      
      bool long_c2   = (up1_c2 > 0); //&& (up2_c2 <= 0);
      bool short_c2  = (up1_c2 < 0); //&& (up2_c2 >= 0);*/
      
      //Two line cross indicator templete__________________________________________________________________
      
      //Calling the indicator and its buffers 
      //Up
      double up1_c2 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c2, s1_c2, s2_c2, s3_c2, s4_c2, s5_c2, s6_c2, s7_c2, 0, 1);
      double up2_c2 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c2, s1_c2, s2_c2, s3_c2, s4_c2, s5_c2, s6_c2, s7_c2, 0, 2);
      
      //Down 
      double down1_c2 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c2, s1_c2, s2_c2, s3_c2, s4_c2, s5_c2, s6_c2, s7_c2, 1, 1);
      double down2_c2 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c2, s1_c2, s2_c2, s3_c2, s4_c2, s5_c2, s6_c2, s7_c2, 1, 2);
      
      //Condition Long & Short 
      bool long_c2   = (up1_c2 > down1_c2); //&& (up2_c2 <= down2_c2);
      bool short_c2  = (up1_c2 < down1_c2); //&& (up2_c2 >= down2_c2);
      
      //===================================================================================================
      //Volume indicator 
      //===================================================================================================
      
      //Calling the indicator and its buffers 
      //Up
      double up1_vol = iCustom(NULL, PERIOD_CURRENT, IndiNAME_vol, s1_vol, s2_vol, s3_vol, s4_vol, s5_vol, s6_vol, s7_vol, 0, 1);
      double up2_vol = iCustom(NULL, PERIOD_CURRENT, IndiNAME_vol, s1_vol, s2_vol, s3_vol, s4_vol, s5_vol, s6_vol, s7_vol, 0, 2);
      
      //Down 
      double down1_vol = iCustom(NULL, PERIOD_CURRENT, IndiNAME_vol, s1_vol, s2_vol, s3_vol, s4_vol, s5_vol, s6_vol, s7_vol, 1, 1);
      double down2_vol = iCustom(NULL, PERIOD_CURRENT, IndiNAME_vol, s1_vol, s2_vol, s3_vol, s4_vol, s5_vol, s6_vol, s7_vol, 1, 2);
      
      //Condition Long & Short 
      bool volume = (up1_vol > down1_vol);
      
      //===================================================================================================
      //Baseline
      //===================================================================================================
      
      //Calling the indicator and its buffers 
      double baseline1 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, 1);
      double baseline2 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, 2);
      
      //Condition Long & Short 
      bool isBase_Long  = (iClose(NULL, NULL, 1) > baseline1);
      bool isBase_Short = (iClose(NULL, NULL, 1) < baseline1);
      
      bool signal_l_base  = (iClose(NULL, NULL, 1) > baseline1) && (iClose(NULL, NULL, 2) <= baseline2);
      bool signal_s_base = (iClose(NULL, NULL, 1) < baseline1) && (iClose(NULL, NULL, 2) >= baseline2);
      
      //Bar when condition was true
      int bar_last_cross_long = barsince_base_cross_ls(0, true);
      int bar_last_cross_short = barsince_base_cross_ls(0, false);
      
      //Baseline ATR rule
      
      //===================================================================================================
      //Trade Signal & Entry  
      //===================================================================================================
      // Types of Entry
      
      //:::::::::::::::::::::::::::::::::::::::
      // Confirmation C1 Entry                |
      //:::::::::::::::::::::::::::::::::::::::
      bool CONFIRMATION_c1_l  = signal_l_c1 && long_c2; //&& volume && isBase_Long;
      bool CONFIRMATION_c1_s = signal_s_c1 && short_c2; //&& volume && isBase_Short;
      
      //:::::::::::::::::::::::::::::::::::::::
      // Baseline Entry                       |
      //:::::::::::::::::::::::::::::::::::::::
      bool CONFIRMATION_base_l = signal_l_base && isC1_Long && long_c2 && volume;
      bool CONFIRMATION_base_s = signal_s_base && isC1_Short && short_c2 && volume;
      
      //:::::::::::::::::::::::::::::::::::::::
      // Pullback Entry                       |
      //:::::::::::::::::::::::::::::::::::::::
      
      //:::::::::::::::::::::::::::::::::::::::
      // Continuation Entry                   |
      //:::::::::::::::::::::::::::::::::::::::
      enum Entry_c1_or_base 
      {C1, baseline};
      
      int barC1_base_l = barsince_for_cont(1, true, C1);
      int barC1_base_s = barsince_for_cont(1, false, C1);
      
      int barBase_c1_l = barsince_for_cont(1, true, baseline);
      int barBase_c1_s = barsince_for_cont(1, false, baseline);
      
      int bar_r_main_ll = barC1_base_l <= barBase_c1_l ? barC1_base_l : barBase_c1_l;
      int bar_r_main_ss = barC1_base_s <= barBase_c1_s ? barC1_base_s : barBase_c1_s;
      
      bool continuation_l = bar_r_main_ll <= bar_last_cross_short;
      bool continuation_s = bar_r_main_ss <= bar_last_cross_long;
      
      //***********************
      //Signal for trade entry
      //***********************
      longentry  = CONFIRMATION_c1_l;
      shortentry = CONFIRMATION_c1_s;
      
      
      //===================================================================================================
      //Trade Execution, Fill the orders, Open and Close my Position (trigger)
      //===================================================================================================
      
      //***************************************
      if (longentry) { // Submitting Long Trade
      //***************************************
        
         //..................................
         //ATR, Average True Range & Stoploss 
         //..................................
         double atr = iATR(NULL, 0, atrPeriod, 0);
         double LongATRstop = Ask - (atr * atrStopMultiplier); 
         
         //..................................
         // Pips for Lot Size Calculation  
         //..................................
         double pip_l = (Ask - LongATRstop) * Pip_Multiplier();  
         double lot_l = imp_LotSize(riskPerTrade, pip_l);
         
         //..................................
         // Submitting a Long Position
         //..................................
         string sllc = DoubleToString(LongATRstop); 
         LongATRstop1 = NormalizeDouble(LongATRstop, Digits); //Store Original SL in static variable 
         long_lot = lot_l;
         
         order_long = OrderSend(NULL, OP_BUY, lot_l, Ask, 10, LongATRstop, 0, sllc, 1);
         if (order_long < 0)
            {Alert(Symbol(), ": Order Rejected");
             Alert(ErrorHandling(GetLastError(), true, lot_l, LongATRstop, 0));}
      } 
      
      //***************************************
      if (shortentry) { // Submitting Short Trade
      //***************************************
      
         //..................................
         //ATR, Average True Range & Stoploss
         //.................................. 
         double atr = iATR(NULL, 0, atrPeriod, 0);  
         double ShortATRstop = Bid + (atr * atrStopMultiplier);   
         
         //..................................
         // Pips for Lot Size Calculation 
         //.................................. 
         double pip_s = (ShortATRstop - Bid) * Pip_Multiplier();
         double lot_s = imp_LotSize(riskPerTrade, pip_s);
      
         //..................................
         // Submitting a Short Position
         //..................................
         string slsc = DoubleToString(ShortATRstop);
         ShortATRstop1 = NormalizeDouble(ShortATRstop, Digits);
         short_lot = lot_s;
         
         order_short = OrderSend(NULL, OP_SELL, lot_s, Bid, 10, ShortATRstop, 0, slsc, 2);
         if (order_short < 0)
            {Alert(Symbol(), ": Order Rejected");
             Alert(ErrorHandling(GetLastError(), false, lot_s, ShortATRstop, 0));}
      }
      
      //..................................
      //Exit from reverse of C1
      //..................................
      if (checkIfOpenOrdersByMagicNB(1)){ // Close Long Trade C1 reverse
         if (signal_s_c1) {
            for(int b=OrdersTotal()-1; b >= 0; b--) {
               if(OrderSelect(b, SELECT_BY_POS, MODE_TRADES)) 
                  if(OrderMagicNumber() == 1)
                     if(OrderSymbol() == Symbol())
                        if(OrderType() == OP_BUY)
                           {int order_close_l = OrderClose(OrderTicket(), OrderLots(), Ask, 100000);
                           Alert("Order ", OrderTicket(), " Closed out due to C1 reverse");}
            }
         }
      }
      
      if (checkIfOpenOrdersByMagicNB(2)) {// Close Short Trade C1 reverse
         if (signal_l_c1) {
            for(int s=OrdersTotal()-1; s >= 0; s--) {
               if(OrderSelect(s, SELECT_BY_POS, MODE_TRADES)) 
                  if(OrderMagicNumber() == 2)
                     if(OrderSymbol() == Symbol())
                        if(OrderType() == OP_SELL)
                           {int order_close_s = OrderClose(OrderTicket(), OrderLots(), Ask, 100000);
                           Alert("Order ", OrderTicket(), " Closed out due to C1 reverse");}
            }
         }
      }
      
      //..................................
      //Trailing Stop   
      //..................................
      if (OrdersTotal() > 0) AdjustTrail_V2(1, 2, LongATRstop1, ShortATRstop1);
   } 
   
   //..................................
   //Move to breakeven 
   //and close half of the trade
   //..................................
   if (OrdersTotal() > 0) MoveToBreakeven_half_trade_off(1,2);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| #n of bars since Baseline Cross or C1 Signal                     |
//+------------------------------------------------------------------+
// This function is only to be used owhen working with Contuiation trades
// This shit is so big that I won't even bother exporting to the include files
 
int barsince_for_cont (int Index, bool isLong, int do_I_want_to_check_c1) {

   int Index_0 = 0;
   int Index_1 = 0; 
   
   //Loop for when I want to get bar since last C1 signal (int Index == 0)   
   for (int i=0; i < Bars; i++) {
   
      double base_line_1 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+1);
      double base_line_2 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+2);
      
      bool long_cross  = (iClose(NULL, NULL, i+1) > base_line_1) && (iClose(NULL, NULL, i+2) <= base_line_2);
      bool short_cross = (iClose(NULL, NULL, i+1) < base_line_1) && (iClose(NULL, NULL, i+2) >= base_line_2);
      
      double up1_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, i+1);
      double up2_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, i+2);
      
      bool long_c1   = (up1_c1 > 0) && (up2_c1 <= 0);
      bool short_c1  = (up1_c1 < 0) && (up2_c1 >= 0);
      
      bool isC1_Long  = (up1_c1 > 0);
      bool isC1_Short = (up1_c1 < 0);
      
      bool check_l_base = long_cross && isC1_Long;
      bool check_s_base = short_cross && isC1_Short;
      
      bool check_l_c1 = long_c1 && (iClose(NULL, NULL, i+1) > base_line_1);
      bool check_s_c1 = short_c1 && (iClose(NULL, NULL, i+1) < base_line_1);
      
      if (do_I_want_to_check_c1 == 0) {
         if (isLong) {
            if (check_l_c1) {
            
               Index_0 = i;
               break;
            }
         }
         
         if (isLong == false) {
            if (check_s_c1) {
            
               Index_0 = i;
               break;
            }
         }
      }
      
      if (do_I_want_to_check_c1 == 1) {
         if (isLong) {
            if (check_l_base) {
            
               Index_0 = i;
               break;
            }
         }
         
         if (isLong == false) {
            if (check_s_base) {
            
               Index_0 = i;
               break;
            }
         }
      }         
   }
   
   //Loop for when I want to get bar since C1 signal previous to the last one (int Index == 1)       
   for (int i = Index_0 + 1; i < Bars; i++) {
   
      double base_line_1 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+1);
      double base_line_2 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+2);
      
      bool long_cross  = (iClose(NULL, NULL, i+1) > base_line_1) && (iClose(NULL, NULL, i+2) <= base_line_2);
      bool short_cross = (iClose(NULL, NULL, i+1) < base_line_1) && (iClose(NULL, NULL, i+2) >= base_line_2);
      
      double up1_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, i+1);
      double up2_c1 = iCustom(NULL, PERIOD_CURRENT, IndiNAME_c1, s1_c1, s2_c1, s3_c1, s4_c1, s5_c1, s6_c1, s7_c1, 0, i+2);
      
      bool long_c1   = (up1_c1 > 0) && (up2_c1 <= 0);
      bool short_c1  = (up1_c1 < 0) && (up2_c1 >= 0);
      
      bool isC1_Long  = (up1_c1 > 0);
      bool isC1_Short = (up1_c1 < 0);
      
      bool check_l_base = long_cross && isC1_Long;
      bool check_s_base = short_cross && isC1_Short;
      
      bool check_l_c1 = long_c1 && (iClose(NULL, NULL, i+1) > base_line_1);
      bool check_s_c1 = short_c1 && (iClose(NULL, NULL, i+1) < base_line_1);
      
      if (do_I_want_to_check_c1 == 0) {
         if (isLong) {
            if (check_l_c1) {
            
               Index_1 = i;
               break;
            }
         }
         
         if (isLong == false) {
            if (check_s_c1) {
            
               Index_1 = i;
               break;
            }
         }
      }
      
      if (do_I_want_to_check_c1 == 1) {
         if (isLong) {
            if (check_l_base) {
            
               Index_1 = i;
               break;
            }
         }
         
         if (isLong == false) {
            if (check_s_base) {
            
               Index_1 = i;
               break;
            }
         }
      }            
   }
   return Index == 0 ? Index_0 : Index_1; 
}



//+------------------------------------------------------------------+
//| #n of bars since Baseline Cross Long or short                    |
//+------------------------------------------------------------------+
int barsince_base_cross_ls(int Index, bool isLong) {

   int Index_0 = 0;
   int Index_1 = 0; 
   
   //Loop for when I want to get bar since last C1 signal (int Index == 0)   
   for (int i=0; i < Bars; i++) {
   
      double base_line_1 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+1);
      double base_line_2 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+2);
      
      bool long_cross  = (iClose(NULL, NULL, i+1) > base_line_1) && (iClose(NULL, NULL, i+2) <= base_line_2);
      bool short_cross = (iClose(NULL, NULL, i+1) < base_line_1) && (iClose(NULL, NULL, i+2) >= base_line_2);
      
      if (isLong) {
         if (long_cross) {
         
            Index_0 = i;
            break;
         }
      }
      
      if (isLong == false) {
         if (short_cross) {
         
            Index_0 = i;
            break;
         }
      }      
   }
   
   //Loop for when I want to get bar since C1 signal previous to the last one (int Index == 1)       
   for (int i = Index_0 + 1; i < Bars; i++) {
   
      double base_line_1 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+1);
      double base_line_2 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+2);
      
      bool long_cross  = (iClose(NULL, NULL, i+1) > base_line_1) && (iClose(NULL, NULL, i+2) <= base_line_2);
      bool short_cross = (iClose(NULL, NULL, i+1) < base_line_1) && (iClose(NULL, NULL, i+2) >= base_line_2);
      
      if (isLong) {
         if (long_cross) {
         
            Index_1 = i;
            break;
         }
      }
      
      if (isLong == false) {
         if (short_cross) {
         
            Index_1 = i;
            break;
         }
      }          
   }
   return Index == 0 ? Index_0 : Index_1;     
}

//+------------------------------------------------------------------+
//| #n of bars since Baseline Cross                                  |
//+------------------------------------------------------------------+
int barsince_base_cross(int Index) {

   int Index_0 = 0;
   int Index_1 = 0; 
   
   //Loop for when I want to get bar since last C1 signal (int Index == 0)   
   for (int i=0; i < Bars; i++) {
   
      double base_line_1 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+1);
      double base_line_2 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+2);
      
      bool long_cross  = (iClose(NULL, NULL, i+1) > base_line_1) && (iClose(NULL, NULL, i+2) <= base_line_2);
      bool short_cross = (iClose(NULL, NULL, i+1) < base_line_1) && (iClose(NULL, NULL, i+2) >= base_line_2);
      
      if (long_cross || short_cross) {
      
         Index_0 = i;
         break;
      }       
   }
   
   //Loop for when I want to get bar since C1 signal previous to the last one (int Index == 1)       
   for (int i = Index_0 + 1; i < Bars; i++) {
   
      double base_line_1 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+1);
      double base_line_2 = iMA(NULL, NULL, ma_period, 0, ma_method, PRICE_CLOSE, i+2);
      
      bool long_cross  = (iClose(NULL, NULL, i+1) > base_line_1) && (iClose(NULL, NULL, i+2) <= base_line_2);
      bool short_cross = (iClose(NULL, NULL, i+1) < base_line_1) && (iClose(NULL, NULL, i+2) >= base_line_2);
      
      if (long_cross || short_cross) {
      
         Index_1 = i;
         break;
      }          
   }
   return Index == 0 ? Index_0 : Index_1;     
}

