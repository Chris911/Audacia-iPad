//
//  XMLUtil.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//  Original article by http://www.raywenderlich.com/725/how-to-read-and-write-xml-documents-with-gdataxml
//

#import "XMLUtil.h"
#import "Scene.h"
#import "Node.h"

@implementation XMLUtil

// Returns the complete path of the desired XML File
+ (NSString *)dataFilePath:(NSString*)fileName:(BOOL)forSave {

    NSString *filePath = [fileName stringByAppendingString:@".xml"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:filePath];
    if (forSave ||
        [[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
    }
}

+ (RenderingTree *)loadRenderingTreeFromGDataXMLDocument:(GDataXMLDocument*)doc {
    
    // Get the XML file from path
//    NSString *filePath = [self dataFilePath:name:FALSE];
//    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
//    NSError *error;
//    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
//                                                           options:0 error:&error];
    if (doc == nil) { return nil; }
    
    // Parse the tree
    RenderingTree *renderingTree = [[[RenderingTree alloc] init] autorelease];
    NSArray *tree = [doc.rootElement elementsForName:@"Tree"];
    
    for (GDataXMLElement *node in tree) {
    
        NSString *type;
        
        // Get the first element (Type)
        NSArray *types = [node elementsForName:@"Type"];
        if (types.count > 0) {
            GDataXMLElement *firstType = (GDataXMLElement *) [types objectAtIndex:0];
            type = firstType.stringValue;
        } else continue;

        // Create the current node with attributes
        Node *node = [[[Node alloc] init]autorelease];
        node.type = type;
        
        // Add the node to the tree
        [renderingTree addNodeToTree:node];
        
    }
    
    // Print the XML tree
    NSLog(@"%@", doc.rootElement);
    
    [doc release];
    return renderingTree;
}

// source : 
// http://www.raywenderlich.com/725/how-to-read-and-write-xml-documents-with-gdataxml
//
+ (NSData *)getRenderingTreeXmlData:(RenderingTree *)renderingTree
{
    GDataXMLElement *treeElement = [GDataXMLNode elementWithName:@"Objets"];
    
    //Not a good XML design. Only implemented this way for compability with game engine
    GDataXMLElement *boosterRoot = [GDataXMLNode elementWithName:@"Booster"];
    GDataXMLElement *portalRoot = [GDataXMLNode elementWithName:@"Portal"];
    GDataXMLElement *pommeauRoot = [GDataXMLNode elementWithName:@"Pommeau"];
    GDataXMLElement *murretRoot = [GDataXMLNode elementWithName:@"Murret"];
    GDataXMLElement *puckRoot = [GDataXMLNode elementWithName:@"Puck"];
    GDataXMLElement *pointControleRoot = [GDataXMLNode elementWithName:@"PointControle"];
    GDataXMLElement *butRoot = [GDataXMLNode elementWithName:@"But"];
    
    for(Node *node in renderingTree.tree) {
        //Object node
        GDataXMLElement *nodeElement = [GDataXMLNode elementWithName:node.xmlType];
        //Common Properties (all objects have a position)
        GDataXMLElement *posXProperty = [GDataXMLNode attributeWithName:@"PositionX" stringValue:[NSString stringWithFormat:@"%f",node.position.x]];
        GDataXMLElement *posYProperty = [GDataXMLNode attributeWithName:@"PositionY" stringValue:[NSString stringWithFormat:@"%f",node.position.y]];
        GDataXMLElement *posZProperty = [GDataXMLNode attributeWithName:@"PositionZ" stringValue:[NSString stringWithFormat:@"%f",node.position.z]];
        
        // Add attribute to the current nodeElement
        [nodeElement addAttribute:posXProperty];
        [nodeElement addAttribute:posYProperty];
        [nodeElement addAttribute:posZProperty];
        
        if([node.xmlType isEqualToString:@"Booster"])
        {
            [boosterRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"Portal"])
        {
            [portalRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"Pommeau"])
        {
            [pommeauRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"Murret"])
        {
            [murretRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"Puck"])
        {
            [puckRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"PointControle"])
        {
            [pointControleRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"But"])
        {
            [butRoot addChild:nodeElement];
        }
    }
    
    [treeElement addChild:boosterRoot];
    [treeElement addChild:portalRoot];
    [treeElement addChild:pommeauRoot];
    [treeElement addChild:murretRoot];
    [treeElement addChild:puckRoot];
    [treeElement addChild:pointControleRoot];
    [treeElement addChild:butRoot];
    
    // Save the constructed tree to an xml file
    GDataXMLDocument *document = [[[GDataXMLDocument alloc]initWithRootElement:treeElement] autorelease];
    
    return document.XMLData;
}

@end
