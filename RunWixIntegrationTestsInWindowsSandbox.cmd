setlocal
pushd %~dp0

::// The path to the WiX build tree.
:://
set _WIXBUILD=Z:\src\wix4\build

::// The path to folder on the host machine that's shared with the
::// Sandbox VM, as specified in RunWixIntegrationTestsInWindowsSandbox.wsb.
:://
set _WIXSANDBOX=X:\wixsandbox

::// Copy the integration tests to the shared sandbox folder.
:://
robocopy %_WIXBUILD%\IntegrationBurn\Debug\netcoreapp3.1 %_WIXSANDBOX%\IntegrationBurn /MIR
robocopy %_WIXBUILD%\IntegrationMsi\Debug\netcoreapp3.1  %_WIXSANDBOX%\IntegrationMsi  /MIR

::// Launch, run, and wait for the tests to complete.
:://
start /wait RunWixIntegrationTestsInWindowsSandbox.wsb

popd
endlocal