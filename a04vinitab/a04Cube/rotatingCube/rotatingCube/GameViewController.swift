//
//  GameViewController.swift
//  a02solution
//
//  Created by Mitja Hmeljak on 2017-02-23.
//  Copyright © 2017 B481 Spring 2017. All rights reserved.
//

import GLKit
import OpenGLES

let UNIFORM_MODELVIEWPROJECTION_MATRIX = 0
let UNIFORM_NORMAL_MATRIX = 1
var uniforms = [GLint](repeating: 0, count: 2)

// OpenGL ES requires the use of C-like pointers to "CPU memory",
// without the automated memory management provided by Swift,:
func obtainUnsafePointer(_ i: Int) -> UnsafeRawPointer? {
    return UnsafeRawPointer(bitPattern: i)
}

var gVertexData: [GLfloat] = [
    // vertex data structured thus:
    //  positionX, positionY, etc.
    
    // SOLUTION: start from NO vertices:
    
    
]
var gAxesData: [GLfloat] = [ 0.0, 0.0, 0.0,
                             1.0, 0.0, 0.0,
                             0.0, 0.0, 0.0,
                             0.0, 1.0, 0.0,
                             0.0, 0.0, 0.0,
                             0.05, 0.05, 1.0]
var gColorData: [[GLfloat]] = [
    // color data in RGBA float format
    [0.0, 1.0, 0.0, 1.0],
    [0.0, 1.0, 1.0, 1.0],
    [1.0, 0.0, 0.0, 1.0]
]

let G_DISTANCE_VV: GLfloat = 20.0
let G_DISTANCE_VL: GLfloat = 10.0

enum G_LIT {
    case NONLIT
    case LITVERTEX
    case LITLINE
}




class GameViewController: GLKViewController {
    
    var myGLESProgram: GLuint = 0
    
    var myModelViewProjectionMatrix:GLKMatrix4 = GLKMatrix4Identity
    var mynormalMatrix: GLKMatrix3 = GLKMatrix3Identity
    
    var myViewPortWidth:GLsizei = -1
    var myViewPortHeight:GLsizei = -1
    
    var myWidthUniform: GLint = 0
    var myHeightUniform: GLint = 0
    var myColorUniform: GLint = 0
    var myFoVUniform:GLint = 0
    var myAspectUniform:GLint = 0
    var myNearUniform:GLint = 0
    var myFarUniform:GLint = 0
    var myDeltaXUniform: GLint = 0
    var myDeltaYUniform: GLint = 0
    
    var myVertexArray: GLuint = 0
    var myVertexBuffer: GLuint = 0
    
    var myGLESContext: EAGLContext? = nil
    var myGLKView: GLKView? = nil
    var myeffect: GLKBaseEffect? = nil
    
    // touch event data:
    var myTouchXbegin: GLfloat = -1.0
    var myTouchYbegin: GLfloat = -1.0
    var myTouchXcurrent: GLfloat = -1.0
    var myTouchYcurrent: GLfloat = -1.0
    var myTouchXold: GLfloat = -1.0
    var myTouchYold: GLfloat = -1.0
    var myTouchPhase: UITouchPhase? = nil
    var myFoV:GLfloat = 40.0
    var myAspect:GLfloat = 1.0
    var myNear:GLfloat = 0.01
    var myFar:GLfloat = 21.01
    var myDelta_x:GLfloat = 0.001
    var myDelta_y:GLfloat = 0.001
    var myfirstTouchX:GLfloat = 0.0
    var myfirstTouchY:GLfloat = 0.0
    // polygon build data:
    var myEnteredVertices = 0
    var myLitType = G_LIT.NONLIT
    var myLitID = -1
    
    // ------------------------------------------------------------------------
    deinit {
        self.tearDownGL()
        
        if EAGLContext.current() === self.myGLESContext {
            EAGLContext.setCurrent(nil)
        }
    }
    
    
    // ------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This view controller's view has loaded.
        //   It's time to initialize OpenGL ES!
        
        // Initialize a newly allocated OpenGL ES *rendering context*
        //   with the specified version of the OpenGL ES rendering API:
        self.myGLESContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        
        if !(self.myGLESContext != nil) {
            NSLog("EAGLContext failed to initialize OpenGL ES 2.x context :-( ")
            return
        }
        
