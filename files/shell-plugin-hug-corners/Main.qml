import QtQuick
import Quickshell
import qs.Commons as Commons

// Rounds all four corners of the desktop, sized by Hyprland's window rounding:
// two against a top or bottom bar in the theme's bar color, and two on the
// opposite screen edge in pure black.
Item {
  id: root

  property var shell: null

  readonly property var barState: shell ? shell.bar : null
  readonly property string position: barState ? barState.position : "top"
  readonly property bool barHidden: barState ? barState.barHidden : false
  readonly property bool barAtBottom: position === "bottom"

  // Mirrors how the bar reads its own background setting.
  readonly property string look: {
    var config = shell && shell.barConfig ? shell.barConfig : ({})
    return config.background || (config.transparent === true ? "none" : "opaque")
  }

  // A glassy or clear bar has no solid slab for the corners to continue.
  readonly property bool cornersWanted: (position === "top" || position === "bottom")
    && !barHidden && look === "opaque" && cornerSize > 0

  readonly property int cornerSize: Commons.Style.cornerRadius

  // The same cross-fade the bar uses on a theme change.
  property color fillColor: Commons.Color.bar.background
  Behavior on fillColor {
    ColorAnimation { duration: Commons.Style.duration(250); easing.type: Easing.OutCubic }
  }

  // Against the bar.
  Variants {
    model: Quickshell.screens

    delegate: Component {
      CornerStrip {
        followsBar: true
        bottomEdge: root.barAtBottom
        cornersWanted: root.cornersWanted
        cornerSize: root.cornerSize
        fillColor: root.fillColor
      }
    }
  }

  // On the screen edge opposite the bar.
  Variants {
    model: Quickshell.screens

    delegate: Component {
      CornerStrip {
        followsBar: false
        bottomEdge: !root.barAtBottom
        cornersWanted: root.cornersWanted
        cornerSize: root.cornerSize
        fillColor: "#000000"
      }
    }
  }
}
