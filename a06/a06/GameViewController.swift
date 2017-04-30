//
//  GameViewController.swift
//  a06
//
//  Created by Vinita Boolchandani on 2017-04-27.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
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


/*var gVertexData: [GLfloat] = [
 // vertex data structured thus:
 //  positionX, positionY, etc.
 
 // SOLUTION: start from NO vertices:
 ]*/
var layer: CALayer?
var gColorData: [[GLfloat]] = [
    // color data in RGBA float format
    [0.0, 1.0, 0.0, 1.0],
    [0.0, 1.0, 1.0, 1.0],
    [1.0, 0.0, 0.0, 1.0]
]

var gAxesData: [GLfloat] = [ 0.0, 0.0, 0.0,
                             1.0, 0.0, 0.0,
                             0.0, 0.0, 0.0,
                             0.0, 1.0, 0.0,
                             0.0, 0.0, 0.0,
                             0.05, 0.05, 1.0]


let G_DISTANCE_VV: GLfloat = 20.0
let G_DISTANCE_VL: GLfloat = 10.0

enum G_LIT {
    case NONLIT
    case LITVERTEX
    case LITLINE
}

enum G_OPR {
    case SCALE
    case TRANS_XY
    case TRANS_XZ
    case ROTATE
}

enum G_OBJ {
    case OBJECT1
    case OBJECT2
    case OBJECT3
    case CAM
}

var gMat: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                       0.0, 1.0, 0.0, 0.0,
                       0.0, 0.0, 1.0, 0.0,
                       0.0, 0.0, 0.0, 1.0]

var gMatView: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                           0.0, 1.0, 0.0, 0.0,
                           0.0, 0.0, 1.0, 0.0,
                           0.0, 0.0, -5.0, 1.0]

var vertices = [GLfloat]()
var normals = [GLfloat]()
var faces = [GLint]()
var texture = [GLfloat]()
var drawvertices: [GLfloat] = [ /*0.5, -0.5, -0.5,        1.0, 0.0, 0.0,
                                0.5, 0.5, -0.5,         1.0, 0.0, 0.0,         
                                0.5, -0.5, 0.5,         1.0, 0.0, 0.0,         
                                0.5, -0.5, 0.5,         1.0, 0.0, 0.0,         
                                0.5, 0.5, -0.5,         1.0, 0.0, 0.0,         
                                0.5, 0.5, 0.5,          1.0, 0.0, 0.0,         
                                
                                0.5, 0.5, -0.5,         0.0, 1.0, 0.0,         
                                -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,         
                                0.5, 0.5, 0.5,          0.0, 1.0, 0.0,         
                                0.5, 0.5, 0.5,          0.0, 1.0, 0.0,         
                                -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,         
                                -0.5, 0.5, 0.5,         0.0, 1.0, 0.0,         
                                
                                -0.5, 0.5, -0.5,        -1.0, 0.0, 0.0,        
                                -0.5, -0.5, -0.5,       -1.0, 0.0, 0.0,        
                                -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,        
                                -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,        
                                -0.5, -0.5, -0.5,       -1.0, 0.0, 0.0,        
                                -0.5, -0.5, 0.5,        -1.0, 0.0, 0.0,        
                                
                                -0.5, -0.5, -0.5,       0.0, -1.0, 0.0,        
                                0.5, -0.5, -0.5,        0.0, -1.0, 0.0,        
                                -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,        
                                -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,        
                                0.5, -0.5, -0.5,        0.0, -1.0, 0.0,        
                                0.5, -0.5, 0.5,         0.0, -1.0, 0.0,        
                                
                                0.5, 0.5, 0.5,          0.0, 0.0, 1.0,         
                                -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,         
                                0.5, -0.5, 0.5,         0.0, 0.0, 1.0,         
                                0.5, -0.5, 0.5,         0.0, 0.0, 1.0,         
                                -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,         
                                -0.5, -0.5, 0.5,        0.0, 0.0, 1.0,         
                                
                                0.5, -0.5, -0.5,        0.0, 0.0, -1.0,        
                                -0.5, -0.5, -0.5,       0.0, 0.0, -1.0,        
                                0.5, 0.5, -0.5,         0.0, 0.0, -1.0,        
                                0.5, 0.5, -0.5,         0.0, 0.0, -1.0,        
                                -0.5, -0.5, -0.5,       0.0, 0.0, -1.0,        
                                -0.5, 0.5, -0.5,        0.0, 0.0, -1.0*/
    
]

