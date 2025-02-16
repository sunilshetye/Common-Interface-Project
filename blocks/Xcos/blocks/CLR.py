from common.AAAAAA import *


def CLR(outroot, attribid, ordering, geometry, parameters, parent=1, style=None):
    func_name = 'CLR'
    if style is None:
        style = func_name

    outnode = addOutNode(outroot, BLOCK_BASIC,
                         attribid, ordering, parent,
                         func_name, 'csslti4', 'C_OR_FORTRAN',
                         style, BLOCKTYPE_C,
                         dependsOnT='1')

    addExprsNode(outnode, TYPE_STRING, 2, parameters)
    addSciDBNode(outnode, TYPE_DOUBLE, AS_REAL_PARAM, 16, realParts=[0.0,
                 -100.0,
                 1.0, -12.0, 0.0, 1.0, 100.0,
                 0.0, 0.0]
                 )
    addTypeNode(outnode, TYPE_DOUBLE, AS_INT_PARAM, 0, [])
    addObjNode(outnode, TYPE_ARRAY, CLASS_LIST, AS_OBJ_PARAM, parameters)
    array = ['0']
    addPrecisionNode(outnode, TYPE_INTEGER, AS_NBZERO, 1, array)
    addPrecisionNode(outnode, TYPE_INTEGER, AS_NMODE, 1, array)
    addSciDBNode(outnode, TYPE_DOUBLE, AS_STATE,
                 3, realParts=[0.0, 0.0, 0.0])
    addTypeNode(outnode, TYPE_DOUBLE, AS_DSTATE, 0, [])
    addObjNode(outnode, TYPE_ARRAY, CLASS_LIST, AS_ODSTATE, parameters)
    addArrayNode(outnode, scilabClass="ScilabList",
                                      **{'as': 'equations'})
    addgeometryNode(outnode, GEOMETRY, geometry['height'],
                    geometry['width'], geometry['x'], geometry['y'])

    return outnode


def get_from_CLR(cell):
    parameters = getParametersFromExprsNode(cell, TYPE_STRING)

    dp1 = get_value_min(parameters[0])
    dp2 = get_value_min(parameters[1])
    display_parameter = dp1 + ',' + dp2

    eiv = ''
    iiv = ''
    con = ''
    eov = ''
    iov = ''
    com = ''

    ports = [eiv, iiv, con, eov, iov, com]

    return (parameters, display_parameter, ports)
