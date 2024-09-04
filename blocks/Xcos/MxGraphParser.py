#!/usr/bin/env python

import datetime
import os
import re
import sys
import traceback
import xml.etree.ElementTree as ET
import defusedxml.ElementTree as goodET

from xcosblocks import *

if len(sys.argv) != 2:
    print("Usage: %s filename.xml" % sys.argv[0])
    sys.exit(1)

filename = sys.argv[1]
(basename, ext) = os.path.splitext(filename)

if ext != '.xml':
    print("Usage: %s filename.xml" % sys.argv[0])
    sys.exit(1)
base = r'(_[a-zA-Z]*_on_Cloud)?( *\([0-9]*\))?\.xml$'
title = re.sub(r'^.*/', r'', filename)
title = re.sub(base, r'', title)

tree = goodET.parse(filename)

model = tree.getroot()
if model.tag != 'mxGraphModel':
    print(model.tag, '!= mxGraphModel')
    sys.exit(2)
outdiagram = ET.Element('XcosDiagram')
outdiagram.set('background', '-1')
outdiagram.set('finalIntegrationTime', '30.0')   # TODO: From POST
outdiagram.set('title', title)
dt = datetime.datetime(2021, 7, 15, 15, 31)
comment = ET.Comment(dt.strftime('Xcos - 2.0 - scilab-6.1.1 - %Y%m%d %H%M'))
outdiagram.append(comment)
outmodel = ET.SubElement(outdiagram, 'mxGraphModel')
outmodel.set('as', 'model')

def split_array_by_point(array, point):
    for i in range(len(array) - 1):
        # Check if the point lies on the line segment between array[i] and array[i + 1]
        if -40<= array[i]['y'] - point['y']<=40 and -40<= array[i + 1]['y'] - point['y']<=40 and array[i]['x'] <= point['x'] <= array[i + 1]['x']:
            # Split the array into two parts
            return array[:i+1], array[i+1:]
        if -40<= array[i]['x'] - point['x']<=40 and -40<= array[i + 1]['x'] - point['x']<=40 and array[i]['y'] <= point['y'] <= array[i + 1]['y']:
            # Split the array into two parts
            return array[:i+1], array[i+1:]
        
    return array, []

def check_point_on_array(array, point):
    print('P1', array, point)
    for i in range(len(array) - 1):
        # Check if the point lies on the line segment between array[i] and array[i + 1]
        if -40<= array[i]['y'] - point['y']<=40 and -40<= array[i + 1]['y'] - point['y']<=40 and array[i]['x'] <= point['x'] <= array[i + 1]['x']:
            # Split the array into two parts
            return True, array[:i+1], array[i+1:]
        if -40<= array[i]['x'] - point['x']<=40 and -40<= array[i + 1]['x'] - point['x']<=40 and array[i]['y'] <= point['y'] <= array[i + 1]['y']:
            # Split the array into two parts
            return True, array[:i+1], array[i+1:]
        
    return False, array, []

def splitlink_by_point(array1, s1, t1, array2, s2, t2, array3, s3, t3, point):
    onarray, array4, array5 = check_point_on_array(array1, point)
    print('testcheck',onarray, array4, array5)
    if onarray == True:
        return array1, s1, t1, array4, array5
    onarray, array4, array5 = check_point_on_array(array2, point)
    if onarray == True:
        return array2, s2, t2, array4, array5 
    onarray, array4, array5 = check_point_on_array(array3, point)
    if onarray == True:
        return array3, s3, t3, array4, array5

