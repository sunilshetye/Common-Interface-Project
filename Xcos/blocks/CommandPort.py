def CommandPort(outroot, attribid, parentattribid, ordering, geometry, value='', forSplitBlock=False):
    func_name = 'CommandPort'

    if forSplitBlock:
        outnode = addNode(outroot, func_name, dataType='UNKNOW_TYPE',
            **{'id': attribid}, ordering=ordering, parent=parentattribid,
            style=func_name, visible=0)
    else:
        outnode = addNode(outroot, func_name, dataType='UNKNOW_TYPE',
            **{'id': attribid}, ordering=ordering, parent=parentattribid,
            style=func_name)

    node = addNode(outnode, 'mxGeometry', **{'as': 'geometry'},
        height='8.0', width='8.0', x='100.0', y='160.0')

    return outnode
