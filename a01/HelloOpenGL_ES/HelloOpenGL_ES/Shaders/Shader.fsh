//
//  Shader.fsh
//  HelloOpenGL_ES
//
//  Created by VINITA BOOLCHANDANI on 05/02/17.
//  Copyright © 2017 B581 Spring 2017. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
