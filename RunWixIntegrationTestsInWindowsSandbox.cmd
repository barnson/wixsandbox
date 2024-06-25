setlocal
pushd %~dp0

echo %time%

::// The path to the WiX build tree.
:://
set _WIXBUILD=Z:\src\wix\build

::// The path to folder on the host machine that's shared with the
::// Sandbox VM, as specified in RunWixIntegrationTestsInWindowsSandbox.wsb.
:://
set _WIXSANDBOX=X:\wixsandbox

::// Copy the integration tests to the shared sandbox folder.
:://
robocopy %_WIXBUILD%\IntegrationBurn\Debug\net6.0-windows %_WIXSANDBOX%\IntegrationBurn /MIR
robocopy %_WIXBUILD%\IntegrationMsi\Debug\net6.0-windows  %_WIXSANDBOX%\IntegrationMsi  /MIR

::// Launch, run, and wait for the tests to complete.
:://
start /wait RunWixIntegrationTestsInWindowsSandbox.wsb

echo %time%

popd
endlocal