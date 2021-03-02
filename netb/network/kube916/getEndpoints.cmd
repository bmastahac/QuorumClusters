@ECHO OFF
SETLOCAL
SET NUMBER_OF_NODES=2
SET /A NODE_NUMBER=%1

if "%1"=="" (
    echo Please provide the number of the node to attach to (i.e. attach.cmd 2^) && EXIT /B 1
)

if %NODE_NUMBER% EQU 0 (
    echo Please provide the number of the node to attach to (i.e. attach.cmd 2^) && EXIT /B 1
)

if %NODE_NUMBER% GEQ %NUMBER_OF_NODES%+1 (
    echo %1 is not a valid node number. Must be between 1 and %NUMBER_OF_NODES%. && EXIT /B 1
)

minikube ip >nul 2>&1
if ERRORLEVEL 1 (
  FOR /f "delims=" %%g IN ('minikube ip') DO set IP_ADDRESS=%%g
) else (
  set IP_ADDRESS=localhost
)

FOR /f "delims=" %%g IN ('minikube ip 2^>nul ^|^| echo localhost') DO set IP_ADDRESS=%%g

FOR /F "tokens=* USEBACKQ" %%g IN (`kubectl get service quorum-node%NODE_NUMBER% -o^=jsonpath^="{range.spec.ports[?(@.name=='rpc-listener')]}{.nodePort}"`) DO set QUORUM_PORT=%%g

FOR /F "tokens=* USEBACKQ" %%g IN (`kubectl get service quorum-node%NODE_NUMBER% -o^=jsonpath^="{range.spec.ports[?(@.name=='tm-tessera-third-part')]}{.nodePort}"`) DO set TESSERA_PORT=%%g

echo quorum rpc: http://%IP_ADDRESS%:%QUORUM_PORT%
echo tessera 3rd party: http://%IP_ADDRESS%:%TESSERA_PORT%

kubectl get service cakeshop-service >nul 2>&1
if ERRORLEVEL 1 (
  FOR /F "tokens=* USEBACKQ" %%g IN (`kubectl get service cakeshop-service -o^=jsonpath^="{range.spec.ports[?(@.name=='http')]}{.nodePort}"`) DO set CAKESHOP_PORT=%%g
  echo cakeshop: http://%IP_ADDRESS%:%CAKESHOP_PORT%
)

kubectl get service quorum-monitor >nul 2>&1
if ERRORLEVEL 1 (
  FOR /F "tokens=* USEBACKQ" %%g IN (`kubectl get service quorum-monitor -o^=jsonpath^="{range.spec.ports[?(@.name=='prometheus')]}{.nodePort}"`) DO set PROMETHEUS_PORT=%%g
  echo prometheus: http://%IP_ADDRESS%:%PROMETHEUS_PORT%
)