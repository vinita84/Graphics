//
//  Shader.vsh
//  a04Spline2
//
//  Created by VINITA BOOLCHANDANI on 07/03/17.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//

uniform float u_Width;
uniform float u_Height;
uniform vec2 u_ControlPoints[];
attribute vec4 a_Position;
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
    float b = 1.00;
    float Gy = u_ControlPoints[3].y;
    float Gx = u_ControlPoints[3].x;
    float Fy = u_ControlPoints[2].y;
    float Fx = u_ControlPoints[2].x;
    float Ey = u_ControlPoints[1].y;
    float Ex = u_ControlPoints[1].x;
    float Dy = u_ControlPoints[0].y;
    float Dx = u_ControlPoints[0].x;
    vec4 a;
    a.x = ((b-t)*(b-t)*(b-t)*Dx)+(3.00*t*(b-t)*(b-t)*Ex)+(3.00*t*t*(b-t)*Fx)+(t*t*t*Gx);
    a.y = ((b-t)*(b-t)*(b-t)*Dy)+(3.00*t*(b-t)*(b-t)*Ey)+(3.00*t*t*(b-t)*Fy)+(t*t*t*Gy);
    //float arr[4] = float[](1.00, t, t*t, t*t*t);
    /*mat4 arr1;
    arr1[0] = vec4(1, t, t*t, t*t*t);
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
    return a;
}



// define a varying variable:
varying vec2 var_Position;

void main() {
    
    mat4 projectionMatrix = myOrtho2D(0.0, u_Width, 0.0, u_Height);
    vec4 aPos = interpolateSpline(a_Position.x);
    gl_PointSize = 10.0;

    /*    aPos.x = 100.0;
    aPos.y = 100.0;
    aPos.z = 0.0;
    aPos.w = 1.0;
  */  //gl_Position = projectionMatrix * a_Position;
    gl_Position = projectionMatrix * aPos;
    // the value for var_Position is set in this vertex shader,
    // then it goes through the interpolator before being
    // received (interpolated!) by a fragment shader:
    var_Position = gl_Position.xy;
}
