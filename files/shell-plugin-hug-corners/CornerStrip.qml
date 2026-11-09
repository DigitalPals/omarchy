import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// A click-through strip along one screen edge, with a corner at each end.
PanelWindow {
  id: strip

  required property var modelData

  property bool bottomEdge: false
  // True to sit against the bar, false to sit on the physical screen edge.
  property bool followsBar: false
  property bool cornersWanted: false
  property int cornerSize: 0
  property color fillColor: "transparent"

  // Hyprland's window corners measure 1 physical px tighter than
  // decoration:rounding (31 px for rounding 16 at scale 2), so match that.
  readonly property real drawnSize: Math.max(0, cornerSize - 1 / modelData.devicePixelRatio)

  // Same test the bar uses for a real fullscreen window. Maximized windows
  // keep the bar, so they keep the corners too.
  readonly property bool underFullscreen: {
    var monitor = Hyprland.monitorFor(modelData)
    var workspace = monitor ? monitor.activeWorkspace : null
    if (!workspace) return false
    var toplevels = Hyprland.toplevels.values
    for (var i = 0; i < toplevels.length; i++) {
      var toplevel = toplevels[i]
      if (!toplevel || !toplevel.workspace || toplevel.workspace.id !== workspace.id) continue
      var ipc = toplevel.lastIpcObject
      if (ipc && (Number(ipc.fullscreen) & 2) !== 0) return true
    }
    return false
  }

  screen: modelData
  anchors {
    top: !strip.bottomEdge
    bottom: strip.bottomEdge
    left: true
    right: true
  }
  implicitHeight: Math.max(1, strip.cornerSize)
  color: "transparent"

  // Normal mode with no zone of its own makes the compositor place the strip
  // directly against the bar, at whatever thickness the bar has. Ignore keeps
  // the other strip on the physical edge whatever else reserves space there.
  exclusionMode: strip.followsBar ? ExclusionMode.Normal : ExclusionMode.Ignore
  exclusiveZone: 0

  // Never takes the pointer.
  mask: Region {}

  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "john-hug-corners"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  // The surface stays mapped and only its drawing hides: Hyprland lifts every
  // layer on a monitor above fullscreen when one of them remaps.
  Item {
    anchors.fill: parent
    visible: strip.cornersWanted && !strip.underFullscreen

    HugCorner {
      x: 0
      y: strip.bottomEdge ? parent.height - height : 0
      cornerSize: strip.drawnSize
      bottomCorner: strip.bottomEdge
      fillColor: strip.fillColor
    }

    HugCorner {
      x: parent.width - width
      y: strip.bottomEdge ? parent.height - height : 0
      cornerSize: strip.drawnSize
      rightCorner: true
      bottomCorner: strip.bottomEdge
      fillColor: strip.fillColor
    }
  }
}
