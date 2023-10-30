# Default App

Build on Windows in PowerShell

```shell
$Env:GOARCH="arm64"; $Env:GOOS="linux" ; go build .\cmd\bootstrap
```

Build On Linux:

```shell


GOARCH="arm64" GOOS="linux" go build cmd/bootstrap
```

