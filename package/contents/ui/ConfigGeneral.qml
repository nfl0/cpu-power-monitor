import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: settings

    // property alias cfg_updateInterval: updateInterval.value
    property alias cfg_makeFontBold: makeFontBold.checked
    property var doesntHaveFixCommand: 1

    Plasma5Support.DataSource {
        id: executable

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)

        function exec(cmd) {
            if (cmd)
                connectSource(cmd);

        }

        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"];
            var exitStatus = data["exit status"];
            var stdout = data["stdout"];
            var stderr = data["stderr"];
            console.log(exitCode);
            console.log(exitStatus);
            console.log(stdout);
            console.log(stderr);
            exited(sourceName, exitCode, exitStatus, stdout, stderr);
            disconnectSource(sourceName);
        }
        onExited: {
            settings.doesntHaveFixCommand = stdout.trim();
        }
    }

    ColumnLayout {
        // RowLayout {
        //     SpinBox {
        //         // textFromValue: i18nc("Abbreviation for seconds", "s")
        //         id: updateInterval
        //         readonly property int decimalFactor: 10
        //         function decimalToInt(decimal) {
        //             return decimal * decimalFactor;
        //         }
        //         value: decimalToInt(1)
        //         stepSize: decimalToInt(0.1)
        //         from: decimalToInt(0.1)
        //         to: decimalToInt(4)
        //     }
        // Label {
        //     id: updateIntervalLabel
        //     text: i18n("Update interval:")
        // }
        // }

        CheckBox {
            id: makeFontBold

            text: i18n("Bold Text")
        }

        PlasmaComponents.Button {
            // iconSource: ""
            text: i18n('Add "Fix Permission" to CronJobs')
            onPressed: {
                // executable.exec('pkexec crontab -l | grep "@reboot chmod 444 /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/energy_uj" > /dev/null ; echo $?')
                // if (settings.doesntHaveFixCommand=='1'){
                // executable.connectSource('pkexec bash -c "crontab -l > ~/cron_bkp && echo @reboot chmod 444 /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/energy_uj >> ~/cron_bkp && crontab ~/cron_bkp && rm ~/cron_bkp" ')
                executable.connectSource('pkexec bash -c "crontab -l | grep @reboot | grep chmod | grep 444 | grep /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/energy_uj > /dev/null" ; if [[ $? -eq 1 ]]; then pkexec bash -c "echo yes && crontab -l > ~/cron_bkp && echo @reboot chmod 444 /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/energy_uj >> ~/cron_bkp && crontab ~/cron_bkp && rm ~/cron_bkp" ; fi');
            }
        }

    }

}
