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
#import "NodePortal.h"
#import "NodeTableEdge.h"
#import "NodePommeau.h"
#import "NodePuck.h"
#import "NodeTable.h"
#import "NodeBooster.h"
#import "NodeMurret.h"

@implementation XMLUtil

// Returns the complete path of the desired XML File
+ (NSString *)dataFilePath:(NSString*)fileName :(BOOL)forSave {

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

+ (RenderingTree *)loadRenderingTreeFromGDataXMLDocument:(GDataXMLDocument*)doc
{
    if (doc == nil) { return nil; }
    
    // Parse the tree (This part is awful)
    RenderingTree *renderingTree = [[[RenderingTree alloc] init] autorelease];
    
    NodeTable* table = [[NodeTable alloc]init];
    [renderingTree addNodeToTree:table];
    
    NSArray *pointControleRoot = [doc.rootElement elementsForName:@"PointControle"];
    for(GDataXMLElement *node in pointControleRoot)
    {
        NSArray* pointsConrole = [node elementsForName:@"PointControle"];
        int i=0;
        for(GDataXMLElement *nodeControle in pointsConrole)
        {
            float posX = [[[nodeControle attributeForName:@"PositionX"] stringValue] floatValue];
            float posY = [[[nodeControle attributeForName:@"PositionY"] stringValue] floatValue];
            NodeTableEdge* nodeT = [[NodeTableEdge alloc]initWithCoordsAndIndex:posX :posY :i];
            [renderingTree addNodeToTree:nodeT];
        }
    }
    
    NSArray *boosterRoot = [doc.rootElement elementsForName:@"Booster"];
    for(GDataXMLElement *node in boosterRoot)
    {
        NSArray* boosters = [node elementsForName:@"Booster"];
        for(GDataXMLElement *realNode in boosters)
        {
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue];
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue];
            float posZ = [[[realNode attributeForName:@"PositionZ"] stringValue] floatValue];
            NodeBooster* booster = [[[NodeBooster alloc]init]autorelease];
            [renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *portalRoot = [doc.rootElement elementsForName:@"Portal"];
    for(GDataXMLElement *node in portalRoot)
    {
        NSArray* portals = [node elementsForName:@"Portal"];
        for(GDataXMLElement *realNode in portals)
        {
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue];
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue];
            float posZ = [[[realNode attributeForName:@"PositionZ"] stringValue] floatValue];
            float gravite = [[[realNode attributeForName:@"Gravite"] stringValue] floatValue];
            NodePortal* portal = [[[NodePortal alloc]init]autorelease];
            portal.Gravite = gravite;
            [renderingTree addNodeToTreeWithInitialPosition:portal :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *pommeauRoot = [doc.rootElement elementsForName:@"Pommeau"];
    for(GDataXMLElement *node in pommeauRoot)
    {
        NSArray* pommeaux = [node elementsForName:@"Pommeau"];
        for(GDataXMLElement *realNode in pommeaux)
        {
            //We don't really care about the other values on load
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue];
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue];
            float posZ = [[[realNode attributeForName:@"PositionZ"] stringValue] floatValue];
            NodePommeau* pommeau = [[[NodePommeau alloc]init]autorelease];
            [renderingTree addNodeToTreeWithInitialPosition:pommeau :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *murretRoot = [doc.rootElement elementsForName:@"Murret"];
    for(GDataXMLElement *node in murretRoot)
    {
        NSArray* murrets = [node elementsForName:@"Murret"];
        for(GDataXMLElement *realNode in murrets)
        {
            //We don't really care about the other values on load
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue];
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue];
            float posZ = [[[realNode attributeForName:@"PositionZ"] stringValue] floatValue];
            NodeMurret* murret = [[[NodeMurret alloc]init]autorelease];
            [renderingTree addNodeToTreeWithInitialPosition:murret :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *puckRoot = [doc.rootElement elementsForName:@"Puck"];
    for(GDataXMLElement *node in puckRoot)
    {
        NSArray* pucks = [node elementsForName:@"Puck"];
        for(GDataXMLElement *realNode in pucks)
        {
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue];
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue];
            float posZ = [[[realNode attributeForName:@"PositionZ"] stringValue] floatValue];
            float coeffFriction = [[[realNode attributeForName:@"CoeffFriction"] stringValue] floatValue];
            float coeffRebond = [[[realNode attributeForName:@"CoeffRebond"] stringValue] floatValue];
            NodePuck* puck = [[[NodePuck alloc]init]autorelease];
            puck.coeffRebond = coeffRebond;
            puck.coeffFriction = coeffFriction;
            [renderingTree addNodeToTreeWithInitialPosition:puck :Vector3DMake(posX, posY, posZ)];
        }
    }
    
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
        
        if([node.xmlType isEqualToString:@"But"] &&
           [node.xmlType isEqualToString:@"PointControle"])
        {
            GDataXMLElement *angleProperty = [GDataXMLNode attributeWithName:@"AngleFactor" stringValue:[NSString stringWithFormat:@"%f",node.angle]];
            GDataXMLElement *scaleProperty = [GDataXMLNode attributeWithName:@"ScaleFactor" stringValue:[NSString stringWithFormat:@"%f",node.scaleFactor]];
            
            [nodeElement addAttribute:angleProperty];
            [nodeElement addAttribute:scaleProperty];
        }
        
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
            GDataXMLElement *gravityProperty = [GDataXMLNode attributeWithName:@"Gravite" stringValue:[NSString stringWithFormat:@"%f",((NodePortal *)node).Gravite]];
            [nodeElement addAttribute:gravityProperty];
            
            [portalRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"Pommeau"])
        {
            // Fixme: The XML should be fixed in the game engine
            GDataXMLElement *controlProperty = [GDataXMLNode attributeWithName:@"Control" stringValue:@"clavier"];
            [nodeElement addAttribute:controlProperty];
            
            GDataXMLElement *campProperty = [GDataXMLNode attributeWithName:@"Camp" stringValue:@"droite"];
            [nodeElement addAttribute:campProperty];
            
            GDataXMLElement *toucheHautProperty = [GDataXMLNode attributeWithName:@"ToucheHaut" stringValue:@"haut"];
            [nodeElement addAttribute:toucheHautProperty];
            
            GDataXMLElement *toucheBasProperty = [GDataXMLNode attributeWithName:@"ToucheBas" stringValue:@"bas"];
            [nodeElement addAttribute:toucheBasProperty];
            
            GDataXMLElement *toucheDroiteProperty = [GDataXMLNode attributeWithName:@"ToucheDroite" stringValue:@"droite"];
            [nodeElement addAttribute:toucheDroiteProperty];
            
            GDataXMLElement *toucheGaucheProperty = [GDataXMLNode attributeWithName:@"ToucheGauche" stringValue:@"gauche"];
            [nodeElement addAttribute:toucheGaucheProperty];
            
            [pommeauRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"Murret"])
        {
            [murretRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"Puck"])
        {
            // Fixme: Again this should be fixed in the game engine
            Node* table = [renderingTree getTable];
            GDataXMLElement *frictionProperty = [GDataXMLNode attributeWithName:@"CoeffFriction" stringValue:[NSString stringWithFormat:@"%f",((NodeTable *)table).CoeffFriction]];
            [nodeElement addAttribute:frictionProperty];
            
            GDataXMLElement *rebondProperty = [GDataXMLNode attributeWithName:@"CoeffRebond" stringValue:[NSString stringWithFormat:@"%f",((NodeTable *)table).CoeffRebond]];
            [nodeElement addAttribute:rebondProperty];
            
            GDataXMLElement *zoneHProperty = [GDataXMLNode attributeWithName:@"HauteurZone" stringValue:@"140"];
            [nodeElement addAttribute:zoneHProperty];
            
            GDataXMLElement *zoneLProperty = [GDataXMLNode attributeWithName:@"LargeurZone" stringValue:@"210"];
            [nodeElement addAttribute:zoneLProperty];
            
            [puckRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"PointControle"])
        {
            [pointControleRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"But"])
        {
            GDataXMLElement *facteurButProperty = [GDataXMLNode attributeWithName:@"FacteurBut" stringValue:@"1"];
            [nodeElement addAttribute:facteurButProperty];
            
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
