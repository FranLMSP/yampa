FROM mcr.microsoft.com/windows/servercore:ltsc2019

RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    Invoke-WebRequest -Uri https://aka.ms/install-winget -OutFile install-winget.ps1; \
    powershell -ExecutionPolicy Bypass -File install-winget.ps1; \
    Remove-Item install-winget.ps1 -Force

RUN winget install --id Git.Git -e --source winget; \
    winget install --id Microsoft.VisualStudio.2019.BuildTools -e --source winget; \
    winget install --id Microsoft.VisualStudio.2019.DesktopDevelopment -e --source winget

ENV FLUTTER_VERSION=stable
ENV FLUTTER_HOME=C:/flutter
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

RUN powershell -Command \
    Invoke-WebRequest -Uri https://storage.googleapis.com/flutter_infra/releases/stable/windows/flutter_windows_${FLUTTER_VERSION}-stable.zip -OutFile flutter.zip; \
    Expand-Archive flutter.zip -DestinationPath C:/; \
    Remove-Item flutter.zip -Force

RUN winget install --id Microsoft.VisualStudio.2019.DesktopDevelopment -e --source winget

RUN flutter doctor

WORKDIR /app

COPY . /app

CMD ["flutter", "build", "windows", "--release"]
