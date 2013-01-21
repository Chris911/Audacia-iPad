//
//  XMLUtil.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//
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
+ (void)savePartyWithFileName:(RenderingTree *)renderingTree:(NSString*) name {
    
    GDataXMLElement *treeElement = [GDataXMLNode elementWithName:@"Tree"];
    
    for(Node *node in renderingTree.tree) {
        
        // Get the values from the node (ex : type, scale, angle, etc.)
        GDataXMLElement *nodeElement = [GDataXMLNode elementWithName:@"Node"];
        GDataXMLElement *typeElement = [GDataXMLNode elementWithName:@"Type" stringValue:node.type];
        
        // Add values to the current nodeElement
        [nodeElement addChild:typeElement];
        
        // Add the nodeElement to the tree
        [treeElement addChild:nodeElement];
    }
    
    // Save the constructed tree to an xml file
    GDataXMLDocument *document = [[[GDataXMLDocument alloc]initWithRootElement:treeElement] autorelease];
    NSData *xmlData = document.XMLData;
    
    // Need to specify the path
    NSString *filePath = [self dataFilePath:name:TRUE];
    NSLog(@"Saving xml data to %@...", filePath);
    [xmlData writeToFile:filePath atomically:YES];

}


@end
