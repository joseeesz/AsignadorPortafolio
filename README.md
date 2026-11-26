
Jose Luis Sanchez Davila · jlsd

Herramienta para decidir como repartir una inversion entre IVV, QQQ, IEF, GLD y BIL (SIC), NAFTRAC y CETES 28 dias, todo medido en pesos. Estima el riesgo con GJR GARCH y DCC, compara 10 estrategias en un backtest fuera de muestra desde 2012 con comisiones de GBM, valida el VaR al 99% y simula escenarios a un año en R. Al final da las ordenes de compra y venta y guarda el Reporte final con la fecha.

    main.ipynb          todo el proceso y el panel de decision
    R/escenarios.R      escenarios a un año (solo R base)
    actualizar.bat      corre todo y abre el ultimo reporte
    tokenbanxico.txt    token de Banxico para la tasa de CETES
    resultados          reportes, ordenes, metricas e historial

