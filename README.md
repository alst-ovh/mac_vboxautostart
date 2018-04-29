# mac_vboxautostart

Auto Starting VirtualBox VM's on OS X

## Getting Started

I run Virtualbox with a bunch VM's on a Mac Mini in Headless Mode.

The Autostart works and you can Start Stop the VM's in Ordered Mode.

A clean Shutdown with the Powerkey is also possible

And with an Cyperpower UPS it does a clean Shutdown if Power fails.

Works with:

macOS High Sierra 10.13.4

Virtualbox 5.2.10

### Prerequisites

What things you need to install the software and how to install them

* [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
* [Midnight Commander](http://louise.hu/poet/midnight-commander-for-mac-os-x/) - optional for better editing
* [PowerKey](https://github.com/pkamb/PowerKey) - optional Shutdown with PowerKey
* [PowerPanel](https://www.cyberpowersystems.de/produkte/usv-zubehoer/software-powerpanel/pp-mac-edition.html) -optional CyberPower UPS

### Installing

Install/Uninstall:
```
Download and run install.sh, there is also a uninstall.sh
```

## Running

Generate Config:
```
vbox.sh cfg
```
Start All:
```
vbox.sh startall
```

Stop All:
```
vbox.sh stopall
```

## Authors

* **Albert Steiner** - *Initial work* - [alst-ovh](https://github.com/alst-ovh)

## License

This project is licensed under the GNU General Public License v2.0 - see the [LICENSE](LICENSE) file for details
