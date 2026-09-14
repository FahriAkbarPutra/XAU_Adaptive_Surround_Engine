//+------------------------------------------------------------------+
//|                                XAU_Adaptive_Surround_Engine.mq5  |
//|                                      MQL5 Expert Advisor Script  |
//+------------------------------------------------------------------+
#property copyright "Custom EA"
#property link      "https://github.com/yourusername/XAU-Adaptive-Surround-Engine"
#property version   "5.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>

//--- PENGATURAN LOT & SPREAD
input group "=== PENGATURAN LOT & SPREAD ==="
input double InpLotSize       = 0.01;      // Ukuran Lot Awal
input double InpLotMultiplier = 1.0;       // Pengali Lot saat Berbalik (Reversal)
input int    InpMaxSpread     = 80;        // Max Spread (Isi persis angka di Market Watch)

//--- PENGATURAN JARAK TRANSAKSI (POIN)
input group "=== PENGATURAN JARAK TRANSAKSI (POIN) ==="
input int    InpPendingDist   = 50;        // Jarak Order Pengepungan Atas/Bawah (Poin)
input int    InpInitialSL     = 200;       // Jarak Stop Loss Awal (Poin)

//--- PENGATURAN TRAILING SL (POIN)
input group "=== PENGATURAN TRAILING SL (POIN) ==="
input int    InpTrailingStart = 100;       // Kapan Trailing Aktif? (Jarak Profit dlm Poin)
input int    InpTrailingDist  = 150;       // Jarak Ekor Trailing SL dari Harga (Poin)
input int    InpTrailingStep  = 50;        // Step Geser Trailing (Modifikasi tiap brp Poin)

//--- SISTEM
input group "=== PENGATURAN SISTEM ==="
input ulong  InpMagicNumber   = 888999;    // ID Magic Number EA

CTrade         trade;
CSymbolInfo    sym;
CPositionInfo  pos;

// UI Variables
bool isActive = false;
int panelX = 20, panelY = 20;
bool isDragging = false;
int dragOffsetX = 0, dragOffsetY = 0;

string objBg = "ea_bg", objHeader = "ea_header", objTitle = "ea_title";
string objBtn = "ea_btn", objInfo1 = "ea_info1", objInfo2 = "ea_info2";

//+------------------------------------------------------------------+
//| UI Management Functions                                          |
//+------------------------------------------------------------------+
void CreateUI() {
    ObjectCreate(0, objBg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objBg, OBJPROP_BGCOLOR, clrDarkSlateGray);
    ObjectSetInteger(0, objBg, OBJPROP_COLOR, clrBlack);
    
    ObjectCreate(0, objHeader, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objHeader, OBJPROP_BGCOLOR, clrBlack);
    ObjectSetInteger(0, objHeader, OBJPROP_COLOR, clrBlack);
    
    ObjectCreate(0, objTitle, OBJ_LABEL, 0, 0, 0);
    ObjectSetString(0, objTitle, OBJPROP_TEXT, "XAU ADAPTIVE ENGINE");
    ObjectSetInteger(0, objTitle, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, objTitle, OBJPROP_FONTSIZE, 10);
    
    ObjectCreate(0, objInfo1, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objInfo1, OBJPROP_COLOR, clrGold);
    ObjectSetInteger(0, objInfo1, OBJPROP_FONTSIZE, 9);
    
    ObjectCreate(0, objInfo2, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objInfo2, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, objInfo2, OBJPROP_FONTSIZE, 9);
    
    ObjectCreate(0, objBtn, OBJ_BUTTON, 0, 0, 0);
    
    if(isActive) {
        ObjectSetString(0, objBtn, OBJPROP_TEXT, "PAUSE ENGINE (TESTER)");
        ObjectSetInteger(0, objBtn, OBJPROP_BGCOLOR, clrSeaGreen);
    } else {
        ObjectSetString(0, objBtn, OBJPROP_TEXT, "START ENGINE");
        ObjectSetInteger(0, objBtn, OBJPROP_BGCOLOR, clrFireBrick);
    }
    ObjectSetInteger(0, objBtn, OBJPROP_COLOR, clrWhite);
    
    UpdateUIPositions();
}

