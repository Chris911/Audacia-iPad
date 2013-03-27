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

const float xmlScale = 1.4f;

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
    RenderingTree *renderingTree = [[[RenderingTree alloc] init]autorelease];
    
    NodeTable* table = [[[NodeTable alloc]init]autorelease];
    [renderingTree addNodeToTree:table];
    
    NSMutableArray* newEdges = [[NSMutableArray alloc]init];
    NSArray *pointControleRoot = [doc.rootElement elementsForName:@"PointControle"];
    for(GDataXMLElement *node in pointControleRoot)
    {
        NSArray* pointsConrole = [node elementsForName:@"pointControle"];
        int i=0;
        for(GDataXMLElement *nodeControle in pointsConrole)
        {
            float posX = [[[nodeControle attributeForName:@"PositionX"] stringValue] floatValue]/xmlScale;
            float posY = [[[nodeControle attributeForName:@"PositionY"] stringValue] floatValue]/xmlScale;
            NodeTableEdge* nodeT = [[NodeTableEdge alloc]initWithCoordsAndIndex:posX :posY :i++];
            [newEdges addObject:nodeT];
            [renderingTree addNodeToTree:nodeT];
        }
    }
    [table initTableEdgesFromXML:newEdges];
    
    NSArray *boosterRoot = [doc.rootElement elementsForName:@"Booster"];
    for(GDataXMLElement *node in boosterRoot)
    {
        NSArray* boosters = [node elementsForName:@"booster"];
        for(GDataXMLElement *realNode in boosters)
        {
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue]/xmlScale;
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue]/xmlScale;
            float posZ = 2.0;
            float scaleFactor = [[[realNode attributeForName:@"ScaleFactor"] stringValue] floatValue] - 3;
            float angleFactor = [[[realNode attributeForName:@"AngleFactor"] stringValue] floatValue];
            float accelFactor = [[[realNode attributeForName:@"Acceleration"] stringValue] floatValue];
            NodeBooster* booster = [[[NodeBooster alloc]init]autorelease];
            booster.scaleFactor = scaleFactor;
            booster.angle = angleFactor;
            booster.Acceleration = accelFactor;
            [renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *portalRoot = [doc.rootElement elementsForName:@"Portal"];
    for(GDataXMLElement *node in portalRoot)
    {
        NSArray* portals = [node elementsForName:@"portal"];
        for(GDataXMLElement *realNode in portals)
        {
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue]/xmlScale;
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue]/xmlScale;
            float posZ = 1.0;
            float scaleFactor = [[[realNode attributeForName:@"ScaleFactor"] stringValue] floatValue] - 3;
            float angleFactor = [[[realNode attributeForName:@"AngleFactor"] stringValue] floatValue];
            float gravite = [[[realNode attributeForName:@"Gravite"] stringValue] floatValue];
            NodePortal* portal = [[[NodePortal alloc]init]autorelease];
            portal.scaleFactor = scaleFactor;
            portal.angle = angleFactor;
            portal.Gravite = gravite;
            [renderingTree addNodeToTreeWithInitialPosition:portal :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *pommeauRoot = [doc.rootElement elementsForName:@"Pommeau"];
    for(GDataXMLElement *node in pommeauRoot)
    {
        NSArray* pommeaux = [node elementsForName:@"pommeau"];
        for(GDataXMLElement *realNode in pommeaux)
        {
            //We don't really care about the other values on load
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue]/xmlScale;
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue]/xmlScale;
            float posZ = 1.0;
            NodePommeau* pommeau = [[[NodePommeau alloc]init]autorelease];
            [renderingTree addNodeToTreeWithInitialPosition:pommeau :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *murretRoot = [doc.rootElement elementsForName:@"Murret"];
    for(GDataXMLElement *node in murretRoot)
    {
        NSArray* murrets = [node elementsForName:@"murret"];
        for(GDataXMLElement *realNode in murrets)
        {
            //We don't really care about the other values on load
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue]/xmlScale;
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue]/xmlScale;
            float posZ = 1.0;
            float scaleFactor = [[[realNode attributeForName:@"ScaleFactor"] stringValue] floatValue] - 3;
            float angleFactor = [[[realNode attributeForName:@"AngleFactor"] stringValue] floatValue];
            float coeffRebond = [[[realNode attributeForName:@"CoeffRebond"] stringValue] floatValue];
            NodeMurret* murret = [[[NodeMurret alloc]init]autorelease];
            murret.scaleFactor = scaleFactor;
            murret.angle = angleFactor;
            murret.CoeffRebond = coeffRebond;
            [renderingTree addNodeToTreeWithInitialPosition:murret :Vector3DMake(posX, posY, posZ)];
        }
    }
    
    NSArray *puckRoot = [doc.rootElement elementsForName:@"Puck"];
    for(GDataXMLElement *node in puckRoot)
    {
        NSArray* pucks = [node elementsForName:@"puck"];
        for(GDataXMLElement *realNode in pucks)
        {
            float posX = [[[realNode attributeForName:@"PositionX"] stringValue] floatValue]/xmlScale;
            float posY = [[[realNode attributeForName:@"PositionY"] stringValue] floatValue]/xmlScale;
            float posZ = 2.0;
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
    
    BOOL firstPommeau = YES;
    for(Node *node in renderingTree.tree) {
        //Object node
        GDataXMLElement *nodeElement = [GDataXMLNode elementWithName:node.xmlType];
        //Common Properties (all objects have a position)
        GDataXMLElement *posXProperty = [GDataXMLNode attributeWithName:@"PositionX" stringValue:[NSString stringWithFormat:@"%f",node.position.x*xmlScale]];
        GDataXMLElement *posYProperty = [GDataXMLNode attributeWithName:@"PositionY" stringValue:[NSString stringWithFormat:@"%f",node.position.y*xmlScale]];
        GDataXMLElement *posZProperty;
        if([node.xmlType isEqualToString:@"pommeau"]){
            posZProperty = [GDataXMLNode attributeWithName:@"PositionZ" stringValue:[NSString stringWithFormat:@"%f",-15.0f]];
        } else {
            posZProperty = [GDataXMLNode attributeWithName:@"PositionZ" stringValue:[NSString stringWithFormat:@"%f",0.0]];
        }
        
        if(!([node.xmlType isEqualToString:@"but"] || [node.xmlType isEqualToString:@"pointControle"]))
        {
            GDataXMLElement *angleProperty = [GDataXMLNode attributeWithName:@"AngleFactor" stringValue:[NSString stringWithFormat:@"%f",node.angle]];
            GDataXMLElement *scaleProperty = [GDataXMLNode attributeWithName:@"ScaleFactor" stringValue:[NSString stringWithFormat:@"%.0f",node.scaleFactor+3]];
            
            [nodeElement addAttribute:angleProperty];
            [nodeElement addAttribute:scaleProperty];
        }
        
        // Add attribute to the current nodeElement
        [nodeElement addAttribute:posXProperty];
        [nodeElement addAttribute:posYProperty];
        [nodeElement addAttribute:posZProperty];
        
        if([node.xmlType isEqualToString:@"booster"])
        {
            GDataXMLElement *accelProperty = [GDataXMLNode attributeWithName:@"Acceleration" stringValue:[NSString stringWithFormat:@"%f",((NodeBooster *)node).Acceleration]];
            [nodeElement addAttribute:accelProperty];
            [boosterRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"portal"])
        {
            GDataXMLElement *gravityProperty = [GDataXMLNode attributeWithName:@"Gravite" stringValue:[NSString stringWithFormat:@"%f",((NodePortal *)node).Gravite]];
            [nodeElement addAttribute:gravityProperty];
            
            [portalRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"pommeau"])
        {
            if(firstPommeau)
            {
                firstPommeau = NO;
                
                // Fixme: The XML should be fixed in the game engine
                GDataXMLElement *controlProperty = [GDataXMLNode attributeWithName:@"Control" stringValue:@"souris"];
                [nodeElement addAttribute:controlProperty];
                
                GDataXMLElement *campProperty = [GDataXMLNode attributeWithName:@"Camp" stringValue:@"droite"];
                [nodeElement addAttribute:campProperty];
                
                GDataXMLElement *toucheHautProperty = [GDataXMLNode attributeWithName:@"ToucheHaut" stringValue:@""];
                [nodeElement addAttribute:toucheHautProperty];
                
                GDataXMLElement *toucheBasProperty = [GDataXMLNode attributeWithName:@"ToucheBas" stringValue:@""];
                [nodeElement addAttribute:toucheBasProperty];
                
                GDataXMLElement *toucheDroiteProperty = [GDataXMLNode attributeWithName:@"ToucheDroite" stringValue:@""];
                [nodeElement addAttribute:toucheDroiteProperty];
                
                GDataXMLElement *toucheGaucheProperty = [GDataXMLNode attributeWithName:@"ToucheGauche" stringValue:@""];
                [nodeElement addAttribute:toucheGaucheProperty];
            }
            else
            {
                // Fixme: The XML should be fixed in the game engine
                GDataXMLElement *controlProperty = [GDataXMLNode attributeWithName:@"Control" stringValue:@"clavier"];
                [nodeElement addAttribute:controlProperty];
                
                GDataXMLElement *campProperty = [GDataXMLNode attributeWithName:@"Camp" stringValue:@"gauche"];
                [nodeElement addAttribute:campProperty];
                
                GDataXMLElement *toucheHautProperty = [GDataXMLNode attributeWithName:@"ToucheHaut" stringValue:@"haut"];
                [nodeElement addAttribute:toucheHautProperty];
                
                GDataXMLElement *toucheBasProperty = [GDataXMLNode attributeWithName:@"ToucheBas" stringValue:@"bas"];
                [nodeElement addAttribute:toucheBasProperty];
                
                GDataXMLElement *toucheDroiteProperty = [GDataXMLNode attributeWithName:@"ToucheDroite" stringValue:@"droite"];
                [nodeElement addAttribute:toucheDroiteProperty];
                
                GDataXMLElement *toucheGaucheProperty = [GDataXMLNode attributeWithName:@"ToucheGauche" stringValue:@"gauche"];
                [nodeElement addAttribute:toucheGaucheProperty];
            }
            [pommeauRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"murret"])
        {
            GDataXMLElement *coeffRebond = [GDataXMLNode attributeWithName:@"CoeffRebond" stringValue:[NSString stringWithFormat:@"%f",((NodeMurret *)node).CoeffRebond]];
            [nodeElement addAttribute:coeffRebond];
            [murretRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"puck"])
        {
            // Fixme: Again this should be fixed in the game engine
            GDataXMLElement *frictionProperty = [GDataXMLNode attributeWithName:@"CoeffFriction" stringValue:[NSString stringWithFormat:@"%f",0.1f]];
            [nodeElement addAttribute:frictionProperty];
            
            GDataXMLElement *rebondProperty = [GDataXMLNode attributeWithName:@"CoeffRebond" stringValue:[NSString stringWithFormat:@"%f",0.87f]];
            [nodeElement addAttribute:rebondProperty];
            
            GDataXMLElement *zoneHProperty = [GDataXMLNode attributeWithName:@"HauteurZone" stringValue:@"140"];
            [nodeElement addAttribute:zoneHProperty];
            
            GDataXMLElement *zoneLProperty = [GDataXMLNode attributeWithName:@"LargeurZone" stringValue:@"210"];
            [nodeElement addAttribute:zoneLProperty];
            
            [puckRoot addChild:nodeElement];
        }
        else if([node.xmlType isEqualToString:@"pointControle"])
        {
            [pointControleRoot addChild:nodeElement];
            if((((NodeTableEdge *)node).index == 3) || (((NodeTableEdge *)node).index == 4))
            {
                GDataXMLElement *nodeElement = [GDataXMLNode elementWithName:@"but"];
                GDataXMLElement *facteurButProperty = [GDataXMLNode attributeWithName:@"FacteurBut" stringValue:@"1"];
                GDataXMLElement *posXProperty = [GDataXMLNode attributeWithName:@"PositionX" stringValue:[NSString stringWithFormat:@"%f",node.position.x*xmlScale]];
                GDataXMLElement *posYProperty = [GDataXMLNode attributeWithName:@"PositionY" stringValue:[NSString stringWithFormat:@"%f",node.position.y*xmlScale]];
                GDataXMLElement *posZProperty = [GDataXMLNode attributeWithName:@"PositionZ" stringValue:[NSString stringWithFormat:@"%f",0.0]];
                [nodeElement addAttribute:posXProperty];
                [nodeElement addAttribute:posYProperty];
                [nodeElement addAttribute:posZProperty];
                [nodeElement addAttribute:facteurButProperty];
                
                [butRoot addChild:nodeElement];
            }
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
