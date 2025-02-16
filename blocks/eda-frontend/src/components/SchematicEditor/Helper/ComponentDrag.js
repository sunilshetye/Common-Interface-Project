/* eslint new-cap: ["error", {"newIsCapExceptionPattern": "^mx"}] */
import 'mxgraph/javascript/src/css/common.css'

import mxGraphFactory from 'mxgraph'
import store from '../../../redux/store'
import dot from '../../../static/dot.gif'
import blockstyle from '../../../static/style.json'
import { getCompProperties, closeCompProperties } from '../../../redux/actions/index'

import toolbarTools from './ToolbarTools'
import keyboardShortcuts from './KeyboardShortcuts'
import { sideBar } from './SideBar'

export let graph

const {
  mxGraph,
  mxRubberband,
  mxClient,
  mxUtils,
  mxEvent,
  mxOutline,
  mxCell,
  mxPoint,
  mxGraphView,
  mxCellEditor,
  mxEdgeHandler,
  mxConnectionConstraint,
  mxEdgeSegmentHandler,
  mxEdgeStyle,
  mxStyleRegistry,
  mxConnectionHandler,
  mxConstants,
  mxGraphHandler,
  mxCylinder,
  mxCellRenderer,
  mxConstraintHandler,
  mxImage
} = new mxGraphFactory()

function configureStylesheet (graph) {
  graph.stylesheet.styles = blockstyle
}

export function styleToObject (style) {
  // To add semicolon at the end if it isn't already present.
  if (style[style.length - 1] !== ';') {
    style = style + ';'
  }
  const styleObject = {
  }

  let remainingStyle = style
  while (remainingStyle.length > 0) {
    const indexOfKeyValue = remainingStyle.indexOf(';')

    const indexOfKey = remainingStyle.indexOf('=')
    if (indexOfKey > 0 && indexOfKey < indexOfKeyValue) {
      const key = remainingStyle.substring(0, indexOfKey)
      const value = remainingStyle.substring(indexOfKey + 1, indexOfKeyValue)
      styleObject[key] = value
    } else {
      const key = 'default'
      const value = remainingStyle.substring(0, indexOfKeyValue)
      if (value !== '' && !(key in styleObject)) {
        styleObject[key] = value
      }
    }

    remainingStyle = remainingStyle.substring(indexOfKeyValue + 1)
  }

  return styleObject
}

export const ExplicitPort = 0
export const ImplicitPort = 1
export const ControlCommandPort = 2
export const InputPort = 3
export const OutputPort = 4
export const SplitPort = 5

export function getPortType (cell, isSplit = false) {
  while (cell.edge === true) {
    cell = cell.source
    isSplit = true
  }

  const style = styleToObject(cell.style).default
  let type1, type2

  // Determine if the port is explicit, implicit, control, or command
  if (style === 'ExplicitInputPort' || style === 'ExplicitOutputPort') {
    type1 = ExplicitPort
  } else if (style === 'ImplicitInputPort' || style === 'ImplicitOutputPort') {
    type1 = ImplicitPort
  } else if (style === 'ControlPort' || style === 'CommandPort') {
    type1 = ControlCommandPort
  }

  // Determine if the port is input or output
  if (isSplit) {
    type2 = SplitPort
  } else if (style === 'ExplicitInputPort' || style === 'ImplicitInputPort' || style === 'ControlPort') {
    type2 = InputPort
  } else if (style === 'ExplicitOutputPort' || style === 'ImplicitOutputPort' || style === 'CommandPort') {
    type2 = OutputPort
  }

  return { type1, type2 }
}