void UpdateUIPositions() {
    ObjectSetInteger(0, objBg, OBJPROP_XDISTANCE, panelX);
    ObjectSetInteger(0, objBg, OBJPROP_YDISTANCE, panelY);
    ObjectSetInteger(0, objBg, OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, objBg, OBJPROP_YSIZE, 130);
    
    ObjectSetInteger(0, objHeader, OBJPROP_XDISTANCE, panelX);
    ObjectSetInteger(0, objHeader, OBJPROP_YDISTANCE, panelY);
    ObjectSetInteger(0, objHeader, OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, objHeader, OBJPROP_YSIZE, 25);
    
    ObjectSetInteger(0, objTitle, OBJPROP_XDISTANCE, panelX + 35);
    ObjectSetInteger(0, objTitle, OBJPROP_YDISTANCE, panelY + 5);
    
    ObjectSetInteger(0, objInfo1, OBJPROP_XDISTANCE, panelX + 10);
    ObjectSetInteger(0, objInfo1, OBJPROP_YDISTANCE, panelY + 35);
    
    ObjectSetInteger(0, objInfo2, OBJPROP_XDISTANCE, panelX + 10);
    ObjectSetInteger(0, objInfo2, OBJPROP_YDISTANCE, panelY + 55);
    
    ObjectSetInteger(0, objBtn, OBJPROP_XDISTANCE, panelX + 10);
    ObjectSetInteger(0, objBtn, OBJPROP_YDISTANCE, panelY + 80);
    ObjectSetInteger(0, objBtn, OBJPROP_XSIZE, 180);
    ObjectSetInteger(0, objBtn, OBJPROP_YSIZE, 35);
    ChartRedraw();
}

void DestroyUI() {
    ObjectDelete(0, objBg); ObjectDelete(0, objHeader);
    ObjectDelete(0, objTitle); ObjectDelete(0, objInfo1);
    ObjectDelete(0, objInfo2); ObjectDelete(0, objBtn);
}

//+------------------------------------------------------------------+
//| Initialization & Deinitialization                                |
//+------------------------------------------------------------------+
int OnInit() {
    sym.Name(_Symbol);
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetTypeFillingBySymbol(_Symbol); 
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
    
    if(MQLInfoInteger(MQL_TESTER)) {
        isActive = true; 
    }
    
    CreateUI();
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);
    DestroyUI();
}

//+------------------------------------------------------------------+
//| Chart Event (Drag UI & Button Logic)                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if(id == CHARTEVENT_OBJECT_CLICK && sparam == objBtn) {
        ObjectSetInteger(0, objBtn, OBJPROP_STATE, false); 
        isActive = !isActive;
        
        if(isActive) {
            ObjectSetString(0, objBtn, OBJPROP_TEXT, "PAUSE ENGINE");
            ObjectSetInteger(0, objBtn, OBJPROP_BGCOLOR, clrSeaGreen);
        } else {
            ObjectSetString(0, objBtn, OBJPROP_TEXT, "START ENGINE");
            ObjectSetInteger(0, objBtn, OBJPROP_BGCOLOR, clrFireBrick);
        }
    }
    
    if(id == CHARTEVENT_MOUSE_MOVE) {
        int x = (int)lparam;
        int y = (int)dparam;
        int mouseState = (int)StringToInteger(sparam);
        
        if(mouseState == 1) { 
            if(!isDragging) {
                if(x >= panelX && x <= panelX + 200 && y >= panelY && y <= panelY + 25) {
                    isDragging = true;
                    dragOffsetX = x - panelX;
                    dragOffsetY = y - panelY;
                }
            } else {
                panelX = x - dragOffsetX;
                panelY = y - dragOffsetY;
                UpdateUIPositions();
            }
        } else {
            isDragging = false;
        }
    }
}