var drawnormals: [GLfloat] = [0.0]
var rotation:GLfloat = 0.0
class GameViewController: GLKViewController {
    
    var myGLESProgram: GLuint = 0
    
    var myModelViewProjectionMatrix:GLKMatrix4 = GLKMatrix4Identity
    var mynormalMatrix: GLKMatrix3 = GLKMatrix3Identity
    
    
    var myViewPortWidth:GLsizei = -1
    var myViewPortHeight:GLsizei = -1
    
    var myWidthUniform: GLint = 0
    var myHeightUniform: GLint = 0
    var myColorUniform: GLint = 0
    
    var myMat4Uniform: GLint = 0
    var myMat4ViewUniform: GLint = 0
    var myFoVUniform:GLint = 0
    var myAspectUniform:GLint = 0
    var myNearUniform:GLint = 0
    var myFarUniform:GLint = 0
    
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
    var myFoV:GLfloat = 90.0
    var myAspect:GLfloat = 0.6
    var myNear:GLfloat = 0.01
    var myFar:GLfloat = 21.01
    var myDelta_x:GLfloat = 0.0
    var myDelta_y:GLfloat = 0.0
    var myfirstTouchX:GLfloat = 0.0
    var myfirstTouchY:GLfloat = 0.0
    var totalX:GLfloat = 0.0
    var totalY:GLfloat = 0.0
    
