from common.AAAAAA import *


def PerteDP(outroot, attribid, ordering, geometry, parameters, parent=1, style=None):
    func_name = 'PerteDP'
    if style is None:
        style = func_name

    outnode = addOutNode(outroot, BLOCK_BASIC,
                         attribid, ordering, parent,
                         func_name, 'PerteDP', 'DEFAULT',
                         style, BLOCKTYPE_C,
                         dependsOnU='1')

    addExprsNode(outnode, TYPE_STRING, 6, parameters)
    addScilabDNode(outnode, AS_REAL_PARAM, width=6, realParts=[
                   format_real_number(parameters[0]),
                   format_real_number(parameters[1]),
                   "0.03",
                   format_real_number(parameters[3]),
                   format_real_number(parameters[4]),
                   format_real_number(parameters[5])
                   ])
    addTypeNode(outnode, TYPE_DOUBLE, AS_INT_PARAM, 0, [])
    addObjNode(outnode, TYPE_ARRAY, CLASS_LIST, AS_OBJ_PARAM, parameters)
    array = ['0']
    addPrecisionNode(outnode, TYPE_INTEGER, AS_NBZERO, 1, array)
    addPrecisionNode(outnode, TYPE_INTEGER, AS_NMODE, 1, array)
    addTypeNode(outnode, TYPE_DOUBLE, AS_STATE, 0, [])
    addSciDBNode(outnode, TYPE_DOUBLE, AS_DSTATE, 0, [])
    addObjNode(outnode, TYPE_ARRAY, CLASS_LIST, AS_ODSTATE, parameters)
    equationsArrayNode = addArrayNode(outnode, scilabClass="ScilabTList",
                                      **{'as': 'equations'})

    # Add ScilabString nodes to equationsArrayNode
    scilabStringParameters = ["modelica", "model",
                              "inputs", "outputs",
                              "parameters"]
    addScilabStringNode(equationsArrayNode, width=5,
                        parameters=scilabStringParameters)

    # Add additional ScilabString nodes to equationsArrayNode
    additionalScilabStrings = ["PerteDP", "C1"]
    for param in additionalScilabStrings:
        additionalStringNode = addDataNode(equationsArrayNode,
                                           'ScilabString',
                                           height=1, width=1)
        addDataData(additionalStringNode, param)

    additionalStringNode1 = addDataNode(equationsArrayNode,
                                        'ScilabString',
                                        height=1, width=1)
    addDataData(additionalStringNode1, "C2")

    innerArrayNode = addArrayNode(equationsArrayNode,
                                  scilabClass="ScilabList")
    additionalSciStrings = ["L", "D", "lambda", "z1", "z2", "p_rho"]
    additionalStringNode = addDataNode(innerArrayNode,
                                       'ScilabString',
                                       height=6, width=1)
    for param in additionalSciStrings:
        addDataData(additionalStringNode, param)

    addNodeScilabDouble(innerArrayNode, height=6, realParts=[
                        format_real_number(parameters[0]),
                        format_real_number(parameters[1]),
                        "0.03",
                        format_real_number(parameters[3]),
                        format_real_number(parameters[4]),
                        format_real_number(parameters[5])
                        ])
    addgeometryNode(outnode, GEOMETRY, geometry['height'],
                    geometry['width'], geometry['x'], geometry['y'])

    return outnode


def get_from_PerteDP(cell):
    parameters = getParametersFromExprsNode(cell, TYPE_STRING)

    display_parameter = ''

    eiv = ''
    iiv = ''
    con = ''
    eov = ''
    iov = ''
    com = ''

    ports = [eiv, iiv, con, eov, iov, com]

    return (parameters, display_parameter, ports)
