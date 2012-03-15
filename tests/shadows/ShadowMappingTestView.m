/*
 * iSGL3D: http://isgl3d.com
 *
 * Copyright (c) 2010-2012 Stuart Caunt
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ShadowMappingTestView.h"

@implementation ShadowMappingTestView

+ (id<Isgl3dCamera>)createDefaultSceneCameraForViewport:(CGRect)viewport {
    Isgl3dClassDebugLog(Isgl3dLogLevelInfo, @"creating default camera with perspective projection. Viewport size = %@", NSStringFromCGSize(viewport.size));
    
    CGSize viewSize = viewport.size;
    float fovyRadians = Isgl3dMathDegreesToRadians(45.0f);
    Isgl3dPerspectiveProjection *perspectiveLens = [[Isgl3dPerspectiveProjection alloc] initFromViewSize:viewSize fovyRadians:fovyRadians nearZ:1.0f farZ:10000.0f];
    
    Isgl3dVector3 cameraPosition = Isgl3dVector3Make(0.0f, 0.0f, 10.0f);
    Isgl3dVector3 cameraLookAt = Isgl3dVector3Make(0.0f, 0.0f, 0.0f);
    Isgl3dVector3 cameraLookUp = Isgl3dVector3Make(0.0f, 1.0f, 0.0f);
    Isgl3dLookAtCamera *standardCamera = [[Isgl3dLookAtCamera alloc] initWithLens:perspectiveLens
                                                                             eyeX:cameraPosition.x eyeY:cameraPosition.y eyeZ:cameraPosition.z
                                                                          centerX:cameraLookAt.x centerY:cameraLookAt.y centerZ:cameraLookAt.z
                                                                              upX:cameraLookUp.x upY:cameraLookUp.y upZ:cameraLookUp.z];
    [perspectiveLens release];
    return [standardCamera autorelease];
}

- (id)init {
	
	if (self = [super init]) {
		
		_sphereAngle = 0;
		_littleSphereAngle = 25;
		_lightAngle = 0;
        
        Isgl3dLookAtCamera *camera = (Isgl3dLookAtCamera *)self.defaultCamera;
		camera.eyePosition = Isgl3dVector3Make(5, 5, 6);

		// Enable shadow rendering
		[Isgl3dDirector sharedInstance].shadowRenderingMethod = Isgl3dShadowMaps;
//		[Isgl3dDirector sharedInstance].shadowRenderingMethod = Isgl3dShadowPlanar;
		[Isgl3dDirector sharedInstance].shadowAlpha = 0.5;

		// Construct scene
		Isgl3dColorMaterial * colorMaterial = [Isgl3dColorMaterial materialWithHexColors:@"FFFFFF" diffuse:@"FFFFFF" specular:@"FFFFFF" shininess:0.7];
		Isgl3dTextureMaterial *  isglLogo = [Isgl3dTextureMaterial materialWithTextureFile:@"isgl3d_logo.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
		Isgl3dTextureMaterial *  textureMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"mars.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
		Isgl3dTextureMaterial *  hostel = [Isgl3dTextureMaterial materialWithTextureFile:@"hostel.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
	
		Isgl3dGLMesh * sphereMesh = [Isgl3dSphere meshWithGeometry:1.0 longs:16 lats:16];
		_sphere = [self.scene createNodeWithMesh:sphereMesh andMaterial:textureMaterial];
		_sphere.position = Isgl3dVector3Make(-1, 0, 3);
		_sphere.enableShadowCasting = YES;
	
		Isgl3dGLMesh * littleSphereMesh = [Isgl3dSphere meshWithGeometry:0.3 longs:16 lats:16];
		_littleSphere = [self.scene createNodeWithMesh:littleSphereMesh andMaterial:textureMaterial];
		_littleSphere.enableShadowCasting = YES;
	
		Isgl3dGLMesh * cubeMesh = [Isgl3dCube meshWithGeometry:2 height:2 depth:2 nx:4 ny:4];
		Isgl3dMeshNode * cube = [self.scene createNodeWithMesh:cubeMesh andMaterial:isglLogo];
		cube.position = Isgl3dVector3Make(2, -1, -3);
		cube.enableShadowCasting = YES;
	
		Isgl3dGLMesh * buildingMesh = [Isgl3dPlane meshWithGeometry:2.0 height:2.0 nx:4 ny:4];
		Isgl3dMeshNode * building = [self.scene createNodeWithMesh:buildingMesh andMaterial:hostel];
		building.position = Isgl3dVector3Make(0, -1, 0);
		building.enableShadowCasting = YES;
		building.transparent = YES;
		building.doubleSided = YES;
	
		Isgl3dPlane * planeMesh = [Isgl3dPlane meshWithGeometry:12.0 height:12.0 nx:10 ny:10];
		Isgl3dMeshNode * plane = [self.scene createNodeWithMesh:planeMesh andMaterial:isglLogo];
		plane.rotationX = -90;
		plane.position = Isgl3dVector3Make(0, -2, 0);
	
		Isgl3dMeshNode * plane2 = [self.scene createNodeWithMesh:planeMesh andMaterial:colorMaterial];
		plane2.position = Isgl3dVector3Make(0, 1, -6);
		//plane2.enableShadowRendering = NO;
	
		Isgl3dMeshNode * plane3 = [self.scene createNodeWithMesh:planeMesh andMaterial:colorMaterial];
		plane3.rotationY = 90;
		plane3.position = Isgl3dVector3Make(-6, 1, 0);
		//plane3.enableShadowRendering = NO;
		
		_light = [Isgl3dShadowCastingLight lightWithHexColor:@"111111" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" fovyRadians:Isgl3dMathDegreesToRadians(65.0f) attenuation:0.05];
		[self.scene addChild:_light];
		_light.renderLight = YES;
		_light.planarShadowsNode = plane;
	
		[self setSceneAmbient:@"444444"];


		// Schedule updates
		[self schedule:@selector(tick:)];
	}
	return self;
}

- (void)dealloc {
		
	[super dealloc];
}


- (void)tick:(float)dt {
	[_sphere setRotation:_sphereAngle x:0 y:1 z:0];
	_sphereAngle = _sphereAngle - 1;
	
	float x = 3 * sin(_lightAngle * M_PI / 180.);
	float z = 3 * cos(_lightAngle * M_PI / 180.);
	_light.position = Isgl3dVector3Make(x, 3, z);

	_lightAngle += 1;

	x = 0.9 * sin(_littleSphereAngle * M_PI / 180.);
	z = 0.9 * cos(_littleSphereAngle * M_PI / 180.);
	_littleSphere.position = Isgl3dVector3Make(x, 1.2, z);
	
	_littleSphereAngle += 2;
}

@end



#pragma mark AppDelegate

/*
 * Implement principal class: simply override the createViews method to return the desired demo view.
 */
@implementation AppDelegate

- (void)createViews {
	// Create view and add to Isgl3dDirector
	Isgl3dView *view = [ShadowMappingTestView view];
    view.displayFPS = YES;
    
	[[Isgl3dDirector sharedInstance] addView:view];
}

@end
