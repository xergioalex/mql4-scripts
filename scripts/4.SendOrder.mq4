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
  
  
void CreateOrder(double price, double lotSize, int orderType, double stopLoss, double takeProfit) {
  int slippage = 3; // Slippage in points
  int magicNumber = 123456; // Magic number for the order
  string comment = "Order created by script"; // Comment for the order

  int ticket = OrderSend(
    Symbol(),          // Symbol
    orderType,         // Order type (e.g., OP_BUY, OP_SELL, etc.)
    lotSize,           // Lot size
    price,             // Price
    slippage,          // Slippage
    stopLoss,          // Stop loss
    takeProfit,        // Take profit
    comment,           // Comment
    magicNumber,       // Magic number
    0,                 // Expiration (0 for no expiration)
    clrNONE            // Arrow color (clrNONE for no arrow)
  );

  if (ticket < 0) {
    Alert("OrderSend failed with error #", GetLastError());
  } else {
    Alert("Order created successfully. Ticket #", ticket);
  }
}


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
    
  // Example usage of CreateOrder function
  double price = Ask; // Example price
  double lotSize = 0.1; // Example lot size
  int orderType = OP_BUY; // Example order type (Buy)
  double stopLoss = price - 50 * Point; // Example stop loss
  double takeProfit = price + 50 * Point; // Example take profit

  CreateOrder(price, lotSize, orderType, stopLoss, takeProfit);
}
//+------------------------------------------------------------------+
