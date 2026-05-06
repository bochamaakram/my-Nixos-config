import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root
  property color bgBase: "#1a1b26"
  property color bgSurface: "#24283b"
  property color bgOverlay: "#88000000"
  property color bgHover: "#1e2235"
  property color bgSelected: "#283457"
  property color bgBorder: "#32364a"

  property color textPrimary: "#c0caf5"
  property color textSecondary: "#a9b1d6"
  property color textMuted: "#565f89"

  property color accentPrimary: "#7aa2f7"
  property color accentCyan: "#7dcfff"
  property color accentGreen: "#9ece6a"
  property color accentOrange: "#ff9e64"
  property color accentRed: "#f7768e"

  readonly property color urgencyLow: textMuted
  readonly property color urgencyNormal: accentPrimary
  readonly property color urgencyCritical: accentRed
  readonly property color batteryGood: accentGreen
  readonly property color batteryWarning: accentOrange
  readonly property color batteryCritical: accentRed

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
              root.bgBase = withAlpha(pColors.special.background, 0.85);
              root.bgSurface = withAlpha(pColors.colors.color0, 0.85);
              root.bgHover = withAlpha(pColors.colors.color8, 0.85);
              root.bgSelected = withAlpha(pColors.colors.color8, 0.85);
              root.bgBorder = pColors.colors.color8;

              root.textPrimary = pColors.special.foreground;
              root.textSecondary = pColors.colors.color7;
              root.textMuted = pColors.colors.color8;

              root.accentPrimary = pColors.colors.color4;
              root.accentCyan = pColors.colors.color6;
              root.accentGreen = pColors.colors.color2;
              root.accentOrange = pColors.colors.color3;
              root.accentRed = pColors.colors.color1;
          } catch (e) {
              console.log("[Notification Theme] Failed to parse pywal colors:", e);
          }
      }
  }
}
