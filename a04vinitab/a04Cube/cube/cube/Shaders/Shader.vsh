//
//  Shader.vsh
//  a02solution
//
//  Created by Mitja Hmeljak on 2017-02-23.
//  Copyright © 2017 B481 Spring 2017. All rights reserved.
//

uniform float u_FoV;
uniform float u_Aspect;
uniform float u_Near;
uniform float u_Far;
uniform float u_DeltaX;
uniform float u_DeltaY;
/*uniform float u_Tx = 0.0;
 uniform float u_Ty = 0.0;
 uniform float u_Tz = -500.0;
 */attribute vec4 a_Position;
attribute vec4 color;
//  ...
//attribute vec4 position;
attribute vec3 normal;
varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;


// function that computes a 3D translation matrix:
mat4 myTranslate(float pTX, float pTY, float pTZ) {
    // the returned matrix is defined "transposed", i.e. the last row
    //   is really the last column as used in matrix multiplication:
    return mat4(  1.0,         0.0,         0.0,      0.0,
                0.0,         1.0,         0.0,      0.0,
                0.0,         0.0,         1.0,      0.0,
                pTX,         pTY,         pTZ,      1.0   );
}

mat4 myRotate2D(float A) {
    // the returned matrix is defined "transposed", i.e. the last row
    //   is really the last column as used in matrix multiplication:
    return mat4( cos(A),         sin(A),         0.0,      0.0,
                -sin(A),         cos(A),         0.0,      0.0,
                0.0,            0.0,         1.0,      0.0,
                0.0,            0.0,         0.0,      1.0   );
}

// function that computes a 3D perspective transformation matrix:
mat4 myGLUPerspective(in float pFoV, in float pAspect, in float pNear, in float pFar)  {
    
    mat4 lPerspectiveMatrix = mat4(0.0);
    
    float lAngle = (pFoV / 180.0) * 3.14159;
    float lFocus = 1.0 / tan ( lAngle * 0.5 );
    
    
    lPerspectiveMatrix[0][0] = lFocus / pAspect;
    lPerspectiveMatrix[1][1] = lFocus;
    lPerspectiveMatrix[2][2] = (pFar + pNear) / (pNear - pFar);
    lPerspectiveMatrix[2][3] = -1.0;
    lPerspectiveMatrix[3][2] = (2.0 * pFar * pNear) / (pNear - pFar);
    
    return lPerspectiveMatrix;
}



//  ...

varying vec2 var_Position;
void main() {
    gl_PointSize = 10.0;
    /*vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));*/
    
    colorVarying = color; //diffuseColor * nDotVP;

    mat4 projectionMatrix = myGLUPerspective(u_FoV, u_Aspect, u_Near, u_Far);
    
    //mat4 rotationMatrix = myRotate2D(40.0);
    
    mat4 modelViewMatrix = myTranslate(u_DeltaX, u_DeltaY, -1.05);
    
    gl_Position = projectionMatrix * modelViewMatrix * a_Position;
    
    //gl_Position = modelViewProjectionMatrix * a_Position;
    var_Position = gl_Position.xy;
    //  ...
    
}
