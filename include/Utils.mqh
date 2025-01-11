double GetPipValueMultiplier(int orderDigits) {
  // Return pip value multiplier based on the number of digits
  if (orderDigits == 5 || orderDigits == 3 || orderDigits == 2) {
    return MathPow(10, orderDigits);
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

void PrintOrderDetails(
  int orderTicket, 
  string orderSymbol, 
  int orderType, 
  int orderDigits, 
  double orderOpenPrice, 
  double orderLotsSize, 
  double orderStopLoss, 
  double orderTakeProfit, 
  double riskDollars, 
  double profitDollars,
  double currentProfitDollars,
  string resultError = ""
) {
  string orderTypeStr = GetOrderTypeStr(orderType);
  Print("Order #", orderTicket, ": Symbol = ", orderSymbol, ", Type = ", orderTypeStr, ", Digits = ", orderDigits, ", Price = ", orderOpenPrice, ", Lot Size = ", orderLotsSize, "Take Profit = ", orderTakeProfit, ", Stop Loss = ", orderStopLoss);
  Print("Risk ($) = ", riskDollars, ", Profit ($) = ", profitDollars, ", Current Profit ($) = ", currentProfitDollars);
  
  if (resultError != "") {
    Print("ERROR: ", resultError);
  } else {
    Print("SUCCESS:Order modified successfully.");
  }
  Print("---");
}