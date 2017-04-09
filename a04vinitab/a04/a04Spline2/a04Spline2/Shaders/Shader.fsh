//
//  Shader.fsh
//  a03Spline
//
//  Created by VINITA BOOLCHANDANI on 07/03/17.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//

precision mediump float;

varying vec2 var_Position;

uniform vec4 u_Color;

void main() {
    // TODO: try using the varying var_Position variable from the vertex shader
    // to set color values smoothly varying within a line segment:
    // e.g. from full color on one vertex,
    //   to another color in the middle of the line segment,
    //   and back to full color on the other vertex
    // Hint: you may use abs(...)
    gl_FragColor = vec4( u_Color.r, u_Color.g, u_Color.b, u_Color.a );
}