for root in model:
    if root.tag != 'root':
        print('Not root')
        sys.exit(2)
    outroot = ET.SubElement(outmodel, 'root')

    EIV = {}
    IIV = {}
    CON = {}
    EOV = {}
    IOV = {}
    COM = {}
    IDLIST = {}
    componentOrdering = 0
    nextattribid = 0
    nextAttribForSplit = 10000
    edgeDict = {}
    edgeDict2 = {}
    splitList = []
    mxPointList = {}
    blkgeometry = {}
    points1 = []
    for cell in list(root):
        try:
            attrib = cell.attrib
            attribid = attrib['id']
            if nextattribid <= int(attribid):
                nextattribid = int(attribid) + 1

            if attribid == '0':
                outnode = ET.SubElement(outroot, 'mxCell')
                outnode.set('id', attribid)
                continue

            if attribid == '1':
                outnode = ET.SubElement(outroot, 'mxCell')
                outnode.set('id', attribid)
                outnode.set('parent', '0')
                continue

            cell_type = attrib['CellType']

            if cell_type == 'Component':
                style = attrib['style']
                componentGeometry = {}
                componentGeometry['height'] = 40
                componentGeometry['width'] = 40
                componentGeometry['x'] = 0
                componentGeometry['y'] = 0
                componentOrdering += 1
                parameter_values = cell.find('./Object[@as="parameter_values"]')
                parameters = []
                if parameter_values is not None:
                    parameter_values = parameter_values.attrib
                    for i in range(100):
                        parameter = 'p%03d_value' % i
                        if parameter in parameter_values:
                            parameters.append(parameter_values[parameter])
                        else:
                            break
                mxGeometry = cell.find('mxGeometry')
                if mxGeometry is not None:
                    componentGeometry['height'] = mxGeometry.attrib['height']
                    componentGeometry['width'] = mxGeometry.attrib['width']
                    componentGeometry['x'] = mxGeometry.attrib['x']
                    componentGeometry['y'] = mxGeometry.attrib['y']
                EIV[attribid] = []
                IIV[attribid] = []
                CON[attribid] = []
                EOV[attribid] = []
                IOV[attribid] = []
                COM[attribid] = []
                IDLIST[attribid] = cell_type
                blkgeometry[attribid] = componentGeometry
                globals()[style](outroot, attribid, componentOrdering, componentGeometry, parameters)
            elif 'vertex' in attrib:
                style = attrib['style']
                geometry = {}
                geometry['height'] = 40
                geometry['width'] = 40
                geometry['x'] = 0
                geometry['y'] = 0
                ParentComponent = attrib['ParentComponent']
                if style == 'ExplicitInputPort':
                    styleArray = EIV[ParentComponent]
                elif style == 'ImplicitInputPort':
                    styleArray = IIV[ParentComponent]
                elif style == 'ControlPort':
                    styleArray = CON[ParentComponent]
                elif style == 'ExplicitOutputPort':
                    styleArray = EOV[ParentComponent]
                elif style == 'ImplicitOutputPort':
                    styleArray = IOV[ParentComponent]
                elif style == 'CommandPort':
                    styleArray = COM[ParentComponent]
                styleArray.append(attribid)
                mxGeometry = cell.find('mxGeometry')
                if mxGeometry is not None:
                    geometry['height'] = mxGeometry.attrib['height']
                    geometry['width'] = mxGeometry.attrib['width']
                    geometry['x'] = mxGeometry.attrib.get('x', 0)
                    geometry['y'] = mxGeometry.attrib.get('y', 0)
                    if mxGeometry.attrib.get('relative', '0') == '1':
                        geometry['x'] = float(componentGeometry['x']) + float(componentGeometry['width']) * float(geometry['x'])
                        geometry['y'] = float(componentGeometry['y']) + float(componentGeometry['height']) * float(geometry['y'])
                ordering = len(styleArray)
                IDLIST[attribid] = style
                blkgeometry[attribid] = blkgeometry[ParentComponent]
                print('BLKGEO', blkgeometry[attribid])
                globals()[style](outroot, attribid, ParentComponent, ordering, geometry)

            elif 'edge' in attrib:
                mxGeometry = cell.find('mxGeometry')
                array = mxGeometry.find('Array')
                celid = cell.attrib.get('id')
                mxPointList[celid] = array
                # print(mxPointList)
                for points in mxPointList:
                    value = mxPointList[points]
                arrayelem = []
                arrayElement = mxGeometry.find('Array')
                if arrayElement is not None:
                    for arrayChild in arrayElement:
                        if arrayChild.tag == 'mxPoint':
                            arrayelem.append(arrayChild.attrib)

                print('ARRAYELEM:', arrayelem)

                sourceVertex = attrib['sourceVertex']
                targetVertex = attrib['targetVertex']
                sourceType = IDLIST[sourceVertex]
                targetType = IDLIST[targetVertex]

                # switch vertices if required
                if sourceType in ['ExplicitInputPort', 'ImplicitInputPort', 'ControlPort'] and targetType in ['ExplicitOutputPort', 'ExplicitLink', 'ImplicitOutputPort', 'ImplicitLink', 'CommandPort', 'CommandControlLink']:
                    (sourceVertex, targetVertex) = (targetVertex, sourceVertex)
                    (sourceType, targetType) = (targetType, sourceType)
                elif sourceType in ['ExplicitInputPort', 'ExplicitLink', 'ImplicitInputPort', 'ImplicitLink', 'ControlPort', 'CommandControlLink'] and targetType in ['ExplicitOutputPort', 'ImplicitOutputPort', 'CommandPort']:
                    (sourceVertex, targetVertex) = (targetVertex, sourceVertex)
                    (sourceType, targetType) = (targetType, sourceType)

                style = None
                addSplit = False
                if sourceType in ['ExplicitInputPort', 'ExplicitOutputPort', 'CommandPort', 'ControlPort'] and targetType == sourceType:
                    print(attribid, 'cannot connect two ports of', sourceType, 'and', targetType)
                elif sourceType in ['ExplicitLink', 'ImplicitLink', 'CommandControlLink'] and targetType == sourceType:
                    print(attribid, 'cannot connect two links of', sourceType, 'and', targetType)
                elif sourceType in ['ExplicitOutputPort'] and targetType in ['ExplicitInputPort']:
                    style = 'ExplicitLink'
                elif sourceType in ['ExplicitOutputPort', 'ExplicitLink'] and targetType in ['ExplicitInputPort', 'ExplicitLink']:
                    style = 'ExplicitLink'
                    addSplit = True
                elif sourceType in ['ImplicitOutputPort', 'ImplicitInputPort'] and targetType in ['ImplicitInputPort', 'ImplicitOutputPort']:
                    style = 'ImplicitLink'
                elif sourceType in ['ImplicitOutputPort', 'ImplicitInputPort', 'ImplicitLink'] and targetType in ['ImplicitInputPort', 'ImplicitOutputPort', 'ImplicitLink']:
                    style= 'ImplicitLink'
                    addSplit = True
                elif sourceType in ['CommandPort'] and targetType in ['ControlPort']:
                    style = 'CommandControlLink'
                elif sourceType in ['CommandPort', 'CommandControlLink'] and targetType in ['ControlPort', 'CommandControlLink']:
                    style = 'CommandControlLink'
                    addSplit = True
                else:
                    print(attribid, 'Unknown combination of', sourceType, 'and', targetType)

                if style is None:
                    continue

                edgeDict[attribid] = (style, str(sourceVertex), str(targetVertex), sourceType, targetType, arrayelem)
                edgeDict2[attribid] = (style, str(sourceVertex), str(targetVertex), sourceType, targetType, arrayelem)
                IDLIST[attribid] = style

                if addSplit:
                    try:
                        print("SOURCEV:", edgeDict[sourceVertex])
                        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2, arrayelem2) = edgeDict[sourceVertex]
                    except KeyError:
                        pass
                    try:
                        print("SOURCET:", edgeDict[targetVertex])
                        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2, arrayelem2) = edgeDict[targetVertex]
                    except KeyError:
                        pass
                    for a in cell.attrib:
                        print(a, cell.attrib.get(a) )
                    mxGeometry = cell.find('mxGeometry')
                    if mxGeometry is not None:
                        for a in mxGeometry.attrib:
                            print(a, mxGeometry.attrib.get(a) )
                        for child in mxGeometry:
                            print(child)
                        mxPoint = mxGeometry.find('mxPoint')
                        if mxPoint is not None:
                            point = mxPoint.attrib
                            del point['as']
                            points1.append(point)
                            print('PP',points1)
                            if points1:
                                last_stored_point = points1[-1]
                            larger_array = arrayelem2
                            print('LA:', larger_array)
                            larger_array = [{k: int(v) for k, v in coord.items()} for coord in larger_array]
                            point = {k: int(v) for k, v in point.items()}

                            # Split the array
                            array1, array2 = split_array_by_point(larger_array, point)
                            print('A1:', array1)
                            print('A2:', array2)
                            array3 = arrayelem
                            for b in mxPoint.attrib:
                                print('ARRAY of SPlitLink', b, mxPoint.attrib.get(b), last_stored_point)
                            for child in mxPoint:
                                print(child)


                            geometry = {}
                            geometry['width'] = mxPoint.attrib.get('width', '7')
                            geometry['height'] = mxPoint.attrib.get('height', '7')
                            geometry['x'] = mxPoint.attrib.get('x', '0')
                            geometry['y'] = mxPoint.attrib.get('y', '0')

                            splitList.append((attribid, sourceVertex, targetVertex, sourceType, targetType, geometry, array1, array2, array3, last_stored_point))
                            # print('SPLIST', splitList)
                            try:
                                print("Source",edgeDict[sourceVertex])
                                del edgeDict[sourceVertex]
                            except KeyError:
                                pass
                            try:
                                print("target",edgeDict[targetVertex])
                                del edgeDict[targetVertex]
                            except KeyError:
                                pass
        except BaseException:
            traceback.print_exc()