export default function LoadGrid (container, sidebar, outline) {
  // Checks if the browser is supported
  if (!mxClient.isBrowserSupported()) {
    // Displays an error message if the browser is not supported.
    mxUtils.error('Browser is not supported!', 200, false)
  } else {
    // Disables the built-in context men
    mxEvent.disableContextMenu(container)
    // Tells if the cell is a component or a pin or a wire
    mxCell.prototype.CellType = 'Unknown'
    // Tells the magnitude of a resistor/capacitor
    mxCell.prototype.Magnitude = null
    // Parent component of a pin, default is null
    mxCell.prototype.ParentComponent = null
    mxCell.prototype.node = null
    mxCell.prototype.CompObject = null
    mxCell.prototype.parameter_values = {}
    mxCell.prototype.errorFields = {}
    mxCell.prototype.displayProperties = {}
    mxCell.prototype.sourceVertex = false
    mxCell.prototype.targetVertex = false
    mxCell.prototype.tarx = 0
    mxCell.prototype.tary = 0

    // Enables guides
    mxGraphHandler.prototype.guidesEnabled = true
    mxEdgeHandler.prototype.snapToTerminals = true

    // Enable cell Rotation
    // mxVertexHandler.prototype.rotationEnabled = true

    // Creates the graph inside the given container
    graph = new mxGraph(container)

    mxConnectionHandler.prototype.movePreviewAway = false
    mxConnectionHandler.prototype.waypointsEnabled = true
    mxGraph.prototype.resetEdgesOnConnect = false
    mxConstants.SHADOWCOLOR = '#C0C0C0'
    const joinNodeSize = 7
    const strokeWidth = 2

    // Replaces the port image
    mxConstraintHandler.prototype.pointImage = new mxImage(dot, 10, 10)

    // Creates the outline (navigator, overview) for moving
    // around the graph in the top, right corner of the window.
    const outln = new mxOutline(graph, outline)
    // To show the images in the outline, uncomment the following code
    outln.outline.labelsVisible = true
    outln.outline.setHtmlLabels(true)

    graph.addListener(mxEvent.DOUBLE_CLICK, function (sender, evt) {
      const cell = evt.getProperty('cell')
      if (cell !== undefined && cell.CellType === 'Component') {
        store.dispatch(getCompProperties(cell))
      } else {
        store.dispatch(closeCompProperties())
      }
      evt.consume()
    })

    graph.view.scale = 1
    configureStylesheet(graph)
    graph.setPanning(true)
    graph.setConnectable(true)
    graph.setConnectableEdges(true)
    graph.setDisconnectOnMove(false)
    graph.foldingEnabled = false

    // Panning handler consumed right click so this must be
    // disabled if right click should stop connection handler.
    graph.panningHandler.isPopupTrigger = function () { return false }

    // Enables return key to stop editing (use shift-enter for newlines)
    graph.setEnterStopsCellEditing(true)

    // Adds rubberband selection
    new mxRubberband(graph) // eslint-disable-line no-new

    // Alternative solution for implementing connection points without child cells.
    // This can be extended as shown in portrefs.html example to allow for per-port
    // incoming/outgoing direction.
    graph.getAllConnectionConstraints = function (terminal) {
      const geo = (terminal != null) ? this.getCellGeometry(terminal.cell) : null

      if ((geo != null ? !geo.relative : false) && this.getModel().isVertex(terminal.cell) && this.getModel().getChildCount(terminal.cell) === 0) {
        return [new mxConnectionConstraint(new mxPoint(0, 0.5), false), new mxConnectionConstraint(new mxPoint(1, 0.5), false)]
      }

      return null
    }

    // Makes sure non-relative cells can only be connected via constraints
    graph.connectionHandler.isConnectableCell = function (cell) {
      if (this.graph.getModel().isEdge(cell)) {
        return true
      } else {
        const edgeCount = (cell != null) ? cell.getEdgeCount() : 0
        if (edgeCount !== 0) {
          return false
        }

        const geo = (cell != null) ? this.graph.getCellGeometry(cell) : null

        return (geo != null) ? geo.relative : false
      }
    }

    mxEdgeHandler.prototype.isConnectableCell = function (cell) {
      return graph.connectionHandler.isConnectableCell(cell)
    }

    // Override the connection validation function
    graph.connectionHandler.validateConnection = function (source, target) {
      const sourceType = getPortType(source)
      const targetType = getPortType(target)
      // Rule 1: Check if source and target ports are of the same type
      if (sourceType.type1 !== targetType.type1) {
        return 'Types do not match'
      }
      // Rule 2 : Cannot connect 2 splits
      if (sourceType.type2 === SplitPort && targetType.type2 === SplitPort) {
        return 'Cannot connect two links'
      }
      if (sourceType.type1 !== ImplicitPort) {
        // Rule 3: Cannot connect 2 input ports
        if (sourceType.type2 === InputPort && targetType.type2 === InputPort) {
          return 'Cannot connect two input ports'
        }
        // Rule 4: cannot connect 2 output ports
        if (sourceType.type2 === OutputPort && targetType.type2 === OutputPort) {
          return 'Cannot connect two output ports'
        }
        // Rule 5: cannot connect split to output port
        const ports = [OutputPort, SplitPort]
        if (ports.includes(sourceType.type2) && ports.includes(targetType.type2)) {
          return 'Cannot connect a link to an output port'
        }
      }
      // Rule 6: cannot connect from an already connected port again
      if (sourceType.type2 !== SplitPort && source.getEdgeCount() > 0) {
        return 'Cannot connect from an already connected port again'
      }
      // Rule 7: cannot connect to an already connected port again
      if (targetType.type2 !== SplitPort && target.getEdgeCount() > 0) {
        return 'Cannot connect to an already connected port again'
      }

      return null
    }

    graph.addEdge = function (edge, parent, source, target, index) {
      if (source == null || target == null) {
        return null
      }

      return mxGraph.prototype.addEdge.apply(this, arguments)
    }

    // Adds a special tooltip for edges
    graph.setTooltips(true)

    graph.getTooltipForCell = function (cell) {
      let text = null
      if (cell != null) {
        const attribute = cell.style
        if (attribute == null) {
          let source = cell.source
          while (source.edge === true) {
            source = source.source
          }
          const styleObject = styleToObject(source.style)
          let style = 'Link'
          switch (styleObject.default) {
            case 'ExplicitOutputPort': case 'ExplicitInputPort':
              style = 'ExplicitLink'
              break

            case 'ImplicitOutputPort': case 'ImplicitInputPort':
              style = 'ImplicitLink'
              break

            case 'CommandPort': case 'ControlPort':
              style = 'CommandControlLink'
              break
          }
          text = style + '\n' +
            'UID: ' + cell.id + '\n' +
            'Source: ' + cell.source?.id + '\n' +
            'Target: ' + cell.target?.id + '\n'
          return text
        }

        const styleObject = styleToObject(attribute)
        let flip
        let mirror
        if (styleObject.flip == null) {
          flip = false
        } else {
          flip = (styleObject.flip === 'true')
        }
        if (styleObject.mirror == null) {
          mirror = false
        } else {
          mirror = (styleObject.mirror === 'true')
        }

        if (cell.CellType === 'Component') {
          const inputPorts = cell.explicitInputPorts + cell.implicitInputPorts
          const outputPorts = cell.explicitOutputPorts + cell.implicitOutputPorts
          const controlPorts = cell.controlPorts
          const commandPorts = cell.commandPorts
          const geometry = cell.geometry

          text = 'Block Name: ' + styleObject.default + '\n' +
            'Simulation: ' + cell.simulationFunction + '\n' +
            'UID: ' + cell.id + '\n' +
            'Style: ' + cell.style + '\n' +
            'Flip: ' + flip + '\n' +
            'Mirror: ' + mirror + '\n' +
            'Input Ports: ' + inputPorts + '\n' +
            'Output Ports: ' + outputPorts + '\n' +
            'Control Ports: ' + controlPorts + '\n' +
            'Command Ports: ' + commandPorts + '\n' +
            'x: ' + geometry.x + '\n' +
            'y: ' + geometry.y + '\n' +
            'w: ' + geometry.width + '\n' +
            'h: ' + geometry.height + '\n'
        } else {
          const geometry = cell.geometry

          text = styleObject.default + '\n' +
            'UID: ' + cell.id + '\n' +
            'Style: ' + cell.style + '\n' +
            'Flip: ' + flip + '\n' +
            'Mirror: ' + mirror + '\n' +
            'x: ' + geometry.x + '\n' +
            'y: ' + geometry.y + '\n' +
            'w: ' + geometry.width + '\n' +
            'h: ' + geometry.height + '\n'
        }
      }
      return text
    }

    graph.isHtmlLabel = function (cell) {
      return !this.isSwimlane(cell)
    }

    graph.convertValueToString = function (cell) {
      if (cell.style == null) {
        return ''
      }
      const attribute = styleToObject(cell.style).default

      const stylesheet = graph.getStylesheet()
      const style = stylesheet.styles[attribute]
      let displayedLabel = style?.displayedLabel
      if (displayedLabel == null) {
        return cell.getAttribute('label', '')
      }

      const displayParameter = cell.displayProperties.display_parameter
      if (displayParameter == null) {
        return displayedLabel
      }

      const displayParameters = displayParameter.split(',')
      for (const lbl of displayParameters) {
        displayedLabel = displayedLabel.replace('%s', lbl)
      }
      return displayedLabel
    }

    // Switch for black background and bright styles
    const invert = false

    if (invert) {
      container.style.backgroundColor = 'black'

      // White in-place editor text color
      const mxCellEditorStartEditing = mxCellEditor.prototype.startEditing
      mxCellEditor.prototype.startEditing = function (cell, trigger) {
        mxCellEditorStartEditing.apply(this, arguments)

        if (this.textarea != null) {
          this.textarea.style.color = '#FFFFFF'
        }
      }

      mxGraphHandler.prototype.previewColor = 'white'
    }

    const labelBackground = (invert) ? '#000000' : '#FFFFFF'
    const fontColor = (invert) ? '#FFFFFF' : '#000000'
    const strokeColor = (invert) ? '#C0C0C0' : '#000000'

    let style = graph.getStylesheet().getDefaultEdgeStyle()
    delete style.endArrow
    style.strokeColor = strokeColor
    style.labelBackgroundColor = labelBackground
    style.edgeStyle = 'wireEdgeStyle'
    style.fontColor = fontColor
    style.fontSize = '9'
    style.movable = '0'
    style.strokeWidth = strokeWidth
    // style.rounded = '1'

    // Sets join node size
    style.startSize = joinNodeSize
    style.endSize = joinNodeSize

    style = graph.getStylesheet().getDefaultVertexStyle()
    style.gradientDirection = 'south'
    // style.gradientColor = '#909090'
    style.strokeColor = strokeColor
    // style.fillColor = '#e0e0e0'
    style.fillColor = 'none'
    style.fontColor = fontColor
    style.fontStyle = '1'
    style.fontSize = '12'
    style.resizable = '0'
    style.rounded = '1'
    style.strokeWidth = strokeWidth

    sideBar(graph, sidebar)
    keyboardShortcuts(graph)
    // NetlistInfoFunct(graph)
    toolbarTools(graph)

    store.subscribe(() => {
      const id = store.getState().componentPropertiesReducer.id
      const parameterValues = store.getState().componentPropertiesReducer.parameter_values
      const displayProperties = store.getState().componentPropertiesReducer.displayProperties
      const cellList = graph.getModel().cells
      const c = cellList[id]
      if (c !== undefined) {
        c.parameter_values = parameterValues
        c.errorFields = {}
        c.displayProperties = displayProperties
      }
    })

    // Wire-mode
    const checkbox = {
      checked: false
    }

    // document.body.appendChild(checkbox)
    // mxUtils.write(document.body, 'Wire Mode')

    // Starts connections on the background in wire-mode
    const connectionHandlerIsStartEvent = graph.connectionHandler.isStartEvent
    graph.connectionHandler.isStartEvent = function (me) {
      return checkbox.checked || connectionHandlerIsStartEvent.apply(this, arguments)
    }

    // Avoids any connections for gestures within tolerance except when in wire-mode
    // or when over a port
    const connectionHandlerMouseUp = graph.connectionHandler.mouseUp
    graph.connectionHandler.mouseUp = function (sender, me) {
      if (this.first != null && this.previous != null) {
        const point = mxUtils.convertPoint(this.graph.container, me.getX(), me.getY())
        const dx = Math.abs(point.x - this.first.x)
        const dy = Math.abs(point.y - this.first.y)

        if (dx < this.graph.tolerance && dy < this.graph.tolerance) {
          // Selects edges in non-wire mode for single clicks, but starts
          // connecting for non-edges regardless of wire-mode
          if (!checkbox.checked && this.graph.getModel().isEdge(this.previous.cell)) {
            this.reset()
          }

          return
        }
      }

      connectionHandlerMouseUp.apply(this, arguments)
    }

    // Grid
    /* const checkbox2 = document.createElement('input')
    checkbox2.setAttribute('type', 'checkbox')
    checkbox2.setAttribute('checked', 'true')

    document.body.appendChild(checkbox2)
    mxUtils.write(document.body, 'Grid')

    mxEvent.addListener(checkbox2, 'click', function (evt) {
      if (checkbox2.checked) {
        container.style.background = 'url(\'images/wires-grid.gif\')'
      } else {
        container.style.background = ''
      }

      container.style.backgroundColor = (invert) ? 'black' : 'white'
    }) */

    mxEvent.disableContextMenu(container)
  }

  // Computes the position of edge to edge connection points.
  mxGraphView.prototype.updateFixedTerminalPoint = function (edge, terminal, source, constraint) {
    let pt = null

    if (constraint != null) {
      pt = this.graph.getConnectionPoint(terminal, constraint)
    }

    if (pt == null) {
      const s = this.scale
      const tr = this.translate
      const orig = edge.origin
      const geo = this.graph.getCellGeometry(edge.cell)
      pt = geo.getTerminalPoint(source)

      // Computes edge-to-edge connection point
      if (pt != null) {
        pt = new mxPoint(s * (tr.x + pt.x + orig.x),
          s * (tr.y + pt.y + orig.y))

        // Finds nearest segment on edge and computes intersection
        if (terminal != null && terminal.absolutePoints != null) {
          const seg = mxUtils.findNearestSegment(terminal, pt.x, pt.y)

          // Finds orientation of the segment
          const p0 = terminal.absolutePoints[seg]
          const pe = terminal.absolutePoints[seg + 1]
          const horizontal = (p0.x - pe.x === 0)

          // Stores the segment in the edge state
          const key = (source) ? 'sourceConstraint' : 'targetConstraint'
          const value = (horizontal) ? 'horizontal' : 'vertical'
          edge.style[key] = value

          // Keeps the coordinate within the segment bounds
          if (horizontal) {
            pt.x = p0.x
            pt.y = Math.min(pt.y, Math.max(p0.y, pe.y))
            pt.y = Math.max(pt.y, Math.min(p0.y, pe.y))
          } else {
            pt.y = p0.y
            pt.x = Math.min(pt.x, Math.max(p0.x, pe.x))
            pt.x = Math.max(pt.x, Math.min(p0.x, pe.x))
          }
        }
      } else if (terminal != null && terminal.cell.geometry?.relative) {
        // Computes constraint connection points on vertices and ports
        pt = new mxPoint(this.getRoutingCenterX(terminal),
          this.getRoutingCenterY(terminal))
      }
    }

    edge.setAbsoluteTerminalPoint(pt, source)
  }
  // Sets source terminal point for edge-to-edge connections.
  mxConnectionHandler.prototype.createEdgeState = function (me) {
    const edge = this.graph.createEdge()

    if (this.sourceConstraint != null && this.previous != null) {
      edge.style = mxConstants.STYLE_EXIT_X + '=' + this.sourceConstraint.point.x + ';' +
        mxConstants.STYLE_EXIT_Y + '=' + this.sourceConstraint.point.y + ';'
    } else if (this.graph.model.isEdge(me.getCell())) {
      const scale = this.graph.view.scale
      const tr = this.graph.view.translate
      const pt = new mxPoint(this.graph.snap(me.getGraphX() / scale) - tr.x,
        this.graph.snap(me.getGraphY() / scale) - tr.y)
      edge.geometry.setTerminalPoint(pt, true)
    }

    return this.graph.view.createState(edge)
  }

  // Uses right mouse button to create edges on background (see also: lines 67 ff)
  mxConnectionHandler.prototype.isStopEvent = function (me) {
    return me.getState() != null || mxEvent.isRightMouseButton(me.getEvent())
  }

  // Updates target terminal point for edge-to-edge connections.
  try {
    const mxConnectionHandlerUpdateCurrentState = mxConnectionHandler.prototype.updateCurrentState
    mxConnectionHandler.prototype.updateCurrentState = function (me) {
      try {
        mxConnectionHandlerUpdateCurrentState.apply(this, arguments)
      } catch (err) {
      }
      if (this.edgeState != null) {
        this.edgeState.cell.geometry.setTerminalPoint(null, false)

        if (this.shape != null && this.currentState != null &&
          this.currentState.view.graph.model.isEdge(this.currentState.cell)) {
          const scale = this.graph.view.scale
          const tr = this.graph.view.translate
          const pt = new mxPoint(this.graph.snap(me.getGraphX() / scale) - tr.x,
            this.graph.snap(me.getGraphY() / scale) - tr.y)
          this.edgeState.cell.geometry.setTerminalPoint(pt, false)
        }
      }
    }
  } catch (e) {
    console.error(e)
  }

  // Updates the terminal and control points in the cloned preview.
  mxEdgeSegmentHandler.prototype.clonePreviewState = function (point, terminal) {
    const clone = mxEdgeHandler.prototype.clonePreviewState.apply(this, arguments)
    clone.cell = clone.cell.clone()

    if (this.isSource || this.isTarget) {
      clone.cell.geometry = clone.cell.geometry.clone()

      // Sets the terminal point of an edge if we're moving one of the endpoints
      if (this.graph.getModel().isEdge(clone.cell)) {
        // TODO: Only set this if the target or source terminal is an edge
        clone.cell.geometry.setTerminalPoint(point, this.isSource)
      } else {
        clone.cell.geometry.setTerminalPoint(null, this.isSource)
      }
    }

    return clone
  }

  const mxEdgeHandlerConnect = mxEdgeHandler.prototype.connect
  mxEdgeHandler.prototype.connect = function (edge, terminal, isSource, isClone, me) {
    let result = null
    const model = this.graph.getModel()

    model.beginUpdate()
    try {
      result = mxEdgeHandlerConnect.apply(this, arguments)
      let geo = model.getGeometry(result)

      if (geo != null) {
        geo = geo.clone()
        let pt = null

        if (model.isEdge(terminal)) {
          pt = this.abspoints[(this.isSource) ? 0 : this.abspoints.length - 1]
          pt.x = pt.x / this.graph.view.scale - this.graph.view.translate.x
          pt.y = pt.y / this.graph.view.scale - this.graph.view.translate.y

          const pstate = this.graph.getView().getState(
            this.graph.getModel().getParent(edge))

          if (pstate != null) {
            pt.x -= pstate.origin.x
            pt.y -= pstate.origin.y
          }

          pt.x -= this.graph.panDx / this.graph.view.scale
          pt.y -= this.graph.panDy / this.graph.view.scale
        }

        geo.setTerminalPoint(pt, isSource)
        model.setGeometry(edge, geo)
      }
    } finally {
      model.endUpdate()
    }

    return result
  }

  const mxConnectionHandlerCreateMarker = mxConnectionHandler.prototype.createMarker
  mxConnectionHandler.prototype.createMarker = function () {
    const marker = mxConnectionHandlerCreateMarker.apply(this, arguments)

    // Uses complete area of cell for new connections (no hotspot)
    marker.intersects = function (state, evt) {
      return true
    }

    // Adds in-place highlighting
    marker.highlight.highlight = function (state) {
      if (this.state !== state) {
        if (this.state != null) {
          this.state.style = this.lastStyle

          // Workaround for shape using current stroke width if no strokewidth defined
          this.state.style.strokeWidth = this.state.style.strokeWidth || '1'
          this.state.style.strokeColor = this.state.style.strokeColor || 'none'

          if (this.state.shape != null) {
            this.state.view.graph.cellRenderer.configureShape(this.state)
            this.state.shape.redraw()
          }
        }

        if (state != null) {
          this.lastStyle = state.style
          state.style = mxUtils.clone(state.style)
          state.style.strokeColor = '#00ff00'
          state.style.strokeWidth = '3'

          if (state.shape != null) {
            state.view.graph.cellRenderer.configureShape(state)
            state.shape.redraw()
          }
        }

        this.state = state
      }
    }

    return marker
  }

  const mxEdgeHandlerCreateMarker = mxEdgeHandler.prototype.createMarker
  mxEdgeHandler.prototype.createMarker = function () {
    const marker = mxEdgeHandlerCreateMarker.apply(this, arguments)

    // Adds in-place highlighting when reconnecting existing edges
    marker.highlight.highlight = this.graph.connectionHandler.marker.highlight.highlight

    return marker
  }

  const mxGraphGetCellStyle = mxGraph.prototype.getCellStyle
  mxGraph.prototype.getCellStyle = function (cell) {
    let style = mxGraphGetCellStyle.apply(this, arguments)

    if (style != null && this.model.isEdge(cell)) {
      style = mxUtils.clone(style)

      if (this.model.isEdge(this.model.getTerminal(cell, true))) {
        style.startArrow = 'oval'
      }

      if (this.model.isEdge(this.model.getTerminal(cell, false))) {
        style.endArrow = 'oval'
      }
    }

    return style
  }

  function ResistorShape () { }
  ResistorShape.prototype = new mxCylinder()
  ResistorShape.prototype.constructor = ResistorShape

  ResistorShape.prototype.redrawPath = function (path, x, y, w, h, isForeground) {
    const dx = w / 16

    if (isForeground) {
      path.moveTo(0, h / 2)
      path.lineTo(2 * dx, h / 2)
      path.lineTo(3 * dx, 0)
      path.lineTo(5 * dx, h)
      path.lineTo(7 * dx, 0)
      path.lineTo(9 * dx, h)
      path.lineTo(11 * dx, 0)
      path.lineTo(13 * dx, h)
      path.lineTo(14 * dx, h / 2)
      path.lineTo(16 * dx, h / 2)

      path.end()
    }
  }

  mxCellRenderer.registerShape('resistor', ResistorShape)

  mxEdgeStyle.WireConnector = function (state, source, target, hints, result) {
    // Creates array of all way- and terminalpoints
    const pts = state.absolutePoints
    let horizontal = true
    let hint = null

    // Gets the initial connection from the source terminal or edge
    if (source != null && state.view.graph.model.isEdge(source.cell)) {
      horizontal = state.style.sourceConstraint === 'horizontal'
    } else if (source != null) {
      horizontal = source.style.portConstraint !== 'vertical'

      // Checks the direction of the shape and rotates
      const direction = source.style[mxConstants.STYLE_DIRECTION]

      if (direction === 'north' || direction === 'south') {
        horizontal = !horizontal
      }
    }

    // Adds the first point
    // TODO: Should move along connected segment
    let pt = pts[0]

    if (pt == null && source != null) {
      pt = new mxPoint(state.view.getRoutingCenterX(source), state.view.getRoutingCenterY(source))
    } else if (pt != null) {
      pt = pt.clone()
    }

    const first = pt

    // Adds the waypoints
    if (hints != null && hints.length > 0) {
      // FIXME: First segment not movable
      /* hint = state.view.transformControlPoint(state, hints[0])
         mxLog.show()
         mxLog.debug(hints.length, 'hints0.y=' + hint.y, pt.y)

         if (horizontal && Math.floor(hint.y) != Math.floor(pt.y))
         {
           mxLog.show()
           mxLog.debug('add waypoint')

           pt = new mxPoint(pt.x, hint.y)
           result.push(pt)
           pt = pt.clone()
           horizontal = !horizontal
         } */

      for (let i = 0; i < hints.length; i++) {
        horizontal = !horizontal
        hint = state.view.transformControlPoint(state, hints[i])

        if (horizontal) {
          if (pt.y !== hint.y) {
            pt.y = hint.y
            result.push(pt.clone())
          }
        } else if (pt.x !== hint.x) {
          pt.x = hint.x
          result.push(pt.clone())
        }
      }
    } else {
      hint = pt
    }

    // Adds the last point
    pt = pts[pts.length - 1]

    // TODO: Should move along connected segment
    if (pt == null && target != null) {
      pt = new mxPoint(state.view.getRoutingCenterX(target), state.view.getRoutingCenterY(target))
    }

    if (horizontal) {
      if (pt.y !== hint.y && first.x !== pt.x) {
        result.push(new mxPoint(pt.x, hint.y))
      }
    } else if (pt.x !== hint.x && first.y !== pt.y) {
      result.push(new mxPoint(hint.x, pt.y))
    }
  }

  mxStyleRegistry.putValue('wireEdgeStyle', mxEdgeStyle.WireConnector)

  // This connector needs an mxEdgeSegmentHandler
  const mxGraphCreateHandler = mxGraph.prototype.createHandler
  mxGraph.prototype.createHandler = function (state) {
    if (state != null) {
      if (this.model.isEdge(state.cell)) {
        const style = this.view.getEdgeStyle(state)

        if (style === mxEdgeStyle.WireConnector) {
          return new mxEdgeSegmentHandler(state)
        }
      }
    }

    return mxGraphCreateHandler.apply(this, arguments)
  }
}
