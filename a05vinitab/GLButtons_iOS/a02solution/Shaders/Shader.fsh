//
//  Shader.fsh
//  a02solution
//
//  Created by Mitja Hmeljak on 2017-02-23.
//  Copyright © 2017 B481 Spring 2017. All rights reserved.
//


precision mediump float;

varying vec2 var_Position;

varying lowp vec4 colorVarying;

void main() {
    // TODO: try using the varying var_Position variable from the vertex shader
    // to set color values smoothly varying within a line segment:
    // e.g. from full color on one vertex,
    //   to another color in the middle of the line segment,
    //   and back to full color on the other vertex
    // Hint: you may use abs(...)
    gl_FragColor = colorVarying;//vec4( u_Color.r, u_Color.g, u_Color.b, u_Color.a );
}
