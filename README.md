# YAMPA - Yet Another Music player App

Simple music player app for Android, Windows, and Linux.

This app is currently in alpha state. Expect bugs and active development.

<a href="https://www.buymeacoffee.com/franlmsp" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-yellow.png" alt="Buy Me A Coffee" height="41" width="174"></a>

## Screenshots

![1](./screenshots/1.png)
![2](./screenshots/2.png)
![3](./screenshots/3.png)
![4](./screenshots/4.png)


## Dependencies
```
apt install libmpv-dev libsqlite3-0 libsqlite3-dev
```

## Building

You can either build the app using Docker by running the `make build/all` command (you can also target a specific platform, see `Makefile`), or install Flutter manually and run `flutter build --release`.

## Downloads

https://github.com/FranLMSP/yampa/releases


## MacOS and iOS support
Even though Flutter has support for MacOS and iOS, I don't currently own a Mac or an iPhone, so I can't build for those platforms.
