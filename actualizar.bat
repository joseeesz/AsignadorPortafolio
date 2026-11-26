@echo off
rem jlsd, corre todo y abre el ultimo reporte
cd /d "%~dp0"
python -m jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=3600 main.ipynb
for /f "delims=" %%f in ('dir /b /o:d "resultados\Reporte final*.html"') do set ultimo=%%f
start "" "resultados\%ultimo%"
