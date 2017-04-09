//
//  GameViewController.swift
//  a03Spline
//
//  Created by VINITA BOOLCHANDANI on 07/03/17.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//

import GLKit
import OpenGLES


// OpenGL ES requires the use of C-like pointers to "CPU memory",
// without the automated memory management provided by Swift,:
func obtainUnsafePointer(_ i: Int) -> UnsafeRawPointer? {
    return UnsafeRawPointer(bitPattern: i)
}


var gVertexData: [GLfloat] = [
    // vertex data structured thus:
    //  positionX, positionY, etc.
    
    // we're not really using this data in the assignment 02 template,
    //  since we're setting all vertex data from touch events.
    
]

var gControlPoints: [GLfloat] = []
var gfirstDPoints: [GLfloat] = []

//var gControlPoints: [GLfloat] = []
var gColorData: [[GLfloat]] = [
    // color data in RGBA float format
    [0.0, 1.0, 0.0, 1.0],
    [0.0, 0.0, 1.0, 1.0],
    [1.0, 0.0, 0.0, 1.0],
    [1.0, 1.0, 0.0, 1.0],
    [0.0, 1.0, 1.0, 1.0],
    [1.0, 0.0, 1.0, 1.0],
    [0.0, 1.0, 0.0, 1.0],
    [0.0, 0.0, 1.0, 1.0],
    [1.0, 0.0, 0.0, 1.0]
]

class GameViewController: GLKViewController {
    
    var myGLESProgram: GLuint = 0
    
    var myModelViewProjectionMatrix:GLKMatrix4 = GLKMatrix4Identity
    
    var myViewPortWidth:GLsizei = -1
    var myViewPortHeight:GLsizei = -1
    
    var myWidthUniform: GLint = 0
    var myHeightUniform: GLint = 0
    var myColorUniform: GLint = 0
    
    var myVertexArray: GLuint = 0
    var myVertexBuffer: GLuint = 0
    
    var myGLESContext: EAGLContext? = nil
    var myGLKView: GLKView? = nil
    
    // touch event data:
    var myTouchXbegin: GLfloat = -1.0
    var myTouchYbegin: GLfloat = -1.0
    var myTouchXcurrent: GLfloat = -1.0
    var myTouchYcurrent: GLfloat = -1.0
    var myTouchXold: GLfloat = -1.0
    var myTouchYold: GLfloat = -1.0
    var myTouchPhase: UITouchPhase? = nil
    
