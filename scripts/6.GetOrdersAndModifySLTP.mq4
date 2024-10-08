//+------------------------------------------------------------------+
//|                                               ListOpenCharts.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//-- Include
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| Script program start function .                                   |
//+------------------------------------------------------------------+

void OnStart() {
  int ordersTotal = OrdersTotal();
  Alert("OrderTotal: ", ordersTotal);
  double profitDollarsToSet = 10;
  // Loop through all orders and get details of open orders for the current symbol
  for (int i = 0; i < ordersTotal; i++) {
    Alert("Loop: ", i);
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      double price = OrderOpenPrice();
      double lotSize = OrderLots();
      double stopLoss = OrderStopLoss();
      double takeProfit = OrderTakeProfit();
      int orderType = OrderType();
      
      // Calculate risk and potential profit in dollars
      double pipValue = MarketInfo(OrderSymbol(), MODE_TICKVALUE);
      double riskDollars = 0.0;
      double profitDollars = 0.0;  
      double riskPipDiff = 0.0;
      double lotSizePipValue = (lotSize * pipValue);
      double PIP_VALUE_MULTIPLIER = 0;
      if (StringFind(OrderSymbol(), "JPY") != -1) {
        PIP_VALUE_MULTIPLIER = 10;
      } else {
        PIP_VALUE_MULTIPLIER = 100000;
      }
      if (orderType == OP_BUY || orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP) {
        // Adjust Take Profit to ensure risk is 10 USD
        double profitPips = profitDollarsToSet / lotSizePipValue;
        takeProfit = price + (profitPips * Point);
        Alert("Take Profit: ", takeProfit);
        if (!OrderModify(OrderTicket(), price, stopLoss, takeProfit, 0, clrNONE)) {
          Alert("--- Error Buy ----");
          Alert("Error: ", ErrorDescription(GetLastError()));
        }

        riskPipDiff = (price - stopLoss);
        Alert("riskPipDiff: ", riskPipDiff * PIP_VALUE_MULTIPLIER);
        riskDollars = (riskPipDiff * lotSizePipValue) * PIP_VALUE_MULTIPLIER;
        profitDollars = ((takeProfit - price) * lotSizePipValue) * PIP_VALUE_MULTIPLIER;
      } else if (orderType == OP_SELL || orderType == OP_SELLLIMIT || orderType == OP_SELLSTOP) {
        // Adjust Take Profit to ensure risk is 10 USD
        double profitPips = profitDollarsToSet / lotSizePipValue;
        takeProfit = price - (profitPips * Point);
        Alert("Take Profit: ", takeProfit);
        if (!OrderModify(OrderTicket(), price, stopLoss, takeProfit, 0, clrNONE)) {
          Alert("--- Error Sell ----");
          Alert("Error: ", ErrorDescription(GetLastError()));
        }

        riskPipDiff = (stopLoss - price);
        Alert("riskPipDiff: ", riskPipDiff * PIP_VALUE_MULTIPLIER);
        riskDollars = (riskPipDiff * lotSizePipValue) * PIP_VALUE_MULTIPLIER;
        profitDollars = ((price - takeProfit) * lotSizePipValue) * PIP_VALUE_MULTIPLIER;
      }
      
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
      
      Alert("Order #", OrderTicket(), ": Symbol = ", Symbol(), ", Type = ", orderTypeStr, ", Price = ", price, ", Lot Size = ", lotSize, ", Stop Loss = ", stopLoss, ", Take Profit = ", takeProfit, ", Risk ($) = ", riskDollars, ", Profit ($) = ", profitDollars);
    }
  }
}
//+------------------------------------------------------------------+