//+------------------------------------------------------------------+
//| Core Engine Logic                                                |
//+------------------------------------------------------------------+
void OnTick() {
    sym.RefreshRates();
    
    double currentSpread = sym.Ask() - sym.Bid();
    double currentSpreadPoints = currentSpread / _Point;
    
    if(!MQLInfoInteger(MQL_OPTIMIZATION)) {
        ObjectSetString(0, objInfo1, OBJPROP_TEXT, "Spread Saat Ini: " + DoubleToString(currentSpreadPoints, 0) + " Poin");
    }
    
    double floatProfit = 0;
    int buys = 0, sells = 0, buyStops = 0, sellStops = 0;
    ulong ticketBuy = 0, ticketSell = 0, ticketBuyStop = 0, ticketSellStop = 0;
    double slBuy = 0, slSell = 0;
    double currentLot = InpLotSize;

    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(pos.SelectByIndex(i) && pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber) {
            floatProfit += pos.Profit();
            currentLot = pos.Volume(); 
            if(pos.PositionType() == POSITION_TYPE_BUY) { buys++; ticketBuy = pos.Ticket(); slBuy = pos.StopLoss(); }
            if(pos.PositionType() == POSITION_TYPE_SELL) { sells++; ticketSell = pos.Ticket(); slSell = pos.StopLoss(); }
        }
    }
    
    if(!MQLInfoInteger(MQL_OPTIMIZATION)) {
        ObjectSetString(0, objInfo2, OBJPROP_TEXT, "Floating: $" + DoubleToString(floatProfit, 2));
    }
    
    if(!isActive) return;

    for(int i = OrdersTotal() - 1; i >= 0; i--) {
        ulong ticket = OrderGetTicket(i);
        if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == InpMagicNumber) {
            if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP) { buyStops++; ticketBuyStop = ticket; }
            if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP) { sellStops++; ticketSellStop = ticket; }
        }
    }

    if(buys > 0) {
        pos.SelectByTicket(ticketBuy);
        if(sym.Bid() - pos.PriceOpen() >= InpTrailingStart * _Point) {
            double newSL = NormalizeDouble(sym.Bid() - InpTrailingDist * _Point, _Digits);
            if(newSL - pos.StopLoss() >= InpTrailingStep * _Point || pos.StopLoss() == 0) {
                if(trade.PositionModify(ticketBuy, newSL, 0)) slBuy = newSL;
            }
        }
    }
    if(sells > 0) {
        pos.SelectByTicket(ticketSell);
        if(pos.PriceOpen() - sym.Ask() >= InpTrailingStart * _Point) {
            double newSL = NormalizeDouble(sym.Ask() + InpTrailingDist * _Point, _Digits);
            if(pos.StopLoss() - newSL >= InpTrailingStep * _Point || pos.StopLoss() == 0) {
                if(trade.PositionModify(ticketSell, newSL, 0)) slSell = newSL;
            }
        }
    }

    double nextLot = NormalizeDouble(currentLot * InpLotMultiplier, 2);
    if(nextLot < InpLotSize) nextLot = InpLotSize;

    if(buys == 0 && sells == 0 && currentSpreadPoints <= InpMaxSpread) {
        if(buyStops == 0) {
            double p = NormalizeDouble(sym.Ask() + InpPendingDist * _Point, _Digits);
            double sl = NormalizeDouble(p - InpInitialSL * _Point, _Digits);
            trade.BuyStop(InpLotSize, p, _Symbol, sl, 0, 0, 0, "Top");
        }
        if(sellStops == 0) {
            double p = NormalizeDouble(sym.Bid() - InpPendingDist * _Point, _Digits);
            double sl = NormalizeDouble(p + InpInitialSL * _Point, _Digits);
            trade.SellStop(InpLotSize, p, _Symbol, sl, 0, 0, 0, "Bot");
        }
    }
    else if(buys > 0) {
        if(buyStops > 0) trade.OrderDelete(ticketBuyStop);
        if(slBuy > 0) {
            if(sellStops == 0) {
                double sl = NormalizeDouble(slBuy + InpInitialSL * _Point, _Digits);
                trade.SellStop(nextLot, slBuy, _Symbol, sl, 0, 0, 0, "Rev.Sell");
            } else {
                OrderSelect(ticketSellStop);
                if(MathAbs(OrderGetDouble(ORDER_PRICE_OPEN) - slBuy) > _Point) {
                    double sl = NormalizeDouble(slBuy + InpInitialSL * _Point, _Digits);
                    trade.OrderModify(ticketSellStop, slBuy, sl, 0, ORDER_TIME_GTC, 0, 0);
                }
            }
        }
    }
    else if(sells > 0) {
        if(sellStops > 0) trade.OrderDelete(ticketSellStop);
        if(slSell > 0) {
            if(buyStops == 0) {
                double sl = NormalizeDouble(slSell - InpInitialSL * _Point, _Digits);
                trade.BuyStop(nextLot, slSell, _Symbol, sl, 0, 0, 0, "Rev.Buy");
            } else {
                OrderSelect(ticketBuyStop);
                if(MathAbs(OrderGetDouble(ORDER_PRICE_OPEN) - slSell) > _Point) {
                    double sl = NormalizeDouble(slSell - InpInitialSL * _Point, _Digits);
                    trade.OrderModify(ticketBuyStop, slSell, sl, 0, ORDER_TIME_GTC, 0, 0);
                }
            }
        }
    }
}