        // now that the OpenGL ES rendering context is available,
        //   set our (GameViewController's) view as a GL view:
        self.myGLKView = self.view as? GLKView
        // The GLKView directly manages a framebuffer object
        //   on our application’s behalf.
        // Our code just needs to draw into the framebuffer
        //   when the contents need to be updated.
        self.myGLKView!.context = self.myGLESContext!
        // set the *depth* (z-buffer)'s size:
        self.myGLKView!.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
        // in 3D we'll often need the depth buffer, e.g.:
        // lView.drawableDepthFormat = GLKViewDrawableDepthFormat.Format24
        
        self.setupGL()
        
    } // end of viewDidLoad()
    
    // ------------------------------------------------------------------------
    // the system is running out of memory: clean up an abandon GLES
    // ------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded && (self.view.window != nil) {
            self.view = nil
            
            self.tearDownGL()
            
            if EAGLContext.current() === self.myGLESContext {
                EAGLContext.setCurrent(nil)
            }
            self.myGLESContext = nil
        }
    } // end of didReceiveMemoryWarning()
    
    
    // ------------------------------------------------------------------------
    // initialize OpenGL ES:
    // ------------------------------------------------------------------------
    func setupGL() {
        EAGLContext.setCurrent(self.myGLESContext)
        
        
        let lGL_VERSION_ptr = glGetString(GLenum(GL_VERSION))
        let lGL_VERSION = String(cString: lGL_VERSION_ptr!)
        print("glGetString(GLenum(GL_VERSION_ptr)) = \(lGL_VERSION_ptr)")
        print("   returned: '\(lGL_VERSION)'")
        let lGL_SHADING_LANGUAGE_VERSION_ptr = glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION))
        let lGL_SHADING_LANGUAGE_VERSION = String(cString: lGL_SHADING_LANGUAGE_VERSION_ptr!)
        print("glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION_ptr)) = \(lGL_SHADING_LANGUAGE_VERSION_ptr)")
        print("   returns '\(lGL_SHADING_LANGUAGE_VERSION)' ")
        if (!self.loadShaders()) {
            self.alertUserNoShaders()
        }
        
        /*self.myeffect!.light0.enabled = GLboolean(GL_TRUE)
         self.myeffect!.light0.diffuseColor = GLKVector4Make(1.0, 0.4, 0.4, 1.0)*/
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
        glGenVertexArrays(1, &myVertexArray)
        glBindVertexArray(myVertexArray)
        
        glGenBuffers(1, &myVertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * gVertexData.count),
                     &gVertexData,
                     GLenum(GL_STATIC_DRAW))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              0, obtainUnsafePointer(0) )
        glBindVertexArray(0)
        self.myViewPortWidth = GLsizei(self.view.bounds.size.width)
        self.myViewPortHeight = GLsizei(self.view.bounds.size.height)
        
        glViewport ( 0, 0, self.myViewPortWidth, self.myViewPortHeight )
        glClearColor ( 0.0, 0.0, 0.0, 1.0 );
        
    } // end of setupGL()
    
    // ------------------------------------------------------------------------
    func tearDownGL() {
        EAGLContext.setCurrent(self.myGLESContext)
        
        glDeleteBuffers(1, &myVertexBuffer)
        glDeleteVertexArrays(1, &myVertexArray)
        
        if myGLESProgram != 0 {
            glDeleteProgram(myGLESProgram)
            myGLESProgram = 0
        }
    }
    
    
    
    // ------------------------------------------------------------------------
    // user interface to alert our user about an inescapable shader problem:
    func alertUserNoShaders() {
        
        // provide an UIAlertController:
        // http://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAlertController_class/
        
        let lAlert = UIAlertController(
            title: "Alert",
            message: "I haven't been successful in creating OpenGL shaders",
            preferredStyle: UIAlertControllerStyle.alert)
        
        // the alert controller only has a "Cancel" button:
        
        let lCancelAction = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.default,
            handler: {
                (action: UIAlertAction) -> Void in
                // do nothing if "Cancel" is pressed
        }
        )
        
        // add the two actions as buttons to the alert controller:
        lAlert.addAction(lCancelAction)
        // present the alert to the user:
        present(lAlert, animated: true, completion: nil)
    }  // end of func addUser()
    
    
    
    // ------------------------------------------------------------------------
    // MARK: - GLKView and GLKViewController delegate methods
    // ------------------------------------------------------------------------
    
    // ------------------------------------------------------------------------
    func update() {
        
    } // end of update()
    
    // ------------------------------------------------------------------------
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glUseProgram(myGLESProgram)
        
        glClear( GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT)   )
        
        
        // get viewport dimensions:
        self.myViewPortWidth = GLsizei(self.view.bounds.size.width)
        self.myViewPortHeight = GLsizei(self.view.bounds.size.height)
        
        // pass viewport dimensions to the vertex shader:
        glUniform1f(self.myWidthUniform, GLfloat(self.myViewPortWidth))
        glUniform1f(self.myHeightUniform, GLfloat(self.myViewPortHeight))
        
        // SOLUTION: don't change the gVertexData array in the drawing function!
        
       /* glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        // define where the vertex buffer is going to find its data:
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * gVertexData.count),
                     &gVertexData,
                     GLenum(GL_STATIC_DRAW))
        
        // enable which kind of attributes the buffer data is going to use:
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              0, obtainUnsafePointer(0) )*/
        
        // bind the vertex array to draw:
        glBindVertexArray(myVertexArray)
        //glBindVertexArrayOES(myVertexArray)
        
        
        glUniform1f(self.myFoVUniform, myFoV)
        glUniform1f(self.myAspectUniform,GLfloat(myAspect))
        glUniform1f(self.myNearUniform,GLfloat(myNear))
        glUniform1f(self.myFarUniform,GLfloat(myFar))
        glUniform1f(self.myDeltaXUniform, GLfloat(myDelta_x))
        glUniform1f(self.myDeltaYUniform, GLfloat(myDelta_y))
        
        glLineWidth(2.0)
        
        
        // SOLUTION: only draw if you have at least 2 vertices
        /*let lNumberOfVertices = gVertexData.count/2
        if (lNumberOfVertices >= 2) {
            // what color to use for the line strip:
            glUniform4f(self.myColorUniform,
                        gColorData[0][0],
                        gColorData[0][1],
                        gColorData[0][2],
                        gColorData[0][3])
            // draw the line strip:
            // these are the parameters:
            //   glDrawArrays(_ mode: GLenum, _ first: GLint, _ count: GLsizei)
            //glDrawArrays( GLenum(GL_LINE_STRIP), 0, GLsizei(lNumberOfVertices) )
        }*/
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
        //DRAWING AXES
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              0, obtainUnsafePointer(0) )
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * gAxesData.count),
                     &gAxesData,
                     GLenum(GL_STATIC_DRAW))
        glUniform4f(self.myColorUniform,
                    gColorData[0][0],
                    gColorData[0][1],
                    gColorData[0][2],
                    gColorData[0][3])
        
        glDrawArrays( GLenum(GL_LINE_STRIP), 0, 2 )
        glUniform4f(self.myColorUniform,
                    gColorData[2][0],
                    gColorData[2][1],
                    gColorData[2][2],
                    gColorData[2][3])
        glDrawArrays( GLenum(GL_LINE_STRIP), 2, 2 )
        glUniform4f(self.myColorUniform,
                    gColorData[1][0],
                    gColorData[1][1],
                    gColorData[1][2],
                    gColorData[1][3])
        glDrawArrays( GLenum(GL_LINE_STRIP), 4, 2 )
        
        
        
        //DRAWING CUBE
        
        withUnsafePointer(to: &myModelViewProjectionMatrix, {
            $0.withMemoryRebound(to: Float.self, capacity: 16, {
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, $0)
            })
        })
        
        withUnsafePointer(to: &mynormalMatrix, {
            $0.withMemoryRebound(to: Float.self, capacity: 9, {
                glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, $0)
            })
        })
        
        
       glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.size * gCubeVertexData.count), &gCubeVertexData, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, obtainUnsafePointer(0))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, obtainUnsafePointer(12))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, obtainUnsafePointer(24))

        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
        
        
        
        
        // now "break" the vertex array binding:
        glBindVertexArray(0)
        
    } // end of glkView( ... drawInRect: )
    
    
    
    
    
    // ------------------------------------------------------------------------
    // MARK: - Assignment 02 Task B SOLUTION: distance functions
    // ------------------------------------------------------------------------
    
    /* Proximity functions:
     *  vvDist =  vert vert distance
     *  vlinedist = "h" = vert-to-line distance
     *  vlineproj = "l" = projection-on-line distance
     *  vertonseg =  "l-test" = 1 if on seg, 0 if not */
    
    // ------------------------------------------------------------------------
    func vvDist(_ lX1: GLfloat, _ lY1: GLfloat,
                _ lX2: GLfloat, _ lY2: GLfloat) -> GLfloat {
        return (
            sqrt(
                pow((lX2 - lX1), 2) +
                    pow((lY2 - lY1), 2)
            )
        )
    }
    
    
    
    // ------------------------------------------------------------------------
    /* the line segment is from (x1,y1) to (x2, y2) */
    /* the point is (x0,y0)*/
    func vlinedist(_ x0: GLfloat, _ y0: GLfloat, _ x1: GLfloat, _ y1: GLfloat, _ x2: GLfloat, _ y2: GLfloat) -> GLfloat {
        
        var vldis, length: GLfloat
        var normX, normY: GLfloat
        
        length = vvDist(x1,y1,x2,y2)
        
        // test for degenerate edges:
        if (length == 0.0) { return -999.0 }
        
        /* find norm direction perpendicular to the line X2-X1 */
        normX = -(y2-y1) / length
        normY = (x2-x1) / length
        
        /* the projection of X0-X1 on the perpendicular norm */
        vldis = normX * (x0-x1) + normY * (y0-y1)
        
        return vldis
    } // end of vlinedist()
    
    
    // ------------------------------------------------------------------------
    func vlineproj(_ x0: GLfloat, _ y0: GLfloat, _ x1: GLfloat, _ y1: GLfloat, _ x2: GLfloat, _ y2: GLfloat) -> GLfloat {
        var vlpro, length: GLfloat
        var horX, horY: GLfloat
        
        /* normalized vector from vertex (x1,y1) to vertex (x2,y2) */
        length = vvDist(x1,y1,x2,y2)
        
        // test for degenerate edges:
        if (length==0.0) { return -999.0 }
        
        horX = (x2-x1)/length
        horY = (y2-y1)/length
        vlpro = horX * (x0-x1) + horY * (y0-y1)
        
        return vlpro
    }
    
    // ------------------------------------------------------------------------
    /* Returns true if projected point is on line segment, false otherwise  */
    func vertonseg(_ x0: GLfloat, _ y0: GLfloat, _ x1: GLfloat, _ y1: GLfloat, _ x2: GLfloat, _ y2: GLfloat) -> Bool {
        var l, length: GLfloat
        
        length = vvDist(x1,y1,x2,y2)
        
        // test for degenerate edges:
        if (length == 0.0) { return false }
        
        l = vlineproj(x0,y0,x1,y1,x2,y2)
        
        if (l>=0 && l<=length) {
            return true
        } else {
            return false
        }
    } // end of vertonseg
    
    
    // ------------------------------------------------------------------------
    func proximityTest() -> Bool {
        var onseg: Bool
        var dist: GLfloat
        
        self.myLitType = G_LIT.NONLIT
        self.myLitID = -1
        
        /* Test vertex first */
        // only test closeness to vertex if there is a vertex already!
        if (self.myEnteredVertices >= 1) {
            for i in 0 ..< self.myEnteredVertices {
                
                let lViX = gCubeVertexData[i*2]
                let lViY = gCubeVertexData[i*2 + 1]
                dist = vvDist(self.myTouchXbegin, self.myTouchYbegin, lViX, lViY)
                
                if (dist <= G_DISTANCE_VV) {
                    self.myLitType = G_LIT.LITVERTEX
                    self.myLitID = i
                    return true
                }
                
            }
        }
        /* Test edges next */
        if (self.myEnteredVertices >= 2) {
            
            for i in 0 ..< (self.myEnteredVertices - 1) {
                onseg =  vertonseg(self.myTouchXbegin, self.myTouchYbegin,
                                   gCubeVertexData[i*2], gCubeVertexData[i*2 + 1],
                                   gCubeVertexData[i*2 + 2], gCubeVertexData[i*2 + 3])
                dist =  fabs(vlinedist(
                    self.myTouchXbegin, self.myTouchYbegin,
                    gCubeVertexData[i*2], gCubeVertexData[i*2 + 1],
                    gCubeVertexData[i*2 + 2], gCubeVertexData[i*2 + 3] ))
                if (onseg && (dist <= G_DISTANCE_VL)) {
                    self.myLitType = G_LIT.LITLINE
                    self.myLitID = i
                    return true
                }
            }
            
        }
        return false
    } // end of proximityTest
    
    
    // ------------------------------------------------------------------------
    // MARK: - UIResponder delegate methods for touch events
    // ------------------------------------------------------------------------
    
    // ------------------------------------------------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let firstTouch = touches.first  {
            let firstTouchPoint = firstTouch.location(in: self.view)
            let lMessage = "Touch Began at \(firstTouchPoint.x), \(firstTouchPoint.y)"
            
            // the position where the finger begins touching the screen:
            self.myTouchXbegin = GLfloat(firstTouchPoint.x)
            self.myTouchYbegin = GLfloat(self.myViewPortHeight) - GLfloat(firstTouchPoint.y - 1)
            
            // the position where the finger currently touches the screen:
            self.myTouchXcurrent = self.myTouchXbegin
            self.myTouchYcurrent = self.myTouchYbegin
            
            // the last known position of the finger touching the screen:
            //   at redraw or at new (first) touch event:
            self.myTouchXold = self.myTouchXcurrent
            self.myTouchYold = self.myTouchYcurrent
            
            
            myfirstTouchX = self.myTouchXbegin
            myfirstTouchY = self.myTouchYbegin
            // we are in the "we've just began" phase of the touch event sequence:
            self.myTouchPhase = UITouchPhase.began
            
            // SOLUTION task B:
            // if not close to a vertex, nor close to a line, add a vertex:
            if (!proximityTest()) {
                // SOLUTION task A: add one vertex to the gVertexData Swift array of floats:
                //gVertexData.append(self.myTouchXbegin)
                //gVertexData.append(self.myTouchYbegin)
                self.myEnteredVertices += 1
            }
            
            
            NSLog(lMessage)
        }
    } // end of touchesBegan()
    
    
    // ------------------------------------------------------------------------
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first  {
            let firstTouchPoint = firstTouch.location(in: self.view)
            let lMessage = "Touch Moved to \(firstTouchPoint.x), \(firstTouchPoint.y)"
            
            // store "current" to "old" touch coordinates
            self.myTouchXold = self.myTouchXcurrent
            self.myTouchYold = self.myTouchYcurrent
            
            // get new "current" touch coordinates
            self.myTouchXcurrent = GLfloat(firstTouchPoint.x)
            self.myTouchYcurrent = GLfloat(self.myViewPortHeight) - GLfloat(firstTouchPoint.y - 1)
            
            // we are in the "something has moved" phase of the touch event sequence:
            self.myTouchPhase = UITouchPhase.moved
            let ratio = fabsf(Float(self.view.bounds.size.width/self.view.bounds.size.height)) * 50
            myDelta_x = (self.myTouchXcurrent - myfirstTouchX) / ratio
            myDelta_y = (self.myTouchYcurrent - myfirstTouchY) / ratio
            
            
            // SOLUTION task C : move vertex or line segment:
            /*if (self.myLitType == G_LIT.NONLIT) {
             // SOLUTION task A: modify the current vertex, if entering a new
             //   vertex to the gVertexData Swift array of floats:
             //gVertexData[2 * (self.myEnteredVertices-1)] = self.myTouchXcurrent
             //gVertexData[(2 * (self.myEnteredVertices-1)) + 1] = self.myTouchYcurrent
             } else if (self.myLitType == G_LIT.LITVERTEX) || (self.myLitType == G_LIT.LITLINE)
             {
             
             // SOLUTION task B: if close to a vertex, or close to a line, move highlighted element:
             //gVertexData[2 * self.myLitID] += (self.myTouchXcurrent - self.myTouchXold)
             //gVertexData[2 * self.myLitID + 1] += (self.myTouchYcurrent - self.myTouchYold)
             }*/
            /*else if (self.myLitType == G_LIT.LITLINE){
             gVertexData[2 * self.myLitID] += (self.myTouchXcurrent - self.myTouchXold)
             gVertexData[2 * self.myLitID + 1] += (self.myTouchYcurrent - self.myTouchYold)
             gVertexData[2 * self.myLitID + 2] += (self.myTouchXcurrent - self.myTouchXold)
             gVertexData[2 * self.myLitID + 3] += (self.myTouchYcurrent - self.myTouchYold)
             }*/
            
            
            NSLog(lMessage)
        }
    } // end of touchesMoved()
    
    
    
    // ------------------------------------------------------------------------
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first  {
            let firstTouchPoint = firstTouch.location(in: self.view)
            let lMessage = "Touches Ended at \(firstTouchPoint.x), \(firstTouchPoint.y)"
            
            // detected end of touch event sequence (finger lifted from surface)
            // NOTE: here you may need to instead set both current and old points to the last detected coordinates:
            self.myTouchXold = self.myTouchXcurrent
            self.myTouchYold = self.myTouchYcurrent
            
            self.myTouchXcurrent = GLfloat(firstTouchPoint.x)
            self.myTouchYcurrent = GLfloat(self.myViewPortHeight) - GLfloat(firstTouchPoint.y - 1)
            self.myTouchPhase = UITouchPhase.ended
            
            //resetting the rotation
            myDelta_x = 0.001
            myDelta_y = 0.001
            myfirstTouchX = 0.0
            myfirstTouchY = 0.0
            
            // SOLUTION: stop highlighting when touch event is off:
            self.myLitType = G_LIT.NONLIT
            self.myLitID = -1
            
            NSLog(lMessage)
        }
    } // end of touchesEnded()
    
    
    
    // ------------------------------------------------------------------------
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        let lMessage = "Touches Cancelled"
        
        self.myTouchXbegin = -1.0
        self.myTouchYbegin = -1.0
        self.myTouchXcurrent = -1.0
        self.myTouchYcurrent = -1.0
        self.myTouchXold = -1.0
        self.myTouchYold = -1.0
        
        
        // we are in the "something just interrupted us, e.g. a phone call" phase
        //     of the touch event sequence:
        self.myTouchPhase = UITouchPhase.cancelled
        
        NSLog(lMessage)
        
    } // end of touchesMoved()
    
    
    
    
    // ------------------------------------------------------------------------
    // MARK: -  OpenGL ES 2 shader compilation, linking, binding
    // ------------------------------------------------------------------------
    
    
    
    
    
    
    // ------------------------------------------------------------------------
    // load GLSL shaders from separate source code files, then compile and link
    // ------------------------------------------------------------------------
    func loadShaders() -> Bool {
        var vertShader: GLuint = 0
        var fragShader: GLuint = 0
        var vertShaderPathname: String
        var fragShaderPathname: String
        
        // Create shader program.
        myGLESProgram = glCreateProgram()
        
        // Create and compile vertex shader:
        vertShaderPathname = Bundle.main.path(forResource: "Shader", ofType: "vsh")!
        
        if self.compileShader(&vertShader,
                              type: GLenum(GL_VERTEX_SHADER),
                              file: vertShaderPathname) == false {
            
            NSLog("Failed to compile vertex shader")
            return false
        }
        
        // Create and compile fragment shader.
        fragShaderPathname = Bundle.main.path(forResource: "Shader", ofType: "fsh")!
        
        if self.compileShader(&fragShader,
                              type: GLenum(GL_FRAGMENT_SHADER),
                              file: fragShaderPathname) == false {
            NSLog("Failed to compile fragment shader")
            return false
        }
        
        // Attach vertex shader object code to GPU program:
        glAttachShader(myGLESProgram, vertShader)
        
        // Attach fragment shader object code to GPU program:
        glAttachShader(myGLESProgram, fragShader)
        
        // Bind locations of attribute variables:
        //  (this needs to be done *before* linking)
        glBindAttribLocation(myGLESProgram, GLuint(GLKVertexAttrib.position.rawValue), "a_Position")
        glBindAttribLocation(myGLESProgram, GLuint(GLKVertexAttrib.normal.rawValue), "normal")
        glBindAttribLocation(myGLESProgram, GLuint(GLKVertexAttrib.color.rawValue), "color")
        // Link GPU program:
        if !self.linkProgram(myGLESProgram) {
            NSLog("Failed to link program: \(myGLESProgram)")
            // if linking fails, dispose of anything we got so far:
            if vertShader != 0 {
                glDeleteShader(vertShader)
                vertShader = 0
            }
            if fragShader != 0 {
                glDeleteShader(fragShader)
                fragShader = 0
            }
            if myGLESProgram != 0 {
                glDeleteProgram(myGLESProgram)
                myGLESProgram = 0
            }
            return false
        }
        
        // Get location of uniform variables in the shaders:
        self.myWidthUniform = glGetUniformLocation(myGLESProgram, "u_Width")
        self.myHeightUniform = glGetUniformLocation(myGLESProgram, "u_Height")
        self.myColorUniform = glGetUniformLocation(myGLESProgram, "u_Color")
        self.myFoVUniform = glGetUniformLocation(myGLESProgram, "u_FoV")
        self.myAspectUniform = glGetUniformLocation(myGLESProgram, "u_Aspect")
        self.myNearUniform = glGetUniformLocation(myGLESProgram, "u_Near")
        self.myFarUniform = glGetUniformLocation(myGLESProgram, "u_Far")
        self.myDeltaXUniform = glGetUniformLocation(myGLESProgram, "u_DeltaX")
        self.myDeltaYUniform = glGetUniformLocation(myGLESProgram, "u_DeltaY")
        uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(myGLESProgram, "modelViewProjectionMatrix")
        uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(myGLESProgram, "normalMatrix")
        
        /*myFoVUniform      90.0
         myAspectUniform   1.0
         myNearUniform     10.0
         myFarUniform      1000.0*/
        
        
        // Release vertex and fragment shaders.
        if vertShader != 0 {
            glDetachShader(myGLESProgram, vertShader)
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDetachShader(myGLESProgram, fragShader)
            glDeleteShader(fragShader)
        }
        
        return true
    } // end of loadShaders()
    
    
    // ------------------------------------------------------------------------
    // compile GLSL source code into linkable shader object code:
    // ------------------------------------------------------------------------
    func compileShader(_ shader: inout GLuint, type: GLenum, file: String) -> Bool {
        var status: GLint = 0
        var source: UnsafePointer<Int8>
        do {
            source = try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue).utf8String!
        } catch {
            NSLog("Failed to load vertex shader \(file)")
            return false
        }
        var castSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
        
        // create a shader object to hold GLSL source code,
        //   and obtain a non-zero value by which it can be referenced
        shader = glCreateShader(type)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)
        
        var logLength: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            if let logRawPointer = malloc(Int(logLength)) {
                let logOpaquePointer = OpaquePointer(logRawPointer)
                let logContextPointer = UnsafeMutablePointer<GLchar>(logOpaquePointer)
                glGetShaderInfoLog(shader, logLength, &logLength, logContextPointer)
                NSLog("Shader compile log: \n%s", logContextPointer)
                free(logRawPointer)
            }
        }
        
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if status == GL_FALSE {
            glDeleteShader(shader)
            return false
        }
        return true
    } // end of compileShader()
    
    // ------------------------------------------------------------------------
    // link compiled GLSL shaders into a GLSL program for use by CPU GLES code
    // ------------------------------------------------------------------------
    func linkProgram(_ prog: GLuint) -> Bool {
        var status: GLint = 0
        
        glLinkProgram(prog)
        
        var logLength: GLint = 0
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            if let logRawPointer = malloc(Int(logLength)) {
                let logOpaquePointer = OpaquePointer(logRawPointer)
                let logContextPointer = UnsafeMutablePointer<GLchar>(logOpaquePointer)
                glGetProgramInfoLog(prog, logLength, &logLength, logContextPointer)
                NSLog("Shader link log: \n%s", logContextPointer)
                free(logRawPointer)
            }
        }
        
        glGetProgramiv(prog, GLenum(GL_LINK_STATUS), &status)
        if status == GL_FALSE {
            return false
        }
        
        return true
    }
    
    // ------------------------------------------------------------------------
    // you may call validateProgram()
    // ------------------------------------------------------------------------
    func validateProgram(_ prog: GLuint) -> Bool {
        var logLength: GLsizei = 0
        var status: GLint = 0
        
        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log: [GLchar] = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(prog, logLength, &logLength, &log)
            NSLog("Program validate log: %@", String(validatingUTF8: log)!)
        }
        
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        var returnVal = true
        if status == 0 {
            returnVal = false
        }
        return returnVal
    } // end of validateProgram()
    
    
} // end of class GameViewController


