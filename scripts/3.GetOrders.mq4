//+------------------------------------------------------------------+
//|                                               ListOpenCharts.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function .                                   |
//+------------------------------------------------------------------+

class ChartInfo
  {
   public:
      long chartID;
      string symbol;
      int indicatorsTotal;
  };

void OnStart() {
  // Clear previous alerts by adding empty alerts
  for (int k = 0; k < 30; k++) {
    Alert("");
  }
  
   long chartID = ChartID();
   string symbol = ChartSymbol(chartID); // Get the chart symbol
    
   // Create a ChartInfo object and store the information
   ChartInfo info;
   info.chartID = chartID;
   info.symbol = symbol;
   info.indicatorsTotal = ChartIndicatorsTotal(chartID, 0);
   
   Alert("Symbol = ", info.symbol, ", Chart ID = ", info.chartID, ", Indicators: ", info.indicatorsTotal);
    
  // Loop through all orders and get details of open orders for the current symbol
  for (int i = 0; i < OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol() == symbol) {
        double price = OrderOpenPrice();
        double lotSize = OrderLots();
        double stopLoss = OrderStopLoss();
        double takeProfit = OrderTakeProfit();
        int orderType = OrderType();
        string orderTypeStr;
        
        switch(orderType) {
          case OP_BUY:
            orderTypeStr = "Buy";
            break;
          case OP_SELL:
            orderTypeStr = "Sell";
            break;
          case OP_BUYLIMIT:
            orderTypeStr = "Buy Limit";
            break;
          case OP_SELLLIMIT:
            orderTypeStr = "Sell Limit";
            break;
          case OP_BUYSTOP:
            orderTypeStr = "Buy Stop";
            break;
          case OP_SELLSTOP:
            orderTypeStr = "Sell Stop";
            break;
          default:
            orderTypeStr = "Unknown";
        }
        
        Alert("Order #", OrderTicket(), ": Type = ", orderTypeStr, ", Price = ", price, ", Lot Size = ", lotSize, ", Stop Loss = ", stopLoss, ", Take Profit = ", takeProfit);
      }
    }
  }
}
//+------------------------------------------------------------------+
