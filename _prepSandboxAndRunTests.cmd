pushd %~dp0

::// Install the latest .NET SDK in this directory.
:://
set s="Did not find .NET SDK"
for /f %%i in ('dir /od /b dotnet-sdk*.exe') do set s=%%i
%s% /passive /install /norestart

::// Need to manually add `dotnet` to the path, as the installer
::// can't touch environment variables in the current process.
:://
set PATH=C:\Program Files\dotnet\;%PATH%

::// Run the tests we copied before launching the Sandbox.
:://
pushd IntegrationBurn
start /wait %COMSPEC% /c runtests.cmd
popd

pushd IntegrationMsi
start /wait %COMSPEC% /c runtests.cmd
popd

::// In an ideal world, this would cleanly shut down the Sandbox VM.
::// In our world, it "crashes" the Sandbox VM, or least the viewer.
::// Maybe it's better in Windows 11?
:://
shutdown /s /t 1

popd
