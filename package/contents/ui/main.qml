/*
 * Copyright 2022 Phani Pavan K <kphanipavan@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0


Item {
    id: main
    anchors.fill: parent
    
    //height and width, when the widget is placed in desktop
    width: 60
    height: 15

    //height and width, when widget is placed in plasma panel
    Layout.preferredWidth: 60 * units.devicePixelRatio
    Layout.preferredHeight: 15 * units.devicePixelRatio

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    property string rAPLPath: getRAPLPath()
    property bool energyNow: checkEnergyNow(rAPLPath)
    property double power: getPower(rAPLPath)
    property double oldEnergy: 0.0
    property double oldTime: 0

    function getRAPLPath() {
        return "/sys/class/powercap/intel-rapl:0/energy_uj"
    }


    function checkEnergyNow(fileUrl) {
        if(fileUrl == "") {
            return false
        }

        var path = fileUrl
        var req = new XMLHttpRequest();

        req.open("GET", path, false);
        req.send(null);

        if(req.responseText == "") {
            return false
        }
        else {
            return true
        }
    }

    function getPower(fileUrl) {
        if(fileUrl == "") {
            return "0.0"
        }
        if( main.energyNow == true) {
            var path = fileUrl
            var time = (new Date).getTime()
            var req = new XMLHttpRequest();
            req.open("GET", path, false);
            req.send(null);

            var nrgInJoules = parseInt(req.responseText) / 1000000;
            var timeDelta = (time - main.oldTime) / 1000
            
            var power = (nrgInJoules - main.oldEnergy) / timeDelta
            console.log(main.oldEnergy, nrgInJoules, main.oldTime, time, timeDelta, power)
            main.oldEnergy = nrgInJoules
            main.oldTime = time
            return(Math.round(power*10)/10);
        }
        return "0.0"
    }

    PlasmaComponents.Label {
        id: display

        anchors {
            fill: parent
            margins: Math.round(parent.width * 0.01)
        }

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        text: {
            if(Number.isInteger(main.power)) {
                return(main.power + ".0 W");
            }
            else {
                return(main.power + " W");
            }
        }

        font.pixelSize: 1000;
        minimumPointSize: theme.smallestFont.pointSize
        fontSizeMode: Text.Fit
        font.bold: plasmoid.configuration.makeFontBold
    }

    Timer {
        interval: plasmoid.configuration.updateInterval * 1000
        running: true
        repeat: true
        onTriggered: {
            main.power = getPower(main.rAPLPath)
            if(Number.isInteger(main.power)) {
                //When power has 0 decimal places, it removes the decimal
                //point inspite of power variable being double. This momentarily
                //makes the font size bigger due to extra available space which
                //does not look good. So we do this simple hack of manually adding 
                //a .0 to number
                display.text = main.power + ".0 W";
            }
            else {
                display.text = main.power + " W"
            }
        }
    }
}
