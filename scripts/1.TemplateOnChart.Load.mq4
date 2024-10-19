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
  //for (int k = 0; k < 30; k++) {
  //  Alert("");
  //}
  
   long chartID = ChartID();
   string symbol = ChartSymbol(chartID); // Get the chart symbol
    
   // Create a ChartInfo object and store the information
   ChartInfo info;
   info.chartID = chartID;
   info.symbol = symbol;
   info.indicatorsTotal = ChartIndicatorsTotal(chartID, 0);
   
   Print("Symbol = ", info.symbol, ", Chart ID = ", info.chartID, ", Indicators: ", info.indicatorsTotal);
    
   string templateName = info.symbol;
   if (StringFind(templateName, ".") != -1) {
      templateName = templateName + "tpl";
   } else {
      templateName = templateName + ".tpl";
   }
   if (StringFind(templateName, "SPX500") != -1) {
      templateName = "US500.tpl";
   }
   
   if (ChartApplyTemplate(info.chartID, templateName)) {
      Print("Template ", templateName, " applied successfully to chart ", info.chartID);
   } else {
      Print("Failed to apply template ", templateName, " to chart ", info.chartID);
   }
   //Alert("#############################");
   //Alert("#############################");
   //Alert("#############################");
}
//+------------------------------------------------------------------+
