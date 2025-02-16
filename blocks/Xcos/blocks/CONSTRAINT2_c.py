from common.AAAAAA import *


def CONSTRAINT2_c(outroot, attribid, ordering, geometry, parameters, parent=1, style=None):
    func_name = 'CONSTRAINT2_c'
    if style is None:
        style = func_name

    outnode = addOutNode(outroot, BLOCK_BASIC,
                         attribid, ordering, parent,
                         func_name, 'constraint_c', 'IMPLICIT_C_OR_FORTRAN',
                         style, BLOCKTYPE_C,
                         dependsOnT='1')

    addExprsArrayNode(outnode, TYPE_STRING, 1, parameters, [], TYPE_STRING, func_name)
    addTypeNode(outnode, TYPE_DOUBLE, AS_REAL_PARAM, 0, [])
    addPrecNode(outnode, TYPE_INTEGER, AS_INT_PARAM, 1, parameters[0])
    addObjNode(outnode, TYPE_ARRAY, CLASS_LIST, AS_OBJ_PARAM, parameters)
    array = ['0']
    addPrecisionNode(outnode, TYPE_INTEGER, AS_NBZERO, 1, array)
    addPrecisionNode(outnode, TYPE_INTEGER, AS_NMODE, 1, array)
    addScilabDNode(outnode, AS_STATE, width=2, realParts=[
                   format_real_number(parameters[0]),
                   format_real_number(parameters[1])])
    addTypeNode(outnode, TYPE_DOUBLE, AS_DSTATE, 0, [])
    addObjNode(outnode, TYPE_ARRAY, CLASS_LIST, AS_ODSTATE, parameters)
    addObjNode(outnode, TYPE_ARRAY,
               CLASS_LIST, AS_EQUATIONS, parameters)
    addgeometryNode(outnode, GEOMETRY, geometry['height'],
                    geometry['width'], geometry['x'], geometry['y'])

    return outnode


def get_from_CONSTRAINT2_c(cell):
    parameters = getParametersFromExprsNode(cell, TYPE_STRING)

    display_parameter = parameters[0] + ',' + parameters[1]

    eiv = ''
    iiv = ''
    con = ''
    eov = ''
    iov = ''
    com = ''

    ports = [eiv, iiv, con, eov, iov, com]

    return (parameters, display_parameter, ports)
