# Power Monitor
Another stupidly simple KDE Plasma 5 widget to monitor the power consumption of your CPU (only) in real time.

This is a fork of [Power Monitor](https://github.com/atul-g/plasma-power-monitor). The original measures the battery power consumption while this extension measures only <b>Intel</b> CPU's power.

## Preview
Widget as shown on desktop

![Widget on Desktop](images/desktop.png)

Widget as shown on taskbar

![Widget on Taskbar](images/taskbar.png)


## Installation

To install this, right click on the desktop, click on `Add Widgets`, select `Get New Widgets`, select `Download New Plasma Widgets` and search for `CPU Power Monitor`. Install it by pressing the install button.

## Customization

1. Update Interval: Changes the rate at which the widget updates
2. Bold Text: Changes display text to <b>Bold</b>
3. Add "Fix Permission" to CronJobs: Adds a cron job to <b> root's </b> cron list to fix sensor permission when the system reboots. When clicked,
   * If it asked for the sudo password <b> twice</b>, this fix is successfully installed.
   * If it asked for the sudo password only <b> once</b>, the fix is already installed.

### Note
1. The widget displays power consumption in Watts.
2. This widget makes use of the `/sys/class/powercap/intel-rapl:0/energy_uj` file to query the energy consumption. If the widget displays "PERM", then you either 
    * don't have this file in your OS, or
    * don't have the permission to read the said file.
3. If later is the case, try:
    * click on `Add Fix Permission to CronJobs` in the settings menu and enter the password when asked(either once or twice) (Permanent).
    * select `Fix Sensor Permission` in the right click menu as seen below and enter your Super User password. (Temporary, resets on reboot)
    
    
    ![Fix permission](images/fixPermission.png)
    
    
    * running `sudo chmod 444 /sys/class/powercap/intel-rapl:0/energy_uj` in konsole and see if the issue is fixed. (Temporary, resets on reboot)
4. The power usage rises continously when the laptop is plugged in to A/C power. It is normal if you see high readings.
5. This will only work for <b>Intel CPUs</b>.
