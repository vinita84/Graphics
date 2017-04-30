//
//  Shader.fsh
//  a06
//
//  Created by Vinita Boolchandani on 2017-04-27.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//


precision mediump float;
uniform vec4 u_Color;
varying vec2 var_Position;
uniform sampler2D tex;
varying lowp vec4 colorVarying;
varying lowp vec4 text;
varying vec2 tex_coord;
uniform vec4 DiffuseProduct;
//uniform sampler2D tex;

void main() {
    // TODO: try using the varying var_Position variable from the vertex shader
    // to set color values smoothly varying within a line segment:
    // e.g. from full color on one vertex,
    //   to another color in the middle of the line segment,
    //   and back to full color on the other vertex
    // Hint: you may use abs(...)
    //vec4 color = texture2D(tex,text.st);
    
    //vec4 N = texture2D(tex, tex_coord);
    //vec3 NN = normalize(2.0*N.xyz-1.0);
   // vec3 LL = normalize(colorVarying.xyz);
    //float Kd = max(dot(N, colorVarying), 0.0);
    //gl_FragColor = Kd*DiffuseProduct;
    gl_FragColor = colorVarying;// * texture2D(tex, tex_coord);//vec4( u_Color.r, u_Color.g, u_Color.b, u_Color.a );
}
