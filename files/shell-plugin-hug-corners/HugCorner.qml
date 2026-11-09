import QtQuick
import QtQuick.Shapes

// One inverted corner. The canonical path is the lower left corner of a top
// bar; the transforms mirror it for the other side and for a bottom bar.
//
// Adapted from CybexOS desktop/quickshell/Common/HugCorner.qml (MIT, see
// LICENSE-CybexOS).
Item {
  id: root

  property bool rightCorner: false
  property bool bottomCorner: false
  property real cornerSize: 16
  property color fillColor: "transparent"

  width: cornerSize
  height: cornerSize
  transform: [
    Scale {
      origin.x: root.width / 2
      xScale: root.rightCorner ? -1 : 1
    },
    Scale {
      origin.y: root.height / 2
      yScale: root.bottomCorner ? -1 : 1
    }
  ]

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: root.fillColor
      strokeWidth: -1
      startX: 0
      startY: 0
      PathLine { x: root.width; y: 0 }
      // 0.4477153 is 1 - kappa, which makes this cubic a circular arc and so
      // the same curve as a Hyprland window corner at rounding_power 2.
      PathCubic {
        control1X: root.width * 0.4477153
        control1Y: 0
        control2X: 0
        control2Y: root.height * 0.4477153
        x: 0
        y: root.height
      }
      PathLine { x: 0; y: 0 }
    }
  }
}
