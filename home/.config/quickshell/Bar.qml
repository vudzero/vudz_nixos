import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    height: 30
    color: "#1e1e1e"

    // ── Hyprland workspace state ──────────────────────────────────────────
    property var hyprMonitor: Hyprland.monitorFor(root.screen)
    property int activeWsId: hyprMonitor?.activeWorkspace?.id ?? -1

    // ── Polled stat properties ────────────────────────────────────────────
    property string cpuText:      "CPU --%"
    property string memText:      "RAM --G"
    property string gpuText:      ""
    property string volText:      "-- %"
    property string batText:      ""
    property string netIcon:      ""
    property string hypridleIcon: "💤"
    property string vpnIcon:      "󰖂"
    property string vpnClass:     "disconnected"

    // ── Polling processes ─────────────────────────────────────────────────
    Process { id: cpuProc;      command: ["bash", "-c", "$HOME/.config/quickshell/scripts/cpu-usage.sh"];       stdout: SplitParser { onRead: l => root.cpuText = l }      }
    Process { id: memProc;      command: ["bash", "-c", "$HOME/.config/quickshell/scripts/mem-usage.sh"];       stdout: SplitParser { onRead: l => root.memText = l }      }
    Process { id: gpuProc;      command: ["bash", "-c", "$HOME/.config/quickshell/scripts/gpu-usage.sh"];       stdout: SplitParser { onRead: l => root.gpuText = l }      }
    Process { id: volProc;      command: ["bash", "-c", "$HOME/.config/quickshell/scripts/volume.sh"];          stdout: SplitParser { onRead: l => root.volText = l }      }
    Process { id: batProc;      command: ["bash", "-c", "$HOME/.config/quickshell/scripts/battery.sh"];         stdout: SplitParser { onRead: l => root.batText = l }      }
    Process { id: netProc;      command: ["bash", "-c", "$HOME/.config/quickshell/scripts/network.sh"];         stdout: SplitParser { onRead: l => root.netIcon = l }      }
    Process { id: hypridleProc; command: ["bash", "-c", "$HOME/.config/quickshell/scripts/hypridle-status.sh"]; stdout: SplitParser { onRead: l => root.hypridleIcon = l } }
    Process {
        id: vpnProc
        command: ["bash", "-c", "$HOME/.config/quickshell/scripts/vpn-status.sh"]
        stdout: SplitParser {
            onRead: l => {
                const p = l.split("|")
                if (p.length >= 2) { root.vpnIcon = p[0]; root.vpnClass = p[1] }
            }
        }
    }

    // ── Polling timers ────────────────────────────────────────────────────
    Timer { interval: 2000;  running: true; repeat: true; onTriggered: cpuProc.running      = true }
    Timer { interval: 2000;  running: true; repeat: true; onTriggered: memProc.running      = true }
    Timer { interval: 2000;  running: true; repeat: true; onTriggered: gpuProc.running      = true }
    Timer { interval: 1000;  running: true; repeat: true; onTriggered: volProc.running      = true }
    Timer { interval: 10000; running: true; repeat: true; onTriggered: batProc.running      = true }
    Timer { interval: 5000;  running: true; repeat: true; onTriggered: netProc.running      = true }
    Timer { interval: 2000;  running: true; repeat: true; onTriggered: hypridleProc.running = true }
    Timer { interval: 5000;  running: true; repeat: true; onTriggered: vpnProc.running      = true }

    Component.onCompleted: {
        refreshClock()
        cpuProc.running      = true
        memProc.running      = true
        gpuProc.running      = true
        volProc.running      = true
        batProc.running      = true
        netProc.running      = true
        hypridleProc.running = true
        vpnProc.running      = true
    }

    // ── Click-action processes ────────────────────────────────────────────
    Process { id: procHypridle;  command: ["bash", "-c", "$HOME/.config/hypr/toggle-hypridle.sh"] }
    Process { id: procScale;     command: ["bash", "-c", "$HOME/.config/waybar/scripts/scale-selector.sh"] }
    Process { id: procVpnToggle; command: ["bash", "-c", "$HOME/.config/waybar/scripts/kinova-vpn-toggle.sh"] }
    Process { id: procNetwork;   command: ["alacritty", "--class", "impala", "-e", "impala"] }
    Process { id: procBluetooth; command: ["alacritty", "--class", "bluetuith", "-e", "bluetuith"] }
    Process { id: procAudio;     command: ["bash", "-c", "$HOME/.config/hypr/audio-switcher.sh"] }
    Process { id: procWlogout;   command: ["wlogout"] }

    // ── Inline components ─────────────────────────────────────────────────

    // Pill-shaped chip widget for the right-side indicators
    component Chip: Rectangle {
        property string text: ""
        property color textColor: "#000000"
        signal clicked()
        property bool clickable: false

        height: 22
        radius: 4
        color: "#ddddff"
        implicitWidth: lbl.implicitWidth + 20

        Text {
            id: lbl
            anchors.centerIn: parent
            text: parent.text
            color: parent.textColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.clickable
            cursorShape: parent.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: parent.clicked()
        }
    }

    // Workspace number button
    component WsBtn: Rectangle {
        property int wsId: 0
        property bool isActive: root.activeWsId === wsId

        width: 24
        height: 30
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: parent.wsId.toString()
            color: parent.isActive ? "#ffffff" : "rgba(255,255,255,0.35)"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            font.bold: parent.isActive
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch("workspace " + parent.wsId)
        }
    }

    // ── Clock ─────────────────────────────────────────────────────────────
    property string clockText: ""

    function refreshClock() {
        const d = new Date()
        const pad = n => String(n).padStart(2, '0')
        clockText = `${String(d.getFullYear()).slice(2)}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refreshClock()
    }

    // ── Main layout ───────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 8
        spacing: 0

        // Left: workspace buttons 1–9
        Row {
            spacing: 2

            Repeater {
                model: [1, 2, 3, 4, 5, 6, 7, 8, 9]
                WsBtn { wsId: modelData }
            }
        }

        Item { Layout.fillWidth: true }

        // Center: date + time
        Text {
            Layout.alignment: Qt.AlignVCenter
            color: "#ffffff"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            text: root.clockText
        }

        Item { Layout.fillWidth: true }

        // Right: system indicators (Row auto-excludes invisible children)
        Row {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            // Hypridle toggle
            Chip {
                text: root.hypridleIcon
                clickable: true
                onClicked: procHypridle.running = true
            }

            // Display scale selector
            Chip {
                text: "󰍹"
                clickable: true
                onClicked: procScale.running = true
            }

            // Kinova VPN status
            Chip {
                text: root.vpnIcon
                textColor: root.vpnClass === "connected"  ? "#4CAF50"
                         : root.vpnClass === "connecting" ? "#FF9800"
                         : "#888888"
                clickable: true
                onClicked: procVpnToggle.running = true
            }

            // CPU usage
            Chip { text: root.cpuText }

            // GPU usage (hidden when nvidia-smi unavailable)
            Chip {
                text: root.gpuText
                visible: root.gpuText !== ""
            }

            // RAM usage
            Chip { text: root.memText }

            // Network icon
            Chip {
                text: root.netIcon
                clickable: true
                onClicked: procNetwork.running = true
            }

            // Bluetooth
            Chip {
                text: "󰂱"
                clickable: true
                onClicked: procBluetooth.running = true
            }

            // Volume
            Chip {
                text: root.volText
                clickable: true
                onClicked: procAudio.running = true
            }

            // Battery (hidden on desktop — no battery found)
            Chip {
                text: root.batText
                visible: root.batText !== ""
            }

            // Power / logout button
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "⏻"
                color: "#ffffff"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: procWlogout.running = true
                }
            }
        }
    }
}
