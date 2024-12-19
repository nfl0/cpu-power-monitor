/*
 * Copyright 2024 Phani Pavan K <kphanipavan@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/gpl-3.0.html>.
 */

import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmoidItem { // Main component of the plasmoid
    id: root // Reference name of the main component
    preferredRepresentation: fullRepresentation
    property var power: "FX-PR" // Variable used for holding the text to display in the widget
    property double oldNRG: 0 // State variable, to hold old energy value
    property double newNRG: 0 // State variable, used for storing new energy value
    property double oldTime: 0 // State variable, to store old time
    property string raplPath: "/sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/energy_uj" // Path to file which stores the energy information

    // The main UI component, shows simple text
    fullRepresentation: PlasmaComponents.Label {
        id: output
        text: root.power
        fontSizeMode: Text.Fit
        anchors.fill: parent
        font.pixelSize: 1000
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: plasmoid.configuration.bold
    }

    // Command execution engine. Runs the cat and chmod commands
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function (source, data) {
            // when a command is executed, store the output of the command into stdout variable.
            // Only 2 commands are executed.
            // chmod to fix the file permission, which doesn't produce any output
            // cat to get the value, this outputs the energy values in the file.
            // below code gets that value and stores it in newNRG variable.
            var stdout = data["stdout"];
            disconnectSource(source);
            root.newNRG = stdout.trim();
        }

        function exec(cmd) {
            executable.connectSource(cmd);
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            // Right click action to fix the file permission
            text: i18n("Fix Sensor Permission")
            icon.name: "view-refresh"
            onTriggered: fixPermission()
        }
    ]

    function fixPermission() {
        // Main function to fix the permission
        executable.exec(["pkexec", "chmod", "444", root.raplPath].join(" "));
    }

    function update() {
        // Code to recalculate new power draw and update the UI
        executable.exec('cat ' + root.raplPath);
        console.log(root.newNRG);
        print(root.newNRG);
        if (root.newNRG == '') {
            root.power = 'FX-PR';
        } else {
            var time = (new Date).getTime();
            var timeDelta = (time - root.oldTime) / 1000;
            console.log(timeDelta);
            var joules = parseInt(root.newNRG) / 1e+06;
            root.power = Math.round((joules - root.oldNRG) * 10 / (timeDelta)) / 10;
            root.oldNRG = joules;
            root.oldTime = time;
            if (Number.isInteger(root.power))
                root.power = root.power + '.0 W';
            else
                root.power = root.power + ' W';
        }
    }

    Timer {
        // Repeating trigger which calls the update function
        interval: plasmoid.configuration.delay * 100
        repeat: true
        running: true
        onTriggered: update()
    }
}
