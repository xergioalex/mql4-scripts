//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                         TrailingProfitChaser.mq4 |
//|                                      Copyright 2024, XergioAleX. |
//|                                       https://www.xergioalex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, XergioAleX."
#property link      "https://www.xergioalex.com"
#property version       "1.00"
#property strict
#property description   "TrailingChaser is an advanced trading algorithm that automatically"
#property description   "adjusts stop-loss and take-profit levels based on price movement,"
#property description   "helping you maximize profits while maintaining risk management"
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property description   "Find More on XergioAleX.com"
#property strict
#property icon   "\\Icons\\indicator-icon.ico"
#property show_inputs

#include <stdlib.mqh>
#include "../include/Utils.mqh";

enum ENUM_ORDER_TYPES {
    ALL_ORDERS = 1, // ALL ORDERS
    ONLY_BUY = 2,   // BUY ONLY
    ONLY_SELL = 3   // SELL ONLY
};

input bool OnlyCurrentSymbol = true; // Only current chart's symbol
input ENUM_ORDER_TYPES OrderTypeFilter = ALL_ORDERS; // Type of orders to move SL to BE
input bool OnlyMagicNumber = false;   // Only orders matching the magic number
input int MagicNumber = 0;            // Matching magic number
input bool OnlyWithComment = false;   // Only orders with the following comment
input string MatchingComment = "";    // Matching comment
input double PercentageOfPositiveProfitToMoveThePrice = 70; // Percentage of positive profit to move the price
input double PercentageOfProfitToBeIncreased = 20; // Percentage of profit to be increased

// Start program to start the function.
void OnStart() {
  Print("#######################################");
  Print("##### • START TRAILING PROFIT CHASER SCRIPT • #####");
  Print("");
  
  StartTrailingProfitChaserStrategy();

  Print("");
  Print("##### • END TRAILING PROFIT CHASER SCRIPT • #####");
  Print("#####################################");
}


void StartTrailingProfitChaserStrategy() {
  // Check if terminal is connected
  if (!TerminalInfoInteger(TERMINAL_CONNECTED)) {
    Print("Not connected to the trading server. Exiting.");
    return;
  }

  // Check if trading is allowed
  if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED))) {
    Print("Autotrading is disable. Please enable. Exiting.");
    return;
  }

  // Get total orders
  int ordersTotal = OrdersTotal();
  int marketOrdersTotal = 0;
  int marketOrdersModifiedTotal = 0;
  Print("Total orders: ", ordersTotal);


  // If no orders found, exit
  if (ordersTotal == 0) {
    Print("No orders found.");
    return;
  }

  Print("---");

  // Loop through all orders
  for (int i = 0; i < ordersTotal; i++) {
    // Select order by position
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      Print("ERROR - Unable to select the order: ", GetLastError());
      continue;
    }

    // Get order type
    int orderType = OrderType();
    if (orderType == OP_BUY || orderType == OP_SELL) {
        marketOrdersTotal++;
        // Apply break even strategy to the order
        if (ApplyTrailingChaserStrategy(orderType)) {
            marketOrdersModifiedTotal++;
        }
    }
    
  }

  Print("Total market orders: ", marketOrdersTotal);
  Print("Total market orders modified: ", marketOrdersModifiedTotal);
}

double ShouldTrailingProfitChaserStrategyToTheOrder(double profitDollars, double currentProfitDollars) {
  // Verify if we can apply the strategy
  if (!(profitDollars > 0 && currentProfitDollars != 0)) {
    Print("ERROR: Dollars values not valid.");
    return false;
  } 

  double profitToMoveThePriceInDollars = profitDollars * (PercentageOfPositiveProfitToMoveThePrice / 100); 
  if (currentProfitDollars >= profitToMoveThePriceInDollars) {
    return true;
  }
  return false;
}

double CalcBreakEvenDollars(double orderCommission, double orderSwap) {
  // Calculate break even in dollars
  double breakEvenDollars = (orderCommission + (orderCommission * 0.30)) + orderSwap;
  if (breakEvenDollars > 0) {
    breakEvenDollars = orderCommission;
  }
  return MathAbs(breakEvenDollars);
}