    var touchCount = -1
    var no_spline_seg = 0
    //var interpolateVertexCount = -1
    var grab = 0
    // var insert = 0
    //var highlightX = -1
    //var highlightY = -1
    var highlightPoint = -1
    //var highlightLine = -1
    var grabLine = 0
    
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
        self.myGLKView!.drawableDepthFormat = GLKViewDrawableDepthFormat.formatNone
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
        //        let lGL_VERSION = String.fromCString(lGL_VERSION_ptr as! UnsafePointer<CChar>)
        let lGL_VERSION = String(cString: lGL_VERSION_ptr!)
        print("glGetString(GLenum(GL_VERSION_ptr)) = \(lGL_VERSION_ptr)")
        print("   returned: '\(lGL_VERSION)'")
        //        print("   returns 'OpenGL ES 2.0 APPLE-12.0.40' ")
        //        print("   or 'OpenGL ES 3.0 APPLE-12.0.40' ")
        let lGL_SHADING_LANGUAGE_VERSION_ptr = glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION))
        let lGL_SHADING_LANGUAGE_VERSION = String(cString: lGL_SHADING_LANGUAGE_VERSION_ptr!)
        print("glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION_ptr)) = \(lGL_SHADING_LANGUAGE_VERSION_ptr)")
        print("   returns '\(lGL_SHADING_LANGUAGE_VERSION)' ")
        //        print("   returns 'OpenGL ES GLSL ES 1.00' ")
        //        print("   or 'OpenGL ES GLSL ES 3.00' ")
        
        
        // get shaders ready -- load, compile, link GLSL code into GPU program:
        if (!self.loadShaders()) {
            self.alertUserNoShaders()
        }
        
        // in 2D, we don't need depth/Z-buffer:
        glDisable(GLenum(GL_DEPTH_TEST))
        
        // the vertices we draw are stored in an array:
        glGenVertexArrays(1, &myVertexArray)
        glBindVertexArray(myVertexArray)
        
        glGenBuffers(1, &myVertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        // define where the vertex buffer is going to find its data:
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * gVertexData.count),
                     &gVertexData,
                     GLenum(GL_STATIC_DRAW))
        
        // enable which kind of attributes the buffer data is going to use:
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        
        // now call glVertexAttribPointer() to specify the location and data format
        //   of the array of generic vertex attributes at index,
        //   to be used at rendering time, when glDrawArrays() is going to be called.
        //
        // public func glVertexAttribPointer(indx: GLuint, _ size: GLint,
        //   _ type: GLenum, _ normalized: GLboolean,
        //   _ stride: GLsizei, _ ptr: UnsafePointer<Void>)
        // see https://www.khronos.org/opengles/sdk/docs/man/xhtml/glVertexAttribPointer.xml
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              2, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              0, obtainUnsafePointer(0) )
        
        // now "break" the vertex array binding:
        glBindVertexArray(0)
        
        // glViewport(x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei)
        self.myViewPortWidth = GLsizei(self.view.bounds.size.width)
        self.myViewPortHeight = GLsizei(self.view.bounds.size.height)
        
        glViewport ( 0, 0, self.myViewPortWidth, self.myViewPortHeight )
        
        // Set the background color
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
        
        // B481 Assignment 1 TODO: cause a change in the drawing
        
        // for example,
        //   try changing some of the vertex coordinate values,
        //   then ensure that any change is propagated to the GLSL program
        
    } // end of update()
    
    func pointToPointDist(x1: GLfloat, y1: GLfloat)
    {
        
        //var i = interpolateVertexCount+1
        var i=0
        while i <= gControlPoints.count-2
        //while i <= touchCount
        {
            //i = gVertexData.index(of: x)
            //let y = gVertexData.index(after: i)
            let distance = abs(sqrt(((x1 - gControlPoints[i])*(x1 - gControlPoints[i]) + (y1 - gControlPoints[i+1])*(y1 - gControlPoints[i+1]))))
            if (distance < 10)
            {
                grabLine = 0
                grab = 1
                highlightPoint = i
                break
            }
            else
            {
                grab = 0
                grabLine = 0
            }
            
            i = i+2
            
        }
    }
    
    
    
    func pointToLineDist(x0: GLfloat, y0: GLfloat)
    {
        var h = 0.0
        var j = 0
        //while j < gVertexData.count-4
        while j <= touchCount-3
        {
            let x1 = gVertexData[j]
            let y1 = gVertexData[j+1]
            let x2 = gVertexData[j+2]
            let y2 = gVertexData[j+3]
            let n = abs(sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1)))
            h = abs(Double(((x2 - x1) * (y0 - y1) - (y2 - y1) * (x0 - x1))/n))
            let hMessage = "h is: \(h)"
            NSLog(hMessage)
            
            let v = n
            let l = ((x2 - x1) * (x0 - x1) + (y2 - y1) * (y0 - y1))/v
            let lMessage = "l is: \(l)"
            NSLog(lMessage)
            
            if (h<10 && l>=0 && l<v)
            {
                grabLine = 1
                //grab = 0
                highlightPoint = j
                break
            }
            else
            {
                grabLine = 0
                grab = 0
            }
            j = j+2
            
        }
    }
    
    // ------------------------------------------------------------------------
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glUseProgram(myGLESProgram)
        
        glClear( GLbitfield(GL_COLOR_BUFFER_BIT) |
            GLbitfield(GL_DEPTH_BUFFER_BIT)   )
        
        // get viewport dimensions:
        self.myViewPortWidth = GLsizei(self.view.bounds.size.width)
        self.myViewPortHeight = GLsizei(self.view.bounds.size.height)
        
        // pass viewport dimensions to the vertex shader:
        glUniform1f(self.myWidthUniform, GLfloat(self.myViewPortWidth))
        glUniform1f(self.myHeightUniform, GLfloat(self.myViewPortHeight))
        
        // set vertex coordinates:
        
        // the "current" line
        // gVertexData[0] = GLfloat( myTouchXbegin )
        //gVertexData[1] = GLfloat( myTouchYbegin )
        //gVertexData[2] = GLfloat( myTouchXcurrent )
        //gVertexData[3] = GLfloat( myTouchYcurrent )
        
        // the "delta" line (point from old to current touch location)
        /*   gVertexData[4] = GLfloat( myTouchXold )
         gVertexData[5] = GLfloat( myTouchYold )
         gVertexData[6] = GLfloat( myTouchXcurrent )
         gVertexData[7] = GLfloat( myTouchYcurrent )*/
        
        
        
        // gVertexData.append(GLfloat( myTouchYbegin ))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        // define where the vertex buffer is going to find its data:
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * gVertexData.count),
                     &gVertexData,
                     GLenum(GL_STATIC_DRAW))
        
        // enable which kind of attributes the buffer data is going to use:
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        
        // now call glVertexAttribPointer() to specify the location and data format
        //   of the array of generic vertex attributes at index,
        //   to be used at rendering time, when glDrawArrays() is going to be called.
        //
        // public func glVertexAttribPointer(indx: GLuint, _ size: GLint,
        //   _ type: GLenum, _ normalized: GLboolean,
        //   _ stride: GLsizei, _ ptr: UnsafePointer<Void>)
        // see https://www.khronos.org/opengles/sdk/docs/man/xhtml/glVertexAttribPointer.xml
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              2, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              0, obtainUnsafePointer(0) )
        
        // bind the vertex array to draw:
        glBindVertexArray(myVertexArray)
        
        
        glLineWidth(3.0)
        glPointSize(1.0)
        
        if touchCount>=1
        {
            //var i = 0
            let j = 0
            /*let todraw:GLint = GLint(touchCount+1)/2
            while GLint(i)<todraw-1 && todraw>1
            {
                if(j==6)
                { j=0
                }
                //glDrawArrays( GLenum(GL_LINE_STRIP), 0, 2)
                glUniform4f(self.myColorUniform,
                            gColorData[j][0],
                            gColorData[j][1],
                            gColorData[j][2],
                            gColorData[j][3])
                glDrawArrays( GLenum(GL_LINE_STRIP), GLint(i), 2)
                i=i+1
                j=j+1
            }*/
            
            
            glUniform4f(self.myColorUniform,
                        gColorData[2][0],
                        gColorData[2][1],
                        gColorData[2][2],
                        gColorData[2][3])
            
            let interpolateVertexCount = (gVertexData.count+1)/2//((touchCount-1)/2)*100 //
            glDrawArrays( GLenum(GL_LINE_STRIP), 0, GLint(interpolateVertexCount))
            
           
            glEnable(GLenum(GL_POINT_SMOOTH))
            glPointSize(20.0)
            glUniform4f(self.myColorUniform,
                        gColorData[1][0],
                        gColorData[1][1],
                        gColorData[1][2],
                        gColorData[1][3])
            /*let k = GLint((gVertexData.count-touchCount-1)/2)
            let m = GLint((touchCount+1)/2)
            //NSLog("k: \(k), m: \(m)")
            glDrawArrays( GLenum(GL_POINTS), k, m )
            
            else if grabLine == 1
            {
                glDrawArrays( GLenum(GL_LINE_STRIP), GLint(highlightPoint/2), 2 )
                //grabLine=0
            }*/
            
        }
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        // define where the vertex buffer is going to find its data:
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * gControlPoints.count),
                     &gControlPoints,
                     GLenum(GL_STATIC_DRAW))
        glDrawArrays( GLenum(GL_POINTS), 0, Int32(gControlPoints.count/2) )
        
        glUniform4f(self.myColorUniform,
                    1,
                    1,
                    1,
                    1)

        if grab == 1
        {
            glDrawArrays( GLenum(GL_POINTS), GLint(highlightPoint/2), 1 )
            //grab = 0;
        }
        glUniform4f(self.myColorUniform,
                    gColorData[3][0],
                    gColorData[3][1],
                    gColorData[3][2],
                    gColorData[3][3])
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * gfirstDPoints.count),
                     &gfirstDPoints,
                     GLenum(GL_STATIC_DRAW))
        glDrawArrays( GLenum(GL_LINE_STRIP), 0, Int32(gfirstDPoints.count/2) )

        // now "break" the vertex array binding:
        glBindVertexArray(0)
        
    } // end of glkView( ... drawInRect: )
    
    
    
    
    
    
    // ------------------------------------------------------------------------
    // MARK: - UIResponder delegate methods for touch events
    // ------------------------------------------------------------------------
    
    // ------------------------------------------------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first  {
            
            //highlightPoint = -1
            grabLine = 0
            grab=0
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
            
            
            if touchCount >= 1
            {
                pointToPointDist(x1: myTouchXbegin, y1: myTouchYbegin)
            }
            /*if touchCount >= 3 && grab == 0
            {
                pointToLineDist(x0: myTouchXbegin, y0: myTouchYbegin)
            }*/

            // we are in the "we've just began" phase of the touch event sequence:
            self.myTouchPhase = UITouchPhase.began
            
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
            
            if grab==1 {
                gControlPoints[highlightPoint] = myTouchXcurrent
                gControlPoints[highlightPoint+1] = myTouchYcurrent
                interpolateSpline()
                //gVertexData.append(contentsOf: gControlPoints)
            }
            
            if grabLine == 1
            {
                let movedX = myTouchXcurrent - myTouchXold
                let movedY = myTouchYcurrent - myTouchYold
                gVertexData[highlightPoint] = gVertexData[highlightPoint] + movedX
                gVertexData[highlightPoint+1] = gVertexData[highlightPoint+1] + movedY
                gVertexData[highlightPoint+2] = gVertexData[highlightPoint+2] + movedX
                gVertexData[highlightPoint+3] = gVertexData[highlightPoint+3] + movedY
                
            }
            NSLog(lMessage)
        }
    } // end of touchesMoved()
    
    func interpolateSpline ()
    {
        var t:GLfloat = 0.0
        //var i = interpolateVertexCount
        var i = -1
        //let j=(no_spline_seg*3+1)*2-2
        var j = 0
        gVertexData.removeAll()
        while j<=touchCount-7
        {
        let Gy = gControlPoints[j+7]
        let Gx = gControlPoints[j+6]
        let Fy = gControlPoints[j+5]
        let Fx = gControlPoints[j+4]
        let Ey = gControlPoints[j+3]
        let Ex = gControlPoints[j+2]
        let Dy = gControlPoints[j+1]
        let Dx = gControlPoints[j]
        t=0.0
        while t<=1.0
        {
            let Px = ((1-t)*(1-t)*(1-t)*Dx)+(3*t*(1-t)*(1-t)*Ex)+(3*t*t*(1-t)*Fx)+(t*t*t*Gx)
            let Py = ((1-t)*(1-t)*(1-t)*Dy)+(3*t*(1-t)*(1-t)*Ey)+(3*t*t*(1-t)*Fy)+(t*t*t*Gy)
            let Pdx = (3*(1-t)*(1-t)*(Dx+Ex))+(6*t*(1-t)*(Ex+Fx))+(3*t*t*(Fx+Gx))
            let Pdy = (3*(1-t)*(1-t)*(Dy+Ey))+(6*t*(1-t)*(Ey+Fy))+(3*t*t*(Fy+Gy))
            i = i+1
            gfirstDPoints.insert(GLfloat(Pdx), at: Int(i))
            gVertexData.insert(GLfloat( Px ), at: Int(i))
            i = i+1
            gfirstDPoints.insert(GLfloat(Pdy), at: Int(i))
            gVertexData.insert(GLfloat( Py ), at: Int(i))
            t = t+0.01
        }
            j=j+6
        }
        //interpolateVertexCount = i
    }

    
    // ------------------------------------------------------------------------
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first  {
            let firstTouchPoint = firstTouch.location(in: self.view)
            let lMessage = "Touches Ended at \(firstTouchPoint.x), \(firstTouchPoint.y)"
            
            // detected end of touch event sequence (finger lifted from surface)
            // NOTE: here you may need to instead set both current and old points to the last detected coordinates:
            self.myTouchXold = self.myTouchXcurrent
            self.myTouchYold = self.myTouchYcurrent
            if touchCount>63
            {
                gControlPoints.removeAll()
                gVertexData.removeAll()
                touchCount = -1
                no_spline_seg=0
                
            }
            
            self.myTouchXcurrent = GLfloat(firstTouchPoint.x)
            self.myTouchYcurrent = GLfloat(self.myViewPortHeight) - GLfloat(firstTouchPoint.y - 1)
            self.myTouchPhase = UITouchPhase.ended
            
            if grab == 0 && grabLine == 0
            {
                touchCount = touchCount+1
                gControlPoints.insert(GLfloat( myTouchXcurrent ), at: Int(touchCount))
                touchCount = touchCount+1
                gControlPoints.insert(GLfloat( myTouchYcurrent ), at: Int(touchCount))
                if touchCount==((no_spline_seg+1)*3+1)*2-1
                {
                    //NSLog("gVertex data: \(gVertexData[2]), gVertex data: \(gVertexData[3])")
                   interpolateSpline()
                    no_spline_seg = no_spline_seg+1
                    //gVertexData.append(contentsOf: gControlPoints)
                    //NSLog("gVertex data: \(gVertexData[interpolateVertexCount+3]), gVertex data: \(gVertexData[interpolateVertexCount+4])")
                }
                /*else
                {
                    var i = gVertexData.count
                    gVertexData.insert(myTouchXcurrent , at: i)
                    // k=k+1
                    i=i+1
                    gVertexData.insert(myTouchYcurrent , at: i)
                }*/
            }
            
           NSLog(lMessage)
            grab = 0
            grabLine = 0
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
        glBindAttribLocation(myGLESProgram,
                             GLuint(GLKVertexAttrib.position.rawValue),
                             "a_Position")
        
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

