/* eslint new-cap: ["error", {"newIsCapExceptionPattern": "^mx"}] */
import 'mxgraph/javascript/src/css/common.css'

import mxGraphFactory from 'mxgraph'

import { getRotationParameters, PORTDIRECTIONS } from './ToolbarTools'

const {
  mxPoint
} = new mxGraphFactory()

// we need to divide the svg width and height by the same number in order to maintain the aspect ratio.
export const defaultScale = parseFloat(process.env.REACT_APP_BLOCK_SCALE)
export const portSize = parseFloat(process.env.REACT_APP_PORT_SIZE)

export function getParameter (i) {
  if (i < 10) { return 'p00' + i.toString() } else if (i < 100) { return 'p0' + i.toString() } else { return 'p' + i.toString() }
}

export function getSvgMetadata (graph, parent, evt, target, x, y, component) {
  // calls extractData and other MXGRAPH functions
  // initialize information from the svg meta
  // plots pinnumbers and component labels.

  const allowedPart = [0, 1]
  const allowedDmg = [0, 1]

  const blockName = component.block_name
  const parameterCount = component.newblockparameter_set.length
  // make the component images smaller by scaling
  const width = component.block_width / defaultScale
  const height = component.block_height / defaultScale

  const v1 = graph.insertVertex(parent, null, null, x, y, width, height, blockName)
  v1.CellType = 'Component'
  v1.blockprefix = component.blockprefix.name
  v1.displayProperties = {
    display_parameter: component.initial_display_parameter
  }
  const parameterValues = {}
  for (let i = 0; i < parameterCount; i++) {
    const p = getParameter(i) + '_value'
    parameterValues[p] = component.newblockparameter_set[i].p_value_initial
  }
  v1.parameter_values = parameterValues
  v1.errorFields = {}

  v1.setConnectable(false)

  const blockports = component.newblockport_set
  const ports = blockports.length
  v1.explicitInputPorts = 0
  v1.implicitInputPorts = 0
  v1.explicitOutputPorts = 0
  v1.implicitOutputPorts = 0
  v1.controlPorts = 0
  v1.commandPorts = 0
  v1.simulationFunction = component.simulation_function
  v1.pins = {
    explicitInputPorts: [],
    implicitInputPorts: [],
    controlPorts: [],
    explicitOutputPorts: [],
    implicitOutputPorts: [],
    commandPorts: []
  }
  for (let i = 0; i < ports; i++) {
    const blockport = blockports[i]

    if (!allowedPart.includes(blockport.port_part)) { continue }
    if (!allowedDmg.includes(blockport.port_dmg)) { continue }
    if (blockport.port_name === 'NC') { continue }

    let xPos = 1 / 2 + blockport.port_x / defaultScale / width
    let yPos = 1 / 2 + blockport.port_y / defaultScale / height

    const portOrientation = blockport.port_orientation
    const portRotation = blockport.port_rotation
    const rotationParameters = getRotationParameters(portOrientation, portRotation)

    let pointX
    let pointY
    let pins
    switch (rotationParameters.rotatename) {
      case 'ExplicitInputPort':
        pointX = -portSize
        pointY = -portSize / 2
        break
      case 'ControlPort':
        pointX = -portSize / 2
        pointY = -portSize
        break
      case 'ExplicitOutputPort':
        pointX = 0
        pointY = -portSize / 2
        break
      case 'CommandPort':
        pointX = -portSize / 2
        pointY = 0
        break
      default:
        pointX = -portSize / 2
        pointY = -portSize / 2
        break
    }
    switch (portOrientation) {
      case 'ExplicitInputPort':
        v1.explicitInputPorts += 1
        pins = v1.pins.explicitInputPorts
        break
      case 'ImplicitInputPort':
        v1.implicitInputPorts += 1
        pins = v1.pins.implicitInputPorts
        break
      case 'ControlPort':
        v1.controlPorts += 1
        pins = v1.pins.controlPorts
        break
      case 'ExplicitOutputPort':
        v1.explicitOutputPorts += 1
        pins = v1.pins.explicitOutputPorts
        break
      case 'ImplicitOutputPort':
        v1.implicitOutputPorts += 1
        pins = v1.pins.implicitOutputPorts
        break
      case 'CommandPort':
        v1.commandPorts += 1
        pins = v1.pins.commandPorts
        break
      default:
        pins = null
        break
    }

    const xPosOld = xPos
    switch (rotationParameters.portdirection) {
      case PORTDIRECTIONS.L2T:
      case PORTDIRECTIONS.T2L:
        xPos = yPos
        yPos = xPosOld
        break
      case PORTDIRECTIONS.L2R:
        xPos = 1 - xPosOld
        /* same yPos */
        break
      case PORTDIRECTIONS.L2B:
        xPos = yPos
        yPos = 1 - xPosOld
        break
      case PORTDIRECTIONS.T2R:
        xPos = 1 - yPos
        yPos = xPosOld
        break
      case PORTDIRECTIONS.T2B:
        /* same xPos */
        yPos = 1 - yPos
        break
    }
    const point = new mxPoint(pointX, pointY)

    const vp = graph.insertVertex(v1, null, null, xPos, yPos, portSize, portSize, portOrientation)
    vp.geometry.relative = true
    vp.geometry.offset = point
    vp.CellType = 'Pin'
    vp.ParentComponent = v1.id
    if (pins != null) {
      pins.push(vp)
    }
  }
}
