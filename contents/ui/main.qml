import QtQuick 2.15
import QtMultimedia 5.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root
    width: 128
    height: 128

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property bool isPlaying: false

    // 🎚 SETTINGS
    property real masterVolume:
        (plasmoid.configuration.volume ?? 100) / 100

    property real mikuChance:
        plasmoid.configuration.mikuChance ?? 0.5

    property real mikuVolume:
        (plasmoid.configuration.mikuVolume ?? 100) / 100

    property real engineerVolume:
        (plasmoid.configuration.engineerVolume ?? 100) / 100

    property url mikuSound:
        plasmoid.configuration.mikuSound && plasmoid.configuration.mikuSound !== ""
            ? plasmoid.configuration.mikuSound
            : Qt.resolvedUrl("../sounds/miku-fixed.wav")

    property url engineerSound:
        plasmoid.configuration.engineerSound && plasmoid.configuration.engineerSound !== ""
            ? plasmoid.configuration.engineerSound
            : Qt.resolvedUrl("../sounds/engineer.wav")

    // 🖼️ IMAGE
    AnimatedImage {
        id: display
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        playing: true
        speed: 1.0
        source: Qt.resolvedUrl("../images/miku.png")
    }

    // 🔊 Qt5-CORRECT AUDIO
    MediaPlayer {
        id: player
        volume: masterVolume
    }

    function resetToIdle() {
        root.isPlaying = false
        display.speed = 1.0
        display.source = Qt.resolvedUrl("../images/miku.png")
        display.playing = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.isPlaying)
                return

            console.log("CLICKED 🔥")
            root.isPlaying = true

            player.stop()
            player.source = ""

            display.playing = false
            display.source = ""

            if (Math.random() < root.mikuChance) {
                // 💙 MIKU MODE
                display.speed = 4.0
                display.source = Qt.resolvedUrl("../images/4051639.gif")
                player.volume = masterVolume * mikuVolume
                player.source = mikuSound
            } else {
                // 🧰 ENGINEER MODE
                display.speed = 1.0
                display.source = Qt.resolvedUrl("../images/engineer-tf2.gif")
                player.volume = masterVolume * engineerVolume
                player.source = engineerSound
            }

            display.playing = true
            player.play()
        }
    }

    Connections {
        target: player
        function onPlaybackStateChanged() {
            if (player.playbackState === MediaPlayer.StoppedState && root.isPlaying) {
                resetToIdle()
            }
        }
    }

    Component.onCompleted: {
        console.log("MIKU PLASMOID ONLINE 🟢")
        console.log("Miku sound:", mikuSound)
        console.log("Engineer sound:", engineerSound)
    }
}