    //my matrices
    var myRotateMat: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                                  0.0, 1.0, 0.0, 0.0,
                                  0.0, 0.0, 1.0, 0.0,
                                  0.0, 0.0, 0.0, 1.0]
    var myTranslateMat: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                                     0.0, 1.0, 0.0, 0.0,
                                     0.0, 0.0, 1.0, 0.0,
                                     0.0, 0.0, 0.0, 1.0]
    var myScaleMat: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                                 0.0, 1.0, 0.0, 0.0,
                                 0.0, 0.0, 1.0, 0.0,
                                 0.0, 0.0, 0.0, 1.0]
    
    var myRotateMatCam: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                                     0.0, 1.0, 0.0, 0.0,
                                     0.0, 0.0, 1.0, 0.0,
                                     0.0, 0.0, 0.0, 1.0]
    var myTranslateMatCam: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                                        0.0, 1.0, 0.0, 0.0,
                                        0.0, 0.0, 1.0, 0.0,
                                        0.0, 0.0, 0.0, 1.0]
    var myScaleMatCam: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                                    0.0, 1.0, 0.0, 0.0,
                                    0.0, 0.0, 1.0, 0.0,
                                    0.0, 0.0, 0.0, 1.0]
    
    //Centre of mass data
    var CofMX: GLfloat = 0.0
    var CofMY: GLfloat = 0.0
    var CofMZ: GLfloat = 0.0
    
    var CamX: GLfloat = 0.0
    var CamY: GLfloat = 0.0
    var CamZ: GLfloat = 0.0
    
    var ScaleX: GLfloat = 1.0
    var ScaleY: GLfloat = 1.0
    var ScaleZ: GLfloat = 1.0
    
    var myOperation = G_OPR.ROTATE
    var myObject = G_OBJ.OBJECT1
    
    // polygon build data:
    var myEnteredVertices = 0
    var myLitType = G_LIT.NONLIT
    var myLitID = -1
    
    var topSelection = 0
    var bottomSelection = 0
    
    var topList = [UIView]()
    var bottomList = [UIView]()
    
    var blue = "7cbaf3"
    var darkblue = "2f6699"
    
    func testInsideButtons(_ p:CGPoint) -> Int {
        for i in 0 ..< 4 {
            if(topList[i].frame.contains(p)) {return 1}
            if(bottomList[i].frame.contains(p)) {return 1}
        }
        return 0
    }
    
    func myScale(x :GLfloat, y: GLfloat, z: GLfloat) -> [GLfloat] {
        
        let res: [GLfloat] = [x, 0.0, 0.0, 0.0,
                              0.0, y, 0.0, 0.0,
                              0.0, 0.0, z, 0.0,
                              0.0, 0.0, 0.0, 1.0]
        return res //matrixMultiply(mat1: res, mat2: myScaleMat)
    }
    
    func  myTranslate(x :GLfloat, y: GLfloat, z: GLfloat) -> [GLfloat] {
        
        let res: [GLfloat] = [1.0, 0.0, 0.0, 0.0,
                              0.0, 1.0, 0.0, 0.0,
                              0.0, 0.0, 1.0, 0.0,
                              x, y, z, 1.0]
        return res //matrixMultiply(mat1: res, mat2: myTranslateMat)
    }
    
    func myRotate(x1 :GLfloat, y1: GLfloat, z: GLfloat) -> [GLfloat] {
        let R = GLfloat(1.0)
        let dr = sqrt(x1 * x1 + y1 * y1);
        let A = dr/R;
        let nx = -y1;
        let ny = x1;
        let magnitude = sqrt(nx * nx + ny * ny + z * z);
        let x = nx/magnitude
        let y = ny/magnitude
        let c = cos(A)
        let s = sin(A)
        let d = 1.0-c
        let xx = x * x
        let xy = x * y
        let xz = x * z
        let yy = y * y
        let yz = y * z
        let zz = z * z
        //lrotateMatrix = GLKMatrix4(0.0);
        let res: [GLfloat] = [ xx*d+c,    xy*d+z*s,         xz*d-y*s,      0.0,
                               xy*d-z*s,         yy*d+c,         yz*d+x*s,      0.0,
                               xz*d+y*s,            yz*d-x*s,         zz*d+c,      0.0,
                               0.0,            0.0,         0.0,      1.0]
        return res
        //gMat = matrixMultiply(mat1: myRotate2d, mat2: gMat)
    }
    
    func matrixMultiply(mat1 :[GLfloat], mat2: [GLfloat]) -> [GLfloat]
    {
        var i = 0
        var j = 0
        var k = 0
        var res_mat: [GLfloat] = []
        /*res_mat[0][0] = mat1[0][0] * mat2[0][0] + mat1[0][1]*mat2[1][0] + mat1[0][2]*mat1[2][0] + mat1[0][3] * mat2[3][0]
         res_mat[0][1] = mat1[0][0] * mat2[0][1] + mat1[0][1]*mat2[1][1] + mat1[0][2]*mat1[2][1] + mat1[0][3] * mat2[3][1]
         res_mat[0][2] = mat1[0][0] * mat2[0][2] + mat1[0][1]*mat2[1][2] + mat1[0][2]*mat1[2][2] + mat1[0][3] * mat2[3][2]
         res_mat[0][3] = mat1[0][0] * mat2[0][3] + mat1[0][1]*mat2[1][3] + mat1[0][2]*mat1[2][3] + mat1[0][3] * mat2[3][3]
         res_mat[1][0] = mat1[1][0] * mat2[0][1] + mat1[0][1]*mat2[1][1] + mat1[0][2]*mat1[2][1] + mat1[0][3] * mat2[3][1]
         res_mat[1][1] = mat1[0][0] * mat2[0][1] + mat1[0][1]*mat2[1][1] + mat1[0][2]*mat1[2][1] + mat1[0][3] * mat2[3][1]*/
        var c: GLfloat = 0.0
        while i<4
        {
            j=0
            while j<4
            {
                k=0
                c=0.0
                while k<4
                {
                    c += mat1[i*4+k] * mat2[k*4+j]
                    k+=1
                }
                res_mat.insert(c, at: (i*4)+j)
                j+=1
            }
            i+=1
        }
        //myTranslateMat = res_mat
        return res_mat
    }
    
    func setButtons() {
        let height = self.view.frame.height
        let width = self.view.frame.width
        let edgeBuffer = 40 as CGFloat
        let buffer = 12 as CGFloat
        let buttonWidth = (width - buffer*3 - edgeBuffer*2)/4
        let buttonHeight = height/20
        
        var x = edgeBuffer
        var y = 25 as CGFloat
        addButton(x,y,buttonWidth, buttonHeight, blue, "Rot", 1, 0)
        x += buttonWidth + buffer
        addButton(x,y,buttonWidth, buttonHeight, darkblue, "T-xy", 1, 1)
        x += buttonWidth + buffer
        addButton(x,y,buttonWidth, buttonHeight, darkblue, "T-xz", 1, 2)
        x += buttonWidth + buffer
        addButton(x,y,buttonWidth, buttonHeight, darkblue, "Scale", 1, 3)
        
        x = edgeBuffer
        y += buttonHeight + buffer
        addButton(x,y,buttonWidth, buttonHeight, blue, "Obj1", 0, 0)
        x += buttonWidth + buffer
        addButton(x,y,buttonWidth, buttonHeight, darkblue, "Obj2", 0, 1)
        x += buttonWidth + buffer
        addButton(x,y,buttonWidth, buttonHeight, darkblue, "Anim", 0, 2)
        x += buttonWidth + buffer
        addButton(x,y,buttonWidth, buttonHeight, darkblue, "Cam", 0, 3)
        
    }
    
    func topRowClick(_ recognizer: UITapGestureRecognizer) {
        let index = recognizer.view!.tag
        topSelection = index
        for i in 0 ..< 4 {
            topList[i].layer.sublayers?[0].removeFromSuperlayer()
            if(i != index) {topList[i].layer.insertSublayer(createGradient(darkblue, bounds: topList[i].bounds,round: 5 as CGFloat), at:0)}
            else {topList[index].layer.insertSublayer(createGradient(blue, bounds: topList[index].bounds,round: 5 as CGFloat), at:0)}
        }
        //insert more code here */
    }
    
    func bottomRowClick(_ recognizer: UITapGestureRecognizer) {
        let index = recognizer.view!.tag
        bottomSelection = index
        for i in 0 ..< 4 {
            bottomList[i].layer.sublayers?[0].removeFromSuperlayer()
            if(i != index) {bottomList[i].layer.insertSublayer(createGradient(darkblue, bounds: bottomList[i].bounds,round: 5 as CGFloat), at:0)}
            else {bottomList[index].layer.insertSublayer(createGradient(blue, bounds: bottomList[index].bounds,round: 5 as CGFloat), at:0)}
        }
        
        //insert more code here
    }
    
    func addButton(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat, _ color:String, _ text:String, _ isTop:Int, _ index:Int) {
        let createView = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
        createView.layer.insertSublayer(createGradient(color, bounds: createView.bounds,round: 0 as CGFloat), at:0)
        createView.tag = index
        let tapGestureTop = UITapGestureRecognizer(target: self, action: #selector(GameViewController.topRowClick(_:)))
        let tapGestureBottom = UITapGestureRecognizer(target: self, action: #selector(GameViewController.bottomRowClick(_:)))
        
        let create = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
        create.text = text
        create.textColor = UIColor.white
        create.textAlignment = NSTextAlignment.center
        create.backgroundColor = UIColor.clear
        create.font = UIFont(name: "Helvetica", size: CGFloat(15))!
        createView.layer.borderWidth = 2
        createView.layer.cornerRadius = 5
        createView.layer.borderColor = UIColorFromRGB("6E7B8B").cgColor
        createView.clipsToBounds = true
        createView.addSubview(create)
        
        if(isTop == 1) {
            createView.addGestureRecognizer(tapGestureTop)
            topList.append(createView)
        }
        else {
            createView.addGestureRecognizer(tapGestureBottom)
            bottomList.append(createView)
        }
        self.view.addSubview(createView)
    }
    
    func createGradient(_ color:String, bounds:CGRect, round:CGFloat) -> CAGradientLayer {
        let grad = CAGradientLayer()
        let pc = UIColorFromRGB(color, alpha: 1)
        let lpc = UIColorFromRGB(color, alpha: 0.4)
        grad.colors = [lpc.cgColor, pc.cgColor]
        grad.frame = bounds
        grad.cornerRadius = round
        return grad
    }
    
    func UIColorFromRGB(_ colorCode: String, alpha: Float = 1.0) -> UIColor {
        var colorCode = colorCode
        colorCode = colorCode.replacingOccurrences(of: "#", with: "", options: NSString.CompareOptions.literal, range: nil)
        let scanner = Scanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
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
        //self.myGLKView!.drawableDepthFormat = GLKViewDrawableDepthFormat.formatNone
        // in 3D we'll often need the depth buffer, e.g.:
        self.myGLKView!.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
        
        self.setupGL()
        setButtons()
        loadObj()
        
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
        /*self.effect = GLKBaseEffect()
        self.effect!.light0.enabled = GLboolean(GL_TRUE)
        self.effect!.light0.diffuseColor = GLKVector4Make(1.0, 0.4, 0.4, 1.0)*/
        // in 2D, we don't need depth/Z-buffer:
        glEnable(GLenum(GL_DEPTH_TEST))
        
        
        // the vertices we draw are stored in an array:
        glGenVertexArrays(1, &myVertexArray)
        glBindVertexArray(myVertexArray)
        
        glGenBuffers(1, &myVertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertexBuffer)
        // define where the vertex buffer is going to find its data:
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * drawvertices.count),
                     &drawvertices,
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
                              3, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              32, obtainUnsafePointer(0) )
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              2, GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                              32, obtainUnsafePointer(12) )
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
         glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, obtainUnsafePointer(20))
        /* glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue
         glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, obtainUnsafePointer(24))*/
        
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
   
    func animateObj()
    {
        /*let newLayer = CALayer()
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.fromValue = 0.0
        rotation.toValue = 200.0
        rotation.duration = 5
        rotation.repeatCount = .infinity
        
        newLayer.add(rotation, forKey: "rotation")
        //rotation += Float(self.timeSinceLastUpdate * 0.5)
         //layer = newLayer
        self.view.layer.addSublayer(newLayer)
        */
        var i=0
        while i<100 {
        let rot = myRotate(x1: 0.5, y1: 0.5, z: 0.0)
        myRotateMat = matrixMultiply(mat1: myRotateMat, mat2: rot)
        let res = matrixMultiply(mat1: myScaleMat, mat2: myTranslateMat)
        let res2 = matrixMultiply(mat1: myRotateMat, mat2: res)
        gMat = res2
        i+=1
        }
    }
    func updateModellingMatrix() {
        
        switch topSelection {
            
        case 0: let rot = myRotate(x1: myDelta_x, y1: myDelta_y, z: 0.0)
        //let trans_inv = myTranslate(x: -CofMX, y: -CofMY, z: -CofMZ)
        //let trans = myTranslate(x: CofMX, y: CofMY, z: CofMZ)
        //let res = matrixMultiply(mat1: rot, mat2: trans_inv)
        //let res_mat = matrixMultiply(mat1: trans, mat2: res)
        myRotateMat = matrixMultiply(mat1: myRotateMat, mat2: rot)
            
        case 1: CofMX = (myDelta_x * 2.0 + CofMX)  //1+(-0.5)
        CofMY = (myDelta_y * 2.0 + CofMY)
        myTranslateMat = myTranslate(x: CofMX, y: CofMY, z: CofMZ)
        NSLog("CofMX: \(CofMX), CofMY: \(CofMY), scalez: \(ScaleZ)")
            //myTranslateMat = matrixMultiply(mat1: myTranslateMat, mat2: res)
            
        case 2: CofMX = myDelta_x + CofMX
        CofMZ = myDelta_y + CofMZ
        myTranslateMat = myTranslate(x: CofMX, y: CofMY, z: CofMZ)
            
        case 3: ScaleX += myDelta_x + myDelta_y
        ScaleY = powf(2.0, ScaleX)
        ScaleZ = ScaleY
        NSLog("ScaleX: \(ScaleX), ScaleY: \(ScaleY), ScaleZ: \(ScaleZ)")
        myScaleMat = myScale(x: ScaleY, y: ScaleY, z: ScaleZ)
            
        default: NSLog("Wrong Button clicked: \(topSelection)")
        }
        let res = matrixMultiply(mat1: myScaleMat, mat2: myTranslateMat)
        let res2 = matrixMultiply(mat1: myRotateMat, mat2: res)
        gMat = res2
        
    } // end of updateModellingMatrix()
    
    
    
    func updateViewingMatrix() {
        
        switch topSelection {
            
        case 0: let res = myRotate(x1: myDelta_x, y1: myDelta_y, z: 0.0)
        let res_mat = matrixMultiply(mat1: myRotateMatCam, mat2: res)
        //res = myTranslate(x: 0.0, y: 0.0, z: -0.5)
        myRotateMatCam = res_mat //matrixMultiply(mat1: res, mat2: res_mat)
            
        case 1: CamX = myDelta_x + CamX
        CamY = myDelta_y + CamY
        myTranslateMatCam = myTranslate(x: -CamX, y: -CamY, z: -CamZ-5.0)
            //myTranslateMatCam = matrixMultiply(mat1: myTranslateMatCam, mat2: res)
            
        case 2: CamX = myDelta_x + CamX
        CamZ = myDelta_y + CamZ
        myTranslateMatCam = myTranslate(x: -CamX, y: -CamY, z: -CamZ-5.0)
            
        default: NSLog("Wrong Button clicked: \(topSelection)")
        }
        let res = matrixMultiply(mat1: myRotateMatCam, mat2: myScaleMatCam)
        let res2 = matrixMultiply(mat1: myTranslateMatCam, mat2: res)
        gMatView = res2
        
    } //end of updateViewingMatrix()
    
    
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
        glUniformMatrix4fv(myMat4Uniform, 1, GLboolean(GL_FALSE), gMat)
        glUniformMatrix4fv(myMat4ViewUniform, 1, GLboolean(GL_FALSE), gMatView)
        glUniform1f(self.myFoVUniform, myFoV)
        glUniform1f(self.myAspectUniform,GLfloat(myAspect))
        glUniform1f(self.myNearUniform,GLfloat(myNear))
        glUniform1f(self.myFarUniform,GLfloat(myFar))
        
        // SOLUTION: don't change the gVertexData array in the drawing function!
        glEnable(GLenum(GL_DEPTH_TEST))
        if (bottomSelection == 2)
        {
            //var a = 0
            //while bottomSelection == 2{
            animateObj()
            
            //a+=1
            // }
        }
        
        //DRAWING CUBE
        
        //gVertexData = drawvertices
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
        // define where the vertex buffer is going to find its data:
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     GLsizeiptr(MemoryLayout<GLfloat>.size * drawvertices.count),
                     &drawvertices,
                     GLenum(GL_STATIC_DRAW))
        
        // enable which kind of attributes the buffer data is going to use:
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, obtainUnsafePointer(0))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, obtainUnsafePointer(12))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, obtainUnsafePointer(20))
        
        glUniform4f(self.myColorUniform,
                    gColorData[1][0],
                    gColorData[1][1],
                    gColorData[1][2],
                    gColorData[1][3])
        
        let size = (drawvertices.count)/8
        //NSLog("size:\(size)")
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(size))
        
        // now "break" the vertex array binding:
        glBindVertexArray(0)
        
    } // end of glkView( ... drawInRect: )
    
    
    
    
    
    func loadObj()
    {
        var f_count = 0
        //NSURL file = NS
        
        // let someText = NSString(string:"some text")
        // let destinationPath = "Avent.obj"
        //var file = NSFileManager
        
        /*let location = NSString(string:"./Users/vinitaboolchandani/Desktop/MS/Graphics/Avent.obj").expandingTildeInPath
         let fileContent = try? NSString(contentsOfFile: location, encoding: String.Encoding.utf8.rawValue)
         
         NSLog("contents:\(fileContent)")
         var comp: [String] = (fileContent?.components(separatedBy: "\n"))!
         */
        drawvertices.removeAll()
        faces.removeAll()
        normals.removeAll()
        vertices.removeAll()
        drawnormals.removeAll()
        texture.removeAll()
        let filePath = Bundle.main.path(forResource: "Avent", ofType:"obj")
        do {
            let input_data = try String(contentsOfFile: filePath!, encoding: String.Encoding.utf8);
            //NSLog("\(input_data)")
            //let message = "\(input_data)"
            let lines = input_data.components(separatedBy: "\n")
            //NSLog("\(lines)")
            
            var str_vertices = [String]()
            var str_normals = [String]()
            var string_faces = [String]()
            var string_texture = [String]()
            
            for i in stride(from: 0, to: lines.count, by: 1 ){
                //if lines[i] == "v"{
                let comps = lines[i].components(separatedBy: " ")
                //NSLog("comps = \(comps)")
                
                if comps[0] == "v"{
                    str_vertices += [comps[1], comps[2], comps[3]]
                }
                
                if comps[0] == "vn"{
                    str_normals += [comps[1], comps[2], comps[3]]
                }
                
                if comps[0] == "vt"{
                    string_texture += [comps[1], comps[2]]
                }
                
                if comps[0] == "f"{
                    f_count += 1
                    if comps.count <= 4
                    {
                        string_faces += [comps[1], comps[2], comps[3]]
                    }
                    else {
                        var k=2
                        while k <= comps.count - 2
                        {
                            //string_faces += ,
                            string_faces += [comps[1], comps[k], comps[k+1]]
                            k+=1
                        }
                        //string_faces += [comps[k]]
                    }
                }
                
                
                //}
            }
            
            //NSLog("vertices = \(str_vertices)")
            //NSLog("normals = \(str_normals)")
            NSLog("string faces = \(string_faces.count)")
            NSLog("f count = \(f_count)")
            
            var str_faces = [String]()
            for j in stride(from: 0, to: string_faces.count, by: 1){
                let faceSTR = string_faces[j].components(separatedBy: "/")
                str_faces += faceSTR
                
            }
            NSLog("str faces = \(str_faces.count)")
            
            var float_vertices = [GLfloat]()
            var float_normals = [GLfloat]()
            var float_faces = [GLint]()
            var float_textures = [GLfloat]()
            
            //var vertices = [GLfloat]()
            //var normals = [GLfloat]()
            //var faces = [GLint]()
            
            for i in stride(from: 0, to: str_vertices.count, by: 1){
                float_vertices = [(str_vertices[i] as NSString).floatValue]
                vertices += float_vertices
            }
            for i in stride(from: 0, to: str_normals.count, by: 1){
                float_normals = [(str_normals[i] as NSString).floatValue]
                normals += float_normals
            }
            for i in stride(from: 0, to: string_texture.count, by: 1){
                float_textures = [(string_texture[i] as NSString).floatValue]
                texture += float_textures
            }
            for i in stride(from: 0, to: str_faces.count, by: 1){
                float_faces = [(str_faces[i] as NSString).intValue]
                faces += float_faces
            }
            
            
        }
        catch {NSLog("file not read")}
        
        NSLog("vertices = \(vertices.count)")
        NSLog("faces = \(faces.count)")
        var i = 0
        while i<faces.count{
        //for i in stride(from: 0, to: faces.count, by: 1){
            
            //var index: GLint
            var index: Int = (Int(faces[i]))-1
            
            let drawvertex = [vertices[Int(index*3)], vertices[Int(index*3)+1], vertices[(index*3)+2]]
            
            //NSLog("index = \(index)")
            //NSLog("draw vertex = \(drawvertex)")
            drawvertices += drawvertex
            i+=1
            
            index = (Int(faces[i]))-1
            if index == -1 {
                index += 1
             let drawtexture = [texture[Int(index*2)], texture[Int(index*2)+1]]
            //drawnormals += drawnormal
            drawvertices += drawtexture
            }
            else
            {
                let drawtexture = [texture[Int(index*2)], texture[Int(index*2)+1]]
                //drawnormals += drawnormal
                drawvertices += drawtexture
                
            }
            i+=1
            
            index = (Int(faces[i]))-1
            let drawnormal = [normals[Int(index*3)], normals[Int(index*3)+1], normals[(index*3)+2]]
            //drawnormals += drawnormal
            drawvertices += drawnormal
            i+=1
        }
        
        NSLog("draw vertices = \(drawvertices[0])")
        NSLog("draw normals = \(drawnormals.count)")
        
        
        
    }
    
    
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
                
                let lViX = gVertexData[i*2]
                let lViY = gVertexData[i*2 + 1]
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
                                   gVertexData[i*2], gVertexData[i*2 + 1],
                                   gVertexData[i*2 + 2], gVertexData[i*2 + 3])
                dist =  fabs(vlinedist(
                    self.myTouchXbegin, self.myTouchYbegin,
                    gVertexData[i*2], gVertexData[i*2 + 1],
                    gVertexData[i*2 + 2], gVertexData[i*2 + 3] ))
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
            
            let num = testInsideButtons(firstTouchPoint)
            if(num == 1) {return}
            
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
            
            // we are in the "we've just began" phase of the touch event sequence:
            self.myTouchPhase = UITouchPhase.began
            
            //if (proximityTest())
            //{
            myfirstTouchX = self.myTouchXbegin
            myfirstTouchY = self.myTouchYbegin
            //myDelta_x = 0.0
            //myDelta_y = 0.0
            //}
            // SOLUTION task B:
            // if not close to a vertex, nor close to a line, add a vertex:
            if (bottomSelection == 2)
            {
                //var a = 0
                //while bottomSelection == 2{
                    animateObj()
                    
                    //a+=1
               // }
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
            
            //let ratio = fabsf(Float(self.view.bounds.size.width/self.view.bounds.size.height)) * 50
            /*myDelta_x = (self.myTouchXcurrent - myfirstTouchX) / 500.0 - myDelta_x
             myDelta_y = (self.myTouchYcurrent - myfirstTouchY) / 500.0 - myDelta_y*/
            
            myDelta_x = (self.myTouchXcurrent - self.myTouchXold)/60.0
            myDelta_y = (self.myTouchYcurrent - self.myTouchYold)/70.0
            
            NSLog("myDelta_x:\(myDelta_x), myDelta_y:\(myDelta_y)\n")
            if (bottomSelection == 3) {
                updateViewingMatrix()
            }
            else if (bottomSelection == 2)
            {
                /*var i = 0
                while i < 1000000
                {
                    */animateObj()
                  //  i+=1
                //}
                
            }
            else {
                updateModellingMatrix()
            }
            // SOLUTION task C : move vertex or line segment:
            /* if (self.myLitType == G_LIT.NONLIT) {
             // SOLUTION task A: modify the current vertex, if entering a new
             //   vertex to the gVertexData Swift array of floats:
             gVertexData[2 * (self.myEnteredVertices-1)] = self.myTouchXcurrent
             gVertexData[(2 * (self.myEnteredVertices-1)) + 1] = self.myTouchYcurrent
             } else if (self.myLitType == G_LIT.LITVERTEX) {
             // SOLUTION task B: if close to a vertex, or close to a line, move highlighted element:
             gVertexData[2 * self.myLitID] += (self.myTouchXcurrent - self.myTouchXold)
             gVertexData[2 * self.myLitID + 1] += (self.myTouchYcurrent - self.myTouchYold)
             } else if (self.myLitType == G_LIT.LITLINE){
             gVertexData[2 * self.myLitID] += (self.myTouchXcurrent - self.myTouchXold)
             gVertexData[2 * self.myLitID + 1] += (self.myTouchYcurrent - self.myTouchYold)
             gVertexData[2 * self.myLitID + 2] += (self.myTouchXcurrent - self.myTouchXold)
             gVertexData[2 * self.myLitID + 3] += (self.myTouchYcurrent - self.myTouchYold)
             }
             
             */
            
            
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
            
            // SOLUTION: stop highlighting when touch event is off:
            self.myLitType = G_LIT.NONLIT
            self.myLitID = -1
            
            //myDelta_x = 0.001
            //myDelta_y = 0.001
            //myfirstTouchX = 0.0
            //myfirstTouchY = 0.0
            
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
        glBindAttribLocation(myGLESProgram,
                             GLuint(GLKVertexAttrib.position.rawValue),
                             "a_Position")
        glBindAttribLocation(myGLESProgram, GLuint(GLKVertexAttrib.normal.rawValue), "normal")
        glBindAttribLocation(myGLESProgram, GLuint(GLKVertexAttrib.texCoord0.rawValue), "texture")
        //glBindAttribLocation(myGLESProgram, GLuint(GLKVertexAttrib.texCoord1.rawValue), "color")
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
        //self.myColorUniform = glGetUniformLocation(myGLESProgram, "u_Color")
        self.myFoVUniform = glGetUniformLocation(myGLESProgram, "u_FoV")
        self.myAspectUniform = glGetUniformLocation(myGLESProgram, "u_Aspect")
        self.myNearUniform = glGetUniformLocation(myGLESProgram, "u_Near")
        self.myFarUniform = glGetUniformLocation(myGLESProgram, "u_Far")
        self.myMat4Uniform = glGetUniformLocation(myGLESProgram, "u_Mat4")
        self.myMat4ViewUniform = glGetUniformLocation(myGLESProgram, "u_Mat4View")
        uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(myGLESProgram, "normalMatrix")
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

var gVertexData: [GLfloat] = []
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    /*0.5, -0.5, -0.5,        1.0, 0.0, 0.0,          1.0, 0.0, 0.0, 1.0,
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
    -0.5, 0.5, -0.5,        0.0, 0.0, -1.0,        1.0, 0.0, 1.0, 1.0*/
    
//]

