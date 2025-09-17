import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils

SimpleKCM {
    id: configItem
    property alias cfg_delay: delay.value
    property alias cfg_bold: bold.checked
    property alias cfg_debug: debug.checked
    property alias cfg_enableGPU: enableGPU.checked

    Kirigami.FormLayout {

        Controls.CheckBox {
            id: bold
            text: "Use Bold Text "
            LayoutMirroring.enabled: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Controls.CheckBox {
            id: debug
            text: "Enable Debug Logging"
            LayoutMirroring.enabled: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Controls.CheckBox {
            id: enableGPU
            text: "Enable AMD GPU Power Monitoring"
            LayoutMirroring.enabled: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Controls.SpinBox {
            id: delay

            from: decimalToInt(0.1)
            value: decimalToInt(1.0)
            to: decimalToInt(10)
            stepSize: decimalToInt(0.1)
            editable: true
            Kirigami.FormData.label: "Update Delay"
            hoverEnabled: true

            property int decimals: 1
            property real realValue: value / decimalFactor
            readonly property int decimalFactor: Math.pow(10, decimals)

            function decimalToInt(decimal) {
                return decimal * decimalFactor;
            }

            validator: DoubleValidator {
                bottom: Math.min(delay.from, delay.to)
                top: Math.max(delay.from, delay.to)
                decimals: delay.decimals
                notation: DoubleValidator.StandardNotation
            }

            textFromValue: function (value, locale) {
                return Number(value / decimalFactor).toLocaleString(locale, 'f', delay.decimals);
            }

            valueFromText: function (text, locale) {
                return Math.round(Number.fromLocaleString(locale, text) * decimalFactor);
            }
        }
    }
}
