import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Omarchy's workspace widget, with CybexOS's look: the shown workspace is a
// numbered accent chip that slides between slots, workspaces with windows show
// their number, and empty ones are dots. The workspace logic is Omarchy's. The look and motion are adapted from
// CybexOS desktop/quickshell/Bar/Workspaces.qml (MIT, see LICENSE-CybexOS).
BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Every monitor has workspaces 1-10 of its own, which Hyprland numbers in a
  // block of ten per monitor: 1-10, 11-20, and so on (see
  // default/hypr/monitor-workspaces.lua). Each bar shows its own monitor's block,
  // numbered 1-10, and the one that monitor shows, whichever monitor has focus.
  readonly property int slots: 10

  // CybexOS's geometry and timing. The chip is wider than its cell, and the
  // padding keeps it clear of the neighbouring widgets at either end.
  readonly property int cellSize: 22
  readonly property int stripPadding: 5
  readonly property int dotSize: 6
  readonly property int chipLength: 26
  readonly property int chipThickness: Math.min(24, root.barSize - 6)
  readonly property int chipRadius: 7
  readonly property int leadingMs: 120
  readonly property int trailingMs: 300

  readonly property color dotColor: root.bar ? root.bar.barForeground : Commons.Color.foreground
  readonly property real occupiedOpacity: 0.78
  readonly property real emptyOpacity: 0.44

  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property string monitorName: root.monitor ? root.monitor.name : ""

  // Connector -> block, from the file Hyprland keeps them in.
  property var blocks: ({})

  function readBlocks(text) {
    var next = {}
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var fields = lines[i].split("\t")
      if (fields.length >= 3 && fields[1] !== "") next[fields[1]] = parseInt(fields[0], 10)
    }
    root.blocks = next
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readBlocks(text())
    onLoadFailed: root.readBlocks("")
  }

  function blockOf(id) {
    return Math.floor((id - 1) / root.slots)
  }

  function slotOf(id) {
    return (id - 1) % root.slots + 1
  }

  function activeWorkspaceId() {
    return root.monitor && root.monitor.activeWorkspace ? root.monitor.activeWorkspace.id : -1
  }

  // Until Hyprland has written the file, the workspace a monitor shows is in
  // its own block.
  readonly property int block: {
    var block = root.blocks[root.monitorName]
    if (block !== undefined) return block
    var active = root.activeWorkspaceId()
    return active > 0 ? root.blockOf(active) : 0
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // The first five of the monitor's own, and any of the rest that exist. After
  // them come workspaces that are only visiting: those of a monitor that is
  // unplugged, which had no room to join this one's.
  function workspaceIds() {
    var base = root.block * root.slots
    var ids = [base + 1, base + 2, base + 3, base + 4, base + 5]
    var guests = []
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id <= 0) continue
      if (root.blockOf(id) === root.block) {
        if (ids.indexOf(id) === -1) ids.push(id)
      } else if (values[i].monitor && values[i].monitor.name === root.monitorName) {
        guests.push(id)
      }
    }

    ids.sort(function(left, right) { return left - right })
    guests.sort(function(left, right) { return left - right })
    return ids.concat(guests)
  }

  function dispatch(expression) {
    if (root.bar) root.bar.run("hyprctl dispatch " + Util.shellQuote(expression))
  }

  function focusWorkspace(id) {
    if (root.blockOf(id) === root.block) {
      root.dispatch("o.workspaces.focus(" + root.slotOf(id) + ", \"" + root.monitorName + "\")")
    } else {
      root.dispatch("hl.dsp.focus({ workspace = \"" + id + "\" })")
    }
  }

  // A wheel notch moves one entry along the row, and a touchpad adds up its
  // smaller deltas until they make a notch's worth.
  property real wheelAccumulator: 0

  function scrollWorkspaces(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return

    // Holds at either end rather than wrapping, so a touchpad swipe that runs
    // long stops on the last workspace.
    var ids = root.workspaceIds()
    var index = ids.indexOf(root.activeWorkspaceId())
    if (index === -1) return
    var target = ids[Util.clamp(index - wheel.steps, 0, ids.length - 1)]
    if (target !== ids[index]) root.focusWorkspace(target)
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      // Quickshell credits every workspace switch to the focused monitor, as
      // the event doesn't say which one switched, and misses the workspace a
      // monitor falls back to when its own is moved away. Moving workspaces
      // between monitors switches the others, so ask Hyprland for the truth.
      // A workspace that changes number is only learned by asking too. Every
      // bar shares what Hyprland answers, so one asks after a plain switch.
      var switched = name === "workspacev2" && root.monitor !== null && root.monitor.focused
      if (switched || name === "moveworkspacev2" || name === "changeworkspaceid") {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
  }

  // Omarchy's layout commands still call this after changing a layout. This
  // widget doesn't show the layout, so there is nothing to refresh.
  ShellIpc {
    target: "omarchy.workspaces"

    function refresh(): void {}
  }

  // Hyprland republishes its workspaces on every focus and window event, and
  // the list almost always comes out the same. Going through a string gives
  // the Repeater a new model only when the ids really change.
  readonly property string idsKey: JSON.stringify(root.workspaceIds())
  readonly property var ids: JSON.parse(root.idsKey)
  readonly property int shownId: root.activeWorkspaceId()

  // A gap sets visiting workspaces apart from the monitor's own.
  readonly property int guestGap: Style.space(6)
  readonly property int firstGuestIndex: {
    for (var i = 1; i < root.ids.length; i++) {
      if (root.blockOf(root.ids[i]) !== root.block) return i
    }
    return -1
  }

  function cellStart(index) {
    return root.stripPadding + index * root.cellSize
      + (root.firstGuestIndex > 0 && index >= root.firstGuestIndex ? root.guestGap : 0)
  }

  readonly property real stripLength: root.ids.length > 0
    ? root.cellStart(root.ids.length - 1) + root.cellSize + root.stripPadding : 0

  implicitWidth: root.vertical ? root.barSize : root.stripLength
  implicitHeight: root.vertical ? root.stripLength : root.barSize

  FontMetrics {
    id: numberMetrics
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
    font.weight: Font.DemiBold
  }

  property bool pillReady: false
  property bool snapRequested: true
  property int previousIndex: -1

  // The edge moving toward the new slot leads and the other trails, so the
  // chip stretches in the direction of travel.
  function settlePill(animate) {
    var index = root.ids.indexOf(root.shownId)
    if (index < 0) {
      root.pillReady = false
      root.previousIndex = -1
      return
    }

    var start = root.cellStart(index) + (root.cellSize - root.chipLength) / 2
    var moving = animate && root.pillReady && !root.snapRequested
      && root.previousIndex >= 0 && root.previousIndex !== index
    var forward = index > root.previousIndex

    pill.startDuration = moving ? Style.duration(forward ? root.trailingMs : root.leadingMs) : 0
    pill.endDuration = moving ? Style.duration(forward ? root.leadingMs : root.trailingMs) : 0
    pill.animateEdges = moving
    pill.startEdge = start
    pill.endEdge = start + root.chipLength

    root.pillReady = true
    root.previousIndex = index
    root.snapRequested = false
  }

  function snapPill() {
    root.snapRequested = true
    settleTimer.restart()
  }

  onShownIdChanged: settleTimer.restart()
  onIdsKeyChanged: root.snapPill()
  onVerticalChanged: root.snapPill()
  Component.onCompleted: root.snapPill()

  Timer {
    id: settleTimer
    interval: 0
    onTriggered: root.settlePill(true)
  }

  Rectangle {
    id: pill

    property real startEdge: 0
    property real endEdge: root.chipLength
    property int startDuration: 0
    property int endDuration: 0
    property bool animateEdges: false
    readonly property real length: Math.max(1, endEdge - startEdge)

    visible: root.pillReady
    x: root.vertical ? (root.barSize - width) / 2 : startEdge
    y: root.vertical ? startEdge : (root.barSize - height) / 2
    width: root.vertical ? root.chipThickness : length
    height: root.vertical ? length : root.chipThickness
    radius: root.chipRadius
    color: Commons.Color.accent
    z: 1

    Behavior on startEdge {
      enabled: pill.animateEdges
      NumberAnimation { duration: pill.startDuration; easing.type: Easing.OutCubic }
    }

    Behavior on endEdge {
      enabled: pill.animateEdges
      NumberAnimation { duration: pill.endDuration; easing.type: Easing.OutCubic }
    }

    Behavior on color {
      ColorAnimation { duration: Style.duration(200) }
    }
  }

  Repeater {
    model: root.ids

    Item {
      id: cell

      required property int index
      required property int modelData

      readonly property var workspace: root.workspaceById(modelData)
      readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
      readonly property bool urgent: workspace !== null && workspace.urgent === true
      readonly property bool shown: root.shownId === modelData

      x: root.vertical ? 0 : root.cellStart(index)
      y: root.vertical ? root.cellStart(index) : 0
      width: root.vertical ? root.barSize : root.cellSize
      height: root.vertical ? root.cellSize : root.barSize
      z: 2

      Rectangle {
        anchors.centerIn: parent
        width: root.cellSize - 2
        height: root.chipThickness
        radius: root.chipRadius
        color: root.dotColor
        opacity: button.tooltipHovered && !cell.shown ? 0.09 : 0

        Behavior on opacity {
          NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic }
        }
      }

      // Only an empty workspace that isn't shown has a dot.
      Rectangle {
        anchors.centerIn: parent
        width: root.dotSize
        height: root.dotSize
        radius: root.dotSize / 2
        scale: button.pressScale
        color: cell.urgent ? (root.bar ? root.bar.urgent : Commons.Color.urgent) : root.dotColor
        opacity: cell.shown || cell.occupied ? 0 : (cell.urgent ? 1 : root.emptyOpacity)

        Behavior on color {
          ColorAnimation { duration: Style.duration(200) }
        }

        Behavior on opacity {
          NumberAnimation { duration: Style.duration(200); easing.type: Easing.OutCubic }
        }
      }

      // Stays in its own cell while the chip slides over it, as in CybexOS.
      // Placed by its baseline, so the digit itself is what gets centered
      // rather than the line box around it. Digits are 0.73 of the font size;
      // Qt's tightBoundingRect rounds that up, which would sit the digit low.
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.baseline: parent.top
        anchors.baselineOffset: (parent.height + numberMetrics.font.pixelSize * 0.73) / 2
        textFormat: Text.PlainText
        text: root.slotOf(cell.modelData) === root.slots ? "0" : String(root.slotOf(cell.modelData))
        color: cell.shown ? Commons.Color.background
          : cell.urgent ? (root.bar ? root.bar.urgent : Commons.Color.urgent)
          : root.dotColor
        font.family: numberMetrics.font.family
        font.pixelSize: numberMetrics.font.pixelSize
        font.weight: cell.shown || cell.urgent ? Font.DemiBold : Font.Medium
        renderType: Text.NativeRendering
        opacity: cell.shown || cell.urgent ? 1 : (cell.occupied ? root.occupiedOpacity : 0)

        Behavior on color {
          ColorAnimation { duration: Style.duration(200) }
        }

        Behavior on opacity {
          NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic }
        }
      }

      WidgetButton {
        id: button

        anchors.fill: parent
        bar: root.bar
        hasVisualContent: true
        labelVisible: false
        fixedWidth: cell.width
        fixedHeight: cell.height
        pressable: !cell.shown
        onPressed: function() {
          if (!cell.shown) root.focusWorkspace(cell.modelData)
        }
        onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }
      }
    }
  }
}