var gCubeVertexData: [GLfloat] = [
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5, -0.5, -0.5,        1.0, 0.0, 0.0,          1.0, 0.0, 0.0, 1.0,
    0.5, 0.5, -0.5,         1.0, 0.0, 0.0,          1.0, 0.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         1.0, 0.0, 0.0,          1.0, 0.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         1.0, 0.0, 0.0,          1.0, 0.0, 0.0, 1.0,
    0.5, 0.5, -0.5,         1.0, 0.0, 0.0,          1.0, 0.0, 0.0, 1.0,
    0.5, 0.5, 0.5,          1.0, 0.0, 0.0,          1.0, 0.0, 0.0, 1.0,
    
    0.5, 0.5, -0.5,         0.0, 1.0, 0.0,          0.0, 1.0, 0.0, 1.0,
    -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,          0.0, 1.0, 0.0, 1.0,
    0.5, 0.5, 0.5,          0.0, 1.0, 0.0,          0.0, 1.0, 0.0, 1.0,
    0.5, 0.5, 0.5,          0.0, 1.0, 0.0,          0.0, 1.0, 0.0, 1.0,
    -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,          0.0, 1.0, 0.0, 1.0,
    -0.5, 0.5, 0.5,         0.0, 1.0, 0.0,          0.0, 1.0, 0.0, 1.0,
    
    -0.5, 0.5, -0.5,        -1.0, 0.0, 0.0,         0.0, 0.0, 1.0, 1.0,
    -0.5, -0.5, -0.5,       -1.0, 0.0, 0.0,         0.0, 0.0, 1.0, 1.0,
    -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,         0.0, 0.0, 1.0, 1.0,
    -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,         0.0, 0.0, 1.0, 1.0,
    -0.5, -0.5, -0.5,       -1.0, 0.0, 0.0,         0.0, 0.0, 1.0, 1.0,
    -0.5, -0.5, 0.5,        -1.0, 0.0, 0.0,         0.0, 0.0, 1.0, 1.0,
    
    -0.5, -0.5, -0.5,       0.0, -1.0, 0.0,         0.0, 1.0, 1.0, 1.0,
    0.5, -0.5, -0.5,        0.0, -1.0, 0.0,         0.0, 1.0, 1.0, 1.0,
    -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,         0.0, 1.0, 1.0, 1.0,
    -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,         0.0, 1.0, 1.0, 1.0,
    0.5, -0.5, -0.5,        0.0, -1.0, 0.0,         0.0, 1.0, 1.0, 1.0,
    0.5, -0.5, 0.5,         0.0, -1.0, 0.0,         0.0, 1.0, 1.0, 1.0,
    
    0.5, 0.5, 0.5,          0.0, 0.0, 1.0,         1.0, 1.0, 0.0, 1.0,
    -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,         1.0, 1.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         0.0, 0.0, 1.0,         1.0, 1.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         0.0, 0.0, 1.0,         1.0, 1.0, 0.0, 1.0,
    -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,         1.0, 1.0, 0.0, 1.0,
    -0.5, -0.5, 0.5,        0.0, 0.0, 1.0,         1.0, 1.0, 0.0, 1.0,
    
    0.5, -0.5, -0.5,        0.0, 0.0, -1.0,        1.0, 0.0, 1.0, 1.0,
    -0.5, -0.5, -0.5,       0.0, 0.0, -1.0,        1.0, 0.0, 1.0, 1.0,
    0.5, 0.5, -0.5,         0.0, 0.0, -1.0,        1.0, 0.0, 1.0, 1.0,
    0.5, 0.5, -0.5,         0.0, 0.0, -1.0,        1.0, 0.0, 1.0, 1.0,
    -0.5, -0.5, -0.5,       0.0, 0.0, -1.0,        1.0, 0.0, 1.0, 1.0,
    -0.5, 0.5, -0.5,        0.0, 0.0, -1.0,        1.0, 0.0, 1.0, 1.0
    
]

