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
      bool isIntraday;
  };

void OnStart() {  
   long chartID = ChartID();
   string symbol = ChartSymbol(chartID); // Get the chart symbol
    
   // Create a ChartInfo object and store the information
   ChartInfo info;
   info.chartID = chartID;
   info.symbol = symbol;
   info.indicatorsTotal = ChartIndicatorsTotal(chartID, 0);
   info.isIntraday = false;

   for (int i = 0; i < info.indicatorsTotal; i++) {
      string indicatorName = ChartIndicatorName(info.chartID, 0, i);
      if (StringFind(indicatorName, "Intraday") != -1) {
         info.isIntraday = true;
      }
   }
   
   Print("Symbol = ", info.symbol, ", Chart ID = ", info.chartID, ", Indicators: ", info.indicatorsTotal, ", Intraday: ", info.isIntraday);
     
   string templateName = info.symbol;
   if (StringFind(templateName, ".") != -1) {
      templateName = templateName + "tpl";
   } else {
      templateName = templateName + ".tpl";
   }
   if (StringFind(templateName, "SPX500") != -1) {
      templateName = "US500.tpl";
   }
   if (StringFind(templateName, "DE30") != -1) {
      templateName = "DE40.tpl";
   }
   if (StringFind(templateName, "GER40") != -1) {
      templateName = "DE40.tpl";
   }

   if (info.isIntraday) {
      templateName = "Intraday" + templateName;
   }
   
   if (ChartSaveTemplate(info.chartID, templateName)) {
      Print("Template ", templateName, " saved successfully to chart ", info.chartID);
   } else {
      Print("Failed to save template ", templateName, " to chart ", info.chartID);
   }
}
//+------------------------------------------------------------------+