bool ApplyTrailingChaserStrategy(int orderType) {
  // Get order details
  int orderTicket = OrderTicket();
  string orderSymbol = OrderSymbol();
  double orderOpenPrice = OrderOpenPrice();
  double orderLotsSize = OrderLots();
  double orderStopLoss = OrderStopLoss();
  double orderTakeProfit = OrderTakeProfit();
  datetime orderExpiration = OrderExpiration();
  double orderCommission = OrderCommission();
  double orderSwap = OrderSwap();
  int orderMagicNumber = OrderMagicNumber();
  string orderComment = OrderComment();
  int orderDigits = (int)MarketInfo(orderSymbol, MODE_DIGITS);
  double currentProfitDollars = OrderProfit();

  // Check if the order matches the filter and if not, skip the order and move to the next one.
  if (!(orderType == OP_BUY || orderType == OP_SELL)) return false;
  if ((OrderTypeFilter == ONLY_SELL) && (orderType == OP_BUY)) return false;
  if ((OrderTypeFilter == ONLY_BUY)  && (orderType == OP_SELL)) return false;
  if ((OnlyCurrentSymbol) && (orderSymbol != Symbol())) return false;
  if ((OnlyMagicNumber) && (orderMagicNumber != MagicNumber)) return false;
  if ((OnlyWithComment) && (StringCompare(orderComment, MatchingComment) != 0)) return false;
  
  // Calculate risk and profit in dollars
  double pipValue = MarketInfo(orderSymbol, MODE_TICKVALUE);
  double pipValueMultiplier = GetPipValueMultiplier(orderDigits);

  // If pip value multiplier is 0, continue to the next order
  if (pipValueMultiplier == 0) {
    Print("ERROR: Invalid pip value multiplier.");
    return false;
  }
  double profitDollars = 0.0;  
  double riskDollars = 0.0; 
  double lotSizePipValue = (orderLotsSize * pipValue);
  string resultError = "";
  
  if (orderType == OP_BUY) {
    // Verify if the order Break Even was already applied
    if (orderOpenPrice >= orderStopLoss) {
      resultError = "i) Strategy can not be applied, the stop loss should be positive.";
    } else {
      // Calculate risk and profit in pips and dollars
      double riskPipDiff = (orderStopLoss - orderOpenPrice);
      double profitPipDiff = (orderTakeProfit - orderOpenPrice);
      riskDollars = (riskPipDiff * lotSizePipValue) * pipValueMultiplier;
      profitDollars = (profitPipDiff * lotSizePipValue) * pipValueMultiplier;

      // Verify if we should apply break even to the order
      if (resultError == "" && ShouldTrailingProfitChaserStrategyToTheOrder(profitDollars, currentProfitDollars)) {
        // Calculate positions to move the limits
        double profitToIncreaseInDollars = profitDollars * (PercentageOfProfitToBeIncreased / 100);
        double riskDollarsResult = riskDollars + profitToIncreaseInDollars;
        double profitDollarsResult = profitDollars + profitToIncreaseInDollars;

        // Calculate the new stop loss and take profit
        double orderStopLossProfitPips = riskDollarsResult / lotSizePipValue;
        double orderTakeProfitPips = profitDollarsResult / lotSizePipValue;
        orderStopLoss = orderOpenPrice + (orderStopLossProfitPips * Point);
        orderTakeProfit = orderOpenPrice + (orderTakeProfitPips * Point);
      }
    }
  } else if (orderType == OP_SELL) {
    // Verify if the order Break Even was already applied
    if (orderOpenPrice <= orderStopLoss) {
      resultError = "i) Strategy can not be applied, the stop loss should be positive.";
    } else {
      // Calculate risk and profit in pips and dollars
      double riskPipDiff = (orderOpenPrice - orderStopLoss);
      double profitPipDiff = (orderOpenPrice - orderTakeProfit);
      riskDollars = (riskPipDiff * lotSizePipValue) * pipValueMultiplier;
      profitDollars = (profitPipDiff * lotSizePipValue) * pipValueMultiplier;

      // Verify if we should apply break even to the order
      if (resultError == "" && ShouldTrailingProfitChaserStrategyToTheOrder(profitDollars, currentProfitDollars)) {
        // Calculate positions to move the limits
        double profitToIncreaseInDollars = profitDollars * (PercentageOfProfitToBeIncreased / 100);
        double riskDollarsResult = riskDollars + profitToIncreaseInDollars;
        double profitDollarsResult = profitDollars + profitToIncreaseInDollars;

        // Calculate the new stop loss and take profit
        double orderStopLossProfitPips = riskDollarsResult / lotSizePipValue;
        double orderTakeProfitPips = profitDollarsResult / lotSizePipValue;
        orderStopLoss = orderOpenPrice - (orderStopLossProfitPips * Point);
        orderTakeProfit = orderOpenPrice - (orderTakeProfitPips * Point);
      }
    }
  }

  // Modify order
  if (resultError == "" && !OrderModify(orderTicket, orderOpenPrice, orderStopLoss, orderTakeProfit, orderExpiration, clrNONE)) {
    resultError = "Error modifying order: " + ErrorDescription(GetLastError());
  }
  
  PrintOrderDetails(
    orderTicket, orderSymbol, orderType, orderDigits, orderOpenPrice, orderLotsSize, orderStopLoss, 
    orderTakeProfit, riskDollars, profitDollars, currentProfitDollars, resultError
  );

  if (resultError != "") {
    return false;
  }
  return true;
}
 