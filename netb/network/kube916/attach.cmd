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

FOR /f "delims=" %%g IN ('kubectl get pod --field-selector=status.phase^=Running -o name ^| findstr quorum-node%NODE_NUMBER%') DO set POD=%%g
ECHO ON
kubectl exec -it %POD% -c quorum -- /geth-helpers/geth-attach.sh