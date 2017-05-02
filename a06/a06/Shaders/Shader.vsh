//
//  Shader.vsh
//  a06
//
//  Created by Vinita Boolchandani on 2017-04-27.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//

uniform float u_Width;
uniform float u_Height;
uniform mat4 u_Mat4;
uniform mat4 u_Mat4View;
uniform float u_FoV;
uniform float u_Aspect;
uniform float u_Near;
uniform float u_Far;
varying lowp vec4 colorVarying;
attribute vec2 texCoord;
attribute vec4 a_Position;
attribute vec3 normal;
varying lowp vec2 texCoordVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;


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

mat4 myTranslate(float pTX, float pTY, float pTZ) {
    // the returned matrix is defined "transposed", i.e. the last row
    //   is really the last column as used in matrix multiplication:
    return mat4(  1.0,         0.0,         0.0,      0.0,
                0.0,         1.0,         0.0,      0.0,
                0.0,         0.0,         1.0,      0.0,
                pTX,         pTY,         pTZ,      1.0   );
}


// define a varying variable:
//varying vec2 var_Position;
//varying vec2 tex_coord;
void main() {
    
    //vec3 MaterialDiffuseColor = vec3(0.00, 0.00, 1.00);
    /*vec3 Ka = vec3(0.00, 0.00, 0.00);
    //Tf 1.00 1.00 1.00
    float  Ni 1.00
    vec3 Ks = vec3(0.00, 0.00, 0.00);*/
    vec3 n = normalize(normal );
    vec3 lightPosition1 = vec3(0.0, 1.0, 1.0);
    vec3 l = normalize( lightPosition1 );
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 LightColor = vec3(1.0, 1.0, 1.0);
    vec3 LightPower = vec3(1.0,1.0,1.0);
    float cosTheta = max(0.0, dot(n, l));
    
    vec3 MaterialAmbientColor = vec3(1.0,1.0,1.0);
    vec3 MaterialDiffuseColor = vec3(0.1,0.1,1.0);
    vec3 MaterialSpecularColor = vec3(1.0, 1.0, 1.0);
    //vec3 E = normalize(eyeNormal);
    vec3 R = reflect(-l,n);
    float cosAlpha = max(dot(eyeNormal,R ), 0.0 );
    
    colorVarying.xyz = MaterialAmbientColor + MaterialDiffuseColor * LightColor * LightPower * cosTheta + MaterialSpecularColor * LightColor * LightPower * cosAlpha;
    
        
    texCoordVarying = texCoord;
    mat4 projectionMatrix = myGLUPerspective(u_FoV, u_Aspect, u_Near, u_Far);
    gl_Position = projectionMatrix * u_Mat4View * u_Mat4 * a_Position;
    //var_Position = gl_Position.xy;
}
