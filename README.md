# Running WiX runtime tests in Windows Sandbox

WiX v4 includes both unit tests and runtime tests. The unit tests validate portions of the core toolset and are run as part of local developer builds and CI builds. The WiX runtime tests do more than the unit tests by actually running MSI packages and bundles. They require elevation and do all sorts of things that you don't want to do on a machine you care about -- especially if you're in the middle of implementing a feature or fixing a bug. The WiX CI build runs the runtime tests because the CI build runs elevated and on VMs that are automatically disposed of when the build completes. That's normally good enough to get feedback on a pull request, but it does take about an hour to get the test results back. That delay can be a bit annoying, especially if you nedd a couple of commits to get your code working...not that I've ever had to do that...

During [WiX Online Meeting 236][236], we were discussing how the WiX runtime tests work and the idea of using the [Windows Sandbox][wsb] came up. Windows Sandbox was introduced in Windows 10 and provides a lightweight bare VM that "evaporates" when shut down. It's based on Hyper-V so it's nothing that you couldn't put together using a "normal" Hyper-V VM, but Sandbox is really convenient, supports batch files and shared folders, and it boots quickly: on the order of about five seconds on my dev box.

So what would it take to run the WiX runtime tests in Windows Sandbox? It turns out, just two batch files and one XML file. You can get those files by cloning [the wixsandbox repo on GitHub][wixsandbox] and modifying the files as appropriate for your machine.

## Windows Sandbox configuration

[You can configure Windows Sandbox in a few ways.][wsbconfig] There are two bits of configuration that are interesting for automating the WiX runtime tests:

- Mapped folders allow us to get the WiX tests into the Sandbox VM.
- Logon commands let us automatically prepare the Sandbox VM and run the tests.

Here's the mapped folder I configured in `RunWixIntegrationTestsInWindowsSandbox.wsb`:

    <MappedFolders>
        <MappedFolder>
            <HostFolder>X:\wixsandbox</HostFolder>
            <SandboxFolder>C:\wixsandbox</SandboxFolder>
            <ReadOnly>false</ReadOnly>
        </MappedFolder>
    </MappedFolders>

This configuration maps the `X:\wixsandbox` folder on my dev box to `C:\wixsandbox` in the Sandbox VM. I set `ReadOnly` to false so the tests can run directly in `C:\wixsandbox`, writing whatever files they need to run. More importantly, the log files that the tests write are available from the host machine after the Sandbox VM shuts down.

You'll want to change the `HostFolder` value to a folder on your own machine. You can use the same directory where you checked out [the wixsandbox repo][wixsandbox].

The logon command lets us run a script when the Sandbox VM starts. We need that capability because the Sandbox VM as-is isn't quite up to running the WiX runtime tests. But first, we need to prepare the VM.


## Batch file #1: Preparing the mapped folder and starting the Sandbox

`RunWixIntegrationTestsInWindowsSandbox.cmd` copies the runtime tests to the folder that's mapped into the Sandbox VM, then starts the VM with the configuration file to do the actual work by running the other batch file. The paths to the tests and the shared folder need to be edited. Modify these lines as appropriate:

    set _WIXBUILD=Z:\src\wix4\build
    set _WIXSANDBOX=X:\wixsandbox

The rest of the file can be used as-is.


## Batch file #2: Preparing the Sandbox VM and running the tests

[Every time Windows Sandbox runs, it's as clean as a brand-new installation of Windows.][wsb] That's great...except when you need a prerequisite of some sort. That's exactly the case we're facing with the WiX runtime tests. They're written in C# and need the .NET SDK. 

We'll take advantage of the Windows Sandbox configuration file to run a batch file -- inside the Sandbox VM! -- that installs the .NET SDK. To do that, it needs a copy of the .NET SDK. [You can download the latest version here. As of this writing, the latest version of the .NET 6 SDK works fine for running the WiX tests. You'll want the `x64` version, assuming you're running an `x64` version of Windows.][sdk] For me, that's `dotnet-sdk-6.0.300-win-x64.exe`. Put the SDK installer in the root of the folder you specified as `HostFolder`. (I considered downloading the SDK but it's over 200MB and I decided that a one-time download was better for the environment.)

`_prepSandboxAndRunTests.cmd` is the batch file specified in the `RunWixIntegrationTestsInWindowsSandbox.wsb` configuration file. Windows Sandbox runs it when the Sandbox VM starts. It installs the .NET SDK and runs the WiX tests.


## Examining test results



[236]: https://www.youtube.com/watch?v=rkP-BpU1DII
[wsb]: https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview
[wsbconfig]: https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file
[sdk]: https://dotnet.microsoft.com/en-us/download/dotnet/6.0
[wixsandbox]: https://github.com/barnson/wixsandbox
