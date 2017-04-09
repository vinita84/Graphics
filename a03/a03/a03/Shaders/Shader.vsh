//
//  Shader.vsh
//  a03template
//
//  Created by Mitja Hmeljak on 2017-03-02.
//  Copyright 2017 B581 Spring 2017. All rights reserved.
//

uniform float u_Width;
uniform float u_Height;

uniform float u_TX;
uniform float u_TY;
uniform float u_sinA;
uniform float u_theta;
uniform float fixed_X;
uniform float fixed_Y;

attribute vec4 a_Position;

mat4 myOrtho2D(float pLeft, float pRight, float pBottom, float pTop) {
    float lNear = -1.0;
    float lFar = 1.0;
    float rl = pRight-pLeft;
    float tb = pTop-pBottom;
    float fn = lFar-lNear;
    // the returned matrix is defined "transposed", i.e. the last row
    //   is really the last column as used in matrix multiplication:
    return mat4(  2.0/rl,                0.0,              0.0,  0.0,
                0.0,             2.0/tb,              0.0,  0.0,
                0.0,                0.0,          -2.0/fn,  0.0,
                -(pRight+pLeft)/rl, -(pTop+pBottom)/tb, -(lFar+lNear)/fn,  1.0 );
}

mat4 myTranslate2D(float pTX, float pTY) {
    // the returned matrix is defined "transposed", i.e. the last row
    //   is really the last column as used in matrix multiplication:
    return mat4(  1.0,         0.0,         0.0,      0.0,
                0.0,         1.0,         0.0,      0.0,
                0.0,         0.0,         1.0,      0.0,
                pTX,         pTY,         0.0,      1.0   );
}

mat4 myRotate2D(float A) {
    // the returned matrix is defined "transposed", i.e. the last row
    //   is really the last column as used in matrix multiplication:
    return mat4( cos(A),         sin(A),         0.0,      0.0,
                -sin(A),         cos(A),         0.0,      0.0,
                    0.0,            0.0,         1.0,      0.0,
                    0.0,            0.0,         0.0,      1.0   );
}

// define a varying variable:
varying vec2 var_Position;

void main() {
    
    gl_PointSize = 10.0;
    
    mat4 projectionMatrix = myOrtho2D(0.0, u_Width, 0.0, u_Height);
    
    mat4 rotateMatrix = myTranslate2D(fixed_X, fixed_Y) * myRotate2D(u_theta) * myTranslate2D(-fixed_X, -fixed_Y);
    mat4 modelViewMatrix = myTranslate2D(u_TX, u_TY) * rotateMatrix;
   // mat4 rotateMatrix = myRotate2D(u_sinA, u_cosA);
    //mat4 transMatrix = myTranslate2D(fixed_X, fixed_Y);
    gl_Position = projectionMatrix * modelViewMatrix * a_Position;
    //gl_Position = projectionMatrix * modelViewMatrix * a_Position;
    
    // the value for var_Position is set in this vertex shader,
    // then it goes through the interpolator before being
    // received (interpolated!) by a fragment shader:
    var_Position = gl_Position.xy;
}
