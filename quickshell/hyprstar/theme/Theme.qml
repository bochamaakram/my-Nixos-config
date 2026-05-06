pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme
    
    // --- theme state ---
    property string current: "Pywal"

    // MAIN
    readonly property color bg: palette.bg
    readonly property color border: palette.border
    readonly property color accent: palette.accent
    readonly property color danger: palette.danger
    readonly property color bttnbg: palette.bttnbg
    readonly property color text: palette.text
    readonly property color subText: palette.subText
    
    // GRID BUTTONS
    readonly property color gridBttn_on_bg:   palette.gridBttn_on_bg
    readonly property color gridBttn_on_ttl:  palette.gridBttn_on_ttl
    readonly property color gridBttn_on_subt: palette.gridBttn_on_subt
    readonly property color gridBttn_off_bg:   palette.gridBttn_off_bg
    readonly property color gridBttn_off_ttl:  palette.gridBttn_off_ttl
    readonly property color gridBttn_off_subt: palette.gridBttn_off_subt
    readonly property color gridBttn_disc_bg:   palette.gridBttn_disc_bg
    readonly property color gridBttn_disc_ttl:  palette.gridBttn_disc_ttl
    readonly property color gridBttn_disc_subt: palette.gridBttn_disc_subt

    // WIDGETS
    readonly property color widget: palette.widget
    readonly property color coverArt: palette.coverArt

    // BATTERY
    readonly property color battNormal: palette.battNormal
    readonly property color battCharging: palette.battCharging
    readonly property color battLow: palette.battLow
    readonly property color battText: palette.battText
    
    // BACKGROUND GRADIENTS
    readonly property color gradientTop:    palette.gradientTop
    readonly property color gradientBottom: palette.gradientBottom
    
    ///////////
    // PYWAL //
    ///////////
    readonly property QtObject pywal: QtObject {
        property color bg: "#181825"
        property color bttnbg: "#313244"
        property color border: "#45475a"
        property color accent: "#b4befe"
        property color danger: "#f38ba8"
        property color text: "#CDD6F4"
        property color subText: '#a0afb7'

        property color gridBttn_on_ttl:  "#1E1E2E"
        property color gridBttn_on_subt: "#313244"
        property color gridBttn_off_bg:   "#313244"
        property color gridBttn_off_ttl:  "#CDD6F4"
        property color gridBttn_off_subt: "#A6ADC8"
        property color gridBttn_disc_bg:   "#F38BA8"
        property color gridBttn_disc_ttl:  "#1E1E2E"
        property color gridBttn_disc_subt: "#313244"

        property color widget: "#1E1E2E"
        property color coverArt: "#11111b"

        property color battNormal: "#b4befe"
        property color battCharging: "#a6e3a1"
        property color battLow: "#f38ba8"
        property color battText: "#FFFFFF"
        
        property color gradientTop:    "#181825"
        property color gradientBottom: "#000000"
    }

    property var pywalFileView: FileView {
        id: pywalFile
        path: "/home/akram/.cache/wal/colors.json"
        watchChanges: true
        onFileChanged: pywalFile.reload()
        onLoaded: parsePywal()

        function withAlpha(colorStr, alpha) {
            let c = colorStr.toString();
            if (c.startsWith("#") && c.length === 7) {
                let a = Math.round(alpha * 255).toString(16);
                if (a.length === 1) a = "0" + a;
                return "#" + a + c.substring(1);
            }
            return colorStr;
        }

        function parsePywal() {
            if (!text()) return;
            try {
                let pColors = JSON.parse(text());
                // Make backgrounds slightly transparent (95% opacity)
                pywal.bg = withAlpha(pColors.special.background, 0.95);
                pywal.bttnbg = withAlpha(pColors.colors.color0, 0.95);
                pywal.gridBttn_on_ttl = pColors.special.background;
                pywal.gridBttn_on_subt = withAlpha(pColors.colors.color0, 0.95);
                pywal.gridBttn_off_bg = withAlpha(pColors.colors.color0, 0.95);
                pywal.gridBttn_disc_ttl = pColors.special.background;
                pywal.gridBttn_disc_subt = withAlpha(pColors.colors.color0, 0.95);
                pywal.widget = withAlpha(pColors.colors.color0, 0.95);
                pywal.coverArt = withAlpha(pColors.colors.color0, 0.95);
                pywal.gradientTop = withAlpha(pColors.special.background, 0.95);
                pywal.gradientBottom = withAlpha(pColors.colors.color0, 0.95);

                pywal.text = pColors.special.foreground;
                pywal.border = pColors.colors.color8;
                pywal.accent = pColors.colors.color4;
                pywal.danger = pColors.colors.color1;
                pywal.subText = pColors.colors.color7;
                
                pywal.gridBttn_off_ttl = pColors.special.foreground;
                pywal.gridBttn_off_subt = pColors.colors.color8;
                pywal.gridBttn_disc_bg = pColors.colors.color1;

                pywal.battNormal = pColors.colors.color2;
                pywal.battCharging = pColors.colors.color2;
                pywal.battLow = pColors.colors.color1;
                pywal.battText = pColors.special.foreground;

            } catch (e) {
                console.log("[Theme] Failed to parse pywal colors:", e);
            }
        }
    }

    ////////////////
    // CATPPUCCIN //
    ////////////////
    readonly property QtObject catppuccin: QtObject {

        // MAIN
        readonly property color bg: "#181825"
        readonly property color bttnbg: "#313244"
        readonly property color border: "#45475a"
        readonly property color accent: "#b4befe"
        readonly property color danger: "#f38ba8"
        readonly property color text: "#CDD6F4"
        readonly property color subText: '#a0afb7'

        // GRID BUTTONS
        readonly property color gridBttn_on_ttl:  "#1E1E2E"
        readonly property color gridBttn_on_subt: "#313244"
        readonly property color gridBttn_off_bg:   "#313244"
        readonly property color gridBttn_off_ttl:  "#CDD6F4"
        readonly property color gridBttn_off_subt: "#A6ADC8"
        readonly property color gridBttn_disc_bg:   "#F38BA8"
        readonly property color gridBttn_disc_ttl:  "#1E1E2E"
        readonly property color gridBttn_disc_subt: "#313244"

        // WIDGETS
        readonly property color widget: "#1E1E2E"
        readonly property color coverArt: "#11111b"

        // BATTERY
        readonly property color battNormal: "#b4befe"
        readonly property color battCharging: "#a6e3a1"
        readonly property color battLow: "#f38ba8"
        readonly property color battText: "#FFFFFF"
        
        // BACKGROUND GRADIENT
        readonly property color gradientTop:    "#181825"  // Catppuccin Mocha Crust
        readonly property color gradientBottom: "#000000"  // Catppuccin Mocha Base (darker)
    }

    //////////
    // OLED //
    //////////
    readonly property QtObject oled: QtObject {

        // MAIN
        readonly property color bg: "#000000"
        readonly property color bttnbg: "#121212"
        readonly property color border: "#1A1A1A"
        readonly property color accent: "#dedede"
        readonly property color danger: "#FF4D5A"
        readonly property color text: "#dedede"
        readonly property color subText: "#B9B9B9"

        // GRID BUTTONS (Network, Bluetooth, etc.)
        readonly property color gridBttn_on_ttl:  "#000000"
        readonly property color gridBttn_on_subt: "#160000"
        readonly property color gridBttn_off_bg:   "#000000"
        readonly property color gridBttn_off_ttl:  "#EDEDED"
        readonly property color gridBttn_off_subt: "#A8A8A8"
        readonly property color gridBttn_disc_bg:   "#160000"
        readonly property color gridBttn_disc_ttl:  "#FFFFFF"
        readonly property color gridBttn_disc_subt: "#FFB3B8"
        
        // WIDGETS
        readonly property color widget: '#080808'
        readonly property color coverArt: "#121212"

        // BATTERY
        readonly property color battNormal: "#1c1e2e"
        readonly property color battCharging: "#1b301a"
        readonly property color battLow: "#160000"
        readonly property color battText: "#dedede"
        
        // BACKGROUND GRADIENT
        readonly property color gradientTop:    "#000000"
        readonly property color gradientBottom: "#000000"
    }
    
    readonly property QtObject palette: (current === "Pywal") ? pywal : (current === "Oled") ? oled : catppuccin
    function setTheme(name) {
        if (name !== "Oled" && name !== "Catppuccin" && name !== "Pywal") {
            console.log("[Theme] unknown:", name, "keeping:", current)
            return
        }
        current = name
        console.log("[Theme] switched to:", current)
    }
    
    function toggleTheme() {
        setTheme(current === "Oled" ? "Catppuccin" : (current === "Catppuccin" ? "Pywal" : "Oled"))
    }
    
    IpcHandler {
        target: "theme"  // This is what you use in the command: quickshell ipc call theme <function>
        
        // types MUST be explicit for qs ipc call to see them
        function themeSet(name: string): void { theme.setTheme(name) }
        function themeToggle(): void { theme.toggleTheme() }
        function themeGet(): string { return theme.current }
    }
    
    Component.onCompleted: console.log("[Theme] loaded, current =", current)
}