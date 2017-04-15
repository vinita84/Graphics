//
//  Shader.vsh
//  a04Spline2
//
//  Created by VINITA BOOLCHANDANI on 07/03/17.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//

uniform float u_Width;
uniform float u_Height;
uniform float u_ControlPoints[60];
uniform int u_PrimitiveType;
attribute vec4 a_Position;
uniform int u_SplineNum;
//attribute vec3 gVertexData[];


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


vec4 interpolateSpline (float t)
{
    //var t = a_Position.x;
    //float b = 1.0 - t;
    int i = ((u_SplineNum*3)+1)*2-1;
    float Gy = u_ControlPoints[i];
    float Gx = u_ControlPoints[i-1];
    float Fy = u_ControlPoints[i-2];
    float Fx = u_ControlPoints[i-3];
    float Ey = u_ControlPoints[i-4];
    float Ex = u_ControlPoints[i-5];
    float Dy = u_ControlPoints[i-6];
    float Dx = u_ControlPoints[i-7];
    vec4 a;
    a.x = ((1.0-t)*(1.0-t)*(1.0-t)*Dx)+(3.0*t*(1.0-t)*(1.0-t)*Ex)+(3.0*t*t*(1.0-t)*Fx)+(t*t*t*Gx);
    a.y = ((1.0-t)*(1.0-t)*(1.0-t)*Dy)+(3.0*t*(1.0-t)*(1.0-t)*Ey)+(3.0*t*t*(1.0-t)*Fy)+(t*t*t*Gy);
    /*arr1[0] = vec4(1, t, t*t, t*t*t);
    arr1[1] = vec4(0, 0, 0, 0);
    arr1[2] = vec4(0, 0, 0, 0);
    arr1[3] = vec4(0, 0, 0, 0);
    mat4 arr2 = mat4(1, 0, 0, 0,
                    -3, 3, 0, 0,
                     3, -6, 3, 0,
                     -1, -3, -3, 1);
    vec4 arr3 = vec4(Dx, Ex, Fx, Gx);
    vec4 arr4 = vec4(Dy, Ey, Fy, Gy);
    vec4 a;
    a.x = (vec4(arr1 * arr2 * arr3)).x;
    a.y = (vec4(arr1 * arr2 * arr4)).x;*/
    a.z = 0.0;
    a.w = 1.0;
    return a;
}



// define a varying variable:
varying vec2 var_Position;

void main() {
    
    mat4 projectionMatrix = myOrtho2D(0.0, u_Width, 0.0, u_Height);
    gl_PointSize = 10.0;
    if (u_PrimitiveType == 3)
    {
        vec4 a_Pos = interpolateSpline(a_Position.x);
        gl_Position = projectionMatrix * a_Pos;
    }
    else
    {
        gl_Position = projectionMatrix * a_Position;
    }
    

    /*    aPos.x = 100.0;
    aPos.y = 100.0;
    aPos.z = 0.0;
    aPos.w = 1.0;
  */  //gl_Position = projectionMatrix * a_Position;
    
    // the value for var_Position is set in this vertex shader,
    // then it goes through the interpolator before being
    // received (interpolated!) by a fragment shader:
    var_Position = gl_Position.xy;
}
