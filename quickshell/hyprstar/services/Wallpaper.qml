import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme

PanelWindow {
    property string imagePath: ""
    property bool isAnimated: false
    
    visible: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    anchors { top: true; bottom: true; left: true; right: true }
    
    // Static image loader
    Image {
        id: staticImage
        anchors.fill: parent
        source: !isAnimated && imagePath ? ("file://" + imagePath) : ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: !isAnimated
    }
    
    // Animated image loader (for GIFs)
    AnimatedImage {
        id: animatedImage
        anchors.fill: parent
        source: isAnimated && imagePath ? ("file://" + imagePath) : ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: isAnimated
        playing: true
    }
    
    // Function to update wallpaper
    function updateWallpaper() {
        const home = Quickshell.env("HOME")
        const base = home + "/.config/quickshell/assets/wallpapers/"
        const newPath = base + (Theme.current === "Oled" ? "oled.png" : "wall.gif")
        
        // Check if the file is a GIF
        isAnimated = newPath.toLowerCase().endsWith(".gif")
        imagePath = newPath
    }
    
    // Add this connection to react to theme changes
    Connections {
        target: Theme
        function onCurrentChanged() {
            updateWallpaper()
        }
    }
    
    // Set initial wallpaper on component load
    Component.onCompleted: {
        updateWallpaper()
    }
}