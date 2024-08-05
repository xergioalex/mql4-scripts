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
  int chartIndex = 0;
  long chartID = ChartFirst();
  ChartInfo chartInfo[]; // Array to store chart information
  
  while (chartID >= 0) {
    string symbol = ChartSymbol(chartID); // Get the chart symbol
    
    // Create a ChartInfo object and store the information
    ChartInfo info;
    info.chartID = chartID;
    info.symbol = symbol;
    info.indicatorsTotal = ChartIndicatorsTotal(chartID, 0);
    
    // Store the object in the array
    ArrayResize(chartInfo, ArraySize(chartInfo) + 1);
    chartInfo[ArraySize(chartInfo) - 1] = info;
    
    chartID = ChartNext(chartID);
    chartIndex++;
  }
  
  // Iterate over the array and display the information
  for (int i = 0; i < ArraySize(chartInfo); i++) {
    Alert("Chart ", i + 1, ": Symbol = ", chartInfo[i].symbol, ", Chart ID = ", chartInfo[i].chartID, ", Indicators: ", chartInfo[i].indicatorsTotal);
    
    if (chartInfo[i].indicatorsTotal >= 3) {
       // Cargar la plantilla con el mismo nombre que el símbolo
       string templateName = chartInfo[i].symbol + ".tpl";
       if (ChartApplyTemplate(chartInfo[i].chartID , templateName)) {
         Alert("Template ", templateName, " applied successfully to chart ", chartInfo[i].chartID);
       } else {
         Alert("Failed to apply template ", templateName, " to chart ", chartInfo[i].chartID);
       }
    }
  }
  
  Alert("Total open charts...: ", chartIndex);
  Alert("#############################");
  Alert("#############################");
  Alert("#############################");
}
//+------------------------------------------------------------------+
