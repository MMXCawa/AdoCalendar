$ErrorActionPreference = "Stop"

$projectDirectory = $PSScriptRoot
$mainFile = Join-Path $projectDirectory "src\main.zm"
$iconFile = Join-Path $projectDirectory "icon.ico"

if (-not (Test-Path -LiteralPath $mainFile -PathType Leaf)) {
    throw "Zamak source file not found: $mainFile"
}
if (-not (Test-Path -LiteralPath $iconFile -PathType Leaf)) {
    throw "Application icon not found: $iconFile"
}
if (-not (Get-Command zam -ErrorAction SilentlyContinue)) {
    throw "Zamak compiler 'zam' is not available on PATH."
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
Push-Location $projectDirectory
try {
    $buildOutput = & zam build . 2>&1
} finally {
    Pop-Location
}
$buildExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
$buildOutput | ForEach-Object { Write-Host $_ }
if ($buildExitCode -ne 0) {
    throw "Zamak build failed with exit code $buildExitCode."
}

$outputLine = $buildOutput | ForEach-Object { "$_" } |
    Where-Object { $_ -match '^OUTPUT\s+(.+\.exe)\s*$' } |
    Select-Object -Last 1
if (-not $outputLine -or $outputLine -notmatch '^OUTPUT\s+(.+\.exe)\s*$') {
    throw "Could not determine the executable path from zam build output."
}
$exeFile = $Matches[1].Trim()
if (-not [IO.Path]::IsPathRooted($exeFile)) {
    $exeFile = [IO.Path]::GetFullPath((Join-Path $projectDirectory $exeFile))
}
if (-not (Test-Path -LiteralPath $exeFile -PathType Leaf)) {
    throw "Built executable not found: $exeFile"
}

$resourceEditor = @'
using System;
using System.IO;
using System.Runtime.InteropServices;

public static class ExeIconResource
{
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern IntPtr BeginUpdateResource(string fileName, bool deleteExistingResources);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool UpdateResource(
        IntPtr update,
        IntPtr type,
        IntPtr name,
        ushort language,
        byte[] data,
        uint dataSize);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool EndUpdateResource(IntPtr update, bool discard);

    private static IntPtr ResourceId(ushort id)
    {
        return new IntPtr(id);
    }

    public static void Set(string exePath, string icoPath)
    {
        byte[] ico = File.ReadAllBytes(icoPath);
        if (ico.Length < 6 || ico[0] != 0 || ico[1] != 0 || ico[2] != 1 || ico[3] != 0)
            throw new InvalidDataException("The icon file is not a valid .ico file.");

        int count = ico[4] | (ico[5] << 8);
        if (count == 0 || ico.Length < 6 + count * 16)
            throw new InvalidDataException("The icon file has an invalid image directory.");

        byte[] group = new byte[6 + count * 14];
        Buffer.BlockCopy(ico, 0, group, 0, 4);
        group[4] = (byte)count;
        group[5] = (byte)(count >> 8);

        IntPtr update = BeginUpdateResource(exePath, false);
        if (update == IntPtr.Zero)
            throw new Win32ExceptionWithCode("BeginUpdateResource failed");

        bool ended = false;
        try
        {
            for (int i = 0; i < count; i++)
            {
                int source = 6 + i * 16;
                int destination = 6 + i * 14;
                uint size = BitConverter.ToUInt32(ico, source + 8);
                uint offset = BitConverter.ToUInt32(ico, source + 12);
                if (size == 0 || offset > ico.Length || size > ico.Length - offset)
                    throw new InvalidDataException("The icon file contains an invalid image entry.");

                ushort iconId = (ushort)(i + 1);
                byte[] image = new byte[size];
                Buffer.BlockCopy(ico, (int)offset, image, 0, (int)size);
                if (!UpdateResource(update, ResourceId(3), ResourceId(iconId), 0x0409, image, size))
                    throw new Win32ExceptionWithCode("Writing an icon image resource failed");

                Buffer.BlockCopy(ico, source, group, destination, 8);
                Buffer.BlockCopy(BitConverter.GetBytes(size), 0, group, destination + 8, 4);
                Buffer.BlockCopy(BitConverter.GetBytes(iconId), 0, group, destination + 12, 2);
            }

            if (!UpdateResource(update, ResourceId(14), ResourceId(1), 0x0409, group, (uint)group.Length))
                throw new Win32ExceptionWithCode("Writing the icon group resource failed");
            if (!EndUpdateResource(update, false))
                throw new Win32ExceptionWithCode("Saving icon resources failed");
            ended = true;
        }
        finally
        {
            if (!ended)
                EndUpdateResource(update, true);
        }
    }

    public static void AddEmbeddedProgram(string launcherPath, string programPath)
    {
        byte[] program = File.ReadAllBytes(programPath);
        IntPtr update = BeginUpdateResource(launcherPath, false);
        if (update == IntPtr.Zero)
            throw new Win32ExceptionWithCode("BeginUpdateResource failed");

        bool ended = false;
        try
        {
            if (!UpdateResource(update, ResourceId(10), ResourceId(101), 0x0409, program, (uint)program.Length))
                throw new Win32ExceptionWithCode("Embedding the application failed");
            if (!EndUpdateResource(update, false))
                throw new Win32ExceptionWithCode("Saving the embedded application failed");
            ended = true;
        }
        finally
        {
            if (!ended)
                EndUpdateResource(update, true);
        }
    }

    private sealed class Win32ExceptionWithCode : Exception
    {
        public Win32ExceptionWithCode(string operation)
            : base(operation + " (Win32 error " + Marshal.GetLastWin32Error() + ").")
        {
        }
    }
}
'@

Add-Type -TypeDefinition $resourceEditor
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$releaseFile = Join-Path $projectDirectory "build\main_$timestamp.exe"
$singleFileSource = @'
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;

public static class SingleFileCalendar
{
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int MessageBox(IntPtr window, string text, string caption, uint type);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    private static extern IntPtr GetModuleHandle(string moduleName);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr FindResource(IntPtr module, IntPtr name, IntPtr type);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr LoadResource(IntPtr module, IntPtr resource);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr LockResource(IntPtr resourceData);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern uint SizeofResource(IntPtr module, IntPtr resource);

    private static IntPtr ResourceId(ushort id)
    {
        return new IntPtr(id);
    }

    public static int Main()
    {
        string extractedProgram = null;
        try
        {
            IntPtr module = GetModuleHandle(null);
            IntPtr resource = FindResource(module, ResourceId(101), ResourceId(10));
            if (resource == IntPtr.Zero)
                throw new InvalidOperationException("Embedded application resource was not found.");

            uint size = SizeofResource(module, resource);
            IntPtr loadedResource = LoadResource(module, resource);
            IntPtr resourceData = LockResource(loadedResource);
            if (size == 0 || resourceData == IntPtr.Zero)
                throw new InvalidOperationException("Embedded application resource could not be read.");

            byte[] program = new byte[size];
            Marshal.Copy(resourceData, program, 0, program.Length);
            extractedProgram = Path.Combine(Path.GetTempPath(), "ADOCalendar-" + Guid.NewGuid().ToString("N") + ".exe");
            File.WriteAllBytes(extractedProgram, program);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = extractedProgram;
            startInfo.WorkingDirectory = Path.GetDirectoryName(extractedProgram);
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.WindowStyle = ProcessWindowStyle.Hidden;
            using (Process application = Process.Start(startInfo))
            {
                if (application == null)
                    throw new InvalidOperationException("Windows could not create the application process.");
                application.WaitForExit();
                return application.ExitCode;
            }
        }
        catch (Exception error)
        {
            MessageBox(IntPtr.Zero, "The application could not be started:\r\n" + error.Message, "ADOCalendar startup error", 0x10);
            return 1;
        }
        finally
        {
            if (extractedProgram != null)
            {
                try
                {
                    File.Delete(extractedProgram);
                }
                catch (Exception cleanupError)
                {
                    MessageBox(IntPtr.Zero, "The application closed, but its temporary file could not be removed:\r\n" + cleanupError.Message, "ADOCalendar cleanup warning", 0x30);
                }
            }
        }
    }
}
'@
Add-Type -TypeDefinition $singleFileSource -OutputAssembly $releaseFile -OutputType WindowsApplication
[ExeIconResource]::Set($releaseFile, $iconFile)
[ExeIconResource]::AddEmbeddedProgram($releaseFile, $exeFile)
Write-Host "Embedded icon: $iconFile"
Write-Host "Build artifact: $exeFile"
Write-Host "Single-file GUI executable (no console): $releaseFile"
