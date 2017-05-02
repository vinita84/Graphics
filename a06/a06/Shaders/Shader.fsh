//
//  Shader.fsh
//  a06
//
//  Created by Vinita Boolchandani on 2017-04-27.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//



//uniform vec4 u_Color;
//uniform vec4 DiffuseProduct;
varying lowp vec2 texCoordVarying;
varying lowp vec4 colorVarying;

uniform sampler2D textureUniform;

void main()
{
    gl_FragColor = colorVarying * texture2D(textureUniform, texCoordVarying);
}