dict1 = {}
for (attribid, sourceVertex, targetVertex, sourceType, targetType, geometry, array1, array2, array3, last_stored_point) in splitList:
    print('test', attribid, sourceVertex, targetVertex, sourceType, targetType, geometry, array1, array2, array3, nextattribid, last_stored_point)
    componentOrdering += 1

    SplitBlock(outroot, nextattribid, componentOrdering, geometry)
    splitblockid = nextattribid
    nextattribid += 1

    # print('DICT1:', dict1, sourceVertex, targetVertex)
    if sourceVertex in dict1:
        new_array1, new_array2, new_array3, new_splitblockid, new_sourceVertex, new_targetVertex, new_splitblkgeometry, new_port1, new_port2, new_port3, new_point = dict1[sourceVertex]
        print('DICTSV1', dict1[sourceVertex])
    elif targetVertex in dict1:
        new_array1, new_array2, new_array3, new_splitblockid, new_sourceVertex, new_targetVertex, new_splitblkgeometry, new_port1, new_port2, new_port3, new_point = dict1[targetVertex]
        print('DICTTV1', dict1[targetVertex])
    # else:
        # dict1[sourceVertex] = array1, array2, array3, splitblockid, sourceVertex, targetVertex, geometry
        # print('DICTSV2', dict1[sourceVertex], sourceVertex)
        # dict1[targetVertex] = array1, array2, array3, splitblockid, sourceVertex, targetVertex, geometry
        # print('DICTTV2', dict1[targetVertex], targetVertex)


    inputCount = 0
    outputCount = 0
    if sourceType == 'ExplicitOutputPort':
        (inputCount, outputCount, nextattribid, nextAttribForSplit) = addExplicitInputPortForSplit(outroot, splitblockid, sourceVertex, targetVertex, sourceType, targetType, edgeDict, inputCount, outputCount, nextattribid, nextAttribForSplit)
        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2, arrayelem) = edgeDict2[targetVertex]
        (inputCount, outputCount, nextattribid, nextAttribForSplit) = addExplicitInputPortForSplit(outroot, splitblockid, sourceVertex2, targetVertex2, sourceType2, targetType2, edgeDict, inputCount, outputCount, nextattribid, nextAttribForSplit)
        (inputCount, outputCount, nextattribid, nextAttribForSplit) = addExplicitOutputPortForSplit(outroot, splitblockid, sourceVertex2, targetVertex2, sourceType2, targetType2, edgeDict, inputCount, outputCount, nextattribid, nextAttribForSplit)
    elif sourceType == 'ImplicitOutputPort':
        geometry = {}
        geometry['width'] = 8
        geometry['height'] = 8
        geometry['x'] = -8
        geometry['y'] = -4
        inputCount += 1
        ImplicitInputPort(outroot, nextattribid, splitblockid, inputCount, geometry, forSplitBlock=True)
        portid = nextattribid
        nextattribid += 1
        linkid = nextAttribForSplit
        nextAttribForSplit += 1
        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2) = edgeDict2.get(sourceVertex, (None, None, None, None, None))
    elif sourceType == 'ControlPort':
        geometry = {}
        geometry['width'] = 8
        geometry['height'] = 8
        geometry['x'] = -4
        geometry['y'] = -8
        inputCount += 1
        CommandPort(outroot, nextattribid, splitblockid, inputCount, geometry, forSplitBlock=True)
        portid = nextattribid
        nextattribid += 1
        linkid = nextAttribForSplit
        nextAttribForSplit += 1
        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2) = edgeDict2[sourceVertex]
    if targetType == 'ExplicitInputPort':
        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2, arrayelem) = edgeDict2[sourceVertex]
        # print('ED2', edgeDict2[sourceVertex], sourceVertex)
        port1 = nextattribid
        print('D1:', dict1)
        if sourceVertex in dict1:
            splitpoints = splitlink_by_point(array1, sourceVertex2, new_port1, array2, new_port3, targetVertex2, array3, new_port2, targetVertex2, point)
            print('SP', splitpoints)
            key_to_remove = None
            for key, value in edgeDict.items():
                if value[1] == str(splitpoints[1]) and value[2] == str(splitpoints[2]):
                    key_to_remove = key
                    break
            
            if key_to_remove is not None:
                del edgeDict[key_to_remove]

        (inputCount, outputCount, nextattribid, nextAttribForSplit) = addExplicitInputPortForSplit(outroot, splitblockid, sourceVertex2, targetVertex2, sourceType2, targetType2, edgeDict, inputCount, outputCount, nextattribid, nextAttribForSplit, array1)
        port2 = nextattribid
        (inputCount, outputCount, nextattribid, nextAttribForSplit) = addExplicitOutputPortForSplit(outroot, splitblockid, sourceVertex2, targetVertex2, sourceType2, targetType2, edgeDict, inputCount, outputCount, nextattribid, nextAttribForSplit, array2)
        port3 = nextattribid
        (inputCount, outputCount, nextattribid, nextAttribForSplit) = addExplicitOutputPortForSplit(outroot, splitblockid, sourceVertex, targetVertex, sourceType, targetType, edgeDict, inputCount, outputCount, nextattribid, nextAttribForSplit, array3)


    elif targetType == 'ImplicitInputPort':
        geometry = {}
        geometry['width'] = 8
        geometry['height'] = 8
        geometry['x'] = 7
        geometry['y'] = -4
        outputCount += 1
        ImplicitOutputPort(outroot, nextattribid, splitblockid, outputCount, geometry, forSplitBlock=True)
        portid = nextattribid
        nextattribid += 1
        linkid = nextAttribForSplit
        nextAttribForSplit += 1
        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2) = edgeDict2.get(targetVertex, (None, None, None, None, None))
        geometry = {}
        geometry['width'] = 8
        geometry['height'] = 8
        geometry['x'] = -8
        geometry['y'] = -4
        inputCount += 1
        ImplicitInputPort(outroot, nextattribid, splitblockid, inputCount, geometry, forSplitBlock=True)
        portid = nextattribid
        nextattribid += 1
        linkid = nextAttribForSplit
        nextAttribForSplit += 1
        geometry = {}
        geometry['width'] = 8
        geometry['height'] = 8
        geometry['x'] = 7
        geometry['y'] = -4
        outputCount += 1
        ImplicitOutputPort(outroot, nextattribid, splitblockid, outputCount, geometry, forSplitBlock=True)
        portid = nextattribid
        nextattribid += 1
        linkid = nextAttribForSplit
        nextAttribForSplit += 1
    elif targetType == 'CommandPort':
        geometry = {}
        geometry['width'] = 8
        geometry['height'] = 8
        geometry['x'] = -4
        geometry['y'] = 7
        outputCount += 1
        ControlPort(outroot, nextattribid, splitblockid, outputCount, geometry, forSplitBlock=True)
        portid = nextattribid
        nextattribid += 1
        linkid = nextAttribForSplit
        nextAttribForSplit += 1
        (style2, sourceVertex2, targetVertex2, sourceType2, targetType2) = edgeDict2[targetVertex]
   
    dict1[sourceVertex] = array1, array2, array3, splitblockid, sourceVertex, targetVertex, geometry, port1, port2, port3, point
    print('DICTSV2', dict1[sourceVertex], sourceVertex)
    dict1[attribid] = array1, array2, array3, splitblockid, sourceVertex, targetVertex, geometry, port1, port2, port3, point
    dict1[targetVertex] = array1, array2, array3, splitblockid, sourceVertex, targetVertex, geometry, port1, port2, port3, point
    print('DICTTV2', dict1[targetVertex], targetVertex)

for (attribid, (style, sourceVertex, targetVertex, sourceType, targetType, array1)) in edgeDict.items():
    print("testing",attribid,style, sourceVertex, targetVertex, sourceType, targetType, array1)
    if int(attribid) >= 10000:
        attribid = nextattribid
        nextattribid += 1   
    globals()[style](outroot, attribid, sourceVertex, targetVertex, array1)

outnode = ET.SubElement(outdiagram, 'mxCell')
outnode.set('id', str(1))
outnode.set('parent', str(0))
outnode.set('as', 'defaultParent')

outtree = ET.ElementTree(outdiagram)
ET.indent(outtree)
outfile = basename + '.xcos'
outtree.write(outfile, encoding='UTF-8', xml_declaration=True)
sys.exit(0)
