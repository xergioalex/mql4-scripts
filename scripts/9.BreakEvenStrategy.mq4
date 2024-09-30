//+------------------------------------------------------------------+
//|                                          BreakEvenWithParams.mq4 |
//|                                      Copyright 2024, XergioAleX. |
//|                                       https://www.xergioalex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, XergioAleX."
#property link      "https://www.xergioalex.com"
#property version   "1.00"
#property strict
#include <stdlib.mqh>

// Start program to start the function.
void OnStart() {
  Print("#######################################");
  Print("##### • START BREAK EVEN SCRIPT • #####");
  Print("");
  
  StartBreakEvenStrategy();

  Print("");
  Print("##### • END BREAK EVEN SCRIPT • #####");
  Print("#####################################");
}


void StartBreakEvenStrategy() {
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
  Print("Orders total: ", ordersTotal);

  // If no orders found, exit
  if (ordersTotal == 0) {
    Print("No orders found.");
    return;
  }

  int ordersModified = 0;
  double profitDollarsToSet = 10;
  // Loop through all orders
  for (int i = 0; i < ordersTotal; i++) {
    // Select order by position
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      Print("ERROR - Unable to select the order: ", GetLastError());
      continue;
    }

    // Apply break even strategy to the order
    if (ApplyOrderBreakEven()) {
      ordersModified++;
    }
  }

  Print("Total orders modified: ", ordersModified);
}


double GetPipValueMultiplier() {
  // Return pip value multiplier based on the number of digits
  if (Digits == 5 || Digits == 3 || Digits == 2) {
    return MathPow(10, Digits);
  } else {
    return 0;
  }
}

string GetOrderTypeStr(int orderType) {
  // Return order type as string
  switch(orderType) {
    case OP_BUY:
      return "Buy";
    case OP_SELL:
      return "Sell";
    case OP_BUYLIMIT:
      return "Buy Limit";
    case OP_SELLLIMIT:
      return "Sell Limit";
    case OP_BUYSTOP:
      return "Buy Stop";
    case OP_SELLSTOP:
      return "Sell Stop";
    default:
      return "Unknown";
  }
}

double ShouldApplyBreakEvenToTheOrder(double riskDollars, double profitDollars, double currentProfitDollars) {
  // Verify if we can calculate the break even
  if ((!riskDollars > 0 && profitDollars > 0 && currentProfitDollars != 0)) {
    return false;
  } 

  // Depending on the current profit, we will calculate the break even in dollars
  double PERCENTAGE_OF_PROFIT_TO_BREAK_EVEN = 40;
  if (currentProfitDollars > 0) {
    double positiveProfitPercentage = (currentProfitDollars * 100) / profitDollars;
    Print("Positive Profit Percentage: ", positiveProfitPercentage);
    if (MathAbs(positiveProfitPercentage) > 40) {
      return true;
    }
  } else {
    double negativeProfitPercentage = (currentProfitDollars * 100) / riskDollars;
    Print("Negative Profit Percentage: ", negativeProfitPercentage);
    if (MathAbs(negativeProfitPercentage) > 40) {
      return true;
    }
  }
  return false;
}

double CalcBreakEvenDollars(double orderCommission, double orderSwap) {
  // Calculate break even in dollars
  double breakEvenDollars = (orderCommission + (orderCommission * 0.10)) + orderSwap;
  if (breakEvenDollars > 0) {
    breakEvenDollars = orderCommission;
  }
  return MathAbs(breakEvenDollars);
}

bool ApplyOrderBreakEven() {
  // Get order details
  int orderType = OrderType();
  if (!(orderType == OP_BUY || orderType == OP_SELL)) {
    return false;
  }
  int orderTicket = OrderTicket();
  string orderSymbol = OrderSymbol();
  double orderOpenPrice = OrderOpenPrice();
  double orderLotsSize = OrderLots();
  double orderStopLoss = OrderStopLoss();
  double orderTakeProfit = OrderTakeProfit();
  datetime orderExpiration = OrderExpiration();
  double orderCommission = OrderCommission();
  double orderSwap = OrderSwap();
  
  // Calculate risk and profit in dollars
  double pipValue = MarketInfo(orderSymbol, MODE_TICKVALUE);
  double pipValueMultiplier = GetPipValueMultiplier();

  // If pip value multiplier is 0, continue to the next order
  if (pipValueMultiplier == 0) {
    return false;
  }
  double profitDollars = 0.0;  
  double riskDollars = 0.0; 
  double lotSizePipValue = (orderLotsSize * pipValue);
  
  if (orderType == OP_BUY) {
    if (orderStopLoss > orderOpenPrice) {
      return false;
    }

    // Calculate risk and profit in pips and dollars
    double riskPipDiff = (orderOpenPrice - orderStopLoss);
    double profitPipDiff = (orderTakeProfit - orderOpenPrice);
    riskDollars = (riskPipDiff * lotSizePipValue) * pipValueMultiplier;
    profitDollars = (profitPipDiff * lotSizePipValue) * pipValueMultiplier;
    
    // Calculate current profit in dollars
    double currentProfitDollars = OrderProfit();

    // Verify if we should apply break even to the order
    if (!ShouldApplyBreakEvenToTheOrder(riskDollars, profitDollars, currentProfitDollars)) {
      Print("Should NOT apply break even to the order");
      return false;
    }

    // Calculate break even in dollars
    double breakEvenDollars = CalcBreakEvenDollars(orderCommission, orderSwap);
    double profitPips = breakEvenDollars / lotSizePipValue;
    if (currentProfitDollars > 0) {
      orderStopLoss = orderOpenPrice + (profitPips * Point);
    } else {
      orderTakeProfit = orderOpenPrice + (profitPips * Point);
    }
  } else if (orderType == OP_SELL) {
    if (orderOpenPrice > orderStopLoss) {
      return false;
    }

    // Calculate risk and profit in pips and dollars
    double riskPipDiff = (orderStopLoss - orderOpenPrice);
    double profitPipDiff = (orderOpenPrice - orderTakeProfit);
    riskDollars = (riskPipDiff * lotSizePipValue) * pipValueMultiplier;
    profitDollars = (profitPipDiff * lotSizePipValue) * pipValueMultiplier;

    // Calculate current profit in dollars
    double currentProfitDollars = OrderProfit();

    // Verify if we should apply break even to the order
    if (!ShouldApplyBreakEvenToTheOrder(riskDollars, profitDollars, currentProfitDollars)) {
      Print("Should NOT apply break even to the order");
      return false;
    }
    
    // Calculate break even in dollars
    double breakEvenDollars = CalcBreakEvenDollars(orderCommission, orderSwap);
    double profitPips = breakEvenDollars / lotSizePipValue;
    if (currentProfitDollars > 0) {
      orderStopLoss = orderOpenPrice - (profitPips * Point);
    } else {
      orderTakeProfit = orderOpenPrice - (profitPips * Point);
    }
  }

  // Modify order
  if (!OrderModify(orderTicket, orderOpenPrice, orderStopLoss, orderTakeProfit, orderExpiration, clrNONE)) {
    Print("Error on Buy Order: ", ErrorDescription(GetLastError()));
    return false;
  }
  
  // Print order details
  string orderTypeStr = GetOrderTypeStr(orderType);
  Print("Order #", orderTicket, ": Symbol = ", orderSymbol, ", Type = ", orderTypeStr, ", Price = ", orderOpenPrice, ", Lot Size = ", orderLotsSize, ", Stop Loss = ", orderStopLoss, ", Take Profit = ", orderTakeProfit, ", Risk ($) = ", riskDollars, ", Profit ($) = ", profitDollars);
  return true;
}